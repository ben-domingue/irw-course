<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 35–43, "Parameter invariance", with the Baker illustration) and c4/enem2.R. Tidied 09-24 (#62): Ben's answers applied (C17, A4); pick-ups checked against the drafted `rasch`. -->

# Parameter invariance (`parameter-invariance`)

Module: irt · Prereqs: 1pl-to-4pl · Extension · Status: outline

## Core ideas

1. **Invariance is a property of the model, not of estimates.** If an IRT model holds in a population, the same item parameters govern responses in every subgroup of it, just as a regression line is the same whatever range of $x$ you sample. *(major)* Sources: Baker (2001), *The basics of item response theory* (2nd ed.), ERIC Clearinghouse on Assessment and Evaluation (ED458219; free; no DOI), ch. 3, "The group invariance of item parameters", pp. 51–54, Figs. 3-3 to 3-7 (groups in [−3, −1] and [+1, +3] both give b = −.39, a = 1.27); third edition Baker & Kim (2017), doi:10.1007/978-3-319-54205-8; Rupp & Zumbo (2006), doi:10.1177/0013164404273942; Lord (1980), doi:10.4324/9780203056615.
2. **Estimates are local.** Each group's estimates sit on that group's own scale (`mirt` centres $\theta$ in each group, as `rasch` showed), so difficulties shift by a constant and slopes rescale before any comparison. Putting them on one scale is linking. *(major)* Thread from `rasch` (the scale has no origin). Sources: Stocking & Lord (1983), doi:10.1177/014662168300700208; Kolen & Brennan (2014), doi:10.1007/978-1-4939-0317-7.
3. **Estimates from restricted groups can be poor.** Fitting within a narrow range of ability starves the slopes of information. And splitting on the sum score of the same items selects on the outcome: within each half the items correlate about zero (MRMET: mean inter-item r 0.065 overall, −0.003 in the top half), so 2PL slopes collapse. *(major)* Sources: Baker (2001), ch. 3; the selection effect is this lesson's own finding in the data (C17).
4. **Rasch difficulties look more invariant in practice.** With slopes fixed, difficulties from different groups line up better than 2PL estimates (slide 43). The lesson asks whether that is a property of the items or of fitting fewer parameters (problem 6). Source: Wright (1997), doi:10.1111/j.1745-3992.1997.tb00606.x.
5. **When invariance fails for real.** Differences that survive linking are differential item functioning; that is `dif`'s subject. Source: Holland & Wainer (1993), *Differential item functioning*, Routledge reprint doi:10.4324/9780203357811.

DOIs Crossref-checked 09-24.

**Verdict (voice rule A):** how to split a sample when checking invariance (never on the same items' sum score; random halves, a background variable, or a separate set of items).

## Picks up

- Specific objectivity: comparisons of items shouldn't depend on the respondents; crossing ICCs (from `rasch`).
- The scale has no origin; `mirt` fixes the mean ability at 0, other programs the mean difficulty (from `rasch`).
- The 2PL, `mirt`'s parameterization and identification (from `1pl-to-4pl`).

## Promises / leaves open

- Linking estimates from different groups or forms → `equating`.
- Group differences that remain after linking → `dif`, `invariance-experience`.
- Invariance of person parameters across item sets (the other half of specific objectivity) → `equating`, `item-banks-cat`.
- The linear indeterminacy of 2PL estimates across groups (problem 1, Go deeper) → `equating`, `item-banks-cat`.
- Restricted samples starve estimates of information: if the reader has done `information`, this is the same point seen from the item side (a sibling, not an ancestor; E2 pointer, no hook).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `wilmer-mrmet-normative-data-set-2022` | main example | Multiracial RMET (Kim et al., 2024, doi:10.3758/s13428-023-02323-x), 37 items, 9,295 complete respondents with gender, age and country. **Random halves:** difficulties agree almost perfectly (Rasch r ≈ 1.00; 2PL slopes r = 0.98). **Women vs. men:** Rasch difficulties r = 0.99, shifted by 0.24 logits (a scale difference, not an item difference); 2PL slopes r = 0.92. **High vs. low scorers, split on the same items:** Rasch r = 0.95 with a 1.3-logit shift; the 2PL falls apart (slopes near zero in both halves, r of difficulties −0.08). **Split on the odd items, estimating the even ones:** Rasch r = 0.97; 2PL difficulties r = 0.87, slopes r = 0.60. | `1pl-to-4pl` uses the RMET table from the same paper. |

The MRMET items correlate weakly with one another (mean r 0.065), which is common for tests of this kind and sharpens the restricted-range problem. The lesson says so gently.

**Decisions (Ben, 09-24):** keep the selection effect (C17); no ENEM, and forms are left to `equating` (A4).

## Widget / simulation / problem ideas

**Widgets**
- Baker's illustration: a true ICC, two groups sampled from different ability ranges; each group's fitted curve, and the same curve underneath (idea 1).
- Local scales: two groups' difficulty estimates, with a "link" button that removes the shift (idea 2).
- Restricted range: slide the ability range sampled; watch the spread of the 2PL slope estimate grow (idea 3).

**Predict-then-check:** will item difficulties agree better between women and men, or between high and low scorers? Answered by the four comparisons.

**Simulate:** 2PL data for one population; fit separately in random halves, in high and low groups (split on true $\theta$), and in groups split on the sum score; compare with the true parameters.

**Problems**
1. Derivation: if $\theta$ is standardized within a group whose true mean is $\mu$ and SD $\sigma$, show that the 2PL estimates satisfy $a^* = a\sigma$ and $b^* = (b-\mu)/\sigma$.
2. Derivation: use 1 to link the women's and men's 2PL estimates by mean–sigma; how close do they get?
3. Real data with a twist: split the MRMET by age (under 25 vs. over 40). Are the difficulties invariant after linking?
4. Judgment: why does splitting on the total score of the same items distort the estimates, and what split would you use instead?
5. Design: you need item parameters that hold for a new population. What sample would you calibrate on?
6. Challenge (open): the Rasch difficulties look more invariant than the 2PL's. Is that a property of the items, or of fitting fewer parameters?

## Go deeper

- **Linear indeterminacy of 2PL estimates across groups** (problem 1 as a callout). Why: `equating`, `dif`, `item-banks-cat`. Length: half a page.

## Open questions

- None.
