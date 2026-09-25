<!-- Outlined 2026-09-24 from EDUC 252 PS5#4 and PS7#1, with the code in ps5/rctdif.R, ps5/groupdiff_example.R and ps7/ilhte.R. Deep dive #26 (item-level treatment effects across RCTs). Scope (Ben, 09-24, #45): IL-HTE stays here as an extension after dif, framed explicitly as DIF with treatment as the group. -->

# Measurement invariance under treatment and life events (`invariance-experience`)

Module: fairness · Prereqs: dif · Extension · Status: drafted (09-25, #45)

## Core ideas

1. **Experience can change how a measure works.** After spousal loss, depressive symptoms rise over the first months and return to their earlier level within about two years, but not evenly: the CES-D's "lonely" and "sad" items carry most of the rise (PS5#4). More depression, or a different measure of it? Alpha, beta and gamma change; response shift. Occasions (longitudinal invariance) and randomized response formats are the same question with a different "treatment": one paragraph, with "if you've done" Recalls of `g-theory` and `fa-exploratory`'s format experiment (E2, E4). *(major)* Sources: Domingue, Duncan, Harrati & Belsky (2021), doi:10.1093/geronb/gbaa044 (Figure 1 and the supplement's item-level figure, **to recheck**); Golembiewski, Billingsley & Yeager (1976), doi:10.1177/002188637601200201; Sprangers & Schwartz (1999), doi:10.1016/S0277-9536(99)00045-3; Widaman, Ferrer & Conger (2010), doi:10.1111/j.1750-8606.2009.00110.x.
2. **Treatment assignment as a DIF group, with the pretest as a placebo.** Randomization makes treatment the cleanest grouping variable: no impact before treatment, so the pretest should show no treatment DIF, and DIF at posttest is caused by the intervention. *(major)* Sources: Recall `dif` (idea 4); Gilbert, Kim & Miratrix (2023), doi:10.3102/10769986231171710.
3. **The IL-HTE model.** A random item slope on treatment: $\text{logit}\Pr(x_{ij}=1) = \theta_j + b_i + \zeta_i T_j$, $\theta_j = \beta_0 + \beta_1 T_j + \varepsilon_j$, with $(b_i, \zeta_i)$ bivariate normal. $\sigma_\zeta$ is the spread of item-specific effects around $\beta_1$; $\rho$ says whether easier or harder items move more. Fit with `glmer`; standardize by $\sigma_\theta$. *(major)* Sources: De Boeck & Wilson (Eds.) (2004), doi:10.1007/978-1-4757-3990-9; Gilbert, Himmelsbach, Soland, Joshi & Domingue (2025), doi:10.1002/pam.70025; Bates, Mächler, Bolker & Walker (2015), `lme4`, doi:10.18637/jss.v067.i01.
4. **Why it matters for the effect estimate.** Sum-score and θ effects can agree even when items move very differently; the item spread says how much the estimate depends on which items were written (generalizability). When item effects correlate with difficulty, a treatment × pretest interaction in a sum-score model can be spurious (PS7#1). *(major)* Sources: Ahmed et al. (2024), doi:10.1080/19345747.2024.2361337; Gilbert, Miratrix, Joshi & Domingue (2025), doi:10.3102/10769986241240085.
5. **Is item-level change bias or information?** Items closest to what the intervention taught move most (near vs. far transfer). For evaluating the intervention that can be the signal; for claiming a general gain it is a threat. The answer depends on the use (Recall `validity-argument`). Group-specific item parameters can also be judged by prediction (the IMV: Domingue et al., 2024, doi:10.1007/s11336-024-09977-2; `ps5/groupdiff_example.R`).

Crossref-checked 09-24 unless marked.

## Picks up

- DIF, impact vs. bias, MH and logistic regression, the ETS categories; treatment as a grouping variable (from `dif`).
- Treatment indicators and waves in IRW tables (from `irw-data`).
- Interpretation depends on the use; the same scores for evaluating an intervention vs. measuring the construct (from `validity-argument`).
- The construct suggests an intervention; here we see which items it moves (from `constructs`).
- Multigroup CFA and invariance (from `fa-confirmatory`, not an ancestor: an "if you've done" Recall, E2).
- Occasions as a facet (from `g-theory`, not an ancestor: E2) and response formats as an experiment (from `fa-exploratory`, not an ancestor: a Recall of its finding, no table reuse, E4).
- Group differences that remain after linking (from `parameter-invariance`, extension: E2).
- Multigroup SEM (from `sem`, extension: E2).
- Reliable change assumes the same construct at both waves (from `score-meaning`, not an ancestor: E2).
- Treatment as a grouping variable; impact vs. bias (from `fairness`, via `dif`).

## Promises / leaves open

- Explaining which items move with item features (content alignment, transfer distance) → `explanatory-irt`.
- Life events with real IRW data → unpaid (no bereavement table in the IRW, 09-24; the spousal-loss result stays a cited figure, E5).
- Response shift in health measurement (then-tests, reconceptualization) → unpaid.
- Item-level effects in polytomous outcomes → unpaid (the deep dive is dichotomous only, as in the vignette).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_20` | main example (treatment DIF, pretest vs. posttest) | A Tier 2 fractions intervention for struggling fifth graders (Jayanthi et al., 2021, doi:10.1177/00144029211008851), 186 students, a 37-item pretest (wave 0) and a 93-item posttest (wave 1). Pretest (placebo): 3 of 37 items show treatment DIF at .05 (none after a false-discovery correction); no item-level heterogeneity (p = 0.22); effect 0.11 SD. Posttest: 13 of 93 at .05 (6 after correction; 2 C and 8 B on the ΔR² scale of Jodoin & Gierl, 2001, doi:10.1207/S15324818AME1404_2); average effect 1.13 SD on θ, σ_ζ = 0.70 SD (p ≈ 10⁻³¹). Sum-score and Rasch θ effect sizes agree (0.95, 0.94). | — |
| `gilbert_meta_37` | contrast (IL-HTE with interpretable content) | Health knowledge after an entertainment-education programme in India (Carpena, 2024, doi:10.1080/00220388.2024.2312832), 21 items, 839 respondents. Average effect 0.48 SD; σ_ζ = 0.28 SD (p = 0.0002); ρ = −0.33. The three night-blindness items move most (0.68–0.81 logits), the condom and handwashing items less (0.12–0.43). IL-HTE hardly changes the treatment-by-baseline interaction here (0.024 vs. 0.020 logits). | — |

The finding: treatment "DIF" is at chance before treatment; after it, a handful of items carry much of the effect. In `gilbert_meta_37` they share one topic, which reads like the programme's content (to check against Carpena, 2024).

Notes, stated gently: `gilbert_meta_20`'s two waves are different forms, so the placebo uses the pretest's own items. In `gilbert_meta_37`, item text matches the ids (checked 09-24); several items are options of one "select all that apply" question.

**Sanity table.** `gilbert_meta_20` at wave 0: flags there estimate the false-positive rate (3 of 37 at .05, 0 after correction).

**Deep dive (#26): corpus filter.** As in the IRW vignette (https://itemresponsewarehouse.org/vignettes/il_hte.html): `irw_filter(var = "treat", n_participants = c(100, Inf))`; dichotomous; at least 3 items; up to 5,000 respondents; `glmer(resp ~ treat + (1|id) + (treat|item))`, σ_ζ in SDs of θ, boundary-corrected LRT (vignette: 40 of 70 tables significant). **Wave rule (F10, adopted):** the first post-randomization wave per table from its processing notes, not "wave 1" (`gilbert_meta_20` codes the pretest 0; `gilbert_meta_74` has waves 1 and 2); any pretest wave serves as a placebo. The same fix goes to the IRW vignette as an IRW issue. Pilot known-good tables: `gilbert_meta_20`, `gilbert_meta_37`.

## Widget / simulation / problem ideas

**Widgets**
- Item effects around an average: set β₁, σ_ζ and ρ; see item-specific effects, the sum-score effect, and which items a short form would keep (ideas 3, 4).
- Pretest placebo: DIF flags by wave in a simulated RCT as items and n change (idea 2).
- The spurious interaction: with ρ ≠ 0 and no person-level heterogeneity, watch the sum-score treatment × pretest interaction appear (idea 4).

**Predict-then-check:** in the fractions RCT, how many items will show treatment DIF at the pretest, and how many at the posttest? Answered by the two DIF runs (3 of 37 and 13 of 93 at .05; 0 and 6 after correction).

**Simulate:** an RCT outcome from the IL-HTE model with known β₁, σ_ζ and ρ; fit constant-effect and IL-HTE models with `glmer`; compare recovered σ_ζ and the treatment × pretest interaction with the truth (small sizes in the browser; say how to scale up).

**Problems**
1. Derivation: under IL-HTE with ρ = 0, the effect on the expected proportion correct for an item with difficulty b. Why do items far from the average θ show smaller raw effects even when every ζ_i = 0?
2. Real data with a twist (PS5#4): the `gilbert_meta_20` posttest effect on the sum score and on θ; drop the 10 B/C items and re-estimate. How much of the effect do they carry?
3. Real data (PS7#1): the treatment × baseline interaction in `gilbert_meta_37` with and without random item slopes on treatment. Why is the change small here (look at ρ)?
4. Judgment: the spousal-loss finding (lonely and sad move most). More depression after bereavement, or depression measured differently? What would you report?
5. Design: an outcome for a vocabulary intervention that separates near transfer (taught words) from far transfer (untaught words).
6. Challenge (open): if the items that move are those aligned with the intervention, is item-level heterogeneity evidence against the measure's validity for evaluation, or for it?

## Go deeper

- **Why a sum-score interaction can be spurious.** A half-page sketch of Gilbert, Miratrix et al. (2025): with ρ ≠ 0, treatment stretches the spread of item difficulties, and a constant-item model reads that as a treatment × pretest interaction. Why: this lesson, `explanatory-irt`. Length: half a page.

## Open questions

- None. Settled 09-24: non-ancestor Recalls as "if you've done" (E2); response formats as a Recall, no `bfi2_zhang_2025` reuse (E4); spousal loss stays a cited figure (E5); the deep dive's wave rule (F10).

## Drafting notes (09-25, #45)

What changed from this outline while drafting, and why:

- **Waves in `gilbert_meta_20`.** The posttest (wave 1) repeats all 37 pretest items and adds 56 (`tuf5`, more procedures, `trans_math`), so the two waves are not different forms. The placebo compares the same 37 items before and after, as well as the full 93.
- **DIF test.** Uniform DIF only (1-df likelihood-ratio test, $\Delta R^2$ from M0 to M1), since a shift in one item's treatment effect is uniform DIF; complete cases. Numbers: pretest 3 of 37 at .05 (1.9 by chance), 0 after Benjamini–Hochberg, but all 3 reach B on $\Delta R^2$ (the categories are generous at n = 186); posttest 12 of 93, 5 after correction, 8 B and 2 C; the 37 repeated items at posttest 9, 5 after correction. The predict-then-check asks about the 37 repeated items.
- **Effect sizes.** Sum score 1.08 within-arm SDs, $\theta$ 1.11 (constant effect) and 1.13 (IL-HTE); $\sigma_\zeta$ 0.70 SD (0.59 logits). Pretest $\sigma_\theta$ is 0.31 logits (students selected in a narrow band), so the pretest's $\sigma_\zeta$ in SDs (0.59, p = 0.22) is stated in logits too.
- **$\rho$ sign.** The lesson's $\rho$ is the correlation of $\zeta_i$ with *difficulty* $b_i$ (notation.md), so it is the negative of what `lme4` prints and of the vignette's $\rho$ (which uses easiness). `gilbert_meta_37`: $\rho$ = +0.33.
- **Spousal loss (E5).** Checked: the published paper says the depressive rise attenuated within one year (not two); the loneliness/sadness result is in the medRxiv preprint (doi:10.1101/19009878), citing its Supplemental Figures S7–S8. The published supplement was not checked.
- **Night blindness (digest D).** Checked against Carpena (2024), Supplementary Material A and the replication tables: night blindness was module 5 of 5 (one VHAI film); the paper's own longer-term results by topic have night blindness with the largest effect and the lowest control mean. The IRW table is the endline (10 months) survey; `treat` pools the two film arms (HEE, HEEC) against the placebo arm; `std_baseline` closely tracks the number right on three baseline knowledge items.
- **Alpha/beta/gamma.** Definitions checked against Livingston et al. (2022, doi:10.1007/s41542-022-00122-y) and Jabrayilov et al. (2017, doi:10.1007/s11136-017-1500-1); Golembiewski et al. (1976) is paywalled, abstract only.
- **Widgets.** Three: the pretest placebo (MH by treatment at two waves), item effects around an average (with short forms), and the spurious interaction (population expected sum scores, no sampling noise). Go deeper as planned.
- **Deep dive (#26).** `compute.R` follows the vignette, with the F10 wave rule (processing notes where checked, else "wave 0 is a pretest", else the smallest wave; recorded per table) and pretest waves fitted as placebos; no density filter (longitudinal tables have density > 1). PILOT run only (5 tables: 3 fitted, 2 failed for having no dichotomous items); the partial-run callout shows.
- **IMV.** Mentioned in one sentence (idea 5) rather than worked, to keep the length.
