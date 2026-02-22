library(googlesheets4)
library(tidyverse)
library(here)
library(ggrepel)

# 1. AUTH & LINK
# gs4_deauth() is used because the sheet is intentionally public.
# If you ever make the sheet private, move sheet_url to .Renviron
# and authenticate with gs4_auth() instead.
gs4_deauth()
sheet_url <- "https://docs.google.com/spreadsheets/d/1UZ1JB-RD30dOB2WFd9vqyP-1uFTyl6a-fhO6rvw8EPg/"

# 2. FETCH DATA
# Error handling ensures a clear message if the API or sheet is unavailable
brands <- tryCatch({
  read_sheet(sheet_url, sheet = "brands")
}, error = function(e) {
  stop(paste("Failed to load brands sheet:", e$message))
})

materials <- tryCatch({
  read_sheet(sheet_url, sheet = "materials")
}, error = function(e) {
  stop(paste("Failed to load materials sheet:", e$message))
})

purchases <- tryCatch({
  read_sheet(sheet_url, sheet = "purchases")
}, error = function(e) {
  stop(paste("Failed to load purchases sheet:", e$message))
})

burn_times <- tryCatch({
  read_sheet(sheet_url, sheet = "burn_times") %>%
    mutate(
      total_time = as.numeric(difftime(stop_time, start_time, units = "hours")),
      # Cap at 4 hours UNLESS it's the final burn
      # Final burns are allowed full time to extract all remaining value
      effective_time = if_else(
        is_final_burn == TRUE,
        total_time,              # No cap on final burn
        pmin(total_time, 4)      # Cap at 4hr for all other sessions
      )
    )
}, error = function(e) {
  stop(paste("Failed to load burn_times sheet:", e$message))
})

# 3. THE MASTER JOIN & SCENT LOGIC
df_master <- burn_times %>%
  left_join(purchases, by = c("candle_id", "brand_id")) %>%
  left_join(brands, by = "brand_id") %>%
  rename(brand_name = any_of(c("brand_name.x", "brand_name"))) %>%
  mutate(
    # Average all available hot throw measurements (1-3 checkpoints across candle life)
    throw_hot_avg = rowMeans(
      select(., throw_hot_1, throw_hot_2, throw_hot_3), 
      na.rm = TRUE
    ),
    # Replace NaN (when all three are NA) with NA
    throw_hot_avg = if_else(is.nan(throw_hot_avg), NA_real_, throw_hot_avg),
    
    # Weighted scent score: 40% Cold Throw + 60% Hot Throw
    # Falls back to Cold only if Hot is missing, defaults to neutral (3) if both missing
    cold_score = coalesce(as.numeric(throw_cold), 3),
    hot_score  = coalesce(throw_hot_avg, as.numeric(throw_cold), 3),
    weighted_scent = (cold_score * 0.4) + (hot_score * 0.6),
    
    # PROVENANCE: Check if throws were measured empirically vs recalled from memory
    is_empirical = !is.na(throw_basis) & throw_basis == "Measured"
  )

# 4. BASELINES
# Both indexes are relational - 100 always = current collection average
# Uses effective_time (capped at 4hr except final burns) for fair efficiency comparison
global_avg_eff   <- mean(df_master$effective_time / df_master$price_usd, na.rm = TRUE)
global_avg_scent <- mean(df_master$weighted_scent, na.rm = TRUE)

# 5. BRAND RANKINGS
brand_rankings <- df_master %>%
  group_by(brand_name) %>%
  summarise(
    n_candles      = n_distinct(candle_id),
    total_hrs      = sum(effective_time, na.rm = TRUE),
    avg_eff        = mean(effective_time / price_usd, na.rm = TRUE),
    avg_scent      = mean(weighted_scent, na.rm = TRUE),
    is_verified    = any(is_empirical == TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    # PAE: Hours per dollar relative to collection average
    pae_index = (avg_eff / global_avg_eff) * 100,
    
    # SAV: Weighted scent density relative to collection average
    # This matches the methodology page formula:
    # SAV = (weighted_scent / collection_avg_scent) × 100
    sav_index = (avg_scent / global_avg_scent) * 100,
    
    # Confidence Tax: 20% penalty for brands with fewer than 3 candles
    # Applied to both indexes since small samples affect all measurements
    pae_index = if_else(n_candles < 3, pae_index * 0.8, pae_index),
    sav_index = if_else(n_candles < 3, sav_index * 0.8, sav_index)
  )

# 6. GENERATE PERFORMANCE PLOT
performance_plot <- ggplot(brand_rankings, aes(x = pae_index, y = sav_index)) +
  
  # Quadrant Labels
  annotate("text", x = 160, y = 160, label = "GRAIL",       alpha = 0.1, size = 10, fontface = "bold") +
  annotate("text", x = 40,  y = 40,  label = "DUD",         alpha = 0.1, size = 10, fontface = "bold") +
  annotate("text", x = 40,  y = 160, label = "OVERACHIEVER",alpha = 0.1, size = 6,  fontface = "bold") +
  annotate("text", x = 160, y = 40,  label = "WORKHORSE",   alpha = 0.1, size = 6,  fontface = "bold") +
  
  # Quadrant Grid Lines
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey85") +
  geom_vline(xintercept = 100, linetype = "dashed", color = "grey85") +
  
  # Points: Bubble size for collection depth, Color for data quality
  geom_point(aes(size = n_candles, color = is_verified), alpha = 0.6) +
  
  geom_text_repel(aes(label = brand_name), size = 3.5, family = "sans") +
  
  scale_color_manual(
    values = c("TRUE" = "#2a9d8f", "FALSE" = "#e76f51"),
    labels = c("TRUE" = "Empirical (Measured)", "FALSE" = "Anecdotal (Recall)"),
    drop = FALSE
  ) +
  
  # Hide size legend to keep dashboard clean
  scale_size_continuous(range = c(3, 12), guide = "none") +
  
  labs(
    title    = "CANDLEGRAPH PERFORMANCE MAP",
    subtitle = "Size indicates collection depth | Color indicates Hot Throw basis",
    x        = "Efficiency Index (PAE)",
    y        = "Scent Value Index (SAV)",
    color    = "Data Provenance"
  ) +
  
  theme_minimal(base_size = 12) +
  theme(
    legend.position  = "bottom",
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

# 7. EXPORT PLOT
# Saves to static/images/ so Hugo can serve it directly
# Also available as R object (performance_plot) for inline .Rmd rendering
ggsave(
  filename = here::here("static", "images", "performance_map.png"),
  plot     = performance_plot,
  width    = 10,
  height   = 8,
  dpi      = 150,
  bg       = "white"
)

message("Sync Complete: SAV/PAE indexes calculated. Performance map exported to static/images/.")