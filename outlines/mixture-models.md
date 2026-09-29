<!-- Outlined 2026-09-28 from #189; merged 09-28 with the `careless-responding` outline (Ben, 09-28: no separate careless-responding lesson; mixture models get one lesson, with careless or inattentive responding as the main worked example and response styles as a second application). Preliminary numbers from R (mirt 1.46.1) on the tokenless CSVs (IRW v64 / v5); scratch code in the session scratchpad (careless-responding/, mixture-models/, mixture-merge/). Citations checked on Crossref 09-28 (no mailto) unless marked. -->

# Mixture models: when respondents differ in kind (`mixture-models`)

Module: beyond · Prereqs: guessing-priors, person-fit, instrument-building (+ polytomous, proposed; see Open questions) · Extension · Status: stub (outlined)

Ancestry. #189 proposed `rasch`, `fit-prediction`, `guessing-priors`; the first two are ancestors of `guessing-priors`. `person-fit` adds no new ancestors and makes `misfit-many-causes` and the Much reuse threads. `instrument-building` brings `constructs` and `ctt-reliability`, which were already ancestors, and makes `wording-direction` and the new `response-styles` legal returns. `polytomous` would add only itself, since `information` is already an ancestor; idea 4 fits a partial credit model. `response-time`, `cdm`, `irtrees` and `dif` are not ancestors; each gets an "if you've done" Recall (E2).

## Core ideas

1. **One population, or several?** *(major)* Each respondent belongs to one of $K$ latent classes with share $\pi_k$, and each class has its own measurement model. A pattern's likelihood is a weighted sum over classes, and Bayes' rule gives each respondent's posterior class probabilities. This is the same move as EAP, with a discrete prior. In the **mixture Rasch model**, each class has its own difficulties $b_{ik}$ ([Rost, 1990](https://doi.org/10.1177/014662169001400305); [Mislevy & Verhelst, 1990](https://doi.org/10.1007/bf02295283); [von Davier & Rost, 2016](https://doi.org/10.1201/9781315374512), *Handbook of IRT* Vol. 1). Within a class the sum score is still sufficient for $\theta$, but the *pattern* carries the class (thread `sum-score-sufficiency`). The safety valve of `guessing-priors` is the special case in which one class's model is fixed at chance ([Xiao, Ulitzsch, Zhang, Frank & Domingue, 2026](https://doi.org/10.31234/osf.io/7gtwd_v1); thread `chance-floor`). Levels or kinds? Classes that differ only in location are a continuum cut into pieces. Classes differ in kind when their difficulty profiles cross: specific objectivity holds within each class and fails between them (thread `specific-objectivity`). Pointer to `cdm` (E2): there, attributes fix the classes; here a class is defined by *which model a respondent follows*.
2. **Screening one respondent at a time, and why the screens disagree.** *(major)* The first pass is a set of person-level screens:
   - *speed*: median time per item, with the cut set by reading time (Huang, Curran, Keeney, Poposki & DeShon, 2012, doi:10.1007/s10869-011-9231-8; Wise & Kong, 2005, doi:10.1207/s15324818ame1802_2);
   - *sameness*: long string, or within-person SD (Johnson, 2005, doi:10.1016/j.jrp.2004.09.009);
   - *inconsistency*: even–odd consistency (Curran, 2016, doi:10.1016/j.jesp.2015.07.006);
   - *oddness*: Mahalanobis distance, and person fit $l_z$/$Z_h$, recalled from `person-fit` (Drasgow, Levine & Williams, 1985, doi:10.1111/j.2044-8317.1985.tb00817.x);
   - *direct checks*: instructed-response items and fake words (Oppenheimer, Meyvis & Davidenko, 2009, doi:10.1016/j.jesp.2009.03.009; Maniaci & Rogge, 2014, doi:10.1016/j.jrp.2013.09.008).

   On the Su PSS the screens split into two families that barely overlap: speed and sameness in one, oddness in the other. A straight line fits the model well, so it overfits and doesn't misfit (thread `overfit-underfit`); random answering sits far from everyone. Careless responding isn't one behaviour, and each screen sees one of them (Meade & Craig, 2012, doi:10.1037/a0028085; Niessen, Meijer & Tendeiro, 2016, doi:10.1016/j.jrp.2016.04.010). A misfitting pattern says the model doesn't describe the respondent; a mixture proposes the model that does (thread `misfit-many-causes`). The section is kept short: one table of flags and one widget.
3. **The content-free class.** *(major)* The engaged class follows the Rasch model on keyed items. The content-free class answers without regard to content, at chance or agreeing with everything. On a balanced scale that makes forward items look easy and reversed items hard ([Jin, Chen & Wang, 2018](https://doi.org/10.1177/1094428117725792); [Ulitzsch, Yildirim-Erbasli, Gorgun & Bulut, 2022](https://doi.org/10.1111/bmsp.12272); [van Laar & Braeken, 2022](https://doi.org/10.1111/jedm.12317)).
   - **Kay** (main): the mixture finds the class without being told who is in it. It sorts closely by platform, and 44% of the class passed every attention check.
   - **Su pair** (contrast): the same fast responders, measured on two keying designs. Their alpha is 0.00 on the balanced PSS and 0.93 on the all-forward PHQ-9. This returns `instrument-building`'s acquiescence widget with real respondents (threads `response-styles`, `alpha-lower-bound`, `wording-direction`, `reverse-keying`). On an all-forward scale, a content-free class looks like a high (or low) trait, so balanced keying is what makes it visible (Woods, 2006, doi:10.1007/s10862-005-9004-7; Kam & Meyer, 2015, doi:10.1177/1094428115571894; Arias et al., 2020, doi:10.3758/s13428-020-01401-8; Weijters, Baumgartner & Schillewaert, 2013, doi:10.1037/a0032121).
4. **Response styles as classes.** Extreme and midpoint responding are tendencies, not lapses: fairly stable within a respondent, and shared by every item (Baumgartner & Steenkamp, 2001, doi:10.1509/jmkr.38.2.143.18840). A **mixed partial credit model** (Rost, 1991, doi:10.1111/j.2044-8317.1991.tb00951.x) lets each class have its own thresholds. Classes that use the ends of the scale and classes that use the middle turn up in personality and attitude questionnaires: Rost, Carstensen & von Davier (1997; book chapter, no DOI, *unverified*); Eid & Rauber (2000), doi:10.1027//1015-5759.16.1.20; Hernández, Drasgow & González-Romá (2004), doi:10.1037/0021-9010.89.4.687 (the middle category); Austin, Deary & Egan (2006), doi:10.1016/j.paid.2005.10.018; Wetzel, Carstensen & Böhnke (2013), doi:10.1016/j.jrp.2012.10.010. The question to ask is whether a style class is measuring style or the trait. On the Su PSS, a 2–3 class fit is pending (to be computed at drafting; see Tables). An "if you've done `irtrees`" Recall (E2) points to the model-based separation there ([Böckenholt, 2012](https://doi.org/10.1037/a0028111) is already cited in `irtrees`).
5. **How many classes, and are they real?** *(major)* Another class always raises the likelihood. $K$ can be chosen with BIC ([Li, Cohen, Kim & Cho, 2009](https://doi.org/10.1177/0146621608326422); [Nylund, Asparouhov & Muthén, 2007](https://doi.org/10.1080/10705510701575396)) or with held-out responses (thread `imv`; [Domingue et al., 2024](https://doi.org/10.1007/s11336-024-09977-2)); on Kay, the two agree on two classes and disagree about the third. Two issues are shown, not asserted: **label switching**, where classes are named by profile and not by number ([Stephens, 2000](https://doi.org/10.1111/1467-9868.00265)), and **local maxima**, handled with several random starts (`mirt`'s `nruns`; [Chalmers, 2012](https://doi.org/10.18637/jss.v048.i06)). Classes or a continuum (thread `classes-vs-continuum`): a non-normal continuum or the wrong item model can produce classes that aren't kinds of people ([Bauer & Curran, 2003](https://doi.org/10.1037/1082-989X.8.3.338); [Lubke & Muthén, 2005](https://doi.org/10.1037/1082-989X.10.1.21)). A class needs outside evidence before it gets a name: platform, check items, a gibberish item, times.
6. **When responses can't tell, times can** (short section, about 250 words). If the disengaged pattern is one the engaged model also produces, such as every item wrong on a test with no chance floor, responses alone can't separate the classes. Response times can inform membership ([Wang & Xu, 2015](https://doi.org/10.1111/bmsp.12054); [Ulitzsch, Pohl, Khorramdel, Kroehne & von Davier, 2022](https://doi.org/10.1007/s11336-021-09817-7)). The lesson restates log time as a second outcome with an "if you've done `response-time`" callout (E2). Uses `test_taking_much_2025_mr`.

**Tools (checked).** `mirt::multipleGroup(..., dentype = "mixture-K", nruns = )` fits mixture Rasch, PCM (`itemtype = "Rasch"` on polytomous items), 2PL and GRM models, and `START`/`FIXED` syntax fixes a class. Fixing one class at $P = 0.5$ reproduces the hand-written EM of `guessing-priors` exactly, in about 30 s (sanity row). `psychomix` ([Frick, Strobl, Leisch & Zeileis, 2012](https://doi.org/10.18637/jss.v048.i07)) wasn't tried and isn't checked in webR, so it goes in *Going further* only. Neither package fits responses and times jointly, so idea 6 uses a short EM that extends `guessing-priors`' `fit_mixture()`. Every screen in idea 2 is computed by hand in a few lines. The `careless` R package (Yentes & Wilhelm) is not verified and is not needed.

**Verdict (proposed; soft and impersonal).** When a survey is balanced, or a test has a known chance rate, a two-class mixture may be sufficient for some purposes as a first look at inattentive responding. It should be fitted beside the one-class model, with its cuts and $K$ chosen before the substantive analysis, and checked against something known: instructed-response items, times, where the sample came from. The class is a hypothesis about how some respondents answered, not a verdict on who they are. When a score feeds a decision about a person, as in a campus mental-health screening, a high posterior may serve better as a reason to follow up than as a reason to delete. Aphorism candidate: a flag is a hypothesis about a person, not a finding.

**Word budget (2,000–3,000).** Roughly: What this is for + Goals 250; idea 1 450; idea 2 300; idea 3 550; idea 4 300; idea 5 350; idea 6 250; With real data 450. The following move out of the main line:
- latent DIF → problem 5;
- the balance-scale strategies → problem 2;
- the DASS all-4s respondents → problem 3;
- what to do with a flag (drop / follow up / report both / model) → the verdict plus problem 4;
- the mixture covariance algebra → Go deeper;
- the full joint RT–response model → unpaid.

## Picks up

- The safety-valve mixture $\pi P_{ij} + (1-\pi)c$, the "four ways to add guessing" ICC widget, $\hat\pi = 0.87$ on `roar_lexical`, and its open problem 6 (from `guessing-priors`; thread `chance-floor`). No ICCs are redrawn; the first widget starts from the pattern.
- Rapid responses as a property of respondents (from `guessing-priors`).
- Response-level folds and the IMV; BIC's dependence on $n$ (from `fit-prediction`; thread `imv`).
- Sum-score sufficiency (from `rasch`; thread `sum-score-sufficiency`). New use: the Kay classes have the same mean sum score, so only the pattern tells them apart.
- Specific objectivity; crossing ICCs as its failure (from `rasch`, `1pl-to-4pl`; thread `specific-objectivity`).
- Overfit vs. underfit (from `rasch`; thread `overfit-underfit`). Same-option responders have $Z_h$ ≈ +1.4 on the Su PSS: they overfit.
- Ordered classes look like a continuum cut into pieces (from `constructs`; thread `classes-vs-continuum`).
- Keying has to be checked (from `ctt-reliability`; thread `reverse-keying`). New use: the PSS codes arrive already keyed, so a straight line on the screen doesn't look like one in the data. An agree-with-everything class is consistent in the raw ratings and inconsistent once keyed. Also thread `keying-check` (from `irw-data`), for the Su landing page.
- Correlated errors push alpha above reliability (from `ctt-reliability`; thread `alpha-lower-bound`). Same-option responding is such an error: the PHQ-9's alpha is 0.93 within the fast group.
- Reliability depends on the population (from `ctt-reliability`; thread `population-dependence`). Who is included changes alpha.
- Acquiescence; all-forward vs. balanced scales; the `simAcquiescence` widget (from `instrument-building`). Proposed as a new thread, **`response-styles`**; see Promises.
- Wording direction as a second dimension (from `instrument-building`; thread `wording-direction`). The PSS's second eigenvalue falls from 3.6 to 2.3 when the fast respondents are set aside.
- Posterior = likelihood × prior; EAP (from `ability-estimation`). The class posterior is the same move.
- A misfitting pattern says the model doesn't describe the respondent, not why; person fit can't see disengagement that looks like low ability (from `person-fit`; its proposed thread `misfit-many-causes`, not yet in `lessons.yml`). $l_z$ and $Z_h$ are recalled, not retaught.
- The partial credit model and its thresholds (from `polytomous`), if Ben adds the prerequisite. Otherwise this is an E2 Recall that restates the PCM in three lines.
- E2 Recalls, not threads:
  - latent class models and EM (`cdm`);
  - log time as a second outcome, and "rapid guessing as a latent class" (`response-time`);
  - response-style nodes, and fast answers that tracked extraversion (`irtrees`);
  - DIF (`dif`);
  - the balance-scale rules (`validity-causal`, for problem 2).

**Thread legality (E2).** Checked against `lessons.yml` on 09-28. With prerequisites `guessing-priors`, `person-fit` and `instrument-building`, the ancestors are 1pl-to-4pl, ability-estimation, constructs, ctt-limits, ctt-reliability, fit-prediction, guessing-priors, information, instrument-building, irw-data, likelihood, measurement, person-fit and rasch. Every thread listed above is introduced in one of these, so every return is legal. `misfit-many-causes` and `response-styles` are legal once registered with those introducers.

## Promises / leaves open

- New thread **`response-styles`**: "Acquiescence and other response styles are shared by every item; alpha counts them as signal." Introduced in `instrument-building` (acquiescence, the `simAcquiescence` widget); returns here (the Su pair and the mixed PCM classes). `irtrees` can't return it, because `irtrees` isn't a descendant of `instrument-building`; it recalls it under E2.
- The two thread proposals from the earlier outlines, `content-free-class` and `screens-disagree`, are dropped: with the careless-responding lesson gone, neither has a return. They stay ideas of this lesson.
- A joint model of responses and item-level times (the full Wang & Xu or Ulitzsch et al. model; this lesson uses a person-level shortcut) → unpaid.
- Combining flags into one classifier (Schroeders, Schmidt & Gnambs, 2022, doi:10.1177/00131644211004708) → Going further; otherwise unpaid.
- Factor mixture models (Lubke & Muthén) → unpaid.
- Latent DIF as a fairness question (#152) → unpaid.
- Social desirability, and faking on high-stakes surveys → unpaid.
- Deep-dive candidates, unpaid:
  - the share of a content-free class across the IRW's balanced Likert tables;
  - the share of sub-second responses across the roughly 30 Likert tables with `rt`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `kay_2025_antonyms` | main example | See Kay below the table. | — |
| `su_2024_pss14` + `su_2024_phq9` | contrast (one job, two tables: the same 24,292 respondents on a balanced and an all-forward scale; precedent `rapm_poulton_2022_*`) | See Su below the table. | — |
| `test_taking_much_2025_mr` | contrast (times; idea 6) | See Much below the table. | `person-fit` (its failure case). A deliberate reuse along `misfit-many-causes`; already under `reuses:`. |
| `roar_lexical` | sanity | The safety valve refitted in `mirt`: log likelihood −25,281 vs. −25,579 for Rasch (+298), $\hat\pi = 0.87$, 16 respondents in the guessing class, as in `guessing-priors`. Held out, its IMV over the Rasch model is 0.0022, against the fixed floor's 0.0023 there. | `guessing-priors`, `response-time` (sanity tables aren't listed) |

**Kay** (main example; ideas 1, 3, 5).
- *Design.* A data-quality probe (Kay, 2025, *Behavior Research Methods* 57, 340, doi:10.3758/s13428-025-02852-7). 1,200 respondents from Connect (100), Prolific (100) and MTurk (400 + 600) rate 29 statement pairs, 26 of them antonyms ("I am an extravert" / "I am an introvert"). There are four instructed-response items (`cov_att_chk` = number failed).
- *Raw correlations.* On Connect and Prolific the extravert/introvert pair correlates −0.82. On MTurk, among those who failed at most one check, it correlates +0.18.
- *Setup.* The lesson keys the ten extraversion items by hand and cuts at "slightly agree".
- *Mixture Rasch* (10 random starts, one maximum). One class, with $\hat\pi = 0.50$, finds forward items easy ($b$ −3.6 to −1.2) and reversed items hard (+2.4 to +3.4), with $\theta$ variance 0.045. The other has difficulties near 0 (variance 0.73). The profiles cross. 88% of posteriors are beyond 0.9 or 0.1.
- *Checks.*
  - 4 of 200 Connect/Prolific respondents are in the content-free class, against 594 of 1,000 on MTurk.
  - 44% of those who passed all four instructed items are in the class (54% on MTurk), against 67% of those who failed one or more.
  - 90% of the class agree with a gibberish item ("I am ffhjhl"), against 28% of the rest.
  - On the 20 antonym pairs outside the scale, the median raw correlation is +0.28 in the class and −0.17 outside it.
  - Both classes have a mean keyed sum of 5 of 10.
- *K.* BIC 14,816 (1) → 12,340 (2) → 12,116 (3) → 12,105 (4). Held out (5 folds over responses), the IMV of 2 classes over Rasch is 0.17, and of 3 over 2 is 0.016. The 2PL alone gains 0.16 over Rasch, and the mixture adds 0.0088 over it. The reason: in the whole sample, keyed forward and reversed items correlate negatively (about −0.3), so a one-class 2PL becomes an agreement dimension.

**Su** (contrast; ideas 2, 3, 4).
- *Design.* A mandatory online mental-health screening at a Chinese medical university (Su et al., 2024, doi:10.1038/s41597-024-03888-8).
- *Timing.* Person median time on the PSS is bimodal: 17% (4,078 respondents) answer in under 1 s per item, against a main mode near 3–4 s.
- *The fast group's pattern.* A third of the fast group give one pattern: 1 on the seven stress items and 5 on the seven positive items (codes already keyed; see Data notes). This is probably the same option clicked on every screen, and it scores exactly 28 of 56, the midpoint.
- *PSS alpha.* 0.84 among slower respondents, −0.00 in the fast group and 0.79 overall.
- *PHQ-9.* On the all-forward PHQ-9, the same fast group gives all zeros 52% of the time (29% for slower respondents), and its alpha is 0.93 (0.87 slower).
- *Wording and speed.* The PSS's second eigenvalue is 3.6 with everyone and 2.3 without the fast group. Log median times on the PSS and PHQ-9 correlate 0.59.
- *Screens* (new, 09-28; a random 5,000, with each screen flagging its worst 5%). The long-string and SD screens use the inferred screen positions.
  - Speed and long string share 83 of about 250–311 flags. Mahalanobis and $Z_h$ share 129 of 250, and even–odd and Mahalanobis share 63.
  - Speed and $Z_h$ share 2, and long string and even–odd share 0.
  - Spearman correlations: 0.53 between speed and long string, 0.84 between Mahalanobis and $-Z_h$, and $|r| \le 0.21$ between speed and oddness.
  - The 311 all-same respondents (in screen positions) have median $Z_h$ = +1.4, against 0.65 overall.
- *Response styles (mixed PCM).* Pending (to be computed at drafting). Plan: 1–3 class mixed PCM (`itemtype = "Rasch"`, `nruns = 5`) on a random 3,000 slower respondents (median ≥ 1 s per item) and on 3,000 from everyone; report each class's share, category use (ends 1/5 vs. middle 3), mean keyed sum, alpha and median time, plus BIC and held-out IMV by $K$. A 09-28 attempt was stopped before it finished (script `mixture-merge/pcm_mix.R`).

**Much** (contrast, times; idea 6).
- *Design.* Matrix reasoning: 20 constructed-response items with no chance floor, given on Prolific (Much, Mutak, Pohl & Ranger, 2025, doi:10.5334/jopd.124). 1,243 respondents, of whom 231 (19%) get every item wrong.
- *Responses alone.* A two-class mixture (Rasch, plus a class with one common success rate) puts exactly the zero scorers in the second class (226; rate 0.000).
- *With times.* Adding each respondent's mean log time to the class model moves 81 slow zero scorers to the engaged class and 14 fast non-zero scorers out: $\hat\pi = 0.13$, 164 respondents, with a median of 17 s per item against 37 s.
- *Outside evidence.* 25% of the class report not understanding the task, partly or at all, against 7% of the rest. The attention checks (`cov_ac`) barely separate them: 13% of those who passed all three are in the class, against 15% of those who passed two.

**The finding.** On a balanced scale, half the respondents follow a model in which content doesn't matter, and the model finds them without being told who they are. Almost none come from the panels that screen workers, and most come from MTurk; many passed every attention check. Their sum scores match everyone else's, and only the pattern shows them. On the Su scales the same fast respondents raise the all-forward PHQ-9's alpha, zero the balanced PSS's, and make a wording factor. On the matrix test, responses alone just relabel the zeros, and times are needed to tell a fast zero from a slow one.

**Problem-only data (not worked examples; see Open questions).** `balance_mokken` (problem 2) and `depression_anxiety_stress` (problem 3).
- *balance_mokken.* Balance-scale tasks (van Maanen, Been & Sijtsma, 1989, doi:10.1007/978-3-642-83943-6_17; via `mokken`): 484 children, 25 items in five types.
  - Two crossing classes. One (36%) solves weight and conflict-weight items (0.99, 0.98) and fails distance, conflict-distance and conflict-balance items (0.28, 0.04, 0.01): Siegler's Rule I ([Siegler, 1976](https://doi.org/10.1016/0010-0285(76)90016-5); [Jansen & van der Maas, 1997](https://doi.org/10.1006/drev.1997.0437)). The other (64%) solves distance items (0.92) but only 0.44 of conflict-weight items.
  - BIC 12,129 (1) → 10,006 (2) → 9,499 (3) → 9,460 (4). The three-class fit adds a class that solves conflict-balance items (0.73).
- *depression_anxiety_stress.* A voluntary online DASS-42 (Open-Source Psychometrics Project; 39,775 respondents who said their answers were accurate).
  - 249 respondents gave one answer to all 42 items: 123 answered all 4s and 110 all 1s. Their median time is 1.6 s, against 3.6 s overall.
  - Among the all-4s respondents, 29% checked a fake word.
  - In a random 5,000, the screens split as on Su: $Z_h$ and Mahalanobis overlap on 122 of 250 flags, long string and speed on 85, and $Z_h$ and long string on 0. This is a replication, which is why the DASS isn't a worked example.

**Keying and data notes.**
- *Kay.*
  - `resp` is the raw −3…+3 rating (OSF survey PDF).
  - `_x`/`_r` marks the member of the pair, not the trait's direction (`cntr_005_x` is "I keep in the background"), so items are keyed from their wording.
  - `blue` and `gibb` aren't antonym pairs; `pets` and `sick` are weak ones.
  - Script `data/kay_2025_antonyms.py` keeps `finished == 1`; no waves.
  - No times in the table.
- *Su PSS keying.*
  - In the deposit's `score` column, score = Σ(code − 1) for every row, and reversing the positive items (4, 5, 6, 7, 9, 10, 13) matches only 4.7% of rows. So the stored codes are already keyed, with higher meaning more stress. The IRW script keeps them as deposited, and the landing page doesn't say they are keyed.
  - Among slower respondents, item 12 correlates −0.14 to −0.25 with the positive items. That is a fact about fit, to be checked against the Chinese version's scoring.
  - The display order of the response options is not verified in the authors' GitHub repository. Until it is, "same option on every screen" is an inference.
- *Su timing and order.* RT is in seconds. Items were given in a fixed order (demographics → PHQ-9 → GAD-7 → PSS → ISI; paper, Methods). The deposit records no withdrawals.
- *Much.*
  - 1 = correct.
  - This table drops omitted responses (35 respondents have fewer than 20). Its scores match `much_tte_2025_matrixreasoning` exactly: the same zero scorers, and sums that correlate 1.00.
  - No processing script is found in `ben-domingue/irw/data`.
- *Balance.* 1 = correct. Script `data/mokken.R` copies `mokken::balance` unchanged.
- *DASS.*
  - Items were shown in a random order for each respondent, and the IRW table drops the position columns, so a long string in item-number order isn't what the respondent saw.
  - Items are 1–68 with no labels: 1–42 DASS, 43–52 TIPI, 53–68 checklist. The fake words are at 58, 61 and 64. Only the DASS items have times.
  - The source kept only respondents who answered "yes" to an accuracy question, so a self-report screen was already applied.
- *Instrument sources (Crossref 09-28).*
  - PSS: Cohen, Kamarck & Mermelstein (1983), doi:10.2307/2136404.
  - PHQ-9: Kroenke et al. (2001), doi:10.1046/j.1525-1497.2001.016009606.x.
  - DASS: Lovibond & Lovibond (1995), doi:10.1016/0005-7967(94)00075-U.

## Widget / simulation / problem ideas

**Widgets**
- *Whose pattern is it?* (idea 1). Click a pattern on ten balanced items to see its likelihood under the engaged and content-free classes, the shares and the posterior. Two patterns with the same sum get very different posteriors.
- *Which screen sees which?* (idea 2). Simulate random, straight-line and fast-but-reading respondents. A grid shows each screen's detection rate by type (time, SD, even–odd, Mahalanobis, $l_z$). The earlier *Too fast to read* widget folds in as its time-cut slider.
- *Balanced or all-forward?* (idea 3; returns `simAcquiescence`). A slider for the size of a same-option or agree-with-everything class, and a toggle for the keying. It shows alpha for both designs, the antonym correlation, the second eigenvalue and the class profile. With all-forward keying, the class sits at an end of the trait.
- *Levels, kinds or styles?* (ideas 4–5). Two classes' category-use or difficulty profiles, on a slider from "shifted" (stacked) to "crossing" to "same location, different thresholds" (a style). A toggle draws $\theta$ from a skewed distribution, and a two-class fit finds a "class" anyway (precomputed, seeded).
- *How many classes?* (idea 5). BIC and held-out IMV against $K$ for simulated data. A rerun button swaps labels and sometimes stops at a lower maximum.

That makes five widgets. *Fast zero, slow zero* (idea 6) is a static figure, or it replaces *Levels, kinds or styles?* if Ben prefers.

**Predict-then-check** (in With real data): "Among Kay respondents who passed all four instructed-response items, what share does the mixture put in the content-free class: almost none, about one in ten, or more than a third?" The answer is 44% (54% on MTurk, 2% on Connect/Prolific), printed by the cross-tabulation. An optional second one in Core ideas, tied to the *Balanced or all-forward?* widget, asks for the fast group's alpha on the PHQ-9 and the PSS (0.93 and 0.00).

**Simulate.** 1,000 respondents answer ten balanced items: 80% follow the Rasch model, and 20% agree with any item with probability 0.8. Fit Rasch and a two-class mixture in `mirt` (`nruns = 3`), and compare $\hat\pi$, the profiles and the assignments with the truth. Change the seed and watch the labels swap; fit $K = 3$ and read BIC. Then compute the screens (time from a lognormal, SD, Mahalanobis) on the same data and cross-tabulate them against the true class. Then set the agreement probability to 0.5 (random responding, which is harder to find), or key everything forward. Check the time in the browser at drafting.

**Problems**
1. *Derivation.* Write the posterior class probability under a two-class mixture Rasch model. Show that within a class it depends on $\theta$ only through the sum, and that the class posterior depends on the pattern. Then, on a balanced 2k-item 1–5 scale, show that a same-option responder always scores the midpoint. What happens on an all-forward scale, and with acquiescence of size δ added to every raw response?
2. *Real data with a twist: strategies* (`balance_mokken`). Fit two and three classes to the balance-scale tasks. Do the classes cross, and do they match Siegler's rules ("if you've done `validity-causal`")? What would make a class a strategy rather than a level?
3. *Judgment, gentle* (`depression_anxiety_stress`). 123 respondents answered 4 ("applied to me very much") on all 42 DASS items. Is this a straight line, or severe distress? Use time (median 1.6 s), fake words (29% checked one) and the design, which used random item order. What can't the data tell, and what would you do in a campus screening where a person's score feeds a follow-up?
4. *Design.* Plan a 20-item survey on which both screens and a mixture can find inattentive respondents: keying, antonym pairs, instructed items, fake words, timing. Say what each buys and set the cuts before collecting data. Then a colleague drops everyone in the Kay content-free class before correlating extraversion with political orientation (`cov_poli_cont`). What changes, and what should happen to posteriors near 0.5 (Credé, 2010, doi:10.1177/0013164410366686)?
5. *Real data: latent DIF.* Which Kay items function differently between the classes, and does the class line up with the platform (Cohen & Bolt, 2005, doi:10.1111/j.1745-3984.2005.00007; "if you've done `dif`")? When is a class an observed group under another name? Also: refit on the neuroticism pairs (`mood`, `upst`, `rlxd`). Is the content-free class a property of the respondent or of the scale?
6. *Challenge (open).* Fit the mixture GRM or PCM to the 7-point Kay ratings (preliminary GRM: BIC 39,110 → 36,979 with two classes; one class answers every pair alike) and look for style classes beside the content-free one. Does the gain survive against a skewed continuum? I don't know of a general test that tells a real class from a non-normal continuum.

## Go deeper

- **Why the pattern, not the sum, carries the class.** Under the mixture Rasch model $\Pr(\mathbf{x} \mid r, k) = \exp(-\sum_i x_i b_{ik})/\gamma_r(\mathbf{b}_k)$. So the class posterior depends on the pattern through each class's conditional likelihood, and on the sum through the class's score distribution (Rost's 1990 conditional formulation). Why: it extends `sum-score-sufficiency` and is the basis of problem 1. Length: half a page.
- **A contaminating class's covariance.** For a two-class mixture, $\Sigma = \pi\Sigma_1 + (1-\pi)\Sigma_0 + \pi(1-\pi)(\mu_1-\mu_0)(\mu_1-\mu_0)^\top$. A same-option class adds a rank-one term along the keying vector: on an all-forward scale it lies along the first factor, and on a balanced scale it becomes a wording factor. This is the algebra behind the Su alphas and the second eigenvalue. Why: `alpha-lower-bound`, `wording-direction`; `fa-exploratory` could use it for wording factors. Length: half a page.

## Open questions

- **Prerequisites.** *Default:* `guessing-priors`, `person-fit`, `instrument-building`, and add `polytomous`. The PCM is needed for idea 4 and problem 6, and `polytomous` adds no other ancestors. Alternative: leave `polytomous` out and restate the PCM in an E2 Recall. `response-time` stays out, with an "if you've done" callout; adding it would bring `explanatory-irt` into the chain.
- **Scope after the merge.** Six ideas in 2,000–3,000 words is tight. *Default:* ideas 2 (screens) and 6 (times) are short sections of about 300 and 250 words. Latent DIF, strategies, the DASS case and "what to do with a flag" go to problems, and the covariance algebra goes to Go deeper. Alternative: make idea 6 a problem and keep Much as the reuse only there.
- **Idea 2 on Su, not the DASS.** The two-families finding reproduces on the Su PSS, so the DASS isn't needed as a worked example. *Default:* Su for idea 2, and the DASS as problem 3 only.
- **Problem-only tables.** `balance_mokken` and `depression_anxiety_stress` are loaded only in problems (and their solutions). *Default:* they don't count against the ceiling of three and aren't listed under `tables:`. The lesson links their landing pages, and the problem text says how to load them. If Ben counts them as loads, drop the DASS problem, and problem 3 uses the Su fast respondents (all-zero PHQ-9 in 0.4 s per item) instead.
- **Two Su tables as one job** (precedent `rapm_poulton_2022_*`). *Default:* yes. Otherwise drop `su_2024_phq9` and describe the all-forward side with the widget only.
- **Su carries three ideas (2, 3, 4).** *Default:* keep it, since it is one population read three ways. Alternative: move response styles to Kay's 7-point ratings (problem 6) and keep Su for ideas 2–3.
- **New thread `response-styles`**, introduced in `instrument-building`. *Default:* register it, with its return here. `instrument-building`'s *For instructors* currently says response styles such as extreme responding are "modelled in `irtrees`". It could add a pointer to this lesson.
- **Thread `misfit-many-causes`** depends on `person-fit` registering it. *Default:* yes, per the person-fit outline.
- **Dichotomizing the Kay ratings.** *Default:* cut at "slightly agree or more". The mixture GRM/PCM is problem 6.
- **The Kay paper's title** ("Why you shouldn't trust data collected on MTurk") is a claim about a platform. *Default:* cite it plainly, and keep the lesson's words about how some respondents answered, not about the platform or its workers (PROTOCOL §2). Likewise the Su respondents are students in a mandatory screening, and the text says so gently.
- **Verdict** as above (soft, impersonal). *Default:* use it.
- **Notation.** *Default:* classes $k = 1, \dots, K$, shares $\pi_k$ and class difficulties $b_{ik}$, added to the lesson-local table. `cdm` indexes classes by $c$, which clashes with the lower asymptote once a mixture has guessing, and $k$ is the number of options in `guessing-priors`. PCM thresholds follow `polytomous`, so a class's thresholds are $b_{ik\ell}$ or are written per class in words.
- **No EDUC 252 source.** The anatomy is unchanged. *For instructors* says the lesson is new, names the Handbook chapter as its spine, and says the careless-responding lesson was folded in (Ben, 09-28).
- **Not used:** `vollbracht_et_al_2026_ambulatory_assessment` (ESM data with a `cov_careless` flag and 151-point sliders); `much_tte_2025_matrixreasoning` + `_effort` (the same respondents as the Much table, with self-reported effort).
- **IRW data (for the IRW side, not the lesson):**
  - `su_2024_pss14`: note on the landing page that the codes are already keyed.
  - `depression_anxiety_stress`: keep item position and item labels.
  - `kay_2025_antonyms`: the landing page gives the author as "ay, C.S." and the language as "ger" (Crossref: Cameron S. Kay; the survey is in English).
  - `test_taking_much_2025_mr`: no processing script found.
  - `gcbs_brotherton_2013` (not used): `rt` looks like milliseconds (median 5,913); its script doesn't convert.
  - IRW's title for van Maanen et al. (1989) differs from Crossref's ("The Linear Logistic Test Model and heterogeneity of cognitive strategies").

**Unverified or partly verified.**
- Rost, Carstensen & von Davier (1997), "Applying the mixed Rasch model to personality questionnaires", in Rost & Langeheine (Eds.), *Applications of latent trait and latent class models in the social sciences* (Waxmann): no DOI on Crossref, and the details are not checked against the book. The other response-style sources above were checked on Crossref.
- von Davier & Rost (2016): only the book DOI is on Crossref. The chapter title and pages come from `cdm`'s *Going further*.
- The Kay paper itself wasn't read (it is paywalled from here); the design comes from the OSF survey PDF and the analysis code.
- The display order of the Su response options (see Data notes).
- Cohen & Bolt (2005): the DOI resolves without the usual `.x`.
- The `careless` R package (not needed).
- Böckenholt (2012) is taken from `irtrees`' citations, not re-checked here.
- The mixed PCM response-style numbers: pending (to be computed at drafting). Whether Su shows extreme or midpoint classes at all is unknown; if it doesn't, idea 4 moves to Kay's 7-point ratings (problem 6) or rests on the cited studies.
