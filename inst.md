# Installed files {#inst}



When a package is installed, everything in `inst/` is copied into the top-level package directory. In some sense `inst/` is the opposite of `.Rbuildignore` - where `.Rbuildignore` lets you remove arbitrary files and directories from the top level, `inst/` lets you add them. You are free to put anything you like in `inst/` with one caution: because `inst/` is copied into the top-level directory, you should never use a subdirectory with the same name as an existing directory. This means that you should avoid `inst/build`, `inst/data`, `inst/demo`, `inst/exec`, `inst/help`, `inst/html`, `inst/inst`, `inst/libs`, `inst/Meta`, `inst/man`, `inst/po`, `inst/R`, `inst/src`, `inst/tests`, `inst/tools` and `inst/vignettes`.

This chapter discusses the most common files found in `inst/`:

* `inst/AUTHOR` and `inst/COPYRIGHT`. If the copyright and authorship of a 
  package is particularly complex, you can use plain text files, 
  `inst/COPYRIGHTS` and `inst/AUTHORS`, to provide more information.

* `inst/CITATION`: how to cite the package, see 
  [package citation](#inst-citation) for details.

* `inst/docs`: This is an older convention for vignettes, and should be avoided 
   in modern packages.

* `inst/extdata`: additional external data for examples and vignettes. 
  See [external data](#data-extdata) for more detail.

* `inst/java`, `inst/python` etc. See [other languages](#inst-other-langs).

To find a file in `inst/` from code use `system.file()`. For example, to find `inst/extdata/mydata.csv`, you'd call `system.file("extdata", "mydata.csv", package = "mypackage")`. Note that you omit the `inst/` directory from the path. This will work if the package is installed, or if it's been loaded with `devtools::load_all()`.

## Package citation {#inst-citation}

The `CITATION` file lives in the `inst` directory and is intimately connected to the `citation()` function which tells you how to cite R and R packages. Calling `citation()` without any arguments tells you how to cite base R:


```r
citation()
#> 
#> To cite R in publications use:
#> 
#>   R Core Team (2022). R: A language and environment for
#>   statistical computing. R Foundation for Statistical
#>   Computing, Vienna, Austria. URL
#>   https://www.R-project.org/.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {R: A Language and Environment for Statistical Computing},
#>     author = {{R Core Team}},
#>     organization = {R Foundation for Statistical Computing},
#>     address = {Vienna, Austria},
#>     year = {2022},
#>     url = {https://www.R-project.org/},
#>   }
#> 
#> We have invested a lot of time and effort in creating R,
#> please cite it when using it for data analysis. See also
#> 'citation("pkgname")' for citing R packages.
```

Calling it with a package name tells you how to cite that package:


```r
citation("lubridate")
#> 
#> To cite lubridate in publications use:
#> 
#>   Garrett Grolemund, Hadley Wickham (2011). Dates and Times
#>   Made Easy with lubridate. Journal of Statistical Software,
#>   40(3), 1-25. URL https://www.jstatsoft.org/v40/i03/.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Article{,
#>     title = {Dates and Times Made Easy with {lubridate}},
#>     author = {Garrett Grolemund and Hadley Wickham},
#>     journal = {Journal of Statistical Software},
#>     year = {2011},
#>     volume = {40},
#>     number = {3},
#>     pages = {1--25},
#>     url = {https://www.jstatsoft.org/v40/i03/},
#>   }
```

To customise the citation for your package, add a `inst/CITATION` that looks like this:


```
citHeader("To cite lubridate in publications use:")

citEntry(entry = "Article",
  title        = "Dates and Times Made Easy with {lubridate}",
  author       = personList(as.person("Garrett Grolemund"),
                   as.person("Hadley Wickham")),
  journal      = "Journal of Statistical Software",
  year         = "2011",
  volume       = "40",
  number       = "3",
  pages        = "1--25",
  url          = "https://www.jstatsoft.org/v40/i03/",

  textVersion  =
  paste("Garrett Grolemund, Hadley Wickham (2011).",
        "Dates and Times Made Easy with lubridate.",
        "Journal of Statistical Software, 40(3), 1-25.",
        "URL https://www.jstatsoft.org/v40/i03/.")
)
```

You need to create `inst/CITATION`. As you can see, it's pretty simple: you only need to learn one new function, `citEntry()`. The most important arguments are:

* `entry`: the type of citation, "Article", "Book", "PhDThesis" etc.

* The standard bibliographic information like `title`, `author` (which should 
  be a `personList()`), `year`, `journal`, `volume`, `issue`, `pages`, ...
  
A complete list of arguments can be found in `?bibentry`.

Use `citHeader()` and `citFooter()` to add additional exhortations.

## Other languages {#inst-other-langs}

Sometimes a package contains useful supplementary scripts in other programming languages. Generally, you should avoid these, because it adds an additional extra dependency, but it may be useful when wrapping substantial amounts of code from another language. For example, [gdata](https://cran.r-project.org/web/packages/gdata/index.html) wraps the Perl module [Spreadsheet::ParseExcel](https://search.cpan.org/~dougw/Spreadsheet-ParseExcel-0.65/) to read excel files into R.

The convention is to put scripts of this nature into a subdirectory of `inst/`, `inst/python`, `inst/perl`, `inst/ruby` etc. If these scripts are essential to your package, make sure you also add the appropriate programming language to the `SystemRequirements` field in the `DESCRIPTION`. (This field is for human reading so don't worry about exactly how you specify it.)

Java is a special case and the best place to learn more is the documentation of the rJava package (<http://www.rforge.net/rJava/>).
