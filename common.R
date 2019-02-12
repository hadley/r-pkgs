## seeded with content from same in adv-r
## deleted bits that seem irrelevant
## commented out bits that look like they may become relevant

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE
  # cache = TRUE,
  # fig.retina = 0.8, # figures are either vectors or 300 dpi diagrams
  # dpi = 300,
  # out.width = "70%",
  # fig.align = 'center',
  # fig.width = 6,
  # fig.asp = 0.618,  # 1 / phi
  # fig.show = "hold"
)

options(
  rlang_trace_top_env = rlang::current_env(),
  rlang__backtrace_on_error = "none"
)

options(
  digits = 3,
  str = strOptions(strict.width = "cut")
)

if (knitr::is_latex_output()) {
  knitr::opts_chunk$set(width = 69)
  options(width = 69)
  options(crayon.enabled = FALSE)
  options(cli.unicode = TRUE)
}

# knitr::knit_hooks$set(
#   small_mar = function(before, options, envir) {
#     if (before) {
#       par(mar = c(4.1, 4.1, 0.5, 0.5))
#     }
#   }
# )

# Make error messages closer to base R
registerS3method("wrap", "error", envir = asNamespace("knitr"),
                 function(x, options) {
                   msg <- conditionMessage(x)
                   
                   call <- conditionCall(x)
                   if (is.null(call)) {
                     msg <- paste0("Error: ", msg)
                   } else {
                     msg <- paste0("Error in ", deparse(call)[[1]], ": ", msg)
                   }
                   
                   msg <- error_wrap(msg)
                   knitr:::msg_wrap(msg, "error", options)
                 }
)

error_wrap <- function(x, width = getOption("width")) {
  lines <- strsplit(x, "\n", fixed = TRUE)[[1]]
  paste(strwrap(lines, width = width), collapse = "\n")
}

knitr::knit_hooks$set(chunk_envvar = function(before, options, envir) {
  envvar <- options$chunk_envvar
  if (before && !is.null(envvar)) {
    old_envvar <<- Sys.getenv(names(envvar), names = TRUE, unset = NA)
    do.call("Sys.setenv", as.list(envvar))
    #print(str(options))
  } else {
    do.call("Sys.setenv", as.list(old_envvar))
  }
})

check_quietly <- purrr::quietly(devtools::check)

shhh_check <- function(..., quiet = TRUE) {
  out <- check_quietly(..., quiet = quiet)
  out$result
}

