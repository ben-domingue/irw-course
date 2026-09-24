# Checks that every IRW table named in lessons.yml has a tokenless CSV on its
# landing page. Needs the network, so it is run by hand, not during the render:
#   Rscript check_tables.R
source("lessons/_course.R")
course <- read_course()
uses <- do.call(rbind, lapply(course$lessons, function(l)
  if (length(l$tables)) data.frame(table = unlist(l$tables), lesson = l$id)))
tabs <- sort(unique(uses$table))
url <- vapply(tabs, irw_csv_url, "")
for (t in tabs) cat(sprintf("%-24s %-4s %s\n", t, if (is.na(url[[t]])) "NO" else "ok",
                            paste(uses$lesson[uses$table == t], collapse = ", ")))
bad <- tabs[is.na(url)]
if (length(bad)) {
  cat("\n", length(bad), " table(s) without a tokenless CSV: over 100 MB (needs a teaching",
      " subsample table) or no landing page.\n", sep = "")
  quit(status = 1)
}
