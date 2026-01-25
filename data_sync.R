library(googlesheets4)
library(tidyverse)

# 1. AUTHENTICATION
# Since your sheet is 'Public' (anyone with link can view), we can read it without
# needing a complex login every time by using gs4_deauth().
gs4_deauth() 

# 2. THE DATA LINK
sheet_url <- "https://docs.google.com/spreadsheets/d/1UZ1JB-RD30dOB2WFd9vqyP-1uFTyl6a-fhO6rvw8EPg/"

# 3. FETCHING THE TABLES
brands      <- read_sheet(sheet_url, sheet = "brands")
materials   <- read_sheet(sheet_url, sheet = "materials")
purchases   <- read_sheet(sheet_url, sheet = "purchases")
burn_times  <- read_sheet(sheet_url, sheet = "burn_times")

# 4. THE MASTER JOIN
df_master <- burn_times %>%
  # Join purchases using both IDs to be safe
  left_join(purchases, by = c("candle_id", "brand_id")) %>%
  
  # Join brands using brand_id
  left_join(brands, by = "brand_id") %>%
  
  # Join materials using both IDs
  left_join(materials, by = c("candle_id", "brand_id"))

# 5. CLEAN UP
# Since brand_name appeared in both 'purchases' and 'brands', 
# R creates brand_name.x and brand_name.y to avoid overwriting.
df_master <- df_master %>% 
  select(-brand_name.y) %>% 
  rename(brand_name = brand_name.x)

