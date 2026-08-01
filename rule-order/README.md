# Rule Order

**A firewall ruleset is a sequence, not a set.** Six rules, one network, five flows. Only the
*order* changes — and it changes everything.

**[▶ Play it](https://michael-borck.github.io/security-toys/rule-order/)** · projector mode: add `?present`

## What it kills

The belief that a ruleset is a *set* of statements that are all simultaneously true. It's a
sequence, the firewall stops at the first match, and a rule's position decides whether it means
anything at all.

## The moment

It opens broken: **3 of 5 flows correct, 3 rules never reached.**

Look at rules 4, 5 and 6. They're spelled correctly. They name the right hosts. They do **nothing**,
because a leftover `-j ACCEPT` is sitting at position 3 catching everything first. Nothing warns you
about this — a firewall has no opinion about a rule it never reaches.

Walk that catch-all to the bottom and all five flows go green.

Then read the closing line, because the toy isn't finished with you: the catch-all is *still there*,
now unreachable. The firewall behaves correctly today. The ruleset is still a finding — the next
person to add a rule below it writes a rule that does nothing, and the next person to move it opens
the network. **Correct behaviour and a correct ruleset are not the same claim.**

Try the other classic while you're there: push the broad `-d 10.1.1.0/24 -j DROP` to the top and
watch four rules die at once, including the one letting the manager in. Specific before general.

## It's the pre-lab primer

Topology, addressing and syntax come straight from `assume-breach-labs` **module 07 (firewalls)** —
`pc1` at 10.1.1.2 inside, `pc2`/`pc3`/`pc4` outside, the same DROP-vs-REJECT distinction in the lab's
own words. That lab's Phase 3 is literally *"rule order decides everything"*, where students insert
an ACCEPT above a REJECT and watch a blocked host start working without touching the reject rule.

Ten minutes of this beforehand and Phase 3 stops being a surprise and starts being a confirmation.

## Using it in class

1. Open it. Ask the room to read the six rules and say whether the firewall is configured correctly.
   They'll say yes — every rule *is* correct.
2. Show the score: 3 of 5. Ask which rule is wrong. None of them is.
3. Let someone find the catch-all. Move it. Watch two flows flip at once.
4. Land it: **"How would you have caught this by reading the file?"** That's the audit question, and
   it's the one the Essential Eight gap-analysis will ask them for real.

## Don't

- Treat "never reached" as a general claim. The toy can only say that none of *these five flows*
  reaches the rule; proving a rule is unreachable for all possible traffic is a harder problem.
- Expect it to model connection state. There's no `--ctstate ESTABLISHED,RELATED` here — that's a
  second ordering lesson and it belongs in the lab.

Full modelling notes, the rule table and known simplifications: [`SPEC.md`](SPEC.md).
