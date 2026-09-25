// Widget helpers for the lesson "Estimating abilities: MLE and EAP". Pure functions
// only; the plotting is in the lesson's OJS cells. Shared math comes from irt.js.
// Everything here is for the Rasch model with known difficulties b, where every
// estimator depends on the responses only through the sum score r.
import {p2pl, dnorm, grid} from "./irt.js";

// Rasch difficulties of the ten Wordsum items (c19prc_uk_mcbride_2021_wordsum), from
// the lesson's fit-ws chunk (mirt, b = -d), to three decimals (the page prints two),
// and the fitted SD of ability.
export const wsB = [-1.241, -1.981, 1.554, -2.507, -1.099, -2.315, 0.882, 1.371, -1.126, 1.386];
export const wsSd = 1.881;

// Rasch log likelihood for a sum score r, up to a constant that doesn't involve theta:
// r * theta - sum_i log(1 + exp(theta - b_i)).
export const logLikR = (theta, r, b) =>
  r * theta - b.reduce((s, bi) => s + Math.log1p(Math.exp(theta - bi)), 0);

const expected = (theta, b) => b.reduce((s, bi) => s + p2pl(theta, bi), 0);
const infoR = (theta, b) => b.reduce((s, bi) => { const p = p2pl(theta, bi); return s + p * (1 - p); }, 0);

// Find the root of an increasing-then-decreasing score function f by bisection on
// [lo, hi], where f(lo) > 0 > f(hi).
function bisect(f, lo = -15, hi = 15) {
  for (let k = 0; k < 80; k++) {
    const mid = (lo + hi) / 2;
    if (f(mid) > 0) lo = mid; else hi = mid;
  }
  return (lo + hi) / 2;
}

// Maximum likelihood: solve sum_i P_i(theta) = r. +/-Infinity for a perfect or zero score.
export function mleR(r, b) {
  if (r <= 0) return -Infinity;
  if (r >= b.length) return Infinity;
  return bisect(t => r - expected(t, b));
}

// Standard error of the MLE, 1 / sqrt(I) at the estimate.
export const seR = (theta, b) => 1 / Math.sqrt(infoR(theta, b));

// Warm's weighted likelihood estimate: the score equation plus J / (2I), where
// J = sum_i P_i (1 - P_i)(1 - 2 P_i). Finite for every score.
export function wleR(r, b) {
  return bisect(t => {
    let J = 0, I = 0;
    for (const bi of b) { const p = p2pl(t, bi); I += p * (1 - p); J += p * (1 - p) * (1 - 2 * p); }
    return r - expected(t, b) + J / (2 * I);
  });
}

// Posterior mode with a normal(mu, sd) prior: r - sum P_i - (theta - mu) / sd^2 = 0.
export const mapR = (r, b, mu = 0, sd = 1) => bisect(t => r - expected(t, b) - (t - mu) / (sd * sd));

// The posterior on a grid of nodes, normalised to sum to 1, with its mean (EAP) and SD.
export function posteriorR(r, b, mu = 0, sd = 1, nodes = grid(-8, 8, 641)) {
  const ll = nodes.map(t => logLikR(t, r, b) + Math.log(dnorm(t, mu, sd)));
  const top = Math.max(...ll);
  const w = ll.map(v => Math.exp(v - top));
  const tot = w.reduce((s, v) => s + v, 0);
  const post = w.map(v => v / tot);
  const eap = nodes.reduce((s, t, k) => s + t * post[k], 0);
  const psd = Math.sqrt(nodes.reduce((s, t, k) => s + (t - eap) ** 2 * post[k], 0));
  return {nodes, post, eap, psd};
}
