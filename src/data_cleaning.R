# -----------------------------------------------
# Rationale for log transformation (Added 2025-12-04)
# Raw trading volume is extremely right-skewed.
# Applying log(Volume + 1) compresses large values,
# stabilises variance, and improves suitability for
# statistical testing and visualisation.
# -----------------------------------------------


# src/data_cleaning.R
library(readr); library(dplyr)

raw <- "data/raw/samsung_raw.csv"
if(!file.exists(raw)) stop("CSV not found at data/raw/samsung_raw.csv")

df <- read_csv(raw, show_col_types = FALSE) %>% 
  arrange(Date)

# remove exact duplicates
n_before <- nrow(df)
df <- distinct(df)
n_after <- nrow(df)
cat("Rows before:", n_before, "after removing duplicates:", n_after, "\n")

# ensure Volume numeric & report NA
df <- df %>% mutate(Volume = as.numeric(Volume))
na_volume <- sum(is.na(df$Volume))
cat("NA in Volume:", na_volume, "\n")

# optional: remove rows with NA in Volume (documented)
if(na_volume > 0) {
  df <- df %>% filter(!is.na(Volume))
  cat("Removed rows with NA in Volume; new rows:", nrow(df), "\n")
}

# Save cleaned CSV
dir.create("data/cleaned", recursive = TRUE, showWarnings = FALSE)
write_csv(df, "data/cleaned/samsung_clean.csv")
cat("Saved cleaned: data/cleaned/samsung_clean.csv\n")

