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
  # Scent Logic: Use throw_hot if available, else throw_cold
  mutate(combined_scent = coalesce(as.numeric(throw_hot), as.numeric(throw_cold), 5))

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
    is_verified = any(is_measured == TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pae_index = (avg_eff / global_avg_eff) * 100,
    sav_index = pae_index * (avg_scent / global_avg_scent),
    # Confidence Tax for N < 3
    weighted_sav = ifelse(n_candles < 3, sav_index * 0.8, sav_index)
  )

message("Sync Complete: Rankings calculated and PAE/SAV indices generated.")