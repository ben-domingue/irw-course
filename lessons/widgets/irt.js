// Item response math shared by the lesson widgets. Pure functions only: the
// plotting happens in each lesson's OJS cells, where Observable Plot is in scope.
// Import with:  import {p2pl, loglik} from "./widgets/irt.js"

export const logistic = (x) => 1 / (1 + Math.exp(-x));

// Probability of a correct response. With a = 1 this is the Rasch model.
export const p2pl = (theta, b, a = 1) => logistic(a * (theta - b));

// Standard normal CDF (Abramowitz & Stegun 7.1.26; error below 1e-7).
export function pnorm(x) {
  const t = 1 / (1 + 0.3275911 * Math.abs(x) / Math.SQRT2);
  const y = 1 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t
    - 0.284496736) * t + 0.254829592) * t * Math.exp(-(x * x) / 2);
  return x >= 0 ? (1 + y) / 2 : (1 - y) / 2;
}

export const dnorm = (x, mu = 0, sd = 1) =>
  Math.exp(-0.5 * ((x - mu) / sd) ** 2) / (sd * Math.sqrt(2 * Math.PI));

// Evenly spaced grid, inclusive of both ends.
export const grid = (lo, hi, n = 241) =>
  Array.from({ length: n }, (_, i) => lo + (i * (hi - lo)) / (n - 1));

// Log-likelihood of a response pattern x (0/1 array) at theta, given item
// difficulties b and (optional) slopes a.
export function loglik(theta, x, b, a = null) {
  let ll = 0;
  for (let i = 0; i < x.length; i++) {
    const p = p2pl(theta, b[i], a ? a[i] : 1);
    ll += x[i] ? Math.log(p) : Math.log(1 - p);
  }
  return ll;
}

// Maximum-likelihood theta by grid search. Returns +/-Infinity for all-correct
// or all-incorrect patterns, where no finite maximum exists.
export function mle(x, b, a = null, lo = -6, hi = 6) {
  const s = x.reduce((u, v) => u + v, 0);
  if (s === 0) return -Infinity;
  if (s === x.length) return Infinity;
  let best = lo, bestll = -Infinity;
  for (const t of grid(lo, hi, 2401)) {
    const ll = loglik(t, x, b, a);
    if (ll > bestll) { bestll = ll; best = t; }
  }
  return best;
}

// All 0/1 patterns of length n with sum s.
export function patternsWithSum(n, s) {
  const out = [];
  for (let m = 0; m < 2 ** n; m++) {
    const x = Array.from({ length: n }, (_, i) => (m >> i) & 1);
    if (x.reduce((u, v) => u + v, 0) === s) out.push(x);
  }
  return out;
}

// Expected proportion correct for a normal(mu, sd) population on items b.
export function expectedPropCorrect(b, mu = 0, sd = 1) {
  const g = grid(mu - 5 * sd, mu + 5 * sd, 401);
  const w = g.map((t) => dnorm(t, mu, sd));
  const wsum = w.reduce((u, v) => u + v, 0);
  let e = 0;
  for (let k = 0; k < g.length; k++)
    e += w[k] * b.reduce((u, bi) => u + p2pl(g[k], bi), 0) / b.length;
  return e / wsum;
}

// n values evenly spread (as quantiles) from a normal(mu, sd): a deterministic
// stand-in for a sample, so widgets don't jitter as sliders move.
export function normalQuantiles(n, mu = 0, sd = 1) {
  const qnorm = (p) => { // Acklam's approximation
    const a = [-39.6968302866538, 220.946098424521, -275.928510446969, 138.357751867269, -30.6647980661472, 2.50662827745924];
    const b = [-54.4760987982241, 161.585836858041, -155.698979859887, 66.8013118877197, -13.2806815528857];
    const c = [-0.00778489400243029, -0.322396458041136, -2.40075827716184, -2.54973253934373, 4.37466414146497, 2.93816398269878];
    const d = [0.00778469570904146, 0.32246712907004, 2.445134137143, 3.75440866190742];
    const pl = 0.02425;
    if (p < pl) { const q = Math.sqrt(-2 * Math.log(p)); return (((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
    if (p > 1 - pl) { const q = Math.sqrt(-2 * Math.log(1 - p)); return -(((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
    const q = p - 0.5, r = q * q;
    return (((((a[0]*r+a[1])*r+a[2])*r+a[3])*r+a[4])*r+a[5])*q / (((((b[0]*r+b[1])*r+b[2])*r+b[3])*r+b[4])*r+1);
  };
  return Array.from({ length: n }, (_, i) => mu + sd * qnorm((i + 0.5) / n));
}
