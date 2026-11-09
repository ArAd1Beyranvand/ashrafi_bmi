# Open Questions & Decisions

Single place to track unknowns. Check this file at the start of every prompt; when a question is
answered, move it to "Decided" and update the affected doc.

## Still open
| ID | Question | Current behaviour until answered |
|---|---|---|
| Q2 | `Gender` coding: 1 = Male? What is Female (0 or 2)? | 1 → "Male", anything else → "Female" |
| Q3 | Body Fat Mass isn't exported. OK to derive `weight × bodyFat% / 100`? (segment fat masses sum to 20.6 vs 21.5) | derive, 1 dp |
| Q4 | Is `muscleMass` (57.7) "Lean Body Mass" (prototype label) or soft lean mass? (weight − fat mass = 60.8) | show `muscleMass` under "Muscle Mass (Lean Body Mass)" |
| Q5 | Meaning/scale of level fields (`trunkFat`, `rightArmLean`, …; sample values 2–3) | assume 1 = Low, 2 = Normal, 3 = High; mapping isolated in one function so it is easy to change |
| Q6 | `posture` (9): ignore? | ignored |
| Q7 | Also accept the Prompt-0 JSON schema as input? | device format only |
| Q8 | Timezone of `date` | treated as local time, no conversion |
| D8 | Female standard ranges/ticks for the analysis bars? Prototype has one set | same ticks/bands for everyone |

## Decided (2026-11-09)
- **Q1** Name = file-name prefix before the first `_` (`Hamid_AllData_…` → "Hamid"; whole base
  name without extension if there's no `_`; "Sample" for Load sample). ID = `–`.
- **D1** Report = the A4 sheet only. Fit-to-screen scale is **capped at 1.0** (as in the
  prototype); zooming beyond that only via InteractiveViewer (max 4).
- **D2** Border + shadow on screen; export has no border and no shadow.
- **D3–D6** Show real data (rules in `DESIGN_SPECIFICATION.md` §4.3, §4.5, §4.6, §4.7).
- **D7** Import card: white, radius 12, padding 28, shadow `0 4 24 rgba(0,0,0,.18)`.
