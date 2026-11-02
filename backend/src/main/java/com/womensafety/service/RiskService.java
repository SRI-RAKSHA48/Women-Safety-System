package com.womensafety.service;

import com.womensafety.model.RiskRequest;
import com.womensafety.model.RiskResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class RiskService {

    public RiskResponse predict(RiskRequest r) {
        double score = 0;
        List<String> reasons = new ArrayList<>();
        List<String> positives = new ArrayList<>();

        // Explainable, deterministic prototype model.
        // Each factor contributes to the score; there is no random number generation.

        if (r.historicalIncidentRate() >= 0.70) {
            score += 28;
            reasons.add("High historical incident rate");
        } else if (r.historicalIncidentRate() >= 0.40) {
            score += 15;
            reasons.add("Moderate historical incident rate");
        } else {
            positives.add("Low historical incident rate");
        }

        switch (r.streetLighting() == null ? "" : r.streetLighting().toUpperCase()) {
            case "POOR" -> { score += 18; reasons.add("Poor street lighting"); }
            case "MODERATE" -> { score += 8; reasons.add("Moderate street lighting"); }
            case "GOOD" -> positives.add("Good street lighting");
            default -> {}
        }

        switch (r.crowdDensity() == null ? "" : r.crowdDensity().toUpperCase()) {
            case "LOW" -> { score += 12; reasons.add("Low pedestrian/crowd density"); }
            case "MEDIUM" -> score += 4;
            case "HIGH" -> positives.add("High pedestrian/crowd density");
            default -> {}
        }

        switch (r.trafficLevel() == null ? "" : r.trafficLevel().toUpperCase()) {
            case "LOW" -> { score += 6; reasons.add("Low traffic activity"); }
            case "MEDIUM" -> score += 2;
            case "HIGH" -> positives.add("High traffic activity");
            default -> {}
        }

        if (r.hour() >= 22 || r.hour() < 5) {
            score += 12;
            reasons.add("Late-night travel");
        }

        if (r.routeIsolated()) {
            score += 12;
            reasons.add("Route is marked as isolated");
        } else {
            positives.add("Route is not marked isolated");
        }

        if (r.routeDeviation()) {
            score += 15;
            reasons.add("Unexpected route deviation");
        }

        if (r.rain()) {
            score += 5;
            reasons.add("Rain/weather may reduce visibility and activity");
        }

        if (r.unusualMovement()) {
            score += 18;
            reasons.add("Unusual movement pattern detected");
        }

        // Transport mode changes the interpretation, as required by the project.
        if ("CAB".equalsIgnoreCase(r.transportMode()) && r.routeDeviation()) {
            score += 10;
            reasons.add("Cab route deviation requires attention");
        }
        if ("PUBLIC_TRANSPORT".equalsIgnoreCase(r.transportMode())
                && r.crowdDensity() != null
                && r.crowdDensity().equalsIgnoreCase("LOW")
                && (r.hour() >= 22 || r.hour() < 5)) {
            score += 8;
            reasons.add("Late-night public transport with low crowd density");
        }
        if ("WALKING".equalsIgnoreCase(r.transportMode()) && r.streetLighting() != null
                && r.streetLighting().equalsIgnoreCase("POOR")) {
            score += 7;
            reasons.add("Walking on poorly lit streets");
        }

        int finalScore = (int)Math.round(Math.max(0, Math.min(100, score)));
        String level = finalScore >= 70 ? "HIGH" : finalScore >= 40 ? "MODERATE" : "SAFE";

        if (positives.isEmpty()) {
            positives.add("No strong positive safety factor supplied");
        }
        if (reasons.isEmpty()) {
            reasons.add("No major risk factor detected from supplied features");
        }

        return new RiskResponse(finalScore, level, reasons, positives,
                r.latitude(), r.longitude(), r.transportMode());
    }
}
