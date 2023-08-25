library(readxl)
install.packages("meta")
library(meta)
library(tidyr)
library(dplyr)

read_excel("C:\\Users\\Sana.1778446\\Documents\\Retake RR\\metaanalysis_data.xlsx") -> stu.meta
stu.meta %>% names()
stu.meta %>% 
  select(Study,
         Mean_girls_play_female,
         Mean_girls_play_male,
         SD_girls_play_female,
         SD_girls_play_male,
         N_girls,
         Year) -> subdata
metagen( 
  #sm = "RD",
  data = subdata,
  TE = Mean_girls_play_male,
  seTE = SD_girls_play_male,
  n.e = N_girls,
  studlab = Study
  
) -> model
model %>% forest(sortvar = Year)
model %>% funnel(bg = "#E4E88F",
                 studlab = TRUE,
                 cex.studlab = 0.4,
                 level = 0.95,
                 contour = c(0.9, 0.95, 0.99),
                 col.contour = c("#7E9379", "#61821B", '#B4E6A8'))
