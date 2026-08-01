# Detection Dial — build specification

Sufficient to rebuild the toy from scratch.

---

## 1. The one thing it teaches

**No alert threshold gives you both coverage and a readable queue.** Base rates make detection an
economics problem, not a tuning problem.

**The "wait, what?" moment** (if a build doesn't produce this, it isn't finished):

> Catching all three intrusions on the *Good* detector means alerting from score 37 up: **3,659
> alerts a day, about 31 analysts** doing nothing but reading them. Set the dial where one analyst
> can actually clear the queue and **two of the three intrusions walk past**.

The secondary beat is the rebuttal every student reaches for — *just buy a better detector*. Switch
to **State of the art** and catching all three still costs **733 alerts a day, ~6 analysts**. A
better detector moves the number. It never removes it.

## 2. Screen layout

Two columns, collapsing below 860px:

1. **The stream** — a 101-bar histogram of today's suspicion scores, the three intrusions marked as
   red pins, a shaded "alerted" region, the threshold slider, and three preset buttons.
2. **What you caught** — the three intrusions by name, each CAUGHT or MISSED.
3. **What it costs** — alerts, caught, precision, analyst-hours, analysts-on-shift, and a verdict
   band that always names what was given up.
4. **"Just buy a better detector"** — three detector options and a line computing the cost of full
   coverage under the selected one.

A full-width closing card states the lesson in prose.

Bar heights use a **square-root scale**. Linear hides the thin upper tail — which is exactly where
the intrusions live, so linear would erase the subject of the toy.

## 3. The data

10,000 events per day; 3 are intrusions; 9,997 benign.

Benign scores are drawn from a clamped normal distribution via Box–Muller, using a **seeded
mulberry32 PRNG** — the numbers are identical on every load, so a class can argue about them and a
demo repeats. `Math.random()` here would be a bug.

The three intrusion scores are **fixed constants, not sampled**, and deliberately spread out:

| Detector | Benign μ / σ | Intrusion scores | Seed |
|---|---|---|---|
| Basic (signature IDS) | 35 / 20 | 78 · 55 · 30 | 11 |
| Good (tuned SIEM) | 30 / 18 | 88 · 64 · 37 | 22 |
| State of the art (ML) | 24 / 14 | 94 · 76 · 45 | 33 |

**The heterogeneity is the lesson.** A loud port scan, a moderate credential-stuffing run, and a
low-and-slow DNS exfiltration that scores barely above background. Sampling all three from one
distribution would sometimes produce three easy intrusions and destroy the teaching case; fixing
them guarantees the stealthy one is always there.

Resulting curve (verified):

| Detector | Catch 1 | Catch 2 | Catch 3 | One analyst's queue |
|---|---|---|---|---|
| Basic | 158 alerts | 1,572 | **6,062 (51 analysts)** | T=81 → **0 of 3** |
| Good | 7 | 292 | **3,659 (31 analysts)** | T=71 → 1 of 3 |
| State of the art | 1 | 3 | **733 (6 analysts)** | T=57 → 2 of 3 |

## 4. Derived numbers

- `alerts = benign_at_or_above(T) + caught(T)`
- `precision` is shown as **"1 in N"**, never as a percentage — "0.08%" slides off students, "one
  real alert in every 1,220" does not
- `analyst time = alerts × 4 minutes`; `analysts = time / 480 min`
- The **"A readable queue"** preset finds the lowest threshold whose queue one analyst clears in a
  480-minute shift; it is computed, not hard-coded, so it stays correct if constants change

The verdict band has four states and **never congratulates**. Even the "everything caught, queue
survivable" case (only reachable on the best detector) pushes back: *try the other detectors*.

## 5. Deliberate simplifications

State these if a student pushes — each is real, none is a bug:

- **One score per event.** Real detection is many correlated signals, and correlation is precisely
  how a SOC escapes this trade-off. The toy models the tool, not the practice — that's the point the
  closing card makes.
- **4 minutes per alert** is a plausible triage figure, not a measured one. Change it and the shape
  holds; only the labels move.
- **Normal distributions.** Real score distributions are lumpy and multi-modal.
- **Three intrusions in one day** is generous. A real base rate is far lower, which makes the
  precision worse, not better.
- **Not a detector benchmark.** Nothing here says anything about any real product.

## 6. Non-negotiables

- Single self-contained `index.html`. No CDN, no fonts, no fetch, no storage, no analytics.
- Deterministic output — same numbers every load.
- `?present` adds `.present` to `<body>`, raising `--fs` from 16px to 20px.
- Threshold is a native `range` input, so keyboard and screen-reader support come free; the verdict
  is `role="status" aria-live="polite"`; detector buttons carry `aria-pressed`.
- CAUGHT / MISSED is carried by a **word**, not only by colour.
- Works from `file://`, at 1024×768 on a projector, and on a phone.
