<!-- Outlined and drafted 2026-09-25 (#152), at Ben's request while reviewing dif (09-25): a broader fairness lesson as a preliminary to dif, with measurement invariance in general and DIF as the item-level special case. Impact vs. bias (Ben's slide 5 rule, the heights example) moves here from outlines/dif.md. Sources: EDUC 252 slides c5, 1–16. -->

# Fairness in testing: bias, impact, and measurement invariance (`fairness`)

Module: fairness · Prereqs: validity-argument · Core · Status: drafted (#152)

## Core ideas

1. **Fairness as the *Standards* frame it.** Fairness is a validity issue: a fair test measures the same construct for everyone in the intended population, and nobody gains or loses through characteristics irrelevant to it. The four views of chapter 3 (treatment during testing; lack of measurement bias; access to the construct; validity of individual interpretations for the intended use), and the one view the chapter sets aside: equal outcomes. The lesson's one quotation (p. 54): group differences in outcomes don't in themselves show bias. *(major)* Sources: AERA, APA & NCME (2014), *Standards*, ch. 3, pp. 49–54, open access at https://www.testingstandards.net/open-access-files.html (book, no DOI; read 09-25); Camilli (2013), doi:10.1080/13803611.2013.767602.
2. **Impact is not bias.** Impact: groups differ on the construct (the heights of 3- and 10-year-olds, slide 4). Bias: they differ for reasons unrelated to it (slide 4); in terms of error, fairness asks whether measurement error is associated with other characteristics (slide 2). A widget shows that the same observed gap can be all impact, all bias or any mix, so the gap alone can't tell them apart. Where bias enters: the instrument (a checklist word with a cousin in another language), administration (web vs. phone in the HRS: Domingue et al., 2023, doi:10.1093/geronb/gbad068), culture (Kroupin et al., 2025, doi:10.1073/pnas.2407955122; named only, since `dif` may use it as a problem). Ben's rule (slide 5): measures are best at comparing people who start in similar situations; the bigger the impact, the harder bias is to find. *(major)*
3. **The same measure in different groups: measurement invariance.** Invariance: the distribution of responses given θ doesn't depend on group (Meredith, 1993, doi:10.1007/BF02294825; Millsap, 2011, doi:10.4324/9780203821961). The ladder conceptually: configural (same structure), metric (same slopes/loadings, so a unit means the same), scalar (same intercepts/difficulties, so means can be compared); partial invariance. An "if you've done `fa-confirmatory`" Recall of its multigroup CFA (E2); not re-taught. The limit: invariance is relative. A shift shared by every item is indistinguishable from impact, so invariance tests can't see it. *(major)* Also Vandenberg & Lance (2000), doi:10.1177/109442810031002; Putnick & Bornstein (2016), doi:10.1016/j.dr.2016.06.004.
4. **Predictive bias: the Cleary model.** A test is biased in prediction for a group when a common regression line systematically over- or under-predicts that group's criterion (Cleary, 1968, doi:10.1111/j.1745-3984.1968.tb00613.x; *Standards* glossary and Standard 3.7, pp. 65–66). An "if you've done `validity-evidence`" Recall (E2; its Go deeper names predictive bias). An outside criterion can see a shift common to all items, which invariance can't. But with a fallible test and impact, a common line over-predicts the lower group even with no bias anywhere (Linn & Werts, 1971, doi:10.1111/j.1745-3984.1971.tb00898.x, on unreliability in bias studies; shown by widget and simulation). Measurement and predictive invariance can disagree (Millsap, 2007, doi:10.1007/s11336-007-9039-7; *Standards* p. 52). Empirical record (Sackett, Borneman & Connelly, 2008, doi:10.1037/0003-066X.63.4.215; Aguinis, Culpepper & Pierce, 2010, doi:10.1037/a0018714): moved to *Going further* in the draft, for length.
5. **DIF: the item-level special case.** Differential test functioning vs. differential item functioning (*Standards* p. 51 and glossary); the hand-off to `dif`, which matches on the other items and asks item by item. One paragraph.

Crossref-checked 09-25 (OpenAlex for abstracts; no email sent anywhere).

## Picks up

- Validity as an interpretation for a use; construct-irrelevant variance and the mathematics test that leans on reading (from `validity-argument`).
- What we want from a measure: insensitivity to nonfocal attributes (from `measurement`, via `validity-argument`'s Recall).
- Reliability as the share of true-score variance; a test's correlation with anything is bounded by it (from `ctt-reliability`), for the Cleary artefact.
- Multigroup CFA and the invariance ladder (from `fa-confirmatory`, not an ancestor: "if you've done", E2).
- Predictive bias named in `validity-evidence`'s Go deeper (not an ancestor, and not yet on main: "if you've done", E2).
- The 2PL, only as the model the real-data fit uses; named in words so that a reader with only the prerequisites can follow.

## Promises / leaves open

- Item by item: matching on the other items, MH and logistic DIF, anchors and purification → `dif`.
- Treatment as a grouping variable → `invariance-experience` (via `dif`).
- The Cleary artefact and the MH impact problem share one mechanism (conditioning on a fallible score when groups differ) → `dif` (its Zwick recall).
- Access, accommodations and universal design (the *Standards*' third view) → unpaid.
- Whether an invariant test can still be unfair (opportunity to learn) → unpaid; problem 6, open.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gcbs_brotherton_2013_vcl` | main example (one checklist, two groupings) | The Open-Source Psychometrics Project's 16-word vocabulary checklist ("check the words whose definitions you are sure you know"; 3 non-words as a validity check), given with the GCBS (Brotherton, French & Pickering, 2013, doi:10.3389/fpsyg.2013.00279; IRW biblio). 2,495 respondents, 13 real words. **Age** (under 25, n = 1,409, vs. 40+, n = 468): sum-score gap 0.69 SD, latent gap 1.25 under scalar invariance; LR χ² = 72 (24 df), above ten random splits (19–54), but BIC favours scalar by 109, and freeing the two largest words moves the gap only to 1.19. Impact, near enough. **Native language** (1,875 native vs. 612 not): sum-score gap −0.29 SD; χ² = 280 and BIC favours configural; *epistemology* (checked by 50% of non-native vs. 44% of native speakers, although non-native speakers check fewer words overall), *abysmal* (64% vs. 84%) and *pastiche* depart most; freeing them moves the latent gap from −0.40 to −0.51. | — |

Notes, stated gently in the lesson: the checklist is self-report of knowing a word, not a test of meaning; the online sample took the survey mainly for amusement (codebook); `cov_engnat` 0 = no answer (8 respondents). Word list checked against the source codebook (GCBS.zip, openpsychometrics.org). Cognates (*epistemology*, *pastiche* have close relatives in several European languages) are offered as a hypothesis the table can't test, with no citation claimed.

**Sanity table.** The same table, split at random ten times: χ² 19–54 on 24 df (4 of 10 below .05), BIC favours scalar every time (by 134–169), latent gaps within ±0.11. This is the baseline for reading the two real groupings, and the reason the lesson doesn't rest on the LR p-value.

## Widget / simulation / problem ideas

**Widgets**
- Impact and bias (idea 2): two groups' true standings and observed scores; sliders for impact and a bias against the focal group. Impact 1 with no bias, 0.5 and 0.5, and 0 with bias 1 give the same observed gap (−0.94 in the seeded sample).
- What the data can see (idea 3): eight items; one item's shift and a shift shared by all; the shared shift moves into the apparent group difference, and only the one-item shift stays visible.
- A common regression line (idea 4): criterion against test score by group; sliders for impact, reliability, and a real criterion difference. At impact 1, reliability 0.7 and no bias, the common line over-predicts the focal group by 0.14; at reliability 1, by 0.005.

**Predict-then-check:** with *epistemology*, *abysmal* and *pastiche* freed, will the gap between native and non-native speakers (−0.40 SD with every word equal) shrink, stay or grow? It grows, to −0.51.

**Simulate:** 2PL data for two groups, impact 0.8, no bias: raw item gaps all negative; configural vs. scalar (χ² 11.9 on 28 df, p = 1.0); latent gap −0.79; a criterion that depends on θ alone, yet the common line over-predicts the focal group (intercept difference −0.13, t = −4.0). Then `shift_all <- 0.5`: invariance test silent (p = 0.85), latent gap −1.31, and the common line now *under*-predicts the focal group (+0.26).

**Problems**
1. Derivation: shifting every item's difficulty by δ for one group gives the same response probabilities as shifting that group's θ by −δ. What does that imply for what invariance tests can detect?
2. Real data with a twist: the three non-words. Who checks them, by age and by language? Refit the native-language comparison without respondents who check any non-word.
3. Judgment: the checklist used (a) to study English vocabulary across adulthood; (b) as a verbal-ability covariate in an international online study. Is the native-language gap impact or bias under each use?
4. Design: web vs. phone (Domingue et al., 2023). Why does random assignment of mode let you see a bias that invariance tests can't?
5. Derivation/judgment: with reliability ρ and impact Δ, by how much does a common line over-predict the lower group? (The Go deeper.) What happens with 40 items?
6. Challenge (open): can a test be invariant and still unfair? Opportunity to learn (*Standards* p. 54); Meredith (1993) argues strict invariance is required for fairness: necessary, sufficient, or neither?

## Go deeper

- **Why a fallible predictor over-predicts the lower group.** With X = θ + e, Y = β₁θ + u, θ ~ N(μ_g, 1) within group, the within-group regression of Y on X has slope β₁ρ and intercept β₁(1 − ρ)μ_g; the common line sits between them. Why: `dif` (the same mechanism behind Zwick's result on matching with impact), `validity-evidence` (attenuation). Length: half a page.

## Changes in drafting

- Sackett et al. (2008) and Aguinis et al. (2010) moved from idea 4 to *Going further* (length).
- The real-data code prints BIC and χ² through a small `compare()` helper; the partial model for age frees *paucity* and *epistemology*.
- Problem 5 uses the simulation's values (β₁ = 1, reliability about 0.8, gap 0.8).

## Open questions

- **For Ben:** the verdict. Proposed: "When an invariance test rejects, I don't stop at the p-value. I free the items that fail and ask whether the comparison I care about moves." Default: keep.
- **For Ben:** Kroupin et al. (2025) is named here in one sentence; `dif` has it as problem 6. Default: leave it with `dif`.
- Threads proposed in the PR, not in `lessons.yml`.
