library(tidyverse)
library(rtweet)

# https://ropensci.org/packages/all/

br_trends <- rtweet::get_trends("Brazil")

#1. postar
rtweet::post_tweet(
  "curso-r é daorinha demais puxa, vlw @Azeloc! #rstats"
)


# 2. timeline 
minha_timeline <- rtweet::get_timeline("")

# 3. mencoes
minhas_mencoes <- rtweet::get_mentions()

# 4. pegar tweets que usam certa hashtag
dados_hashtag <- rtweet::search_users("#rstats", n = 30) 
