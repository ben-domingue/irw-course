// Widget helpers for the lesson "Response time and the speed-accuracy tradeoff".
// Pure functions only; colours and the seeded rng come from irt.js. Import with:
//   import {timeSample, betweenWithin, cafWorld, acceleration} from "./widgets/response-time.js"
import {rng, logistic, cor, logisticFit} from "./irt.js";

const median = (x) => { const s = [...x].sort((a, b) => a - b), n = s.length;
  return n % 2 ? s[(n - 1) / 2] : (s[n / 2 - 1] + s[n / 2]) / 2; };
const mean = (x) => x.reduce((u, v) => u + v, 0) / x.length;

// Response times from the lognormal model for one item: log t = beta - tau + e, with
// tau ~ N(0, sdTau) across respondents and e ~ N(0, sigma). Returns the sample and
// its median and mean in seconds.
export function timeSample(beta, sdTau, sigma, n = 2000, seed = 53) {
  const r = rng(seed), rows = [];
  for (let j = 0; j < n; j++) {
    const lt = beta - sdTau * r.norm() + sigma * r.norm();
    rows.push({t: Math.exp(lt), lt});
  }
  const t = rows.map(d => d.t);
  return {rows, median: median(t), mean: mean(t), p99: [...t].sort((a, b) => a - b)[Math.floor(0.99 * n)]};
}

// Between and within. Respondents have theta ~ N(0, 1) and speed tau (SD 0.3)
// correlated rho. Each answers k items of average difficulty with residual log time
// e ~ N(0, 0.4); P(correct) = logistic(theta + delta * e / 0.4), so delta is the
// change in log odds for a response one residual SD slower than expected.
// Returns people (average log time and proportion correct), one short line per person
// showing their own curve over e in [-0.4, 0.4], and the between-person correlation.
export function betweenWithin(rho, delta, nShow = 40, n = 400, k = 30, seed = 7) {
  const r = rng(seed), people = [], lines = [];
  for (let j = 0; j < n; j++) {
    const z1 = r.norm(), z2 = r.norm();
    const theta = z1, tau = 0.3 * (rho * z1 + Math.sqrt(1 - rho * rho) * z2);
    let sumLt = 0, sumX = 0;
    for (let i = 0; i < k; i++) {
      const e = 0.4 * r.norm(), lt = 3.4 - tau + e;
      sumLt += lt; sumX += r.unif() < logistic(theta + delta * e / 0.4) ? 1 : 0;
    }
    people.push({id: j, lt: sumLt / k, p: sumX / k, theta, tau});
    if (j < nShow) for (const e of [-0.4, 0, 0.4])
      lines.push({id: j, lt: 3.4 - tau + e, p: logistic(theta + delta * e / 0.4)});
  }
  return {people: people.slice(0, nShow), lines,
    rBetween: cor(people.map(d => d.lt), people.map(d => d.p))};
}

// The conditional accuracy function. np respondents x ni items, theta ~ N(0, 1),
// difficulties spread evenly; residual log time e ~ N(0, 0.5) independent of theta.
// P(correct) = logistic(theta - b + g(z)), z = e / 0.5, with g set by the shape:
//   none: 0; rising: s z; falling: -s z; inverted U: -s (z^2 - 1) / 2.
// Returns accuracy by decile of e, the overall accuracy and a logistic slope of the
// response on z (pooled over respondents, which e is independent of).
export function cafWorld(shape, s, np = 300, ni = 20, seed = 11) {
  const r = rng(seed), g = (z) => shape === "rising" ? s * z : shape === "falling" ? -s * z :
    shape === "inverted U" ? -s * (z * z - 1) / 2 : 0;
  const rows = [];
  for (let j = 0; j < np; j++) {
    const theta = r.norm();
    for (let i = 0; i < ni; i++) {
      const b = -1.5 + 3 * i / (ni - 1), z = r.norm();
      rows.push({z, x: r.unif() < logistic(theta - b + g(z)) ? 1 : 0});
    }
  }
  rows.sort((a, b) => a.z - b.z);
  const n = rows.length, deciles = [];
  for (let d = 0; d < 10; d++) {
    const part = rows.slice(Math.floor(d * n / 10), Math.floor((d + 1) * n / 10));
    deciles.push({decile: d + 1, p: mean(part.map(v => v.x))});
  }
  const fit = logisticFit(rows.map(v => v.z), rows.map(v => v.x));
  return {deciles, overall: mean(rows.map(v => v.x)), slope: fit.b1};
}

// Response acceleration: a respondent whose time on an item k positions later is
// multiplied by ratio^(k / 10). Items are alike, with a typical time of t1 seconds.
// Returns time by position, the single level a constant-speed model would fit (the
// geometric mean) and the residual log time at the first and last positions.
export function acceleration(ratio, nItems = 40, t1 = 60) {
  const rows = Array.from({length: nItems}, (_, k) => ({position: k + 1, t: t1 * ratio ** (k / 10)}));
  const level = Math.exp(mean(rows.map(d => Math.log(d.t))));
  return {rows, level, first: Math.log(rows[0].t / level), last: Math.log(rows[nItems - 1].t / level),
    after30: ratio ** 3};
}
