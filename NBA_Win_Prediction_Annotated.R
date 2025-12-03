############################################################
# NBA Game Win Prediction Using Multivariable Regression
# Date: 2025-11-06
# Description: Predicts NBA game outcomes and point differentials
############################################################

#Setup
knitr::opts_chunk$set(echo = TRUE)

#Loads required packages 
source("00_requirements.R")

#Runs the cleaning script that loads and preprocesses data
source("01_CleaningCode.R")

#Data Summary

#Creates summary statistics for differential performance metrics
summary_stats <- games_clean %>%
  select(FG_diff, FT_diff, FG3_diff, AST_diff, REB_diff, PTS_diff) %>%
  summarise_all(list(
    mean = ~mean(., na.rm = TRUE),
    median = ~median(., na.rm = TRUE),
    sd = ~sd(., na.rm = TRUE),
    min = ~min(., na.rm = TRUE),
    max = ~max(., na.rm = TRUE)))

#Displays the summary statistics table
print(summary_stats)

#Visualization Section 

#Scatter plots showing linear trends between predictors and point differential

#1. Field Goal % Differential
ggplot(games_clean, aes(x = FG_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Relationship: FG% Diff vs Point Diff",
       x = "FG% Differential",
       y = "Point Differential") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) 

#2. Free Throw % Differential
ggplot(games_clean, aes(x = FT_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Relationship: FT% Diff vs Point Diff",
       x = "FT% Differential",
       y = "Point Differential") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#3. Three-Point % Differential
ggplot(games_clean, aes(x = FG3_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Relationship: 3PT % Diff vs Point Diff",
       x = "3PT% Differential",
       y = "Point Differential") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#4. Assist Differential
ggplot(games_clean, aes(x = AST_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Relationship: Assist Diff vs Point Diff",
       x = "Assist Differential",
       y = "Point Differential") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#5. Rebound Differential
ggplot(games_clean, aes(x = REB_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Relationship: Rebound Diff vs Point Diff",
       x = "Rebound Differential",
       y = "Point Differential") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Prediction Modeling Section

#Logistic Regression: Predicts the probability that the home team wins
win_model <- glm(
  HOME_TEAM_WINS ~ FG_diff + FT_diff + FG3_diff + AST_diff + REB_diff,
  data = games_clean,
  family = binomial)

#Displays model coefficients, p-values, and overall fit
summary(win_model)

#Generate predictions using both regression models
games_clean <- games_clean %>%
  mutate(pred_homewin_prob = predict(win_model, newdata = ., type = "response"),  
    pred_winner = if_else(pred_homewin_prob >= 0.5, HOME_ABBREVIATION, VISITOR_ABBREVIATION),  
    pred_margin = as.numeric(predict(differential_model, newdata = .)),       
    pred_side = if_else(pred_winner == HOME_ABBREVIATION, "HOME", "AWAY")     )

#Preview predictions for quick inspection
head(games_clean %>%
       select(GAME_ID, HOME_ABBREVIATION, VISITOR_ABBREVIATION,
              HOME_TEAM_WINS, pred_homewin_prob, pred_winner, pred_margin, pred_side))
