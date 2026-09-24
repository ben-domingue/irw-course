<!--
Outline template (#7). Copy to outlines/<id>.md, where <id> is the lesson's id in
lessons.yml. Keep every heading, in this order, even when a section is empty
(write "None."). The cross-check passes (#9) read these headings by name.

An outline is a plan, not a draft: bullets, one line each where possible. Aim for
one screen per heading at most. Refer to other lessons by id (e.g. `rasch`), so the
cross-checks can match them.
-->

# <Lesson title> (`<id>`)

Module: <module id> · Prereqs: <ids from lessons.yml> · Preliminary | Core | Extension · Status: outline

## Core ideas

<!-- The 3–6 ideas a reader should leave with, in teaching order. Each becomes a
subsection of Core ideas; mark the major ones, which get a quick check (2–4 total).
Name the source(s) for each idea (citations are generous: PROTOCOL.md §2), and mark any
not yet verified. -->

1. **<Idea>.** <One sentence: what the reader should be able to say or do.>

## Picks up

<!-- What this lesson assumes from earlier lessons, and where each was introduced.
One line each: the idea, then the lesson id that introduced it. If the idea was only
promised (not taught) earlier, say so. -->

- <Idea> (from `<id>`).

## Promises / leaves open

<!-- Hooks: things this lesson raises and hands to a later lesson (or leaves open for
good). One line each: the hook, then the lesson id that should pay it off, or
"unpaid" if no lesson does yet. Include assumptions stated here that a later lesson
tests, relaxes or shows violated. -->

- <Hook> → `<id>` | unpaid.

## Tables

<!-- At most 3 IRW tables, each with one job (main example | contrast | failure
case), and what the real-data section should turn up with it. Only tables with a
tokenless CSV on their landing page (see #15 for subsamples). Flag any table another
lesson also uses, and say whether the reuse is deliberate (a thread) or should go
(#12). Add a sanity table (a table whose answer is known, used to check the fit
before trusting it; it needn't appear in the lesson) and, for a deep-dive lesson, the
corpus filter (#4). Neither counts against the 3. -->

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `<table>` | main example | <the finding the section is written around> | — |
| `<table>` | sanity | <the known answer> | — |

## Widget / simulation / problem ideas

<!-- Widgets: 3–5 "Try it" ideas, each tied to a core idea by number.
Predict-then-check: exactly one, in With real data, about the finding above.
Simulate: what the webR simulation generates, fits and compares (seconds in the
browser). Problems: 6, covering derivation · real data with a twist · judgment ·
design · challenge (open is allowed). -->

**Widgets**
- <Widget> (idea <n>).

**Predict-then-check:** <the question, and the output that answers it>.

**Simulate:** <what it generates and what the reader compares>.

**Problems**
1. <Derivation.>
2. <Real data with a twist.>
3. <Judgment.>
4. <Design.>
5. <...>
6. <Challenge.>

## Go deeper

<!-- Candidate derivations or proofs for collapsible callouts (0–2 per lesson). The
criterion is load-bearing, not merely elegant: many later lessons pick the result
up. For each: the result, why it matters (which lessons use it), rough length.
The depth pass (#10) ranks these across all lessons. -->

- **<Result>.** Why: <lessons that pick it up>. Length: <e.g. half a page>.

## Open questions

<!-- Anything for Ben: a section of the fixed anatomy that doesn't fit this lesson,
a boundary with a neighbouring lesson, a table choice. Each also goes in #62 with
the needs-ben label. Write "None." if there are none. -->

- None.
