# The package within {#package-within}





This part of the book ends the same way it started, with the development of a small toy package.
The [whole game chapter](#whole-game) established the basic mechanics, workflow, and tooling of package development, but said practically nothing about the R code inside the package.
Here we have a totally different emphasis.
In this chapter, we focus primarily on the package's R code and how it differs from R code in a script.

We start with a data analysis script and show how to find the package that lurks within.
We isolate and then extract reusable data and logic from the script, put this into an R package, and then use that package in a much simplified script.
We make a few rookie mistakes along the way, in order to highlight special considerations for the R code inside a package.

*The section headers incorporate the NATO phonetic alphabet and have no specific meaning.
They are just a convenient way to mark our progress towards a working package.*

## Alfa: a script that works

Here is a fictional data analysis script `data-cleaning.R` for a group that collects reports from people who went for a swim:

> Where did you swim and how hot was it outside?

Their data usually comes as a CSV file, which they read into a data frame.




```r
infile <- "swim.csv"
(dat <- read.csv(infile))
#>   name    where temp
#> 1 Adam    beach   95
#> 2 Bess    coast   91
#> 3 Cora seashore   28
#> 4 Dale    beach   85
#> 5 Evan  seaside   31
```

They then classify each observation as using American ("US") or British ("UK") English, based on the word chosen to describe the sandy place where the ocean and land meet.
The `where` column is used to build the new `english` column.


```r
dat$english[dat$where == "beach"] <- "US"
dat$english[dat$where == "coast"] <- "US"
dat$english[dat$where == "seashore"] <- "UK"
dat$english[dat$where == "seaside"] <- "UK"
```

Sadly, the temperatures are often reported in a mix of Fahrenheit and Celsius.
In the absence of better information, they guess that Americans report temperatures in Fahrenheit and therefore those observations are converted to Celsius.


```r
dat$temp[dat$english == "US"] <- (dat$temp[dat$english == "US"] - 32) * 5/9
dat
#>   name    where temp english
#> 1 Adam    beach 35.0      US
#> 2 Bess    coast 32.8      US
#> 3 Cora seashore 28.0      UK
#> 4 Dale    beach 29.4      US
#> 5 Evan  seaside 31.0      UK
```

Finally, this cleaned (cleaner?) data is written back out to a CSV file.
They like to capture a timestamp in the filename when they do this[^format-posixct].

[^format-posixct]: `Sys.time()` returns an object of class `POSIXct`, therefore when we call `format()` on it, we are actually using `format.POSIXct()`. Read the help for [`?format.POSIXct`](https://rdrr.io/r/base/strptime.html) if you're not familiar with such format strings.


```r
now <- Sys.time()
timestamp <- format(now, "%Y-%B-%d_%H-%M-%S")
(outfile <- paste0(timestamp, "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile)))
#> [1] "2022-February-06_07-13-15_swim_clean.csv"
write.csv(dat, file = outfile, quote = FALSE, row.names = FALSE)
```



Even if your typical analytical tasks are quite different, hopefully you see a few familiar patterns here.
It's easy to imagine that this group does very similar pre-processing of many similar data files over time.
Their analyses can be more efficient and consistent if they make these standard data maneuvers available to themselves as functions in a package, instead of inlining the same data and logic into dozens or hundreds of data ingest scripts.

## Bravo: a better script that works

The package that lurks within the original script is actually pretty hard to see!
It's obscured by a few suboptimal coding practices, such as the use of repetitive copy/paste-style code and the mixing of code and data.
Therefore a good first step is to refactor this code, isolating as much data and logic as possible in proper objects and functions, respectively.

At the same time, we introduce the use of some add-on packages, for several reasons.
First, we would actually use the tidyverse for this sort of data wrangling.
Second, many people use add-on packages in their scripts, so it is good to see how add-on packages are handled as we create this package.

Here's the next version of the script.




```r
library(tidyverse)

infile <- "swim.csv"
dat <- read_csv(infile, col_types = cols(name = "c", where = "c", temp = "d"))

lookup_table <- tribble(
      ~where, ~english,
     "beach",     "US",
     "coast",     "US",
  "seashore",     "UK",
   "seaside",     "UK"
)

dat <- dat %>% 
  left_join(lookup_table)
#> Joining, by = "where"

f_to_c <- function(x) (x - 32) * 5/9

dat <- dat %>% 
  mutate(temp = if_else(english == "US", f_to_c(temp), temp))
dat
#> [90m# A tibble: 5 × 4[39m
#>   name  where     temp english
#>   [3m[90m<chr>[39m[23m [3m[90m<chr>[39m[23m    [3m[90m<dbl>[39m[23m [3m[90m<chr>[39m[23m  
#> [90m1[39m Adam  beach     35   US     
#> [90m2[39m Bess  coast     32.8 US     
#> [90m3[39m Cora  seashore  28   UK     
#> [90m4[39m Dale  beach     29.4 US     
#> [90m5[39m Evan  seaside   31   UK

now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}
write_csv(dat, outfile_path(infile))
```



The key features to note are:

  * We are using functions from tidyverse packages (specifically from readr and
    dplyr).
  * The map between different "beach" words and whether they are considered to be
    US or UK English is now isolated in a lookup table, which lets us create
    the `english` column in one go with a `left_join()`. This also makes it
    easier to add new words in the future
  * The `f_to_c()`, `timestamp()`, and `outfile_path()` functions now hold the
    logic for converting temperatures and forming the timestamped output file
    name.

It's getting easier to recognize the reusable bits of this script, i.e. the bits that have nothing to do with a specific input file, like `swim.csv`.
This sort of refactoring often happens naturally on the way to creating your own package, but if it does not, it's a good idea to do this intentionally.

## Charlie: external helpers

A typical next step is to move reusable data and logic out of the analysis script and into one or more separate files.
This is a conventional opening move, if you want to use these same helper files in multiple analyses.

Here is the content of `beach-lookup-table.csv`:




```
where,english
beach,US
coast,US
seashore,UK
seaside,UK
```

Here is the content of `cleaning-helpers.R`:


```r
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
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}
```

We've added some high-level helper functions, `localize_beach()` and `celsify_temp()`, to the pre-existing helpers (`f_to_c()`, `timestamp()`, and `outfile_path()`).

Here is the next version of the data cleaning script, now that we've pulled out the helper functions (and lookup table).






```r
library(tidyverse)
source("cleaning-helpers.R")

infile <- "swim.csv"
dat <- read_csv(infile, col_types = cols(name = "c", where = "c", temp = "d"))

(dat <- dat %>% 
    localize_beach() %>% 
    celsify_temp())
#> Joining, by = "where"
#> [90m# A tibble: 5 × 4[39m
#>   name  where     temp english
#>   [3m[90m<chr>[39m[23m [3m[90m<chr>[39m[23m    [3m[90m<dbl>[39m[23m [3m[90m<chr>[39m[23m  
#> [90m1[39m Adam  beach     35   US     
#> [90m2[39m Bess  coast     32.8 US     
#> [90m3[39m Cora  seashore  28   UK     
#> [90m4[39m Dale  beach     29.4 US     
#> [90m5[39m Evan  seaside   31   UK

write_csv(dat, outfile_path(infile))
```



You'll notice that the script is getting shorter and, hopefully, easier to read and modify, because repetitive and fussy clutter has been moved out of sight.
Whether the code is actually easier to work with is subjective and depends on how natural the "interface" feels for the people who actually preprocess swimming data.
These sorts of design decisions are the subject of a separate project: [principles.tidyverse.org](https://principles.tidyverse.org).

Let's assume the group agrees that our design decisions are promising, i.e. we seem to be making things better, not worse.
Sure, the existing code is not perfect, but this is a typical developmental stage when you're trying to figure out what the helper functions should be and how they should work.

## Delta: an attempt at a package

Let's make a package! Here's the simplest thing you might hope will "just work": make `cleaning-helpers.R` into an R package. Somehow.

Concretely, we do this:

  * Use `usethis::create_package()` to scaffold a new R package.
    - This is a good first step!
  * Copy `cleaning-helpers.R` into the new package, specifically, to
    `R/cleaning-helpers.R`.
    - This is morally correct, but mechanically wrong in several ways, as we
      will soon see.
  * Copy `beach-lookup-table.csv` into the new package. But where? Let's try
    the top-level of the source package.
    - This is not going to end well. Shipping data in a package is a special
      topic, which is covered in chapter \@ref(data).
  * Install this package.
    - Despite all of the problems identified above, this actually works! Which
      is interesting, because we can (try to) use it and see what happens.
      
Here's the version of the script that you hope will run after successfully installing this package.


```r
library(tidyverse)
library(delta)

infile <- "swim.csv"
dat <- read_csv(infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat %>% 
  localize_beach() %>% 
  celsify_temp()

write_csv(dat, outfile_path(infile))
```

The only change from our previous script is that


```r
source("cleaning-helpers.R")
```

has been replaced by


```r
library(delta)
```

Here's what actually happens when we try to run this:


```r
library(tidyverse)
library(delta)

infile <- "swim.csv"
dat <- read_csv(infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat %>% 
  localize_beach() %>% 
  celsify_temp()
#> Error in localize_beach(.) : could not find function "localize_beach"

write_csv(dat, outfile_path(infile))
#> Error in outfile_path(infile) : could not find function "outfile_path"
```

None of our helper functions are actually available for use, even though we call `library(delta)`!
In contrast to `source()`ing a file of helper functions, attaching a package does not dump its functions into the global workspace.
By default, functions in a package are only for internal use.
We need to export `localize_beach()`, `celsify_temp()`, and `outfile_path()` so our users can call them.
In this book, we achieve this by putting `@export` in the special roxygen comment above each function (namespace management is covered in chapter \@ref(namespace)).


```r
#' @export
celsify_temp <- function(dat) {
  mutate(dat, temp = if_else(english == "US", f_to_c(temp), temp))
}
```

Let's say we do that, run `devtools::document()` to (re)generate a `NAMESPACE` file, and re-install the package.
Now when we execute our script, it works!

Correction: it works *sometimes*.
Specifically, it works if and only if the working directory is set to the top-level of the source package.
From any other working directory, we still get an error:


```r
library(tidyverse)
library(delta)

infile <- "swim.csv"
dat <- read_csv(infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat %>% 
  localize_beach() %>% 
  celsify_temp()
#> Error: 'beach-lookup-table.csv' does not exist in current working directory ('/Users/jenny/tmp').

write_csv(dat, outfile_path(infile))
```

The lookup table consulted inside `localize_beach()` cannot be found.
One does not simply dump CSV files into the source of an R package and expect things to "just work".
We will fix this in our next iteration of the package (chapter \@ref(data) has full coverage of how to include data in a package).

Before we abandon this initial experiment, let's also marvel at the fact that we were able to install, attach, and, to a certain extent, use a fundamentally broken package.
`load_all()` works fine, too!
This is a sobering reminder that you should be running `R CMD check`, probably via `check()`, very often during development.
This will quickly alert you to many problems that simple installation and usage does not reveal.

Indeed, `R CMD check` fails for this package and we see this[^configure-license]:

[^configure-license]: If you have not done so already, you'll also need to configure a license to satisfy `R CMD check`.
For a quick experiment like this, `usethis::use_mit_license()` is fine.
For real work, see chapter \@ref(license) for guidance.

```
* installing *source* package ‘delta’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
Error in library(tidyverse) : there is no package called ‘tidyverse’
Error: unable to load R code in package ‘delta’
Execution halted
ERROR: lazy loading failed for package ‘delta’
* removing ‘/Users/jenny/rrr/delta.Rcheck/delta’
```

What do you mean "there is no package called 'tidyverse'"?!?
We're using it, with no problems, in our main script!
Also, we've already installed and used this package, why can't `R CMD check` install it?

This error is what happens when the strictness of `R CMD check` meets the very first line of `R/cleaning-helpers.R`:


```r
library(tidyverse)
```

This is **not** how you declare that your package depends on another package (the tidyverse, in this case).
This is **not** how you make functions in another package available for use in yours.
Dependencies must be declared in `DESCRIPTION` (and that's not all).
Since we declared no dependencies, `R CMD check` takes us at our word and tries to install our package with only the base packages available, which means this `library(tidyverse)` call fails.
A "regular" installation succeeds, simply because the tidyverse is available in your regular library, which hides this particular mistake.

To review, copying `cleaning-helpers.R` to `R/cleaning-helpers.R`, without further modification, was problematic in (at least) these ways:

* Does not account for exported vs. non-exported functions.
* The CSV file holding our lookup table cannot be found in the installed 
  package.
* Does not properly declare our dependency on other add-on packages.

## Echo: a working package

We're ready to make the most minimal version of this package that actually works.

Here is the new version of `R/cleaning-helpers.R`[^bad-file-name]:

[^bad-file-name]: Putting everything in one file, with this name, is not ideal, but it is technically allowed.
We discuss organising and naming the files below `R/` in section \@ref(code-organising).


```r
lookup_table <- dplyr::tribble(
      ~where, ~english,
     "beach",     "US",
     "coast",     "US",
  "seashore",     "UK",
   "seaside",     "UK"
)

#' @export
localize_beach <- function(dat) {
  dplyr::left_join(dat, lookup_table)
}

f_to_c <- function(x) (x - 32) * 5/9

#' @export
celsify_temp <- function(dat) {
  dplyr::mutate(dat, temp = dplyr::if_else(english == "US", f_to_c(temp), temp))
}

now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")

#' @export
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}
```

We've gone back to defining the `lookup_table` with R code, since our initial attempt to read it from CSV created some sort of filepath snafu.
This is OK for small, internal, static data, but remember to see chapter \@ref(data) for more general techniques for storing data in a package.

All of our calls to tidyverse functions have now been qualified with the name of the specific package that actually provides the function, e.g. `dplyr::mutate()`.
There are other ways to access functions in another package, explained in chapter \@ref(namespace), but this is our recommended default.
It is also our strong recommendation that no one depend on the tidyverse meta-package in a package[^do-not-depend-on-tidyverse].
Instead, it is better to identify the specific package(s) you actually use.
In this case, our package only uses dplyr.

[^do-not-depend-on-tidyverse]: The blog post [The tidyverse is for EDA, not packages](https://www.tidyverse.org/blog/2018/06/tidyverse-not-for-packages/) elaborates on this.

The `library(tidyverse)` call is gone and instead we declare our use of dplyr in the Imports field of `DESCRIPTION`:

```
Package: echo
(... other lines omitted ...)
Imports: 
    dplyr
```

This, together with our use of namespace-qualified calls, like `dplyr::left_join()`, constitutes a valid way to use another package within ours.
The metadata conveyed via DESCRIPTION is covered in chapter \@ref(description).

All of the user-facing functions have an `@export` tag in their roxygen comment, which means that `devtools::document()` adds them correctly to the `NAMESPACE` file.
Note that `f_to_c()` is currently only used internally, inside `celsify_temp()`, so we have not exported it (likewise for `timestamp()`).

This version of the package can be installed, used, AND it technically passes `R CMD check`, though with 1 note and 1 warning.

```
* checking R code for possible problems ... NOTE
celsify_temp: no visible binding for global variable ‘english’
celsify_temp: no visible binding for global variable ‘temp’
Undefined global functions or variables:
  english temp

* checking for missing documentation entries ... WARNING
Undocumented code objects:
  ‘celsify_temp’ ‘localize_beach’ ‘outfile_path’
All user-level objects in a package should have documentation entries.
See chapter ‘Writing R documentation files’ in the ‘Writing R
Extensions’ manual.
```

The "no visible binding" note is a peculiarity of using dplyr and unquoted variable names inside a package, where the use of bare variable names (`english` and `temp`) looks suspicious.
We could add either of these lines to any file below `R/` to eliminate this note[^dplyr-global-variables-note]:

[^dplyr-global-variables-note]: For more details, see the [Programming with dplyr vignette](https://dplyr.tidyverse.org/articles/programming.html#eliminating-r-cmd-check-notes).


```r
# option 1 (then you should also put utils in Imports)
utils::globalVariables(c("english", "temp"))

# option 2
english <- temp <- NULL
```

The warning about missing documentation is because we haven't properly documented our exported functions.
This is a valid concern and something you should absolutely address in a real package.
You've already seen how to create help files with roxygen comments in [the whole game chapter](whole-game-document) and we cover this topic thoroughly in chapter \@ref(man).
Therefore, we won't discuss this further here.

## Foxtrot: build time vs. run time {#package-within-build-time-run-time}

The package works, which is great, but group members notice something odd about the timestamps:


```r
Sys.time()
#> [1] "2020-09-03 16:12:29 PDT"

outfile_path("INFILE.csv")
#> [1] "2020-September-03_11-06-33_INFILE_clean.csv"
```

The datetime in the timestamped filename doesn't reflect the time reported by the system.
In fact, the users claim that the timestamp never seems to change at all!
Why is this?

Recall how we form the filepath for output files:


```r
now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}
```

The fact that we capture `now <- Sys.time()` outside of the definition of `outfile_path()` has probably been vexing some readers for a while.
`now` reflects the instant in time when we execute `now <- Sys.time()`.
In the initial approach, that happened when we `source()`d `cleaning-helpers.R`.
That's not ideal, but it was probably a pretty harmless mistake, because the helper file would be `source()`d shortly before we wrote the outfile.

But this approach is quite devastating in the context of a package.
`now <- Sys.time()` is executed **when the package is built**.
And never again.
It is very easy to subconsciously assume your package code is re-evaluated when the package is installed, attached, or used.
But it is not.
Yes, the code *inside your functions* is absolutely run whenever they are called.
But your functions -- and any other objects created in top-level code below `R/` -- are defined exactly once, at build time.

By defining `now` with top-level code below `R/`, we've doomed our package to timestamp all of its output files with the same (wrong) time.
The fix is to make sure the `Sys.time()` call happens at runtime.

Let's look again at parts of `R/cleaning-helpers.R`:


```r
lookup_table <- dplyr::tribble(
      ~where, ~english,
     "beach",     "US",
     "coast",     "US",
  "seashore",     "UK",
   "seaside",     "UK"
)

now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}
```

There are four top-level `<-` assignments in this excerpt.
The top-level definitions of the data frame `lookup_table` and the functions `timestamp()` and `outfile_path()` are correct.
It is appropriate that these be defined exactly once, at build time.
The top-level definition of `now`, which is then used inside `outfile_path()`, is incorrect.

Here are better versions of `outfile_path()`:


```r
# always timestamp as "now"
outfile_path <- function(infile) {
  ts <- timestamp(Sys.time())
  paste0(ts, "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}

# allow user to provide a time, but default to "now"
outfile_path <- function(infile, time = Sys.time()) {
  ts <- timestamp(time)
  paste0(ts, "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}
```

This illustrates that you need to have a different mindset when defining objects inside a package.
The vast majority of those objects should be functions and these functions should generally only use data they create or that is passed via an argument.
There are some types of sloppiness that are fairly harmless when a function is defined immediately before its use, but that can be more costly for functions distributed as a package.

## Golf: side effects {#package-within-side-effects}

The timestamps now reflect the current time, but the group raises a new concern.
As it stands, the timestamps reflect who has done the data cleaning and which part of the world they're in.
The heart of the timestamp strategy is this format string[^format-posixct]:


```r
format(Sys.time(), "%Y-%B-%d_%H-%M-%S")
#> [1] "2022-February-06_07-13-16"
```

This formats `Sys.time()` in such a way that it includes the month *name* (not number) and the local time[^month-name-vs-number].

[^month-name-vs-number]: It would clearly be better to format according to ISO 8601, which encodes the month by number, but please humor me for the sake of making this example more obvious.

Here's such a timestamp produced by a few hypothetical colleagues cleaning some data at exactly the same instant in time.




|location           |timestamp                  |LC_TIME |tz                |
|:------------------|:--------------------------|:-------|:-----------------|
|Rome, Italy        |2020-September-05_00-30-00 |it_IT   |Europe/Rome       |
|Warsaw, Poland     |2020-September-05_00-30-00 |pl_PL   |Europe/Warsaw     |
|Sao Paulo, Brazil  |2020-September-04_19-30-00 |pt_BR   |America/Sao_Paulo |
|Greenwich, England |2020-September-04_23-30-00 |en_GB   |Europe/London     |
|"Computer World!"  |2020-September-04_22-30-00 |C       |UTC               |

We see that the month names vary, as does the time, and even the date!
The safest choice is to form timestamps with respect to a fixed locale and time zone (presumably the non-geographic choices represented by "Computer World!" above).

You do some research and learn that you can force a certain locale via `Sys.setlocale()` and force a certain time zone by setting the TZ environment variable.
Specifically, we set the LC_TIME component of the locale to "C" and the time zone to "UTC" (Coordinated Universal Time).
Here's your first attempt to improve `timestamp()`:




```r
timestamp <- function(time = Sys.time()) {
  Sys.setlocale("LC_TIME", "C")
  Sys.setenv(TZ = "UTC")
  format(time, "%Y-%B-%d_%H-%M-%S")
}
```

But your Brazilian colleague notices that datetimes print differently, before and after she uses `outfile_path()` from your package:

Before:


```r
format(Sys.time(), "%Y-%B-%d_%H-%M-%S")
```


```
#> Warning in (function (category = "LC_ALL", locale = "") : OS reports
#> request to set locale to "pt_BR" cannot be honored
#> [1] "2022-February-06_04-13-16"
```

After:

```r
outfile_path("INFILE.csv")
#> [1] "2022-February-06_07-13-16_INFILE_clean.csv"

format(Sys.time(), "%Y-%B-%d_%H-%M-%S")
#> [1] "2022-February-06_07-13-16"
```



Notice that her month name switched from Portuguese to English and the time is clearly being reported in a different time zone.
Our calls to `Sys.setlocale()` and `Sys.setenv()` inside `timestamp()` have made persistent (and very surprising) changes to her R session.
This sort of side effect is very undesirable and is extremely difficult to track down and debug, especially in more complicated settings. 

Here are better versions of `timestamp()`:


```r
# use withr::local_*() functions to keep the changes local to timestamp()
timestamp <- function(time = Sys.time()) {
  withr::local_locale(c("LC_TIME" = "C"))
  withr::local_timezone("UTC")
  format(time, "%Y-%B-%d_%H-%M-%S")
}

# use the tz argument to format.POSIXct()
timestamp <- function(time = Sys.time()) {
  withr::local_locale(c("LC_TIME" = "C"))
  format(time, "%Y-%B-%d_%H-%M-%S", tz = "UTC")
}

# put the format() call inside withr::with_*()
timestamp <- function(time = Sys.time()) {
  withr::with_locale(
    c("LC_TIME" = "C"),
    format(time, "%Y-%B-%d_%H-%M-%S", tz = "UTC")
  )
}
```

We show various methods to limit the scope of our changes to LC_TIME and the timezone.
A good rule of thumb is to make the scope of such changes as narrow as is possible and practical.
The `tz` argument of `format()` is the most surgical way to deal with the timezone, but nothing similar exists for LC_TIME.
We make the temporary locale modification using the withr package, which provides a very flexible toolkit for temporary state changes.
This (and `base::on.exit()`) are discussed further in section \@ref(code-r-landscape).

This underscores a point from the previous section: you need to adopt a different mindset when defining functions inside a package.
Try to avoid making any changes to the user's overall state.
If such changes are unavoidable, make sure to reverse them (if possible) or to document them explicitly (if related to the function's primary purpose).



<!--

Loose ends and Unimplemented ideas

Inconsistent w.r.t. voice: is it "they" or "you" or "we" who's writing this package?

Another data cleaning idea was to deal with dysfunctional missing value codes, e.g. where -99 means temp is missing.

Could also show using the degree symbol properly with unicode escape sequence.

-->

<!--

Text to possible reuse?

As your use of R becomes more sophisticated, it's common to start to write your own R functions.
If a function is only used in one place, you probably define it right there.
But if you've bothered to write a function, it's likely you want to reuse it in multiple places: within one script, across multiple scripts, or even across multiple projects.
This is *exactly* what an R package is for!

Without package technology, you probably collect these function definitions in one or more dedicated `.R` files and then `source()` them as needed.
Typically these functions co-evolve with the code where you use them, i.e. your analysis code, your Shiny apps, or your R Markdown reports.
If you use these functions across multiple projects, you also face the uncomfortable dilemma of where to define them and whether to have multiple, slightly different copies of this code lying around.

-->
