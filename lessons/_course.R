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

# The citation for an IRW table, from IRW biblio as published in the schema.org
# record on its landing page: the reference, a link to the original source (the DOI,
# else a DOI inside the reference, else the "Source data" URL), and the licence.
# Needs the network, so lessons never call it: check_tables.R caches the results in
# lessons/_citations.yml, and data_sources() reads that cache.
irw_citation <- function(table) {
  page <- tryCatch(paste(readLines(paste0(TABLE_BASE, tolower(table), "/"), warn = FALSE),
                         collapse = "\n"), error = function(e) "")
  ld <- regmatches(page, regexpr('(?s)<script type="application/ld\\+json">.*?</script>', page, perl = TRUE))
  if (!length(ld)) return(NULL)
  meta <- jsonlite::fromJSON(gsub("</?script[^>]*>", "", ld))
  or_na <- function(x) if (length(x)) x else NA_character_
  ref <- trimws(gsub("\\s*\n+\\s*", " ", or_na(meta$creditText)))
  src <- regmatches(page, regexec("<th>Source data</th><td>(?:<a[^>]*>)?(https?://[^<\"]+)", page, perl = TRUE))[[1]][2]
  doi <- regmatches(ref, regexpr("https://doi\\.org/[^ ]+[^ .,;)]", ref))
  list(reference = if (!is.na(ref) && nzchar(ref)) ref else NA_character_,
       # First candidate that is a real URL: the IRW metadata sometimes holds
       # "https://doi.org/No DOI" (09-25, Forthmann-2024-cleverness_ratings).
       link = or_na(Filter(function(u) grepl("^https?://[^ ]+$", u) && !grepl("No%20DOI|NoDOI", u, ignore.case = TRUE),
                           na.omit(c(meta$citation, doi, src)))[1]),
       license = or_na(meta$license),
       irw_version = or_na(meta$version))
}

CITATIONS <- file.path(.course_dir, "lessons", "_citations.yml")

# The Data sources block that closes a lesson: every table the lesson lists in
# lessons.yml, cited from the cache and linked to its IRW landing page. A table
# missing from the cache stops the render, so a citation cannot be forgotten; in a
# stub, whose tables are only planned, it is shown as missing instead.
# Emit with `#| output: asis`, just before "For instructors".
data_sources <- function(id) {
  l <- lesson_by_id(id)
  tables <- unlist(l$tables)
  if (!length(tables)) return(invisible())
  cites <- if (file.exists(CITATIONS)) yaml::read_yaml(CITATIONS) else list()
  missing <- setdiff(tables, names(cites))
  if (length(missing) && l$status != "stub")
    stop("no citation cached for ", paste(missing, collapse = ", "),
         ": run Rscript check_tables.R from course/")
  items <- vapply(tables, function(t) {
    c <- cites[[t]]
    if (is.null(c)) return(sprintf("- `%s`: *citation missing (no IRW landing page found).*", t))
    ref <- if (is.na(c$reference)) "No reference recorded in IRW biblio." else
      gsub("(https?://[^ ]*[^ .,;)])", "<\\1>", c$reference)
    # Skip the link when the reference already carries it (a DOI, over http or https).
    key <- sub("^https?://(dx\\.)?", "", c$link)
    link <- if (!is.na(c$link) && !grepl(key, ref, fixed = TRUE)) paste0(" <", c$link, ">.") else ""
    lic <- if (is.na(c$license)) "" else paste0(" Licence: ", c$license, ".")
    sprintf("- [`%s`](%s%s/): %s%s%s", t, TABLE_BASE, tolower(t), sub("\\.?$", ".", ref), link, lic)
  }, "")
  cat("## Data sources\n\n",
      "Data from the [Item Response Warehouse](https://itemresponsewarehouse.org) ",
      "(each table name links to its IRW page); references from IRW biblio.\n\n",
      paste(items, collapse = "\n"), "\n\n", sep = "")
}

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
  # Tranches (Ben, 09-24): a lesson may not require one from a later tranche.
  tranches <- c("preliminary", "core", "extension")
  tr <- setNames(vapply(course$lessons, function(l) if (is.null(l$tranche)) NA_character_ else l$tranche, ""), ids)
  for (id in ids[!tr %in% tranches])
    problems <- c(problems, sprintf("%s: tranche must be one of %s", id, paste(tranches, collapse = ", ")))
  rank <- setNames(match(tr, tranches), ids)
  for (l in course$lessons) for (p in intersect(unlist(l$prereqs), ids))
    if (isTRUE(rank[[p]] > rank[[l$id]]))
      problems <- c(problems, sprintf("%s (%s) requires '%s' (%s), from a later tranche", l$id, tr[[l$id]], p, tr[[p]]))
  for (p in course$paths) {
    bad <- setdiff(unlist(p$lessons), ids)
    if (length(bad))
      problems <- c(problems, sprintf("path %s: unknown lesson '%s'", p$id, bad))
  }
  # Paths: a lesson never comes before one of its prerequisites that is in the
  # same path (prerequisites outside the path are the teacher's call).
  pre_of <- setNames(lapply(course$lessons, function(l) unlist(l$prereqs)), ids)
  for (p in course$paths) {
    ord <- unlist(p$lessons)
    for (i in seq_along(ord)) for (q in intersect(pre_of[[ord[i]]], ord))
      if (match(q, ord) > i)
        problems <- c(problems, sprintf("path %s: '%s' comes before its prerequisite '%s'", p$id, ord[i], q))
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
  # Threads: each names lessons that exist, and never returns to the lesson that
  # introduces it or to one of that lesson's prerequisites (direct or indirect).
  ancestors <- function(id, seen = character()) {
    for (p in setdiff(pre[[id]], seen)) seen <- ancestors(p, c(seen, p))
    seen
  }
  tids <- vapply(course$threads, function(t) if (length(t$id)) t$id else "", "")
  dup <- unique(tids[duplicated(tids)])
  if (length(dup)) problems <- c(problems, paste("duplicate thread id:", dup))
  for (t in course$threads) {
    miss <- setdiff(c("id", "idea", "introduced", "returns"), names(t))
    if (length(miss)) {
      problems <- c(problems, sprintf("thread %s: missing %s", t$id %||% "?", paste(miss, collapse = ", ")))
      next
    }
    back <- vapply(t$returns, function(r) if (length(r$lesson)) r$lesson else "", "")
    bad <- setdiff(c(t$introduced, back), ids)
    if (length(bad))
      problems <- c(problems, sprintf("thread %s: unknown lesson '%s'", t$id, bad))
    for (r in t$returns) if (!length(r$how))
      problems <- c(problems, sprintf("thread %s: return to %s has no `how`", t$id, r$lesson))
    if (t$introduced %in% ids && !length(setdiff(ids, done))) {
      early <- intersect(back, c(t$introduced, ancestors(t$introduced)))
      if (length(early))
        problems <- c(problems, sprintf("thread %s: returns to %s, which comes before %s (where it is introduced)",
                                        t$id, early, t$introduced))
    }
  }
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
  # Threads this lesson starts (and where each goes next), and threads it picks up
  # (and where each began). A row appears only when the lesson has such threads.
  starts <- vapply(Filter(function(t) t$introduced == id, course$threads), function(t)
    paste0(t$idea, " (→ ", links(vapply(t$returns, `[[`, "", "lesson")), ")"), "")
  picks <- vapply(Filter(function(t) id %in% vapply(t$returns, `[[`, "", "lesson"), course$threads),
                  function(t) paste0(t$idea, " (from ", links(t$introduced), ")"), "")
  thread_rows <- c(
    if (length(starts)) paste0("**Starts threads:** ", paste(starts, collapse = "; "), "  \n"),
    if (length(picks)) paste0("**Picks up threads:** ", paste(picks, collapse = "; "), "  \n"))
  code <- unlist(l$origin$code)
  origin <- c(
    if (length(l$origin$slides)) paste("slides", paste(unlist(l$origin$slides), collapse = ", ")),
    if (length(l$origin$ps)) paste("problem sets", paste(unlist(l$origin$ps), collapse = ", ")),
    if (length(code)) paste("code", paste(sprintf("[`%s`](%s%s)", code, CODE_BASE, code), collapse = ", "))
  )
  cat(
    "::: {.callout-note appearance=\"simple\"}\n",
    "**Module:** ", mod, "  \n",
    "**Tranche:** ", switch(l$tranche, preliminary = "preliminary (sets up the course)", core = "core (a first course)", extension = "extension (beyond a first course)"), "  \n",
    "**Before this:** ", links(unlist(l$prereqs)), "  \n",
    "**Builds toward:** ", links(next_ids), "  \n",
    thread_rows,
    "**IRW tables:** ", tables_md, "  \n",
    "**From EDUC 252:** ", if (length(origin)) paste(origin, collapse = "; ") else "n/a", "  \n",
    "**Status:** ", l$status, "  \n",
    # Authorship note on every lesson (#70).
    "**Authorship:** Written largely by Claude (Anthropic), from Ben Domingue's EDUC 252 ",
    "materials and under Ben's direction. Ben reviews each lesson before it is marked done.\n",
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
    "opens a new conversation that already knows what the lesson is about; add your question at the end. ",
    "Claude shows a caution notice on any prompt that arrives through a link; that's expected.\n",
    ":::\n\n", sep = ""
  )
}
