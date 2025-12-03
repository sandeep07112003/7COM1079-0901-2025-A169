install.packages("readr")
install.packages("dplyr")
install.packages("ggplot2")

library(readr)
library(dplyr)
library(ggplot2)

raw_path <- "data/raw/samsung_raw.csv"
if (!file.exists(raw_path)) {
  stop("Place samsung_raw.csv at data/raw/samsung_raw.csv or update raw_path")
}

df <- read_csv(raw_path)
glimpse(df)
summary(df$Volume)

# quick histogram
p <- ggplot(df, aes(x=Volume)) + geom_histogram(bins=60) + ggtitle("Volume histogram (prototype)")
ggsave("figures/volume_hist_prototype.png", p, dpi=150)

