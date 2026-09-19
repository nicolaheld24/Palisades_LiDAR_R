# Find out acquisition time and date of LiDAR flight 

# Connect with 01_setup.R
source("01_setup.R")

# 2023 acquisition 
las2023 <- readLAS(
  "C:/Users/nicol/Desktop/EAGLE/LiDAR/final_project/rstudio_laz_files_2023_2025/2023/USGS_LPC_CA_LosAngeles_B23_11SLT035300376700.laz"
)

las2023@header

range(las2023$gpstime)

# 2025 acquisition 
las2025 <- readLAS(
  "C:/Users/nicol/Desktop/EAGLE/LiDAR/final_project/rstudio_laz_files_2023_2025/2025/USGS_LPC_CA_2025LosAngelesPostWildfire_C25_11SLT003517037672.laz"
)
las2025@header

range(las2025$gpstime)