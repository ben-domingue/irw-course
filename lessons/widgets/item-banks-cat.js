// Widget helpers for the lesson "Item banks and adaptive testing". Pure functions only;
// the plotting is in the lesson's OJS cells. Shared math comes from irt.js.
// Everything here is a 2PL bank with known item parameters, EAP scoring on a grid of
// nodes under a standard normal prior, and selection by Fisher information.
import {p2pl, dnorm, grid, rng, normalQuantiles} from "./irt.js";

// Nodes and prior for EAP, as in the lesson's R engine (coarser, for speed).
export const catNodes = grid(-5, 5, 101);
const prior = catNodes.map(t => dnorm(t));

// A 2PL bank of n items: difficulties spread as normal quantiles around `mean` with SD
// `sd`, slopes lognormal (median 1.2, log-SD 0.3) from a seeded generator, so the bank
// changes only when a control does.
export function makeBank(n, mean = 0, sd = 1, seed = 11) {
  const r = rng(seed);
  return normalQuantiles(n, mean, sd).map((b, i) => ({id: i, b, a: 1.2 * Math.exp(0.3 * r.norm())}));
}

// 2PL item information a^2 P (1 - P).
export const info2pl = (theta, it) => { const p = p2pl(theta, it.b, it.a); return it.a * it.a * p * (1 - p); };

// Posterior summary from log likelihood values on the nodes.
export function eapFrom(ll) {
  const m = Math.max(...ll);
  const w = ll.map((v, k) => Math.exp(v - m) * prior[k]);
  const s = w.reduce((u, v) => u + v, 0);
  const post = w.map(v => v / s);
  const th = post.reduce((u, v, k) => u + v * catNodes[k], 0);
  const sd = Math.sqrt(post.reduce((u, v, k) => u + v * (catNodes[k] - th) ** 2, 0));
  return {theta: th, sd, post};
}

// Maximum-likelihood estimate for a 2PL pattern by bisection on the score equation;
// null when every response is the same (no finite maximum).
export function mle2pl(items, xs) {
  const r = xs.reduce((u, v) => u + v, 0);
  if (r === 0 || r === xs.length) return null;
  const score = t => items.reduce((u, it, i) => u + it.a * (xs[i] - p2pl(t, it.b, it.a)), 0);
  let lo = -10, hi = 10;
  for (let k = 0; k < 60; k++) { const mid = (lo + hi) / 2; if (score(mid) > 0) lo = mid; else hi = mid; }
  return (lo + hi) / 2;
}

// One simulated CAT. The respondent's true theta is `theta`; `u` supplies uniform draws
// (one per bank item, so a respondent's answer to an item doesn't depend on when it is
// given). Options: maxItems, seStop (posterior SD at which to stop), select ("info" or
// "random" or "astrat"), top (randomesque: pick at random among the `top` most
// informative), and pick (a uniform generator for the random choices). "astrat" is
// a-stratified selection (Chang & Ying, 1999): the bank is split into four strata by
// slope, the test moves from the flattest stratum to the steepest in equal stages, and
// within a stratum the item whose b is closest to the EAP is given. Returns every step.
export function runCat(theta, bank, u, {maxItems = 20, seStop = 0, select = "info", top = 1, pick = Math.random} = {}) {
  const strata = select === "astrat" ? slopeStrata(bank, 4) : null;
  const ll = catNodes.map(() => 0);
  const used = new Set();
  const steps = [];
  let est = eapFrom(ll);
  while (steps.length < maxItems && est.sd > seStop && used.size < bank.length) {
    const avail = bank.filter(it => !used.has(it.id));
    let chosen;
    if (select === "random") {
      chosen = avail[Math.floor(pick() * avail.length)];
    } else if (select === "astrat") {
      const stage = Math.min(3, Math.floor(4 * steps.length / maxItems));
      const pool = avail.filter(it => strata.get(it.id) === stage);
      const from = pool.length ? pool : avail;
      chosen = from.reduce((p, q) => Math.abs(q.b - est.theta) < Math.abs(p.b - est.theta) ? q : p);
    } else {
      const ranked = avail.map(it => ({it, I: info2pl(est.theta, it)})).sort((p, q) => q.I - p.I);
      chosen = ranked[Math.floor(pick() * Math.min(top, ranked.length))].it;
    }
    const x = u[chosen.id] < p2pl(theta, chosen.b, chosen.a) ? 1 : 0;
    const before = est;
    catNodes.forEach((t, k) => { const p = p2pl(t, chosen.b, chosen.a); ll[k] += x ? Math.log(p) : Math.log(1 - p); });
    used.add(chosen.id);
    est = eapFrom(ll);
    steps.push({item: chosen, x, infoAtStart: info2pl(before.theta, chosen), thetaBefore: before.theta,
                eap: est.theta, sd: est.sd, post: est.post});
  }
  return steps;
}

// Stratum (0 = flattest) of each item, by slope, in k strata of equal size.
function slopeStrata(bank, k) {
  const sorted = [...bank].sort((p, q) => p.a - q.a);
  return new Map(sorted.map((it, i) => [it.id, Math.floor(k * i / sorted.length)]));
}

// Many CATs at once: `per` respondents at each true theta in `thetas`, with seeded
// draws. Returns one row per respondent: true theta, final EAP, posterior SD, items used,
// and the ids of the items given.
export function simulateCats(bank, thetas, per, opts, seed = 5) {
  const r = rng(seed);
  const rows = [];
  for (const th of thetas) {
    for (let k = 0; k < per; k++) {
      const u = bank.map(() => r.unif());
      const steps = runCat(th, bank, u, {...opts, pick: r.unif});
      const last = steps[steps.length - 1];
      rows.push({theta: th, eap: last.eap, sd: last.sd, n: steps.length, ids: steps.map(s => s.item.id)});
    }
  }
  return rows;
}

// Respondents drawn from a standard normal, for the exposure widget.
export function normalThetas(n, seed = 3) {
  const r = rng(seed);
  return Array.from({length: n}, () => r.norm());
}
