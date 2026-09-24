<!-- Outlined 2026-09-24. New lesson (Ben's suggestion, #64); optional. The IRW's lavaan CFA vignette is a starting point. -->

# Structural equation modeling with lavaan (`sem`)

Module: fa · Prereqs: fa-confirmatory · Optional · Status: outline

## Core ideas

1. **Measurement model plus structural model.** Latent variables measured by items (the CFA from the last lesson), connected by regressions. *(major)* Sources: Bollen (1989), *Structural equations with latent variables*, doi:10.1002/9781118619179; Jöreskog (1969).
2. **Why latent regressions differ from regressions on sum scores.** Measurement error attenuates paths between sum scores; latent paths correct for it (under the model). *(major)* Thread: attenuation from `ctt-reliability` problem 2 (Lord & Novick, 1968).
3. **Specification in `lavaan`.** `=~`, `~`, `~~`; identification; estimators for ordinal and non-normal data (MLR, WLSMV). Source: Rosseel (2012), doi:10.18637/jss.v048.i02.
4. **Fit, and fit of which part.** Global fit mixes measurement and structure; check the measurement model first (two-step). *(major)* Sources: Anderson & Gerbing (1988), doi:10.1037/0033-2909.103.3.411; Hu & Bentler (1999), doi:10.1080/10705519909540118.
5. **What SEM can't do.** Paths are regressions: without design, they aren't causal effects; equivalent models fit identically. Source: MacCallum, Wegener, Uchino & Fabrigar (1993), doi:10.1037/0033-2909.114.1.185.

## Picks up

- CFA, fit indices, ordinal estimation, `lavaan` syntax (from `fa-confirmatory`).
- Attenuation (from `ctt-reliability`).
- Multiple regression (assumed from a prior course).

## Promises / leaves open

- Latent regression of ability on covariates in IRT → `explanatory-irt`.
- Multigroup SEM and invariance → `dif`, `invariance-experience`.
- Causal claims about constructs → `validity-causal`.
- Longitudinal SEM (the twins data have waves) → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `florida_twins_grit` | main example (measurement: grit) | Grit-O items with item text; first wave; joined to PANAS by `id`. | — |
| `florida_twins_panas` | main example (outcome: affect) | PANAS positive and negative affect (Watson, Clark & Tellegen, 1988, doi:10.1037/0022-3514.54.6.1063). 618 children and adolescents (ages 9–18) have both. | — |

**Finding:** with MLR, fit is modest (CFI 0.84, RMSEA 0.06, SRMR 0.07). Perseverance of effort predicts positive affect strongly (standardized 0.66); consistency of interest predicts lower negative affect (−0.27). Keying (confirmed 09-24 from the IRW option text): the grit scale runs 1 = "Very much like me" to 5 = "Not like me at all", so the six perseverance items are reversed to make higher = more grit. The consistency-of-interest items, being negatively worded, already run that way. Same direction as `dimensionality`.

Two tables from one study count as one data source; the lesson says so.

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

- None (optional lesson).

## Open questions

- `florida_twins_grit` also appears in `dimensionality` (grit alongside growth mindset, PS6#1). It's recorded as a deliberate thread: `sem` carries `reuses: [florida_twins_grit]`, and both lessons key grit the same way.

- Optional (Ben, 09-24, #64). Still open: `lavaan` is introduced in `fa-confirmatory`, not here. Agree?
- Twins are clustered in families; is a family id available in the source data? If not, the lesson says the standard errors are too small, gently.
