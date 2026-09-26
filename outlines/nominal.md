<!-- Outlined 2026-09-24 from EDUC 252 c9 (slides 15–16) and c9/nominal.R (written for `preference_inventory`, which has no tokenless CSV; replaced here, per #15 and #80). No problem set covers it. Tidied 09-24 (#62). -->

# Nominal response and multiple-choice models (`nominal`)

Module: beyond · Prereqs: polytomous, guessing-priors · Extension · Status: draft (#80)


**Drafted 09-25 (#80). What changed from this outline:**
- Numbers recomputed on the pinned tables (RMET v22, the version `1pl-to-4pl` uses; Borges v60). RMET, 4,000 respondents: test information at θ = −2 is 7.2 (nominal) vs 4.1 (2PL), within 0.2 from 0 up; 38 of 108 distractors peak inside (−3, 3), 70 fall, none rises to the top. Item 14's *irritated* falls with θ (0.20 → 0.02, peak at −2.2), not rises as outlined; the rising RMET distractor is item 25's *incredulous* (0.17 → 0.23, peak 2.35). The 3PL median $c$ is 0.01 (as `1pl-to-4pl` and `guessing-priors` say), not 0.05.
- Added: respondents at or below chance don't choose at random (median key 0.20, top distractor 0.33, bottom 0.18); the most popular distractor takes a median 54% of wrong answers. Pays `lower-asymptote-identification` and the proposed `chance-floor` thread.
- Borges numbers match the outline (information 19.9 vs 9.1 at θ = −2; 19 items with item-rest r < 0.1; item 21's C 0.03 → 0.73). New: the four items with negative item-rest r (21, 32, 78, 95) are all among the ten with a rising distractor. The "align the sign" step is not needed: with the key coded last, the nominal θ correlates 0.96 with the sum score.
- Intercept written $\gamma_k$ (notation.md has $c$ for the lower asymptote); proposed for notation.md in the PR.
- Widgets: option curves; which is the key (Borges item 21); information with/without distractors (driven by the first widget's item); the MC model's don't-know category. Predict-then-check as planned.
- Simulate as planned (seed 80): bottom-third correlation 0.778 (nominal) vs 0.677 (2PL).
- Problem tables: `himmelstein-berlin_numeracy-2025` dropped (option-level data not checked); problem 4 shortened.

## Core ideas

1. **Scoring 0/1 throws away which wrong answer was chosen.** The nominal response model gives every option its own slope and intercept, so the model, not the scorer, orders the options along θ. *(major)* Sources: Bock (1972), doi:10.1007/bf02291411; Thissen, Cai & Bock (2010), doi:10.4324/9780203861264.ch3; `mirt`: Chalmers (2012), doi:10.18637/jss.v048.i06.
2. **Reading option curves.** The key rises; a good distractor falls; one that peaks mid-range attracts partial knowledge; one that rises at the top is a second right answer or a key worth checking (c9 slide 15: "Which response do you think is correct?"). *(major)* Sources: Thissen, Steinberg & Fitzpatrick (1989), doi:10.1111/j.1745-3984.1989.tb00326.x; Gierl, Bulut, Guo & Zhang (2017), doi:10.3102/0034654317726529.
3. **Distractors carry information, mostly at low θ.** Among respondents who miss an item, the distractor chosen says something about θ, so nominal information exceeds the 2PL's below the item's difficulty and matches it above. *(major)* Sources: Bock (1972); Thissen et al. (1989).
4. **The multiple-choice model and guessing.** Thissen and Steinberg add a latent "don't know" category spread across the options, a different account of guessing from the 3PL's floor. It isn't in `mirt`, so it is taught with a widget, and `mirt`'s nested logit model (`2PLNRM`) is the software example (digest F34). Sources: Thissen & Steinberg (1984), doi:10.1007/bf02302588; Suh & Bolt (2010), doi:10.1007/s11336-010-9163-7.
5. **Nominal and ordinal are ends of a continuum.** The PCM and GPCM are nominal models with ordered slopes; fitting the nominal model to Likert data shows how ordered the categories are (c9 slide 16). Sources: Thissen & Steinberg (1986), doi:10.1007/bf02295596; Nalbandyan, Gilbert, Franco & Domingue, PsyArXiv, doi:10.31234/osf.io/zbv8f (preprint, v6).

**Verdict (Claude's reading; for Ben to confirm):** keep the chosen option and read the option curves before scoring 0/1. On the Borges exam they show items with a second defensible answer that a 0/1 analysis shows only as a low slope.

References checked on Crossref (09-24).

## Picks up

- The PCM, GPCM and category response functions (from `polytomous`).
- The 3PL's lower asymptote and RMET's weak guessing (median $c$ = 0.05 with four options) (from `1pl-to-4pl`). Deliberate reuse of RMET, recorded under `reuses:`: the guessing puzzle there becomes a distractor question here.
- Guessing as a property of people (from `guessing-priors`): the MC model's "don't know" class is one version.
- Item and test information (from `information`).
- Brief Recall (E2; restated, not a thread): plausible distractors as an item-writing rule, from `instrument-building`.

## Promises / leaves open

- Distractor-level DIF → unpaid (dif comes earlier; Suh & Bolt, 2011, is the pointer).
- Pattern scoring with the nominal model for reported scores, and the fairness of crediting wrong answers → unpaid (problem 6).
- The ordinal–nominal continuum across the IRW as a deep dive → unpaid (a #4 candidate, citing Nalbandyan et al.).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `wilmer-rmet-normative-data-set-2022` | main example | RMET (Baron-Cohen et al., 2001, doi:10.1111/1469-7610.00715; Kim et al., 2024, doi:10.3758/s13428-023-02323-x): 36 items, four emotion words each; nominal model on 4,000. Test information at θ = −2 is 6.5 (nominal) vs. 4.0 (2PL), equal from 0 up. 27 of 108 distractors peak inside [−3, 3]. "Irritated" for "accusing" (item 14) rises from 0.04 to 0.21 across θ. The low asymptotes don't mean nobody guesses; wrong answers here are rarely random. | `1pl-to-4pl` (recorded under `reuses:`) |
| `borges_brazil_residency_2024_pbt` | contrast | Medical residency exam (Borges et al., 2024, doi:10.3352/jeehp.2024.21.32; CC0): 1,914 complete candidates × 100 items, A–D. Distractors add more low-θ information than on RMET (19 vs. 9.1 at θ = −2). 19 items have item-rest r < 0.1; on item 21 option C rises from 0.03 to 0.73 while the key falls. Gently: a fact about a handful of items (or a key worth checking with the authors), not the exam. | — |
| simulated nominal data | sanity | Known option parameters recovered; on RMET the keyed-option curve matches the 2PL's. | — |

Borges handling: drop the 133 blanks (80 candidates), take the key from the IRW's `resp`, align the nominal θ's sign with the sum score (r = 0.96). RMET items are photographs the IRW doesn't have: name the four words (published in Baron-Cohen et al., 2001), no images (digest F33). Problem tables: `himmelstein-berlin_numeracy-2025`, `borges_brazil_residency_2024_cbt`.

## Widget / simulation / problem ideas

**Widgets**
- Option curves: slope and intercept sliders; tie two slopes and they become one ordinal category (ideas 1, 5).
- Which is the key? A mystery item's curves (Borges item 21); pick, then reveal (idea 2).
- Information with and without distractors, for one item (idea 3).
- Don't-know class vs. the 3PL's flat floor (idea 4).

**Predict-then-check:** will knowing which wrong word someone chose add information for able respondents, less able ones, or both? (6.5 vs. 4.0 at θ = −2; equal from 0 up.)

**Simulate:** nominal responses for 20 four-option items with one informative distractor each; fit the 2PL and the nominal model; compare θ recovery at low θ. Seconds at n = 1,000.

**Problems**
1. Derivation: with option slopes $a_k = a \cdot k$ the nominal model is the GPCM.
2. Real data with a twist: the nominal model on five-category Likert items (e.g. `bfi_goldberg_1992_conscientiousness`). Are the categories as ordered as assumed?
3. Judgment: an RMET distractor draws 20% of the ablest respondents. Rewrite, keep or rescore?
4. Design: four options where each distractor diagnoses a different misconception. How would you check it?
5. Real data: Borges paper vs. computer. Do distractors behave the same?
6. Challenge (open): should a test give partial credit for a "good" wrong answer? What about respondents who skip?

## Go deeper

- **Why distractor information sits below the item's difficulty.** Nominal information is the variance of the option slopes given θ; above the difficulty it collapses to the 2PL's. Why: `information`, `polytomous`, `item-banks-cat`. Half a page.

## Open questions

- The verdict above is Claude's reading of the Borges result (voice rule A). *Default:* use it unless you'd put it differently.
