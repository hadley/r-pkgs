out <- "extras/devtools"
if (!file.exists(out)) {
  dir.create(out)
}

url <- "https://github.com/hadley/devtools/archive/master.zip"
download.file(url, file.path(out, "devtools.zip"), method = "wget", quiet = TRUE)
unzip(file.path(out, "devtools.zip"), exdir = out)
src <- dir(file.path(out, "devtools-master"))

dev_built <- build(file.path(out, "devtools-master"))
untar(dev_built, exdir = out)
blt <- dir(file.path(out, "devtools"))

dev_binary <- build(file.path(out, "devtools-master"), binary = TRUE)
untar(dev_binary, exdir = out)
bin <- dir(file.path(out, "devtools"))


paths <- c(src, blt, bin)
type <- rep(c("src", "blt", "bin"), c(length(src), length(blt), length(bin)))

tbl <- table(paths, factor(type, c("src", "blt", "bin")))
tbl[] <- ifelse(tbl == 0, "", "x")
tbl[tbl == 1] <- "x"
