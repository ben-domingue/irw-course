<!-- Outlined 2026-09-24 from EDUC 252 slides c2 (slides 3–17). Tidied 09-24 (#62): Ben's answers C4 and A5 applied; settled questions folded into the body; citations verified. -->

# Constructs and construct maps (`constructs`)

Module: ctt · Prereqs: measurement · Core · Status: draft (#30)

## Core ideas

References verified 09-24 against Crossref unless noted; the table citation is from IRW biblio.

1. **A construct is how we operationalize what we can't grasp.** *(major)* Cronbach and Meehl (1955, *Psychological Bulletin* 52(4), 281–302, doi:10.1037/h0040957): a postulated attribute, reflected in test performance, carrying statements of the form "people with this attribute, in situation X, act in manner Y (with a stated probability)".
2. **A construct map.** *(major)* Wilson's simpler version: an underlying continuum with qualitatively described levels, on which items and respondents sit in the same space (the picture IRT will draw) (Wilson, 2005, *Constructing Measures*, Erlbaum, doi:10.4324/9781410611697; Crossref dates the Routledge DOI 2004). Worked example: California's Desired Results Developmental Profile (DRDP), a developmental continuum built with the BEAR Center (California Department of Education, https://www.desiredresults.us/; verified on the web, no DOI).
3. **Two tests for a proposed construct.** Does the map order the items before you see data? Does it suggest an intervention, a plan for "increasing" the construct? c2 slide 11 sets two descriptions side by side:
   - a construct map for the Earth in the Solar System, five levels each describing what a student understands (Briggs, Alonzo, Schwab & Wilson, 2006, *Educational Assessment* 11(1), 33–63, doi:10.1207/s15326977ea1101_2, Figure 2, © WestEd 2002: paraphrase and cite, don't reproduce);
   - NAEP grade 4 achievement-level descriptors for geography (Basic, Proficient, Advanced), each a list of things students "should be able to" do (National Assessment Governing Board, *NAEP Achievement Levels for Geography 1992–1998*, https://www.nagb.gov/content/dam/nagb/en/documents/publications/achievement/naep-geography-achievement-levels-1992-1998.pdf).

   Verdict (agreed with Ben, 09-24): the astronomy map comes much closer to the ideal, because each level names the misconception to overcome next (the figure's "common errors"; show some), so it implies what to teach. The descriptors list performances with no account of how a student moves between them.
4. **Continuous or categorical?** *(major)* Latent classes (Moffitt's taxonomy of antisocial behaviour; Moffitt, 1993, *Psychological Review* 100(4), 674–701, doi:10.1037/0033-295X.100.4.674) vs. a continuum. My prior is that variation is much more often continuous; taxometric research mostly finds dimensions (Haslam, Holland & Kuppens, 2012, *Psychological Medicine* 42(5), 903–920, doi:10.1017/S0033291711001966).
5. **A different starting point: blueprints.** Licensure, admissions and K–12 tests often sample a domain to a specification, not a construct map (AERA, APA & NCME, 2014, *Standards for Educational and Psychological Testing*, ch. 4; no DOI, verified at aera.net and ERIC ED565876); sometimes that is a bureaucratic minimum standard (the driving test).

## Picks up

- Latent vs. manifest; constructs; probes (from `measurement`).
- Measurement as discovery (the thermometer) (from `measurement`).

## Promises / leaves open

- Items and people on one scale → `rasch` (Wright map), `information`.
- The construct map orders the items: checked against data → `rasch`, `validity-evidence`; the number-series ordering as a sanity check → `ai-psychometrics`.
- The construct is unidimensional → `fa-exploratory`, `dimensionality`.
- A scale meant to measure one thing, and how consistently it does → `ctt-reliability`.
- From map to items → `instrument-building`.
- Latent classes → `cdm` (latent class analysis, with cognitive diagnosis as its restricted case); mixture IRT otherwise unpaid.
- The construct suggests an intervention → `validity-causal` (Borsboom's causal view), `invariance-experience`.
- Blueprints and domain sampling → `validity-argument` (content evidence), `validity-evidence`, `g-theory` (items as a facet).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `himmelstein-number_series-2025` | main example | Nine number-series items from the Forecasting Proficiency Test (Himmelstein et al., 2025, PsyArXiv, doi:10.31234/osf.io/a7kdx_v8; CC BY 4.0), 569 respondents in the first wave. Proportions correct run from 0.84 (NS_2, "3, 6, 10, 15, 21, ___") to 0.02 (NS_6, "200, 198, 192, 174, ___", differences that triple). A construct map of pattern complexity (constant difference → growing difference → multiplicative → interleaved → fractions) orders most items correctly before any data. | sanity in `ai-psychometrics` |

One table: the lesson is conceptual. Item text (A5): the items are openly licensed, so the lesson shows them in full from the item-text snapshot, after confirming the source licence matches the IRW page (E6). Numbers from the 09-24 outline pass (not recomputed). Sanity: none (no model is fitted).

## Widget / simulation / problem ideas

**Widgets**
- Build a construct map: drag number-series items onto levels, then reveal their proportions correct (ideas 2, 3).
- DRDP explorer: a developmental continuum with descriptors at each level (idea 2).
- Which description suggests an intervention? The astronomy map and the geography descriptors side by side; pick a student at each level and say what you would teach next (idea 3).
- Continuum or classes? Simulated sum-score histograms from a continuous trait vs. a four-class mixture; can you tell which is which? (idea 4)

**Predict-then-check:** rank the nine number-series items from easiest to hardest from their text alone. Answered by the proportions correct.

**Simulate** (kept, digest C4): generate responses from a construct map (items at levels, respondents on a continuum) and from a latent-class model with the same item means; compare sum-score distributions and item-rest correlations. Shows how hard it is to tell the two apart from summary statistics.

**Problems**
1. Derivation: under a two-class model, show what an item's mean and its correlation with the sum score are, in terms of class proportions and within-class probabilities.
2. Real data with a twist: which number-series item is most out of place relative to your construct map? Propose a reason from its text.
3. Judgment: write the Cronbach–Meehl sentence for a construct you work with. Does it pass the intervention test?
4. Design: sketch a four-level construct map for a construct of your choice, with one item per level.
5. Judgment: a licensure exam built from a blueprint vs. a scale built from a construct map. What does each let you claim?
6. Challenge (open): Moffitt's taxonomy is categorical. What data would convince you that antisocial behaviour is a continuum instead?

## Go deeper

- None.

## Open questions

- None. Settled: idea 3's sources and verdict (Ben, 09-24); the Simulate section (C4); item text (A5).

## Changes made while drafting (#30, 09-24)

- **Waves pooled.** The table's two waves (3 and 5) are the two cognitive-test waves, and each participant was randomly assigned to one (Himmelstein et al., 2025, sec. 2.1), so every respondent appears once. The lesson pools them: 1,189 respondents. Proportions correct change slightly from the wave-3-only figures above: NS_2 0.84 (unchanged), NS_6 0.015 (was 0.02).
- **Unanswered items.** Each item had a 30-second limit; unanswered items are absent from the IRW table (1,602 of 10,701 trials). The lesson reports proportions correct both among those who answered and counting unanswered as wrong (rank correlation with the map −0.76 either way).
- **The finding: NS_6's key.** The source key accepts 165 for "200, 198, 192, 174, __"; continuing the tripled steps gives 120, which 101 respondents typed against 13 for 165. The lesson reads the raw answers from the source repository (forecastingresearch/fpt, pinned commit) and frames this gently as a fact about the key. Rescored, NS_6 would be 0.115.
- **The construct map used:** 1 same step (NS_1); 2 step changes by a simple pattern (NS_2, NS_3, NS_4); 3 step changes by multiplication (NS_6, NS_8); 4 interleaved (NS_7); 5 fractions (NS_5, NS_9).
- **Item text** comes from the test's public source code (`materials/js/number_series_task.js`), not a snapshot; the repository has no licence file, the paper is CC BY 4.0 (flagged for Ben).
- **DRDP:** the current DRDP (2025) PTK view, problem-solving measure, paraphrased (the instrument is "all rights reserved").
- **Moffitt:** the slide's four groups are given as the two of Moffitt (1993) plus the third found at age 26 (Moffitt, Caspi, Harrington & Milne, 2002, doi:10.1017/S0954579402001104).
- **Widgets:** the DRDP explorer and the intervention widget are one widget (three descriptions); "build a construct map" is a set of dropdowns, checked against the data in *With real data*.
