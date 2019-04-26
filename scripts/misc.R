library(tidyverse)
library(fs)

# Source all files in the R directory
dir_walk("R", source)

ed2in_in <- read_ed2in("ED2IN")

ed2in <- ed2in_in %>%
  modify_ed2in(start_date = "1902-06-01",
               end_date = "1902-06-15")

result <- run_ed(ed2in)
