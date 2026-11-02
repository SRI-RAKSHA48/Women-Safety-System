package com.womensafety.controller;

import com.womensafety.model.SosRequest;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/sos")
public class SosController {
    private final ConcurrentHashMap<String, Map<String, Object>> incidents = new ConcurrentHashMap<>();

    @PostMapping("/activate")
    public Map<String, Object> activate(@RequestBody SosRequest request) {
        String id = "INC-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        Map<String, Object> incident = new java.util.HashMap<>();
        incident.put("incidentId", id);
        incident.put("status", "ACTIVE");
        incident.put("startedAt", Instant.now().toString());
        incident.put("latitude", request.latitude());
        incident.put("longitude", request.longitude());
        incident.put("transportMode", request.transportMode());
        incident.put("activationMethod", request.activationMethod());
        incidents.put(id, incident);
        return incident;
    }

    @PostMapping("/{incidentId}/stop")
    public Map<String, Object> stop(@PathVariable String incidentId) {
        Map<String, Object> incident = incidents.get(incidentId);
        if (incident == null) {
            return Map.of("status", "NOT_FOUND", "incidentId", incidentId);
        }
        incident.put("status", "STOPPED");
        incident.put("stoppedAt", Instant.now().toString());
        return incident;
    }

    @GetMapping
    public Object list() {
        return incidents.values();
    }
}
