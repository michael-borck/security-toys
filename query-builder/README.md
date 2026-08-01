# Query Builder

**Watch the SQL assemble as you type.** A login form, and the query it builds underneath. Type a
quote and watch the exact character where your data stops being data.

**[▶ Play it](https://michael-borck.github.io/security-toys/query-builder/)** · projector mode: add `?present`

## What it kills

**Injection as a magic incantation.** Nobody tricks the database. It parses the sentence it was
handed and answers honestly — the vulnerability is one line above, where the sentence got built by
gluing text together.

## The moment

Press the **`admin'--`** chip. You are logged in as the administrator, and you never supplied a
password: the comment marker threw away the half of the sentence that checks it.

Now press **Parameterised**. Same input, same form, same everything except one line of server code —
and the whole string is just a username nobody has.

That toggle is the lesson. Flip it back and forth with the same payload.

**And notice what the safe version is not doing.** Nothing inspected the input. Nothing escaped a
quote or blocked a keyword. The query was finished before the input was anywhere near it, so the
quote had nothing to close. Students who leave thinking the fix is "ban the word OR" have learned the
wrong thing.

## It really runs the SQL

There's a small tokeniser, parser and evaluator in the page, so anything typed is genuinely parsed
and evaluated — including the mistakes. Three consequences worth using in class:

- **A single `'` produces a real syntax error**, and the toy calls that a finding: the error proves
  the input reached the parser, so the form is injectable even though that payload broke. That's why
  attackers probe with a quote.
- **Precedence is real.** `' OR '1'='1` with password `hunter2` returns *only alice*, because `AND`
  binds tighter than `OR`. A cheat-sheet payload that behaves unexpectedly is a teaching moment, not
  a bug.
- **Bobby Tables is handled honestly.** `'; DROP TABLE users--` mostly *doesn't* work: nearly every
  database API runs one statement per call. The toy says so, and warns that this doesn't mean the
  form is safe.

## Using it in class

1. Log in as alice properly. Establish that the form is ordinary.
2. Type a single `'` in the username. Get the error. Ask what it just told an attacker.
3. Press `admin'--`. Let the room sit with "no password was involved".
4. Press **Parameterised** without changing anything else.
5. Land it: **"What did we filter?"** Nothing. That's the answer.

Pairs with the OWASP Juice Shop lab (`assume-breach-labs` module 10) — ten minutes of this first and
the lab stops being trial-and-error with payloads off a cheat sheet.

## Don't

- Expect `UNION SELECT`, subqueries or `LIKE`. Data extraction is a different lesson; this one is
  login bypass, and the engine covers `=`, `AND`, `OR` and brackets deliberately.
- Read anything into the plaintext passwords in the table. That's a separate sin, and `crack-time` is
  the toy for it.

Full grammar, modelling notes and known simplifications: [`SPEC.md`](SPEC.md).
