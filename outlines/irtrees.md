<!-- Outlined 2026-09-24 from EDUC 252 slides c8 (slides 31–42: trees, linear vs. nested, response styles, skipped items, the likelihood, lme4 coding, the neutrality example), PS8#4 (fast responding, a bonus), and the code c8/irtree.R, c8/irtree2.R, c8/irtree_sim.R and ps8/fast.R. -->

# IRTree models (`irtrees`)

Module: beyond · Prereqs: polytomous, explanatory-irt · Optional · Status: outline

## Core ideas

1. **A response as a sequence of decisions.** Break each response into binary nodes (do I take a side at all? which side? how strongly?) and fit an item response model at each node. The response probability is the product of the branch probabilities along its path. *(major)* Sources: De Boeck & Partchev (2012), doi:10.18637/jss.v048.c01; Böckenholt (2012), doi:10.1037/a0028111; Thissen-Roe & Thissen (2013), doi:10.3102/1076998613481500.
2. **Tree shape and node abilities are choices.** Linear trees (one branch ends, the other continues) vs. nested trees (c8 slide 33); one θ for all nodes vs. a separate θ per node, and the correlations between them. A linear tree with one θ is the sequential model from `polytomous`. *(major)* Sources: De Boeck & Partchev (2012); Tutz (1990), doi:10.1111/j.2044-8317.1990.tb00925.x; Jeon & De Boeck (2016), doi:10.3758/s13428-015-0631-y.
3. **Fitting a tree is recoding, then a mixed model.** Each response becomes one row per node it passes through (the pseudo-items), and the model is `resp ~ 0 + item:node + (0 + node | id)`, the `explanatory-irt` formula with the node as an item predictor (c8 slide 41, with Ben's warning: `node` must be a factor). Source: De Boeck & Partchev (2012); `lme4`: Bates et al. (2015), doi:10.18637/jss.v067.i01.
4. **Response styles.** Midpoint and extreme responding are person tendencies that run across content; a tree gives them their own dimensions, so the content θ is estimated net of them. *(major)* Sources: Baumgartner & Steenkamp (2001), doi:10.1509/jmkr.38.2.143.18840; Böckenholt (2017), doi:10.1037/met0000106; Khorramdel & von Davier (2014), doi:10.1080/00273171.2013.866536; Plieninger & Meiser (2014), doi:10.1177/0013164413514998.
5. **Trees for what the response hides: speed and skips.** A first node for "answered fast" (PS8#4) or "skipped / not reached" (c8 slide 36) turns missingness or timing into data, with its own θ that can correlate with the trait. Sources: Debeer, Janssen & De Boeck (2017), doi:10.1111/jedm.12147; DiTrapani, Jeon, De Boeck & Partchev (2016), doi:10.1016/j.intell.2016.02.012; Wise & Kong (2005), doi:10.1207/s15324818ame1802_2.

All references above were checked on Crossref (09-24).

## Picks up

- Polytomous models built from dichotomizations, and the sequential model in particular (from `polytomous`; its promise: IRTrees → `irtrees`).
- The mixed-model formula for item responses, item predictors, crossed random effects (from `explanatory-irt`; its promise: node as an item-side predictor → `irtrees`).
- Response styles, acquiescence and extreme responding (from `instrument-building`; its promise → `irtrees`).
- Skipped responses carry information (from `guessing-priors`; its promise → `irtrees`). Paid in the simulation and a problem only: none of the tokenless tables checked has enough skips (the Borges residency exam has 54 blanks in 199,400 responses).
- Person fit and aberrant responding (from `fit-prediction`, listed there as a candidate for `irtrees`): the fast-responding tree is one answer.
- Reverse keying (thread from `ctt-reliability`): the data are keyed before the tree is built.
- The PCM is a Rasch model (from `polytomous`'s Go deeper): a tree with Rasch nodes is not a PCM, and the lesson says why.

## Promises / leaves open

- Response time as a node → `response-time` (the tree uses a fixed 2 s cut; the continuous treatment is there).
- Whether response-style dimensions threaten validity arguments (a score net of style vs. a raw score) → `validity-evidence` (a Recall at most; otherwise unpaid).
- Choosing among trees for the same categories (linear vs. nested, which nodes share θ): unpaid beyond AIC; a candidate IMV comparison.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `bfi_goldberg_1992_conscientiousness` | main example | IPIP Big-Five markers (Goldberg, 1992, doi:10.1037/1040-3590.4.1.26; Open Psychometrics, CC BY 4.0): 19,718 complete respondents × 10 items, 1–5. A GRM flags C2, C4, C6 and C8 as reverse-keyed. On 3,000 respondents, a three-node tree (midpoint? side? extreme?) with a separate θ per node beats one shared θ by a wide margin (AIC 85,950 → 82,875). Node SDs: midpoint 0.78, side (conscientiousness) 1.67, extreme 1.22. Avoiding the midpoint and choosing the extremes correlate 0.61; each correlates only 0.28 and 0.19 with the content node. So there is a "decisiveness" style that is mostly separate from conscientiousness. | — |
| `introversion_extroversion` | contrast (fast responding, PS8#4) | Multidimensional Introversion–Extraversion Scales development data (Open Psychometrics, CC BY 4.0): 7,188 respondents × 91 items, 1–5, with per-item response times; median 3.2 s, 15% under 2 s. A two-node tree (slow > 2 s? then agree?) on 1,500 respondents: the speed node's θ correlates 0.01 with the trait node. Here fast responding says nothing about introversion–extraversion. That is the finding: PS8#4 asked whether fast responders on conscientiousness were less conscientious, and the tree is the tool, but on this scale the answer is no. Sensitivity to the 2 s cut is left to problem 5 (the 1, 1.5 and 3 s refits are slow at 91 items). | — |
| sanity: simulated GRM data (c8/irtree_sim.R) | sanity | A tree with one shared θ fitted to data simulated from a graded model recovers the ordering of item locations; a tree fitted to data simulated from a tree recovers the node correlations. No IRW table has a published tree answer we could match exactly; see Open questions. | — |

`ffm_CSN` (the 252 table for PS8#4 and c8/irtree2.R) has no tokenless CSV, and the #15 subsample is unlikely soon (course-33, 09-24). `bfi_goldberg_1992_*` is the same instrument family (the IPIP Big-Five markers on Open Psychometrics), smaller and tokenless, so it replaces ffm for the response-style tree without losing anything. It lacks response times, which is why the fast-responding example uses `introversion_extroversion`. If the ffm subsample arrives, ffm_CSN (with RT) would let one table carry both examples.

The comparison of tree AIC with the GRM (Ben's question on c8 slide 42): the three-node tree is a full recoding of the five categories, so its likelihood is on the same data as the GRM (AIC 83,522 from `mirt`), but `glmer` with `nAGQ = 0` and `mirt`'s EM compute the marginal likelihood differently. The two-node tree of c8/irtree2.R drops the extreme split, so its AIC is not comparable at all. The lesson makes that the teaching point, not a model ranking.

## Widget / simulation / problem ideas

**Widgets**
- Tree builder: a 1–5 response; pick a linear or nested tree and watch each category's path and pseudo-items (the recoded rows) appear (ideas 1, 3).
- Node curves: sliders for θ on each node (content, midpoint, extreme); the five category probabilities update, and setting the style θs equal shows what a GRM cannot separate (ideas 2, 4).
- Two respondents, same conscientiousness: one extreme responder, one midpoint lover; their raw sum scores differ, their content θs don't (idea 4).

**Predict-then-check:** do people who avoid the middle category also choose the extremes, and does either tendency track conscientiousness? Answered by the node correlations (0.61 between the style nodes, 0.28 and 0.19 with content).

**Simulate:** c8/irtree_sim.R, extended: simulate a three-node tree with correlated node θs; fit one-θ and per-node-θ trees; compare the recovered correlations with the truth. Then simulate skips that depend on θ and show how treating them as wrong or as missing biases θ, and how a skip node repairs it. Use `glmer(..., nAGQ = 0)` or `lmer` (the linear probability version Ben used for speed) to keep the browser run to seconds.

**Problems**
1. Derivation: write the category probabilities of the three-node tree and show they sum to one; show that a linear tree with one θ and Rasch nodes is the sequential model, not the PCM.
2. Real data with a twist (c8/irtree2.R): fit the midpoint tree to the other four `bfi_goldberg_1992_*` traits. How much does the midpoint tendency vary across traits?
3. Judgment (c8 slide 42): can you compare the tree's AIC with the GRM's? When yes, when no?
4. Design: a survey will be given in two countries with different response-style norms. How would you use a tree to make the comparison fairer, and what would it not fix?
5. Real data (PS8#4): how sensitive is the fast-responding result to the 2 s cut? Try 1, 1.5 and 3 s.
6. Challenge (open): skipped items in a low-stakes test. Build a tree with a skip node and argue whether the skip θ belongs in the reported score.

## Go deeper

- **The tree likelihood factorizes over nodes.** Because each node's branch probability is conditional on reaching it, the likelihood is a product of ordinary item response likelihoods over pseudo-items, which is why any IRT or GLMM software fits it (c8 slides 37–39). Why: `polytomous` (sequential model), `explanatory-irt`, `response-time`. Length: half a page.

## Open questions

- `ffm_CSN` replaced by `bfi_goldberg_1992_conscientiousness` (response styles) and `introversion_extroversion` (fast responding). *Default:* use these two; revisit only if the ffm subsample (#15) is released, since ffm_CSN would let one table carry both examples.
- The sanity check is simulated rather than an IRW table with a published answer. *Default:* accept simulation as this lesson's sanity check; a published tree result on an IRW table (e.g. De Boeck & Partchev's verbal-aggression tree, which needs the three-category `verbagg` that the IRW stores dichotomized) would be better if it becomes available.
- The skipped-responses promise from `guessing-priors` is paid only in simulation and a problem, since no tokenless table has enough skips. *Default:* accept.
