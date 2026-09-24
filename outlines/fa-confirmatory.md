<!-- Outlined 2026-09-24. Not in EDUC 252; added after the landscape analysis (CFA in 6 of 11 syllabi; omega and ordinal CFA as the bridge to IRT). Multigroup CFA invariance moved here from dif on 09-24 (Ben, E1). -->

# Factor analysis II: confirmatory models, omega, and IRT as factor analysis (`fa-confirmatory`)

Module: fa · Prereqs: fa-exploratory, 1pl-to-4pl · Core · Status: outline

## Core ideas

1. **Confirmatory factor analysis.** State the structure first (which items load on which factors, the rest fixed at zero); identification by fixing a loading or the factor variance; fit with `lavaan`. *(major)* Sources: Jöreskog (1969), doi:10.1007/bf02289343; Rosseel (2012), doi:10.18637/jss.v048.i02.
2. **Fit indices, and what they can't tell you.** χ², CFI, TLI, RMSEA, SRMR; the Hu–Bentler cutoffs as conventions, not laws; comparing nested models. *(major)* Sources: Hu & Bentler (1999), doi:10.1080/10705519909540118; Zhang, Rahal, Kanopka, Ulitzsch, Zhang & Domingue (2026), *Multivariate Behavioral Research*, doi:10.1080/00273171.2026.2645212 (predictive performance of CFA with binary outcomes via the IMV).
3. **Omega.** Model-based reliability; equals alpha under tau-equivalence; omega hierarchical for a general factor in a bifactor model, which answers "one construct or three?" for the DASS here (E3: not handed on to `validity-evidence`). Sources: McDonald (1999), *Test theory: A unified treatment*, doi:10.4324/9781410601087; Revelle & Zinbarg (2009), doi:10.1007/s11336-008-9102-z; Reise (2012), doi:10.1080/00273171.2012.715555.
4. **IRT as factor analysis.** Ordinal CFA on polychorics is the normal-ogive graded response model: $a = \lambda/\sqrt{1-\lambda^2}$ (times 1.702 for the logistic metric), thresholds ↔ intercepts. One paragraph on when treating Likert items as continuous is safe enough (five or more categories, roughly symmetric: Rhemtulla, Brosseau-Liard & Savalei, 2012, doi:10.1037/a0029315). *(major)* Sources: Takane & de Leeuw (1987), doi:10.1007/bf02294363; Kamata & Bauer (2008), doi:10.1080/10705510701758406; Chalmers (2012), doi:10.18637/jss.v048.i06.
5. **Measurement invariance with multigroup CFA.** Does the same model hold in two groups? Configural (same pattern), metric (equal loadings), scalar (equal intercepts or thresholds): comparing latent means needs scalar invariance; partial invariance frees the offending parameters. ΔCFI conventions and their limits; ordinal indicators need care with identification. Unequal loadings are non-uniform DIF and unequal intercepts uniform DIF, which is how `dif` recalls this section. Sources: Meredith (1993), doi:10.1007/BF02294825; Vandenberg & Lance (2000), doi:10.1177/109442810031002; Millsap (2011), doi:10.4324/9780203821961; Chen (2007), doi:10.1080/10705510701301834; Wu & Estabrook (2016), doi:10.1007/s11336-016-9506-0; Putnick & Bornstein (2016), doi:10.1016/j.dr.2016.06.004.

All references above were checked on Crossref (09-24).

`lavaan` syntax is introduced here, not in `sem` (C9). The lesson follows `1pl-to-4pl` although it sits in the FA module, because idea 4 needs the 2PL (C10). To fit one session, idea 2 stays short and idea 5 is one worked comparison.

## Picks up

- The common factor model, loadings, polychorics, rotation (from `fa-exploratory`).
- Alpha ≤ reliability, tau-equivalence (thread from `ctt-reliability`).
- The 2PL, slopes and intercepts (from `1pl-to-4pl`).
- Wording direction as a second dimension (from `instrument-building`).
- Unidimensionality as a Rasch assumption (from `rasch`).

## Promises / leaves open

- SEM: structural paths between latent variables; multigroup SEM → `sem` (extension).
- Multidimensional IRT = multidimensional ordinal FA → `dimensionality`.
- Graded response model in its own right → `polytomous`.
- Invariance item by item, with a matching variable instead of a factor model → `dif` (which recalls idea 5 as "if you've done `fa-confirmatory`", E2), `invariance-experience`.
- Omega as the reliability of a reported score → `score-meaning` (an "if you've done" Recall there).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `grit` | main example | Grit-O (Duckworth et al., 2007), 12 items, 1–5, 3,103 complete cases. One factor fits poorly (CFI 0.80, RMSEA 0.16); the two designed facets fit better (CFI 0.91, RMSEA 0.11, SRMR 0.07) but not well; the facets correlate 0.62. An EFA puts every item on its intended facet. Ordinal CFA loadings convert to slopes that match `mirt`'s graded model (loading 0.78 → 2.1; `mirt` 2.2). | — |
| `neurodegenerative_huizinga_2019_dass` | contrast; invariance example | DASS-21 (Dutch), 1,246 complete cases. The three designed scales correlate 0.84–0.87, and one factor fits nearly as well (CFI 0.95 vs. 0.97); a bifactor model fits best (0.99). Omega hierarchical 0.86 vs. omega total 0.97: most reliable variance is general distress. **Invariance by `cov_sex`** (577 in group 1, 669 in group 2; which is women to confirm from the paper), three-factor model, MLR with items treated as continuous: configural CFI 0.93, RMSEA 0.062; metric Δχ² 13.5 on 18 df (p = 0.76); scalar Δχ² 24.6 on 18 df (p = 0.14); robust CFI 0.93 at every step. No constraint stands out (largest scaled score test: item 16's intercept, 6.9 on 1 df, among 39). With scalar invariance, group 2 sits about 0.17 SD higher on anxiety and stress and 0.09 on depression. A measure that passes. | — |

Invariance numbers computed 09-24 (`lavaan::cfa`, MLR, `group.equal`, Satorra–Bentler differences; latent means in group 1's factor SDs). The draft should repeat them with ordinal estimation (WLSMV).

Item text: Grit and DASS are on A5's list of instruments to show in full once Claude confirms each licence (Grit: free for non-commercial use). Grit's item text comes from the Florida twins table (used in `sem`), whose numbering matches the published Grit-O.

Grit sources: Duckworth, Peterson, Matthews & Kelly (2007), doi:10.1037/0022-3514.92.6.1087; Credé, Tynan & Harms (2017) meta-analysis on the facets, doi:10.1037/pspp0000102. DASS sources: Lovibond & Lovibond (1995), doi:10.1016/0005-7967(94)00075-u; Henry & Crawford (2005), doi:10.1348/014466505x29657. Table citations come from IRW biblio.

## Widget / simulation / problem ideas

**Widgets**
- Paths to a correlation matrix: draw a two-factor model; the implied matrix and residuals update (ideas 1, 2).
- Fit index sandbox: add misfit (a cross-loading, a correlated error) and watch CFI, RMSEA and SRMR respond, each differently (idea 2).
- Loading ↔ slope: a loading slider with the implied ICC, next to the 2PL curve with $a = 1.702\lambda/\sqrt{1-\lambda^2}$ (idea 4).
- Invariance ladder (from `dif`): a two-group one-factor model with loading and intercept controls for one item; configural, metric and scalar fit light up as constraints fail, and the latent mean difference moves (idea 5).

**Predict-then-check:** the DASS-21 is scored as three scales. How strongly will the three factors correlate? Answered by the CFA (0.84–0.87).

**Simulate:** ordinal data from a two-factor model; fit the CFA with `lavaan` and the graded model with `mirt`; compare converted parameters with the truth.

**Problems**
1. Derivation: show that under a one-factor model with equal loadings, omega equals alpha.
2. Derivation: the probit link between an ordinal CFA loading and a normal-ogive slope.
3. Real data with a twist: fit Grit with a correlated error between two similarly worded items; how much does fit improve, and is that a finding or a patch?
4. Judgment: DASS-21. Report three subscale scores or one? Use omega hierarchical and the factor correlations.
5. Design: you want to compare DASS-21 scores across education levels (`cov_education`). Which level of invariance do you need to compare means, and which to compare the factor correlations? What would you do if one item's intercept failed?
6. Challenge (open): fit indices reward some misfit and punish others. Credé et al. (2017) argue grit is mostly conscientiousness. What model would test that, and what data would you need?

## Go deeper

- **Ordinal factor analysis is the graded response model.** From a latent response $y^* = \lambda\eta + \epsilon$ cut at thresholds to the normal-ogive GRM. Why: `polytomous`, `dimensionality`, `1pl-to-4pl`, `sem`. Length: about a page.
- **Omega and alpha.** Omega as reliability of a model-implied sum score; equality under tau-equivalence. Why: `ctt-reliability` (the alpha thread), `score-meaning`. Length: half a page.

## Open questions

- None. Settled 09-24: `lavaan` first appears here (C9); keep the order after `1pl-to-4pl` (C10); multigroup CFA lives here (E1); the bifactor question is answered here (E3); item text per A5.
