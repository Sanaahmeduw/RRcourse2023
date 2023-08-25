# Load necessary libraries
library(rmarkdown)

# Specify the R Markdown file
input_file <- "C:\\Users\\Sana.1778446\\Documents\\Retake RR\\Render Format.Rmd"

# Specify the output formats and their settings
output_formats <- c("html_document")

# Loop through each output format and render the R Markdown file
for (format in output_formats) {
  if (format == "html_document") {
    render(input_file, output_format = format)
  } else {
    render(input_file, output_format = format, runtime = NULL)
  }
}
