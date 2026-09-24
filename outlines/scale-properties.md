<!-- Outlined 2026-09-24. New lesson (Ben's suggestion, #66); no EDUC 252 source. Built from measurement theory and the literature on gains, growth and gaps. -->

# Scale properties: is the scale equal-interval? (`scale-properties`)

Module: uses · Prereqs: measurement, rasch · Optional · Status: outline

## Core ideas

1. **What "equal-interval" would mean.** A one-unit difference means the same thing anywhere on the scale. Stevens declared it by the rule of assignment; Michell asks for evidence that the attribute is quantitative at all; Borsboom and Mellenbergh reply that IRT models are such hypotheses and can be tested. *(major)* Sources: Stevens (1946), doi:10.1126/science.103.2684.677; Michell (1997), doi:10.1111/j.2044-8295.1997.tb02641.x; Michell (2000), doi:10.1177/0959354300105004; Borsboom & Mellenbergh (2004), doi:10.1177/0959354304040200.
2. **Additive conjoint measurement, and what the Rasch model licenses.** If persons and items combine additively, $\theta - b$, then order relations in the data (the cancellation conditions) pin the scale down up to a linear transformation. The Rasch model is a probabilistic version of this; the 2PL and 3PL are not, and their $\theta$ metric is a convention (Lord). So the Rasch claim is conditional on fit, and fit can be checked. *(major)* Sources: Luce & Tukey (1964), doi:10.1016/0022-2496(64)90015-x; Perline, Wright & Wainer (1979), doi:10.1177/014662167900300213; Lord (1975), doi:10.1007/bf02291567; Kyngdon (2008), doi:10.1177/0959354307086924 (a dissent); Domingue (2014), doi:10.1007/s11336-013-9342-4 (testing the cancellation conditions on test scores); Karabatsos (2001), *Journal of Applied Measurement* 2(4) (no DOI; *not verified*).
3. **Comparisons that need an interval scale, and those that don't.** Order-preserving rescalings leave the sign of a difference alone only when one distribution sits above the other everywhere (from `measurement`). Randomized comparisons of overlapping groups are fairly robust; comparisons of groups that sit on different parts of the scale are not. *(major)* Sources: Bond & Lang (2013), doi:10.1162/rest_a_00370; Ho (2009), doi:10.3102/1076998609332755 (metric-free gaps); Reardon & Ho (2015), doi:10.3102/1076998615570944.
4. **Gains, growth and vertical scales.** Who gains more, the low starters or the high? A question about intervals at two different places on the scale. Vertical scales (linked across grades, from `equating`) inherit the problem, and decisions made in building them change growth interpretations. *(major)* Sources: Yen (1986), doi:10.1111/j.1745-3984.1986.tb00252.x; Ballou (2009), doi:10.1162/edfp.2009.4.4.351; Briggs & Weeks (2009), doi:10.1111/j.1745-3992.2009.00158.x; Briggs (2013), doi:10.1111/jedm.12011; Briggs & Domingue (2013), doi:10.3102/1076998613508317; Jacob & Rothstein (2016), doi:10.1257/jep.30.3.85.
5. **What to do about it.** State which conclusions survive every monotone rescaling; use metric-free summaries (percentile-based gaps, Ho's $V$) where the claim allows; check model fit before leaning on $\theta$'s unit; and say which conclusions depend on it. My verdict (for the draft): treat $\theta$ from a well-fitting Rasch model as the best available interval scale, and treat gain comparisons across distant parts of it as hypotheses, not findings. Sources: Ho (2009); Domingue (2014); Bond & Lang (2013).

All DOIs above were checked on Crossref on 09-24 (Michell 2000 by DOI lookup). Karabatsos (2001) is *not yet verified*.

## Picks up

- Levels of measurement; an order-preserving rescaling can shrink, grow or reverse a difference in group means; the Lexile as a model-based unit (from `measurement`, idea 5).
- When a mean difference survives every rescaling: stochastic dominance (from `measurement`'s Go deeper callout).
- Is the attribute quantitative? (Michell) (from `measurement`; also `validity-causal` if taught).
- The scale has no origin; only $\theta - b$ matters (from `rasch`).
- Specific objectivity; the sum score is sufficient under Rasch (from `rasch`).
- Outfit and infit, and misfit as overfit or underfit (from `rasch`).
- Vertical linking across grades (from `equating`, if taught first; not a prerequisite).
- The reliability of a difference score (from `score-meaning`, if taught first).
- Whether a unit means the same across the scale (from `score-meaning`).

## Promises / leaves open

- Group gaps under DIF: when items, not the scale, differ across groups → `dif`.
- Treatment effects on latent scales, and when the construct itself changes → `invariance-experience`.
- Nonlinear transformations of $\theta$ in reporting (scale scores) → `score-meaning` (already there).
- A formal test of the cancellation conditions on IRW data → unpaid (a deep-dive candidate: the equal-interval check across the IRW, following Domingue 2014).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `project_kids_wj_lwid_wave` | main example | Woodcock–Johnson Letter-Word Identification in the Project KIDS studies (Hart et al., 2021): 76 items, basal and ceiling rules (every child's items form a contiguous run). A Rasch model over waves 1 and 3, 3,319 children with both. **Gains by wave-1 quartile:** 2.6, 3.6, 2.9 and 1.2 logits (raw WJ-style scores: 10.2, 13.3, 11.0, 5.4): low starters gain more than high starters, twice as much in wave-1 SD units (0.78 against 0.35). The quartiles' $\theta$ ranges don't overlap (Q1 −5.8 to −4.0, Q4 1.6 to 5.7 at the 5th and 95th percentiles), so some monotone rescaling must reverse the order. A convex one, $g(z) = (e^{kz}-1)/k$ on the wave-1 $z$ scale, does it at $k = 0.38$, which makes a unit at +2 SD count 4.6 times one at −2 SD. **Regression to the mean:** grouping by wave-2 score instead shrinks the gap (2.3 against 1.5 logits) but keeps the order. **Does Rasch license the unit here?** Not well: the 2PL fits far better (AIC 149,515 against 160,224), and 50 of 76 items overfit (outfit < 0.7), slopes steeper than Rasch allows. **The treatment contrast:** the programme's effect on gains is 0.029 wave-1 SD (SE 0.016) on $\theta$ and runs from 0.010 to 0.131 under rescalings with $k$ from −1 to 1.5: its sign holds (randomized, overlapping groups), but its size and its "significance" move. | — |
| simulated copy of the main table | sanity | Data simulated from the Rasch model with the table's estimated difficulties and the children's estimated $\theta$s: Rasch fits, the 2PL gains nothing, the cancellation checks pass. A known answer against which the real table's misfit reads. (Not an IRW table; see Open questions.) | — |

One IRW table: the lesson is conceptual, and its one table has both a growth comparison and a randomized one.

Data notes: `get_processing_notes` was not available in this session; the landing page was read. Items outside a child's basal–ceiling window are missing, not scored; the WJ's own raw score credits items below the basal, which the "WJ-style raw score" above copies. Missing by design and ignorable given the model (Mislevy & Wu, 1996, doi:10.1002/j.2333-8504.1996.tb01708.x). The table pools eight projects; the timing of waves 1 and 3 and the treatment in each project are to be read from the LDbase documentation (doi:10.33009/ldbase.1620837890.bcf8) before drafting. The WJ is a commercial instrument: no item text in the lesson.

## Widget / simulation / problem ideas

**Widgets**
- Rescale the gains: the four quartiles' wave-1 and wave-3 distributions; a curvature slider ($k$); the bar chart of mean gains reorders as $k$ passes 0.38 (ideas 3, 4).
- Overlap or not: two groups whose distributions you can slide; the range of $k$ over which the sign of the difference holds, and the stochastic-dominance check (idea 3; Recall from `measurement`).
- Cancellation: a 3 × 3 table of proportions correct (three score groups × three items); check single and double cancellation by eye; toggle Rasch- and 2PL-generated tables (idea 2).
- Vertical scale: two grades' tests linked through common items; a slider for how the grades' variances are set (Briggs & Weeks's decisions); the growth from grade to grade by starting level (idea 4).

**Predict-then-check:** children in the lowest wave-1 quartile gain more logits than those in the top quartile. How strong a rescaling, stretching the top of the scale, would it take to make the top quartile gain more? Answered by the $k$ at which the gains cross (0.38: a unit at +2 SD worth 4.6 of one at −2 SD).

**Simulate:** two data sets with the same items and the same people: one from the Rasch model, one from a 2PL with slopes as varied as the real table's. Fit Rasch to both; compare gains by quartile on $\theta$ and on a rescaled $\theta$; run the cancellation check. Shows that the conclusion is licensed in one world and not the other. `mirt`, seconds.

**Problems**
1. Derivation: show that under the Rasch model the double cancellation condition holds for the matrix of $\Pr(x_{ij} = 1)$, and construct a 2PL example where it fails.
2. Real data with a twist: redo the gain comparison with 2PL $\theta$s. Does the order change, and how far is the crossing $k$ from 0.38?
3. Judgment: a district says its lowest readers "caught up" on a vertically scaled test. What would you need to know before believing it?
4. Design: to test whether a reading scale is equal-interval, what data would you collect (items, people, ranges), and what check would you run?
5. Real data: compute Ho's $V$ for the treatment contrast in wave 3. How does it compare with the standardized mean difference?
6. Challenge (open): Michell says psychometrics has never tested whether its attributes are quantitative; Borsboom and Mellenbergh say IRT does. What would it take to convince each of them?

## Go deeper

- **Stochastic dominance and monotone rescalings, for gains.** Extends `measurement`'s callout from one difference to a difference of differences: a gain comparison survives every monotone rescaling only under conditions that non-overlapping groups can't meet. Why: `invariance-experience`, `dif` (gaps), `equating` (vertical scales). Length: half a page to a page.
- **Additive conjoint measurement in one page** (the cancellation conditions, and why Rasch satisfies them in expectation). Why: `rasch` (specific objectivity), `measurement`. Length: about a page.

## Open questions

- **The split with `measurement` (#66).** Proposal:
  - `measurement` introduces the levels, the claim that an interval scale needs a unit that means the same everywhere, and one demonstration that order-preserving rescalings can change or reverse a between-group difference at one time point (its RCT table), with the stochastic-dominance callout. No IRT.
  - `scale-properties` takes it further: what would make a unit equal (conjoint measurement), what the Rasch model does and doesn't license (conditional on fit; the 2PL's metric is a convention), and the comparisons that lean on it hardest: gains from different starting points, growth, vertical scales and gap trends.
  - Hooks: `measurement`'s promise "unpaid for growth and vertical scales (Briggs 2013) unless `equating` takes it" moves here, so `measurement` would read "→ `score-meaning`, `equating`, `scale-properties` (growth, vertical scales)". `equating` names vertical scaling and points here for what growth on it means. `measurement`'s Go deeper callout stays in `measurement`; this lesson extends it to gains.
  - Since `scale-properties` is optional, a core reader still meets the interval question in `measurement` and `score-meaning` (percentile ranks against z and T scores).
- **One IRW table and a simulated sanity copy.** PROTOCOL.md §5 asks for a sanity *table*; here the known answer comes from a simulated copy of the main table. Acceptable, or should the sanity be an IRW table known to fit the Rasch model (which one?)?
- **Ben's own work.** Domingue (2014) and Briggs & Domingue (2013) are central sources. Cite them as the literature, in the usual way?
- **Wave timing and treatments** in Project KIDS are still to be read from LDbase; the lesson shouldn't describe the programme's effect until they are.
