# Rule Order — build specification

Sufficient to rebuild the toy from scratch.

---

## 1. The one thing it teaches

**A firewall ruleset is a sequence, not a set.** The chain is read top to bottom and evaluation stops
at the first match, so a rule's position decides what it means, and whether it means anything at all.

**The "wait, what?" moment** (if a build doesn't produce this, it isn't finished):

> Three of the six rules are spelled correctly, address the right hosts, and **do nothing whatsoever**,
> because a leftover `-j ACCEPT` sits above them. Nothing reports this. A firewall has no opinion
> about a rule it never reaches.

Two further beats fall out of the same idea without any new mechanic:

- **Specific before general.** Push the broad `-d 10.1.1.0/24 -j DROP` to the top and four rules go
  dead at once, including the one permitting the manager.
- **Correct behaviour ≠ correct ruleset.** Solving it leaves the catch-all unreachable at the bottom.
  The firewall now does the right thing, and the ruleset is still a finding: the next person to add a
  rule below it writes a rule that does nothing, and the next person to move it opens the network.

## 2. It matches the lab exactly

Topology, addressing and verbs are lifted from `assume-breach-labs` **module 07 (firewalls)**, whose
Phase 3 is literally *"rule order decides everything"*:

```
inside                            outside
  pc1  10.1.1.2      [FIREWALL]     pc2  10.1.2.3
  dns  10.1.1.253                   pc3  10.1.2.4
                                    pc4  10.1.2.5
```

The lab's DROP-vs-REJECT distinction is preserved and surfaces in the outcome text, in the lab's own
words: DROP *"times out silently, 100% loss, no error"*; REJECT *"fails fast: Destination Host
Unreachable"*. A student who plays this then does the lab sees the same names, the same addresses and
the same `iptables` syntax.

## 3. The six rules

| id | Rule | Plain |
|---|---|---|
| `pc4` | `-p icmp -s 10.1.2.5 -d 10.1.1.2 -j ACCEPT` | let pc4 reach pc1 |
| `pc2` | `-p icmp -s 10.1.2.3 -d 10.1.1.2 -j DROP` | silently discard pc2 |
| `pc3` | `-p icmp -s 10.1.2.4 -d 10.1.1.2 -j REJECT` | refuse pc3, and say so |
| `in` | `-p icmp -d 10.1.1.0/24 -j DROP` | nothing else gets into the inside network |
| `out` | `-p icmp -s 10.1.1.0/24 -j ACCEPT` | the inside may reach out |
| `any` | `-j ACCEPT` | …left over from a Friday afternoon |

**Starting order is `pc4, pc2, any, pc3, in, out`** — the leftover catch-all placed third. That yields
3 of 5 flows correct and three dead rules, with the failures both pointing at rule 3, so the toy is
self-guiding without a hint button.

## 4. The five flows

| Flow | Should | Why |
|---|---|---|
| pc2 → pc1 | DROP | an untrusted machine: give it nothing back |
| pc3 → pc1 | REJECT | a staff machine: tell them it is blocked |
| pc4 → pc1 | ACCEPT | the manager's machine is allowed in |
| pc2 → dns | DROP | the outside has no business touching the name server |
| pc1 → pc4 | ACCEPT | the inside may still reach out |

Verified outcomes:

| Order | Score | Never reached |
|---|---|---|
| Start (`any` third) | 3/5 | `pc3`, `in`, `out` |
| Solved (`any` last) | **5/5** | `any` |
| General first (`in` top) | 3/5 | `pc4`, `pc2`, `pc3`, `any` |
| Catch-all first | 2/5 | all five others |

Several orders solve it, because `pc4`/`pc2`/`pc3` are disjoint and `in`/`out` never contend. That is
realistic and not worth constraining.

## 5. Interaction

**▲▼ buttons, not drag-and-drop.** Dragging is awkward on a projector, hostile on touch, and needs
extra work to be keyboard-accessible; two buttons are all three for free. Boundary buttons are
`disabled` rather than hidden so the list doesn't reflow.

Flows whose verdict changed since the last render flash amber for 600 ms. The flip *is* the lesson,
so it should be impossible to miss when a single move changes two outcomes at once.

Rules matched by no flow render dashed and dimmed with **"never reached"**. The wording is deliberate:
the toy can only say no *test* traffic reaches the rule, not that it is unreachable for all possible
traffic. True shadowing analysis is a harder problem and is not claimed.

## 6. Deliberate simplifications

- **ICMP only, no state.** Real chains carry `-m conntrack --ctstate ESTABLISHED,RELATED` near the
  top, which is itself an ordering lesson, and a second one. One idea per toy.
- **No policy target.** Real chains have a default policy (`-P FORWARD DROP`) as well as rules; here
  the trailing rule plays that part, which is how the lab presents it too.
- **No rule editing, adding or deleting.** Order is the only variable, on purpose.
- **"Never reached" is relative to the five flows** (see above).

## 7. Non-negotiables

- Single self-contained `index.html`. No CDN, no fonts, no fetch, no storage, no analytics.
- `?present` adds `.present` to `<body>`, raising `--fs` from 16px to 20px.
- Move buttons carry `aria-label` naming the rule number; the score is `role="status" aria-live="polite"`.
- ACCEPT / DROP / REJECT are always carried by the **word**, never by colour alone.
- Works from `file://`, at 1024×768 on a projector, and on a phone.
