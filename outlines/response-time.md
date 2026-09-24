<!-- Outlined 2026-09-24 from EDUC 252 c9 (slides 24–54, 57), PS9#1 and ps9/sat.R. Deep dive #24 is homed here. No PISA subsample (digest A4), so credentialform_lnirt replaces PS9#1's pisa2018_read. Tidied 09-24 (#62): Ben's answer E8b applied (no first-person criticism of the hierarchical model; its assumptions become a question the data answer). -->

# Response time and the speed–accuracy tradeoff (`response-time`)

Module: beyond · Prereqs: explanatory-irt · Extension · Status: outline

## Core ideas

1. **Response time is data, and it is skewed.** Model log time: $\log t_{ij} = \beta_i - \tau_j + \varepsilon_{ij}$ (item time intensity $\beta_i$, person speed $\tau_j$), a crossed random-effects model like those in `explanatory-irt`. *(major)* Sources: van der Linden (2006), doi:10.3102/10769986031002181; Thissen (1983), doi:10.1016/b978-0-12-742780-5.50019-6.
2. **The hierarchical model, and what it assumes.** An IRT model for accuracy, the lognormal model for time, and a second level correlating θ with τ (and b with β). It buys better estimates and the speed–ability correlation, *if* two assumptions hold: each respondent works at one constant speed, and given θ and τ, speed and accuracy are conditionally independent. The lesson asks whether they hold and lets the tables answer (ideas 4 and 5). *(major)* Sources: van der Linden (2007), doi:10.1007/s11336-006-1478-z; Klein Entink, Fox & van der Linden (2009), doi:10.1007/s11336-008-9075-y; `LNIRT`: Fox, Klotzke & Simsek (2023), doi:10.7717/peerj-cs.1232; De Boeck & Jeon (2019), doi:10.3389/fpsyg.2019.00102.
3. **The speed–accuracy tradeoff is a within-person claim.** Forced to go faster, a person gets less accurate. That says nothing about whether fast *people* are more able; the between-person correlation can take either sign. *(major)* Sources: Heitz (2014), doi:10.3389/fnins.2014.00150; Goldhammer et al. (2014), doi:10.1037/a0034716.
4. **Does conditional independence hold? The conditional accuracy function.** Remove person and item effects, then ask how an unusually slow response relates to accuracy. Under the model the answer is "not at all"; across the tables the curve rises, falls or is an inverted U. *(major)* Sources: Bolsinova, De Boeck & Tijmstra (2017), doi:10.1007/s11336-016-9537-6; Domingue et al. (2022), doi:10.3102/10769986221099906.
5. **Is speed constant? Speed changes over a test.** Response acceleration in an adaptive test: a response 10 positions later takes about 88% as long (slides 30–33); very fast responses at chance are rapid guesses. Sources: Domingue, Kanopka, Stenhaug, Soland, Kuhfeld & Wise (2021), doi:10.1111/jedm.12291; Wise & Kong (2005), doi:10.1207/s15324818ame1802_2.

**Verdict (proposed, for Ben to confirm):** I'd model response time when the question is about how people take the test (rapid guessing, speededness, a time limit), not to sharpen θ. Across the IRW, adding response time barely improves prediction of accuracy (median IMV gain 0.0054, `rt_imv` vignette).

Articles checked on Crossref (09-24); Thissen (1983) is a chapter whose Crossref record matches the publisher's.

## Picks up

- Items as fixed or random effects in long data; log RT as a second outcome with the same machinery (from `explanatory-irt`).
- The Rasch item response function (from `rasch`); the 2PL's $a$ appears only in passing.
- Response times beside `resp`; errors slower than correct in `rr98_accuracy` (from `irw-data`).
- Brief Recalls (E2; restated, not threads; digest E1): in `roar_lexical`, 3.1% of responses come in under 0.3 s at accuracy 0.51 (`guessing-priors`); the IMV (`fit-prediction`), for the deep dive.

## Promises / leaves open

- Process models that generate the response and its time together → `rt-process-models`.
- Rapid guessing as a latent class (a mixture) → unpaid.
- Using RT to flag aberrant behaviour (`credentialform_lnirt` flags 46 respondents) → unpaid; a problem (van der Linden & Guo, 2008, doi:10.1007/s11336-007-9046-8).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `credentialform_lnirt` | main example | Licensure exam (Cizek & Wollack, 2016, from IRW biblio): 1,636 respondents, median 54 s per item. More able respondents are faster (θ–speed r = 0.30); harder items take longer (b–β r = 0.51); log-time variance mostly within person (0.25 vs. person 0.03, item 0.11). Slower than expected goes with lower accuracy: 0.83 in the fastest residual decile, 0.56 in the slowest. | — |
| `roar_lexical` | contrast | Lexical decision, median 0.85 s. θ–speed r = −0.09; the within-person curve is an inverted U (0.63, 0.86, 0.70), its fast end the rapid guessing restated from `guessing-priors`. | `guessing-priors` (recorded under `reuses:`) |
| `rapm_poulton_2022_timed` + `_untimed` | contrast (forced speed; one job, two tables, agreed by Ben 09-24) | Raven's APM, 12 items. Timed (60 s/item, 479 people): 11% hit the limit, at 0.29 accuracy; able people are *slower* (r = −0.36). Untimed (567): accuracy 0.65 vs. 0.55; hard items lose most (item 10: 0.45 → 0.25). | — |
| `rr98_accuracy` | sanity | Errors slower than correct (0.65 vs. 0.56 s), as published. | `irw-data`, `trials` |

**The finding:** the speed–ability correlation has no fixed sign (+0.30, −0.09, −0.36) and the within-person curve no fixed shape. On the licensure exam and in lexical decision, an unusually slow response predicts accuracy, in different shapes, so conditional independence doesn't hold there (idea 4). The constant-speed check on these tables (log time by item position, e.g. in `credentialform_lnirt`) is to be computed when drafting; until then idea 5 rests on the cited acceleration result.

**Deep dive #24 (Across the IRW).** `irw_filter(var = "rt", n_categories = 2, n_participants = c(150, Inf))`, 20 tables today (150 for stable crossed random effects; dichotomous for one accuracy model). Per table: θ–speed and b–β correlations, and the IMV gain from centred log RT. The vignette reports median gains of 0.0054 (78% positive) and 0.0091 (94%). Pilot: `chess_lnirt`, `credentialform_lnirt`. Vignette: <https://itemresponsewarehouse.org/vignettes/rt_imv.html>.

## Widget / simulation / problem ideas

**Widgets**
- Raw vs. log time: lognormal generator, histograms of $t$ and $\log t$ (idea 1).
- Between vs. within: persons with speed–ability correlation ρ and within-person slope δ, of opposite signs if you like (ideas 2, 3).
- Conditional accuracy function: choose a shape; see the binned residual-time plot the real-data section uses (idea 4).
- Response acceleration: time per item × 0.88 per 10 positions (idea 5).

**Predict-then-check:** on the licensure exam, are respondents who take longer than usual more or less likely to be right? (0.83 → 0.56; −1.03 logits per unit of residual log time.)

**Simulate:** generate from the hierarchical model with conditional independence; fit accuracy (`glmer`) and log time (`lmer`); recover ρ; the within-person slope is near zero, as it should be. Then add a within-person SAT and watch it appear. 200 × 20, seconds.

**Problems**
1. Derivation: under the lognormal model the median time is $\exp(\beta_i - \tau_j)$ and the mean is larger by $\exp(\sigma^2/2)$. Why report medians?
2. Real data with a twist (PS9#1): `resp ~ lrt + (1|item) + (1|id)` on `roar_lexical`, then with log time centred within person and item. Which slope answers the SAT question?
3. Real data: the 46 flagged licensure respondents barely differ on means (0.71 vs. 0.72). What would preknowledge leave that means can't show?
4. Judgment: should a program report a speed score beside ability? Use the three tables.
5. Design: a per-item or a per-test time limit: which lets you study the SAT?
6. Challenge (open): propose one process that gives an inverted U in lexical decision and a falling curve on the licensure exam (`rt-process-models` takes one route).

## Go deeper

- **Within-person slopes are identified; the between-person correlation isn't causal.** Under the hierarchical model, a between-person ρ leaves the within-person slope at zero. Why: `rt-process-models`, `explanatory-irt`. Half a page.

## Open questions

- The verdict above (when to model response time) is proposed for the lesson in place of the slide-29 aside, per E8b. *Default:* use it unless you'd put it differently.
