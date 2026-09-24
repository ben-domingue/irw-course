<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 2–17, "Back to validity" through the dyslexia-screener discussion). -->

# Validity as causation: Borsboom's view (`validity-causal`)

Module: validity · Prereqs: validity-argument · Optional · Status: outline

## Core ideas

1. **The shortcoming of the argument view.** If validity depends on every proposed use, must every length measure grapple with every use? Have we set the bar so high that people stop trying (slides 3–4, the "you must be this tall to ride" sign)? *(major)* Sources: Borsboom, Mellenbergh & van Heerden (2004), doi:10.1037/0033-295X.111.4.1061; Markus & Borsboom (2013), doi:10.4324/9780203501207.
2. **Borsboom's definition.** "A test is valid for measuring an attribute if and only if (a) the attribute exists and (b) variations in the attribute causally produce variations in the outcomes of the measurement procedure." A return to Kelley's "measures what it purports to measure". What needs testing is "a theory of response behavior", not a nomological network. The slide's gloss: they are "fairly scathing" about nomological networks, and an implicit definition through one is "fairly weak tea" (slide 6, Ben's words). *(major)* Sources: Borsboom et al. (2004) (the definition as quoted on slide 6; **page and exact wording to check** against the article, whose abstract words it slightly differently); Kelley (1927), *Interpretation of educational measurements* (book, no DOI; **the quotation is taken from Borsboom et al. and not checked against Kelley**); Cronbach & Meehl (1955), doi:10.1037/h0040957 (the nomological network they reject).
3. **A theory of response behavior makes testable predictions.** Piaget's balance scale: four rules, and "conflict" items on which children using an earlier rule outperform children using a later one, so the rule classes can be tested against response patterns (slides 7–14). *(major)* Sources: Siegler (1976), doi:10.1016/0010-0285(76)90016-5; Jansen & van der Maas (1997), doi:10.1006/drev.1997.0437 (the slide 10 figure: rule use by age); Jansen & van der Maas (2002), doi:10.1006/jecp.2002.2664 (the slide 13–14 quotation). Related: Embretson's construct representation vs. nomothetic span, Whitely (1983), doi:10.1037/0033-2909.93.1.179.
4. **Does the attribute exist, and in whom?** A causal effect in the population need not be an attribute on which people differ. Borsboom, Mellenbergh & van Heerden (2003) separate between-subjects from within-subjects readings of a latent variable; an experimental effect can be robust while its person-level differences carry little stable variance. Sources: Borsboom et al. (2003), doi:10.1037/0033-295X.110.2.203; Hedge, Powell & Sumner (2018), doi:10.3758/s13428-017-0935-1; Cronbach & Furby (1970), doi:10.1037/h0029382 (difference scores); Michell (1997), doi:10.1111/j.2044-8295.1997.tb02641.x (is the attribute quantitative?).
5. **What I would worry about** (slide 15). If we attend only to the internals of measurement, what happens to uses? What about score variation not caused by the attribute? And the grain size: Borsboom's examples are small, theory-rich tasks, not high-stakes standardized tests. Maybe one concept can't cover both. Ben's verdict goes here (first person).

Crossref-checked 09-24 unless marked.

## Picks up

- The argument view, the Standards' definition and the validity paradox (from `validity-argument`).
- Is the attribute really there, and quantitative? Michell and realism (from `measurement`).
- The construct suggests an intervention (from `constructs`): Borsboom's view asks for exactly this kind of causal theory.
- Construct maps that order items before data (from `constructs`).
- Causal claims about constructs in structural models (from `sem`, optional and not an ancestor; answered in prose).

## Promises / leaves open

- Uses, once validity is only about the attribute: a separate process? → unpaid (the lesson leaves it open, as slide 15 does).
- Item features that explain difficulty (a theory of response behavior as a model) → `explanatory-irt`.
- Latent classes of rule users (the balance scale) → `cdm`; mixture models otherwise unpaid.
- The reliability paradox in full, with stimuli as items → `trials` (which uses a different Stroop table; no formal thread, since `validity-causal` is optional).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `vocab_assessment_3_to_8_year_old_children` | main example (a response theory that predicts) | oREV, a German receptive vocabulary task (Bohn et al., 2022, doi:10.31234/osf.io/4z86w), 52 words, 581 children aged 3–8, with each word's age of acquisition. A simple theory of response behavior (a child picks the right picture once the word is acquired) predicts item order before any data: age of acquisition correlates 0.80 with Rasch difficulty (47 items; 5 items everyone answered correctly are dropped). Age correlates 0.62 with θ. | — |
| `robison_2026_retesting_stroop` | contrast (a cause without an individual attribute) | Stroop task (Stroop, 1935, doi:10.1037/h0054651) given twice, about two weeks apart, to 250 undergraduates (Robison et al., 2026, doi:10.3758/s13428-025-02897-8). Incongruent trials are slower by 0.12 s at session 1 (d_z = 0.36, about 5.7 standard errors from zero), and 67% of respondents show a positive effect. But the effect's retest correlation is 0.15 (234 respondents with both sessions), against 0.70 for mean congruent RT. The manipulation causes the effect; the effect barely ranks people. | — |

Both tables have item-level features that the lesson reads (`itemcov_aoa_german_comb`, `itemcov_conflict`); no item text is needed. The licence of the oREV picture materials is still to check (#63); the lesson needs only the words and their ages of acquisition. Table citations come from IRW biblio.

Sanity table: within the Stroop table, mean congruent RT (retest 0.70) is the known-good contrast for the pipeline; for the oREV Rasch fit, the age–θ correlation (0.62) is the expected direction.

No balance-scale data are in the IRW (searched 09-24: `balance_mokken` is toddlers' physical balancing tasks). The balance scale stays in the Core ideas as the slides' worked example, from Jansen & van der Maas.

## Widget / simulation / problem ideas

**Widgets**
- Balance-scale rules: choose weights and distances; see each rule's prediction; build a "conflict" item where Rule I beats Rule III (idea 3).
- Rule classes to response patterns: pick class proportions; see the item-by-class table of expected proportions correct, including items on which the youngest class does best (ideas 3, 4).
- Between vs. within: simulated people with a common Stroop effect plus small person differences; slide the person-level SD and the number of trials and watch the retest correlation of the effect (idea 4).

**Predict-then-check:** in the Stroop table, the group-level effect is clear. Before seeing it, predict the correlation between each respondent's effect at session 1 and at session 2. Answered by the retest correlation (0.15, vs. 0.70 for congruent RT).

**Simulate:** a within-person causal effect with and without person variation in the effect. Generate trials, compute each person's effect twice, and compare the group mean and t with the retest correlation. Shows a robust effect with near-zero reliability of individual differences (seconds in webR).

**Problems**
1. Derivation: the reliability of a difference score in terms of the two scores' reliabilities and their correlation (Cronbach & Furby, 1970). Plug in the Stroop numbers.
2. Real data with a twist: in oREV, which words are most out of line with their age of acquisition? Propose a reason from the word and its picture set.
3. Judgment: slide 15's worries. Take the dyslexia screeners (slides 16–17). What would a Borsboom-style validity study of one screener look like, and what would it leave out?
4. Judgment: slide 6 calls definition through a nomological network "fairly weak tea". Give one case where network evidence is all you can get, and say whether that means the test is invalid or the theory is thin.
5. Design: write a theory of response behavior for a construct you work with, strong enough to predict an item on which lower-θ respondents should do better than higher-θ respondents (the balance scale's conflict items).
6. Challenge (open): can a test be valid in Borsboom's sense for a population effect while its scores are useless for ranking individuals? What would that mean for uses?

## Go deeper

- None proposed. (The difference-score reliability derivation is problem 1; `trials` may carry the reliability paradox in depth.)

## Open questions

- **Tables.** No balance-scale data in the IRW; oREV (age of acquisition predicts difficulty) is the positive example and the Stroop table the contrast. Is oREV close enough in spirit to the balance scale, or would you rather the lesson use a construct-map table (the number-series items are taken by `constructs`)?
- **Overlap with `trials`.** `trials` (course-d6) teaches the reliability paradox with `enkavi_2019_stroop`. This lesson angles the Stroop table toward Borsboom's between/within point and cites Hedge et al.; `trials` will say "see validity-causal" without a formal thread. OK?
- **Ben's verdict (idea 5).** Slide 15 closes with worries rather than a verdict. The lesson needs your first-person view: is Borsboom's view a replacement for the argument view, a complement, or a different concept for different grain sizes?
- **Kelley (1927).** The "measures what it purports to measure" line is quoted from Borsboom et al. Check the original, or cite it as quoted in Borsboom et al. (2004)?
