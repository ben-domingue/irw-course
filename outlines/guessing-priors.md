<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 33, 60–61), PS4#3 and #4, ps4/guessing.R and ps4/priors.R. Tidied 09-24 (#62): Ben's answers applied (C15, E4); pick-ups checked against the drafted `likelihood` and `rasch`. -->

# Guessing and priors (`guessing-priors`)

Module: irt · Prereqs: ability-estimation, fit-prediction · Extension · Status: outline

## Core ideas

1. **What does the 3PL's lower asymptote learn from the data?** It is informed only by low-ability respondents on hard items; on easy tests it drifts to zero whatever the number of options (the RMET in `1pl-to-4pl`). Out of sample, the 3PL's gain over the 2PL is at most 0.001 in IMV, even when the 3PL generated the data (slide 61), and its parameters have known identification problems. The lesson poses this as a question about the model's assumptions that the data answer, not as a verdict on the model. *(major)* Sources: Domingue, Kanopka, Kapoor, Pohl, Chalmers, Rahal & Rhemtulla (2024), *Psychometrika* 89(3), 1034–1054, doi:10.1007/s11336-024-09977-2 (§3 and the Table 1 discussion; C15); Maris & Bechger (2009), doi:10.1080/15366360903070385.
2. **Fix guessing from the item's structure.** When the chance rate is known (two alternatives in lexical decision, four options in multiple choice), impose it: the 1PL-G, a Rasch model with a fixed lower asymptote. Nothing extra is estimated. *(major)* Sources: San Martín, del Pino & De Boeck (2006), doi:10.1177/0146621605282773; Han (2012), *Practical Assessment, Research, and Evaluation* 17, Article 1 (no DOI; ERIC EJ977575; fixing $c = 1/k$ performed well).
3. **Guessing may belong to respondents, not items.** Rapid guessing shows up in response times: responses too fast to reflect processing, answered at chance. *(major)* Source: Wise & Kong (2005), doi:10.1207/s15324818ame1802_2.
4. **Priors keep estimates well behaved.** A posterior is likelihood times prior (as for abilities in `ability-estimation`); with small samples, lognormal priors on slopes and beta priors on $c$ pull wild estimates back. A conceptual guide, not a full Bayesian treatment. Sources: Mislevy (1986), doi:10.1007/bf02293979; Harwell & Baker (1991), doi:10.1177/014662169101500409.
5. **Judge it by prediction.** Whether fixing guessing or adding priors helps is a question for held-out data (PS4#3 bonus). Thread from `fit-prediction`.

DOIs Crossref-checked 09-24.

**Verdict (voice rule A; C15, and the rule on other researchers' models):** on the practitioner's choice, verdict first: "On tests like these I wouldn't estimate $c$. If the chance rate is known, fix it; otherwise fit the 2PL and check out of sample." (Proposed wording.) Not a verdict on the 3PL as a model.

**Across the IRW (deep dive #22, home here):** across multiple-choice tables, which guessing correction improves out-of-sample prediction; the [guessing vignette](https://itemresponsewarehouse.org/vignettes/guessing.html).

## Picks up

- The 3PL, its lower asymptote, `mirt`'s parameterization; the RMET's median $c$ of 0.05 (from `1pl-to-4pl`).
- Out-of-sample prediction and the IMV (from `fit-prediction`).
- The Bayesian reading of the likelihood (from `likelihood`).
- Response times as data beside responses (from `irw-data`).
- Priors on abilities; EAP and shrinkage (from `ability-estimation`).
- Information, and where guessing costs it (from `information`).

## Promises / leaves open

- Response times modelled jointly with accuracy → `response-time` (which restates the rapid-guessing finding; `roar_lexical` reuse recorded there).
- Skipped responses carry information → `irtrees` (simulation and a problem only there).
- Guessing as a property of respondents: the nominal model's "don't know" class → `nominal`; mixtures otherwise unpaid.
- EM with priors on item parameters: `item-estimation` has the machinery; a sibling, so each restates what it needs (E2), no hook.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `roar_lexical` | main example | ROAR lexical decision (Yeatman et al., 2021, doi:10.1038/s41598-021-85907-x): 123 respondents, 500 real and made-up words, two choices, so chance is 0.5; accuracy 0.80. The Rasch model and the 1PL-G with $c = 0.5$ give abilities that correlate 0.97, but the 1PL-G spreads difficulties out (SD 0.8 → 2.0) and fits better (log likelihood −25,561 → −25,362) with no extra parameters. 3.1% of responses come faster than 0.3 s, and those are at chance (accuracy 0.51 vs. 0.81). | `response-time` (deliberate reuse, recorded there) |
| `vocabulary_iq` | contrast (priors) | Open Psychometrics Vocabulary IQ Test (items 1–45; CC BY 4.0), 2,802 complete. The 3PL fitted to 300 respondents without priors gives wild slopes (SD 3.8, six above 5); with the 252 priors (lognormal on $a$, beta on $c$), SD 1.2, and the error against the full-sample estimates drops from 3.5 to 0.84. The items are easy (median p = 0.90), and full-sample guessing parameters are near zero (0–0.09). | — |

**LEVANTE (not used).** PS4#3 uses the LEVANTE vocabulary task, which isn't a tokenless IRW table; `roar_lexical` covers the same point, and PS4#3 names it as the fallback.

## Widget / simulation / problem ideas

**Widgets**
- Where the lower asymptote is learned: a 3PL item, a slider for the test's difficulty relative to the respondents; the width of the $c$ estimate's interval (idea 1).
- Rasch vs. 1PL-G: the same item under both, with $c$ fixed at 0.5 or 0.25 (idea 2).
- Prior × likelihood = posterior for one slope: sample-size slider (idea 4).

**Predict-then-check:** the lexical decision task has two choices. When we fix guessing at 0.5, will the ability estimates change much? Answered by the correlation (0.97) and the difficulty spread (0.8 → 2.0).

**Simulate:** 3PL data with $c = 0.2$; fit Rasch, 3PL, and 3PL with priors at n = 300 and n = 3,000; compare abilities and item parameters with the truth.

**Problems**
1. Derivation: under the 1PL-G with $c$ fixed, write the likelihood for $\theta$ from one item; why is a correct answer weaker evidence than under the Rasch model?
2. Real data with a twist: in `roar_lexical`, drop responses faster than 0.3 s and refit. What changes?
3. Real data (PS4#3 bonus): compare the Rasch model and the 1PL-G on held-out responses.
4. Judgment: a four-option test gives 3PL guessing estimates near zero. Is nobody guessing?
5. Design (PS4#4): choose priors for a 3PL fitted to 200 respondents; defend them.
6. Challenge (open): build a model where guessing is a property of the respondent (a rapid-guessing class). What data would identify it?

## Go deeper

- None (extension lesson; the posterior as a compromise is shown by a widget).

## Open questions

- None.
