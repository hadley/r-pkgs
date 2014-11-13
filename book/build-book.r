library(bookdown)
library(rmarkdown)

# Render chapters into tex  ----------------------------------------------------
needs_update <- function(src, dest) {
  if (!file.exists(dest)) return(TRUE)
  mtime <- file.info(src, dest)$mtime
  mtime[2] < mtime[1]
}

render_chapter <- function(src) {
  dest <- file.path("book/tex/", gsub("\\.rmd", "\\.tex", src))
  if (!needs_update(src, dest)) return()

  message("Rendering ", src)
  command <- bquote(rmarkdown::render(.(src), bookdown::tex_chapter(),
    output_dir = "book/tex", quiet = TRUE, env = globalenv()))
  writeLines(deparse(command), "run.r")
  on.exit(unlink("run.r"))
  source_clean("run.r")
}

source_clean <- function(path) {
  r_path <- file.path(R.home("bin"), "R")
  cmd <- paste0(shQuote(r_path), " --quiet --file=", shQuote(path))

  out <- system(cmd, intern = TRUE)
  status <- attr(out, "status")
  if (is.null(status)) status <- 0
  if (!identical(as.character(status), "0")) {
    stop("Command failed (", status, ")", call. = FALSE)
  }
}

chapters <- dir(".", pattern = "\\.rmd$")
lapply(chapters, render_chapter)

# Copy across additional files -------------------------------------------------
file.copy("book/r-packages.tex", "book/tex/", recursive = TRUE)
file.copy("diagrams/", "book/tex/", recursive = TRUE)
file.copy("screenshots/", "book/tex/", recursive = TRUE)

# Build tex file ---------------------------------------------------------------
# (build with Rstudio to find/diagnose errors)
old <- setwd("book/tex")
system("xelatex -interaction=batchmode r-packages ")
system("xelatex -interaction=batchmode r-packages ")
setwd(old)

file.copy("book/tex/r-packages.pdf", "book/r-packages.pdf", overwrite = TRUE)
