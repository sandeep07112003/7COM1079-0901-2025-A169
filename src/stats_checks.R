# src/stats_checks.R
library(readr); library(dplyr)

clean <- "data/cleaned/samsung_clean.csv"
if(!file.exists(clean)) stop("Cleaned CSV missing. Run data_cleaning.R first.")
df <- read_csv(clean, show_col_types = FALSE) %>%
  mutate(pre_post = if_else(Date < as.Date("2020-01-01"), "pre", "post"))

# descriptive table
dir.create("report/tables", recursive = TRUE, showWarnings = FALSE)
sum_tab <- df %>% group_by(pre_post) %>% summarise(n = n(), mean_vol = mean(Volume, na.rm=TRUE), sd_vol = sd(Volume, na.rm=TRUE))
write_csv(sum_tab, "report/tables/descriptive_pre_post.csv")
cat("Saved descriptive table: report/tables/descriptive_pre_post.csv\n")

# Shapiro tests - sample to n=450 if larger
pre_vol <- df %>% filter(pre_post=="pre") %>% pull(Volume)
post_vol <- df %>% filter(pre_post=="post") %>% pull(Volume)
set.seed(42)
pre_sample <- if(length(pre_vol) > 450) sample(pre_vol, 450) else pre_vol
post_sample <- if(length(post_vol) > 450) sample(post_vol, 450) else post_vol

sh_pre <- shapiro.test(pre_sample)
sh_post <- shapiro.test(post_sample)

dir.create("appendices", showWarnings = FALSE)
sink("appendices/normality_results.txt")
cat("Shapiro test (pre sample):\n"); print(sh_pre)
cat("\nShapiro test (post sample):\n"); print(sh_post)
sink()
cat("Saved normality results to appendices/normality_results.txt\n")

# if non-normal, create log transform file
if(sh_pre$p.value < 0.05 || sh_post$p.value < 0.05) {
  df <- df %>% mutate(logVolume = log(Volume + 1))
  write_csv(df, "data/cleaned/samsung_clean_log.csv")
  cat("Non-normal detected; saved log-transformed CSV at data/cleaned/samsung_clean_log.csv\n")
}

