# (PART) Getting started {-}



# Introduction {#intro}



In R, the fundamental unit of shareable code is the package. A package bundles together code, data, documentation, and tests, and is easy to share with others. As of June 2019, there were over 14,000 packages available on the **C**omprehensive **R** **A**rchive **N**etwork, or CRAN, the public clearing house for R packages. This huge variety of packages is one of the reasons that R is so successful: the chances are that someone has already solved a problem that you're working on, and you can benefit from their work by downloading their package.

If you're reading this book, you already know how to use packages:

* You install them from CRAN with `install.packages("x")`.
* You use them in R with `library("x")`.
* You get help on them with `package?x` and `help(package = "x")`.

The goal of this book is to teach you how to develop packages so that you can write your own, not just use other people's. Why write a package? One compelling reason is that you have code that you want to share with others. Bundling your code into a package makes it easy for other people to use it, because like you, they already know how to use packages. If your code is in a package, any R user can easily download it, install it and learn how to use it.

But packages are useful even if you never share your code. As Hilary Parker says in her [introduction to packages](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/): "Seriously, it doesn't have to be about sharing your code (although that is an added benefit!). It is about saving yourself time." Organising code in a package makes your life easier because packages come with conventions. For example, you put R code in `R/`, you put tests in `tests/` and you put data in `data/`. These conventions are helpful because:

* They save you time --- you don't need to think about the best way to organise
  a project, you can just follow a template.
  
* Standardised conventions lead to standardised tools --- if you buy into
  R's package conventions, you get many tools for free.

It's even possible to use packages to structure your data analyses, as described by Marwick, Boettiger, and Mullen in [@marwick2018-tas] [@marwick2018-peerj].

## Philosophy {#intro-phil}

This book espouses our philosophy of package development: anything that can be automated, should be automated. Do as little as possible by hand. Do as much as possible with functions. The goal is to spend your time thinking about what you want your package to do rather than thinking about the minutiae of package structure.

This philosophy is realised primarily through the devtools package, which is the public face for a suite of R functions that automate common development tasks. The release of version 2.0.0 in October 2018 marked its internal restructuring into a set of more focused packages, with devtools becoming more of a meta-package. The usethis package is the sub-package you are most likely to interact with directly; we explain the devtools-usethis relationship in section \@ref(setup-usage).

As always, the goal of devtools is to make package development as painless as possible. It encapsulates the best practices developed by first author Hadley Wickham, initially from years as a prolific solo developer. More recently, he has assembled a team of ~10 developers at RStudio, who collectively look after ~150 open source R packages, including those known as [the tidyverse](https://www.tidyverse.org). The reach of this team allows us to explore the space of all possible mistakes at an extraordinary scale. Fortunately, it also affords us the opportunity to reflect on both the successes and failures, in the company of expert and sympathetic colleagues. We try to develop practices that make life more enjoyable for both the maintainer and users of a package. The devtools meta-package is where these lessons are made concrete.

:::rstudio-tip
Through the book, we highlight specific ways that RStudio can expedite your package development workflow, in specially formatted sections like this.
:::

devtools works hand-in-hand with RStudio, which we believe is the best development environment for most R users. The main alternative is [Emacs Speaks Statistics](http://ess.r-project.org/) (ESS), which is a rewarding environment if you're willing to put in the time to learn Emacs and customise it to your needs. The history of ESS stretches back over 20 years (predating R!), but it's still actively developed and many of the workflows described in this book are also available there. For those loyal to vim, we recommend the [Nvim-R plugin](https://github.com/jalvesaq/Nvim-R).

Together, devtools and RStudio insulate you from the low-level details of how packages are built. As you start to develop more packages, we highly recommend that you learn more about those details. The best resource for the official details of package development is always the official [writing R extensions][r-ext] manual. However, this manual can be hard to understand if you're not already familiar with the basics of packages. It's also exhaustive, covering every possible package component, rather than focusing on the most common and useful components, as this book does. Writing R extensions is a useful resource once you've mastered the basics and want to learn what's going on under the hood.

## In this book {#intro-outline}

Chapter \@ref(whole-game) runs through the development of a small toy package. It's meant to paint the Big Picture and suggest a workflow, before we descend into the detailed treatment of the key components of an R package.

Chapter \@ref(setup) describes how to prepare your system for package development, which has more requirements than simply running R scripts. This includes recommendations on some optional setup that can make your workflow more pleasant, which tends to lead to a higher-quality product.

The basic structure of a package and how that varies across different states is explained in chapter \@ref(package-structure-state).

Chapter \@ref(workflows101) goes over core workflows that come up repeatedly for package developers. This chapter also covers connections between our favored tools, such as devtools/usethis and RStudio, and the philosophies that drive the design of these tools.

Subsequent chapters of the book go into more details about each package component. They're roughly organised in order of importance:

* R code, chapter \@ref(r): the most important directory is `R/`, where your R
  code lives. A package with just this directory is still a useful package. (And
  indeed, if you stop reading the book after this chapter, you'll have still
  learned some useful new skills.)
  
* Package metadata, chapter \@ref(description): the `DESCRIPTION` lets you
  describe what your package needs to work. If you're sharing your package,
  you'll also use the `DESCRIPTION` to describe what it does, who can use it 
  (the license), and who to contact if things go wrong.

* Documentation, chapter \@ref(man): if you want other people (including
  future-you!) to understand how to use the functions in your package, you'll
  need to document them. We'll show you how to use roxygen2 to document your
  functions. We recommend roxygen2 because it lets you write code and
  documentation together while continuing to produce R's standard documentation
  format.
  
* Vignettes, chapter \@ref(vignettes): function documentation describes the
  nit-picky details of every function in your package. Vignettes give the big
  picture. They're long-form documents that show how to combine multiple parts
  of your package to solve real problems. We'll show you how to use Rmarkdown
  and knitr to create vignettes with a minimum of fuss.

* Tests, chapter \@ref(tests): to ensure your package works as designed (and
  continues to work as you make changes), it's essential to write unit tests
  which define correct behaviour, and alert you when functions break. In this
  chapter, we'll teach you how to use the testthat package to convert the
  informal interactive tests that you're already doing to formal, automated
  tests.

* Namespace, chapter \@ref(namespace): to play nicely with others, your package
  needs to define what functions it makes available to other packages and what
  functions it requires from other packages. This is the job of the `NAMESPACE`
  file and we'll show you how to use roxygen2 to generate it for you. 
  The `NAMESPACE` is one of the more challenging parts of developing an R 
  package but it's critical to master if you want your package to work reliably.
 
* External data, chapter \@ref(data): the `data/` directory allows you to
  include data with your package. You might do this to bundle data
  in a way that's easy for R users to access, or just to provide compelling 
  examples in your documentation.

* Compiled code, chapter \@ref(src): R code is designed for human efficiency,
  not computer efficiency, so it's useful to have a tool in your back pocket
  that allows you to write fast code. The `src/` directory allows you to include
  speedy compiled C and C++ code to solve performance bottlenecks in your
  package.

* Other components, chapter \@ref(misc): this chapter documents the handful of
  other components that are rarely needed: `demo/`, `exec/`, `po/` and `tools/`.

The final chapters describe general best practices not specifically tied to one directory:

* Git and GitHub, chapter \@ref(git): mastering a version control system is
  vital to easily collaborate with others, and is useful even for solo work
  because it allows you to easily undo mistakes. In this chapter, you'll learn
  how to use the popular Git and GitHub combo with RStudio.
  
* Automated checking, chapter \@ref(r-cmd-check): R provides very useful
  automated quality checks in the form of `R CMD check`. Running them regularly
  is a great way to avoid many common mistakes. The results can sometimes be a
  bit cryptic, so we provide a comprehensive cheatsheet to help you convert
  warnings to actionable insight.
  
* Release, chapter \@ref(release): the life-cycle of a package culminates with
  release to the public. This chapter compares the two main options (CRAN and
  GitHub) and offers general advice on managing the process.

This is a lot to learn, but don't feel overwhelmed. Start with a minimal subset of useful features (e.g. just an `R/` directory!) and build up over time. To paraphrase the Zen monk Shunryu Suzuki: "Each package is perfect the way it is --- and it can use a little improvement".

## Acknowledgments {#intro-ack}



Since the first edition of R Packages was published, the packages supporting the workflows described here have undergone extensive development. The original trio of devtools, roxygen2, and testthat has expanded to include the packages created by the ["conscious uncoupling" of devtools](#setup-usage). Most of these packages originate with Hadley Wickham (HW), because of their devtools roots. There are many other significant contributors, many of whom now serve as maintainers:

  * devtools: HW, [Winston Chang][winston], [Jim Hester][jim] (maintainer, >= v1.13.5)
  * usethis: HW, [Jennifer Bryan][jenny] (maintainer >= v1.5.0)
  * roxygen2: HW (maintainer), [Peter Danenburg][klutometis], [Manuel Eugster][mjaeugster]
  * testthat: HW (maintainer)
  * desc: [Gábor Csárdi][gabor] (maintainer), [Kirill Müller][kirill], [Jim Hester][jim]
  * pkgbuild: HW, [Jim Hester][jim] (maintainer)
  * pkgload: HW, [Jim Hester][jim] (maintainer), [Winston Chang][winston]
  * rcmdcheck: [Gábor Csárdi][gabor] (maintainer)
  * remotes: HW, [Jim Hester][jim] (maintainer), [Gábor Csárdi][gabor], [Winston Chang][winston], [Martin Morgan][mtmorgan], [Dan Tenenbaum][dtenenba]
  * revdepcheck: HW, [Gábor Csárdi][gabor] (maintainer)
  * sessioninfo: HW, [Gábor Csárdi][gabor] (maintainer), [Winston Chang][winston], [Robert Flight][rmflight], [Kirill Müller][kirill], [Jim Hester][jim]

This book and the R package development community benefit tremendously from experts who smooth over specific pain points:

  * [Kevin Ushey][kevin], [JJ Allaire](https://github.com/jjallaire), and [Dirk Eddelbuettel](http://dirk.eddelbuettel.com) tirelessly answered all sorts of C, C++, and Rcpp questions.
  * [Craig Citro](https://github.com/craigcitro) wrote much of the initial code to facilitate using Travis-CI with R packages.
  * [Jeroen Ooms](https://github.com/jeroen) also helps to maintain R community infrastructure, such as the current R support for Travis-CI (along with Jim Hester), and the Windows toolchain.

*TODO: revisit rest of this section when 2nd edition nears completion. Currently applies to and worded for 1st edition.*

Often the only way I learn how to do it the right way is by doing it the wrong way first. For suffering through many package development errors, I'd like to thank all the CRAN maintainers, especially Brian Ripley, Uwe Ligges and Kurt Hornik. 

This book was [written and revised in the open](https://github.com/hadley/r-pkgs/) and it is truly a community effort: many people read drafts, fix typos, suggest improvements, and contribute content. Without those contributors, the book wouldn't be nearly as good as it is, and we are deeply grateful for their help.

A special thanks goes to Peter Li, who read the book from cover-to-cover and provided many fixes. I also deeply appreciate the time the reviewers ([Duncan Murdoch](http://www.stats.uwo.ca/faculty/murdoch/), [Karthik Ram](http://karthik.io), [Vitalie Spinu](http://vitalie.spinu.info) and [Ramnath Vaidyanathan](https://ramnathv.github.io)) spent reading the book and giving me thorough feedback.

Thanks go to all contributors who submitted improvements via github (in alphabetical order): `@aaronwolen`, `@adessy`, Adrien Todeschini, Andrea Cantieni, Andy Visser, `@apomatix`, Ben Bond-Lamberty, Ben Marwick, Brett K, Brett Klamer, `@contravariant`, Craig Citro, David Robinson, David Smith, `@davidkane9`, Dean Attali, Eduardo Ariño de la Rubia, Federico Marini, Gerhard Nachtmann, Gerrit-Jan Schutten, Hadley Wickham, Henrik Bengtsson, `@heogden`, Ian Gow, `@jacobbien`, Jennifer (Jenny) Bryan, Jim Hester, `@jmarshallnz`, Jo-Anne Tan, Joanna Zhao, Joe Cainey, John Blischak, `@jowalski`, Justin Alford, Karl Broman, Karthik Ram, Kevin Ushey, Kun Ren, `@kwenzig`, `@kylelundstedt`, `@lancelote`, Lech Madeyski, `@lindbrook`, `@maiermarco`, Manuel Reif, Michael Buckley, `@MikeLeonard`, Nick Carchedi, Oliver Keyes, Patrick Kimes, Paul Blischak, Peter Meissner, `@PeterDee`, Po Su, R. Mark Sharp, Richard M. Smith, `@rmar073`, `@rmsharp`, Robert Krzyzanowski, `@ryanatanner`, Sascha Holzhauer, `@scharne`, Sean Wilkinson, `@SimonPBiggs`, Stefan Widgren, Stephen Frank, Stephen Rushe, Tony Breyal, Tony Fischetti, `@urmils`, Vlad Petyuk, Winston Chang, `@winterschlaefer`, `@wrathematics`, `@zhaoy`.

The light bulb image used for workflow tips comes from [www.vecteezy.com](https://www.vecteezy.com/vector-art/139644-ampoule-icons-vector).

## Conventions {#intro-conventions}

Throughout this book, we write `foo()` to refer to functions, `bar` to refer to variables and function parameters, and `baz/` for paths. 

Larger code blocks intermingle input and output. Output is commented so that if you have an electronic version of the book, e.g., <https://r-pkgs.org>, you can easily copy and paste examples into R. Output comments look like `#>` to distinguish them from regular comments.

## Colophon {#intro-colophon}

This book was authored using [R Markdown](https://rmarkdown.rstudio.com), using [bookdown](https://bookdown.org), inside [RStudio](https://www.rstudio.com/products/rstudio/). The [website](https://r-pkgs.org) is hosted with [Netlify](https://www.netlify.com), and automatically updated after every commit by GitHub actions. The complete source is available from [GitHub](https://github.com/hadley/r-pkgs).

This version of the book was built with:


```r
library(devtools)
#> Loading required package: usethis
library(roxygen2)
library(testthat)
#> 
#> Attaching package: 'testthat'
#> The following object is masked from 'package:devtools':
#> 
#>     test_file
devtools::session_info()
#> [1m[36m─ Session info ───────────────────────────────────────────────────[39m[22m
#>  [3m[90msetting [39m[23m [3m[90mvalue[39m[23m
#>  version  R version 4.2.0 (2022-04-22)
#>  os       Ubuntu 20.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language (EN)
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2022-06-04
#>  pandoc   2.14.2 @ /usr/bin/ (via rmarkdown)
#> 
#> [1m[36m─ Packages ───────────────────────────────────────────────────────[39m[22m
#>  [3m[90mpackage    [39m[23m [3m[90m*[39m[23m [3m[90mversion[39m[23m [3m[90mdate (UTC)[39m[23m [3m[90mlib[39m[23m [3m[90msource[39m[23m
#>  bookdown      0.26    [90m2022-04-15[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  brio          1.1.3   [90m2021-11-30[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  bslib         0.3.1   [90m2021-10-06[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  cachem        1.0.6   [90m2021-08-19[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  callr         3.7.0   [90m2021-04-20[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  cli           3.3.0   [90m2022-04-25[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  crayon        1.5.1   [90m2022-03-26[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  desc          1.4.1   [90m2022-03-06[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  devtools    * 2.4.3   [90m2021-11-30[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  digest        0.6.29  [90m2021-12-01[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  downlit       0.4.0   [90m2021-10-29[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  ellipsis      0.3.2   [90m2021-04-29[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  evaluate      0.15    [90m2022-02-18[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  fastmap       1.1.0   [90m2021-01-25[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  fs            1.5.2   [90m2021-12-08[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  glue          1.6.2   [90m2022-02-24[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  htmltools     0.5.2   [90m2021-08-25[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  jquerylib     0.1.4   [90m2021-04-26[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  jsonlite      1.8.0   [90m2022-02-22[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  knitr         1.39    [90m2022-04-26[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  lifecycle     1.0.1   [90m2021-09-24[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  magrittr      2.0.3   [90m2022-03-30[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  memoise       2.0.1   [90m2021-11-26[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  pkgbuild      1.3.1   [90m2021-12-20[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  pkgload       1.2.4   [90m2021-11-30[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  prettyunits   1.1.1   [90m2020-01-24[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  processx      3.5.3   [90m2022-03-25[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  ps            1.7.0   [90m2022-04-23[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  purrr         0.3.4   [90m2020-04-17[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  R6            2.5.1   [90m2021-08-19[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  remotes       2.4.2   [90m2021-11-30[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  rlang         1.0.2   [90m2022-03-04[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  rmarkdown     2.14    [90m2022-04-25[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  roxygen2    * 7.2.0   [90m2022-05-13[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  rprojroot     2.0.3   [90m2022-04-02[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  sass          0.4.1   [90m2022-03-23[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  sessioninfo   1.2.2   [90m2021-12-06[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  stringi       1.7.6   [90m2021-11-29[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  stringr       1.4.0   [90m2019-02-10[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  testthat    * 3.1.4   [90m2022-04-26[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  usethis     * 2.1.6   [90m2022-05-25[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  withr         2.5.0   [90m2022-03-03[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  xfun          0.31    [90m2022-05-10[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  xml2          1.3.3   [90m2021-11-30[39m [90m[1][39m [1m[35mRSPM[39m[22m
#>  yaml          2.3.5   [90m2022-02-21[39m [90m[1][39m [1m[35mRSPM[39m[22m
#> 
#> [90m [1] /home/runner/work/_temp/Library[39m
#> [90m [2] /opt/R/4.2.0/lib/R/library[39m
#> 
#> [1m[36m──────────────────────────────────────────────────────────────────[39m[22m
```

[r-ext]:https://cran.r-project.org/doc/manuals/R-exts.html#Creating-R-packages
[winston]:https://github.com/wch
[jim]:https://github.com/jimhester
[jenny]:https://github.com/jennybc
[klutometis]:https://github.com/klutometis
[mjaeugster]:https://github.com/mjaeugster
[gabor]:https://github.com/gaborcsardi
[mtmorgan]:https://github.com/mtmorgan
[dtenenba]:https://github.com/dtenenba
[kirill]:https://github.com/krlmlr
[rmflight]:https://github.com/rmflight
[kevin]:https://github.com/kevinushey
