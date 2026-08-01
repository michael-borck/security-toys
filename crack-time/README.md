# Crack Time

**How long does your password actually last?** Type a password, choose how the site stored it, and
choose what the attacker is running. Watch which of the three knobs actually moves the number.

**[▶ Play it](https://michael-borck.github.io/security-toys/crack-time/)** · projector mode: add `?present`

## What it kills

The belief that **complexity is what matters**. It isn't: time-to-crack is length × algorithm ×
work factor, and two of those three belong to the site, not the user.

## The moment

Load `correct horse battery staple`, set the attacker to **Cloud farm**, and switch storage between
**MD5** and **bcrypt cost 12**:

- MD5 → **~1.4 hours**
- bcrypt cost 12 → **~18 thousand years**

Same password. Same attacker. The user changed nothing — the *site's* decision moved the answer by
eight orders of magnitude.

Then hit the `P@ssw0rd!` chip and watch it classify as **Dictionary + rules**, not brute force. All
the substitutions are one automatic mangling rule. bcrypt buys about an hour against a serious rig
and no more: a slow hash rescues a good password, not a bad one.

## Using it in class

1. Ask the room for a password they think is strong (nobody's real one). Type it. Leave it on MD5.
2. Switch the attacker from laptop → GPU → cloud farm. The number collapses; nothing about the
   password changed.
3. Switch storage to bcrypt cost 12. The number explodes; still nothing about the password changed.
4. Land it: *"Which of those three did the user control?"*

Pairs with the password-cracking lab (`assume-breach-labs` module 03) — run this for ten minutes
first and the John the Ripper session stops being a tool demo and starts being an argument.

## Don't

- Present it as a password strength meter. It isn't one, and the wordlist is ~80 words.
- Ask anyone to type a password they actually use. Nothing leaves the page, but the projector is a
  network too.

Full modelling notes, constants and known simplifications: [`SPEC.md`](SPEC.md).
