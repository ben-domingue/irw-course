<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 33, 60–61), PS4#3 and #4, ps4/guessing.R and ps4/priors.R. -->

# Guessing and priors (`guessing-priors`)

Module: irt · Prereqs: ability-estimation, fit-prediction · Optional · Status: outline

## Core ideas

1. **The 3PL's guessing parameter is hard to estimate and hard to interpret.** The lower asymptote is informed only by low-ability people on hard items; with easy tests it drifts to zero whatever the number of options. My view: the 3PL doesn't really work as a model of guessing (slide 61: even data simulated from the 3PL are recovered well by the Rasch model). *(major)* Sources: Domingue, Kanopka, Kapoor, Pohl, Chalmers, Rahal & Rhemtulla (2024), *Psychometrika* 89(3), 1034–1054, doi:10.1007/s11336-024-09977-2 (IMV(2PL, 3PL) ≤ 0.001 even when the 3PL generates the data; the source for slide 61); Maris & Bechger (2009), doi:10.1080/15366360903070385 (interpreting 3PL parameters); Han (2012) on fixing the guessing parameter (to verify).
2. **Fix guessing from the item's structure.** When the chance rate is known (two alternatives in a lexical decision task, four options in multiple choice), impose it: the 1PL-G, a Rasch model with a fixed lower asymptote. Not the 3PL: nothing extra is estimated. *(major)* Source: San Martín, del Pino & De Boeck (2006), doi:10.1177/0146621605282773 (guessing models).
3. **Guessing may belong to people, not items.** Rapid guessing shows up in response times: responses too fast to reflect processing, answered at chance. *(major)* Source: Wise & Kong (2005), doi:10.1207/s15324818ame1802_2.
4. **Priors keep estimates well behaved.** A posterior is likelihood times prior; with small samples, lognormal priors on slopes and beta priors on guessing pull wild estimates back. A conceptual guide, not a full Bayesian treatment. Sources: Mislevy (1986), doi:10.1007/bf02293979; Harwell & Baker (1991), doi:10.1177/014662169101500409.
5. **Judge it by prediction.** Whether fixing guessing or adding priors helps is a question for held-out data (PS4#3 bonus). Thread from `fit-prediction`.

Crossref-checked 09-24 unless marked.

## Picks up

- The 3PL, its lower asymptote, `mirt`'s parameterization (from `1pl-to-4pl`).
- Out-of-sample prediction for comparing models (from `fit-prediction`).
- The likelihood, and the Bayesian reading of it (from `likelihood`).
- Response times as data beside responses (from `irw-data`).
- Priors on abilities; EAP and shrinkage (from `ability-estimation`).
- Information, and where guessing costs it (from `information`).

## Promises / leaves open

- Estimation machinery (EM, with or without priors) → `item-estimation` (an optional sibling; each restates what it needs).
- Response times modelled jointly with accuracy → `response-time`.
- Skipped responses carry information (ENEM coded missing as wrong) → `irtrees`.
- Guessing as a latent class of responders → unpaid (mixture models).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `roar_lexical` | main example | ROAR lexical decision (Yeatman et al., 2021, doi:10.1038/s41598-021-85907-x): 123 people, 500 real and made-up words, two choices, so chance is 0.5; accuracy 0.80. The Rasch model and the 1PL-G with $c = 0.5$ give abilities that correlate 0.97, but the 1PL-G spreads difficulties out (SD 0.8 → 2.0) and fits better (log-likelihood −25,561 → −25,362) with no extra parameters. 3.1% of responses come faster than 0.3 s, and those are at chance (accuracy 0.51 vs. 0.81). | `response-time` also lists it (reuse to settle; see Open questions) |
| `vocabulary_iq` | contrast (priors) | Open Psychometrics Vocabulary IQ Test (items 1–45; CC BY 4.0), 2,802 complete. The 3PL fitted to 300 people without priors gives wild slopes (SD 3.8, six above 5); with the 252 priors (lognormal on $a$, beta on $c$), SD 1.2, and the error against the full-sample estimates drops from 3.5 to 0.84. The items are easy (median p = 0.90), and full-sample guessing parameters are near zero (0–0.09). | — |

**LEVANTE (not used).** PS4#3 uses the LEVANTE vocabulary task, which needs a Redivis account; it isn't in the IRW as a tokenless table. `roar_lexical` covers the same point (fixed guessing), and PS4#3 already names it as the fallback.

## Widget / simulation / problem ideas

**Widgets**
- Where the lower asymptote is learned: a 3PL item, a slider for the test's difficulty relative to the people; the width of the $c$ estimate's interval (idea 1).
- Rasch vs. 1PL-G: the same item under both, with $c$ fixed at 0.5 or 0.25 (idea 2).
- Prior × likelihood = posterior for one slope: sample-size slider (idea 4).

**Predict-then-check:** the lexical decision task has two choices. When we fix guessing at 0.5, will the ability estimates change much? Answered by the correlation (0.97) and the difficulty spread (0.8 → 2.0).

**Simulate:** 3PL data with $c = 0.2$; fit Rasch, 3PL, and 3PL with priors at n = 300 and n = 3,000; compare abilities and item parameters with the truth.

**Problems**
1. Derivation: under the 1PL-G with $c$ fixed, show the likelihood for $\theta$ from one item, and why a correct answer is weaker evidence than under the Rasch model.
2. Real data with a twist: in `roar_lexical`, drop responses faster than 0.3 s and refit. What changes?
3. Real data (PS4#3 bonus): compare the Rasch model and the 1PL-G on held-out responses.
4. Judgment: a four-option test gives 3PL guessing estimates near zero. Is nobody guessing?
5. Design (PS4#4): choose priors for a 3PL fitted to 200 examinees; defend them.
6. Challenge (open): build a model where guessing is a property of the person (a rapid-guessing class). What data would identify it?

## Go deeper

- None (optional lesson; posterior-as-compromise is shown by a widget).

## Open questions

- `roar_lexical` is listed for both this lesson and `response-time`. It fits here (two-choice guessing, rapid responses), but `response-time` could keep it as a deliberate thread (recorded under `reuses:`), or choose another RT table.
- Settled (Ben, 09-24): slide 61's argument is Domingue et al. (2024, *Psychometrika*), §3 and the Table 1 discussion.
- Verified 09-24: Han, K. T. (2012). Fixing the c parameter in the three-parameter logistic model. *Practical Assessment, Research, and Evaluation*, 17, Article 1, https://scholarworks.umass.edu/pare/vol17/iss1/1/ (ERIC EJ977575). Fixing c = 1/k performed well.
