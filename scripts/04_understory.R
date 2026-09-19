######### UNDERSTORY ANALYSIS #########

# Connect to 01_setup.R
source("01_setup.R")

# Define understory minimum & maximum threshold for analysis 
understory_min <- 0.5
understory_max <- 2

process_understory <- function(ctg, dtm, output) {
  result <- catalog_apply(
    ctg,
    function(cluster) {
      
      # Read the current point cloud chunk and exclude withheld points 
      las <- readLAS(
        cluster,
        filter = "-drop_withheld"
      )
      
      # Skip empty chunks 
      if (is.empty(las)) return
      
      # Extract DTM elevation for each LiDAR point 
      z_dtm <- terra::extract(
        dtm,
        las@data[, c("X", "Y")]
      )[, 2]
      
      # Skip chunks where no valid DTM elevation is available 
      if (length(z_dtm) != nrow(las@data)) return(NULL)
      
      # Calculate normalized height above ground 
      las@data$Z_norm <- las$Z - z_dtm
      
      # Select Class 1 returns between 0.5 and 2 m above ground
      keep <- las@data$Classification == 1 &
        !is.na(las@data$Z_norm) &
        las@data$Z_norm >= understory_min &
        las@data$Z_norm < understory_max
      
      las <- las[keep]
      
      # Skip chunks without valid understory returns 
      if (is.empty(las)) return(NULL)
      
      # Calculate understory return density at 1m resolution 
      rasterize_density(las, res = 1)
    },
    .options = list(automerge = TRUE)
  )
  
  # Align the result with the common 1m analysis grid (template) 
  result <- project(result, template, method = "near")
  result <- crop(result, template)
  
  # Save final understory density raster 
  writeRaster(result, output, overwrite = TRUE)
  
  result
}

# Calculate understory tif rasters
understory_2023 <- process_understory(
  ctg_2023,
  dtm_2023,
  file.path(output_dir, "understory_analysis", "Understory_density_2023.tif")
)

understory_2025 <- process_understory(
  ctg_2025,
  dtm_2025,
  file.path(output_dir, "understory_analysis", "Understory_density_2025.tif")
)

# Check understory density statistics
# Understory of 2023 
global(understory_2023, c("min", "max", "mean"), na.rm = TRUE)

global(
  understory_2023,
  quantile,
  probs = c(0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99),
  na.rm = TRUE
)

# Visualize understory density 
# Only keep range between 0 to 30 because of quantile distribution  
plot(understory_2023, range = c(0, 30))
plot(understory_2025, range = c(0, 30))

# Apply NOAA vegetation mask 
understory_2023_veg <- mask(understory_2023, veg_mask)
understory_2025_veg <- mask(understory_2025, veg_mask)

# Check if both rasters have same geometry 
compareGeom(understory_2023_veg, understory_2025_veg)

# Calculate understory change between 2023 and 2025
understory_change <- understory_2025_veg - understory_2023_veg

# Save Understory Change raster 
writeRaster(
  understory_change,
  file.path(output_dir, "change", "Understory_change_2025_2023.tif"),
  overwrite = TRUE
)

# STATISTICS 

# Calculate mean understory return density for each year
global(understory_2023_veg, "mean", na.rm = TRUE)
global(understory_2025_veg, "mean", na.rm = TRUE)

# Extract all valid understory change values 
change_values <- values(understory_change, mat = FALSE)
change_values <- change_values[!is.na(change_values)]

# Calculate distribution of understory change
quantile(
  change_values,
  c(0, 0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99, 1)
)

# Classify understory change into three categories
# < -2       = Decrease
# -2 to +2   = Little/no change
# > +2       = Increase
understory_change_class <- ifel(
  understory_change < -2,
  1,
  ifel(
    understory_change <= 2,
    2,
    3
  )
)

# Extract valid change classes
class_values <- values(understory_change_class, mat = FALSE)
class_values <- class_values[!is.na(class_values)]

# Count pixels in each change category
class_table <- as.data.frame(
  table(factor(class_values, levels = 1:3))
)

names(class_table) <- c("Class", "Pixels")

# Add descriptive labels
class_table$Change <- c(
  "Decrease (< -2)",
  "Little/no change (-2 to +2)",
  "Increase (> +2)"
)

# Calculate percentage and area
class_table$Percent <- round(
  class_table$Pixels / sum(class_table$Pixels) * 100,
  2
)

class_table$Area_ha <- round(
  class_table$Pixels / 10000,
  2
)

# Keep relevant columns
class_table <- class_table[, c(
  "Change",
  "Pixels",
  "Area_ha",
  "Percent"
)]

class_table

# Visualize understory change 
plot(understory_change, range = c(-30, 10))

# Mask understory change by NOAA land-cover class 
# Class 1 = Tree/Forest 
# Class 2 = Scrub/Shrub
tree_change <- mask(
  understory_change,
  noaa_aligned == 1,
  maskvalues = FALSE
)

scrub_change <- mask(
  understory_change,
  noaa_aligned == 2,
  maskvalues = FALSE
)

# Exctract valid change values for Tree/Forest 
tree_values <- values(tree_change, mat = FALSE)
tree_values <- tree_values[!is.na(tree_values)]

# Extract valid change values for Scrub/Shrub
scrub_values <- values(scrub_change, mat = FALSE)
scrub_values <- scrub_values[!is.na(scrub_values)]

# Calculate mean & median understory change by land-cover class 
change_by_class <- data.frame(
  Land_cover = c("Tree/Forest", "Scrub/Shrub"),
  Mean_change = c(mean(tree_values), mean(scrub_values)),
  Median_change = c(median(tree_values), median(scrub_values)),
  Pixels = c(length(tree_values), length(scrub_values))
)

change_by_class

###### STATISTICS TABLE ######

# Create table
table_understory_change <- class_table |>
  dplyr::select(
    Change,
    Pixels,
    Area_ha,
    Percent
  ) |>
  gt() |>
  cols_label(
    Change = "Understory change",
    Pixels = "Pixels",
    Area_ha = "Area (ha)",
    Percent = "Area (%)"
  ) |>
  fmt_number(
    columns = Pixels,
    decimals = 0
  ) |>
  fmt_number(
    columns = Area_ha,
    decimals = 1
  ) |>
  fmt_number(
    columns = Percent,
    decimals = 1,
    suffix = "%"
  ) |>
  tab_header(
    title = "Understory return density change",
    subtitle = "LiDAR-derived Class 1 returns between 0.5 and 2 m above ground · 2023–2025"
  ) |>
  tab_source_note(
    source_note = "Class 1 = unclassified LiDAR returns. Decrease: < -2 returns/m²; little/no change: -2 to +2 returns/m²; increase: > +2 returns/m²."
  ) |>
  data_color(
    columns = Percent,
    palette = c("#8AB17D", "#FFF8E1", "#E76F3C")
  ) |> 
  tab_options(
    table.font.names = "Georgia"
  )
  
table_understory_change

gtsave(
  table_understory_change,
  file.path(output_dir, "github_post", "Understory_change_table.png")
)






