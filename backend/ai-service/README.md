# AI Service

This directory follows the professor-specified AI stack.

Suggested model responsibilities:
- Scikit-learn: baseline risk classification/regression
- TensorFlow/PyTorch: deep learning and behavior models
- OpenCV/MediaPipe: computer vision, people/crowd and movement features
- Transformers/spaCy: NLP assistant intent detection and entity extraction

The Spring Boot service currently contains a deterministic explainable prototype risk engine so
the application can run without downloading a large ML model. Replace/augment RiskService with
a trained model after the project's real dataset is prepared.

Do not claim synthetic/demo values are live environmental measurements.
