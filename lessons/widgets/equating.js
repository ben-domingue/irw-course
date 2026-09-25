// Widget helpers for the lesson "Linking and equating". Pure functions only; the
// plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {p2pl, grid, dnorm, rng} from "./irt.js";

// Distribution of the sum score on Rasch items b for a normal(mu, 1) population,
// by the Lord-Wingersky recursion over a quadrature grid. Returns an array of
// probabilities for scores 0..n.
export function scoreDist(b, mu = 0, sd = 1) {
  const nodes = grid(mu - 5 * sd, mu + 5 * sd, 121);
  const w = nodes.map((t) => dnorm(t, mu, sd));
  const wsum = w.reduce((u, v) => u + v, 0);
  const out = new Array(b.length + 1).fill(0);
  nodes.forEach((t, k) => {
    let f = [1];
    for (const bi of b) {
      const p = p2pl(t, bi), g = new Array(f.length + 1).fill(0);
      for (let s = 0; s < f.length; s++) { g[s] += f[s] * (1 - p); g[s + 1] += f[s] * p; }
      f = g;
    }
    f.forEach((v, s) => { out[s] += v * w[k] / wsum; });
  });
  return out;
}

// Percentile rank of score x (Kolen & Brennan's continuized definition): the share
// below x plus half the share at x, so a score spreads uniformly over x +/- 0.5.
export function percentileRank(dist, x) {
  const xs = Math.max(-0.5, Math.min(dist.length - 0.5, x));
  const s = Math.floor(xs + 0.5);
  let below = 0;
  for (let k = 0; k < s; k++) below += dist[k];
  return below + dist[Math.min(s, dist.length - 1)] * (xs - (s - 0.5));
}

// The score on form Y with the same percentile rank (the inverse of percentileRank).
export function equipercentile(distX, distY, x) {
  const pr = percentileRank(distX, x);
  let lo = -0.5, hi = distY.length - 0.5;
  for (let it = 0; it < 60; it++) {
    const mid = (lo + hi) / 2;
    if (percentileRank(distY, mid) < pr) lo = mid; else hi = mid;
  }
  return (lo + hi) / 2;
}

// Mean and SD of a score distribution.
export function moments(dist) {
  const m = dist.reduce((u, p, s) => u + p * s, 0);
  const v = dist.reduce((u, p, s) => u + p * (s - m) ** 2, 0);
  return {mean: m, sd: Math.sqrt(v)};
}

// n draws of (x, y) from a bivariate normal with correlation rho, means mx, my and
// SDs sx, sy, from a seeded generator.
export function bivariate(n, rho, mx, my, sx, sy, seed = 1) {
  const r = rng(seed);
  return Array.from({length: n}, () => {
    const z1 = r.norm(), z2 = r.norm();
    return {x: mx + sx * z1, y: my + sy * (rho * z1 + Math.sqrt(1 - rho * rho) * z2)};
  });
}

// Test characteristic curve: expected score on 2PL items [{a, b}] at theta.
export const tcc = (theta, items) => items.reduce((s, it) => s + p2pl(theta, it.b, it.a), 0);

// Put items from another calibration on the base scale: b -> A b + B, a -> a / A.
export const transform = (items, A, B) => items.map((it) => ({a: it.a / A, b: A * it.b + B}));

// Stocking-Lord criterion: squared gap between the two TCCs, weighted by a normal
// density on the base scale.
export function slLoss(base, other, A, B) {
  const t = transform(other, A, B);
  return grid(-4, 4, 81).reduce((s, th) => s + dnorm(th) * (tcc(th, base) - tcc(th, t)) ** 2, 0) * 0.1;
}

// The A and B that minimise slLoss, by a coarse grid search and then a finer one.
export function slFit(base, other) {
  let best = {A: 1, B: 0, l: Infinity};
  for (const A of grid(0.4, 2.5, 43)) for (const B of grid(-2, 2, 81)) {
    const l = slLoss(base, other, A, B);
    if (l < best.l) best = {A, B, l};
  }
  for (const A of grid(best.A - 0.05, best.A + 0.05, 21)) for (const B of grid(best.B - 0.05, best.B + 0.05, 21)) {
    const l = slLoss(base, other, A, B);
    if (l < best.l) best = {A, B, l};
  }
  return best;
}

// Mean-mean and mean-sigma linking constants (other onto base).
export function momentLinks(base, other) {
  const mean = (v) => v.reduce((u, w) => u + w, 0) / v.length;
  const sd = (v) => { const m = mean(v); return Math.sqrt(v.reduce((u, w) => u + (w - m) ** 2, 0) / (v.length - 1)); };
  const aB = base.map((d) => d.a), bB = base.map((d) => d.b), aO = other.map((d) => d.a), bO = other.map((d) => d.b);
  const Amm = mean(aO) / mean(aB), Ams = sd(bB) / sd(bO);
  return {meanMean: {A: Amm, B: mean(bB) - Amm * mean(bO)}, meanSigma: {A: Ams, B: mean(bB) - Ams * mean(bO)}};
}

// Walk round a ring of `n` links. Each link's shift is `bias` plus normal noise with
// SD `noise`. Returns the cumulative position after each link (0 at the start).
export function ringWalk(n, bias, noise, seed = 1) {
  const r = rng(seed);
  const out = [{link: 0, position: 0}];
  let pos = 0;
  for (let k = 1; k <= n; k++) { pos += bias + noise * r.norm(); out.push({link: k, position: pos}); }
  return out;
}
