# R Packages

<!-- badges: start -->

[![render](https://github.com/hadley/r-pkgs/actions/workflows/render.yaml/badge.svg)](https://github.com/hadley/r-pkgs/actions/workflows/render.yaml) [![Netlify Status](https://api.netlify.com/api/v1/badges/a5dbbee9-7396-4e7f-8ce7-6abd362d9752/deploy-status)](https://app.netlify.com/sites/r-pkgs/deploys)

<!-- badges: end -->

This repo holds the code and text behind the **R Packages** book.
The site is built with [Quarto](https://quarto.org).

-   The first edition is no longer available online.
-   A second edition is under development and available at <https://r-pkgs.org>.

*Status as of 2022-07: Work on a second edition is full swing, with publication expected in early 2023. Issues and PRs are welcome, but please bear in mind that sometimes we need to make large, systematic changes ourselves, which can clobber smaller, external PRs.*

## Notes on mechanics

Screenshots: use `include_graphics()`, chunk should have `output.width = NULL`.

[Quarto callouts](https://quarto.org/docs/authoring/callouts.html) look like this:

    ::: callout-tip
    Here's a super handy nifty thing!
    :::

At the time of writing (2022-08-31), we use `callout-tip`, `callout-warning`, `callout-note`, and `callout-important`.
The `XXX` of `callout-XXX` is its type and controls the icon and color:

-   `-tip` green
-   `-warning` orange
-   `-note` blue
-   `-important` red

Use a `##`-level header to caption the callout.

Do this for tips specific to RStudio:

    ::: callout-tip
    ## RStudio
    Here's a super handy nifty thing about RStudio specifically.
    :::

The other callout that appears multiple times is:

    ::: callout-warning
    ## Submitting to CRAN
    Here's something to super careful about.
    :::
