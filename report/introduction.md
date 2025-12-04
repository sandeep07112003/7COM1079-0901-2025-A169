1\. Introduction (Full Section)

1.1 Problem Statement \& Research Motivation (100 words)



Financial markets experienced major structural changes around 2020, including heightened volatility, shifts in investor behaviour, and pandemic-driven liquidity shocks. Understanding how trading activity changed during this period is essential for interpreting market resilience and pricing efficiency. Daily trading volume is a core indicator of liquidity and market participation, making it a relevant measure for detecting behavioural or structural shifts. By examining whether mean trading volume changed after 1 January 2020, the study aims to quantify the impact of this transition period. Prior research highlights liquidity disruptions during crises, underscoring the need for empirical validation using high-resolution stock data.



1.2 Dataset Description (75 words)



The dataset consists of 1,505 daily observations of Samsung Electronics’ stock price and trading volume from 2019 to 2024, sourced from a public Kaggle repository. It includes variables such as date, open, high, low, close, adjusted close, and trading volume. The dataset provides a continuous pre- and post-2020 time series suitable for analysing structural changes in market activity. Data cleaning involved parsing dates, removing duplicated rows, enforcing numeric types, and computing a log-transformed volume measure to address skewness.



1.3 Research Question (50 words)



Does the mean daily trading volume of Samsung Electronics differ between the period before 1 January 2020 and the period after this date? The research seeks to identify whether a structural break in trading activity occurred around 2020, reflecting broader changes in liquidity, investor participation, or market volatility.



1.4 Hypotheses (100 words)



Null hypothesis (H₀): There is no difference in mean daily trading volume (after log transformation) between the pre-2020 and post-2020 periods; any observed variation is due to random sampling fluctuations.

Alternative hypothesis (H₁): The mean daily trading volume (log-transformed) differs between the two periods, indicating a structural shift in trading activity.

The hypothesis structure aligns with a two-sample mean comparison framework. Log transformation is used to stabilise variance and mitigate skewness, ensuring that hypothesis testing reflects central tendency rather than extreme outliers frequently present in raw volume data.

