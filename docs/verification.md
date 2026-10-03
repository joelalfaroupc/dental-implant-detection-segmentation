# Publication verification

Performed on 2026-10-03 against the supplied source artifacts and cleaned edition:

- Parsed the notebook JSON and all eight Python code cells with the Python parser after removing notebook install/unzip commands.
- Checked the notebook has no execution outputs or original machine/widget metadata.
- Transcribed all 30 U-Net training rows and checked the archived test metrics against saved outputs.
- Inspected both published curve images: aggregate training/validation plots, with no radiographs.
- Audited 200 source JPEGs: 138 train, 33 validation, 29 test; unique filenames and byte hashes across splits; each image has a class-0 five-field normalized box label and a nonempty same-size mask.
- Checked internal Markdown file links and the publication manifest.
- Excluded original data, original Live Script, embedded notebook predictions, private machine paths and model weights.

No MATLAB execution or neural-model retraining was performed for this edition. The original split and exact dependency environment were not recoverable. Python syntax checks are not evidence that every training dependency or GPU configuration has been executed successfully. Future seeded exports and training must be evaluated separately.
