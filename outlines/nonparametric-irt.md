<!-- Outlined 2026-09-28 from #153 (approved by Ben 09-28). No EDUC 252 slide source. Numbers are preliminary, from CSVs fetched at IRW v64 (scratch analysis, mokken 3.1.2, mirt 1.46.1, KernSmoothIRT 6.6). -->

# Nonparametric IRT: Mokken scaling (`nonparametric-irt`)

Module: irt · Prereqs: ctt-limits, rasch · Extension · Status: stub (outlined)

## Core ideas

1. **The monotone homogeneity model (MHM): the Rasch model's assumptions without its curve.** One latent variable, local independence, and item curves that never fall, with no formula for their shape. What it buys: every pair of items covaries non-negatively, and the sum score orders respondents on θ (stochastically), with no need for sufficiency. *(major)* Sources: Mokken (1971), doi:10.1515/9783110813203; Holland & Rosenbaum (1986), doi:10.1214/aos/1176350174; Grayson (1988), doi:10.1007/BF02294219; Hemker, Sijtsma, Molenaar & Junker (1997), doi:10.1007/BF02294555 (the ordering can fail for polytomous items; one sentence); Sijtsma & Molenaar (2002), doi:10.4135/9781412984676; Sijtsma & Molenaar (2016), "Mokken models", *Handbook of IRT*, Vol. 1, doi:10.1201/9781315374512 (volume DOI; Crossref has no chapter DOI; pp. 303–321 as cited in `ctt-limits`, not rechecked).
2. **Scalability: Loevinger's H for a pair, an item and a scale.** $H_{ij}$ is the covariance of two items over the largest covariance their p-values allow; equivalently, one minus observed over expected Guttman errors. $H_i$ and $H$ pool these. Mokken's conventions (weak 0.3, medium 0.4, strong 0.5) are stated as conventions, not tests. *(major)* Sources: Loevinger (1948), doi:10.1037/h0055827; Guttman (1944), doi:10.2307/2086306; Mokken (1971); van der Ark (2007), `mokken`, doi:10.18637/jss.v020.i11.
3. **Automated item selection (AISP).** Build scales bottom-up: start from the most scalable pair, add items while every $H_i$ stays above a bound $c$; raise $c$ and scales split. A reasonable first look at a pool whose structure isn't known; it groups items and says nothing about why. Sources: Mokken (1971); van der Ark (2012), doi:10.18637/jss.v048.i05; Straat, van der Ark & Sijtsma (2013), doi:10.1007/s00357-013-9122-y (the genetic-algorithm alternative); Sijtsma & van der Ark (2017), doi:10.1111/bmsp.12078 (tutorial).
4. **Checking monotonicity in rest-score groups.** Group respondents by the rest score (pooled to a minimum group size), plot each item's proportion, and count significant decreases. The rest score, not the sum score, because the sum score contains the item. *(major)* Sources: Junker & Sijtsma (2001), doi:10.1177/01466210122032028; van der Ark (2007); Sijtsma & Molenaar (2002, ch. 5).
5. **Double monotonicity and invariant item ordering (IIO).** Add "curves don't cross" and every respondent finds the items in the same order: the ordinal content of specific objectivity. The Rasch model implies it; the 2PL generally doesn't. Checked with `check.iio` and $H^T$. Sources: Sijtsma & Junker (1996), doi:10.1111/j.2044-8317.1996.tb01076.x; Ligtvoet, van der Ark, te Marvelde & Sijtsma (2010), doi:10.1177/0013164409355697.
6. **Kernel-smoothed item curves, and where they part from a parametric curve.** Nadaraya–Watson smoothing of responses against rank-based θ (Ramsay); bandwidth trades noise for bias; the smoothed curve is a check on a fitted logistic curve, not a replacement for one. *(major)* Sources: Ramsay (1991), doi:10.1007/BF02294494; Mazza, Punzo & McGuire (2014), `KernSmoothIRT`, doi:10.18637/jss.v058.i06; Douglas & Cohen (2001), doi:10.1177/01466210122032046. Bayesian order-constrained alternative, *Going further* only: Karabatsos & Sheu (2004), doi:10.1177/0146621603260678.

**Verdict (proposed, soft and impersonal):** in the case that the claim is only that the sum score orders respondents, a Mokken scale (H of at least 0.3 and no significant monotonicity violations) may be sufficient for some purposes, and it asks less of the data than a Rasch model. A parametric model earns its place when items are compared across forms or groups, or when precision at a point on the scale matters. A claim that items come in a fixed order is a separate claim (IIO) and needs its own check.

All articles and books above checked on Crossref (09-28, no mailto). Mokken (1971) and Sijtsma & Molenaar (2002) are books with DOIs.

## Picks up

- Item curves against the sum score; "estimating these curves directly, without a model for their shape, is the business of nonparametric IRT" (Mokken, Ramsay, Sijtsma & Molenaar are already cited there); the rest score in problem 3; the challenge (problem 6) asks what else could go on the x-axis (from `ctt-limits`). Threads `items-rise-with-score` and `sum-score-part-whole`.
- Items that don't rise: DONTBELIEV and WISHNOTNEC in `andrich_mudfold` (from `ctt-limits`); recalled, not reloaded.
- The ICC; unidimensionality and local independence as the model's two assumptions (from `rasch`). Thread `local-independence`.
- Specific objectivity as non-crossing curves ("do the curves cross?" widget) (from `rasch`). Thread `specific-objectivity`.
- The sum score is sufficient under the Rasch model (from `rasch`). Optional thread return: `sum-score-sufficiency` (the MHM keeps only the ordering).
- The observed vs. Rasch-implied $\Pr(x_i = 1 \mid r)$ table for `wirs`, whose item 1 rises then falls (from `rasch`): the same comparison, now with no model on one side.
- The slope slider in `rasch` previews the 2PL, which this lesson uses as its parametric comparison in one sentence; "if you've done `1pl-to-4pl`" Recall (E2) for readers who have.
- Levels of measurement; an ordinal scale (from `measurement`, an ancestor). Optional thread return: `equal-unit` (a Mokken scale licenses order, not a unit).
- Logistic regression of an item on the sum score (from `ctt-limits`, `likelihood`).

## Promises / leaves open

- Curves that peak by design; MUDFOLD's H as Loevinger's H with unfolding's errors → `unfolding`. Not a descendant, so an "if you've done" pointer each way (E2), not a thread. Proposed: at the next cross-check, `unfolding`'s MUDFOLD paragraph (line 213) adds a link here.
- Polytomous items: item-step curves, and the sum score's ordering that can fail → `polytomous` (not a descendant; unpaid as a thread; a sentence here).
- Rater-nested data (pupils within classes): two-level scalability (Koopman, Zijlstra & van der Ark, 2020, doi:10.1111/bmsp.12174) → `rater-models` could pick it up; unpaid.
- The balance-scale items look like classes, not a continuum (strategies) → `constructs`' `classes-vs-continuum` thread is an ancestor idea; a Recall, and latent-class models stay unpaid.
- How scalable are IRW scales? H across the corpus → unpaid (a possible vignette).
- A formal test of a parametric curve against the kernel curve (Douglas & Cohen, 2001) → `fit-prediction` is not a descendant; unpaid, challenge problem.
- Starts no thread: nothing downstream yet.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `mcmi_mokken` | main example | Dutch MCMI-III, 44 true/false items, 1,208 patients and inmates, complete (Rossi, Elklit & Simonsen, 2010, doi:10.1521/pedi.2010.24.1.128, from IRW biblio; subset from de la Torre, van der Ark & Rossi, 2018, doi:10.1080/07481756.2017.1327286). Scale $H$ = 0.42 (medium); $H_i$ 0.25–0.60; $H_{ij}$ 0.10–0.85. AISP at $c$ = 0.3: 41 items in one scale, 3 unscalable; at 0.4, 33 + 3 + 2 (6 out); at 0.5, eight small scales. Rest-score check: **no** violations in any item. IIO: $H^T$ = 0.25; backward selection drops 22 items and leaves $H^T$ = 0.22. So monotone, but the curves cross: 2PL slopes run 0.8 to 3.0. **Parametric vs. kernel:** the 2PL stays within 0.19 of the kernel curve (median item 0.07); the Rasch curve is off by up to 0.32 (median 0.17). Item 12: kernel 0.05 → 0.92 between θ ≈ −1.1 and 0.6; Rasch 0.33 → 0.76. | — |
| `balance_mokken` | failure case | 25 balance-scale problems, 484 children, five types of five (weight, distance, conflict-weight, conflict-distance, conflict-balance) (Van Maanen, Been & Sijtsma, 1989, doi:10.1007/978-3-642-83943-6_17). $H$ = 0.10. Conflict-weight items have negative $H_i$ (CW1 −0.31) and fail monotonicity (5–6 significant decreases each; CD4 also flags). CW1 by rest score: 0.97 (7–9, n = 88), 0.39 (14–15), 0.24 (16–17), 0.12 (18+, n = 57). AISP at 0.3 sorts the items by **type**: D + CB + CD5; W2, W5 + all CW; CD1–4; W1, W3; W4 out. **Parametric vs. kernel:** the 2PL gives CW1 a negative slope (−2.8), falling from 1.00 to 0.00; the kernel curve rises, peaks near 0.9, and falls only to 0.16–0.3; W1: the 2PL is flat at 0.9 while the kernel rises from 0.37. The rise at the bottom rests on 4 children with rest scores ≤ 6: say so. Reading: children follow strategies (Siegler, 1976, doi:10.1016/0010-0285(76)90016-5), so conflict-weight items are solved by children using the simplest rule and missed by some more advanced ones; a single continuum isn't the model for these items. | — |
| `swmd_mokken` | problem only (problem 4) | 651 pupils in 30 classes rate their teachers on 7 items, 1–5 (Zijsling et al., 2017, from IRW biblio; COOL5-18, doi:10.17026/dans-zfp-egnq, checked on DataCite). In the IRW the class is `id` and the pupil is `rater`. Pupil-level $H$ = 0.55; Item7 ("would prefer other teachers", arrives keyed) has the lowest $H_i$, 0.39. Two-level $H$ to compute when drafting. Ships with the `irw` package as its example data set (`irw::swmd_mokken`), so it loads with no network. | — |
| `transreas_mokken` | sanity | 425 children, 12 transitive-reasoning tasks (Verweij, Sijtsma & Koops, 1996, doi:10.1177/016502549601900115). The IRW rows equal `mokken::transreas` exactly (checked), and the p-values by grade reproduce the package's construction of Sijtsma & Molenaar's (2002) Table 3.1. The two pseudo-transitivity tasks have negative $H_i$ (T11P −0.03, T12P −0.14), as the design predicts. | — |

**What `swmd_mokken` is.** `irw::swmd_mokken` is not a function: it is the `irw` package's bundled example data (`?swmd_mokken`: "to illustrate package functionality … without needing authentication"), the IRW table of the same name, built from `mokken::SWMD`. It isn't tied to an IRW vignette: none of the 19 vignettes is about Mokken scaling (three include `_mokken` tables in their corpora, as data only). Its Mokken connection is its source package and a two-level design.

**Keying and processing.** All four are processed by `data/mokken.R` (read). mcmi: 1 = endorsed; items and respondents deidentified, so no item text; the Q-matrix columns (A, H, SS, CC) ride along and aren't needed. balance and transreas: 1 = correct. swmd: 1–5, Item7 keyed already (r = 0.30–0.39 with the others). No waves; transreas has `cov_grade` (2–6).

**Where the finding is.** One scale that is monotone but whose curves cross (mcmi: the 2PL and the kernel agree; the Rasch curve doesn't), and one item set where monotonicity itself fails and the 2PL, forced to be monotone, draws a curve the kernel doesn't (balance). Comparison scale: kernel curves on KernSmoothIRT's rank-based normal quantiles, parametric curves on `mirt`'s N(0, 1) θ; close, not identical. The draft may instead compare observed and model-implied $\Pr(x_i = 1 \mid r)$, as `rasch` does for `wirs`.

## Widget / simulation / problem ideas

**Widgets**
- Guttman errors and $H_{ij}$: two items, p-value sliders and a "strength" slider; the 2×2 table, the observed and expected error counts, and $H_{ij}$ = cov / cov-max (idea 2).
- Rest-score groups: pick a curve shape (logistic, flat, inverted U) and a minimum group size; the dots, the pooled groups and any flagged decrease (idea 4).
- Crossing and order: two 2PL items; shade the θ range where the order reverses and report the share of a N(0, 1) population in it; with equal slopes the share is 0 (idea 5; differs from `rasch`'s crossing widget by counting respondents).
- Bandwidth: one simulated inverted-U item; kernel curve with a bandwidth slider, and the logistic fit beside it (idea 6).

**Predict-then-check:** on the balance problems, conflict-weight item CW1 is solved by 97% of children with rest scores of 7–9. Among the children with the highest rest scores (18 or more), will it be higher, about the same, or lower? (0.12; the rest-score table and `check.monotonicity` summary answer it.)

**Simulate:** 1,000 respondents, 10 items from the 2PL (slopes 0.5–2.5) plus one inverted-U item; `coefH`, `aisp`, `check.monotonicity`, `check.iio`; a hand-written kernel smoother (KernSmoothIRT isn't in the webR repo; `mokken` and `mirt` are). What to watch: H and monotonicity are fine for the 2PL items, the inverted-U item gets a low $H_i$ and flags; IIO fails. Set all slopes to 1 (Rasch): IIO holds, H drops or rises with the spread of difficulties. Seconds.

**Problems**
1. Derivation: for two items with $p_i \le p_j$, show that the largest covariance is $p_i(1 - p_j)$ and that $H_{ij}$ = 1 − (observed Guttman errors) / (expected under independence).
2. Real data with a twist: AISP on `balance_mokken` at $c$ = 0.3, 0.4, 0.5. Which item types stay together, and what would the five types lead you to expect? Then read about Siegler's rules.
3. Judgment: the MCMI scale has $H$ = 0.42, no monotonicity violations, and $H^T$ = 0.25. Which of these claims survive: the sum score orders patients; item 12 is endorsed before item 3 by everyone; a 5-point difference means the same everywhere?
4. Design (`swmd_mokken`): pupils rate their teachers. Is the scale for pupils or for teachers? Compare pupil-level $H$ with the two-level coefficients (Koopman et al., 2020), and say what a class-level claim needs.
5. Derivation / simulation: in a 2PL with slopes 1 and 2, find where the curves cross and what share of a N(0, 1) population is on each side. When does it matter for IIO in practice?
6. Challenge (open): build a test of a fitted 2PL curve against the kernel curve (Douglas & Cohen, 2001). How should the bandwidth and the rank-based θ enter the null distribution?

## Go deeper

- **Why the MHM makes covariances non-negative and orders respondents by the sum score.** Under local independence and monotone curves, any two items are associated (Holland & Rosenbaum, 1986); for dichotomous items the sum score has monotone likelihood ratio in θ (Grayson, 1988), so higher sums mean stochastically higher θ. Why: justifies $H \ge 0$ as a necessary condition and the verdict's "the sum score orders respondents"; the ordinal counterpart of `rasch`'s sufficiency callout; `polytomous` and `dif` (matching on the total) touch it. Length: half a page, one inequality each.

## Open questions

- **Prerequisites.** `ctt-limits` and `rasch` (`rasch` already implies `ctt-limits`; listing both shows the thread's origin in the header box). The lesson uses the 2PL in one sentence as the parametric comparison. *Default:* [ctt-limits, rasch], with an "if you've done `1pl-to-4pl`" Recall. Alternative: add `1pl-to-4pl`, which moves the lesson later in the map.
- **Threads.** Returns proposed for `items-rise-with-score` (tests monotonicity without a curve, in rest-score groups), `sum-score-part-whole` (checks with the rest score), `local-independence` (keeps it, with monotonicity, as the whole model), `specific-objectivity` (asks only for curves that don't cross: IIO). Optional: `sum-score-sufficiency` (keeps only the ordering), `equal-unit` (order without a unit). *Default:* the four; the two optional ones as plain Recalls.
- **Third table.** `swmd_mokken` only in a problem. *Default:* keep it (it is the `irw` package's own example data and a two-level case); drop it if you'd rather hold to two tables.
- **H conventions.** Mokken's 0.3 / 0.4 / 0.5 stated as conventions with their source, never as a pass mark. *Default:* yes.
- **Unfolding.** Proposed pointer both ways (E2), not a thread; a one-line link from `unfolding`'s MUDFOLD paragraph at the next cross-check. *Default:* yes.
- **Verdict** above. *Default:* use it unless you'd put it differently.

**Unverified.** Siegler's (1976) rule-by-item-type predictions (which rule solves conflict-weight items) are from memory: check in the paper before drafting. The MCMI Q-matrix scale names. The age of the balance-scale sample (IRW and `mokken` say "toddlers"; balance-scale tasks usually go to school-age children). The Handbook chapter's pages.

**IRW data notes (for the IRW, not the lesson).**
- `acl_mokken` (v64): only items 110–218 of the 218 are present, and each of those rows appears twice per respondent with identical responses (94,394 rows = 433 × 109 × 2); items 1–109 (Communality through part of Aggression) are missing. `data/mokken.R` looks right, so the fault is probably downstream of it. Not used here.
- `ds14_mokken` was withdrawn 09-25 (Si3 overwritten) and rebuilt 09-27, but its landing page is still 404. Not used.
- `balance_mokken`: IRW biblio gives the chapter as "Problem solving strategies and the linear logistic test model"; Crossref has "The Linear Logistic Test Model and heterogeneity of cognitive strategies" (same authors, book and pages 267–287; doi:10.1007/978-3-642-83943-6_17). No DOI in IRW biblio.
- `mokken`'s SWMD help says scores 0–4; both the package data and the IRW table are 1–5. Harmless.
