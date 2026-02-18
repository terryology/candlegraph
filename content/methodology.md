---
title: "The Methodology: Inside the Candlegraph Engine"
date: 2026-02-15
draft: false
math: true
description: "A deep dive into the math, normalization, and provenance of the Candlegraph performance index."
---

Most candle reviews are purely anecdotal. **Candlegraph** uses a normalized calibration engine to strip away "size bias" and "luxury markups" to find the true engineering value of a scent.

---

## 1. The Normalization Baseline
To compare a 3oz votive to a 30oz centerpiece fairly, we normalize every data point to a **10oz Standard**. This creates our **Size Factor ($SF$):**

$$SF = \frac{\text{Weight (oz)}}{10}$$

By dividing the output by the Size Factor, we can see how a candle *would* perform if it were a standard 10oz jar.



## 2. The SAV Index (Scent Adjusted Value)
The SAV measures **Scent Density**. It rewards candles that "punch above their weight class" by weighing chemical potential against mechanical output. 

We use a **40/60 Weighted Split**:
* **40% Cold Throw (Static):** The out-of-the-box potential.
* **60% Hot Throw (Active):** The measured performance during a burn.

**The Formula:**
$$SAV = \left( \frac{(\text{Cold Density} \times 0.4) + (\text{Hot Density} \times 0.6)}{\text{Collection Average}} \right) \times 100$$

## 3. The PAE Index (Price/Performance Efficiency)
The PAE measures how much "ambience" your dollar actually buys. It calculates the burn hours achieved per dollar spent, indexed against the market average.

$$PAE = \left( \frac{\text{Hours per Dollar}}{\text{Collection Avg Hours per Dollar}} \right) \times 100$$

---

## 4. Understanding the Quadrants
When we plot **SAV** against **PAE**, four distinct categories of candle engineering emerge:

| Quadrant | Character | Strategy |
| :--- | :--- | :--- |
| **THE GRAILS** | High SAV / High PAE | **The Unicorn.** Elite scent performance and longevity at a fair price. |
| **OVERACHIEVERS** | High SAV / Low PAE | **The Luxury Play.** Elite sensory experience, but you are paying a "luxury tax" for the brand. |
| **WORKHORSES** | Low SAV / High PAE | **The Daily Driver.** Exceptional value. Perfect for consistent, daily background ambience. |
| **THE DUDS** | Low SAV / Low PAE | **Failed Engineering.** Poor scent output and expensive burn time. |



---

## 5. Data Provenance (The Evidence Scale)
In the spirit of technical honesty, we track the **Reliability** of our data. Not all metrics are created equal.

* <span style="color: #2D5A27; font-weight: bold;">● Archival:</span> The Gold Standard. Both Cold and Hot throws were measured and logged in real-time with a stopwatch and rubric.
* <span style="color: #967E5D; font-weight: bold;">● Recovered:</span> Mixed Certainty. One metric was logged; the other was filled in retroactively from memory.
* <span style="color: #D4A373; font-weight: bold;">● Recalled:</span> Anecdotal. The data is based on best-memory reconstruction from before the Engine was live.

---

## 6. Why the "100" Line Moves
These indexes are **Relational**. An index of **100** always represents the current average of the collection. 

As the collection grows and I discover better-engineered candles, the "Average" rises. This forces brands to "compete" for their spot on the map. A "Grail" today must continue to outperform new entries to keep its title.

---

### Current Performance Map
{{< data-vault title="Global Collection Index" >}}
  {{< /data-vault >}}

---
*The Candlegraph Engine is a technically sophisticated system powered by R, pulling live data via JSON to ensure the performance map is always reflective of the most recent burn logs.*