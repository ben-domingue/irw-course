// Widget helpers for the lesson "Information, precision, and short forms". Pure
// functions only; the plotting is in the lesson's OJS cells. Shared math comes from
// irt.js, and the 4PL curve from the 1PL-to-4PL lesson's helpers.
import {p2pl} from "./irt.js";
import {p4pl} from "./1pl-to-4pl.js";

// Item information under the 4PL family (Rasch: a = 1, c = 0, u = 1):
//   I(theta) = a^2 (P - c)^2 (u - P)^2 / ((u - c)^2 P (1 - P)).
// With c = 0 and u = 1 this is a^2 P (1 - P), the 2PL's; with a = 1 as well, P (1 - P).
export function itemInfo(theta, b, a = 1, c = 0, u = 1) {
  const P = p4pl(theta, b, a, c, u);
  return (a * a * (P - c) ** 2 * (u - P) ** 2) / ((u - c) ** 2 * P * (1 - P));
}

// Test information: the sum of item informations (under local independence).
// items is an array of {b, a, c}; a and c default to 1 and 0.
export const testInfo = (theta, items) =>
  items.reduce((s, it) => s + itemInfo(theta, it.b, it.a ?? 1, it.c ?? 0), 0);

// Rasch log likelihood of a pattern x at theta, for items with difficulties b.
export function raschLoglik(theta, x, b) {
  let ll = 0;
  for (let i = 0; i < x.length; i++) {
    const p = p2pl(theta, b[i]);
    ll += x[i] ? Math.log(p) : Math.log(1 - p);
  }
  return ll;
}

// Rasch maximum-likelihood theta: solve sum_i p_i(theta) = r by bisection. Returns
// -Infinity or +Infinity for a zero or perfect score, where no finite maximum exists.
export function raschMle(x, b) {
  const r = x.reduce((s, v) => s + v, 0);
  if (r === 0) return -Infinity;
  if (r === x.length) return Infinity;
  let lo = -10, hi = 10;
  for (let k = 0; k < 60; k++) {
    const mid = (lo + hi) / 2;
    const e = b.reduce((s, bi) => s + p2pl(mid, bi), 0);
    if (e < r) lo = mid; else hi = mid;
  }
  return (lo + hi) / 2;
}

// Every k-subset of the indices 0..n-1 (for n = 18, k = 5: 8,568 of them).
export function combinations(n, k) {
  const out = [], idx = Array.from({length: k}, (_, i) => i);
  while (true) {
    out.push(idx.slice());
    let i = k - 1;
    while (i >= 0 && idx[i] === n - k + i) i--;
    if (i < 0) return out;
    idx[i]++;
    for (let j = i + 1; j < k; j++) idx[j] = idx[j - 1] + 1;
  }
}

// 2PL estimates for the 18 financial-literacy items (bialowolski_2024_financial_literacy),
// from the lesson's fit-fl chunk (mirt, b = -d/a), to three decimals (the page prints two).
export const flItems = [
  {item: "FL_1", a: 2.172, b: -1.008}, {item: "FL_2", a: 0.141, b: 11.518},
  {item: "FL_3", a: 0.716, b: 1.637}, {item: "FL_4", a: 1.059, b: 0.333},
  {item: "FL_5", a: 1.415, b: 0.041}, {item: "FL_6", a: 1.668, b: -0.651},
  {item: "FL_7", a: 1.199, b: -1.225}, {item: "FL_8", a: 1.103, b: -0.886},
  {item: "FL_9", a: 0.362, b: 0.454}, {item: "FL_10", a: 0.917, b: 1.878},
  {item: "FL_11", a: 1.835, b: -0.186}, {item: "FL_12", a: 2.062, b: -1.083},
  {item: "FL_13", a: 1.523, b: -1.482}, {item: "FL_14", a: 1.932, b: -0.576},
  {item: "FL_15", a: 1.156, b: -0.432}, {item: "FL_16", a: 1.171, b: -3.183},
  {item: "FL_17", a: 1.583, b: -0.213}, {item: "FL_19", a: 1.365, b: -1.144}
];
