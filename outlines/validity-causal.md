<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 2–17, "Back to validity" through the dyslexia-screener discussion). Tidied 09-24 (#62): Ben's answers E8a, F4, F5 and the no-criticism rule applied. -->

# Validity as causation: Borsboom's view (`validity-causal`)

Module: validity · Prereqs: validity-argument · Extension · Status: outline

## Core ideas

1. **The shortcoming of the argument view.** If validity depends on every proposed use, have we set the bar so high that people stop trying (slides 3–4)? *(major)* Sources: Borsboom, Mellenbergh & van Heerden (2004), doi:10.1037/0033-295X.111.4.1061; Markus & Borsboom (2013), doi:10.4324/9780203501207.
2. **Borsboom's definition.** "A test is valid for measuring an attribute if and only if (a) the attribute exists and (b) variations in the attribute causally produce variations in the outcomes of the measurement procedure." A return to Kelley's "measures what it purports to measure": what needs testing is a theory of response behaviour, not a nomological network. The lesson paraphrases Borsboom et al.'s case against the nomological network (not the slide's "weak tea", per the no-criticism rule) and asks what that definition assumes. *(major)* Sources: Borsboom et al. (2004) (the definition's exact wording and page *to check*; digest D); Kelley (1927), *Interpretation of educational measurements* (book verified; the line cited as quoted in Borsboom et al., F5); Cronbach & Meehl (1955), doi:10.1037/h0040957.
3. **A theory of response behaviour makes testable predictions.** Piaget's balance scale: four rules, and "conflict" items on which children using an earlier rule beat children using a later one (slides 7–14). It is the worked example in prose and widgets; oREV is the real-data stand-in (F4). *(major)* Sources: Siegler (1976), doi:10.1016/0010-0285(76)90016-5; Jansen & van der Maas (1997), doi:10.1006/drev.1997.0437 (slide 10 figure); Jansen & van der Maas (2002), doi:10.1006/jecp.2002.2664 (slides 13–14 quotation).
4. **Does the attribute exist, and in whom?** A causal effect in the population need not be an attribute on which people differ: between- vs. within-subjects readings of a latent variable. An experimental effect can be robust while its person-level differences carry little stable variance. Sources: Borsboom, Mellenbergh & van Heerden (2003), doi:10.1037/0033-295X.110.2.203; Hedge, Powell & Sumner (2018), doi:10.3758/s13428-017-0935-1.
5. **Replacement, complement, or a different grain size? (E8a.)** Slide 15's worries as questions: if validity is only about the attribute, what happens to uses, and to score variation the attribute doesn't cause? Borsboom's examples are small, theory-rich tasks, not high-stakes tests. The lesson lays out three readings (a *replacement* for the argument view, a *complement*, or a concept for a *different grain size* of test), gives the case for each and leaves it open (Ben: a good question with no correct answer). It returns as challenge problem 6. If you've done `sem`, its equivalent-models point is the same worry about causal claims (E2 aside).

The lesson's first-person verdict goes on a smaller practitioner question (E8a). **Candidate, for Ben to confirm:** "Before I trust a score as a measure of an attribute, I want two checks. First, one prediction from a theory of how people answer the items (which items should be harder, or an item that lower scorers should get right more often) that the data could have broken and didn't. Second, evidence that people differ stably on the attribute, not just that a manipulation moves the group mean. In the lesson's data, oREV meets the first; the Stroop effect is clear at the group level but barely ranks people, so it doesn't meet the second."

For *Going further*: Whitely (1983), doi:10.1037/0033-2909.93.1.179 (construct representation vs. nomothetic span); Cronbach & Furby (1970), doi:10.1037/h0029382 (difference scores); Michell (1997), doi:10.1111/j.2044-8295.1997.tb02641.x. Crossref-checked 09-24 unless marked.

## Picks up

- The argument view, the Standards' definition and the validity paradox (from `validity-argument`).
- Is the attribute really there, and quantitative? Michell and realism (from `measurement`).
- The construct suggests an intervention: a causal theory (from `constructs`).
- Construct maps that order items before data (from `constructs`).
- Causal claims about constructs in structural models (from `sem`; not an ancestor: an "if you've done it" aside in idea 5, E2).

## Promises / leaves open

- Uses, once validity is only about the attribute: a separate process? → unpaid (left open; problem 6).
- Item features that explain difficulty: a pointer to `explanatory-irt` (not a descendant, E2; no hook).
- Latent classes of rule users (the balance scale): a pointer to `cdm` (not a descendant, E2); mixture models otherwise unpaid.
- The reliability paradox in full: a pointer to `trials` (not a descendant; a different Stroop table; settled 09-24).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `vocab_assessment_3_to_8_year_old_children` | main example (a response theory that predicts) | oREV, a German receptive vocabulary task (Bohn et al., 2022, doi:10.31234/osf.io/4z86w), 52 words, 581 children aged 3–8, with each word's age of acquisition. A simple theory (a child picks the right picture once the word is acquired) predicts item order: age of acquisition correlates 0.80 with Rasch difficulty (47 items; 5 items everyone answered correctly are dropped). Age correlates 0.62 with θ. | — |
| `robison_2026_retesting_stroop` | contrast (a cause without an individual attribute) | Stroop task (Stroop, 1935, doi:10.1037/h0054651) given twice, about two weeks apart, to 250 undergraduates (Robison et al., 2026, doi:10.3758/s13428-025-02897-8). Incongruent trials are slower by 0.12 s at session 1 (d_z = 0.36, about 5.7 standard errors from zero); 67% of respondents show a positive effect. But the effect's retest correlation is 0.15 (234 respondents with both sessions), against 0.70 for mean congruent RT. The manipulation causes the effect; the effect barely ranks people. | — |

Both tables carry the item features the lesson reads (`itemcov_aoa_german_comb`, `itemcov_conflict`); no item text is needed (the oREV picture licence is still to check, digest D). Citations from IRW biblio. No balance-scale data are in the IRW (searched 09-24; E5: add nothing now).

Sanity: mean congruent RT (retest 0.70) for the Stroop pipeline; the age–θ correlation (0.62) for the oREV Rasch fit.

## Widget / simulation / problem ideas

**Widgets**
- Balance-scale rules: set weights and distances; see each rule's prediction; build a "conflict" item (idea 3).
- Rule classes to response patterns: pick class proportions; see expected proportions correct by item and class (ideas 3, 4).
- Between vs. within: a common Stroop effect plus small person differences; slide the person SD and the number of trials; watch the effect's retest correlation (idea 4).

**Predict-then-check:** the Stroop table's group-level effect is clear. Predict the correlation between each respondent's effect at session 1 and at session 2. Answered by the retest correlation (0.15, vs. 0.70 for congruent RT).

**Simulate:** a within-person effect with and without person variation; compute each person's effect twice; compare the group t with the retest correlation.

**Problems**
1. Derivation: the reliability of a difference score (Cronbach & Furby, 1970), with the Stroop numbers.
2. Real data with a twist: which oREV words are most out of line with their age of acquisition, and why might that be?
3. Judgment: take the dyslexia screeners (slides 16–17). What would a Borsboom-style validity study of one screener look like, and what would it leave out?
4. Judgment: give one case where evidence from a nomological network is all you can get. Does that make the test invalid, or the theory thin?
5. Design: write a theory of response behaviour for your own construct, strong enough to predict an item on which lower-θ respondents do better.
6. Challenge (open, E8a): is Borsboom's definition a replacement for the argument view, a complement to it, or a concept for a different grain size of test? Make the best case for the reading you find weakest (the solution is a "what we know so far" note).

## Go deeper

- None. (The difference-score reliability derivation is problem 1; `trials` carries the reliability paradox in depth.)

## Open questions

- **The practitioner verdict (E8a).** *Default:* the candidate under Core ideas, in Ben's words once he has edited it.
