<!-- Outlined 2026-09-24 from EDUC 252 c9 (slides 17–23), PS9#2, c9/mrot.R and ps9/shots.R. Tidied 09-24 (#62). -->

# Trials as items: tasks, shots, and rotations (`trials`)

Module: beyond · Prereqs: explanatory-irt · Extension · Status: outline

## Core ideas

1. **In a task, the "item" is a condition met many times.** What counts as an item (stimulus, condition, trial) is a modelling choice, and task analyses often ignore person or item effects (slide 19). *(major)* Sources: De Boeck & Wilson (2004), doi:10.1007/978-1-4757-3990-9; Rouder & Haaf (2019), doi:10.3758/s13423-018-1558-y.
2. **Replace item parameters with stimulus features.** When stimuli vary continuously (angle, brightness, coherence), difficulty is a function of the feature: the LLTM from `explanatory-irt` with one or two parameters. Check the shape and compare out of sample. *(major)* Sources: Fischer (1973), doi:10.1016/0001-6918(73)90003-6; Wichmann & Hill (2001), doi:10.3758/BF03194544; Shepard & Metzler (1971), doi:10.1126/science.171.3972.701; Domingue et al. (2024), the IMV, doi:10.1007/s11336-024-09977-2.
3. **The question is often about the stimulus, not the person.** Slide 19: does changing the stimulus change performance for everyone? A task can have a large, universal effect and almost no individual differences to measure: the reliability paradox, in full here. *(major)* Sources: Hedge, Powell & Sumner (2018), doi:10.3758/s13428-017-0935-1; Stroop (1935), doi:10.1037/h0054651.
4. **When respondents choose their trials, ability absorbs the choice.** Shooters pick their shots; raw accuracy mixes skill with selection (PS9#2). Taught with a widget and a problem: the shot data (Samangy, GitHub) aren't in the IRW, and no data are added for now (digest E5). Source: Gilovich, Vallone & Tversky (1985), doi:10.1016/0010-0285(85)90010-6.

Many trials also bring practice, fatigue and sequence effects, and a choice of scoring accuracy, time or both (slide 23); these go in problems. `lme4`: Bates et al. (2015), doi:10.18637/jss.v067.i01.

**Verdict (Claude's reading; for Ben to confirm):** before using a task to measure individual differences, look at where the variance lives; a large, reliable stimulus effect is not evidence of a good measure of people.

Articles checked on Crossref (09-24). Named, not used: Nelson (2016), doi:10.1088/1478-3975/13/2/025001 (slide 20); the LEVANTE shape-rotation task (slide 22; not in the IRW, and `mentalrotation_wolf_2024` stands in, digest E5).

## Picks up

- The LLTM, the random-item LLTM, `glmer` in long data; hearts and flowers as stimulus × context (from `explanatory-irt`; a Recall of `imps2025_hf`, no reuse).
- Conditions repeated as trials in `rr98_accuracy` (from `irw-data`).
- Brief Recalls (E2; restated, not threads): crossed random effects in `item-estimation`; local dependence in `dimensionality`; the IMV in `fit-prediction`; the Stroop between/within point in `validity-causal`.

## Promises / leaves open

- Learning across trials as change in θ → unpaid (dynamic IRT).
- Adaptive testing with task banks (slide 23): a mention; item-banks-cat comes earlier, so no hook.
- Response times on the same trials: response-time and rt-process-models don't follow this lesson, so they are linked, not hooks.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `rr98_accuracy` | main example; also its own sanity check | Brightness discrimination (Ratcliff & Rouder, 1998, doi:10.1111/1467-9280.00067): 33 levels, three observers × about ten sessions (the IRW's 30 "respondents"). Accuracy 0.94 at the extremes, 0.50 in the middle, symmetric as published. Distance from the middle does nearly the work of 33 parameters (AIC 12,946 vs. 12,923); session SD 0.04 logits, observer SD 0 (accuracies 0.72–0.73). No person to measure. | `irw-data` (recorded under `reuses:`) |
| `mentalrotation_wolf_2024` | contrast (mrot.R) | 3-D printed Shepard–Metzler shapes (Wolf & Larsen, 2024, doi:10.5334/jopd.99): 37 × 32, angles 0–150°. Accuracy falls a little (0.77 → 0.70; −0.16 logits per 50°). Out of sample: angle IMV 0.0019, one parameter per angle 0.0014, random item 0.0045. Shapes matter more than angle; the classic angle effect is in RT, which this table lacks. | — |
| `enkavi_2019_stroop` | failure case (individual differences) | Enkavi et al. (2019), doi:10.1073/pnas.1818430116: 522 people, 150 retested. Incongruent is slower (0.79 vs. 0.67 s) for all 150, yet the person Stroop effect has retest r = 0.43 vs. 0.61 for mean RT; random-slope SD 0.06 vs. 0.14 for the intercept. | — |

Table citations come from IRW biblio. Passed over: `motion` (in `rt-process-models`), `dd_rotation`, `hmcdm_spatialreasoning`, `robison_2026_retesting_*`, `twod_rotation_mather2023`.

## Widget / simulation / problem ideas

**Widgets**
- Stimulus → difficulty: a psychometric function against 33 per-condition points, with the parameter count (idea 2).
- Where the variance lives: stimulus effect and person SD; the retest correlation of each person's effect by number of trials (idea 3).
- Choosing shots: equally skilled shooters with different shot mixes; adjusting for distance restores the tie (idea 4).

**Predict-then-check:** three observers, 33 levels, thousands of trials. How much do the observers differ? (Session SD 0.04, observer SD 0; 0.72–0.73.)

**Simulate:** a person × angle model with random intercepts and slopes; fit per-angle, linear and random-slope models with `glmer`; compare with the IMV. Shrink the slope SD and watch slope reliability collapse while the mean effect stays clear. 50 × 40, seconds.

**Problems**
1. Derivation: the reliability of an incongruent-minus-congruent difference; why a large mean effect doesn't help.
2. Real data with a twist (mrot.R): add angle², then a shape effect. Which predicts better out of sample?
3. Real data: in `rr98_accuracy`, observer vs. observer-session as the person. Which is right for which question?
4. Judgment (PS9#2): two shooters take equal numbers of threes; one shoots mostly late in games. Compare their percentages?
5. Design: a mental-rotation measure of individual differences: angles, trials per angle, accuracy or time?
6. Challenge (open): a model where the choice of trial depends on ability. What identifies skill separately from choice?

## Go deeper

- **The reliability of a difference.** Why robust experimental effects give unreliable individual differences (Hedge et al., 2018). Why: `ctt-reliability`, `response-time`. Half a page.

## Open questions

- The verdict above is Claude's reading of the Stroop and rr98 results (voice rule A). *Default:* use it unless you'd put it differently.
