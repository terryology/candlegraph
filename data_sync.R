library(googlesheets4)
library(tidyverse)
library(here)
library(ggrepel)

# 1. AUTH & LINK
gs4_deauth() 
sheet_url <- "https://docs.google.com/spreadsheets/d/1UZ1JB-RD30dOB2WFd9vqyP-1uFTyl6a-fhO6rvw8EPg/"

# 2. FETCH DATA
brands     <- read_sheet(sheet_url, sheet = "brands")
materials  <- read_sheet(sheet_url, sheet = "materials")
purchases  <- read_sheet(sheet_url, sheet = "purchases")
burn_times <- read_sheet(sheet_url, sheet = "burn_times") %>%
  mutate(total_time = as.numeric(difftime(stop_time, start_time, units = "hours")))

# 3. THE MASTER JOIN & CLEAN 5-SCALE LOGIC
df_master <- burn_times %>%
  left_join(purchases, by = c("candle_id", "brand_id")) %>%
  left_join(brands, by = "brand_id") %>%
  rename(brand_name = any_of(c("brand_name.x", "brand_name"))) %>%
  mutate(
    # Direct 1-5 mapping: prioritizes Hot, falls back to Cold, defaults to Neutral (3)
    combined_scent = coalesce(as.numeric(throw_hot), as.numeric(throw_cold), 3),
    # PROVENANCE: Strictly check the explicit 'Measured' tag in your basis column
    is_hot_empirical = !is.na(throw_hot_basis) & throw_hot_basis == "Measured"
  )

# 4. BASELINES
# Efficiency is relative to the collection average; Scent is relative to the scale midpoint (3)
global_avg_eff   <- mean(df_master$total_time / df_master$price_usd, na.rm = TRUE)
target_scent_avg <- 3.0 

# 5. BRAND RANKINGS
brand_rankings <- df_master %>%
  group_by(brand_name) %>%
  summarise(
    n_candles   = n_distinct(candle_id),
    total_hrs   = sum(total_time, na.rm = TRUE),
    avg_eff     = mean(total_time / price_usd, na.rm = TRUE),
    avg_scent   = mean(combined_scent, na.rm = TRUE),
    is_verified = any(is_hot_empirical == TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pae_index = (avg_eff / global_avg_eff) * 100,
    # SAV = Efficiency scaled by how much the scent exceeds or fails the 3.0 midpoint
    sav_index = pae_index * (avg_scent / target_scent_avg)
  )

# 6. GENERATE PERFORMANCE PLOT
performance_plot <- ggplot(brand_rankings, aes(x = pae_index, y = sav_index)) +
  # Quadrant Labels
  annotate("text", x = 160, y = 160, label = "GRAIL", alpha = 0.1, size = 10, fontface = "bold") +
  annotate("text", x = 40, y = 40, label = "DUD", alpha = 0.1, size = 10, fontface = "bold") +
  
  # Grid Lines
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey85") +
  geom_vline(xintercept = 100, linetype = "dashed", color = "grey85") +
  
  # Points: Bubble size for depth, Color for quality of data
  geom_point(aes(size = n_candles, color = is_verified), alpha = 0.6) +
  
  geom_text_repel(aes(label = brand_name), size = 3.5, family = "sans") +
  
  scale_color_manual(
    values = c("TRUE" = "#2a9d8f", "FALSE" = "#e76f51"),
    labels = c("TRUE" = "Empirical (Measured)", "FALSE" = "Anecdotal (Recall)"),
    drop = FALSE 
  ) +
  
  # Hide the size legend to keep the dashboard clean
  scale_size_continuous(range = c(3, 12), guide = "none") + 
  
  labs(
    title = "CANDLEGRAPH PERFORMANCE MAP",
    subtitle = "Size indicates collection depth | Color indicates Hot Throw basis",
    x = "Efficiency Index (PAE)",
    y = "Value Index (SAV)",
    color = "Data Provenance"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

message("Sync Complete: Standardized 1-5 Performance Index Loaded.")