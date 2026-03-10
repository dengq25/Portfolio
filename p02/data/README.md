# Data

The EEG data files for this portfolio are not included in this repository due to GitHub's 100MB file size limit.

## Files Required

| File | Description |
|------|-------------|
| `sub-301_erpcon_stimlocked_offtask.fdt` | Raw EEG data (binary) |
| `sub-301_erpcon_stimlocked_offtask.set` | EEGLAB epoch metadata |

These two files must be kept in the same folder — the `.set` file references the `.fdt` file directly.

## How to Access

The data files have been shared separately via Google Drive. Please place them in this `data/` folder before running the notebook.

## Dataset

**Study:** Aging and Cognitive Control  
**Subject:** 301  
**Condition:** offtask (stimulus-locked)  
**Format:** EEGLAB (.set / .fdt)
