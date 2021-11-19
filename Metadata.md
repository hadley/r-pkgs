# Package metadata {#description}



The job of the `DESCRIPTION` file is to store important metadata about your package.
When you first start writing packages, you'll mostly use these metadata to record what packages are needed to run your package.
However, as time goes by and you start sharing your package with others, the metadata file becomes increasingly important because it specifies who can use it (the license) and whom to contact (you!) if there are any problems.

Every package must have a `DESCRIPTION`.
In fact, it's the defining feature of a package (RStudio and devtools consider any directory containing `DESCRIPTION` to be a package).
To get you started, `usethis::create_package("mypackage")` automatically adds a bare-bones description file.
This will allow you to start writing the package without having to worry about the metadata until you need to.
The minimal description will vary a bit depending on your settings, but should look something like this:



<!-- TODO: do we want to edit that boilerplate DESCRIPTION a bit before we display it? -->


```{.yaml .yaml}
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

If you ever need to work with `DESCRIPTION` files programmatically or consume them as data, take a look at the base functions `read.dcf()` / `write.dcf()` and the [desc package](https://www.r-pkg.org/pkg/desc) (usethis uses desc heavily under-the-hood).

This chapter will show you how to use the most important `DESCRIPTION` fields.

## Dependencies: What does your package need? {#description-dependencies}

It's the job of the `DESCRIPTION` to list the packages that your package needs to work.
R has a rich set of ways of describing potential dependencies.
For example, the following lines indicate that your package needs both dplyr and tidyr to work:

```yaml
Imports:
    dplyr,
    tidyr
```

Whereas, the lines below indicate that, while your package can take advantage of dplyr and tidyr, they're not required to make it work:

```yaml
Suggests:
    dplyr,
    tidyr
```

Both `Imports` and `Suggests` take a comma separated list of package names.
We recommend putting one package on each line, and keeping them in alphabetical order.
That makes it easy to skim.

<!-- Is this the place to mention `usethis::use_tidy_description()`? -->

`Imports` and `Suggests` differ in their strength of dependency:

* `Imports`: packages listed here _must_ be present for your package to work.
  In fact, any time your package is installed, those packages will also be
  installed, if not already present.
  `devtools::load_all()` also checks that all packages in `Imports` are
  installed.
    
  Adding a package to `Imports` ensures it will be installed, but it does *not*
  mean that it will be attached along with your package, i.e. it does not do the
  equivalent of `library(otherpkg)`.
  Inside your package, the best practice is to explicitly refer to external
  functions using the syntax `package::function()`.
  This makes it very easy to identify which functions live outside of your
  package.
  This is especially useful when you read your code in the future.
  
  If you use a lot of functions from another package, this is rather verbose.
  There's also a minor performance penalty associated with `::` (on the order of
  5µs, so it will only matter if you call the function millions of times).
  You'll learn about alternative ways to call functions in other packages in
  [namespace imports](#imports).

* `Suggests`: your package can use these packages, but doesn't require them.
  You might use suggested packages for example datasets, to run tests, build
  vignettes, or maybe there's only one function that needs the package.
  
  Packages listed in `Suggests` are not automatically installed along with
  your package.
  This means that you can't assume the package is available unconditionally.
  Below we show various ways to handle these checks.

The easiest way to add a package to `Imports` or `Suggests` is with `usethis::use_package()`.
This automatically puts them in the right place in your `DESCRIPTION`, and reminds you how to use them.




```r
usethis::use_package("dplyr") # Default is "Imports"
#> [32m✔[39m Adding [34m'dplyr'[39m to [32mImports[39m field in DESCRIPTION
#> [31m•[39m Refer to functions with [90m`dplyr::fun()`[39m

usethis::use_package("tidyr", "Suggests")
#> [32m✔[39m Adding [34m'tidyr'[39m to [32mSuggests[39m field in DESCRIPTION
#> [31m•[39m Use [90m`requireNamespace("tidyr", quietly = TRUE)`[39m to test if package is installed
#> [31m•[39m Then directly refer to functons like [90m`tidyr::fun()`[39m (replacing [90m`fun()`[39m).
```



<!-- TODO: if the package Imports rlang, should usethis suggest `rlang::check_installed()` and `rlang::is_installed()` instead? Also seem like the usethis message should be more parallel in these two cases.-->

### Guarding the use of a suggested package

Inside a function in your own package, check for the availabilility of a suggested package with `requireNamespace(pkg, quietly = TRUE)`.
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

rlang has some useful functions for checking package availability.
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
  
`Suggests` isn't terribly relevant for packages used by a modest number of people or in a very predictable context.
Using `Suggests` is mostly a courtesy to external users or to accommodate very lean installations.
It can free users from downloading rarely needed packages (especially those that are tricky to install) and lets them get started with your package as quickly as possible.

Another common place to use a suggested package is in an example and here we often guard with `require()` (but you'll also see `requireNamespace()` used for this).
This example is from `glue::glue_col()`.


```r
#' @examples
#' if (require(crayon)) {
#'   glue_col("{blue foo bar}")
#' ...
#' }
```

An example is basically the only place where we would use `require()` inside a package.

Inside a test, testthat users can use `testthat::skip_if_not_installed()` to gracefully skip tests that exercise suggested packages.
Here's an example from ggplot2, which tests some functions that use the suggested sf package: 


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

The example above is actually a bit of an exception, as the tidyverse team does not typically guard use of a suggested package in tests.
That is, in general, we assume all suggested packages are available when writing tests.
So what justifies making an exception?
In the example above, the sf package can be nontrivial to install and it is conceivable that a contributor would want to run the remaining tests, even if sf is not available.

The motivation for the tidyverse team's policy of writing tests as if all suggested packages are present is because that is, indeed, true for testthat itself.
If the tests are being run, that implies that testthat is installed and that, in turn, implies that suggested packages have been installed.
This is a matter of convention and not a hard-and-fast rule enforced by externally.
Other package maintainers take a different stance and choose to protect all usage of suggested packages in their tests.

Also note that `testthat::skip_if_not_installed(pkg, minimum_version = "x.y.z")` can be used to conditionally skip a test based on the version of the other package.

Finally, another place you might use a suggested package is in a vignette.
Similar to tests, the tidyverse team generally writes vignettes as if all suggested packages are available.
But if you choose to use suggested packages conditionally in your vignettes, the knitr chunk options `purl` and `eval` may be useful for achieving this.
See chapter \@ref(vignettes) for more discussion of vignettes.

### Minimum versions

If you need a specific version of a package, specify it in parentheses after the package name:

```yaml
Imports:
    dplyr (>= 1.0.0),
    tidyr (>= 1.1.0)
```

You basically always want to specify a minimum version (`dplyr (>= 1.0.0)`) rather than an exact version (`dplyr (== 1.0.0)`).
Since R can't have multiple versions of the same package loaded at the same time, specifying an exact dependency dramatically increases the chance of conflicting versions.

<!-- Is this a good place to mention renv for people who think this level of control does not suit their use case? -->

Versioning is most important when you release your package.
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

### Other dependencies

There are three other fields that allow you to express more specialised dependencies:

* `Depends`: Prior to the rollout of namespaces in R 2.14.0 in 2011, `Depends`
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
  You'll learn more about `LinkingTo` in [compiled code](#src).
    
* `Enhances`: packages listed here are "enhanced" by your package.
  Typically, this means you provide methods for classes defined in another
  package (a sort of reverse `Suggests`).
  But it's hard to define what that means, so we don't recommend using
  `Enhances`.
    
You can also list things that your package needs outside of R in the `SystemRequirements` field.
But this is just a plain text field and is not automatically checked.
Think of it as a quick reference; you'll also need to include detailed system requirements (and how to install them) in your README.

<!-- This description of SystemRequirements seems a bit too dismissive or wishy-washy now, given the importance of this field to RSPM, ubuntu-based CI, etc. Should we rephrase? -->

#### An R version gotcha

Before we leave this topic, we give a concrete example of how easily an R version dependency can creep in and have a broader impact than you might expect.
The `saveRDS()` function writes a single R object as an `.rds` file, an R-specific format.
For almost 20 years, `.rds` files used the "version 2" serialization format.
"Version 3" became the new default in R 3.6.0 (released April 2019) and cannot be read by R versions prior to 3.5.0 (released April 2018).

Many R packages have at least one `.rds` file lurking within and, if that gets re-generated with a modern R version, by default, the new `.rds` file will have the "version 3" format.
When that R package is next built, such as for a CRAN submission, the required R version is automatically bumped to 3.5.0, signalled by this message:

```console
NB: this package now depends on R (>= 3.5.0)
  WARNING: Added dependency on R >= 3.5.0 because serialized objects in
  serialize/load version 3 cannot be read in older versions of R.
  File(s) containing such objects:
    'path/to/some_file.rds'
```

Literally, the `DESCRIPTION` file in the bundled package says `Depends: R (>= 3.5.0)`, even if `DESCRIPTION` in the source package says differently.

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

<!-- TODO: long-term, a better link might be https://pak.r-lib.org/reference/pak_package_sources.html, but the formatting is wonky there right now (fixed in pak's dev site, so should self-resolve). -->

The dependency and any minimum version requirement still need to be declared in the normal way in, e.g., `Imports`.
`usethis::use_dev_package()` helps to make the necessary changes in `DESCRIPTION`.
If your package temporarily relies on a development version of usethis, the affected `DESCRIPTION` fields might evolve like this:

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
This phenomenon is not directly related to devtools; it's more accurate to say that it's associated with the use of devtools.
`Config/Needs/*` fields are used by some standard continuous integration workflows made available to the community at <https://github.com/r-lib/actions/> and exposed via functions such as `usethis::use_github_actions()`.
Specifically, `Config/Needs/*` fields are a way to inform the [`setup-r-dependencies`](https://github.com/r-lib/actions/tree/master/setup-r-dependencies#readme) GitHub Action of extra packages it should install.

`Config/Needs/website` is the most common and it provides a place to specify packages that aren't a formal dependency, but that must be present in order to build the package's website.
On the left is an example of what might appear in `DESCRIPTION` for a package that uses various tidyverse packages in the non-vignette articles on its website, which is also formatted with styling that lives in `tidyverse/template`.
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

You'll notice that `Description` only gives you a small amount of space to describe what your package does.
This is why it's so important to also include a `README.md` file that goes into much more depth and shows a few examples.
You'll learn about that in [README.md](#readme).

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

This command says that both the author (aut) and the maintainer (cre) is Hadley Wickham, and that his email address is `hadley@rstudio.com`.
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
  There are four important roles:

    * `cre`: the creator or maintainer, the person you should bother 
      if you have problems.
      
    * `aut`: authors, those who have made significant contributions to the 
      package.
    
    * `ctb`: contributors, those who have made smaller contributions, like 
      patches.
    
    * `cph`: copyright holder. This is used if the copyright is held by someone 
      other than the author, typically a company (i.e. the author's employer).
    
    (The [full list of roles](https://www.loc.gov/marc/relators/relaterm.html) is
    extremely comprehensive.
    Should your package have a woodcutter ("wdc"), lyricist ("lyr") or costume
    designer ("cst"), rest comfortably that you can correctly describe their
    role in creating your package.
    However, note that packages destined for CRAN must limit themselves to the
    subset of MARC roles listed in the documentation for `person()`.
    )

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

Every package must have at least one author (aut) and one maintainer (cre) (they might be the same person).
The maintainer (cre) must have an email address.
These fields are used to generate the basic citation for the package (e.g. `citation("pkgname")`).
Only people listed as authors will be included in the auto-generated citation.
There are a few extra details if you're including code that other people have written.
Since this typically occurs when you're wrapping a C library, it's discussed in [compiled code](#src).

An older, still valid approach is to have separate `Maintainer` and `Author` fields in `DESCRIPTION`.
However, we strongly recommend the more modern approach of `Authors@R` and the `person()` function, because it offers richer metadata for various downstream uses.

## License: Who can use your package? {#description-license}

The `License` field can be either a standard abbreviation for an open source license, like `GPL-2` or `BSD`, or a pointer to a file containing more information, `file LICENSE`.
Or sometimes both!
If you have no plans to share your package, you can ignore this section.
But if you plan to share, even if only by putting the code where others can see it, you really should specify a license.

Licensing is a big enough topic that it has a dedicated chapter (chapter \@ref(license)).
Most maintainers will settle on a permissive license like MIT, one of the GPL copyleft licenses, or CC0.
These (and more) can all be configured by usethis, via functions like `use_mit_license()`, `use_gpl_license()`, or `use_cc0_license()`.
Read the [licensing chapter](#license) to learn more.

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

The version number of your package increases with subsequent releases of a package, but it's more than just an incrementing counter -- the way the number changes with each release can convey information about what kind of changes are in the package.

I don't recommend taking full advantage of R's flexibility.
Instead always use `.` to separate version numbers. 

* A released version number consists of three numbers, `<major>.<minor>.<patch>`. 
  For version number 1.9.2, 1 is the major number, 9 is the minor number, and 
  2 is the patch number. Never use versions like `1.0`, instead always spell
  out the three components, `1.0.0`.

* An in-development package has a fourth component: the development version.
  This should start at 9000. For example, the first version of the package
  should be `0.0.0.9000`. There are two reasons for this recommendation:
  first, it makes it easy to see if a package is released or in-development,
  and the use of the fourth place means that you're not limited to what the
  next version will be. `0.0.1`, `0.1.0`, and `1.0.0` are all greater than 
  `0.0.0.9000`.
  
  Increment the development version, e.g. from `9000` to `9001` if you've
  added an important feature that another development package needs to depend 
  on.
    
  If you're using svn, instead of using the arbitrary `9000`, you can
  embed the sequential revision identifier.

This advice here is inspired in part by [Semantic Versioning](https://semver.org) and by the [X.Org](https://www.x.org/releases/X11R7.7/doc/xorg-docs/Versions.html) versioning schemes.
Read them if you'd like to understand more about the standards of versioning used by many open source projects.

We'll come back to version numbers in the context of releasing your package, [picking a version number](#release-version).
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

## Other components {#description-other-fields}

<!-- TODO: integrate these better. Currently just transplanted from an earlier miscellany section. -->

As well as your email address, it's also a good idea to list other resources available for help.
You can list URLs in `URL`.
Multiple URLs are separated with a comma.
`BugReports` is the URL where bug reports should be submitted.
For example, knitr has:

```yaml
URL: https://yihui.name/knitr/
BugReports: https://github.com/yihui/knitr/issues
```

A number of other fields are described elsewhere in the book:

* `Collate` controls the order in which R files are sourced. This only
  matters if your code has side-effects; most commonly because you're
  using S4. This is described in more depth in [documenting S4](#man-s4).

* `LazyData` makes it easier to access data in your package. Because it's so 
  important, it's included in the minimal description created by devtools. It's
  described in more detail in [external data](#data).

There are actually many other rarely, if ever, used fields. A complete list can be found in the "The DESCRIPTION file" section of the [R extensions manual][R-exts].
You can also create your own fields to add additional metadata.
The only restrictions are that you shouldn't use existing names and that, if you plan to submit to CRAN, the names you use should be valid English words (so a spell-checking NOTE won't be generated).

[R-exts]: https://cran.r-project.org/doc/manuals/R-exts.html#The-DESCRIPTION-file
