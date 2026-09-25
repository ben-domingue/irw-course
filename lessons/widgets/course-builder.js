// "Build your own course" on the course map (index.qmd, #14). Everything comes
// from lessons.yml, passed in by index.qmd with ojs_define():
//   import {courseBuilder} from "./lessons/widgets/course-builder.js"
//   courseBuilder(JSON.parse(cb_course))
// The dependency logic (closure, add, remove, order, presets, URL hash) is plain
// functions of a course object, so it can be tested in node without a page
// (see the PR for #14); only courseBuilder() touches the DOM.
import { palette } from "./irt.js";

const arr = (x) => (x == null ? [] : [].concat(x));

// Index the course: lessons by id, prerequisites, dependants, threads, and a
// rank for breaking ties in the order (first-course path, then lessons.yml).
export function makeCourse(data) {
  const lessons = arr(data.lessons).map((l) => ({ ...l, prereqs: arr(l.prereqs) }));
  const byId = new Map(lessons.map((l) => [l.id, l]));
  const paths = arr(data.paths).map((p) => ({ ...p, lessons: arr(p.lessons) }));
  const threads = arr(data.threads).map((t) => ({ ...t, returns: arr(t.returns) }));
  const dependants = new Map(lessons.map((l) => [l.id, []]));
  for (const l of lessons) for (const p of l.prereqs) if (dependants.has(p)) dependants.get(p).push(l.id);
  const first = (paths.find((p) => p.id === "first-course") || { lessons: [] }).lessons;
  const rank = new Map(lessons.map((l, i) => [l.id, first.includes(l.id) ? first.indexOf(l.id) : first.length + i]));
  return { lessons, byId, paths, threads, modules: arr(data.modules), dependants, rank };
}

// Missing prerequisites of `ids` (transitively), each with the lesson that
// first needed it: [{id, neededBy}], in the order they were found.
export function missingPrereqs(ids, course) {
  const have = new Set(ids), added = [];
  const visit = (id) => {
    for (const p of course.byId.get(id).prereqs) {
      if (have.has(p)) continue;
      have.add(p); added.push({ id: p, neededBy: id });
      visit(p);
    }
  };
  for (const id of ids) visit(id);
  return added;
}

// A selection closed under prerequisites, plus what had to be added. Unknown
// ids are dropped and reported.
export function closeSelection(ids, course) {
  const known = [...new Set(ids)].filter((id) => course.byId.has(id));
  const unknown = ids.filter((id) => !course.byId.has(id));
  const added = missingPrereqs(known, course);
  return { selection: new Set([...known, ...added.map((a) => a.id)]), added, unknown };
}

// Add a lesson and any prerequisites it is missing.
export function addLesson(selection, id, course) {
  const added = missingPrereqs([id], course).filter((a) => !selection.has(a.id));
  return { selection: new Set([...selection, id, ...added.map((a) => a.id)]), added };
}

// Remove a lesson, unless a selected lesson lists it as a prerequisite: then
// the selection is unchanged and `blockedBy` names those lessons.
export function removeLesson(selection, id, course) {
  const blockedBy = course.dependants.get(id).filter((d) => selection.has(d));
  if (blockedBy.length) return { selection, blockedBy };
  const s = new Set(selection); s.delete(id);
  return { selection: s, blockedBy: [] };
}

// Teaching order: every lesson after its prerequisites; among lessons that are
// ready, the one earliest in the first-course path, then in lessons.yml.
export function orderSelection(selection, course) {
  const left = new Set(selection), out = [];
  while (left.size) {
    const ready = [...left].filter((id) => course.byId.get(id).prereqs.every((p) => !left.has(p)));
    if (!ready.length) throw new Error("prerequisite cycle among " + [...left].join(", "));
    ready.sort((a, b) => course.rank.get(a) - course.rank.get(b));
    out.push(ready[0]); left.delete(ready[0]);
  }
  return out;
}

// The presets: the first-course path (the default), EDUC 252, and everything.
export function presets(course) {
  const path = (id) => (course.paths.find((p) => p.id === id) || { lessons: [] }).lessons;
  return [
    { id: "first-course", label: "A first course", ids: path("first-course") },
    { id: "educ252", label: "EDUC 252", ids: path("educ252") },
    { id: "everything", label: "Everything", ids: course.lessons.map((l) => l.id) }
  ];
}

export const encodeHash = (order) => "#course=" + order.join(",");

// The lesson ids in a hash like "#course=measurement,irw-data", or null if the
// hash carries no course.
export function decodeHash(hash) {
  const m = /^#?course=(.*)$/.exec(hash || "");
  if (!m) return null;
  return decodeURIComponent(m[1]).split(",").map((s) => s.trim()).filter(Boolean);
}

export const asText = (order, course) =>
  order.map((id, i) => `${i + 1}. ${course.byId.get(id).title}`).join("\n");

// What a lesson needs, what it unlocks, and the threads it starts and picks up.
export function neighbourhood(id, course) {
  return {
    needs: course.byId.get(id).prereqs,
    unlocks: course.dependants.get(id),
    starts: course.threads.filter((t) => t.introduced === id),
    picks: course.threads.filter((t) => t.returns.some((r) => r.lesson === id))
  };
}

// ---- The widget ------------------------------------------------------------

function el(tag, attrs = {}, ...kids) {
  const e = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "style") e.style.cssText = v;
    else if (k.startsWith("on")) e.addEventListener(k.slice(2), v);
    else e.setAttribute(k, v);
  }
  for (const k of kids) if (k != null) e.append(k);
  return e;
}

const TAG = "font-size:0.7rem;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-left:0.4rem;white-space:nowrap";
const BUTTON = `border:1px solid ${palette.main};border-radius:4px;background:${palette.white};color:${palette.main};` +
  "padding:0.25rem 0.75rem;cursor:pointer;font-size:0.9rem";
const BUTTON_ON = `border:1px solid ${palette.main};border-radius:4px;background:${palette.main};color:${palette.white};` +
  "padding:0.25rem 0.75rem;cursor:pointer;font-size:0.9rem";

export function courseBuilder(data, { base = "lessons/" } = {}) {
  const course = makeCourse(data);
  const title = (id) => course.byId.get(id).title;
  const href = (id) => `${base}${id}.html`;
  const link = (id) => {
    const l = course.byId.get(id);
    return el("a", { href: href(id), style: l.status === "stub" ? `color:${palette.guide}` : "" }, l.title);
  };
  const links = (ids) => {
    if (!ids.length) return document.createTextNode("none");
    const span = el("span");
    ids.forEach((id, i) => { if (i) span.append(" · "); span.append(link(id)); });
    return span;
  };
  const code = (id) => el("code", {}, id);
  const listOf = (ids) => {
    const span = el("span");
    ids.forEach((id, i) => { if (i) span.append(i === ids.length - 1 ? " and " : ", "); span.append(code(id)); });
    return span;
  };

  let selection = new Set();
  let current = null; // the preset the selection still matches, if any

  // Messages (what was added and why; why a removal was blocked). Read out by
  // screen readers as they change.
  const note = el("div", { role: "status", "aria-live": "polite", style: "min-height:1.4em;margin:0.6rem 0;font-size:0.92rem" });
  const say = (kind, ...kids) => {
    note.replaceChildren();
    if (!kids.length) return;
    const colour = kind === "blocked" ? palette.contrast : palette.main;
    note.append(el("div", { style: `border-left:4px solid ${colour};padding:0.35rem 0.8rem` }, ...kids));
  };
  const addedNote = (added) => {
    const span = el("span", {}, el("strong", {}, "Added "));
    added.forEach((a, i) => {
      if (i) span.append("; ");
      span.append(code(a.id), ", needed by ", code(a.neededBy));
    });
    span.append(".");
    return span;
  };

  // Presets.
  const presetButtons = new Map();
  const presetRow = el("div", { role: "group", "aria-label": "Start from a preset", style: "display:flex;flex-wrap:wrap;gap:0.4rem;align-items:center" },
    el("span", { style: "font-weight:600;margin-right:0.2rem" }, "Start from:"));
  for (const p of presets(course)) {
    const b = el("button", { type: "button", style: BUTTON, "aria-pressed": "false", onclick: () => loadPreset(p) }, p.label);
    presetButtons.set(p.id, b); presetRow.append(b);
  }
  const clear = el("button", { type: "button", style: BUTTON, onclick: () => { selection = new Set(); current = null; say(); update(); } }, "Clear");
  presetRow.append(clear);

  // The chooser: one fieldset per module, a checkbox per lesson, and a details
  // element with its neighbourhood.
  const boxes = new Map();
  const chooser = el("div", { style: "flex:1 1 22rem;min-width:0" }, el("h3", { style: "font-size:1.05rem" }, "Choose lessons"));
  for (const m of course.modules) {
    const fs = el("fieldset", { style: `border:1px solid ${palette.rule};border-radius:6px;padding:0.4rem 0.9rem 0.6rem;margin:0 0 0.8rem` },
      el("legend", { style: "font-size:0.95rem;font-weight:600;float:none;width:auto;padding:0 0.3rem;margin:0" }, m.title));
    for (const l of course.lessons.filter((x) => x.module === m.id)) {
      const cb = el("input", { type: "checkbox", id: `cb-${l.id}`, style: "margin-right:0.45rem;flex:none;margin-top:0.3rem" });
      cb.addEventListener("change", () => toggle(l.id, cb.checked));
      boxes.set(l.id, cb);
      const tags = [];
      if (l.tranche !== "core") tags.push(el("span", { style: `${TAG};color:${palette.contrast}` }, l.tranche));
      if (l.status === "stub") tags.push(el("span", { style: `${TAG};color:${palette.guide}` }, "not yet written"));
      const nb = neighbourhood(l.id, course);
      const thread = (t, from) => el("li", {}, t.idea, " (", from ? "from " : "→ ",
        from ? link(t.introduced) : links(t.returns.map((r) => r.lesson)), ")");
      const details = el("details", { style: "margin:0.1rem 0 0.2rem 1.6rem;font-size:0.85rem" },
        el("summary", { style: `color:${palette.guide};cursor:pointer` }, "Dependencies and threads",
          el("span", { class: "visually-hidden" }, ` for ${l.title}`)),
        el("div", { style: `border-left:2px solid ${palette.rule};padding:0.2rem 0 0.2rem 0.7rem;margin:0.2rem 0` },
          el("div", {}, el("strong", {}, "Needs: "), links(nb.needs)),
          el("div", {}, el("strong", {}, "Unlocks: "), links(nb.unlocks)),
          nb.starts.length ? el("div", {}, el("strong", {}, "Starts threads:"), el("ul", { style: "margin:0;padding-left:1.2rem" }, ...nb.starts.map((t) => thread(t, false)))) : null,
          nb.picks.length ? el("div", {}, el("strong", {}, "Picks up threads:"), el("ul", { style: "margin:0;padding-left:1.2rem" }, ...nb.picks.map((t) => thread(t, true)))) : null,
          el("div", {}, el("a", { href: href(l.id) }, "Open the lesson"))));
      fs.append(el("div", { style: "margin:0.15rem 0" },
        el("div", { style: "display:flex;align-items:flex-start" }, cb,
          el("label", { for: `cb-${l.id}`, style: `cursor:pointer;${l.status === "stub" ? `color:${palette.guide}` : ""}` }, l.title, ...tags)),
        details));
    }
    chooser.append(fs);
  }

  // The course itself.
  const heading = el("h3", { style: "font-size:1.05rem" });
  const list = el("ol", { style: "padding-left:1.6rem;margin-bottom:0.6rem" });
  const copied = el("span", { role: "status", "aria-live": "polite", style: `margin-left:0.6rem;font-size:0.85rem;color:${palette.guide}` });
  const copy = el("button", { type: "button", style: BUTTON, onclick: copyList }, "Copy as list");
  const share = el("p", { style: `font-size:0.85rem;color:${palette.guide};margin:0.4rem 0 0` },
    "The page address keeps your choice: bookmark it or send it to share this course.");
  const output = el("div", { style: `flex:1 1 20rem;min-width:0;border:1px solid ${palette.rule};border-top:4px solid ${palette.main};border-radius:6px;padding:0 1rem 1rem;align-self:flex-start` },
    heading, list, el("div", {}, copy, copied), share);

  function toggle(id, on) {
    if (on) {
      const r = addLesson(selection, id, course);
      selection = r.selection;
      say("added", ...(r.added.length ? [addedNote(r.added)] : []));
    } else {
      const r = removeLesson(selection, id, course);
      if (r.blockedBy.length) {
        say("blocked", el("strong", {}, "Can't remove "), code(id), el("strong", {}, ": "),
          listOf(r.blockedBy), r.blockedBy.length > 1 ? " need it. Remove them first." : " needs it. Remove that first.");
        update(); // puts the box back; the selection (and its preset) is unchanged
        return;
      }
      selection = r.selection; say();
    }
    current = null;
    update();
  }

  function loadPreset(p) {
    const r = closeSelection(p.ids, course);
    selection = r.selection; current = p.id;
    say("added", ...(r.added.length ? [el("strong", {}, p.label), " lists a lesson without its prerequisite. ", addedNote(r.added)] : []));
    update();
  }

  function copyList() {
    const text = asText(orderSelection(selection, course), course);
    const done = (msg) => { copied.textContent = msg; setTimeout(() => { copied.textContent = ""; }, 2500); };
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(() => done("Copied."), () => fallback(text));
    } else fallback(text);
    function fallback(t) {
      const ta = el("textarea", { rows: "6", style: "width:100%;margin-top:0.5rem;font-size:0.85rem", "aria-label": "Your course as a list" });
      ta.value = t; copied.replaceChildren(); output.querySelector("textarea")?.remove();
      copy.after(ta); ta.select(); done("Select all and copy.");
    }
  }

  function update() {
    for (const [id, cb] of boxes) cb.checked = selection.has(id);
    for (const [id, b] of presetButtons) {
      b.style.cssText = id === current ? BUTTON_ON : BUTTON;
      b.setAttribute("aria-pressed", String(id === current));
    }
    const order = orderSelection(selection, course);
    const stubs = order.filter((id) => course.byId.get(id).status === "stub").length;
    heading.replaceChildren(`Your course: ${order.length} session${order.length === 1 ? "" : "s"}`,
      el("span", { style: `font-weight:normal;font-size:0.85rem;color:${palette.guide}` },
        stubs ? ` (${stubs} not yet written)` : ""));
    list.replaceChildren(...order.map((id) => {
      const l = course.byId.get(id);
      return el("li", {}, link(id), l.status === "stub" ? el("span", { style: `${TAG};color:${palette.guide}` }, "not yet written") : null);
    }));
    if (!order.length) list.append(el("li", { style: `list-style:none;color:${palette.guide};margin-left:-1.6rem` }, "No lessons chosen yet."));
    copy.disabled = !order.length;
    try { history.replaceState(null, "", location.pathname + location.search + encodeHash(order)); } catch (e) { /* e.g. a sandboxed preview */ }
  }

  // Restore a course from the address, else start from the default preset.
  const fromHash = decodeHash(location.hash);
  if (fromHash) {
    const r = closeSelection(fromHash, course);
    selection = r.selection;
    const msgs = [];
    if (r.unknown.length) msgs.push(el("span", {}, el("strong", {}, "Skipped "), listOf(r.unknown), ": not in the course. "));
    if (r.added.length) msgs.push(addedNote(r.added));
    say("added", ...msgs);
    update();
  } else loadPreset(presets(course)[0]);

  return el("div", { class: "course-builder" }, presetRow, note,
    el("div", { style: "display:flex;flex-wrap:wrap;gap:1.2rem;align-items:flex-start" }, output, chooser));
}
