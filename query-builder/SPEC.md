# Query Builder — build specification

Sufficient to rebuild the toy from scratch.

---

## 1. The one thing it teaches

**SQL injection is string concatenation, made visible.** Nobody tricks the database: it parses the
sentence it was handed and answers honestly. The vulnerability is one line above, where a query is
assembled by gluing text together and can no longer tell which words came from the developer and
which came from a stranger.

**The "wait, what?" moment** (if a build doesn't produce this, it isn't finished):

> The **toggle**. Load `admin'--`, watch it log in as the administrator with no password, then switch
> to *Parameterised*. Same input, same form, same everything except one line of server code, and now
> the whole string is just a username nobody has.

Crucially the safe version is **not** escaping, filtering or blocking a keyword. Nobody inspected the
input at all. It simply never got to be part of the sentence. Students who leave believing the fix is
"ban the word OR" have learned the wrong lesson.

## 2. A real engine, not pattern matching

The page contains a small SQL-expression **tokeniser, recursive-descent parser and evaluator** (about
70 lines). Whatever a student types is genuinely parsed and genuinely evaluated against the three
rows.

This matters more than it looks. A lookup table of known payloads would:

- get **operator precedence wrong**. `' OR '1'='1` with password `hunter2` returns *only alice*,
  because `AND` binds tighter than `OR`: it evaluates as `username='' OR ('1'='1' AND
  password='hunter2')`. A student who tries a payload from a cheat sheet and gets an unexpected result
  deserves the true answer, which is the beginning of understanding precedence.
- have no honest answer for input it has never seen, which is most of what a curious class types.

Grammar:

```
orExpr  := andExpr (OR andExpr)*
andExpr := cmp (AND cmp)*
cmp     := primary ('=' primary)?
primary := STRING | NUMBER | IDENT | '(' orExpr ')'
```

`--` and `#` begin a comment to end of line. Unterminated string literals, unknown columns, stray
tokens and empty expressions all raise a real error with a real message.

## 3. The three result states

| State | When | What it teaches |
|---|---|---|
| **Rows returned** | the condition is satisfiable | first row wins, which is how login code usually behaves |
| **Login failed** | it parsed but nothing matched | a parsed query is not a successful attack |
| **SQL syntax error** | tokenising or parsing failed | **the error is itself a finding** |

The error state is not a failure of the toy. Typing a single `'` is the classic probe precisely
because the error reply proves the input reached the parser: the form is injectable even though that
payload broke. The verdict says so.

## 4. Stacked queries, handled honestly

`'; DROP TABLE users--` is the payload every student knows, and it **usually does not work**. Nearly
every database API sends one statement per call, so the second is never executed. The toy detects the
`;`, refuses to pretend, and says so — while warning that this does *not* mean the form is safe, and
pointing at the tautology instead.

Getting this wrong would teach a memorable falsehood, and Bobby Tables is the single most-quoted thing
in the topic.

## 5. The colour rule

Inside the assembled query, the student's input is split at the **first quote character**:

- before it: `--data` teal, still data
- from it onward: `--code` red, now part of the sentence

That boundary is the entire mechanism of the vulnerability, rendered as a colour change. In
parameterised mode the input is shown `--bound` purple next to the `?` placeholders, physically
outside the query text.

**All user input is HTML-escaped before rendering** (`esc()`), including in the SQL panel and the
verdict. A security toy that XSSes itself on `<img onerror=...>` would be an embarrassing own goal;
there is a test for it.

## 6. Deliberate simplifications

- **Three rows, one table, no JOINs.** Enough for a login bypass, which is the canonical case.
- **Only `=`, `AND`, `OR`, brackets, literals.** No `UNION SELECT`, no subqueries, no functions,
  no `LIKE`. `UNION`-based data extraction is a genuinely different lesson and belongs in the Juice
  Shop lab, not here.
- **String comparison is loose** (`String(a) === String(b)`), which is close enough to MySQL's
  behaviour for this purpose and avoids a type-coercion rabbit hole.
- **Passwords are shown in plain text in the table.** That is a separate sin, deliberately not the
  subject here; `crack-time` is the toy that deals with it.
- **No prepared-statement emulation subtleties.** Real drivers vary in whether they emulate prepares
  client-side. Out of scope.

## 7. Non-negotiables

- Single self-contained `index.html`. No CDN, no fonts, no fetch, no storage, no analytics.
- All user input escaped before it reaches `innerHTML`.
- `?present` adds `.present` to `<body>`, raising `--fs` from 16px to 20px.
- Verdict is `role="status" aria-live="polite"`; mode buttons carry `aria-pressed`.
- Result is carried by **words** as well as colour.
- Works from `file://`, at 1024×768 on a projector, and on a phone.
