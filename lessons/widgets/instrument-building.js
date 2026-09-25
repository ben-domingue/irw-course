// Widget helpers for the lesson "From construct map to items". Pure functions only;
// colours and the seeded rng come from irt.js. Import with:
//   import {alphaOf, simWording, simAcquiescence, spearmanBrown} from "./widgets/instrument-building.js"
import {rng, cor, corMatrix, eigenSym} from "./irt.js";

// Cut a continuous response into four ordered categories, 1 to 4, at -1, 0 and 1
// (as cut(..., breaks = c(-Inf, -1, 0, 1, Inf)) does in the lesson's R code).
const cut4 = z => (z <= -1 ? 1 : z <= 0 ? 2 : z <= 1 ? 3 : 4);

const mean = a => a.reduce((u, v) => u + v, 0) / a.length;
const variance = a => { const m = mean(a); return a.reduce((u, v) => u + (v - m) ** 2, 0) / (a.length - 1); };

// Cronbach's alpha for a response matrix X (an array of respondents' rows).
export function alphaOf(X) {
  const k = X[0].length;
  const itemVar = Array.from({length: k}, (_, j) => variance(X.map(r => r[j])));
  const tot = X.map(r => r.reduce((u, v) => u + v, 0));
  return (k / (k - 1)) * (1 - itemVar.reduce((u, v) => u + v, 0) / variance(tot));
}

// Spearman-Brown: reliability of a test m times as long as one with reliability rho.
export const spearmanBrown = (rho, m) => m * rho / (1 + (m - 1) * rho);

// Ten four-point items, keyed: items 1-5 worded forward, 6-10 reversed. Each item
// loads `lambda` on the trait; the reversed items load `gamma` on a wording factor,
// the forward items `gammaF` on one of their own. Mirrors code/instrument-building-sim.R.
export function simWording({seed = 56, n = 600, lambda = 0.6, gamma = 0.6, gammaF = 0} = {}) {
  const r = rng(seed), X = [], trait = [];
  for (let j = 0; j < n; j++) {
    const t = r.norm(), w = r.norm(), wf = r.norm();
    trait.push(t);
    X.push(Array.from({length: 10}, (_, i) => {
      const g = i < 5 ? gammaF : gamma, f = i < 5 ? wf : w;
      const e = Math.sqrt(Math.max(0, 1 - lambda ** 2 - g ** 2));
      return cut4(lambda * t + g * f + e * r.norm());
    }));
  }
  const R = corMatrix(X);
  const avg = (a, b) => { const v = []; for (const i of a) for (const k of b) if (i < k || a !== b) v.push(R[i][k]); return mean(v); };
  const F = [0, 1, 2, 3, 4], V = [5, 6, 7, 8, 9];
  return {
    R, alpha: alphaOf(X), eig: eigenSym(R),
    withinF: avg(F, F), withinR: avg(V, V), across: avg(F, V),
    r2: cor(X.map(row => row.reduce((u, v) => u + v, 0)), trait) ** 2
  };
}

// Acquiescence: every respondent adds their own tendency to agree (SD `acq`) to the
// raw agreement with every item, whatever its direction. Ten four-point items loading
// 0.6 on the trait. Returns alpha and the squared correlation of the keyed sum score
// with the trait for an all-forward scale and a balanced one (five items reversed and
// then keyed, x -> 5 - x).
export function simAcquiescence({seed = 7, n = 600, acq = 0.5, lambda = 0.6} = {}) {
  const r = rng(seed), fwd = [], bal = [], trait = [];
  const e = Math.sqrt(1 - lambda ** 2);
  for (let j = 0; j < n; j++) {
    const t = r.norm(), a = acq * r.norm();
    trait.push(t);
    const rowF = [], rowB = [];
    for (let i = 0; i < 10; i++) {
      const noise = e * r.norm();
      rowF.push(cut4(lambda * t + noise + a));
      // Reversed: agreeing means less of the trait; key it afterwards.
      rowB.push(i < 5 ? cut4(lambda * t + noise + a) : 5 - cut4(-lambda * t + noise + a));
    }
    fwd.push(rowF); bal.push(rowB);
  }
  const sum = X => X.map(row => row.reduce((u, v) => u + v, 0));
  return {
    forward: {alpha: alphaOf(fwd), r2: cor(sum(fwd), trait) ** 2},
    balanced: {alpha: alphaOf(bal), r2: cor(sum(bal), trait) ** 2}
  };
}
