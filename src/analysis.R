# src/figure_prep.R
library(readr); library(dplyr)
library(ggplot2)
library(scales)   # for comma
# Ensure directories
dir.create("figures", showWarnings = FALSE)
dir.create("report/figures", recursive = TRUE, showWarnings = FALSE)

# Read cleaned data
clean_path <- ("C:/Users/sriil/OneDrive/Desktop/7COM1079-0901-2025-A169/data/cleaned/samsung_clean.csv")
if(!file.exists(clean_path)) stop("Cleaned CSV missing. Run data_cleaning.R first.")

df <- read_csv(clean_path, show_col_types = FALSE) %>%
  arrange(Date) %>%
  mutate(pre_post = if_else(Date < as.Date("2020-01-01"), "pre", "post"),
         pre_post = factor(pre_post, levels = c("pre", "post")),    # force order
         logVolume = log(Volume + 1),
         Volume_millions = Volume / 1e6)

# quick checks
cat("Rows:", nrow(df), "Pre count:", sum(df$pre_post=="pre"), "Post count:", sum(df$pre_post=="post"), "\n")

# Save a small sample table for report (optional)
dir.create("report/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(df %>% group_by(pre_post) %>% summarise(n=n(), mean_vol=mean(Volume), median_vol=median(Volume)), "report/tables/summary_pre_post_for_figures.csv")

