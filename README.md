# Security Toys

> **Part of the [Assume-Breach series](https://github.com/michael-borck/security-labs)** — five hands-on security labs, two companion books, and a game. Browse them all at the [series hub](https://github.com/michael-borck/security-labs).

Small self-contained web pages, each built to break **one** specific misconception that lecture
slides reliably fail to break.

**▶ [michael-borck.github.io/security-toys](https://michael-borck.github.io/security-toys/)**

No install, no account, no network, no backend. Save any page and it still works — in an offline lab,
from a USB stick, or uploaded to an LMS as a single file.

## The toys

| Toy | Kills | Status |
|---|---|---|
| **[Crack Time](crack-time/)** | "complexity is what matters" — time-to-crack is length × algorithm × work factor, and two of those belong to the site | ✅ ready |
| **[Defence in Depth](defence-in-depth/)** | "we bought a firewall, we're fine" — layer the controls, misalign the holes, buy the longest attack path your budget allows | ✅ ready |
| **[Detection Dial](detection-dial/)** | base-rate neglect — no threshold gives you both a readable alert queue and full coverage | ✅ ready |
| **[Rule Order](rule-order/)** | "a ruleset is a set" — it's a sequence, first match wins, and a leftover catch-all silences every rule beneath it | ✅ ready |
| **Query Builder** | injection as magic incantation — watch the SQL assemble as you type, then flip one toggle | 🔨 building |
| **EXIF Drop** | "a photo is a picture" — camera, timestamp, and the coordinates of wherever you were standing | 🔨 building |

Add `?present` to any toy (e.g. `crack-time/?present`) to bump type sizes for a projector.

## Course mapping

This repo is **course-agnostic and numbering-agnostic** — folders are named for what the toy *is*.
Two different module numbering schemes exist in the series and they only agree on 03, so the mapping
lives here rather than in the folder names. Adopting these in a unit? Add a row.

| Toy | `assume-breach-labs` module | Curtin ISYS2012 module |
|---|:--:|:--:|
| `crack-time` | 03 password attacks | 03 Authentication & Access |
| `detection-dial` | 06 packet capture | 07 Network Security |
| `rule-order` | 07 firewalls | 08 VPN & Firewalls |
| `query-builder` | 10 web security | 09 Web Security |
| `exif-drop` | 08 forensics | 10 Cybercrime & Forensics |
| `defence-in-depth` | — | 05 Risk · 06 Incident & DR |

`detection-dial` is also used in ISYS6018 (audit) for sampling and detection risk.

## House rules

Every toy obeys all seven. They're what make six pages feel like one set:

1. **Single self-contained `index.html`.** No CDN, no external fonts, no `fetch`. This is the
   load-bearing rule: it survives an offline lab, an LMS upload, and 2029.
2. **One idea per toy.** If it needs a tutorial, it's too big.
3. **Playable in 90 seconds** from cold, by someone who read no instructions.
4. **A named "wait, what?" moment** — the instant the misconception breaks. It's in every `SPEC.md`.
   If a build doesn't produce it, the build isn't finished.
5. **Shared identity** — the palette and type scale in [`STYLE.md`](STYLE.md).
6. **`?present` mode** for projection.
7. **A `SPEC.md` per toy**, sufficient to rebuild it from scratch.

Plus one absolute: **nothing leaves the page.** No storage, no analytics, no backend, anywhere in
this collection. `exif-drop` handles students' personal photos entirely client-side and says so
on-page.

## Offline bundle

```bash
./package.sh          # → security-toys-offline.zip
```

Unzip, open `index.html`, no server. That's the artefact for a lab machine with no internet, an LMS
Content Collection upload, or a student who wants to keep them.

## Adding a toy

1. `cp -r crack-time/ new-toy/` — the scaffold *is* an existing toy
2. Write `index.html`; paste the tokens from [`STYLE.md`](STYLE.md)
3. Write `SPEC.md` and a short `README.md`
4. Add a card to the root `index.html` and a row to the tables above

No generator, no template repo. At this size, copying a folder beats maintaining a scaffolder — and
it keeps the rule that a toy is a file you can read top to bottom.

## What this deliberately doesn't have

No test framework (the check is manual: opens from `file://`, works with no network, readable at
1024×768 on a projector, usable on a phone, keyboard-navigable). No analytics. No framework, no
TypeScript, no build step. No backend.

## Licence

MIT. Unit-agnostic teaching material — no institution or course branding.
