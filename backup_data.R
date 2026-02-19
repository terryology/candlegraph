# Exports Google Sheets data to timestamped CSV files
# Run manually before major data changes or monthly
# Outputs to: data/backups/YYYY-MM-DD-[tablename].csv

library(googlesheets4)
library(here)
library(readr)

gs4_deauth()
sheet_url <- "https://docs.google.com/spreadsheets/d/1UZ1JB-RD30dOB2WFd9vqyP-1uFTyl6a-fhO6rvw8EPg/"

# Create backup directory
backup_dir <- here("data", "backups")
dir.create(backup_dir, showWarnings = FALSE, recursive = TRUE)

# Export all sheets
timestamp <- format(Sys.Date(), "%Y-%m-%d")

write_csv(
  read_sheet(sheet_url, sheet = "brands"),
  here(backup_dir, paste0(timestamp, "-brands.csv"))
)

write_csv(
  read_sheet(sheet_url, sheet = "purchases"),
  here(backup_dir, paste0(timestamp, "-purchases.csv"))
)

write_csv(
  read_sheet(sheet_url, sheet = "burn_times"),
  here(backup_dir, paste0(timestamp, "-burn_times.csv"))
)

write_csv(
  read_sheet(sheet_url, sheet = "materials"),
  here(backup_dir, paste0(timestamp, "-materials.csv"))
)

message("Backup complete: ", timestamp)