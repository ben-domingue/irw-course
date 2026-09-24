# Psychometrics with the IRW (course in a box)

Stand-alone lessons on psychometrics built on Item Response Warehouse data, linked
by a course map. Teach the whole sequence or take single lessons. The material
grew out of EDUC 252 at Stanford (code: https://github.com/ben-domingue/252).
IRW roadmap item 15.2 (ben-domingue/irw#1717).

## Layout

- `lessons.yml`: the one source of truth for lessons, modules, prerequisites and paths.
- `index.qmd`: the course map, generated from `lessons.yml`. The render fails if
  the file is inconsistent (unknown prereq, cycle, missing page).
- `lessons/<id>.qmd`: one page per lesson. Its header box is generated from `lessons.yml`.
- `lessons/_course.R`: the helpers the map and the lessons share.
- `make_stubs.R`: creates a stub page for any lesson without one. It never overwrites.
- `source/`: gitignored. The raw 252 materials and a checkout of the 252 code.

Formatting is copied from the IRW site (`irw_site/_quarto.yml`, `scss/`,
`resources/scss/`) so that `lessons/`, `lessons.yml` and `index.qmd` can later move
into `irw_site/course/` unchanged.

## Render

    quarto render        # or: quarto preview

Rendering needs no Redivis credentials. Lessons that use data will follow the
IRW site's vignette pattern: a `<id>_compute.R` fetches the data once and caches
the results, and the page renders from that cache.
