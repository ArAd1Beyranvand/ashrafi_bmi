# Project Overview

## Purpose
Show a Charder U310 body-composition export as the approved one-page A4 report
(`docs/reference/prototype.html`), and let the user export it (PDF/PNG).

## Screens
1. **Import** – pick a file (button) or drag & drop it (desktop). Accepts `.json`, `.txt`, `.b64`;
   content is JSON, raw or base64. "Load sample" loads `assets/sample/sample_report.json`.
   Parse errors are shown under the drop zone with a specific reason.
2. **Report** – the A4 sheet (794×1123) scaled to fit, pinch/zoom/pan. Toolbar: **Back**,
   **measurement selector** (one entry per measurement in the file, newest selected by default),
   **Export**.

## User flow
Launch → Import → choose/drop file → (loading) → success → Report → pick another measurement
(sheet re-renders using that one as "current") → Export, or Back → Import.

## Out of scope
- Accounts, login, backend, network sync (except Google Fonts download, with bundled fallback).
- Several people per file / person switching (the prototype's person `<select>` becomes a
  measurement selector).
- Persistence (no history of opened files, no settings storage).
- Dark sheet / theme toggle (prototype's "Theme" button is dropped; canvas stays light).
- Localisation (English only), editing data, device connection.
