library(tidyverse)
library(stockfish)

data <- read.csv('./source_data/carlsen_games_moves.csv')

carlsen_unames <- c('DrDrunkenstein', 'DrNykterstein', 'STL_Carlsen', 'MagnusCarlsen', 
                    'DannytheDonkey', 'manwithavan', 'damnsaltythatsport', 'DrGrekenstein')

data <- 
  data %>% 
  mutate(player=ifelse(player %in% carlsen_unames, "Carlsen", "Other"))

n <- 25

games <-
  data %>% 
  pull(game_id) %>% 
  unique() %>% 
  sample(n)


game_id_vec = c()
player_vec = c()
move_vec = c()
accurate_vec = c()

current_game = 1
for (game in games){
  to_print = sprintf('Analyzing game %s/%s', current_game, n)
  print(to_print)
  game_df <-
    data %>% 
    filter(game_id == game)
  
  moves <- 
    game_df %>% 
    pull(move_no)
  
  for (current_move in moves[1:length(moves)-1]){
    int_move = as.integer(current_move)
    next_move = toString(int_move + 1)
    current_fen <-
      game_df %>% 
      filter(move_no == current_move) %>% 
      pull(fen)
    next_move_df <-
      game_df %>% 
      filter(move_no == next_move)
    
    next_move <-
      next_move_df %>% 
      pull(move)
    
    player <-
      next_move_df %>% 
      pull(player)
    engine <- fish$new()
    engine$ucinewgame()
    engine$position(current_fen)
    res <- engine$go()
    splt <- unlist(str_split(toString(res), " "))
    best_move <- splt[2]
    if (!(is.na(next_move)) & !(is.na(best_move))){
      if (next_move == best_move){
        accurate = 1
      } else {
        accurate = 0
      }
      game_id_vec = c(game_id_vec, game)
      player_vec = c(player_vec, player)
      move_vec = c(move_vec, current_move)
      accurate_vec = c(accurate_vec, accurate)
    }
  }
  current_game = current_game + 1
}
  
accuracy_df <- data.frame(game_id = game_id_vec,
                          player = player_vec,
                          move = move_vec,
                          accurate = accurate_vec) 

write.csv(accuracy_df, './source_data/accuracy.csv', row.names = FALSE)