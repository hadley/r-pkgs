# Continuous integration

::: {.rmdnote}
You are reading the work-in-progress second edition of R Packages. This chapter is currently a dumping ground for ideas, and we don't recommend reading it. :::

## Checking after every commit with GitHub actions {#gha}

If you're already using GitHub, as described in [git and GitHub](#git), I highly recommend also using GitHub actions. GitHub actions allow you to run code every time you push to GitHub.

To use GitHub actions:

1.  Run `usethis::use_github_action_check_standard()` to set up a GitHub action that runs R CMD check on Linux, Mac, and Windows. 

1.  Commit and push to GitHub.

1.  Wait a few minutes to see the results in your email.

With this setup in place, `R CMD check` will be run on every time you push to GitHub or whenever someone else submits a pull request. You'll find out about failures right away, which makes them easier to fix. Using automated checks also encourages me to check more often locally, because I know if it fails I'll find out about it a few minutes later, often once I've moved on to a new problem.

### Other uses

Since GitHub actions allows you to run arbitrary code, there are many other things that you can use it for:

* Re-publishing a book website every time you make a change to the source.
  (Like this book!)

* Building vignettes and publishing them to a website.

* Automatically building a documentation website for your package.

Learn more about using GitHub actions with R at <https://github.com/r-lib/actions/tree/master/examples>.
