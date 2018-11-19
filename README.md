# R packages

This is code and text behind the [R packages](http://r-pkgs.had.co.nz)
book. 

*Status as of 2018-11: Work on a second edition of this book is planned for 2019 and at the moment this repo is "resting". Issues and PRs are still welcome but may not be addressed until that revision begins. This is especially true for any updates related to changes in devtools and related packages.* 

The site is built using jekyll, with a custom plugin to render `.rmd` files with
knitr and pandoc. To create the site, you need:

* jekyll gem: `gem install jekyll`
* bookdown: `install_github("hadley/bookdown")`
* [pandoc](http://johnmacfarlane.net/pandoc/)
* [knitr](http://yihui.name/knitr/): `install.packages("knitr")`
