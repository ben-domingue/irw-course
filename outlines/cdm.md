<!-- Outlined 2026-09-24 from PS7#2 (parts B–D) and the code c7/3_cdm.R and ps7/cdm.R. c7.pptx is missing from the export, so the lesson is built from c7/3_cdm.R and PS7#2 (digest F26; Ben may send the deck if it has slide material worth keeping). Tidied 09-24 (#62). -->

# Cognitive diagnostic models (`cdm`)

Module: beyond · Prereqs: explanatory-irt · Extension · Status: outline

## Core ideas

1. **A different kind of latent variable.** Each respondent has a profile of binary attributes; $K$ attributes give $2^K$ classes, so a CDM is a restricted latent class model. *(major)* Sources: Rupp, Templin & Henson (2010), *Diagnostic measurement* (Guilford; ISBN 9781606235270, Open Library); Haertel (1989), doi:10.1111/j.1745-3984.1989.tb00336.x.
2. **The Q-matrix says which attributes each item needs.** It is the LLTM's design matrix again, now linking items to classes rather than to a difficulty. Tatsuoka's fraction subtraction is the classic case. *(major)* Sources: Tatsuoka (1983), doi:10.1111/j.1745-3984.1983.tb00212.x; Tatsuoka (2002), doi:10.1111/1467-9876.00272 (the IRW citation for `frac20`).
3. **DINA: all or nothing.** With every required attribute, P(correct) = $1 - s$ (slip); missing any, $g$ (guess). DINO is "any one will do"; G-DINA and the LCDM free each combination. *(major)* Sources: Junker & Sijtsma (2001), doi:10.1177/01466210122032064; de la Torre (2011), doi:10.1007/s11336-011-9207-7; Henson, Templin & Willse (2009), doi:10.1007/s11336-008-9089-5.
4. **The latent structure costs parameters.** Eight attributes give 255 class proportions. A higher-order model (attributes driven by one θ) or a hierarchy cuts that to a handful, and brings CDMs back towards IRT. Sources: de la Torre & Douglas (2004), doi:10.1007/bf02295640; Templin & Bradshaw (2014), doi:10.1007/s11336-013-9362-0.
5. **Is the Q-matrix right, and is a CDM better than IRT?** Q-matrix validation (PVAF), shown briefly with the caution that it suggests too many changes under DINA (digest F28); AIC, BIC and held-out prediction against the 2PL. The lesson's verdict is on hold (see Open questions). Sources: de la Torre & Chiu (2016), doi:10.1007/s11336-015-9467-8; `GDINA`: Ma & de la Torre (2020), doi:10.18637/jss.v093.i14.

References checked on Crossref (09-24) unless marked.

## Picks up

- The LLTM and a design matrix of item properties (from `explanatory-irt`); PS7#2 part B fits `resp ~ 0 + (1 | id) + Q`.
- Latent classes as an alternative to a continuum (from `constructs`).
- Sum scores and their sufficiency (from `rasch`), for attribute counts vs. θ.
- Brief Recalls (E2; restated, not threads): the slip and guessing asymptotes of `1pl-to-4pl` (DINA's $1 - s$ and $g$ are asymptotes with no curve between them); AIC, BIC and the IMV from `fit-prediction`; the balance-scale rule classes of `validity-causal`.

## Promises / leaves open

- Longitudinal CDMs (`hmcdm_spatialreasoning`) → unpaid.
- Mixture and latent-class IRT beyond CDMs → unpaid.
- Classification accuracy of attribute profiles → unpaid (Templin & Bradshaw, 2013, doi:10.1007/s00357-013-9129-4).
- Attribute profiles for feedback or placement: not a hook (`score-meaning` doesn't follow this lesson).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `frac20` | main example | 536 × 20, 8 attributes. DINA slip ≤ 0.25 on 19 items; guessing near 0 except item 8 (0.44). 201 students (37.5%) master all eight; attribute count correlates 0.89 with Rasch θ. AIC: DINA 9,395 (295 parameters), G-DINA 9,422, Rasch 9,635, 2PL 9,360; higher-order DINA 9,115 (BIC 9,321 vs. 2PL 9,532). A scrambled Q raises AIC to 9,769. PVAF suggests changes to 9 of 20 items. | — |
| `cdm_ecpe` | contrast | 2,922 × 28, 3 attributes. G-DINA puts 0.95 of respondents in four of eight profiles (000, 001, 011, 111): a linear hierarchy. The 2PL wins (AIC 85,205 vs. DINA 85,809, G-DINA 85,639). An ordinal scale in disguise. | — |
| `frac20` vs. `c7/frac20.rds` | sanity | Same data and Q; DINA log-likelihood −4,402.3 from both. | — |

`cdm_timss07` (15 attributes) didn't finish in 10 minutes saturated; problems only, with `cdm_timss03`, `cdm_pisa00R`, `cdm_mentalhealth_tan_2023_bsi`.

## Widget / simulation / problem ideas

**Widgets**
- Q-matrix explorer: click a profile, see which items DINA says it gets right (ideas 2, 3).
- DINA vs. 2PL item: two plateaus against the Rasch curve (idea 3).
- Class count: $2^K - 1$ against sample size, and the higher-order count (idea 4).

**Predict-then-check:** ECPE's three attributes allow eight profiles. How many hold most respondents? (Four, 95%.)

**Simulate:** DINA data from a 10-item, 3-attribute Q; fit DINA, G-DINA, 2PL; compare parameters and classification. Then misspecify one Q entry and see which $g$ or $s$ absorbs it. `GDINA` in webR is Claude's check.

**Problems**
1. Derivation: the DINA likelihood for one respondent; with one attribute per item it is a two-class model.
2. Real data with a twist (PS7#2 B): fit `resp ~ 0 + (1 | id) + Q` to frac20. Do items with the same Q row have similar difficulties?
3. Real data (PS7#2 D): Rasch, 2PL, DINA, higher-order DINA on held-out responses. Does the ranking agree with AIC? Also the full PVAF analysis.
4. Judgment: a district wants skill reports from a state test not designed with a Q-matrix. Advise.
5. Design: a Q-matrix for eight items with at least one single-attribute item per attribute. Why does that matter?
6. Challenge (open): when attributes are hierarchical, is a CDM a new model or a unidimensional one with cut points?

## Go deeper

- **The higher-order DINA is close to unidimensional IRT.** Attributes as thresholds on one θ; why it tracks Rasch θ (r = 0.89). Half a page.

## Open questions

- **Verdict (F27, on hold with Ben).** Candidate: "a CDM earns its keep only when the Q-matrix was designed into the test, not retrofitted to it" (Claude's reading of PS7#2 and ECPE). *Default while on hold:* the draft carries the candidate in a hidden TODO, not on the page, and the lesson's first-person verdict waits for Ben.
