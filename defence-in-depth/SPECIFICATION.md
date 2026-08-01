# Defence in Depth — "The Swiss-Cheese Game"
## Build Specification v3

A single-file interactive HTML teaching tool for introductory security units. It animates the defence-in-depth / swiss-cheese metaphor and lets students play the defender's resource-allocation problem. Conceptual accuracy over technical precision throughout; the one non-negotiable lesson is **risk never reaches zero — the defender's product is *time***.

---

## 1. Concept & teaching goals

The mental model being taught:

1. Security controls form concentric **layers** (Physical → Administrative → Technical) around the **CIA triad** (the assets).
2. Every layer has **holes** (swiss cheese). Breaches happen when holes **line up**.
3. An attacker who gets through one hole must **search laterally** for the next — that search is **delay**, and delay is what gives monitoring/people/detection time to fire.
4. If the attacker reaches the core anyway, the discipline shifts to **forensics** (reconstruct, learn, re-layer).
5. Real-world constraints: **budgets force triage**, controls affect **C, I and A unevenly** (decisions are never in isolation), and even a "fully sealed" system can fail (**controls fail; risk ≠ 0**).

Audience: undergraduates, first exposure. Tone: story-driven, slightly playful, projector-friendly.

## 2. Structure: Watch + three play levels, one engine

Single page, four tabs sharing the same rendering/attack engine. The three play levels are **progressive disclosure** — each adds exactly one decision dimension:

| Tab | Name | Adds | Removed/absent |
|---|---|---|---|
| ▶ Watch | Watch the concept (landing) | narrated scripted attack stories | — |
| L1 | **Analyst** — "learn the layers" | placement/misalignment + CIA gauges | no budget (all 16 controls free), no funding button, no costs shown on chips, no risk matrix |
| L2 | **Security Manager** — "budgets & trade-offs" | budget, affordability, funding | no risk matrix |
| L3 | **CISO** — "risk & consequences" | threat risk matrix, mitigation, "Run the quarter" simulation, breach costs + cost-benefit report | manual Launch replaced by Run the quarter |

The **SOC feed** (attack stream, §8.6) runs in every tab, including Watch — the feeling of being constantly under attack is level-independent. Each level shows a one-line description under the panel title ("Level 1 · Analyst — Learn the layers. Controls are free…" etc.).

Note: in L1 the player *can* seal every layer for free — that's intentional; it fast-forwards them to the bounce/bypass lesson (risk ≠ 0) without money in the way.

## 3. Technical constraints

- One self-contained `.html` file: inline CSS + vanilla JS + SVG. No frameworks, no build step, no external requests, **no localStorage/sessionStorage** (in-memory state only).
- Works from `file://` in any modern browser; pointer events (mouse + touch) for drag.
- Dark theme, CSS custom properties:
  `--bg #0b1220`, panels `#111a2e`/`#0e1626`, line `#22304d`, ink `#e6edf7`, muted `#93a4c3`,
  physical `#2dd4bf` (teal), admin `#60a5fa` (blue), technical `#a78bfa` (violet),
  CIA/amber `#fbbf24`, attack `#f87171`, good `#34d399`.
- Layout (desktop-first; not intended for phones): header (title + tab buttons) → **status strip** (flex row: Narration card + detection meter, flexible width · Scoreboard, play mode only · Layers legend) → main flex row: SVG stage (`viewBox 0 0 800 800`) centred in the remaining space, sized `height: clamp(420px, 100vh − 300px, 820px)` · right column 330px (Watch: scenario buttons + hint; Play: budget line, action buttons **above** the tray, control tray grouped by layer with per-layer open-gap counts, hint, CIA readout — column scrolls) → footer disclaimer:
  *"Conceptual model for teaching — real defence in depth also spans detection, response and recovery. Risk never reaches zero; the goal is time."*

## 4. Scene geometry (SVG, centre CX=CY=400)

| Element | Values |
|---|---|
| Ring: Physical (outer) | rIn 300, rOut 352 |
| Ring: Administrative | rIn 220, rOut 272 |
| Ring: Technical (inner) | rIn 140, rOut 192 |
| Attacker corridors (radius the attacker circles at) | 286 (between physical/admin), 206 (between admin/technical) |
| Attack entry radius | 386 |
| Hole angular width | 17° |
| Core disc | r 112, dark fill |
| CIA triangle | equilateral, circumradius 72, vertices at −90° (C, top), 150° (I), 30° (A); vertex circles r 19; centre label "ASSETS" |

Rendering details:

- Rings drawn as thick arc strokes (`stroke-width = rOut−rIn` on radius `(rIn+rOut)/2`), solid segments between holes, plus a faint (12% opacity) full-circle underlay.
- **Open hole**: gap in the ring with dashed radial edge lines; invisible drop-target circle at the hole midpoint.
- **Plugged hole**: arc segment re-drawn across the gap at 50% opacity + circular badge (r 16) with the control's emoji; `<title>` tooltip = control name; click to unplug/refund.
- Layer name labels sit at the top (−90°) of each ring on rounded dark background pills, layered **under** plug badges.
- SVG group z-order: rings → labels → plugs/holes → centre → attack.
- **CIA gauges**: each vertex circle fills bottom-up with amber (clip-path rect) proportional to coverage (see §8.4); letter is white with dark halo so it reads on both states; tooltip gives ~% and the caveat "(from placed controls — conceptual)".

## 5. Data model

```
holes = { physical: [{angle, plug: controlId|null}, …], admin: […], technical: […] }
```

Gap counts (Play): physical 5, admin 5, technical 4 → **14 gaps**.

Random layout (Play): per ring, evenly spaced base angles (360/n) with a random global offset and per-hole jitter of ±(base−17−10)/2, so holes never collide.

**Staggered layout (Watch, detection stories)** — random layouts almost always contain a near-aligned pair, so scripted stories must use a constructed layout where every hole is ≥ ~50° from the nearest hole in the adjacent layer:
physical [35, 155, 275], admin [95, 215, 335], technical [155, 275] — all + one random global rotation + ±7° jitter.

**Aligned layout (Watch, "Everything lined up")**: physical [35,150,255], admin [35,165,270], technical [35,205], all + one random global rotation — a straight-shot tunnel in a different position every run.

## 6. Attack engine

- The attacker enters at a **random open physical gap** (they can't see the whole board), then hunts **optimally from there**: brute-force all (admin × technical) open-hole combinations and take the path minimising total lateral arc length. Exception: the "Everything lined up" scenario uses full optimisation over all three layers so it always finds the tunnel wherever the rotation put it.
- Path = radial in at entry hole (386→286) → arc along corridor 286 to admin hole (shortest direction) → radial 286→206 → arc along corridor 206 to technical hole → radial 206→centre.
- Animated as an SVG path: glowing red dot (`getPointAtLength`) + red trail (stroke-dashoffset), constant speed **150 px/s**. Segment-keyed narration captions update as the dot enters each phase.
- **Detection clock**: only *lateral/search* distance counts (radial punches are "free"). Detection threshold **D** is in px of search-arc; when accumulated search ≥ D → intercepted (green pulse ring at that point, banner alert). Reaching the centre first → breach (red pulse on core, banner, forensics).
- Sidebar meter: green→amber→red fill = search/D. Readout: Watch shows "delay: X.Xs"; Play shows a **countdown**: "SOC detects in X.Xs (while attacker hunts)".
- Forensics timeline on every outcome — **qualitative, no raw degrees**: entry line, then one line per hop based on angular distance (<22° → "⚠ almost no searching… these gaps were nearly lined up"; 22–60° → "a moderate hunt"; >60° → "a long, exposed search — good misalignment"), total seconds, and on breaches a verdict line ("the layers were effectively one hole" when any hop <22°, else "decent misalignment, but not enough time").
- **End-of-round overlay**: breach or containment is a stop-the-game moment, so the outcome is a modal debrief card centred over the dimmed board (dark backdrop + blur), appearing ~950 ms after resolution so the pulse animation lands first. Card = coloured headline (green contained / red breach), epilogue, forensics list, and two buttons: a contextual primary ("🎲 Another scenario" in Watch → runs a random story; "▶ New round" in Play → reshuffle + budget reset) and "🔍 Inspect the board" (close, leaving the attack trail visible for discussion). Backdrop click and Escape also close. There is no sidebar outcome card — the overlay is the single outcome surface; the narration strip keeps a one-line summary.

## 7. Watch mode — story scenarios

Three buttons: **🎲 Random scenario**, **🛡 Detection story**, **💥 Breach story** (the latter two pick randomly within their category). Each scenario overrides the default per-segment narration, the alert banner, and supplies an epilogue for the outcome card.

| # | Type | Title | Detection point (frac of total search-arc) | Story beat / banner |
|---|---|---|---|---|
| 1 | detect | The curious employee | 0.32 | Tailgater wanders badge-less; staff member asks "Can I help you? Who are you here to see?" → intruder bails. Lesson: **people/security culture are a layer**. |
| 2 | detect | The night-shift guard | 0.55 | 2:14 am fence cut; CCTV operator spots movement in a blind-spot handover, dispatches patrol. Lesson: monitoring turns delay into detection. |
| 3 | detect | The suspicious request | 0.72 | Cloned contractor badge; fake IT asks staff to "verify" a password; trained employee refuses & reports; SOC correlates. Lesson: **admin controls detect as well as prevent**. |
| 4 | detect | The 3 am beacon | 0.90 | Attacker inside via shared account; EDR flags lateral movement at the last layer. Lesson: any single save is luck; the layered system is design. |
| 5 | breach | Everything lined up | never (aligned layout) | Propped fire door → unenforced visitor policy → unpatched server: three forgivable holes become one tunnel. → forensics. |
| 6 | breach | The quiet Sunday | D = totalArc×1.15+60 (meter fills ~87% but never triggers) | Staggered layout, long noisy path, alerts firing — but the SOC queue is unstaffed. Lesson: **response capacity is a layer too; risk ≠ 0**. |

Detection scenarios use the staggered layout so D = frac×totalArc always fires and the four stories intercept progressively later (~1s → ~2.7s), visually distinct.

## 8. Play mode

### 8.1 Controls catalogue (16 options, $990k total)

`cia = [C,I,A]` contributions, 0–3, deliberately debatable "best guess":

| Layer | Control | Cost $k | C | I | A |
|---|---|---|---|---|---|
| Physical | 🚧 Perimeter fence | 70 | 1 | 0 | 2 |
| Physical | 📷 CCTV | 50 | 1 | 1 | 0 |
| Physical | 🛂 Badge access | 60 | 2 | 1 | 0 |
| Physical | 💂 Security guards | 110 | 1 | 1 | 2 |
| Physical | 🧯 Fire/UPS protection | 80 | 0 | 0 | 3 |
| Admin | 🎓 Security training | 40 | 2 | 1 | 0 |
| Admin | 📋 Policies & procedures | 30 | 1 | 2 | 0 |
| Admin | 🤝 Vendor vetting | 45 | 1 | 1 | 1 |
| Admin | 🕵️ Background checks | 35 | 2 | 1 | 0 |
| Admin | 🚨 IR plan & drills | 55 | 0 | 1 | 2 |
| Technical | 🔐 MFA | 65 | 3 | 1 | 0 |
| Technical | 🩹 Patching | 55 | 1 | 2 | 1 |
| Technical | 🛰️ EDR | 90 | 1 | 2 | 0 |
| Technical | 💾 Backups | 60 | 0 | 1 | 3 |
| Technical | 🔏 Encryption | 75 | 3 | 1 | 0 |
| Technical | 🧱 Firewall | 70 | 1 | 1 | 1 |

Designed inequality: **16 options > 14 gaps > ~8 affordable** (base budget $400k).

### 8.2 Placement

Tray of chips (colour-coded by layer, showing cost; tooltip shows CIA contribution). Drag onto a matching-layer open hole (valid targets highlight during drag; snap radius ~55 px screen). Controls only fit their own layer. Click a plugged badge → full refund to tray. Unaffordable chips grey out (not draggable) as remaining budget shrinks.

### 8.3 Budget & funding

Base budget **$400k**, shown as "Budget $X · unspent $Y · controls cost $990k in total". **💰 Seek funding** button (disabled mid-attack): 50% rejection with rotating flavour lines ("CFO: 'Not this quarter'", "Didn't we buy a firewall in 2019?"…); 42% grant +$50–150k; **8% windfall +$400–600k** ("a breach at a competitor made headlines") — enough to eventually plug everything, which sets up the bounce lesson. "New round" resets budget, reshuffles gaps, empties tray.

### 8.4 CIA gauges

`points[c|i|a] = Σ cia of placed controls`; fill fraction = `min(1, points/9)` (target 9). Rendered in the triangle vertices (§4) and echoed as text: "CIA coverage: C x% · I y% · A z% — every control moves them differently; no decision is made in isolation." Updates live on every plug/unplug.

### 8.5 Attack resolution (🚨 Launch attack)

- Draw SOC detection time **T = 1.0 + rand×2.8 seconds** of hunting (i.e. D = T×150 px). Shown as a live countdown.
- If an open path exists → smart-attacker animation (§6). Balance result: near-aligned open gaps (~0.5s path) always breach; a well-misaligned spread (~3.4s max achievable) is contained ~85% of the time. Good play usually wins, never certainly.
- **Bounce phase** — if any layer is fully plugged (no path): the attacker repeatedly probes random plugged holes on the outermost sealed layer (dot animates in-and-out, ~1.1s per attempt; probing accrues hunt-time at 0.9× real time, so the countdown keeps falling). After each bounce, **9% chance the probed control fails** ("💥 {control} fails under a novel technique — no control is perfect") → that hole opens (visually), and resolution re-runs (path if one now exists, else keep bouncing the next sealed layer). Expected outcome ≈ 80% contained ("repeated probing lit up the SOC — attacker locked out"), ≈ 20% a control fails and the attack proceeds — preserving *risk ≠ 0 even fully sealed*. Failed controls are restored automatically at the next attack / new round.
- Scoreboard: attacks, contained, breaches, best delay (s).
- Outcomes use the end-of-round overlay (§6): contained (green) or breach→forensics (red) headline + epilogue + forensics/probe log.

### 8.6 SOC feed (attack stream)

A translucent monospace ticker fixed to the lower-left of the stage (max 5 lines, older lines fade by position, fake HH:MM clock that advances 1–7 min per line). Every ~3.4 s (paused during quarter sims and live attacks) it prints a fizzled attack attempt: a threat is picked weighted by its *effective likelihood* ([1,3,7] weights for low/med/high), then rendered as either "blocked by {a placed mitigating control}" (65% chance when one exists, green accent), a threat-specific fizzle line ("🔒 Ransomware — loader crashed on execution"), or a generic incompetent-attacker line ("🧑‍💻 attacker typo'd the exploit — failed"). Manual attack launches print "⚠ intrusion in progress — tracer active" in red. The feed is theatre with a point: security work is mostly invisible successes.

### 8.7 Threat catalogue & risk matrix (Level 3)

3×3 heat-map grid (x = likelihood →, y = impact ↑), cells tinted green→amber→red by (impact+likelihood). Threat chips (emoji) sit in their **effective** cell and move when controls change; the chip pulses when its threat attempts in a quarter. `mit` controls reduce likelihood one step each when placed; `impMit` controls reduce impact one step each. Tooltips give base vs effective values and the mitigating control lists; tray chip tooltips list what each control mitigates.

| Threat | base like | base impact | likelihood ↓ with | impact ↓ with |
|---|---|---|---|---|
| 🌊 DDoS | high | low | Firewall | IR plan |
| 🎣 Phishing | high | med | Training, MFA | IR plan |
| 🔒 Ransomware | med | high | Patching, EDR, Training | Backups, IR plan |
| 🕶 Insider threat | med | high | Background checks, Policies | IR plan |
| 🧩 Supply-chain | med | high | Vendor vetting, Patching | IR plan |
| 🚪 Physical intrusion | med | med | Fence, Badge, Guards, CCTV | — |

### 8.8 "Run the quarter" & cost-benefit (Level 3)

Replaces the manual Launch button. 7–9 attack attempts, one every ~1.3–2 s: each picks a weighted threat, pulses its matrix chip, and rolls escalation probability by effective likelihood — **[0.05, 0.14, 0.30]** for low/med/high. Non-escalations print fizzle lines. The **first escalation** becomes a live tracer attack (the normal engine, bounce phase included). Placement is frozen (no drag/unplug) while a quarter runs.

Every quarter ends in the overlay as a board report: attempts, fizzled count, controls spend, then:

- **Quiet quarter** (~25–30% when nothing escalates): "security success is invisible" framing; nuisance avoided ≈ $25k × fizzled; verdict compares spend vs avoided.
- **Contained**: breach-cost-avoided ≈ IMPACT_COST[effective impact] = **[$80k, $220k, $500k]**; verdict "defence paid for itself" or "this one attack didn't repay the spend, but the fizzled attempts did".
- **Breach**: breach cost = IMPACT_COST[effective impact] + random flavour (IR retainer, regulator fine, reputation/churn, stock dip, weekend rebuild); forensics timeline included; verdict totals controls + breach and asks "what would you change: cheaper controls, or better placement?"

## 9. Tuning constants (single source of truth)

| Constant | Value |
|---|---|
| Attacker speed | 150 px/s |
| Hole width | 17° |
| Watch detect fracs | 0.32 / 0.55 / 0.72 / 0.90 of total search-arc |
| Watch breach threshold | totalArc × 1.15 + 60 px (fills, never fires) |
| Play SOC timer T | 1.0 + rand×2.8 s |
| Bounce duration / clock rate / bypass chance | 1100 ms / 0.9× / 0.09 |
| Base budget / catalogue total | $400k / $990k |
| CIA fill target | 9 points per letter |
| Funding odds | 50% reject · 42% +$50–150k · 8% +$400–600k |
| Gaps per ring (play) | 5 / 5 / 4 |
| SOC feed cadence / max lines | ~3.4 s · 5 lines |
| Quarter attempts / cadence | 7–9 · ~1.3–2 s |
| Escalation odds by eff. likelihood | 0.05 / 0.14 / 0.30 |
| Breach/avoided cost by eff. impact | $80k / $220k / $500k |
| Quiet-quarter nuisance value | $25k × fizzled attempts |

## 10. Key copy (verbatim where it matters)

- Header sub: "Every layer of controls has holes. Your job isn't to make risk zero — it can't be — it's to make sure the holes never line up, so an attacker's journey to the core takes long enough to be detected."
- Default attack narration by segment: physical entry → "search sideways… this movement is pure delay" → admin entry → "every degree they travel is time our monitoring, logging and people have to notice" → "final push toward the core!"
- Contained: "Delay is a security outcome." Breach: "Prevention failed, so we move into forensics: reconstruct the path, learn, re-layer."

## 11. Acceptance checks

1. No console errors on load, mode switch, all six Watch scenarios, drag/drop, refund, funding, open-path attack, sealed-layer bounce attack (headless-browser test each).
2. All four detection stories intercept (staggered layout guarantees D < totalArc); "Everything lined up" and "The quiet Sunday" always breach.
3. Player can never afford all 16 controls on base budget; windfall path can seal all 14 gaps; sealed system still occasionally breaches via bounce-bypass.
4. CIA gauges: an all-C spend visibly leaves A near-empty (the trade-off must be seeable at a glance).
5. Unplug always refunds exactly the cost; bypassed controls restore next round.
6. Levels differ correctly: L1 shows no costs/funding and never greys a chip; L2 = budget game; L3 shows the matrix and "Run the quarter". Placing Training visibly drops Phishing one likelihood column.
7. A quarter always terminates (quiet report, contained report, or breach report), re-enables all buttons, and clears the frozen-placement state — including when the escalated attack hits the bounce phase.
8. The SOC feed ticks in all four tabs and pauses during quarters/live attacks.

## 12. Backlog / nice-to-haves

Post-round debrief line ("your longest survivable path was X°; the attacker found Y°"); difficulty presets (SOC timer range); named attacker personas with different speeds; sound cues; class leaderboard; export round summary for discussion.
