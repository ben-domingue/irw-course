<!-- Outlined 2026-09-24 from EDUC 252 c8 (slides 40–41), c10 (slide 25), PS6#2, PS7#2 part B, ps6/hf.R and ps7/cdm.R (c8/lmer_example.R is empty). Tidied 09-24 (#62): Ben's answers applied, cut to one session. -->

# What is an item? Explanatory item response models (`explanatory-irt`)

Module: beyond · Prereqs: rasch · Extension · Status: outline

## Core ideas

1. **An item response model is a regression.** Stack the data long and the Rasch model is `resp ~ 0 + item + (1 | id)`; the rest of the lesson changes that formula. Fitted with `lme4` throughout, not `mirt` (digest F11). *(major)* Sources: Rijmen, Tuerlinckx, De Boeck & Kuppens (2003), doi:10.1037/1082-989X.8.2.185; De Boeck et al. (2011), doi:10.18637/jss.v039.i12; Bates, Mächler, Bolker & Walker (2015), doi:10.18637/jss.v067.i01.
2. **Descriptive vs. explanatory.** An explanatory model replaces item or person parameters with predictors; the LLTM replaces 24 difficulties with a handful of design effects. *(major)* Sources: Wilson & De Boeck (2004), doi:10.1007/978-1-4757-3990-9_2; Fischer (1973), doi:10.1016/0001-6918(73)90003-6.
3. **Explaining difficulty is not fitting it; items as random effects.** Item predictors can explain most of the difficulty and still fail a likelihood-ratio test. An item residual (random items around the LLTM prediction) reconciles the two. The same move answers c8 slide 40's question, "are we interested in *these* items?": when items come in families, how much difficulty sits between families? *(major)* Sources: Janssen, Schepers & Peres (2004), doi:10.1007/978-1-4757-3990-9_6; De Boeck (2008), doi:10.1007/s11336-008-9092-x; Glas & van der Linden (2003), doi:10.1177/0146621603027004001.
4. **Person predictors and latent regression.** Covariates in the same formula give effects on the θ scale with no two-step detour. Sources: Zwinderman (1991), doi:10.1007/BF02294492; Mislevy (1987), doi:10.1177/014662168701100106.
5. **What is an item? Trials and local dependence.** In a repeated task the item is a stimulus in a context: a flower is harder right after a heart. A trial covariate is an item predictor; a person × family random effect is local dependence made explicit. *(major)* Sources: PS6#2; Davidson, Amso, Anderson & Diamond (2006), doi:10.1016/j.neuropsychologia.2006.02.006; Bradlow, Wainer & Wang (1999), doi:10.1007/BF02294533.

**Verdict (Claude's reading; for Ben to confirm):** unless items were generated from the design, I'd fit the LLTM with an item residual, not without: real items always leave something over, and the residual SD says how much.

Item-difficulty modelling as a design tool is cited, not taught: Embretson (1998), doi:10.1037/1082-989X.3.3.380. All references checked on Crossref (09-24).

## Picks up

- The Rasch model and local independence (from `rasch`).
- Logistic regression and the likelihood (from `likelihood`).
- `verbagg`'s want/do pattern, described there and modelled here (from `irw-data`).
- Local dependence among items that share a context (from `ctt-limits`, `ctt-reliability`).
- Brief Recalls for readers who have done them (E2; restated, not threads): random effects in `g-theory`; `glmer` and latent regression in `item-estimation`; latent regression in `sem`; testlets in `dimensionality` and `information`; item text in `instrument-building`.

## Promises / leaves open

- Item text and LLM-predicted difficulty; deep dive #25 → `ai-psychometrics` (this lesson's LLTM is the human-coded baseline).
- The Q-matrix as an item design matrix → `cdm`.
- Trees as explanatory models (`item:node + (0 + node | id)`) → `irtrees`.
- Continuous stimulus features (rotation angle, shot location) → `trials`.
- Log response time as a second outcome → `response-time`.
- How much the item residual matters to scores → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `verbagg` | main example | 316 × 24, stored 0/1. Rasch AIC 8,129; LLTM (5 parameters) 8,250, rejected (χ² = 159, df = 19), yet the design explains 89% of the Rasch easiness variance (r = 0.94). Item residual: AIC 8,164, SD 0.34 vs. person SD 1.37. Want × shout +0.69. | `irw-data` (recorded under `reuses:`) |
| `trog_brinchmann_2019` | contrast (random items, families) | 210 children, 80 items in 20 constructs of 4. Family variance 5.90 vs. item-within-family 0.35 (94% between). A person × family effect improves fit (AIC 11,974 → 11,708; SD 1.15 vs. person 2.26). | — |
| `imps2025_hf` | failure case (naive item definition); person predictors | 31,394 trials, grades 3–5. Shape × side gives four items at 0.82–0.86, but a trial after a shape switch is −0.63 logits harder. Grade 5 is +0.59 over grade 3. | `trials` Recalls it (no reuse) |
| `verbagg` vs. `lme4::VerbAgg` | sanity | Identical item proportions, so De Boeck et al.'s (2011) LLTM is the known answer. | — |

TROG models take minutes in `glmer`: precompute them; the browser gets the simulation. Say gently: `verbagg` is stored dichotomized without person covariates; one item is spelled `S4wantCurse`; TROG items are copyrighted, so name constructs, not items.

## Widget / simulation / problem ideas

**Widgets**
- Formula builder: tick item effects, item predictors, residual, person predictors; formula, parameter count and design matrix update (ideas 1, 2).
- LLTM vs. Rasch difficulties with a residual-SD slider (idea 3).
- Families: between- vs. within-family SDs; expected score on a new item from a known vs. a new family (idea 3).
- Switch cost: ICCs for flower-after-flower and flower-after-heart (idea 5).

**Predict-then-check:** the design explains 89% of item difficulty. Will the LR test accept the LLTM? (χ² = 159 on 19 df; then the residual model.)

**Simulate:** LLTM data with a small item residual, 300 × 24; fit Rasch, LLTM and random-item LLTM with `glmer`; watch the LR test reject as the residual SD grows from 0 to 0.5. `lme4` speed in webR is Claude's check (digest D).

**Problems**
1. Derivation: the LLTM as Rasch with $b_i = \sum_k q_{ik}\eta_k$; count verbagg's parameters.
2. Real data with a twist: the want × behaviour interaction on verbagg. What does it say about inhibition?
3. Judgment (c8 slide 40): TROG items fixed or random? What if a new form draws new items from the same constructs?
4. Design: which features would you code for a new bank of arithmetic word problems?
5. Real data (PS6#2): add `time_limit` to hearts and flowers. Does the switch cost depend on it?
6. Challenge (open): when is a trial "the same item" twice? Propose a criterion and test it.

## Go deeper

- **The LLTM keeps the sum score sufficient.** A Rasch model with a linear constraint. Why: `rasch`, `cdm`, `trials`. Half a page.
- **Crossed random effects and the marginal likelihood.** Why `glmer` and `mirt` Rasch estimates nearly agree (Laplace). Why: `trials`, `response-time`, `irtrees`. About a page.

## Open questions

- The verdict above is Claude's reading of the verbagg result (voice rule A needs one per lesson). *Default:* use it unless you'd put it differently.
