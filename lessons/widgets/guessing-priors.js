// Widget helpers for the lesson "Guessing and priors". Pure functions only; the
// plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, grid, dnorm, pnorm, rng} from "./irt.js";

// Invert a 3x3 matrix (returns null if singular).
function inv3(m) {
  const [[a, b, c], [d, e, f], [g, h, k]] = m;
  const A = e * k - f * h, B = -(d * k - f * g), C = d * h - e * g;
  const det = a * A + b * B + c * C;
  if (!Number.isFinite(det) || Math.abs(det) < 1e-300) return null;
  return [
    [A / det, -(b * k - c * h) / det, (b * f - c * e) / det],
    [B / det, (a * k - c * g) / det, -(a * f - c * d) / det],
    [C / det, -(a * h - b * g) / det, (a * e - b * d) / det]];
}

// Standard errors of (a, b, c) for one 3PL item answered by n respondents whose
// abilities are known and normal(mu, 1). The Fisher information for one response
// at theta is g g' / (P(1 - P)), where g holds the derivatives of P with respect
// to a, b and c; we average it over the ability distribution (on a grid), multiply
// by n, and invert. Known abilities make this a best case: with estimated
// abilities the standard errors are larger.
export function se3pl(a, b, c, mu, n) {
  const th = grid(mu - 5, mu + 5, 401);
  const w = th.map(t => dnorm(t, mu, 1));
  const sw = w.reduce((s, v) => s + v, 0);
  const I = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
  th.forEach((t, k) => {
    const L = logistic(a * (t - b)), P = c + (1 - c) * L;
    const g = [(1 - c) * L * (1 - L) * (t - b), -(1 - c) * L * (1 - L) * a, 1 - L];
    const wt = w[k] / sw / (P * (1 - P));
    for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) I[i][j] += n * wt * g[i] * g[j];
  });
  const V = inv3(I);
  if (!V) return {a: Infinity, b: Infinity, c: Infinity};
  return {a: Math.sqrt(V[0][0]), b: Math.sqrt(V[1][1]), c: Math.sqrt(V[2][2])};
}

// Share of respondents (abilities normal(mu, 1)) for whom the item's logistic part
// is below 0.1, so that a correct response from them is mostly chance: the people
// from whom the data learn about c. logistic(a(theta - b)) < 0.1 when
// theta < b - log(9)/a.
export const shareNearFloor = (a, b, mu) => pnorm(b - Math.log(9) / a - mu);

// One item's slope from n respondents with known abilities (difficulty 0, no
// lower asymptote): simulated responses, the log likelihood over a grid of slopes,
// a lognormal prior (log a ~ normal(0, sdlog)), and the posterior. The first n of
// 2,000 seeded respondents are used, so more respondents add data rather than
// redraw it. Returns curves scaled to a peak of 1, and the MLE, the posterior
// mode (MAP) and the posterior mean (EAP) of the slope.
export function slopePosterior(n, aTrue, sdlog, seed = 11) {
  const r = rng(seed);
  const all = Array.from({length: 2000}, () => {
    const t = r.norm();
    return {t, x: r.unif() < logistic(aTrue * t) ? 1 : 0};
  });
  const d = all.slice(0, n);
  const as = grid(0.02, 8, 800);
  const ll = as.map(a => d.reduce((s, o) => {
    const p = logistic(a * o.t);
    return s + (o.x ? Math.log(p) : Math.log(1 - p));
  }, 0));
  const lp = as.map(a => -Math.log(a) - Math.log(a) ** 2 / (2 * sdlog * sdlog));
  const lpost = ll.map((v, k) => v + lp[k]);
  const scale = v => { const m = Math.max(...v); return v.map(u => Math.exp(u - m)); };
  const L = scale(ll), prior = scale(lp), post = scale(lpost);
  const argmax = v => v.reduce((bi, u, k) => (u > v[bi] ? k : bi), 0);
  const sp = post.reduce((s, v) => s + v, 0);
  const eap = as.reduce((s, a, k) => s + a * post[k], 0) / sp;
  const kMle = argmax(ll);
  return {as, L, prior, post, mle: kMle === as.length - 1 ? Infinity : as[kMle],
          map: as[argmax(lpost)], eap};
}
