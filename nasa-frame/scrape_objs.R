library(tidyverse)
library(rvest)

# scrape all obj models from the NASA archive
model_listing <- read_html("https://nasa3d.arc.nasa.gov/models")
model_links <- html_nodes(model_listing, ".block-grid-item.block-grid-border>a")
for(link in model_links) {
  link %>% html_attr("href") %>%
    read_html() ->
    model_page
  btns <- html_nodes(model_page, ".asset-download button")
  for(btn in btns) {
    if(grepl("obj file", html_text(btn))) {
      btn %>% html_attr("onclick") %>%
        gsub("window\\.location='|'$", "", .) ->
        rel_link
      dest <- sub(".*/", "downloads/", rel_link)
      if(!file.exists(dest)) {
        download.file(paste0("https://nasa3d.arc.nasa.gov", rel_link),
                      dest, mode = "wb")
      }
    }
  }
}

# unzip files
for(f in list.files("downloads/")) {
  unzip(paste0("downloads/", f),
        overwrite = FALSE, exdir = "models")
}
