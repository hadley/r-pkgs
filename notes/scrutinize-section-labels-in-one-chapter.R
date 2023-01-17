library(tidyverse)
library(parsermd)

file <- "lifecycle.Rmd"
(rmd <- parse_rmd(file) |> 
    rmd_select(has_type("rmd_heading")))

# parsermd doesn't know about callouts, so they erroneously appear as sec_h2
dat <- as_tibble(rmd) |> 
  select(matches("sec_h[23]")) |> 
  filter(!str_detect(sec_h2, "Submitting to CRAN")) |> 
  separate_wider_regex(
    everything(),
    c("text" = "[^\\{]*", " [{]", label = ".*", "[}]"),
    names_sep = "_", too_few = "align_start"
  )
dat |> 
  select(ends_with("label")) |> 
  print(n = Inf)
