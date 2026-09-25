// "Build your own course" on the course map (index.qmd, #14). A bank of every
// lesson (from lessons.yml, passed in by index.qmd with ojs_define) and a canvas
// holding the teacher's course: lessons and unit headings, in any order. Nothing
// is blocked or added automatically; a notes panel points out lessons that come
// before a prerequisite, and prerequisites missing from the course, each with a
// one-click fix the teacher can ignore.
//   import {courseBuilder} from "./lessons/widgets/course-builder.js"
//   Sortable = require("sortablejs@1")
//   courseBuilder(JSON.parse(cb_course), {Sortable})
// The logic (notes, fixes, presets, URL hash, text export) is plain functions of
// a course object and a list of items, so it can be tested in node; only
// courseBuilder() touches the DOM.
import { palette } from "./irt.js";

const arr = (x) => (x == null ? [] : [].concat(x));

// Index the course: lessons by id, dependants, threads, and a rank for ordering
// "Everything" (first-course path, then lessons.yml).
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

// ---- Items ------------------------------------------------------------------
// The canvas is a list of items: {type: "lesson", id} or {type: "heading", title}.

export const lesson = (id) => ({ type: "lesson", id });
export const heading = (title) => ({ type: "heading", title });
export const lessonIds = (items) => items.filter((it) => it.type === "lesson").map((it) => it.id);
const indexOfLesson = (items, id) => items.findIndex((it) => it.type === "lesson" && it.id === id);

// Move the item at `from` so it ends up at index `to`.
export function moveItem(items, from, to) {
  const out = items.slice();
  const [it] = out.splice(from, 1);
  out.splice(Math.max(0, Math.min(to, out.length)), 0, it);
  return out;
}

// Put lesson `id` at index `at`. A lesson appears once: if it is already on the
// canvas, it moves (the index is where it lands in the final list).
export function placeLesson(items, id, at) {
  const out = items.filter((it) => !(it.type === "lesson" && it.id === id));
  out.splice(Math.max(0, Math.min(at, out.length)), 0, lesson(id));
  return out;
}

export const removeItem = (items, i) => items.filter((_, j) => j !== i);

// The bank: every lesson not on the canvas, in lessons.yml order. A lesson is in
// the course or in the bank, never both (Ben, 09-25).
export function bankIds(items, course) {
  const on = new Set(lessonIds(items));
  return course.lessons.map((l) => l.id).filter((id) => !on.has(id));
}

// Teaching order for a set of lessons: every lesson after its prerequisites (in
// the set); among lessons that are ready, the one earliest in the first-course
// path, then in lessons.yml. Used to lay out "Everything".
export function orderSelection(ids, course) {
  const left = new Set(ids), out = [];
  while (left.size) {
    const ready = [...left].filter((id) => course.byId.get(id).prereqs.every((p) => !left.has(p)));
    if (!ready.length) throw new Error("prerequisite cycle among " + [...left].join(", "));
    ready.sort((a, b) => course.rank.get(a) - course.rank.get(b));
    out.push(ready[0]); left.delete(ready[0]);
  }
  return out;
}

// ---- Notes and fixes --------------------------------------------------------

// Advisory notes, in canvas order: {kind: "order", id, prereq} when lesson `id`
// comes before its prerequisite `prereq`; {kind: "missing", id, prereq} when the
// prerequisite isn't on the canvas at all.
export function courseNotes(items, course) {
  const ids = lessonIds(items), notes = [];
  ids.forEach((id, i) => {
    for (const p of course.byId.get(id).prereqs) {
      const j = ids.indexOf(p);
      if (j < 0) notes.push({ kind: "missing", id, prereq: p });
      else if (j > i) notes.push({ kind: "order", id, prereq: p });
    }
  });
  return notes;
}

// The fix a note offers: move the prerequisite (or add it) just before the lesson.
export function applyFix(items, note) {
  const at = indexOfLesson(items, note.id);
  if (at < 0) return items;
  if (note.kind === "order") {
    const from = indexOfLesson(items, note.prereq);
    return from > at ? moveItem(items, from, at) : items;
  }
  return placeLesson(items, note.prereq, at);
}

// ---- Presets, sharing and export --------------------------------------------

export function presets(course) {
  const path = (id) => (course.paths.find((p) => p.id === id) || { lessons: [] }).lessons;
  return [
    { id: "first-course", label: "A first course", ids: path("first-course") },
    { id: "educ252", label: "EDUC 252", ids: path("educ252") },
    { id: "everything", label: "Everything", ids: orderSelection(course.lessons.map((l) => l.id), course) },
    { id: "empty", label: "Empty", ids: [] }
  ];
}
export const presetItems = (p) => p.ids.map(lesson);

// The hash: "#c=" then comma-separated entries, each a lesson id or "~" and a
// URI-encoded heading. Lesson ids are readable and survive reordering lessons.yml.
export const encodeHash = (items) =>
  "#c=" + items.map((it) => (it.type === "lesson" ? it.id : "~" + encodeURIComponent(it.title))).join(",");

// Items from a hash, or null if the hash carries no course. Unknown lesson ids
// and repeats are dropped and listed in `unknown`. Also reads the first
// version's "#course=id,id,...".
export function decodeHash(hash, course) {
  const m = /^#?(?:c|course)=(.*)$/.exec(hash || "");
  if (!m) return null;
  const items = [], unknown = [], seen = new Set();
  for (const raw of m[1].split(",")) {
    if (!raw) continue;
    if (raw[0] === "~") {
      let t; try { t = decodeURIComponent(raw.slice(1)); } catch (e) { t = raw.slice(1); }
      items.push(heading(t));
    } else {
      let id; try { id = decodeURIComponent(raw).trim(); } catch (e) { id = raw; }
      if (course.byId.has(id) && !seen.has(id)) { items.push(lesson(id)); seen.add(id); } else unknown.push(id);
    }
  }
  return { items, unknown };
}

// Plain text: headings on their own line, lessons numbered as sessions.
export function asText(items, course) {
  let n = 0;
  return items.map((it) => (it.type === "heading" ? it.title : `${++n}. ${course.byId.get(it.id).title}`)).join("\n");
}

// Markdown: headings as ##, lessons as numbered links (numbering runs across units).
export function asMarkdown(items, course, url = (id) => `lessons/${id}.html`) {
  let n = 0;
  const out = [];
  for (const it of items) {
    if (it.type === "heading") {
      if (out.length) out.push("");
      out.push(`## ${it.title}`, "");
    } else out.push(`${++n}. [${course.byId.get(it.id).title}](${url(it.id)})`);
  }
  return out.join("\n");
}

// What a lesson needs, what it unlocks, and the threads it starts and picks up.
export function neighbourhood(id, course) {
  return {
    needs: course.byId.get(id).prereqs,
    unlocks: course.dependants.get(id),
    starts: course.threads.filter((t) => t.introduced === id),
    picks: course.threads.filter((t) => t.returns.some((r) => r.lesson === id))
  };
}

// ---- The widget ---------------------------------------------------------------

function el(tag, attrs = {}, ...kids) {
  const e = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "style") e.style.cssText = v;
    else if (k.startsWith("on")) e.addEventListener(k.slice(2), v);
    else if (v !== false && v != null) e.setAttribute(k, v === true ? "" : v);
  }
  for (const k of kids) if (k != null && k !== false) e.append(k);
  return e;
}

const TAG = "font-size:0.68rem;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-left:0.4rem;white-space:nowrap";
const BTN = `border:1px solid ${palette.main};border-radius:4px;background:${palette.white};color:${palette.main};` +
  "padding:0.2rem 0.65rem;cursor:pointer;font-size:0.88rem";
const BTN_ON = `border:1px solid ${palette.main};border-radius:4px;background:${palette.main};color:${palette.white};` +
  "padding:0.2rem 0.65rem;cursor:pointer;font-size:0.88rem";
const ICON = `border:1px solid ${palette.rule};border-radius:4px;background:${palette.white};color:${palette.ink};` +
  "padding:0 0.45rem;cursor:pointer;font-size:0.85rem;line-height:1.6;min-width:1.9rem";
const GRIP = `cursor:grab;color:${palette.guide};padding:0 0.35rem;user-select:none;touch-action:none;font-size:1.1rem;line-height:1.4`;
const CSS = `
.course-builder .cb-ghost { opacity: 0.45; outline: 2px dashed ${palette.main}; }
.course-builder .cb-drag { background: ${palette.white}; }
.course-builder button:disabled { opacity: 0.45; cursor: default; }
.course-builder .cb-bank { max-height: 75vh; overflow-y: auto; }
.course-builder button:focus-visible, .course-builder input:focus-visible, .course-builder summary:focus-visible { outline: 2px solid ${palette.contrast}; outline-offset: 1px; }
`;

let uid = 0;
const keyed = (it) => ({ ...it, key: ++uid });

export function courseBuilder(data, { Sortable = null, base = "lessons/" } = {}) {
  const course = makeCourse(data);
  const href = (id) => `${base}${id}.html`;
  const absolute = (id) => new URL(href(id), location.href).href;
  const title = (id) => course.byId.get(id).title;
  const code = (id) => el("code", {}, id);
  const link = (id) => el("a", { href: href(id), style: course.byId.get(id).status === "stub" ? `color:${palette.guide}` : "" }, title(id));
  const links = (ids) => {
    if (!ids.length) return document.createTextNode("none");
    const span = el("span");
    ids.forEach((id, i) => { if (i) span.append(" · "); span.append(link(id)); });
    return span;
  };
  const tags = (l) => [
    l.tranche !== "core" ? el("span", { style: `${TAG};color:${palette.contrast}` }, l.tranche) : null,
    l.status === "stub" ? el("span", { style: `${TAG};color:${palette.guide}` }, "not yet written") : null
  ];

  let items = [];       // the canvas; each item has a `key` for focus after a redraw
  let current = null;   // the preset the canvas still matches, if any
  let unitCount = 0;

  // ---- Bank ----
  const filter = el("input", { type: "search", placeholder: "Filter lessons", "aria-label": "Filter lessons by title",
    style: `width:100%;padding:0.3rem 0.5rem;border:1px solid ${palette.rule};border-radius:4px;margin-bottom:0.6rem` });
  const bankRows = new Map(); // id -> {row, text}
  const bankLists = [];
  const bankBody = el("div", { class: "cb-bank" });
  for (const m of course.modules) {
    const ul = el("ul", { style: "list-style:none;margin:0;padding:0" });
    for (const l of course.lessons.filter((x) => x.module === m.id)) {
      const nb = neighbourhood(l.id, course);
      const thread = (t, from) => el("li", {}, t.idea, " (", from ? "from " : "→ ",
        from ? link(t.introduced) : links(t.returns.map((r) => r.lesson)), ")");
      const add = el("button", { type: "button", style: ICON, "aria-label": `Add ${l.title} to the end of your course`,
        onclick: () => setItems(placeLesson(items, l.id, items.length)) }, "Add");
      const row = el("li", { "data-id": l.id, style: "margin:0.1rem 0" },
        el("div", { style: "display:flex;align-items:flex-start;gap:0.2rem" },
          el("span", { class: "cb-grip", "aria-hidden": "true", title: "Drag to your course", style: GRIP }, "⠿"),
          el("span", { style: `flex:1;${l.status === "stub" ? `color:${palette.guide}` : ""}` }, l.title, ...tags(l)),
          add),
        el("details", { style: "margin:0 0 0.2rem 1.6rem;font-size:0.84rem" },
          el("summary", { style: `color:${palette.guide};cursor:pointer` }, "Dependencies and threads",
            el("span", { class: "visually-hidden" }, ` for ${l.title}`)),
          el("div", { style: `border-left:2px solid ${palette.rule};padding:0.2rem 0 0.2rem 0.7rem;margin:0.2rem 0` },
            el("div", {}, el("strong", {}, "Needs: "), links(nb.needs)),
            el("div", {}, el("strong", {}, "Unlocks: "), links(nb.unlocks)),
            nb.starts.length ? el("div", {}, el("strong", {}, "Starts threads:"), el("ul", { style: "margin:0;padding-left:1.2rem" }, ...nb.starts.map((t) => thread(t, false)))) : null,
            nb.picks.length ? el("div", {}, el("strong", {}, "Picks up threads:"), el("ul", { style: "margin:0;padding-left:1.2rem" }, ...nb.picks.map((t) => thread(t, true)))) : null,
            el("div", {}, el("a", { href: href(l.id) }, "Open the lesson")))));
      bankRows.set(l.id, { row, text: (l.title + " " + l.id).toLowerCase() });
      ul.append(row);
    }
    const fs = el("fieldset", { style: `border:1px solid ${palette.rule};border-radius:6px;padding:0.3rem 0.7rem 0.5rem;margin:0 0 0.7rem` },
      el("legend", { style: "font-size:0.92rem;font-weight:600;float:none;width:auto;padding:0 0.3rem;margin:0" }, m.title), ul);
    const allIn = el("p", { hidden: true, style: `margin:0.1rem 0 0;font-size:0.84rem;color:${palette.guide}` }, "All in your course.");
    fs.append(allIn);
    bankLists.push({ fs, ul, allIn, ids: course.lessons.filter((x) => x.module === m.id).map((x) => x.id) });
    bankBody.append(fs);
  }
  const bankEmpty = el("p", { hidden: true, style: `font-size:0.88rem;color:${palette.guide}` });
  bankBody.append(bankEmpty);
  // Show the lessons that are in the bank (not on the canvas) and match the
  // filter. A module whose lessons are all in the course keeps its legend and says
  // so; one emptied only by the filter is hidden.
  function showBank() {
    const q = filter.value.trim().toLowerCase();
    const inBank = new Set(bankIds(items, course));
    for (const [id, { row, text }] of bankRows) row.hidden = !inBank.has(id) || (!!q && !text.includes(q));
    let shown = 0;
    for (const { fs, ul, allIn, ids } of bankLists) {
      const left = ids.filter((id) => inBank.has(id)).length;
      const visible = [...ul.children].filter((r) => r.dataset.id && !r.hidden).length;
      allIn.hidden = left > 0;
      fs.hidden = q ? visible === 0 : false;
      shown += visible;
    }
    bankEmpty.hidden = shown > 0;
    bankEmpty.textContent = inBank.size ? "No lessons in the bank match the filter." : "Every lesson is in your course.";
  }
  filter.addEventListener("input", showBank);
  const bank = el("section", { "aria-label": "Lesson bank", style: "flex:1 1 20rem;min-width:0" },
    el("h3", { style: "font-size:1.05rem" }, "Lesson bank"),
    el("p", { style: `font-size:0.85rem;color:${palette.guide};margin:0 0 0.4rem` },
      "Drag a lesson by its handle (⠿) into your course, or use Add. Drag a lesson back here, or use ✕, to return it."),
    filter, bankBody);

  // ---- Canvas ----
  const presetButtons = new Map();
  const presetRow = el("div", { role: "group", "aria-label": "Fill the course from a preset", style: "display:flex;flex-wrap:wrap;gap:0.35rem;align-items:center;margin-bottom:0.5rem" },
    el("span", { style: "font-weight:600;font-size:0.9rem;margin-right:0.2rem" }, "Start from:"));
  for (const p of presets(course)) {
    const b = el("button", { type: "button", style: BTN, "aria-pressed": "false", onclick: () => setItems(presetItems(p), p.id) }, p.label);
    presetButtons.set(p.id, b); presetRow.append(b);
  }
  const count = el("h3", { style: "font-size:1.05rem;margin-bottom:0.3rem" });
  const status = el("div", { role: "status", "aria-live": "polite", class: "visually-hidden" });
  const skipped = el("p", { hidden: true, style: `font-size:0.85rem;border-left:4px solid ${palette.contrast};padding:0.2rem 0.6rem` });
  const notesBox = el("div", { style: "margin:0.4rem 0 0.6rem" });
  const list = el("ol", { "aria-label": "Your course", style: `list-style:none;margin:0;padding:0.3rem;min-height:3.2rem;border:1px dashed ${palette.rule};border-radius:6px` });
  const empty = el("p", { style: `color:${palette.guide};font-size:0.88rem;margin:0.3rem 0 0` }, "Your course is empty. Drag lessons here, use Add, or start from a preset.");
  const addHeading = el("button", { type: "button", style: BTN, onclick: () => {
    const it = keyed(heading(`Unit ${++unitCount}`));
    setItems([...items, it], null, () => list.querySelector(`[data-key="${it.key}"] input`)?.select());
  } }, "Add heading");
  const copied = el("span", { role: "status", "aria-live": "polite", style: `font-size:0.85rem;color:${palette.guide}` });
  const copyText = el("button", { type: "button", style: BTN, onclick: () => copy(asText(items, course)) }, "Copy as list");
  const copyMd = el("button", { type: "button", style: BTN, onclick: () => copy(asMarkdown(items, course, absolute)) }, "Copy as Markdown");
  const tools = el("div", { style: "display:flex;flex-wrap:wrap;gap:0.35rem;align-items:center;margin-top:0.6rem" }, addHeading, copyText, copyMd, copied);
  const canvas = el("section", { "aria-label": "Your course", style: `flex:1.3 1 22rem;min-width:0;border:1px solid ${palette.rule};border-top:4px solid ${palette.main};border-radius:6px;padding:0 0.9rem 0.9rem` },
    count, presetRow, skipped, notesBox, list, empty, tools,
    el("p", { style: `font-size:0.82rem;color:${palette.guide};margin:0.5rem 0 0` },
      "The page address keeps your course, headings included: bookmark it or send it to share."), status);

  function copy(text) {
    const done = (msg) => { copied.textContent = msg; setTimeout(() => { copied.textContent = ""; }, 2500); };
    const fallback = () => {
      canvas.querySelector("textarea")?.remove();
      const ta = el("textarea", { rows: "6", style: "width:100%;margin-top:0.5rem;font-size:0.82rem", "aria-label": "Your course, to copy" });
      ta.value = text; tools.after(ta); ta.select(); done("Select all and copy.");
    };
    if (navigator.clipboard && window.isSecureContext) navigator.clipboard.writeText(text).then(() => done("Copied."), fallback);
    else fallback();
  }

  // Replace the canvas and redraw. `preset` names the preset it now matches.
  function setItems(next, preset = null, after = null) {
    items = next.map((it) => (it.key ? it : keyed(it)));
    current = preset;
    render();
    if (after) after();
  }
  const focusIn = (key, sel) => list.querySelector(`[data-key="${key}"] ${sel}`);

  const moveBtn = (i, dir, what) => el("button", {
    type: "button", class: dir < 0 ? "cb-up" : "cb-down", style: ICON, disabled: dir < 0 ? i === 0 : i === items.length - 1,
    "aria-label": `Move ${what} ${dir < 0 ? "up" : "down"}`,
    onclick: () => {
      const key = items[i].key, cls = dir < 0 ? ".cb-up" : ".cb-down", other = dir < 0 ? ".cb-down" : ".cb-up";
      setItems(moveItem(items, i, i + dir), null, () => {
        const b = focusIn(key, cls);
        (b && !b.disabled ? b : focusIn(key, other))?.focus();
      });
    } }, dir < 0 ? "↑" : "↓");
  const removeBtn = (i, what) => el("button", { type: "button", class: "cb-remove", style: ICON, "aria-label": `Remove ${what}`,
    onclick: () => setItems(removeItem(items, i), null,
      () => list.children[Math.min(i, items.length - 1)]?.querySelector(".cb-remove")?.focus()) }, "✕");

  function renderNotes(notes) {
    const order = notes.filter((n) => n.kind === "order"), missing = notes.filter((n) => n.kind === "missing");
    const fix = (n, label) => el("button", { type: "button", style: `${BTN};font-size:0.8rem;padding:0.05rem 0.5rem;margin-left:0.4rem`,
      onclick: () => setItems(applyFix(items, n)) }, label);
    const group = (head, rows) => rows.length ? el("div", {},
      el("div", { style: "font-weight:600;font-size:0.88rem;margin-top:0.2rem" }, head),
      el("ul", { style: "margin:0.1rem 0 0.2rem;padding-left:1.1rem;font-size:0.87rem" }, ...rows)) : null;
    const box = el("div", { style: `border-left:4px solid ${notes.length ? palette.contrast : palette.main};padding:0.3rem 0.8rem` },
      notes.length ? null : el("span", { style: "font-size:0.88rem" }, items.some((it) => it.type === "lesson")
        ? "No notes: every lesson comes after the lessons it assumes." : "Notes on the order will appear here."),
      group(`Out of order (${order.length})`, order.map((n) => el("li", { style: "margin:0.15rem 0" },
        code(n.id), " comes before its prerequisite ", code(n.prereq), ".",
        fix(n, `Move ${n.prereq} before ${n.id}`)))),
      group(`Missing prerequisites (${missing.length})`, missing.map((n) => el("li", { style: "margin:0.15rem 0" },
        code(n.id), " assumes ", code(n.prereq), ", which isn't in your course.",
        fix(n, `Add ${n.prereq} before ${n.id}`)))),
      notes.length ? el("div", { style: `font-size:0.8rem;color:${palette.guide};margin-top:0.2rem` },
        "Notes are advice: the course is yours to order.") : null);
    notesBox.replaceChildren(el("div", { style: "font-weight:600;font-size:0.95rem;margin-bottom:0.2rem" }, "Notes"), box);
  }

  function render() {
    let n = 0;
    list.replaceChildren(...items.map((it, i) => {
      if (it.type === "heading") {
        const input = el("input", { type: "text", value: it.title, "aria-label": "Heading title",
          style: `flex:1;min-width:0;font-weight:600;font-size:1rem;border:1px solid transparent;border-bottom:1px solid ${palette.rule};padding:0.1rem 0.3rem;background:transparent;color:inherit` });
        input.addEventListener("input", () => { it.title = input.value; current = null; saveHash(); });
        return el("li", { "data-key": it.key, style: "display:flex;align-items:center;gap:0.25rem;margin:0.5rem 0 0.2rem" },
          el("span", { class: "cb-grip", "aria-hidden": "true", title: "Drag to reorder", style: GRIP }, "⠿"),
          input, moveBtn(i, -1, `heading ${it.title}`), moveBtn(i, 1, `heading ${it.title}`), removeBtn(i, `heading ${it.title}`));
      }
      const l = course.byId.get(it.id);
      return el("li", { "data-key": it.key, style: `display:flex;align-items:center;gap:0.25rem;padding:0.12rem 0;border-bottom:1px solid ${palette.rule}` },
        el("span", { class: "cb-grip", "aria-hidden": "true", title: "Drag to reorder", style: GRIP }, "⠿"),
        el("span", { style: `min-width:1.8rem;text-align:right;color:${palette.guide};font-size:0.85rem` }, `${++n}.`),
        el("span", { style: "flex:1;min-width:0" }, link(it.id), ...tags(l)),
        moveBtn(i, -1, l.title), moveBtn(i, 1, l.title), removeBtn(i, l.title));
    }));
    empty.hidden = items.length > 0;
    const stubs = lessonIds(items).filter((id) => course.byId.get(id).status === "stub").length;
    count.replaceChildren(`Your course: ${n} session${n === 1 ? "" : "s"}`,
      el("span", { style: `font-weight:normal;font-size:0.85rem;color:${palette.guide}` }, stubs ? ` (${stubs} not yet written)` : ""));
    showBank();
    for (const [id, b] of presetButtons) { b.style.cssText = id === current ? BTN_ON : BTN; b.setAttribute("aria-pressed", String(id === current)); }
    const notes = courseNotes(items, course);
    renderNotes(notes);
    copyText.disabled = copyMd.disabled = !items.length;
    status.textContent = `${n} session${n === 1 ? "" : "s"}; ${notes.length} note${notes.length === 1 ? "" : "s"}.`;
    saveHash();
  }

  function saveHash() {
    try { history.replaceState(null, "", location.pathname + location.search + encodeHash(items)); } catch (e) { /* sandboxed preview */ }
  }

  // Drag and drop with SortableJS (mouse and touch), by the ⠿ handle. The canvas
  // is redrawn from `items` after every drop, which replaces Sortable's DOM moves.
  if (Sortable) {
    // forceFallback: the same pointer-driven dragging for mouse and touch.
    const common = { handle: ".cb-grip", animation: 120, ghostClass: "cb-ghost", chosenClass: "cb-drag", forceFallback: true, fallbackOnBody: true };
    for (const { ul } of bankLists) Sortable.create(ul, { ...common, sort: false,
      group: { name: "course", pull: "clone", put: (to, from) => from.el === list },
      // A lesson dragged back from the canvas: take it off the canvas; the redraw
      // shows it again in its own module, in lessons.yml order.
      onAdd: (e) => {
        const key = Number(e.item.dataset.key);
        e.item.remove();
        setItems(items.filter((it) => it.key !== key));
      } });
    Sortable.create(list, { ...common, group: { name: "course", pull: true, put: true },
      onAdd: (e) => {
        // The dragged bank row goes back to the bank (Sortable left a clone there).
        const id = e.item.dataset.id;
        e.clone.replaceWith(e.item);
        const before = items.slice(0, e.newIndex).some((it) => it.type === "lesson" && it.id === id) ? 1 : 0;
        setItems(placeLesson(items, id, e.newIndex - before));
      },
      onEnd: (e) => {
        if (e.from !== list || e.to !== list || e.oldIndex === e.newIndex) return;
        setItems(moveItem(items, e.oldIndex, e.newIndex));
      } });
  }

  // Restore from the address, else the default preset.
  const restored = decodeHash(location.hash, course);
  if (restored) {
    unitCount = restored.items.filter((it) => it.type === "heading").length;
    if (restored.unknown.length) {
      skipped.textContent = `Skipped from the address (not a lesson, or repeated): ${restored.unknown.join(", ")}.`;
      skipped.hidden = false;
    }
    setItems(restored.items);
  } else setItems(presetItems(presets(course)[0]), "first-course");

  return el("div", { class: "course-builder" }, el("style", {}, CSS),
    el("div", { style: "display:flex;flex-wrap:wrap;gap:1.2rem;align-items:flex-start" }, bank, canvas));
}
