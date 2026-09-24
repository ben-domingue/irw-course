<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 22–31) and c10 (slides 44–45, 49). No 252 code or problem set for this lesson; the post-hoc CAT is new. -->

# Item banks and adaptive testing (`item-banks-cat`)

Module: uses · Prereqs: information (proposed: add `ability-estimation`; see Open questions) · Optional · Status: outline

## Core ideas

1. **An item bank is what lets you reuse items.** At minimum, the item and its calibrated parameters; in practice also content codes, exposure counts, dates, DIF screens and drift checks. Because the parameters are fixed, new respondents land on the old scale. Banks need upkeep: parameter drift, exposure, retirement. *(major)* Sources: c6 slides 22–24; c10 slides 44 and 49 ("item banks are our friends"); Wainer et al. (2000), *Computerized Adaptive Testing: A Primer* (2nd ed.), Routledge, doi:10.4324/9781410605931; van der Linden & Glas (Eds.) (2010), *Elements of Adaptive Testing*, Springer, doi:10.1007/978-0-387-85461-8.
2. **The adaptive loop.** Start; choose the most informative item at the current estimate; answer; update $\hat\theta$ (EAP, because the MLE doesn't exist after all-right or all-wrong answers); stop. Adaptive testing is old: Binet chose items by age level, and basal and ceiling rules still do it on paper. *(major)* Sources: c6 slides 25–27 (the IACAT walk-through, http://iacat.org/irt-based-cat, *link to check*); Binet & Simon (1904), doi:10.3406/psy.1904.3675; Lord (1980), doi:10.4324/9780203056615, ch. 10; Weiss (1982), doi:10.1177/014662168200600408; Weiss & Kingsbury (1984), doi:10.1111/j.1745-3984.1984.tb01040.x; Owen (1975), doi:10.2307/2285821; Bock & Mislevy (1982), doi:10.1177/014662168200600405.
3. **Stopping rules and what they buy.** Fixed length, a target standard error, or a classification decision (the SPRT). Precision per item is the payoff; a bank thin at one end is the limit. *(major)* Sources: Weiss & Kingsbury (1984); Eggen (1999), doi:10.1177/01466219922031365; Reckase (1983), "A procedure for decision making using tailored testing", in Weiss (Ed.), *New Horizons in Testing*, Academic Press (chapter; *not verified*).
4. **What maximum information costs.** Overexposure of the best items, content balance, and the slope-greedy start; the fixes (randomesque, a-stratification, Sympson–Hetter) in outline. Sources: Kingsbury & Zara (1989), doi:10.1207/s15324818ame0204_6; Chang & Ying (1999), doi:10.1177/01466219922031338; Chang (2015), doi:10.1007/s11336-014-9401-5; Sympson & Hetter (1985), conference paper (*not verified*).
5. **Everything rests on parameter invariance.** A CAT assumes the bank's parameters hold for whoever is tested, on whatever items they happen to see. ROAR-CAT as an example that tested it; post-hoc simulation as the check you can run yourself. Sources: c6 slides 28–30; Ma et al. (2025), ROAR-CAT, doi:10.3758/s13428-024-02578-y; Magis & Raîche (2012), `catR`, doi:10.18637/jss.v048.i08; Chalmers (2016), `mirtCAT`, doi:10.18637/jss.v071.i05.

All DOIs above were checked on Crossref on 09-24. Reckase (1983) and Sympson & Hetter (1985) have no DOI and are *not yet verified*; the IACAT page is to check.

## Picks up

- Information, the CSEM $1/\sqrt{I(\theta)}$, targeting, short forms (from `information`).
- Choosing the next item by information (from `information`).
- EAP, and no MLE for perfect patterns (from `ability-estimation`; a prerequisite if Ben agrees, see Open questions).
- The 2PL: $a^2p(1-p)$ information and the slope-greedy pull (from `1pl-to-4pl`, via `information`).
- Calibrated to the task, precise quickly (from `measurement`, Ben's desiderata).
- Missing responses by design: a CAT's data are missing by design and ignorable, given the model (from `irw-data`; Mislevy & Wu, 1996, doi:10.1002/j.2333-8504.1996.tb01708.x).
- Invariance of person parameters across item sets; linear indeterminacy (from `parameter-invariance`, optional; if not taught, idea 5 states it).
- Many-item sparse designs, EM (from `item-estimation`, optional).
- Information from polytomous items for short forms and CAT; the PCM is a Rasch model (from `polytomous`; the PROMIS contrast uses the graded model, so `polytomous` should come first, see Open questions).
- The null distribution of outfit, for screening bank items (from `fit-prediction`; a pointer only).
- Elo as online estimation in adaptive learning systems (from `competitions`, optional; one paragraph, Pelánek, 2016, doi:10.1016/j.compedu.2016.03.017).
- Multidimensional adaptive testing (from `dimensionality`, optional): one paragraph and a pointer; not taught.
- New items onto the bank's scale (from `equating`, if taught first).
- Adaptive testing with difficulties predicted for new, uncalibrated items (from `ai-psychometrics`, optional; a mention).

## Promises / leaves open

- Classification stopping rules (SPRT) against a cut score → `score-meaning` (the cut) if taught first; otherwise unpaid.
- DIF screening of bank items → `dif`.
- Item parameter drift over time → unpaid (a pointer to `equating`'s anchors).
- Generating and pre-calibrating items for a bank → `ai-psychometrics` (automatic item generation, difficulty predicted from item text).
- Multistage testing → unpaid (a paragraph in idea 3).
- Response time in adaptive tests → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `choi_2026_cmsce_2020_1` | main example | Korea's Clinical Medical Science Comprehensive Examination, 2020, part 1: 5,388 medical students × 304 items, complete; 68% correct on average. The source paper built a CAT from these forms (Choi et al., 2025, doi:10.3352/jeehp.2025.22.29). A 2PL fitted to a random half; 30 items with slopes below 0.3 left out, leaving a 274-item bank. Test information peaks near $\theta = -1.5$ (CSEM 0.11) and falls to CSEM 0.44 at $\theta = 3$: the exam is easy. Post-hoc CAT (EAP, maximum information) on 600 held-out students, using their real responses: 20 items give $r$ = 0.95 with the full-test $\theta$ (RMSE 0.30), against $r$ = 0.88 (RMSE 0.46) for 20 random items; 40 items give 0.975. With a stopping rule of SE ≤ 0.3, the median is 19 items, but the mean is 32: students below $\theta = -1$ need 12 items on average, those above $\theta = 2$ hit the 100-item cap. The paper reports the same thing from its live CAT (students at the extremes hit its 50-item maximum). | — |
| `promis1wave1_depression` | contrast | PROMIS wave 1 depression items: 56 items, five categories, 14,909 adults, of whom 781 answered every item (Cella et al., 2010, doi:10.1016/j.jclinepi.2010.04.011; Pilkonis et al., 2011, doi:10.1177/1073191111411667). A graded model on everyone; post-hoc CAT (`mirtCAT`) to SE ≤ 0.3 for 300 full-bank respondents: median 4 items, mean 7.4, $r$ = 0.96 with the full-bank $\theta$. The bank is thin at the other end: respondents below $\theta = -0.5$ (few symptoms) need 14 items on average and still stop at SE 0.31, while those above 0.5 need about 3. The same pattern as Choi et al. (2010), doi:10.1007/s11136-009-9560-5. | — |
| `choi_2026_cmsce_2020_1` | sanity | Run the post-hoc CAT with no stopping rule but the bank size: the CAT estimate must equal the full-test EAP for every respondent. | — |

Why these two: the main table is dichotomous and large (so the 2PL bank is well estimated), and its source paper is itself a CAT feasibility study, so the lesson can compare its simulation with a live CAT. The contrast is the best-known adaptive bank in health measurement, polytomous, with the floor where the exam has its ceiling.

Data notes: the IRW biblio lists the CMSCE data set as 2026 (Harvard Dataverse, doi:10.7910/DVN/TQZQ6L); the paper is 2025. The paper's bank pooled 1,145 items from six administrations (2019–2021), which share no items in the IRW tables. How the paper put them on one scale is a question for problem 3, not a criticism. `get_processing_notes` was not available in this session; the landing pages were read.

## Widget / simulation / problem ideas

**Widgets**
- One CAT, step by step: a simulated respondent, a Rasch or 2PL bank; each step shows the posterior, the item chosen and its information at $\hat\theta$; a "next item" button (idea 2).
- Stopping rules: fixed length vs. target SE; items used and error by true $\theta$, for a bank you can shape (uniform, easy, hard) (ideas 3, 1).
- Exposure: the same 500 simulated respondents through maximum information vs. randomesque selection; a bar chart of how often each item is used (idea 4).
- Paper adaptive testing: a basal/ceiling rule (start at an age-based item, go back until six right in a row, forward until six wrong) against a CAT on the same bank (idea 2).

**Predict-then-check:** for the CMSCE, with a stopping rule of SE ≤ 0.3, which students will need the most items: the weakest, the average, or the strongest? Answered by items used by $\theta$ band (the strongest: the bank has few hard items).

**Simulate:** a 200-item 2PL bank; 200 simulated respondents; CAT with EAP and maximum information to SE ≤ 0.3 (`catR` or `mirtCAT`); compare items used and error with a fixed 20-item form built from the same bank. Seconds in webR at these sizes (the 600-respondent real-data run takes 19 minutes locally, so the page shows cached output).

**Problems**
1. Derivation: for the Rasch model, show that the most informative item at $\hat\theta$ is the one with $b$ closest to $\hat\theta$; for the 2PL, show why maximum information favours high slopes early.
2. Real data with a twist: rerun the CMSCE CAT with Choi et al.'s screening rule (slope above 0.6, $|b| < 5$). How much bank is left, and what happens at the top?
3. Judgment: the paper's bank pools six administrations that share no items. What would you need to assume to put them on one scale (see `equating`), and how would you check it?
4. Design: for the PROMIS depression bank, write new items for the low end. What would they ask about? How would you calibrate them onto the bank?
5. Real data: CAT with an SPRT around a pass mark set at the 10th percentile of the CMSCE. How many items does a pass/fail decision take, compared with a precise score?
6. Challenge (open): a post-hoc CAT reuses responses given in a fixed form, in a fixed order, with no stakes on the items chosen. What might a live CAT differ in (position, fatigue, test-taking strategy), and how would you find out?

## Go deeper

- **Maximum information and the posterior.** Why selecting at the EAP with Fisher information is an approximation to minimizing expected posterior variance, and when they differ (early in the test). Why: `ability-estimation`, `information`. Length: half a page.

## Open questions

- **Prerequisites.** Since the IRT reordering (PR #90), `information` comes before `ability-estimation`, so EAP (`ability-estimation`) is no longer upstream of this lesson. Add `ability-estimation` and `polytomous` as prerequisites (both core)? Without `polytomous`, the PROMIS contrast needs a paragraph on the graded model.
- **Post-hoc CAT cost.** The real-data CAT (600 respondents × five rules) takes about 19 minutes locally, so it can't run in the browser. Precompute it (a small `compute.R` and a committed `.rds`, as for deep dives), or run 50 respondents live?
- **Source slides.** c10 slides 45–46 ("build an item bank from state summative data in IRW format") point to a data set I couldn't identify. Is there a specific table Ben had in mind?
- **Tone of the contrast.** The PROMIS depression bank is a mental-health measure; the lesson reads it as a bank design question (where the items are), not as anything about the respondents. Fine?
