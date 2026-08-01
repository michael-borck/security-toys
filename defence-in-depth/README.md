# Defence in Depth — The Swiss-Cheese Game

An interactive, single-file teaching tool for introductory security units. It animates the
defence-in-depth / swiss-cheese metaphor (concentric Physical → Administrative → Technical
layers around the CIA triad) and lets students play the defender's resource-allocation problem.

**Play it:** open `index.html` in any modern browser — no build, no dependencies, no network.

## Modes

- **▶ Watch** — narrated attack stories, randomly chosen each click: sometimes an employee
  challenges a stranger, sometimes CCTV or EDR saves the day… and sometimes the holes line up.
- **L1 · Analyst** — learn the layers. Controls are free; misalign the gaps and watch the
  C·I·A vertices fill differently depending on what you place.
- **L2 · Security Manager** — now there's a budget. More options than gaps, more gaps than
  money: triage, seek funding, buy the longest possible attack path.
- **L3 · CISO** — own the risk. Controls also mitigate threats on a 3×3 risk matrix.
  Run the quarter, survive the SOC feed, and answer for the costs in a board report.

## The one non-negotiable lesson

Risk never reaches zero. Even a fully sealed board can fail — controls break, attackers get
lucky. The defender's product is **time**: misaligned layers force a long, noisy search, and
that delay is what detection needs.

## Docs

`SPECIFICATION.md` is a complete build specification — concept, geometry, scenario scripts,
control/threat catalogues, algorithms, and tuning constants — sufficient to rebuild the game
from scratch.

## Licence & credits

Built by Michael Borck (Curtin University) with Claude. Conceptual model for teaching —
real defence in depth also spans detection, response and recovery.
