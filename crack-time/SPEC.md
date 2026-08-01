# Crack Time — build specification

Sufficient to rebuild the toy from scratch. Written in the style of `defence-in-depth/SPECIFICATION.md`.

---

## 1. The one thing it teaches

**Password strength is mostly not the user's decision.**

Three inputs decide time-to-crack. The user picks one (the password); the site picks the second (how
it's stored); the attacker picks the third (the hardware). The second one dominates by orders of
magnitude — so "use a strong password" is advice aimed at the wrong person.

**The "wait, what?" moment** (if a build doesn't produce this, it isn't finished):

> `correct horse battery staple`, attacked by a rented cloud farm, falls in **~1.4 hours** if the
> site stored it as MD5 — and holds for **~18 thousand years** if the site stored it as bcrypt cost
> 12. Same password. Same attacker. The user changed nothing.

The secondary beat: `P@ssw0rd!` and `Tr0ub4dor&3` are **dictionary hits, not brute force**. All that
decoration is one automatic mangling rule to an attacker, and bcrypt only buys about an hour against
a serious rig. A slow hash does not rescue a bad password — it rescues a *good* one.

## 2. Screen layout

Four cards, two columns, collapsing to one below 820px:

1. **You choose** — text input, plus five preset chips.
2. **The site chooses** — four storage buttons; bcrypt reveals a cost slider (4–16, default 12).
3. **The attacker chooses** — three hardware buttons.
4. **The answer** — big humanised time, verdict band, three facts (attack used / guesses needed /
   guesses per second), and the counterfactual panel.

A full-width closing card states the lesson in prose.

Colour coding is the argument: user input is teal (`--user`), the site's decision purple
(`--system`), the attacker's red (`--attacker`). The counterfactual panel is purple-bordered because
it is always about the site's decision.

## 3. Constants

Guesses per second, order-of-magnitude, shaped by published hashcat benchmarks:

| Rig | MD5 | SHA-256 | bcrypt cost 5 |
|---|---|---|---|
| Old laptop (CPU) | 5 × 10⁷ | 2 × 10⁷ | 1.5 × 10³ |
| Gaming GPU | 1.6 × 10¹¹ | 2.2 × 10¹⁰ | 1.8 × 10⁵ |
| Cloud farm (100 GPUs) | 1.6 × 10¹³ | 2.2 × 10¹² | 1.8 × 10⁷ |

bcrypt at cost *c*: `rate = bcrypt5 / 2^(c-5)` — each +1 halves throughput, for attacker and login
page alike.

Plain text: no rate. Time is zero and the UI says "No cracking required" rather than printing a
number — the point is that hashing is the assumption every other figure rests on.

## 4. Candidate estimation

In priority order:

| Test | Attack | Guesses |
|---|---|---|
| Exact match in the top-passwords list | Top-passwords list | its **rank** (entry #1 = 1 guess) |
| Base word survives de-leeting + suffix stripping | Dictionary + rules | `10⁴ words × 10³ rules = 10⁷` |
| ≥3 alphabetic tokens of length ≥3 | Word-list attack | `(2 × 10⁴)^n_words` |
| otherwise | Brute force | `charset^length` |

Charset: 26 lower + 26 upper + 10 digits + 33 symbols, counted only if present.

Expected time uses **half** the space (you find it halfway through on average), except for an exact
top-list hit, where the rank *is* the guess count.

**Suffix stripping matters.** `P@ssw0rd!` must reach `password`. Strip trailing non-alphanumerics,
then a trailing number, then trailing non-alphanumerics again, *then* de-leet. Doing it in the other
order turns the trailing `!` into an `i` and yields `passwordi`, which misses the wordlist and
reclassifies the password as brute force — silently destroying the toy's main teaching point. Both
the stripped and unstripped forms are tested.

**Why every dictionary password shows the same number.** `10⁷` is the cost of running the *whole*
standard dictionary-plus-rules attack, which the attacker does regardless of which word you chose. It
is not the cost of your specific word. The UI says so, because students notice.

## 5. The quantum panel

A collapsed `<details>` under the closing card, because "what about quantum computers?" is asked in
every offering and the popular answer is wrong.

**Three design decisions, all deliberate:**

1. **Not a fourth attacker rig.** Adding a "quantum computer" button beside three real ones would
   put a machine that does not exist on equal footing with hardware you can rent this afternoon.
   That *is* the misconception; the toy must not reproduce it.
2. **Not a storage option.** "Quantum-resistant hashing" is a category error. Quantum threatens
   *asymmetric* cryptography via Shor's algorithm (RSA, elliptic curve: key exchange and
   signatures), which is what post-quantum standards like ML-KEM address. Password hashing is
   symmetric-flavoured work; the only answer there is more bits and a higher work factor.
3. **Measured in bits, never in seconds.** Inventing a quantum gate rate would be fiction dressed as
   data. Halving the exponent is the honest, checkable claim, so the panel shows
   `log2(n)` against `log2(n)/2` and translates it as "a password with half the strength".

Grover gives a **quadratic** speedup on unstructured search, roughly √N. Worked values:

| Password | Search space | Under Grover |
|---|---|---|
| `P@ssw0rd!` (dictionary hit) | 23 bits | 12 bits |
| `correct horse battery staple` | 57 bits | 29 bits |
| 16-char random | 105 bits | 53 bits |

The panel also carries the point that ties back to the toy's main lesson: **Grover reduces the
number of guesses, not the cost of each one.** A slow hash multiplies every guess, and that
multiplication survives quantum untouched, so bcrypt's work factor is as useful against a quantum
attacker as against a GPU.

It closes on proportion: no such machine exists, error correction currently costs thousands of
physical qubits per logical one, Grover parallelises badly so more machines don't rescue it, and the
cloud farm in panel 3 is rentable today. Worry in that order.

## 6. Deliberate simplifications

State these if a student pushes — each is a real limitation, not a bug:

- **No salt modelling.** Salts stop precomputation and cross-account reuse; they don't change the
  per-password rate, which is what this toy measures.
- **The wordlist is ~80 base words.** A real one is millions of entries. Enough to demonstrate
  behaviour; not enough to be a strength meter.
- **Passphrase pool is a flat 2 × 10⁴ per word** and assumes the words were chosen *randomly*. Four
  words from a sentence you'd actually say are far weaker than four dice rolls.
- **Rates are point-in-time and will age.** They are for teaching the relationship between the three
  inputs, not for quoting in a report.
- **This is not a password strength meter.** Do not present it as one, and do not let students test
  their real passwords in front of anyone.

## 7. Non-negotiables

- Single self-contained `index.html`. No CDN, no fonts, no fetch, no storage, no analytics.
- Nothing typed leaves the page; the UI says so next to the input.
- `?present` adds `.present` to `<body>`, raising `--fs` from 16px to 20px.
- Result region is `role="status" aria-live="polite"`; storage/rig buttons carry `aria-pressed`.
- Works from `file://`, at 1024×768 on a projector, and on a phone.
