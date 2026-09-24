<!-- Outlined 2026-09-24. No EDUC 252 source beyond c9 slides 55–56 (Ben's suggestion, #65; decided 09-24 as its own optional lesson after response-time). -->

# Process models for response time: drift diffusion and race models (`rt-process-models`)

Module: beyond · Prereqs: response-time · Optional · Status: outline

## Core ideas

1. **A decision as a random walk.** Evidence drifts toward one of two boundaries, with noise; the first boundary crossed is the response, the crossing time plus a non-decision time is the RT. Four parameters: drift $v$ (quality of evidence), boundary separation $a$ (caution), starting point $z$ (bias), non-decision time $T_{er}$. One process produces both accuracy and the skewed RT distribution, so the lognormal isn't needed as an assumption. *(major)* Sources: Ratcliff (1978), doi:10.1037/0033-295X.85.2.59; Ratcliff & McKoon (2008), doi:10.1162/neco.2008.12-06-420; Ratcliff, Smith, Brown & McKoon (2016), doi:10.1016/j.tics.2016.01.007.
2. **What the parameters mean, read off the data.** A harder stimulus lowers drift (slower and less accurate); a speed instruction lowers the boundary (faster and less accurate). The SAT from `response-time` becomes one parameter. EZ-diffusion recovers $v$, $a$ and $T_{er}$ in closed form from accuracy and the mean and variance of correct RTs, which makes it browser-friendly. *(major)* Sources: Wagenmakers, van der Maas & Grasman (2007), doi:10.3758/BF03194023; Ratcliff & Rouder (1998), doi:10.1111/1467-9280.00067.
3. **The diffusion model is an IRT model.** Let drift be person ability minus item difficulty: accuracy is then a logistic function with discrimination set by the boundary, so a cautious respondent's responses discriminate more. This is the Q-diffusion and D-diffusion bridge to the 2PL. *(major)* Sources: Tuerlinckx & De Boeck (2005), doi:10.1007/s11336-000-0810-3; van der Maas, Molenaar, Maris, Kievit & Borsboom (2011), doi:10.1037/a0022749; Molenaar, Tuerlinckx & van der Maas (2015), `diffIRT`, doi:10.18637/jss.v066.i04; Kang, De Boeck & Ratcliff (2022), doi:10.1007/s11336-021-09819-5.
4. **Slow errors, and what the simple model can't do.** In the basic model, correct and error RTs have the same distribution. Real data often have slow errors (or fast ones); across-trial variability in drift and starting point produces them. Sources: Ratcliff & Tuerlinckx (2002), doi:10.3758/BF03196302; Ratcliff & Rouder (1998).
5. **Race models for more than two options.** Each option is a horse accumulating evidence; the first to its threshold wins. The linear ballistic accumulator is the tractable case. Diffusion is (mostly) a two-choice model; races handle multiple choice (slide 56). Sources: Brown & Heathcote (2008), doi:10.1016/j.cogpsych.2007.12.002; Heathcote & Matzke (2022), doi:10.1177/09637214221095852.

Articles checked on Crossref (09-24). Software: `rtdists` (Singmann et al., CRAN) for densities and `diffIRT`; EZ is a few lines of R. My view, from slide 55: this is hard to get working with the tasks I usually see; the lesson says where it works and where it doesn't.

## Picks up

- Log RT, the lognormal model, person speed and item time intensity (from `response-time`).
- The within- vs. between-person SAT, and the conditional accuracy function (from `response-time`).
- The 2PL and discrimination as a slope (from `1pl-to-4pl`; not an ancestor, see Open questions).
- Errors slower than correct responses in `rr98_accuracy` (from `irw-data`).
- Crossed random effects for ability and difficulty, fitted to accuracy and log time (from `response-time`).

## Promises / leaves open

- Fitting the full diffusion model with trial-to-trial variability (maximum likelihood per person, or hierarchical Bayes, e.g. HDDM) → unpaid (Go further only).
- Diffusion IRT for real test items (minutes long, many options) → unpaid; the failure case below says why it's hard.
- Rapid guessing as a separate process (a mixture of a guess process and a diffusion) → unpaid (guessing-priors and response-time leave the same hook open).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `mturkddm_lexical` | main example | Lexical decision collected to test diffusion modelling online (Ratcliff & Hendrickson, 2021): 142 people × 480 trials, accuracy 0.89, median 0.64 s; errors about as fast as correct responses (0.63 vs. 0.64 s), so EZ's assumptions roughly hold. EZ per person: median $v$ = 0.19, $a$ = 0.12, $T_{er}$ = 0.42 s. Drift tracks the random-effects ability estimate (r = 0.78), boundary tracks slowness (r = −0.74 with speed), and ability and speed barely correlate (r = −0.22). The diffusion model splits what a Rasch model lumps together. | — |
| `motion` | contrast | Random-dot motion (O'Brien & Yeatman, 2021): 106 participants × 300 trials at five coherence levels. Pooled EZ drift rises with coherence (0.030 at 6% → 0.098 at 48%) while the boundary stays put (0.23): the model's story. But errors are slower than correct responses at every level (e.g. 1.5 vs. 1.1 s overall), which simple diffusion can't produce, and 100% coherence is *less* accurate than 48% (0.81 vs. 0.91). | — |
| `credentialform_lnirt` (failure case, via a thread) | failure case | EZ on a licensure exam with minute-long, multi-option items gives a median non-decision time of 13 s and a negative one for 7% of respondents. The model is for single fast decisions; a 54-s item is many decisions. | `response-time` (record under `reuses:`) |
| `rr98_accuracy` | sanity (not in the lesson) | Ratcliff & Rouder (1998) Experiment 1, the classic diffusion data. EZ drift should rise with distance from the ambiguous middle brightness and the boundary shouldn't: $v$ = 0.006, 0.046, 0.125, 0.190, 0.207 across five distance bins, $a$ between 0.12 and 0.16. | `irw-data`, `trials` |

Sources for the tables: Ratcliff & Hendrickson (2021), doi:10.3758/s13428-021-01573-x; O'Brien & Yeatman (2021), doi:10.1111/desc.13039 (this study is also the motion-perception example on c9 slide 21). Table citations come from IRW biblio.

The motion item codes combine a coherence level with a second index (1–6) that looks like block order (median RT falls from 1.3 to 1.1 s across it); check the processing notes before drafting.

## Widget / simulation / problem ideas

**Widgets**
- Random walk: sliders for $v$, $a$, $z$, $T_{er}$; animated sample paths, the two RT histograms (correct and error) and accuracy (ideas 1, 2).
- Drift vs. boundary: move one and watch the SAT curve; lowering $a$ trades accuracy for speed, lowering $v$ costs both (idea 2).
- Diffusion as 2PL: set drift = θ − b; plot P(correct) against θ for two boundary values and overlay the 2PL with $a$ matched (idea 3).
- Slow errors: add across-trial SD of drift; error RTs pull past correct ones (idea 4).

**Predict-then-check:** "In the lexical decision data, will EZ drift or boundary track the person's ability estimate from a Rasch-type model?" Answered by r(v, θ) = 0.78 vs. r(a, speed) = −0.74 and r(θ, speed) = −0.22.

**Simulate:** simulate diffusion trials for 100 people (random $v$ and $a$; `rtdists::rdiffusion`), recover them with EZ, and fit `glmer` to the accuracies; plot recovered drift against true drift and against the `glmer` θ. A few seconds for 100 × 200 trials. Then add drift variability and watch EZ's $T_{er}$ and $v$ go wrong.

**Problems**
1. Derivation: with $z = a/2$ and no non-decision time, the diffusion model's P(correct) is $1/(1 + e^{-av/s^2})$. Show that with $v = θ - b$ this is a 2PL, and read off the discrimination.
2. Real data with a twist: `mturkddm_lexical` mixes words and nonwords. Estimate EZ parameters separately for each. Which parameter differs, and is that what you'd expect?
3. Real data: in `motion`, errors are slower than correct responses. Which extension of the model explains that, and what else would it predict about the RT distributions?
4. Judgment: a colleague wants to report $T_{er}$ for each respondent on a 12-item reasoning test (`rapm`-style items, minutes each). Advise.
5. Design: to separate drift from boundary for each person, what would you manipulate across trials, and how many trials per condition would you want?
6. Challenge (open): the Stroop task has three or more response colours. Sketch a race model for it and say what the congruency effect would do to each accumulator.

## Go deeper

- **The EZ equations.** From the diffusion model's accuracy, mean and variance of decision time to the closed-form inverse (Wagenmakers et al., 2007). Why: Simulate, idea 2. Length: half a page.
- **Diffusion → 2PL.** The boundary as discrimination, with its assumptions (unbiased start, constant boundary across items). Why: `1pl-to-4pl` (what a slope is), `response-time`. Length: half a page.

## Open questions

- Tables: `credentialform_lnirt` as the failure case is a deliberate reuse from `response-time` (recorded under `reuses:`). Fine, or should the failure case use a table no other lesson has? **Answered (Ben, 09-24):** some reuse is fine; use tables broadly where possible. Keep it.
- Browser feasibility: EZ is instant; `rtdists` needs to install in webR (it has compiled code). If it doesn't, simulate with a plain R random walk (slower but fine at 100 × 200). Check before drafting.
- `mturkddm_lexical`'s item text is the letter string of each word and nonword. It is shown only as examples, so the reuse question (#63) is small, but the words/nonwords split in Problem 2 needs a word/nonword flag, which the tokenless CSV doesn't carry. Take it from the item text snapshot, or drop the problem?
- Prerequisites: idea 3 (diffusion → 2PL) needs the 2PL, but `1pl-to-4pl` isn't an ancestor (`response-time` → `explanatory-irt` → `rasch`). Add `1pl-to-4pl` as a prerequisite, or restate the 2PL in a paragraph?
