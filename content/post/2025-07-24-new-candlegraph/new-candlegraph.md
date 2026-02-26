---
title: "Playing with R: My First Data Visualizations"
author: "Terry"
date: "2025-07-24"
tags: ["technical", "r", "data-visualization"]
output: html_document
---



First, we'll load in our libraries. I'm using `library(here)` on the advice of Jenny Bryan from her [Project-oriented workflow](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/) post on Tidyverse. This is just to organize my project into a folder in order to keep it self-contained and portable.


``` r
# loading libraries
library(readr)
library(dplyr)
library(tidyverse)
library(here)
```

Next, we'll load in the data. This comes from 4 tabs of a Google Sheets file on which I've recorded my candle research. Variables include things such as the price and weight of a candle, as well as how long it burned.


``` r
# loading data
brands <- read_csv("brands.csv")
burn_times <- read_csv("burn_times.csv")
materials <- read_csv("materials.csv")
purchases <- read_csv("purchases.csv")
```

Now that we've got our data, let's do something with it! Using the %\>% pipe character from the `dplyr` library, let's find the mean time that I let each candle burn for during a session.


``` r
mean_session_times <- burn_times %>%
  group_by(candle_id) %>%
  summarize(mean = mean(session_time))
mean_session_times
```

```
## # A tibble: 12 × 2
##    candle_id  mean
##        <dbl> <dbl>
##  1         1  3   
##  2         2  3.49
##  3         3  2.96
##  4         4  2.18
##  5         5  3.47
##  6         6  3.39
##  7         7  4.09
##  8         8  4.09
##  9         9  4.74
## 10        10  4.79
## 11        11  5.38
## 12        12  3.16
```

Interestingly, it seems that the amount of time I let a candle burn for during each session trended upward over time, though it didn't always increase from one candle to the next. Let's use a bar graph to visualize the data. I'm using the `ggplot2` library to create the visual.


``` r
viz <- ggplot(mean_session_times,aes(fill=as.factor(candle_id),x=candle_id,y=mean)) + geom_bar(stat = "identity", ,col="brown")
viz + labs(title="Average Session Times",subtitle="Data from Candlegraph",caption="The graph shows that I became less careful about keeping burn times down as time went on.",x="Candle ID",y="Hours",fill="Candle ID")
```

<img src="/post/2025-07-24-new-candlegraph/new-candlegraph_files/figure-html/unnamed-chunk-4-1.png" width="672" />

While the above graph is a good start, it doesn't tell us the candle names, just their IDs. This is because `burn_times.csv` and the `burn_times` data frame that was created from it do not have those names listed. But our `purchases` data frame does. Both frames contain the common column `candle_id`, which allows us to associate the `candle_id` with the candle name (`scent_name`) using an inner join.


``` r
scents <- burn_times %>%
  inner_join(purchases)
```

```
## Joining with `by = join_by(candle_id)`
```

``` r
scents
```

```
## # A tibble: 168 × 16
##    candle_id start_time     stop_time session_time start_temp stop_temp start_rh
##        <dbl> <chr>          <chr>            <dbl>      <dbl>     <dbl>    <dbl>
##  1         1 2022-02-20 12… 2022-02-…          3         70.5      74.1     42.8
##  2         1 2022-02-21 12… 2022-02-…          3         75.5      82       50.4
##  3         1 2022-02-22 20… 2022-02-…          3         73.1      76.8     45.1
##  4         1 2022-02-23 21… 2022-02-…          2.4       67.2      68       37.2
##  5         1 2022-02-24 20… 2022-02-…          3.3       67.8      68.5     36  
##  6         1 2022-02-28 11… 2022-02-…          2.8       66.6      75.4     36.1
##  7         1 2022-03-03 21… 2022-03-…          3.1       76.3      81.9     41  
##  8         1 2022-03-07 20… 2022-03-…          3.2       73.3      77.1     41.3
##  9         1 2022-03-11 20… 2022-03-…          3.2       68.2      74.5     39.7
## 10         1 2022-03-15 20… 2022-03-…          3.2       75.3      82.7     41.4
## # ℹ 158 more rows
## # ℹ 9 more variables: stop_rh <dbl>, start_dp <dbl>, stop_dp <dbl>,
## #   session_id <dbl>, brand_id <dbl>, brand_name <chr>, scent_name <chr>,
## #   price_usd <dbl>, weight_oz <dbl>
```

Now we have the ID of the candle and its associated name (listed as `scent_name`) in our data frame. For our purposes, we only need the `candle_id`, `session_time`, and `scent_name columns`, so let's update `scents` to include only those three column names, using the `select` function.


``` r
scents <- scents %>%
  select(candle_id,session_time,scent_name)
scents
```

```
## # A tibble: 168 × 3
##    candle_id session_time scent_name
##        <dbl>        <dbl> <chr>     
##  1         1          3   Slow Burn 
##  2         1          3   Slow Burn 
##  3         1          3   Slow Burn 
##  4         1          2.4 Slow Burn 
##  5         1          3.3 Slow Burn 
##  6         1          2.8 Slow Burn 
##  7         1          3.1 Slow Burn 
##  8         1          3.2 Slow Burn 
##  9         1          3.2 Slow Burn 
## 10         1          3.2 Slow Burn 
## # ℹ 158 more rows
```

Now that we have the `session_time` linked to the `scent_name`, we can find the average (mean) time per session for each scent.


``` r
mean_session_times <- scents %>%
  group_by(candle_id) %>%
  mutate(mean = mean(session_time)) %>%
  slice(1)
mean_session_times
```

```
## # A tibble: 12 × 4
## # Groups:   candle_id [12]
##    candle_id session_time scent_name                  mean
##        <dbl>        <dbl> <chr>                      <dbl>
##  1         1          3   Slow Burn                   3   
##  2         2          4.4 Mentheverte                 3.49
##  3         3          2.3 Cozy Cabin                  2.96
##  4         4          2   Edition 02 - Shiso          2.18
##  5         5          4.8 Small Fires                 3.47
##  6         6          3   Tobacco Toscano             3.39
##  7         7          4.1 34 Boulevard Saint-Germain  4.09
##  8         8          4.3 30 Montaigne                4.09
##  9         9          4   Goji Tarocco Orange         4.74
## 10        10          4   No. 12 Hacienda             4.79
## 11        11          4   Sandalwood Rose             5.38
## 12        12          3.6 Ash                         3.16
```

That seems a little more readable. Let's use this new variable to create a bar chart similar to the one above. Note that I'm removing the text for the scent names on the x-axis, as it got a little crowded. Instead, we can use the legend on the right to tell us which bar represents which candle.


``` r
viz <- ggplot(mean_session_times,aes(fill=scent_name,x=scent_name,y=mean)) + geom_bar(stat = "identity", ,col="brown") + theme(axis.text.x = element_blank())
viz + labs(title="Average Session Times",subtitle="Data from Candlegraph",x="Scent Name",y="Hours",fill="Scent Name")
```

<img src="/post/2025-07-24-new-candlegraph/new-candlegraph_files/figure-html/unnamed-chunk-8-1.png" width="672" />

That's much better! However, because we are labeling by the `scent_name` rather than the `candle_id`, the list is now in alphabetical instead of numerical order. To preserve the numerical order, we can use the `dplyr` library. (I discovered this trick from [Reorder a variable with ggplot2](https://r-graph-gallery.com/267-reorder-a-variable-in-ggplot2.html).)


``` r
viz <- mean_session_times %>%
  arrange(mean) %>%
  mutate(scent_name=factor(scent_name,levels=scent_name)) %>%
  ggplot(aes(fill=scent_name,x=scent_name,y=mean)) + geom_bar(stat = "identity", ,col="brown") + theme(axis.text.x = element_blank())
viz + labs(title="Average Session Times",subtitle="Data from Candlegraph",x="Scent Name",y="Hours",fill="Scent Name")
```

<img src="/post/2025-07-24-new-candlegraph/new-candlegraph_files/figure-html/unnamed-chunk-9-1.png" width="672" />

Now the mean burn time for each session is listed in order of `candle_id`, and you can easily see the progession.

Thanks for reading!
