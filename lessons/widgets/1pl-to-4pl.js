// Widget helpers for the lesson "From the 1PL to the 4PL". Pure functions only; the
// plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, p2pl, grid} from "./irt.js";

// Four-parameter logistic curve: lower asymptote c, upper asymptote u. With c = 0
// and u = 1 it is the 2PL; with a = 1 as well, the Rasch model.
export const p4pl = (theta, b, a = 1, c = 0, u = 1) => c + (u - c) * logistic(a * (theta - b));

// Log-likelihood of a response pattern under the 4PL family (slopes a, lower
// asymptotes c, upper asymptotes u; null means 1, 0 and 1 for every item).
export function loglik4(theta, x, b, a = null, c = null, u = null) {
  let ll = 0;
  for (let i = 0; i < x.length; i++) {
    const p = p4pl(theta, b[i], a ? a[i] : 1, c ? c[i] : 0, u ? u[i] : 1);
    ll += x[i] ? Math.log(p) : Math.log(1 - p);
  }
  return ll;
}

// Maximum-likelihood theta under the 4PL family, by grid search on [lo, hi]. A
// maximum on the edge of the grid is returned as -Infinity or +Infinity: the
// likelihood is still rising there, so no finite maximum exists in range.
export function mle4(x, b, a = null, c = null, u = null, lo = -6, hi = 6) {
  const g = grid(lo, hi, 2401);
  let k = 0, bestll = -Infinity;
  for (let i = 0; i < g.length; i++) {
    const ll = loglik4(g[i], x, b, a, c, u);
    if (ll > bestll + 1e-12) { bestll = ll; k = i; }
  }
  return k === 0 ? -Infinity : k === g.length - 1 ? Infinity : g[k];
}

// The 2PL curve closest to a target curve f(theta), by weighted least squares over
// the points thetas with weights w (e.g. a normal density: where respondents are).
// Grid search over slope a in [aLo, aHi] and difficulty b in [bLo, bHi], then a
// finer search around the best point. Returns {a, b, maxDiff}, where maxDiff is the
// largest |difference| in probability over the thetas whose weight is at least
// 14.6% of the peak: for normal weights, the middle 95% of respondents.
export function closest2pl(f, thetas, w, aLo = 0.2, aHi = 4, bLo = -5, bHi = 5) {
  const target = thetas.map(f);
  const loss = (a, b) => {
    let s = 0;
    for (let k = 0; k < thetas.length; k++) s += w[k] * (p2pl(thetas[k], b, a) - target[k]) ** 2;
    return s;
  };
  let best = {a: 1, b: 0, l: Infinity};
  for (const a of grid(aLo, aHi, 60)) for (const b of grid(bLo, bHi, 80)) {
    const l = loss(a, b);
    if (l < best.l) best = {a, b, l};
  }
  const da = (aHi - aLo) / 59, db = (bHi - bLo) / 79;
  for (const a of grid(Math.max(aLo, best.a - da), best.a + da, 41))
    for (const b of grid(best.b - db, best.b + db, 41)) {
      const l = loss(a, b);
      if (l < best.l) best = {a, b, l};
    }
  const wmax = Math.max(...w);
  let maxDiff = 0;
  for (let k = 0; k < thetas.length; k++)
    if (w[k] >= 0.146 * wmax) maxDiff = Math.max(maxDiff, Math.abs(p2pl(thetas[k], best.b, best.a) - target[k]));
  return {a: best.a, b: best.b, maxDiff};
}
