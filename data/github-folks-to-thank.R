library(tidyverse)
library(gh)

res <- gh(
  "/repos/{owner}/{repo}/issues",
  owner = "hadley", repo = "r-pkgs",
  state = "all", filter = "all",.limit = Inf)
length(res) # 994

dat <- tibble(raw = res) |> 
  hoist(raw, user = c("user", "login")) |> 
  mutate(user_data = map(user, \(x) gh("/users/{username}", username = x))) |> 
  hoist(user_data, "name")

dat |> 
  count(user, name, sort = TRUE) |> 
  print(n = Inf)
# 413 unique users

dat2 <- dat |> 
  select(user, name) |> 
  filter(!user %in% c("jennybc", "hadley", "ghost")) |> 
  distinct() |> 
  arrange(tolower(user)) |> 
  mutate(maybe_name = if_else(is.na(name), "", str_glue(" ({name})")))

dat2 |> 
  write_csv("data/contribs.csv")

# write the file I will point O'Reilly to
dat2 |> 
  mutate(string = str_glue("@{user}{maybe_name}")) |> 
  pull(string) |> 
  str_flatten_comma() |> 
  write_file("data/contribs.txt")
