package com.womensafety.model;

public record SosRequest(
        double latitude,
        double longitude,
        String transportMode,
        String activationMethod
) {}
