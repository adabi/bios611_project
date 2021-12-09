library(tidyverse)

data <- read.csv('./source_data/carlsen_games_moves.csv')

carlsen_unames <- c('DrDrunkenstein', 'DrNykterstein', 'STL_Carlsen', 'MagnusCarlsen', 
                    'DannytheDonkey', 'manwithavan', 'damnsaltythatsport', 'DrGrekenstein')

first_moves <-
  data %>% 
  filter(move_no == 1 & piece=="P") %>%
  mutate(player=ifelse(player %in% carlsen_unames, "Carlsen", "Other")) %>% 
  group_by(player, to_square) %>% 
  tally()

carlsen_first_moves <-
  first_moves %>% 
  filter(player == 'Carlsen')

other_first_moves <-
  first_moves %>% 
  filter(player == 'Other')

all_letters = rep(letters[1:8], each=8)
all_numbers = rep(c(1:8), 8)
all_squares = paste(all_letters, all_numbers, sep="")
missing_squares_carlsen = all_squares[!(all_squares %in% carlsen_first_moves$to_square)]
n = length(missing_squares_carlsen)
zero_vec = rep(c(0), n)
player_vec = rep('Carlsen', n)
to_concat = data.frame(player = player_vec, 
                       to_square = missing_squares_carlsen, 
                       n = zero_vec)
first_moves <- rbind(first_moves, to_concat)

missing_squares_others = all_squares[!(all_squares %in% other_first_moves$to_square)]
n = length(missing_squares_others)
zero_vec = rep(c(0), n)
player_vec = rep('Other', n)
to_concat = data.frame(player = player_vec, 
                       to_square = missing_squares_others, 
                       n = zero_vec)
first_moves <- rbind(first_moves, to_concat)

first_moves <-
  first_moves %>% 
  separate(to_square, into=c('col', 'row'), sep=1) %>% 
  mutate(col = factor(col, levels = letters[1:8]))

ggplot(data=first_moves, aes(x=col, y=row, fill=n)) +
  geom_tile(color = "black",
            lwd = 0.5,
            linetype = 1) +
  scale_fill_gradient(low = "white", high = "red") + 
  coord_fixed() +
  facet_wrap(~player) +
  labs(title="First Pawn Moves as White", x="", y="")

ggsave('./figures/first_moves_white.png', dpi=600)

#----Black First Move Analysis---

first_moves <-
  data %>% 
  filter(move_no == 2 & piece=="P") %>%
  mutate(player=ifelse(player %in% carlsen_unames, "Carlsen", "Other")) %>% 
  group_by(player, to_square) %>% 
  tally()

carlsen_first_moves <-
  first_moves %>% 
  filter(player == 'Carlsen')

other_first_moves <-
  first_moves %>% 
  filter(player == 'Other')

all_letters = rep(letters[1:8], each=8)
all_numbers = rep(c(1:8), 8)
all_squares = paste(all_letters, all_numbers, sep="")
missing_squares_carlsen = all_squares[!(all_squares %in% carlsen_first_moves$to_square)]
n = length(missing_squares_carlsen)
zero_vec = rep(c(0), n)
player_vec = rep('Carlsen', n)
to_concat = data.frame(player = player_vec, 
                       to_square = missing_squares_carlsen, 
                       n = zero_vec)
first_moves <- rbind(first_moves, to_concat)

missing_squares_others = all_squares[!(all_squares %in% other_first_moves$to_square)]
n = length(missing_squares_others)
zero_vec = rep(c(0), n)
player_vec = rep('Other', n)
to_concat = data.frame(player = player_vec, 
                       to_square = missing_squares_others, 
                       n = zero_vec)
first_moves <- rbind(first_moves, to_concat)

first_moves <-
  first_moves %>% 
  separate(to_square, into=c('col', 'row'), sep=1) %>% 
  mutate(col = factor(col, levels = letters[1:8]))

ggplot(data=first_moves, aes(x=col, y=row, fill=n)) +
  geom_tile(color = "black",
            lwd = 0.5,
            linetype = 1) +
  scale_fill_gradient(low = "white", high = "red") + 
  coord_fixed() +
  facet_wrap(~player) +
  labs(title="First Pawn Moves as Black", x="", y="")

ggsave('./figures/first_moves_black.png', dpi=600)

#-----Openings Analysis-----
openings_df <- read.csv('./source_data/eco_codes.csv')

games <-
  data %>% 
  pull(game_id) %>% 
  unique()

game_id_vec = c()
opening_vec = c()
for (game in games){
  game_df <-
    data %>% 
    filter(game_id == game)
  opening_not_found <- TRUE
  last_move <- 1
  full_notation <- c()
  current_opening <- "Uncommon Opening"
  while (opening_not_found){
    notations <-
      game_df %>% 
      filter(as.numeric(move_no_pair) == last_move) %>% 
      pull(notation)
    full_notation <- c(full_notation, toString(last_move), notations)
    moves = paste(full_notation, collapse = " ")
    possible_opening <- 
      openings_df %>% 
      filter(eco_example == moves) %>% 
      pull(eco_name)
    if (length(possible_opening) == 0){
      opening_not_found <- FALSE
    }
    else {
      current_opening <- possible_opening
    }
    last_move <- last_move + 1
    
  }
  game_id_vec <- c(game_id_vec, game)
  opening_vec <- c(opening_vec, current_opening)
}

parsed_opening_df <- data.frame(game_id = game_id_vec, opening = opening_vec)

full_data <-
  left_join(data, parsed_opening_df, by="game_id")

openings_count <-
  full_data %>% 
  filter(move_no == 1) %>% 
  mutate(player=ifelse(player %in% carlsen_unames, "Carlsen", "Other")) %>% 
  group_by(player, opening) %>% 
  tally()

ggplot(data=openings_count, aes(x=opening, y=n, fill=player)) +
  geom_bar(stat='identity', position="dodge") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title="Openings by Player", x="Opening")

ggsave("./figures/openings.png", width=10, height = 7, dpi=600)

#-----ROC for Binomial Regression-----

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

#-----Accuracy Analysis-----

accuracy_df <- read.csv('./source_data/accuracy.csv')

accuracy_df <-
  accuracy_df %>% 
  group_by(player) %>% 
  summarise(accuracy = rate(accurate)) 

ggplot(data=accuracy_df, aes(x=player, y=accuracy)) +
  geom_bar(stat='identity', fill='deepskyblue2') +
  labs(title="Move Accuracy by Player", x='Player', y='Accuracy')

ggsave('./figures/accuracy.png')
