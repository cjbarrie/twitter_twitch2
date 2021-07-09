########################################################
# PURPOSE: TWITCH DEMO OF TWEET COUNTS API ENDPOINT    #
# AUTHOR: CHRISTOPHER BARRIE                           #
########################################################

library(academictwitteR) #to query the Twitter API
library(ggplot2) #for plotting
library(gganimate) #for plot animations
library(ggthemes) #for plot styling
library(dplyr) #for data wrangling
library(tidyr) #for data wrangling


# main function -----------------------------------------------------------

tweetcounts <- count_all_tweets(
  query = "(climate emergency)",
  start_tweets = "2015-01-01T00:00:00Z",
  end_tweets = "2021-06-25T00:00:00Z",
  file = "data/clim_emergency.rds",
  granularity = "day",
  n = Inf
)

# tweetcounts <- readRDS("data/clim_emergency.rds") #here's one I made earlier

head(tweetcounts)

# test <- tweetcounts %>%
#   mutate(date = as.Date(start))
# 
# head(test$date)

# visualize output --------------------------------------------------------

# plot output as line graph

tweetcounts %>%
  mutate(date = as.Date(start)) %>%
  ggplot(aes(date, tweet_count)) +
  geom_line()

# style

tweetcounts %>%
  mutate(date = as.Date(start)) %>%
  ggplot(aes(date, tweet_count)) +
  geom_line() +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "# climate emergency tweets") +
  theme(axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12))
# add notable date markers

tweetcounts %>%
  mutate(date = as.Date(start)) %>%
  ggplot(aes(date, tweet_count)) +
  geom_line() +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "# climate emergency tweets") +
  geom_vline(
    mapping = aes(xintercept = as.Date("2018-08-01")),
    #first Greta sit-in
    color = "black",
    linetype = "dashed"
  ) +
  geom_vline(
    mapping = aes(xintercept = as.Date("2019-03-15")),
    #first Global Climate Strike
    color = "darkgreen",
    linetype = "dashed"
  ) +
  geom_text(
    aes(
      x = as.Date("2018-07-01"),
      label = "Skolstrejk för klimatet",
      y = 85000
    ),
    colour = "black",
    angle = 90,
    size = 3
  ) +
  geom_text(
    aes(
      x = as.Date("2019-02-20"),
      label = "#GlobalClimateStrike",
      y = 85000
    ),
    colour = "darkgreen",
    angle = 90,
    size = 3
  )

# animate output ----------------------------------------------------------

p <- tweetcounts %>%
  mutate(date = as.Date(start)) %>%
  ggplot(aes(date, tweet_count)) +
  geom_line() +
  geom_vline(
    mapping = aes(xintercept = as.Date("2018-08-01")),
    #first Greta sit-in
    color = "black",
    linetype = "dashed"
  ) +
  geom_vline(
    mapping = aes(xintercept = as.Date("2019-03-15")),
    #first Global Climate Strike
    color = "darkgreen",
    linetype = "dashed"
  ) +
  geom_text(
    aes(
      x = as.Date("2018-07-01"),
      label = "Skolstrejk för klimatet",
      y = 85000
    ),
    colour = "black",
    angle = 90,
    size = 3
  ) +
  geom_text(
    aes(
      x = as.Date("2019-02-20"),
      label = "#GlobalClimateStrike",
      y = 85000
    ),
    colour = "darkgreen",
    angle = 90,
    size = 3
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
  # height = 600,
  # width = 1000,
  # res = 150
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

# tweetcounts2 <- readRDS("data/clim_change.rds") #here's one I made earlier

tweetcountsratio <- tweetcounts %>%
  select(start, tweet_count) %>%
  rename(clim_emerg = tweet_count) %>%
  left_join(tweetcounts2, by = "start") %>%
  rename(clim_chng = tweet_count) %>%
  select(-end) %>%
  mutate(ratio = clim_emerg / clim_chng)

tweetcountsratio %>%
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
  geom_text(
    aes(
      x = as.Date("2018-07-01"),
      label = "Skolstrejk för klimatet",
      y = .6
    ),
    colour = "black",
    angle = 90,
    size = 3
  ) +
  geom_text(
    aes(
      x = as.Date("2019-02-20"),
      label = "#GlobalClimateStrike",
      y = .6
    ),
    colour = "darkgreen",
    angle = 90,
    size = 3
  ) +
  theme_tufte(base_family = "Helvetica") +
  labs(x = "Date", y = "ratio climate emergency/climate change") +
  theme(axis.title = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12))
