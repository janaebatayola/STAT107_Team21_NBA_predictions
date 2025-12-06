#01_CleaningCode.R
#load data
teams <- read.csv("Raw_Data/teams.csv")
teams <- teams %>%
  select(TEAM_ID, ABBREVIATION, NICKNAME, CITY)

games <- read.csv("Raw_Data/games.csv")

#Clean data
games_clean <- games %>% 
  left_join(teams %>%
              rename(
                HOME_TEAM_ID        = TEAM_ID,
                HOME_ABBREVIATION   = ABBREVIATION,
                HOME_NICKNAME       = NICKNAME,
                HOME_CITY           = CITY),
            by = "HOME_TEAM_ID") %>% 
  left_join(teams %>% 
              rename(
                VISITOR_TEAM_ID        = TEAM_ID,
                VISITOR_ABBREVIATION   = ABBREVIATION,
                VISITOR_NICKNAME       = NICKNAME,
                VISITOR_CITY           = CITY),
            by = "VISITOR_TEAM_ID") %>%
  mutate(ABBREVIATION_TEAM_WIN = case_when(
    HOME_TEAM_WINS == 1L ~ HOME_ABBREVIATION,
    HOME_TEAM_WINS == 0L ~ VISITOR_ABBREVIATION,
    TRUE                  ~ NA_character_   )) %>%
  select(-GAME_STATUS_TEXT) %>%
  mutate(FG_diff  = FG_PCT_home - FG_PCT_away,
         FT_diff  = FT_PCT_home - FT_PCT_away,
         FG3_diff = FG3_PCT_home - FG3_PCT_away,
         AST_diff = AST_home - AST_away,
         REB_diff = REB_home - REB_away,
         PTS_diff = PTS_home - PTS_away
  ) %>%
  tidyr::drop_na(HOME_TEAM_WINS, PTS_diff, FG_diff, FT_diff, FG3_diff, AST_diff, REB_diff)

#split the data into training data and testing data to see how good our model is on untrained data
n <- nrow(games_clean)
train_ind <- sample(1:n, size = floor(0.7 * n))  # 70% = 18,656 obs
test_ind  <- setdiff(1:n, train_ind)            # remaining 30%
train_data <- games_clean[train_ind, ] #create the data frame for train_data
test_data  <- games_clean[test_ind, ] #create the data frame for test_data