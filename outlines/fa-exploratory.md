<!-- Outlined backwards from lessons/fa-exploratory.qmd (draft), 2026-09-24. Not in EDUC 252; added after the landscape analysis (EFA in 8 of 11 first-course syllabi). -->

# Factor analysis I: exploring dimensionality (`fa-exploratory`)

Module: fa · Prereqs: ctt-reliability · Core · Status: outline (page is a draft)

## Core ideas

1. **A model for correlations.** The common factor model; with one factor, $\text{cor}(x_i,x_j) = \lambda_i\lambda_j$; communality and uniqueness. *(major)* Sources: Spearman (1904), doi:10.2307/1412107 (the one-factor model and tetrads); Thurstone (1947), *Multiple-factor analysis* (book; to verify).
2. **How many factors?** Eigenvalues, the Kaiser rule, the scree plot, and parallel analysis; the number of factors is an estimate. *(major)* Sources: Kaiser (1960), doi:10.1177/001316446002000116; Cattell (1966), doi:10.1207/s15327906mbr0102_10; Horn (1965), doi:10.1007/bf02289447.
3. **Rotation.** Loadings aren't unique; rotation picks an interpretable solution with the same fit. Simple structure; orthogonal vs. oblique; my default is oblique. *(major)* Sources: Thurstone (1947, simple structure); Kaiser (1958), doi:10.1007/bf02289233 (varimax); Browne (2001), doi:10.1207/s15327906mbr3601_05 (rotation overview).
4. **Two practical notes.** Polychoric correlations for Likert items; factor analysis is not PCA. Sources: Olsson (1979), doi:10.1007/bf02296207 (polychoric correlation); Fabrigar, Wegener, MacCallum & Strahan (1999), doi:10.1037/1082-989x.4.3.272.

Articles checked on Crossref (09-24); Thurstone (1947) is a book, still to verify.

## Picks up

- Alpha, tau-equivalence, reverse keying (from `ctt-reliability`).
- Constructs; unidimensionality as a property of a construct map (from `constructs`).
- Wording direction as a second dimension (from `instrument-building`).

## Promises / leaves open

- Confirmatory models, fit indices, omega → `fa-confirmatory`.
- Ordered categories as a coarsened continuous variable (polychorics) → `fa-confirmatory` (ordinal FA ≡ GRM), `polytomous`.
- The scale of a factor is arbitrary (rotation, like the Rasch origin) → `rasch` (thread: the scale has no origin).
- Dimensionality in IRT → `dimensionality`; deep dive #23 (how often unidimensionality holds).
- Response formats as an experiment (problem 4) → `invariance-experience`, unpaid otherwise.
- The "unusually clean" claim needs a baseline (TODO in the page, #3) → the dimensionality vignette.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `bfi2_zhang_2025` | main example | BFI-2, 60 items, 1,335 students, four randomly assigned formats. Five blocks in the correlation matrix; parallel analysis says 9 against a 5-domain design; all 60 items load most strongly on their own domain; item 26 loads below 0.3. Orthogonal and oblique fit identically. | — |

## Widget / simulation / problem ideas

**Widgets**
- Correlations from one factor (idea 1).
- Eigenvalues and parallel analysis: loadings, factors, sample size (idea 2).
- Rotating two factors: angle slider, loadings move, fit doesn't (idea 3).

**Predict-then-check:** how many factors will parallel analysis find in a five-domain inventory? Answered by the parallel analysis (9).

**Simulate:** two correlated factors, five items each; parallel analysis and oblique EFA; compare with the truth (`psych`).

**Problems**
1. Derivation: $\lambda_i\lambda_j$ and the tetrad constraints.
2. Derivation / thread: the sum score's correlation with the factor; tau-equivalence in terms of loadings (links to the alpha proof).
3. Simulation: when parallel analysis fails.
4. Real data: formats; loadings by format (Zhang et al., 2025).
5. Judgment: the three lowest-communality items; drop them? (wording in Soto & John, 2017).
6. Challenge: PCA vs. FA loadings.

## Go deeper

- **Rotational indeterminacy.** Any orthogonal $T$ gives $\Lambda T (\Lambda T)^\top = \Lambda\Lambda^\top$. Why: `fa-confirmatory` (identification), `dimensionality`, `rasch` (scale indeterminacy). Length: a few lines, possibly a problem rather than a callout.

## Open questions

- None new. The baseline for "unusually clean" is Claude's to add (#3).
