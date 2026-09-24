# Shared helpers for the course map (index.qmd) and every lesson page.
# Everything reads ../lessons.yml: lesson metadata lives there and nowhere else.
# Quarto runs each page's chunks from that page's own directory, so the path is
# resolved relative to this file's location instead of the working directory.

.course_dir <- local({
  here <- if (file.exists("lessons.yml")) "." else ".."
  normalizePath(here)
})

# knitr treats ```{webr} cells as its own chunks: it strips their `#|` options
# (so `context: setup` is lost) and drops them entirely under echo: false. This
# engine hands each cell back untouched, as a fenced block that the quarto-webr
# filter then turns into an in-browser cell. Every lesson sources this file in its
# first chunk, before any webr cell.
local({
  webr_opts <- c("context", "autorun", "read-only", "include", "output", "warning",
                 "message", "results", "fig-width", "fig-height", "timelimit", "classes", "label")
  knitr::knit_engines$set(webr = function(options) {
    opts <- options[intersect(names(options), webr_opts)]
    opts <- opts[!vapply(opts, is.null, TRUE)]
    head <- if (length(opts)) paste0("#| ", names(opts), ": ",
      vapply(opts, function(v) if (is.logical(v)) tolower(as.character(v)) else as.character(v), ""))
    paste(c("```{webr}", head, options$code, "```"), collapse = "\n")
  })
})

CODE_BASE  <- "https://github.com/ben-domingue/252/blob/main/"
TABLE_BASE <- "https://itemresponsewarehouse.org/tables/"

# The tokenless CSV for an IRW table, as linked from its landing page. Lessons use
# only tables that have one (no Redivis token needed). Redivis serves anonymous CSVs
# only under 100 MB, so a larger table has no link and gets a teaching subsample
# published as its own IRW table instead. The URL is version-pinned, and the shard
# and version differ by table, so it is read off the page, never built by hand.
irw_csv_url <- function(table) {
  page <- tryCatch(readLines(paste0(TABLE_BASE, tolower(table), "/"), warn = FALSE),
                   error = function(e) character())
  hit <- regmatches(page, regexpr('https://redivis\\.com/api/v1/tables/[^"]+format=csv', page))
  if (length(hit)) hit[[1]] else NA_character_
}

irw_csv <- function(table) utils::read.csv(irw_csv_url(table))

read_course <- function() {
  yaml::read_yaml(file.path(.course_dir, "lessons.yml"))
}

# Stops the render if lessons.yml is inconsistent: duplicate ids, unknown modules,
# prereqs or path entries naming a lesson that does not exist, a prerequisite
# cycle, or a lesson with no page. Called from index.qmd, so a broken map fails
# loudly instead of drawing dangling arrows.
check_course <- function(course = read_course()) {
  ids  <- vapply(course$lessons, `[[`, "", "id")
  mods <- vapply(course$modules, `[[`, "", "id")
  problems <- character()
  dup <- unique(ids[duplicated(ids)])
  if (length(dup)) problems <- c(problems, paste("duplicate lesson id:", dup))
  for (l in course$lessons) {
    if (!l$module %in% mods)
      problems <- c(problems, sprintf("%s: unknown module '%s'", l$id, l$module))
    bad <- setdiff(unlist(l$prereqs), ids)
    if (length(bad))
      problems <- c(problems, sprintf("%s: unknown prereq '%s'", l$id, bad))
    page <- file.path(.course_dir, "lessons", paste0(l$id, ".qmd"))
    if (!file.exists(page))
      problems <- c(problems, sprintf("%s: no page at lessons/%s.qmd", l$id, l$id))
  }
  opt <- ids[vapply(course$lessons, function(l) isTRUE(l$optional), TRUE)]
  for (l in course$lessons) if (!isTRUE(l$optional)) {
    bad <- intersect(unlist(l$prereqs), opt)
    if (length(bad))
      problems <- c(problems, sprintf("%s: core lesson requires optional '%s'", l$id, bad))
  }
  for (p in course$paths) {
    bad <- setdiff(unlist(p$lessons), ids)
    if (length(bad))
      problems <- c(problems, sprintf("path %s: unknown lesson '%s'", p$id, bad))
  }
  # Cycle check: repeatedly peel off lessons whose prereqs are all peeled.
  pre <- setNames(lapply(course$lessons, function(l) unlist(l$prereqs)), ids)
  done <- character()
  repeat {
    ready <- setdiff(names(pre)[vapply(pre, function(p) all(p %in% done), TRUE)], done)
    if (!length(ready)) break
    done <- c(done, ready)
  }
  if (length(setdiff(ids, done)))
    problems <- c(problems, paste("prerequisite cycle among:",
                                  paste(setdiff(ids, done), collapse = ", ")))
  if (length(problems)) stop("lessons.yml:\n  ", paste(problems, collapse = "\n  "))
  invisible(TRUE)
}

lesson_by_id <- function(id, course = read_course()) {
  hit <- Filter(function(l) l$id == id, course$lessons)
  if (!length(hit)) stop("no lesson '", id, "' in lessons.yml")
  hit[[1]]
}

# `from` is where the link is written: "lessons" for a lesson page, "root" for index.qmd.
lesson_link <- function(l, from = "lessons") {
  href <- if (from == "lessons") paste0(l$id, ".qmd") else paste0("lessons/", l$id, ".qmd")
  sprintf("[%s](%s)", l$title, href)
}

# The box at the top of every lesson: module, prerequisites, what builds on it,
# IRW tables, and where the material came from in EDUC 252. Emit with
# `#| output: asis`.
lesson_header <- function(id) {
  course <- read_course()
  l <- lesson_by_id(id, course)
  mod <- Filter(function(m) m$id == l$module, course$modules)[[1]]$title
  links <- function(ids) {
    if (!length(ids)) return("none")
    paste(vapply(ids, function(i) lesson_link(lesson_by_id(i, course)), ""), collapse = " · ")
  }
  next_ids <- vapply(Filter(function(x) l$id %in% unlist(x$prereqs), course$lessons),
                     `[[`, "", "id")
  tables <- unlist(l$tables)
  tables_md <- if (length(tables))
    paste(sprintf("[`%s`](%s%s/)", tables, TABLE_BASE, tolower(tables)), collapse = ", ")
  else "none"
  code <- unlist(l$origin$code)
  origin <- c(
    if (length(l$origin$slides)) paste("slides", paste(unlist(l$origin$slides), collapse = ", ")),
    if (length(l$origin$ps)) paste("problem sets", paste(unlist(l$origin$ps), collapse = ", ")),
    if (length(code)) paste("code", paste(sprintf("[`%s`](%s%s)", code, CODE_BASE, code), collapse = ", "))
  )
  cat(
    "::: {.callout-note appearance=\"simple\"}\n",
    "**Module:** ", mod, if (isTRUE(l$optional)) " (optional: beyond a first course)", "  \n",
    "**Before this:** ", links(unlist(l$prereqs)), "  \n",
    "**Builds toward:** ", links(next_ids), "  \n",
    "**IRW tables:** ", tables_md, "  \n",
    "**From EDUC 252:** ", if (length(origin)) paste(origin, collapse = "; ") else "n/a", "  \n",
    "**Status:** ", l$status, "\n",
    ":::\n\n", sep = ""
  )
}

# "Ask Claude about this lesson": a button that opens Claude with a prompt
# carrying the lesson's topic, so a reader can ask questions without leaving
# with nothing. No backend: it is a link (https://claude.ai/new?q=...). `about`
# is one or two sentences on what the lesson covers. Emit with `#| output: asis`.
ask_claude <- function(id, about) {
  l <- lesson_by_id(id)
  prompt <- paste0(
    "I'm working through a lesson called \"", l$title, "\" in an open psychometrics ",
    "course built on the Item Response Warehouse (IRW). ", about, " ",
    "Please act as a patient tutor: answer my questions, check my reasoning, and ",
    "prefer small worked examples in R. If data would help, IRW tables are ",
    "described at https://itemresponsewarehouse.org/llms.txt. My first question is: "
  )
  href <- paste0("https://claude.ai/new?q=", utils::URLencode(prompt, reserved = TRUE))
  cat(
    "::: {.callout-tip appearance=\"simple\" icon=\"false\"}\n",
    "**Stuck, or curious about something this lesson doesn't cover?** ",
    "[Ask Claude about this lesson](", href, "){target=\"_blank\" .btn .btn-outline-primary .btn-sm} ",
    "opens a new conversation that already knows what the lesson is about; add your question at the end.\n",
    ":::\n\n", sep = ""
  )
}
