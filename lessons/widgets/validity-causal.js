// Widget helpers for the lesson "Validity as causation". Pure functions only;
// colours and the seeded rng come from irt.js. Import with:
//   import {ruleAnswer, torqueAnswer, itemType, ITEM_TYPES, RULE_P, mixAt, simEffects} from "./widgets/validity-causal.js"
import {rng, cor} from "./irt.js";

const side = (x) => (x > 0 ? "left" : x < 0 ? "right" : "balance");

// The correct answer for one stack of wl weights on peg dl (left) and wr on dr (right).
export const torqueAnswer = (wl, dl, wr, dr) => side(wl * dl - wr * dr);

// Each rule's answer, after Siegler (1976) as described by Borsboom et al. (2004):
// I   weights only;
// II  weights, and distance only when the weights are equal;
// III weights and distance, guessing when they point opposite ways;
// IV  compare weight x distance on each side.
// "guess" means the child picks one of the three answers at random.
export function ruleAnswer(rule, wl, dl, wr, dr) {
  const w = side(wl - wr), d = side(dl - dr);
  if (rule === 1) return w;
  if (rule === 2) return w !== "balance" ? w : d;
  if (rule === 3) {
    if (w === "balance") return d;
    if (d === "balance" || d === w) return w;
    return "guess";
  }
  return torqueAnswer(wl, dl, wr, dr);
}

// Chance that a rule gives the right answer on this item (1/3 for a guess).
export function ruleCorrect(rule, wl, dl, wr, dr) {
  const a = ruleAnswer(rule, wl, dl, wr, dr);
  return a === "guess" ? 1 / 3 : a === torqueAnswer(wl, dl, wr, dr) ? 1 : 0;
}

// Six kinds of item, by how weight and distance relate and which side wins.
export const ITEM_TYPES = [
  {key: "same", label: "Same weights, same distances", ex: [2, 2, 2, 2]},
  {key: "weight", label: "Weights differ, same distances", ex: [3, 2, 2, 2]},
  {key: "distance", label: "Same weights, distances differ", ex: [2, 3, 2, 2]},
  {key: "cw", label: "Conflict: heavier side goes down", ex: [4, 2, 2, 3]},
  {key: "cd", label: "Conflict: farther side goes down", ex: [2, 4, 3, 2]},
  {key: "cb", label: "Conflict: it balances", ex: [3, 2, 2, 3]}
];

export function itemType(wl, dl, wr, dr) {
  const w = side(wl - wr), d = side(dl - dr), t = torqueAnswer(wl, dl, wr, dr);
  if (w === "balance" && d === "balance") return "same";
  if (d === "balance") return "weight";
  if (w === "balance") return "distance";
  if (w === d) return "agree";    // both cues point the same way: every rule gets it right
  if (t === "balance") return "cb";
  return t === w ? "cw" : "cd";
}

// Expected proportion correct for each rule (rows I to IV) on each item type.
export const RULE_P = [1, 2, 3, 4].map(r => ITEM_TYPES.map(t => ruleCorrect(r, ...t.ex)));

// Stylized development: shares of children using rules I to IV at a position
// `pos` (0 = everyone on rule I, 3 = everyone on rule IV); `spread` is how far rule
// use overlaps around that position. Not data.
export function mixAt(pos, spread) {
  const w = [0, 1, 2, 3].map(k => Math.exp(-0.5 * ((k - pos) / Math.max(spread, 0.05)) ** 2));
  const s = w.reduce((u, v) => u + v, 0);
  return w.map(v => v / s);
}

// Expected proportion correct on each item type for a mix of rule users.
export const mixP = (mix) => ITEM_TYPES.map((_, j) => mix.reduce((u, m, r) => u + m * RULE_P[r][j], 0));

// A Stroop-like task twice over. Each of n respondents has a true conflict effect
// drawn from N(mu, tau); each session estimates it from `trials` trials per
// condition with trial SD sigma. Returns both sessions' estimates and summaries.
export function simEffects({n = 250, mu = 0.11, tau = 0.1, sigma = 0.8, trials = 25, seed = 1}) {
  const r = rng(seed), se = sigma * Math.sqrt(2 / trials);
  const truth = Array.from({length: n}, () => mu + tau * r.norm());
  const e1 = truth.map(v => v + se * r.norm()), e2 = truth.map(v => v + se * r.norm());
  const m = e1.reduce((u, v) => u + v, 0) / n;
  const sd = Math.sqrt(e1.reduce((u, v) => u + (v - m) ** 2, 0) / (n - 1));
  return {
    pts: e1.map((v, i) => ({s1: v, s2: e2[i]})),
    mean: m, t: m / (sd / Math.sqrt(n)), pos: e1.filter(v => v > 0).length / n,
    r: cor(e1, e2), rel: tau * tau / (tau * tau + se * se)
  };
}
