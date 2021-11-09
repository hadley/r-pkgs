---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "man/figures/README-",
  out.width = "100%"
)
```

**NOTE: This is a toy package created for expository purposes, for the second edition of [R Packages](https://r-pkgs.org). It is not meant to actually be useful. If you want a package for factor handling, please see [stringr](https://stringr.tidyverse.org), [stringi](https://stringi.gagolewski.com/),
[rex](https://cran.r-project.org/package=rex), and
[rematch2](https://cran.r-project.org/package=rematch2).**

# regexcite

<!-- badges: start -->
<!-- badges: end -->

The goal of regexcite is to make regular expressions more exciting!
It provides convenience functions to make some common tasks with string manipulation and regular expressions a bit easier.

## Installation

You can install the development version of regexcite from [GitHub](https://github.com/) with:
      
``` r
# install.packages("devtools")
devtools::install_github("jennybc/regexcite")
```

## Usage

A fairly common task when dealing with strings is the need to split a single string into many parts.
This is what `base::strplit()` and `stringr::str_split()` do.

```{r}
(x <- "alfa,bravo,charlie,delta")
strsplit(x, split = ",")
stringr::str_split(x, pattern = ",")
```

Notice how the return value is a **list** of length one, where the first element holds the character vector of parts.
Often the shape of this output is inconvenient, i.e. we want the un-listed version.

That's exactly what `regexcite::str_split_one()` does.

```{r}
library(regexcite)

str_split_one(x, pattern = ",")
```

Use `str_split_one()` when the input is known to be a single string.
For safety, it will error if its input has length greater than one.

`str_split_one()` is built on `stringr::str_split()`, so you can use its `n` argument and stringr's general interface for describing the `pattern` to be matched.

```{r}
str_split_one(x, pattern = ",", n = 2)

y <- "192.168.0.1"
str_split_one(y, pattern = stringr::fixed("."))
```
