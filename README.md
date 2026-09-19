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

See [`02_DSM_DTM.R`](scripts/02_DSM_DTM.R).

### 1.2 Canopy Height Model Calculation 

Canopy Height Models (CHM) were calculated as the difference between the DSM and DTM. 

![Canopy height comparison](figures/palisades_fires_chm_2023_2025.png)

The figure provides an overview of the study area before and after the fire. The marked location indicates the area selected for the subsequent 3D LiDAR visualization in CloudCompare (see 1.3 3D LiDAR visualization). This allows the spatial location of the detailed point-cloud examples to be related back to the full study area.

Canopy height change was calculated by subtracting the 2023 CHM from the 2025 CHM:

**CHM change = CHM 2025 − CHM 2023**

![CHM change](figures/palisades_fires_chm_change.png)

Negative values indicate a decrease in vegetation height between the two LiDAR acquisitions, while positive values indicate an increase.

### 1.3 3D LiDAR Visualization

To provide a closer look at changes in vegetation structure, selected areas were extracted from the LiDAR point clouds and visualized in CloudCompare.

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

The following figure shows the NOAA mask used to define these vegetation classes within the LiDAR analysis area.

![NOAA vegetation mask](figures/palisades_fires_noaa_mask.png)

The CHM change data were subsequently summarized separately for forest and shrub areas. Vegetation height loss was grouped into different severity classes based on the magnitude of CHM decrease.

![CHM vegetation loss](figures/palisades_fires_chm_veg_loss_table.png)

The table summarizes the area affected by different levels of structural vegetation loss in the two vegetation classes.
See [`03_CHM.R`](scripts/03_CHM.R).

## 2. Understory Vegetation Loss 

A complementary analysis focused on low-height LiDAR returns between **0.5 and 2 m above ground**. Unclassified LiDAR returns (Class 1) within this height range were used as a proxy for low-height vegetation structure.

Changes in return density were calculated between 2023 and 2025.

![Understory change](figures/palisades_fires_understory_change_table.png)

The table summarizes areas with decreases, little or no change, and increases in low-height LiDAR return density.
See [`04_understory.R`](scripts/04_understory.R).

### 3. Sentinel-2 Spectral Indices

The LiDAR analysis provides information on changes in vegetation structure following the fire. To complement this structural perspective, Sentinel-2 imagery was used to assess changes in vegetation condition and spectral response over time since Sentinel-2 provides spatially continuous spectral information that can be used to examine vegetation disturbance and subsequent recovery.

The selected scenes from December 2023 to January 2026 were used to calculate NDVI and NBR. The time series provides an additional perspective on the fire impact and allows changes in vegetation condition during the subsequent recovery period to be examined.

Two spectral vegetation indices were calculated:

- **NDVI** – Normalized Difference Vegetation Index
- **NBR** – Normalized Burn Ratio

These indices provide complementary information on vegetation condition and spectral changes associated with the fire.

#### 3.1 NDVI
Normalized Difference Vegetation Index (NDVI) was calculated for selected Sentinel-2 scenes between December 2023 and January 2026 to examine changes in vegetation condition over time.

![Sentinel-2 NDVI](figures/palisades_fires_NDVI.png)

#### 3.2 NBR
Normalized Burn Ratio (NBR) was calculated for the same Sentinel-2 scenes to characterize spectral changes associated with fire disturbance and vegetation recovery.

![Sentinel-2 NBR](figures/palisades_fires_NBR.png)

### 4. Limitations

Several factors should be considered when interpreting the results:

- The 2023 and 2025 LiDAR datasets differ in acquisition period and point density.
- CHM differences represent changes in vegetation height and do not directly measure biomass loss.
- Low-height LiDAR return density is used as a proxy for low-height vegetation structure and does not directly represent biomass or vegetation cover.
- NOAA C-CAP vegetation classes represent land cover from 2021 and therefore do not describe vegetation conditions at the exact time of the fire.
- Sentinel-2 observations are limited to selected cloud-free scenes and provide complementary spectral information rather than direct measurements of vegetation structure.

### 5. Conclusion

The combination of LiDAR and Sentinel-2 data provides complementary information on vegetation change following the 2025 Palisades Fire. LiDAR data were used to quantify structural changes in canopy height and low-height vegetation, while Sentinel-2 NDVI and NBR provided additional information on vegetation disturbance and subsequent recovery.
