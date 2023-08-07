# Sets the path to the parent directory of RR classes
setwd("C:\\Users\\Sana.1778446\\Documents\\Ex6RR\\RRcourse2023\\6. Coding and documentation")

# Load necessary libraries
library(readxl)
library(dplyr)
library(Hmisc)
library(stringr)
install.packages("groundhog")
library(groundhog)
pkgs <- c("rvest", "stringi")
groundhog.library(pkgs, date = "2021-09-01")

# Using a Function to read employment data from Eurostat
read_eurostat_employment <- function(sheet) {
  read_excel("Data\\Eurostat_employment_isco.xlsx", sheet = sheet)
}

# Using a loop to Read employment data from Eurostat
countries <- c("Belgium", "Spain", "Poland")
isco_data <- lapply(1:9, function(i) {
  sheet_name <- paste0("ISCO", i)
  read_eurostat_employment(sheet_name)
})

# Calculate worker totals in each of the chosen countries
total_countries <- lapply(isco_data, function(data) rowSums(data[, countries]))

# Merge all the datasets
all_data <- do.call(rbind, isco_data)
all_data$total_Belgium <- rep(total_countries[[1]], each = nrow(all_data))
all_data$total_Spain <- rep(total_countries[[2]], each = nrow(all_data))
all_data$total_Poland <- rep(total_countries[[3]], each = nrow(all_data))

# Check Error
tryCatch(all_data)

# Calculate shares of each occupation among all workers in a period-country
all_data$share_Belgium <- all_data$Belgium / all_data$total_Belgium
all_data$share_Spain <- all_data$Spain / all_data$total_Spain
all_data$share_Poland <- all_data$Poland / all_data$total_Poland

# Function to standardize task values using weights for each country
standardize_task_values <- function(data, task_col, share_col) {
  temp_mean <- wtd.mean(data[[task_col]], data[[share_col]])
  temp_sd <- wtd.var(data[[task_col]], data[[share_col]]) %>% sqrt()
  return((data[[task_col]] - temp_mean) / temp_sd)
}

# List of task items of interest
task_items <- list(
  "t_4A2a4", "t_4A2b2", "t_4A4a1"
)

# Loop to standardize task values for each country and task item
for (country in countries) {
  for (task_item in task_items) {
    std_col <- paste("std_", country, task_item, sep = "_")
    all_data[[std_col]] <- standardize_task_values(all_data, task_item, paste("share_", country, sep = ""))
  }
}

# Function to calculate the "classic" task content intensity
calculate_classic_task_intensity <- function(data, country) {
  task_cols <- c(paste("std_", country, task_items, sep = "_"))
  classic_task_intensity <- rowSums(data[, task_cols])
  temp_mean <- wtd.mean(classic_task_intensity, data[[paste("share_", country, sep = "")]])
  temp_sd <- wtd.var(classic_task_intensity, data[[paste("share_", country, sep = "")]]) %>% sqrt()
  return((classic_task_intensity - temp_mean) / temp_sd)
}

# Calculate "classic" task content intensity for each country
all_data$Belgium_NRCA <- calculate_classic_task_intensity(all_data, "Belgium")
all_data$Poland_NRCA <- calculate_classic_task_intensity(all_data, "Poland")
all_data$Spain_NRCA <- calculate_classic_task_intensity(all_data, "Spain")

# Create a country-level mean for tracking changes over time
country_means <- lapply(countries, function(country) {
  weighted_sum <- (all_data[[paste("std_", country, "NRCA", sep = "_")]] * all_data[[paste("share_", country, sep = "")]])
  agg_data <- aggregate(weighted_sum, by = list(all_data$TIME), FUN = sum, na.rm = TRUE)
  colnames(agg_data)[2] <- "NRCA_intensity"
  return(agg_data)
})

# Plot the changes over time for each country
par(mfrow = c(3, 1))
for (i in 1:3) {
  plot(country_means[[i]]$NRCA_intensity, xaxt = "n", main = countries[i])
  axis(1, at = seq(1, 40, 3), labels = country_means[[i]]$Group.1[seq(1, 40, 3)])
}
