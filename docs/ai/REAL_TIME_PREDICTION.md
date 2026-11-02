# Real-Time Risk Prediction Design

## Inputs

1. Current GPS from Flutter/geolocator
2. Transport mode selected by the user
3. Current time
4. Traffic condition from the approved map/data provider
5. Historical incidents around the current coordinate
6. Street lighting dataset
7. Crowd estimate from OpenCV/MediaPipe where camera processing is permitted
8. Weather
9. Route isolation/deviation
10. Movement behavior

## Why the number is not random

The current prototype calculates a fixed contribution for every supplied feature. Therefore the
same inputs always produce the same score. It is intentionally transparent for a viva/demo.

## Production ML

Prepare a labelled dataset:
features -> incident/risk label

Then train:
- Scikit-learn baseline
- TensorFlow/PyTorch advanced model

Validate using accuracy, precision, recall, F1 and confusion matrix. Persist the trained model
and call inference from the AI service.

## Important limitation

A phone cannot truthfully know exact street-light count, exact number of people or CCTV coverage
from GPS alone. Those values must come from verified datasets/APIs or explicit computer-vision
estimates. The app must display UNKNOWN when a verified source is unavailable.
