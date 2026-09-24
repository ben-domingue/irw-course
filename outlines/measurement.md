<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 8–22) and PS1#4. -->

# What is measurement? (`measurement`)

Module: foundations · Prereqs: none · Core · Status: outline

## Core ideas

1. **Psychometrics measures latent constructs through probes.** Latent vs. manifest (height); constructs; probes, items, stimuli; why standardization matters.
2. **Two definitions of measurement.** Michell: estimating the magnitude of a quantitative attribute relative to a unit. Stevens: assigning numbers to objects by a rule. My verdict: aspire to Michell, and know that most practice runs on Stevens. *(major)*
3. **Levels of measurement, through hardness.** Nominal (rock types), ordinal (Mohs), interval (a unit that means the same everywhere). Each level licenses different claims. Would the geology faculty accept "this box of minerals has a uniform distribution of hardness"? *(major)*
4. **Measurement is discovered, not declared.** Thermoscope to thermometer: marks on a tube aren't a unit; temperature took conceptual work before it could be measured. The nature of things vs. our current understanding of it.
5. **Interval scales and what hangs on them.** An order-preserving rescaling can shrink, grow or even reverse a difference in group means. Two routes to a unit: model-based (the Lexile, via the Rasch model) and anchoring to an external interval quantity (earnings). *(major)*
6. **What we want from a psychological measure** (my desiderata): insensitive to nonfocal attributes; calibrated to the task (wide range vs. fine distinctions); precise quickly.

## Picks up

- None (first lesson).

## Promises / leaves open

- Constructs, and where probes come from → `constructs`, `instrument-building`.
- Consistency with the Rasch model as a route to a unit (Lexile) → `rasch` (specific objectivity; the scale has no origin).
- Whether a scale is interval changes group comparisons → `score-meaning`, `equating`; unpaid for growth and vertical scales (Briggs 2013) unless `equating` takes it.
- Insensitive to nonfocal attributes → `dif`, `validity-argument`.
- Calibrated to the task; precise quickly → `information`, `item-banks-cat`.
- Is the attribute really there, and quantitative? (Michell; realism) → `validity-causal`.
- The data we'll analyse are the responses to probes → `irw-data`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| to choose: an RCT table with `treat` (a `gilbert_meta_*` table not used elsewhere) | main example | The treatment effect on the sum score, then the same effect after a few order-preserving rescalings of the score: its size moves, and it may change sign. | — |

A conceptual lesson; one table is enough.

## Widget / simulation / problem ideas

**Widgets**
- Hardness: order minerals by scratching (Mohs), then show absolute hardness; which statements are licensed at each level? (ideas 3, 5)
- Thermoscope: mark a tube; a second liquid disagrees between the marks (idea 4).
- Rescale the scores: a curvature slider applied to two groups' score distributions; watch the standardized gap change and, for crossing distributions, reverse (idea 5).

**Predict-then-check:** if we stretch the top of the score scale, does the treatment effect grow, shrink or stay the same? Answered by the effect under each rescaling.

**Simulate:** two groups on a latent scale; report scores through several order-preserving transformations; compare the gap across them. Shows that the sign of a gap is safe only when one group's distribution sits above the other's everywhere.

**Problems**
1. Derivation: construct two groups and an order-preserving transformation that reverses the sign of their mean difference.
2. Real data with a twist: in the lesson's table, find a rescaling that halves the treatment effect.
3. Judgment (PS1#4): the Lexile unit vs. anchoring to earnings; pros and cons.
4. Design: what evidence would make the "uniform distribution of hardness" claim acceptable?
5. Judgment: a measure you use: what level of measurement does it reach, and which desiderata does it meet?
6. Challenge (open): temperature took centuries. What would a thermometer for reading comprehension require?

## Go deeper

- **When a mean difference survives every rescaling.** The sign of a mean difference is preserved by every order-preserving transformation if and only if one distribution stochastically dominates the other. Why: `score-meaning`, `equating`, `dif` (group comparisons on scales of uncertain interval status). Length: half a page.

## Open questions

- Simulate and With real data fit only through the rescaling idea (5). Is that the right real-data hook for a conceptual lesson?
- Settled (Ben, digest C2): idea 5 cites Bond & Lang (2013), *Review of Economics and Statistics* 95(5), 1468–1479, doi:10.1162/rest_a_00370 (verified 09-24).
- Item text (#63): showing a real instrument's probes would ground idea 1. That depends on how item text is sourced.
