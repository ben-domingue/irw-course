<!-- Outlined 2026-09-28 (#153; scope split with mixture-models in #189). Preliminary numbers from R on the tokenless CSVs (IRW v64 / v5), scratch code in the session scratchpad. Citations checked on Crossref (09-28), no mailto. -->

# Careless responding and response styles (`careless-responding`)

Module: beyond · Prereqs: response-time, instrument-building, person-fit · Extension · Status: stub (outlined)

## Core ideas

1. **Too fast to read.** Start from `response-time`: a respondent's median time per item is a screen. Set a cut by what reading takes, and look for a second mode in the distribution rather than a tail. A fast response isn't always careless (`irtrees` found fast extraversion answers that tracked the trait). *(major)* Sources: Huang, Curran, Keeney, Poposki & DeShon (2012), doi:10.1007/s10869-011-9231-8 (2 s per item); Wise & Kong (2005), doi:10.1207/s15324818ame1802_2; Meade & Craig (2012), doi:10.1037/a0028085.
2. **Screens that read the pattern.** There are four families of screen:
   - *sameness*: long string, or within-person SD;
   - *inconsistency*: even–odd consistency;
   - *oddness*: Mahalanobis distance, and person fit $l_z$, recalled from `person-fit`;
   - *direct checks*: instructed items, and fake words (the overclaiming technique).

   Each screen is computed one respondent at a time. *(major)* Sources: Johnson (2005), doi:10.1016/j.jrp.2004.09.009; Curran (2016), doi:10.1016/j.jesp.2015.07.006; Drasgow, Levine & Williams (1985), doi:10.1111/j.2044-8317.1985.tb00817.x; Oppenheimer, Meyvis & Davidenko (2009), doi:10.1016/j.jesp.2009.03.009; Maniaci & Rogge (2014), doi:10.1016/j.jrp.2013.09.008; Paulhus, Harms, Bruce & Lysy (2003), doi:10.1037/0022-3514.84.4.890.
3. **The screens disagree, because careless responding isn't one behaviour.** Random responding sits far from everyone, so Mahalanobis distance and $l_z$ catch it. A straight line fits the model well: it overfits. Speed and sameness go together, and oddness is a separate cluster. The question the data can answer: which behaviour does this screen see? *(major)* Sources: Meade & Craig (2012); Niessen, Meijer & Tendeiro (2016), doi:10.1016/j.jrp.2016.04.010; Karabatsos (2003), doi:10.1207/S15324818AME1604_2; Meijer & Sijtsma (2001), doi:10.1177/01466210122031957.
4. **Keying decides what careless responding does to a scale.** This returns `instrument-building`'s acquiescence widget, now with real respondents:
   - A same-option responder gets an extreme score on an all-forward scale and exactly the midpoint on a balanced scale.
   - It raises the all-forward scale's alpha, and within the fast group it pulls the balanced scale's alpha to zero.
   - It creates a wording factor.
   - If the stored codes are already keyed, a straight line on the screen doesn't look like a straight line in the data.

   *(major)* Sources: Woods (2006), doi:10.1007/s10862-005-9004-7; Kam & Meyer (2015), doi:10.1177/1094428115571894; Arias et al. (2020), doi:10.3758/s13428-020-01401-8; Weijters, Baumgartner & Schillewaert (2013), doi:10.1037/a0032121.
5. **Response styles are tendencies, not lapses.** Acquiescence, extreme responding and midpoint responding are fairly stable within a respondent, and are measured with counts over heterogeneous items (ARS, ERS, MRS). The question: is a style index measuring style, or the trait? A short "if you've done `irtrees`" Recall covers the model-based separation. Sources: Baumgartner & Steenkamp (2001), doi:10.1509/jmkr.38.2.143.18840; Weijters, Geuens & Schillewaert (2010), doi:10.1037/a0018721; Van Vaerenbergh & Thomas (2013), doi:10.1093/ijpor/eds021; Paulhus (1991), doi:10.1016/B978-0-12-590241-0.50006-X; Bolt & Johnson (2009), doi:10.1177/0146621608329891.
6. **What to do with a flag.** The options are to drop, to follow up, to report with and without, or to model it (→ `mixture-models`). A flag is a hypothesis about a person, not a finding. Removing flagged respondents changes the estimate, and so can keeping them. Sources: Ward & Meade (2023), doi:10.1146/annurev-psych-040422-045007; DeSimone, Harms & DeSimone (2015), doi:10.1002/job.1962; Credé (2010), doi:10.1177/0013164410366686; Bowling et al. (2016), doi:10.1037/pspp0000085.

**Verdict (proposed, soft and impersonal):** when the aim is a group estimate and the survey has a balanced scale or a check item, screening on time plus one pattern index, with the cuts set before looking at the data, may be sufficient for some purposes. When a score feeds a decision about a person, as in a campus mental-health screening, a flag may serve better as a reason to follow up than as a reason to delete.

All DOIs above were checked on Crossref on 09-28. Instrument sources were also checked: DASS, Lovibond & Lovibond (1995), doi:10.1016/0005-7967(94)00075-U; TIPI, Gosling et al. (2003), doi:10.1016/S0092-6566(03)00046-1; PSS, Cohen, Kamarck & Mermelstein (1983), doi:10.2307/2136404; PHQ-9, Kroenke et al. (2001), doi:10.1046/j.1525-1497.2001.016009606.x. The `careless` R package (Yentes & Wilhelm, on CRAN) is not yet verified; the lesson can compute every index by hand.

## Picks up

- Log time, a respondent's speed, and rapid responses at chance (from `response-time`). This lesson moves from tests to surveys.
- Acquiescence; all-forward vs. balanced scales; alpha rises with a shared nuisance (from `instrument-building`, where the widget is `simAcquiescence`). This is proposed as a new thread, `response-styles` (see Promises).
- Wording direction as a second dimension (thread `wording-direction`, from `instrument-building`). The PSS's second eigenvalue falls from 3.6 to 2.3 when the fast respondents are set aside.
- Keying has to be checked, and the data can't always tell (thread `reverse-keying`, from `ctt-reliability`). The PSS codes arrive already keyed, so an analyst who reverse-keys them "again" turns a straight line into a perfectly consistent pattern.
- Correlated errors push alpha above reliability (thread `alpha-lower-bound`, from `ctt-reliability`). Same-option responding is such an error: within the fast group, the PHQ-9's alpha is 0.93.
- Reliability depends on the population (thread `population-dependence`, from `ctt-reliability`). Who is included changes alpha.
- Overfit vs. underfit (thread `overfit-underfit`, from `rasch`). Straight-liners have $Z_h \approx +1.2$: they overfit, and they don't misfit.
- $l_z$ and its sampling distribution (from `person-fit`, outlined in parallel). Pick up whichever thread that outline registers for $l_z$.
- The GRM, for $l_z$ on four-point items (from `polytomous`, a core lesson that isn't an ancestor). This is a brief "if you've done" Recall (E2), unless Ben adds the prerequisite.
- E2 Recalls, which are not threads:
  - "if you've done `irtrees`": response-style nodes, and fast answers that tracked extraversion;
  - "if you've done `guessing-priors`": rapid guesses in `roar_lexical`, restated and not reloaded.

## Promises / leaves open

- Inattentive respondents as a latent class, with response times informing membership (Ulitzsch, Pohl, Khorramdel, Kroehne & von Davier, 2022, doi:10.1007/s11336-021-09817-7) → `mixture-models`. This is a thread only if `mixture-models` lists `careless-responding` as a prerequisite; otherwise it is an E2 Recall there (Open questions).
- New thread **`response-styles`**: "Acquiescence and other response styles are shared by every item". It is introduced in `instrument-building`, and this lesson is its first return. `irtrees` can't carry it, because it isn't a descendant of `instrument-building`.
- New thread **`screens-disagree`**: "Careless responding leaves different traces; each screen sees one". It is introduced here and returns in `mixture-models` (if that lesson is a descendant).
- Combining flags into one classifier (Schroeders, Schmidt & Gnambs, 2022, doi:10.1177/00131644211004708) → problem 6, otherwise unpaid.
- Social desirability, and faking on high-stakes surveys → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `su_2024_pss14` + `su_2024_phq9` | main example (one job, two tables: the same 24,292 respondents on a balanced scale and an all-forward one; precedent `rapm_poulton_2022_*`) | A mandatory online mental-health screening at a Chinese medical university (Su et al., 2024, doi:10.1038/s41597-024-03888-8). Person median time on the PSS is bimodal: 17% answer in under 1 s per item (4,078 respondents), against a main mode near 3–4 s. A third of them give one pattern: 1 on the seven stress items and 5 on the seven positive items (codes already keyed; see Data notes), probably the same option clicked on every screen. That pattern scores exactly 28 of 56, the midpoint. The PSS's alpha is 0.84 among slower respondents, −0.00 in the fast group and 0.79 overall. On the all-forward PHQ-9 the same fast group gives all zeros 52% of the time (29% for slower respondents), with alpha 0.93 (0.87 slower). The PSS's second eigenvalue is 3.6 with everyone and 2.3 without the fast group. Log median times on the PSS and PHQ-9 correlate 0.59. | — |
| `depression_anxiety_stress` | contrast | A voluntary online DASS-42 with the TIPI and a 16-word checklist with three fake words (Open-Source Psychometrics Project; 39,775 respondents who said their answers were accurate). Only 1.4% of DASS responses are under 1 s. In a random 5,000, with each screen flagging its worst 5%: $Z_h$ and Mahalanobis overlap on 122 of 250 flags; long string and speed overlap on 85; $Z_h$ and long string on 0. Fake-word checking (13%) barely tracks any screen (Spearman $|r| \le 0.11$). It rises from 12% with no other flag to 38% with three. 249 respondents gave one answer to all 42 items: 123 answered all 4s and 110 all 1s, with a median time of 1.6 s against 3.6 s overall. TIPI extreme responding (neuroticism items excluded) correlates 0.14 with the DASS total. | — |
| Simulated GRM data | sanity | Under the model, $Z_h$ has mean ≈ 0 and SD ≈ 1. Also checked: in the DASS checklist the real words *boat* and *robot* are checked by 81% and 87%, and the fake words by 4–8%, which confirms 1 = checked. | — |

**The finding:** the fast group behaves like `instrument-building`'s acquiescence slider set high. It raises the all-forward PHQ-9's alpha, zeroes the balanced PSS's, and makes a wording factor. On the DASS, the screens split into two families that barely overlap.

**Data notes (processing scripts read; landing pages checked; tokenless CSVs 33 MB, 2 MB and 40 MB):**
- *Su PSS keying.* In the deposit's `score` column, score = Σ(code − 1) for every row, and reversing the positive items (4, 5, 6, 7, 9, 10, 13) matches only 4.7% of rows. So the stored codes are already keyed, higher meaning more stress. The IRW script keeps them as deposited, and the landing page doesn't say they are keyed.
  - Among slower respondents, item 12 correlates −0.14 to −0.25 with the positive items. That is a fact about fit, to be checked against the Chinese version's scoring.
  - The display order of the response options is not yet verified in the authors' GitHub repository. Until it is, "same option on every screen" is an inference.
- *Su timing and order.* RT is in seconds. Items were given in a fixed order (demographics → PHQ-9 → GAD-7 → PSS → ISI; paper, Methods). The deposit records no withdrawals.
- *DASS order.* Items were shown in a random order for each respondent (codebook). The IRW table drops the position columns (`Q#I`), so a long string in item-number order isn't what the respondent saw. The lesson uses within-person SD and all-same patterns, and states this plainly.
- *DASS item ids.* Items are 1–68 with no labels: 1–42 DASS, 43–52 TIPI, 53–68 checklist, with fake words at 58, 61 and 64 (*cuivocal*, *florted*, *verdid*, from the codebook). Only the DASS items have times.
- *DASS sample.* The source kept only respondents who answered "yes" to "Have you given accurate answers...?". A self-report screen was already applied.

## Widget / simulation / problem ideas

**Widgets**
- *Too fast to read* (idea 1). A mix of engaged readers and fast responders on the same option; a slider for the time cut. It shows the histogram of person median times with the cut, the share flagged, and how many engaged readers are caught.
- *The straight line you can't see* (ideas 2 and 4). Click one option position on all 14 items. The widget shows the screen positions, the stored (keyed) codes, the long-string index on each, and the score: 28 on a balanced scale, 0 on an all-forward one.
- *Balanced vs. all-forward* (idea 4; returns `simAcquiescence`). A slider for the share of same-option responders. It shows alpha for both designs, the trait's share of the sum, and the second eigenvalue.
- *Which screen sees which?* (idea 3). Simulate random, straight-line and fast-but-reading respondents. A grid shows the detection rate of each screen (time, SD, even–odd, Mahalanobis, $l_z$) for each type.

**Predict-then-check:** among the Su respondents who answered in under 1 s per item, what is the alpha of the PHQ-9, and of the PSS? (0.93 and −0.00.)

**Simulate:** 1,000 respondents from a GRM on a 14-item balanced scale, with lognormal times. Contaminate chosen shares with random, straight-line and fast-reading respondents. Compute the five screens and $l_z$ (`mirt::personfit`), and report each screen's detection and false-flag rates by type. This takes seconds in webR.

**Problems**
1. *Derivation:* on a balanced 2k-item 1–5 scale, a same-option responder always scores the midpoint. What happens on an all-forward scale? And with acquiescence of size δ added to every raw response?
2. *Real data with a twist:* the DASS table lacks presentation order. Which screens survive random ordering, and which need order? Compare long string in item order with within-person SD.
3. *Judgment (gentle):* in a campus screening, a respondent gives all zeros on the PHQ-9 in 0.4 s per item. Drop, keep, or follow up? What does each choice do to the estimated prevalence?
4. *Design:* choose a check for a new survey: an instructed item, fake words, or a balanced pair. Say what each can and can't see, and set the cut before collecting data.
5. *Real data:* the 123 DASS respondents who answered 4 on all 42 items. Is this a straight line, or severe distress? Use time (median 1.6 s), fake words (29% checked one) and the design. What can't the data tell?
6. *Challenge (open):* one screen or many? Compare flag-and-drop, a combined classifier (Schroeders et al., 2022) and a mixture (→ `mixture-models`). When does dropping flagged respondents bias a correlation (Credé, 2010)?

## Go deeper

- **A contaminating group's covariance.** For a mixture, $\Sigma = \pi\Sigma_1 + (1-\pi)\Sigma_0 + \pi(1-\pi)(\mu_1-\mu_0)(\mu_1-\mu_0)^\top$. A same-option group adds a rank-one term along the keying vector: it lies along the first factor on an all-forward scale, and becomes a wording factor on a balanced one. This is the algebra behind the alpha results and the second eigenvalue. Why: `mixture-models` and `fa-exploratory` (wording factors). Length: half a page.

## Open questions

- **Prerequisites.** *Default:* `response-time`, `instrument-building`, `person-fit`. This makes `response-styles`, `wording-direction`, `reverse-keying`, `alpha-lower-bound`, `population-dependence` and `overfit-underfit` legal returns, and the order has no cycle (person-fit ← rasch, fit-prediction). Should `polytomous` be added for the GRM? *Default:* no. `polytomous` is core, so it gets an E2 Recall.
- **The mixture-models link.** Should `mixture-models` list `careless-responding` as a prerequisite, so that the promise and `screens-disagree` become threads? *Default:* no. Its prerequisites stay light, and it recalls this lesson under E2.
- **Two Su tables as one job** (precedent `rapm_poulton_2022_*`). *Default:* yes. Otherwise, drop `su_2024_phq9` and describe the all-forward side with the widget only.
- **Not used:**
  - `much_tte_2025_matrixreasoning` + `_effort`: a matrix test with times, a speeded condition and self-reported effort (Much et al., 2025, doi:10.5334/jopd.124). It would be a fourth load; a possible problem, or it could go to `mixture-models`.
  - `vollbracht_et_al_2026_ambulatory_assessment`: ESM data with a `cov_careless` flag and 151-point sliders.
- **Deep dive.** Share of sub-second responses across the roughly 30 Likert tables with `rt`. *Default:* none for now; a candidate for later.
- **Verdict** as above (soft, impersonal). *Default:* use it.
- **IRW data (for the IRW side, not the lesson):**
  - `su_2024_pss14`: note on the landing page that the codes are already keyed.
  - `depression_anxiety_stress`: keep item position and item labels.
  - `gcbs_brotherton_2013` (not used here): `rt` looks like milliseconds (median 5,913), unlike the IRW's seconds; its processing script doesn't convert.
