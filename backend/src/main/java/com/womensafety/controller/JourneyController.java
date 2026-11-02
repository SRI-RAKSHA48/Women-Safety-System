package com.womensafety.controller;

import com.womensafety.model.JourneyRequest;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/journey")
public class JourneyController {
    @PostMapping("/start")
    public Map<String, Object> start(@RequestBody JourneyRequest request) {
        return Map.of(
                "journeyId", "JRN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(),
                "startedAt", Instant.now().toString(),
                "latitude", request.latitude(),
                "longitude", request.longitude(),
                "destination", request.destination(),
                "transportMode", request.transportMode(),
                "expectedMinutes", request.expectedMinutes(),
                "checkInEnabled", true,
                "checkInIntervalMinutes", 15
        );
    }
}
