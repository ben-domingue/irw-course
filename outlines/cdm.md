<!-- Outlined 2026-09-24 from PS7#2 (parts B–D: items as carriers of skills, the DINA model, comparing fit) and the code c7/3_cdm.R and ps7/cdm.R. Slides c7 are missing from the EDUC 252 export (source/252 has no c7.pptx), so the slide material is reconstructed from c7/3_cdm.R: DINA on frac20, guessing and slip, attribute profiles against sum scores, model-implied vs. empirical proportions, and a "nonsense Q" comparison. -->

# Cognitive diagnostic models (`cdm`)

Module: beyond · Prereqs: explanatory-irt · Optional · Status: outline

## Core ideas

1. **A different kind of latent variable.** Instead of one continuous θ, each respondent has a profile of binary attributes (mastered or not). With $K$ attributes there are $2^K$ latent classes; a CDM is a restricted latent class model. *(major)* Sources: Rupp, Templin & Henson (2010), *Diagnostic measurement: Theory, methods, and applications* (Guilford; ISBN 9781606235270, checked in the Open Library catalogue, the Guilford page did not resolve); Haertel (1989), doi:10.1111/j.1745-3984.1989.tb00336.x; Macready & Dayton (1977), doi:10.3102/10769986002002099.
2. **The Q-matrix says which attributes each item needs.** It is the item design matrix of the LLTM again, but now it links items to classes rather than to a difficulty. Tatsuoka's fraction subtraction items are the classic case. *(major)* Sources: Tatsuoka (1983), rule space, doi:10.1111/j.1745-3984.1983.tb00212.x; Tatsuoka (1990), in *Diagnostic monitoring of skill and knowledge acquisition*, doi:10.4324/9780203056899-22; Tatsuoka (2002), doi:10.1111/1467-9876.00272 (the IRW citation for `frac20`).
3. **DINA: all or nothing.** A respondent who has every required attribute answers correctly with probability $1 - s$ (slip); anyone missing one answers with probability $g$ (guess). DINO is the "any one will do" counterpart; G-DINA and the LCDM let each combination of attributes have its own effect. *(major)* Sources: Junker & Sijtsma (2001), doi:10.1177/01466210122032064; de la Torre (2009), doi:10.3102/1076998607309474; Templin & Henson (2006), DINO, doi:10.1037/1082-989x.11.3.287; de la Torre (2011), G-DINA, doi:10.1007/s11336-011-9207-7; Henson, Templin & Willse (2009), LCDM, doi:10.1007/s11336-008-9089-5; von Davier (2008), doi:10.1348/000711007x193957.
4. **The latent structure costs parameters.** Eight attributes give 255 free class proportions, more than half the frac20 sample size. A higher-order model (attributes driven by one continuous θ) or an attribute hierarchy cuts that to a handful, and brings CDMs back towards IRT. Sources: de la Torre & Douglas (2004), doi:10.1007/bf02295640; Leighton, Gierl & Hunka (2004), doi:10.1111/j.1745-3984.2004.tb01163.x; Templin & Bradshaw (2014), doi:10.1007/s11336-013-9362-0.
5. **Is the Q-matrix right, and is a CDM better than IRT?** Empirical Q-matrix validation; comparing CDM and IRT fit with AIC, BIC and (PS7#2's bonus) held-out prediction. My view, to be written as the verdict: a CDM earns its keep only when the Q-matrix was designed into the test, not retrofitted to it. Sources: de la Torre & Chiu (2016), doi:10.1007/s11336-015-9467-8; `GDINA`: Ma & de la Torre (2020), doi:10.18637/jss.v093.i14; `CDM`: George, Robitzsch, Kiefer, Gross & Ünlü (2016), doi:10.18637/jss.v074.i02.

References checked on Crossref (09-24) unless marked.

## Picks up

- The LLTM and a design matrix of item properties (from `explanatory-irt`); here the Q-matrix plays that role. PS7#2 part B fits exactly that model (`resp ~ 0 + (1 | id) + Qmatrix__1 + … + Qmatrix__8`).
- The slip parameter (upper asymptote $u$) and the lower asymptote $c$ (from `1pl-to-4pl`, which hands the slip parameter to `cdm`): DINA's $1 - s$ and $g$ are item asymptotes with no curve between them.
- Latent classes as an alternative to a continuum (from `constructs`, which hands latent classes to `cdm`).
- Sum scores and their sufficiency under the Rasch model (from `rasch`), for the comparison of attribute counts with θ.
- AIC and BIC, and out-of-sample prediction with the IMV (from `fit-prediction`, if taught first; not a prerequisite).

## Promises / leaves open

- Longitudinal CDMs (attribute transitions over time; `hmcdm_spatialreasoning` is an IRW example) → unpaid.
- Mixture and latent-class IRT beyond CDMs (from `constructs`) stays unpaid.
- Classification accuracy and reliability of attribute profiles → unpaid (Templin & Bradshaw, 2013, doi:10.1007/s00357-013-9129-4, is the pointer).
- Using attribute profiles for feedback or placement → `score-meaning` (a Recall only, if that lesson wants it).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `frac20` | main example | Tatsuoka's fraction subtraction, 536 middle-school students × 20 items, 8 attributes (convert a whole number, separate a whole number, simplify, common denominator, borrow, column borrow, subtract numerators, reduce). DINA: slip ≤ 0.25 on 19 of 20 items; guessing mostly near 0, but 0.44 for item 8 (needs only "subtract numerators"). Attribute prevalence 0.57 (convert a whole number) to 0.84 (subtract numerators). 201 students (37.5%) master all eight; 102 distinct profiles appear. The number of attributes mastered correlates 0.89 with the Rasch θ. Fit: saturated DINA AIC 9,395 (295 parameters, 255 of them class proportions), G-DINA 9,422, Rasch 9,635, 2PL 9,360; a higher-order DINA (48 parameters) beats them all on both criteria (AIC 9,115, BIC 9,321 vs. 2PL 9,532). Scrambling four Q-matrix columns (as in c7/3_cdm.R) raises AIC to 9,769. Q-matrix validation (PVAF) suggests changes to 9 of 20 items; the lesson should treat that as a prompt to look, not an answer. | — |
| `cdm_ecpe` | contrast | ECPE grammar section (Templin & Hoffman, 2013): 2,922 respondents × 28 items, 3 attributes (morphosyntactic, cohesive, lexical rules; names from the `CDM` package documentation). G-DINA class proportions pile onto four of the eight profiles, 000 (0.30), 001 (0.12), 011 (0.18) and 111 (0.35): together 0.95, a linear hierarchy (lexical, then cohesive, then morphosyntactic; Templin & Bradshaw, 2014). With the profiles lined up like that, a unidimensional model does better: 2PL AIC 85,205 and BIC 85,540, against DINA 85,809 / 86,186 and G-DINA 85,639 / 86,124. The CDM here is an ordinal scale in disguise. | — |
| sanity: `frac20` against the course's `c7/frac20.rds` | sanity | Same responses and same Q-matrix; DINA log-likelihood −4,402.3 from both. | — |

`cdm_timss07` (TIMSS 2007, 698 × 25, 15 attributes, 28% missing by booklet) was tried as a retrofitting failure case: a saturated model with $2^{15}$ classes did not finish in 10 minutes. A higher-order model might work; left for a problem, not the lesson. Other Q-matrix tables in the IRW, for problems: `cdm_timss03`, `cdm_pisa00R`, `cdm_mentalhealth_tan_2023_bsi` (a clinical, polytomous case), `hmcdm_spatialreasoning`.

## Widget / simulation / problem ideas

**Widgets**
- Q-matrix explorer: a 20 × 8 grid; click a respondent profile, see which items DINA says they should get right (ideas 2, 3).
- DINA vs. 2PL item: two plateaus ($g$, $1-s$) against the Rasch curve, with a slider for how many required attributes the respondent has (idea 3).
- Class count: attributes slider (1–10), with $2^K - 1$ class parameters against the sample size, and the higher-order alternative's count (idea 4).

**Predict-then-check:** ECPE's three attributes allow eight profiles. How many will hold most respondents? Answered by the G-DINA class proportions (four profiles, 95%).

**Simulate:** Generate DINA data from a 10-item, 3-attribute Q-matrix with known $g$ and $s$; fit DINA, G-DINA and the 2PL; compare recovered parameters and classification accuracy. Then misspecify one Q-matrix entry and watch which item's $g$ or $s$ absorbs it. `GDINA` is fast (under 2 s for frac20 locally); confirm it installs in webR.

**Problems**
1. Derivation: write the DINA likelihood for one respondent and show that, with one attribute per item, it is a two-class latent class model.
2. Real data with a twist (PS7#2 B): fit the "items are exchangeable carriers of skills" model, `resp ~ 0 + (1 | id) + Q`, to frac20. Do items with the same Q-matrix row have similar difficulties?
3. Real data (PS7#2 D, bonus): compare Rasch, 2PL, DINA and higher-order DINA on held-out responses. Does the held-out ranking agree with AIC?
4. Judgment: a district wants skill-level reports from a 25-item state test that was not designed with a Q-matrix. What would you tell them?
5. Design: write a Q-matrix for eight items of your own on one topic, with at least one item per attribute that needs that attribute alone. Why does that matter for identification?
6. Challenge (open): ECPE's profiles fall on a hierarchy. When attributes are ordered like that, is a CDM a new model or a unidimensional one with cut points?

## Go deeper

- **The higher-order DINA is close to a unidimensional IRT model.** Attributes as thresholds on one θ; why the higher-order fit on frac20 beats the 2PL but tracks the Rasch θ (r = 0.89). Why: `explanatory-irt`, `dimensionality`, `score-meaning`. Length: half a page.

## Open questions

- c7.pptx is missing from the export. *Default:* build the lesson from c7/3_cdm.R and PS7#2 (as outlined); send the deck if there is slide material worth keeping.
- The verdict in idea 5 ("a CDM earns its keep only when the Q-matrix was designed into the test") is my reading of PS7#2 and the ECPE result. *Default:* use it unless you'd put it differently.
- Q-matrix validation flags 9 of 20 frac20 items. *Default:* show it briefly in the lesson, with the caution that PVAF suggests too many changes under DINA; the full analysis goes to a problem.
