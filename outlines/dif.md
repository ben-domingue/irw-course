<!-- Outlined 2026-09-24 from EDUC 252 slides c5 (slides 1–31, fairness and DIF), PS5#3 and the code in c5/art.R, ps5/dif_itemtext.R and ps5/groupdiff_example.R. Deep dive #19 (gender DIF across the IRW). Scope note on #44: introduce IL-HTE as DIF with treatment as the group, and point to invariance-experience. -->

# Differential item functioning (`dif`)

Module: fairness · Prereqs: 1pl-to-4pl, validity-argument · Core · Status: outline

## Core ideas

1. **Impact is not bias.** Reference and focal groups; impact (groups differ on the construct: the heights of 3- and 10-year-olds) vs. bias (they differ for reasons unrelated to it). Fairness asks whether measurement error is associated with other characteristics. Ben's rule (slide 5): psychological measures are a great way of understanding differences among people who start in similar situations; the bigger the impact, the harder bias is to find. *(major)* Sources: AERA, APA & NCME (2014), *Standards*, ch. 3 "Fairness in testing" (open access; book, no DOI); Holland & Wainer (Eds.) (1993), *Differential item functioning*, doi:10.4324/9780203357811 (2012 reprint); Camilli (2006), "Test fairness", in R. L. Brennan (Ed.), *Educational measurement* (4th ed.) (book chapter, no DOI; **unverified**).
2. **DIF: the same item, conditional on the construct.** Nothing but θ should predict a response; if group membership does, the item functions differently (slides 17–21). Uniform vs. non-uniform DIF. The hard part is the x-axis: where does an unbiased measure of θ come from (slide 20)? The rest score or θ from the other items as the matching variable; anchors, purification, and why DIF is always relative to the other items (slide 22). *(major)* Sources: Lord (1980), *Applications of item response theory to practical testing problems*, doi:10.4324/9780203056615 (2012 reprint), ch. 14; Thissen, Steinberg & Wainer (1993), chapter in Holland & Wainer (1993); Swaminathan & Rogers (1990), doi:10.1111/j.1745-3984.1990.tb00754.x.
3. **Two workhorse methods and an effect size.** Logistic regression DIF (slide 25: the group coefficient is "where the action is"; an interaction for non-uniform DIF) and the Mantel–Haenszel common odds ratio, with ETS's Δ = −2.35 ln α and the A/B/C categories (slide 22: green, yellow, red). With many items and big samples something is always significant; the categories and substantive review decide. *(major)* Sources: Mantel & Haenszel (1959), doi:10.1093/jnci/22.4.719; Holland & Thayer (1986), ETS RR, doi:10.1002/j.2330-8516.1986.tb00186.x (published 1988 in Wainer & Braun, *Test validity*); Zwick (2012), doi:10.1002/j.2333-8504.2012.tb02290.x (flagging rules); Jodoin & Gierl (2001), doi:10.1207/S15324818AME1404_2 (ΔR² effect sizes); Magis, Béland, Tuerlinckx & De Boeck (2010), `difR`, doi:10.3758/BRM.42.3.847. Polytomous items: Crane et al. (2006), doi:10.1097/01.mlr.0000245183.28384.ed; Choi, Gibbons & Crane (2011), `lordif`, doi:10.18637/jss.v039.i08.
4. **Measurement invariance with multigroup CFA.** The factor-analytic version of the same question (slide 23): configural, metric (loadings), scalar (intercepts or thresholds) invariance; partial invariance; ordinal indicators need care with identification; ΔCFI conventions and their limits. Non-uniform DIF ↔ unequal loadings, uniform DIF ↔ unequal intercepts. Sources: Meredith (1993), doi:10.1007/BF02294825; Vandenberg & Lance (2000), doi:10.1177/109442810031002; Millsap (2011), *Statistical approaches to measurement invariance*, doi:10.4324/9780203821961; Wu & Estabrook (2016), doi:10.1007/s11336-016-9506-0; Chen (2007), doi:10.1080/10705510701301834; Putnick & Bornstein (2016), doi:10.1016/j.dr.2016.06.004; Rosseel (2012), `lavaan`, doi:10.18637/jss.v048.i02.
5. **Where bias comes from, and what to do about it.** Instrument bias (familiarity with multiple choice), administration bias (web vs. phone for a cognitive measure: Domingue et al., 2023, doi:10.1093/geronb/gbad068), culture-level differences (executive function tasks built for "schooled worlds": Kroupin et al., 2025, doi:10.1073/pnas.2407955122), language load in math items for English learners (Martiniello, 2008, doi:10.17763/haer.78.2.70783570r1111t32), and the classic SAT analogy item DECOY : DUCK, harder for women at equal ability (Dorans & Kulick, 1983, ETS RR, doi:10.1002/j.2330-8516.1983.tb00009.x; 1986, doi:10.1111/j.1745-3984.1986.tb00255.x; slide 13's quotation is from a secondary source, **which and where to verify**). Review before administration (think-alouds) beats repair after; a flagged item needs a theory, not only a p-value (slides 6–7, 29). Beyond the item: predictive bias, where a test predicts a criterion differently by group (Cleary, 1968, doi:10.1111/j.1745-3984.1968.tb00613.x; slide 24's JD-Next figure, **source to identify**).
6. **Treatment as a grouping variable.** Nothing restricts the group to demographics. With an RCT, "group" can be treatment assignment: items that move more than the rest under treatment show DIF by treatment (item-level heterogeneous treatment effects). Introduced here; developed in `invariance-experience`. Sources: Gilbert, Kim & Miratrix (2023), doi:10.3102/10769986231171710; Ahmed et al. (2024), doi:10.1080/19345747.2024.2361337.

Crossref-checked 09-24 unless marked.

## Picks up

- The 2PL and its ICCs; slopes as discrimination (from `1pl-to-4pl`).
- A measure should be insensitive to nonfocal attributes; fairness as part of validity (from `measurement`, `validity-argument`).
- Covariates in IRW tables (`cov_*`, `treat`) (from `irw-data`).
- Multigroup CFA and invariance (from `fa-confirmatory`, which isn't an ancestor: see Open questions).
- DIF for polytomous items, PS8#3 (from `polytomous`, not an ancestor: see Open questions).
- Predictive bias (the Cleary model) and invariance of structure across groups (from `validity-evidence`, not an ancestor; a Recall).
- Group differences that remain after linking (from `parameter-invariance`, optional; a Recall for readers who took it).
- Items that work differently for different groups (from `instrument-building`, not an ancestor).
- Multigroup SEM (from `sem`, optional).
- When a mean difference survives every rescaling (stochastic dominance; the `measurement` Go deeper): Recall when comparing groups on θ.

## Promises / leaves open

- Treatment as the grouping variable; item-level treatment effects; life events → `invariance-experience`.
- Linking and anchor items in operational DIF → `equating`.
- Explaining DIF with item features (why this item?) → `explanatory-irt`.
- Predictive bias and the Standards' fairness chapter beyond items → unpaid (landscape gap 7, "fair tests, fair uses").
- Gender DIF across the whole corpus → this lesson's *Across the IRW* (#19).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_11` | main example (dichotomous DIF, many groupings) | Science and social-studies vocabulary items from a content-literacy RCT (Kim et al., 2021, doi:10.1007/s10648-021-09609-6), 24 "circle two words that go with …" items, 2,588 students (2,347 complete), with gender, race/ethnicity, English-learner, IEP and low-income flags and treatment assignment (the PS5#3 analysis). Mantel–Haenszel by gender, Black, Hispanic, English learner, IEP and low income: 4–10 items significant at .05 per grouping, but every item is category A except one or two B items for English learners, IEP and low income (largest \|Δ\| 0.55–1.2). By **treatment**: 11 significant, 6 B and 3 C, and the largest \|Δ\| is 4.5 ("expedition": 9% correct in control, 58% under treatment). Demographic DIF is small; treatment DIF is large. | — |
| `alexandrowicz_2018_cesd` | contrast (polytomous items and multigroup CFA) | CES-D (Radloff, 1977, doi:10.1177/014662167700100306), 20 items scored 0–3, Austrian general-population sample (Alexandrowicz, Jahn & Wancata, 2018, doi:10.1371/journal.pone.0197908), 508 complete (262 women, 246 men). Ordinal logistic DIF by sex: "I had crying spells" (item 17) is the largest (z = 4.3, higher for women at equal rest score), then "happy" and "hopeful" (higher for men, z −2.8 and −2.6) and "my life had been a failure" (women, 2.4). This matches the authors' own Rasch DIF analysis (failure and crying favour women; hopeful, happy and enjoy favour men) and the older literature on the crying item (Cole et al., 2000, doi:10.1016/S0895-4356(99)00151-1). Multigroup CFA (one factor, MLR): metric and scalar constraints both worsen fit (Δχ² 52.9 and 49.9 on 19 df, p < .001), and the largest score tests in the scalar model are the crying item's loading (χ² 54) and intercept (14). | — |

Notes, stated gently in the lesson:
- `gilbert_meta_11`: the IRW description says grade 1; Kim et al. (2021) is an elementary-grade study. Grade to confirm from the paper. Item text comes from `irw_itemtext` (checked 09-24: the "circle two words that go with *X*" stems match the `sci`/`ss` item ids by content area). Instrument reuse status for #63.
- `alexandrowicz_2018_cesd`: `cov_sex` is coded 1/2; the direction of our results matches the paper's only if 2 = women, which I take as confirmed by that agreement (to recheck against the paper's data file). Reverse-worded items (`cesr*`) arrive keyed. A one-factor model fits the CES-D only moderately (configural CFI 0.83, RMSEA 0.073), as expected from Radloff's four components; the draft should fit the four-factor (or bifactor) model before testing invariance.
- `DART_Brysbaert_2020_1` (the slides' example) is dropped here: see Open questions.

**Sanity table.** `gilbert_meta_11` with a random split in place of a real group: over 20 random splits, on average 1.3 of 24 items are significant at .05 (about the nominal 5%), none reaches B, and the largest \|Δ\| is 0.77.

**Deep dive (#19): corpus filter.** Following the IRW vignette (https://itemresponsewarehouse.org/vignettes/gender_dif.html): `union(irw_filter(var = "cov_gender"), irw_filter(var = "cov_sex"))` with `irw_filter`'s default density ≥ 0.5; drop tables with fewer than 6 items or fewer than 50 respondents per group; binarize on the two most common values; sample up to 5,000 respondents; MH (dichotomous) and generalized MH / ordinal logistic (polytomous) via `difR`. Summary per table: share of items in B and C. Pilot known-good tables: `alexandrowicz_2018_cesd` (crying should flag) and `gilbert_meta_11` (gender: all A). The vignette's own run included 181 of 459 candidate tables.

## Widget / simulation / problem ideas

**Widgets**
- Impact vs. DIF: two groups' θ distributions and one item's ICC per group; move the group mean gap (impact) and the item's shift (DIF) separately, and watch the raw proportion-correct gap, which mixes the two (ideas 1, 2).
- Uniform vs. non-uniform: two ICCs with separate b and a controls; the MH Δ and the logistic-regression coefficients update (ideas 2, 3).
- The matching variable: with one DIF item among 20, compare matching on the total including the item, on the rest score, and on a purified score; watch the DIF estimate for the other items (contamination) (idea 2).
- Invariance ladder: a two-group factor model with loading and intercept controls for one item; configural/metric/scalar fit statistics light up as constraints fail (idea 4).

**Predict-then-check:** in the vocabulary RCT, which grouping will show the most DIF: gender, race/ethnicity, English-learner status, IEP status, low income, or treatment assignment? Answered by the A/B/C table (treatment: 3 C items; every demographic grouping essentially all A).

**Simulate:** generate 2PL data for two groups with impact and one or two DIF items; run MH and logistic regression with and without purification; compare flags with the truth across replications (Type I error for the clean items, power for the DIF items). Seconds in webR with `difR`.

**Problems**
1. Derivation: under the Rasch model with no DIF, show that the MH common odds ratio is 1 when matching on the total score *including* the studied item (sufficiency; Holland & Thayer, 1986; Zwick, 1990, doi:10.3102/10769986015003185). Why does it fail for the 2PL, or when the studied item is left out of the total?
2. Real data with a twist (PS5#3): repeat the `gilbert_meta_11` gender analysis within the control group only. Does anything change, and why might treatment DIF contaminate a gender analysis in the full sample?
3. Real data: in the CES-D, free the crying item's loading and intercept and compare the women–men latent mean difference with and without that freedom. How much of the raw sum-score difference does one item carry?
4. Judgment: a C item on a licensure test with a plausible content explanation ("hunting and fishing", slide 13) and one with none. What do you do with each (slide 22: "what to do with red items?")?
5. Design: you're building a math test for a population with many English learners. Where in development would you look for bias, and with what (reviews, think-alouds, DIF on a pilot)? (Martiniello, 2008.)
6. Challenge (open): culture-level DIF. If executive-function tasks measure something different in unschooled populations (Kroupin et al., 2025), is that DIF, a different construct, or both? What data would separate them?

## Go deeper

- **The Mantel–Haenszel odds ratio and the Rasch model.** Under the Rasch model the sum score is sufficient, so matching on the total that includes the studied item makes the MH no-DIF null exact (Zwick, 1990); problem 1 as a callout. Why: `rasch` (sufficiency, the agreed depth target), `invariance-experience`, `equating`. Length: half a page.

## Open questions

- **Prerequisites.** Core idea 4 needs CFA, but `fa-confirmatory` isn't a prerequisite (and polytomous DIF comes from `polytomous`, also not an ancestor). Add `fa-confirmatory` (and `polytomous`) as prereqs of `dif`? Both are core and come before `dif` in the first-course path. Otherwise idea 4 must teach multigroup CFA from scratch.
- **DART.** The slides' `DART_Brysbaert_2020_1` is dropped. In the IRW table a checked foil name scores 1 like a recognized author (e.g. 3% "recognize" the foil Kim Wassing), so the matching total mixes hits and false alarms, and with 199 respondents (67 men) only 2 of 132 names survive a false-discovery correction. The Austen/Allende vs. Clancy/Krabbé pattern is appealing. Keep it as a problem with foils removed (using Brysbaert et al.'s foil list), or drop it?
- **Treatment DIF in the main example.** The main example's biggest finding is treatment DIF, which is `invariance-experience`'s subject. Per the #44 note this lesson introduces the idea; `invariance-experience` then uses different tables (`gilbert_meta_20`, `gilbert_meta_37`). OK to lead with it here?
- **Slide sources to identify:** the secondary source quoting Dorans & Kulick on DECOY : DUCK (slide 13); the JD-Next figure (slide 24).
