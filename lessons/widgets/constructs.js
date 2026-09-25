// Widget helpers for the lesson "Constructs and construct maps". Pure functions only;
// colours and the seeded rng come from irt.js. Import with:
//   import {simTwo, spearman} from "./widgets/constructs.js"
import {logistic, dnorm, grid, rng, cor} from "./irt.js";

// Ranks (1 = smallest), with ties given their average rank, as R's rank() does.
export function ranks(x) {
  const idx = x.map((v, i) => [v, i]).sort((a, b) => a[0] - b[0]);
  const r = Array(x.length);
  for (let i = 0; i < idx.length;) {
    let j = i;
    while (j + 1 < idx.length && idx[j + 1][0] === idx[i][0]) j++;
    for (let k = i; k <= j; k++) r[idx[k][1]] = (i + j) / 2 + 1;
    i = j + 1;
  }
  return r;
}

// Spearman's rank correlation, as cor(x, y, method = "spearman") in R.
export const spearman = (x, y) => cor(ranks(x), ranks(y));

// Item-rest correlations for a complete 0/1 response matrix X (an array of rows).
export function itemRest(X) {
  const p = X[0].length, tot = X.map(r => r.reduce((u, v) => u + v, 0));
  return Array.from({length: p}, (_, j) => cor(X.map(r => r[j]), X.map((r, i) => tot[i] - r[j])));
}

// Expected proportion correct on an item at location b when theta ~ N(0, 1).
function marginalP(b) {
  const t = grid(-7, 7, 701), dt = t[1] - t[0];
  return t.reduce((s, v) => s + logistic(v - b) * dnorm(v) * dt, 0);
}

// Two samples of n respondents on ten items (two at each of the locations -2..2):
// one from a continuum (theta ~ N(0, 1), logistic item curves) and one from four
// ordered latent classes, `sep` apart, whose item locations are chosen so that
// each item has the same expected proportion correct. Mirrors code/constructs-sim.R.
export function simTwo({seed = 1, n = 1000, sep = 1, share = [0.2, 0.3, 0.3, 0.2]} = {}) {
  const r = rng(seed);
  const b = [-2, -2, -1, -1, 0, 0, 1, 1, 2, 2];
  const K = share.length, mid = (K + 1) / 2;
  const loc = share.map((_, k) => (k + 1 - mid) * sep);
  const bCls = b.map(bi => {
    const target = marginalP(bi);
    let lo = -10, hi = 10;
    for (let it = 0; it < 60; it++) {
      const m = (lo + hi) / 2;
      const p = share.reduce((s, w, k) => s + w * logistic(loc[k] - m), 0);
      if (p > target) lo = m; else hi = m;
    }
    return (lo + hi) / 2;
  });
  const cum = share.map((_, k) => share.slice(0, k + 1).reduce((u, v) => u + v, 0));
  const cont = [], cls = [];
  for (let j = 0; j < n; j++) {
    const th = r.norm();
    cont.push(b.map(bi => (r.unif() < logistic(th - bi) ? 1 : 0)));
    const u = r.unif();
    let k = cum.findIndex(c => u < c); if (k < 0) k = K - 1;
    cls.push(bCls.map(bi => (r.unif() < logistic(loc[k] - bi) ? 1 : 0)));
  }
  const sums = X => X.map(row => row.reduce((u, v) => u + v, 0));
  return {
    continuum: {sums: sums(cont), itemRest: itemRest(cont)},
    classes: {sums: sums(cls), itemRest: itemRest(cls)}
  };
}
