library(tidyverse)
library(delta)

infile <- "swim.csv"
dat <- read_csv(infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat %>% 
  localize_beach() %>% 
  celsify_temp()

write_csv(dat, outfile_path(infile))
