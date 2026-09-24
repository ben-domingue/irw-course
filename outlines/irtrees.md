<!-- Outlined 2026-09-24 from EDUC 252 c8 (slides 31–42), PS8#4 (fast responding) and the code c8/irtree.R, c8/irtree2.R, c8/irtree_sim.R and ps8/fast.R. Tidied 09-24 (#62). -->

# IRTree models (`irtrees`)

Module: beyond · Prereqs: polytomous, explanatory-irt · Extension · Status: outline

## Core ideas

1. **A response as a sequence of decisions.** Break each response into binary nodes (take a side? which side? how strongly?) and fit an item response model at each; the response probability is the product along its path. *(major)* Sources: De Boeck & Partchev (2012), doi:10.18637/jss.v048.c01; Böckenholt (2012), doi:10.1037/a0028111.
2. **Tree shape and node abilities are choices.** Linear vs. nested trees (c8 slide 33); one θ for all nodes or one per node. A linear tree with one θ is the sequential model from `polytomous`. *(major)* Sources: De Boeck & Partchev (2012); Tutz (1990), doi:10.1111/j.2044-8317.1990.tb00925.x; Jeon & De Boeck (2016), doi:10.3758/s13428-015-0631-y.
3. **Fitting a tree is recoding, then a mixed model.** One row per node passed (pseudo-items); `resp ~ 0 + item:node + (0 + node | id)`, the `explanatory-irt` formula with the node as an item predictor (c8 slide 41: `node` must be a factor). Source: Bates et al. (2015), doi:10.18637/jss.v067.i01.
4. **Response styles.** Midpoint and extreme responding get their own dimensions, so content θ is estimated net of them. *(major)* Sources: Baumgartner & Steenkamp (2001), doi:10.1509/jmkr.38.2.143.18840; Böckenholt (2017), doi:10.1037/met0000106; Plieninger & Meiser (2014), doi:10.1177/0013164413514998.
5. **Trees for what the response hides: speed and skips.** A first node for "answered fast" (PS8#4) or "skipped" (c8 slide 36) turns timing or missingness into data. Skips are paid in simulation and a problem only: no tokenless table has enough (digest F30). Sources: Debeer, Janssen & De Boeck (2017), doi:10.1111/jedm.12147; DiTrapani, Jeon, De Boeck & Partchev (2016), doi:10.1016/j.intell.2016.02.012.

**Verdict (Claude's reading; for Ben to confirm):** fit a tree when you have a process in mind (midpoint avoidance, speed, skipping); as a general replacement for the GRM it buys little, and its AIC isn't comparable with the GRM's anyway.

All references checked on Crossref (09-24).

## Picks up

- The sequential model and dichotomizations (from `polytomous`).
- The mixed-model formula, item predictors, crossed random effects (from `explanatory-irt`).
- Reverse keying (thread from `ctt-reliability`): data are keyed before the tree is built.
- Brief Recalls (E2; restated, not threads): response styles from `instrument-building`; skipped responses from `guessing-priors`; person fit from `fit-prediction`.

## Promises / leaves open

- Response time as a node: the continuous treatment is in `response-time`, a sibling (both follow `explanatory-irt`); linked, not a hook.
- Whether response-style dimensions threaten validity arguments → unpaid (validity-evidence comes earlier in the course).
- Choosing among trees for the same categories → unpaid beyond AIC; an IMV candidate.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `bfi_goldberg_1992_conscientiousness` | main example | IPIP markers (Goldberg, 1992, doi:10.1037/1040-3590.4.1.26; CC BY 4.0), 10 items 1–5; C2, C4, C6, C8 reverse-keyed. On 3,000 respondents a three-node tree with a θ per node beats one shared θ (AIC 85,950 → 82,875). Midpoint avoidance and extremes correlate 0.61; with content only 0.28 and 0.19. | — |
| `introversion_extroversion` | contrast (fast responding, PS8#4) | 7,188 × 91 with RTs (median 3.2 s; 15% under 2 s). Two-node tree on 1,500: the speed node correlates 0.01 with the trait. Fast responding says nothing about the trait here. | — |
| simulated tree and GRM data (c8/irtree_sim.R) | sanity | Trees recover item order from GRM data and node correlations from tree data. | — |

`ffm_CSN` has no tokenless CSV; these two replace it (digest F29), revisited only if the ffm subsample is released. The sanity check is simulated because the IRW stores `verbagg` dichotomized (F30). Tree AIC vs. the GRM (c8 slide 42): `glmer` (`nAGQ = 0`) and `mirt` compute the marginal likelihood differently, and the two-node tree drops categories; that is the teaching point, not a ranking.

## Widget / simulation / problem ideas

**Widgets**
- Tree builder: a 1–5 response through a linear or nested tree, with its pseudo-items (ideas 1, 3).
- Node curves: θ sliders per node; five category probabilities (ideas 2, 4).
- Two respondents, same conscientiousness, different styles: raw sums differ, content θs don't (idea 4).

**Predict-then-check:** do people who avoid the middle also choose the extremes, and does either track conscientiousness? (0.61; 0.28 and 0.19.)

**Simulate:** a three-node tree with correlated node θs; fit one-θ and per-node trees; compare correlations with the truth. Then θ-dependent skips: scoring them wrong or missing biases θ; a skip node repairs it. `glmer(..., nAGQ = 0)` for speed.

**Problems**
1. Derivation: category probabilities of the three-node tree sum to one; a linear Rasch tree is the sequential model, not the PCM.
2. Real data with a twist: the midpoint tree on the other four `bfi_goldberg_1992_*` traits.
3. Judgment (c8 slide 42): when can you compare the tree's AIC with the GRM's?
4. Design: a survey in two countries with different style norms. What can a tree fix, and what not?
5. Real data (PS8#4): sensitivity to the 2 s cut (1, 1.5, 3 s).
6. Challenge (open): a skip node in a low-stakes test. Does the skip θ belong in the reported score?

## Go deeper

- **The tree likelihood factorizes over nodes**, so any IRT or GLMM software fits it (c8 slides 37–39). Why: `polytomous`, `response-time`. Half a page.

## Open questions

- The verdict above is Claude's reading (voice rule A). *Default:* use it unless you'd put it differently.
