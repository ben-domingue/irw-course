<!-- Outlined 2026-09-24. New lesson (Ben's suggestion, #64). The IRW's lavaan CFA vignette is a starting point. Tidied 09-24 (#62): C9, E1, E2 and the tranches applied. -->

# Structural equation modeling with lavaan (`sem`)

Module: fa · Prereqs: fa-confirmatory · Extension · Status: outline

## Core ideas

1. **Measurement model plus structural model.** Latent variables measured by items (the CFA from `fa-confirmatory`), connected by regressions. *(major)* Sources: Bollen (1989), *Structural equations with latent variables*, doi:10.1002/9781118619179; Jöreskog (1969), doi:10.1007/BF02289343.
2. **Why latent regressions differ from regressions on sum scores.** Measurement error attenuates paths between sum scores; latent paths correct for it (under the model). *(major)* Recall attenuation from `ctt-reliability` problem 2 (Lord & Novick, 1968, *Statistical theories of mental test scores*, Addison-Wesley; book, no DOI).
3. **Specification in `lavaan`.** `~` and `~~` added to the `=~` syntax readers already know (C9, settled: `lavaan` first appears in `fa-confirmatory`, so this lesson extends it rather than introducing it); identification; estimators for ordinal and non-normal data (MLR, WLSMV). Source: Rosseel (2012), doi:10.18637/jss.v048.i02.
4. **Fit, and fit of which part.** Global fit mixes measurement and structure; check the measurement model first (two-step). *(major)* Sources: Anderson & Gerbing (1988), doi:10.1037/0033-2909.103.3.411; Hu & Bentler (1999), doi:10.1080/10705519909540118.
5. **What SEM can't do.** Paths are regressions: without design, they aren't causal effects, and equivalent models fit identically. Source: MacCallum, Wegener, Uchino & Fabrigar (1993), doi:10.1037/0033-2909.114.1.185.

Crossref-checked 09-24 unless marked.

## Picks up

- CFA, fit indices, ordinal estimation, `lavaan` syntax (from `fa-confirmatory`).
- Attenuation (from `ctt-reliability`).
- Multiple regression (assumed from a prior course).

## Promises / leaves open

- Longitudinal SEM (the twins data have waves) → unpaid.
- Multigroup SEM (structural paths compared across groups; the measurement side, multigroup CFA invariance, is taught in `fa-confirmatory` before this lesson, E1) → `invariance-experience` (not a descendant: an "if you've done `sem`" aside there, E2); otherwise unpaid.
- Causal claims about constructs → `validity-causal` (not a descendant: an "if you've done `sem`" aside there, E2).
- Latent regression of ability on covariates in IRT: a pointer to `explanatory-irt` (not a descendant, E2; no hook).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `florida_twins_grit` | main example (measurement: grit) | Grit-O items with item text; first wave; joined to PANAS by `id`. | `dimensionality` (deliberate reuse: same grit items, keyed the same way; `sem` records `reuses:`) |
| `florida_twins_panas` | main example (outcome: affect) | PANAS positive and negative affect (Watson, Clark & Tellegen, 1988, doi:10.1037/0022-3514.54.6.1063). 618 children and adolescents (ages 9–18) have both. | — |

**Finding:** with MLR, fit is modest (CFI 0.84, RMSEA 0.06, SRMR 0.07). Perseverance of effort predicts positive affect strongly (standardized 0.66); consistency of interest predicts lower negative affect (−0.27). Keying (confirmed 09-24 from the IRW option text): the grit scale runs 1 = "Very much like me" to 5 = "Not like me at all", so the six perseverance items are reversed to make higher = more grit; the consistency-of-interest items already run that way. Same direction as `dimensionality`.

Two tables from one study count as one data source; the lesson says so.

Clustering: twins are nested in families. IRW ids come in pairs ending 00/01 (e.g. 31700, 31701), and `id %/% 100` gives 390 families of two plus 2 singletons; use it as `lavaan`'s `cluster =` variable. This is inferred from the id pattern; confirming it against the LDbase codebook (login needed) is Claude's to-do (digest D).

## Widget / simulation / problem ideas

**Widgets**
- Attenuation: reliability sliders for X and Y; the regression on sum scores shrinks, the latent path doesn't (idea 2).
- Path diagram ↔ syntax: build a small model by clicking; the `lavaan` syntax writes itself (idea 3).
- Equivalent models: reverse an arrow; fit unchanged (idea 5).

**Predict-then-check:** will perseverance or consistency of interest be the stronger predictor of positive affect? Answered by the structural paths.

**Simulate:** two latent variables with a known path, measured with error; compare the regression on sum scores with the SEM estimate, across reliabilities.

**Problems**
1. Derivation: the attenuation of a regression slope by unreliability in the predictor.
2. Real data with a twist: the same model on sum scores; compare the paths.
3. Judgment: the participants are twins. What does that do to the standard errors, and how would you handle it?
4. Design: draw an SEM for a question you care about; what would identify it?
5. Real data: fit the measurement model alone first. Where is the misfit?
6. Challenge (open): write down an equivalent model with a different causal story. What evidence would separate them?

## Go deeper

- None (extension lesson).

## Open questions


- **Notes for drafting (Ben, 09-25).** (1) Prediction as a complement to fit: Zhang, Rahal, Kanopka, Ulitzsch, Zhang & Domingue (2026), *Multivariate Behavioral Research*, doi:10.1080/00273171.2026.2645212 (IMV for CFA with binary outcomes; verified on Crossref); `fa-confirmatory` cites it and has a problem on it, so recall rather than re-teach. (2) Composites vs. factors: composite-based SEM (PLS, PLSc, GSCA) models a construct as a weighted sum of its items rather than a common factor; a paragraph at most, with the `cSEM` package or the Composite-SEM jamovi module (github.com/AbdullahAlarfaj101/Composite-SEM; small, no licence file as of 09-25) as a pointer, flagged as a different model. Point-and-click users: jamovi's SEM tools (verify which module before naming one).

- **First-person verdict.** The outline has none yet. *Default:* "I fit and inspect the measurement model before I read a single structural path; a path between badly measured factors is not worth interpreting" (idea 4, Anderson & Gerbing's two-step). For Ben to confirm or reword.
