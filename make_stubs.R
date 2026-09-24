# Creates lessons/<id>.qmd for every lesson in lessons.yml that has no page yet.
# Never overwrites an existing page. Run from course/: Rscript make_stubs.R
course <- yaml::read_yaml("lessons.yml")
for (l in course$lessons) {
  path <- file.path("lessons", paste0(l$id, ".qmd"))
  if (file.exists(path)) next
  writeLines(c(
    "---",
    sprintf("title: %s", deparse(l$title)),
    "---",
    "",
    "```{r}",
    "#| output: asis",
    "source(\"_course.R\")",
    sprintf("lesson_header(\"%s\")", l$id),
    "```",
    "",
    "## What this is for",
    "",
    "*To be written.*",
    "",
    "## Goals",
    "",
    "## Core ideas",
    "",
    "## Worked example",
    "",
    "## Problems",
    "",
    "## Going further",
    "",
    "```{r}",
    "#| output: asis",
    sprintf("data_sources(\"%s\")", l$id),
    "```",
    "",
    "## For instructors",
    ""
  ), path)
  message("created ", path)
}
