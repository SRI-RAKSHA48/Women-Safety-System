package com.womensafety.model;

public record RiskRequest(
        double latitude,
        double longitude,
        String transportMode,
        int hour,
        String trafficLevel,
        String crowdDensity,
        String streetLighting,
        double historicalIncidentRate,
        boolean routeIsolated,
        boolean routeDeviation,
        boolean rain,
        boolean unusualMovement
) {}
