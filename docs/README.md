# Candlegraph Documentation

This folder contains comprehensive documentation for the Candlegraph project, covering the complete technical review, refactoring work, and content creation workflow.

---

## Quick Start

**New to the project?** Start here:
1. **CANDLEGRAPH-PROJECT-SUMMARY.md** - Complete overview of all work done
2. **CONTENT-WORKFLOW-SUMMARY.md** - How to create blog posts

**Need a snippet?**
- **CANDLEGRAPH-SNIPPETS.md** - Copy/paste RStudio snippet code

---

## Documentation by Topic

### Project Overview
- **CANDLEGRAPH-PROJECT-SUMMARY.md**
  - Complete review summary
  - What was accomplished across CSS, Hugo, R, and data
  - Action items and deployment checklist
  - Future roadmap

### Content Creation
- **CONTENT-WORKFLOW-SUMMARY.md**
  - Step-by-step workflow for creating posts
  - Snippet usage and tab-stops
  - Deployment pipeline explanation
  - Best practices and common pitfalls
  - **START HERE** before writing your first post

- **CANDLEGRAPH-SNIPPETS.md**
  - All three snippets in copy/paste format
  - candlereview (brand reviews)
  - candlefeature (prose posts)
  - candleplot (burn session charts)
  - Installation and troubleshooting

- **BLOGDOWN-WORKFLOW-ADDENDUM.md**
  - Why .Rmarkdown instead of .Rmd
  - How Hugo shortcodes work
  - Troubleshooting shortcode rendering
  - File type comparison table

### Technical Stack

#### Frontend (CSS & Hugo)
- **CSS-REFACTOR-SUMMARY.md**
  - Complete stylesheet refactor
  - Semantic variables and accessibility
  - Dark mode implementation
  - Design system documentation

- **HUGO-REVIEW-SUMMARY.md**
  - Config, templates, partials, shortcodes
  - Pagination implementation
  - Environment-based CSS loading
  - File manifest and deployment

#### Backend (R & Data)
- **R-SCRIPTS-SUMMARY.md**
  - data_sync.R pipeline
  - post_brief.R helper function
  - SAV/PAE formula corrections
  - Breaking changes and migration

- **SCHEMA-UPDATE-SUMMARY.md**
  - Google Sheets schema changes
  - Throw measurement refactor
  - Migration steps
  - Updated R code

---

## File Types in This Folder

| File | Type | Purpose |
|------|------|---------|
| README.md | Guide | This file - navigation help |
| *-SUMMARY.md | Documentation | Detailed technical documentation |
| CANDLEGRAPH-SNIPPETS.md | Reference | Code snippets for RStudio |
| *-ADDENDUM.md | Supplement | Additional discoveries and notes |

---

## When to Read What

### Starting a new post
1. CONTENT-WORKFLOW-SUMMARY.md (workflow steps)
2. CANDLEGRAPH-SNIPPETS.md (get the snippet code)

### Updating existing posts
1. R-SCRIPTS-SUMMARY.md (understand data_sync.R changes)
2. CONTENT-WORKFLOW-SUMMARY.md (data pipeline section)

### Making design changes
1. CSS-REFACTOR-SUMMARY.md (understand the system)
2. HUGO-REVIEW-SUMMARY.md (understand templates)

### Updating data collection
1. SCHEMA-UPDATE-SUMMARY.md (current schema)
2. R-SCRIPTS-SUMMARY.md (how R processes it)

### Troubleshooting
1. CONTENT-WORKFLOW-SUMMARY.md (common pitfalls section)
2. BLOGDOWN-WORKFLOW-ADDENDUM.md (shortcode issues)
3. Relevant technical doc for your specific issue

---

## Project Status

**Last Updated:** February 17, 2026

**Current State:** Production ready with documented workflow

**Immediate Action Items:**
- [ ] Fix `stop_temp = 748` -> `74.8` in Google Sheets (burn_times, row 170)
- [ ] Fill in missing hot throw values (throw_hot_1, throw_hot_2, throw_hot_3)
- [ ] Re-run data_sync.R with new SAV formula
- [ ] Update published posts with new SAV/PAE scores

**Workflow Status:**
- ✅ CSS refactored and production-ready
- ✅ Hugo templates reviewed and fixed
- ✅ R scripts updated with correct formulas
- ✅ Content workflow documented and tested
- ✅ Blogdown workflow working with shortcodes

---

## Key Conventions

### File Extensions
- Posts use `.Rmarkdown` (NOT `.Rmd`)
- Blogdown generates `.markdown` files
- Hugo processes `.markdown` into HTML

### Workflow Commands
- Create posts: `blogdown::new_post(title = "...", ext = ".Rmarkdown")`
- Preview: `blogdown::serve_site()`
- Never use the Knit button for posts

### Data Updates
- Primary sheet: Google Sheets (public, read-only access)
- Pipeline: `source(here::here("data_sync.R"))`
- Post helper: `source(here::here("post_brief.R"))`
- Always source both files in post setup chunks

---

## External Resources

**Live Site:** https://candlegraph.netlify.app/  
**GitHub Repo:** (your repo URL)  
**Google Sheets:** (linked in data_sync.R)  
**Hugo Theme:** hugo-lithium  
**Deployment:** Netlify (auto-deploy on GitHub push)

---

## Questions?

If something isn't clear:
1. Check the relevant summary document above
2. Search for keywords across all docs
3. Refer to inline comments in the actual code files

Each summary document has detailed explanations, examples, and troubleshooting sections.

---

**End of README**
