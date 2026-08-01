# Detection Dial

**Where do you set the threshold?** Ten thousand events crossed the network today. Three were an
attack. Choose the suspicion score at which an event becomes an alert a human has to read — and
discover there is no good answer.

**[▶ Play it](https://michael-borck.github.io/security-toys/detection-dial/)** · projector mode: add `?present`

## What it kills

**Base-rate neglect** — the belief that a good detector plus a sensible threshold catches the bad
things and leaves you alone. At three intrusions in ten thousand events, it can't.

## The moment

Hit **Catch everything** on the default *Good* detector:

- **3,659 alerts** to read today
- **1 real alert in every 1,220**
- **31 analysts** doing nothing else

Now hit **A readable queue** — a workload one analyst can actually clear in a shift:

- 113 alerts
- **1 of 3 intrusions caught.** The other two walked straight past.

Then reach for the obvious fix and press **State of the art**. Full coverage still costs 733 alerts
a day and about six analysts. A better detector moves the number; it never removes it.

The quiet intrusion — low-and-slow exfiltration over DNS — is never beaten by tuning. It scores 37,
barely above ordinary traffic. It isn't beating your detector, **it's beating your budget**.

## Using it in class

1. Ask the room to find a good threshold. Give them a minute. Let them fail.
2. Run the three presets in order: *Catch everything* → *A readable queue* → *Quiet life*.
3. Take the "just buy a better detector" objection when it comes — it always comes — and answer it
   with the detector buttons rather than with words.
4. Land it: **"Which of these would you sign your name to, and what would you tell the board you
   chose not to look at?"**

### ISYS2012 (Network Security)

Pairs with the packet-capture lab. It reframes "spot the anomaly" from a puzzle with an answer into
a decision with a cost — which is what the SOC job actually is.

### ISYS6018 (Prove?)

Same artefact, different verb: this is **sampling and detection risk**. A control that *fires* is not
a control that *works*, and a sample that finds nothing is not evidence of nothing. The dial turns
"sufficient and appropriate" into a number the student has to choose and then defend.

Journal prompt: *"You set the threshold. Justify it to the client's CISO, who is paying for every
alert your setting generates."*

## Don't

- Present it as a benchmark of any real detection product. It's synthetic.
- Let the class settle on a "right" threshold. There isn't one — that's the finding, not a failure
  of the exercise.

Full modelling notes, constants and known simplifications: [`SPEC.md`](SPEC.md).
