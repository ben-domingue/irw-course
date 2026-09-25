<!-- Outlined backwards from lessons/ctt-reliability.qmd (draft), 2026-09-24. Updated to match the retrofitted page (#11), 2026-09-24. -->

# Classical test theory and reliability (`ctt-reliability`)

Module: ctt · Prereqs: constructs, irw-data · Core · Status: draft (retrofitted to the protocol, #11)

## Core ideas

1. **True scores and error.** $X = T + E$; the variance splits; reliability is $\sigma^2_T/\sigma^2_X$, which can't be computed directly (Spearman 1904; Lord & Novick 1968). *(major)*
2. **Parallel forms.** Their correlation equals reliability; the standard error of measurement is what reliability means for one respondent, and CTT gives one SEM for everyone. *(major)*
3. **Alpha from one administration.** Items as little parallel tests; KR-20 for 0/1 items, Guttman's $\lambda_3$; alpha equals reliability only under (essential) tau-equivalence and is otherwise a lower bound (Novick & Lewis 1967); correlated errors break the bound. *(major)*
4. **Split halves and Spearman–Brown.** Lengthening and shortening (with a quick check on test length); alpha is the average split half (Cronbach 1951).
5. **Item analysis and reading your items.** Item means and item-rest correlations; item-rest correlations can't reveal reverse keying; the first principal component nearly can, but not for every item, so read the items.

Nothing dropped in the retrofit.

## Picks up

- Long to wide, item means, sum scores (from `irw-data`; Recall callout at *Item analysis*).
- Constructs; a scale is meant to measure one thing (from `constructs`; linked in *What this is for*).
- Keying: already-reversed items in the Mini-IPIP (from `irw-data`). Not recalled explicitly: `irw-data` is still a stub; the cross-check should add a Recall once it is drafted.

## Promises / leaves open

- Alpha ≤ reliability needs tau-equivalence → `fa-confirmatory` (omega), `ctt-limits` (how loose the bound can be).
- One SEM for everyone → `information` (conditional SEM; linked in the page), `score-meaning` (error bands).
- CTT says nothing about item responses → `ctt-limits`, `rasch`.
- Correlated errors (shared passages) make alpha overstate → `dimensionality`, `explanatory-irt`.
- Alpha is not unidimensionality → `fa-exploratory`.
- Reliability is a property of scores in a population (the reliability paradox) → `validity-evidence` (briefly), `trials` (per digest part 2; no formal thread).
- Reverse keying; automated keying gets most items but not all → `fa-exploratory`, `polytomous`, `instrument-building`, `irtrees`, `unfolding`.
- Many sources of error at once → `g-theory`.
- Attenuation (problem 2) → `validity-evidence`, `sem`.
- Reliability is necessary but not sufficient for validity → `validity-argument` (a Recall of alpha).
- Reliability bounds any correlation, and unreliability can mimic group differences in intercepts → `fairness`.

## Tables

| Table | Job | What it turns up | Also used in |
|---|---|---|---|
| `gilbert_meta_1` | main example | School-randomized reading trial (7,797 third graders, 110 schools), 30 items, 7,322 complete cases. Median item-rest 0.49, 24 of 30 at 0.40 or above; `s_read_7_4` at −0.01. Alpha 0.898; 1,000 split halves average 0.899 (range 0.875–0.911, a third below alpha). | — |
| `lessR_Mach4` | contrast | Stored unkeyed. Unkeyed alpha 0.37, item-rest correlations small, 17 of 20 positive; keyed by the published ten-item key, 0.70. m19 is −0.05 keyed as published and 0.05 reversed; the first principal component recovers the ten published reversals and adds m19 (as the lessR documentation also does). | — |

Sanity table: none needed; the real-data section fits no model.

Item text (A5, E6): the Mach IV is not openly licensed (Christie & Geis 1970, Academic Press), so the page quotes two items (m01, m04), cited, and describes m19 by topic.

## Widget / simulation / problem ideas

**Widgets**
- Parallel forms: simulated forms with adjustable error SD; the correlation tracks reliability; SEM shown (idea 2).
- When does alpha equal reliability? Six items with loadings pulled apart (idea 3).
- Lengthening a test: Spearman–Brown curve (idea 4).

**Quick checks (3):** parallel-forms correlation (idea 2); when is "alpha is a lower bound" safe (idea 3); how many items to reach 0.85 (idea 4).

**Predict-then-check (With real data):** before keying the Mach IV, what is alpha? (0.37.)

**Simulate:** six-item classical model; true reliability vs. alpha with equal (0.865 vs 0.86) and unequal (0.879 vs 0.829) loadings (base R).

**Problems**
1. Derivation: parallel forms correlation; where each assumption is used.
2. Derivation: attenuation, and the bound on validity (Spearman 1904; Loevinger 1954).
3. Real data with a twist: drop `s_read_7_4`; compare with the Spearman–Brown prediction.
4. Judgment: why alpha isn't below every split half; challenge (open): are the low splits non-parallel?
5. Judgment / design: the two weakest keyed Mach IV items (and which way to key m19): drop, rewrite or keep? Research vs. screening.
6. Real data: alpha at scale for five 0/1 tables; predict, then explain. The small version of deep dive #20 (digest C6).

## Go deeper

- **Alpha is a lower bound on reliability (in the page).** Assumptions stated at the top; equality under essential tau-equivalence; fails with correlated errors. Why: `fa-confirmatory` (omega), `ctt-limits`, `g-theory`. Length: about a page.
- **Parallel forms ⇒ reliability (candidate).** Currently problem 1; the depth pass (#10) decides whether it becomes a callout.

## Open questions

- None open. A2 (Ben): the "Limitations worth remembering" prose stands as the alpha verdict. The page's first-person line is on automated keying ("I use automated keying as a prompt to read the items"). C6: problem 6 stays the small version of deep dive #20; *Across the IRW* is added when #20 is computed.
- Citations: Lord & Novick (1968) has no DOI (verified through Crossref-indexed reviews); McDonald (1999) is cited by the DOI of the Routledge reissue (10.4324/9781410601087). The Mach IV reverse key is verified from secondary sources only (the book isn't to hand).
