package com.womensafety.model;

import java.util.List;

public record RiskResponse(
        int score,
        String level,
        List<String> reasons,
        List<String> positiveFactors,
        double latitude,
        double longitude,
        String transportMode
) {}
