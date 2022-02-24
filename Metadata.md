# Package metadata {#description}



The job of the `DESCRIPTION` file is to store important metadata about your package.
When you first start writing packages, you'll mostly use these metadata to record what packages are needed to run your package.
However, as time goes by, other aspects of the metadata file will become useful to you, such as revealing what your package does (via the `Title` and `Description`) and whom to contact (you!) if there are any problems.

Every package must have a `DESCRIPTION`.
In fact, it's the defining feature of a package (RStudio and devtools consider any directory containing `DESCRIPTION` to be a package)[^DESC-and-package-hood].
To get you started, `usethis::create_package("mypackage")` automatically adds a bare-bones `DESCRIPTION` file.
This will allow you to start writing the package without having to worry about the metadata until you need to.
This minimal `DESCRIPTION` will vary a bit depending on your settings, but should look something like this:

[^DESC-and-package-hood]:
The relationship between "has a `DESCRIPTION` file" and "is a package" is not quite this clear-cut.
Many non-package projects use a `DESCRIPTION` file to declare their dependencies, i.e. which packages they rely on.
In fact, the bookdown project for this book does exactly this!
This off-label use of `DESCRIPTION` makes it easy to piggy-back on package development tooling to install all the packages necessary to work with a non-package project.





```yaml
Package: mypackage
Title: What the Package Does (One Line, Title Case)
Version: 0.0.0.9000
Authors@R: 
    person("First", "Last", , "first.last@example.com", role = c("aut", "cre"),
           comment = c(ORCID = "YOUR-ORCID-ID"))
Description: What the package does (one paragraph).
License: `use_mit_license()`, `use_gpl3_license()` or friends to pick a
    license
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.1.2
```

If you create a lot of packages, you can customize the default content of new `DESCRIPTION` files by setting the global option `usethis.description` to a named list.
You can pre-configure your preferred name, email, license, etc.
See the [article on usethis setup](https://usethis.r-lib.org/articles/articles/usethis-setup.html) for more details.

`DESCRIPTION` uses a simple file format called DCF, the Debian control format.
You can see most of the structure in the examples in this chapter.
Each line consists of a __field__ name and a value, separated by a colon.
When values span multiple lines, they need to be indented:

```yaml
Description: The description of a package is usually long,
    spanning multiple lines. The second and subsequent lines
    should be indented, usually with four spaces.
```

If you ever need to work with a `DESCRIPTION` file programmatically, take a look at the [desc package](https://www.r-pkg.org/pkg/desc), which usethis uses heavily under-the-hood.

This chapter will show you how to use the most important `DESCRIPTION` fields.
`Imports` and, to a lesser extent, `Suggests` are the key fields for declaring your dependencies.
`Title` and `Description` provide concise information about your package, suitable for inclusion in package lists.
We discuss a few other useful fields, some of which are sufficiently important to merit dedicated treatment elsewhere in the book, such as licensing (covered in Chapter \@ref(license)).

## Dependencies: What does your package need? {#description-dependencies}

It's the job of the `DESCRIPTION` to list the packages that your package needs to work.
R has a rich set of ways to describe different types of dependencies.
A key point is whether a dependency is needed by regular users or is only needed for development tasks or optional functionality.

Packages listed in `Imports` are needed by your users at runtime.
The following lines indicate that your package absolutely needs both dplyr and tidyr to work.

```yaml
Imports:
    dplyr,
    tidyr
```

Packages listed in `Suggests` are either needed for development tasks or *might* unlock optional functionality for your users.
The lines below indicate that, while your package can take advantage of ggplot2 and testthat, they're not absolutely required:

```yaml
Suggests:
    ggplot2,
    testthat
```

For example, the [withr package](https://withr.r-lib.org) is very useful for writing tests that clean up after themselves.
Such usage is compatible with listing withr in `Suggests`, since regular users don't need to run the tests.
But sometimes a package might also use withr in its own functions, perhaps to offer its own `with_*()` and `local_*()` functions.
In that case, withr should be listed in `Imports`.

Both `Imports` and `Suggests` take a comma-separated list of package names.
We recommend putting one package on each line, and keeping them in alphabetical order.
A non-haphazard order makes it easier for humans to parse this field and appreciate changes.
The easiest way to add a package to `Imports` or `Suggests` is with `usethis::use_package()`.
If the dependencies are already in alphabetical order, `use_package()` will keep it that way. 
In general, it can be nice to run `usethis::use_tidy_description()` regularly, which orders and formats `DESCRIPTION` fields according to a fixed standard.

`Imports` and `Suggests` differ in the strength and nature of dependency:

* `Imports`: packages listed here _must_ be present for your package to work.
  Any time your package is installed, those packages will also be installed, if
  not already present.
  `devtools::load_all()` also checks that all packages in `Imports` are
  installed.
    
  Adding a package to `Imports` ensures it will be installed, but it does *not*
  mean that it will be attached along with your package, i.e. it does not do the
  equivalent of `library(otherpkg)`[^load-vs-attach].
  Inside your package, the best practice is to explicitly refer to external
  functions using the syntax `package::function()`.
  This makes it very easy to identify which functions live outside of your
  package.
  This is especially useful when you read your code in the future.
  
  If you use a lot of functions from another package, this is rather verbose.
  There's also a minor performance penalty associated with `::` (on the order of
  5µs, so it will only matter if you call the function millions of times).
  You'll learn about alternative ways to make functions in other packages
  available inside your package in section \@ref(imports).

* `Suggests`: your package can use these packages, but doesn't require them.
  You might use suggested packages for example datasets, to run tests, build
  vignettes, or maybe there's only one function that needs the package.
  
  Packages listed in `Suggests` are not automatically installed along with
  your package.
  This means that you can't assume the package is available unconditionally.
  Below we show various ways to handle these checks.

[^load-vs-attach]: The difference between loading and attaching a package is covered in more detail in \@ref(search-path).

If you add packages to `DESCRIPTION` with `usethis::use_package()`, it will also remind you of the recommended way to call them.




```r
usethis::use_package("dplyr") # Default is "Imports"
#> [32m✔[39m Adding [34m'dplyr'[39m to [32mImports[39m field in DESCRIPTION
#> [31m•[39m Refer to functions with [90m`dplyr::fun()`[39m

usethis::use_package("ggplot2", "Suggests")
#> [32m✔[39m Adding [34m'ggplot2'[39m to [32mSuggests[39m field in DESCRIPTION
#> [31m•[39m Use [90m`requireNamespace("ggplot2", quietly = TRUE)`[39m to test if package is installed
#> [31m•[39m Then directly refer to functions with [90m`ggplot2::fun()`[39m
```



### Guarding the use of a suggested package

Inside a function in your own package, check for the availability of a suggested package with `requireNamespace("pkg", quietly = TRUE)`.
There are two basic scenarios:
    

```r
# the suggested package is required 
my_fun <- function(a, b) {
  if (!requireNamespace("pkg", quietly = TRUE)) {
    stop(
      "Package \"pkg\" must be installed to use this function.",
      call. = FALSE
    )
  }
  # code that includes calls such as pkg::f()
}

# the suggested package is optional; a fallback method is available
my_fun <- function(a, b) {
  if (requireNamespace("pkg", quietly = TRUE)) {
    pkg::f()
  } else {
    g()
  }
}
```

The rlang package has some useful functions for checking package availability.
Here's how the checks around a suggested package could look if you use rlang:
  

```r
# the suggested package is required 
my_fun <- function(a, b) {
  rlang::check_installed("pkg", reason = "to use `my_fun()`")
  # code that includes calls such as pkg::f()
}

# the suggested package is optional; a fallback method is available
my_fun <- function(a, b) {
  if (rlang::is_installed("pkg")) {
    pkg::f()
  } else {
    g()
  }
}
```
    
These rlang functions have handy features for programming, such as vectorization over `pkg`, classed errors with a data payload, and, for `check_installed()`, an offer to install the needed package in an interactive session.
  
`Suggests` isn't terribly relevant for packages where the user base is approximately equal to the development team or for packages that are used in a very predictable context.
In that case, it's reasonable to just use `Imports` for everything.
Using `Suggests` is mostly a courtesy to external users or to accommodate very lean installations.
It can free users from downloading rarely needed packages (especially those that are tricky to install) and lets them get started with your package as quickly as possible.

Another common place to use a suggested package is in an example and here we often guard with `require()` (but you'll also see `requireNamespace()` used for this).
This example is from `ggplot2::coord_map()`.


```r
#' @examples
#' if (require("maps")) {
#'   nz <- map_data("nz")
#'   # Prepare a map of NZ
#'   nzmap <- ggplot(nz, aes(x = long, y = lat, group = group)) +
#'     geom_polygon(fill = "white", colour = "black")
#'  
#'   # Plot it in cartesian coordinates
#'   nzmap
#' }
```

An example is basically the only place where we would use `require()` inside a package.

Another place you might use a suggested package is in a vignette.
The tidyverse team generally writes vignettes as if all suggested packages are available.
But if you choose to use suggested packages conditionally in your vignettes, the knitr chunk options `purl` and `eval` may be useful for achieving this.
See Chapter \@ref(vignettes) for more discussion of vignettes.

#### Whether and how to guard in a test

As with vignettes, the tidyverse team does not usually guard the use of a suggested package in a test.
In general, for vignettes and tests, we assume all suggested packages are available.
The motivation for this posture is self-consistency and pragmatism.
The key packages needed to run tests or build vignettes (e.g. testthat or knitr) appear in `Suggests`, not in `Imports` or `Depends`.
Therefore, if the tests are actually executing or the vignettes are being built, that implies that an expansive notion of package dependencies has been applied.
Also, empirically, in every important scenario of running `R CMD check`, the suggested packages are installed.
This is generally true for CRAN and we ensure that it's true in our own automated checks.
However, it's important to note that other package maintainers take a different stance and choose to protect all usage of suggested packages in their tests and vignettes.

Sometimes even the tidyverse team makes an exception and guards the use of a suggested package in a test.
Here's a test from ggplot2, which uses `testthat::skip_if_not_installed()` to skip execution if the suggested sf package is not available.


```r
test_that("basic plot builds without error", {
  skip_if_not_installed("sf")

  nc_tiny_coords <- matrix(
    c(-81.473, -81.741, -81.67, -81.345, -81.266, -81.24, -81.473,
      36.234, 36.392, 36.59, 36.573, 36.437, 36.365, 36.234),
    ncol = 2
  )

  nc <- sf::st_as_sf(
    data_frame(
      NAME = "ashe",
      geometry = sf::st_sfc(sf::st_polygon(list(nc_tiny_coords)), crs = 4326)
    )
  )

  expect_doppelganger("sf-polygons", ggplot(nc) + geom_sf() + coord_sf())
})
```

What might justify the use of `skip_if_not_installed()`?
In this case, the sf package can be nontrivial to install and it is conceivable that a contributor would want to run the remaining tests, even if sf is not available.

Finally, note that `testthat::skip_if_not_installed(pkg, minimum_version = "x.y.z")` can be used to conditionally skip a test based on the version of the other package.

### Minimum versions

If you need a specific version of a package, specify it in parentheses after the package name:

```yaml
Imports:
    dplyr (>= 1.0.0),
    tidyr (>= 1.1.0)
```

You always want to specify a minimum version (`dplyr (>= 1.0.0)`) rather than an exact version (`dplyr (== 1.0.0)`).
Since R can't have multiple versions of the same package loaded at the same time, specifying an exact dependency dramatically increases the chance of conflicting versions[^pointer-to-renv].

[^pointer-to-renv]: The need to specify the exact versions of packages, rather than minimum versions, comes up more often in the development of non-package projects.
The [renv package](https://rstudio.github.io/renv/) provides a way to do this, by implementing project-specific environments (package libraries).
renv is a reboot of an earlier package called packrat.
If you want to freeze the dependencies of a project at exact versions, use renv instead of (or possibly in addition to) a `DESCRIPTION` file.   

Versioning is most important if you will release your package for use by others.
Usually people don't have exactly the same versions of packages installed that you do.
If someone has an older package that doesn't have a function your package needs, they'll get an unhelpful error message if your package does not advertise the minimum version it needs.
However, if you state a minimum version, they'll learn about this problem clearly, probably at the time of installing your package.

Think carefully if you declare a minimum version for a dependency.
In some sense, the safest thing to do is to require a version greater than or equal to the package's current version.
For public work, this is most naturally defined as the current CRAN version of a package; private or personal projects may adopt some other convention.
But it's important to appreciate the implications for people who try to install your package: if their local installation doesn't fulfill all of your requirements around versions, installation will either fail or force upgrades of these dependencies.
This is desirable if your minimum version requirements are genuine, i.e. your package would be broken otherwise.
But if your stated requirements have a less solid rationale, this may be unnecessarily conservative and inconvenient.

In the absence of clear, hard requirements, you should set minimum versions (or not) based on your expected user base, the package versions they are likely to have, and a cost-benefit analysis of being too lax versus too conservative.
The *de facto* policy of the tidyverse team is to specify a minimum version when using a known new feature or when someone encounters a version problem in authentic use.
This isn't perfect, but we don't currently have the tooling to do better, and it seems to work fairly well in practice.

### Other dependencies

There are three other fields that allow you to express more specialised dependencies:

* `Depends`: Prior to the roll-out of namespaces in R 2.14.0 in 2011, `Depends`
  was the only way to "depend" on another package.
  Now, despite the name, you should almost always use `Imports`, not `Depends`.
  You'll learn why, and when you should still use `Depends`, in
  [namespaces](#namespace).
    
  You can also use `Depends` to state a minimum version for R itself, e.g.
  `Depends: R (>= 4.0.0)`.
  Again, think carefully if you do this.
  This raises the same issues as setting a minimum version for a package you
  depend on, except the stakes are much higher when it comes to R itself.
  Users can't simply consent to the necessary upgrade, so, if other packages
  depend on yours, your minimum version requirement for R can cause a cascade of
  package installation failures.

  - The [backports package](https://cran.r-project.org/package=backports) is
    useful if you want to use a function like `tools::R_user_dir(()`, which was
    introduced in 4.0.0 in 2020, while still supporting older R versions.
  - The tidyverse packages officially support the current R version, the devel
    version, and four previous versions.
    We proactively test this support in the standard build matrix we use for
    continuous integration.
  - Packages with a lower level of use may not need this level of rigour.
    The main takeaway is: if you state a minimum of R, you should have a reason
    and you should take reasonable measures to test your claim regularly.      
    
* `LinkingTo`: packages listed here rely on C or C++ code in another package. 
  You'll learn more about `LinkingTo` in Chapter \@ref(src).
    
* `Enhances`: packages listed here are "enhanced" by your package.
  Typically, this means you provide methods for classes defined in another
  package (a sort of reverse `Suggests`).
  But it's hard to define what that means, so we don't recommend using
  `Enhances`.
    
You can also list things that your package needs outside of R in the `SystemRequirements` field.
But this is just a plain text field and is not automatically checked.
Think of it as a quick reference; you'll also need to include detailed system requirements (and how to install them) in your README.

<!-- This description of SystemRequirements seems a bit too dismissive or wishy-washy now, given the importance of this field to RSPM, ubuntu-based CI, etc. But at the moment, we think more discussion fits best in the compiled code chapter. -->

#### An R version gotcha

Before we leave this topic, we give a concrete example of how easily an R version dependency can creep in and have a broader impact than you might expect.
The `saveRDS()` function writes a single R object as an `.rds` file, an R-specific format.
For almost 20 years, `.rds` files used the "version 2" serialization format.
"Version 3" became the new default in R 3.6.0 (released April 2019) and cannot be read by R versions prior to 3.5.0 (released April 2018).

Many R packages have at least one `.rds` file lurking within and, if that gets re-generated with a modern R version, by default, the new `.rds` file will have the "version 3" format.
When that R package is next built, such as for a CRAN submission, the required R version is automatically bumped to 3.5.0, signaled by this message:

```console
NB: this package now depends on R (>= 3.5.0)
  WARNING: Added dependency on R >= 3.5.0 because serialized objects in
  serialize/load version 3 cannot be read in older versions of R.
  File(s) containing such objects:
    'path/to/some_file.rds'
```

Literally, the `DESCRIPTION` file in the bundled package says `Depends: R (>= 3.5.0)`, even if `DESCRIPTION` in the source package says differently[^recall-package-states].

[^recall-package-states]: The different package states, such as source vs. bundled, are explained in section \@ref(package-states).

When such a package is released on CRAN, the new minimum R version is viral, in the sense that all packages listing the original package in `Imports` or even `Suggests` have, to varying degrees, inherited the new dependency on R >= 3.5.0.

The immediate take-away is to be very deliberate about the `version` of `.rds` files until R versions prior to 3.5.0 have fallen off the edge of what you intend to support.
This particular `.rds` issue won't be with us forever, but similar issues crop up elsewhere, such as in the standards implicit in compiled C or C++ source code.
The broader message is that the more reverse dependencies your package has, the more thought you need to give to your package's stated minimum versions, especially for R itself.

<!-- TODO: I could probably get the blessing to include a concrete example of this happening, as there are many. For example, the tidymodels team has direct experience. Does that seem necessary / beneficial? -->

### Nonstandard dependencies

In packages developed with devtools, you may see `DESCRIPTION` files that use a couple other nonstandard fields for package dependencies specific to development tasks.

The `Remotes` field can be used when you need to install a dependency from a nonstandard place, i.e. from somewhere besides CRAN or Bioconductor.
One common example of this is when you're developing against a development version of one of your dependencies.
During this time, you'll want to install the dependency from its development repository, which is often GitHub.
The way to specify various remote sources is described in a [devtools vignette](https://devtools.r-lib.org/articles/dependencies.html).

<!-- TODO: long-term, a better link will presumably be https://pak.r-lib.org/reference/pak_package_sources.html, once the pivot from remotes to pak is further along. -->

The dependency and any minimum version requirement still need to be declared in the normal way in, e.g., `Imports`.
`usethis::use_dev_package()` helps to make the necessary changes in `DESCRIPTION`.
If your package temporarily relies on a development version of usethis, the affected `DESCRIPTION` fields might evolve like this:

<!-- This is unlovely, but I just wanted to get the content down "on paper". It's easier to convey with a concrete example. -->

```
Stable -->               Dev -->                       Stable again
----------------------   ---------------------------   ----------------------
Package: yourpkg         Package: yourpkg              Package: yourpkg
Version: 1.0.0           Version: 1.0.0.9000           Version: 1.1.0
Imports:                 Imports:                      Imports: 
    usethis (>= 2.1.3)       usethis (>= 2.1.3.9000)       usethis (>= 2.2.0)
                         Remotes:   
                             r-lib/usethis 
```

It's important to note that you should not submit your package to CRAN in the intermediate state, meaning with a `Remotes` field and with a dependency required at a version that's not available from CRAN or Bioconductor.
For CRAN packages, this can only be a temporary development state, eventually resolved when the dependency updates on CRAN and you can bump your minimum version accordingly.

You may also see devtools-developed packages with packages listed in `DESCRIPTION` fields in the form of `Config/Needs/*`.
This pattern takes advantage of the fact that fields prefixed with `Config/` are ignored by CRAN and also do not trigger a NOTE about "Unknown, possibly mis-spelled, fields in `DESCRIPTION`".

<!--
https://github.com/wch/r-source/blob/de49776d9fe54cb4580fbbd04906b40fe2f6117e/src/library/tools/R/QC.R#L7133
https://github.com/wch/r-source/blob/efacf56dcf2f880b9db8eafa28d49a08d56e861e/src/library/tools/R/utils.R#L1316-L1389
-->

The use of `Config/Needs/*` is not directly related to devtools.
It's more accurate to say that it's associated with continuous integration workflows made available to the community at <https://github.com/r-lib/actions/> and exposed via functions such as `usethis::use_github_actions()`.
A `Config/Needs/*` field tells the [`setup-r-dependencies`](https://github.com/r-lib/actions/tree/master/setup-r-dependencies#readme) GitHub Action about extra packages that need to be installed.

`Config/Needs/website` is the most common and it provides a place to specify packages that aren't a formal dependency, but that must be present in order to build the package's website.
On the left is an example of what might appear in `DESCRIPTION` for a package that uses various tidyverse packages in the non-vignette articles on its website, which is also formatted with styling that lives in the `tidyverse/template` GitHub repo.
On the right is the corresponding excerpt from the configuration of the workflow that builds and deploys the website.

```
in DESCRIPTION                  in .github/workflows/pkgdown.yaml
--------------------------      ---------------------------------
Config/Needs/website:           - uses: r-lib/actions/setup-r-dependencies@v1
    tidyverse,                    with:
    tidyverse/tidytemplate          extra-packages: pkgdown
                                    needs: website
```

Continuous integration and package websites are discussed more in ?? and ??, respectively.
*These chapters are a yet-to-be-(re)written task for the 2nd edition.*

<!-- TODO: Link to CI and pkgdown material when it has been written and/or revised. -->

The `Config/Needs/*` convention is handy because it allows a developer to use `DESCRIPTION` as their definitive record of package dependencies, while maintaining a clean distinction between true runtime dependencies versus those that are only needed for specialized development tasks.

<!-- re: describing different types of dependencies, another term you see for "runtime" dependency is "production" -->

## Title and description: What does your package do? {#description-title-description}

The title and description fields describe what the package does.
They differ only in length:

* `Title` is a one line description of the package, and is often shown in a
  package listing.
  It should be plain text (no markup), capitalised like a title, and NOT end in
  a period.
  Keep it short: listings will often truncate the title to 65 characters.
* `Description` is more detailed than the title.
  You can use multiple sentences, but you are limited to one paragraph.
  If your description spans multiple lines (and it should!), each line must be
  no more than 80 characters wide.
  Indent subsequent lines with 4 spaces.

The `Title` and `Description` for ggplot2 are:

```yaml
Title: Create Elegant Data Visualisations Using the Grammar of Graphics
Description: A system for 'declaratively' creating graphics,
    based on "The Grammar of Graphics". You provide the data, tell 'ggplot2'
    how to map variables to aesthetics, what graphical primitives to use,
    and it takes care of the details.
```

A good title and description are important, especially if you plan to release your package to CRAN, because they appear on the CRAN download page as follows:

<!-- TODO: I know my hacky diagram might need replacement, but at least it's more up-to-date. -->

<div class="figure">
<img src="diagrams/cran-package-ggplot2.png" alt="The CRAN page for ggplot2, highlighting Title and Description." width="100%" />
<p class="caption">(\#fig:cran-package-page)The CRAN page for ggplot2, highlighting Title and Description.</p>
</div>

If you plan to submit your package to CRAN, both the `Title` and `Description` are a frequent source of rejections for reasons not covered by the automated `R CMD check`.
In addition to the basics above, here are a few more tips:

* Put the names of R packages, software, and APIs inside single quotes.
  This goes for both the `Title` and the `Description`.
  See the ggplot2 example above.
* If you need to use an acronym, try to do so in `Description`, not in `Title`.
  In either case, explain the acronym in `Description`, i.e. fully expand it.
* Don't include the package name, especially in `Title`, which is often
  prefixed with the package name.
* Do not start with "A package for ..." or "This package does ...".
  This rule makes sense once you look at [the list of CRAN packages by name](https://cran.r-project.org/web/packages/available_packages_by_name.html).
  The information density of such a listing is much higher without a universal
  prefix like "A package for ...".
  
If these constraints give you writer's block, it often helps to spend a few minutes reading `Title` and `Description` of packages already on CRAN.
Once you read a couple dozen, you can usually find a way to say what you want to say about your package that is also likely to pass CRAN's human-enforced checks.

You'll notice that `Description` only gives you a small amount of space to describe what your package does.
This is why it's so important to also include a `README.md` file that goes into much more depth and shows a few examples.
You'll learn about that in section \@ref(readme).

## Author: who are you? {#description-authors}

To identify the package's author, and whom to contact if something goes wrong, use the `Authors@R` field.
This field is unusual because it contains executable R code rather than plain text. Here's an example:

```yaml
Authors@R: person("Hadley", "Wickham", email = "hadley@rstudio.com",
  role = c("aut", "cre"))
```


```r
person("Hadley", "Wickham", email = "hadley@rstudio.com", 
  role = c("aut", "cre"))
#> [1] "Hadley Wickham <hadley@rstudio.com> [aut, cre]"
```

This command says that Hadley Wickham is both the maintainer (`cre`) and an author (`aut`) and that his email address is `hadley@rstudio.com`.
The `person()` function has four main inputs:

* The name, specified by the first two arguments, `given` and `family` (these
  are normally supplied by position, not name).
  In English cultures, `given` (first name) comes before `family` (last name).
  In many cultures, this convention does not hold.
  For a non-person entity, such as "R Core Team" or "RStudio", use the `given`
  argument (and omit `family`).
  
* The `email` address.
  It's important to note that this is the address CRAN uses to let you know
  if your package needs to be fixed in order to stay on CRAN.
  Make sure to use an email address that's likely to be around for a while.
  CRAN policy requires that this be for a person, as opposed to, e.g., a
  mailing list.

* One or more three letter codes specifying the `role`.
  These are the most important roles to know about:

    * `cre`: the creator or maintainer, the person you should bother 
      if you have problems. Despite being short for "creator", this is the
      correct role to use for the current maintainer, even if they are not
      the initial creator of the package.
      
    * `aut`: authors, those who have made significant contributions to the 
      package.
    
    * `ctb`: contributors, those who have made smaller contributions, like 
      patches.
    
    * `cph`: copyright holder. This is used if the copyright is held by someone 
      other than the author, typically a company (i.e. the author's employer).
      
    * `fnd`: funder, the people or organizations that have provided financial
      support for the development of the package.
    
    (The [full list of roles](https://www.loc.gov/marc/relators/relaterm.html)
    is extremely comprehensive.
    Should your package have a woodcutter (`wdc`), lyricist (`lyr`) or costume
    designer (`cst`), rest comfortably that you can correctly describe their
    role in creating your package.
    However, note that packages destined for CRAN must limit themselves to the
    subset of MARC roles listed in the documentation for `person()`.)

* The optional `comment` argument has become more relevant, since `person()` and
  CRAN landing pages have gained some nice features around
  [ORCID identifiers](https://orcid.org).
  Here's an example of such usage (note the auto-generated URI):

    
    ```r
    person(
      "Jennifer", "Bryan",
      email = "jenny@rstudio.com",
      role = c("aut", "cre"),
      comment = c(ORCID = "0000-0002-6983-2759")
    )
    #> [1] "Jennifer Bryan <jenny@rstudio.com> [aut, cre] (<https://orcid.org/0000-0002-6983-2759>)"
    ```



You can list multiple authors with `c()`:

```yaml
Authors@R: c(
    person("Hadley", "Wickham", email = "hadley@rstudio.com", role = "cre"),
    person("Winston", "Chang", email = "winston@rstudio.com", role = "aut"),
    person("RStudio", role = c("cph", "fnd")))
```

Every package must have at least one author (`aut`) and one maintainer (`cre`) (they might be the same person).
The maintainer (`cre`) must have an email address.
These fields are used to generate the basic citation for the package (e.g. `citation("pkgname")`).
Only people listed as authors will be included in the auto-generated citation.
There are a few extra details if you're including code that other people have written.
Since this typically occurs when you're wrapping a C library, it's discussed in Chapter \@ref(src).

An older, still valid approach is to have separate `Maintainer` and `Author` fields in `DESCRIPTION`.
However, we strongly recommend the more modern approach of `Authors@R` and the `person()` function, because it offers richer metadata for various downstream uses.

## License: Who can use your package? {#description-license}

Licensing is a big enough topic that it has a dedicated chapter (Chapter \@ref(license)).
If you have no plans to share your package, you may be able to ignore licensing.
But if you plan to share, even if only by putting the code where others can see it, you really should specify a license.

Most maintainers will settle on a permissive license like MIT, one of the GPL copyleft licenses, or CC0.
These (and more) can all be configured by usethis, via functions like `use_mit_license()`, `use_gpl_license()`, or `use_cc0_license()`.
These helpers populate the `License` field  of `DESCRIPTION` and, if necessary, setup additional files to complete the license.
Read the licensing chapter (Chapter \@ref(license)) to learn more.

## Version {#description-version}

Formally, an R package version is a sequence of at least two integers separated by either `.` or `-`.
For example, `1.0` and `0.9.1-10` are valid versions, but `1` and `1.0-devel` are not.
You can parse a version number with `numeric_version()`.


```r
numeric_version("1.9") == numeric_version("1.9.0")
#> [1] TRUE
numeric_version("1.9.0") < numeric_version("1.10.0")
#> [1] TRUE
```

For example, a package might have a version 1.9.
This version number is considered by R to be the same as 1.9.0, less than version 1.9.2, and all of these are less than version 1.10 (which is version "one point ten", not "one point one zero").
R uses version numbers to determine whether package dependencies are satisfied.
A package might, for example, import package `devtools (>= 1.9.2)`, in which case version 1.9 or 1.9.0 wouldn't work.

Here is our recommended framework for managing the package version number:

* Always use `.` as the separator, never `-`.

* A released version number consists of three numbers, `<major>.<minor>.<patch>`. 
  For version number 1.9.2, 1 is the major number, 9 is the minor number, and 
  2 is the patch number.
  Never use versions like `1.0`, instead always spell out the three components,
  `1.0.0`.
  
* An in-development package has a fourth component: the development version.
  This should start at 9000.
  For example, the first version of the package should be `0.0.0.9000`.
  There are two reasons for this recommendation:
  First, it makes it easy to see if a package is released or in-development.
  Also, the use of the fourth place means that you're not limited to what the
  next version will be.
  `0.0.1`, `0.1.0`, and `1.0.0` are all greater than `0.0.0.9000`.
  
  Increment the development version, e.g. from `9000` to `9001`, if you've
  added an important feature that another development package needs to depend 
  on.

The advice above is inspired in part by [Semantic Versioning](https://semver.org) and by the [X.Org](https://www.x.org/releases/X11R7.7/doc/xorg-docs/Versions.html) versioning schemes.
Read them if you'd like to understand more about the standards of versioning used by many open source projects.
Finally, know that other maintainers follow different philosophies on how to manage the package version number.

The version number of your package increases with subsequent releases of a package, but it's more than just an incrementing counter -- the way the number changes with each release can convey information about what kind of changes are in the package.
We discuss this and more in Section \@ref(release-version).
For now, just remember that the first version of your package should be `0.0.0.9000`.
`usethis::create_package()` does this, by default.
`usethis::use_version()` increments the package version; when called interactively, with no argument, it presents a helpful menu:


```r
usethis::use_version()
#> Current version is 0.1.
#> What should the new version be? (0 to exit) 
#> 
#> 1: major --> 1.0
#> 2: minor --> 0.2
#> 3: patch --> 0.1.1
#> 4:   dev --> 0.1.0.9000
#> 
#> Selection: 
```

## Other fields {#description-other-fields}

A few other `DESCRIPTION` fields are heavily used and worth knowing about.

As well as the maintainer's email address, it's a good idea to list other places people can learn more about your package.
The `URL` field is commonly used to advertise the package's website and to link to a public source repository, where development happens.
Multiple URLs are separated with a comma.
`BugReports` is the URL where bug reports should be submitted, e.g., as GitHub issues.
For example, devtools has:

```yaml
URL: https://devtools.r-lib.org/, https://github.com/r-lib/devtools
BugReports: https://github.com/r-lib/devtools/issues
```

If you use `usethis::use_github()` to connect your local package to a remote GitHub repository, it will automatically populate `URL` and `BugReports` for you.
If a package is already connected to a remote GitHub repository, `usethis::use_github_links()` can be called to just add the relevant links to `DESCRIPTION`.

The `Encoding` field is required if `DESCRIPTION` does not consist entirely of ASCII characters.
If specified, this `Encoding` is interpreted as applying more broadly throughout the package.
By default, `create_package()` uses `Encoding: UTF-8`, which should be interpreted as our very strong recommendation to use UTF-8 encoding.

A number of other fields are described elsewhere in the book:

* `Collate` controls the order in which R files are sourced. This only
  matters if your code has side-effects; most commonly because you're
  using S4. This is described in more depth in Section \@ref(man-s4).

* `LazyData` is relevant if your package makes data available to the user.
  If you specify `LazyData: true`, the datasets are lazy-loaded, which
  makes them more immediately available, i.e. users don't have to use `data()`.
  The addition of `LazyData: true` is handled automatically by
  `usethis::use_data()`.
  More detail is given when we talk about external data in Chapter \@ref(data).

There are actually many other rarely, if ever, used fields.
A complete list can be found in the "The DESCRIPTION file" section of the [R extensions manual][R-exts].

There is also some flexibility to create your own fields to add additional metadata.
In the narrowest sense, the only restriction is that you shouldn't re-purpose the official field names used by R.
But in practice, if you plan to submit to CRAN, there are more constraints.
First, only use valid English words, so the field names aren't flagged by the spell-check.
Beyond that, custom fields should follow one of these two patterns:

* `Config/` prefix: We featured an example of this earlier, where
  `Config/Needs/website` is used to record additional packages needed to build
  a package's website.
* `Note` suffix: You can add `Note` to any standard field name, e.g.,
  `SuggestsNote`.
  It is also permitted to use `Note`, alone, as a field name.

By default, `create_package()` writes two more fields we haven't discussed yet, relating to the use of the roxygen2 package for documentation:

```yaml
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.1.2
```

You will learn more about these in Chapter \@ref(man).

[R-exts]: https://cran.r-project.org/doc/manuals/R-exts.html#The-DESCRIPTION-file
