# EXIF Drop

**A photo is not a picture, it's a file — and the file has opinions about you.** Drop one in and read
what it says besides the image.

**[▶ Play it](https://michael-borck.github.io/security-toys/exif-drop/)** · projector mode: add `?present`

## Read this before you use it in class

**Never put a student's photo on the projector.** A holiday photo on a lecture-hall screen is a live
disclosure of where somebody lives, to a room full of people. This is a **private exercise on each
student's own screen** — that's the whole design, and the deck note has to say so out loud.

The page itself is built for that: nothing uploads, nothing is stored, there's no analytics and no
server. It says so in a permanent banner, and students can prove it by pulling the network first —
everything still works. It also deliberately **won't open a map for you**; it offers to copy the
coordinates and explains that pasting them into a map service sends them to that service. Making
that a decision rather than a click is part of the lesson.

## What it kills

The belief that a photo is just an image. It's a container: camera, lens, the exact second the
shutter opened, often a **serial number**, and frequently the coordinates of wherever you were
standing.

## The moment

It's their own photo, from their own phone. It names the spot to within a few metres, at a known
second, from a camera whose serial number appears in **every other photo it has ever taken**.

Press **Load a synthetic sample** first if you want a guaranteed demo — it builds a JPEG with EXIF in
memory, ships no real photograph, and its coordinates are a public university campus. It reports
itself as *6.8 km SSE of Perth*.

## When nothing comes back

That's a teaching state, not a failure. Screenshots and PNGs carry no EXIF, and most chat apps and
social networks strip it on upload — **which is why the copy you received is clean, and the original
on the photographer's phone is not.** Absence tells you about the path the file took, not about the
camera.

Note the phone-native format caveat: iPhones shoot HEIC by default, which this doesn't parse. A JPEG
straight off a camera or phone gives the best result.

## Using it in class

1. Run the synthetic sample on the projector. Safe, and it shows the shape of the thing.
2. Ask everyone to try one of their own photos, **on their own screen**, and say nothing out loud.
3. Ask only for a show of hands: *who got coordinates?*
4. Land it: **"You never chose to publish any of that. The camera wrote it while you were composing
   the shot."**
5. Then the forensics turn, which is the module's actual subject: one photo gives a place and a
   second; a handful from the same camera share a serial number and cluster around the few places a
   person really spends time. Nobody had to follow anyone.

Pairs with the digital-forensics lab (`assume-breach-labs` module 08).

## Don't

- Ask anyone to share a photo, describe where it was taken, or hand you their phone.
- Treat a clean result as proof of good practice — it usually means a platform stripped the data on
  the way, which is a favour nobody asked for and nobody can rely on.

Full parser notes, the synthetic-sample design and known limits: [`SPEC.md`](SPEC.md).
