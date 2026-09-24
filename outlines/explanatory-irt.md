<!-- Outlined 2026-09-24 from EDUC 252 slides c8 (slides 40–41, fixed vs. random effects in lme4) and c10 (slide 25, item difficulty modelling and the LLTM), PS6#2 (hearts and flowers: "what makes an item?"), PS7#2 part B (items as exchangeable carriers of skills), and the code ps6/hf.R and ps7/cdm.R. c8/lmer_example.R is empty in the export. -->

# What is an item? Explanatory item response models (`explanatory-irt`)

Module: beyond · Prereqs: rasch · Optional · Status: outline

## Core ideas

1. **An item response model is a regression.** Stack the data long (one row per response) and the Rasch model is a logistic mixed model: respondents as a random effect, items as fixed effects, `resp ~ 0 + item + (1 | id)`. Everything else in the lesson is a change to that formula. *(major)* Sources: Rijmen, Tuerlinckx, De Boeck & Kuppens (2003), doi:10.1037/1082-989X.8.2.185; Doran, Bates, Bliese & Dowling (2007), doi:10.18637/jss.v020.i02; De Boeck, Bakker, Zwitser, Nivard, Hofman, Tuerlinckx & Partchev (2011), doi:10.18637/jss.v039.i12; `lme4`: Bates, Mächler, Bolker & Walker (2015), doi:10.18637/jss.v067.i01.
2. **Descriptive vs. explanatory.** A descriptive model gives each item and each respondent its own parameter; an explanatory model replaces those parameters with predictors (item properties, person properties, or both). The LLTM replaces 24 item difficulties with a handful of design effects. *(major)* Sources: Wilson & De Boeck (2004), ch. 2 of *Explanatory item response models*, doi:10.1007/978-1-4757-3990-9_2; Fischer (1973), doi:10.1016/0001-6918(73)90003-6; Janssen, Schepers & Peres (2004), ch. 6, doi:10.1007/978-1-4757-3990-9_6.
3. **Explaining difficulty is not the same as fitting it.** Item predictors can account for most of the variation in difficulty and still be rejected by a likelihood-ratio test. Adding an item residual (items as random effects around the LLTM prediction) reconciles the two and says how much is left unexplained. *(major)* Sources: De Boeck (2008), *Random item IRT models*, doi:10.1007/s11336-008-9092-x; Janssen et al. (2004); Cho, De Boeck, Embretson & Rabe-Hesketh (2014), doi:10.1007/s11336-013-9360-2.
4. **Fixed or random items: are we interested in *these* items?** Ben's question from c8 slide 40: random item effects treat items as a sample from a population of items (item families, clones, generated items). When items come in families, how much of the difficulty sits between families? Sources: De Boeck (2008); Glas & van der Linden (2003) on item cloning, doi:10.1177/0146621603027004001; Sinharay, Johnson & Williamson (2003) on item families, doi:10.3102/10769986028004295.
5. **Person predictors and latent regression.** Put respondent covariates (grade, time point) in the same formula: the effect is estimated on the θ scale, without a two-step "estimate θ, then regress" detour. Sources: Zwinderman (1991), doi:10.1007/BF02294492; Mislevy (1987), doi:10.1177/014662168701100106; Wilson & De Boeck (2004).
6. **What is an item? Trials and local dependence.** When a task is repeated, the "item" is a stimulus in a context: the same flower is harder right after a heart. A trial-level covariate is an item predictor; shared context within a family (a testlet effect, a person × family random effect) is local dependence made explicit. *(major)* Sources: PS6#2; Davidson, Amso, Anderson & Diamond (2006) on hearts and flowers, doi:10.1016/j.neuropsychologia.2006.02.006; Bradlow, Wainer & Wang (1999), doi:10.1007/BF02294533; Wang & Wilson (2005), doi:10.1177/0146621604271053.

Item-difficulty modelling as a design tool is cited, not taught: Embretson (1998), doi:10.1037/1082-989X.3.3.380; Hartig, Frey, Nold & Klieme (2012), doi:10.1177/0013164411430707.

All references above were checked on Crossref (09-24).

## Picks up

- The Rasch model, item difficulty as a fixed parameter, local independence (from `rasch`; its promise: local independence → `explanatory-irt`).
- The Rasch likelihood and logistic regression (from `likelihood`).
- `verbagg` and its want/do pattern in the item means (from `irw-data`, described there, modelled here).
- Random effects and variance components for persons × facets (from `g-theory`; its promise: random-effects models for item responses → `explanatory-irt`).
- Crossed random effects as an estimator (`glmer`), and latent regression as a prior that depends on covariates (from `item-estimation`, promised there).
- Latent regression of ability on covariates (promised in `sem`).
- Local dependence among items that share a context (promised in `ctt-limits`, `ctt-reliability`, `information`, `dimensionality`).
- Item text as a predictor of difficulty (promised in `instrument-building` and `irw-data`): taken up here with human-coded item features; the text itself goes to `ai-psychometrics`.

## Promises / leaves open

- Item text and LLM-predicted difficulty; deep dive #25 (does item wording predict difficulty?) → `ai-psychometrics` (agreed with course-beyond-2: the deep dive lives there; this lesson's LLTM is the human-coded baseline it improves on).
- Q-matrix as an item design matrix: the LLTM with skills as predictors becomes a latent class model → `cdm`.
- Trees as explanatory models (node as an item-side predictor, `item:node + (0 + node | id)`) → `irtrees`.
- Trials with continuous stimulus features (rotation angle, shot location) → `trials`.
- Log response time as a second outcome with the same random-effects machinery → `response-time`.
- Person × item predictors (DIF as an interaction) → `dif`, and treatment × item interactions → `invariance-experience` (PS7#1's `(1 + treat | item)`).
- The random-item LLTM is a Bayesian-flavoured model with no closed form for how much the item residual matters to scores → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `verbagg` | main example | Verbal aggression (De Boeck & Wilson, 2004; 316 respondents × 24 items, 0/1 as stored, so "perhaps" and "yes" are both 1). Three design factors: want vs. do, curse/scold/shout, other- vs. self-to-blame. The Rasch model (24 item parameters) has AIC 8,129; the LLTM (5 parameters) 8,250, and the likelihood-ratio test rejects it (χ² = 159, df = 19). Yet the design explains 89% of the variance in the Rasch item easiness (r = 0.94). Adding a random item residual gives AIC 8,164 with residual SD 0.34 against a person SD of 1.37. Effects (logits): want +0.71, scold −1.06, shout −2.10, self-to-blame −1.05. A want × shout interaction (+0.69) says the gap between wanting to and doing is widest for shouting. Largest residuals: S3DoShout (−0.86) and S4DoCurse (+0.70). | `irw-data` (deliberate thread: described there, modelled here; record `reuses:`) |
| `trog_brinchmann_2019` | contrast (random items, families) | Norwegian TROG-2, a test of receptive grammar (Brinchmann, Braeken & Lyster, 2019): 210 children, 80 items in 20 blocks of 4, each block one grammatical construct (`item_family`). Item difficulty is almost all between blocks: with crossed random effects, family variance 5.90 vs. item-within-family 0.35 (94% between). Family means fall from 0.95 to 0.07 correct in test order. Items within a construct are nearly exchangeable, which is the case for random items. A person × family (testlet) random effect: see the note below the table. | — |
| `imps2025_hf` | failure case for the naive item definition; person predictors | Hearts and flowers (Obradović et al., 2018; DeJoseph et al., 2025), mixed block: 31,394 trials from 1,438 child × time points, grades 3–5. Defining the item as shape × side gives four items with accuracy 0.82–0.86, but a trial that follows a switch of shape is much harder: −0.63 logits (flower 0.89 → 0.83, heart 0.87 → 0.80). Trials violate local independence under the naive item definition; the switch covariate repairs part of it. Person side: grade 5 is 0.59 logits above grade 3, grade 4 0.25. | `trials` Recalls it, no reuse (agreed with course-beyond-2) |
| sanity: `verbagg` against `lme4::VerbAgg` | sanity | The IRW table reproduces the `lme4` copy of the same data exactly (item proportions identical), so the LLTM in De Boeck et al. (2011) is the known answer the pipeline must match. | — |

TROG testlet (person × family) variance: fit still running on 09-24; the number goes here before review.

Notes on the data, to say gently in the lesson: `verbagg` is stored dichotomized and without the `lme4` copy's person covariates (anger, gender), so the person-predictor example uses hearts and flowers; one `verbagg` item name is spelled `S4wantCurse` (lower-case "want"), so code that parses the design from names must ignore case. `imps2025_hf` has a `time_limit` (0.75 or 1.25 s) that is a second trial-level predictor worth a problem. The TROG items are copyrighted (Pearson), so the lesson names the constructs, not the items.

## Widget / simulation / problem ideas

**Widgets**
- Formula builder: tick boxes for item fixed effects, item predictors, item residual, person predictors; the model formula, number of parameters and a design-matrix picture update (ideas 1, 2).
- LLTM vs. Rasch difficulties: 24 points (Rasch difficulty vs. LLTM prediction) with a residual-SD slider showing how much scatter a random item residual allows (idea 3).
- Families: draw items from families with between- and within-family SDs; a respondent's expected score on a new item from a known family vs. a new family (idea 4).
- Switch cost: an item characteristic curve for "flower after flower" and "flower after heart", with a slider for the switch effect (idea 6).

**Predict-then-check:** the three verbagg design factors explain most of the item difficulties (r = 0.94 with the Rasch estimates). Will a likelihood-ratio test accept the LLTM? Answered by χ² = 159 on 19 df, then the random-residual model.

**Simulate:** Generate responses from an LLTM with a small item residual; fit Rasch, LLTM and random-item LLTM with `glmer`; compare recovered design effects and residual SD with the truth, and watch the LR test reject the LLTM as the residual SD grows from 0 to 0.5. Keep to about 300 respondents × 24 items for seconds in webR (`lme4` in webR to confirm).

**Problems**
1. Derivation: show that the LLTM is a Rasch model with the constraint $b_i = \sum_k q_{ik}\eta_k$, and count its parameters for verbagg.
2. Real data with a twist: refit the verbagg LLTM with the want × behaviour interaction. Which interaction does the data support, and what does it say about inhibition?
3. Judgment (c8 slide 40): for TROG, would you treat items as fixed or random? What changes if a new form draws new items from the same 20 constructs?
4. Design: you are writing a new item bank of arithmetic word problems. Which item features would you code before fielding it, so that an LLTM could be fitted afterwards?
5. Real data (PS6#2): add `time_limit` to the hearts-and-flowers model. Does the switch cost depend on the time limit?
6. Challenge (open): in PS6#2 the item is the stimulus; in verbagg it is a situation × verb. When is a trial "the same item" twice? Propose a criterion and test it on one table.

## Go deeper

- **The LLTM is a Rasch model with a linear constraint, so the sum score stays sufficient for θ.** Why: `rasch` (sufficiency), `cdm` (a Q-matrix as the design matrix), `trials`. Length: half a page.
- **Crossed random effects and the marginal likelihood.** Why the `glmer` Rasch model and `mirt`'s Rasch model give nearly the same item estimates, and where they differ (the Laplace approximation). Why: `item-estimation`, `trials`, `response-time`, `irtrees`. Length: about a page.

## Open questions

- `verbagg` returns from `irw-data` as a deliberate thread (the want/do pattern described there becomes a model here). Record it with `reuses:`? It is the canonical LLTM example (De Boeck & Wilson's own), which is the case for the reuse.
- The lesson uses `lme4` throughout, not `mirt`. Does `lme4` run acceptably in webR for the simulation, or should Simulate use a smaller design?
- Deep dive #25 lives in `ai-psychometrics` (agreed with course-beyond-2). Agree?
- PS7#1 (IL-HTE, `ps7/ilhte.R`) is homed in `invariance-experience`; this lesson only points to it.
