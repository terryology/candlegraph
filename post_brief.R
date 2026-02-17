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
