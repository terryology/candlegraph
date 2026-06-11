get_brief <- function(target_brand) {
  
  # Load data if not already in environment
  if (!exists("brand_rankings")) source(here::here("data_sync.R"))
  
  # Throw score label lookups
  hot_labels <- c(
    "1" = "Trace",
    "2" = "Personal",
    "3" = "Standard",
    "4" = "Strong",
    "5" = "Powerhouse"
  )
  
  cold_labels <- c(
    "1" = "Non-Existent",
    "2" = "Faint",
    "3" = "Standard",
    "4" = "Strong",
    "5" = "Room-Filling"
  )
  
  # Find brand (case-insensitive)
  b <- brand_rankings %>%
    filter(tolower(brand_name) == tolower(target_brand))
  
  if (nrow(b) == 0) stop(paste("Brand not found:", target_brand))
  
  # Quadrant Logic
  current_tier <- case_when(
    b$pae_index >= 100 & b$sav_index >= 100 ~ "Grail",
    b$pae_index <  100 & b$sav_index >= 100 ~ "Overachiever",
    b$pae_index >= 100 & b$sav_index <  100 ~ "Workhorse",
    TRUE                                    ~ "Dud"
  )
  
  # Throw labels
  cold_label <- cold_labels[as.character(round(b$avg_cold))]
  hot_label  <- hot_labels[as.character(round(b$avg_hot))]
  
  # Confidence note
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
    tolower(current_tier)
  )
  
  audit_shortcode <- sprintf(
    '{{< vault-audit brand="%s" id="AUDIT-%s" candles="%d" hours="%.1f" confidence="%s" >}}',
    b$brand_name,
    toupper(substr(b$brand_name, 1, 3)),
    b$n_candles,
    b$total_hrs,
    ifelse(b$is_verified, "Empirical", "Anecdotal")
  )
  
  session_shortcode <- sprintf(
    '{{< session-details sessions="%d" avg="%.1f" min="%.1f" max="%.1f" over4h="%d" cold="%.1f" cold-label="%s" hot="%.1f" hot-label="%s" >}}',
    b$n_sessions,
    b$avg_session,
    b$min_session,
    b$max_session,
    b$sessions_over_4h,
    b$avg_cold,
    cold_label,
    b$avg_hot,
    hot_label
  )
  
  # Print to console for copy/paste into post
  cat("\n--- HUGO SPECS ---\n")
  cat(specs_shortcode)
  cat(confidence_note)
  
  cat("\n\n--- HUGO AUDIT ---\n")
  cat(audit_shortcode)
  
  cat("\n\n--- HUGO SESSION DETAILS ---\n")
  cat(session_shortcode)
  cat("\n")
  
  # Return invisibly for programmatic use
  invisible(list(
    brand            = b$brand_name,
    tier             = current_tier,
    sav              = b$sav_index,
    pae              = b$pae_index,
    specs            = specs_shortcode,
    audit            = audit_shortcode,
    session          = session_shortcode,
    n_sessions       = b$n_sessions,
    avg_session      = b$avg_session,
    min_session      = b$min_session,
    max_session      = b$max_session,
    sessions_over_4h = b$sessions_over_4h,
    avg_cold         = b$avg_cold,
    cold_label       = cold_label,
    avg_hot          = b$avg_hot,
    hot_label        = hot_label,
    low_sample       = b$n_candles < 3
  ))
}