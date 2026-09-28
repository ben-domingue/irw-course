// Widget helpers for the competitions lesson (Bradley-Terry and Elo).
// Pure functions; colours and the seeded rng come from irt.js.
import {logistic, rng} from "./irt.js";

// Bradley-Terry by the MM (Zermelo) iteration (Zermelo, 1929; Hunter, 2004).
// n[i][k]: games between i and k (symmetric); w[i][k]: i's wins over k (a draw
// counts half to each). Returns strengths on the logit scale, centred at mean 0,
// after `iters` iterations. When an agent never loses, its strength never settles.
export function btMM(n, w, iters = 200) {
  const m = n.length;
  const W = w.map(row => row.reduce((s, v) => s + v, 0));
  let pi = Array(m).fill(1);
  for (let it = 0; it < iters; it++) {
    const next = pi.map((p, i) => {
      let denom = 0;
      for (let k = 0; k < m; k++) if (k !== i && n[i][k] > 0) denom += n[i][k] / (p + pi[k]);
      return denom > 0 ? W[i] / denom : p;
    });
    // Rescale so the log-strengths have mean 0 (the origin is ours to choose).
    const g = next.reduce((s, v) => s + Math.log(Math.max(v, 1e-300)), 0) / m;
    pi = next.map(v => Math.max(v, 1e-300) / Math.exp(g));
  }
  return pi.map(v => Math.log(v));
}

// The strength-of-schedule league: two divisions of three, a share `within` of
// each team's `games` against its own division. Returns games and expected wins
// under Bradley-Terry with the given strengths (no noise).
export function divisionLeague(theta, within, games = 40) {
  const m = theta.length, div = theta.map((_, i) => (i < m / 2 ? 0 : 1));
  const nw = (games * within) / (m / 2 - 1), nc = (games * (1 - within)) / (m / 2);
  const n = theta.map((_, i) => theta.map((_, k) => (i === k ? 0 : div[i] === div[k] ? nw : nc)));
  const w = n.map((row, i) => row.map((g, k) => g * logistic(theta[i] - theta[k])));
  return {n, w};
}

// Elo tracking one agent whose true strength jumps from 0 to `jump` halfway
// through. Opponents' strengths are drawn from N(0, 0.5^2) and known exactly, so
// only our agent's rating moves. Returns one row per game.
export function eloTrack(K, jump = 1, games = 200, seed = 1) {
  const r = rng(seed);
  let rating = 0;
  const out = [];
  for (let g = 1; g <= games; g++) {
    const truth = g > games / 2 ? jump : 0;
    const opp = 0.5 * r.norm();
    const y = r.unif() < logistic(truth - opp) ? 1 : 0;
    const p = logistic(rating - opp);
    rating += K * (y - p);
    out.push({game: g, truth, rating});
  }
  return out;
}
