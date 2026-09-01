# Personas

Agents drive the real Mantle build as these people, per the fleet testing
rule. Each scenario gives a start state, plain steps, what success looks like,
and what to check. "Standard checks" means: text scale 1.3 at 360 dp width,
dark mode, airplane mode, and every error in plain words with a way out. Run
the web PWA as well as the APK: the audit found the reveal fails only on web.

## Primary: the Okafor-Lindqvist household, a blended family of four

Ade (45) and Maren (43) just merged two households, with teenagers Tobi (15)
and Elsa (13). They are redecorating and keep arguing about "style". They sit
around one tablet after dinner, passing it hand to hand. The agent plays each
member in turn.

- **Goal:** finish a round together and print a House Charter everyone
  recognises.
- **Context:** shared tablet on the table, four people, 72 quick taps, one
  teen is colour-blind (deuteranopia).
- **Would quit if:** the evening's decisions vanish, or the payoff never
  appears.

**H1. Round to reveal, on web.** Start: fresh PWA in a browser, no members.
Steps: add four members; start a round; make every choice for each member,
passing on each hand-off; tap "See your Mantle". Success: the reveal renders
Spine, Contested, and through-lines. If it fails, the message says the
decisions are saved and offers a working retry. Check: no instruction to
"run a round again"; standard checks.

**H2. Progress you can read.** Start: round in progress. Steps: watch the
title and bar across the Architecture to Tailoring boundary. Success: text
like "Architecture, 4 of 12" is visible; the domain change is marked. Check:
text scale 1.3; screen reader value matches the visible label.

**H3. A mis-tap and a pause.** Start: mid-round, member 2's turn. Steps: tap
the wrong plate; look for an undo; then leave the app and reopen it. Success:
an undo restores the pair; Home offers to continue the unfinished round.
Check: a tap on a plate shows feedback before the pair changes.

**H4. Whose turn is it?** Start: members using the first two default colours.
Steps: view the round in grayscale or a deuteranopia filter. Success: the
current member is identifiable by name or initial, not colour alone. Check:
swatches have names, not "Member colour 3".

## Secondary: Priya, who typed a name wrong

Priya is 52, lives with their partner and adult child, and uses large text.
They added "Aria" as "Aira" and added a guest by accident.

- **Goal:** fix the member list without losing past Charters, then browse
  Explore alone.
- **Context:** text scale 1.3, careful reader, not confident with menus.
- **Would quit if:** the only fix is wiping everything, or an error screen
  has no way back.

**P1. Edit and remove a member.** Start: three members, one Charter saved.
Steps: tap a member tile to rename it; remove the extra member. Success: both
are possible in place; removal can be undone. Check: undo after delete.

**P2. Clear all data.** Start: two saved Charters. Steps: Settings, Clear all
data. Success (fleet delete ruling): with backup set up, it clears at once,
a safety copy is in Previous backups, and an Undo that never expires brings
everything back; without backup, it asks first and says there is no copy.
Check: plain wording; dark mode.

**P3. Explore offline.** Start: airplane mode. Steps: open Explore, then
Learn your style. Success: any error screen keeps its app bar, back arrow,
and a Try again that works. Check: Home leads with "Start a round", not the
tutor.
