# src/visuals_draft.R
library(readr); library(dplyr); library(ggplot2)

clean <- "data/cleaned/samsung_clean.csv"
if(!file.exists(clean)) stop("Run data_cleaning.R first to create cleaned CSV.")

df <- read_csv(clean, show_col_types = FALSE) %>%
  mutate(pre_post = if_else(Date < as.Date("2020-01-01"), "pre", "post"))

dir.create("figures", showWarnings = FALSE)
dir.create("report/figures", recursive = TRUE, showWarnings = FALSE)

# Boxplot pre vs post
p1 <- ggplot(df, aes(x = pre_post, y = Volume)) +
  geom_boxplot() +
  labs(title="Daily Trading Volume: Pre vs Post 2020", x="Period", y="Volume (shares)")
ggsave("figures/boxplot_volume_pre_post_draft.png", p1, dpi=300, width=8, height=5)

# Histogram with normal curve overlay (density)
p2 <- ggplot(df, aes(x = Volume)) +
  geom_histogram(aes(y=..density..), bins=60, fill="grey90", color="black") +
  stat_function(fun = dnorm, args = list(mean = mean(df$Volume, na.rm=TRUE), sd = sd(df$Volume, na.rm=TRUE)), color="red", size=0.6) +
  labs(title="Histogram of Volume with Normal Curve", x="Volume (shares)", y="Density")
ggsave("figures/hist_volume_bell_draft.png", p2, dpi=300, width=8, height=5)

# captions file
writeLines(c("Boxplot: Volume pre vs post 2020 (draft).", "Histogram: Volume with overlaid normal curve (draft)."), "report/figures/captions.txt")
cat("Saved figures and captions\n")

