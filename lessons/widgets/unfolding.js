// Widget helpers for the lesson "Unfolding models". Pure functions only; the
// plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, grid, dnorm, logisticFit} from "./irt.js";

// Hyperbolic cosine model (Andrich & Luo, 1993): the probability of agreeing with a
// statement at delta, for a respondent at theta; lambda sets how wide the region of
// agreement is.
export const hcm = (theta, delta, lambda) =>
  Math.exp(lambda) / (Math.exp(lambda) + 2 * Math.cosh(theta - delta));

// The three-category partial credit model behind it: 0 = disagree from below,
// 1 = agree, 2 = disagree from above, with steps at delta - lambda and delta + lambda.
export function pcm3(theta, delta, lambda) {
  const l = [0, theta - (delta - lambda), 2 * (theta - delta)];
  const m = Math.max(...l);
  const e = l.map(v => Math.exp(v - m));
  const s = e[0] + e[1] + e[2];
  return e.map(v => v / s);
}

// The 2PL that best describes an ideal-point curve for respondents distributed
// N(0, 1): a weighted logistic regression of the curve on theta. Returns the slope a,
// difficulty b and the fitted curve on the grid.
export function best2PL(curve, lo = -4, hi = 4, n = 161) {
  const th = grid(lo, hi, n);
  const y = th.map(curve);
  const w = th.map(t => dnorm(t));
  const {b0, b1} = logisticFit(th, y, w);
  return {a: b1, b: -b0 / b1, th, y, fit: th.map(t => logistic(b0 + b1 * t))};
}

// Does a 0/1 pattern, read in a given order, have its 1s in one unbroken run?
export function oneRun(row, order) {
  let starts = 0, prev = 0;
  for (const k of order) {
    const x = row[k];
    if (x === 1 && prev === 0) starts++;
    prev = x;
  }
  return starts === 1;
}

// Shuffle an array with a seeded uniform generator (Fisher-Yates).
export function shuffle(arr, unif) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(unif() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}
