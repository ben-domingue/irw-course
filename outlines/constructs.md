<!-- Outlined 2026-09-24 from EDUC 252 slides c2 (slides 3–17). -->

# Constructs and construct maps (`constructs`)

Module: ctt · Prereqs: measurement · Core · Status: outline

## Core ideas

1. **A construct is how we operationalize what we can't grasp.** Cronbach and Meehl (1955): a postulated attribute, reflected in test performance, carrying statements of the form "people with this attribute, in situation X, act in manner Y (with a stated probability)". *(major)*
2. **A construct map.** Wilson's simpler version: an underlying continuum, with qualitatively described levels, on which items and respondents sit in the same space (the picture IRT will draw). A worked example: the California DRDP. *(major)*
3. **Two tests for a proposed construct.** Does the map order the items before you see data? Does it suggest an intervention: a plan for "increasing" the construct? My view is that some published constructs come much closer to this ideal than others.
4. **Continuous or categorical?** Latent classes (Moffitt's taxonomy of antisocial behaviour) vs. a continuum. My prior is that variation is much more often continuous. *(major)*
5. **A different starting point: blueprints.** Licensure, admissions and K–12 tests often sample a domain to a specification, not a construct map; sometimes that is a bureaucratic minimum standard (the driving test).

## Picks up

- Latent vs. manifest; constructs; probes (from `measurement`).
- Measurement as discovery (the thermometer) (from `measurement`).

## Promises / leaves open

- Items and people on one scale → `rasch` (Wright map), `information`.
- The construct map orders the items: checked against data → `rasch`, `validity-evidence`.
- The construct is unidimensional → `fa-exploratory`, `dimensionality`.
- From map to items → `instrument-building`.
- Latent classes → `cdm`; mixture/latent-class item response models otherwise unpaid.
- The construct suggests an intervention → `validity-causal` (Borsboom's causal view), `invariance-experience`.
- Blueprints and domain sampling → `validity-argument` (content evidence), `g-theory` (items as a facet).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `himmelstein-number_series-2025` | main example | Nine number-series items with item text, 569 people in the first wave. Proportions correct run from 0.84 (NS_2, "3, 6, 10, 15, 21, ___") to 0.02 (NS_6, "200, 198, 192, 174, ___", differences that triple). A construct map of pattern complexity (constant difference → growing difference → multiplicative → interleaved → fractions) orders most items correctly before any data. | — |

One table: the lesson is conceptual, and the table's job is to test a construct map.

## Widget / simulation / problem ideas

**Widgets**
- Build a construct map: drag number-series items onto levels, then reveal their proportions correct (ideas 2, 3).
- DRDP explorer: a developmental continuum with descriptors at each level (idea 2).
- Continuum or classes? Simulated sum-score histograms from a continuous trait vs. a four-class mixture; can you tell which is which? (idea 4)

**Predict-then-check:** rank the nine number-series items from easiest to hardest from their text alone. Answered by the proportions correct.

**Simulate:** generate responses from a construct map (items at levels, people on a continuum) and from a latent-class model with the same item means; compare sum-score distributions and item–total correlations. Shows how hard it is to tell the two apart from summary statistics.

**Problems**
1. Derivation: under a two-class model, show what an item's mean and its correlation with the sum score are, in terms of class proportions and within-class probabilities.
2. Real data with a twist: in the number-series table, which item is most out of place relative to your construct map? Propose a reason from its text.
3. Judgment: take a construct you work with; write its Cronbach–Meehl sentence ("in situation X, act in manner Y"). Does it pass the intervention test?
4. Design: sketch a four-level construct map for a construct of your choice, with one item per level.
5. Judgment: a licensure exam built from a blueprint vs. a scale built from a construct map. What does each let you claim?
6. Challenge (open): Moffitt's taxonomy is categorical. What data would convince you that antisocial behaviour is a continuum instead?

## Go deeper

- None.

## Open questions

- Item text (#63): the lesson leans on item text. The number-series items are short arithmetic sequences; their reuse status needs checking.
- Slide 11 ("one of these comes much closer to this ideal") compares two constructs whose images aren't in the text export. Which two, for the verdict in idea 3?
- Simulate compares a continuum with latent classes. Is that the right simulation for a conceptual lesson, or should Simulate build a construct map's Wright map?
