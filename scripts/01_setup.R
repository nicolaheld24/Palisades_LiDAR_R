library(lidR)
library(terra)
library(sf)
library(gt)

# Set output directory 
output_dir <- "C:/Users/nicol/Desktop/EAGLE/LiDAR/final_project/rstudio_laz_files_2023_2025"

path_2023 <- file.path(output_dir, "2023")
path_2025 <- file.path(output_dir, "2025")

ctg_2023 <- readLAScatalog(path_2023)
ctg_2025 <- readLAScatalog(path_2025)

dsm_2023 <- rast(file.path(output_dir, "DSMs", "DSM_2023.tif"))
dsm_2025 <- rast(file.path(output_dir, "DSMs", "DSM_2025.tif"))
dtm_2023 <- rast(file.path(output_dir, "DTMs", "DTM_2023.tif"))
dtm_2025 <- rast(file.path(output_dir, "DTMs", "DTM_2025.tif"))

chm_2023_noaa <- rast(file.path(output_dir, "change", "CHM_2023.tif"))
chm_2025_noaa <- rast(file.path(output_dir, "change", "CHM_2025.tif"))
chm_change_veg <- rast(file.path(output_dir, "change", "CHM_change_2025_2023_NOAA.tif"))

# Load understory rasters 
understory_2023 <- rast(file.path(output_dir, "understory_analysis", "Understory_density_2023.tif"))
understory_2025 <- rast(file.path(output_dir, "understory_analysis", "Understory_density_2025.tif"))
understory_change <- rast(file.path(output_dir, "understory_analysis", "Understory_change_2025_2023.tif"))

# Set AOI for both years 
xmin <- 352000
xmax <- 354750
ymin <- 3767368.39
ymax <- 3769500

template <- rast(
  xmin = xmin,
  xmax = xmax,
  ymin = ymin,
  ymax = ymax,
  resolution = 1,
  crs = crs(dtm_2023)
)

opt_filter(ctg_2023) <- paste(
  "-keep_xy 352000 3767368.39 354750 3769500",
  "-drop_class 7 18 20"
)

opt_filter(ctg_2025) <- paste(
  "-keep_xy 352000 3767368.39 354750 3769500",
  "-drop_class 7 18 20"
)

opt_chunk_size(ctg_2023) <- 500
opt_chunk_size(ctg_2025) <- 500

opt_chunk_buffer(ctg_2023) <- 20
opt_chunk_buffer(ctg_2025) <- 20

# Implement NOAA GeoTIFF Land Cover Classification 
noaa <- rast(file.path(output_dir, "NOAA_california_1m", "2021_ccap_v2_canopy_draft_ca_J1452922tR0_C0.tif"))

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









