redirects <- tibble::tribble(
  # backing out of the pattern where I used uppercase filenames to indicate
  # chapters that had been revised for 2e
  ~from,                    ~to,                    
  "Code.html",             "/code.html",           
  "Data.html",             "/data.html",           
  "Introduction.html",     "/introduction.html",   
  "Metadata.html",         "/metadata.html",       
  "Package-within.html",   "/package-within.html", 
  "Preface.html",          "/preface.html",        
  "Setup.html",            "/setup.html",          
  "Structure.html",        "/structure.html",      
  "Whole-game.html",       "/whole-game.html",     
  "Workflow101.html",      "/workflow101.html",    
  
  # chapters removed
  "git.html",              "/software-development-practices.html",
  "src.html",              "/preface.html", 
  
  # 1e -> 2e move, then another move during 2e development
  "package.html",          "/package-structure-state.html",
  "package-structure-state.html", "/structure.html",
  
  # 1e -> 2e move
  "check.html",            "/workflow101#sec-workflow101-r-cmd-check",
  
  # chapter got merged into another
  "inst.html",             "/misc.html#inst",
  
  # lots of 1e -> 2e changes and churn within 2e
  "namespace.html",        "/dependencies-mindset-background.html#sec-dependencies-namespace",
  
  # split into multiple chapters
  "tests.html",            "/testing-basics.html"
)

redirects$html <- sprintf(
  "<!DOCTYPE html><html><head><meta http-equiv=\"refresh\" content=\"0; url=%s\" /></head></html>",
  redirects$to
)
redirects$path <- file.path("_redirects", redirects$from)
purrr::walk2(redirects$html, redirects$path, writeLines)
