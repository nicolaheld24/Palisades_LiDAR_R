######## CREATE CHMs #########

# Connect with 01_setup.R
source("01_setup.R")

# Resample DSMs & DTMs 
# regrid so that DSM and DTM have same raster grid
dsm_2023 <- resample(dsm_2023, dtm_2023, method = "bilinear")
dsm_2025 <- resample(dsm_2025, dtm_2025, method = "bilinear")

# Calculate CHMs for both years 
chm_2023 <- dsm_2023 - dtm_2023
chm_2025 <- dsm_2025 - dtm_2025

# Resample CHMs 
chm_2023 <- resample(chm_2023, template, method = "bilinear")
chm_2025 <- resample(chm_2025, template, method = "bilinear")

# Mask out only vegetation 
chm_2023_noaa <- mask(chm_2023, veg_mask)
chm_2025_noaa <- mask(chm_2025, veg_mask)

# Create change CHM between 2023 & 2025
chm_change_veg <- chm_2025_noaa - chm_2023_noaa

# Check whether chm_2023 & chm_2025 have same geometry
compareGeom(chm_2023_noaa, chm_2025_noaa)

plot(chm_change_veg)

# Save CHMs 
writeRaster(chm_2023_noaa, file.path(output_dir, "change", "CHM_2023.tif"), overwrite = TRUE)
writeRaster(chm_2025_noaa, file.path(output_dir, "change", "CHM_2025.tif"), overwrite = TRUE)
writeRaster(chm_change_veg, file.path(output_dir, "change", "CHM_change_2025_2023_NOAA.tif"), overwrite = TRUE)


############# CREATE STATISTICS TABLE #################
global(chm_2023_noaa, quantile,
       probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
       na.rm = TRUE)

global(chm_2025_noaa, quantile,
       probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
       na.rm = TRUE)

# vegetation mask with noaa_aligned.tif
# take veg_mask from 01_setup.R
# class 1 = Forest (Tree)
# class 2 = Shrub

# Distribution of min, max, mean for Change Veg CHM 
global(chm_change_veg, c("min", "max", "mean"), na.rm = TRUE)

# Look at quantiles 
global(
  chm_change_veg,
  quantile,
  probs = c(0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99),
  na.rm = TRUE
)

# Remove extreme CHM change values
chm_change_clean <- ifel(
  chm_change_veg < -10 | chm_change_veg > 10,
  NA,
  chm_change_veg
)

# Save cleaned CHM 
writeRaster(chm_change_clean, file.path(output_dir, "change", "CHM_change_2025_2023_NOAA_clean.tif"), overwrite = TRUE)


#### TREE & SHRUB ANALYSIS ####
# class 1 = Upland Trees (Forest), class 2 = scrub / shrub
tree_mask <- ifel(noaa_aligned == 1, 1, NA)
scrub_mask <- ifel(noaa_aligned == 2, 1, NA)

# Mask CHM change tif 
chm_change_tree <- mask(chm_change_clean, tree_mask)
chm_change_scrub <- mask(chm_change_clean, scrub_mask)

# Check distribution of values per class type 
global(chm_change_tree, c("min", "max", "mean"), na.rm = TRUE)
global(chm_change_scrub, c("min", "max", "mean"), na.rm = TRUE)

# Remove Nan-values
values_tree <- values(chm_change_tree, na.rm = TRUE)[, 1]
values_scrub <- values(chm_change_scrub, na.rm = TRUE)[, 1]

# Show quantile distribution of tree & shrub class 
quantile(values_tree, c(.05, .25, .5, .75, .95))
quantile(values_scrub, c(.05, .25, .5, .75, .95))


####### CREATE STATISTICS TABLE #######
# Count pixels for each class type in CHM change tif 
# 3 different thresholds of loss severity (<= -1m, <= -2m, <= -5m)
# Cumulative values (<= -1 also contains <= -2 and -5)
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

# Total pixels with more than 1 m CHM loss 
tree_loss_total <- sum(values_tree < -1) 
scrub_loss_total <- sum(values_scrub < -1)

# Calculate area of ha and percentage affected, sorted by trees & shrubs 
# 10,000 m² = 1 ha
# E.g. 108,569 pixels / 10.000 = 10.8569 ha loss of Tree / Forest
# Then calculate share of loss in percent for each class & threshold
area_table <- data.frame(
  CHM_decrease = c("-1 to -2 m", "< -2 to -5 m", "< -5 m"),
  Tree_ha = tree_pixels / 10000,
  Tree_percent = tree_pixels / tree_loss_total * 100,
  Scrub_ha = scrub_pixels / 10000,
  Scrub_percent = scrub_pixels / scrub_loss_total * 100
)

# Create plot 
table_shrubs_trees <- area_table |>
  dplyr::select(
    CHM_decrease,
    Tree_ha,
    Tree_percent,
    Scrub_ha,
    Scrub_percent
  ) |>
  gt() |>
  cols_label(
    CHM_decrease = "CHM height loss",
    Tree_ha = "Upland Tree (Forest) (ha)",
    Tree_percent = "Upland Tree (Forest) (%)",
    Scrub_ha = "Scrub / Shrub (ha)",
    Scrub_percent = "Scrub / Shrub (%)"
  ) |>
  fmt_number(
    columns = c(Tree_ha, Scrub_ha),
    decimals = 1
  ) |>
  fmt_number(
    columns = c(Tree_percent, Scrub_percent),
    decimals = 1,
    suffix = "%"
  ) |>
  tab_header(
    title = "Structural vegetation loss by severity after the Palisades Fire (Jan 2025)",
    subtitle = "LiDAR-derived CHM change · 2023–2025"
  ) |>
  tab_source_note( 
    source_note = gt::html( 
      "Source: USGS LiDAR 2023 & 2025 · NOAA C-CAP 2021.<br> 
      Percentages refer to areas with more than 1 m CHM loss within each vegetation class." 
    ) 
  ) |>
  data_color(
    columns = c(Tree_percent, Scrub_percent),
    palette = c("#FFF8E1", "#FFD54F", "#E76F3C")
  ) |>
  tab_options(
    table.font.names = "Georgia"
  )

table_shrubs_trees

gtsave(
  table_shrubs_trees,
  file.path(output_dir, "github_post", "CHM_veg_loss_shru_tree_table.png")
)







