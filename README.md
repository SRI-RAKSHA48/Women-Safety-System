# AI-Enabled Women Security Application

A professor-aligned prototype for a Smart Women Security Application using Flutter, Spring Boot,
PostgreSQL, MongoDB, TensorFlow/PyTorch/Scikit-learn, OpenCV/MediaPipe, Transformers/spaCy,
Google Maps, Firebase Cloud Messaging/Auth, AWS S3, WebSockets, MQTT/BLE, Docker and Kubernetes.

## Important
This repository is designed to run as a practical academic prototype. Some integrations that
require external credentials or official datasets (Google Maps, Firebase, AWS S3, BLE hardware,
official emergency databases, live street-light/CCTV datasets) are configurable and have safe
local/demo fallbacks. The risk engine is deterministic and explainable; it does NOT generate
random risk numbers.

## Quick start

### Backend
Requirements:
- Java 17+
- Maven 3.9+
- PostgreSQL (optional for demo mode)
- MongoDB (optional for demo mode)

Run:
    cd backend
    mvn spring-boot:run

API:
    http://localhost:8080

Health:
    GET /api/health

Risk prediction:
    POST /api/risk/predict

Journey:
    POST /api/journey/start

SOS:
    POST /api/sos/activate
    POST /api/sos/{incidentId}/stop

### Flutter
Requirements:
- Flutter 3.x
- Android Studio / Android SDK

Run:
    cd frontend/flutter_app
    flutter pub get
    flutter run

The app includes:
- Login
- Register
- Forgot password
- Emergency contacts
- One-tap SOS
- SOS stop/confirmation
- Live GPS position
- Journey transport selection
- Explainable risk prediction
- Fake call
- Emergency helplines
- AI assistant with intent-based responses
- Incident timeline
- Profile and logout
- Smart safety check-in

## Google Maps
Add your Google Maps API key to:
android/app/src/main/AndroidManifest.xml

Replace:
YOUR_GOOGLE_MAPS_API_KEY

## Firebase
For Firebase Auth/FCM, generate the normal Android Firebase configuration from
Firebase Console and add google-services.json under android/app. The app remains runnable
without Firebase by using local prototype authentication.

## AWS S3
Set environment variables in a production deployment:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_S3_BUCKET

Do not commit credentials.

## ML
The academic risk engine is implemented as an explainable feature-weighted model in the
Spring Boot prototype. The repository also contains a Python AI service skeleton showing
where Scikit-learn/TensorFlow/PyTorch models can be trained and served.

## Architecture
frontend/flutter_app -> Spring Boot -> risk/emergency/journey services
                           -> PostgreSQL/MongoDB
                           -> AI service
                           -> AWS S3 / FCM / WebSockets / MQTT

## Advanced modules
OpenCV, MediaPipe, Transformers and spaCy integration points are documented under
backend/ai-service. They require their respective Python environments/models and are not
falsely presented as live law-enforcement integrations.

## Emergency safety note
The application is an academic prototype. Emergency numbers and official services should be
verified before real-world deployment.
