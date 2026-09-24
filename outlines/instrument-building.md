<!-- Outlined 2026-09-24 from EDUC 252 slides c2 (slides 18–24) and the landscape analysis (notes/landscape-2026-09-24.md, gap 3). Tidied 09-24 (#62): Ben's answers C7 and A5 applied; settled questions folded in; citations verified. -->

# From construct map to items: building an instrument (`instrument-building`)

Module: ctt · Prereqs: constructs, ctt-reliability · Core · Status: outline

## Core ideas

References verified 09-24 against Crossref unless noted; the table citation is from IRW biblio.

1. **The process.** *(major)* Construct map → blueprint → items → review and cognitive interviews → pilot → item analysis → revise (Wilson, 2005, *Constructing Measures*, doi:10.4324/9781410611697; AERA, APA & NCME, 2014, *Standards*, ch. 4, no DOI, verified at aera.net). Most of the work happens before any data. Cognitive interviews: Willis (2005, *Cognitive Interviewing*, Sage, doi:10.4135/9781412983655).
2. **Item formats.** Selected response (multiple choice, Likert) and constructed response. Every response must end in a finite set of mutually exclusive, ordered categories; for constructed responses that means scoring, which is expensive and brings in raters.
3. **Writing items.** *(major)* Rules that carry weight: one idea per item, no double negatives, balanced and labelled options, plausible distractors (Haladyna, Downing & Rodriguez, 2002, *Applied Measurement in Education* 15(3), 309–333, doi:10.1207/S15324818AME1503_5).
4. **Reverse-worded items.** *(major)* They guard against acquiescence, but reverse wording can bring in its own dimension: items cluster by the direction they're worded in (Marsh, 1996, *Journal of Personality and Social Psychology* 70(4), 810–819, doi:10.1037/0022-3514.70.4.810, on global self-esteem; Weijters, Baumgartner & Schillewaert, 2013, *Psychological Methods* 18(3), 320–334, doi:10.1037/a0032121).
5. **The pilot and item analysis.** Item means, item-rest correlations and alpha-if-deleted, read alongside the item's text; decide keep, rewrite or drop (recalled from `ctt-reliability`, not re-taught).

## Picks up

- Construct maps and blueprints (from `constructs`).
- Item-rest correlations, alpha, reverse keying (from `ctt-reliability`).
- Probes, and where they come from (from `measurement`).

## Promises / leaves open

- Raters and constructed-response scoring → `g-theory`.
- Wording direction as a second dimension → `fa-exploratory`, `fa-confirmatory`, `dimensionality`, `ai-psychometrics`.
- Response styles (acquiescence, extreme responding) → `irtrees`; careless responding otherwise unpaid.
- Distractors carry information → `nominal` (nominal response and multiple-choice models).
- Item text predicts difficulty → `explanatory-irt`, `ai-psychometrics`.
- Items that work differently for different groups → `dif` (not a descendant: an "if you've done `instrument-building`" Recall there, per E2).
- Content evidence for validity: item writing and review → `validity-evidence` (a prerequisite there since E1).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `song_2023_rses` | main example | The Rosenberg Self-Esteem Scale (Rosenberg, 1965, *Society and the Adolescent Self-Image*, Princeton University Press, doi:10.1515/9781400876136) as administered by Song et al. (2023, *PLOS ONE* 18(4), e0284335, doi:10.1371/journal.pone.0284335; CC BY 4.0): 10 items, 1–4, 1,238 respondents, keyed (alpha 0.86). Items split into two clusters that match wording direction: correlations of 0.5–0.8 within a cluster, about 0.2 between; second eigenvalue 2.3. The negatively worded block is items 3, 5, 9 and 10. The fifth negatively worded item, 8 ("I wish I could have more respect for myself", reversed), correlates 0.54–0.59 with the positive items and 0.01–0.16 with the other negatives: it doesn't share the wording factor. That's a finding, noted gently, not a data error. | — |

One table: the pilot's data are the case study; the rest of the lesson is design. Item-text alignment was checked 09-24 against Song et al.'s Methods (items 3, 5, 8, 9, 10 negatively worded; matches the IRW text). Item text (A5): the data are CC BY 4.0, but the scale is Rosenberg's; quote only the items the argument needs, with citation, unless the snapshot's licence check finds the scale free to reproduce. Numbers from the 09-24 outline pass (not recomputed). Sanity: none (no model is fitted; the simulation checks the eigenvalue reading).

## Widget / simulation / problem ideas

**Widgets**
- Fix this item: flawed items (double-barrelled, double negative, unbalanced options) with a rewrite to compare (idea 3).
- Blueprint builder: content × process grid, items allotted to cells (idea 1).
- Wording effect: a slider for how much reverse wording adds its own factor; watch the correlation matrix split into two blocks (idea 4).

**Predict-then-check:** will the positively and negatively worded self-esteem items correlate as well with each other as within their own group? Answered by the correlation matrix.

**Simulate** (digest C7, accepted): a unidimensional scale plus a wording factor on the reverse-worded items; alpha stays high while the correlation matrix shows two blocks.

**Problems**
1. Derivation: with a general factor and a wording factor, write the correlation between two items worded the same way and two worded oppositely.
2. Real data with a twist: alpha-if-deleted for each RSES item; which item's removal raises alpha, and does its wording explain why?
3. Judgment: multiple choice or constructed response for a construct of your choice; what does each cost?
4. Design: write six items for a construct map from `constructs`, two reverse-worded; list the item-writing rules each follows.
5. Design: plan a cognitive interview for two of your items: what would you ask?
6. Challenge (open): is the wording factor a nuisance or a real feature of self-esteem (Marsh, 1996)? What data would decide it?

## Go deeper

- None.

## Open questions

- None. Settled: the Simulate section (C7); item-text alignment (checked 09-24); showing item text follows A5.
