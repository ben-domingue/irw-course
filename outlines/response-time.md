<!-- Outlined 2026-09-24 from EDUC 252 slides c9 (slides 24–54, 57), PS9#1 and ps9/sat.R. Deep dive #24 is homed here. -->

# Response time and the speed–accuracy tradeoff (`response-time`)

Module: beyond · Prereqs: explanatory-irt · Optional · Status: outline

## Core ideas

1. **Response time is data, and it is skewed.** Digital delivery records how long every response took. Times have a long right tail (some respondents walk away), so we model log time: $\log t_{pi} = \beta_i - \tau_p + \varepsilon_{pi}$, with item time intensity $\beta_i$ and person speed $\tau_p$. This is a crossed random-effects model like the ones in `explanatory-irt`. *(major)* Sources: van der Linden (2006), doi:10.3102/10769986031002181; Thissen (1983), "Timed testing: An approach using item response theory", in *New Horizons in Testing* (Academic Press), 179–203, doi:10.1016/b978-0-12-742780-5.50019-6.
2. **The hierarchical model: speed and ability as two person traits.** An IRT model for accuracy, the lognormal model for time, and a second level that correlates θ with τ (and b with β). What it buys, if its assumptions hold: better estimates and the speed–ability correlation. What I don't like about it: it assumes each person works at one constant speed. *(major)* Sources: van der Linden (2007), doi:10.1007/s11336-006-1478-z; Klein Entink, Fox & van der Linden (2009), doi:10.1007/s11336-008-9075-y; Fox, Klotzke & Simsek (2023), the `LNIRT` package, doi:10.7717/peerj-cs.1232; De Boeck & Jeon (2019), overview, doi:10.3389/fpsyg.2019.00102; Kyllonen & Zu (2016), doi:10.3390/jintelligence4040014.
3. **The speed–accuracy tradeoff is a within-person claim.** Force someone to go faster and they get less accurate. That says nothing about whether fast *people* are more or less able; the between-person correlation can take either sign. *(major)* Sources: Heitz (2014), doi:10.3389/fnins.2014.00150; Goldhammer et al. (2014) on time-on-task, doi:10.1037/a0034716.
4. **Don't assume the SAT when nobody invoked it.** Condition on the person and the item, then ask how an idiosyncratic slowdown relates to accuracy (the conditional accuracy function). Across real data the shape is heterogeneous: rising, falling, inverted U. Treat RT as something to explore, not something to cram into the first model you think of (slides 49–54). Sources: Domingue et al. (2022), *JEBS* 47(5), 576–602, doi:10.3102/10769986221099906; Bolsinova, De Boeck & Tijmstra (2017) on conditional dependence, doi:10.1007/s11336-016-9537-6; Gilbert, Young, Himmelsbach, Ulitzsch & Domingue (2025), RT and discrimination across the IRW (PsyArXiv, doi:10.31234/osf.io/rp34w_v3).
5. **Speed varies within a person over the test.** Response acceleration in an adaptive test: a response 10 positions later takes about 88% as long (slides 30–33). Very fast responses at chance are rapid guesses. Sources: Domingue, Kanopka, Stenhaug, Soland, Kuhfeld & Wise (2021), doi:10.1111/jedm.12291; Wise & Kong (2005), doi:10.1207/s15324818ame1802_2; Schnipke & Scrams (1997), doi:10.1111/j.1745-3984.1997.tb00516.x.

Articles checked on Crossref (09-24). Thissen (1983) is a book chapter; its Crossref record matches the publisher's.

## Picks up

- Crossed random effects for persons and items (`glmer`/`lmer`), item covariates (from `explanatory-irt`).
- The Rasch/2PL item response function, θ and b (from `rasch`, `1pl-to-4pl`).
- Response times as a column beside `resp`; errors slower than correct in `rr98_accuracy` (from `irw-data`).
- Rapid responses at chance in `roar_lexical`, 3.1% of responses under 0.3 s at accuracy 0.51 (from `guessing-priors`). `guessing-priors` isn't an ancestor via `explanatory-irt`, so the lesson restates the finding in a sentence and links back (see Open questions).
- Out-of-sample comparison and the IMV (from `fit-prediction`), used in the deep dive. Also not an ancestor; restated briefly.

## Promises / leaves open

- Process models that generate the response and its time together (drift diffusion, race models) → `rt-process-models`.
- Rapid guessing as a latent class of responses (a mixture) → unpaid (the same hook `guessing-priors` leaves open).
- Using RT to flag aberrant behaviour (preknowledge, cheating); `credentialform_lnirt` carries a flag for 46 candidates → unpaid (a Problem only; van der Linden & Guo, 2008, doi:10.1007/s11336-007-9046-8).
- Timing information in adaptive testing (item selection, speededness) → `item-banks-cat` (mention only).
- Omitted and not-reached responses as information → `irtrees`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `credentialform_lnirt` | main example | A licensure exam distributed with the `LNIRT` package (Cizek & Wollack, 2016, from IRW biblio): 1,636 candidates, 170 common items plus one of three 10-item pretest blocks (so 20 responses per person are missing by design). Median time 54 s per item. Separate calibration of the two halves of the hierarchical model: more able candidates are faster (θ–speed r = 0.30); harder items take longer (b–β r = 0.51); log-time variance is mostly within person (residual 0.25 vs. person 0.03, item 0.11). Within person, taking longer than expected goes with *lower* accuracy: 0.83 in the fastest residual decile, 0.56 in the slowest. | — |
| `roar_lexical` | contrast (deliberate thread from `guessing-priors`) | Lexical decision, median 0.85 s. Speed and ability are nearly unrelated (r = −0.09), and the within-person curve is an inverted U: 0.63 accuracy in the fastest residual decile, 0.86 in the middle, 0.70 in the slowest. The fast end is the rapid guessing found in `guessing-priors`. | `guessing-priors` (record under `reuses:`) |
| `rapm_poulton_2022_timed` | contrast (forced speed) | Raven's APM, 12 items, 60-s limit per item (Poulton et al., 2022; first wave, 479 people). The limit is the SAT by design: 11% of responses hit it, at accuracy 0.29 vs. 0.58 otherwise. Here able people are *slower* (θ–speed r = −0.36): on hard reasoning items, persistence pays. | — |
| `rr98_accuracy` | sanity (not in the lesson) | Ratcliff & Rouder (1998): errors slower than correct responses (median 0.65 vs. 0.56 s), and harder conditions slower, as published. Checks the RT handling before trusting the fits above. | `irw-data`, `trials` |

**The finding the section is built around:** the speed–ability correlation has no fixed sign (+0.30 on the licensure exam, −0.09 in lexical decision, −0.36 on Raven's), and the within-person curve has no fixed shape. The SAT is one possible story, not the default.

**Deep dive #24 (Across the IRW).** Corpus: `irw_filter(var = "rt", n_categories = 2, n_participants = c(150, Inf))`, 20 tables today (150 respondents for stable crossed random effects, as in the IRW `rt_imv` vignette; dichotomous so one accuracy model serves all; the default density filter keeps mostly complete designs). For each table: the θ–speed and b–β correlations from separate calibration, and the IMV gain from adding within-item-centred log RT (linear and spline) to the random-item Rasch model, as the vignette does. The vignette reports a median linear IMV gain of 0.0054 (78% of 18 tables positive) and a spline gain of 0.0091 (94%). Known-good pilot tables: `chess_lnirt` (θ–speed r = +0.50, clear negative within-person slope) and `credentialform_lnirt`. Vignette: <https://itemresponsewarehouse.org/vignettes/rt_imv.html>.

**Why not PISA.** 252's PS9#1 used `pisa2018_read` (Spain). It has no tokenless CSV (17.6 million responses) and no IRW biblio reference, and Ben (09-24) doesn't expect the #15 subsample soon. `credentialform_lnirt` does the same job (a high-stakes test with minute-scale items). PISA would still be the preferred example if #15 lands, since it is the test readers know.

Other tables checked and passed over: `chess_lnirt` (the corpus pilot instead; it is already in three lessons), `much_tte_2025_matrixreasoning` (a two-group design that needs the paper to interpret), `rapm_poulton_2022_untimed` (a fourth table; see Open questions).

## Widget / simulation / problem ideas

**Widgets**
- Raw vs. log time: a lognormal generator with sliders for time intensity, speed and σ; histograms of $t$ and $\log t$ (idea 1).
- Between vs. within: simulate people whose speed and ability correlate at ρ, each with a within-person SAT slope of δ; the scatter of person means shows ρ, the within-person lines show δ, and they can have opposite signs (ideas 3, 4).
- Conditional accuracy function: choose a shape (flat, rising, falling, inverted U) for the within-person curve; the widget shows the binned residual-time plot the real-data section uses (idea 4).
- Response acceleration: time per item falls by a factor per 10 positions (0.88 in slides 30–31); the cumulative time saved over 30 items (idea 5).

**Predict-then-check:** "On the licensure exam, will candidates who take longer than usual on an item be more or less likely to get it right?" Answered by the residual-decile accuracies (0.83 → 0.56) and the within-person slope (−1.03 logits per unit of residual log time).

**Simulate:** generate from the hierarchical model (θ, τ correlated at ρ; b, β correlated) with no within-person dependence; fit accuracy with `glmer` and log time with `lmer`; recover ρ from the person random effects; then show that the within-person slope is near zero, as it should be (slides 44–46). Then add a true within-person SAT and watch the slope appear. 200 people × 20 items runs in seconds.

**Problems**
1. Derivation: under the lognormal model, show that the median time for person $p$ on item $i$ is $\exp(\beta_i - \tau_p)$ and that the mean is larger by $\exp(\sigma^2/2)$. Why report medians?
2. Real data with a twist (PS9#1): fit `resp ~ lrt + (1|item) + (1|id)` to `roar_lexical`. Then replace `lrt` with log time centred within person and item. Why do the two slopes differ, and which answers the SAT question?
3. Real data: in `credentialform_lnirt`, compare the 46 flagged candidates with the rest on speed and accuracy. The means barely differ (0.71 vs. 0.72 correct). What pattern would preknowledge leave that means can't show?
4. Judgment: a testing program wants to report a "speed" score beside the ability score. Using the three tables' θ–speed correlations, argue for or against.
5. Design: you can impose a time limit per item or per test. Which lets you study the SAT, and what would the data look like?
6. Challenge (open): the within-person curve is an inverted U in lexical decision and falling on the licensure exam. Propose a model in which both come from the same process. (`rt-process-models` takes one route.)

## Go deeper

- **Why the within-person slope is identified and the between-person one isn't causal.** With person and item effects removed, the residual time varies only within person; a short derivation that a between-person correlation ρ leaves the within-person slope at zero under the hierarchical model. Why: `rt-process-models`, `explanatory-irt` (between vs. within), `validity-causal` (Borsboom's within/between point). Length: half a page.

## Open questions

- `roar_lexical` is reused from `guessing-priors` (recorded under `reuses:`). `guessing-priors` isn't an ancestor of this lesson. Restate the rapid-guessing finding (my plan), or add `guessing-priors` as a prerequisite?
- The timed/untimed comparison is the cleanest forced-speed evidence: on the same 12 Raven's items, the hard ones lose most under the 60-s limit (item 10: 0.45 untimed → 0.25 timed; untimed median time 82 s), the easy ones least (item 6: 0.69 → 0.65). It needs `rapm_poulton_2022_untimed` as a fourth table. Allow the pair as one job, or keep it to a Problem with the untimed table named but not analysed?
- 252 used PISA 2018 reading from Spain; Ben (09-24) doesn't expect the #15 subsample soon, so this outline plans on `credentialform_lnirt`. Revisit if #15 lands?
- Slide 29: "I don't much like this model." Keep the first-person objection (constant speed within person) as the lesson's verdict?
