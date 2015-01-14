#' @useDynLib src.c add_
add <- function(x, y) {
  .C(add_, x, y, numeric(1))[[3]]
}
