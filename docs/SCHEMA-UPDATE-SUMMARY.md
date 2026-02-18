# Google Sheets Schema Update - Summary

**Date:** February 17, 2026  
**Change Type:** Schema evolution to support multiple hot throw measurements

---

## What Changed

The throw measurement schema was updated to better reflect how scent evaluations are actually collected:

### Old Schema

**burn_times table:**
- throw_hot (single measurement per session)
- throw_hot_basis (Measured/Recall)

**purchases table:**
- throw_cold (single measurement)
- throw_cold_basis (Measured/Recall)

### New Schema

**burn_times table:**
- No throw columns (burn times are purely empirical measurements now)

**purchases table:**
- throw_cold (single measurement at purchase)
- throw_hot_1 (first burn checkpoint)
- throw_hot_2 (mid-life checkpoint)
- throw_hot_3 (end-life checkpoint)
- throw_basis (applies to all throw measurements: Measured/Recall)

---

## Why This Change?

### Problem with old schema:
1. Recording hot throw for every burn session was exhausting and noisy
2. Having separate basis columns for cold/hot was redundant
3. Throw measurements didn't belong in the burn_times table (not session-level data)

### Benefits of new schema:
1. **Realistic measurement cadence:** 2-3 checkpoints across candle life is manageable
2. **Captures consistency patterns:** Can see if throw degrades (4→3→2) or stays stable (4→4→4)
3. **Cleaner separation:** Empirical burn data vs. subjective evaluations
4. **Simpler provenance:** One basis flag per candle, not per measurement type

---

## Migration Steps

If you have existing data to migrate:

1. **Move throw_hot from burn_times to purchases:**
   - Take the most representative hot throw value (or average if multiple)
   - Put it in `throw_hot_1` in the purchases table
   - Leave `throw_hot_2` and `throw_hot_3` empty (fill later as you recall/re-evaluate)

2. **Consolidate basis columns:**
   - If you have both cold and hot measured: `throw_basis = "Measured"`
   - If recalling both: `throw_basis = "Recall"`
   - If mixed (unlikely): use "Measured" if any empirical data exists

3. **Clean up burn_times:**
   - Remove `throw_hot` column
   - Remove `throw_hot_basis` column

4. **Update purchases:**
   - Rename `throw_cold_basis` to `throw_basis`
   - Remove `throw_hot_basis` (now redundant)

---

## Updated R Code

The updated `data_sync.R` now:

```r
# Average all available hot throw measurements
throw_hot_avg = rowMeans(
  select(., throw_hot_1, throw_hot_2, throw_hot_3), 
  na.rm = TRUE
),
# Replace NaN (when all three are NA) with NA
throw_hot_avg = if_else(is.nan(throw_hot_avg), NA_real_, throw_hot_avg),

# Weighted scent score
cold_score = coalesce(as.numeric(throw_cold), 3),
hot_score  = coalesce(throw_hot_avg, as.numeric(throw_cold), 3),
weighted_scent = (cold_score * 0.4) + (hot_score * 0.6),

# Provenance flag
is_empirical = !is.na(throw_basis) & throw_basis == "Measured"
```

---

## Going Forward

### For new candles:
1. Measure `throw_cold` at purchase
2. Measure `throw_hot_1` after first proper burn
3. Measure `throw_hot_2` at mid-life (~50% burned)
4. Measure `throw_hot_3` near end of candle
5. Set `throw_basis = "Measured"` if you took notes contemporaneously

### For completed candles (retrospective):
1. Recall the general pattern: did it start strong? stay consistent? fade?
2. Estimate 2-3 checkpoint values that reflect that pattern
3. Set `throw_basis = "Recall"`

### Workflow tip:
Keep quick notes in your individual candle sheets at those 3 checkpoints:
- "First burn: Strong throw, fills room - 4"
- "Mid-life: Still strong - 4"
- "Near end: Noticeably weaker - 3"

Then transfer to the primary sheet when candle is complete.

---

## Files Updated

- `data_sync.R` - Updated to average three hot throw measurements
- `CANDLEGRAPH-PROJECT-SUMMARY.md` - Updated action items
- `SCHEMA-UPDATE-SUMMARY.md` - This document

---

## Notes

- The SAV/PAE math is unchanged - this is purely a data collection refinement
- Brand rankings still use `is_verified` flag (calculated from `is_empirical`)
- Performance plot legend still shows "Empirical" vs "Anecdotal"
- The `post_brief.R` script needs no changes

---

**End of Summary**
