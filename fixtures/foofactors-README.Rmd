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

**NOTE: This is a toy package created for expository purposes, for the second edition of [R Packages](https://r-pkgs.org). It is not meant to actually be useful. If you want a package for factor handling, please see [forcats](https://forcats.tidyverse.org).**

# foofactors    

<!-- badges: start -->
<!-- badges: end -->

Factors are a very useful type of variable in R, but they can also be very aggravating. This package provides some helper functions for the care and feeding of factors.

## Installation

You can install foofactors like so:

``` r
devtools::install_github("jennybc/foofactors")
```
  
## Quick demo

Binding two factors via `fbind()`:

```{r}
library(foofactors)
a <- factor(c("character", "hits", "your", "eyeballs"))
b <- factor(c("but", "integer", "where it", "counts"))
```

Simply catenating two factors leads to a result that most don't expect.

```{r}
c(a, b)
```

The `fbind()` function glues two factors together and returns factor.

```{r}
fbind(a, b)
```

Often we want a table of frequencies for the levels of a factor. The base `table()` function returns an object of class `table`, which can be inconvenient for downstream work.

```{r}
set.seed(1234)
x <- factor(sample(letters[1:5], size = 100, replace = TRUE))
table(x)
```

The `fcount()` function returns a frequency table as a tibble with a column of factor levels and another of frequencies:

```{r}
fcount(x)
```
