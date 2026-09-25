// Widget helpers for the lesson "Model fit and out-of-sample prediction". Pure
// functions only; the plotting is in the lesson's OJS cells. Shared math comes from
// irt.js.
import {logistic, rng, pnorm} from "./irt.js";

// Outfit for every item of one simulated Rasch dataset, computed with the TRUE
// abilities and difficulties (no estimation). Returns {outfit, exactSD}: exactSD[i]
// is the standard deviation of item i's outfit under the model, from
// Var(z^2) = 1/(pq) - 4 for one Bernoulli response (see the Go deeper callout).
export function outfitNull(n, b, seed = 1) {
  const r = rng(seed);
  const theta = Array.from({length: n}, () => r.norm());
  const outfit = [], exactSD = [];
  for (const bi of b) {
    let s = 0, v = 0;
    for (const t of theta) {
      const p = logistic(t - bi), x = r.unif() < p ? 1 : 0;
      s += (x - p) ** 2 / (p * (1 - p));
      v += 1 / (p * (1 - p)) - 4;
    }
    outfit.push(s / n);
    exactSD.push(Math.sqrt(v) / n);
  }
  return {outfit, exactSD};
}

// Solve A x = y by Gaussian elimination with partial pivoting (small systems only).
function solve(A, y) {
  const n = y.length, M = A.map((row, i) => [...row, y[i]]);
  for (let c = 0; c < n; c++) {
    let piv = c;
    for (let r = c + 1; r < n; r++) if (Math.abs(M[r][c]) > Math.abs(M[piv][c])) piv = r;
    [M[c], M[piv]] = [M[piv], M[c]];
    for (let r = c + 1; r < n; r++) {
      const f = M[r][c] / M[c][c];
      for (let k = c; k <= n; k++) M[r][k] -= f * M[c][k];
    }
  }
  const x = Array(n).fill(0);
  for (let r = n - 1; r >= 0; r--) {
    let s = M[r][n];
    for (let k = r + 1; k < n; k++) s -= M[r][k] * x[k];
    x[r] = s / M[r][r];
  }
  return x;
}

// Logistic regression of y (0/1) on a polynomial in x of the given degree, by
// Newton's method. A very small ridge penalty keeps the fit finite when a
// high-degree polynomial separates the data. Returns the coefficients,
// intercept first. Degree 1 is an item's 2PL curve with theta known.
export function polyLogitFit(x, y, degree, ridge = 1e-4) {
  const k = degree + 1;
  const X = x.map(v => Array.from({length: k}, (_, j) => v ** j));
  let beta = Array(k).fill(0);
  for (let it = 0; it < 60; it++) {
    const g = Array(k).fill(0), H = Array.from({length: k}, () => Array(k).fill(0));
    for (let i = 0; i < x.length; i++) {
      const eta = X[i].reduce((s, v, j) => s + v * beta[j], 0);
      const p = logistic(eta), w = p * (1 - p);
      for (let a = 0; a < k; a++) {
        g[a] += (y[i] - p) * X[i][a];
        for (let c = 0; c < k; c++) H[a][c] += w * X[i][a] * X[i][c];
      }
    }
    for (let a = 1; a < k; a++) { g[a] -= ridge * beta[a]; H[a][a] += ridge; }
    const step = solve(H, g);
    beta = beta.map((b, j) => b + step[j]);
    if (step.reduce((s, v) => s + Math.abs(v), 0) < 1e-9) break;
  }
  return beta;
}

export const polyLogitPredict = (beta, x) =>
  logistic(beta.reduce((s, b, j) => s + b * x ** j, 0));

// Mean log likelihood of 0/1 outcomes y under predictions p.
export const meanLogLik = (y, p) =>
  y.reduce((s, v, i) => s + (v ? Math.log(p[i]) : Math.log(1 - p[i])), 0) / y.length;

// The weight w in [0.5, 1) of the coin whose expected log likelihood per toss,
// w log w + (1 - w) log(1 - w), equals the mean log likelihood ll (by bisection).
// Predictions no better than a fair coin get w = 0.5.
export function coinWeight(ll) {
  if (ll <= Math.log(0.5)) return 0.5;
  let lo = 0.5, hi = 1 - 1e-15;
  for (let it = 0; it < 200; it++) {
    const w = (lo + hi) / 2, e = w * Math.log(w) + (1 - w) * Math.log(1 - w);
    if (e < ll) lo = w; else hi = w;
  }
  return (lo + hi) / 2;
}

// The IMV of enhanced predictions p1 over baseline predictions p0 for outcomes y.
export function imv(y, p0, p1) {
  const w0 = coinWeight(meanLogLik(y, p0)), w1 = coinWeight(meanLogLik(y, p1));
  return {w0, w1, imv: (w1 - w0) / w0};
}

// Item response functions that aren't logistic, for the misspecification widget.
// Each maps a(theta - b) to a probability. The complementary log-log and the
// logistic positive exponent (Samejima, 2000) are asymmetric; the Cauchy has heavier
// tails than the logistic.
export const links = {
  "Logistic": z => logistic(z),
  "Normal ogive (probit)": z => pnorm(z),
  "Complementary log-log": z => 1 - Math.exp(-Math.exp(z)),
  "Logistic to the power 4": z => logistic(z) ** 4,
  "Cauchy": z => 0.5 + Math.atan(z) / Math.PI
};
