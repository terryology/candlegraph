get_brief <- function(target_brand) {
  
  # Load data if not already in environment
  if (!exists("brand_rankings")) source(here::here("data_sync.R"))
  
  # Find brand (case-insensitive)
  b <- brand_rankings %>%
    filter(tolower(brand_name) == tolower(target_brand))
  
  if (nrow(b) == 0) stop(paste("Brand not found:", target_brand))
  
  # Quadrant Logic
  # Note: Tier is determined AFTER confidence tax has been applied in data_sync.R
  current_tier <- case_when(
    b$pae_index >= 100 & b$sav_index >= 100 ~ "Grail",
    b$pae_index <  100 & b$sav_index >= 100 ~ "Overachiever",
    b$pae_index >= 100 & b$sav_index <  100 ~ "Workhorse",
    TRUE                                    ~ "Dud"
  )
  
  # Confidence note for small samples
  # Tax is already applied to scores in data_sync.R
  confidence_note <- if_else(
    b$n_candles < 3,
    paste0("\n\n<!-- NOTE: 20% Confidence Tax applied to scores (N = ", b$n_candles, " < 3) -->"),
    ""
  )
  
  # Build shortcode strings
  specs_shortcode <- sprintf(
    '{{< brand-specs brand="%s" sav="%.1f" pae="%.1f" tier="%s" >}}',
    b$brand_name,
    b$sav_index,
    b$pae_index,
    current_tier
  )
  
  audit_shortcode <- sprintf(
    '{{< vault-audit brand="%s" id="AUDIT-%s" sessions="%d" hours="%.1f" confidence="%s" >}}',
    b$brand_name,
    toupper(substr(b$brand_name, 1, 3)),
    b$n_candles,
    b$total_hrs,
    ifelse(b$is_verified, "Empirical", "Anecdotal")
  )
  
  # Print to console for copy/paste into post
  cat("\n--- HUGO SPECS ---\n")
  cat(specs_shortcode)
  cat(confidence_note)
  
  cat("\n\n--- HUGO FOOTNOTE ---\n")
  cat(audit_shortcode)
  cat("\n")
  
  # Return invisibly for programmatic use
  invisible(list(
    brand      = b$brand_name,
    tier       = current_tier,
    sav        = b$sav_index,
    pae        = b$pae_index,
    specs      = specs_shortcode,
    audit      = audit_shortcode,
    low_sample = b$n_candles < 3
  ))
}

get_candle_brief <- function(target_brand, target_scent) {
  
  # Load data if not already in environment
  if (!exists("df_master")) source(here::here("data_sync.R"))
  
  # 1. Filter the master dataframe created in data_sync.R
  candle_sessions <- df_master %>%
    filter(tolower(brand_name) == tolower(target_brand),
           tolower(scent_name) == tolower(target_scent))
  
  if (nrow(candle_sessions) == 0) {
    stop(paste("No data found for:", target_brand, "-", target_scent))
  }
  
  # 2. Aggregate stats using Hybrid Logic
  stats <- candle_sessions %>%
    summarise(
      price = first(price_usd),
      actual_burn_hrs = sum(total_time, na.rm = TRUE),    # Total physical life
      effective_hrs   = sum(effective_time, na.rm = TRUE), # "Rule of Four" life
      .groups = "drop"
    )
  
  # 3. Efficiency Calculation (The "Terryology" standard)
  # Uses effective_hrs to penalize over-burning beyond 4 hours
  efficiency_val <- (stats$effective_hrs * 60) / stats$price
  cost_hr_val <- stats$price / stats$actual_burn_hrs # Consumer cost per hour
  
  # 4. Generate Shortcode
  cat("\n--- CANDLE SPECS SHORTCODE ---\n")
  cat(sprintf(
    '{{< candle-specs price="%.2f" burn="%.1f" efficiency="%.0f" cost_hour="%.2f" >}}',
    stats$price, stats$actual_burn_hrs, efficiency_val, cost_hr_val
  ))
  cat("\n------------------------------\n")
}