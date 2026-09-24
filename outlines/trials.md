<!-- Outlined 2026-09-24 from EDUC 252 slides c9 (slides 17–23), PS9#2, c9/mrot.R and ps9/shots.R. -->

# Trials as items: tasks, shots, and rotations (`trials`)

Module: beyond · Prereqs: explanatory-irt · Optional · Status: outline

## Core ideas

1. **In a task, the "item" is a condition, and people meet it many times.** Psychology's tasks repeat the same stimulus, or small variations of it, dozens or hundreds of times. What counts as an item (the exact stimulus, the condition, the trial) is a modelling choice, and often the models ignore person or item effects altogether (slide 19). *(major)* Sources: De Boeck & Wilson (2004), *Explanatory Item Response Models* (Springer), doi:10.1007/978-1-4757-3990-9; Rouder & Haaf (2019), doi:10.3758/s13423-018-1558-y.
2. **Replace item parameters with stimulus features.** When stimuli vary continuously (angle of rotation, brightness, motion coherence), difficulty is a function of the feature: the LLTM idea from `explanatory-irt`, with one or two parameters instead of one per condition. Check the function's shape (linear, quadratic, splines) and compare out of sample. *(major)* Sources: Fischer (1973), doi:10.1016/0001-6918(73)90003-6; Wichmann & Hill (2001) on the psychometric function, doi:10.3758/BF03194544; Shepard & Metzler (1971), doi:10.1126/science.171.3972.701; Domingue et al. (2024), the IMV, doi:10.1007/s11336-024-09977-2.
3. **The question is often about the stimulus, not the person.** Ben's framing (slide 19): the key question is usually whether changing the stimulus changes performance for everyone. A task can have a large, universal stimulus effect and almost no individual differences to measure. That is the reliability paradox. *(major)* Sources: Hedge, Powell & Sumner (2018), doi:10.3758/s13428-017-0935-1 (linked from slide 19); Stroop (1935), doi:10.1037/h0054651; Enkavi et al. (2019), from IRW biblio.
4. **When respondents choose their trials, ability estimates absorb the choice.** In basketball, shooters pick their shots. Ranking shooters by raw accuracy mixes skill with shot selection; trial features have to come out of the ability estimate (PS9#2). Sources: Gilovich, Vallone & Tversky (1985) for why shooting data are a classic, doi:10.1016/0010-0285(85)90010-6; the shot data (Samangy, NBA shots 2004–2024, GitHub; not in the IRW).
5. **Many trials per person bring their own questions.** Practice, fatigue and sequence effects (local dependence across trials), and the choice between modelling accuracy, time, or both (some adaptive tasks score time alone, slide 23). Sources: Bates, Mächler, Bolker & Walker (2015), `lme4`, doi:10.18637/jss.v067.i01.

Articles checked on Crossref (09-24). Two slide examples are named, not used: the single-photon threshold question (Nelson, 2016, doi:10.1088/1478-3975/13/2/025001; slide 20) and the LEVANTE shape-rotation task (slide 22; its data aren't in the IRW).

## Picks up

- Items as bundles of features; the LLTM; random item effects; persons × items crossed in `glmer` (from `explanatory-irt`).
- Hearts and flowers, where the "item" is stimulus × context (from `explanatory-irt`, `imps2025_hf`). Recall only; no reuse.
- Items that are conditions repeated as trials; `rr98_accuracy`'s 33 conditions answered many times each (from `irw-data`).
- Crossed random effects (`glmer`) as an alternative estimator (from `item-estimation`).
- Local dependence in repeated trials (from `dimensionality`).
- Out-of-sample comparison and the IMV (from `fit-prediction`; not an ancestor via `explanatory-irt`, so restated briefly).

## Promises / leaves open

- Response time on the same trials → `response-time` (a sibling, not a prerequisite; linked).
- Process models for trial-level choices and times → `rt-process-models`.
- Adaptive testing with task item banks (slide 23) → `item-banks-cat` (mention only).
- Learning across trials as change in θ → unpaid (dynamic/longitudinal IRT).
- Reliability of difference scores, the reliability paradox as a CTT result → `ctt-reliability` / `validity-evidence` (course-bd pays it there briefly; this lesson gives the full treatment; `validity-causal` uses a Stroop table for Borsboom's between/within point).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `rr98_accuracy` | main example (deliberate thread from `irw-data`) | Brightness discrimination (Ratcliff & Rouder, 1998): 33 brightness levels, but only three observers, each in about ten sessions; the IRW's 30 "respondents" are observer-sessions. Accuracy runs from 0.94 at the extremes to 0.50 in the middle. One stimulus feature (distance from the middle) does nearly the work of 33 item parameters (AIC 12,946 vs. 12,923), and people barely differ: session SD 0.04 logits, observer SD 0, accuracies 0.72, 0.72, 0.73. The stimulus is everything; there is no person to measure. No sequential dependence (previous trial's accuracy: −0.07, p = 0.15). | `irw-data` (record under `reuses:`); sanity table in `response-time`, `rt-process-models` |
| `mentalrotation_wolf_2024` | contrast (the mrot.R analysis) | Shepard–Metzler shapes, 3-D printed (Wolf & Larsen, 2024): 37 people, 32 trials each, angles 0–150°. Accuracy falls a little with angle (0.77, 0.75, 0.68, 0.70), −0.16 logits per 50°. Angle explains about 18% of the item variance (item SD 0.40 → 0.36); out of sample the angle model gains IMV 0.0019 over person-only, one parameter per angle 0.0014, a random item effect 0.0045. Here the shapes matter more than the angle, and the classic angle effect lives in RT, which this table doesn't have. | — |
| `enkavi_2019_stroop` | failure case (for individual differences) | Colour-word Stroop (Enkavi et al., 2019): 522 people, about 96 trials each at baseline; 150 retested. Incongruent trials are slower (0.79 vs. 0.67 s) and less accurate (0.94 vs. 0.98), and the effect is positive for all 150 retested people. Yet the person-level Stroop effect has retest r = 0.43, against 0.61 for mean RT; in a random-slope model its SD is 0.06 vs. 0.14 for the intercept (log RT). A universal effect makes a poor measure of individual differences. | — |

**Sanity table:** `rr98_accuracy` doubles as its own sanity check: the psychometric function should be symmetric around the middle brightness and steepest there (published in Ratcliff & Rouder, 1998). A side term (bright vs. dark half) adds almost nothing (0.10 logits).

Sources: Ratcliff & Rouder (1998), doi:10.1111/1467-9280.00067; Wolf & Larsen (2024), doi:10.5334/jopd.99; Enkavi et al. (2019), doi:10.1073/pnas.1818430116. Table citations come from IRW biblio.

Passed over: `motion` (coherence levels; now in `rt-process-models`), `dd_rotation` (Borst et al., 2011; 10 items, no angle column), `hmcdm_spatialreasoning` (a CDM design), `robison_2026_retesting_*` (retest batteries; `robison_2026_retesting_stroop` is claimed by `validity-causal`), `twod_rotation_mather2023` (1.9 million responses, but a median of 2 items per person and no angle column).

## Widget / simulation / problem ideas

**Widgets**
- Stimulus → difficulty: a psychometric function with a slope and midpoint; points for 33 conditions; toggle "one parameter per condition" vs. "a curve", with the parameter count (idea 2).
- Where the variance lives: sliders for stimulus-effect size and person SD; the retest correlation of each person's effect for a chosen number of trials (idea 3).
- Choosing shots: shooters of equal skill who choose different shot mixes; raw accuracy ranks them by their choices; adjusting for distance restores the tie (idea 4).

**Predict-then-check:** "Three observers, 33 brightness levels, thousands of trials. How much do the observers differ?" Answered by the random-effect SDs (0.04 logits for sessions, 0 for observers) and the observers' accuracies (0.72–0.73).

**Simulate:** simulate trials from a person × feature model (difficulty linear in angle, person random intercepts and slopes); fit (a) one parameter per angle, (b) a linear angle effect, (c) random slopes with `glmer`; compare out of sample with the IMV. Then shrink the person slope SD and watch the retest reliability of the slopes collapse while the average effect stays clear. Seconds in the browser at 50 people × 40 trials.

**Problems**
1. Derivation: with $K$ trials per condition, the reliability of a person's difference score (incongruent minus congruent) depends on the true-score variance of the difference. Derive it and show why a large mean effect doesn't help.
2. Real data with a twist (mrot.R): in `mentalrotation_wolf_2024`, add a squared angle term, then a shape effect. Which improves out-of-sample prediction more?
3. Real data: in `rr98_accuracy`, treat observer rather than observer-session as the person. What changes, and which is right for which question?
4. Judgment (PS9#2): two shooters take the same number of threes; one shoots mostly in the last minute of games. Should their percentages be compared? What would you model?
5. Design: you are building a mental-rotation measure of individual differences. Choose angles, trials per angle, and whether to score accuracy, time, or both.
6. Challenge (open): build a model for chosen trials in which the choice itself depends on ability. What would identify skill separately from choice?

## Go deeper

- **The reliability of a difference.** From CTT, the reliability of $X - Y$ when $X$ and $Y$ are highly correlated; why robust experimental effects give unreliable individual differences (Hedge et al., 2018). Why: `ctt-reliability` (the alpha thread), `validity-evidence`, `response-time`. Length: half a page.

## Open questions

- PS9#2's NBA shots data (Samangy, GitHub, 2004–2024) aren't in the IRW, so the shots idea runs on simulation and a Problem. Add the data to the IRW (as a subsample, #15-style), or keep it simulated?
- 252's mental rotation data (LEVANTE, shape rotation) aren't in the IRW; `mentalrotation_wolf_2024` stands in, and its angle effect on accuracy is small (0.77 → 0.70). A dataset with RT and angle would show the classic linear RT effect. Worth asking LEVANTE for an IRW table?
- `rr98_accuracy` now appears in `irw-data` (introduced), here (main example), and as a sanity table in `response-time` and `rt-process-models`. The last two don't list it in `lessons.yml` (sanity tables needn't appear in the lesson). OK?
- The reliability paradox is owed to `validity-evidence` by `ctt-reliability` (course-bd pays it briefly there); this lesson gives the full treatment. Agree with the split?
