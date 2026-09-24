<!-- Outlined 2026-09-24 from EDUC 252 slides c10 (slides 1–41) and c10/model.R. Deep dive #25 is homed here (agreed with course-beyond-1: explanatory-irt teaches item features with human-coded covariates and hands "can text alone predict difficulty?" forward). -->

# AI and psychometrics (`ai-psychometrics`)

Module: beyond · Prereqs: 1pl-to-4pl · Optional · Status: outline

## Core ideas

1. **Two intersections.** AI used to measure people (scoring, item writing, difficulty prediction, simulated respondents), and psychometrics used to measure AI (benchmark questions are items; models are respondents). The lesson is mostly about the first; the second gets a section and a pointer. Sources: Martínez-Plumed, Prudêncio, Martínez-Usó & Hernández-Orallo (2019), IRT for machine-learning evaluation, doi:10.1016/j.artint.2018.09.004.
2. **Automated scoring is an agreement problem.** Machine scores are judged by their agreement with human raters, usually quadratic weighted kappa. Build QWK from the contingency table (slides 8–15); compare machine–human agreement (about 0.8 in a recent meta-analysis) with human–human agreement (0.60 in one essay set). Scores also carry signals we may not want, such as household income. *(major)* Sources: Cohen (1968), doi:10.1037/h0026256; Attali & Burstein (2006), "Automated essay scoring with e-rater V.2", *Journal of Technology, Learning, and Assessment* 4(3) (no DOI; checked on the journal's site); Kumar & Boulanger (2021), doi:10.1007/s40593-020-00211-5; Alvero et al. (2021), doi:10.1126/sciadv.abi9031; the meta-analysis on slide 7 (IEEE document 11062635; **not yet verified**).
3. **Can the text of an item predict its difficulty?** An old idea (the LLTM, cognitive item modelling, Lexile's word frequency and sentence length), now tried with language-model embeddings. My verdict from the state-assessment work: embeddings don't beat human annotations, and accuracy metrics are the wrong yardstick; I'd rather know how many respondents a prediction is worth, since not having to field-test items is the real prize (slides 35–36). *(major)* Sources: Fischer (1973), doi:10.1016/0001-6918(73)90003-6; Gorin & Embretson (2006), doi:10.1177/0146621606288554; Stenner et al. (2006), "How accurate are Lexile text measures?", *Journal of Applied Measurement* 7(3) (no DOI; **to verify**); Kapoor, Truong, Haber, Ruiz-Primo & Domingue (2025), arXiv:2502.20663; Marinho et al. (2023), ENEM, doi:10.1145/3576050.3576139; Benedetto et al. (2023), survey, doi:10.1145/3556538; Domingue et al. (2024, 2025) on the IMV, doi:10.1007/s11336-024-09977-2, doi:10.1371/journal.pone.0316491.
4. **Language models as simulated respondents.** Prompt a model to answer as a student at a given level; use the simulated responses to study misconceptions, train teachers, or estimate item difficulty. Worth asking whether a simpler route (item 3) gets the same difficulty for less. Sources: Argyle et al. (2023), doi:10.1017/pan.2023.2; Liu, Bhandari & Pardos (2025), doi:10.1111/bjet.13570; Scarlatos et al. (2025), SMART, arXiv:2507.05129; Markel, Opferman, Landay & Piech (2023), doi:10.1145/3573051.3593393; Hu et al. (2025), doi:10.1038/s41539-025-00300-x.
5. **Automatic item generation, and checking what it makes.** If we know what makes items hard, we can generate them (Embretson's generative item models). Language models now write items directly; the psychometric questions don't change: do they measure the construct, how hard are they, do the distractors work? *(major)* Sources: Embretson (1999), doi:10.1007/BF02294564; Gierl & Haladyna (Eds.) (2012), *Automatic Item Generation* (Routledge), doi:10.4324/9780203803912; Zelikman et al. (2023), sentence reading efficiency, doi:10.18653/v1/2023.emnlp-main.135; Russell-Lasalandra, Christensen & Golino (2024), AI-GENIE (from IRW biblio); Haladyna & Downing (1993) on functioning distractors, doi:10.1177/0013164493053004013.

Articles checked on Crossref (09-24); arXiv preprints checked on arXiv. Unverified: the IEEE meta-analysis and Stenner et al. (2006); the slide-25 correlation (r = 0.62, "Embretson & Daniel") needs its source pinned down before it is quoted.

## Picks up

- The 2PL: difficulty $b$ and discrimination $a$ (from `1pl-to-4pl`).
- Item features predict difficulty (the LLTM, random item effects); "can text alone predict difficulty?" is handed forward (from `explanatory-irt`). Not an ancestor of this lesson (the prerequisite is `1pl-to-4pl`), so the LLTM gets a one-paragraph restatement.
- Item text in the IRW, with its provenance caveats (from `irw-data`; #63).
- Item text predicts difficulty; wording direction as a second dimension (from `instrument-building`; not an ancestor, so restated).
- A construct map orders items before any data (from `constructs`, `himmelstein-number_series-2025`); used as the sanity check below.
- The IMV and out-of-sample comparison (from `fit-prediction`; restated briefly, not an ancestor).

## Promises / leaves open

- Distractor analysis with the nominal response model → `nominal` (the AI-written quiz is a natural example; mention and link).
- Rater effects and many-facet models for human and machine raters → unpaid.
- Psychometrics of AI benchmarks (models as respondents, benchmark questions as items) → unpaid; no IRW table holds model-by-question responses yet (see Open questions).
- Differential functioning of machine scores across groups → `dif` (mention; Alvero et al.).
- Adaptive testing with predicted difficulties for new items → `item-banks-cat` (mention).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `himmelstein-impossible_question-2025` | main example (deep-dive miniature) | Forecasting Proficiency Test, general knowledge (Himmelstein et al., 2025; CC BY 4.0): 90 two-choice items, 1,188 people in the first wave. Word count barely predicts difficulty (r = −0.11 with logit proportion correct; −0.28 among the 72 answerable items). What the text *says* does: the 18 "impossible" questions, recognisable from invented names ("What's the habitat of a Rojixon bird?"), are answered correctly (by opting out) 0.33 of the time vs. 0.71 for the rest, and that one feature explains 27% of the variance. Item text lines up with the data: the easiest items are "The number of weeks in a year is approximately" and a synonym for "Quick" (both 1.00). | — |
| `gpt4mcq_young_2025` | contrast (AI-written cognitive items) | Twenty ChatGPT-4-written multiple-choice items on a textbook reading (Young et al., 2025; CC BY 4.0), 190 students. Reliability is fine (alpha 0.89), but the items are easy: median proportion correct 0.925, 2PL $b$ mostly near −1.6, so the test measures well only well below average. 80% of distractors are chosen by fewer than 5% of students (Haladyna & Downing's non-functioning criterion), and the correct option is the longest in 12 of 20 items. One item splits the class (0.50 correct, item-rest r 0.24): 86 of 190 students chose the distractor "Received social support has universally positive effects". | — |
| `genpsych_russell_2024_gpt4o` | contrast (AI-written personality items) | AI-GENIE (Russell-Lasalandra et al., 2024; CC0): 35 GPT-4o-written Big Five items answered by 999 people (897 complete). A five-factor EFA puts all 35 items on their intended trait; mean inter-item r is 0.44 within a trait and 0.04 between. Two things a psychometrician would still flag: every item is positively worded (no way to separate acquiescence; the `instrument-building` thread), and the eight neuroticism items are near-synonyms (alpha 0.93). | — |
| `himmelstein-number_series-2025` | sanity (not in the lesson) | The text-to-difficulty pipeline should reproduce the construct-map ordering found in `constructs` (NS_2 at 0.84 correct, NS_6 at 0.02). | `constructs` |

Table citations come from IRW biblio. Reuse rights (#63, Ben 09-24: show full text publicly only for openly licensed instruments): all three main tables are CC BY 4.0 or CC0. Some general-knowledge questions may have been adapted from older item pools; check the FPT documentation before quoting many of them.

**Item text alignment (#63).** Checked for all three: the Himmelstein easiest/hardest items make sense (above); in `gpt4mcq_young_2025` the keyed option is the modal response for every item; in `genpsych_russell_2024_gpt4o` the items load on the traits their text names, in blocks (1–7 A, 8–15 C, 16–20 E, 21–28 N, 29–35 O).

**Deep dive #25 (Across the IRW).** Corpus: `irw_filter(construct_type = "Cognitive/educational", n_categories = 2, n_participants = c(200, Inf), primary_language_s_ = "eng")` ∩ `irw_list_itemtext_tables()`: 33 tables today (the vignette found 18 in May, 15 with usable text). Thresholds: dichotomous so proportion correct is the outcome; 200 respondents so item p-values are stable; English so text features are comparable. Per table: the within-table correlation of each text feature with logit proportion correct, then the distribution across tables (the vignette's design: pooling across tables confounds item length with dataset). Features: word count and mean word length (as in the vignette), plus one language-model feature (see Open questions). Pilot known-good tables: `himmelstein-number_series-2025` and `preschool_sel_box` (vignette r = −0.63 for word count). Vignette: <https://itemresponsewarehouse.org/vignettes/item_text_difficulty.html>.

Passed over: `genpsych_russell_2024_gpt3_5` and the other AI-GENIE tables (same design, one is enough), `trivia_fastrich_2017` (question text is in the CSV itself, but wave 1 is scored 0 by design and wave 2 measures memory for the answer, not knowledge), `zhu_2026_llm_meteorology_performance` (ratings of LLMs, a survey not a test).

## Widget / simulation / problem ideas

**Widgets**
- QWK by hand: a 4 × 4 table of two raters' scores; click cells to move counts; kappa, QWK and exact agreement update, and the quadratic weights are shown (idea 2).
- What a difficulty prediction is worth: predicted $b$ with error SD σ vs. calibrating on $n$ respondents; the $n$ that gives the same error (Ben's "effective sample size" point, idea 3).
- Simulated respondents: an LLM-like simulator whose "ability" prompt maps to θ with noise and a bias; compare its implied item difficulties with the truth as the noise changes (idea 4).
- Distractor use: option-choice curves for an item with one functioning and two dead distractors (idea 5; points ahead to `nominal`).

**Predict-then-check:** "In the general-knowledge test, how strongly does word count predict difficulty?" Answered by r = −0.11 (−0.28 among answerable items), against 27% of variance for the impossible-question flag.

**Simulate:** generate item difficulties from two text features plus noise; "predict" them from the features with a train/test split of items; convert the prediction error into an equivalent calibration sample size. Seconds in the browser.

**Problems**
1. Derivation: show that QWK equals 1 − (weighted observed disagreement)/(weighted expected disagreement), and that with two categories it reduces to Cohen's kappa.
2. Real data with a twist: in `himmelstein-impossible_question-2025`, drop the impossible questions and redo the word-count analysis. Then try one feature of your own (a number in the question? "approximately"?).
3. Real data: fit a 2PL to `gpt4mcq_young_2025`. Where on θ is the test informative, and what would you ask the item writer (human or not) to change?
4. Judgment: a vendor says their essay scorer agrees with humans at QWK 0.80, above human–human agreement. What else do you need to know before replacing a second human rater?
5. Design: plan a study to decide whether LLM-predicted difficulties can replace a field test for a new item bank. What sample of items and respondents, and what yardstick?
6. Challenge (open): benchmark questions are items and language models are respondents. What does "ability" mean for a model, and what assumption of IRT is most likely to fail?

## Go deeper

- **QWK and the intraclass correlation.** Under quadratic weights and equal marginals, QWK approximates the ICC for consistency, which ties it to the reliability ideas in `ctt-reliability` and `g-theory`. Length: half a page. (Verify the exact conditions before drafting.)

## Open questions

- Deep dive #25: add a language-model feature (an embedding, or a model's direct difficulty rating) to `compute.R`? That needs an API key and a fixed model version, and the outputs would be committed with the results. Which model, and is the cost acceptable?
- The slide-7 meta-analysis (IEEE 11062635) and Stenner et al. (2006) aren't on Crossref; can Ben confirm the references, or should the lesson cite other sources?
- No IRW table holds language-model responses to benchmark questions, so idea 1's second half has no data. Add one (e.g. a public leaderboard's per-question results) to the IRW?
- The automated-scoring section has no table: no IRW table pairs human and machine scores. Keep it widget-only, or look for one (ASAP-style data)?
- Item text is shown in full for all three main tables (CC BY 4.0 / CC0) per Ben's 09-24 rule. Are AI-generated items treated like any other openly licensed text?
- Prerequisites: the lesson leans on `explanatory-irt` (the LLTM, and the #25 hand-off) and `instrument-building` (item text, wording direction), but its only prerequisite is `1pl-to-4pl`. Add `explanatory-irt` as a prerequisite, or restate the LLTM in a paragraph (the current plan)?
