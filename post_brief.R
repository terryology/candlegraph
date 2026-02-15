# ==========================================
# CANDLEGRAPH: POST-BURN BRIEFING SCRIPT v1.1
# ==========================================
source("data_sync.R") 

get_brief <- function(target_brand) {
  
  # 1. Filter the rankings for the specific brand
  brief_data <- brand_rankings %>%
    filter(brand_name == target_brand)
  
  # Safety check if brand doesn't exist
  if(nrow(brief_data) == 0) {
    return(message("Brand not found. Check spelling or Google Sheet data."))
  }
  
  # 2. Print technical summary to Console
  cat("\n--- DATA AUDIT: ", toupper(target_brand), " ---\n")
  cat("Sample Size: ", brief_data$n_candles, " candle(s) tested\n")
  cat("Data Quality: ", as.character(brief_data$evidence), "\n")
  
  # 3. Format for the Hugo Shortcode (Copy/Paste this)
  cat("\n--- HUGO SHORTCODE ---\n")
  cat(sprintf(
    '{{< brand-specs brand="%s" sav="%.1f" pae="%.1f" tier="%s" >}}',
    brief_data$brand_name,
    brief_data$sav_index,
    brief_data$pae_index,
    tolower(brief_data$pae_index) # Logic placeholder for tier
  ))
  
  # Manual Tier Helper
  tier_suggestion <- case_when(
    brief_data$sav_index >= 100 & brief_data$pae_index >= 100 ~ "Grail",
    brief_data$sav_index >= 100 & brief_data$pae_index < 100  ~ "Overachiever",
    brief_data$sav_index < 100  & brief_data$pae_index >= 100 ~ "Workhorse",
    TRUE                                                     ~ "Dud"
  )
  
  cat("\n\nRecommended Tier: ", tier_suggestion)
  cat("\n----------------------\n")
}

# 4. Format for the Technical Footnote
# We'll calculate total sessions and hours from the raw data
brand_raw <- processed_data %>% filter(brand_name == target_brand)

cat("\n--- HUGO FOOTNOTE ---\n")
cat(sprintf(
  '{{< vault-audit brand="%s" id="%s" sessions="%d" hours="%.1f" confidence="%s" >}}',
  target_brand,
  "Global-ID", # You can swap this for a specific candle ID if you prefer
  brief_data$n_candles, # Using n_candles as a proxy for test volume
  sum(brand_raw$actual_total_hours, na.rm = TRUE),
  as.character(brief_data$evidence)
))
cat("\n----------------------\n")