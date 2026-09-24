<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 22–31) and c10 (slides 44–45, 49). No 252 code or problem set for this lesson; the post-hoc CAT is new. Tidied 09-24: prerequisites per E10, precomputed CAT per E12, the state-data exercise as a design problem per F21. -->

# Item banks and adaptive testing (`item-banks-cat`)

Module: uses · Prereqs: information, ability-estimation, polytomous · Extension · Status: outline

## Core ideas

1. **An item bank is what lets you reuse items.** At minimum, the item and its calibrated parameters; in practice also content codes, exposure counts, dates, DIF screens and drift checks. Because the parameters are fixed, new respondents land on the old scale. Banks need upkeep: drift, exposure, retirement. *(major)* Sources: c6 slides 22–24; c10 slides 44 and 49 ("item banks are our friends"); Wainer et al. (2000), doi:10.4324/9781410605931; van der Linden & Glas (Eds.) (2010), doi:10.1007/978-0-387-85461-8.
2. **The adaptive loop.** Start; choose the most informative item at the current estimate; answer; update $\hat\theta$ (EAP, a Recall of `ability-estimation`: the MLE doesn't exist after all-right or all-wrong answers); stop. Adaptive testing is old: Binet chose items by age level, and basal and ceiling rules still do it on paper. *(major)* Sources: c6 slides 25–27 (the IACAT walk-through, http://iacat.org/irt-based-cat, *link to check*); Binet & Simon (1904), doi:10.3406/psy.1904.3675; Lord (1980), doi:10.4324/9780203056615, ch. 10; Weiss (1982), doi:10.1177/014662168200600408; Owen (1975), doi:10.2307/2285821; Bock & Mislevy (1982), doi:10.1177/014662168200600405.
3. **Stopping rules and what they buy.** Fixed length, a target standard error, or a classification decision (the SPRT, one paragraph); multistage testing in a sentence. Precision per item is the payoff; a bank thin at one end is the limit. *(major)* Sources: Weiss & Kingsbury (1984), doi:10.1111/j.1745-3984.1984.tb01040.x; Eggen (1999), doi:10.1177/01466219922031365; Reckase (1983), in Weiss (Ed.), *New Horizons in Testing* (chapter; *not verified*).
4. **What maximum information costs.** Overexposure of the best items, content balance, the slope-greedy start; the fixes (randomesque, a-stratification, Sympson–Hetter) in outline. Sources: Kingsbury & Zara (1989), doi:10.1207/s15324818ame0204_6; Chang & Ying (1999), doi:10.1177/01466219922031338; Chang (2015), doi:10.1007/s11336-014-9401-5; Sympson & Hetter (1985), conference paper (*not verified*).
5. **Everything rests on parameter invariance.** A CAT assumes the bank's parameters hold for whoever is tested, on whatever items they see. ROAR-CAT tested it; post-hoc simulation is the check you can run yourself. Sources: c6 slides 28–30; Ma et al. (2025), doi:10.3758/s13428-024-02578-y; Magis & Raîche (2012), `catR`, doi:10.18637/jss.v048.i08; Chalmers (2016), `mirtCAT`, doi:10.18637/jss.v071.i05.

DOIs checked on Crossref on 09-24. Reckase (1983) and Sympson & Hetter (1985) have no DOI and are *not yet verified*; the IACAT page is to check.

## Picks up

- Information, the CSEM $1/\sqrt{I(\theta)}$, targeting, short forms; choosing the next item by information (from `information`).
- EAP, and no MLE for perfect patterns (from `ability-estimation`).
- Information from polytomous items; the graded model, for the PROMIS contrast (from `polytomous`).
- The 2PL: $a^2p(1-p)$ information and the slope-greedy pull (from `1pl-to-4pl`, via `information`).
- Calibrated to the task, precise quickly (from `measurement`, Ben's desiderata).
- Missing responses by design: a CAT's data are missing by design and ignorable, given the model (from `irw-data`; Mislevy & Wu, 1996, doi:10.1002/j.2333-8504.1996.tb01708.x).
- A cut score and precision near it, for the SPRT (from `score-meaning`, not an ancestor: E2).
- DIF screens for bank items (from `dif`, not an ancestor: E2).
- New items onto the bank's scale (from `equating`, not an ancestor: E2).
- Brief "if you've done" Recalls (E2), no teaching: invariance across item sets (from `parameter-invariance`); sparse designs and EM (from `item-estimation`); outfit's null distribution for screening (from `fit-prediction`); Elo in adaptive learning systems, Pelánek (2016), doi:10.1016/j.compedu.2016.03.017 (from `competitions`); multidimensional CAT (from `dimensionality`); difficulties predicted for uncalibrated items (from `ai-psychometrics`); timing in adaptive tests (from `response-time`); adaptive task batteries (from `trials`).

## Promises / leaves open

- Generating and pre-calibrating items for a bank → `ai-psychometrics` (automatic item generation, difficulty predicted from item text).
- Item parameter drift over time (a pointer to `equating`'s anchors) → unpaid.
- Multistage testing → unpaid (a sentence in idea 3).
- Response time in adaptive tests → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `choi_2026_cmsce_2020_1` | main example | Korea's Clinical Medical Science Comprehensive Examination, 2020, part 1: 5,388 medical students × 304 items, complete; 68% correct on average. The source paper built a CAT from these forms (Choi et al., 2025, doi:10.3352/jeehp.2025.22.29). A 2PL on a random half; 30 items with slopes below 0.3 left out, a 274-item bank. Test information peaks near $\theta = -1.5$ (CSEM 0.11), CSEM 0.44 at $\theta = 3$: the exam is easy. Post-hoc CAT (EAP, maximum information) on 600 held-out students: 20 items give $r$ = 0.95 with the full-test $\theta$ (RMSE 0.30), against 0.88 (0.46) for 20 random items; 40 items give 0.975. To SE ≤ 0.3: median 19 items, mean 32; students below $\theta = -1$ need 12 on average, those above 2 hit the 100-item cap, as the paper's live CAT found (its 50-item maximum). | — |
| `promis1wave1_depression` | contrast | PROMIS wave 1 depression: 56 items, five categories, 14,909 adults, 781 complete (Cella et al., 2010, doi:10.1016/j.jclinepi.2010.04.011; Pilkonis et al., 2011, doi:10.1177/1073191111411667). Graded model; post-hoc CAT (`mirtCAT`) to SE ≤ 0.3 for 300 full-bank respondents: median 4 items, mean 7.4, $r$ = 0.96 with full-bank $\theta$. Thin at the low end: below $\theta = -0.5$ (few symptoms) 14 items on average, still stopping at SE 0.31; above 0.5, about 3. As in Choi et al. (2010), doi:10.1007/s11136-009-9560-5. Read as bank design (where the items are), not about the respondents (F22). | — |
| `choi_2026_cmsce_2020_1` | sanity | A post-hoc CAT with the whole bank as its length must equal the full-test EAP for every respondent. | — |

**Precomputed (E12).** The 600-respondent CAT (five rules) takes about 19 minutes locally, so it follows the deep-dive split (PROTOCOL §5): `compute.R` writes a committed `.rds` that the page reads, and a 50-respondent version runs live.

Data notes: IRW biblio lists the CMSCE data set as 2026 (Harvard Dataverse, doi:10.7910/DVN/TQZQ6L); the paper is 2025. The paper's bank pooled six administrations (2019–2021) that share no items in the IRW tables; how they were put on one scale is a question the lesson raises, not a criticism. Processing notes still to read (D).

## Widget / simulation / problem ideas

**Widgets**
- One CAT, step by step: a simulated respondent and a 2PL bank; each step shows the posterior, the item chosen and its information at $\hat\theta$ (idea 2).
- Stopping rules: fixed length vs. target SE; items used and error by true $\theta$, for a bank you can shape (ideas 1, 3).
- Exposure: 500 simulated respondents through maximum information vs. randomesque selection; how often each item is used (idea 4).
- Paper adaptive testing: a basal/ceiling rule against a CAT on the same bank (idea 2).

**Predict-then-check:** for the CMSCE, with SE ≤ 0.3, which students need the most items: the weakest, the average, or the strongest? Answered by items used by $\theta$ band (the strongest: the bank has few hard items).

**Simulate:** a 200-item 2PL bank, 200 simulated respondents, EAP and maximum information to SE ≤ 0.3 (`catR` or `mirtCAT`), against a fixed 20-item form from the same bank. Seconds in webR.

**Problems**
1. Derivation: under the Rasch model the most informative item at $\hat\theta$ has $b$ closest to $\hat\theta$; under the 2PL, why maximum information favours high slopes early.
2. Real data with a twist: rerun the CMSCE CAT with Choi et al.'s screening rule (slope above 0.6, $|b| < 5$). How much bank is left, and what happens at the top?
3. Design (F21; c10 slide 45): you work at the state agency and have last year's summative test data. Build an item bank from it: which fields does each item need, and how do you calibrate? Then: what can't you do with these data? (No DIF screens without group information; no drift checks from one year.) Taught without a data set.
4. Judgment: the PROMIS bank is thin at the low end. For a general-population survey where most respondents report few symptoms, would you use the CAT, a fixed short form, or new low-end items first (and how would you calibrate them onto the bank)?
5. Real data: CAT with an SPRT around a pass mark at the CMSCE's 10th percentile. How many items does a pass/fail decision take, compared with a precise score?
6. Challenge (open): a post-hoc CAT reuses responses given in a fixed form and order, with no stakes on the items chosen. How might a live CAT differ, and how would you find out?

## Go deeper

- **Maximum information and the posterior.** Selecting at the EAP with Fisher information approximates minimizing expected posterior variance; when they differ (early in the test). Why: `ability-estimation`, `information`. Length: half a page.

## Open questions

- None. Settled 09-24: prerequisites (E10); precompute the real-data CAT (E12); the state-data exercise as a design problem without data (F21); PROMIS as a bank-design question (F22).
