// Widget helpers for the lesson "From the 1PL to the 4PL". Pure functions only; the
// plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, p2pl, grid, p4pl} from "./irt.js";

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

