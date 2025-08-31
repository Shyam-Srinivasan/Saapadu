package com.saapadu.admin.backend.backend.controllers;

import com.saapadu.admin.backend.backend.services.DashboardService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.concurrent.CompletableFuture;

@RestController
@CrossOrigin(origins = "*")
public class DashboardController {
    @Autowired
    private DashboardService dashboardService;
    private static final Logger logger = LoggerFactory.getLogger(Controller.class);
    
    
    private <T> CompletableFuture<ResponseEntity<?>> createDashboardResponse(CompletableFuture<T> future) {
        return future.<ResponseEntity<?>>thenApply(ResponseEntity::ok)
                .exceptionally(ex -> {
                    logger.error("Dashboard API error", ex); // Log the full exception for backend debugging
                    return ResponseEntity
                            .status(HttpStatus.INTERNAL_SERVER_ERROR)
                            .body(Map.of("message", "Failed to retrieve dashboard data.", "error", ex.getMessage()));
                });
    }

    @GetMapping("/home/total-orders")
    public CompletableFuture<ResponseEntity<?>> fetchTotalOrdersByCollegeId(@RequestParam Long collegeId) {
        return createDashboardResponse(dashboardService.getTotalOrdersByCollegeId(collegeId));
    }

    @GetMapping("/home/pending-orders")
    public CompletableFuture<ResponseEntity<?>> fetchPendingOrdersByCollegeId(@RequestParam Long collegeId) {
        return createDashboardResponse(dashboardService.getPendingOrdersByCollegeId(collegeId));
    }

    @GetMapping("/home/completed-orders")
    public CompletableFuture<ResponseEntity<?>> fetchCompletedOrdersByCollegeId(@RequestParam Long collegeId) {
        return createDashboardResponse(dashboardService.getCompletedOrdersByCollegeId(collegeId));
    }

    @GetMapping("/home/total-revenue")
    public CompletableFuture<ResponseEntity<?>> fetchTotalRevenueByCollegeId(@RequestParam Long collegeId) {
        return createDashboardResponse(dashboardService.getTotalRevenueByCollegeId(collegeId));
    }
}
