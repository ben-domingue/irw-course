// Widget helpers for the lesson "Fairness in testing". Pure functions only; colours
// and the seeded rng come from irt.js. Import with:
//   import {twoGroups, anchorView, simCleary} from "./widgets/fairness.js"
import {rng} from "./irt.js";

const mean = (v) => v.reduce((u, x) => u + x, 0) / v.length;
const median = (v) => { const s = [...v].sort((a, b) => a - b), m = s.length >> 1; return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2; };

// Impact and bias. Two groups of n; each respondent has a true standing (reference
// mean 0, focal mean -impact, SD 1) and a measurement error with SD `err`. A bias
// adds -bias to every focal respondent's observed score. The standard normals are
// drawn once per seed, so moving a slider moves the same people.
export function twoGroups({seed = 5, n = 400} = {}) {
  const r = rng(seed);
  const z = Array.from({length: 2 * n}, () => r.norm()), e = Array.from({length: 2 * n}, () => r.norm());
  return function at({impact = 1, bias = 0, err = 0.4} = {}) {
    const rows = z.map((t, i) => {
      const focal = i >= n, truth = t - (focal ? impact : 0);
      return {group: focal ? "focal" : "reference", truth, observed: truth + err * e[i] - (focal ? bias : 0)};
    });
    const pick = (g, k) => mean(rows.filter(d => d.group === g).map(d => d[k]));
    return {rows, trueGap: pick("focal", "truth") - pick("reference", "truth"),
            observedGap: pick("focal", "observed") - pick("reference", "observed")};
  };
}

// What the data can see. Each item's difficulty for the focal group is its
// reference difficulty plus a shift: `all` for every item, plus `one` for item k.
// Without knowing theta, the data fix the focal group's scale only up to a
// constant, so a multigroup model puts the groups on one scale through the items
// and reports each item's shift relative to the others (here, relative to the
// median shift, a robust stand-in for an anchor). A shift shared by every item
// ends up in the estimated group difference instead.
export function anchorView({nItems = 8, k = 3, one = 0, all = 0, impact = 0.5} = {}) {
  const items = Array.from({length: nItems}, (_, i) => {
    const shift = all + (i === k ? one : 0);
    return {item: `item ${i + 1}`, shift};
  });
  const m = median(items.map(d => d.shift));
  return {
    items: items.map(d => ({...d, seen: d.shift - m})),
    trueImpact: impact, apparentImpact: impact + m
  };
}

// Predictive bias. n per group. theta ~ N(0, 1) in the reference group and
// N(-impact, 1) in the focal group; the test score is theta plus error, with
// within-group reliability `rel`; the criterion is theta plus noise (SD 0.5), minus
// `bias` for the focal group (a real difference in the criterion that the test
// doesn't carry). Returns the points, each group's least-squares line, the common
// line, and the focal group's mean residual from the common line (negative: the
// common line over-predicts the focal group).
export function simCleary({seed = 9, n = 300, impact = 1, rel = 0.7, bias = 0} = {}) {
  const r = rng(seed), errSD = Math.sqrt((1 - rel) / rel), pts = [];
  for (let i = 0; i < 2 * n; i++) {
    const focal = i >= n, th = r.norm() - (focal ? impact : 0);
    pts.push({group: focal ? "focal" : "reference", x: th + errSD * r.norm(), y: th + 0.5 * r.norm() - (focal ? bias : 0)});
  }
  const ols = (d) => {
    const mx = mean(d.map(p => p.x)), my = mean(d.map(p => p.y));
    const sxy = d.reduce((u, p) => u + (p.x - mx) * (p.y - my), 0), sxx = d.reduce((u, p) => u + (p.x - mx) ** 2, 0);
    const slope = sxy / sxx;
    return {slope, intercept: my - slope * mx};
  };
  const ref = ols(pts.filter(p => p.group === "reference")), foc = ols(pts.filter(p => p.group === "focal")), common = ols(pts);
  const focalResid = mean(pts.filter(p => p.group === "focal").map(p => p.y - (common.intercept + common.slope * p.x)));
  return {pts, ref, foc, common, focalResid};
}
