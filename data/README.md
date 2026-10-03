# Local data contract

Radiographs and derived image masks are not redistributed here. Their source and redistribution terms were not established in the supplied project. Obtain authorized local images separately. No weights are bundled.

The neural notebook expects this structure under `data/dataset_final/` (or the directory set by `DENTAL_DATA_DIR`):

```text
dataset_final/
  train/{images,labels,masks}/
  val/{images,labels,masks}/
  test/{images,labels,masks}/
```

For each `images/17.jpg`, provide `labels/17.txt` and `masks/17.png`. Masks have the original image dimensions, background 0 and foreground 255. The single YOLO label is `0 x_center y_center width height`, normalized to image dimensions. Class 0 means implant. Filenames must be unique across splits. The checked archive had 200 images with one box each; the notebook validates directories and pair existence before training.

To generate these annotations, put numbered RGB JPEGs (`1.jpg` through `200.jpg`) in a local `Implantes/` directory and run the MATLAB script from that directory's parent. Adjust its configuration for another collection. MATLAB with Image Processing Toolbox is required. It produces approximate 70/15/15 random splits, not exact counts. Its export assumes one bright, roughly vertical implant per crop; inspect masks and boxes before training. Bounding boxes retain the original MATLAB `regionprops` coordinate convention.

The supplied archive was 138/33/29, while archived training logs show 140/25/35. Neither the data needed to recover the archived split nor patient identifiers are included publicly. The seeded new export cannot recover the original unseeded split. For a new dataset, establish patient-disjoint partitions and independently reviewed labels before making stronger claims.
