# Architecture

## Runtime flow

Flutter
 -> GPS / transport input
 -> Spring Boot REST/WebSocket APIs
 -> Risk service
 -> PostgreSQL/MongoDB
 -> Firebase/FCM
 -> AWS S3 for evidence
 -> Google Maps for mapping/routing
 -> AI service for trained ML/CV/NLP models

## Real-time prediction

The prediction request contains the actual GPS coordinate returned by the phone plus:
- transport mode
- time
- traffic
- crowd density
- street lighting
- historical incident rate
- route isolation/deviation
- weather
- movement anomaly

The prototype model is deterministic and explainable. A production implementation must feed
verified live values for environmental features rather than inventing them.
