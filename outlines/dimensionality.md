<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 3–21, MIRT and the IMV) and c4, PS6#1, and the code c6/enem_mirt.R, c6/enem_imv.R, ps6/personality.R. -->

# Dimensionality and multidimensional IRT (`dimensionality`)

Module: irt · Prereqs: 1pl-to-4pl · Optional · Status: outline

## Core ideas

1. **More than one ability.** Item response surfaces instead of curves; the compensatory model (a gain on θ₁ can offset a loss on θ₂), and non-compensatory alternatives. *(major)* Sources: Reckase (2009), *Multidimensional item response theory*, doi:10.1007/978-0-387-89976-3.
2. **Identification is messy.** Axes must be fixed, and any rotation fits equally well: the same indeterminacy as in exploratory factor analysis, now for item response models. *(major)* Thread from `fa-exploratory` (rotation) and `rasch` (the scale has no origin).
3. **Exploratory vs. confirmatory MIRT.** Let every item load on both dimensions, or fix loadings to zero where a construct isn't measured (PS6#1's m2 vs. m3).
4. **How much better is two dimensions?** AIC and BIC say *whether*, not *how much*. Out-of-sample prediction, summarized with the IMV, says how much. *(major)* Sources: Domingue, Kanopka, Kapoor, Pohl & Chalmers (2024), *Psychometrika* 89(3), 1034–1054, doi:10.1007/s11336-024-09977-2; Domingue, Rahal, Faul, Freese & Kanopka, the IMV (SocArXiv preprint, doi:10.31235/osf.io/gu3ap_v2).
5. **Local dependence.** Items that share a passage or a stem violate local independence; a second dimension is one way to see it. Sources: Yen (1984), doi:10.1177/014662168400800201; Chen & Thissen (1997), doi:10.3102/10769986022003265.

References checked on Crossref (09-24).

## Picks up

- Unidimensionality and local independence (threads from `rasch`).
- The common factor model, rotation, parallel analysis (from `fa-exploratory`).
- Ordinal FA ≡ GRM; multidimensional ordinal FA (from `fa-confirmatory`).
- The 2PL (from `1pl-to-4pl`).
- Out-of-sample prediction and the IMV (from `fit-prediction`, if taught first; not a prerequisite).
- Grit's two facets and its keying (from `fa-confirmatory` and `sem`).

## Promises / leaves open

- Local dependence in repeated trials and item families → `explanatory-irt`, `trials`.
- Bifactor and testlet models: unpaid (they come up in `fa-confirmatory`'s DASS contrast; a full treatment is beyond a first course).
- Multidimensional adaptive testing → `item-banks-cat` (unpaid there otherwise).
- Deep dive #23: how often does unidimensionality hold across the IRW? Home here or in `fa-exploratory` (#4).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `florida_twins_dweck` | main example (second construct) | Implicit theories of intelligence ("mindset"; Dweck, Chiu & Hong, 1995, doi:10.1207/s15327965pli0604_1), 8 items, 1–6, wave 2. | — |
| `florida_twins_grit` | main example (first construct) | Grit-O, 12 items, 1–5, wave 2; 777 young people answered both. Keyed as in PS6#1, sum scores correlate 0.17. A confirmatory two-dimensional graded model beats one dimension (AIC 43,859 → 42,728; BIC 44,361 → 43,236), with a latent correlation of 0.26. An exploratory 2D model puts every mindset item on one factor (0.65–0.87) and most grit items on the other; qgrit3 loads near zero and qgrit11 negatively (−0.37), which is the item PS6#1 asks about. Out of sample (dichotomized as in PS6#1, 5-fold), the second dimension is worth an IMV of 0.013. | `sem` (deliberate thread: same grit items, different partner; `sem` records `reuses:`) |

A worthwhile comparison from the 252 slides (c6 slide 20): on ENEM (booklet 175), a second dimension was worth an IMV of −0.002, i.e. nothing. ENEM isn't available without a token until #15; the lesson can quote the number with its source.

## Widget / simulation / problem ideas

**Widgets**
- Item response surface: a 3D (or heat-map) surface for a two-dimensional item with sliders for $a_1$, $a_2$, $d$; set $a_2 = 0$ and it collapses to a curve (ideas 1, 3).
- Compensation: pick θ₁ and θ₂, see the probability; trade one for the other along a contour (idea 1).
- Rotate the axes: loadings change, the fit doesn't (idea 2; mirrors the `fa-exploratory` widget).

**Predict-then-check:** grit and mindset are both "academic affect" constructs on posters in every classroom. How strongly will they correlate as latent variables? Answered by the confirmatory model (0.26).

**Simulate:** two correlated dimensions with simple structure; fit 1D and 2D models; compute the cross-validated IMV as the correlation between dimensions goes from 0 to 0.9. Shows when a second dimension earns its keep.

**Problems**
1. Derivation: show that a compensatory 2D item with $a_2 = 0$ reduces to a 2PL, and that rotating (θ₁, θ₂) leaves the response probabilities unchanged.
2. Real data with a twist (PS6#1): which grit item(s) behave oddly after keying? Read the text of qgrit11 ("I become very interested in new pursuits every few months") and argue for its keying.
3. Judgment: AIC prefers two dimensions and the IMV is 0.013. Would you report one score or two?
4. Design: you suspect local dependence among items that share a reading passage. Design a check.
5. Simulation: at what latent correlation does the IMV for a second dimension fall below 0.005?
6. Challenge (open): Ben's c6 slide 4: "What if $a_1 = 0$ for some items and $a_2 = 0$ for others? I think this is a big question." What changes when a test's dimensions are separate item sets?

## Go deeper

- **Rotational indeterminacy in MIRT.** For any orthogonal $T$, replacing $\mathbf{a}$ with $T^\top\mathbf{a}$ and θ with $T^\top\theta$ leaves $\mathbf{a}^\top\theta$ unchanged. Why: `fa-exploratory`, `fa-confirmatory`, `rasch` (scale indeterminacy). Length: a few lines (may duplicate `fa-exploratory`'s candidate; the depth pass decides where it lives).

## Open questions

- Grit keying (settled 09-24, consistent with `sem`): the response scale runs 1 = "Very much like me" to 5 = "Not like me at all" (IRW option text). PS6#1 reverses the six consistency-of-interest items and then dichotomizes ≤3 as "like me", which ends with 1 = gritty. For polytomous analyses the course keys the other way round, reversing the six perseverance items so that higher = more grit. That is what `sem` does. Both routes agree on which items move together; the lesson should state its direction once.
- qgrit11: after keying, it loads negatively (−0.37) and its item-rest correlation is −0.08. Ben's PS6#1 flagged it too. The lesson should say so gently. Is it keyed right?
- Twins are clustered in families (as in `sem`).
- `enem_2013_1mil_lc` is dropped for now (#15). Bring it back as a third table if the teaching subsample arrives?
