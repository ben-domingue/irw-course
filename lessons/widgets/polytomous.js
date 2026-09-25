// Widget helpers for the lesson "Models for polytomous responses". Pure functions
// only; the plotting is in the lesson's OJS cells. Shared math comes from irt.js.
// An item has categories 0..K, one slope a and K parameters bs = [b_1, ..., b_K].
import {logistic} from "./irt.js";

// Graded response model: P(x >= k) = logistic(a (theta - b_k)); category
// probabilities are differences of adjacent boundary curves. Needs ordered bs.
export function grmProbs(theta, a, bs) {
  const star = [1, ...bs.map(b => logistic(a * (theta - b))), 0];
  return bs.map((_, k) => star[k] - star[k + 1]).concat([star[bs.length]]);
}

// Generalized partial credit model (PCM when a = 1): P(x = k) is proportional to
// exp(sum over v <= k of a (theta - b_v)). Computed on the log scale for stability.
export function gpcmProbs(theta, a, bs) {
  const logit = [0];
  bs.forEach((b, k) => logit.push(logit[k] + a * (theta - b)));
  const m = Math.max(...logit);
  const e = logit.map(v => Math.exp(v - m));
  const s = e.reduce((u, v) => u + v, 0);
  return e.map(v => v / s);
}

// Sequential model: P(x >= k | x >= k - 1) = logistic(a (theta - b_k)); a respondent
// passes the steps in order and stops at the first one failed.
export function seqProbs(theta, a, bs) {
  const q = bs.map(b => logistic(a * (theta - b)));
  const out = [];
  let reach = 1;
  for (let k = 0; k <= bs.length; k++) {
    out.push(reach * (k < bs.length ? 1 - q[k] : 1));
    if (k < bs.length) reach *= q[k];
  }
  return out;
}

export function catProbs(model, theta, a, bs) {
  if (model === "GRM") return grmProbs(theta, a, [...bs].sort((u, v) => u - v));
  if (model === "Sequential") return seqProbs(theta, a, bs);
  return gpcmProbs(theta, model === "PCM" ? 1 : a, bs);  // "GPCM" or "PCM"
}

// Expected score: sum over k of k P(x = k).
export const expectedScore = p => p.reduce((s, v, k) => s + k * v, 0);

// Item information for any of the models: sum over k of (dP_k / dtheta)^2 / P_k,
// with the derivative taken numerically.
export function polyInfo(model, theta, a, bs, h = 1e-4) {
  const lo = catProbs(model, theta - h, a, bs), hi = catProbs(model, theta + h, a, bs);
  const p = catProbs(model, theta, a, bs);
  return p.reduce((s, pk, k) => {
    const d = (hi[k] - lo[k]) / (2 * h);
    return pk > 1e-12 ? s + (d * d) / pk : s;
  }, 0);
}

// Log odds of category k against category k - 1 (adjacent categories).
export function adjacentLogit(model, theta, a, bs, k) {
  const p = catProbs(model, theta, a, bs);
  return Math.log(p[k] / p[k - 1]);
}

// Is category k the most likely response anywhere on a grid of theta values?
export function everModal(model, a, bs, k, grid) {
  return grid.some(t => {
    const p = catProbs(model, t, a, bs);
    return p.indexOf(Math.max(...p)) === k;
  });
}
