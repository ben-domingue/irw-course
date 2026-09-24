<!-- Outlined 2026-09-24 from EDUC 252 slides c5 (1–31), PS5#3, c5/art.R, ps5/dif_itemtext.R, ps5/groupdiff_example.R. Deep dive #19. #44: introduce IL-HTE as treatment DIF; point to invariance-experience. Trimmed 09-24 (Ben, E1): multigroup CFA moved to fa-confirmatory; polytomous DIF became a problem; sources of bias and predictive bias cut to a sentence each. -->

# Differential item functioning (`dif`)

Module: fairness · Prereqs: 1pl-to-4pl, validity-argument · Core · Status: outline

The lesson leads with the vocabulary RCT (`gilbert_meta_11`): demographic DIF first, treatment DIF as the twist (Ben, F9).

## Core ideas

1. **Impact is not bias.** Impact (groups differ on the construct: the heights of 3- and 10-year-olds) vs. bias (they differ for reasons unrelated to it); fairness asks whether measurement error is associated with other characteristics. Ben's rule (slide 5): measures are best at comparing people who start in similar situations; the bigger the impact, the harder bias is to find. One sentence each on where bias enters (instrument, administration: Domingue et al., 2023, doi:10.1093/geronb/gbad068; culture: problem 6) and on predictive bias (Cleary, 1968, doi:10.1111/j.1745-3984.1968.tb00613.x). *(major)* Sources: AERA, APA & NCME (2014), *Standards*, ch. 3 (open access; book, no DOI); Holland & Wainer (Eds.) (1993), doi:10.4324/9780203357811; Camilli (2006), "Test fairness", in Brennan (Ed.), *Educational measurement* (4th ed.) (chapter, no DOI; **unverified**).
2. **DIF: the same item, conditional on the construct.** If group membership predicts a response at equal θ, the item functions differently (slides 17–21); uniform vs. non-uniform. The hard part is the x-axis (slide 20): matching on the rest score or θ from the other items; anchors, purification, and why DIF is always relative to the other items (slide 22). One paragraph recalls multigroup CFA for readers who have done `fa-confirmatory` (loadings ↔ non-uniform, intercepts ↔ uniform DIF). *(major)* Sources: Lord (1980), doi:10.4324/9780203056615, ch. 14; Thissen, Steinberg & Wainer (1993), in Holland & Wainer (1993); Swaminathan & Rogers (1990), doi:10.1111/j.1745-3984.1990.tb00754.x.
3. **Two workhorse methods and an effect size.** Logistic regression DIF (slide 25: the group coefficient is "where the action is"; an interaction for non-uniform DIF) and the Mantel–Haenszel odds ratio, with ETS's Δ = −2.35 ln α and A/B/C categories. With many items and big samples something is always significant; the categories and review decide, and a flagged item needs a theory (DECOY : DUCK: Dorans & Kulick, 1983, doi:10.1002/j.2330-8516.1983.tb00009.x; 1986, doi:10.1111/j.1745-3984.1986.tb00255.x; slide 13's quotation is from a secondary source, **to identify**). *(major)* Sources: Mantel & Haenszel (1959), doi:10.1093/jnci/22.4.719; Holland & Thayer (1986), doi:10.1002/j.2330-8516.1986.tb00186.x; Zwick (2012), doi:10.1002/j.2333-8504.2012.tb02290.x; Magis, Béland, Tuerlinckx & De Boeck (2010), `difR`, doi:10.3758/BRM.42.3.847.
4. **Treatment as a grouping variable.** In an RCT, items that move more than the rest under treatment show DIF by treatment (item-level heterogeneous treatment effects). The twist in the real data; developed in `invariance-experience`. *(major)* Sources: Gilbert, Kim & Miratrix (2023), doi:10.3102/10769986231171710; Ahmed et al. (2024), doi:10.1080/19345747.2024.2361337.

Crossref-checked 09-24 unless marked.

## Picks up

- The 2PL and its ICCs; slopes as discrimination (from `1pl-to-4pl`).
- Fairness as part of validity; insensitivity to nonfocal attributes; stochastic dominance when comparing groups on θ (from `validity-argument`, `measurement`).
- Sufficiency of the sum score, for the Go deeper (from `rasch`).
- Covariates in IRW tables (`cov_*`, `treat`) (from `irw-data`).
- Multigroup CFA and invariance (from `fa-confirmatory`, not an ancestor: one "if you've done" paragraph, E2).
- Predictive bias, the Cleary model (from `validity-evidence`, not an ancestor: one sentence, E2).
- Items that work differently for different groups (from `instrument-building`, not an ancestor: E2).
- Group differences that remain after linking (from `parameter-invariance`, extension: E2).
- Polytomous DIF, PS8#3 (the hook from `polytomous`, paid by problem 3, which is self-contained; `dif` doesn't depend on `polytomous`, E1).

## Promises / leaves open

- Treatment as the grouping variable; item-level treatment effects; life events → `invariance-experience`.
- Linking and anchor items in operational DIF (drifting anchors) → `equating`.
- Explaining DIF with item features (why this item?) → `explanatory-irt`.
- DIF screens for the items in a bank → `item-banks-cat` (an "if you've done" Recall there).
- Fairness beyond items (the Standards' fairness chapter: access, accommodations, uses) → unpaid (landscape gap 7).
- Gender DIF across the whole corpus → this lesson's *Across the IRW* (#19).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_11` | main example (dichotomous DIF, many groupings) | Vocabulary items from a content-literacy RCT (Kim et al., 2021, doi:10.1007/s10648-021-09609-6), 24 items, 2,347 complete students, with gender, race/ethnicity, English-learner, IEP, low-income and treatment flags (PS5#3). MH by demographic grouping: 4–10 items significant at .05 each, but all category A except one or two B items for English learners, IEP and low income (largest \|Δ\| 0.55–1.2). By **treatment**: 11 significant, 6 B and 3 C; largest \|Δ\| 4.5 ("expedition": 9% correct in control, 58% under treatment). | — |
| `alexandrowicz_2018_cesd` | problem 3 (polytomous DIF) | CES-D (Radloff, 1977, doi:10.1177/014662167700100306), 20 items, 0–3, Austrian general population (Alexandrowicz, Jahn & Wancata, 2018, doi:10.1371/journal.pone.0197908), 508 complete. Ordinal logistic DIF by sex: "I had crying spells" largest (z = 4.3, women higher at equal rest score), as in the authors' Rasch analysis and Cole et al. (2000), doi:10.1016/S0895-4356(99)00151-1. | — |

Notes, stated gently in the lesson:
- `gilbert_meta_11`: the IRW says grade 1 (to confirm from Kim et al., 2021). Item text matches the ids (checked 09-24).
- `alexandrowicz_2018_cesd`: `cov_sex` is 1/2; our direction matches the paper if 2 = women (to recheck). Reverse-worded items arrive keyed.
- `DART_Brysbaert_2020_1` (the slides' example) appears only in problem 4, with the foils removed (F8): in the IRW a checked foil scores 1 like a recognized author.

**Sanity table.** `gilbert_meta_11`, random splits as the group: over 20 splits, 1.3 of 24 items significant at .05 on average, none B, largest \|Δ\| 0.77.

**Deep dive (#19): corpus filter.** As in the IRW vignette (https://itemresponsewarehouse.org/vignettes/gender_dif.html): tables with `cov_gender` or `cov_sex`; at least 6 items and 50 respondents per group; up to 5,000 respondents; MH or generalized MH via `difR`; share of items in B and C per table. Pilot known-good tables: `alexandrowicz_2018_cesd` (crying flags), `gilbert_meta_11` (gender: all A).

## Widget / simulation / problem ideas

**Widgets**
- Impact vs. DIF: move the groups' mean gap (impact) and one item's shift (DIF) separately; the raw proportion-correct gap mixes the two (ideas 1, 2).
- Uniform vs. non-uniform: two ICCs with b and a controls; MH Δ and the logistic coefficients update (ideas 2, 3).
- The matching variable: one DIF item among 20; match on the total, the rest score or a purified score and watch the other items' estimates (idea 2).

**Predict-then-check:** in the vocabulary RCT, which grouping will show the most DIF: gender, race/ethnicity, English-learner status, IEP status, low income, or treatment assignment? Answered by the A/B/C table (treatment: 3 C; demographics essentially all A).

**Simulate:** 2PL data for two groups with impact and one or two DIF items; MH and logistic regression with and without purification; Type I error and power across replications. Seconds in webR (`difR`).

**Problems**
1. Derivation: under the Rasch model with no DIF, the MH common odds ratio is 1 when matching on the total *including* the studied item (Zwick, 1990, doi:10.3102/10769986015003185). Why not for the 2PL?
2. Real data with a twist (PS5#3): repeat the gender analysis within the control group only. How could treatment DIF contaminate a gender analysis?
3. Real data: polytomous DIF on the CES-D, taught in the problem: a cumulative-logit model per item on the rest score, plus sex and sex × rest score (Crane et al., 2006, doi:10.1097/01.mlr.0000245183.28384.ed; `lordif`: Choi, Gibbons & Crane, 2011, doi:10.18637/jss.v039.i08). Which item flags, and why might it?
4. Judgment (F8): in the DART author-recognition table (foils removed), Austen and Allende look easier for women, Clancy and Krabbé for men (the solution checks this). DIF, bias, or the construct? What do you do with a C item that has a content explanation, and with one that has none (slide 22)?
5. Design: a math test for many English learners. Where in development would you look for bias, and how? (Martiniello, 2008, doi:10.17763/haer.78.2.70783570r1111t32.)
6. Challenge (open): executive-function tasks built for "schooled worlds" (Kroupin et al., 2025, doi:10.1073/pnas.2407955122): DIF, a different construct, or both? What data would separate them?

## Go deeper

- **The Mantel–Haenszel odds ratio and the Rasch model.** Problem 1 as a callout (Zwick, 1990). Why: `rasch` (sufficiency), `invariance-experience`, `equating`. Length: half a page.

## Open questions

- None (settled 09-24: E1, E2, F8, F9). Finding DECOY : DUCK's secondary source is Claude's (D).
