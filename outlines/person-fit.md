<!-- Outlined 2026-09-28 from #153 (Ben approved the lesson 09-28). Source chapter: Glas & Khalid, "Person fit", Handbook of IRT Vol. 3 (2018), ch. 6. Preliminary numbers come from a scratch analysis run on 09-28 (R, mirt 1.4x, PerFit 1.4.7), with tables read from their tokenless CSVs. Sébastien Béland is to be tagged on this outline; Ben adds the handle: @<handle>. -->

# Person fit: does a respondent's pattern fit the model? (`person-fit`)

Module: irt · Prereqs: fit-prediction, ability-estimation · Extension · Status: stub (outlined)

## Core ideas

1. **A score can be ordinary while its pattern is not.** Two respondents with the same sum score can differ a lot in which items they got right. Ordered by difficulty, a pattern that misses easy items and gets hard ones right contains *Guttman errors*. Counting them (normalized, $G^*$) or using U3 needs no fitted model. *(major)* Sources: Guttman (1944), doi:10.2307/2086306; Meijer (1994), doi:10.1177/014662169401800402; van der Flier (1982), doi:10.1177/0022002182013003001; Harnisch & Linn (1981), doi:10.1111/j.1745-3984.1981.tb00848.x.
2. **Model-based indices: person outfit, infit and $l_z$.** Outfit and infit are the item statistics from `rasch` and `fit-prediction`, averaged over a respondent's items instead of an item's respondents. $l_z$ standardizes the log-likelihood of the pattern at $\hat\theta$: $l_z = (l_0 - E[l_0])/\sqrt{\text{Var}(l_0)}$. Below 0 the pattern is less likely than the model expects (underfit); above 0 it is more predictable than expected (overfit). *(major)* Sources: Wright & Masters (1982), cited as in `fit-prediction` (rasch.org/rsa.htm); Levine & Rubin (1979), doi:10.3102/10769986004004269; Drasgow, Levine & Williams (1985), doi:10.1111/j.2044-8317.1985.tb00817.x; `mirt::personfit` (Chalmers, 2012, doi:10.18637/jss.v048.i06).
3. **Estimating θ from the same responses shrinks the null distribution.** With $\hat\theta$ in place of θ, $l_z$ has variance below 1, so a cutoff of −1.645 flags fewer than 5%. Snijders's $l_z^*$ corrects the mean and variance for ML, WLE and Bayes modal $\hat\theta$. With simulated 2PL data, $l_z$ at the ML $\hat\theta$ has SD 0.83–0.89 and flags 3–4% at 10, 24 and 170 items, while $l_z^*$ has SD 1.00–1.02 and flags 5.3–5.7%. A longer test does not remove the shrinkage. Perfect patterns get no statistic at all. *(major)* Sources: Snijders (2001), doi:10.1007/BF02294437; Nering (1995), doi:10.1177/014662169501900201; Magis, Raîche & Béland (2012), doi:10.3102/1076998610396894; Molenaar & Hoijtink (1990), doi:10.1007/bf02294745 (skewed nulls in short tests; the true-θ $l_z$ flags 7.8% at 10 items).
4. **Power depends on the kind of aberrance and on the test.** Random responding, preknowledge of a few items, guessing by low scorers and a shifted construct leave different traces. A global index built on all items has little power when only a few items are affected, and a respondent who answers nothing correctly looks like a low-ability respondent, not a misfitting one. Sources: Karabatsos (2003), doi:10.1207/S15324818AME1604_2; Meijer & Sijtsma (2001), doi:10.1177/01466210122031957.
5. **What can misfit mean?** Possible causes include carelessness, cheating or preknowledge, guessing, a different construct (the respondent answers another question than the one the scale asks), or a model that is wrong for this respondent (their item parameters differ). A flag starts an inquiry; the pattern alone can't say which cause applies. Overfit is also a possible finding. *(major)* Sources: Glas & Khalid (2018), Handbook of IRT Vol. 3, ch. 6, pp. 107–126 (see *Unverified*); Meade & Craig (2012), doi:10.1037/a0028085; Niessen, Meijer & Tendeiro (2016), doi:10.1016/j.jrp.2016.04.010; Reise & Waller (1993), doi:10.1037/0022-3514.65.1.143; Cizek & Wollack (2016), doi:10.4324/9781315743097; Rost (1990), doi:10.1177/014662169001400305.

**Tool:** PerFit (Tendeiro, Meijer & Niessen, 2016, doi:10.18637/jss.v074.i05). It implements $l_z$, $l_z^*$, $G^*$, U3 and polytomous versions, with cutoffs set by bootstrap. See also the practical guide by Meijer, Niessen & Tendeiro (2016, *Assessment* 23, 52–62; online 2015), doi:10.1177/1073191115577800.

**Verdict (proposed, soft):** if the question is whether a respondent's score can be reported as usual, $l_z^*$ at a WLE or ML $\hat\theta$, read alongside $G^*$, may be sufficient for some purposes as a first screen. A flag is a reason to look at the pattern, not a finding about the respondent. The licensure table in *Tables* shows why: the respondents the program flagged fit the model slightly *better* than everyone else.

**Unverified:** the Glas & Khalid chapter is not in Crossref, and its chapter DOI does not resolve. The chapter number (6) and authors are confirmed by a Technometrics review of Vol. 3 (Lipovetsky, 2021, doi:10.1080/00401706.2021.1945327). The page range 107–126 comes from a secondary citation. The volume's DOI is 10.1201/9781315117430 (Crossref, 2017-12-15). Every other DOI above was checked on Crossref (09-28), with no mailto.

## Picks up

- Outfit and infit, and misfit read as overfit or underfit (thread `overfit-underfit`, from `rasch`). Here they are turned around to describe respondents.
- The null distribution of outfit, and "estimated parameters pull a fit statistic toward the data". EAP abilities push outfit below 1 (from `fit-prediction`: its Go deeper and Simulate section). Idea 3 is the person-side version of the same point.
- Size vs. significance: a $z$ says whether a departure could be chance, not whether it matters (from `fit-prediction`).
- MLE, WLE and EAP. The WLE removes the MLE's first-order bias (from `ability-estimation`). $l_z^*$ is defined for ML and WLE $\hat\theta$.
- Perfect patterns have no MLE (thread `perfect-patterns`, from `ability-estimation`). They get no person-fit statistic either.
- EAP shrinks toward the mean (thread `shrinkage`, from `ability-estimation`). The shrinkage biases person outfit and $l_z$.
- The likelihood of a response pattern at a given θ (from `ability-estimation`'s first widget). $l_0$ is that log-likelihood.
- Sum-score sufficiency and conditioning on $r$ (threads `sum-score-sufficiency`, `conditional-ml`, from `rasch`). Under the Rasch model the distribution of patterns given $r$ is free of θ, which gives exact person-fit tests (Go deeper).
- Brief "if you've done" Recalls (E2; not threads): response times as another route to aberrant behaviour, and the `credentialform_lnirt` flags (`response-time`, its problem 3); the two-class safety valve (`guessing-priors`); DIF (`dif`), for the overfit tail in the licensure table.

**Threads this lesson could start:**
- `misfit-many-causes`: "A misfitting pattern says the model doesn't describe this respondent, not why." It would return in `careless-responding` (screening) and `mixture-models` (a class that follows another model), but only if Ben makes `person-fit` a prerequisite of each (see *Open questions*). Otherwise they recall it briefly.
- `estimated-theta-null`: "Estimating θ from the same responses narrows a fit statistic's null." No descendant returns to it yet.

## Promises / leaves open

- Screening for careless responding with person-fit indices alongside long strings, attention checks and response times → `careless-responding` (being outlined in parallel).
- Model-based detection: inattentive respondents as a latent class with their own measurement model → `mixture-models` (#189, being outlined in parallel). The mixture Rasch model is the idea-5 cause "a model that is wrong for this respondent", made into a model.
- Using response times to find preknowledge (van der Linden & Guo, 2008, doi:10.1007/s11336-007-9046-8) → unpaid. `response-time` is not an ancestor, so this is a pointer only.
- Person fit for polytomous items (Emons, 2008, doi:10.1177/0146621607302479; Sinharay, 2016, doi:10.1007/s11336-015-9465-x) → a problem here; otherwise unpaid.
- Bayesian person fit with posterior predictive checks (Glas & Meijer, 2003, doi:10.1177/0146621603027003003) → *Going further*; unpaid.
- Across the IRW: how often does $l_z^*$ fall below −1.645 more often than the nominal 5%, and does the excess belong to respondents or to the model? → optional (problem 6, and a candidate deep dive). Not built.
- Group-specific item parameters as a cause of person misfit (the overfit tail below) → `dif` has the machinery; mention only.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `credentialform_lnirt` | main example | Licensure exam (Cizek & Wollack, 2016, from IRW biblio), 1,636 respondents, scored items 1–170 only, 2PL. $l_z$ at the ML $\hat\theta$: SD 0.76, 2.0% below −1.645. $l_z^*$: SD 1.10, 7.9% below. Idea 3 on real data, with some real misfit left over. The 46 respondents the vendor flagged have *higher* mean $l_z^*$ than the rest (0.40 vs. 0.01; 4 of 46 below −1.645): a global index on 170 items doesn't find them. The overfit tail is larger for respondents educated in India or the Philippines (19–20% above +1.645, against 5% for the USA) and for repeat takers. Spearman correlations: $l_z^*$ with $G^*$ −0.61, with infit −0.96. | `response-time` (main example). A deliberate reuse, but not a thread (not an ancestor); needs Ben's OK (see *Open questions*). |
| `psychtools_epi` | contrast | Eysenck Personality Inventory (Eysenck & Eysenck, 1968, from IRW biblio), neuroticism scale (24 items), 3,269 respondents with complete answers and a score strictly between 0 and 24; 2PL. $l_z^*$ flags 8.9% at −1.645. The share rises with the Lie scale: 5.4% (Lie 0–2), 10.6% (3–4), 19.2% (5–9). That is idea 5's "different construct" with a measure of it built into the instrument. By sum score the share stays between 5% and 11%, so the gradient isn't a score effect. | — |
| `test_taking_much_2025_mr` | failure case | Matrix reasoning, 20 items, 1,178 complete respondents (Much, Mutak, Pohl & Ranger, 2025, doi:10.5334/jopd.124). 19% answer every item wrongly and have no statistic. Of the 29 who reported not understanding the task at all, 20 scored 0. Among those with a statistic, $l_z^*$ barely tracks self-reported disruptions or the attention checks. Person fit can't see disengagement that looks like low ability. | — (but `careless-responding` may want it for its attention checks; see *Open questions*) |
| simulated 2PL data | sanity | $l_z^*$ SD 1.00–1.02, 5.3–5.7% below −1.645 at 10, 24 and 170 items; $l_z$ at the ML $\hat\theta$ SD 0.83–0.89. | — |

**Data notes (processing scripts read):**
- **`credentialform_lnirt`** (`data/lnirt.R`): columns 171–200 are pilot slots. Each holds whichever pilot set a respondent received, so one "item" mixes different items. The lesson uses items 1–170, as `response-time` did. The vendor's list of compromised items is not in the IRW table, so it can't be used.
- **`psychtools_epi`** (`data/psychtools.R`): psychTools codes 1 = yes, 2 = no, and the script subtracts 1, so **in the IRW table 1 means "no"**. This was checked against item wording and endorsement rates (for example, 83% say yes to having thoughts they wouldn't like others to know). The lesson reverses the coding once, where the data are introduced. The neuroticism items are all keyed the same way. The Lie scale has six reversed items (psychTools `epi.keys`). 4,746 missing responses; 285 respondents with any missing neuroticism item are dropped.
- **`test_taking_much_2025_mr`**: no script is listed in `metadata/table_scripts.csv`. Items `Y_MRm01` and `Y_MRt01–06` are training items and are dropped. The two ten-item blocks differ in speed instruction, and the order of the blocks is counterbalanced (`cov_group`). The `rater` column is not documented at the source. Worth a gentle note to the IRW maintainers.

## Widget / simulation / problem ideas

**Widgets**
- Guttman pattern: items sorted by difficulty; click to set responses; see the Guttman error count, $G^*$, person outfit and $l_z$ for patterns with the same score (ideas 1, 2).
- Same score, different likelihoods: $l_0$ against its expectation for every pattern with $r$ correct, with the Rasch model and the 2PL (idea 2).
- True θ vs. $\hat\theta$: histograms of $l_z$ at the true θ, at the ML $\hat\theta$, and of $l_z^*$; slider for test length; share below −1.645 (idea 3). Numbers checked against the scratch simulation.
- Aberrance generator: choose random responding, preknowledge on *k* hard items, guessing by low scorers, or a shifted construct; see the power of $l_z^*$, $G^*$ and outfit at a 5% cutoff (ideas 4, 5).

**Predict-then-check:** "The vendor flagged 46 licensure respondents for suspected inappropriate behaviour. Will their $l_z^*$ be lower than everyone else's?" The output answers: no. Their mean is 0.40 against 0.01, and 4 of 46 fall below −1.645.

**Simulate:** 2PL data (1,000 × 20); replace 5% of respondents with one kind of aberrance; fit `mirt`; compute $l_z$ (`personfit`) and $l_z^*$. $l_z^*$ is computed by hand in about 15 lines, which also shows the correction. Compare the null rate on clean respondents with the detection rate on the replaced ones. Seconds in the browser.

**Problems**
1. Derivation: $E(l_0)$ and $\text{Var}(l_0)$ for known θ; show why they are wrong at $\hat\theta$ (first-order argument, after Snijders).
2. Real data with a twist: repeat the EPI analysis on extraversion, whose items run both ways and whose IRW coding is 1 = "no". Does the Lie gradient hold?
3. Judgment: a licensure program proposes to review everyone with $l_z^* < -1.645$. At 7.9% of 1,636, that is about 129 people. What should a review look for, and what would a flag not justify?
4. Design: preknowledge of 20 of 170 items. Why is a global index weak? Design a statistic on a suspected subset and simulate its power (Cizek & Wollack, 2016).
5. Real data: the overfit tail in `credentialform_lnirt` (India, the Philippines, repeat takers). What could make patterns more predictable than the model expects? Check whether a 2PL fitted within each group changes the picture.
6. Challenge (open): across the IRW, how often does $l_z^*$ exceed its nominal rate, and is the excess about respondents or about the model? (Possible deep dive; not built.)

## Go deeper

- **Why $\hat\theta$ shrinks $l_z$, and Snijders's correction.** A first-order expansion of $l_0$ around θ; the ML score equation removes the component of $l_0$ along the score function; $l_z^*$ puts that back through a weighted correction term. Why: the null for any person-fit statistic used later (`careless-responding`, `mixture-models`); the person-side twin of `fit-prediction`'s outfit Go deeper. Length: about a page.
- **Exact person fit under the Rasch model.** Given $r$, the pattern's distribution is free of θ (sufficiency), so a pattern's probability can be compared with all patterns with the same score, with no estimate at all (Molenaar & Hoijtink, 1990). Why: pays off `sum-score-sufficiency` and `conditional-ml` on the person side. Length: half a page. Candidate; the depth pass (#10) chooses.

## Open questions

- **Prerequisites.** Default: `fit-prediction` and `ability-estimation` (both core; `rasch` comes through both). `ability-estimation` is needed because $l_z^*$ is defined through the ML and WLE estimators and because of perfect patterns.
- **Reusing `credentialform_lnirt`.** `response-time` already loads it, and `response-time` isn't an ancestor, so this is a reuse without a thread. It is the only IRW table with a respondent-level flag for suspected cheating. Default: reuse it, record it under `reuses:`, and add an "if you've done `response-time`" Recall. Alternative main example: `difnlr_msatb` (20 items, 1,407 respondents; not explored).
- **Coordination with `careless-responding`.** `test_taking_much_2025_mr` has attention checks and self-reported disruptions, which suit screening. Default: `person-fit` keeps it as a failure case. If `careless-responding` wants it as a main example, this lesson drops it and keeps two tables.
- **Should `careless-responding` and `mixture-models` list `person-fit` as a prerequisite?** Without that, `misfit-many-causes` can't return in them as a thread (E2). Default: yes for `careless-responding`, no for `mixture-models`.
- **Deep dive.** Default: none. The across-IRW question is problem 6 and a candidate for later.
- **webR.** PerFit is on the webR repository, but its dependencies (Hmisc, fda, irtoys, ltm) are heavy. Default: compute $l_z^*$ by hand in the browser and use PerFit in the downloadable `-irw.R`.
- **Sébastien Béland** to be tagged on this outline (Ben adds the handle). Magis, Raîche & Béland (2012) is cited in idea 3.

## Drafting notes (09-28)

What the draft changed from this outline:

- **Numbers.** The drafted code (`lessons/code/person-fit-irw.R`) differs slightly from the scratch analysis: licensure $l_z^*$ SD 1.14 (not 1.10), 7.8% below and 7.6% above ±1.645; flagged mean 0.39. EPI: 3,232 respondents complete on the neuroticism *and* Lie items, 3,216 with a score strictly between 0 and 24, 8.8% flagged (not 3,269 and 8.9%). The Lie gradient (5.4%, 10.6%, 19.2%) holds within every neuroticism band above 6 and reverses in the lowest band, which the lesson says.
- **Overfit tail (licensure).** The draft no longer suggests that the items discriminate more sharply for India- and Philippines-educated respondents. A check for the solutions (problem 5) found that with group-specific 2PLs the non-USA tail above +1.645 falls to 6.4%, but with USA-only parameters 44% of non-USA respondents fall *below* −1.645. The lesson now says only that some items may work differently in these groups (DIF), so the pooled parameters don't describe them.
- **Matrix reasoning.** Kept as the failure case. The 58 respondents who reported not understanding the task have a *higher* mean $l_z^*$ (0.39) than those with no issues (0.13).
- **Widgets.** Four: Guttman errors; same score, different likelihoods (the outline's second widget, now plotting $l_z$ against Guttman errors for every same-score pattern, Rasch or 2PL); $l_z$ at the true θ vs at $\hat\theta$ vs $l_z^*$ by test length; the aberrance generator, with cutoffs set by simulating clean respondents.
- **Both Go deeper candidates** are in: Snijders's correction, and exact person fit under the Rasch model.
- **Dropped:** the "if you've done `guessing-priors`" Recall (the two-class safety valve) for length; `careless-responding` is not in `lessons.yml`, so *For instructors* mentions careless-responding screens without a link.
- **PerFit** appears only in the downloadable `-irw.R` (last chunk, not shown on the page); the page and webR compute $l_z$, $l_z^*$ and $G^*$ by hand, checked against `mirt::personfit` (`Zh`, exact) and PerFit (to 1e-4).
