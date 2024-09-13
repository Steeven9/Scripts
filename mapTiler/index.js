const MapSlicer = require("mapslice");

const mapSlicer = new MapSlicer({
  file: `./map.jpg`,
  output: `./output/{z}/tile_{x}_{y}.jpg`,
  imageMagick: true,
  // parallelLimit: 1,
  concurrency: 1,
});

mapSlicer.on("start", (files, options) =>
  console.info(`Starting to process ${files} files.`)
);
mapSlicer.on("imageSize", (width, height) =>
  console.info(`Image size: ${width}x${height}`)
);
mapSlicer.on("levels", (levels) => {
  console.info(`Level Data: ${levels}`);
});
mapSlicer.on("warning", (err) => console.warn(err));
mapSlicer.on("progress", (progress, total, current, path) =>
  console.info(`Progress: ${Math.round(progress * 100)}%`)
);
mapSlicer.on("end", () => console.info("Finished processing slices."));
mapSlicer.start().catch((err) => console.error(err));
