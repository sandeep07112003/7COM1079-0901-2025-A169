# src/robustness.R
library(readr); library(dplyr)
if(!requireNamespace("car", quietly=TRUE)) install.packages("car")
if(!requireNamespace("boot", quietly=TRUE)) install.packages("boot")
library(car); library(boot)

# load data
df <- read_csv("data/cleaned/samsung_clean.csv", show_col_types = FALSE) %>%
  mutate(pre_post = if_else(Date < as.Date("2020-01-01"), "pre", "post"),
         pre_post = factor(pre_post, levels = c("pre","post")),
         logVolume = log(Volume + 1))

pre_vals <- df %>% filter(pre_post=="pre") %>% pull(logVolume)
post_vals <- df %>% filter(pre_post=="post") %>% pull(logVolume)

# 1. Levene test for variance equality (on logVolume)
lev <- leveneTest(logVolume ~ pre_post, data = df)

# 2. Pooled t-test (var.equal = TRUE) - compare with Welch
t_pooled <- t.test(post_vals, pre_vals, var.equal = TRUE)

# 3. Wilcoxon rank-sum test (non-parametric) on logVolume
wil <- wilcox.test(post_vals, pre_vals, exact = FALSE)

# 4. Hedges' g: compute from Cohen's d with small-sample correction
# compute cohen's d manually (pooled sd)
n1 <- length(pre_vals); n2 <- length(post_vals)
m1 <- mean(pre_vals); m2 <- mean(post_vals)
sd1 <- sd(pre_vals); sd2 <- sd(post_vals)
# pooled sd
s_pooled <- sqrt(((n1-1)*sd1^2 + (n2-1)*sd2^2) / (n1 + n2 - 2))
cohen_d <- (m2 - m1) / s_pooled
# Hedges' g correction factor J
df_total <- n1 + n2 - 2
J <- 1 - (3 / (4*df_total - 1))
hedges_g <- cohen_d * J

# 5. Bootstrap CI for mean difference (post - pre) on logVolume
boot_mean_diff <- function(data, indices) {
  d <- data[indices, ]
  mean(d$post) - mean(d$pre)
}
# prepare data frame for boot
set.seed(123)
boot_df <- data.frame(post = post_vals, pre = c(pre_vals, rep(NA, length(post_vals)-length(pre_vals)))[1:length(post_vals)])
# Alternative: bootstrap by resampling within groups, computing mean diff
boot_func <- function(data, i) {
  pre_samp <- sample(pre_vals, length(pre_vals), replace = TRUE)
  post_samp <- sample(post_vals, length(post_vals), replace = TRUE)
  mean(post_samp) - mean(pre_samp)
}
B <- 5000
boots <- replicate(B, boot_func(NULL, NULL))
boot_ci <- quantile(boots, probs = c(0.025, 0.975))

# Save outputs
dir.create("appendices", showWarnings = FALSE)
sink("appendices/robustness_output.txt")
cat("Levene test for equality of variances (logVolume):\n"); print(lev); cat("\n")
cat("Pooled t-test (var.equal=TRUE):\n"); print(t_pooled); cat("\n")
cat("Wilcoxon rank-sum test (logVolume):\n"); print(wil); cat("\n")
cat("Cohen's d (pooled) and Hedges' g:\n"); cat("Cohen's d:", round(cohen_d,4), "\n"); cat("Hedges' g:", round(hedges_g,4), "\n\n")
cat("Bootstrap 95% CI for mean difference (post - pre) on logVolume:\n"); print(boot_ci); cat("\n")
sink()

# Save a compact CSV summary
rob_tab <- tibble::tibble(
  test = c("levene_F", "levene_p", "pooled_t_stat", "pooled_p", "wilox_p", "cohen_d", "hedges_g", "boot_ci_low", "boot_ci_high"),
  value = c(as.numeric(lev$`F value`[1]), as.numeric(lev$`Pr(>F)`[1]),
            as.numeric(t_pooled$statistic), as.numeric(t_pooled$p.value),
            as.numeric(wil$p.value),
            cohen_d, hedges_g, boot_ci[1], boot_ci[2])
)
dir.create("report/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(rob_tab, "report/tables/robustness_table.csv")
cat("Saved robustness outputs and table\n")

