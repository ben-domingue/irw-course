<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 23–41), PS1#3 and c1/irw_data_exploration.R. -->

# Item response data and the IRW (`irw-data`)

Module: foundations · Prereqs: none · Core · Status: outline

## Core ideas

1. **Item response data.** People (or other units) respond to probes; the data are the responses. Understanding the data is separate from judging the items or the construct, but never forget those.
2. **The IRW.** Open, harmonized item response data: over 1,000 tables, with metadata and, for many, item text; R and Python packages.
3. **The data standard.** Three essential columns (`id`, `item`, `resp`), with responses coded to be treated as ordinal. Data are stored long; extra columns (`rt`, `wave`, `treat`, `cov_*`) ride along. Why long? *(major)*
4. **Long to wide.** One row per person; missing cells; people with no responses. *(major)*
5. **A first look.** Missingness and categories per item; item means; the sum-score distribution; item–total correlations, and why each is worth computing. *(major)*
6. **Items aren't always questions.** Trials in a perception task, with response times; an RCT with treatment, waves and clusters; item text.

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

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `verbagg` | main example | Complete and dichotomous (316 × 24). Item means range from 0.09 (S3DoShout) to 0.79 (S2WantCurse): cursing is endorsed more than shouting, and "want" more than "do" (0.53 vs. 0.42). | — |
| `rr98_accuracy` | contrast | Items are conditions and each is answered many times (30 people, 33 conditions, 12,205 responses, with `rt`), so "one row per person" needs a decision about repeats. | candidate for `trials` (deliberate reuse as a thread?) |
| `gilbert_meta_56` | contrast | An RCT: `treat`, `wave`, `cluster_id` and covariates; 2,712 students and 4 items. Most children (2,307 of 2,712) appear in both waves, so a naive reshape mixes them. | — (`ctt-reliability` uses `gilbert_meta_1`) |

`chess_lnirt` moves out of this lesson (#12); it stays in `likelihood` and `rasch`.

## Widget / simulation / problem ideas

**Widgets**
- Long ↔ wide: click a row in the long table and see its cell in the wide one (ideas 3, 4).
- Missingness map: a person × item grid for a small table (idea 4).
- Match the histogram: four item-mean histograms, four tables (idea 5).

**Predict-then-check:** in verbagg, which is endorsed more, "I would want to curse" or "I would curse", and which verb is endorsed least? Answered by the item means.

**Simulate:** generate person × item responses where each person has a propensity (no model named yet), then again with none; compare item–total correlations. Item–total correlations are the first sign that items share something.

**Problems**
1. Derivation: the item–total correlation includes the item itself. Show how much that inflates it on a short test; compute the corrected version.
2. Real data with a twist (PS1#3a): take an IRW table with response times; for each item, compare mean RT for correct and incorrect responses. What complicates the inference?
3. Judgment: when is wide format the better store? What does long format make easy?
4. Design: you have your own dataset; map its columns to the IRW standard.
5. Real data (PS1#3c): pick a table and report the four descriptives plus one question they raise.
6. Challenge (open, PS1#3b): an item-text table; relate a feature of the wording to the item means.

## Go deeper

- None.

## Open questions

- Item text (#63): ideas 2 and 6 and problem 6 want item text. With a Redivis login it works (`irw_itemtext`); with no token it doesn't. Depends on #63.
- Access route: lessons read tokenless CSVs; the 252 code uses `irw::irw_fetch` (needs a Redivis login). Teach both, with the CSV as the default?
