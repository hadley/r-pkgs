library(tidyverse)

localize_beach <- function(dat) {
  lookup_table <- read_csv(
    "beach-lookup-table.csv",
    col_types = cols(where = "c", english = "c")
  )
  left_join(dat, lookup_table)
}

f_to_c <- function(x) (x - 32) * 5/9

celsify_temp <- function(dat) {
  mutate(dat, temp = if_else(english == "US", f_to_c(temp), temp))
}

now <- Sys.time()
outfile_path <- function(infile) {
  timestamp <- format(now, "%Y-%B-%d_%H-%M")
  paste0(timestamp, "_", sub("(.*)[.]csv$", "\\1_clean.csv", infile))
}
