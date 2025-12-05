install.packages("broom")


library(readr); library(dplyr); library(broom)
if(!requireNamespace("effsize", quietly=TRUE)) install.packages("effsize")
library(effsize)

# Load cleaned data
clean <- "data/cleaned/samsung_clean.csv"
if(!file.exists(clean)) stop("Cleaned CSV missing. Run data_cleaning.R first.")
df <- read_csv(clean, show_col_types = FALSE) %>%
  mutate(pre_post = if_else(Date < as.Date("2020-01-01"), "pre", "post"),
         pre_post = factor(pre_post, levels = c("pre","post")),
         logVolume = log(Volume + 1))

# Descriptive summary (logVolume)
sum_tab <- df %>%
  group_by(pre_post) %>%
  summarise(n = n(),
            mean_log = mean(logVolume, na.rm=TRUE),
            sd_log = sd(logVolume, na.rm=TRUE),
            median_log = median(logVolume, na.rm=TRUE)) %>%
  arrange(pre_post)

dir.create("report/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(sum_tab, "report/tables/descriptive_log_pre_post.csv")

# Prepare vectors
pre_vals <- df %>% filter(pre_post=="pre") %>% pull(logVolume)
post_vals <- df %>% filter(pre_post=="post") %>% pull(logVolume)

# Welch t-test (post vs pre)
t_welch <- t.test(post_vals, pre_vals, var.equal = FALSE)

# Cohen's d (post vs pre) - use pooled sd by effsize default
cohen_res <- cohen.d(post_vals, pre_vals, paired = FALSE, na.rm = TRUE)

# Save outputs to appendices
dir.create("appendices", showWarnings = FALSE)
sink("appendices/stats_output.txt")
cat("Welch two-sample t-test: post vs pre (logVolume)\n\n")
print(t_welch)
cat("\nCohen's d (post vs pre):\n")
print(cohen_res)
cat("\nDescriptive summary (logVolume):\n")
print(sum_tab)
sink()

# Prepare compact results CSV
mean_diff <- as.numeric(diff(t_welch$estimate)) # post - pre
t_stat <- as.numeric(t_welch$statistic)
p_val <- as.numeric(t_welch$p.value)
ci_lower <- as.numeric(t_welch$conf.int[1])
ci_upper <- as.numeric(t_welch$conf.int[2])
cohens_d <- as.numeric(cohen_res$estimate)

results_table <- tibble::tibble(
  measure = c("n_pre","n_post","mean_log_pre","mean_log_post","sd_log_pre","sd_log_post",
              "mean_diff_post_minus_pre","t_statistic","p_value","ci_lower","ci_upper","cohens_d"),
  value = c(sum_tab$n[sum_tab$pre_post=="pre"],
            sum_tab$n[sum_tab$pre_post=="post"],
            sum_tab$mean_log[sum_tab$pre_post=="pre"],
            sum_tab$mean_log[sum_tab$pre_post=="post"],
            sum_tab$sd_log[sum_tab$pre_post=="pre"],
            sum_tab$sd_log[sum_tab$pre_post=="post"],
            mean_diff, t_stat, p_val, ci_lower, ci_upper, cohens_d)
)

write_csv(results_table, "report/tables/results_table.csv")

# Print short console summary
cat("t-statistic:", round(t_stat,4), " p-value:", signif(p_val,6), "\n")
cat("Mean diff (post - pre):", round(mean_diff,4), "95% CI [", round(ci_lower,4), ",", round(ci_upper,4), "]\n")
cat("Cohen's d:", round(cohens_d,4), "\n")
