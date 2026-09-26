<!-- Outlined 2026-09-24. No EDUC 252 source beyond c9 slides 55–56 (Ben's suggestion, #65). Its own extension lesson after response-time (Ben, 09-24, S3); 1pl-to-4pl added as a prerequisite (digest E1). Tidied 09-24 (#62). -->

# Process models for response time: drift diffusion and race models (`rt-process-models`)

Module: beyond · Prereqs: response-time, 1pl-to-4pl · Extension · Status: draft

## Core ideas

1. **A decision as a random walk.** Evidence drifts toward one of two boundaries; the first crossed is the response, and the crossing time plus a non-decision time is the RT. Drift $v$, boundary separation $a$, starting point $z$, non-decision time $T_{er}$. One process gives both accuracy and the skewed RT distribution, so the lognormal isn't an assumption. *(major)* Sources: Ratcliff (1978), doi:10.1037/0033-295X.85.2.59; Ratcliff & McKoon (2008), doi:10.1162/neco.2008.12-06-420.
2. **What the parameters mean, read off the data.** A harder stimulus lowers drift (slower and less accurate); a speed instruction lowers the boundary (faster and less accurate). The SAT from `response-time` becomes one parameter. EZ-diffusion recovers $v$, $a$, $T_{er}$ in closed form, which suits the browser. *(major)* Sources: Wagenmakers, van der Maas & Grasman (2007), doi:10.3758/BF03194023; Ratcliff & Rouder (1998), doi:10.1111/1467-9280.00067.
3. **The diffusion model is an IRT model.** With drift = θ − b, accuracy is logistic with discrimination set by the boundary: a cautious respondent's responses discriminate more. The bridge to the 2PL. *(major)* Sources: Tuerlinckx & De Boeck (2005), doi:10.1007/s11336-000-0810-3; van der Maas, Molenaar, Maris, Kievit & Borsboom (2011), doi:10.1037/a0022749; `diffIRT`: Molenaar, Tuerlinckx & van der Maas (2015), doi:10.18637/jss.v066.i04.
4. **Slow errors, and what the simple model can't do.** In the basic model correct and error RTs share a distribution; real data often have slow errors, which across-trial variability in drift produces. Sources: Ratcliff & Tuerlinckx (2002), doi:10.3758/BF03196302.
5. **Race models for more than two options.** Each option accumulates evidence; the first to threshold wins (slide 56). The linear ballistic accumulator is the tractable case. Sources: Brown & Heathcote (2008), doi:10.1016/j.cogpsych.2007.12.002; Heathcote & Matzke (2022), doi:10.1177/09637214221095852.

**Verdict (from slide 55, in practitioner terms; for Ben to confirm the wording):** I'd reach for a diffusion model when each response is a single fast decision and there are many trials per person; for test items that take minutes, I wouldn't (the failure case shows why).

Articles checked on Crossref (09-24). Software: `rtdists` (Singmann et al., CRAN) and `diffIRT`; EZ is a few lines of R. Claude checks `rtdists` in webR; if it won't install, simulate with a plain random walk (digest D).

## Picks up

- Log RT, person speed and item time intensity; within- vs. between-person SAT; the conditional accuracy function (from `response-time`).
- The 2PL and discrimination as a slope (from `1pl-to-4pl`).
- Errors slower than correct responses in `rr98_accuracy` (from `irw-data`): within levels the gap is about 0.02 s against 0.09 s pooled, so compare error and correct RTs within a condition before reading slow errors as drift variability.

## Promises / leaves open

- The full diffusion model with trial-to-trial variability (ML per person, hierarchical Bayes) → unpaid (Going further).
- Diffusion IRT for real test items (minutes long, many options) → unpaid; the failure case says why it's hard.
- Rapid guessing as a separate process (a guess–diffusion mixture) → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `mturkddm_lexical` | main example | Lexical decision for online diffusion modelling (Ratcliff & Hendrickson, 2021, doi:10.3758/s13428-021-01573-x): 142 × 480 trials, accuracy 0.89, median 0.64 s; errors about as fast as correct, so EZ roughly holds. Median $v$ = 0.19, $a$ = 0.12, $T_{er}$ = 0.42 s. Drift tracks the random-effects ability (r = 0.78), boundary tracks slowness (r = −0.74 with speed), and ability and speed barely correlate (r = −0.22). | — |
| `motion` | contrast | Random-dot motion (O'Brien & Yeatman, 2021, doi:10.1111/desc.13039): 106 × 300 at five coherence levels. EZ drift rises with coherence (0.030 → 0.098) while the boundary stays at 0.23: the model's story. But errors are slower at every level (1.5 vs. 1.1 s), which simple diffusion can't produce, and 100% coherence is less accurate than 48% (0.81 vs. 0.91). | — |
| `credentialform_lnirt` | failure case | EZ on a licensure exam: median $T_{er}$ 13 s, negative for 7% of respondents. A 54-s item is many decisions. | `response-time` (recorded under `reuses:`) |
| `rr98_accuracy` | sanity | Ratcliff & Rouder (1998): EZ drift rises with distance from the middle brightness (0.006 → 0.207), boundary stays 0.12–0.16. | `irw-data`, `trials` |

Table citations come from IRW biblio. Before drafting, read `motion`'s processing notes: its item codes carry a second index (1–6) that looks like block order.

## Widget / simulation / problem ideas

**Widgets**
- Random walk: $v$, $a$, $z$, $T_{er}$ sliders; sample paths, correct and error RT histograms, accuracy (ideas 1, 2).
- Drift vs. boundary: lowering $a$ trades accuracy for speed; lowering $v$ costs both (idea 2).
- Diffusion as 2PL: drift = θ − b; P(correct) for two boundaries against a matched 2PL (idea 3).
- Slow errors: add across-trial drift SD (idea 4).

**Predict-then-check:** will EZ drift or boundary track the Rasch-type ability estimate? (r(v, θ) = 0.78; r(a, speed) = −0.74; r(θ, speed) = −0.22.)

**Simulate:** diffusion trials for 100 people (`rtdists::rdiffusion`), recovered with EZ and with `glmer` on accuracy; recovered drift against true drift and against θ. Then add drift variability and watch EZ go wrong. Seconds at 100 × 200.

**Problems**
1. Derivation: with $z = a/2$ and no non-decision time, P(correct) = $1/(1 + e^{-av/s^2})$; with $v = θ - b$ this is a 2PL. Read off the discrimination.
2. Real data with a twist: EZ separately for words and nonwords in `mturkddm_lexical`. Which parameter differs? The word/nonword flag comes from the item-text snapshot (digest F12, A5).
3. Real data: errors are slower in `motion`. Which extension explains it, and what else does it predict?
4. Judgment: a colleague wants $T_{er}$ per respondent on a 12-item reasoning test. Advise.
5. Design: to separate drift from boundary per person, what would you manipulate, and how many trials per condition?
6. Challenge (open): sketch a race model for a Stroop task with three or more colours.

## Go deeper

- **The EZ equations** (Wagenmakers et al., 2007). Why: Simulate, idea 2. Half a page.
- **Diffusion → 2PL**, with its assumptions (unbiased start, constant boundary). Why: `1pl-to-4pl`, `response-time`. Half a page.

## Open questions

- The verdict above restates Ben's slide-55 view as a choice for the practitioner. *Default:* use it unless you'd put it differently.

## Drafted (2026-09-25, #65)

What changed from this outline when the lesson was drafted:

- **Notation:** boundary separation is written $\alpha$ (the literature's $a$), keeping $a$ for the item slope; $s = 1$ throughout, with the $s = 0.1$ convention noted (source: `rtdists` documentation). EZ numbers are therefore 10× the outline's ($v$ 1.98, $\alpha$ 1.13 for the lexical median).
- **Trimming:** responses under 0.3 s (at chance in both speeded tables) and the slowest 1% of each table set aside. Recomputed: lexical r(v, θ) = 0.82, r(α, θ) = 0.50, r(α, speed) = −0.71, r(θ, speed) = −0.19; errors 0.633 vs correct 0.639 s. Motion: drift 0.28 → 1.12 (6–48%), 0.85 at 100%; boundary 2.52 → 2.39; errors slower within child × level by 0.13–0.34 s. Licensure: median $T_{er}$ 12.8 s, negative for 6.7%, 5 respondents undefined at 0.5.
- **`motion` item codes:** the item is "<block> <coherence>", block 1–6 first, coherence (6/12/24/48/100) second; each item seen 10 times (`trialnum`), so 60 trials per coherence level (processing script `data/motion_discrimination.R`; verify script `itemtext/itemtables/batch_110/verify_motion.R`). The outline's "second index (1–6)" was the first index.
- **Software:** `rtdists` is in the webR repo, but `rdiffusion` with a drift per respondent–item pair ran > 2 min locally for 20,000 trials; the Simulate cell and the widgets use a plain random walk (base R / JS). Simulate uses the logit of proportion correct instead of `glmer`, so the page loads nothing.
- **Simulate:** drift variability's effect on EZ is shown by `eta <- 1` in Simulate (EZ drift 1.18 vs true 1.47).
- **F12 (problem 2):** the word/nonword flag comes from the original OSF deposit (`Experiment1.data`, osf.io/za9y8, CC BY 4.0, `column_7_value`), not the IRW item-text snapshot, which needs a Redivis login. All 4,588 strings match with one flag each.
- **Sanity table `rr98_accuracy`** (not in the lesson): EZ drift by distance from the middle brightness rises 0.08 → 2.9 ($s = 1$); boundary is not flat under EZ per cell (1.76 → 0.60), unlike the outline's note.
- Quick checks: 3; predict-then-check: which EZ parameter tracks the glmer ability. Widgets: 4 (random walk, drift vs boundary, 2PL inside the walk, slow errors). Go deeper: 2 (EZ equations; walk → 2PL).
