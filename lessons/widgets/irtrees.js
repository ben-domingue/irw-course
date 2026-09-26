// Helpers for the IRTree widgets (lessons/irtrees.qmd). Pure functions; the
// shared math (logistic, grid, rng) comes from irt.js.
import {logistic} from "./irt.js";

// The two trees for a 1-5 rating. Each node is a binary question; `code(x)` says how
// a response x answers it: 1, 0, or null when the response never reaches the node.
export const trees = {
  nested: [
    {node: "side", label: "Take a side? (not 3)", code: x => (x === 3 ? 0 : 1)},
    {node: "direction", label: "Agree side? (4 or 5)", code: x => (x === 3 ? null : x > 3 ? 1 : 0)},
    {node: "extreme", label: "Extreme? (1 or 5)", code: x => (x === 3 ? null : x === 1 || x === 5 ? 1 : 0)}
  ],
  linear: [2, 3, 4, 5].map(k => ({
    node: `step${k}`, label: `Given x ≥ ${k - 1}, is x ≥ ${k}?`,
    code: x => (x < k - 1 ? null : x >= k ? 1 : 0)
  }))
};

// Category probabilities for x = 1..5 under the nested (midpoint) tree, given the
// probability of a 1 at each node.
export function nestedProbs(ps, pd, pe) {
  return [ps * (1 - pd) * pe, ps * (1 - pd) * (1 - pe), 1 - ps, ps * pd * (1 - pe), ps * pd * pe];
}

// Node probabilities from node abilities and node difficulties (Rasch at each node).
export function nodeProbs(th, b) {
  return {side: logistic(th.side - b.side), direction: logistic(th.direction - b.direction),
          extreme: logistic(th.extreme - b.extreme)};
}

export function catProbsTree(th, b) {
  const p = nodeProbs(th, b);
  return nestedProbs(p.side, p.direction, p.extreme);
}

export const expected15 = probs => probs.reduce((s, p, k) => s + (k + 1) * p, 0);

// Layout of a tree diagram: internal nodes, leaves and edges, with the path a response
// takes. Coordinates are in [0, 1] x [0, 1], y downward.
export function treeLayout(kind, x) {
  if (kind === "nested") {
    const nodes = [
      {id: "s", x: 0.5, y: 0.08, text: "Take a side?"},
      {id: "d", x: 0.62, y: 0.38, text: "Agree side?"},
      {id: "e0", x: 0.4, y: 0.68, text: "Extreme?"},
      {id: "e1", x: 0.82, y: 0.68, text: "Extreme?"}
    ];
    const leaves = [
      {id: "3", x: 0.2, y: 0.38}, {id: "1", x: 0.28, y: 0.95}, {id: "2", x: 0.52, y: 0.95},
      {id: "4", x: 0.72, y: 0.95}, {id: "5", x: 0.94, y: 0.95}
    ];
    const edges = [
      ["s", "3", "no"], ["s", "d", "yes"], ["d", "e0", "no"], ["d", "e1", "yes"],
      ["e0", "1", "yes"], ["e0", "2", "no"], ["e1", "4", "no"], ["e1", "5", "yes"]
    ];
    const path = x === 3 ? ["s", "3"] : x < 3 ? ["s", "d", "e0", String(x)] : ["s", "d", "e1", String(x)];
    return finish(nodes, leaves, edges, path);
  }
  const nodes = [2, 3, 4, 5].map((k, i) => ({id: `n${k}`, x: 0.14 + 0.2 * i, y: 0.1 + 0.2 * i, text: `x ≥ ${k}?`}));
  const leaves = [1, 2, 3, 4].map((k, i) => ({id: String(k), x: 0.04 + 0.2 * i, y: 0.32 + 0.2 * i}))
    .concat([{id: "5", x: 0.94, y: 0.9}]);
  const edges = [2, 3, 4, 5].flatMap(k => [[`n${k}`, String(k - 1), "no"], [`n${k}`, k < 5 ? `n${k + 1}` : "5", "yes"]]);
  const path = [2, 3, 4, 5].filter(k => k <= x + 1 && k <= 5).map(k => `n${k}`).concat([String(x)]);
  return finish(nodes, leaves, edges, path);
}

function finish(nodes, leaves, edges, path) {
  const at = Object.fromEntries([...nodes, ...leaves].map(n => [n.id, n]));
  const onPath = new Set(path.slice(1).map((id, i) => `${path[i]}>${id}`));
  return {
    nodes: nodes.map(n => ({...n, on: path.includes(n.id)})),
    leaves: leaves.map(l => ({...l, text: l.id, on: path.includes(l.id)})),
    edges: edges.map(([a, b, lab]) => ({x1: at[a].x, y1: at[a].y, x2: at[b].x, y2: at[b].y,
      lab, on: onPath.has(`${a}>${b}`)}))
  };
}
