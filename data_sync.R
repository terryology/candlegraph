library(googlesheets4)
library(tidyverse)
library(here)

# 1. AUTHENTICATION
gs4_deauth() 

# 2. DATA LINK
sheet_url <- "https://docs.google.com/spreadsheets/d/1UZ1JB-RD30dOB2WFd9vqyP-1uFTyl6a-fhO6rvw8EPg/"

# 3. FETCH & CALCULATE DURATION
brands     <- read_sheet(sheet_url, sheet = "brands")
materials  <- read_sheet(sheet_url, sheet = "materials")
purchases  <- read_sheet(sheet_url, sheet = "purchases")

# We calculate 'total_time' immediately upon import
burn_times <- read_sheet(sheet_url, sheet = "burn_times") %>%
  mutate(
    total_time = as.numeric(difftime(stop_time, start_time, units = "hours"))
  )

# 4. THE MASTER JOIN
df_master <- burn_times %>%
  left_join(purchases, by = c("candle_id", "brand_id")) %>%
  left_join(brands, by = "brand_id") %>%
  left_join(materials, by = c("candle_id", "brand_id"))

# 5. CLEAN UP
df_master <- df_master %>% 
  rename(brand_name = any_of(c("brand_name.x", "brand_name"))) %>%
  select(-any_of("brand_name.y"))

message("Sync Complete: 'total_time' calculated in hours.")