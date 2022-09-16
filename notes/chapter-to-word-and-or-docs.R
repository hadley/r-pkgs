# meant for interactive use!

# experiment in turning individual chapters into Word documents and, perhaps,
# even uploading as Google docs

# thanks to Tom Mock for tips on best way to do this

# goal is to produce something with a commenting workflow that works pretty well
# for both Sara (editor from O'Reilly) and Jenny

# our first attempt at this was with PDF and adobe tools

# the relevant adobe app was a frustrating spinning beachball of death
# experience on jenny's end, hence the current experiment

library(fs)
library(withr)

temp_file_render <- function(file) {
  
  my_temp_dir <- local_tempdir("r-pkgs-surgery-")

  # get the docx name for later
  file_out <- path_ext_set(file, ".docx")

  # get the file in and out in temp dir
  tmp_file_path <- path(my_temp_dir, file)
  tmp_file_out_path <- path(my_temp_dir, file_out)

  # copy existing file to temp folder for rendering 
  # quarto will render in that tempdir
  file_copy(file, new_path = tmp_file_path)
  
  # copy common.R
  if (file_exists("common.R")) {
    file_copy("common.R", new_path = my_temp_dir)
  }

  # quarto render it, but to the temp file
  # with format = docx
  quarto::quarto_render(
    input = tmp_file_path,
    output_format = "docx", 
    output_file = tmp_file_out_path
  )

  # copy it back out to your project dir
  # out of the temp file
  file_copy(tmp_file_out_path, new_path = ".", overwrite = TRUE)
}

temp_file_render("license.Rmd")
# to render the 3 documents below, I had to upgrade Quarto to get a version
# that has the fix for this:
# https://github.com/quarto-dev/quarto-cli/issues/2027
temp_file_render("testing-basics.Rmd")
temp_file_render("testing-design.Rmd")
temp_file_render("testing-advanced.Rmd")

library(googledrive)

drive_auth(email = "jenny.f.bryan@gmail.com")

my_dir <- drive_mkdir("r-pkgs-for-sara-hunter")

drive_upload("license.docx", path = my_dir, type = "document")
drive_upload("testing-basics.docx", path = my_dir, type = "document")
drive_upload("testing-design.docx", path = my_dir, type = "document")
drive_upload("testing-advanced.docx", path = my_dir, type = "document")

drive_browse(my_dir)

drive_share_anyone(my_dir)

# replace the email placeholders below
drive_share(
  my_dir,
  role = "writer",
  type = "user",
  email_address = "bob@example.com" # hadley
)

drive_share(
  my_dir,
  role = "commenter",
  type = "user",
  email_address = "alice@example.com" # sara
)
