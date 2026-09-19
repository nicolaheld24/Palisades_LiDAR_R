###### CLIPPING LAZ FILES FOR CLOUDCOMPARE ######

# Connect with 01_setup.R
source("01_setup.R")

cc_ext <- ext(
  354250,
  354450,
  3768390,
  3768590
)

plot(local_change, main = "CHM change")
plot(cc_ext, add = TRUE)

plot(local_change, main = "CHM change")
plot(cc_ext, add = TRUE)

cc_change <- crop(chm_change, cc_ext)

global(
  cc_change,
  c("min", "max", "mean"),
  na.rm = TRUE
)

las_2023_cc <- clip_rectangle(
  ctg_2023,
  354250,
  3768390,
  354450,
  3768590
)

las_2025_cc <- clip_rectangle(
  ctg_2025,
  354250,
  3768390,
  354450,
  3768590
)

las_2023_cc
las_2025_cc


writeLAS(
  las_2023_cc,
  file.path(output_dir, "change", "CloudCompare_2023_200m.laz")
)

writeLAS(
  las_2025_cc,
  file.path(output_dir, "change", "CloudCompare_2025_200m.laz")
)

