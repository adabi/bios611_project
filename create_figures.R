library(tidyverse)


data <- read.csv('./source_data/carlsen_games_moves.csv')

carlsen_unames <- c('DrDrunkenstein', 'DrNykterstein', 'STL_Carlsen', 'MagnusCarlsen', 
                    'DannytheDonkey', 'manwithavan', 'damnsaltythatsport', 'DrGrekenstein')

first_moves <-
  data %>% 
  filter(move_no == 1) %>%
  mutate(player=ifelse(player %in% carlsen_unames, "Carlsen", "Other")) %>% 
  group_by(player, notation) %>% 
  tally() %>% 
  ungroup() %>% 
  mutate(player = factor(player, levels = c("Other", "Carlsen")))

ggplot(data=first_moves, aes(x=notation, y=n, fill=player)) +
  geom_bar(stat='identity', position='stack') +
  labs(x='Move', title="First Move as White - Carlsen v Other Players", fill="Player")

ggsave("./figures/first_move_white.png", dpi=600)

first_moves_black <-
  data %>% 
  filter(move_no == 2) %>%
  mutate(player=ifelse(player %in% carlsen_unames, "Carlsen", "Other")) %>% 
  group_by(player, notation) %>% 
  tally() %>% 
  ungroup() %>% 
  mutate(player = factor(player, levels = c("Other", "Carlsen")))

ggplot(data=first_moves_black, aes(x=notation, y=n, fill=player)) +
  geom_bar(stat='identity', position='stack') +
  labs(x='Move', title="First Move as Black - Carlsen v Other Players", fill="Player")

ggsave("./figures/first_move_black.png", dpi=600)

data_games <- read.csv('./source_data/carlsen_games.csv')

elo_win <-
  data_games %>% 
  filter(loser_elo > 2000) %>% 
  filter(winner_elo > 2000) %>% 
  mutate(carlsen_won = ifelse(winner %in% carlsen_unames, 1, 0)) %>% 
  mutate(opponent_elo = ifelse(carlsen_won, loser_elo, winner_elo)) %>% 
  group_by(carlsen_won) %>% 
  mutate(train = runif(length(game_id)) < 0.7) %>% 
  select(carlsen_won, opponent_elo, train) %>% 
  ungroup()
  

test <- elo_win %>%
  filter(!train) %>% 
  select(-train)

train <- elo_win %>% 
  filter(train) %>% 
  select(-train)
  

mdl <- glm(data=train, formula = carlsen_won~opponent_elo, family='binomial')

pred <- predict(mdl, newdata = test, type='response')
test_glm <-
  test %>%
  mutate(carlsen_won_pred = pred)

rate <- function(a){
  sum(a)/length(a);
}

maprbind <- function(f,l){
  do.call(rbind, Map(f, l));
}

roc <- maprbind(function(thresh){
  ltest <- test_glm %>% mutate(carlsen_won_pred=1*(carlsen_won_pred>=thresh)) %>%
    mutate(correct=carlsen_won == carlsen_won_pred);
  tp <- ltest %>% filter(ltest$carlsen_won==1) %>% pull(correct) %>% rate();
  fp <- ltest %>% filter(ltest$carlsen_won==0) %>% pull(correct) %>% `!`() %>% rate();
  tibble(threshold=thresh, true_positive=tp, false_positive=fp);
}, seq(from=0, to=1, length.out=10)) %>% arrange(false_positive, true_positive)

ggplot(roc, aes(false_positive, true_positive)) + geom_line() +
  labs(title = "ROC Plot for Binomial Regression")

ggsave("./figures/roc_plot.png", dpi=600)
