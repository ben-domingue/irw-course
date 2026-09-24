<!-- Outlined 2026-09-24 from EDUC 252 slides c9 (slides 15–16: the nominal response model, "which response do you think is correct?", "is there a sharp distinction between nominal and ordinal?", linking Nalbandyan et al.) and the code c9/nominal.R (written for `preference_inventory`, now a nominal-source table without a tokenless CSV; replaced here, per #15 and #80). No problem set covers it. -->

# Nominal response and multiple-choice models (`nominal`)

Module: beyond · Prereqs: polytomous, guessing-priors · Optional · Status: outline

## Core ideas

1. **Scoring 0/1 throws away which wrong answer was chosen.** A multiple-choice response is a choice among options, not a right/wrong event. The nominal response model gives every option its own slope and intercept, so the model, not the scorer, says how the options order along θ. *(major)* Sources: Bock (1972), doi:10.1007/bf02291411; Thissen, Cai & Bock (2010), in *Handbook of polytomous item response theory models*, doi:10.4324/9780203861264.ch3; `mirt`: Chalmers (2012), doi:10.18637/jss.v048.i06.
2. **Reading option curves.** The keyed option should rise with θ; a good distractor falls; a distractor that peaks in the middle attracts partial knowledge; a distractor that rises at the top is a second right answer or a problem with the key (c9 slide 15: "Which response do you think is correct?"). *(major)* Sources: Thissen, Steinberg & Fitzpatrick (1989), doi:10.1111/j.1745-3984.1989.tb00326.x; Gierl, Bulut, Guo & Zhang (2017), doi:10.3102/0034654317726529; Haladyna, Downing & Rodriguez (2002), doi:10.1207/s15324818ame1503_5.
3. **Distractors carry information, mostly at low θ.** Among respondents who get an item wrong, which distractor they chose says something about θ, so the nominal model's information exceeds the 2PL's below the item's difficulty and matches it above. *(major)* Sources: Bock (1972); Thissen et al. (1989).
4. **The multiple-choice model and guessing.** Thissen and Steinberg's model adds a latent "don't know" category whose respondents spread across the options: a different account of guessing from the 3PL's lower asymptote. The nested logit model splits the response into "correct or not", then "which distractor". Sources: Thissen & Steinberg (1984), doi:10.1007/bf02302588; Suh & Bolt (2010), doi:10.1007/s11336-010-9163-7; Samejima (1979), doi:10.21236/ada080350.
5. **Nominal and ordinal are ends of a continuum.** The partial credit and graded models are nominal models whose option slopes are ordered in advance; fitting the nominal model to Likert data shows how ordered the categories actually are, and the IRW varies a lot on this (c9 slide 16). Sources: Thissen & Steinberg (1986), doi:10.1007/bf02295596; Nalbandyan, Gilbert, Franco & Domingue (2024–2026), PsyArXiv, doi:10.31234/osf.io/zbv8f (preprint, latest version v6).

References checked on Crossref (09-24).

## Picks up

- The PCM and GPCM, category response functions, the nominal model's place among polytomous models (from `polytomous`; its promise "Nominal responses and unfolding → `unfolding-nominal`" is now split, and should point here for nominal responses).
- The 3PL's lower asymptote and the RMET's weak guessing (median $c$ = 0.05 with four options) (from `1pl-to-4pl`; `guessing-priors` for fixed guessing). Deliberate table reuse of RMET: the guessing puzzle there becomes a distractor question here.
- Guessing as a property of people rather than items (from `guessing-priors`, whose "guessing as a latent class of responders" is otherwise unpaid): the MC model's "don't know" class is one version of it.
- Plausible distractors as an item-writing rule; distractors carry information (from `instrument-building`; its promise → `nominal`).
- Item and test information (from `information`).

## Promises / leaves open

- Distractor-level DIF (a distractor that draws one group more than another) → `dif` (a Recall at most; Suh & Bolt, 2011, is the pointer). Otherwise unpaid.
- Scoring with the nominal model (pattern scoring that credits the "better" wrong answers) for reported scores → `score-meaning` (a Recall at most); fairness of crediting wrong answers → unpaid.
- The ordinal–nominal continuum across the IRW as a deep dive → unpaid (a candidate for #4's list, citing Nalbandyan et al.).
- Skipped options ("X" and blanks) as a node → `irtrees` (simulation only there).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `wilmer-rmet-normative-data-set-2022` | main example | Reading the Mind in the Eyes (Baron-Cohen et al., 2001, doi:10.1111/1469-7610.00715; normative data from Kim et al., 2024, doi:10.3758/s13428-023-02323-x): 36 items, four emotion words each, the chosen word kept in `resp_raw`; nominal model on 4,000 respondents. Distractors add information below the middle and none above: test information at θ = −2 is 6.5 (nominal) vs. 4.0 (2PL); at −1, 5.2 vs. 4.3; from 0 up they match (3.4, 2.0, 1.1). 27 of 108 distractors peak inside θ ∈ [−3, 3] rather than falling steadily. A few keep drawing able respondents: "irritated" for "accusing" (item 14) rises from 0.04 to 0.21 across θ; "incredulous" for "interested" (item 25) stays near 0.2. That is a gentle answer to `1pl-to-4pl`'s puzzle: the low lower asymptotes are not a sign that nobody guesses; wrong answers here are rarely random. | `1pl-to-4pl` (deliberate thread: guessing there, distractors here; record `reuses:`) |
| `borges_brazil_residency_2024_pbt` | contrast | Paper-based medical residency exam in Brazil (Borges et al., 2024, doi:10.3352/jeehp.2024.21.32; CC0): 1,994 candidates × 100 items, options A–D (plus 133 blanks), chosen option in `text`. A professional exam whose distractors are written only to be wrong. On the 1,914 candidates with an A–D answer to every item (overall proportion correct 0.60, items 0.11–0.98), the distractors add even more low-θ information than on RMET: 19 vs. 9.1 (2PL) at θ = −2, 16 vs. 11 at −1, equal from 0 up. 94 of 300 distractors peak inside θ ∈ [−3, 3]. And 19 of the 100 items have an item-rest correlation below 0.1; the option curves show why for several: on item 21 option C rises from 0.03 to 0.73 across θ while the keyed A falls, and item 32's A and item 65's B hold more than half the ablest candidates. These look like items with a second defensible answer (or a key worth checking with the exam's authors), which a 0/1 analysis would show only as a low slope. Gently: this is a fact about a handful of items, not the exam. | — |
| sanity: simulated nominal data | sanity | Data simulated from `mirt`'s nominal model with known option parameters are recovered (option order and slopes); and on RMET, the nominal model's keyed-option curve matches the 2PL curve for the same item. | — |

Borges data handling: the 133 blank options (X, _) are dropped (80 candidates with a blank are left out), so every item has four categories; the key is taken from the IRW's scored `resp`; the nominal θ's sign is arbitrary, so it is aligned with the sum score (correlation 0.96) before any curve is read. The first pilot, without those steps, gave curves that could not be read.

Other option-level tables for problems: `himmelstein-berlin_numeracy-2025` (4 items; tokenless CSV with `resp_raw`, item text in the IRW), and the `borges_brazil_residency_2024_cbt` twin of the contrast table (computer-based, same exam) for a mode comparison. `preference_inventory` (c9/nominal.R) is a nominal-source table without a landing page, so no tokenless CSV.

## Widget / simulation / problem ideas

**Widgets**
- Option curves: four options with slope and intercept sliders; make one option dominate at high θ and it becomes the key; tie two slopes and they become one ordinal category (ideas 1, 5).
- Which is the key? A mystery item's option curves (Borges item 21, or an RMET item); pick the key, then reveal (idea 2; c9 slide 15).
- Information with and without distractors: the 2PL and nominal information curves for one item, with a slider for how informative the distractors are (idea 3).
- Don't-know class: the MC model's share of guessers across θ, against the 3PL's flat floor (idea 4).

**Predict-then-check:** the RMET's four words per item: will knowing which wrong word someone chose add information for able respondents, less able ones, or both? Answered by the test-information comparison (6.5 vs. 4.0 at θ = −2; equal from θ = 0 up).

**Simulate:** Generate nominal responses for 20 four-option items with one informative distractor per item; fit the 2PL (after scoring) and the nominal model; compare θ recovery at low θ. Seconds in `mirt` at n = 1,000.

**Problems**
1. Derivation: show that the nominal model with option slopes $a_k = a \cdot k$ is the GPCM.
2. Real data with a twist: fit the nominal model to five-category Likert items (e.g. `bfi_goldberg_1992_conscientiousness`, used in `irtrees`, as a Recall). Are the categories as ordered as the scale assumes?
3. Judgment: an RMET distractor draws 20% of the most able respondents. Rewrite the item, keep it, or rescore it?
4. Design: write four options for a new item so that each distractor diagnoses a different misconception. How would you check the diagnosis in data?
5. Real data (`borges_brazil_residency_2024_pbt` vs. `_cbt`): do distractors behave the same on paper and on computer?
6. Challenge (open): should a test ever give partial credit for a "good" wrong answer? What would it do to fairness between respondents who guess and those who skip?

## Go deeper

- **Why distractor information sits below the item's difficulty.** Item information for the nominal model is the variance of the option slopes given θ; above the difficulty nearly everyone picks the key and the variance collapses to the 2PL's. Why: `information`, `polytomous`, `item-banks-cat`. Length: half a page.

## Open questions

- RMET returns from `1pl-to-4pl` as a deliberate thread (guessing there, distractors here). *Default:* keep it and record `reuses:`; the distractors are emotion words, which is what makes them worth reading (digest E4 already lists this reuse).
- RMET's photographs aren't in the IRW, and the lesson would name the four words per item without the images. *Default:* name the words (they are published in Baron-Cohen et al., 2001), no images.
- c9/nominal.R used `preference_inventory`, which now exists only in the nominal source (no tokenless CSV). *Default:* don't use it; RMET and Borges replace it (as in #15 and #80).
- The Thissen–Steinberg MC model isn't in `mirt` (it has the nominal model and nested logit models, `2PLNRM`/`3PLNRM`). *Default:* teach the MC model with a widget and fit the nested logit model as the software example.
