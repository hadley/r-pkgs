# Releasing to CRAN {#release}

::: {.rmdnote}
You are reading the work-in-progress second edition of R Packages. This chapter is undergoing heavy restructuring and may be confusing or incomplete. :::

If you want your package to have significant traction in the R community, you need to submit it to CRAN. Submitting to CRAN is a lot more work than just providing a version on github, but the vast majority of R users do not install packages from github, because CRAN provides discoverability, ease of installation and a stamp of authenticity. The CRAN submission process can be frustrating, but it's worthwhile, and this chapter will make it as painless as possible.

To get your package ready to release, follow these steps:

1. Pick a version number.
1. Run and document `R CMD check`.
1. Check that you're aligned with CRAN policies.
1. Update `README.md` and `NEWS.md`.
1. Submit the package to CRAN.
1. Prepare for the next version by updating version numbers.
1. Publicise the new version.

## The submission process {#release-process}

To manually submit your package to CRAN, you create a package bundle (with `devtools::build()`) then upload it to <https://cran.r-project.org/submit.html>, along with some comments which describe the process you followed. This section shows you how to make submission as easy as possible by providing a standard structure for those comments. Later, in [submission](#release-submission), you'll see how to actually submit the package with `devtools::release()`.

When submitting to CRAN, remember that CRAN is staffed by volunteers, all of whom have other full-time jobs. A typical week has over 100 submissions and only three volunteers to process them all. The less work you make for them the more likely you are to have a pleasant submission experience.

I recommend that you store your submission comments in a file called `cran-comments.md`. `cran-comments.md` should be checked into git (so you can track it over time), and listed in `.Rbuildignore` (so it's not included in the package). As the extension suggests, I recommend using Markdown because it gives a standard way of laying out plain text. However, because the contents will never be rendered to another format, you don't need to worry about sticking to it too closely. Here are the `cran-comments.md` from a recent version of httr:

```md
## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* checking dependencies in R code ... NOTE
  Namespace in Imports field not imported from: 'R6'

  R6 is a build-time dependency.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of httr 
(https://github.com/wch/checkresults/blob/master/httr/r-release). 
All packages that I could install passed except:

* Ecoengine: this appears to be a failure related to config on 
  that machine. I couldn't reproduce it locally, and it doesn't 
  seem to be related to changes in httr (the same problem exists 
  with httr 0.4).
```

This layout is designed to be easy to skim, and easy to match up to the `R CMD check` results seen by CRAN maintainers. It includes two sections:

1.  Check results: I always state that there were no errors or warnings. 
    Any `NOTE`s go in a bulleted list. For each `NOTE`, I include the message 
    from `R CMD check` and a brief description of why I think it's OK.
    If there were no `NOTE`s, I'd say "There were no ERRORs, WARNINGs or NOTEs"

1.  Downstream dependencies: If there are downstream dependencies, I run 
    `R CMD check` on each package and summarise the results. If there are
    no downstream dependencies, keep this section, but say: "There are currently
    no downstream dependencies for this package".

These are described in more detail below.

### Test environments {#release-test-env}

When checking your package you need to make sure that it passed with the current development version of R and it works on at least two platforms. `R CMD check` is continuously evolving, so it's a good idea to check your package with the latest development version, __R-devel__. You can install R-devel on your own machine:

* Mac: install from <https://mac.r-project.org/>.

* Windows: install from <https://cran.r-project.org/bin/windows/base/rdevel.html>

* Linux: either build it from source, or better, learn about Docker containers
  and run the R-devel container from <https://github.com/rocker-org/rocker>.

It's painful to manage multiple R versions, especially since you'll need to reinstall all your packages. Instead, you can run `R CMD check` on CRAN's servers with the `devtools::check_win_*()` family of functions.  They build your package and submit it to the CRAN win-builder. 10-20 minutes after submission, you'll receive an e-mail telling you the check results.

CRAN runs on multiple platforms: Windows, Mac OS X, Linux, and Solaris. You don't need to run `R CMD check` on every one of these platforms, but it's a really good idea to do it on at least two. This increases your chances of spotting code that relies on the idiosyncrasies of specific platform. There are two easy ways to check on different platforms:

* `rhub::check()` which lets you manually run `R CMD check` on the platform of
   your choosing.
   
* `usethis::use_github_action_check_standard()` which helps you set up GitHub
  actions to automatically run `R CMD check` every time you push to GitHub.

Debugging code that works on your computer but fails elsewhere is painful. If that happens to you, either install a virtualisation tool so that you can run another operating system locally, or find a friend to help you figure out the problem. Don't submit the package and hope CRAN will help you figure out the problem.

### Check results {#release-check}

You've already learned how to use `R CMD check` and why it's important in [automated checking](#check). Compared to running `R CMD check` locally, there are a few important differences when running it for a CRAN submission:

  * You must fix all `ERROR`s and `WARNING`s. A package that contains any errors 
    or warnings will not be accepted by CRAN.
  
  * Eliminate as many `NOTE`s as possible. Each `NOTE` requires human oversight, 
    which is a precious commodity. If there are notes that you do 
    not believe are important, it is almost always easier to fix them (even if 
    the fix is a bit of a hack) than to persuade CRAN that they're OK. See 
    [check descriptions](#check-checks) for details on how to fix individual 
    problems.
    
    If you have no `NOTE`s it is less likely that your package will be 
    flagged for additional human checks. These are time consuming for both
    you and CRAN, so are best avoided if possible. 
  
  * If you can't eliminate a `NOTE`, document it in `cran-comments.md`, 
    describing why you think it is spurious. Your comments should be easy to 
    scan, and easy to match up with `R CMD check`. Provide the CRAN maintainers 
    with everything they need in one place, even if it means repeating yourself.
    
    NB: There will always be one `NOTE` when you first submit your package. 
    This reminds CRAN that this is a new submission and that they'll need to 
    do some extra checks. You can't eliminate this, so just mention in
    `cran-comments.md` that this is your first submission.

### Reverse dependencies {#release-deps}

Finally, if you're releasing a new version of an existing package, it's your responsibility to check that downstream dependencies (i.e. all packages that list your package in the `Depends`, `Imports`, `Suggests` or `LinkingTo` fields) continue to work. To help you do this, ~~devtools provides `devtools::revdep_check()`~~. *This section is slated for revision for the 2nd edition. In the meantime, know that this functionality is now provided by the [revdepcheck](https://r-lib.github.io/revdepcheck/) package.* This:

1. Sets up a temporary library so it doesn't clobber any existing packages you
   have installed.
   
1. Installs all of the dependencies of the downstream dependencies.

1. Runs `R CMD check` on each package.

1. Summarises the results in a single file.

Run `usethis::use_revdep()` to set up your package with a useful template.

If any packages fail `R CMD check`, you should give package authors at least two weeks to fix the problem before you submit your package to CRAN (you can easily get all maintainer e-mail addresses with `revdep_maintainers()`). After the two weeks is up, re-run the checks, and list any remaining failures in `cran-comments.md`. Each package should be accompanied by a brief explanation that either tells CRAN that it's a false positive in `R CMD check` (e.g. you couldn't install a dependency locally) or that it's a legitimate change in the API (which the maintainer hasn't fixed yet). 

Inform CRAN of your release process: "I advised all downstream package maintainers of these problems two weeks ago". Here's an example from a recent release of dplyr:

```
Important reverse dependency check notes (full details at 
https://github.com/wch/checkresults/tree/master/dplyr/r-release);

* COPASutils, freqweights, qdap, simPH: fail for various reasons. All package 
  authors were informed of the upcoming release and shown R CMD check issues 
  over two weeks ago.

* ggvis: You'll be receiving a submission that fixes these issues very shortly
  from Winston.

* repra, rPref: uses a deprecated function.
```

## CRAN policies {#cran-policies}

As well as the automated checks provided by `R CMD check`, there are a number of [CRAN policies](https://cran.r-project.org/web/packages/policies.html) that must be checked manually. The CRAN maintainers will typically look at this very closely on a package's first submission.

I've summarised the most common problems below:

* It's vital that the maintainer's e-mail address is stable because this is the 
  only way that CRAN has to contact you, and if there are problems and they 
  can't get in touch with you they will remove your package from CRAN. So make 
  sure it's something that's likely to be around for a while, and that it's not 
  heavily filtered.

* You must have clearly identified the copyright holders in `DESCRIPTION`:
  if you have included external source code, you must ensure that the license
  is compatible. See the [licensing chapter](#license), the [license section of DESCRIPTION](#description-license), and [`src/` licensing](#src-licensing)
  for more details.

* You must "make all reasonable efforts" to get your package working across
  multiple platforms. Packages that don't work on at least two will
  not normally be considered.

* Do not make external changes without explicit user permission. Don't write to 
  the file system, change options, install packages, quit R, send information 
  over the internet, open external software, etc.
  
* Do not submit updates too frequently. The policy suggests a new version
  once every 1-2 months at most.

I recommend following the [CRAN Policy Watch](https://twitter.com/CRANPolicyWatch) Twitter account which tweets whenever there's a policy change. You can also look at the GitHub repository that powers it: <https://github.com/eddelbuettel/crp/commits/master/texi>.


## Release {#release-submission}

You're now ready to submit your package to CRAN. The easiest way to do this is to run `devtools::release()`. This:

* Builds the package and runs `R CMD check` one last time.

* Asks you a number of yes/no questions to verify that you followed the
  most common best practices.
  
* Allows you to add your own questions to the check process by including an
  unexported `release_questions()` function in your package. This should
  return a character vector of questions to ask. For example, httr has:
  
    
    ```r
    release_questions <- function() {
      c(
        "Have you run all the OAuth demos?",
        "Is inst/cacert.pem up to date?"
      )
    }
    ```
    
    This is useful for reminding you to do any manual tasks that 
    can't otherwise be automated.
  
* Uploads the package bundle to the 
  [CRAN submission form](https://cran.r-project.org/submit.html) including the
  comments in `cran-comments.md`.

Within the next few minutes, you'll receive an email notifying you of the submission and asking you to approve it (this confirms that the maintainer address is correct). Next the CRAN maintainers will run their checks and get back to you with the results. This normally takes around 24 hours, but occasionally can take up to 5 days.

### On failure

If your package does not pass `R CMD check` or is in violation of CRAN policies, a CRAN maintainer will e-mail you and describe the problem(s). Failures are frustrating, and the feedback may be curt and may feel downright insulting. Arguing with CRAN maintainers will likely waste both your time and theirs. Instead:

* Breathe. A rejected CRAN package is not the end of the world. It happens to
  everyone. Even members of R-core have to go through the same process and CRAN 
  is no friendlier to them. I have had numerous packages rejected by CRAN.
  I was banned from submitting to CRAN for two weeks because too many of 
  my existing packages had minor problems.

* If the response gets you really riled up, take a couple of days to cool down
  before responding. Ignore any ad hominem attacks, and strive to respond only 
  to technical issues.

* If a devtools problem causes a CRAN maintainer to be annoyed with you, I 
  am deeply sorry. If you forward me the message along with your address,
  I'll send you a hand-written apology card.

Unless you feel extremely strongly that discussion is merited, don't respond to the e-mail. Instead:

  * Fix the identified problems and make recommended changes. Re-run
    `devtools::check()` to make sure you didn't accidentally introduce any 
    new problems.
  
  * Add a "Resubmission" section at the top of `cran-comments.md`. This should 
    clearly identify that the package is a resubmission, and list the changes 
    that you made.
    
    ```md
    ## Resubmission
    This is a resubmission. In this version I have:
    
    * Converted the DESCRIPTION title to title case.
    
    * More clearly identified the copyright holders in the DESCRIPTION
      and LICENSE files.
    ```
  
  * If necessary, update the check results and downstream dependencies sections.
  
  * Run `devtools::submit_cran()` to re-submit the package without working 
    through all the `release()` questions a second time.

### Binary builds

After the package has been accepted by CRAN it will be built for each platform. It's possible this may uncover further errors. Wait 48 hours until all the checks for all packages have been run, then go to the check results page for your package:

![](images/cran-checks.png)<!-- -->

Prepare a patch release that fixes the problems and submit using the same process as above.

## Prepare for next version {#post-release}

Once your package has been accepted by CRAN, you have a couple of technical tasks to do:

* If you use GitHub, go to the repository release page. Create a new release
  with tag version `v1.2.3` (i.e. "v" followed by the version of your package).
  Copy and paste the contents of the relevant `NEWS.md` section into the release 
  notes.
  
* If you use git, but not GitHub, tag the release with `git tag -a v1.2.3`.

* Add the `.9000` suffix to the `Version` field in the DESCRIPTION to indicate
  that this is a development version. Create a new heading in `NEWS.md` and commit the changes.

## Publicising your package {#promotion}

Now you're ready for the fun part: publicising your package. This is really important. No one will use your helpful new package if they don't know that it exists.

Start by writing a release announcement. This should be an R Markdown document that briefly describes what the package does (so people who haven't used it before can understand why they should care), and what's new in this version. Start with the contents of `NEWS.md`, but you'll need to modify it. The goal of `NEWS.md` is to be comprehensive; the goal of the release announcement is to highlight the most important changes. Include a link at the end of the announcement to the full release notes so people can see all the changes. Where possible, I recommend showing examples of new features: it's much easier to understand the benefit of a new feature if you can see it in action. 

There are a number of places you can include the announcement:

* If you have a blog, publish it there. I now publish all package release
  announcements on the [RStudio blog](https://blog.rstudio.org/author/hadleywickham/).

* If you use Twitter, tweet about it with the #rstats hashtag.

* Send it to the 
  [r-packages mailing list](https://stat.ethz.ch/mailman/listinfo/r-packages).
  Messages sent to this list are automatically forwarded to the R-help mailing 
  list.

## Congratulations!

You have released your first package to CRAN and made it to the end of the book! 
