# Checks that every itemresponsewarehouse.org link in the lessons (vignettes,
# table landing pages) and in lessons.yml resolves. Needs the network, so it is
# run by hand, not during the render:
#   Rscript check_links.R
files <- Sys.glob("lessons/*.qmd")
found <- do.call(rbind, lapply(files, function(f) {
  x <- readLines(f, warn = FALSE)
  u <- unlist(regmatches(x, gregexpr("https?://(www\\.)?itemresponsewarehouse\\.org[^][ )\"'<>`]*", x)))
  if (length(u)) data.frame(url = sub("[.,;:]+$", "", u), file = basename(f))
}))
# lessons.yml names tables, not links; lesson_header() links each to its landing
# page, lowercased as it does there.
tabs <- unique(unlist(lapply(yaml::read_yaml("lessons.yml")$lessons, `[[`, "tables")))
if (length(tabs))
  found <- rbind(found, data.frame(url = sprintf("https://itemresponsewarehouse.org/tables/%s/", tolower(tabs)),
                                   file = "lessons.yml"))
urls <- sort(unique(found$url))
status <- vapply(urls, function(u) {
  s <- tryCatch(attr(curlGetHeaders(u), "status"), error = function(e) NA_integer_)
  as.integer(s)
}, 0L)
for (u in urls) cat(sprintf("%-4s %-70s %s\n", if (isTRUE(status[[u]] == 200)) "ok" else status[[u]],
                            u, paste(unique(found$file[found$url == u]), collapse = ", ")))
bad <- urls[!status %in% 200]
if (length(bad)) {
  cat("\n", length(bad), " link(s) that do not resolve: check the vignette or table name.\n", sep = "")
  quit(status = 1)
}
