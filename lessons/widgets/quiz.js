// Self-check components for lessons. They return DOM nodes, so an OJS cell can
// display them directly:
//   import {quiz, predict} from "./widgets/quiz.js"
//   quiz({q: "...", options: [{text: "...", correct: true, why: "..."}, ...]})
// Answers live in the page source: these are for checking understanding, not grading.

function el(tag, attrs = {}, ...kids) {
  const e = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "style") e.style.cssText = v; else e.setAttribute(k, v);
  }
  for (const k of kids) e.append(k);
  return e;
}

const BOX = "border:1px solid #dee2e6;border-left:4px solid #6f42c1;border-radius:6px;" +
  "padding:0.9rem 1.2rem;margin:1rem 0;background:#fcfbff";
const LABEL = "font-size:0.72rem;font-weight:600;text-transform:uppercase;letter-spacing:0.06em;color:#6f42c1";

// Typeset any $...$ math inside a node once it is on the page (Quarto loads MathJax).
function typeset(node) {
  setTimeout(() => { if (window.MathJax && window.MathJax.typesetPromise) window.MathJax.typesetPromise([node]); }, 0);
  return node;
}

// Allows *emphasis*, `code` and $math$ in text without shipping a markdown parser.
function inline(s) {
  const span = document.createElement("span");
  span.innerHTML = String(s)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;")
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*([^*]+)\*/g, "<em>$1</em>")
    .replace(/\$([^$]+)\$/g, "\\($1\\)");
  return span;
}

// Multiple choice. Clicking an option shows whether it is right and why.
export function quiz({ q, options }) {
  const feedback = el("div", { style: "margin-top:0.6rem;min-height:1.2em" });
  const list = el("div", { style: "display:flex;flex-direction:column;gap:0.35rem;margin-top:0.5rem" });
  options.forEach((o) => {
    const b = el("button", {
      type: "button",
      style: "text-align:left;border:1px solid #ced4da;border-radius:4px;background:#fff;padding:0.35rem 0.7rem;cursor:pointer;color:#212529"
    }, inline(o.text));
    b.onclick = () => {
      list.querySelectorAll("button").forEach((x) => { x.style.background = "#fff"; x.style.borderColor = "#ced4da"; });
      b.style.background = o.correct ? "#e8f5e9" : "#fdecea";
      b.style.borderColor = o.correct ? "#2e7d32" : "#c62828";
      feedback.replaceChildren(
        el("strong", { style: `color:${o.correct ? "#2e7d32" : "#c62828"}` }, o.correct ? "Yes. " : "Not quite. "),
        inline(o.why || ""));
      typeset(feedback);
    };
    list.append(b);
  });
  return typeset(el("div", { style: BOX }, el("div", { style: LABEL }, "Quick check"),
    el("div", { style: "margin-top:0.3rem" }, inline(q)), list, feedback));
}

// Commit to a prediction before seeing the answer. `choices` is an array of
// strings; `answer` is the correct string; `reveal` explains it.
export function predict({ q, choices, answer, reveal }) {
  const out = el("div", { style: "margin-top:0.6rem" });
  const row = el("div", { style: "display:flex;flex-wrap:wrap;gap:0.4rem;margin-top:0.5rem" });
  let locked = false;
  choices.forEach((c) => {
    const b = el("button", {
      type: "button",
      style: "border:1px solid #ced4da;border-radius:4px;background:#fff;padding:0.3rem 0.8rem;cursor:pointer;color:#212529"
    }, inline(c));
    b.onclick = () => {
      if (locked) return;
      locked = true;
      const right = c === answer;
      b.style.background = right ? "#e8f5e9" : "#fdecea";
      out.replaceChildren(
        el("div", {}, el("strong", {}, right ? "You predicted correctly. " : `You said ${c}; the answer is ${answer}. `)),
        el("div", { style: "margin-top:0.3rem" }, inline(reveal)));
      typeset(out);
    };
    row.append(b);
  });
  return typeset(el("div", { style: BOX }, el("div", { style: LABEL }, "Predict, then check"),
    el("div", { style: "margin-top:0.3rem" }, inline(q)), row, out));
}
