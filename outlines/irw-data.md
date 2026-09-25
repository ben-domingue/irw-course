<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 23–41), PS1#3 and c1/irw_data_exploration.R. Tidied 09-24 (#62): Ben's answers A5, A7 and E4 applied; citations verified; five core ideas. -->

# Item response data and the IRW (`irw-data`)

Module: foundations · Prereqs: none · Preliminary · Status: draft (lessons/irw-data.qmd, #28)

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

Design columns (`treat`, `wave`, `cluster_id`) get a paragraph and a pointer forward, not a fourth table. Sanity: none (no model is fitted). All numbers above were recomputed in the draft (IRW v418) and hold; the draft adds that within brightness levels errors are slower at 22 of 33 levels by about 0.02 s, so most of the pooled 0.09 s gap is composition (errors fall at the slow, hard levels).

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

## Changes made while drafting (09-24, #28)

- **Widgets.** "Match the histogram" (four tables) was dropped: it would need a fourth table's data on the page. In its place, a keying widget (reverse-key simulated Likert items, watch item-rest correlations and the sum-score SD). The response-time widget is simulated (errors slow because of where they happen, not only how) rather than rr98's own distributions, which the real-data section plots instead. Long ↔ wide and the missingness map are as planned; the missingness map adds a booklet design and early stopping.
- **Predict-then-check** in *With real data* is the verbagg want/do question as planned; a second one in *Core ideas* is tied to the response-time widget.
- **Item text.** The Mini-IPIP item is quoted from the IPIP scoring key (ipip.ori.org), public domain; no snapshot was needed. verbagg's situations are described, not quoted: the IRW item-text notes record no open licence ("silence is permission").
- **Keying evidence.** The deposit's SPSS value labels describe the `R` items as 1 = strongly disagree … 5 = strongly agree, but the values are already reversed (all within-trait correlations positive, 0.18–0.59). The IRW item-text notes (batch_342) reach the same conclusion and record a Greek administration.
- **Data reading.** The real-data code defines `irw_csv_url()`/`irw_csv()` (as in `_course.R`) so the downloaded file runs standalone and reads the current version-pinned link.
- **Length.** Optional columns moved to a collapsible; the draft is at the top of the word range.


## Revisions from Ben's review of PR #125 (09-24)

- **Scope tour** added before *The data standard*: nine bullets, each linking a real IRW landing page (checked with check_links.R), described from its landing page, naming the lesson that uses it.
- **Missingness linked to real data**, verified in the CSVs (collapsible `missing-real` chunk): `cdm_timss11` (14 booklets, each item in two; 11,886 of 15,051 item pairs never answered together); `pirlsmissing_sirt` (blank rates 1% to 25% by item; 134 students whose second-passage blanks run to its end). `rapm_poulton_2022_timed` was checked and not used: time-limit hits are scored, not missing, and its missing rows are respondents not retested at wave 2. No adaptive-test table was verified.
- **Keying widget replaced**: six invented respondents on four public-domain Mini-IPIP Extraversion items (two reversed), one toggle; raw sums 12–14 and all item-rest r negative, keyed sums 6–18 and all positive.
- **"When are errors slow?" widget and its predict cut.** The aggregation point is two sentences in the `rr98_accuracy` section and is handed to `response-time` (Picks up updated there and in `rt-process-models`).
