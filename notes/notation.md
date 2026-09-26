# Notation and terminology

Ben agreed these on 2026-09-24 (digest A3). Every lesson uses them, whichever session
drafts it. PROTOCOL.md §5 points here. If a lesson needs something not listed, add it
here first, in the same PR.

## Symbols

| Quantity | Symbol | Notes |
|---|---|---|
| Respondent ability / latent trait | $\theta$ (person $j$: $\theta_j$) | "ability" for cognitive tests, "trait" or "level" otherwise |
| Item difficulty (location) | $b$ (item $i$: $b_i$) | |
| Item slope | $a$ | "discrimination" in prose, "slope" in formulas and code |
| Lower asymptote (guessing) | $c$ | `mirt` calls it `g` |
| Upper asymptote (slipping) | $u$ | `mirt` calls it `u`; not $d$, to avoid `mirt`'s intercept |
| Response | $x_{ij}$ | |
| Sum score | $r$ (or $X$ in CTT lessons) | CTT keeps $X = T + E$ |
| Regression coefficients | $\beta_0, \beta_1, \dots$ | never $b$, which is item difficulty (Ben, 09-24) |
| Factor loading | $\lambda$ | factor $\eta$ in CFA/SEM; $f$ in EFA |
| Information | $I(\theta)$ | test information is the sum of item information |
| Standard error | $SE(\hat\theta) = 1/\sqrt{I(\theta)}$ | "conditional SEM" (CSEM) in prose |

## Model form

- Formulas use the slope–difficulty form on the logistic metric: $\Pr(x_{ij}=1) =
  c_i + (u_i - c_i)\,\frac{\exp(a_i(\theta_j - b_i))}{1+\exp(a_i(\theta_j - b_i))}$.
  The 1PL/Rasch has $a = 1$, $c = 0$, $u = 1$.
- No $D$ in formulas. $D \approx 1.7$ appears only in the Camilli aside (`rasch`) and the
  factor-analysis ↔ IRT conversion (`fa-confirmatory`).
- Multidimensional (compensatory) items, as in `dimensionality`: $\Pr(x_{ij}=1) = \text{logistic}\big(\sum_k a_{ik}\theta_{jk} - A_i b_i\big)$ with $A_i = \sqrt{\sum_k a_{ik}^2}$ (the item's multidimensional discrimination) and $b_i$ its multidimensional difficulty; $\theta_{jk}$ is respondent $j$'s ability on dimension $k$. In vector form $\mathbf{a}_i^\top\boldsymbol\theta_j + d_i$ appears only where the code or a derivation needs it (09-25, from `dimensionality`).
- `mirt`'s intercept form $a\theta + d$ appears only in code. Wherever code converts,
  state $b = -d/a$ (for the Rasch model, $b = -d$).

## Words

- **Respondent**, not examinee, test-taker or subject (many IRW tables aren't tests).
  "Person" is fine in formulas and model descriptions.
- **Item** throughout; "probe" only in `measurement`, where it is introduced.
- **Item-rest correlation** (the item against the sum of the *other* items). Say
  "item-total" only when the point is the inflation from including the item.
- **Keying:** responses are coded so that higher = more of the construct. Each lesson
  states its keying once, where the data are introduced.
- **Logit** for the $\theta$ scale's unit when a unit is needed.
