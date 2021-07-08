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

tweetcounts <- count_all_tweets(
  query = "(climate emergency)",
  start_tweets = "2015-01-01T00:00:00Z",
  end_tweets = "2021-06-25T00:00:00Z",
  file = "data/clim_emergency.rds",
  granularity = "day",
  n = Inf
)

head(tweetcounts)

# visualize output --------------------------------------------------------

p <- tweetcounts %>%
  mutate(date = as.Date(start)) %>%
  ggplot(aes(date, tweet_count)) +
  geom_line() +
  geom_vline(
    mapping = aes(xintercept = as.Date("2018-08-01")),
    color = "black",
    linetype = "dashed"
  ) +
  geom_vline(
    mapping = aes(xintercept = as.Date("2019-03-15")),
    color = "darkgreen",
    linetype = "dashed"
  ) +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "# climate emergency tweets") +
  transition_reveal(date)

p <- p + theme(
  plot.title = element_text(size = 15),
  axis.title = element_text(size = 15, face = "bold"),
  axis.text = element_text(size = 15)
)

animate(
  p,
  fps = 10,
  height = 600,
  width = 1000,
  res = 150
)

anim_save("plot.gif", animation = last_animation())


# comparing counts --------------------------------------------------------

tweetcounts2 <- count_all_tweets(
  query = "(climate change)",
  start_tweets = "2015-01-01T00:00:00Z",
  end_tweets = "2021-06-25T00:00:00Z",
  file = "data/clim_change.rds",
  granularity = "day",
  n = Inf
)

tweetcountsratio <- tweetcounts %>%
  select(start, tweet_count) %>%
  rename(clim_emerg = tweet_count) %>%
  left_join(tweetcounts2, by = "start") %>%
  rename(clim_chng = tweet_count) %>%
  select(-end) %>%
  mutate(ratio = clim_emerg/clim_chng)

p <- tweetcountsratio %>%
  mutate(date = as.Date(start)) %>%
  ggplot(aes(date, ratio)) +
  geom_line() +
  geom_vline(
    mapping = aes(xintercept = as.Date("2018-08-01")),
    color = "black",
    linetype = "dashed"
  ) +
  geom_vline(
    mapping = aes(xintercept = as.Date("2019-03-15")),
    color = "darkgreen",
    linetype = "dashed"
  ) +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "ratio climate emergency/climate change")

p <- p + theme(
  plot.title = element_text(size = 15),
  axis.title = element_text(size = 12, face = "bold"),
  axis.text = element_text(size = 12)
)


