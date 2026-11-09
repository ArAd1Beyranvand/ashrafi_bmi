# Design Specification

Everything here is copied from `docs/reference/prototype.html` (source of truth). Units = CSS px
= Flutter logical px on the unscaled 794×1123 sheet. Font = **Montserrat** everywhere
(weights 400/500/600/700/800), `tabular-nums` (use `FontFeature.tabularFigures()`).
Default text colour `#2E3B44`.

## 0. Page chrome
- Canvas `#DFE4E7`. Toolbar: right-aligned, gap 8, padding 10×12, canvas background. Controls:
  `600 13px`, text `#33434C`, bg `#FFFFFF`, border 1px `#C7D1D6`, radius 6, padding 7×10.
  Flutter toolbar = **Back** (left), measurement selector + **Export** (right).
- Stage: sheet centered, bottom padding 24. Prototype fit: `k = min(1, (vw−16)/794)`.
  Flutter: fit-to-screen via FittedBox, **scale capped at 1.0** (D1 decided); further zoom only via InteractiveViewer.

## 1. Sheet
`794×1123`, bg `#FFFFFF`, border `2px #5C656B`, padding `22 26 20 26` (border-box → content
`738×1077`), shadow `0 4 24 rgba(0,0,0,.18)`. Export (PNG/PDF): no border, no shadow (D2 decided); on screen both are shown.

### Gradients (`core/theme/gradients.dart`)
- **G (header bars)**: linear 90° `#1C4785 0%, #245F8D 40%, #2F8E94 75%, #45AD9B 100%`, text white.
- Ident header cells (each its own 90° gradient): ID `#20508A→#245A8C`, Gender `#245A8C→#27698E`,
  Age `#27698E→#2B7A91`, Height `#2B7A91→#348E94`, Date `#348E94→#45AD9B`; Name uses G.
- Trio: `#1C4785→#245F8D`, `#245F8D→#2F8E94`, `#2F8E94→#45AD9B`.
- Compare table: `#1C4785 0, #2F8E94 60%, #45AD9B 100%`.

### Section title `.t`
`800 13.5px`, letter-spacing .1, padding 6×10, bg G, white. `.c` = centered.
Height ≈ 13.5·lineHeight(normal≈1.22)+12 ≈ 28.5 (verify against screenshot).

## 2. Top bar (height 44, items aligned bottom, space-between)
- Logo "charder": `500 33px/1`, `#8D2525`, letter-spacing .5. "®" superscript 9px, raised 28px,
  margin-left 1.
- "U310": `600 13px`, `#37444C`, padding-bottom 2.

## 3. Ident grid (margin-top 6)
Columns `1.3fr .7fr .8fr .8fr .8fr 1.4fr` over 738 px (= 165.1/88.9/101.6/101.6/101.6/177.8).
Font 12.5, centered.
- Header row: Name, ID, Gender, Age, Height, Date — `700`, padding 5×0, right border 2px white
  (not on Date). Bg see gradients.
- Value row: bg `#ECECEC`, `#3A454C`, `500 11.5px`, padding 5×0. Values: name, id, gender, age,
  height (cm, number only), date (`M/D/YYYY h:mm:ss AM`).

## 4. Two columns (margin-top 9)
Left 470, gap 9, right 259. Each column: vertical stack, gap 6.

### 4.1 Body Composition Analysis (left)
Title + grid: columns `283px | 1fr` (=178), gap row 3 / col 9, padding-top 5. 11 rows, each cell
height **21.6**, bg `#E3E3E3`.
- Left cell: padding 0 8 0 10, space-between, `700 12.5px #38444B`; right part `(sub)` in
  `italic 400 9.5px #8A9399`.
- Right cell: right-aligned, padding-right 10, `600 11.5px #3A454C`.
Rows (label, sub, value): Weight (Body Weight) `{w}kg`; BMI (Body Mass Index) `{bmi}`;
Visceral Fat (Visceral Fat Level) `{visc}`; Body Fat % (Percentage of body fat) `{fat}%`;
Body Fat Mass (Weight of body fat) `{fm}kg`; SMM (Skeletal Muscle Mass) `{smm}kg`;
Muscle Mass (Lean Body Mass) `{lean}kg`; Body Water (Body Water Percentage) `{water}%`;
Body Age (Estimated Body Age) `{bage}`; BMR (Basal Metabolic Rate) `{bmr}kcal`;
Bone Mass (Bone Mineral Mass) `{bone}kg`.

### 4.2 Analysis bars — Muscle/Fat Analysis & Obesity Analysis
Container `.an` padding 2 0 4. Row `.ar`: grid `118px | 1fr`, height **39**, bottom border
`1.6px #4C565C` (none on last row of a group), items centered vertically.
- Name: `500 17px #3D474E`, line-height 1; unit superscript `600 7px`, margin-left 6, raised 5;
  sub-label below `6px #9AA3A8`, margin-top 2.
- Scale area: height 40, margin-right 30 (→ scale width = 470−118−30 = **322**).
  - Header labels (only when `hdr`): top −3, `6.5px #58636A`, centered at x%.
    `H3 = [[13,'Under'],[33,'Normal'],[70,'Over']]` (x in %).
  - Bands: top 8, height 7, consecutive segments. `bands = [[tickIndexEnd, color]]`,
    segment width% = `end/(n−1)·100 − previousEnd%`.
  - Ticks: top 16, `6.3px #6B757B`, label i centered at `i/(n−1)·100%` (+ padding-left 2);
    tick mark: width .6, height 9, `#9AA3A8`, top −2 relative to label, centered.
  - Value bar: top 28, height 5.5, `#262C30`, from 0 to `pos(ticks,v)%`; label at its right end,
    margin-left 5, top −3, `700 8.5px #1F2529`, text `round1(value)`.
- Colours: `BL #7D98CF`, `GR #8FC6A2`, `BE #F4D9A7`, `RD #C3202A`.
- `pos(ticks,v)`: `v ≤ t0 → 0`; for i: if `v ≤ t[i+1]` → `(i + (v−t[i])/(t[i+1]−t[i]))/(n−1)·100`;
  else `100`.

| Row | Ticks (11) | Bands | Value fed to pos | Header |
|---|---|---|---|---|
| Weight kg "Total Body Weight" | `55,70,85,100,115,130,145,160,175,190,205` | `[2,BL],[4,GR],[7,BE],[10,RD]` | `w/stdW·100` | H3 |
| SMM kg "Skeletal Muscle Mass" | `70,80,90,100,110,120,130,140,150,160,170` | `[2,BL],[4,GR],[7,BE],[10,RD]` | `smm/stdSMM·100` | – |
| BFM kg "Body Fat Mass" | `40,60,80,100,160,220,280,340,400,460,520` | `[2,BL],[4,GR],[10,RD]` | `fm/stdBFM·100` | – |
| PBF % "Percent Body Fat" | `0,5,10,15,20,25,30,35,40,45,50` | `[2,BL],[4,GR],[10,RD]` | `fat` | H3 |
| BMI kg/m² "Body Mass Index" | `10,15,18.5,21,25,30,35,40,45,50,55` | `[2,BL],[4,GR],[5,BE],[10,stripe]` | `bmi` | – |

`stdW = 22·(h/100)²`, `stdSMM = 0.45·stdW`, `stdBFM = 0.18·stdW`.
BMI stripe = repeating 90° pattern: `#C3202A` 0–18 px, `#8F1218` 18–22 px (period 22, from band start).
Row 1 and row 4 render the H3 headers; displayed label is the raw value, not the percentage.

### 4.3 Segmental Analysis
Title + `.segwrap`: 2 columns (each **231**), gap 8, padding-top 6. Each column:
1. Sub-title `800 12.5px`, centered, padding 4×0, bg G: "Segmental Muscle Analysis" /
   "Segmental Fat Analysis".
2. Figure: width 100% (231), height **166**, SVG viewBox `-115 0 430 410`, `xMidYMid meet`
   → scale `166/410 = 0.4049`, drawn width 174.1, x-offset 28.5.
   - Muscle uses **FLEX** path, fat uses **STAND** path.
   - Glow: same path, fill muscle `#F5D6A2` / fat `#D6E1F1`, opacity .55, Gaussian blur σ=3.
   - Body: radial gradient cx .5, cy .4, r .7 (objectBoundingBox): muscle `#F7D9A6→#F1C98D`,
     fat `#DAE4F2→#C9D7EC`.
   - Legend (figure space): rects x −112, y `4+i·20`, 16×18, colours `#F2D9B0` High,
     `#A9D6CC` Normal, `#5F86C6` Low; text x −90, y `17+i·20`, 10px `#4A555B`.
   - Dots (r 4.2, `#2D353A`): muscle `tr[100,104] ra[22,84] la[178,84] rl[90,300] ll[110,300]`;
     fat `tr[100,96] ra[44,170] la[156,170] rl[90,300] ll[110,300]`.
   - Labels `lab = tr[230,40,'Trunk'] ra[-110,140,'Right Arm'] la[230,140,'Left Arm']
     rl[-110,288,'Right Leg'] ll[230,288,'Left Leg']`. `R = lx > 100`, `ex = R ? lx−8 : lx+86`.
     Leader: `M x y C (x+ex)/2 y, (x+ex)/2 ly+8, ex ly+8 H (R ? lx+80 : lx+6)`, stroke
     `#3D464C` 1.3, no fill. Name text at `(lx + (R?0:6), ly−18)` 11px `#4A555B`; value at
     `(lx+(R?0:6), ly+2)` `600 17px #2F393F`, text `{value}kg`. SVG text baseline = y.
     Values: muscle = segmental.muscle, fat = segmental.fat (kg).
3. Strip: 5 columns, gap 2. Labels row: Right Leg, Right Arm, Trunk, Left Arm, Left Leg —
   `7.4px #4E5A61`, centered, padding 3×0. Bar row: height 24, vertical gradient
   `#F2D9B0 0, #ECD8B6 30%, #A9D6CC 40%, #94C9C6 62%, #5F86C6 72%, #4A74BD 100%`; marker
   line left/right 30%, height 1.6, `#3A444A`, top **13** (muscle) / **7** (fat) in the prototype.
   **Real data (D3):** one marker per segment from the level fields (muscle strip ← `*Lean`,
   fat strip ← `*Fat`), order Right Leg, Right Arm, Trunk, Left Arm, Left Leg.
   Marker top: High → **7**, Normal → **13**, Low → **19** (7/13 from the prototype, Low = same step).
   Level code → High/Normal/Low per Q5 (provisional 3/2/1, see `OPEN_QUESTIONS.md`); unknown → no marker.

### 4.4 Body Composition Change
Title + grid columns `92 | 72 | 6×1fr` (8 columns; key + 7 history columns; 1fr = 95.3),
font 12, left border 1px `#E3E3E3`. Every cell: right border 1px **dashed** `#B9C0C4`, bottom
`1.6px #4C565C`, height **27**, padding 0×6, vertically centered, left aligned.
- Key cell `.k`: `500 15px #3D474E`, line-height 1, column; unit superscript 6px (" kg"/" %"),
  sub `5.5px #9AA3A8` margin-top 2. Rows: Weight kg "Total Body Weight" (`{w}kg`),
  SMM kg "Skeletal Muscle Mass" (`{smm}kg`), PBF % "Percent Body Fat" (`{fat}%`).
- Data cells: `history.takeLast(7)` then empty cells to 7.
- Date row `.d`: bg `#DCDCDC`, no bottom border, height 30, `600 8px #4A555B`; first cell
  "Test Date", then `YYYY.MM.DD` per column, padded.
- Note: the key column is 92 and the first history column is 72 (grid quirk) — reproduce.

### 4.5 I-Shape (right)
Title centered + `.ish` 2 columns (129.5 each), height **282**, padding-top 8; left column right
border `1.6px #9CA5AA`. Each column items centered.
- Column title `.ttl`: `500 12px #3A454C`, padding 4 18 8, bottom border `1.6px #6F7A80`,
  margin-bottom 8. Left "Standard", right "I-Shape".
- **Standard figure**: SVG viewBox `0 0 200 410`, height **236** (width 115.1), overflow visible.
  - Body fill = STAND path, linear gradient userSpace (0,0)→(0,410): `#163F73 0, #1F5D83 .45,
    #3A9C9A 1`.
  - Liquid (clipped by STAND path), `top = 406 − water/100·400`:
    - layer 1: top, A=4, φ=0, fill linear (0,top)→(0,410) `#5CC0AA` opacity .22 → .45.
    - layer 2: top+2, A=3, φ=2, fill `#7FD0BB` opacity .15.
    - path: `M0 top`, then for x = 0,5,…,200: `L x, y(x,t)`, then `L200 420 L0 420 Z`.
    - `y(x,t) = top + A·sin(0.05x + 1.5t + φ) + 0.4A·sin(0.13x − 2.2t + 1.6φ)`, t in seconds.
    - Reduced motion (`MediaQuery.disableAnimations`): A = 0, t = 0.
- **I-Shape matrix** (margin-top 10): grid `42 | 18 | 18 | 18`, gap row 4 / col 1, 10.5px
  `#3A454C`. Header row: blank, symbols `—`, `○`, `+` (9px `#9AA3A8`, centered). Rows Weight,
  SMM, BFM: cells 18 high, `#B8C6E6` | `#A9D5C8` | `#F3D7B3`; a 7×7 dot `#1D2327` in one cell per row.
  **Real data (D4):** the dot column comes from the same `pos()` value as the analysis bar of that
  row (Weight, SMM, BFM): `pos < 20` (inside BL band, ticks 0–2) → `—` Low; `pos < 40` (GR band,
  ticks 2–4) → `○` Normal; otherwise `+` High.
- Legend (margin-top 24): grid `14 | auto`, gap 9×8, 7px `#8A949A`; symbol cells `#9AA3A8`
  centered: `—` Result is Low, `○` Result is Normal, `+` Result is High.

### 4.6 Body Type Trend
Title centered + SVG viewBox `0 0 270 290`, width 100% (259 → scale 0.959, height 278.2),
margin-top 4. Constants `X0=26, Y0=24, S=228, c=S/3=76`.
- Grid rect (X0,Y0,S,S) fill linear gradient objectBoundingBox (0,1)→(1,0):
  `#1C4B86 0, #2B7591 .5, #4BAE9E 1` (bottom-left navy → top-right teal).
- Inner rect (X0+2, Y0+2, S−4, S−4) stroke `#BFE3DC` opacity .7, width 1.2, no fill.
- Lines at i=1,2: vertical x=X0+i·c, horizontal y=Y0+i·c, stroke `#D6EFE9` opacity .8, width 1.4.
- Labels (row-major, top → bottom), `|` = line break:
  `[Athletic, Over Weight|Muscular, Obese] / [Low Fat|Muscular, Standard, Over Fat] /
  [Low Fat|Low Weight, Low Weight, Skinny Fat]`. `700 8.5px #FFF`, centered at
  `cx = X0+ci·c+c/2`, first baseline `cy = Y0+ri·c+c/2 − (lines−1)·5.5 + 3`, next line +11.
- Band mapping: `band(v,a,b,lo,hi) = v<a ? (v−lo)/(a−lo) : v<b ? 1+(v−a)/(b−a) : 2+min(1,(v−b)/(hi−b))`.
  `px = X0 + clamp(band(fat,10,25,0,40), .15, 2.85)·c`;
  `py = Y0 + S − clamp(band(bmi,18.5,25,12,35), .15, 2.85)·c`.
- Marker at `(px, py−11)`: circle r 4.5 fill white opacity .85, stroke white 1.2; inner r 1.8
  `#2B7591`. (Note the −11 offset is in the prototype — reproduce.)
- Axes stroke `#1D2327` 1.4: Y `M X0−6, Y0+S+6 V Y0−14`; X `M X0−6, Y0+S+6 H X0+S+16`.
  Arrowheads (open chevron) `M1 1 L6 5 L1 9`, stroke 1.4, marker 10×10 refX 5 refY 5, oriented
  along the line, tip near line end.
- "BMI": 10px `#3A454C`, rotated −90° at (X0−12, Y0+S/2), centered. "Body Fat (%)": 12px
  `#3A454C`, centered at (X0+S/2, Y0+S+24).
- **Real data (D5):** plot every measurement of `history.takeLast(7)` with the same px/py
  mapping. Older points: circle r 2.5 white, opacity .6, joined in time order by a polyline
  stroke white opacity .6 width 1. The current point uses the prototype marker above (drawn last).
  With one measurement it looks exactly like the prototype.

### 4.7 Visceral Fat
Title centered + `.vf`: grid `1fr | 54`, items bottom-aligned, padding 8 2 6.
- Bar area height 30: segments at bottom, height 9: `0–44% #A8D3D4`, `44–100% #F4D4A9`.
  Labels `700 9px`, top 2, centered at 2% "1", 44% "10", 96% "50". **Real data (D6):** add a marker at x = `vpos(visc)`, piecewise linear through the label
  anchors: 1 → 2%, 10 → 44%, 50 → 96% (clamped to 2–96%). Marker = downward triangle 7 wide ×
  5 high, `#262C30`, tip touching the top of the 9-px band. The label number stays as is.
- Number: `600 22px #323D44`, right-aligned: `{visc} ` + `lv` at 9px.

### 4.8 Trio (Body Age / Bone Mass / BMR)
3 equal columns. Header `800 9.5px`, centered, padding 8×0, right border 1px
`rgba(255,255,255,.5)` (none on 3rd), gradients see §1. Values 12px `#3A454C`, centered,
padding 12×0, right border 1px `#9CA5AA` (none on last): `{bage}Y`, `{bone}kg`, `{bmr}kcal`.

### 4.9 Compared To First And Last Measurement
Title centered, font-size override **10.5**. Grid `72 | 3×1fr` (62.3), font 12, bg = compare
gradient. Cells height 27, centered, right+bottom border 1px `#6D777C`.
- Header row `.hh`: height 24, `800 7.5px` white, border `rgba(255,255,255,.45)`: `%`, Weight,
  Fat, SMM.
- Row header `.rh`: `800 6.3px #FFF`, line-height 1.1, padding 0×3, centered, same border.
- Value cells `.cell`: bg white, `#3A454C`.
Rows: Result (`{w}kg`, `{fat}%`, `{smm}kg`); Compare To First (`round1(cur−first)`);
Compare To Last (`round1(cur−prev)`); Max Results; Min Results (over history, no units).

## 5. Silhouettes
Figure space 200×410. Half-outline (right side incl. centerline points) mirrored:
`mirror(h) = h + reverse(h[1 .. n−2]).map((x,y) → (200 − x, y))`.
Closed Catmull-Rom → cubic Bézier, for each i (indices mod n):
`p0=P[i−1], p1=P[i], p2=P[i+1], p3=P[i+2]`; `c1 = p1 + (p2 − p0)/6`; `c2 = p2 − (p3 − p1)/6`;
segment `C c1 c2 p2`. Start `M P[0]`, end `Z`. (Prototype rounds control points to 1 decimal
via `toFixed(1)` — negligible; Flutter may keep full precision.)

**STAND** (standing, arms down — Standard and Fat figures):
```
[100,6],[110,8],[116,16],[118,28],[116,42],[112,52],[110,60],[111,66],[122,71],[136,75],[147,81],
[152,92],[154,106],[155,122],[156,140],[157,158],[158,176],[160,194],[161,210],[163,222],[165,232],
[163,241],[159,246],[154,243],[152,233],[151,220],[149,204],[146,186],[144,168],[142,150],[140,132],
[137,116],[135,132],[133,150],[131,168],[133,186],[136,204],[139,222],[140,244],[138,266],[134,288],
[131,306],[133,326],[131,348],[127,368],[123,386],[124,398],[121,405],[110,406],[106,401],[106,388],
[105,366],[104,344],[104,322],[103,300],[103,276],[102,254],[100,240]
```
**FLEX** (double-biceps — Muscle figure):
```
[100,6],[110,8],[116,16],[118,28],[116,42],[112,52],[110,60],[111,66],[124,70],[138,72],[150,74],
[162,72],[170,66],[170,56],[167,46],[166,36],[171,27],[180,25],[189,31],[192,42],[192,56],[190,72],
[187,88],[180,98],[168,102],[154,106],[140,114],[136,132],[133,150],[131,168],[133,186],[136,204],
[139,222],[140,244],[138,266],[134,288],[131,306],[133,326],[131,348],[127,368],[123,386],[124,398],
[121,405],[110,406],[106,401],[106,388],[105,366],[104,344],[104,322],[103,300],[103,276],[102,254],
[100,240]
```
Both have 58 / 53 half points → 114 / 104 full points.

## 6. Import page
- Canvas `#DFE4E7`, Montserrat. Centered card, max width 520, white, radius 12, padding 28,
  shadow `0 4 24 rgba(0,0,0,.18)` (D7 decided), vertical gap 16 between items.
- Content (top → bottom): "charder" logo text (`500 20px #8D2525`, small ®), title
  "Open a report file" (`700 20px #33434C`), drop zone, hint, error, "Load sample" text button.
- Drop zone: height 180, full width, dashed 1.5px border `#C7D1D6`, radius 8; centered column:
  upload icon (36, `#5C656B`), "Drag & drop a file here" (`600 14px #33434C`), "or"
  (`12px #8A9399`), button "Choose file" (filled `#2F8E94`, white `600 13px`, radius 6).
- Hint: "JSON or base64-encoded JSON (.json, .txt, .b64)", `12px #8A9399`, centered.
- States:
  - idle – as above;
  - dragging – border + icon `#2F8E94`, background `#2F8E94` at 8% opacity;
  - loading – zone content replaced by `CircularProgressIndicator` (`#2F8E94`); inputs disabled;
  - error – zone back to idle, red text under it (`#C3202A`, 13px) with the parser's message;
  - success – navigate to `/report`.

## OPEN QUESTIONS (design)
Tracked in `docs/OPEN_QUESTIONS.md` (open: D8; D1–D7 decided).
