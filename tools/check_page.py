#!/usr/bin/env python3
"""Browser check for one lesson page (review checklist, irw-course#5).

Opens the page in headless Chrome, waits for webR to be ready, clicks every Run
button, and waits until the page text matches EXPECT (a regex that only the
cell's *output* can match, e.g. "estimated b: 0\\.[0-9]"). Reports how long it
took, and saves a full-page screenshot for a visual check of widgets and quizzes.

  python3 tools/check_page.py URL EXPECT [TIMEOUT_S] [OUT.png]

URL can be a local preview (quarto preview, or `python3 -m http.server` in _site/)
or the live site. Needs google-chrome and the websocket-client package.
Exit status 0 if EXPECT appeared, 1 otherwise.
"""
import base64, json, re, subprocess, sys, tempfile, time, urllib.request
import websocket

url, expect = sys.argv[1], sys.argv[2]
timeout = float(sys.argv[3]) if len(sys.argv) > 3 else 180
out = sys.argv[4] if len(sys.argv) > 4 else "check_page.png"
port = 9341
chrome = subprocess.Popen(
    ["google-chrome", "--headless=new", "--disable-gpu", "--no-sandbox",
     f"--remote-debugging-port={port}", "--remote-allow-origins=*",
     f"--user-data-dir={tempfile.mkdtemp()}", "--window-size=1300,1200", "about:blank"],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
try:
    for _ in range(50):
        try:
            tabs = json.load(urllib.request.urlopen(f"http://127.0.0.1:{port}/json")); break
        except Exception:
            time.sleep(0.2)
    ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"])
    n = [0]
    def call(method, **params):
        n[0] += 1; ws.send(json.dumps({"id": n[0], "method": method, "params": params}))
        while True:
            m = json.loads(ws.recv())
            if m.get("id") == n[0]:
                return m.get("result", {})
    # Click each Run button once webR says Ready and the button is enabled. Installed
    # before navigation so it runs inside the page itself (injecting after
    # navigate can land in the old document and be lost).
    clicker = ("setInterval(()=>{const s=document.getElementById('qwebr-status-message-text');"
               "if(!s||!/Ready/.test(s.innerText))return;"
               "document.querySelectorAll('.qwebr-button-run').forEach(b=>{"
               "if(!b.disabled&&!b.dataset.checked){b.dataset.checked=1;b.click()}})},500)")
    call("Page.enable")
    call("Page.addScriptToEvaluateOnNewDocument", source="window.addEventListener('load',()=>{" + clicker + "})")
    call("Page.navigate", url=url)
    t0, hit, text = time.time(), None, ""
    while time.time() - t0 < timeout:
        time.sleep(2)
        text = call("Runtime.evaluate", expression="document.body.innerText", returnByValue=True).get("result", {}).get("value", "")
        hit = re.search(expect, text)
        if hit:
            break
    errs = sorted(set(l.strip() for l in text.splitlines() if re.search(r"^Error( in |:)|there is no package|load failed", l.strip())))
    print(f"{'PASS' if hit else 'FAIL'} after {time.time() - t0:.0f}s: {hit.group(0) if hit else 'expected output not seen'}")
    for e in errs:
        print("  R error:", e[:200])
    # Resize the viewport to the whole page before the screenshot. With
    # captureBeyondViewport alone, Chrome leaves text and images more than a few
    # screens down unpainted, so long lessons came out partly blank.
    h = int(call("Page.getLayoutMetrics")["cssContentSize"]["height"])
    call("Emulation.setDeviceMetricsOverride", width=1300, height=h, deviceScaleFactor=1, mobile=False)
    time.sleep(3)  # let the newly visible content (MathJax, figures) paint
    shot = call("Page.captureScreenshot", format="png")
    open(out, "wb").write(base64.b64decode(shot["data"]))
    sys.exit(0 if hit else 1)
finally:
    chrome.terminate()
