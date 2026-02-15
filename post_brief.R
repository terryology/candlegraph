get_brief <- function(target_brand) {
  
  if (!exists("brand_rankings")) source("data_sync.R")
  
  # Find brand (case-insensitive)
  b <- brand_rankings %>% 
    filter(tolower(brand_name) == tolower(target_brand))
  
  if (nrow(b) == 0) stop("Brand not found.")
  
  # Quadrant Logic
  current_tier <- case_when(
    b$pae_index >= 100 & b$sav_index >= 100 ~ "Grail",
    b$pae_index < 100  & b$sav_index >= 100 ~ "Powerhouse",
    b$pae_index >= 100 & b$sav_index < 100  ~ "Workhorse",
    TRUE                                    ~ "Dud"
  )
  
  # Output: Top Specs
  cat("\n--- HUGO SPECS ---\n")
  cat(sprintf('{{< brand-specs brand="%s" sav="%.1f" pae="%.1f" tier="%s" >}}',
              b$brand_name, b$sav_index, b$pae_index, current_tier))
  
  # Output: Bottom Audit
  cat("\n\n--- HUGO FOOTNOTE ---\n")
  cat(sprintf('{{< vault-audit brand="%s" id="AUDIT-%s" sessions="%d" hours="%.1f" confidence="%s" >}}',
              b$brand_name, toupper(substr(b$brand_name, 1, 3)),
              b$n_candles, b$total_hrs, ifelse(b$is_verified, "Empirical", "Anecdotal")))
  
  if (b$n_candles < 3) cat("\n\nNote: 20% Confidence Tax applied (N < 3).\n")
}