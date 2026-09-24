<!-- Outlined backwards from lessons/rasch.qmd (draft), 2026-09-24; updated for the protocol retrofit (#11), 2026-09-24. -->

# The Rasch model (`rasch`)

Module: irt · Prereqs: ctt-limits · Core · Status: outline (page is a draft)

## Core ideas

1. **The Rasch model is logistic regression with nothing observed on the right.** Opens with a Recall of `likelihood` (chess on Elo; item intercepts raise the slope 0.50 → 0.83; Y15 barely moves with Elo; the closing question). $\theta$ replaces $\beta_1 \times$ Elo, $b$ is the item intercept with its sign flipped. Write $\Pr(x_{ij}=1)$ in terms of $\theta_j - b_i$; read an ICC. *(major)* Rasch (1960; expanded ed. 1980, University of Chicago Press; no DOI, verified via Open Library and the Crossref record of Wolins's 1982 JASA review, doi:10.2307/2287805). The $D \approx 1.7$ probit aside cites and links Camilli (1994), [doi:10.3102/10769986019003293](https://doi.org/10.3102/10769986019003293) (Ben, 09-24).
2. **The scale has no origin.** Only $\theta - b$ matters, so software fixes a constraint; results can differ by a shift. *(major)* Shown in the chess `wright` chunk: mean EAP $\theta$ = 0.00, and `all.equal` after adding 1 to every $\theta$ and $b$ (Ben, 09-24). `mirt`: Chalmers (2012), doi:10.18637/jss.v048.i06; CML programs fix one item or sum-zero: Mair & Hatzinger (2007), doi:10.18637/jss.v020.i09. The unit, by contrast, *is* pinned by the Rasch model (slopes = 1): problem 2, and the difficulty-pool comparison (pool SD 1.75 = our 2.13 / SD of ability 1.22).
3. **People and items share one scale.** The Wright map shows whether a test is targeted at the people who took it.
4. **The model's assumptions.** Unidimensionality and local independence; brainstorm how each fails. Lord (1980), reprint doi:10.4324/9780203056615.
5. **The sum score is sufficient for $\theta$.** Patterns with the same sum score get the same estimate; the 2PL breaks this. *(major)* Fisher (1922), doi:10.1098/rsta.1922.0009. A second Recall of `likelihood` (the intercept's score equation $\sum(y-p) = 0$) gives the one-line reason: $\hat\theta$ solves $r = \sum_i P_i(\theta)$. Carries the lesson's first-person verdict: report the sum score when the Rasch model fits and everyone took the same items; $\hat\theta$ earns its keep when items differ (→ `equating`). *(Claude's draft, for Ben to confirm; A2's equal-slopes prose is unchanged.)*
6. **Specific objectivity.** Non-crossing ICCs make item comparisons independent of the people; it is a demand on the data, not a gift. *(major)* Rasch (1977), doi:10.1163/24689300-01401006; Wright (1997), doi:10.1111/j.1745-3992.1997.tb00606.x.

A short note closes Core ideas: estimation is hard because nothing is known; `mirt` uses EM/MML (Bock & Aitkin, 1981, doi:10.1007/BF02293801); CML (from the Go deeper) is the Rasch model's own alternative.

## Picks up

- Logistic regression and the likelihood (from `likelihood`).
- Sum scores treat items as interchangeable; the sum score vs. item relationship is not linear (from `ctt-limits`).
- Long IRW format, reshaping to wide, dropping empty respondents (from `irw-data`).
- The score equation for an intercept, $\sum(y - p) = 0$ (from `likelihood`): Recall callout in idea 5.
- Probit regression, for the optional $D \approx 1.7$ aside (from outside the course; not taught earlier).
- Items and people on one scale; the construct map orders the items (from `constructs`).
- Consistency with the Rasch model as a route to a unit, the Lexile (from `measurement`).
- CTT says nothing about item responses (from `ctt-reliability`).

## Promises / leaves open

- The slope slider previews the 2PL; equal slopes is testable → `1pl-to-4pl`.
- Specific objectivity fails when ICCs cross → `1pl-to-4pl` (crossing ICCs in chess), `parameter-invariance`.
- Sum score sufficiency holds only under Rasch → `1pl-to-4pl` (2PL weights items), `ability-estimation`.
- Precision depends on where you are on the scale (Wright map) → `information`.
- The scale has no origin; compare across studies with care → `equating`.
- Unidimensionality → `dimensionality`, `fa-confirmatory`.
- Local independence (passages, repeated trials) → `dimensionality`, `explanatory-irt`.
- How abilities and item parameters are estimated (EM, then abilities given items) → `ability-estimation`, `item-estimation`.
- Formal fit checks, and outfit's sampling distribution → `fit-prediction`.
- Is a wide spread of difficulty typical? Done: baseline from the IRW difficulty pool behind the diffsim vignette (`irw::diff_long`, 145 tables; Zhang et al., 2025, doi:10.31234/osf.io/jbhxy_v4). Chess SD 1.75 on the pool's scale vs. a median of 0.99; wider than 74%.
- Are equal slopes plausible in typical data? → deep dive #21 (slopes across the IRW).
- Sufficiency and specific objectivity for ordered categories (the partial credit model) → `polytomous` (Andersen 1977 covers the polytomous case too).
- Conditional ML and the incidental-parameter problem (Andersen, 1970; Neyman & Scott, 1948) → `item-estimation` (JML vs. MML vs. CML).
- Conditioning on the sum score to check fit without $\theta$ (the `wirs` table; Andersen's 1973 LR test) → `fit-prediction`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `chess_lnirt` | main example | 256 players with responses (3 of 259 have none). Difficulty spread SD 2.1, range 8.5 (Y31 −4.9, Y30 +3.6); wider than 74% of the IRW difficulty pool. Rank correlation of p-values and $b$ −0.9998. Mean $\theta$ 0.00, mean $b$ 0.12: well targeted. Four of the five worst items by $|z|$ overfit (outfit 0.64–0.73); Y15 has the largest outfit of all 40 (2.2), the `likelihood` promise; its empirical plot barely rises. | `likelihood` (deliberate thread: Elo → θ; Y15 again), `1pl-to-4pl` (crossing ICCs). Recorded under `reuses:`. |
| `wirs` | contrast | 1,005 respondents, six consultation channels (item wording from the `ltm` docs, Rizopoulos 2006, doi:10.18637/jss.v017.i05). Observed vs. Rasch-implied $\Pr(x_i = 1 \mid r)$: item 3 steeper than the model (0.04 vs. 0.11 at $r=1$; 0.96 vs. 0.84 at $r=5$); item 1 (informal discussion with individual workers) rises then falls (0.58 at $r=3$, 0.36 and 0.40 at 4 and 5 vs. 0.76 and 0.90). | — |

Sanity check: the Simulate section's Rasch-generated data, fit with the same `mirt` call (RMSE of $b$ 0.13 at 500 × 10).

Data notes: `get_processing_notes` was not available in this session; the landing pages and the source packages' documentation were read (chess: `LNIRT`; wirs: `ltm::WIRS`). Neither table has waves. Keying: chess 1 = solved; wirs 1 = that kind of consultation took place.

## Widget / simulation / problem ideas

**Widgets**
- ICC: sliders for $b$ and slope, normal-CDF overlay (ideas 1, previews 2PL).
- Shift everything: add $C$ to all $\theta$ and $b$, probabilities don't move (idea 2).
- Wright map: mean ability, mean difficulty, difficulty spread (idea 3). Carries the optional Core-ideas predict ("average person 1.5 logits above the average item: what proportion right?").
- Sufficiency: pick a pattern of 5 items, see estimates for every pattern with that sum score; toggle Rasch/2PL (idea 5).
- Do the curves cross? Two items, B's slope adjustable (idea 6).

**Predict-then-check:** among the worst-fitting chess items, do you expect overfit or underfit? Answered by the infit/outfit table (four of five overfit; Y15 the exception).

**Simulate:** Rasch data with `np` people and `ni` items; fit with `mirt`; plot estimated vs. true difficulties; vary `np` (50, 2000) and `ni`. With the seed: RMSE of $b$ 0.34 / 0.13 / 0.04 at 50 / 500 / 2,000 people; 0.13 with 40 items. Note that `mirt`'s `d` is an easiness.

**Problems**
1. Derivation: the logit identity; log-odds = $\theta - b$; what one unit of $\theta$ does to the odds.
2. Derivation / judgment: additive vs. multiplicative indeterminacy; what the Rasch model does pin down.
3. Real data with a twist: specific objectivity in chess. Players who solved exactly one of two problems, split by rest score; compare with $1/(1+e^{b_i-b_k})$; repeat with Y15. (Replaces "plot p against raw `d`", dropped in the retrofit: the `d` = easiness point is made in Simulate.)
4. Design: Wright map for chess; who gets least information; propose two items to add.
5. Judgment: empirical fit plots in chess vs. wirs vs. simulated Rasch data; what good fit looks like.
6. Challenge: two chess players with the same sum score, different patterns; compare `fscores` under Rasch and 2PL. Open part: how much is lost by reporting the sum score if the 2PL fits better?

## Go deeper

- **The sum score is sufficient (agreed target, confirmed by Ben 09-24; in the page since the retrofit).** Factorize the likelihood so it depends on $\theta$ only through $r$; conditioning on $r$ removes $\theta$ (elementary symmetric functions), which gives conditional ML (Andersen, 1970, doi:10.1111/j.2517-6161.1970.tb00842.x; Neyman & Scott, 1948, doi:10.2307/1914288) and makes specific objectivity a theorem ($\Pr(x_i=1 \mid x_i+x_k=1) = 1/(1+e^{b_i-b_k})$; Andersen 1973 LR test, doi:10.1007/BF02291180). Converse: Andersen (1977), doi:10.1007/BF02293746; Fischer (1995), doi:10.1007/978-1-4612-4230-7_2. Why: `1pl-to-4pl`, `ability-estimation`, `item-estimation`, `parameter-invariance`, `polytomous`. Length: about a page.

## Open questions

- A2 (Ben, 09-24): the equal-slopes prose stands, no separate verdict. Rule A is met by a new verdict on sum score vs. $\hat\theta$ (idea 5), Claude's draft: Ben to confirm or replace.
- `ctt-limits` is still a stub, so there is no Recall of it yet; the opening paragraph links it. The cross-check pass should add a Recall once it is drafted (its promises: item curves against ability; the sum score contains the item, paid in the `wirs` table's note that $r = 0$ and $r = 6$ agree by construction).
- `lessons/code/rasch-difficulty-spread.R` and `lessons/data/rasch-difficulty-spread.csv` (the earlier 40-table baseline) are no longer used by the page; proposed for removal (the csv is outside this PR's scope).

Dropped in the retrofit: problem 3 "proportions against raw `d`" (see Problems); the `wirs` empirical plot (replaced by the conditional table, which prints its numbers); the empirical plot of item 13 (replaced by Y15, the item the thread promises).
