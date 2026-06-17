# Throw score label lookups — shared by get_brief() and get_candle_brief()
hot_labels <- c(
  "1" = "Trace", "2" = "Personal", "3" = "Standard",
  "4" = "Strong", "5" = "Powerhouse"
)
cold_labels <- c(
  "1" = "Non-Existent", "2" = "Faint", "3" = "Standard",
  "4" = "Strong", "5" = "Room-Filling"
)

get_brief <- function(target_brand) {
  
  # Load data if not already in environment
  if (!exists("brand_rankings")) source(here::here("data_sync.R"))
  
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
  
  # Print to console for copy/paste into post
  cat("\n--- HUGO SPECS ---\n")
  cat(specs_shortcode)
  cat(confidence_note)
  
  cat("\n\n--- HUGO AUDIT ---\n")
  cat(audit_shortcode)
  
  # Return invisibly for programmatic use
  invisible(list(
    brand            = b$brand_name,
    tier             = current_tier,
    sav              = b$sav_index,
    pae              = b$pae_index,
    specs            = specs_shortcode,
    audit            = audit_shortcode,
    low_sample       = b$n_candles < 3
  ))
}

get_candle_brief <- function(target_id) {
  
  if (!exists("df_master")) source(here::here("data_sync.R"))
  
  # Filter to this candle's sessions
  d <- df_master %>%
    filter(candle_id == target_id)
  
  if (nrow(d) == 0) stop(paste("Candle ID not found:", target_id))
  
  # Pull candle metadata (same across all rows for this candle)
  scent_name <- d$scent_name[1]
  brand_name <- d$brand_name[1]
  price      <- d$price_usd[1]
  
  # Session stats
  n_sessions       <- nrow(d)
  avg_session      <- mean(d$total_time, na.rm = TRUE)
  min_session      <- min(d$total_time, na.rm = TRUE)
  max_session      <- max(d$total_time, na.rm = TRUE)
  total_hrs        <- sum(d$total_time, na.rm = TRUE)
  sessions_over_4h <- sum(d$total_time >= 4, na.rm = TRUE)
  avg_cold         <- mean(as.numeric(d$throw_cold), na.rm = TRUE)
  avg_hot          <- mean(as.numeric(d$throw_hot_avg), na.rm = TRUE)
  
  cold_label <- cold_labels[as.character(round(avg_cold))]
  hot_label  <- hot_labels[as.character(round(avg_hot))]
  
  # Derived panel values
  efficiency <- round((total_hrs * 60) / price)
  cost_hour  <- round(price / total_hrs, 2)
  
  # Build shortcodes
  session_shortcode <- sprintf(
    '{{< session-details sessions="%d" avg="%.1f" min="%.1f" max="%.1f" over4h="%d" cold="%.1f" cold-label="%s" hot="%.1f" hot-label="%s" >}}',
    n_sessions, avg_session, min_session, max_session,
    sessions_over_4h, avg_cold, cold_label, avg_hot, hot_label
  )
  
  # Print to console
  cat(sprintf("\n--- %s · %s (ID: %s) ---\n", brand_name, scent_name, target_id))
  
  cat("\n--- FRONT MATTER ---\n")
  cat(sprintf("price: %.2f\n", price))
  cat(sprintf("burn: %.1f\n", total_hrs))
  cat(sprintf("efficiency: %d\n", efficiency))
  cat(sprintf("cost_hour: %.2f\n", cost_hour))
  
  cat("\n--- SESSION DETAILS SHORTCODE ---\n")
  cat(session_shortcode)
  cat("\n")
  
  invisible(list(
    brand            = brand_name,
    scent            = scent_name,
    price            = price,
    burn             = total_hrs,
    efficiency       = efficiency,
    cost_hour        = cost_hour,
    session          = session_shortcode,
    n_sessions       = n_sessions,
    avg_session      = avg_session,
    min_session      = min_session,
    max_session      = max_session,
    sessions_over_4h = sessions_over_4h,
    avg_cold         = avg_cold,
    cold_label       = cold_label,
    avg_hot          = avg_hot,
    hot_label        = hot_label
  ))
}