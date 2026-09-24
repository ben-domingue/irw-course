<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 3–21, MIRT and the IMV) and c4, PS6#1, and the code c6/enem_mirt.R, c6/enem_imv.R, ps6/personality.R. Tidied 09-24 (#62): Ben's answers applied (C18, A4); pick-ups checked against the drafted `rasch`. -->

# Dimensionality and multidimensional IRT (`dimensionality`)

Module: irt · Prereqs: fa-confirmatory · Extension · Status: outline

## Core ideas

1. **More than one ability.** Item response surfaces instead of curves; the compensatory model (a gain on θ₁ can offset a loss on θ₂) and non-compensatory alternatives. *(major)* Sources: Reckase (2009), doi:10.1007/978-0-387-89976-3; Bock, Gibbons & Muraki (1988), doi:10.1177/014662168801200305 (full-information item factor analysis).
2. **Identification is messy.** Axes must be fixed, and any rotation fits equally well: the indeterminacy of exploratory factor analysis, now for item response models. *(major)* Threads from `fa-exploratory` (rotation) and `rasch` (the scale has no origin). Source: Reckase (2009).
3. **Exploratory vs. confirmatory MIRT.** Let every item load on both dimensions, or fix loadings to zero where a construct isn't measured (PS6#1's m2 vs. m3). Sources: Bock, Gibbons & Muraki (1988); Chalmers (2012), doi:10.18637/jss.v048.i06 (`mirt`).
4. **How much better is two dimensions?** AIC and BIC say *whether*, not *how much*; out-of-sample prediction summarized by the IMV says how much. *(major)* Sources: Domingue, Kanopka, Kapoor, Pohl, Chalmers, Rahal & Rhemtulla (2024), *Psychometrika* 89(3), 1034–1054, doi:10.1007/s11336-024-09977-2; Domingue, Rahal, Faul, Freese, Kanopka, Rigos & Stenhaug (2025), *PLOS ONE*, doi:10.1371/journal.pone.0316491.
5. **Local dependence.** Items that share a passage or a stem violate local independence; a second dimension is one way to see it. Sources: Yen (1984), doi:10.1177/014662168400800201; Chen & Thissen (1997), doi:10.3102/10769986022003265.

DOIs Crossref-checked 09-24.

**Verdict (voice rule A):** one score or two for grit and mindset, verdict first (problem 3 asks the reader first).

## Picks up

- Unidimensionality and local independence as model assumptions, with the IRW vignettes on how often each holds (threads from `rasch`).
- The common factor model, rotation, parallel analysis (from `fa-exploratory`).
- Ordinal FA ≡ GRM; multidimensional ordinal FA (from `fa-confirmatory`).
- The 2PL (from `1pl-to-4pl`).
- Out-of-sample prediction and the IMV (from `fit-prediction`, not an ancestor; E2: restated in a paragraph, "if you've done it").
- Grit's two facets and its keying (from `fa-confirmatory`; keyed as in `sem`).
- The construct is unidimensional; wording direction as a second dimension (from `constructs`, `instrument-building`).
- Testlets and correlated errors: local dependence, and alpha overstating (from `ctt-limits`, `ctt-reliability`).

## Promises / leaves open

- Local dependence in repeated trials and item families → `trials` (not a descendant; it reaches the idea through the testlet effect in explanatory IRT, E2).
- Bifactor and testlet models: unpaid (`fa-confirmatory`'s DASS contrast raises them; a full treatment is beyond a first course).
- Multidimensional adaptive testing → `item-banks-cat` (a paragraph there; unpaid otherwise).
- Deep dive #23: how often unidimensionality holds across the IRW (see Open questions).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `florida_twins_dweck` | main example (second construct) | Implicit theories of intelligence ("mindset"; Dweck, Chiu & Hong, 1995, doi:10.1207/s15327965pli0604_1), 8 items, 1–6, wave 2. | — |
| `florida_twins_grit` | main example (first construct) | Grit-O, 12 items, 1–5, wave 2; 777 young people answered both. Keyed as below, sum scores correlate 0.17. A confirmatory two-dimensional graded model beats one dimension (AIC 43,859 → 42,728; BIC 44,361 → 43,236), latent correlation 0.26. An exploratory 2D model puts every mindset item on one factor (0.65–0.87) and most grit items on the other; qgrit3 loads near zero and qgrit11 negatively (−0.37). Out of sample (dichotomized as in PS6#1, 5-fold), the second dimension is worth an IMV of 0.013. | `sem` (deliberate thread: same grit items, different partner; `sem` records `reuses:`) |

**Decisions (Ben, 09-24):**
- Grit keying (B): higher = more grit. The response scale runs 1 = "Very much like me" to 5 = "Not like me at all" (IRW option text); the course reverses the six perseverance items so that higher = more grit, as `sem` does. PS6#1's dichotomized route (reverse the consistency items, then ≤3 = "like me") agrees on which items move together. The lesson states its direction once.
- qgrit11 (C18): after keying it loads −0.37 and its item-rest correlation is −0.08, which Ben's PS6#1 also flagged. The lesson notes it gently, as an item worth reading ("I become very interested in new pursuits every few months"), not as a fault.
- Twins are clustered in families (family = `id %/% 100`, as in `sem`); the lesson says so where standard errors matter.
- No ENEM (A4). The c6 slide 20 result (a second dimension on ENEM booklet 175 worth an IMV of −0.002) can be quoted as the slide's analysis, not rerun.

## Widget / simulation / problem ideas

**Widgets**
- Item response surface: a heat map for a two-dimensional item with sliders for $a_1$, $a_2$ and the intercept; set $a_2 = 0$ and it collapses to a curve (ideas 1, 3).
- Compensation: pick θ₁ and θ₂, see the probability; trade one for the other along a contour (idea 1).
- Rotate the axes: loadings change, the fit doesn't (idea 2; mirrors the `fa-exploratory` widget).

**Predict-then-check:** grit and mindset are both "academic affect" constructs on posters in many classrooms. How strongly will they correlate as latent variables? Answered by the confirmatory model (0.26).

**Simulate:** two correlated dimensions with simple structure; fit 1D and 2D models; the cross-validated IMV as the correlation between dimensions goes from 0 to 0.9. Shows when a second dimension earns its keep.

**Problems**
1. Derivation: show that a compensatory 2D item with $a_2 = 0$ reduces to a 2PL, and that rotating (θ₁, θ₂) leaves the response probabilities unchanged.
2. Real data with a twist (PS6#1): which grit item(s) behave oddly after keying? Read qgrit11's text and argue for its keying.
3. Judgment: AIC prefers two dimensions and the IMV is 0.013. Would you report one score or two?
4. Design: you suspect local dependence among items that share a reading passage. Design a check.
5. Simulation: at what latent correlation does the IMV for a second dimension fall below 0.005?
6. Challenge (open): Ben's c6 slide 4: "What if $a_1 = 0$ for some items and $a_2 = 0$ for others? I think this is a big question." What changes when a test's dimensions are separate item sets?

## Go deeper

- **Rotational indeterminacy in MIRT.** For any orthogonal $T$, replacing $\mathbf{a}$ with $T^\top\mathbf{a}$ and θ with $T^\top\theta$ leaves $\mathbf{a}^\top\theta$ unchanged. Why: `fa-exploratory`, `fa-confirmatory`, `rasch` (scale indeterminacy). Length: a few lines (may duplicate `fa-exploratory`'s candidate; the depth pass decides).

## Open questions

- **Home of deep dive #23** (how often unidimensionality and local independence hold across the IRW; issue #23 says `dimensionality` or `fa-exploratory`). *Default:* here, since it is this lesson's question and it pays off `rasch`'s assumption threads; `fa-exploratory` points forward to it.
