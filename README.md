# LiDAR-based vegetation change after the 2025 Palisades Fire

## Overview

This project investigates changes in vegetation structure following the January 2025 Palisades Fire in Southern California using pre- and post-fire LiDAR data. The analysis focuses on changes in canopy height, vegetation structure, and low-height LiDAR return density between 2023 and 2025.

The workflow combines LiDAR-derived digital surface models (DSM), digital terrain models (DTM), canopy height models (CHM), vegetation change analysis, NOAA land-cover data, and 3D point-cloud visualization in CloudCompare. Sentinel-2 imagery was additionally processed in Google Earth Engine to provide complementary spectral information on vegetation condition.

## Study area

he study area is located in the Santa Monica Mountains in Southern California, within the area affected by the 2025 Palisades Fire.

The region was selected because the fire spread rapidly through the area during the early phase of the incident. On January 8, 2025, extreme fire behavior, including short- and long-range spotting, continued to support further fire spread. The study area includes the Topanga Canyon corridor, which was affected during the fire progression.

The fire progression shown below provides the spatial context for the selected study area.

![Palisades Fire progression](figures/fire_progression_cal_fire_management.webp)

The analysis focuses on a selected area where pre- and post-fire LiDAR data are available, allowing vegetation structure to be compared between 2023 and 2025.

## LiDAR-derived surface and terrain models

Digital surface models (DSM) and digital terrain models (DTM) were generated from the 2023 and 2025 LiDAR point clouds at 1 m spatial resolution.

The DSM represents the elevation of the uppermost surface, while the DTM represents the underlying terrain. Subtracting the DTM from the DSM provides a canopy height model (CHM), representing vegetation height above the ground.

## Canopy height models

The resulting CHMs were used to compare vegetation structure between 2023 and 2025.

![Canopy height comparison](figures/palisades_fires_chm_2023_2025.png)

The figure provides an overview of the study area before and after the fire. The marked location indicates the area selected for the subsequent 3D LiDAR visualization in CloudCompare. This allows the spatial location of the detailed point-cloud examples to be related back to the full study area.

## CHM change

Canopy height change was calculated by subtracting the 2023 CHM from the 2025 CHM:

**CHM change = CHM 2025 − CHM 2023**

![CHM change](figures/palisades_fires_chm_change.png)

Negative values indicate a decrease in vegetation height between the two LiDAR acquisitions, while positive values indicate an increase.

## 3D LiDAR visualization

To provide a closer look at changes in vegetation structure, selected areas were extracted from the LiDAR point clouds and visualized in CloudCompare.

The four visualizations show the same area before and after the fire. The larger views provide spatial context, while the zoomed views focus on a smaller area of pronounced structural change. The zoomed area was additionally outlined using a cylinder to highlight the selected section of the point cloud.

All four visualizations display the LiDAR Z values using the same range from 14.1 to 58 m to allow direct visual comparison between 2023 and 2025.

### 2023

![CloudCompare 2023 overview](figures/cloudcomp_2023_3D.png)

![CloudCompare 2023 zoom](figures/cloudcomp_2023_zoom.png)

### 2025

![CloudCompare 2025 overview](figures/cloudcomp_2025_3D.png)

![CloudCompare 2025 zoom](figures/cloudcomp_2025_zoom.png)

## Vegetation classification and structural loss

A NOAA C-CAP land-cover dataset was used to distinguish between **Upland Tree (Forest)** and **Scrub/Shrub** vegetation.

The following figure shows the NOAA mask used to define these vegetation classes within the LiDAR analysis area.

![NOAA vegetation mask](figures/palisades_fires_noaa_mask.png)

The CHM change data were subsequently summarized separately for forest and shrub areas. Vegetation height loss was grouped into different severity classes based on the magnitude of CHM decrease.

![CHM vegetation loss](figures/palisades_fires_chm_veg_loss_table.png)

The table summarizes the area affected by different levels of structural vegetation loss in the two vegetation classes.

## Understory return density

A complementary analysis focused on low-height LiDAR returns between **0.5 and 2 m above ground**. Unclassified LiDAR returns (Class 1) within this height range were used as a proxy for low-height vegetation structure.

Changes in return density were calculated between 2023 and 2025.

![Understory change](figures/palisades_fires_understory_change_table.png)

The table summarizes areas with decreases, little or no change, and increases in low-height LiDAR return density.

## Sentinel-2 spectral indices

To complement the structural information provided by LiDAR, Sentinel-2 satellite imagery was processed in Google Earth Engine.

Two spectral vegetation indices were calculated:

- **NDVI** – Normalized Difference Vegetation Index
- **NBR** – Normalized Burn Ratio

These indices provide complementary information on vegetation condition and spectral changes associated with the fire.

![Sentinel-2 NDVI](figures/palisades_fires_NDVI.png)

![Sentinel-2 NBR](figures/palisades_fires_NBR.png)

## Limitations

Several factors should be considered when interpreting the results:

- The 2023 and 2025 LiDAR datasets differ in acquisition period and point density.
- CHM differences represent changes in vegetation structure and height, not direct measurements of biomass loss.
- Low-height LiDAR return density is used as a proxy for understory structure and should not be interpreted directly as vegetation biomass or vegetation cover.
- LiDAR return density can be influenced by acquisition conditions and point density.
- The NOAA C-CAP land-cover classification was used to distinguish forest and shrub areas but does not represent vegetation conditions at the time of the fire.

## Software

- R / RStudio
- `lidR`
- `terra`
- `sf`
- `gt`
- CloudCompare
- Google Earth Engine
- QGIS
