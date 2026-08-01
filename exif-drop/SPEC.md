# EXIF Drop — build specification

Sufficient to rebuild the toy from scratch.

---

## 1. The one thing it teaches

**A photo is not a picture, it is a file — and the file has opinions about you.**

**The "wait, what?" moment** (if a build doesn't produce this, it isn't finished):

> It's the student's own photo, from the student's own phone, and it names the spot they were
> standing on to within a few metres, at a known second, from a camera with a serial number that
> appears in every other photo it has ever taken. The room goes quiet.

## 2. Privacy is a design constraint here, not a disclaimer

This toy handles real personal photographs, so the safety rules are part of the build:

- **Everything is client-side.** `FileReader` + `URL.createObjectURL`. No `fetch`, no upload, no
  storage, no analytics — as with every toy in this collection, but here it is stated **on the page,
  in a permanent banner**, not buried in a footer.
- **The page will not open a map for you.** It offers *Copy the coordinates* and explains why:
  pasting them into a map service sends them to that service. Making that a decision rather than a
  click is itself the lesson. Auto-linking would have the toy leak the very thing it is warning about.
- **The banner tells the student to keep their own screen to themselves.**
- **The sample is synthetic** (§4) so the page ships no real photograph and discloses no real home.

**Facilitation rule that must travel with the toy:** never put a volunteer's photo on the lecture
projector. A holiday photo on a lecture-hall screen is a live disclosure of where somebody lives.
This is a private exercise on each student's own screen, and the deck note has to say so.

## 3. The parser

Hand-written, no libraries. JPEG marker scan → `APP1` segment → `Exif\0\0` → TIFF header → IFD walk.

- Marker scan stops at `SOS`/`EOI`; anything that is not a JPEG returns `null` cleanly.
- Byte order from `II`/`MM`, magic `42` checked.
- IFD entries: tag(2) type(2) count(4) value-or-offset(4). Types 1–12 sized from a table; values of
  more than four bytes are read from the offset, four or fewer are read inline.
- `0x8769` (Exif SubIFD) and `0x8825` (GPS IFD) are followed as links.
- Every read is bounds-checked against `byteLength`, so truncated and malformed files return `null`
  instead of throwing. There is a test for a truncated file.

GPS rationals are `[degrees, minutes, seconds]`; decimal = `d + m/60 + s/3600`, negated when the ref
is `S` or `W`.

Fields marked as **tells** (rendered red): body serial number, camera owner, lens serial, artist, and
the original timestamp. These are the ones that link files to each other and to a person, as distinct
from the merely photographic ones.

## 4. The synthetic sample

`buildSample()` constructs a real JPEG-with-EXIF **in memory**, byte by byte, and feeds it to the same
parser. It ships no photograph, and its coordinates are a **public university campus**, not a home.

It doubles as a self-test: if the sample parses, the parser handles inline values, data-area values,
ASCII, SHORT, LONG and RATIONAL, and both sub-IFD links.

> **The bug this caught, recorded because it is easy to reintroduce.** The first version let the
> caller declare whether a value was inline. `GPSLatitudeRef` is `"S\0"` — two bytes — so EXIF
> requires it **inline**, but it was written as a data-area pointer. The parser correctly read the
> pointer bytes as characters, got `"d\x01"`, failed to match `"S"`, and the latitude came back
> **positive**: the sample plotted in the northern hemisphere and reported itself 535 km from
> Shanghai. Nothing errored. The builder now decides inline-vs-offset from the byte length, as the
> format specifies.

## 5. Where on earth, without a map

No tile server (network) and no embedded coastlines (bytes, and inventing simplified geography from
memory would produce something quietly wrong). Instead:

- **Nearest-city distance and bearing** from a 53-city table, by haversine plus initial bearing to a
  16-point compass: *"6.8 km SSE of Perth"*. This lands harder than a dot on a world map anyway.
- **A graticule mini-map**: an equirectangular grid with the equator and prime meridian drawn and the
  position plotted. Honest about what it is; no fabricated coastlines.
- **A precision line**: six decimal places pins a spot roughly the size of a car.

## 6. When there is no EXIF

Handled as a teaching state, never a shrug: screenshots and PNGs carry none, and most chat apps and
social networks strip EXIF on upload — **which is why the copy you received is clean and the original
on the photographer's phone is not**. Absence is evidence about the path the file took.

There is a middle state too: EXIF present, no GPS. The verdict then redirects attention to the
timestamp and serial number, because location is the loudest field, not the only one.

## 7. Deliberate simplifications

- **JPEG only.** HEIC (the iPhone default) is an ISO-BMFF container needing a much larger parser;
  PNG's `eXIf` chunk is rare. Both fall through to the no-EXIF explanation, which is still correct
  and still teaches something.
- **No IPTC or XMP.** Real forensic tools read those too.
- **No thumbnail extraction.** Embedded EXIF thumbnails sometimes survive cropping and show the
  *uncropped* original, which is a great story and a second toy's worth of work.
- **One file at a time.** The cross-photo pattern — same serial, clustered coordinates — is described
  in the closing text rather than built, to keep one idea per toy.

## 8. Non-negotiables

- Single self-contained `index.html`. No CDN, no fonts, no fetch, no storage, no analytics.
- The privacy banner is always visible, above the fold, not in the footer.
- No automatic map link, ever.
- All rendered values HTML-escaped.
- Drop zone is keyboard-operable (`tabindex`, Enter/Space) as well as drag-and-drop.
- `?present` adds `.present` to `<body>`, raising `--fs` from 16px to 20px.
- Works from `file://`, at 1024×768 on a projector, and on a phone.
