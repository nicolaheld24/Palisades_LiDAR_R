// SENTINEL-2 TIMESERIES OF PALISADES FIRE, 2023–2026

// var aoi = ee.FeatureCollection('projects/DEIN-PROJEKT/assets/LiDAR_AOI_WGS84');
// var noaa = ee.Image('projects/propane-tribute-464707-b2/assets/NOAA_palisades_repr_4326'); 

// Select vegetated NOAA classes
var noaaUnite = noaa.eq(1).or(noaa.eq(2));

Map.addLayer(
  noaaUnite.selfMask().clip(aoi),
  {palette: ['grey']},
  'NOAA vegetation mask',
  false
);

Map.centerObject(aoi, 13);
Map.addLayer(aoi, {}, 'LiDAR AOI', false);

// Load selected Sentinel-2 scenes
var imageIds = [
  'COPERNICUS/S2_SR_HARMONIZED/20231214T183759_20231214T184047_T11SLT',
  'COPERNICUS/S2_SR_HARMONIZED/20250102T183751_20250102T183754_T11SLT',
  'COPERNICUS/S2_SR_HARMONIZED/20250112T183731_20250112T183727_T11SLT',
  'COPERNICUS/S2_SR_HARMONIZED/20250616T182919_20250616T184204_T11SLT',
  'COPERNICUS/S2_SR_HARMONIZED/20260109T183831_20260109T183832_T11SLT'
];

var dates = [
  '14 Dec 2023',
  '02 Jan 2025',
  '12 Jan 2025',
  '16 Jun 2025',
  '09 Jan 2026'
];

var images = imageIds.map(function(id) {
  return ee.Image(id).clip(aoi);
});

// Display RGB images
var rgbVis = {
  bands: ['B4', 'B3', 'B2'],
  min: 0,
  max: 3000
};

for (var i = 0; i < images.length; i++) {
  Map.addLayer(images[i], rgbVis, dates[i] + ' RGB', false);
}

// Calculate NDVI or NBR with cloud and vegetation masks
function calculateIndex(image, bands, name) {
  var scl = image.select('SCL');
  var cloudMask = scl.neq(8).and(scl.neq(9)).and(scl.neq(10));

  return image
    .updateMask(cloudMask)
    .updateMask(noaaUnite)
    .normalizedDifference(bands)
    .rename(name);
}

var ndviImages = images.map(function(image) {
  return calculateIndex(image, ['B8', 'B4'], 'NDVI');
});

var nbrImages = images.map(function(image) {
  return calculateIndex(image, ['B8', 'B12'], 'NBR');
});

// Display NDVI and NBR
var ndviVis = {
  min: 0,
  max: 0.9,
  palette: ['brown', 'yellow', 'green']
};

var nbrVis = {
  min: -0.6,
  max: 0.7,
  palette: ['brown', 'yellow', 'green']
};

for (var i = 0; i < images.length; i++) {
  Map.addLayer(ndviImages[i], ndviVis, dates[i] + ' NDVI', true);
  Map.addLayer(nbrImages[i], nbrVis, dates[i] + ' NBR', false);
}

// Calculate spectral change
var dNDVI_fire = ndviImages[1].subtract(ndviImages[2]).rename('dNDVI');
var dNBR_fire = nbrImages[1].subtract(nbrImages[2]).rename('dNBR');

var dNDVI_lidar = ndviImages[0].subtract(ndviImages[2]).rename('dNDVI');
var dNBR_lidar = nbrImages[0].subtract(nbrImages[2]).rename('dNBR');

// Set change map visualisation
var changeImages = [
  dNDVI_fire, dNBR_fire,
  dNDVI_lidar, dNBR_lidar
];

var changeNames = [
  'dNDVI 2025 pre & post',
  'dNBR 2025 pre & post',
  'dNDVI 2023 / 2025',
  'dNBR 2023 / 2025'
];

var changeVis = [
  {min: 0, max: 0.65, palette: ['green', 'white', 'brown']},
  {min: 0, max: 1.1, palette: ['green', 'white', 'brown']},
  {min: 0, max: 0.65, palette: ['green', 'white', 'brown']},
  {min: 0, max: 1.1, palette: ['green', 'white', 'brown']}
];

// Display change maps and calculate statistics
for (var i = 0; i < changeImages.length; i++) {
  Map.addLayer(changeImages[i], changeVis[i], changeNames[i], true);

  print(changeNames[i], changeImages[i].reduceRegion({
    reducer: ee.Reducer.minMax()
      .combine(ee.Reducer.mean(), '', true)
      .combine(ee.Reducer.median(), '', true),
    geometry: aoi.geometry(),
    scale: 20,
    maxPixels: 1e9
  }));
}

// Calculate NDVI and NBR percentiles
[ndviImages, nbrImages].forEach(function(images) {
  for (var i = 0; i < images.length; i++) {
    print(dates[i], images[i].reduceRegion({
      reducer: ee.Reducer.percentile([1, 5, 25, 50, 75, 95, 99]),
      geometry: aoi.geometry(),
      scale: 20,
      maxPixels: 1e9
    }));
  }
});

// Export NDVI and NBR
[
  [ndviImages, 'NDVI_'],
  [nbrImages, 'NBR_']
].forEach(function(group) {
  for (var i = 0; i < group[0].length; i++) {
    Export.image.toDrive({
      image: group[0][i],
      description: group[1] + dates[i],
      folder: 'Palisades_Sentinel2',
      fileNamePrefix: group[1] + dates[i],
      region: aoi.geometry(),
      scale: 20,
      maxPixels: 1e9
    });
  }
});

// Export change maps
var exportNames = [
  'dNDVI_Fire_Impact',
  'dNBR_Fire_Impact',
  'dNDVI_LiDAR_Period',
  'dNBR_LiDAR_Period'
];

for (var i = 0; i < changeImages.length; i++) {
  Export.image.toDrive({
    image: changeImages[i],
    description: exportNames[i],
    folder: 'Palisades_Sentinel2',
    fileNamePrefix: exportNames[i],
    region: aoi.geometry(),
    scale: 20,
    maxPixels: 1e9
  });
}