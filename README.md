# Overview 

This project analyzes NBA game data from the 2022–2023 season to identify which performance statistics are the strongest predictors of winning a game. Using differential team statistics (home − away), we train a multivariable logistic regression model to estimate the probability that the home team wins.

The model uses the following predictors:

- **FG% Differential (FG_diff)**

- **FT% Differential (FT_diff)**

- **3PT% Differential (FG3_diff)**

- **Assist Differential (AST_diff)**

- **Rebound Differential (REB_diff)**

The goal is to understand how performance gaps between teams translate into win probability and to evaluate model accuracy using a 70/30 train–test split.

## Data

Two datasets from Kaggle were used:

- **games.csv** — game-level box score statistics

- **teams.csv** — team identifiers, names, and abbreviations

During data preprocessing, the following were created:

- Differential metrics (e.g., FG_diff = FG%_home − FG%_away)

- A binary outcome variable (home_win)

- Cleaned and merged dataset (games_clean)

# Methods

- Data cleaning and feature engineering in R

- Exploratory visualizations includes histograms, boxplots, scatterplots

**Logistic regression model**:

- home_win ~ FG_diff + FT_diff + FG3_diff + AST_diff + REB_diff
  
- Model evaluation using test-set accuracy

# Results

- FG% differential was the strongest predictor of winning.

- 3PT% and FT% differentials also significantly contributed.

- Assists and rebounds had meaningful but smaller effects.

- The model achieved ~84.7% accuracy on the test set.

# Structure
```
/
/
├── Raw_Data/
│   ├── games.csv
│   ├── teams.csv
│
├── R/
│   ├── 00_requirements.R
│   ├── 01_CleaningCode.R
│   ├── NBA_Win_Prediction_Annotated.R
│   ├── 02_FinalReport.Rmd        # Located here so paths source correctly
│   └── 02_FinalReport.pdf
│
└── README.md
```


# How to Run

Open the project in RStudio

Run in the following order:

source("R/00_requirements.R")

source("R/01_CleaningCode.R")

source("R/NBA_Win_Prediction_Annotated.R")

Knit FinalReport.Rmd for the full analysis

