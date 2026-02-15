library(googlesheets4)
library(tidyverse)
library(here)

# 1. AUTHENTICATION & LINK
gs4_deauth() 
sheet_url <- "https://docs.google.com/spreadsheets/d/1UZ1JB-RD30dOB2WFd9vqyP-1uFTyl6a-fhO6rvw8EPg/"

# 2. FETCH DATA
brands     <- read_sheet(sheet_url, sheet = "brands")
materials  <- read_sheet(sheet_url, sheet = "materials")
purchases  <- read_sheet(sheet_url, sheet = "purchases")
burn_times <- read_sheet(sheet_url, sheet = "burn_times") %>%
  mutate(
    total_time = as.numeric(difftime(stop_time, start_time, units = "hours")),
    # Mark as verified if the burn was actually measured
    is_measured = !is.na(start_time) & !is.na(stop_time)
  )

# 3. THE MASTER JOIN
df_master <- burn_times %>%
  left_join(purchases, by = c("candle_id", "brand_id")) %>%
  left_join(brands, by = "brand_id") %>%
  left_join(materials, by = c("candle_id", "brand_id")) %>%
  rename(brand_name = any_of(c("brand_name.x", "brand_name"))) %>%
  # Scent Logic: Use hot throw if available, else cold
  mutate(
    combined_scent = coalesce(as.numeric(throw_hot), as.numeric(throw_cold), 5),
    # Check if the Hot Throw specifically was Measured
    is_hot_empirical = !is.na(throw_hot_basis) & throw_hot_basis == "Measured"
  )

# 4. GLOBAL BASELINES
global_avg_eff   <- mean(df_master$total_time / df_master$price_usd, na.rm = TRUE)
global_avg_scent <- mean(df_master$combined_scent, na.rm = TRUE)

# 5. BRAND RANKINGS
brand_rankings <- df_master %>%
  group_by(brand_name) %>%
  summarise(
    n_candles   = n_distinct(candle_id),
    total_hrs   = sum(total_time, na.rm = TRUE),
    avg_eff     = mean(total_time / price_usd, na.rm = TRUE),
    avg_scent   = mean(combined_scent, na.rm = TRUE),
    # Brand is verified if any of its candles have a measured hot throw
    is_verified = any(is_hot_empirical == TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pae_index = (avg_eff / global_avg_eff) * 100,
    sav_index = pae_index * (avg_scent / global_avg_scent)
  )

# 6. GENERATE PERFORMANCE PLOT
performance_plot <- ggplot(brand_rankings, aes(x = pae_index, y = sav_index)) +
  # Quadrant Labels
  annotate("text", x = 160, y = 160, label = "GRAIL", alpha = 0.1, size = 10, fontface = "bold") +
  annotate("text", x = 40, y = 40, label = "DUD", alpha = 0.1, size = 10, fontface = "bold") +
  
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey85") +
  geom_vline(xintercept = 100, linetype = "dashed", color = "grey85") +
  
  # Points: Size for volume, Color for basis
  geom_point(aes(size = n_candles, color = is_verified), alpha = 0.6) +
  
  ggrepel::geom_text_repel(aes(label = brand_name), size = 3.5) +
  
  scale_color_manual(
    values = c("TRUE" = "#2a9d8f", "FALSE" = "#e76f51"),
    labels = c("TRUE" = "Empirical (Measured)", "FALSE" = "Anecdotal (Recall)"),
    drop = FALSE 
  ) +
  
  # Hide the size legend to keep it clean
  scale_size_continuous(range = c(3, 12), guide = "none") + 
  
  labs(
    title = "CANDLEGRAPH PERFORMANCE MAP",
    subtitle = "Size indicates collection depth | Color indicates Hot Throw basis",
    x = "Efficiency Index (PAE)",
    y = "Value Index (SAV)",
    color = "Data Provenance"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())

message("Sync Complete: Rankings calculated and PAE/SAV indices generated.")

# This prints the current baselines for you to copy into your Methodology page
message(sprintf("Current Global Baselines: Efficiency = %.2f | Scent = %.2f", 
                global_avg_eff, global_avg_scent))
