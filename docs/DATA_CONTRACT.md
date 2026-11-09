# Data Contract

A real device export exists: `docs/reference/sample_input.b64` (original name
`Hamid_AllData_2026-11-08 10.54.27.txt`). **It differs from the schema proposed in Prompt 0**, so
the parser is designed around the real file. The proposed schema is kept below as the *internal
model shape* (what `ReportData` looks like after parsing).

## 1. Input format (device export, decoded)
```json
{"Gender":1,"Birthday":"1974-10-21 00:00:00","Height":1680,"System":"Android",
 "DataArray":[{"date":"2026-10-21 10:37:41","deviceId":0,
   "weight":8225,"bmi":291,"bodyFat":261,
   "bodyFatRightArm":219,"bodyFatLeftArm":232,"bodyFatTrunk":324,"bodyFatRightLeg":222,"bodyFatLeftLeg":232,
   "muscleMass":577,"muscleMassRightArm":40,"muscleMassLeftArm":41,"muscleMassTrunk":298,
   "muscleMassRightLeg":89,"muscleMassLeftLeg":88,
   "bmr":1684,"boneMass":31,"smm":342,"vatLevel":10,"bodyAge":54,
   "bodyFatRightArmMass":11,"bodyFatLeftArmMass":11,"bodyFatTrunkMass":130,
   "bodyFatRightLegMass":27,"bodyFatLeftLegMass":27,
   "bodyWater":540,"posture":9,
   "rightArmFat":3,"rightLegFat":3,"trunkFat":3,"leftArmFat":3,"leftLegFat":3,
   "rightArmLean":3,"rightLegLean":2,"trunkLean":3,"leftArmLean":3,"leftLegLean":2}]}
```
Values are **integers with implied decimals**.

### Field mapping (device → model)
| Model field | Source | Scale | Sample → value |
|---|---|---|---|
| person.gender | `Gender` | 1 → "Male", otherwise "Female" (provisional, OPEN QUESTION Q2) | 1 → Male |
| person.birthday | `Birthday` (`yyyy-MM-dd HH:mm:ss`) | – | 1974-10-21 |
| person.age | derived: full years from Birthday to the *selected* measurement date | – | 52 |
| person.heightCm | `Height` | ÷10 | 168.0 |
| person.name | **not in file** → file-name prefix before first `_` (Q1 decided) | – | "Hamid" |
| person.id | not in file → `–` | – | – |
| m.timestamp | `date` (`yyyy-MM-dd HH:mm:ss`, local, no TZ) | – | 2026-10-21 10:37:41 |
| m.weight (kg) | `weight` | ÷100 | 82.25 |
| m.bmi | `bmi` | ÷10 | 29.1 |
| m.bodyFatPercent | `bodyFat` | ÷10 | 26.1 |
| m.bodyFatMass (kg) | **derived** `weight·bodyFat/100`, 1 dp (OPEN QUESTION Q3) | – | 21.5 |
| m.smm (kg) | `smm` | ÷10 | 34.2 |
| m.leanMass (kg) "Muscle Mass" | `muscleMass` | ÷10 | 57.7 (OPEN QUESTION Q4) |
| m.bodyWaterPercent | `bodyWater` | ÷10 | 54.0 |
| m.visceralFat (level) | `vatLevel` | ×1 | 10 |
| m.bodyAge (years) | `bodyAge` | ×1 | 54 |
| m.bmr (kcal) | `bmr` | ×1 | 1684 |
| m.boneMass (kg) | `boneMass` | ÷10 | 3.1 |
| segmental.muscle.{trunk,rightArm,leftArm,rightLeg,leftLeg} (kg) | `muscleMass{Trunk,RightArm,…}` | ÷10 | 29.8, 4.0, 4.1, 8.9, 8.8 |
| segmental.fat.{…} (kg) | `bodyFat{Trunk,…}Mass` | ÷10 | 13.0, 1.1, 1.1, 2.7, 2.7 |
| segmental.fatPercent.{…} (%) | `bodyFat{Trunk,RightArm,…}` | ÷10 | 32.4, 21.9, 23.2, 22.2, 23.2 |
| segmental.fatLevel / leanLevel {…} | `trunkFat`, `rightArmLean`, … | ×1 | 1..3? (OPEN QUESTION Q5) |
| ignored | `System`, `deviceId`, `posture` | | (OPEN QUESTION Q6 for posture) |

Unknown extra keys are ignored. Integers and decimals are both accepted for numeric fields
(`num`). The prototype's 1-decimal display uses the scaled value.

### Internal model (after parsing)
```
ReportData { Person person; List<Measurement> measurements /* ascending by timestamp */ }
Person     { String? name, String? id, String gender, DateTime? birthday, double heightCm }
Measurement{ DateTime timestamp, weight, bmi, visceralFat, bodyFatPercent, bodyFatMass, smm,
             leanMass, bodyWaterPercent, bodyAge, bmr, boneMass, Segmental segmental }
Segmental  { SegmentValues muscle, fat, fatPercent; SegmentLevels? fatLevel, leanLevel }
SegmentValues { trunk, rightArm, leftArm, rightLeg, leftLeg }
```
The schema from Prompt 0 (`version`, `device`, `person{name,id,gender,age,heightCm}`,
`measurements[]` with decimal values) is **not** an accepted input unless Q7 says otherwise.

### Optional extension keys (our own, not written by the device)
`Name` and `Id` (strings) at top level override the file-name-derived name / `–`. Used by the
bundled samples (`assets/sample/sample_report.json`, `sample_history.b64`), which are encoded in the
device format with integer-scaled values and `Birthday` chosen to give the intended age.
`ReportParser.parse(bytes, {fileName})`; `ReportData.device` is the constant `'U310'`.
`ReportData.history` = last 7; `historyUpTo(i)` = last 7 ending at index i (for the measurement selector).

## 2. Decoding / base64 detection
1. Read bytes; decode as UTF-8 (strip a leading BOM). Trim whitespace.
2. If the text starts with `{` → parse as JSON.
3. Otherwise treat as base64: remove all whitespace/newlines; accept standard and URL-safe
   alphabets (`-_` → `+/`); add missing `=` padding; decode; UTF-8 decode; trim; must start with `{`.
4. Extension does not decide the format (a `.txt` may hold either). Other extensions are rejected
   before reading.

## 3. Validation rules and error messages
Exact strings (shown under the drop zone); the parser throws `ReportParseException(message)`.

| Condition | Message |
|---|---|
| extension not .json/.txt/.b64 | `Unsupported file type. Use .json, .txt or .b64` |
| empty file | `The file is empty` |
| not JSON and not decodable base64→JSON | `This file is not valid base64 or JSON` |
| top level not an object | `Unexpected file structure: expected a JSON object` |
| required top-level key missing | `Missing field: Height` (same for `Gender`, `DataArray`) |
| `DataArray` not a list or empty | `No measurements found in the file` |
| required measurement key missing / null | `Missing field: DataArray[0].weight` (index = position in the file) |
| wrong type (e.g. string for number) | `Invalid value for DataArray[2].bmi` |
| date unparseable | `Invalid date in DataArray[0].date` |
| `Birthday` unparseable | `Invalid value for Birthday` |
| value out of range (weight ≤ 0, height ≤ 0, % outside 0–100) | `Invalid value for DataArray[0].bodyFat` |

Required per measurement: `date, weight, bmi, bodyFat, smm, muscleMass, bodyWater, vatLevel,
bodyAge, bmr, boneMass`, the five `muscleMass*` segments and the five `bodyFat*Mass` segments.
Optional: `bodyFat{Segment}` %, level fields, `posture`, `deviceId`. `Birthday` optional
(age shows `–` if absent).

## 4. Derived values
- Sort `measurements` ascending by `timestamp` (stable for equal timestamps).
- **selected / current** = the measurement chosen in the toolbar; default = **last** (newest).
- **history** = measurements `[0 … selectedIndex]` (nothing after the selected one).
- **previous** = `history[len-2]`, or the current itself when there is only one (→ deltas 0).
- **first** = `history[0]`.
- **Change table** = last **7** of history (`history.takeLast(7)`), empty columns padded to 7.
- **Max/Min results** = max/min over history of weight, fat %, SMM.
- **Standard weight** `stdW = 22·(heightCm/100)²`; `stdSMM = 0.45·stdW`; `stdBFM = 0.18·stdW`.
- `round1(v) = (v·10).round()/10` (prototype `Math.round(v*10)/10`).

## 5. Display formats (from prototype)
- Ident "Date": `M/D/YYYY h:mm:ss AM|PM` (no zero padding), e.g. `10/21/2026 10:37:41 AM`.
- Change-table / short date: `YYYY.MM.DD`.
- Selector label: `YYYY.MM.DD hh:mm AM|PM`.
- Numbers: shown as the scaled value with no forced decimals (JS `String(number)`: `82.25`, `54`,
  `3.1`). Deltas use `round1`.

## OPEN QUESTIONS
Tracked in `docs/OPEN_QUESTIONS.md` (open: Q2–Q8; Q1 decided). Provisional behaviour is listed there.
