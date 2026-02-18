# Candlegraph

A data-driven candle review site that calculates objective performance indexes to evaluate scented candles based on empirical burn data.

**Live Site:** [candlegraph.netlify.app](https://candlegraph.netlify.app/)

---

## What Is Candlegraph?

Candlegraph is a personal project that applies quantitative analysis to the subjective world of scented candles. Rather than relying solely on impressions, Candlegraph tracks burn times, efficiency, and scent performance across multiple brands to generate objective rankings.

Every candle is evaluated on two key metrics:

- **PAE (Performance-to-Acquisition Efficiency):** How many hours of burn time you get per dollar spent
- **SAV (Scent-to-Acquisition Value):** How the candle's scent performance compares to the collection average

These indexes are calculated from real burn sessions logged in Google Sheets, processed through an R data pipeline, and visualized on a Hugo-based static site.

---

## Why This Exists

Candles are expensive, and marketing doesn't always match performance. Candlegraph brings transparency to candle reviews by:

- **Tracking actual burn times** (not estimated)
- **Measuring efficiency** (hours per dollar)
- **Recording scent performance** at multiple life stages
- **Calculating relative value** across brands
- **Showing the data** behind every review

---

## How It Works

```
Google Sheets → R (data pipeline) → Hugo (static site) → Netlify (hosting)
```

1. **Data Collection:** Burn sessions logged in Google Sheets with timestamps, temperatures, and scent evaluations
2. **Processing:** R scripts calculate performance indexes, generate visualizations, and export data
3. **Publishing:** Hugo builds the static site with embedded charts and data vault components
4. **Deployment:** Netlify automatically deploys on Git push

---

## Tech Stack

**Frontend:**
- Hugo (Static Site Generator)
- Lithium Theme (customized)
- Custom CSS with dark mode support

**Backend/Data:**
- R + tidyverse (data processing)
- ggplot2 (visualizations)
- Google Sheets API (data source)

**Infrastructure:**
- GitHub (version control)
- Netlify (hosting & CI/CD)
- RStudio + blogdown (content creation)

---

## Key Features

- **Performance Map:** Visual scatter plot showing all brands by efficiency vs scent value
- **Brand Rankings:** Sortable table with PAE and SAV indexes
- **Data Vault Components:** Embedded data visualizations in each review
- **Methodology Transparency:** Full explanation of how indexes are calculated
- **Dark Mode:** Automatic theme switching
- **Responsive Design:** Mobile-friendly layouts

---

## Project Structure

```
candlegraph/
├── content/          # Blog posts and pages (.Rmarkdown files)
├── layouts/          # Hugo templates and partials
├── static/           # CSS, images, exported charts
├── docs/             # Project documentation (see docs/README.md)
├── data_sync.R       # Main data pipeline script
├── post_brief.R      # Helper function for generating review shortcodes
└── config.yaml       # Hugo site configuration
```

---

## Development

This is a personal project, but if you're curious about the technical implementation:

1. **Documentation:** See `/docs/README.md` for complete technical documentation
2. **Content Creation:** Uses RStudio snippets + blogdown workflow
3. **Data Pipeline:** R scripts pull from Google Sheets, calculate indexes, generate plots
4. **Deployment:** Automatic via Netlify on push to main branch

---

## Data Methodology

### PAE (Performance-to-Acquisition Efficiency)

```
PAE = (Total Burn Hours / Purchase Price) / Collection Average × 100
```

A PAE of 100 means average efficiency. Higher is better (more hours per dollar).

### SAV (Scent-to-Acquisition Value)

```
SAV = (Weighted Scent Score / Collection Average) × 100
```

Weighted Scent = (40% Cold Throw) + (60% Hot Throw)

A SAV of 100 means average scent performance. Higher is better.

### Confidence Tax

Brands with fewer than 3 candles receive a 20% penalty on both indexes to account for limited sample size.

---

## Roadmap

**Completed:**
- ✅ Data pipeline and index calculations
- ✅ Hugo site with custom styling
- ✅ Performance visualization
- ✅ Dark mode support
- ✅ Responsive design
- ✅ Content workflow with blogdown

**In Progress:**
- 🔄 Filling historical burn data
- 🔄 Writing brand reviews
- 🔄 Building out the collection

**Future:**
- 📋 Custom domain
- 📋 Advanced filtering/sorting
- 📋 Seasonal analysis
- 📋 Brand comparison tools

---

## About

Candlegraph is maintained by [Terry](https://terryology.com) as part of a broader personal data tracking ecosystem. It's a experiment in bringing quantitative rigor to everyday consumer decisions.

**Related Projects:**
- [Terryology](https://terryology.com) - Personal hub site

---

## License

This project is personal/portfolio work. The code and methodology are documented for transparency and educational purposes.

---

## Contact

Questions about the methodology or implementation? Feel free to reach out via [your contact method].

---

**Last Updated:** February 2026
