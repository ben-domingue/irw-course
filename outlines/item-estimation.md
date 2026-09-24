<!-- Outlined 2026-09-24 from EDUC 252 slides c5 (slides 33–63), PS5#1, c5/EM-coins.R and c5/EM-example.R. -->

# Estimating item parameters: JML and EM (`item-estimation`)

Module: irt · Prereqs: ability-estimation · Optional · Status: outline

## Core ideas

1. **The joint likelihood, and why it's hard.** Nothing on the right-hand side is known; the log likelihood splits into sums over people and over items, which suggests alternating. The model is symmetric in $\theta$ and $b$, but the data aren't: many people, few items. *(major)* Source: Baker & Kim (2004), *Item response theory: Parameter estimation techniques* (book; to verify).
2. **Joint maximum likelihood, and its inconsistency.** Alternate: estimate abilities given items, then items given abilities. With a fixed number of items, the item estimates don't converge as people are added (incidental parameters). For the Rasch model they are stretched by about $k/(k-1)$. *(major)* Sources: Neyman & Scott (1948), doi:10.2307/1914288; Wright & Douglas (1977), doi:10.1177/014662167700100216; Andersen (1970) on conditional ML as an alternative, doi:10.1111/j.2517-6161.1970.tb00842.x.
3. **EM, with coins.** Two coins of unknown bias, and we don't know which produced each run of flips: the E step computes each run's probability of coming from each coin; the M step re-estimates the biases from expected counts; repeat. *(major)* Sources: Dempster, Laird & Rubin (1977), doi:10.1111/j.2517-6161.1977.tb01600.x; Do & Batzoglou (2008), doi:10.1038/nbt1406 (the coin example the 252 code follows).
4. **EM for IRT: marginal maximum likelihood.** Integrate $\theta$ out over a grid of quadrature nodes under a prior: the E step gives expected counts of people and correct responses at each node, and the M step fits each item to them. Source: Bock & Aitkin (1981), doi:10.1007/bf02293801.
5. **The price: a prior for $\theta$.** How much does a wrong prior hurt (PS5#1)? Estimating the distribution (empirical histogram) is one check.

## Picks up

- Ability estimation with items known; no MLE for perfect patterns; priors (from `ability-estimation`).
- The Rasch model and sufficiency (from `rasch`; conditional ML is its payoff).
- The likelihood, `optim`, Newton steps (from `likelihood`).
- The 2PL and 3PL, whose item parameters EM estimates too (from `1pl-to-4pl`).

## Promises / leaves open

- Priors on item parameters, where the 3PL needs them → `guessing-priors`.
- Many-item, sparse designs (each person sees some items) → `equating`, `item-banks-cat`.
- Latent regression (a prior that depends on covariates) → `explanatory-irt`.
- Crossed random effects as an alternative estimator (`glmer`) → `explanatory-irt`, `trials`.
- Conditional ML → unpaid (named here only).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `enders_2022_science_literacy` | main example | 11 science-literacy items, 2,040 US adults (7 score 0, 9 score 11). A hand-written JML (dropping the 16 extreme scorers) gives difficulties stretched relative to the marginal-ML ones by a factor of 1.10 (regression slope), matching the $k/(k-1) = 11/10$ stretch of the theory. Refitting the marginal model with an estimated (empirical-histogram) ability distribution instead of a normal prior moves no difficulty by more than 0.02. | — |

Table citation from IRW biblio.

## Widget / simulation / problem ideas

**Widgets**
- EM with coins: five runs of ten flips; step through E and M; watch the estimates converge from different starting values (idea 3).
- Quadrature: a prior over a grid of nodes; one person's likelihood reweights it into a posterior; the expected counts for one item build up (idea 4).
- JML stretch: number of items slider; JML vs. true difficulties on simulated data, with the $k/(k-1)$ line (idea 2).

**Predict-then-check:** will the JML difficulties for the science-literacy items be larger or smaller in magnitude than the marginal-ML ones, and by how much? Answered by the comparison (1.10 times, which is 11/10).

**Simulate:** simulate Rasch data; estimate items by JML (by hand) and by marginal ML (`mirt`); plot both against the truth for 5, 10 and 40 items.

**Problems**
1. Derivation: write the Rasch joint log likelihood (the 252 slide has a deliberate mistake: find it) and its derivatives with respect to $\theta_j$ and $b_i$.
2. Simulation (c5/EM-example.R): how sensitive is the coin EM to starting values, to the true biases, and to the number of runs and flips?
3. Real data with a twist: rescale the science-literacy JML difficulties by $(k-1)/k$; how close are they to marginal ML now?
4. Simulation (PS5#1): generate abilities from a skewed or bimodal distribution; fit with a normal prior; how biased are the difficulties?
5. Judgment: JML is still used (e.g. in some Rasch software) with a correction. When would you accept it?
6. Challenge (open): PS5#1's question. How much trouble are we in if the ability distribution is wrong? Is there recent literature? (Ben: "IDK".)

## Go deeper

- **EM for the Rasch model, one iteration by hand.** The E step's expected counts at each node and the M step for one item. Why: `item-banks-cat`, `equating`, `explanatory-irt`. Length: about a page. (EM is a candidate in `notes/protocol-decisions.md`.)

## Open questions

- Verified 09-24: Baker, F. B., & Kim, S.-H. (2004). *Item response theory: Parameter estimation techniques* (2nd ed.). Marcel Dekker, doi:10.1201/9781482276725.
- The prior-sensitivity result on the real data is null (0.02). Keep it as a reassuring real-data check and put the dramatic case in Simulate, or look for a table with a strongly skewed ability distribution?
- Conditional ML gets a sentence only. Enough for an optional lesson?
