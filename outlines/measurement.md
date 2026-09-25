<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 8–22) and PS1#4. Tidied 09-24 (#62): Ben's answers C1, C2, E11 applied; citations verified against Crossref; table chosen. -->

# What is measurement? (`measurement`)

Module: foundations · Prereqs: none · Preliminary · Status: draft (#27)

## Core ideas

All references below verified 09-24 against Crossref unless noted; table citations from IRW biblio (landing pages).

Scope (digest E11): this lesson keeps the levels of measurement, the claim that an interval scale needs an equal unit, one rescaling demonstration on an RCT (C1) and the stochastic-dominance callout. No IRT. Conjoint measurement, what the Rasch model licenses, gains, growth, vertical scales and gap trends belong to `scale-properties`.

1. **Psychometrics measures latent constructs through probes.** Latent vs. manifest (height vs. anxiety); constructs; probes, items, stimuli; why standardization matters. "Probe" is used here only (notes/notation.md); later lessons say "item".
2. **Two definitions of measurement, and measurement as discovery.** *(major)* Michell: estimating the magnitude of a quantitative attribute relative to a unit (Michell, 1997, doi:10.1111/j.2044-8295.1997.tb02641.x; 1999, doi:10.1017/CBO9780511490040). Stevens: assigning numbers to objects by a rule (Stevens, 1946, doi:10.1126/science.103.2684.677). Temperature is the worked case: marks on a thermoscope tube aren't a unit, and temperature took conceptual work before it could be measured (Chang, 2004, *Inventing Temperature*, doi:10.1093/0195171276.001.0001). My verdict: aspire to Michell, and know that most practice runs on Stevens.
3. **Levels of measurement, through hardness.** *(major)* Nominal (rock types), ordinal (Mohs), interval (a unit that means the same everywhere) (Stevens, 1946). Each level licenses different claims. Would a geology faculty accept "this box of minerals has a uniform distribution of hardness"?
4. **What hangs on an equal unit.** *(major)* An order-preserving rescaling can shrink, grow or even reverse a difference in group means (Bond & Lang, 2013, *Review of Economics and Statistics* 95(5), 1468–1479, doi:10.1162/rest_a_00370; C2). The sign survives every rescaling only when one group's distribution sits above the other's everywhere (Go deeper). Two routes to a unit are named, not taught: a model-based unit (the Lexile; Stenner, Burdick, Sanford & Burdick, 2006, *Journal of Applied Measurement* 7(3), 307–322, no DOI, verified in PubMed, PMID 16807496; → `scale-properties`) and anchoring to an outside quantity that has a unit (years of schooling; Bond & Lang, 2018, *Journal of Human Resources* 53(4), 891–917, doi:10.3368/jhr.53.4.0916.8242r).
5. **What we want from a psychological measure** (my desiderata): insensitive to nonfocal attributes; calibrated to the task (wide range vs. fine distinctions); precise quickly. One paragraph, which later lessons pick up.

## Picks up

- None (first lesson; no prerequisites).

## Promises / leaves open

- Constructs, and where probes come from → `constructs`, `instrument-building`.
- The data we'll analyse are the responses to probes → `irw-data`.
- Whether a scale is interval changes group comparisons → `score-meaning`, `equating`, `scale-properties` (digest E11).
- Levels of measurement; the rescaling demonstration; the Lexile as a model-based unit → `scale-properties` (conjoint measurement, what the Rasch model licenses), `rasch` (specific objectivity; the scale has no origin).
- When a mean difference survives every rescaling (the Go deeper callout) → `scale-properties`, `dif` (comparing groups on θ).
- Is the attribute quantitative? (Michell) → `scale-properties`; is it really there? (realism) → `validity-causal`.
- Insensitive to nonfocal attributes → `dif`, `validity-argument`.
- Calibrated to the task; precise quickly → `information`, `item-banks-cat`.
- Insensitivity to nonfocal attributes, tested for a whole scale → `fairness`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_12` | main example | A cluster-randomized vocabulary intervention in grade 2 (Kim et al., 2021, *Educational Psychology Review* 33(4), 1935–1964, doi:10.1007/s10648-021-09609-6; data doi:10.7910/DVN/HQEMN6; CC BY-NC-SA 4.0). 24 dichotomous vocabulary items; 2,303 complete respondents (1,214 control, 1,089 treated). On the standardized sum score the effect is 0.68 SD. Under the rescalings $\pm e^{kz}$ of the standardized sum ($k$ from −4 to 4) it runs from 0.16 to 0.70: treated respondents pile up near the top of the scale, so a transformation that compresses the top shrinks the effect. It never changes sign: at every score, the treated group's share at or above it is at least the control group's (differences 0.00 to 0.30). That is stochastic dominance. | — |
| `gilbert_meta_15` | contrast (for problem 2 and the Go deeper) | Raven's matrices from the Liberia schools RCT (Romero, Sandefur & Sandholtz, 2020, *American Economic Review* 110(2), 364–400, doi:10.1257/aer.20181478; data doi:10.7910/DVN/5OPIYU; CC0). 10 items, 3,381 complete respondents. A small effect (0.05 SD) whose distributions cross: the share scoring 9 or more is 0.005 lower among the treated, so a rescaling that stretches the top far enough flips the sign. The crossing is well within sampling noise, and the prose says so. | — |

How the numbers were computed (09-24, tokenless CSVs, IRW v414): drop missing responses; keep respondents who answered every item; sum; standardize; apply each rescaling; restandardize; take the treated-minus-control mean. The effects ignore clustering, which doesn't matter for the point about scales; the lesson says so. The R is in the PR description (#62 tidy); the drafting session turns it into `lessons/code/measurement-irw.R`. Before drafting, read both tables' processing notes (IRW MCP server). Adding the tables to `lessons.yml` is proposed in the PR.

Sanity: none (no model is fitted).

## Widget / simulation / problem ideas

**Widgets**
- Hardness: order minerals by scratching (Mohs), then show absolute hardness; which statements are licensed at each level? (idea 3)
- Thermoscope: mark a tube; a second liquid disagrees between the marks (idea 2).
- Rescale the scores: a curvature slider applied to two groups' score distributions; watch the standardized gap change and, for crossing distributions, reverse (idea 4).

**Predict-then-check:** if we compress the top of the vocabulary score scale, does the treatment effect grow, shrink or stay the same? Answered by the effect under each rescaling (it shrinks, to as little as 0.16, and never changes sign).

**Simulate:** two groups on a latent scale; report scores through several order-preserving transformations; compare the gap across them. The sign of a gap is safe only when one distribution dominates the other.

**Problems**
1. Derivation: construct two groups and an order-preserving transformation that reverses the sign of their mean difference.
2. Real data with a twist: in `gilbert_meta_12`, find a rescaling that halves the treatment effect. Then try to reverse the sign of the `gilbert_meta_15` effect, and say why one is possible and the other isn't.
3. Judgment (PS1#4): the Lexile unit vs. anchoring to a later outcome; pros and cons.
4. Design: what evidence would make the "uniform distribution of hardness" claim acceptable?
5. Judgment: a measure you use: what level of measurement does it reach, and which desiderata does it meet?
6. Challenge (open): temperature took centuries. What would a thermometer for reading comprehension require?

## Go deeper

- **When a mean difference survives every rescaling.** The sign of a mean difference is preserved by every order-preserving transformation if and only if one distribution stochastically dominates the other. Ho (2009, *Journal of Educational and Behavioral Statistics* 34(2), 201–228, doi:10.3102/1076998609332755) builds scale-free gap measures on the same idea. Why: `scale-properties`, `score-meaning`, `dif`. Length: half a page.

## Open questions

- None. Item text (#63, A5) doesn't arise: idea 1 uses generic probes, and the vocabulary items aren't shown.

## Drafting notes (#27, 09-24)

- **Numbers recomputed** (IRW v59_0 CSVs). `gilbert_meta_12`: 0.68 SD; 0.16 to 0.71 across $k \in [-4, 4]$. Dominance is *not* exact: one respondent in each group scored 0, so the treated share scoring 1 or more is 0.0001 below the control share. A rescaling that weights the 0→1 step about 38,000 times the others reverses the sign. The lesson reports this and reads it as sampling noise. `gilbert_meta_15`: 0.05 SD; crossing at 9+ (−0.005, SE 0.007). The smooth $e^{kz}$ family does not reverse it (0.012 to 0.052); a step rescaling ($+M$ at 9 or more, $M = 20$) does. The outline's "flips under a rescaling that stretches the top" is kept in that form.
- **Data notes:** both tables come from the Gilbert et al. (2025, doi:10.1002/pam.70025) collection (`data/gilbertmeta.R`, `data/gilbert_hte/postprocessing.R` in ben-domingue/irw). They have one outcome occasion (no `wave`), `std_baseline` is the pretest, and items are scored 1 = correct. In `gilbert_meta_12`, 305 respondents took only one 12-item subtest (207 treated); complete cases are kept. In `gilbert_meta_15`, 129 respondents have no `treat`.
- **Kim et al. (2021)** sampled grades 1 and 2 in 30 schools; the IRW table is grade 2 (IRW description; 30 clusters).
- **Hardness widget:** absolute hardness values dropped (Broz et al. 2006 is closed access, so the values couldn't be checked). The widget instead relabels a box of minerals that is uniform on the Mohs scale. Broz et al. are cited only for their abstract's finding.
- **Anchoring:** Cunha & Heckman not used (not checked against PS1#4's source); only Bond & Lang (2018).
- **Go deeper:** the discrete proof (a sum of steps), with Shaked & Shanthikumar (2007, ch. 1, doi:10.1007/978-0-387-34675-5_1) for the continuous case, and Ho (2009).
