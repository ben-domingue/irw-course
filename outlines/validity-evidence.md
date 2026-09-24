<!-- Outlined 2026-09-24. Not in EDUC 252; added after the landscape analysis (notes/landscape-2026-09-24.md, gap 5: convergent/discriminant, MTMM, criterion validity, range restriction and classification accuracy are in 5–6 of 11 syllabi; the draft's validity lessons were theory only). -->

# Gathering validity evidence (`validity-evidence`)

Module: validity · Prereqs: validity-argument, ctt-reliability · Core · Status: outline

## Core ideas

1. **Evidence is matched to an inference.** The Standards' five sources (test content, response processes, internal structure, relations to other variables, consequences) as the evidence that backs particular links in an interpretation/use argument. This lesson works through the ones a first course can compute: relations to other variables above all, with short notes on content and internal structure. Sources: AERA, APA & NCME (2014), *Standards*, ch. 1 (open access, https://www.testingstandards.net/open-access-files.html; book, no DOI); the *Psicothema* 2014 series, one paper per source: Sireci & Faulkner-Bond, doi:10.7334/psicothema2013.256 (content); Padilla & Benítez, doi:10.7334/psicothema2013.259 (response processes); Rios & Wells, doi:10.7334/psicothema2013.260 (internal structure); Lane, doi:10.7334/psicothema2013.258 (consequences). Content-validity ratio: Lawshe (1975), doi:10.1111/j.1744-6570.1975.tb01393.x.
2. **Convergent and discriminant evidence: the multitrait–multimethod matrix.** Measures of the same trait by different methods should agree (the validity diagonal), and should agree more than different traits measured by the same method (so the agreement isn't shared method). Campbell and Fiske's four comparisons, read off a real matrix. *(major)* Sources: Campbell & Fiske (1959), doi:10.1037/h0046016; Cronbach & Meehl (1955), doi:10.1037/h0040957 (the nomological network the matrix samples); discriminant validity between correlated factors, Rönkkö & Cho (2022), doi:10.1177/1094428120968614.
3. **Reliability bounds validity: attenuation.** $r_{XY} \le \sqrt{\rho_{XX'}\rho_{YY'}}$; the correction for attenuation, and why a corrected correlation answers a different question from the observed one. The reliability paradox: robust experimental tasks can give unreliable individual differences, so their correlations with anything stay low. Sources: Spearman (1904), doi:10.2307/1412159; Lord & Novick (1968), *Statistical theories of mental test scores* (book, no DOI), ch. 3; Hedge, Powell & Sumner (2018), doi:10.3758/s13428-017-0935-1. Recall `ctt-reliability` (problem 2 there derives the bound).
4. **Criterion evidence, incremental validity and range restriction.** Predictive vs. concurrent designs; what a validity coefficient of 0.4 means; incremental validity (what a new measure adds to what you already have); and why selected samples (admitted students, hired workers) understate the correlation you'd see in the applicant pool, with the Thorndike case II correction and its assumptions. *(major)* Sources: Sechrest (1963), doi:10.1177/001316446302300113; Hunsley & Meyer (2003), doi:10.1037/1040-3590.15.4.446; Pearson (1903), doi:10.1098/rsta.1903.0001 (the selection formulas); Thorndike (1949), *Personnel selection* (book, no DOI; **unverified**); Sackett & Yang (2000), doi:10.1037/0021-9010.85.1.112; Hunter, Schmidt & Le (2006), doi:10.1037/0021-9010.91.3.594; Taylor & Russell (1939), doi:10.1037/h0057079.
5. **Classification accuracy.** Sensitivity, specificity, the ROC curve and its area; why base rates dominate what a positive result means; and why the criterion must be independent of the test (Recall the ADHD indicator in `validity-argument`). *(major)* Sources: Meehl & Rosen (1955), doi:10.1037/h0048070; Swets (1988), doi:10.1126/science.3287615; Hanley & McNeil (1982), doi:10.1148/radiology.143.1.7063747; Youden (1950), doi:10.1002/1097-0142(1950)3:1<32::AID-CNCR2820030106>3.0.CO;2-3 (Youden's J).

Crossref-checked 09-24 unless marked.

## Picks up

- The interpretation/use argument and the five sources of evidence (from `validity-argument`).
- The ADHD indicator that was the decision rule itself, so its AUC backed no extrapolation (from `validity-argument`).
- Alpha, parallel forms, and the attenuation bound (from `ctt-reliability`, problem 2).
- Reliability is a property of scores in a population; the reliability paradox (from `ctt-reliability`).
- The construct map orders the items before data: evidence from internal structure and response processes (from `constructs`; the number-series result is recalled, not refitted).
- Content evidence starts at the blueprint (from `constructs`).
- Content evidence for validity: item writing and review (from `instrument-building`, not an ancestor: see Open questions).
- Bifactor models and "is it one construct or three?" (from `fa-confirmatory`, not an ancestor: see Open questions).
- Keying: reverse-worded items must be keyed before scale scores (from `ctt-reliability`, the Mach IV).

## Promises / leaves open

- Group differences in a criterion relationship (predictive bias, the Cleary model) → `dif`.
- Measurement invariance and structure across groups → `dif`.
- Internal structure in depth (factor models, bifactor, "is it one construct or three?") → `fa-exploratory`, `fa-confirmatory` (see Open questions on order).
- Cut scores and decision accuracy for a score scale → `score-meaning`.
- Consequences as evidence → unpaid.
- Multitrait–multimethod as a CFA (trait and method factors) → unpaid (it would suit a problem in the optional SEM lesson).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `de_vries_2022_hexaco_self` | main example (method 1: self) | HEXACO-PI-R, 96 items (4 per facet, 24 facets, 6 traits), 434 Dutch working adults rating themselves (de Vries et al., 2022, doi:10.1371/journal.pone.0272095; instrument: Lee & Ashton, 2004, doi:10.1207/s15327906mbr3902_8). Arrives unkeyed (about half of each trait's loadings are negative); once keyed, trait alphas are 0.80–0.84. | — |
| `de_vries_2022_hexaco_other` | main example (method 2: colleagues) | The same 96 items rated by up to three colleagues per target (398 targets: 393 rated by a first colleague, 361 by a second, 189 by a third; 186 targets have all three). With colleague 1, the 6 × 2 MTMM matrix (393 targets) has validity-diagonal correlations of 0.26 (Honesty-Humility) to 0.52 (Openness), against a mean \|r\| of 0.06 for different traits by different methods and 0.13 for different traits by the same method. Every validity value beats the heterotrait–heteromethod values in its row and column (largest 0.16), and the pattern of trait intercorrelations is similar across methods (r = 0.85 between the two methods' heterotrait correlations). The comparison with the heterotrait–monomethod values fails for Honesty-Humility: self and colleague agree on it at 0.26, but colleagues' Honesty-Humility and Agreeableness ratings correlate at \|r\| = 0.37. Agreeableness only just passes (0.38 vs. 0.37). Averaging colleagues raises the self–other correlations to 0.37–0.59; corrected for attenuation (self alphas 0.80–0.84, colleague-1 alphas 0.82–0.88), the colleague-1 values are 0.31 (Honesty-Humility) to 0.62 (Openness). | — |
| `ieswriting_molloy_2022` | criterion evidence, incremental validity and range restriction | ETS writing study (Burstein et al.; IRW biblio cites the ETS data repository): a 50-item writing-attitudes survey adapted from MacArthur, Philippakos & Graham (2016), doi:10.1177/0731948715583115, with course grade, cumulative GPA and SAT total (ACT concorded to SAT) for 565 first-year students at 4-year universities; 526 complete. The 22-item writing self-efficacy scale is highly reliable (alpha 0.95) but correlates only 0.08 with the course grade and 0.07 with GPA; SAT correlates 0.43 and 0.39. Adding self-efficacy to SAT leaves R² for course grade at 0.19 (F test p = 0.42). Range restriction, in this sample: keeping only students above the median SAT drops r(SAT, course grade) from 0.43 to 0.25; Thorndike case II brings it back to 0.34. For GPA it falls from 0.39 to 0.36 and the correction overshoots to 0.46. | — |

The findings the section is built around: (1) self and colleagues agree on HEXACO traits well above the heterotrait–heteromethod baseline, but for Honesty-Humility the colleagues' ratings overlap more with their own Agreeableness ratings than with the target's self-report, a method effect Campbell and Fiske's third comparison is built to catch; (2) a scale with alpha 0.95 predicts grades hardly at all, so reliability is not criterion validity, and the self-efficacy scale was built to measure motivation, not to predict grades (the finding is about a use, not a flaw in the scale); (3) the range-restriction correction depends on its assumptions and doesn't simply recover the full-sample value.

Notes on the data, stated gently in the lesson:
- HEXACO keying: the lesson keys with the published HEXACO-PI-R scoring key (hexaco.org) and checks that every item then correlates positively with its trait. The first-principal-component key used for these numbers makes the trait *polarity* arbitrary, which doesn't change the validity diagonal (both methods keyed alike) but does change the signs of heterotrait correlations. Numbers to be rechecked with the published key.
- HEXACO item text isn't in the IRW; the lesson needs only the trait/facet codes in the item ids (`PAflex1` = Agreeableness, flexibility).
- `ieswriting_molloy_2022`: survey item text is in the ETS repository's column documentation (https://github.com/EducationalTestingService/ies-writing-achievement-study-data); the source data are CC BY-NC-SA 4.0, the IRW page says CC BY 4.0 (flag for #63; the lesson quotes a few items with citation).
- The survey's four parts use different response scales (Part 2 is 0–10 confidence; the others 1–5).

A third table for classification accuracy would exceed the ceiling; see Open questions. The lesson teaches classification with a widget, the simulation, and a Recall of the Silk ADHD table.

Sanity table: none needed for a model fit (the section is correlations and regressions). The keying check (every item positive on its trait, alphas 0.80–0.88) and the colleague-1 vs. colleague-2 agreement (0.30–0.58, 357 targets) are the pipeline checks.

## Widget / simulation / problem ideas

**Widgets**
- Build an MTMM matrix: set trait correlations, method variance and reliability; the 6 × 6 matrix fills in with the four Campbell–Fiske comparisons marked pass/fail (idea 2).
- Attenuation: two true scores correlated at ρ; slide the two reliabilities and watch the observed correlation and the corrected one (idea 3).
- Range restriction: a scatterplot of predictor vs. criterion; drag a selection cutoff on the predictor and watch r fall; toggle the Thorndike correction (idea 4).
- ROC and base rates: two score distributions (with and without the condition); move the cutoff and the prevalence; see sensitivity, specificity, ROC, AUC and the positive predictive value (idea 5).

**Predict-then-check:** the writing self-efficacy scale has alpha 0.95. How strongly will it correlate with students' course grades, compared with SAT? Answered by the correlations (0.08 vs. 0.43) and the incremental R² (none).

**Simulate:** generate a predictor and criterion with known ρ; select on the predictor (direct restriction) and on a third variable (indirect restriction); compare observed, corrected and true correlations. Shows when case II recovers ρ and when it doesn't (seconds in base R).

**Problems**
1. Derivation: the attenuation bound $r_{XY} \le \sqrt{\rho_{XX'}\rho_{YY'}}$ from $X = T_X + E_X$ (Recall `ctt-reliability` problem 2), and the corrected correlation.
2. Derivation: Thorndike case II from the assumptions of linearity and homoscedasticity in the unrestricted population.
3. Real data with a twist: average all available colleagues instead of colleague 1, then correct the self–other correlations for attenuation using each method's alpha. Which trait gains most? Does Honesty-Humility now pass Campbell and Fiske's third comparison?
4. Judgment: the writing self-efficacy scale doesn't predict grades. Is that evidence against its validity? For which use? Write the inference that this correlation does and doesn't bear on.
5. Design: you have a new 10-item screener for a condition with 3% prevalence and an independent diagnostic interview on 200 people. Plan the classification study: sample, reference standard, what you'd report.
6. Challenge (open): the reliability paradox (Hedge et al., 2018) says robust experimental tasks make poor individual-difference measures. If a task's retest reliability is 0.3, what is the largest criterion correlation it can have, and what would convince you it is a valid measure of anything?

## Go deeper

- **Correction for range restriction (case II).** The derivation from the assumption that the regression of Y on X is linear and homoscedastic in the full population, so selection on X leaves the slope and residual variance unchanged. Why: `validity-evidence`, `score-meaning` (norm samples), `dif` (predictive bias compares regressions across groups). Length: half a page.

## Open questions

- **Classification accuracy as a fourth table.** The ceiling is 3 and the MTMM needs two tables (self and colleague). Options: (a) classification taught through the widget, the simulation and a Recall of the Silk ADHD table, as proposed; (b) count the de Vries self/other pair as one worked example; (c) drop MTMM to one method and add a screener with an independent reference standard. I searched the IRW for (c) (09-24): the diagnosis-bearing tables I found either define the diagnosis from the same items (Silk ADHD) or code cut-offs rather than items (`Karim2022_tmoca_mci`). Which do you prefer?
- **Order and prerequisites.** `fa-confirmatory` hands "bifactor models and one construct or three?" to this lesson, and `instrument-building` hands it content evidence, but neither is an ancestor here, and in the first-course path this lesson comes before both FA lessons. Proposed: content evidence gets a short Core idea 1 paragraph that works without `instrument-building`; the bifactor hook is re-pointed to `dimensionality` or answered by `fa-confirmatory` itself. Or should `validity-evidence` move after the FA module?
- **SAT national SD.** The whole sample is already range-restricted (admitted students; SAT SD 134 here). Correcting to the national SAT SD would need the College Board's annual report figure. Worth adding with that citation, or keep the within-sample demonstration only?
- **Licence note.** The ETS data are CC BY-NC-SA 4.0 at source; the IRW page lists CC BY 4.0. For #63.
