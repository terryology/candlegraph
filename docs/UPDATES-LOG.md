# Candlegraph Updates Log

Minor changes and additions made after the initial comprehensive documentation (February 17, 2026).

---

## February 18, 2026

### Brand-Specs Shortcode Enhancement
**Added methodology info link:**
- Small ⓘ icon added to brand-specs shortcode header
- Links to `/methodology/` page
- Subtle amber hover effect
- Consistent styling across archive and post pages
- Updated files:
  - `layouts/shortcodes/brand-specs.html`
  - `static/css/test.css` and `custom.css` (added `.mini-info-link` styles)

**Reasoning:** Provides contextual help for SAV/PAE indexes without cluttering post prose. Users can access methodology explanation from any post containing brand-specs shortcode.

### Methodology Page Update
**Simplified data provenance scale:**
- Reduced from 3-tier (Archival/Recovered/Recalled) to 2-tier (Empirical/Anecdotal)
- Matches actual data schema (single `throw_basis` column)
- Updated `/content/methodology.md`

**Reasoning:** The schema only tracks one binary state (Measured vs Recall), so the three-tier system was aspirational but not implementable with current data structure.

### Backup System
**Created backup_data.R script:**
- Exports Google Sheets to timestamped CSVs
- Saves to `/data/backups/` directory
- Run manually before major changes or monthly
- All four sheets backed up (brands, purchases, burn_times, materials)

**File location:** Project root

### Local Workflow Tools
**Created REVIEW-CHECKLIST.md:**
- Quick-reference checklist for creating review posts
- Kept local-only (added to `.gitignore`)
- Personal workflow aid, not official documentation

**File location:** Project root (gitignored)

---

## Schema Considerations (Discussed, Not Implemented)

Potential future additions to Google Sheets:
- `purchases.purchase_date` (DATE) - Track acquisition dates
- `materials.wick_count` (INTEGER) - Number of wicks
- `materials.wick_type` (TEXT) - Cotton/Wood/Unknown

Will add when collection grows and patterns emerge requiring this data.

---

For major architectural changes, see primary documentation in `/docs/` folder.
