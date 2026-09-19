######## CREATE DSMs & DTMs #########

# Only need to run this once to calculate DSMs & DTMs 
# Connect with 01_setup.R
source("01_setup.R")

# Set directory of raster output 
dir.create(file.path(output_dir, "DSMs"), showWarnings = FALSE)
dir.create(file.path(output_dir, "DTMs"), showWarnings = FALSE)

# Remove classes 7,18,20 and keep exact extent of AOI 
opt_filter(ctg_2023) <- paste(
  "-keep_xy 352000 3767368.39 354750 3769500",
  "-drop_class 7 18 20"
)

opt_filter(ctg_2025) <- paste(
  "-keep_xy 352000 3767368.39 354750 3769500",
  "-drop_class 7 18 20"
)

# Calculate DSMs 
dsm_2023 <- rasterize_canopy(
  ctg_2023,
  layout = template,
  algorithm = p2r()
)

dsm_2025 <- rasterize_canopy(
  ctg_2025,
  layout = template,
  algorithm = p2r()
)

# Calculate DTMs
dtm_2023 <- rasterize_terrain(
  ctg_2023,
  layout = template,
  algorithm = tin()
)

dtm_2025 <- rasterize_terrain(
  ctg_2025,
  layout = template,
  algorithm = tin()
)

# Look at min, max and mean 
global(dtm_2023, c("min", "max", "mean"), na.rm = TRUE)
global(dtm_2025, c("min", "max", "mean"), na.rm = TRUE)

# Create histogram of rasters
hist(dtm_2023, breaks = 100, main = "DTM 2023 elevation", xlab = "Elevation (m)")

# Save rasters
writeRaster(dsm_2023, file.path(output_dir, "DSMs", "DSM_2023.tif"), overwrite = TRUE)
writeRaster(dsm_2025, file.path(output_dir, "DSMs", "DSM_2025.tif"), overwrite = TRUE)
writeRaster(dtm_2023, file.path(output_dir, "DTMs", "DTM_2023.tif"), overwrite = TRUE)
writeRaster(dtm_2025, file.path(output_dir, "DTMs", "DTM_2025.tif"), overwrite = TRUE)