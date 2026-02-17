# Candlegraph RStudio Snippets - Reference File

This file contains all three Candlegraph snippets in ready-to-paste format.

**To install:**
1. Open RStudio
2. Go to `Tools > Edit Code Snippets`
3. Select the "R" tab
4. Scroll to the bottom
5. Paste these snippets
6. Save and close

**CRITICAL:** Every line after `snippet NAME` must start with exactly ONE tab character (not spaces).

---

## Snippet 1: Brand Review Post

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

---

## Snippet 2: Feature Post

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

---

## Snippet 3: Brand Burn Chart

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

---

## Usage

**candlereview:** Type `candlereview` + Shift+Tab in a new .Rmd file 
**candlefeature:** Type `candlefeature` + Shift+Tab in a new .Rmd file 
**candleplot:** Type `candleplot` + Shift+Tab inside an R chunk

---

## Troubleshooting

**Snippet doesn't expand:**
- Make sure you're in an .Rmd file (not .R)
- Verify every line starts with exactly one tab
- Check for no leading spaces

**Dollar sign missing in output:**
- Use `\$` in the snippet to escape it
- Example: `knitr::opts_chunk\$set`

**get_brief() errors:**
- Brand name must match exactly with Google Sheets
- Check capitalization and spelling
- Verify `data_sync.R` ran successfully

---

**End of Reference**
