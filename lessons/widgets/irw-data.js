// Widget helpers for the irw-data lesson. Pure functions only; colours and the seeded
// rng come from irt.js. Import with:  import {median, itemRest} from "./widgets/irw-data.js"
import {cor} from "./irt.js";

// Median of an array of numbers (NaN for an empty array).
export function median(v) {
  if (!v.length) return NaN;
  const s = v.slice().sort((x, y) => x - y), m = s.length >> 1;
  return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
}

// Item-rest correlations for a complete response matrix X (an array of rows):
// each column against the sum of the *other* columns.
export function itemRest(X) {
  const p = X[0].length, tot = X.map(r => r.reduce((u, v) => u + v, 0));
  return Array.from({length: p}, (_, j) => cor(X.map(r => r[j]), X.map((r, i) => tot[i] - r[j])));
}
