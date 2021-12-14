# The whole game {#whole-game}



*Spoiler alert!*

This chapter runs through the development of a small toy package.
It's meant to paint the Big Picture and suggest a workflow, before we descend into the detailed treatment of the key components of an R package.

To keep the pace brisk, we exploit the modern conveniences in the devtools package and the RStudio IDE.
In later chapters, we are more explicit about what those helpers are doing for us.

## Load devtools and friends

You can initiate your new package from any active R session.
You don't need to worry about whether you're in an existing or new project or not.
The functions we use take care of this.

Load the devtools package, which is the public face of a set of packages that support various aspects of package development.
The most obvious of these is the usethis package, which you'll see is also being loaded.


```r
library(devtools)
#> Loading required package: usethis
```

Do you have an old version of devtools? Compare your version against ours and upgrade if necessary.


```r
packageVersion("devtools")
#> [1] '2.4.3'
```

## Toy package: regexcite

We use various functions from devtools to build a small toy package from scratch, with features commonly seen in released packages:

* Functions to address a specific need, in this case helpers for work with regular expressions.
* Version control and an open development process.
  - This is completely optional in your work, but highly recommended.
    You'll see how Git and GitHub help us expose all the intermediate stages of
    our toy package.
* Access to established workflows for installation, getting help, and checking quality.
  - Documentation for individual functions via [roxygen2](https://CRAN.R-project.org/package=roxygen2).
  - Unit testing with [testthat](https://testthat.r-lib.org).
  - Documentation for the package as a whole via an executable `README.Rmd`.

We call the package **regexcite** and it will have a couple functions that make common tasks with regular expressions easier.
Please note that these functions are super simple and definitely not the point! For real work, there are several proper R packages that address this problem space:

* [stringr](https://stringr.tidyverse.org) (which uses stringi)
* [stringi](https://stringi.gagolewski.com/)
* [rex](https://cran.r-project.org/package=rex)
* [rematch2](https://cran.r-project.org/package=rematch2)

The regexcite package itself is not our goal here.
It is a device for demonstrating a typical workflow for package development with devtools.

## Peek at the finished product

The regexcite package is tracked during its development with the Git version control system.
This is purely optional and you can certainly follow along without implementing this.
A nice side benefit is that we eventually connect it to a remote repository on GitHub, which means you can see the glorious result we are working towards by visiting regexcite on GitHub: <https://github.com/jennybc/regexcite>.
By inspecting the [commit history](https://github.com/jennybc/regexcite/commits/main) and especially the diffs, you can see exactly what changes at each step of the process laid out below.

<!-- TODO: I think these diffs are extremely useful and would like to surface them better here. -->

## `create_package()`

Call `create_package()` to initialize a new package in a directory on your computer (and create the directory, if necessary).
See section \@ref(creating) for more.

Make a deliberate choice about where to create this package on your computer.
It should probably be somewhere within your home directory, alongside your other R projects.
It should not be nested inside another RStudio Project, R package, or Git repo.
Nor should it be in an R package library, which holds packages that have already been built and installed.
The conversion of the source package we create here into an installed package is part of what devtools facilitates.
Don't try to do devtools' job for it!
See \@ref(where-source-package) for more.

Substitute your chosen path into a `create_package()` call like this:


```r
create_package("~/path/to/regexcite")
```

We have to work in a temp directory, because this book is built non-interactively, in the cloud.
Behind the scenes, we're executing our own `create_package()` command, but don't be surprised if our output differs a bit from yours.



:::downlit

```
#> [32m✔[39m Creating [34m'/tmp/RtmpOdlRpJ/regexcite/'[39m
#> [32m✔[39m Setting active project to [34m'/tmp/RtmpOdlRpJ/regexcite'[39m
#> [32m✔[39m Creating [34m'R/'[39m
#> [32m✔[39m Writing [34m'DESCRIPTION'[39m
#> [34mPackage[39m: regexcite
#> [34mTitle[39m: What the Package Does (One Line, Title Case)
#> [34mVersion[39m: 0.0.0.9000
#> [34mAuthors@R[39m (parsed):
#>     * First Last <first.last@example.com> [aut, cre] (YOUR-ORCID-ID)
#> [34mDescription[39m: What the package does (one paragraph).
#> [34mLicense[39m: `use_mit_license()`, `use_gpl3_license()` or friends to
#>     pick a license
#> [34mEncoding[39m: UTF-8
#> [34mRoxygen[39m: list(markdown = TRUE)
#> [34mRoxygenNote[39m: 7.1.2
#> [32m✔[39m Writing [34m'NAMESPACE'[39m
#> [32m✔[39m Writing [34m'regexcite.Rproj'[39m
#> [32m✔[39m Adding [34m'^regexcite\\.Rproj$'[39m to [34m'.Rbuildignore'[39m
#> [32m✔[39m Adding [34m'.Rproj.user'[39m to [34m'.gitignore'[39m
#> [32m✔[39m Adding [34m'^\\.Rproj\\.user$'[39m to [34m'.Rbuildignore'[39m
#> [32m✔[39m Setting active project to [34m'<no active project>'[39m
```
:::





If you're working in RStudio, you should find yourself in a new instance of RStudio, opened into your new regexcite package (and Project).
If you somehow need to do this manually, navigate to the directory and double click on `regexcite.Rproj`.
RStudio has special handling for packages and you should now see a *Build* tab in the same pane as *Environment* and *History*.

<!-- TODO: good place for a screenshot. -->

What's in this new directory that is also an R package and, probably, an RStudio Project?
Here's a listing (locally, you can consult your *Files* pane):

:::downlit

```
#> [90m# A tibble: 6 × 2[39m
#>   path            type     
#>   [3m[90m<fs::path>[39m[23m      [3m[90m<fct>[39m[23m    
#> [90m1[39m .Rbuildignore   file     
#> [90m2[39m .gitignore      file     
#> [90m3[39m DESCRIPTION     file     
#> [90m4[39m NAMESPACE       file     
#> [90m5[39m [01;34mR[0m               directory
#> [90m6[39m regexcite.Rproj file
```
:::

:::rstudio-tip
In the file browser, go to *More > Show Hidden Files* to toggle the visibility of hidden files (a.k.a. ["dotfiles"](https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory#Unix_and_Unix-like_environments)).
A select few are visible all the time, but sometimes you want to see them all.
:::

* `.Rbuildignore` lists files that we need to have around but that should not be
  included when building the R package from source.
  More in \@ref(rbuildignore).
* `.Rproj.user`, if you have it, is a directory used internally by RStudio.
* `.gitignore` anticipates Git usage and ignores some standard,
  behind-the-scenes files created by R and RStudio.
  Even if you do not plan to use Git, this is harmless.
* `DESCRIPTION` provides [metadata about your package](#description).
  We edit this shortly.
* [`NAMESPACE`](#namespace) declares the functions your package exports for
  external use and the external functions your package imports from other
  packages.
  At this point, it is empty, except for a comment declaring that this is a file
  we will not edit by hand.
* The `R/` directory is the ["business end" of your package](#r).
  It will soon contain `.R` files with function definitions.
* `regexcite.Rproj` is the file that makes this directory an RStudio Project.
  Even if you don't use RStudio, this file is harmless.
  Or you can suppress its creation with `create_package(..., rstudio = FALSE)`.
  More in \@ref(projects).

## `use_git()`

:::tip
The use of Git or another version control system is optional, but a recommended practice in the long-term.
We explain its importance in \@ref(git).
:::

The regexcite directory is an R source package and an RStudio Project.
Now we make it also a Git repository, with `use_git()`.


```r
use_git()
#> [32m✔[39m Setting active project to [34m'/tmp/RtmpOdlRpJ/regexcite'[39m
#> [32m✔[39m Initialising Git repo
#> [32m✔[39m Adding [34m'.Rhistory'[39m, [34m'.Rdata'[39m, [34m'.httr-oauth'[39m, [34m'.DS_Store'[39m to [34m'.gitignore'[39m
```

In an interactive session, you will be asked if you want to commit some files here and you should probably accept the offer.
Behind the scenes, we'll cause the same to happen for us.



What's new?
Only the creation of a `.git` directory, which is hidden in most contexts, including the RStudio file browser.
Its existence is evidence that we have indeed initialized a Git repo here.

:::downlit

```
#> [90m# A tibble: 1 × 2[39m
#>   path       type     
#>   [3m[90m<fs::path>[39m[23m [3m[90m<fct>[39m[23m    
#> [90m1[39m [01;34m.git[0m       directory
```
:::

If you're using RStudio, it probably requested permission to relaunch itself in this Project, which you should do.
You can do so manually by quitting, then relaunching RStudio by double clicking on `regexcite.Rproj`.
Now, in addition to package development support, you have access to a basic Git client in the *Git* tab of the *Environment/History/Build* pane.

<!-- TODO: good place for a screenshot. -->

Click on History (the clock icon in the Git pane) and, if you consented, you will see an initial commit made via `use_git()`:

:::downlit

```
#> [90m# A tibble: 1 × 3[39m
#>   commit                                   author          message  
#>   [3m[90m<chr>[39m[23m                                    [3m[90m<chr>[39m[23m           [3m[90m<chr>[39m[23m    
#> [90m1[39m 6351f888debbe35184d8a5f0a4702f58100b20f2 jennybc <jenny… [90m"[39mInitial…
```
:::

:::rstudio-tip
RStudio can initialize a Git repository, in any Project, even if it's not an R package, as long you've set up RStudio + Git integration.
Do *Tools > Version Control > Project Setup*.
Then choose *Version control system: Git* and *initialize a new git repository for this project*.
:::

## Write the first function

A fairly common task when dealing with strings is the need to split a single string into many parts.
The `strsplit()` function in base R does exactly this.


```r
(x <- "alfa,bravo,charlie,delta")
#> [1] "alfa,bravo,charlie,delta"
strsplit(x, split = ",")
#> [[1]]
#> [1] "alfa"    "bravo"   "charlie" "delta"
```

Take a close look at the return value.


```r
str(strsplit(x, split = ","))
#> List of 1
#>  $ : chr [1:4] "alfa" "bravo" "charlie" "delta"
```

The shape of this return value often surprises people or, at least, inconveniences them.
The input is a character vector of length one and the output is a list of length one.
This makes total sense in light of R's fundamental tendency towards vectorization.
But sometimes it's still a bit of a bummer.
Often you know that your input is morally a scalar, i.e. it's just a single string, and really want the output to be the character vector its parts.

This leads R users to employ various methods of "unlist"-ing the result:


```r
unlist(strsplit(x, split = ","))
#> [1] "alfa"    "bravo"   "charlie" "delta"

strsplit(x, split = ",")[[1]]
#> [1] "alfa"    "bravo"   "charlie" "delta"
```

The second, safer solution is the basis for the inaugural function of regexcite: `strsplit1()`.


```{.r .R}
strsplit1 <- function(x, split) {
  strsplit(x, split = split)[[1]]
}
```

This book does not teach you how to write functions in R.
To learn more about that take a look at the [Functions chapter](https://r4ds.had.co.nz/functions.html) of R for Data Science and the [Functions chapter](https://adv-r.hadley.nz/functions.html) of Advanced R.

:::tip
The name of `strsplit1()` is a nod to the very handy `paste0()`, which first appeared in R 2.15.0 in 2012.
`paste0()` was created to address the extremely common use case of `paste()`-ing strings together *without* a separator.
`paste0()` has been lovingly described as ["statistical computing's most influential contribution of the 21st century"](https://simplystatistics.org/posts/2013-01-31-paste0-is-statistical-computings-most-influential-contribution-of-the-21st-century/).
:::

## `use_r()`

Where shall we define `strsplit1()`?
Save it in a `.R` file, in the `R/` subdirectory of your package.
A reasonable starting position is to make a new `.R` file for each user-facing function in your package and name the file after the function.
As you add more functions, you'll want to relax this and begin to group related functions together.
We'll save the definition of `strsplit1()` in the file `R/strsplit1.R`.

The helper `use_r()` creates and/or opens a script below `R/`.
It really shines in a more mature package, when navigating between `.R` files and the associated test file.
But, even here, it's useful to keep yourself from getting too carried away while working in `Untitled4`.


```r
use_r("strsplit1")
#> [31m•[39m Edit [34m'R/strsplit1.R'[39m
#> [31m•[39m Call [90m`use_test()`[39m to create a matching test file
```

Put the definition of `strsplit1()` **and only the definition of `strsplit1()`** in `R/strsplit1.R` and save it.
The file `R/strsplit1.R` should NOT contain any of the other top-level code we have recently executed, such as the definition of our practice input `x`, `library(devtools)`, or `use_git()`.
This foreshadows an adjustment you'll need to make as you transition from writing R scripts to R packages.
Packages and scripts use different mechanisms to declare their dependency on other packages and to store example or test code.
We explore this further in chapter \@ref(r).

## `load_all()` {#whole-game-load-all}

How do we test drive `strsplit1()`?
If this were a regular R script, we might use RStudio to send the function definition to the R Console and define `strsplit1()` in the global environment.
Or maybe we'd call `source("R/strsplit1.R")`.
For package development, however, devtools offers a more robust approach.
See section \@ref(load-all) for more.

Call `load_all()` to make `strsplit1()` available for experimentation.


```r
load_all()
#> [36mℹ[39m Loading [34m[34mregexcite[34m[39m
```

Now call `strsplit1(x)` to see how it works.


```r
(x <- "alfa,bravo,charlie,delta")
#> [1] "alfa,bravo,charlie,delta"
strsplit1(x, split = ",")
#> [1] "alfa"    "bravo"   "charlie" "delta"
```

Note that `load_all()` has made the `strsplit1()` function available, although it does not exist in the global environment.


```r
exists("strsplit1", where = globalenv(), inherits = FALSE)
#> [1] FALSE
```

If you see `TRUE` instead of `FALSE`, that indicates you're still using a script-oriented workflow and sourcing your functions.
Here's how to get back on track:

* Clean out the global environment and restart R.
* Re-attach devtools with `library(devtools)` and re-load regexcite with
  `load_all()`.
* Redefine the test input `x` and call `strsplit1(x, split = ",")` again.
  This should work!
* Run `exists("strsplit1", where = globalenv(), inherits = FALSE)` again and
  you should see `FALSE`.

`load_all()` simulates the process of building, installing, and attaching the regexcite package.
As your package accumulates more functions, some exported, some not, some of which call each other, some of which call functions from packages you depend on, `load_all()` gives you a much more accurate sense of how the package is developing than test driving functions defined in the global environment.
Also `load_all()` allows much faster iteration than actually building, installing, and attaching the package.

Review so far:

* We wrote our first function, `strsplit1()`, to split a string into a character
  vector (not a list containing a character vector).
* We used `load_all()` to quickly make this function available for interactive
  use, as if we'd built and installed regexcite and attached it via
  `library(regexcite)`.

:::rstudio-tip
RStudio exposes `load_all()` in the *Build* menu, in the *Build* pane via *More > Load All*, and in keyboard shortcuts Ctrl + Shift + L (Windows & Linux) or Cmd + Shift + L (macOS).
:::

### Commit `strsplit1()`

If you're using Git, use your preferred method to commit the new `R/strsplit1.R` file.
We do so behind the scenes here and here's the associated diff.




```
#> diff --git a/R/strsplit1.R b/R/strsplit1.R
#> new file mode 100644
#> index 0000000..29efb88
#> --- /dev/null
#> +++ b/R/strsplit1.R
#> @@ -0,0 +1,3 @@
#> +strsplit1 <- function(x, split) {
#> +  strsplit(x, split = split)[[1]]
#> +}
```

From this point on, we commit after each step.
Remember [these commits](https://github.com/jennybc/regexcite/commits/main) are available in the public repository.

## `check()`

We have informal, empirical evidence that `strsplit1()` works.
But how can we be sure that all the moving parts of the regexcite package still work?
This may seem silly to check, after such a small addition, but it's good to establish the habit of checking this often.

`R CMD check`, executed in the shell, is the gold standard for checking that an R package is in full working order.
`check()` is a convenient way to run this without leaving your R session.

Note that `check()` produces rather voluminous output, optimized for interactive consumption.
We intercept that here and just reveal a summary.
Your local `check()` output will be different.


```r
check()
```

:::downlit

```
#> [36m── R CMD check results ─────────────────── regexcite 0.0.0.9000 ────[39m
#> Duration: 22.2s
#> 
#> [35m❯ checking DESCRIPTION meta-information ... WARNING[39m
#>   Non-standard license specification:
#>     `use_mit_license()`, `use_gpl3_license()` or friends to pick a
#>     license
#>   Standardizable: FALSE
#> 
#> [32m0 errors ✔[39m | [31m1 warning ✖[39m | [32m0 notes ✔[39m
```
:::

**Read the output of the check!**
Deal with problems early and often.
It's just like incremental development of `.R` and `.Rmd` files.
The longer you go between full checks that everything works, the harder it becomes to pinpoint and solve your problems.

At this point, we expect 1 warning (and 0 errors, 0 notes):

```
Non-standard license specification:
  `use_mit_license()`, `use_gpl3_license()` or friends to pick a
  license
```

We'll address that soon, by doing exactly what it says.

:::rstudio-tip
RStudio exposes `check()` in the *Build* menu, in the *Build* pane via *Check*, and in keyboard shortcuts Ctrl + Shift + E (Windows & Linux) or Cmd + Shift + E (macOS).
:::

## Edit `DESCRIPTION`

The `DESCRIPTION` file provides metadata about your package and is covered fully in chapter \@ref(description).
This is a good time to have a look at regexcite's current `DESCRIPTION`.
You'll see it's populated with boilerplate content, which needs to be replaced.

Make these edits:

* Make yourself the author. If you don't have an ORCID, you can omit the
  `comment = ...` portion.
* Write some descriptive text in the `Title` and `Description` fields.
  
:::rstudio-tip
Use Ctrl + `.` in RStudio and start typing "DESCRIPTION" to activate a helper that makes it easy to open a file for editing.
In addition to a filename, your hint can be a function name.
This is very handy once a package has lots of files.
:::

When you're done, `DESCRIPTION` should look similar to this:

<!-- I use an unknown language engine intentionally ("default") because I don't want any syntax highlighting. -->


```{.default .default}
Package: regexcite
Title: Make Regular Expressions More Exciting
Version: 0.0.0.9000
Authors@R: 
    person("Jane", "Doe", , "jane@example.com", role = c("aut", "cre"))
Description: Convenience functions to make some common tasks with string
    manipulation and regular expressions a bit easier.
License: `use_mit_license()`, `use_gpl3_license()` or friends to pick a
    license
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.1.2
```



## `use_mit_license()`

> [Pick a License, Any License. -- Jeff Atwood](https://blog.codinghorror.com/pick-a-license-any-license/)

We currently have a placeholder in the `License` field of `DESCRIPTION` that's deliberately invalid and suggests a resolution.

```
License: `use_mit_license()`, `use_gpl3_license()` or friends to pick a
    license
```

Let's call `use_mit_license()`.


```r
use_mit_license()
#> [32m✔[39m Setting [32mLicense[39m field in DESCRIPTION to [34m'MIT + file LICENSE'[39m
#> [32m✔[39m Writing [34m'LICENSE'[39m
#> [32m✔[39m Writing [34m'LICENSE.md'[39m
#> [32m✔[39m Adding [34m'^LICENSE\\.md$'[39m to [34m'.Rbuildignore'[39m
```

This configures the `License` field correctly for the MIT license, which promises to name the copyright holders and year in a `LICENSE` file.
Open the newly created `LICENSE` file and confirm it looks something like this:

:::sourceCode

```
YEAR: 2021
COPYRIGHT HOLDER: regexcite authors
```
:::

Like other license helpers, `use_mit_license()` also puts a copy of the full license in `LICENSE.md` and adds this file to `.Rbuildignore`.
It's considered a best practice to include a full license in your package's source, such as on GitHub, but CRAN disallows the inclusion of this file in a package tarball.



## `document()` {#whole-game-document}

Wouldn't it be nice to get help on `strsplit1()`, just like we do with other R functions?
This requires that your package have a special R documentation file, `man/strsplit1.Rd`, written in an R-specific markup language that is sort of like LaTeX.
Luckily we don't necessarily have to author that directly.

We write a specially formatted comment right above `strsplit1()`, in its source file, and then let a package called [roxygen2](https://roxygen2.r-lib.org) handle the creation of `man/strsplit1.Rd`.
The motivation and mechanics of roxygen2 are covered in chapter \@ref(man).

If you use RStudio, open `R/strsplit1.R` in the source editor and put the cursor somewhere in the `strsplit1()` function definition.
Now do *Code > Insert roxygen skeleton*.
A very special comment should appear above your function, in which each line begins with `#'`.
RStudio only inserts a barebones template, so you will need to edit it to look something like that below.

If you don't use RStudio, create the comment yourself.
Regardless, you should modify it to look something like this:


```{.r .R}
#' Split a string
#'
#' @param x A character vector with one element.
#' @param split What to split on.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' x <- "alfa,bravo,charlie,delta"
#' strsplit(x, split = ",")
strsplit1 <- function(x, split) {
  strsplit(x, split = split)[[1]]
}
```

<!-- TODO: mention how RStudio helps you execute examples here? -->



But we're not done yet!
We still need to trigger the conversion of this new roxygen comment into `man/strsplit1.Rd` with `document()`:


```r
document()
#> [36mℹ[39m Updating [34m[34mregexcite[34m[39m documentation
#> [36mℹ[39m Loading [34m[34mregexcite[34m[39m
#> Writing NAMESPACE
#> Writing strsplit1.Rd
```

:::rstudio-tip
RStudio exposes `document()` in the *Build* menu, in the *Build* pane via *More > Document*, and in keyboard shortcuts Ctrl + Shift + D (Windows & Linux) or Cmd + Shift + D (macOS).
:::

You should now be able to preview your help file like so:


```r
?strsplit1
```

You'll see a message like "Rendering development documentation for 'strsplit1'", which reminds that you are basically previewing draft documentation.
That is, this documentation is present in your package's source, but is not yet present in an installed package.
In fact, we haven't installed regexcite yet, but we will soon.

Note also that your package's documentation won't be properly wired up until it has been formally built and installed.
This polishes off niceties like the links between help files and the creation of a package index.

### `NAMESPACE` changes

In addition to converting `strsplit1()`'s special comment into `man/strsplit1.Rd`, the call to `document()` updates the `NAMESPACE` file, based on `@export` directives found in roxygen comments.
Open `NAMESPACE` for inspection.
The contents should be:

<!-- OK to use this approach here because I actively do not want a copy button. NAMESPACE should be managed by roxygen and I don't want to tempt anyone to edit it by hand. -->


```
# Generated by roxygen2: do not edit by hand

export(strsplit1)
```

The export directive in `NAMESPACE` is what makes `strsplit1()` available to a user after attaching regexcite via `library(regexcite)`.
Just as it is entirely possible to author `.Rd` files "by hand", you can manage `NAMESPACE` explicitly yourself.
But we choose to delegate this to devtools (and roxygen2).



## `check()` again

regexcite should pass `R CMD check` cleanly now and forever more: 0 errors, 0 warnings, 0 notes.


```r
check()
```

:::downlit

```
#> [36m── R CMD check results ─────────────────── regexcite 0.0.0.9000 ────[39m
#> Duration: 23.2s
#> 
#> [32m0 errors ✔[39m | [32m0 warnings ✔[39m | [32m0 notes ✔[39m
```
:::

## `install()`

Since we have a minimum viable product now, let's install the regexcite package into your library via `install()`:


```r
install()
```


```
* checking for file ‘/tmp/RtmpOdlRpJ/regexcite/DESCRIPTION’ ... OK
* preparing ‘regexcite’:
* checking DESCRIPTION meta-information ... OK
* checking for LF line-endings in source and make files and shell scripts
* checking for empty or unneeded directories
* building ‘regexcite_0.0.0.9000.tar.gz’
Running /opt/R/4.1.2/lib/R/bin/R CMD INSTALL \
  /tmp/RtmpOdlRpJ/regexcite_0.0.0.9000.tar.gz --install-tests 
* installing to library ‘/home/runner/work/_temp/Library’
* installing *source* package ‘regexcite’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (regexcite)
```

:::rstudio-tip
RStudio exposes similar functionality in the *Build* menu and in the *Build* pane via *Install and Restart*.
:::

Now we can attach and use regexcite like any other package.
Let's revisit our small example from the top.
This is a good time to restart your R session and ensure you have a clean workspace.


```r
library(regexcite)

x <- "alfa,bravo,charlie,delta"
strsplit1(x, split = ",")
#> [1] "alfa"    "bravo"   "charlie" "delta"
```

Success!

## `use_testthat()`

We've tested `strsplit1()` informally, in a single example.
We can formalize this as a unit test.
This means we express a concrete expectation about the correct `strsplit1()` result for a specific input.

First, we declare our intent to write unit tests and to use the testthat package for this, via `use_testthat()`:


```r
use_testthat()
#> [32m✔[39m Adding [34m'testthat'[39m to [32mSuggests[39m field in DESCRIPTION
#> [32m✔[39m Setting [32mConfig/testthat/edition[39m field in DESCRIPTION to [34m'3'[39m
#> [32m✔[39m Creating [34m'tests/testthat/'[39m
#> [32m✔[39m Writing [34m'tests/testthat.R'[39m
#> [31m•[39m Call [90m`use_test()`[39m to initialize a basic test file and open it for editing.
```

This initializes the unit testing machinery for your package.
It adds `Suggests: testthat` to `DESCRIPTION`, creates the directory `tests/testthat/`, and adds the script `tests/testthat.R`.
You'll notice that testthat is probably added with a minimum version of 3.0.0 and a second DESCRIPTION field, `Config/testthat/edition: 3`.
We'll talk more about those details in chapter \@ref(tests).



However, it's still up to YOU to write the actual tests!

The helper `use_test()` opens and/or creates a test file.
You can provide the file's basename or, if you are editing the relevant source file in RStudio, it will be automatically generated.
For many of you, if `R/strsplit1.R` is the active file in RStudio, you can just call `use_test()`.
However, since this book is built non-interactively, we must provide the basename explicitly:


```r
use_test("strsplit1")
#> [32m✔[39m Writing [34m'tests/testthat/test-strsplit1.R'[39m
#> [31m•[39m Edit [34m'tests/testthat/test-strsplit1.R'[39m
```

This creates the file `tests/testthat/test-strsplit1.R`.
If it had already existed, `use_test()` would have just opened it.
Put this content in:




```{.r .R}
test_that("strsplit1() splits a string", {
  expect_equal(strsplit1("a,b,c", split = ","), c("a", "b", "c"))
})
```

This tests that `strsplit1()` gives the expected result when splitting a string.



Run this test interactively, as you will when you write your own.
Note you'll have to attach testthat via `library(testthat)` in your R session first and you'll probably want to `load_all()`.

Going forward, your tests will mostly run *en masse* and at arm's length via `test()`:

<!-- TODO: I have no idea why I have to disable crayon here, but if I don't, I guess raw ANSI escapes. Other chunks seem to work fine with downlig. It would also be nice to not see evidence of progress reporting, but the previous approach to turning that off keeps this chunk from showing any output at all :( The previous approach was `R.options = list(testthat.default_reporter = testthat::ProgressReporter$new(update_interval = Inf))`. -->


```r
test()
#> ℹ Loading regexcite
#> ℹ Testing regexcite
#> ✔ | F W S  OK | Context
#> ⠏ |         0 | strsplit1                                           ✔ |         1 | strsplit1
#> 
#> ══ Results ═════════════════════════════════════════════════════════
#> [ FAIL 0 | WARN 0 | SKIP 0 | PASS 1 ]
```

:::rstudio-tip
RStudio exposes `test()` in the *Build* menu, in the *Build* pane via *More > Test package*, and in keyboard shortcuts Ctrl + Shift + T (Windows & Linux) or Cmd + Shift + T (macOS).
:::

Your tests are also run whenever you `check()` the package.
In this way, you basically augment the standard checks with some of your own, that are specific to your package.
It is a good idea to use the [covr package](https://covr.r-lib.org) to track what proportion of your package's source code is exercised by the tests.
More details can be found in chapter \@ref(tests).

## `use_package()`

You will inevitably want to use a function from another package in your own package.
Just as we needed to **export** `strsplit1()`, we need to **import** functions from the namespace of other packages.
If you plan to submit a package to CRAN, note that this even applies to functions in packages that you think of as "always available", such as `stats::median()` or `utils::head()`.

One common dilemma when using R's regular expression functions is uncertainty about whether to request `perl = TRUE` or `perl = FALSE`.
And then there are often, but not always, other arguments that alter how patterns are matched, such as `fixed`, `ignore.case`, and `invert`.
It can be hard to keep track of which functions use which arguments and how the arguments interact, so many users never get to the point where they retain these details without rereading the docs.

The stringr package "provides a cohesive set of functions designed to make working with strings as easy as possible".
In particular, stringr uses one regular expression system everywhere (ICU regular expressions) and uses the same interface in every function for controlling matching behaviors, such as case sensitivity.
Some people find this easier to internalize and program around.
Let's imagine you decide you'd rather build regexcite based on stringr (and stringi) than base R's regular expression functions.

First, declare your general intent to use some functions from the stringr namespace with `use_package()`:


```r
use_package("stringr")
#> [32m✔[39m Adding [34m'stringr'[39m to [32mImports[39m field in DESCRIPTION
#> [31m•[39m Refer to functions with [90m`stringr::fun()`[39m
```

This adds the stringr package to the "Imports" section of `DESCRIPTION`.
And that is all it does.



Let's revisit `strsplit1()` to make it more stringr-like.
Here's a new take on it:


```r
str_split_one <- function(string, pattern, n = Inf) {
  stopifnot(is.character(string), length(string) <= 1)
  if (length(string) == 1) {
    stringr::str_split(string = string, pattern = pattern, n = n)[[1]]
  } else {
    character()
  }
}
```

Notice that we:

* Rename the function to `str_split_one()`, to signal that that is a wrapper
  around `stringr::str_split()`.
* Adopt the argument names from `stringr::str_split()`. Now we have `string` and
  `pattern` (and `n`), instead of `x` and `split`.
* Introduce a bit of argument checking and edge case handling. This is
  unrelated to the switch to stringr and would be equally beneficial in the
  version built on `strsplit()`.
* Use the `package::function()` form when calling `stringr::str_split()`. This
  specifies that we want to call the `str_split()` function from the stringr
  namespace. There is more than one way to call a function from another
  package and the one we endorse here is explained fully in chapter
  \@ref(namespace).

Where should we write this new function definition?
I'd like to keep following the convention where we name the `.R` file after the function it defines, so now we need to do some fiddly file shuffling.
Because this comes up fairly often in real life, we have the `rename_files()` function, which choreographs the renaming of a file in `R/` and its associated companion files below `test/`.


```r
rename_files("strsplit1", "str_split_one")
#> [32m✔[39m Moving [34m'R/strsplit1.R'[39m to [34m'R/str_split_one.R'[39m
#> [32m✔[39m Moving [34m'tests/testthat/test-strsplit1.R'[39m to [34m'tests/testthat/test-str_split_one.R'[39m
```

Remember: the file name work is purely aspirational.
We still need to update the contents of these files!

Here are the updated contents of `R/str_split_one.R`.
In addition to changing the function definition, we've also updated the roxygen header to reflect the new arguments and to include examples that show off the stringr features.


```{.r .R}
#' Split a string
#'
#' @param string A character vector with, at most, one element.
#' @inheritParams stringr::str_split
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' x <- "alfa,bravo,charlie,delta"
#' str_split_one(x, pattern = ",")
#' str_split_one(x, pattern = ",", n = 2)
#'
#' y <- "192.168.0.1"
#' str_split_one(y, pattern = stringr::fixed("."))
str_split_one <- function(string, pattern, n = Inf) {
  stopifnot(is.character(string), length(string) <= 1)
  if (length(string) == 1) {
    stringr::str_split(string = string, pattern = pattern, n = n)[[1]]
  } else {
    character()
  }
}
```

Don't forget to also update the test file!

Here are the updated contents of `tests/testthat/test-str_split_one.R`.
In addition to the change in the function's name and arguments, we've added a couple more tests.


```{.r .R}
test_that("str_split_one() splits a string", {
  expect_equal(str_split_one("a,b,c", ","), c("a", "b", "c"))
})

test_that("str_split_one() errors if input length > 1", {
  expect_error(str_split_one(c("a,b","c,d"), ","))
})

test_that("str_split_one() exposes features of stringr::str_split()", {
  expect_equal(str_split_one("a,b,c", ",", n = 2), c("a", "b,c"))
  expect_equal(str_split_one("a.b", stringr::fixed(".")), c("a", "b"))
})
```

Before we take the new `str_split_one()` out for a test drive, we need to call `document()`.
Why?
Remember that `document()` does two main jobs:

1. Converts our roxygen comments into proper R documentation.
1. (Re)generates `NAMESPACE`.

The second point is especially important here, since we will no longer export `strsplit1()` and we will newly export `str_split_one()`.
Don't be dismayed by the warning about `"Objects listed as exports, but not present in namespace: strsplit1"`.
That always happens when you remove something from the namespace.


```r
document()
#> [36mℹ[39m Updating [34m[34mregexcite[34m[39m documentation
#> [36mℹ[39m Loading [34m[34mregexcite[34m[39m
#> Warning in setup_ns_exports(path, export_all, export_imports):
#> Objects listed as exports, but not present in namespace: strsplit1
#> Writing NAMESPACE
#> Writing NAMESPACE
#> Writing str_split_one.Rd
#> Deleting strsplit1.Rd
```

Try out the new `str_split_one()` function by simulating package installation via `load_all()`:


```r
load_all()
#> [36mℹ[39m Loading [34m[34mregexcite[34m[39m
str_split_one("a, b, c", pattern = ", ")
#> [1] "a" "b" "c"
```



## `use_github()`

You've seen us making commits during the development process for regexcite.
You can see an indicative history at <https://github.com/jennybc/regexcite>.
Our use of version control and the decision to expose the development process means you can inspect the state of the regexcite source at each developmental stage.
By looking at so-called diffs, you can see exactly how each devtools helper function modifies the source files that constitute the regexcite package.

How would you connect your local regexcite package and Git repository to a companion repository on GitHub?

1. [`use_github()`](https://usethis.r-lib.org/reference/use_github.html) is a
   helper that we recommend for the long-term. We won't demonstrate it here
   because it requires some credential setup on your end. We also don't want to
   tear down and rebuild the public regexcite package every time we build this
   book.
1. Set up the GitHub repo first! It sounds counter-intuitive, but the easiest way
   to get your work onto GitHub is to initiate there, then use RStudio to start
   working in a synced local copy. This approach is described in Happy Git's
   workflows [New project, GitHub first](https://happygitwithr.com/new-github-first.html) and [Existing project, GitHub first](https://happygitwithr.com/existing-github-first.html).
1. Command line Git can always be used to add a remote repository *post hoc*.
   This is described in the Happy Git workflow [Existing project, GitHub last](https://happygitwithr.com/existing-github-last.html).

Any of these approaches will connect your local regexcite project to a GitHub repo, public or private, which you can push to or pull from using the Git client built into RStudio.

## `use_readme_rmd()`

Now that your package is on GitHub, the `README.md` file matters.
It is the package's home page and welcome mat, at least until you decide to give it a website (see [pkgdown](https://pkgdown.r-lib.org)), add a vignette (see chapter \@ref(vignettes)), or submit it to CRAN (see chapter \@ref(release)).

The `use_readme_rmd()` function initializes a basic, executable `README.Rmd` ready for you to edit:


```r
use_readme_rmd()
#> [32m✔[39m Writing [34m'README.Rmd'[39m
#> [32m✔[39m Adding [34m'^README\\.Rmd$'[39m to [34m'.Rbuildignore'[39m
#> [31m•[39m Update [34m'README.Rmd'[39m to include installation instructions.
#> [32m✔[39m Writing [34m'.git/hooks/pre-commit'[39m
```

In addition to creating `README.Rmd`, this adds some lines to `.Rbuildignore`, and creates a Git pre-commit hook to help you keep `README.Rmd` and `README.md` in sync.

`README.Rmd` already has sections that prompt you to:

* Describe the purpose of the package.
* Provide installation instructions. If a GitHub remote is detected when
  `use_readme_rmd()` is called, this section is pre-filled with instructions on
  how to install from GitHub.
* Show a bit of usage.

How to populate this skeleton?
Copy stuff liberally from `DESCRIPTION` and any formal and informal tests or examples you have.
Anything is better than nothing.
Otherwise ... do you expect people to install your package and comb through individual help files to figure out how to use it?
They probably won't.

We like to write the `README` in R Markdown, so it can feature actual usage.
The inclusion of live code also makes it less likely that your `README` grows stale and out-of-sync with your actual package.

If RStudio has not already done so, open `README.Rmd` for editing.
Make sure it shows some usage of `str_split_one()`.

The `README.Rmd` we use is here: [README.Rmd](https://github.com/jennybc/regexcite/blob/main/README.Rmd) and here's what it contains:



:::sourceCode

````
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
````
:::

Don't forget to render it to make `README.md`!
The pre-commit hook should remind you if you try to commit `README.Rmd`, but not `README.md`, and also when `README.md` appears to be out-of-date.

The very best way to render `README.Rmd` is with `build_readme()`, because it takes care to render with the most current version of your package, i.e. it installs a temporary copy from the current source.


```r
build_readme()
#> [36mℹ[39m Installing [34m[34mregexcite[34m[39m in temporary library
#> [36mℹ[39m Building [34m[34m/tmp/RtmpOdlRpJ/regexcite/README.Rmd[34m[39m
```

You can see the rendered `README.md` simply by [visiting regexcite on GitHub](https://github.com/jennybc/regexcite#readme).

Finally, don't forget to do one last commit. And push, if you're using GitHub.





## The end: `check()` and `install()`

Let's run `check()` again to make sure all is still well.


```r
check()
```

:::downlit

```
#> [36m── R CMD check results ─────────────────── regexcite 0.0.0.9000 ────[39m
#> Duration: 24.3s
#> 
#> [32m0 errors ✔[39m | [32m0 warnings ✔[39m | [32m0 notes ✔[39m
```
:::

regexcite should have no errors, warnings or notes.
This would be a good time to re-build and install it properly. And celebrate!


```r
install()
```


```
* checking for file ‘/tmp/RtmpOdlRpJ/regexcite/DESCRIPTION’ ... OK
* preparing ‘regexcite’:
* checking DESCRIPTION meta-information ... OK
* checking for LF line-endings in source and make files and shell scripts
* checking for empty or unneeded directories
Removed empty directory ‘regexcite/tests/testthat/_snaps’
* building ‘regexcite_0.0.0.9000.tar.gz’
Running /opt/R/4.1.2/lib/R/bin/R CMD INSTALL \
  /tmp/RtmpOdlRpJ/regexcite_0.0.0.9000.tar.gz --install-tests 
* installing to library ‘/home/runner/work/_temp/Library’
* installing *source* package ‘regexcite’ ...
** using staged installation
** R
** tests
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (regexcite)
```

Feel free to visit the [regexcite package](https://github.com/jennybc/regexcite) on GitHub, which is exactly as developed here.
The commit history reflects each individual step, so use the diffs to see the addition and modification of files, as the package evolved.
The rest of this book goes in greater detail for each step you've seen here and much more.


