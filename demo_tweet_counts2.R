########################################################
# PURPOSE: TWITCH DEMO OF TWEET COUNTS API ENDPOINT    #
# AUTHOR: CHRISTOPHER BARRIE                           #
########################################################

library(academictwitteR)
library(ggplot2)
library(dplyr)
library(gganimate)
library(ggthemes)


# main function -----------------------------------------------------------

queries <- c(rep("(climate emergency)", 3), rep("(climate change)", 3))

countries <- c(rep(c("GB", "US", "CA"), 2))

tcs_all <- data.frame()

for (i in seq_along(queries)) {
  
  ctquery = queries[[i]]
  ctcountry = countries[[i]]
  
  tcs <- count_all_tweets(
    query = ctquery,
    start_tweets = "2015-01-01T00:00:00Z",
    end_tweets = "2021-06-25T00:00:00Z",
    granularity = "day",
    country = ctcountry,
    n = Inf
  )
  
  tcs <- tcs %>%
    mutate(date = as.Date(start),
           query = ctquery,
           country = ctcountry) %>%
    select(query, date, tweet_count, country)
  
  tcs_all <- rbind(tcs_all, tcs)
}

tcs_all %>%
  ggplot(aes(date, tweet_count, group = query, color=query)) +
  geom_line() +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "# tweets") +
  facet_wrap(~ country, scales = "free")

saveRDS(tcs_all, "data/clim_combined_countries.rds")
