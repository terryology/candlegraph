# Candlegraph Updates Log

Minor changes and additions made after the initial comprehensive documentation (February 17, 2026).

---

## February 22, 2026

### Data Quality: Burn Time Capping
**Added is_final_burn logic to data_sync.R:**
- Implemented 4-hour session cap for data quality
- Exception: Final burns allowed to run to completion
- New `effective_time` field replaces `total_time` in PAE calculations
- Ensures fair brand comparisons (no artificial inflation from marathon burns)

**Schema addition:**
- `burn_times.is_final_burn` (BOOLEAN) - flags the last session before candle fully consumed

**Impact:**
- PAE scores adjusted (brands with excessive burns capped at 4hr per session)
- Final burns still count fully (extracting all remaining value is legitimate)
- Collection average shifted, some brand positions changed on performance map

**Files modified:**
- `data_sync.R` - Added conditional capping logic
- Updated performance_map.png (regenerated with new calculations)

**Reasoning:** The 4-hour maximum is the industry safety guideline. Hours 5-10 of a single burn aren't representative of quality performance. Final burns are exempted because letting a candle burn to completion naturally is intentional value extraction, not negligence.

### Methodology Page Correction
**Fixed fundamental documentation error:**
- Removed obsolete "10oz normalization baseline" section
- Documented actual formulas used in code
- Added clear examples for SAV and PAE calculations
- Explained why hrs/$ naturally accounts for size differences
- Documented 4hr capping with final burn exception

**The problem:**
- Published methodology described a "Size Factor (oz/10)" normalization that doesn't exist in the code
- Created confusion about how indexes are actually calculated
- Suggested double-normalization (price already accounts for size)

**The fix:**
- Methodology now accurately reflects `data_sync.R` implementation
- PAE: `(brand_hrs/$ / collection_avg_hrs/$) × 100`
- SAV: `(brand_weighted_scent / collection_avg_scent) × 100`
- Both are purely relational - no size factor involved

**Files modified:**
- `content/methodology.md` - Complete rewrite of sections 1-3

### Brand-Specs Shortcode Enhancement
**Added methodology info link:**
- Small ⓘ icon added to brand-specs shortcode header
- Links to `/methodology/` page
- Subtle amber hover effect (0.02 opacity background)
- Consistent styling across archive and post pages

**Files modified:**
- `layouts/shortcodes/brand-specs.html` - Added info link in header
- `static/css/test.css` and `custom.css` - Added `.mini-info-link` styles

**Reasoning:** Provides contextual help for SAV/PAE indexes without cluttering post prose. Users can access methodology explanation from any post containing brand-specs shortcode, not just through site navigation.

### CSS Refinements
**Visual polish and consistency:**
- Centered `.mini-vault` (brand-specs) and `.vault-audit` components
- Added drop shadows to both (0 3px 10px rgba(0,0,0,0.05))
- Fixed vault-audit border (full border instead of just top)
- Added border-radius to vault-audit for card consistency
- Centered text in audit sections

**Dark mode improvements:**
- Added `.dark-mode .legend-box` overrides (per Gemini recommendation)
- Prevents light pastel backgrounds from jarring in dark mode
- Uses transparent tinted versions: rgba(42, 157, 143, 0.1) and rgba(231, 111, 81, 0.1)

**Files modified:**
- `static/css/test.css` and `custom.css` - Complete refactor
- Removed duplicate `.mini-info-link` blocks
- Fixed misplaced closing brace in `.audit-grid`

### Backup System
**Created backup_data.R script:**
- Exports Google Sheets to timestamped CSVs
- Saves to `/data/backups/` directory
- Run manually before major changes or monthly
- All four sheets backed up (brands, purchases, burn_times, materials)

**Files created:**
- `backup_data.R` - Backup script (project root)
- CSV exports in `data/backups/` (committed to Git for version history)

**Reasoning:** Provides insurance against accidental data loss or corruption in Google Sheets. Small collection size means CSV files are tiny (~5-10 KB each), so committing to Git is practical.

---

## February 18, 2026

### Methodology Page Update
**Simplified data provenance scale:**
- Reduced from 3-tier (Archival/Recovered/Recalled) to 2-tier (Empirical/Anecdotal)
- Matches actual data schema (single `throw_basis` column with Measured/Recall)
- Updated `/content/methodology.md`

**Reasoning:** The schema only tracks one binary state (Measured vs Recall), so the three-tier system was aspirational but not implementable with current data structure.

---

## Schema Considerations (Discussed, Not Implemented)

Potential future additions to Google Sheets:
- `purchases.purchase_date` (DATE) - Track acquisition dates
- `materials.wick_count` (INTEGER) - Number of wicks
- `materials.wick_type` (TEXT) - Cotton/Wood/Unknown

Will add when collection grows and patterns emerge requiring this data.

---

## Breaking Changes Summary

### is_final_burn Capping (Feb 22)
**Impact:** PAE scores changed for some brands
- Brands with many long burns saw efficiency decrease (capped at 4hr)
- Brands with mostly proper burns saw relative improvement (baseline shifted)
- Example: Diptyque PAE increased from 39.4 → 40.7 (relative improvement as other brands dropped more)

**Required actions:**
- Re-run `data_sync.R` with new logic ✅
- Performance map regenerated ✅
- No published posts to update yet (first review still in draft)

### Methodology Documentation (Feb 22)
**Impact:** Site documentation now matches implementation
- Removed confusing/incorrect normalization baseline description
- No code changes, purely documentation fix
- Users now have accurate understanding of how indexes work

---

## Files Modified This Session (Feb 22)

### R Scripts
- `data_sync.R` - is_final_burn capping, effective_time usage
- `post_brief.R` - (no changes this session, already updated Feb 17)
- `backup_data.R` - (new file)

### CSS
- `static/css/test.css` - Full refactor with centering, shadows, dark mode fixes
- `static/css/custom.css` - (same as test.css, production-ready)

### Hugo Layouts
- `layouts/shortcodes/brand-specs.html` - Added methodology info icon

### Documentation
- `content/methodology.md` - Major rewrite (sections 1-3)
- `docs/UPDATES-LOG.md` - This file

### Generated Assets
- `static/images/performance_map.png` - Regenerated with new PAE calculations

---

## Next Steps

### Immediate (Before Next Review Post)
- [ ] Commit all Feb 22 changes
- [ ] Verify Netlify deployment succeeds
- [ ] Test methodology page renders correctly
- [ ] Verify performance map displays updated positions

### Future Enhancements
- [ ] Add purchase_date tracking when pattern emerges
- [ ] Consider automated data_sync.R during Netlify builds (when collection grows)
- [ ] Add wick count tracking when relevant
- [ ] Create dedicated performance map page (beyond just methodology embed)

---

For major architectural changes, see primary documentation in project root:
- `CANDLEGRAPH-PROJECT-SUMMARY.md`
- `CSS-REFACTOR-SUMMARY.md`
- `HUGO-REVIEW-SUMMARY.md`
- `R-SCRIPTS-SUMMARY.md`

---

**Last Updated:** February 22, 2026
