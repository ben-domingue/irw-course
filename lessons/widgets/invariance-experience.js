// Widget helpers for the lesson "Measurement invariance under treatment and life
// events". Pure functions only; the plotting is in the lesson's OJS cells. Shared
// math comes from irt.js; the Mantel-Haenszel statistic from dif.js.
import {logistic, rng, normalQuantiles} from "./irt.js";
import {mhItem, scores} from "./dif.js";

// Item difficulties b_i (evenly spread normal quantiles, SD about 1) and item-specific
// departures zeta_i with SD sigmaZeta and correlation rho with b_i, built exactly (so
// the zeta_i average 0 and correlate rho with b_i). The shape of the zeta_i that is
// unrelated to difficulty comes from a seeded draw, fixed as the sliders move.
export function itemEffects({nItems = 20, sigmaZeta = 0.5, rho = 0, seed = 7}) {
  const b = normalQuantiles(nItems);
  const mean = (x) => x.reduce((u, v) => u + v, 0) / x.length;
  const sd = (x) => { const m = mean(x); return Math.sqrt(x.reduce((u, v) => u + (v - m) ** 2, 0) / (x.length - 1)); };
  const z1 = b.map(v => (v - mean(b)) / sd(b));
  const r = rng(seed);
  const raw = b.map(() => r.norm());
  // Residual of raw on z1 (both centred), standardized: orthogonal to difficulty.
  const mr = mean(raw);
  const slope = raw.reduce((u, v, i) => u + (v - mr) * z1[i], 0) / z1.reduce((u, v) => u + v * v, 0);
  const res = raw.map((v, i) => v - mr - slope * z1[i]);
  const w = res.map(v => v / sd(res));
  const zeta = z1.map((v, i) => sigmaZeta * (rho * v + Math.sqrt(1 - rho * rho) * w[i]));
  return {b, zeta};
}

// Expected proportion correct on item i in each arm, theta ~ N(0, 1) in control and
// N(beta1, 1) in the treated arm, with the treated arm's item also shifted by zeta_i.
// Integrated over 41 normal quantiles.
const QUAD = normalQuantiles(41);
export function expectedCorrect(b, zeta, beta1) {
  return b.map((bi, i) => {
    let pc = 0, pt = 0;
    for (const t of QUAD) {
      pc += logistic(t - bi);
      pt += logistic(t + beta1 - bi + zeta[i]);
    }
    return {control: pc / QUAD.length, treated: pt / QUAD.length};
  });
}

// A simulated randomized trial for the placebo widget. nPer respondents per arm answer
// nItems Rasch items at a pretest (no treatment yet) and a posttest (treated theta up by
// beta1, and item i easier for them by a further zeta_i). Returns the Mantel-Haenszel
// statistics by treatment (focal = treated) at each wave, matching on the total.
export function placeboTrial({seed = 3, nPer = 200, nItems = 30, beta1 = 0.5, sigmaZeta = 0.5}) {
  const r = rng(seed);
  const {b, zeta} = itemEffects({nItems, sigmaZeta, rho: 0, seed: seed + 1});
  const X0 = [], X1 = [], g = [];
  for (let grp = 0; grp < 2; grp++) {
    for (let j = 0; j < nPer; j++) {
      const th = r.norm();
      X0.push(b.map(bi => (r.unif() < logistic(th - bi) ? 1 : 0)));
      X1.push(b.map((bi, i) => (r.unif() < logistic(th + 0.5 + grp * (beta1 + zeta[i]) - bi) ? 1 : 0)));
      g.push(grp);
    }
  }
  const run = (X) => {
    const s = scores(X);
    return b.map((_, i) => ({item: i, ...mhItem(X.map(row => row[i]), g, s)}));
  };
  return {pre: run(X0), post: run(X1), zeta};
}

// The population regression of the expected sum score on treatment, pretest and their
// product, with no person-level heterogeneity: theta = 0.7 pre + e (e ~ N(0, 0.51))
// + beta1 T, and item i's treated difficulty lowered by zeta_i. Pretest values are 41
// normal quantiles, e is integrated over 21. Returns the expected sums on the pretest
// grid for each arm and the OLS coefficients (per SD of pretest).
export function spuriousInteraction({b, zeta, beta1 = 0.5}) {
  const pre = normalQuantiles(41), e = normalQuantiles(21, 0, Math.sqrt(0.51));
  const expSum = (p, T) => {
    let s = 0;
    for (const ei of e) for (let i = 0; i < b.length; i++) s += logistic(0.7 * p + ei + beta1 * T - b[i] + T * zeta[i]);
    return s / e.length;
  };
  const rows = [];
  for (const T of [0, 1]) for (const p of pre) rows.push({T, pre: p, s: expSum(p, T)});
  // Separate lines in each arm are the same as the saturated OLS fit.
  const line = (T) => {
    const d = rows.filter(r => r.T === T), n = d.length;
    const mx = d.reduce((u, r) => u + r.pre, 0) / n, my = d.reduce((u, r) => u + r.s, 0) / n;
    const sl = d.reduce((u, r) => u + (r.pre - mx) * (r.s - my), 0) / d.reduce((u, r) => u + (r.pre - mx) ** 2, 0);
    return {intercept: my - sl * mx, slope: sl};
  };
  const c = line(0), t = line(1);
  return {rows, control: c, treated: t, interaction: t.slope - c.slope, effect: t.intercept - c.intercept};
}
