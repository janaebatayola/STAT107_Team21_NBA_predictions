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

# Save histogram objects (data only)

#Visualization Section 

# Histogram to show suitability of log reg
  hist(games_clean$FG_diff,  main="Field Goal % Differential")
  hist(games_clean$FT_diff,  main="Free Throw % Differential")
  hist(games_clean$FG3_diff, main="3-Point % Differential")
  hist(games_clean$AST_diff, main="Assists Differential")
  hist(games_clean$REB_diff, main="Rebounds Differential")
  hist(games_clean$PTS_diff, main="Points Differential")
  
  # Box plots comparing statistics for wins vs losses
 boxplot_diff <- games_clean %>%
    mutate(Win_Status = ifelse(HOME_TEAM_WINS == 1, "Home Win", "Away Win")) %>%
    select(Win_Status, FG_diff, FT_diff, FG3_diff, AST_diff, REB_diff) %>%
    pivot_longer(cols = -Win_Status, names_to = "Statistic", values_to = "Value") %>%
    ggplot(aes(x = Win_Status, y = Value, fill = Win_Status)) +
    geom_boxplot() +
    facet_wrap(~Statistic, scales = "free_y") +
    labs(title = "Distribution of Differential Statistics by Game Outcome",
         x = "Game Outcome",
         y = "Differential Value") +
    theme_minimal() +
    theme(legend.position = "none")
  # Produces boxplots comparing statistical differentials between home and away wins.
  # Faceting allows side-by-side comparison of multiple stats.
  # Helps visualize which stats increase with wins.

#Scatter plots showing linear trends between predictors and point differential

#1. Field Goal % Differential
FG_scat <- ggplot(games_clean, aes(x = FG_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "FG% Diff vs Point Diff",
       x = "FG% Differential",
       y = "Point Differential")

#2. Free Throw % Differential
FT_scat <- ggplot(games_clean, aes(x = FT_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "FT% Diff vs Point Diff",
       x = "FT% Differential",
       y = "Point Differential") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#3. Three-Point % Differential
FG3_scat <- ggplot(games_clean, aes(x = FG3_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "3PT % Diff vs Point Diff",
       x = "3PT% Differential",
       y = "Point Differential")

#4. Assist Differential
AST_scat <- ggplot(games_clean, aes(x = AST_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Assist Diff vs Point Diff",
       x = "Assist Differential",
       y = "Point Differential")

#5. Rebound Differential
REB_scat <- ggplot(games_clean, aes(x = REB_diff, y = PTS_diff)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Rebound Diff vs Point Diff",
       x = "Rebound Differential",
       y = "Point Differential")

#Prediction Modeling Section

#Logistic Regression: Predicts the probability that the home team wins
win_model <- glm(
  HOME_TEAM_WINS ~ FG_diff + FT_diff + FG3_diff + AST_diff + REB_diff,
  data = train_data,
  family = binomial)

#Displays model coefficients, p-values, and overall fit
summary(win_model)

# Generate predictions using the logistic regression model
games_pred <- test_data %>%
  mutate(
    # Predicted probability the home team wins
    PREDICTED_PROB = predict(
      win_model,
      newdata = .,
      type = "response"
    ),
    
    # Predicted winner based on 0.5 threshold
    PREDICTED_WINNER = if_else(
      PREDICTED_PROB >= 0.5,
      HOME_NICKNAME,
      VISITOR_NICKNAME
    ),
    
    # Actual winner from the real game results
    ACTUAL_WINNER = if_else(
      HOME_TEAM_WINS == 1,
      HOME_NICKNAME,
      VISITOR_NICKNAME
    ),
    
    # Whether the prediction was correct
    CORRECT = (PREDICTED_WINNER == ACTUAL_WINNER),
    
    # (Optional) Predicted side HOME vs AWAY
    PREDICTED_SIDE = if_else(
      PREDICTED_WINNER == HOME_NICKNAME,
      "HOME",
      "AWAY"
    )
  )
# win model coefficient table made for analysis
win_model_summary <- tidy(win_model) %>%
  mutate(
    estimate  = round(estimate, 3),
    std.error = round(std.error, 3),
    statistic = round(statistic, 2),
    p.value   = format.pval(p.value, digits = 3, eps = 2e-16)
  ) %>%
  rename(
    Term      = term,
    Estimate  = estimate,
    Std_Error = std.error,
    Z_value   = statistic,
    P_value   = p.value
  )

# Table made for report
pred_table <- games_pred %>%
  transmute(
    Home_Team        = HOME_NICKNAME,
    Away_Team        = VISITOR_NICKNAME,
    Actual_Winner    = ACTUAL_WINNER,
    Predicted_Winner = PREDICTED_WINNER,
    Predicted_Prob   = round(PREDICTED_PROB, 3),
    Correct          = CORRECT
  ) %>%
  head()
