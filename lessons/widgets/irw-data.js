// Widget helpers for the irw-data lesson. Pure functions only; colours and the seeded
// rng come from irt.js. Import with:  import {itemRest} from "./widgets/irw-data.js"
import {cor} from "./irt.js";

// Item-rest correlations for a complete response matrix X (an array of rows):
// each column against the sum of the *other* columns.
export function itemRest(X) {
  const p = X[0].length, tot = X.map(r => r.reduce((u, v) => u + v, 0));
  return Array.from({length: p}, (_, j) => cor(X.map(r => r[j]), X.map((r, i) => tot[i] - r[j])));
}
