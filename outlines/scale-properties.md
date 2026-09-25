<!-- Outlined 2026-09-24. New lesson (Ben's suggestion, #66); no EDUC 252 source. Built from measurement theory and the literature on gains, growth and gaps. Tidied 09-24 (#62): Ben's answers E11, F23, F24 and the tranches applied. -->

# Scale properties: is the scale equal-interval? (`scale-properties`)

Module: uses · Prereqs: measurement, rasch · Extension · Status: draft

**The split with `measurement` (E11, settled).** `measurement` keeps the levels, the equal-unit claim, one RCT rescaling and the stochastic-dominance callout, with no IRT. This lesson takes conjoint measurement, what Rasch licenses, gains, growth, vertical scales and gap trends.

## Core ideas

1. **What "equal-interval" would mean.** A unit means the same thing anywhere on the scale. Stevens declared it by rule; Michell asks for evidence that the attribute is quantitative; Borsboom and Mellenbergh reply that IRT models are testable hypotheses of that kind. *(major)* Sources: Stevens (1946), doi:10.1126/science.103.2684.677; Michell (1997), doi:10.1111/j.2044-8295.1997.tb02641.x; Borsboom & Mellenbergh (2004), doi:10.1177/0959354304040200.
2. **Additive conjoint measurement, and what the Rasch model licenses.** If persons and items combine additively, $\theta - b$, order relations in the data (the cancellation conditions) pin the scale down up to a linear transformation. The Rasch model is a probabilistic version; the 2PL and 3PL are not, and their $\theta$ metric is a convention (Lord). So the Rasch claim is conditional on fit, and fit can be checked. *(major)* Sources: Luce & Tukey (1964), doi:10.1016/0022-2496(64)90015-x; Perline, Wright & Wainer (1979), doi:10.1177/014662167900300213; Lord (1975), doi:10.1007/bf02291567; Domingue (2014), doi:10.1007/s11336-013-9342-4.
3. **Comparisons that need an interval scale, and those that don't.** Order-preserving rescalings leave the sign of a difference alone only when one distribution sits above the other everywhere (Recall `measurement`). Randomized comparisons of overlapping groups are fairly robust; comparisons of groups on different parts of the scale are not. *(major)* Sources: Bond & Lang (2013), doi:10.1162/rest_a_00370; Ho (2009), doi:10.3102/1076998609332755.
4. **Gains, growth and vertical scales.** Who gains more, low starters or high? A question about intervals at two places on the scale. Vertical scales inherit the problem, and decisions made in building them change growth interpretations. *(major)* Sources: Yen (1986), doi:10.1111/j.1745-3984.1986.tb00252.x; Briggs & Weeks (2009), doi:10.1111/j.1745-3992.2009.00158.x; Briggs (2013), doi:10.1111/jedm.12011; Briggs & Domingue (2013), doi:10.3102/1076998613508317.
5. **What to do about it.** State which conclusions survive every monotone rescaling; use metric-free summaries (Ho's $V$) where the claim allows; check fit before leaning on $\theta$'s unit. Verdict (first person): treat $\theta$ from a well-fitting Rasch model as the best available interval scale, and treat gain comparisons across distant parts of it as hypotheses, not findings.

Ben's own papers (Domingue, 2014; Briggs & Domingue, 2013) are cited as ordinary literature (F24). For *Going further*: Michell (2000), doi:10.1177/0959354300105004; Kyngdon (2008), doi:10.1177/0959354307086924 (a dissent); Karabatsos (2001), *Journal of Applied Measurement* 2(4), 389–423 (no DOI; verified on PubMed, PMID 12011506); Reardon & Ho (2015), doi:10.3102/1076998615570944; Ballou (2009), doi:10.1162/edfp.2009.4.4.351; Jacob & Rothstein (2016), doi:10.1257/jep.30.3.85. All DOIs checked on Crossref 09-24.

## Picks up

- Levels of measurement; rescalings can reverse a mean difference; the Lexile; stochastic dominance (Go deeper callout); Michell's question (from `measurement`).
- Only $\theta - b$ matters; specific objectivity and sufficiency; outfit and infit (from `rasch`).
- Vertical linking across grades (from `equating`; not an ancestor: an "if you've done it" aside that restates what linking is, E2).
- Whether a unit means the same across the scale, and the reliability of a difference score (from `score-meaning`; not an ancestor: an "if you've done it" aside, E2).

## Promises / leaves open

- Group gaps under DIF (items, not the scale, differ across groups): a pointer to `dif` (not a descendant, E2; no hook).
- Treatment effects on latent scales, and a construct that changes: a pointer to `invariance-experience` (not a descendant, E2; no hook).
- Nonlinear transformations of $\theta$ in reporting (scale scores): already in `score-meaning`; a pointer (no hook).
- A formal test of the cancellation conditions on IRW data → unpaid (a deep-dive candidate following Domingue, 2014).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `project_kids_wj_lwid_wave` | main example | Woodcock–Johnson Letter-Word Identification in Project KIDS (Hart et al., 2021; LDbase doi:10.33009/ldbase.1620837890.bcf8): 76 items with basal and ceiling rules. Rasch over waves 1 and 3, 3,319 children with both. **Gains by wave-1 quartile:** 2.6, 3.6, 2.9 and 1.2 logits; low starters gain twice as much in wave-1 SD units (0.78 vs. 0.35). The quartiles' $\theta$ ranges don't overlap, so some monotone rescaling must reverse the order: $g(z) = (e^{kz}-1)/k$ does it at $k = 0.38$, where a unit at +2 SD counts 4.6 times one at −2 SD. Grouping by wave-2 score (regression to the mean) shrinks the gap (2.3 vs. 1.5) but keeps the order. **Does Rasch license the unit?** Not well: the 2PL fits far better (AIC 149,515 vs. 160,224), and 50 of 76 items overfit (outfit < 0.7). **Treatment contrast:** the effect on gains is 0.029 wave-1 SD (SE 0.016) on $\theta$, 0.010 to 0.131 for $k$ from −1 to 1.5: the sign holds; size and "significance" move. | — |
| simulated copy of the main table | sanity (F23, settled) | Data simulated from the Rasch model with the table's estimated difficulties and $\theta$s: Rasch fits, the 2PL gains nothing, the cancellation checks pass. A known answer against which the real table's misfit reads. | — |

Data notes: items outside the basal–ceiling window are missing by design, ignorable given the model (Mislevy & Wu, 1996, doi:10.1002/j.2333-8504.1996.tb01708.x). The table pools eight projects: read wave timing, treatments and processing notes on LDbase before describing the programme's effect (digest D). The WJ is commercial: no item text.

## Widget / simulation / problem ideas

**Widgets**
- Rescale the gains: a curvature slider ($k$); the quartiles' mean gains reorder as $k$ passes 0.38 (ideas 3, 4).
- Overlap or not: slide two groups apart; see the range of $k$ over which the sign holds (idea 3).
- Cancellation: a 3 × 3 table of proportions correct; check double cancellation for Rasch- and 2PL-generated tables (idea 2).
- Vertical scale: two linked grades; set how their variances are fixed (Briggs & Weeks); see growth by starting level (idea 4).

**Predict-then-check:** how strong a rescaling, stretching the top of the scale, would make the top quartile gain more than the bottom? Answered by the crossing $k$ (0.38).

**Simulate:** the same items and people from the Rasch model and from a 2PL with the real table's spread of slopes; fit Rasch to both; compare quartile gains on $\theta$ and rescaled $\theta$; run the cancellation check (`mirt`, seconds).

**Problems**
1. Derivation: under the Rasch model, double cancellation holds for the matrix of $\Pr(x_{ij} = 1)$; construct a 2PL example where it fails.
2. Real data with a twist: redo the gain comparison with 2PL $\theta$s. Does the order change, and how far is the crossing $k$ from 0.38?
3. Judgment: a district says its lowest readers "caught up" on a vertically scaled test. What would you need to know before believing it?
4. Design: what data and what check would test whether a reading scale is equal-interval?
5. Real data: compute Ho's $V$ for the treatment contrast at wave 3 and compare it with the standardized mean difference.
6. Challenge (open): Michell says psychometrics has never tested whether its attributes are quantitative; Borsboom and Mellenbergh say IRT does. What would convince each of them?

## Go deeper

- **Stochastic dominance and monotone rescalings, for gains.** Extends `measurement`'s callout to a difference of differences, which non-overlapping groups can't satisfy. Why: `invariance-experience`, `dif`, `equating`. Length: half a page to a page.
- **Additive conjoint measurement in one page** (the cancellation conditions, and why Rasch satisfies them in expectation). Why: `rasch`, `measurement`. Length: about a page.

## Open questions

- None. (Settled 09-24: E11 the split with `measurement`, F23 the simulated sanity copy, F24 Ben's papers cited as ordinary literature.)

## Drafting notes (09-25)

What changed from this outline when the lesson was drafted (`draft-scale-properties`):

- **Forms.** The WJ-III has parallel forms A and B with different words at the same positions, and the IRW table records only the position (about half the children in projects 5–9 took form B; projects 1–3 switch forms by wave). The lesson reads the form from the Project KIDS total-scores file on LDbase (matched on the IRW id, the row number of the Project KIDS files; checked against `cov_project`) and treats form × position as the item: 140 items with at least 100 responses. Project 3's spring responses have no recorded form and are set aside. Proposed for the IRW: add the form as a covariate (see the PR).
- **Numbers recomputed** on that basis: 3,009 children with fall and spring; gains by fall quarter 3.2, 3.6, 3.0, 1.2 logits (0.88, 1.00, 0.83, 0.34 fall SDs); crossing $k$ = 0.44, where a unit at +2 SD counts 5.8 times one at −2 SD; grouped on winter $	heta$ the ends gain 2.8 and 1.6. By grade, growth decelerates (about 3 logits in K and grade 1, 1.5 and 1.0 in grades 2 and 3). 2PL AIC 211,105 vs Rasch 226,621; 113 of 140 items overfit. The Rasch-simulated copy (same forms, starting points and ceiling rule) shows the design alone produces overfit (78 of 140) and a 2PL gain (LR 2,728 vs 15,793 real); double cancellation fails in 12.8% of tested triples (real) vs 8.2% (copy).
- **Treatment contrast** restricted to the four studies comparing ISI with business-as-usual (projects 1, 2, 5, 6). In projects 7 and 8 (ISI vs vocabulary) the group coded `treat = 1` has the size the data paper gives for the vocabulary arm, so they are left out. ISI's effect on gains is 0.06 fall SDs, 0.04–0.07 for $k$ from −1 to 0.5, 0.02 at $k$ = 1 and zero at $k$ = 1.5.
- **Wave timing** (digest D): waves 1–3 are the fall, winter and spring of one school year in each study (van Dijk et al., 2022, doi:10.5334/jopd.58); grades K (projects 1, 2), 1 (3, 5, 6, 9), 2 (7), 3 (8).
- **Widgets:** four. Added "which rescalings keep the Rasch model?" (ICC shapes under $f_k$, idea 2). The vertical-scale widget applies $f_k$ to a stylized five-grade scale instead of setting linked variances (idea 4). "Rescale the gains" moved into the real-data section as a static plot answered by the predict-then-check.
- **Simulate:** equal true gains, Rasch vs middle-peaked 2PL; $	heta$ by ML from the sum score (sufficiency), so it runs in seconds. The cancellation check moved to the real-data section.
- **Citations:** Fischer (2017) removed from *Going further* (the chapter could not be verified on Crossref). Added and verified: van Dijk et al. (2022), Connor et al. (2007, doi:10.1126/science.1134513), Dumont & Willis (2008, doi:10.1002/9780470373699.speced2229) for the WJ-III, Warm (1989), Mislevy & Wu (1996), the Project KIDS total-scores data (doi:10.33009/ldbase.1620844399.85a0).
