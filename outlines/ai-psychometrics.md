<!-- Outlined 2026-09-24 from EDUC 252 c10 (slides 1–41) and c10/model.R. Deep dive #25 is homed here: explanatory-irt teaches item features with human-coded covariates and hands "can text alone predict difficulty?" forward. explanatory-irt is now a prerequisite (digest E1). Tidied 09-24 (#62). -->

# AI and psychometrics (`ai-psychometrics`)

Module: beyond · Prereqs: 1pl-to-4pl, explanatory-irt · Extension · Status: outline

## Core ideas

1. **Two intersections.** AI used to measure people (scoring, item writing, difficulty prediction, simulated respondents), and psychometrics used to measure AI (benchmark questions as items, models as respondents). The lesson is mostly the first; the second gets a paragraph, a pointer and a problem, since no IRW table holds model-by-question responses yet (digest E5). Source: Martínez-Plumed, Prudêncio, Martínez-Usó & Hernández-Orallo (2019), doi:10.1016/j.artint.2018.09.004.
2. **Automated scoring is an agreement problem.** Machine scores are judged by agreement with human raters, usually quadratic weighted kappa (QWK), built from the contingency table (slides 8–15); machine–human agreement (about 0.8 in a recent meta-analysis) against human–human (0.60 in one essay set). Scores can carry signals we don't want, such as household income. Widget-only: no IRW table pairs human and machine scores (digest F13). *(major)* Sources: Cohen (1968), doi:10.1037/h0026256; Attali & Burstein (2006), *JTLA* 4(3) (no DOI; checked on the journal's site); Alvero et al. (2021), doi:10.1126/sciadv.abi9031; the slide-7 meta-analysis (IEEE 11062635; *unverified*).
3. **Can the text of an item predict its difficulty?** The LLTM from `explanatory-irt`, now with language-model features. Verdict (Ben's, slides 35–36): embeddings don't beat human annotations, and accuracy metrics are the wrong yardstick; I'd rather know how many respondents a prediction is worth, since skipping the field test is the real prize. *(major)* Sources: Gorin & Embretson (2006), doi:10.1177/0146621606288554; Stenner et al. (2006), *J. Applied Measurement* 7(3) (*unverified*); Kapoor, Truong, Haber, Ruiz-Primo & Domingue (2025), arXiv:2502.20663; Benedetto et al. (2023), doi:10.1145/3556538; Domingue et al. (2024), doi:10.1007/s11336-024-09977-2.
4. **Language models as simulated respondents.** Prompt a model to answer as a student at a given level and use the responses to estimate difficulty or study misconceptions; the lesson asks whether idea 3's simpler route gets the same difficulty for less. Sources: Argyle et al. (2023), doi:10.1017/pan.2023.2; Liu, Bhandari & Pardos (2025), doi:10.1111/bjet.13570; Scarlatos et al. (2025), arXiv:2507.05129.
5. **Automatic item generation, and checking what it makes.** Language models now write items; the psychometric questions don't change: do they measure the construct, how hard are they, do the distractors work? *(major)* Sources: Embretson (1999), doi:10.1007/BF02294564; Gierl & Haladyna (2012), doi:10.4324/9780203803912; Russell-Lasalandra, Christensen & Golino (2024), AI-GENIE (IRW biblio); Haladyna & Downing (1993), doi:10.1177/0013164493053004013.

Articles checked on Crossref (09-24); arXiv preprints on arXiv. Claude's to-do before drafting (digest D): the IEEE meta-analysis, Stenner et al. (2006), and the source of slide 25's "r = 0.62, Embretson & Daniel"; each stays *unverified* and unquoted until found.

## Picks up

- The 2PL: $b$ and $a$ (from `1pl-to-4pl`).
- The LLTM and random item effects; deep dive #25's question handed forward (from `explanatory-irt`).
- Item text in the IRW and its provenance (from `irw-data`; #63).
- A construct map orders items before any data (from `constructs`, `himmelstein-number_series-2025`); used as the sanity check.
- Brief Recalls (E2; restated, not threads): wording direction from `instrument-building`; the IMV from `fit-prediction`; item banks from `item-banks-cat`.

## Promises / leaves open

- Rater effects and many-facet models for human and machine raters → unpaid.
- Psychometrics of AI benchmarks → unpaid (problem 6).
- Pointers, not hooks (those lessons come earlier or alongside): distractor analysis with the nominal model; differential functioning of machine scores (Alvero et al.); adaptive testing with predicted difficulties.
- Difficulties predicted for new, uncalibrated items → `item-banks-cat` (an "if you've done" Recall there, E2).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `himmelstein-impossible_question-2025` | main example (deep-dive miniature) | Forecasting Proficiency Test, general knowledge (Himmelstein et al., 2025; CC BY 4.0): 90 two-choice items, 1,188 people. Word count barely predicts difficulty (r = −0.11; −0.28 among the 72 answerable items). What the text *says* does: the 18 "impossible" questions ("What's the habitat of a Rojixon bird?") are answered correctly 0.33 of the time vs. 0.71, and that flag explains 27% of the variance. | — |
| `gpt4mcq_young_2025` | contrast (AI-written cognitive items) | 20 GPT-4-written items (Young et al., 2025; CC BY 4.0), 190 students. Alpha 0.89, but easy (median 0.925; $b$ near −1.6). 80% of distractors are chosen by under 5%; the key is the longest option in 12 of 20. | — |
| `genpsych_russell_2024_gpt4o` | contrast (AI-written personality items) | 35 GPT-4o Big Five items (CC0), 897 complete. A five-factor EFA puts every item on its trait (mean r 0.44 within, 0.04 between). Still flagged: all items positively worded (no handle on acquiescence), and the neuroticism items are near-synonyms (alpha 0.93). | — |
| `himmelstein-number_series-2025` | sanity | The pipeline reproduces the construct-map order found in `constructs` (NS_2 at 0.84, NS_6 at 0.02). | `constructs` |

Table citations come from IRW biblio. All three main tables are CC BY 4.0 or CC0, so their items are shown in full, citing the authors and naming the model that wrote the AI items (digest E7, A5). Before quoting many FPT questions, check whether they were adapted from older pools (digest D). Item-text alignment checked for all three (keyed option modal; items load on the traits their text names).

**Deep dive #25 (Across the IRW).** `irw_filter(construct_type = "Cognitive/educational", n_categories = 2, n_participants = c(200, Inf), primary_language_s_ = "eng")` ∩ `irw_list_itemtext_tables()`: 33 tables today. Per table, the within-table correlation of word count and mean word length with logit proportion correct, then the distribution across tables (pooling confounds length with dataset). No language-model feature (Ben, 09-24: punted). Pilot: `himmelstein-number_series-2025`, `preschool_sel_box`. Vignette: <https://itemresponsewarehouse.org/vignettes/item_text_difficulty.html>.

## Widget / simulation / problem ideas

**Widgets**
- QWK by hand: a 4 × 4 table of two raters' scores; kappa, QWK and exact agreement update (idea 2).
- What a difficulty prediction is worth: prediction error SD σ against calibrating on $n$ respondents (idea 3).
- Simulated respondents: a simulator with noise and bias; implied difficulties against the truth (idea 4).
- Distractor use: one functioning and two dead distractors (idea 5).

**Predict-then-check:** how strongly does word count predict difficulty in the general-knowledge test? (r = −0.11, −0.28 among answerable items, against 27% for the impossible-question flag.)

**Simulate:** difficulties from two text features plus noise; predict them with a train/test split of items; convert the error to an equivalent calibration sample. Seconds.

**Problems**
1. Derivation: QWK = 1 − weighted observed / weighted expected disagreement; with two categories, Cohen's kappa.
2. Real data with a twist: drop the impossible questions and redo the word-count analysis; try a feature of your own.
3. Real data: a 2PL for `gpt4mcq_young_2025`. Where is it informative, and what would you ask the item writer to change?
4. Judgment: a vendor's scorer agrees with humans at QWK 0.80. What else do you need before replacing a second rater?
5. Design: a study of whether LLM-predicted difficulties can replace a field test.
6. Challenge (open): models as respondents. What does "ability" mean for a model, and which IRT assumption is most likely to fail?

## Go deeper

- **QWK and the intraclass correlation.** Under quadratic weights and equal marginals QWK approximates the consistency ICC (conditions to verify). Why: `ctt-reliability`. Half a page.

## Open questions

None. (Verdict, item display, data gaps and prerequisites are settled: slides 35–36, E7, E5 and F13, E1.)
