# List of required packages
packages <- c(
  "dplyr",
  "ggplot2",
  "tidyr",
  "broom",
  "flextable",
  "kableExtra",
  "gridExtra"
)

# Install any packages that are missing
installed <- packages %in% rownames(installed.packages())
if(any(!installed)) {
  install.packages(packages[!installed])
}

# Load all packages
lapply(packages, library, character.only = TRUE)

cat("All required packages successfully loaded.\n")
