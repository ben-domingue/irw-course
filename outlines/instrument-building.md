<!-- Outlined 2026-09-24 from EDUC 252 slides c2 (slides 18–24) and the landscape analysis (notes/landscape-2026-09-24.md, gap 3). -->

# From construct map to items: building an instrument (`instrument-building`)

Module: ctt · Prereqs: constructs, ctt-reliability · Core · Status: outline

## Core ideas

1. **The process.** Construct map → blueprint → items → review and cognitive interviews → pilot → item analysis → revise. Most of the work happens before any data. *(major)*
2. **Item formats.** Selected response (multiple choice, Likert) and constructed response. Every response must end in a finite set of mutually exclusive, ordered categories; for constructed responses that means scoring, which is expensive and brings in raters.
3. **Writing items.** Rules that carry weight: one idea per item, no double negatives, balanced and labelled options, plausible distractors. *(major)*
4. **Reverse-worded items.** They guard against acquiescence, but reverse wording can introduce its own dimension: items cluster by the direction they're worded in. *(major)*
5. **The pilot and item analysis.** Item means, item-rest correlations and alpha-if-deleted, read alongside the item's text; decide keep, rewrite or drop.

## Picks up

- Construct maps and blueprints (from `constructs`).
- Item-rest correlations, alpha, reverse keying (from `ctt-reliability`).

## Promises / leaves open

- Raters and constructed-response scoring → `g-theory`.
- Wording direction as a second dimension → `fa-exploratory`, `dimensionality`.
- Response styles (acquiescence, extreme responding) → `irtrees`; careless responding otherwise unpaid.
- Distractors carry information → `nominal` (nominal response and multiple-choice models).
- Item text predicts difficulty → `explanatory-irt`, `ai-psychometrics`.
- Items that work differently for different groups → `dif`.
- Content evidence for validity → `validity-evidence`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `song_2023_rses` | main example | The Rosenberg Self-Esteem Scale, 10 items, 1–4, 1,238 people, keyed (alpha 0.86). Items split into two clusters that match wording direction: correlations of 0.5–0.8 within a cluster, about 0.2 between; second eigenvalue 2.3. | — |

One table: the pilot's data are the case study; the rest of the lesson is design.

## Widget / simulation / problem ideas

**Widgets**
- Fix this item: flawed items (double-barrelled, double negative, unbalanced options) with a rewrite to compare (idea 3).
- Blueprint builder: content × process grid, items allotted to cells (idea 1).
- Wording effect: a slider for how much reverse wording adds its own factor; watch the correlation matrix split into two blocks (idea 4).

**Predict-then-check:** will the positively and negatively worded self-esteem items correlate as well with each other as within their own group? Answered by the correlation matrix.

**Simulate:** a unidimensional scale plus a wording factor on the reverse-worded items; alpha stays high while the correlation matrix shows two blocks.

**Problems**
1. Derivation: with a general factor and a wording factor, write the correlation between two items worded the same way and two worded oppositely.
2. Real data with a twist: alpha-if-deleted for each RSES item; which item's removal raises alpha, and does its wording explain why?
3. Judgment: multiple choice or constructed response for a construct of your choice; what does each cost?
4. Design: write six items for a construct map from the constructs lesson, two reverse-worded; list the item-writing rules each follows.
5. Design: plan a cognitive interview for two of your items: what would you ask?
6. Challenge (open): is the wording factor a nuisance or a real feature of self-esteem? What data would decide it?

## Go deeper

- None.

## Open questions

- **Item-text alignment (#63).** In `song_2023_rses`, the item ids don't follow the standard Rosenberg numbering. The IRW's item text for this table puts "I wish I could have more respect for myself" on RSES8, which clusters with the positive items in the data. Verify the mapping against the original source before drafting. `bakker_2020_rses` shows a similar mismatch.
- Reuse: the RSES is widely treated as free to use, but that needs confirming for #63.
- No Simulate section fits naturally in a design lesson. The wording-factor simulation is the proposal.
