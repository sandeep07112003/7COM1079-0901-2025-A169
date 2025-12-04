# src/boxplot_final.R
library(readr)
library(dplyr)
library(ggplot2)

# load cleaned data
df <- read_csv("data/cleaned/samsung_clean.csv", show_col_types = FALSE) %>%
  mutate(pre_post = if_else(Date < as.Date("2020-01-01"), "pre", "post"),
         pre_post = factor(pre_post, levels = c("pre","post")),
         logVolume = log(Volume + 1))

p_box <- ggplot(df, aes(x = pre_post, y = logVolume, fill = pre_post)) +
  geom_boxplot(outlier.shape = 21, outlier.size = 1.8, width = 0.55, color = "black") +
  scale_fill_manual(values = c("pre" = "#d1e5f0", "post" = "#f7a35c"), guide = FALSE) +
  stat_summary(fun = median, geom = "text",
               aes(label = round(..y..,2)), color="black", size=3, vjust = -0.6) +
  labs(
    title = "Log of Daily Trading Volume: Pre vs Post 1 Jan 2020",
    subtitle = "Log(Volume + 1) used to display central tendency and spread",
    x = "Period",
    y = "Log(Volume + 1)"
  ) +
  coord_cartesian(ylim = c(14, 18)) +
  theme_minimal(base_size = 14)

# save figures
dir.create("figures", showWarnings = FALSE)
dir.create("report/figures", recursive = TRUE, showWarnings = FALSE)

ggsave("report/figures/boxplot_logVolume_pre_post_final.png", p_box,
       dpi = 300, width = 8, height = 6)
ggsave("figures/boxplot_logVolume_pre_post_final.png", p_box,
       dpi = 300, width = 8, height = 6)

cat("Saved final boxplot.\n")

