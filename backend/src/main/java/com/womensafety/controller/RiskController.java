package com.womensafety.controller;

import com.womensafety.model.RiskRequest;
import com.womensafety.model.RiskResponse;
import com.womensafety.service.RiskService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/risk")
public class RiskController {
    private final RiskService service;

    public RiskController(RiskService service) {
        this.service = service;
    }

    @PostMapping("/predict")
    public RiskResponse predict(@Valid @RequestBody RiskRequest request) {
        return service.predict(request);
    }
}
