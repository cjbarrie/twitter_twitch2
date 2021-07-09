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

queries <-
  c(rep("(climate emergency)", 3), rep("(climate change)", 3))
queries
countries <- c(rep(c("GB", "US", "CA"), 2))
countries

# or store these as a list (better):

# qclist <- list(queries = queries,
#                countries = countries)

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

# tcs_all<- readRDS("data/clim_combined_countries.rds") #here's one I made earlier

# plot ratio over time

tcs_all %>%
  ggplot(aes(date, tweet_count, group = query, color = query)) +
  geom_line() +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "# tweets") +
  facet_wrap( ~ country, scales = "free", nrow = 3)

#  log count to see differences?

tcs_all %>%
  ggplot(aes(date, log(tweet_count), group = query, color = query)) +
  geom_line() +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "# tweets") +
  facet_wrap( ~ country, scales = "free", nrow = 3)

#  use ratio

tcs_all %>%
  pivot_wider(names_from = query,
              values_from = tweet_count) %>%
  mutate(ratio = `(climate emergency)` / `(climate change)`) %>%
  ggplot(aes(date, ratio)) +
  geom_line() +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "# ratio climate emergency/climate change") +
  facet_wrap( ~ country, scales = "free", nrow = 3) +
  theme(legend.position = "bottom",
        legend.direction = "horizontal")
