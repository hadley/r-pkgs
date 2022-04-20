# Testing {#tests}



Testing is a vital part of package development.
It ensures that your code does what you want it to do.
Testing, however, adds an additional step to your development workflow.
The goal of this chapter is to show you how to make this task easier and more effective by doing formal automated testing using the testthat package.

The first stage of your testing journey is to become convinced that testing has enough benefits to justify the work.
For some of us, this is easy to accept.
Others must learn the hard way.

Once you've decided to embrace automated testing, it's time to learn some mechanics and figure out where testing fits into your development workflow.

As you and your R packages evolve, you'll start to encounter testing situations where it's fruitful to use techniques that are somewhat specific to testing and differ from what we do below `R/`.

## Why is formal testing worth the trouble?

Up until now, your workflow probably looks like this:

1. Write a function.
1. Load it with `devtools::load_all()`, maybe via Ctrl/Cmd + Shift + L.
1. Experiment with it in the console to see if it works.
1. Rinse and repeat.

While you _are_ testing your code in this workflow, you're only doing it informally.
The problem with this approach is that when you come back to this code in 3 months time to add a new feature, you've probably forgotten some of the informal tests you ran the first time around.
This makes it very easy to break code that used to work. 

<!-- This next paragraph is very "I" based. But it's also hard to rephrase. Let's discuss. -->

I started using automated tests because I discovered I was spending too much time re-fixing bugs that I'd already fixed before.
While writing code or fixing bugs, I'd perform interactive tests to make sure the code worked.
But I never had a system which could store those tests so I could re-run them as needed.
I think that this is a common practice among R programmers.
It's not that you don't test your code, it's that you don't automate your tests.

In this chapter you'll learn how to transition from informal *ad hoc* testing, done interactively in the console, to automated testing (aka unit testing).
While turning casual interactive tests into formal tests requires a little more work up front, it pays off in four ways:

* Fewer bugs.
  Because you're explicit about how your code should behave, you will have fewer
  bugs.
  The reason why is a bit like the reason double entry book-keeping works:
  because you describe the behaviour of your code in two places, both in your
  code and in your tests, you are able to check one against the other.
  If you always introduce new tests when you add a new feature or function,
  you'll prevent many bugs from being created in the first place,
  because you will proactively address pesky edge cases.
  Tests also keep you from (re-)breaking one feature, when you're tinkering with
  another.
  
  <!-- More thoughts re: why "fewer bugs": with informal example-type tests, it's tempting to just explore whatever *you* think of as typical usage / the ideal scenario. In contrast, with formal unit tests, you are much more likely to systematically explore edge cases, like what happens when the inputs are affected by various forms of missingness (which eventually does happen in real life). -->

* Better code structure.
  Code that is well designed tends to be easy to test and you can turn this to
  your advantage.
  Whenever you're struggling to write tests, consider if the problem is
  actually the design of your function(s).
  The process of writing tests is a great way to get free, private, and
  personalized feedback on how well-factored your code is.
  If you integrate testing into your development workflow (versus planning to
  slap tests on "later"), you'll subject yourself to constant pressure to break
  complicated operations into separate functions that work in isolation.
  Functions that are easier to test are usually easier to understand and
  re-combine in new ways.

* Easier restarts.
  If you always finish a coding session by creating a failing test (e.g. for the
  next feature you want to implement), testing makes it easier for you to pick
  up where you left off: your tests will let you know what to do next.
  
  <!-- I never do this. Do you, Hadley? But here's something closely related that happens often: I turn a bug into a (failing) test. Which confirms/establishes that the bug exists. Now I have a very concrete goal: make this test pass. Once I get there, I also have confidence that I have actually fixed the bug. Maybe this is a better real-world pattern to describe? -->

* Robust code.
  If you know that all the major functionality of your package is well covered
  by the tests, you can confidently make big changes without worrying about
  accidentally breaking something.
  This provides a great reality check when you think you've discovered some
  brilliant new way to simplify your package.
  Sometimes such "simplifications" fail to account for some important use case
  and your tests will save you from yourself.

## Introducing testthat

This chapter describes how to test your R package using the testthat package:
<https://testthat.r-lib.org>

If you're familiar with frameworks for unit testing in other languages, you should note that there are some fundamental differences with testthat.
This is because R is, at heart, more a functional programming language than an object-oriented programming language.
For instance, because R's main object-oriented systems (S3 and S4) are based on generic functions (i.e., methods belong to functions not classes), testing approaches built around objects and methods don't make much sense.

testthat 3.0.0 (released 2020-10-31) introduced the idea of an **edition** of testthat, specifically the 3rd edition of testhat, which we refer to as testthat 3e.
An edition is a bundle of behaviours that you have to explicitly choose to use, allowing us to make otherwise backward incompatible changes.
This is particularly important for testthat since it has a very large number of packages that use it (almost 5,000 at last count).
To use testthat 3e, you must have a version of testthat >= 3.0.0 **and** explicitly opt-in to the third edition behaviours.
This allows testthat to continue to evolve and improve without breaking historical packages that are in a rather passive maintenance phase.
You can learn more in the [testthat 3e article](https://testthat.r-lib.org/articles/third-edition.html).

We recommend testthat 3e for all new packages and we recommend updating existing, actively maintained packages to use testthat 3e.
Unless we say otherwise, this chapter describes testthat 3e.

## Test mechanics and workflow

### Initial setup

To setup your package to use testthat, run:


```r
usethis::use_testthat(3)
```

This will:

1.  Create a `tests/testthat/` directory.

1.  Add testthat to the `Suggests` field in the `DESCRIPTION`.
    Specify testthat 3e in the `Config/testthat/edition` field.
    Here are what the relevant `DESCRIPTION` fields might look like:
    
    Suggests: testthat (>= 3.0.0)
    Config/testthat/edition: 3

1.  Create a file `tests/testthat.R` that runs all your tests when
    `R CMD check` runs. (You'll learn more about that in 
    [automated checking](#r-cmd-check).)
    
This initial setup is something you do once per package.

The `tests/testthat.R` script is something you should generally regard as fixed.
It is run during `R CMD check` (and, therefore, `devtools::check()`), but is not used in other test-running scenarios (such as `devtools::test()` or `devtools::test_active_file()`).
If you want to do something that affects all of your tests, there is usually a better mechanism than modifying the standard `tests/testthat.R` script.
You'll see this below when we discuss different types of test helpers and mechanisms for setup / teardown.

### Create a test

As you define functions in your package, in the files below `R/`, you add the corresponding tests to `.R` files in `tests/testthat/`.
We recommend that the organisation of test files match the organisation of `R/` files, discussed in section \@ref(code-organising):
The `foofy()` function (and its friends and helpers) should be defined in `R/foofy.R` and their tests should live in `tests/testthat/test-foofy.R`.

```
R                                     tests/testthat
└── foofy.R                           └── test-foofy.R
    foofy <- function(...) {...}          test_that("foofy does this", {...})
                                          test_that("foofy does that", {...})
```

Even if you have different conventions for file organisation and naming, note that testthat tests **must** live in files below `tests/testthat/` and these file names **must** begin with `test`.
The test file name is displayed in testthat output, which provides helpful context[^bye-bye-context].

[^bye-bye-context]: The legacy function `testthat::context()` is superseded now and its use in new or actively maintained code is discouraged.
In the testthat 3e, `context()` is formally deprecated; you should just remove it.
Once you adopt an intentional, synchronised approach to the organisation of files below `R/` and `tests/testthat/`, the necessary contextual information is right there in the file name, rendering the legacy `context()` superfluous.

usethis offers a helpful pair of functions for creating or toggling between files:

* `usethis::use_r()`
* `usethis::use_test()`

Either one can be called with a file (base) name, in order to create a file *de novo* and open it for editing:


```r
use_r("foofy")    # creates and opens R/foofy.R
use_test("blarg") # creates and opens tests/testthat/test-blarg.R
```

The `use_r()` / `use_test()` duo has some convenience features that make them "just work" in many common situations:

* When determining the target file, they can deal with the presence or absence
  of the `.R` extension and the `test-` prefix.
  - Equivalent: `use_r("foofy.R")`, `use_r("foofy")`
  - Equivalent: `use_test("test-blarg.R")`, `use_test("blarg.R")`, `use_test("blarg")`
* If the target file already exists, it is opened for editing. Otherwise, the
  target is created and then opened for editing.

:::rstudio-tip
If `R/foofy.R` is the active file in your source editor, you can even call `use_test()` with no arguments!
The target test file can be inferred: if you're editing `R/foofy.R`, you probably want to work on the companion test file, `tests/testthat/test-foofy.R`.
If it doesn't exist yet, it is created and, either way, the test file is opened for editing.
This all works the other way around also.
If you're editing `tests/testthat/test-foofy.R`, a call to `use_r()` (optionally, creates and) opens `R/foofy.R`.
:::

Bottom line: `use_r()` / `use_test()` are handy for initially creating these file pairs and, later, for shifting your attention from one to the other.

When `use_test()` initiates a test file *de novo*, it inserts a dummy test:


```r
test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
```

You will replace this with your own logic, but it's a nice reminder of the basic form:

* A test file holds one or more `test_that()` tests.
* Each test describes what it tests for: e.g. "multiplication works".
* Each test has one or more expectations: e.g. `expect_equal(2 * 2, 4)`.

Below we go into much more detail about how to test your own functions, which is a big and important topic.

### Run tests

Depending on where you are in the development cycle, you'll run your tests at various scales.
When you are rapidly iterating on a function, you might work at the level of individual tests.
As the code settles down, you'll run entire test files and eventually the entire test suite.

**Micro-iteration**: This is the interactive phase where you initiate and refine a function and its tests in tandem.
Here you will run `load_all()` often, and then execute individual expectations or whole tests interactively in the console.
Note that `load_all()` attaches testthat, so it puts you in the perfect position to test drive your functions and to execute individual tests and expectations.


```r
# tweak the foofy() function and re-load it
devtools::load_all()

# interactively explore and refine expectations and tests
expect_equal(foofy(...), EXPECTED_FOOFY_OUTPUT)

testthat("foofy does good things", {...})
```

**Mezzo-iteration**: As one file's-worth of functions and their associated tests start to shape up, you will want to execute the entire file of associated tests, perhaps with `testthat::test_file()`:


```r
testthat::test_file("tests/testthat/test-foofy.R")
```

:::rstudio-tip
In RStudio, you don't even have to specify the full filepath!
`devtools::test_active_file()` infers the target test file from the file you are actively editing, similar to how `use_r()` and `use_test()` work.
The easiest way to invoke this is via "Run a test file" in the Addins menu or with the keyboard shortcut Ctrl/Cmd + T.
:::

**Macro-iteration**: As you near the completion of a new feature or bug fix, you will want to run the entire test suite.

Most frequently, you'll do this with `devtools::test()`:


```r
devtools::test()
```

Then eventually, as part of `R CMD check` with `devtools::check()`:


```r
devtools::check()
```
:::rstudio-tip
`devtools::test()` is mapped to Ctrl/Cmd + Shift + T.
`devtools::check()` is mapped to  Ctrl/Cmd + Shift + E.
:::

<!-- We'll probably want to replace this example eventually, but it's a decent placeholder.
The test failure is something highly artificial I created very quickly. 
It would be better to use an example that actually makes sense, if someone elects to really read and think about it.-->

The output of `devtools::test()` looks like this:

    devtools::test()
    ℹ Loading usethis
    ℹ Testing usethis
    ✓ | F W S  OK | Context
    ✓ |         1 | addin [0.1s]
    ✓ |         6 | badge [0.5s]
       ...
    ✓ |        27 | github-actions [4.9s]
       ...
    ✓ |        44 | write [0.6s]
    
    ══ Results ═════════════════════════════════════════════════════════════════
    Duration: 31.3 s
    
    ── Skipped tests  ──────────────────────────────────────────────────────────
    • Not on GitHub Actions, Travis, or Appveyor (3)
    
    [ FAIL 1 | WARN 0 | SKIP 3 | PASS 728 ]

Test failure is reported like this:

    Failure (test-release.R:108:3): get_release_data() works if no file found
    res$Version (`actual`) not equal to "0.0.0.9000" (`expected`).
    
    `actual`:   "0.0.0.1234"
    `expected`: "0.0.0.9000"

Each failure gives a description of the test (e.g., "get_release_data() works if no file found"), its location (e.g., "test-release.R:108:3"), and the reason for the failure (e.g., "res$Version (`actual`) not equal to "0.0.0.9000" (`expected`)").

The idea is that you'll modify your code (either the functions defined below `R/` or the tests in `tests/testthat/`) until all tests are passing.

## Test structure {#test-structure}

A test file lives in `tests/testthat/`.
Its name must start with `test`.
We will inspect and execute a test file from the stringr package.

But first, for the purposes of rendering this book, we must attach stringr and testthat.
Note that in real-life test-running situations, this is taken care of by your package development tooling:

* During interactive development, `load_all()` makes testthat and the
  package-under-development available (both its exported and unexported
  functions).
* During arms-length test execution, this is taken care of by
  `devtools::test_active_file()`, `devtools::test()`, and `tests/testthat.R`.
  
**Your test files should not include these `library()` calls.
We also explicitly request testthat edition 3, but in a real package this will be declared in DESCRIPTION.**


```r
library(testthat)
library(stringr)
local_edition(3)
```

Here are the contents of `tests/testthat/test-dup.r` from stringr[^dev-stringr]:

[^dev-stringr]: Note that we are building the book against a dev version of stringr.


```r
test_that("basic duplication works", {
  expect_equal(str_dup("a", 3), "aaa")
  expect_equal(str_dup("abc", 2), "abcabc")
  expect_equal(str_dup(c("a", "b"), 2), c("aa", "bb"))
  expect_equal(str_dup(c("a", "b"), c(2, 3)), c("aa", "bbb"))
})
#> [32mTest passed[39m 🥳

test_that("0 duplicates equals empty string", {
  expect_equal(str_dup("a", 0), "")
  expect_equal(str_dup(c("a", "b"), 0), rep("", 2))
})
#> [32mTest passed[39m 🎉

test_that("uses tidyverse recycling rules", {
  expect_error(str_dup(1:2, 1:3), class = "vctrs_error_incompatible_size")
})
#> [32mTest passed[39m 🎊
```

This file shows a typical mix of tests:

* "basic duplication works" tests typical usage of `str_dup()`.
* "0 duplicates equals empty string" probes a specific edge case.
* "uses tidyverse recycling rules" checks that malformed input results in a
  specific kind of error.

Tests are organised hierarchically:
__expectations__ are grouped into __tests__ which are organised in __files__:

* A __file__ holds multiple related tests.
  In this example, the file `tests/testthat/test-dup.r` has all of the tests
  for `stringr::str_dup()`, which is defined in `R/dup.r`.
  A test failure is always reported by file name, which is why the file name
  should convey the general context, e.g. the function that is being tested.

* A __test__ groups together multiple expectations to test the output from a
  simple function, a range of possibilities for a single parameter from a more
  complicated function, or tightly related functionality from across multiple
  functions.
  This is why they are sometimes called __unit__ tests.
  Each test should cover a single unit of functionality.
  A test is created with `test_that(desc, code)`.
  It's common to write the description (`desc`) to create something that reads
  naturally, e.g. `test_that("basic duplication works", { ... })`.
  A test failure report includes this description, which is why you want a
  concise statement of the test's purpose, e.g. a specific behaviour.

* An __expectation__ is the atom of testing.
  It describes the expected result of a computation:
  Does it have the right value and right class?
  Does it produce an error when it should?
  An expectation automates visual checking of results in the console.
  Expectations are functions that start with `expect_`.

You want to arrange things such that, when a test fails, you'll know what's wrong and where in your code to look for the problem.
This motivates all our recommendations regarding file organisation, file naming, and the test description.
Finally, try to avoid putting too many expectations in one test - it's better to have more smaller tests than fewer larger tests.

### Expectations

An expectation is the finest level of testing.
It makes a binary assertion about whether or not a function call does what you expect.
All expectations have a similar structure:

* They start with `expect_`.

* They have two main arguments:
  the first is the actual result, the second is what you expect.
  
* If the actual and expected results don't agree, testthat throws an error.

* Some expectations have additional arguments that control the finer points of
  comparing an actual and expected result.

While you'll normally put expectations inside tests inside files, you can also run them directly.
This makes it easy to explore expectations interactively.
There are more than 40 expectations in the testthat package, which can be explored in testthat's [reference index](https://testthat.r-lib.org/reference/index.html).
Here we highlight some of the most important expectations.

* There are two basic ways to test for equality: `expect_equal()`, and
  `expect_identical()`.
  `expect_equal()` is the most commonly used and should be your default:
  it checks for equality within a numerical tolerance:

    
    ```r
    expect_equal(10, 10)
    expect_equal(10, 10L)
    expect_equal(10, 10 + 1e-7)
    expect_equal(10, 11)
    #> Error: 10 (`actual`) not equal to 11 (`expected`).
    #> 
    #>   `actual`: [32m10[39m
    #> `expected`: [32m11[39m
    ```
  
  If you want to test for exact equivalence or need to compare more exotic
  objects like environments, use `expect_identical()`.

    
    ```r
    expect_equal(10, 10 + 1e-7)
    expect_identical(10, 10 + 1e-7)
    #> Error: 10 (`actual`) not identical to 10 + 1e-07 (`expected`).
    #> 
    #>   `actual`: [32m10.0000000[39m
    #> `expected`: [32m10.0000001[39m
    expect_equal(2, 2L)
    expect_identical(2, 2L)
    #> Error: 2 (`actual`) not identical to 2L (`expected`).
    #> 
    #> `actual` is [32ma double vector[39m (2)
    #> `expected` is [32man integer vector[39m (2)
    ```

* `expect_match()` matches a character vector against a regular expression. 
   The optional `all` argument controls whether all elements or just one 
   element needs to match.
   This is powered by `grepl()` and additional arguments like
   `ignore.case = FALSE` or `fixed = TRUE` are passed on down.
   
    
    ```r
    string <- "Testing is fun!"
      
    expect_match(string, "Testing") 
     
    # Fails, match is case-sensitive
    expect_match(string, "testing")
    #> Error: `string` does not match "testing".
    #> Actual value: "Testing is fun!"
      
    # Passes because additional arguments are passed to grepl():
    expect_match(string, "testing", ignore.case = TRUE)
    ```

* `expect_s3_class()` and `expect_s4_class()` check that an object `inherit()`s
  from a specified class. `expect_type()`checks the `typeof()` an object.

    
    ```r
    model <- lm(mpg ~ wt, data = mtcars)
    expect_s3_class(model, "lm")
    expect_s3_class(model, "glm")
    #> Error: `model` inherits from 'lm' not 'glm'.
    ```

* `expect_error()`, `expect_warning()` and `expect_message()` check for side
  effects, i.e. whether the code triggers an error, warning, or message.

    
    ```r
    log(-1)
    #> Warning in log(-1): NaNs produced
    #> [1] NaN
    expect_warning(log(-1))
    
    1 / "a"
    #> Error in 1/"a": non-numeric argument to binary operator
    expect_error(1 / "a") 
    ```
  
  You can specify the second argument `regexp` to assert something about the
  text of the message.
  This is often a good idea, to make sure you're catching the condition you
  intended.
    
    
    ```r
    expect_warning(log(-1), "NaNs produced")
    expect_error(1 / "a", "non-numeric argument")
    ```
  
  It is increasingly common to throw classed errors and, if that is the case,
  checking your error's class is better than checking its message.
  We saw an example of this above in the stringr tests.
  This is what the `class` argument is for:
    
    
    ```r
    expect_error(str_dup(1:2, 1:3), class = "vctrs_error_incompatible_size")
    ```
  
  To check for the *absence* of an error, warning, or message, use
  `regexp = NA`:
  
    
    ```r
    expect_error(1 / 2, regexp = NA)
    ```

* `expect_true()` and `expect_false()` are useful catchalls if none of the 
   other expectations does what you need.

### Snapshot tests

Sometimes it's difficult or awkward to describe an expected result with code.
Snapshots tests are a great solution to this problem and this is one of the main innovations in testthat 3e.
The basic idea is that you record the expected result in a separate, human-readable file.
Going forward, testthat alerts you when a newly computed result differs from the previously recorded snapshot.
Snapshot tests are particularly suited to monitoring your package's user interface, such as its informational messages and errors.
Other use cases include testing images or other complicated objects.

We'll illustrate snapshot tests using the waldo package.
Under the hood, testthat 3e uses waldo to do the heavy lifting of "actual vs. expected" comparisons.
One of the main design goals of waldo is to present differences in a clear and actionable manner, as opposed to a frustrating declaration that "this differs from that and I know exactly how, but I won't tell you".
Therefore, the formatting of output from `waldo::compare()` is very intentional and is well-suited to a snapshot test.
The binary outcome of `TRUE` (actual == expected) vs. `FALSE` (actual != expected)` is fairly easy to check and merits its own dedicated tests.
Here we're concerned with writing a test to ensure that differences are reported to the user in the intended way.

waldo uses a few different layouts for showing diffs, depending on various conditions.
Here we deliberately constrain the width, in order to trigger a side-by-side layout.[^actual-waldo-test].

[^actual-waldo-test]: The actual waldo test that inspires this example targets an unexported helper function that produces the desired layout.
But this example uses an exported waldo function for simplicity.


```r
withr::with_options(
  list(width = 20),
  waldo::compare(c("X", letters), c(letters, "X"))
)
#>     old | new    
#> [1] [33m"X"[39m -        
#> [2] [90m"a"[39m | [90m"a"[39m [1]
#> [3] [90m"b"[39m | [90m"b"[39m [2]
#> [4] [90m"c"[39m | [90m"c"[39m [3]
#> 
#>      old | new     
#> [25] [90m"x"[39m | [90m"x"[39m [24]
#> [26] [90m"y"[39m | [90m"y"[39m [25]
#> [27] [90m"z"[39m | [90m"z"[39m [26]
#>          - [34m"X"[39m [27]
```

The two primary inputs differ at two locations:
once at the start and once at the end.
This layout presents both of these, with some surrounding context, which helps the reader orient themselves.

Here's how this would look as a snapshot test:

<!-- Actually using snapshot test technology here is hard.
I can sort of see how it might be done, by looking at the source of testthat's vignette about snapshotting.
For the moment, I'm just faking it. -->


```r
test_that("side-by-side diffs work", {
  withr::local_options(width = 20)
  expect_snapshot(
    waldo::compare(c("X", letters), c(letters, "X"))
  )
})
```

If you execute `expect_snapshot()` or a test containing `expect_snapshot()` interactively, you'll see this:

```
Can't compare snapshot to reference when testing interactively
ℹ Run `devtools::test()` or `testthat::test_file()` to see changes
```

followed by a preview of the snapshot output.

This reminds you that snapshot tests only function when executed non-interactively, i.e. while running an entire test file or the entire test suite.
This applies both to recording snapshots and to checking them.

The first time this test is executed via `devtools::test()` or similar, you'll see something like this (assume the test is in `tests/testthat/test-diff.R`):

```
── Warning (test-diff.R:63:3): side-by-side diffs work ─────────────────────
Adding new snapshot:
Code
  waldo::compare(c(
    "X", letters), c(
    letters, "X"))
Output
      old | new    
  [1] "X" -        
  [2] "a" | "a" [1]
  [3] "b" | "b" [2]
  [4] "c" | "c" [3]
  
       old | new     
  [25] "x" | "x" [24]
  [26] "y" | "y" [25]
  [27] "z" | "z" [26]
           - "X" [27]
```

There is always a warning upon initial snapshot creation.
The snapshot is added to `tests/testthat/_snaps/diff.md`, under the heading "side-by-side diffs work", which comes from the test's description.
The snapshot looks exactly like what a user sees interactively in the console, which is the experience we want to check for.
The snapshot file is *also* very readable, which is pleasant for the package developer.
Going forward, as long as your package continues to re-capitulate the expected snapshot, this test will pass.

If you've written a lot of conventional unit tests, you can appreciate how well-suited snapshot tests are for this use case.
If we were forced to inline the expected output in the test file, there would be a great deal of quoting, escaping, and newline management.
Ironically, with conventional expectations, the output you expect your user to see tends to get obscured by a heavy layer of syntactical noise.

What about when a snapshot test fails?
Let's imagine a hypothetical internal change where the default labels switch from "old" and "new" to "OLD" and "NEW".
Here's how this snapshot test would react:

```
── Failure (test-diff.R:63:3): side-by-side diffs work──────────────────────────
Snapshot of code has changed:
old[3:15] vs new[3:15]
  "    \"X\", letters), c("
  "    letters, \"X\"))"
  "Output"
- "      old | new    "
+ "      OLD | NEW    "
  "  [1] \"X\" -        "
  "  [2] \"a\" | \"a\" [1]"
  "  [3] \"b\" | \"b\" [2]"
  "  [4] \"c\" | \"c\" [3]"
  "  "
- "       old | new     "
+ "       OLD | NEW     "
and 3 more ...

* Run `snapshot_accept('diff')` to accept the change
* Run `snapshot_review('diff')` to interactively review the change
```

This diff is presented more effectively in most real-world usage, e.g. in the console, by a Git client, or via a Shiny app (see below).
But even this plain text version highlights the changes quite clearly.
Each of the two loci of change is indicated with a pair of lines marked with `-` and `+`, showing how the snapshot has changed.

You can call `testthat::snapshot_review('diff')` to review changes locally in a Shiny app, which lets you skip or accept individual snapshots.
Or, if all changes are intentional and expected, you can go straight to `testthat::snapshot_accept('diff')`.
Once you've re-synchronized your actual output and the snapshots on file, your tests will pass once again.
In real life, snapshot tests are a great way to stay informed about changes to your package's user interface, due to your own internal changes or due to changes in your dependencies or even R itself.

`expect_snapshot()` has a few arguments worth knowing about:

* `cran = FALSE`: By default, snapshot tests are skipped if it looks like the
  tests are running on CRAN's servers.
  This reflects the typical intent of snapshot tests, which is to proactively
  monitor user interface, but not to check for correctness, which presumably
  is the job of other unit tests which are not skipped.
  In typical usage, a snapshot change is something the developer will want to
  know about, but it does not signal an actual defect.
* `error = FALSE`: By default, snapshot code is *not* allowed to throw an error.
  See `expect_error()`, described above, for an one approach to testing errors.
  However, sometimes you've carefully crafted an error message for your user and
  you would like to treat it as part of your user interface.
  Specify `error = TRUE` in this case.
* `transform`: Sometimes a snapshot contains volatile, insignificant elements,
  such as a temporary filepath or a timestamp.
  The `transform` argument accepts a function, presumably written by you, to
  remove or replace such changeable text.
  Another use of `transform` is to scrub sensitive information from the
  snapshot.
* `variant`: Sometimes snapshots reflect the ambient conditions, such as the
  operating system or the version of R or one of your dependencies, and you need
  a different snapshot for each variant. This is an experimental and somewhat
  advanced feature, so if you can arrange things to use a single snapshot, you
  probably should.

## Writing tests {#test-tests}

> Everyone knows that debugging is twice as hard as writing a program in the
> first place. So if you're as clever as you can be when you write it, how will
> you ever debug it?
> --- Brian Kernighan

Above is a well-known quote about debugging and we suspect something similar holds true for testing.
Writing good tests for a code base can sometimes feel more challenging than writing the code in the first place.
Even if it's not strictly more difficult, it absolutely has a different feel.
Testing presents many unique challenges and maneuvers, which tend to get much less air time in programming communities than strategies for writing the "main code".

### Test hygiene

<!-- I feel ambivalent about "self-contained" here.
Technically, it's not quite right or, at least, it's an incomplete description.
It also feels as much a piece of aspirational advice re: mindset, as an observation about how things are rigged.
Like, it's sort of self-contained, but to the extent it's not, we urge you to behave in such a way to promote test-self-contained-ness.
-->

Each `test_that()` test is executed in its own environment and is self-contained.
For example, an R object you create inside a test does not exist after the test exits:


```r
exists("thingy")
#> [1] FALSE

test_that("thingy exists", {
  thingy <- "thingy"
  expect_true(exists(thingy))
})
#> [32mTest passed[39m 😸

exists("thingy")
#> [1] FALSE
```

The `thingy` object lives and dies entirely within the confines of `test_that()`.
However, testthat doesn't know how to cleanup after actions that affect other aspects of the R landscape:

* The filesystem: creating and deleting files, changing the working directory,
  etc.
* The search path: `library()`, `attach()`.
* Global options, like `options()` and `par()`, and environment variables.

If it's easy to avoid making such changes in your test code, that is the best strategy.
But if it's unavoidable, then you have to make sure that you clean up after yourself.
This mindset is very similar to one we advocated for in section \@ref(code-r-landscape), when discussing how to design well-mannered functions.

When possible, make each test self-sufficient:

* Don't change the surrounding landscape.
  More realistically, make sure any changes are reversed upon exit.
* Don't depend on specific aspects of the landscape, especially not in some
  implicit, silent way.
  Check for and/or create the conditions necessary for your test to do its job.

In the testing domain, this is sometimes referred to as *setup and teardown* and we'll describe several official testthat ways to do this, at various scopes.

But first, let's connect this back to very similar advice offered in section \@ref(code-r-landscape), which covers your package's "main code", i.e. everything below `R/`:

> The `.R` files below `R/` should consist almost entirely of function definitions.
> Any other top-level code is suspicious and should be carefully reviewed for possible conversion into a function.

Similarly, `tests/testthat/test-*.R` files should consist almost entirely of calls to `test_that()`.
Any other top-level code is suspicious and should be carefully reviewed for conversion to a more official method of achieving whatever its goal is.

Two concrete examples:

* `source()` should not appear in your tests.
  There are several special files with an official role in testthat workflows
  (see below), not to mention the entire R package machinery, that provide
  better ways to make functions, objects, and other logic available in your
  tests.
* `library()` should (almost certainly) not appear in your tests.
  Similar to advice for the code below `R/`, it's usually better to access
  functions from a dependency via `otherpkg::fun()`.
  
<!-- I also want to mention testthat's built-in efforts re: reproducibility.

So: local_test_context(), local_reproducible_output()

https://testthat.r-lib.org/reference/local_test_context.html

This is (one of) the reasonable places to put this content.
-->

#### Self-sufficient tests

It's hard to beat the pure simplicity and obviousness of a test that creates the conditions it needs, then puts things back as they were.
You've already seen an example of this, when we explored snapshot tests:


```r
test_that("side-by-side diffs work", {
  withr::local_options(width = 20)             # <-- (°_°) look here!
  expect_snapshot(
    waldo::compare(c("X", letters), c(letters, "X"))
  )
})
```

This test requires the display width to be set at 20 columns, which is considerably less than the default width.
We like to use the withr package (<https://withr.r-lib.org>) to make temporary changes in global state, because it automatically captures the initial state and arranges the eventual restoration.
In this case, `withr::local_options(width = 20)` sets the `width` option to 20 and, at the end of the test, resets the option to whatever its original value was.
withr is also pleasant to use during interactive development:
deferred actions are still captured on the global environment and can be executed explicitly via `withr::deferred_run()` or implicitly by restarting R.

We recommend including withr in `Suggests`, if you're only going to use it in your tests, or in `Imports`, if you also use it below `R/`.
Call withr functions as we do above, e.g. like `withr::local_whatever()`, in either case.
We generally use suggested packages (such as withr) unconditionally in tests, but reasonable people can disagree on this point.
See section \@ref(suggested-packages-and-tests) for a full discussion.

::: tip
The easiest way to add a package to DESCRIPTION is with, e.g., `usethis::use_package("withr", type = "Suggests")`.
For tidyverse packages, withr is considered a "free dependency", i.e. the tidyverse uses withr so 
extensively that we don't hesitate to use it whenever it would be useful.
:::

withr has a large set of pre-implemented `local_*()` / `with_*()` functions that should handle most of your testing needs.
Here are a couple of the functions most useful when writing tests:

* `local_options()` / `with_options()` (see above)
* `local_envvar()` / `with_envvar()` for temporarily setting an environment variable
    
    ```r
    # from tibble, in tests/testthat/test-utils.R
    test_that("is_rstudio()", {
      expect_false(withr::with_envvar(c(RSTUDIO = NA), is_rstudio()))
      expect_true(withr::with_envvar(c(RSTUDIO = 1), is_rstudio()))
    })
    ```
* `local_tempfile()`, `local_tempdir()`, and `local_file()` for creating a
  self-destructing file or directory
    
    ```r
    # from roxygen2, in tests/testthat/test-collate.R
    test_that("can read from file name with utf-8 path", {
      path <- withr::local_tempfile(
        pattern = "Universit\u00e0-",
        lines = c("#' @include foo.R", NULL)
      )
      expect_equal(find_includes(path), "foo.R")
    })
    ```

There are many other functions in withr, so check there before you write your own.
If nothing exists that meets your need, `withr::defer()` is the general way to schedule some action at the end of a test.[^on-exit]

[^on-exit]: Base R's `on.exit()` is another alternative, but it requires more from you.
You need to capture the original state and write the restoration code yourself.
Also remember to do `on.exit(..., add = TRUE)` if there's *any* chance a second `on.exit()` call could be added in the test.
You probably also want to default to `after = FALSE`.

What if you need to do more than, e.g., set an option, before you can execute your expectations?
We're going to make the controversial recommendation that you tolerate a fair amount of duplication in test code, i.e. you can relax some of your DRY ("don't repeat yourself") tendencies.

Here's a toy example to make things concrete.


```r
test_that("multiplication works", {
  useful_thing <- 3
  expect_equal(2 * useful_thing, 6)
})
#> [32mTest passed[39m 🥇

test_that("subtraction works", {
  useful_thing <- 3
  expect_equal(5 - useful_thing, 2)
})
#> [32mTest passed[39m 🥳
```

In real life, `useful_thing` is usually a more complicated object that somehow feels burdensome to instantiate.
Notice how `useful_thing <- 3` appears in more than once place.
Conventional wisdom says we should DRY this code out.
It's tempting to just move `useful_thing`'s definition outside of the tests:


```r
useful_thing <- 3

test_that("multiplication works", {
  expect_equal(2 * useful_thing, 6)
})
#> [32mTest passed[39m 😸

test_that("subtraction works", {
  expect_equal(5 - useful_thing, 2)
})
#> [32mTest passed[39m 🎉
```

This does sort of work, because when `useful_thing` is not found in the test-specific environment, the search continues in the parent environment, where `useful_thing` will often be found.
When testthat executes an entire test file, `useful_thing` will get defined and made available for subsequent tests in that file.
However, during interactive development, there is no gesture to systematically identify and execute such code.
Top-level code, outside of any test, is in a sort of No Man's Land and the tests relying on it work more by coincidence, than by definition.
Below we recommend various robust and structured solutions to this problem.

But first, seriously consider inlining the creation of a `useful_thing` whenever you need it.
Is it truly expensive to create a `useful_thing` or does it just bug you to see `useful_thing <- 3` in multiple places?
The blog post [Why Good Developers Write Bad Unit Tests](https://mtlynch.io/good-developers-bad-tests/) makes a compelling argument that the requirements of test code and production code are different:

> Keep the reader in your test function.
> Good production code is well-factored; good test code is obvious.
> ... think about what will make the problem obvious when a test fails.

This captures why we advocate inlining logic and objects, where practical.
Imagine yourself troubleshooting a test that's suddenly started failing on CRAN or on GitHub Actions.
If the test is self-sufficient, you can basically focus your attention to the universe contained within `test_that("your code works", { ... })`.
The code inside `{ ... }` will either explicitly create all the necessary objects and conditions or make explicit calls to specific helpers or fixtures (explained below).
We find this a more sustainable workflow than hunting through a test file for top-level calls that need to be executed in order to work on the tests.

### Test fixtures

When it's not practical to make your test entirely self-sufficient, prefer making the necessary object or logic available in a structured, explicit way.
We describe several specific solutions.

#### Store a concrete `useful_thing` persistently

If a `useful_thing` is costly to create, in terms of time or memory, maybe you don't actually need to re-create it for each test run.
You could make the `useful_thing` once, store it as a static test fixture, and load it in the tests that need it.
Here's a sketch of how this could look:


```r
test_that("foofy() does this", {
  useful_thing1 <- readRDS(test_path("fixtures", "useful_thing.rds"))
  expect_equal(foofy(useful_thing1, x = "this"), EXPECTED_FOOFY_OUTPUT)
})

test_that("foofy() does that", {
  useful_thing2 <- readRDS(test_path("fixtures", "useful_thing.rds"))
  expect_equal(foofy(useful_thing2, x = "that"), EXPECTED_FOOFY_OUTPUT)
})
```

:::tip
`testthat::test_path()` is a handy function for building robust paths for files that live below `tests/testthat/`.
The resulting paths work during interactive development, when working directory is presumably set to the package root directory, and during all other methods of test execution, where the working directory is more likely to be `tests/testthat/`.
:::

<!-- I feel like we should say something about storing the code that creates `tests/testthat/fixtures/useful_thing.rds`, similar to what we advocate for data / `use_data()`, `data_raw/`. -->

#### Create `useful_thing`s with a helper function

Is it fiddly to create a `useful_thing`?
Does it take several lines of code, but not much time or memory?
In that case, write a helper function to create a `useful_thing` on-demand:


```r
new_useful_thing <- function() {
  # your fiddly code to create a useful_thing goes here
}
```

and call that helper in the affected tests:


```r
test_that("foofy() does this", {
  useful_thing1 <- new_useful_thing()
  expect_equal(foofy(useful_thing1, x = "this"), EXPECTED_FOOFY_OUTPUT)
})

test_that("foofy() does that", {
  useful_thing2 <- new_useful_thing()
  expect_equal(foofy(useful_thing2, x = "that"), EXPECTED_FOOFY_OUTPUT)
})
```

Where should the `new_useful_thing()` helper be defined?
For new code and actively maintained code, we recommend defining it like any other internal helper, i.e. in a file below `R/`.
If it logically fits into an existing `.R` file, put it there.
Otherwise, consider making a file for test utilities, such as `R/utils-testing.R` or `R/test-helpers.R`.

A key advantage of this solution is that the `new_useful_thing()` helper is available to you during interactive development after `devtools::load_all()` and during automated test runs (`devtools::test_active_file()`, `devtools::test()`, etc.), because this is true of all unexported functions.
Helper code that is lying around in other places, e.g. sprinkled around in test files, does not have this property.

If it's fiddly AND costly to create a `useful_thing`, your helper function could even use memoisation to avoid unnecessary re-computation.
Once you have a helper like `new_useful_thing()`, you often discover that it has uses beyond testing, e.g. behind-the-scenes in a vignette.
Sometimes you even realize you should just export and document it, so you can use it freely in documentation and tests.

Another, older location for defining test helpers is `tests/testthat/helper.R`.
Any `.R` file below `tests/testthat/` that starts with `helper` gets special treatment by testthat and devtools.
By default, such files are sourced by `load_all()` and when you run entire test file or the entire test suite.
This is a legacy approach which still works, but it has no advantage over defining helpers below `R/`.
Avoid this in new code and consider relocating any existing code in `tests/testthat/helper.R` files when updating a package.

<!-- The way I load a token in gargle-using packages in helper.R is actually something that does NOT work "just as well" below `R/`. It could happen in setup.R I suppose, but I actually want / need it to be executed by `load_all()`. I'm not entirely sold on the deprecation of helper.R. -->

<!-- Drafting this made me realize how hard it is to learn about the role of special files in testthat. It's really not spelled out in any obvious way in the testthat docs. 
Update: I am wrong. I eventually found it here! But I still think lots of people don't find this.

https://testthat.r-lib.org/reference/test_file.html?q=setup#special-files

There are two types of .R file that have special behaviour:

Test files start with test and are executed in alphabetical order.

Setup files start with setup and are executed before tests. If clean up is needed after all tests have been run, you can use withr::defer(clean_up(), teardown_env()). See vignette("test-fixtures") for more details.

There are two other types of special file that we no longer recommend using:

Helper files start with helper and are executed before tests are run. They're also loaded by devtools::load_all(), so there's no real point to them and you should just put your helper code in R/.

Teardown files start with teardown and are executed after the tests are run. Now we recommend interleave setup and cleanup code in setup- files, making it easier to check that you automatically clean up every mess that you make.

All other files are ignored by testthat.
-->

#### Create (and destroy) a "local" `useful_thing`

So far, our example of a `useful_thing` was a regular R object, which is cleaned-up automatically at the end of each test.
What if the creation of a `useful_thing` has a side effect on the local file system, on a remote resource, R session options, environment variables, or the like?
Then your helper function should create a `useful_thing` **and clean up afterwards**.
Instead of a simple `new_useful_thing()` constructor, you'll write a customized function in the style of withr's `local_*()` functions:


```r
local_useful_thing <- function(..., env = parent.frame()) {
  # your fiddly code to create a useful_thing goes here
  withr::defer(
    # your fiddly code to clean up after a useful_thing goes here
    envir = env
  )
}
```

Use it in your tests like this:


```r
test_that("foofy() does this", {
  useful_thing1 <- local_useful_thing()
  expect_equal(foofy(useful_thing1, x = "this"), EXPECTED_FOOFY_OUTPUT)
})

test_that("foofy() does that", {
  useful_thing2 <- local_useful_thing()
  expect_equal(foofy(useful_thing2, x = "that"), EXPECTED_FOOFY_OUTPUT)
})
```

Just like `new_useful_thing()`, the best place to define `local_useful_thing()` is in a file below `R/`, making it available during interactive development and and during automated testing.
To learn more about writing custom helpers like `local_useful_thing()`, see the [testthat vignette on test fixtures](https://testthat.r-lib.org/articles/test-fixtures.html).

<!-- 
Quoting from https://testthat.r-lib.org/articles/test-fixtures.html#test-fixtures

> A test fixture is just a local_ function that you use to change state in such a way that you can reach inside and test parts of your code that would otherwise be challenging.

Pedantic critique: I feel like the thing itself (e.g. the Google Sheet, the R package) is the fixture.

The local_*() function instantiates a fixture and schedules it's destruction.
-->

### Setup and teardown

Sometimes there is truly global test setup that would be impractical to build into every single test and that might be tailored for test execution in non-interactive or remote environments.
Examples:

* Turning off behaviour aimed at an interactive user, such as messaging or
  writing to the clipboard.
* Loading a credential for auth.
* Setting up a cache folder.

Put such code in `tests/testthat/setup.R`.
In fact, any file in that directory whose name starts with "setup" is treated as a setup file.
Setup files are run by testthat before running whole test files.
Note that setup code is *not* run by `devtools::load_all()`.

If any of your setup should be reversed after test execution, you should also include the necessary teardown code in `setup.R`.
We recommend maintaining teardown code alongside the setup code, in `setup.R`, because this makes it easier to ensure they stay in sync.
The artificial environment `teatdown_env()` exists as a magical handle to use in `withr::defer()` and `withr::local_*()` / `withr::with_*()`.
A legacy approach (which still works, but is no longer recommended) is to put teardown code in `tests/testthat/teardown.R`.

Here's a `setup.R` example from the reprex package, where we turn off clipboard and HTML preview functionality during testing:


```r
op <- options(reprex.clipboard = FALSE, reprex.html_preview = FALSE)

withr::defer(options(op), teardown_env())
```

Since we are just modifying options here, we can be even more concise and use the pre-built function `withr::local_options()`:


```r
withr::local_options(
  list(reprex.clipboard = FALSE, reprex.html_preview = FALSE),
  teardown_env()
)
```

### What to test

> Whenever you are tempted to type something into a print statement or a 
> debugger expression, write it as a test instead.
> --- Martin Fowler

There is a fine balance to writing tests.
Each test that you write makes your code less likely to change inadvertently;
but it also can make it harder to change your code on purpose.
It's hard to give good general advice about writing tests, but you might find these points helpful:

* Focus on testing the external interface to your functions - if you test the 
  internal interface, then it's harder to change the implementation in the 
  future because as well as modifying the code, you'll also need to update all 
  the tests.

* Strive to test each behaviour in one and only one test.
  Then if that behaviour later changes you only need to update a single test.

* Avoid testing simple code that you're confident will work.
  Instead focus your time on code that you're not sure about, is fragile, or has
  complicated interdependencies.
  That said, I often find I make the most mistakes when I falsely assume that
  the problem is simple and doesn't need any tests.

* Always write a test when you discover a bug.
  You may find it helpful to adopt the test-first philosophy.
  There you always start by writing the tests, and then write the code that
  makes them pass.
  This reflects an important problem solving strategy:
  start by establishing your success criteria, how you know if you've solved the
  problem.

### Skipping a test

Sometimes it's impossible to perform a test - you may not have an internet connection or you may be missing an important file.
Unfortunately, another likely reason follows from this simple rule:
the more machines you use to write your code, the more likely it is that you won't be able to run all of your tests.
In short, there are times when, instead of getting a failure, you just want to skip a test.
To do that, you can use the `skip()` function - rather than throwing an error it simply prints an `S` in the output.


```r
skip_if_no_api() <- function() {
  if (api_unavailable()) {
    skip("API not available")
  }
}

test_that("foo api returns bar when given baz", {
  skip_if_no_api()
  ...
})
```

The custom skipper `skip_if_no_api()` is a yet another example of a test helper and the advice already given about where to define it applies here too.
Likewise, we lean towards calling `skip_if_no_api()` in each test where it's needed, even though this might lead to repetition.
This is another type of call that is tempting to hoist to the top-level of a test file:


```r
skip_if_no_api()

test_that("foo api returns bar when given baz", {...})

test_that("foo api returns an errors when given qux", {...})
```

We have mixed feelings about this practice.
Within the realm of top-level code in test files, this is probably on the "more acceptable" / "least offensive" end.
But once a test file does not fit entirely on your screen, it creates an implicit yet easy-to-miss connection between the skip(s) and individual tests.

At the complete other extreme, another practice that can make sense in very specific situations is to build a `skip()` directly into a package function.
Here's an example from pkgdown, in `convert_markdown_to_html()`, which absolutely, positively cannot work if the Pandoc tool is unavailable:

<https://github.com/r-lib/pkgdown/blob/98d5a5c735eb244cb98b2e6bab1d54bb27c0af95/R/markdown.R#L95-L106>


```r
# in r-lib/pkgdown/R/markdown.R
convert_markdown_to_html <- function(in_path, out_path, ...) {
  if (rmarkdown::pandoc_available("2.0")) {
    from <- "markdown+gfm_auto_identifiers-citations+emoji+autolink_bare_uris"
  } else if (rmarkdown::pandoc_available("1.12.3")) {
    from <- "markdown_github-hard_line_breaks+tex_math_dollars+tex_math_single_backslash+header_attributes"
  } else {
    if (is_testing()) {
      testthat::skip("Pandoc not available")
    } else {
      abort("Pandoc not available")
    }
  }
  
  rmarkdown::pandoc_convert(...)
  invisible()
}
```

When this function executes, in the absence of Pandoc, it throws an error *unless* it appears to part of a test run, in which it skips the test.
This is an alternative to implementing a custom skipper, e.g. `skip_if_no_pandoc()`, and inserting it into many of pkgdown's tests.

Advantages of this approach: Feels elegant and concise.

Disadvantages of this approach: Seems to violate "Good production code is well-factored; good test code is obvious", i.e. when you're focused on the tests, the existence of this skip is easy to miss.

<!-- I want to talk about the danger of skipping, i.e. when you think everything's "green", but actually you're not running any / many tests, because some pre-condition is not met. -->

### Building your own testing tools

<!--
Why Good Developers Write Bad Unit Tests
https://mtlynch.io/good-developers-bad-tests/
"Your natural inclination might be to delegate all the uninteresting code to test helper methods, but you should first ask a more vital question: why is the system so difficult to test? Excessive boilerplate code is often a symptom of weak architecture."
"When tempted to write test helper methods, try refactoring your production code instead."
-->

Let's return to the topic of duplication in your test code.
We've encouraged you to have a higher tolerance for repetition in test code, in the name of making your tests obvious.
But there's still a limit to how much repetition to tolerate.
We've covered techniques such as loading static objects with `test_path()`, writing a constructor like `new_useful_thing()`, or implementing a test fixture like `local_useful_thing()`.
There are even more types of test helpers that can be useful in certain situations.

For example, the following code shows one test of the `floor_date()` function from `library(lubridate)`.
There are seven expectations that check the results of rounding a date down to the nearest second, minute, hour, etc.
There's a lot of duplication here, which increases the chance of copy / paste errors and generally makes your eyes glaze over.


```r
# this library call would NOT appear in a real test file for lubridate
library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union

test_that("floor_date works for different units", {
  base <- as.POSIXct("2009-08-03 12:01:59.23", tz = "UTC")

  expect_equal(floor_date(base, "second"), 
    as.POSIXct("2009-08-03 12:01:59", tz = "UTC"))
  expect_equal(floor_date(base, "minute"), 
    as.POSIXct("2009-08-03 12:01:00", tz = "UTC"))
  expect_equal(floor_date(base, "hour"),   
    as.POSIXct("2009-08-03 12:00:00", tz = "UTC"))
  expect_equal(floor_date(base, "day"),    
    as.POSIXct("2009-08-03 00:00:00", tz = "UTC"))
  expect_equal(floor_date(base, "week"),   
    as.POSIXct("2009-08-02 00:00:00", tz = "UTC"))
  expect_equal(floor_date(base, "month"),  
    as.POSIXct("2009-08-01 00:00:00", tz = "UTC"))
  expect_equal(floor_date(base, "year"),   
    as.POSIXct("2009-01-01 00:00:00", tz = "UTC"))
})
#> [32mTest passed[39m 😸
```

A nice move here is to create some hyper-local helper functions to make each expectation more concise.
Now each expectation fits on one line, which allows us read the actual and expected value like a table.
This makes it easier to see the expected floor evolve, as we vary the `unit` from `second` to `year`:

<!-- I actually think that, for THIS SPECIFIC EXAMPLE, this is exactly the right level of customization. When we take the next step, below, it feels weird. -->


```r
test_that("floor_date works for different units", {
  as_time <- function(x) as.POSIXct(x, tz = "UTC")
  base <- as_time("2009-08-03 12:01:59.23")
  floor_base <- function(unit) floor_date(base, unit)

  expect_equal(floor_base("second"), as_time("2009-08-03 12:01:59"))
  expect_equal(floor_base("minute"), as_time("2009-08-03 12:01:00"))
  expect_equal(floor_base("hour"),   as_time("2009-08-03 12:00:00"))
  expect_equal(floor_base("day"),    as_time("2009-08-03 00:00:00"))
  expect_equal(floor_base("week"),   as_time("2009-08-02 00:00:00"))
  expect_equal(floor_base("month"),  as_time("2009-08-01 00:00:00"))
  expect_equal(floor_base("year"),   as_time("2009-01-01 00:00:00"))
})
#> [32mTest passed[39m 🥳
```

<!-- Here's where I think we should just find a new example, but I've modernized this one for now. Two changes:

* Fall in with the `object, expected, details` pattern the most expectations have.
* Modern approach to NSE / metaprogramming.

But the basically fixed "base" the primary actual input and the need to as_time() everything adds a lot of fiddliness.
-->

We could go a step further and create a custom expectation function that wraps `expect_equal()`:


```r
expect_floor_date <- function(object, expected, unit) {
  as_time <- function(x) as.POSIXct(x, tz = "UTC")
  expect_equal(floor_date(as_time(object), unit), as_time(expected))
}

expect_floor_date("2009-08-03 12:01:59.23", "2009-01-01 00:00:00", "year")
```

However, if this expectation fails, the output of such a super-simple wrapper is less than ideal:


```r
expect_floor_date("2009-08-03 12:01:59.23", "2222-02-01 00:00:00", "year")
#> Error: floor_date(as_time(object), unit) (`actual`) not equal to as_time(expected) (`expected`).
#> 
#> `actual`:   [32m"2009-01-01"[39m
#> `expected`: [32m"2222-02-01"[39m
```

If you're going to create a custom expectation, you should probably take the next step and do the non-standard evaluation or meta-programming work to give yourself an intelligible and actionable failure message.


```r
expect_floor_date <- function(object, expected, unit) {
  act <- quasi_label(rlang::enquo(object), arg = "object")
  exp <- quasi_label(rlang::enquo(expected), arg = "expected")
  as_time <- function(x) as.POSIXct(x, tz = "UTC")
  
  # I want to do a modern waldo-y comparison
  # is that possible without `testthat:::`?
  comp <- testthat:::waldo_compare(
    floor_date(as_time(object), unit = unit),
    as_time(expected),
    x_arg = "actual", y_arg = "expected"
  )

  expect(
    length(comp) == 0,
    c(
      # could just use object here? I don't see why act$lab is needed
      glue::glue("floor_date({act$lab}, \"{unit}\") not equal to {exp$lab}"),
      comp
    ),
    trace_env = rlang::caller_env()
  )

  invisible(act$val)
}

# success
expect_floor_date("2009-08-03 12:01:59.23", "2009-01-01 00:00:00", "year")

# failure
expect_floor_date("2009-08-03 12:01:59.23", "2222-02-01 00:00:00", "year")
#> Error: floor_date("2009-08-03 12:01:59.23", "year") not equal to "2222-02-01 00:00:00"
#> `actual`:   [32m"2009-01-01"[39m
#> `expected`: [32m"2222-02-01"[39m
```

*I'm keeping the "old way" here, so we can see how the previous custom expectation example played out.*

The key is to use `bquote()` and `eval()`.
In the `bquote()` call below, note the use of `.(x)` - the contents of `()` will be inserted into the call.


```r
expect_floor_old_skool <- function(unit, time) {
  as_time <- function(x) as.POSIXct(x, tz = "UTC")
  base <- as_time("2009-08-03 12:01:59.23")
  eval(bquote(expect_equal(floor_date(base, .(unit)), as_time(.(time)))))
}
expect_floor_old_skool("year", "2008-01-01 00:00:00")
#> Error: floor_date(base, "year") (`actual`) not equal to as_time("2008-01-01 00:00:00") (`expected`).
#> 
#> `actual`:   [32m"2009-01-01"[39m
#> `expected`: [32m"2008-01-01"[39m
# Error: floor_date(base, "year") not equal to as_time("2008-01-01 00:00:00").
# 1/1 mismatches
# [1] 2009-01-01 - 2008-01-01 == 366 days
```

This sort of refactoring is often worthwhile because removing redundant code makes it easier to see what's changing.
Readable tests give you more confidence that they're correct.


```r
test_that("floor_date works for different units", {
  as_time <- function(x) as.POSIXct(x, tz = "UTC")
  
  expect_floor_old_skool <- function(unit, time) {
    eval(bquote(expect_equal(floor_date(base, .(unit)), as_time(.(time)))))
  }
  
  base <- as_time("2009-08-03 12:01:59.23")
  expect_floor_old_skool("second", "2009-08-03 12:01:59")
  expect_floor_old_skool("minute", "2009-08-03 12:01:00")
  expect_floor_old_skool("hour",   "2009-08-03 12:00:00")
  expect_floor_old_skool("day",    "2009-08-03 00:00:00")
  expect_floor_old_skool("week",   "2009-08-02 00:00:00")
  expect_floor_old_skool("month",  "2009-08-01 00:00:00")
  expect_floor_old_skool("year",   "2009-01-01 00:00:00")
})
#> [32mTest passed[39m 😀
```

## CRAN notes {#test-cran}

CRAN will run your tests on all CRAN platforms: Windows, Mac, and Linux.
There are a few things to bear in mind:

* Tests need to run relatively quickly - aim for under a minute.
  Place `skip_on_cran()` at the beginning of long-running tests that shouldn't
  be run on CRAN - they'll still be run locally, but not on CRAN.

* ~Note that tests are always run in the English language (`LANGUAGE=EN`) and
  with C sort order (`LC_COLLATE=C`).
  This minimises spurious differences between platforms.~ *This is not true.*

* Be careful about testing things that are likely to be variable on CRAN
  machines.
  It's risky to test how long something takes (because CRAN machines are often
  heavily loaded) or to test parallel code (because CRAN runs multiple package
  tests in parallel, multiple cores will not always be available).
  Numerical precision can also vary across platforms (it's often less precise on 
  32-bit versions of R) so use `expect_equal()` rather than
  `expect_identical()`.

CRAN revision thought dump:

* Enrich description of platforms, i.e. say more than "Windows, Mac, Linux".
  The check flavors: <https://cran.r-project.org/web/checks/check_flavors.html>.
  - Draw a line to how this determines which "flavors" a package should be
    checked on.
    Depends on how broad the user base is and the "trickiness" of the package's
    code (e.g. does it need compilation?).
    Do a cost benefit analysis.
    Connect that to which `usethis::use_github_action_check_*()` variant is
    appropriate.
* How to decide whether to let a test run on CRAN.
  If the test can fail WITHOUT indicating a defect in your package that merits
  removal from CRAN, do not let CRAN run the test. Examples:
  - Accessing a website or API that could ever be down or have an
    occasional error (so: any website or API on planet earth).
  - Exact formatting of a message.
  - File system work typical of an authentic user that touches files any where
    but the R session's temp directory. This includes reading or writing the
    clipboard.
* How to prevent a test from running on CRAN.
  - `skip_on_cran()`, `skip_on_os()`
  - Default behaviour for snapshot tests
  - Keep in a separate repo

## Miscellaneous sections to (maybe) add

### Mocking

### Filesystem matters

Do not write into `tests/testthat/` during your tests.

The only place you should write into is session temp dir.

Even then, best practice is to clean up any files or folder you create.

Ways to be build good paths:

* `testthat::test_path()`
* `fs::path_package()` and `system.file()`

### Namespace

You can call / test all of your own package's functions without any special effort on your part, regardless of whether they are exported or not.

That is provided at test time by `testhat::test_file()`, `devtools::test()`, etc.

During interactive development, you should make this happen for yourself via `devtools::load_all()`.

In general, testthat's official workflows are designed around the assumption that the user uses `devtools::load_all()`.

### Dependencies

Don't attach other packages from your tests.
Don't call `library()`.
Or, rather, that should be about as rare as using `Depends`.

If other package is in Imports, do `foo::fun()`, just like we recommend when you use it in functions below `R/`.

If other package is in Suggests, .... I already wrote about whether and how to guard in Metadata.Rmd.
Move that content?

<!--
Thought dump re: revision, stuff I haven't added yet (and maybe never will?)

web, APIs, auth, secrets


When does our file naming / organisation  advise not work? sometimes a package has one main function and following the convention would result in having one monster file of tests.

Example: reprex::reprex(), (to a lesser extent) readxl::read_excel()
Instead, in those cases, you might organize your tests around the use of
specific arguments (reprex) or the challenges presented by specific inputs
(readxl).
-->

[tdd]:https://en.wikipedia.org/wiki/Test-driven_development
[extreme-programming]:https://en.wikipedia.org/wiki/Extreme_programming
