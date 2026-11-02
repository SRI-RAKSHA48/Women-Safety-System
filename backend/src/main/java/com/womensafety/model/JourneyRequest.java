package com.womensafety.model;

public record JourneyRequest(
        double latitude,
        double longitude,
        String destination,
        String transportMode,
        int expectedMinutes
) {}
