// Widget helpers for the lesson "Latent classes and cognitive diagnosis".
// Pure functions only; colours come from irt.js. Import with:
//   import {lcClasses, mixtureParts, cutClasses, fracQ, fracAttributes, dinaItems, hoCurve, classCounts} from "./widgets/cdm.js"
import {logistic, grid, dnorm} from "./irt.js";

// A small latent class model for building Pr(x) by hand: three classes, four items.
// Two classes are ordered (low, high); the third finds items 1-2 easy and 3-4 hard.
export const lcClasses = [
  {name: "Low", p: [0.6, 0.45, 0.3, 0.2]},
  {name: "High", p: [0.95, 0.9, 0.85, 0.75]},
  {name: "Uneven", p: [0.9, 0.85, 0.2, 0.15]}];

// The latent class likelihood of one response pattern, piece by piece. `pattern` is
// an array of 0/1; `weights` are relative class sizes, normalised to the shares pi_c.
// For each class: the factor for each item (p if x = 1, 1 - p if x = 0), their product
// (the pattern's probability within the class), pi_c times that product (the class's
// contribution to Pr(x)), and the posterior share (contribution / Pr(x)).
export function mixtureParts(pattern, weights, classes = lcClasses) {
  const tot = weights.reduce((s, v) => s + v, 0);
  const rows = classes.map((c, k) => {
    const factors = c.p.map((p, i) => (pattern[i] ? p : 1 - p));
    const within = factors.reduce((a, v) => a * v, 1);
    const pi = weights[k] / tot;
    return {name: c.name, pi, factors, within, contrib: pi * within};
  });
  const px = rows.reduce((s, r) => s + r.contrib, 0);
  rows.forEach(r => { r.post = r.contrib / px; });
  return {rows, px};
}

// A Rasch continuum cut into K classes of equal size. Ten items with difficulties
// from -1.5 to 1.5; theta ~ N(0, 1). Each class's P(correct) on an item is the
// average of the Rasch curve over the class's slice of theta. With `skill`, one more
// class is added whose members solve the odd-numbered items as if theta were 1 and
// the even-numbered ones as if it were -1: a class that differs in *which* items it
// finds hard. Returns one row per class x item, plus the number of items on which a
// class does worse than the class below it (classes ordered by mean P(correct)).
export function cutClasses(K, skill = false) {
  const b = Array.from({length: 10}, (_, i) => -1.5 + (3 * i) / 9);
  const th = grid(-5, 5, 2001), w = th.map(t => dnorm(t));
  const tot = w.reduce((s, v) => s + v, 0);
  // cumulative mass, to cut theta at the K-quantiles
  let acc = 0;
  const cls = w.map(v => { acc += v; return Math.min(K - 1, Math.floor((K * (acc - v / 2)) / tot)); });
  const classes = [];
  for (let k = 0; k < K; k++) {
    const idx = cls.map((c, j) => (c === k ? j : -1)).filter(j => j >= 0);
    const m = idx.reduce((s, j) => s + w[j], 0);
    classes.push({name: `Class ${k + 1}`, kind: "continuum",
      p: b.map(bi => idx.reduce((s, j) => s + w[j] * logistic(th[j] - bi), 0) / m)});
  }
  if (skill) classes.push({name: "Type", kind: "skill",
    p: b.map((bi, i) => logistic((i % 2 === 0 ? 1 : -1) - bi))});
  const mean = c => c.p.reduce((s, v) => s + v, 0) / c.p.length;
  const sorted = [...classes].sort((x, y) => mean(x) - mean(y));
  let outOfOrder = 0;
  for (let i = 0; i < b.length; i++) {
    if (sorted.some((c, k) => k > 0 && c.p[i] < sorted[k - 1].p[i] - 1e-9)) outOfOrder++;
  }
  const rows = classes.flatMap(c => c.p.map((p, i) => ({item: i + 1, p, cls: c.name, kind: c.kind})));
  // each class's slice of theta, for drawing where the classes came from
  const density = th.filter((_, j) => j % 5 === 0 && Math.abs(th[j]) <= 3)
    .map(t => ({theta: t, d: dnorm(t), cls: `Class ${cls[th.indexOf(t)] + 1}`}));
  return {rows, outOfOrder, density};
}

// Tatsuoka's fraction subtraction Q-matrix (20 items x 8 attributes), as in the IRW
// table frac20 and the GDINA and CDM packages. Attribute labels follow the CDM
// package documentation (DeCarlo, 2011; de la Torre & Douglas, 2004).
export const fracAttributes = [
  "A1 convert a whole number to a fraction",
  "A2 separate a whole number from a fraction",
  "A3 simplify before subtracting",
  "A4 find a common denominator",
  "A5 borrow from the whole number part",
  "A6 column borrow in the numerator",
  "A7 subtract numerators",
  "A8 reduce the answer to simplest form"];

export const fracQ = [
  [0,0,0,1,0,1,1,0], [0,0,0,1,0,0,1,0], [0,0,0,1,0,0,1,0], [0,1,1,0,1,0,1,0],
  [0,1,0,1,0,0,1,1], [0,0,0,0,0,0,1,0], [1,1,0,0,0,0,1,0], [0,0,0,0,0,0,1,0],
  [0,1,0,0,0,0,0,0], [0,1,0,0,1,0,1,1], [0,1,0,0,1,0,1,0], [0,0,0,0,0,0,1,1],
  [0,1,0,1,1,0,1,0], [0,1,0,0,0,0,1,0], [1,0,0,0,0,0,1,0], [0,1,0,0,0,0,1,0],
  [0,1,0,0,1,0,1,0], [0,1,0,0,1,1,1,0], [1,1,1,0,1,0,1,0], [0,1,1,0,1,0,1,0]];

// DINA probabilities for one attribute profile (array of 0/1, length 8): an item is
// answered with probability 1 - s if the profile has every attribute the item needs
// (eta = 1), and g otherwise.
export function dinaItems(profile, g, s) {
  return fracQ.map((q, i) => {
    const eta = q.every((need, k) => !need || profile[k]) ? 1 : 0;
    const missing = q.map((need, k) => (need && !profile[k] ? k + 1 : null)).filter(v => v);
    return {item: i + 1, eta, p: eta ? 1 - s : g, missing: missing.map(k => `A${k}`).join(", ")};
  });
}

// Higher-order DINA for one item that needs m attributes: each attribute is mastered
// with probability logistic(lambda * (theta - delta_k)), independently given theta,
// with thresholds delta_k spread evenly from -1 to 1. Averaging DINA over the
// attributes gives P(correct | theta) = g + (1 - s - g) * prod_k P(alpha_k = 1 | theta).
export function hoCurve(m, lambda, g, s, thetas = grid(-4, 4)) {
  const delta = m === 1 ? [0] : Array.from({length: m}, (_, k) => -1 + (2 * k) / (m - 1));
  return thetas.map(t => {
    const all = delta.reduce((pr, d) => pr * logistic(lambda * (t - d)), 1);
    return {theta: t, p: g + (1 - s - g) * all, all};
  });
}

// Parameters that describe how respondents are spread over profiles: 2^K - 1 for an
// unrestricted distribution over the 2^K profiles, K for a higher-order model with
// one intercept per attribute (slopes fixed at 1, as GDINA's default).
export function classCounts(Kmax = 12) {
  return Array.from({length: Kmax}, (_, i) => i + 1).flatMap(K => [
    {K, count: 2 ** K - 1, model: "Unrestricted: 2^K - 1"},
    {K, count: K, model: "Higher-order: K"}]);
}
