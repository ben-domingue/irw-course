<!-- Outlined 2026-09-24. Not in EDUC 252; added after the landscape analysis (notes/landscape-2026-09-24.md, gap 5: convergent/discriminant, MTMM, criterion validity, range restriction and classification accuracy are in 5–6 of 11 syllabi). Tidied 09-24 (#62): Ben's answers E1, E3, E6, F6, F7 applied; trimmed from five core ideas to four. -->

# Gathering validity evidence (`validity-evidence`)

Module: validity · Prereqs: validity-argument, ctt-reliability, instrument-building · Core · Status: outline

## Core ideas

1. **Evidence is matched to an inference.** The Standards' five sources back particular links in the argument (Recall `validity-argument`). The lesson computes relations to other variables; content and internal structure get a paragraph each. Content evidence starts at item writing and review (Recall `instrument-building`, a prerequisite since E1). Internal structure: the construct map's item order (Recall `constructs`), then a pointer forward to `fa-exploratory` and `fa-confirmatory` (E3). Sources: AERA, APA & NCME (2014), *Standards*, ch. 1 (open access, https://www.testingstandards.net/open-access-files.html; no DOI); Sireci & Faulkner-Bond (2014), doi:10.7334/psicothema2013.256 (content); Rios & Wells (2014), doi:10.7334/psicothema2013.260 (internal structure).
2. **Convergent and discriminant evidence: the multitrait–multimethod matrix.** The same trait by different methods should agree (the validity diagonal), and agree more than different traits by the same method, so the agreement isn't shared method. Campbell and Fiske's comparisons, read off a real matrix. *(major)* Source: Campbell & Fiske (1959), doi:10.1037/h0046016.
3. **Criterion evidence, and what bounds it.** Predictive vs. concurrent designs; what a coefficient of 0.4 means. Reliability caps it, $r_{XY} \le \sqrt{\rho_{XX'}\rho_{YY'}}$ (Recall `ctt-reliability`, problem 2), and one paragraph on the reliability paradox pays that lesson's hook. Incremental validity in a sentence. Selected samples understate the applicant-pool correlation; the Thorndike case II correction depends on its assumptions, shown within the sample only (F7). One sentence names predictive bias (Cleary, 1968). *(major)* Sources: Spearman (1904), doi:10.2307/1412159; Hedge, Powell & Sumner (2018), doi:10.3758/s13428-017-0935-1; Sechrest (1963), doi:10.1177/001316446302300113; Thorndike (1949), *Personnel selection*, Wiley (book verified on Open Library; no DOI); Sackett & Yang (2000), doi:10.1037/0021-9010.85.1.112; Cleary (1968), doi:10.1111/j.1745-3984.1968.tb00613.x.
4. **Classification accuracy.** Sensitivity, specificity, the ROC curve and its area; base rates dominate what a positive result means; the criterion must be independent of the test (Recall the ADHD indicator in `validity-argument`). Taught with the ROC widget, the simulation and that Recall; no fourth table (F6: the IRW has no screener with an independent diagnosis, searched 09-24). *(major)* Sources: Meehl & Rosen (1955), doi:10.1037/h0048070; Swets (1988), doi:10.1126/science.3287615.

For *Going further* (verified): Lane (2014), doi:10.7334/psicothema2013.258 (consequences); Hunsley & Meyer (2003), doi:10.1037/1040-3590.15.4.446 (incremental validity); Hunter, Schmidt & Le (2006), doi:10.1037/0021-9010.91.3.594 (indirect restriction); Hanley & McNeil (1982), doi:10.1148/radiology.143.1.7063747 (the AUC); Youden (1950), doi:10.1002/1097-0142(1950)3:1<32::AID-CNCR2820030106>3.0.CO;2-3. Crossref-checked 09-24 unless marked.

## Picks up

- The interpretation/use argument and the five sources of evidence (from `validity-argument`).
- The ADHD indicator that was the decision rule itself (from `validity-argument`).
- Alpha, the attenuation bound (problem 2), the reliability paradox, and keying before scoring (from `ctt-reliability`).
- The construct map orders the items before data, as internal-structure evidence (from `constructs`; recalled, not refitted).
- Content evidence: blueprints (from `constructs`), item writing and review (from `instrument-building`).

## Promises / leaves open

- Predictive bias (the Cleary model), named here → `dif` (an "if you've done it" Recall there; not a descendant, E2).
- Internal structure in depth (factor models, bifactor, "one construct or three?"): points forward to `fa-exploratory` and `fa-confirmatory`, which answer it themselves (E3; no hook).
- Invariance of structure across groups: multigroup CFA is in `fa-confirmatory` (E1; a pointer, no hook).
- Cut scores as decisions: a pointer to `score-meaning` (not a descendant; boundary agreed 09-24).
- Consequences as evidence → unpaid.
- Multitrait–multimethod as a CFA (trait and method factors) → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `de_vries_2022_hexaco_self` | main example (method 1: self) | HEXACO-PI-R, 96 items, 6 traits, 434 Dutch working adults (de Vries et al., 2022, doi:10.1371/journal.pone.0272095; instrument: Lee & Ashton, 2004, doi:10.1207/s15327906mbr3902_8). Arrives unkeyed; keyed, trait alphas are 0.80–0.84. | — |
| `de_vries_2022_hexaco_other` | main example (method 2: colleagues) | Up to three colleagues per target. With colleague 1 (393 targets), the validity diagonal runs 0.26 (Honesty-Humility) to 0.52 (Openness), against mean \|r\| 0.06 (different traits, different methods) and 0.13 (different traits, same method). The same-method comparison fails for Honesty-Humility: colleagues' Honesty-Humility and Agreeableness ratings correlate at \|r\| = 0.37. | — |
| `ieswriting_molloy_2022` | criterion evidence, incremental validity, range restriction | ETS writing study (IRW biblio cites the ETS repository): a writing-attitudes survey adapted from MacArthur, Philippakos & Graham (2016), doi:10.1177/0731948715583115, with course grade, GPA and SAT; 526 complete first-year students. The self-efficacy scale (alpha 0.95) correlates 0.08 with course grade; SAT 0.43. Adding it to SAT leaves R² at 0.19 (p = 0.42). Above-median SAT only: r falls to 0.25; case II gives 0.34. | — |

The findings: (1) self and colleagues agree well above the heterotrait–heteromethod baseline, but colleagues' Honesty-Humility ratings overlap more with their own Agreeableness ratings than with the self-report, the method effect Campbell and Fiske's comparison catches; (2) alpha 0.95 and almost no prediction of grades: the scale was built to measure motivation, so this is a finding about a use, not a flaw; (3) the correction rests on assumptions and doesn't simply recover the full-sample value.

Data notes: rescore HEXACO with the published key (hexaco.org) and recheck the numbers before drafting; they use a first-principal-component key (digest D). `ieswriting_molloy_2022` follows the stricter source licence, CC BY-NC-SA 4.0 (E6; https://github.com/EducationalTestingService/ies-writing-achievement-study-data), not the IRW page's CC BY 4.0: quote a few items with citation, never the whole survey. Claude flags the mismatch to the IRW (digest D).

Sanity: no model fit; the keying check (every item positive on its trait) and colleague-1 vs. colleague-2 agreement (0.30–0.58, 357 targets) check the pipeline.

## Widget / simulation / problem ideas

**Widgets**
- Build an MTMM matrix: set trait correlations, method variance and reliability; the matrix fills in with Campbell and Fiske's comparisons marked pass/fail (idea 2).
- Range restriction: drag a selection cutoff on the predictor and watch r fall; toggle the case II correction (idea 3).
- ROC and base rates: move the cutoff and the prevalence; see sensitivity, specificity, the ROC, the AUC and the positive predictive value (idea 4).

**Predict-then-check:** the self-efficacy scale has alpha 0.95. How strongly will it correlate with course grades, compared with SAT? Answered by the correlations (0.08 vs. 0.43) and the incremental R² (none).

**Simulate:** a predictor and criterion with known ρ; select on the predictor (direct) and on a third variable (indirect); compare observed, corrected and true correlations. A second short block draws a screener and an independent criterion and reports sensitivity, specificity and PPV at 3% and 30% prevalence (idea 4). Seconds in base R.

**Problems**
1. Derivation: for two normal score distributions with equal SD, the cutoff that maximizes Youden's J, and how it moves with prevalence if you weight errors by base rate.
2. Real data with a twist: average all available colleagues, then correct the self–other correlations for attenuation (Recall the bound). Which trait gains most? Does Honesty-Humility now pass?
3. Real data: repeat the range-restriction demonstration for GPA. Why might the correction overshoot?
4. Judgment: the self-efficacy scale doesn't predict grades. Is that evidence against its validity? For which use?
5. Design: a new 10-item screener, a condition with 3% prevalence, and an independent diagnostic interview on 200 people. Plan the classification study.
6. Challenge (open): a task has retest reliability 0.3 (the reliability paradox). What is the largest criterion correlation it can have, and what would convince you it measures anything?

## Go deeper

- **Correction for range restriction (case II).** From a linear, homoscedastic regression of Y on X, so selection on X leaves slope and residual variance unchanged. Why: `score-meaning` (norm samples), `dif` (predictive bias compares regressions). Length: half a page.

## Open questions

- **First-person verdict.** *Default:* "When I correct a validity coefficient, for attenuation or for range restriction, I report the observed value first and the corrected one beside it, with the assumption it rests on; never the corrected value alone." For Ben to confirm or reword.
