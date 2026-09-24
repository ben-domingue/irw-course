<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 23–41), PS1#3 and c1/irw_data_exploration.R. -->

# Item response data and the IRW (`irw-data`)

Module: foundations · Prereqs: none · Core · Status: outline

## Core ideas

1. **Item response data.** People (or other units) respond to probes; the data are the responses. Understanding the data is separate from judging the items or the construct, but never forget those.
2. **The IRW.** Open, harmonized item response data: over 1,000 tables, with metadata and, for many, item text; R and Python packages.
3. **The data standard.** Three essential columns (`id`, `item`, `resp`), with responses coded to be treated as ordinal: dichotomous (0/1) or polytomous (e.g. a 1–5 Likert scale). Data are stored long; extra columns (`rt`, `wave`, `treat`, `cov_*`) ride along. Why long? *(major)*
4. **Long to wide.** One row per person; missing cells; people with no responses. *(major)*
5. **A first look.** Missingness and categories per item; item means; the sum-score distribution; item–total correlations, and why each is worth computing. The same descriptives read differently for 0/1 and for Likert responses (a mean is a proportion only for 0/1). *(major)*
6. **More than responses.** Many tables carry more than `resp`: response times (`rt`), design (`treat`, `wave`), covariates, and item text. Response time is the first example: how long someone took is data too. Items also aren't always questions: in a perception task they are conditions, repeated as trials.

## Picks up

- Probes, items and stimuli (from `measurement`; not a prerequisite, so restate in a line).

## Promises / leaves open

- Item means as difficulty → `ctt-reliability` (p-values), `rasch` (vs. b).
- Item–total correlations → `ctt-reliability` (item analysis), `1pl-to-4pl` (discrimination).
- The sum score → `ctt-reliability`, `ctt-limits`, `rasch` (sufficiency).
- Response times → `response-time`. Repeated trials → `trials`. Treatment and waves → `invariance-experience`. Covariates → `dif`, `explanatory-irt`. Item text → `explanatory-irt`, `ai-psychometrics`.
- Polytomous responses (ordinal coding) → `polytomous`.
- Missing responses by design → `equating`, `item-banks-cat`; otherwise unpaid.
- Finding tables by metadata (`irw_filter`) → deep dives (#18–26).
- Long format: one row per response, as `glm` wants → `likelihood`.
- Very fast responses as a sign of guessing → `guessing-priors`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `verbagg` | main example (dichotomous) | Complete and 0/1 (316 × 24). Item means range from 0.09 (S3DoShout) to 0.79 (S2WantCurse): cursing is endorsed more than shouting, and "want" more than "do" (0.53 vs. 0.42). | — |
| `manolika_2021_mini_ipip` | contrast (polytomous) | The Mini-IPIP: 20 items, 1–5 Likert, 386 people, with `cov_gender` and `cov_age`, and item text (IPIP items are public domain). Item means run from 3.0 to 4.5. Items marked `R` arrive already reverse-scored ("Am not really interested in others" averages 4.5), which is worth knowing before summing. | — |
| `rr98_accuracy` | contrast (response time) | A perception task with `rt` beside `resp`: 12,205 responses to 33 conditions, answered many times each. Errors are slower than correct responses (median 0.65 vs. 0.56 s). Repeated trials mean "one row per person" needs a decision. | candidate for `trials` (a thread?) |

Design columns (`treat`, `wave`, `cluster_id`) get a paragraph and a pointer to `gilbert_meta_1` in `ctt-reliability`, rather than a fourth table.

`chess_lnirt` moves out of this lesson (#12); it stays in `likelihood` and `rasch`.

## Widget / simulation / problem ideas

**Widgets**
- Long ↔ wide: click a row in the long table and see its cell in the wide one (ideas 3, 4).
- Missingness map: a person × item grid for a small table (idea 4).
- Match the histogram: four item-mean histograms, four tables (idea 5).
- Response time: rr98's RT distributions for correct and incorrect responses, overlaid (idea 6).

**Predict-then-check:** in verbagg, which is endorsed more, "I would want to curse" or "I would curse", and which verb is endorsed least? Answered by the item means.

**Simulate:** generate person × item responses where each person has a propensity (no model named yet), then again with none; compare item–total correlations. Item–total correlations are the first sign that items share something.

**Problems**
1. Derivation: the item–total correlation includes the item itself. Show how much that inflates it on a short test; compute the corrected version.
2. Real data with a twist (PS1#3a): take an IRW table with response times; for each item, compare mean RT for correct and incorrect responses. What complicates the inference?
3. Judgment: when is wide format the better store? What does long format make easy?
4. Design: you have your own Likert dataset with some reverse-worded items; map it to the IRW standard, and say how you record keying.
5. Real data (PS1#3c): pick a table and report the four descriptives plus one question they raise.
6. Challenge (open, PS1#3b): an item-text table; relate a feature of the wording to the item means.

## Go deeper

- None.

## Open questions

- Item text (#63): ideas 2 and 6 and problem 6 want item text. With a Redivis login it works (`irw_itemtext`); with no token it doesn't. The Mini-IPIP makes this easy: IPIP items are public domain. Depends on #63.
- Access route: lessons read tokenless CSVs; the 252 code uses `irw::irw_fetch` (needs a Redivis login). Teach both, with the CSV as the default?
