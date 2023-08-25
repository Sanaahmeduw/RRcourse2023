library(rmarkdown)

# Loop through each season
for (season in 1:8) {
  output_file <- paste0("Season_", season, "_Report.pdf")
  render("Season_Report.Rmd", output_file = output_file, params = list(season_number = season))
}
