<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 23–41), PS1#3 and c1/irw_data_exploration.R. Tidied 09-24 (#62): Ben's answers A5, A7 and E4 applied; citations verified; five core ideas. -->

# Item response data and the IRW (`irw-data`)

Module: foundations · Prereqs: none · Preliminary · Status: outline

## Core ideas

References verified 09-24 against Crossref; table citations from IRW biblio (landing pages).

1. **Item response data, and the IRW.** Respondents (or other units) respond to items; the data are the responses. Understanding the data is separate from judging the items or the construct, but never forget those. The IRW is open, harmonized item response data: over 1,000 tables, with metadata and, for many, item text; R and Python packages (Domingue et al., 2025, *Behavior Research Methods* 57(10), 276, doi:10.3758/s13428-025-02796-y).
2. **The data standard.** *(major)* Three essential columns (`id`, `item`, `resp`), with responses coded to be treated as ordinal: dichotomous (0/1) or polytomous (e.g. a 1–5 Likert scale). Data are stored long, one row per response; extra columns (`rt`, `wave`, `treat`, `cov_*`) ride along. Why long? Tidy data, one observation per row (Wickham, 2014, *Journal of Statistical Software* 59(10), doi:10.18637/jss.v059.i10).
3. **Long to wide, and how lessons read data.** *(major)* One row per respondent; missing cells; respondents with no responses (drop them). Every lesson reads the tokenless CSV with `irw_csv()` from `_course.R`, so no login is needed (digest A7); `irw::irw_fetch()` goes in *Going further* for readers with a Redivis login.
4. **A first look.** *(major)* Missingness and categories per item; item means; the sum-score distribution; item-rest correlations (the item against the sum of the other items; notes/notation.md), and why each is worth computing. The same descriptives read differently for 0/1 and for Likert responses (a mean is a proportion only for 0/1). State the keying once: higher = more of the construct.
5. **More than responses.** Many tables carry more than `resp`: response times (`rt`), design (`treat`, `wave`), covariates and item text. Response time is the worked example: how long someone took is data too. Items also aren't always questions: in a perception task they are conditions, repeated as trials (Ratcliff & Rouder, 1998).

## Picks up

- Probes, items and stimuli (from `measurement`; not a prerequisite, so an "if you've done `measurement`" line that restates it, per E2).

## Promises / leaves open

- Long format: one row per response, as `glm` wants → `likelihood`.
- Item means as difficulty → `ctt-reliability` (p-values), `rasch` (vs. b).
- Item-rest correlations and sum scores → `ctt-reliability` (item analysis), `1pl-to-4pl` (discrimination), `score-meaning`.
- The sum score → `ctt-reliability`, `ctt-limits`, `rasch` (sufficiency).
- Keying: the Mini-IPIP's already-reversed items → `ctt-reliability`.
- Polytomous responses (ordinal coding) → `polytomous`.
- Response times → `response-time`, `guessing-priors` (very fast responses as a sign of guessing); errors slower than correct in `rr98_accuracy` → `rt-process-models`.
- Repeated trials → `trials` (reuses `rr98_accuracy`, recorded).
- Treatment and waves → `invariance-experience`. Covariates → `dif`, `explanatory-irt`.
- Item text → `explanatory-irt` (verbagg's want/do pattern, modelled there; reuse recorded), `ai-psychometrics`.
- Missing responses by design → `equating`, `item-banks-cat`.
- Finding tables by metadata (`irw_filter`) → the deep dives (#18–26).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `verbagg` | main example (dichotomous) | Verbal aggression (De Boeck & Wilson, 2004, *Explanatory Item Response Models*, Springer, doi:10.1007/978-1-4757-3990-9). Complete and 0/1 (316 × 24). Item means range from 0.09 (S3DoShout) to 0.79 (S2WantCurse): cursing is endorsed more than shouting, and "want" more than "do" (0.53 vs. 0.42). | `explanatory-irt` (deliberate, recorded) |
| `manolika_2021_mini_ipip` | contrast (polytomous) | The Mini-IPIP (Donnellan et al., 2006, *Psychological Assessment* 18(2), 192–203, doi:10.1037/1040-3590.18.2.192; data: Manolika, 2021, Harvard Dataverse, doi:10.7910/DVN/23NDKX, CC0): 20 items, 1–5, 386 respondents, with `cov_gender` and `cov_age`. Item means run from 3.0 to 4.5. Items marked `R` arrive already reverse-scored ("Am not really interested in others" averages 4.5), which is worth knowing before summing. IPIP items are public domain (Goldberg et al., 2006, *Journal of Research in Personality* 40(1), 84–96, doi:10.1016/j.jrp.2005.08.007), so the lesson shows their text (A5). | — |
| `rr98_accuracy` | contrast (response time) | A brightness-discrimination task with `rt` beside `resp` (Ratcliff & Rouder, 1998, *Psychological Science* 9(5), 347–356, doi:10.1111/1467-9280.00067): 12,205 responses to 33 conditions, each answered many times. Errors are slower than correct responses (median 0.65 vs. 0.56 s). Repeated trials mean "one row per respondent" needs a decision. | `trials` (deliberate, recorded); sanity in `response-time`, `rt-process-models` |

Design columns (`treat`, `wave`, `cluster_id`) get a paragraph and a pointer forward, not a fourth table. Numbers are from the 09-24 outline pass (not recomputed). Sanity: none (no model is fitted).

## Widget / simulation / problem ideas

**Widgets**
- Long ↔ wide: click a row in the long table and see its cell in the wide one (ideas 2, 3).
- Missingness map: a respondent × item grid for a small table (idea 3).
- Match the histogram: four item-mean histograms, four tables (idea 4).
- Response time: rr98's RT distributions for correct and incorrect responses, overlaid (idea 5).

**Predict-then-check:** in verbagg, which is endorsed more, "I would want to curse" or "I would curse", and which verb is endorsed least? Answered by the item means.

**Simulate:** generate respondent × item responses where each respondent has a propensity (no model named yet), then again with none; compare item-rest correlations. They are the first sign that items share something.

**Problems**
1. Derivation: the item-total correlation includes the item itself. Show how much that inflates it on a short test, and compare the item-rest correlation.
2. Real data with a twist (PS1#3a): in `rr98_accuracy` or another table with response times, compare mean RT for correct and incorrect responses by item. What complicates the inference?
3. Judgment: when is wide format the better store? What does long format make easy?
4. Design: map your own Likert dataset with some reverse-worded items to the IRW standard, and say how you record keying.
5. Real data (PS1#3c): pick a table and report the four descriptives plus one question they raise.
6. Challenge (open, PS1#3b): with the Mini-IPIP item text, relate a feature of the wording (length, negation) to the item means.

## Go deeper

- None.

## Open questions

- None. Item text follows A5 (#63): the Mini-IPIP text is public domain and is shown from the course's item-text snapshot with its provenance manifest; `verbagg`'s situations are described, not quoted, unless the snapshot confirms their licence.
