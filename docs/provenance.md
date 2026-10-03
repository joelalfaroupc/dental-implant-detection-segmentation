# Provenance and publication edits

This is a documented standalone edition of the final vision project by Joel Alfaro and Daniel Pastor. Source material was supplied as `PF_JoelAlfaro_DanielPastor.zip`; it included a MATLAB Live Script, a Jupyter notebook with saved outputs, and 200 implant crops with generated labels. Team credits describe the project as a whole.

The published MATLAB text is extracted from the Live Script. Its labeling algorithm is retained. Publication edits set a seed for future exports, honor the configured input directory, reject an existing output directory rather than deleting it, and stop on an empty component. The original export was unseeded. The original Live Script embeds radiographs and is not included.

The cleaned neural notebook retains the two models, hyperparameters, 30-epoch training and final-epoch U-Net test evaluation. Publication edits remove install/unzip commands and saved outputs, validate local paths/pairs, sort filenames, seed future runs, and correct sample paths. Small qualitative samples are capped at available images. Embedded images, machine metadata, original data and weights are excluded.

The original code requested Albumentations 1.3.1, but saved output warned that `var_limit` was invalid for `GaussNoise`. This conflict means the actual runtime and noise distribution cannot be reconstructed. The cleaned notebook targets Albumentations 2.x and calls `GaussNoise(p=0.2)` with that library's defaults. This is a compatibility edit, not an exact replication. The API changed in [Albumentations 2.0](https://github.com/albumentations-team/albumentations/releases/tag/2.0.0). Other package ranges in requirements are installation guidance, not a recovered environment lock.

Aggregate learning curves are copied from saved notebook outputs. The U-Net CSV transcribes printed values rounded to four decimals. The JSON transcribes archived test outputs and split counts. No model was retrained, and no new performance is claimed. YOLO curves show validation mAP; the table's test mAP comes from a separate saved test call. U-Net test metrics average batches equally and include the background class in pixel accuracy. A scalar Dice loss is not reported here as a foreground Dice coefficient.

No dataset provenance, patient identifiers, expert annotation, exact original split manifest, trained weights, or project license was supplied. This repository does not add a software license or grant rights to third-party material. Radiographs, masks, dataset ZIP and embedded prediction examples are excluded from publication. Aggregate data checks cannot establish patient independence or clinical validity.

## Local source fingerprints

These identify the source artifacts inspected during packaging; the artifacts are not public downloads.

```json
{
  "PF_1.mlx": "330a91eda1dadcbc020780678f086fd443bd0b3e45dd62ed6b57229d1052269a",
  "PF_2.ipynb": "a4d1c31d648080f78ef618ee699a9e4805d3a636a45b93948d6dbc4b30a791b1",
  "dataset_final.zip": "2f93e4182614122c6869cc241e28e8211e06373f8a3026bc4029aa1914e526ce"
}
```
