# LiDAR-based vegetation change after the 2025 Palisades Fire
## Overview

This project investigates changes in vegetation structure following the January 2025 Palisades Fire in Southern California using pre- and post-fire LiDAR data. The analysis focuses on changes in canopy height, vegetation structure, and low-height LiDAR return density between 2023 and 2025.

The workflow combines LiDAR-derived digital surface models (DSM), digital terrain models (DTM), canopy height models (CHM), vegetation change analysis, NOAA land-cover data, and 3D point-cloud visualization in CloudCompare. Sentinel-2 imagery was additionally processed in Google Earth Engine to provide complementary spectral information on vegetation condition.

## Research Questions

This project addresses the following research questions:

1. How much canopy height was lost following the 2025 Palisades Fire, and how did this loss differ between Upland Tree and Scrub/Shrub areas?

2. How did low-height vegetation structure change between the pre-fire and post-fire LiDAR acquisitions?

3. How did vegetation condition change following the fire, and is subsequent vegetation recovery visible in the Sentinel-2 time series?

## Data Sources

The analysis combines airborne LiDAR data, NOAA vegetation classification, Sentinel-2 satellite imagery, and fire progression data to assess vegetation structure and change following the 2025 Palisades Fire in Southern California.

| Data Type | Source/Dataset | Period/Version | Notes |
|------------|------------|------------|--------------|
| LiDAR | USGS `CA_LosAngeles_1_B23` | 2023 | Pre-fire airborne LiDAR |
| LiDAR | USGS `CA_2025LosAngelesPostWildfire_C25` | 2025 | Post-fire airborne LiDAR |
| Vegetation Classification | NOAA C-CAP | 2021 | Upland Tree and Scrub/Shrub classes |
| Satellite Imagery | Sentinel-2 SR Harmonized | 2023–2026 | NDVI and NBR |

## Study area

The study area is located in the Santa Monica Mountains in Southern California, within the area affected by the 2025 Palisades Fire.

The region was selected because the fire spread rapidly through the area during the early phase of the incident. On January 8, 2025, extreme fire behavior, including short- and long-range spotting, continued to support further fire spread. The study area includes the Topanga Canyon corridor, which was affected during the fire progression.

The fire progression shown below provides the spatial context for the selected study area.

![Palisades Fire progression](figures/fire_progression_cal_fire_management.webp)

The analysis focuses on a selected area where pre- and post-fire LiDAR data are available, allowing vegetation structure to be compared between 2023 and 2025.

## Workflow
- [1. Canopy Height Loss after the Palisades Fire](#1-canopy-height-loss-after-the-palisades-fire)
  - [1.1 DSM and DTM Calculation](#11-dsm-and-dtm-calculation)
  - [1.2 Canopy Height Model Calculation](#12-canopy-height-model-calculation)
  - [1.3 LiDAR 3D Visualization](#13-lidar-3d-visualization)
  - [1.4 Vegetation Classes and Canopy Height Loss](#14-vegetation-classes-and-canopy-height-loss)
- [2. Understory Vegetation Loss](#2-understory-vegetation-loss)
- [3. Sentinel-2 Spectral Indices](#3-sentinel-2-spectral-indices)
  - [3.1 NDVI](#31-ndvi)
  - [3.2 NBR](#32-nbr)
- [4. Limitations](#4-limitations)
- [5. Conclusion](#5-conclusion)

## 1. Canopy Height Loss after the Palisades Fire
### 1.1 DSM and DTM Calculation

Digital Surface Models (DSM) and Digital Terrain Models (DTM) were generated from the 2023 and 2025 LiDAR point clouds at 1 m spatial resolution.

```r
# Calculate DSMs 
dsm_2023 <- rasterize_canopy(ctg_2023, layout = template, algorithm = p2r())
dsm_2025 <- rasterize_canopy(ctg_2025, layout = template, algorithm = p2r())

# Calculate DTMs 
dtm_2023 <- rasterize_terrain(ctg_2023, layout = template, algorithm = tin())
dtm_2025 <- rasterize_terrain(ctg_2025, layout = template, algorithm = tin())
```

(See [`02_DSM_DTM.R`](scripts/02_DSM_DTM.R)).

### 1.2 Canopy Height Model Calculation 

Canopy Height Models (CHM) were calculated as the difference between the DSM and DTM. 

```r
# Resample DSMs & DTMs 
dsm_2023 <- resample(dsm_2023, dtm_2023, method = "bilinear")
dsm_2025 <- resample(dsm_2025, dtm_2025, method = "bilinear")

# Calculate CHMs for both years 
chm_2023 <- dsm_2023 - dtm_2023
chm_2025 <- dsm_2025 - dtm_2025

# Mask with NOAA vegetation mask 
chm_2023_noaa <- mask(chm_2023, veg_mask)
chm_2025_noaa <- mask(chm_2025, veg_mask)
```

![Canopy height comparison](figures/palisades_fires_chm_2023_2025.png)

The figure provides an overview of the study area before and after the fire. The marked location indicates the area selected for the subsequent 3D LiDAR visualization in CloudCompare (see 1.3 3D LiDAR visualization). This allows the spatial location of the detailed point-cloud examples to be related back to the full study area.

Canopy height change was calculated by subtracting the 2023 CHM from the 2025 CHM:

```r
# Create change CHM between 2023 and 2025
chm_change_veg <- chm_2025_noaa - chm_2023_noaa
```

![CHM change](figures/palisades_fires_chm_change.png)

Negative values indicate a decrease in vegetation height between the two LiDAR acquisitions, while positive values indicate an increase.

### 1.3 LiDAR 3D Visualization

To provide a closer look at changes in vegetation structure, selected areas were extracted from the LiDAR point clouds using R and visualized in CloudCompare.

```r
# Define a small area for 3D visualization
cc_ext <- ext(354250, 354450, 3768390, 3768590)

# Clip LiDAR point clouds for CloudCompare
las_2023_cc <- clip_rectangle(ctg_2023, 354250, 3768390, 354450, 3768590)
las_2025_cc <- clip_rectangle(ctg_2025, 354250, 3768390, 354450, 3768590)
```

The four visualizations show the same area before and after the fire. The larger views provide spatial context, while the zoomed views focus on a smaller area of pronounced structural change. The zoomed area was additionally outlined using a cylinder to highlight the selected section of the point cloud.

All four visualizations display the LiDAR Z values using the same range from 14.1 to 58 m to allow direct visual comparison between 2023 and 2025.

#### 2023

![CloudCompare 2023 overview](figures/cloudcomp_2023_3D.png)

![CloudCompare 2023 zoom](figures/cloudcomp_2023_zoom.png)

#### 2025

![CloudCompare 2025 overview](figures/cloudcomp_2025_3D.png)

![CloudCompare 2025 zoom](figures/cloudcomp_2025_zoom.png)

### 1.4 Vegetation Classes and Canopy Height Loss 

A NOAA C-CAP land-cover dataset was used to distinguish between **Upland Tree (Forest)** and **Scrub/Shrub** vegetation. Canopy height loss was compared between these vegetation classes.


```r
# Align NOAA land cover raster to LiDAR template
noaa_aligned <- project(
  noaa,
  template,
  method = "near"
)

# Vegetation mask
# class 1 = trees (forest)
# class 2 = shrubs
veg_mask <- ifel(
  noaa_aligned == 1 | noaa_aligned == 2,
  1,
  NA
)
```

The following figure shows the NOAA mask used to define these vegetation classes within the LiDAR analysis area.

![NOAA vegetation mask](figures/palisades_fires_noaa_mask.png)

The CHM change data were subsequently summarized separately for forest and shrub areas. Vegetation height loss was grouped into different severity classes based on the magnitude of CHM decrease.

```r
# Separate CHM change by vegetation class
tree_mask <- ifel(noaa_aligned == 1, 1, NA)
scrub_mask <- ifel(noaa_aligned == 2, 1, NA)

chm_change_tree <- mask(chm_change_clean, tree_mask)
chm_change_scrub <- mask(chm_change_clean, scrub_mask)

# Calculate pixels by CHM loss severity
tree_pixels <- c(
  sum(values_tree < -1 & values_tree >= -2),
  sum(values_tree < -2 & values_tree >= -5),
  sum(values_tree < -5)
)

scrub_pixels <- c(
  sum(values_scrub < -1 & values_scrub >= -2),
  sum(values_scrub < -2 & values_scrub >= -5),
  sum(values_scrub < -5)
)

# Convert pixel counts to area and percentage
area_table <- data.frame(
  CHM_decrease = c("-1 to -2 m", "< -2 to -5 m", "< -5 m"),
  Tree_ha = tree_pixels / 10000,
  Tree_percent = tree_pixels / tree_loss_total * 100,
  Scrub_ha = scrub_pixels / 10000,
  Scrub_percent = scrub_pixels / scrub_loss_total * 100
)
```

![CHM vegetation loss](figures/palisades_fires_chm_veg_loss_table.png)

The table summarizes the area affected by different levels of structural vegetation loss in the two vegetation classes.

(See [`03_CHM.R`](scripts/03_CHM.R)).

## 2. Understory Vegetation Loss 

A complementary analysis focused on low-height LiDAR returns between **0.5 and 2 m above ground**. Unclassified LiDAR returns (Class 1) within this height range were used as a proxy for low-height vegetation structure.

```r
# Define understory minimum & maximum threshold
understory_min <- 0.5
understory_max <- 2

# Select Class 1 returns between 0.5 and 2 m above ground
keep <- las@data$Classification == 1 &
  !is.na(las@data$Z_norm) &
  las@data$Z_norm >= understory_min &
  las@data$Z_norm < understory_max

las <- las[keep]

# Calculate understory return density at 1 m resolution
rasterize_density(las, res = 1)

# Apply NOAA vegetation mask
understory_2023_veg <- mask(understory_2023, veg_mask)
understory_2025_veg <- mask(understory_2025, veg_mask)

# Calculate understory change between 2023 and 2025
understory_change <- understory_2025_veg - understory_2023_veg

# 1 = Decrease (< -2 returns/m²)
# 2 = Little/no change (-2 to +2 returns/m²)
# 3 = Increase (> +2 returns/m²)
understory_change_class <- ifel(
  understory_change < -2, 1,
  ifel(understory_change <= 2, 2, 3)
)
```

Changes in return density were calculated between 2023 and 2025.

![Understory change](figures/palisades_fires_understory_change_table.png)

The table summarizes areas with decreases, little or no change, and increases in low-height LiDAR return density.
(See [`04_understory.R`](scripts/04_understory.R)).

## 3. Sentinel-2 Spectral Indices

The LiDAR analysis provides information on changes in vegetation structure following the fire. To complement this structural perspective, Sentinel-2 imagery was used to assess changes in vegetation condition and spectral response over time since Sentinel-2 provides spatially continuous spectral information that can be used to examine vegetation disturbance and subsequent recovery.

The selected scenes from December 2023 to January 2026 were used to calculate NDVI and NBR. The time series provides an additional perspective on the fire impact and allows changes in vegetation condition during the subsequent recovery period to be examined.

Two spectral vegetation indices were calculated:

- **NDVI** – Normalized Difference Vegetation Index
- **NBR** – Normalized Burn Ratio

These indices provide complementary information on vegetation condition and spectral changes associated with the fire.

### 3.1 NDVI
Normalized Difference Vegetation Index (NDVI) was calculated for selected Sentinel-2 scenes between December 2023 and January 2026 to examine changes in vegetation condition over time.

![Sentinel-2 NDVI](figures/palisades_fires_NDVI.png)

### 3.2 NBR
Normalized Burn Ratio (NBR) was calculated for the same Sentinel-2 scenes to characterize spectral changes associated with fire disturbance and vegetation recovery.

![Sentinel-2 NBR](figures/palisades_fires_NBR.png)

### 4. Limitations

Several factors should be considered when interpreting the results:
Several factors should be considered when interpreting the results:

- The 2023 and 2025 LiDAR datasets differ in acquisition period and point density. The 2023 dataset has a point density of 27.8 points/m², compared with 31.5 points/m² in 2025.
- CHM differences represent changes in vegetation height and do not directly measure biomass loss.
- Low-height LiDAR return density is used as a proxy for low-height vegetation structure and does not directly represent biomass or vegetation cover.
- NOAA C-CAP vegetation classes represent land cover from 2021 and therefore do not describe vegetation conditions at the exact time of the fire.
- Airborne LiDAR data are generally available at much lower temporal frequency than satellite imagery. In this study, the most recent available pre-fire LiDAR acquisition for the study area was from December 2023, more than one year before the January 2025 fire. This limits the ability to capture vegetation conditions immediately before the fire and can reduce the timeliness of LiDAR-based analyses for future fire events.
- Sentinel-2 observations are limited to selected cloud-free scenes and provide complementary spectral information rather than direct measurements of vegetation structure.

### 5. Conclusion

The results show that airborne LiDAR can be effectively used to quantify and visualize changes in vegetation structure following a wildfire. The comparison of pre-fire and post-fire LiDAR data allowed canopy height loss and changes in low-height vegetation structure to be mapped at a very high spatial resolution.

A major advantage of LiDAR for post-fire vegetation assessment is its ability to acquire data independently of cloud cover. This can be particularly useful in the immediate aftermath of a wildfire, when optical satellite imagery such as Sentinel-2 may be limited by clouds. In addition, the 0.5 m spatial resolution of the LiDAR data allows changes in vegetation structure to be captured at a much finer scale than medium-resolution satellite imagery.

Sentinel-2 complemented the LiDAR analysis by providing spectral information on vegetation condition and its changes over time. Together, the two data sources provide complementary information: LiDAR captures changes in vegetation structure, while Sentinel-2 provides information on spectral vegetation response and subsequent recovery.


