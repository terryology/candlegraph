# Candlegraph Content Creation Workflow - Summary Document

## Overview
This document covers the content creation workflow for Candlegraph, including RStudio snippet setup, post creation process, and the local-to-production deployment pipeline.

**Date:** February 17, 2026 
**Context:** Post-refactor workflow optimization following CSS, Hugo, and R script improvements

---

## [GOALS] Content Types & Snippets

Candlegraph has two primary content types, each with its own RStudio snippet:

### 1. Brand Reviews (`candlereview`)
**Purpose:** Data-driven reviews tied to the R pipeline 
**Trigger:** Type `candlereview` + Shift+Tab in RStudio

**What it scaffolds:**
- Complete YAML front matter (title, date, description, slug, type, output format)
- R setup chunk that sources `data_sync.R` and calls `get_brief()`
- Placeholder for `brand-specs` shortcode
- Performance map section with `data-vault` wrapper
- Placeholder for `vault-audit` shortcode

**Snippet code:**
```
snippet candlereview
	---
	title: "${1:Post Title}"
	author: "Terry"
	date: "`r format(Sys.Date(), '%Y-%m-%d')`"
	description: "${2:One-sentence description}"
	slug: "${3:url-slug}"
	type: "review"
	output: blogdown::html_page
	---
	```{r setup, include=FALSE}
	knitr::opts_chunk\$set(echo = FALSE, dev = 'svg', fig.width = 10, fig.height = 8)
	source(here::here("data_sync.R"))
	get_brief("${4:Brand Name}")
	```
	<!-- Paste brand-specs shortcode from get_brief() output below -->
	${5:{{< brand-specs brand="" sav="" pae="" tier="" >}}}
	
	## Performance Hierarchy
	
	{{< data-vault title="Performance Map" id="perf-map-${3}" >}}
	```{r performance-map}
	print(performance_plot)
	```
	{{< /data-vault >}}
	
	---
	
	<!-- Paste vault-audit shortcode from get_brief() output below -->
	${6:{{< vault-audit brand="" id="" sessions="" hours="" confidence="" >}}}
	$0
```

**Important notes:**
- The `\$` in `opts_chunk\$set` is escaped so RStudio doesn't treat it as a snippet field
- Every line after `snippet candlereview` must start with exactly ONE tab character (not spaces)
- The snippet fields (`${1:...}`, `${2:...}`, etc.) allow tab-through navigation when filling in values

### 2. Feature Posts (`candlefeature`)
**Purpose:** Prose-focused posts (reflections, data journey, collection updates) 
**Trigger:** Type `candlefeature` + Shift+Tab in RStudio

**What it scaffolds:**
- Minimal YAML front matter
- Bare-bones R setup chunk
- Drops you straight into the body to start writing

**Snippet code:**
```
snippet candlefeature
	---
	title: "${1:Post Title}"
	author: "Terry"
	date: "`r format(Sys.Date(), '%Y-%m-%d')`"
	description: "${2:One-sentence description}"
	slug: "${3:url-slug}"
	type: "post"
	output: blogdown::html_page
	---
	```{r setup, include=FALSE}
	knitr::opts_chunk\$set(echo = FALSE)
	```
	$0
```

**Key differences from `candlereview`:**
- `type: "post"` instead of `type: "review"` (enables future filtering in Hugo)
- No `dev = 'svg'` or figure dimensions (add manually if needed)
- No `source()` call or `get_brief()` (not data-driven)
- Minimal setup for maximum flexibility

### 3. Brand Burn Chart (`candleplot`)
**Purpose:** Quick visual of a brand's burn session consistency 
**Use case:** Inline in feature posts when discussing specific brand performance

**Snippet code:**
```
snippet candleplot
	```{r ${1:chunk-name}}
	df_master %>%
	 filter(brand_name == "${2:Brand Name}") %>%
	 arrange(start_time) %>%
	 mutate(session_num = row_number()) %>%
	 ggplot(aes(x = session_num, y = total_time)) +
	 geom_col(fill = "#D97706") +
	 labs(
	 title = "${2:Brand Name} -- Burn Sessions",
	 x = "Session",
	 y = "Hours"
	 ) +
	 theme_minimal()
	```
	$0
```

**Notes:**
- Uses `#D97706` (Candlegraph amber from CSS variables)
- References actual schema columns (`total_time`, `start_time`)
- Named chunk prevents knit errors when multiple plots exist in one post

---

## [WORKFLOW] The Review Post Workflow

### Step-by-Step Process

**1. Create the post**
- In RStudio, create new `.Rmd` file in `content/post/`
- Type `candlereview` + Shift+Tab
- Fill in the tab-stop fields:
 - Title
 - Description
 - Slug (URL-friendly, e.g., `paddywax-apricot-rose`)
 - Brand Name (must match exactly with `brand_name` in Google Sheets)

**2. Initial knit**
- Save the file
- Click Knit (or Cmd/Ctrl+Shift+K)
- The setup chunk runs `get_brief()` automatically
- Console output shows two shortcodes ready to copy

**Console output example:**
```
--- HUGO SPECS ---
{{< brand-specs brand="Paddywax" sav="112.3" pae="98.7" tier="Overachiever" >}}

--- HUGO FOOTNOTE ---
{{< vault-audit brand="Paddywax" id="AUDIT-PAD" sessions="3" hours="87.5" confidence="Empirical" >}}
```

**3. Paste shortcodes**
- Copy the `brand-specs` shortcode -> paste into first placeholder
- Copy the `vault-audit` shortcode -> paste into second placeholder

**4. Write your review**
- Add prose between the data vault sections
- Reference stats inline if needed (e.g., `` `r round(b$sav_index, 1)` ``)
- Add additional sections, images, whatever the post needs

**5. Test locally**
- Knit again to regenerate `.html`
- Run `hugo server` or `blogdown::serve_site()`
- Preview at `localhost:4321` (or whatever port Hugo assigns)
- Check for:
 - Shortcode rendering
 - Performance map display
 - Dark mode compatibility
 - Mobile responsiveness

**6. Commit and deploy**
- Stage both `.Rmd` and `.html` files in GitHub Desktop
- Commit with a clear message (e.g., "Add Paddywax review")
- Push to GitHub
- GitHub webhook triggers Netlify
- Netlify runs Hugo build and deploys to `candlegraph.netlify.app`

**7. Verify live**
- Check the live site
- Test on mobile if possible
- Verify all vault components render correctly

---

## [SETUP] RStudio Snippet Setup

### How to edit snippets

1. In RStudio: `Tools > Edit Code Snippets`
2. Select the "R" tab (since `.Rmd` files are R-based)
3. Scroll to bottom or find your snippet
4. Edit carefully, ensuring every line after `snippet NAME` starts with exactly one tab

### Critical formatting rules

**[CHECKLIST] DO:**
- Use exactly one tab at the start of each line
- Escape dollar signs: `\$` when you need a literal `$`
- Escape backticks if needed: `` \` ``
- Test the snippet after editing to verify output

**? DON'T:**
- Use spaces instead of tabs
- Use multiple tabs
- Mix tabs and spaces
- Forget to escape special characters (`$`, backticks, etc.)

### Testing a snippet

After editing:
1. Create a new `.Rmd` file (don't save)
2. Type the snippet trigger + Shift+Tab
3. Verify the output matches what you expect
4. Delete the test file

---

## [DATA] Data Pipeline Integration

### How get_brief() works

When you knit a review post, the setup chunk calls:
```r
source(here::here("data_sync.R"))
get_brief("Brand Name")
```

**What happens:**
1. `data_sync.R` loads and processes all Google Sheets data
2. Calculates SAV and PAE indexes for all brands
3. Applies confidence tax for brands with N < 3
4. `get_brief()` filters to the target brand
5. Determines tier (Grail, Overachiever, Workhorse, Dud)
6. Generates formatted Hugo shortcodes
7. Prints to console for copy/paste

**What you get:**
- `brand-specs` shortcode (displays in mini-vault component)
- `vault-audit` shortcode (technical footnote)
- Both include live, calculated values from current data

### When data changes

If you:
- Add new burn sessions to Google Sheets
- Fix data entry errors
- Re-run `data_sync.R` with formula updates

Then you need to:
1. Re-knit affected posts
2. Run `get_brief()` again for those brands
3. Update the shortcode values in the post
4. Commit updated `.html` files

**This is why the SAV formula change is a breaking change** -- it affects all published posts.

---

## [DEPLOY] Deployment Pipeline

### Local -> GitHub -> Netlify

```
+-----------------+
| RStudio |
| (.Rmd file) |
+--------+--------+
 |
 | Knit
 ?
+-----------------+
| Generated |
| (.html file) |
+--------+--------+
 |
 | Commit both files
 ?
+-----------------+
| GitHub |
| (repo) |
+--------+--------+
 |
 | Webhook triggers
 ?
+-----------------+
| Netlify |
| (Hugo build) |
+--------+--------+
 |
 | Deploy
 ?
+-----------------+
| Live Site |
| candlegraph |
| .netlify.app |
+-----------------+
```

### What happens at each step

**RStudio (Local):**
- You write in `.Rmd`
- Knitr/blogdown processes R code
- Generates `.html` with evaluated chunks and shortcodes
- Hugo server previews locally

**GitHub (Version Control):**
- Stores both `.Rmd` (source) and `.html` (output)
- Tracks all changes
- Triggers Netlify webhook on push

**Netlify (Build & Deploy):**
- Pulls latest commit from GitHub
- Runs `hugo` command to build site
- Processes layouts, partials, shortcodes
- Serves static files at live URL
- No R processing happens here (already done locally)

### Key insight

**R code runs locally, not on Netlify.** This is why you commit the `.html` file -- it already contains the evaluated R output (charts, inline stats, etc.). Netlify just builds the Hugo site from the pre-processed HTML.

---

## [BEST PRACTICES] Best Practices

### Front matter consistency

Always include:
- `title` (self-explanatory)
- `description` (appears in post previews and meta tags)
- `slug` (URL-friendly, lowercase, hyphens)
- `type` ("review" for data posts, "post" for features)
- `output: blogdown::html_page` (required for Hugo compatibility)

### Chunk naming

Name your R chunks, especially if you have multiple in one post:

````
```{r performance-map}
# Your R code here
```
````

Unnamed chunks can cause knit errors when you have several.

### File organization

Posts go in `content/post/`:

- 2024-01-15-paddywax-apricot-rose.Rmd
- 2024-01-15-paddywax-apricot-rose.html
- 2024-02-01-collection-six-months.Rmd
- 2024-02-01-collection-six-months.html
- etc.

Hugo uses the date in the filename for sorting, so follow the `YYYY-MM-DD-slug` convention.

### When to re-knit

Always re-knit before committing if you've:
- Edited the `.Rmd` (even just fixing a typo)
- Re-run `data_sync.R` (updated data affects inline stats)
- Changed any R code in chunks

The `.html` file timestamp will update, and Git will catch it.

---

## [FUTURE] Future Enhancements

### Potential third snippet (not yet needed)

If you start writing feature posts that reference specific brands or pull from the data -- like "here's how collection efficiency shifted over six months" -- you might want a hybrid snippet:

```
snippet candlehybrid
	---
	title: "${1:Post Title}"
	author: "Terry"
	date: "`r format(Sys.Date(), '%Y-%m-%d')`"
	description: "${2:One-sentence description}"
	slug: "${3:url-slug}"
	type: "post"
	output: blogdown::html_page
	---
	```{r setup, include=FALSE}
	knitr::opts_chunk\$set(echo = FALSE, dev = 'svg', fig.width = 10, fig.height = 8)
	source(here::here("data_sync.R"))
	```
	$0
```

Halfway between feature and review -- sources the data but doesn't call `get_brief()` since it's not brand-focused.

**Wait until you actually need it.** Two snippets are enough for now.

### Automated shortcode updates

If the SAV formula changes again in the future, you could write a script to:
1. Read all `.Rmd` files in `content/post/`
2. Extract brand names from shortcodes
3. Run `get_brief()` for each
4. Update shortcode values via regex
5. Re-knit all affected posts

Not worth building until it's a recurring problem.

### Performance map as dedicated page

Right now the performance map is embedded in every review post as a snapshot of "the collection when this brand was reviewed." If you want one canonical, always-current map, create a file at `content/performance.Rmd` that just loads `data_sync.R` and displays `performance_plot`. Then link to `/performance/` from the nav.

---

## [PITFALLS] Common Pitfalls

### Snippet not expanding

**Symptom:** You type `candlereview` + Shift+Tab and nothing happens 
**Cause:** Snippet body isn't indented with tabs 
**Fix:** Edit snippet, ensure every line after `snippet candlereview` starts with one tab

### Dollar sign not rendering

**Symptom:** `opts_chunk$set` becomes `opts_chunkset` in output 
**Cause:** `$` is a snippet special character 
**Fix:** Use `\$` in the snippet code

### get_brief() returns "Brand not found"

**Symptom:** Console error when knitting 
**Cause:** Brand name doesn't match `brand_name` in Google Sheets (case-sensitive) 
**Fix:** Check spelling and capitalization, verify in `brand_rankings`

### Shortcodes not rendering on live site

**Symptom:** You see literal `{{< brand-specs ... >}}` text instead of the component 
**Cause:** Syntax error in shortcode (missing quote, wrong parameter name, etc.) 
**Fix:** Compare against working example, check Hugo build logs in Netlify

### Changes not appearing on live site

**Symptom:** You pushed to GitHub but site didn't update 
**Cause:** Either didn't commit `.html` file, or Netlify build failed 
**Fix:** Check GitHub Desktop for uncommitted files, check Netlify deploy log

---

## [CHECKLIST] Workflow Checklist

Use this for every review post:

- [ ] Create `.Rmd` with `candlereview` snippet
- [ ] Fill in title, description, slug, brand name
- [ ] Knit to run `get_brief()`
- [ ] Copy/paste both shortcodes from console output
- [ ] Write review prose
- [ ] Knit again to regenerate `.html`
- [ ] Test locally with `hugo server`
- [ ] Verify shortcodes render correctly
- [ ] Check dark mode
- [ ] Stage `.Rmd` and `.html` in GitHub Desktop
- [ ] Commit with clear message
- [ ] Push to GitHub
- [ ] Verify live deploy on Netlify
- [ ] Check live site renders correctly

---

## [FILES] File Manifest

**Snippet definitions:**
- Location: RStudio > Tools > Edit Code Snippets > R tab
- Snippets: `candlereview`, `candlefeature`, `candleplot`

**R Scripts:**
- `data_sync.R` - Data pipeline (sourced by review posts)
- `post_brief.R` - Contains `get_brief()` function (sourced by `data_sync.R`)

**Content directories:**
- `content/post/` - All `.Rmd` and `.html` post files

**Documentation:**
- `CONTENT-WORKFLOW-SUMMARY.md` - This document

---

## [TAKEAWAYS] Key Takeaways

1. **Two snippets cover 95% of use cases:** Reviews (`candlereview`) and features (`candlefeature`)
2. **R runs locally, not on Netlify:** Always commit both `.Rmd` and `.html`
3. **get_brief() is your friend:** Generates accurate shortcodes from live data
4. **Test before pushing:** Local Hugo server catches issues before they go live
5. **Keep it simple:** Only add complexity when you actually need it

---

**End of Document**
