<!-- Outlined 2026-09-24 from EDUC 252 PS5#4 and PS7#1, with the code in ps5/rctdif.R, ps5/groupdiff_example.R and ps7/ilhte.R. Deep dive #26 (item-level treatment effects across RCTs). Scope (Ben, 09-24, #45): IL-HTE stays here as an optional follow-on to dif, framed explicitly as DIF with treatment as the group. -->

# Measurement invariance under treatment and life events (`invariance-experience`)

Module: fairness · Prereqs: dif · Optional · Status: outline

## Core ideas

1. **Experience can change how a measure works.** After spousal loss, depressive symptoms rise over the first months and return to their earlier level within about two years, but not evenly: the CES-D's "lonely" and "sad" items carry most of the rise (PS5#4). Is that more depression, or a different measure of it? The classic names: alpha, beta and gamma change (a change in the level, in the scale's calibration, or in the construct itself); response shift. *(major)* Sources: Domingue, Duncan, Harrati & Belsky (2021), doi:10.1093/geronb/gbaa044 (Figure 1 and the supplement's item-level figure; **supplement figure to recheck when drafting**); Golembiewski, Billingsley & Yeager (1976), doi:10.1177/002188637601200201; Sprangers & Schwartz (1999), doi:10.1016/S0277-9536(99)00045-3.
2. **Treatment assignment as a DIF group, with the pretest as a placebo.** Randomization makes treatment the cleanest possible grouping variable: there is no impact before treatment, so the pretest should show no treatment DIF, and any DIF at posttest is caused by the intervention. *(major)* Sources: Recall `dif` (idea 6); Gilbert, Kim & Miratrix (2023), doi:10.3102/10769986231171710.
3. **The IL-HTE model.** An explanatory item response model with a random item slope on treatment: $\text{logit}\Pr(x_{ij}=1) = \theta_j + b_i + \zeta_i T_j$, $\theta_j = \beta_0 + \beta_1 T_j + \varepsilon_j$, with $(b_i, \zeta_i)$ bivariate normal. $\sigma_\zeta$ is the spread of item-specific effects around the average effect $\beta_1$; $\rho$ says whether easier or harder items move more. Fit with `glmer`; standardize by $\sigma_\theta$. *(major)* Sources: De Boeck & Wilson (Eds.) (2004), *Explanatory item response models*, doi:10.1007/978-1-4757-3990-9; Gilbert, Himmelsbach, Soland, Joshi & Domingue (2025), doi:10.1002/pam.70025; Bates, Mächler, Bolker & Walker (2015), `lme4`, doi:10.18637/jss.v067.i01.
4. **Why it matters for the effect estimate.** The average effect on a sum score and on θ can agree closely even when items move very differently; the item spread says how much the estimate depends on which items were written, so it bears on generalizability. And when item effects correlate with difficulty, a treatment-by-pretest interaction in a sum-score model can be spurious (PS7#1's m2 vs. m3a). *(major)* Sources: Ahmed et al. (2024), doi:10.1080/19345747.2024.2361337; Gilbert, Miratrix, Joshi & Domingue (2025), doi:10.3102/10769986241240085.
5. **Is item-level change bias or information?** Items closest to what the intervention taught move most (near vs. far transfer). For evaluating the intervention that can be the signal; for claiming a general gain on the construct it is a threat. The answer depends on the use (Recall `validity-argument`). Group-specific item parameters can also be judged by prediction: do treatment-group parameters predict held-out treatment-group responses better (`ps5/groupdiff_example.R`; the IMV: Domingue et al., 2024, doi:10.1007/s11336-024-09977-2)?
6. **Other experiences.** Occasions (longitudinal invariance across waves) and randomized response formats are the same question with a different "treatment". Sources: Widaman, Ferrer & Conger (2010), doi:10.1111/j.1750-8606.2009.00110.x; Recall `g-theory` and `fa-exploratory` (formats), neither an ancestor: see Open questions.

Crossref-checked 09-24 unless marked.

## Picks up

- DIF, impact vs. bias, MH and logistic regression, the ETS categories; treatment as a grouping variable (from `dif`).
- Measurement invariance via multigroup CFA (from `dif`).
- Treatment indicators and waves in IRW tables (from `irw-data`).
- The construct suggests an intervention (from `constructs`): here we see which items an intervention moves.
- Interpretation depends on the use (from `validity-argument`).
- Occasions as a facet (from `g-theory`, not an ancestor) and response formats as an experiment (from `fa-exploratory` problem 4, not an ancestor): Recalls only.
- Multigroup SEM and invariance (from `sem`, optional).
- Group differences that remain after linking (from `parameter-invariance`, optional; a Recall).

## Promises / leaves open

- Explaining which items move with item features (content alignment, transfer distance) → `explanatory-irt`.
- Life events with real IRW data → unpaid (no bereavement table found in the IRW, 09-24; the spousal-loss study uses HRS data, which the IRW doesn't hold).
- Response shift in health measurement (then-tests, reconceptualization) → unpaid.
- Item-level effects in polytomous outcomes → unpaid (the deep dive is dichotomous only, as in the vignette).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_20` | main example (treatment DIF, pretest vs. posttest) | A Tier 2 fractions intervention for struggling fifth graders (Jayanthi et al., 2021, doi:10.1177/00144029211008851), 186 students, a 37-item pretest (wave 0) and a 93-item posttest (wave 1). Pretest (the placebo): 3 of 37 items show uniform treatment DIF at .05 (none after a false-discovery correction); no detectable item-level heterogeneity (p = 0.22); effect 0.11 SD. Posttest: 13 of 93 items at .05 (6 after correction; 2 C and 8 B on the Jodoin–Gierl ΔR² scale); average effect 1.13 SD on θ in the IL-HTE model, with item-specific effects spread by σ_ζ = 0.70 SD (p ≈ 10⁻³¹). The sum-score and Rasch θ effect sizes agree (0.95 and 0.94). | — |
| `gilbert_meta_37` | contrast (IL-HTE with interpretable content) | Health knowledge after an entertainment-education programme in India (Carpena, 2024, doi:10.1080/00220388.2024.2312832), 21 items, 839 respondents. Average effect 0.48 SD; σ_ζ = 0.28 SD (p = 0.0002); ρ = −0.33. The three night-blindness items move most (item-specific effects 0.68–0.81 logits), while the condom and handwashing items move less (0.12–0.43). Adding IL-HTE hardly changes the treatment-by-baseline interaction here (0.024 vs. 0.020 logits). | — |

The finding the section is built around: before treatment, treatment "DIF" is at chance; after treatment, a handful of items carry much more of the effect than the rest. In `gilbert_meta_37` the items that move are about one topic, which reads like the programme's content (to check against Carpena, 2024, before the lesson says so).

Notes, stated gently in the lesson:
- `gilbert_meta_20`: the pretest and posttest are different forms (37 vs. 93 items), so the placebo check is on the pretest's own items. `gilbert_meta_37`: item text from `irw_itemtext` matches the item ids by topic (checked 09-24: `nightblindness_*` ↔ night-blindness questions); several items are options of one "select all that apply" question, which the lesson should say.
- Instrument reuse status for #63.

**Sanity table.** `gilbert_meta_20` at wave 0: randomization guarantees no treatment effect on any item before treatment, so flags there estimate the false-positive rate (3 of 37 at .05, 0 after correction).

**Deep dive (#26): corpus filter.** Following the IRW vignette (https://itemresponsewarehouse.org/vignettes/il_hte.html): `irw_filter(var = "treat", n_participants = c(100, Inf))`; dichotomous items only; at least 3 items; up to 5,000 respondents; the model `glmer(resp ~ treat + (1|id) + (treat|item))` per table, σ_ζ standardized by σ_θ, and a boundary-corrected likelihood-ratio test. The vignette found significant IL-HTE in 40 of 70 tables. **One change proposed for `compute.R`:** the vignette keeps "wave 1", but wave labels differ across tables (`gilbert_meta_20` codes the pretest 0 and the posttest 1; `gilbert_meta_74` has waves 1 and 2). The script should pick the first post-randomization wave per table from its processing notes, and could use any pretest wave as a per-table placebo. Pilot known-good tables: `gilbert_meta_20` (posttest: strong IL-HTE; pretest: none) and `gilbert_meta_37`.

## Widget / simulation / problem ideas

**Widgets**
- Item effects around an average: set β₁, σ_ζ and ρ; see item-specific effects around the average, the sum-score effect, and which items a short form would keep (ideas 3, 4).
- Pretest placebo: simulated RCT with a pretest and posttest; count DIF flags by wave as the number of items and n change (idea 2).
- The spurious interaction: with ρ ≠ 0 and no true person-level heterogeneity, watch the sum-score treatment × pretest interaction appear (idea 4; Gilbert, Miratrix et al., 2025).

**Predict-then-check:** in the fractions RCT, how many items will show treatment DIF at the pretest, and how many at the posttest? Answered by the two DIF runs (3 of 37 and 13 of 93 at .05; 0 and 6 after correction).

**Simulate:** generate an RCT outcome from the IL-HTE model with known β₁, σ_ζ and ρ; fit the constant-effect and IL-HTE models with `glmer`; compare the recovered σ_ζ and the treatment × pretest interaction with the truth (small n and items so it runs in seconds; say how to scale up locally).

**Problems**
1. Derivation: under the IL-HTE model with ρ = 0, what is the treatment effect on the expected proportion correct for an item with difficulty b? Why do items far from the average θ show smaller raw effects even when every ζ_i = 0?
2. Real data with a twist (PS5#4): estimate the `gilbert_meta_20` posttest effect in raw and effect-size units on the sum score and on θ; then drop the 10 B/C items and re-estimate. How much of the effect do they carry?
3. Real data (PS7#1): fit the treatment × baseline interaction in `gilbert_meta_37` with and without random item slopes on treatment. Does the interaction move? Why is the change small here (look at ρ)?
4. Judgment: the spousal-loss finding (lonely and sad move most). Is the CES-D measuring more depression after bereavement, or measuring it differently? What would you report?
5. Design: you're evaluating a vocabulary intervention. How would you build the outcome so that you can separate near transfer (taught words) from far transfer (untaught words)?
6. Challenge (open): if the items that move are the ones aligned with the intervention, is item-level heterogeneity evidence against the measure's validity for evaluation, or for it?

## Go deeper

- **Why a sum-score interaction can be spurious.** A half-page sketch of the Gilbert, Miratrix et al. (2025) argument: with ρ ≠ 0, treatment stretches the spread of item difficulties, and a constant-item model reads that as a treatment × pretest interaction. Why: `invariance-experience` only, plus `explanatory-irt`; probably a problem rather than a callout. Length: half a page.

## Open questions

- **Recalls from non-ancestors.** `g-theory` (occasions) and `fa-exploratory` (response formats, problem 4) both hand hooks to this lesson, but neither is an ancestor of `dif`. Proposed: brief Recalls ("if you've done…"), no formal threads. Or record threads and accept that some readers won't have seen them?
- **Response formats with real data.** `fa-exploratory` uses `bfi2_zhang_2025`, where respondents were randomized to formats. A problem here could return to it as a deliberate thread (`reuses: [bfi2_zhang_2025]`). Worth it, or leave formats as a Recall?
- **Life events.** No bereavement or life-event table in the IRW (searched 09-24). The spousal-loss result stays as a cited example from Domingue et al. (2021). OK, or is there HRS-derived item-level data that could become an IRW table?
- **The deep dive's wave rule.** Adopt the per-table first-post-randomization wave in `compute.R` (and suggest the same change to the IL-HTE vignette)?
