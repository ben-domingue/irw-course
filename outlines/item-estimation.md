<!-- Outlined 2026-09-24 from EDUC 252 slides c5 (slides 33–63), PS5#1, c5/EM-coins.R and c5/EM-example.R. Tidied 09-24 (#62): Ben's answers applied (E9, C14); widgets planned on Ben's EM walkthrough. -->

# Estimating item parameters: JML and EM (`item-estimation`)

Module: irt · Prereqs: ability-estimation · Extension · Status: drafted (#38)

## Core ideas

1. **θ is the missing data.** If we knew every $\theta$, each item would be a logistic regression on $\theta$, as in `likelihood`. We have only 0s and 1s: items need $\theta$, and $\theta$ needs items. The model is symmetric in $\theta$ and $b$; the data aren't (many respondents, few items). *(major)* Sources: Baker & Kim (2004), *Item response theory: Parameter estimation techniques* (2nd ed.), doi:10.1201/9781482276725; Ben's walkthrough, panel 1.
2. **Joint maximum likelihood, and its inconsistency.** Alternate: abilities given items, then items given abilities. With a fixed number of items, the item estimates don't converge as respondents are added (incidental parameters); for the Rasch model they are stretched by about $k/(k-1)$. Conditional ML, which conditions on the sufficient sum score, avoids this; one sentence. *(major)* Sources: Neyman & Scott (1948), doi:10.2307/1914288; Wright & Douglas (1977), doi:10.1177/014662167700100216; Andersen (1970), doi:10.1111/j.2517-6161.1970.tb00842.x.
3. **Marginal ML: integrate θ out.** Replace each respondent's $\theta$ with a prior over a grid of quadrature nodes (EAP's grid, from `ability-estimation`) and maximize the marginal likelihood. Direct MML and EM climb the same surface. In direct MML every posterior weight changes when any item parameter moves (the "ripple"); EM computes them once per cycle and holds them fixed (the "fix"). Two coins of unknown bias give EM's intuition in a paragraph. *(major)* Sources: Bock & Aitkin (1981), doi:10.1007/bf02293801; Dempster, Laird & Rubin (1977), doi:10.1111/j.2517-6161.1977.tb01600.x; Do & Batzoglou (2008), doi:10.1038/nbt1406 (the coins); Ben's walkthrough, panel 2.
4. **The E step and the M step.** E: for each response pattern, posterior weights $W_{jk}$ over the nodes; from them, the expected number of respondents at each node, $f_k$, and the expected number correct on item $i$ at node $k$, $r_{ik}$. No respondent is pinned to one node. M: with $r_{ik}$ and $f_k$ fixed, each item is a weighted logistic regression at $K$ design points, so the M step is $I$ separate problems, each a few Newton steps. Each cycle raises the marginal log likelihood; with flat posteriors (weak items) it creeps. *(major)* Sources: Bock & Aitkin (1981); Harwell, Baker & Zwarts (1988), doi:10.3102/10769986013003243 (the EM steps written out); Ben's walkthrough, panels 3–5.
5. **The price: a prior for θ.** How much does a wrong prior hurt (PS5#1)? Estimating the distribution (an empirical histogram) is one check. Sources: Mislevy (1984), doi:10.1007/bf02306026; Seong (1990), doi:10.1177/014662169001400307; Woods & Thissen (2006), doi:10.1007/s11336-004-1175-8.

DOIs Crossref-checked 09-24.

**Ben's material.** The widgets follow Ben's EM walkthrough (`em_irt.html`, an interactive page in five panels; local copy in the gitignored `source/em_irt.html`), cited in the lesson as his and rewritten to course conventions: "respondent", not "examinee"; item $i$, respondent (or pattern) $j$, node $k$, so the page's $r_{jk}$ becomes $r_{ik}$; its operation counts become a sentence; new helpers (posterior weights, one E step, one M step) go in `lessons/widgets/irt.js`; `palette` colours; seeded `rng()`.

**Verdict (voice rule A):** which estimator to trust for item parameters (marginal ML by EM; JML only with its correction, and only when the items are many).

## Picks up

- Ability estimation with items known; no MLE for perfect patterns; EAP on a grid of nodes with a prior (from `ability-estimation`).
- "Estimate item parameters first by EM, integrating over abilities" (from `rasch`, its note on estimation); the sum score is sufficient, which is what conditional ML uses (from `rasch`).
- Logistic regression by likelihood; `optim()`; `glm()` "uses a version of Newton's method", and this lesson "opens up the machinery" (from `likelihood`).
- The 2PL and 3PL, whose item parameters EM estimates too (from `1pl-to-4pl`).

## Promises / leaves open

- Many-item, sparse designs (each respondent sees some items) → `equating`, `item-banks-cat`.
- Latent regression (a prior that depends on covariates) → `explanatory-irt`.
- Crossed random effects as an alternative estimator (`glmer`) → `explanatory-irt`, `trials`.
- Conditional ML → unpaid (one sentence here).
- Priors on item parameters: `guessing-priors` covers them; a sibling, so each restates what it needs (E2), no hook.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `enders_2022_science_literacy` | main example | 11 science-literacy items, 2,040 US adults (7 score 0, 9 score 11). A hand-written JML (dropping the 16 extreme scorers) gives difficulties stretched relative to the marginal-ML ones by a factor of 1.10 (regression slope), matching the $k/(k-1) = 11/10$ of the theory. Refitting the marginal model with an empirical-histogram ability distribution instead of a normal prior moves no difficulty by more than 0.02. | — |

Table citation from IRW biblio.

**Decision (C14):** the null prior check (at most 0.02) stays as a reassuring real-data result; the dramatic case (a skewed or bimodal truth fitted with a normal prior) goes in Simulate.

## Widget / simulation / problem ideas

**Widgets** (after Ben's panels)
- θ known, then hidden: pick an item; its logistic fit to simulated $(\theta, x)$ pairs; then the same data with the $\theta$ column removed (idea 1; panel 1).
- Ripple vs. fix: drag one item's $b$; under direct MML every posterior weight recomputes and every item's gradient shifts; under EM $r_{ik}$ and $f_k$ stay put this cycle (idea 3; panel 2).
- The E step: pick a response pattern; its posterior weights over the nodes; then one cell of $r_{ik}$ and $f_k$ built up from them (idea 4; panels 2–3).
- EM, step by step: "step once" and "run to convergence"; true (dashed) vs. current ICCs, the marginal log likelihood by cycle, and a recovery plot (idea 4; panels 4–5).
- JML stretch: number-of-items slider; JML vs. true difficulties on simulated data, with the $k/(k-1)$ line (idea 2).

**Predict-then-check:** will the JML difficulties for the science-literacy items be larger or smaller in magnitude than the marginal-ML ones, and by how much? Answered by the comparison (1.10 times, which is 11/10).

**Simulate:** Rasch data; items by JML (by hand) and by marginal ML (`mirt`), against the truth for 5, 10 and 40 items; then abilities from a skewed distribution fitted with a normal prior (the dramatic case, C14).

**Problems**
1. Derivation: write the Rasch joint log likelihood (the 252 slide has a deliberate mistake: find it) and its derivatives with respect to $\theta_j$ and $b_i$.
2. Simulation (c5/EM-example.R): how sensitive is the two-coin EM to starting values, the true biases, and the number of runs and flips?
3. Real data with a twist: rescale the science-literacy JML difficulties by $(k-1)/k$; how close are they to marginal ML now?
4. Derivation: show that the M step for one item maximizes $\sum_k [r_{ik}\log P_{ik} + (f_k - r_{ik})\log(1-P_{ik})]$, a logistic regression with fractional counts.
5. Judgment: JML is still used (e.g. in some Rasch software) with a correction. When would you accept it?
6. Challenge (open, PS5#1): how much trouble are we in if the ability distribution is wrong? Is there recent literature? (Ben: "IDK".)

## Go deeper

- **EM for the Rasch model, one cycle by hand.** The E step's $r_{ik}$ and $f_k$ at each node and the M step for one item. Why: `item-banks-cat`, `equating`, `explanatory-irt`. Length: about a page.

## Drafting notes (#38, 09-25)

- **Keying.** The IRW table codes 1 = answered "true", not 1 = correct: statements 2, 5, 7, 8 and 11 are false (Enders et al., 2022, S1 file), and before recoding their correlations with the six true statements are mostly negative (24 of 30). The lesson recodes them. The planned numbers above were computed on the unrecoded data; after recoding nobody scores 0 or 1, 145 score 11, JML keeps 1,895; the JML stretch is still 1.09 against MML and 1.10 against CML ($11/10$); the empirical-histogram check moves no (centred) difficulty by more than 0.008 (≤ 0.02 as planned). A fix to the IRW table is proposed in the PR.
- **Notation.** Nodes are $t_q$, $q = 1..Q$, with prior weights $w_q$ (as in `ability-estimation`), not node $k$: so $W_{jq}$, $f_q$, $r_{iq}$, and $I/(I-1)$ for the number of items.
- **CML** gets a paragraph and a hand-written estimator in the real data (the `conditional-ml` thread asks the lesson to compare all three), not just one sentence.
- **Go deeper:** two callouts, the planned EM-for-Rasch cycle and the two-item JML result (JML exactly doubles the CML difference).
- **Simulate:** the dramatic prior case is a 2PL (every slope 1.5) with skewed abilities; a Rasch fit barely moves under the same skew, which the real data echo.
- **Problem 1** uses a joint likelihood with a mistake written for the lesson (the 252 slide's is in an image).
- Widgets rebuilt from Ben's `em_irt.html`: θ known/hidden; JML stretch; ripple vs. fix; E step; EM step by step (with a weak-items switch). Helpers in `lessons/widgets/item-estimation.js`.

## Open questions

- None.
