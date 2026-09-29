// Widget helpers for the lesson "Continuous responses: sliders and bounded scales".
// Pure functions only; the plotting is in the lesson's OJS cells. Shared math comes
// from irt.js. Responses are on [0, 1] (a 0-100 slider divided by 100).
import {logistic, pnorm, dnorm, grid, rng, cor} from "./irt.js";

const logit = (p) => Math.log(p / (1 - p));

// Inverse standard normal CDF (Acklam's rational approximation, error < 1.2e-9).
export function qnorm(p) {
  const a = [-39.69683028665376, 220.9460984245205, -275.9285104469687, 138.357751867269, -30.66479806614716, 2.506628277459239];
  const b = [-54.47609879822406, 161.5858368580409, -155.6989798598866, 66.80131188771972, -13.28068155211397];
  const c = [-0.007784894002430293, -0.3223964580411365, -2.400758277161838, -2.549732539343734, 4.374664141464968, 2.938163982698783];
  const d = [0.007784695709041462, 0.3224671290700398, 2.445134137142996, 3.754408661907416];
  const lo = 0.02425;
  if (p < lo) { const q = Math.sqrt(-2 * Math.log(p)); return (((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
  if (p > 1 - lo) { const q = Math.sqrt(-2 * Math.log(1 - p)); return -(((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
  const q = p - 0.5, r = q * q;
  return (((((a[0]*r+a[1])*r+a[2])*r+a[3])*r+a[4])*r+a[5])*q / (((((b[0]*r+b[1])*r+b[2])*r+b[3])*r+b[4])*r+1);
}

// Log gamma (Lanczos), for the beta density.
function lgamma(x) {
  const g = [676.5203681218851, -1259.1392167224028, 771.32342877765313, -176.61502916214059,
             12.507343278686905, -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7];
  if (x < 0.5) return Math.log(Math.PI / Math.sin(Math.PI * x)) - lgamma(1 - x);
  x -= 1; let s = 0.99999999999980993;
  for (let i = 0; i < 8; i++) s += g[i] / (x + i + 1);
  const t = x + 7.5;
  return 0.5 * Math.log(2 * Math.PI) + (x + 0.5) * Math.log(t) - t + Math.log(s);
}

// Samejima's model on [0, 1]: logit(x) = a (theta - b) + e, e ~ N(0, sigma^2).
// Returns the median and the 2.5% and 97.5% points of x, and the mean.
export function samejimaBand(theta, a, b, sigma) {
  const m = a * (theta - b);
  const nodes = grid(-4, 4, 81), w = nodes.map(u => dnorm(u)), sw = w.reduce((u, v) => u + v, 0);
  const mean = nodes.reduce((s, u, k) => s + w[k] * logistic(m + sigma * u), 0) / sw;
  const sd = Math.sqrt(nodes.reduce((s, u, k) => s + w[k] * (logistic(m + sigma * u) - mean) ** 2, 0) / sw);
  return {median: logistic(m), lo: logistic(m - 1.96 * sigma), hi: logistic(m + 1.96 * sigma), mean, sd};
}

// The linear model that best matches a Samejima item across theta ~ N(0, 1): the
// regression of x on theta, and its residual SD (constant, by assumption).
export function linearMatch(a, b, sigma) {
  const th = grid(-4, 4, 161), w = th.map(t => dnorm(t)), sw = w.reduce((u, v) => u + v, 0);
  const band = th.map(t => samejimaBand(t, a, b, sigma));
  const mx = band.reduce((s, q, k) => s + w[k] * q.mean, 0) / sw;
  const slope = band.reduce((s, q, k) => s + w[k] * th[k] * (q.mean - mx), 0) / sw;  // var(theta) = 1
  const resid = band.reduce((s, q, k) => s + w[k] * (q.sd ** 2 + (q.mean - mx - slope * th[k]) ** 2), 0) / sw;
  return {intercept: mx, slope, sd: Math.sqrt(resid)};
}

// Densities on (0, 1) at one theta.
export const logitNormalDens = (x, mu, sigma) => dnorm(logit(x), mu, sigma) / (x * (1 - x));
export function betaDens(x, mean, phi) {
  const p = mean * phi, q = (1 - mean) * phi;
  return Math.exp((p - 1) * Math.log(x) + (q - 1) * Math.log(1 - x) + lgamma(p + q) - lgamma(p) - lgamma(q));
}
// Share of a beta(mean, phi) above x0, by the midpoint rule on a fine grid.
export function betaUpper(x0, mean, phi, n = 4000) {
  let s = 0; const h = (1 - x0) / n;
  for (let k = 0; k < n; k++) s += betaDens(x0 + (k + 0.5) * h, mean, phi) * h;
  return s;
}

// The squeeze constant. np respondents answer two items; the logit of each response
// is 1.5 theta + shift + N(0, 1) noise, and the response is rounded to a whole
// number on 0-100, so every response above 99.5 is recorded as 100.
export function squeezeSample(np, shift, seed = 7) {
  const r = rng(seed);
  const round = z => Math.round(100 * logistic(z));
  const x1 = [], x2 = [];
  for (let j = 0; j < np; j++) {
    const t = r.norm();
    x1.push(round(1.5 * t + shift + r.norm())); x2.push(round(1.5 * t + shift + r.norm()));
  }
  return {x1, x2};
}
export const squeeze = (x, nu) => Math.log((x + nu) / (100 - x + nu));
// Two items with equal loadings: lambda^2 = r, and each carries r / (1 - r).
export function twoItemInfo(x1, x2) { const r = cor(x1, x2); return {r, info: 2 * r / (1 - r)}; }

// Cutting the line. The latent response y* = lambda theta + e (var(y*) = 1) is
// observed on a line from -3 to 3 and cut into K bins, either of equal width or
// holding equal shares of respondents. Returns the thresholds.
export function cuts(K, kind = "equal") {
  return Array.from({length: K - 1}, (_, k) => kind === "equal" ? -3 + 6 * (k + 1) / K : qnorm((k + 1) / K));
}
// Information in the cut item at theta: sum over bins of (P_k')^2 / P_k.
export function cutInfo(theta, lambda, t) {
  const s = Math.sqrt(1 - lambda * lambda);
  const u = [-Infinity, ...t, Infinity].map(v => (v - lambda * theta) / s);
  let I = 0;
  for (let k = 0; k < u.length - 1; k++) {
    const P = (k === u.length - 2 ? 1 : pnorm(u[k + 1])) - (k === 0 ? 0 : pnorm(u[k]));
    const dP = -(lambda / s) * ((k === u.length - 2 ? 0 : dnorm(u[k + 1])) - (k === 0 ? 0 : dnorm(u[k])));
    if (P > 1e-12) I += dP * dP / P;
  }
  return I;
}
export const lineInfo = (lambda) => lambda * lambda / (1 - lambda * lambda);
