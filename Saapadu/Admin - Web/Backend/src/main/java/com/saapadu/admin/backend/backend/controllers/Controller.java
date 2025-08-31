package com.saapadu.admin.backend.backend.controllers;


import com.saapadu.admin.backend.backend.models.OrderModel;
import com.saapadu.admin.backend.backend.models.SignUpModel;
import com.saapadu.admin.backend.backend.services.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;


@RestController
@CrossOrigin(origins = {"http://localhost:3000", "http://192.168.1.1:3000", "http://192.168.1.2:3000", "http://192.168.1.3:3000", "http://192.168.1.4:3000", "http://192.168.1.5:3000", "http://192.168.1.6:3000", "http://192.168.1.7:3000", "http://192.168.1.8:3000", "http://192.168.1.9:3000"})
public class Controller {

    @Autowired
    private SignUpService signUpService;
    @Autowired
    private SignInService signInService;
    @Autowired
    private OrderService orderService;


//    private final SignInService signInService;
//    private final SignUpService signUpService;
//
//    public Controller(SignInService signInService, SignUpService signUpService) {
//        this.signInService = signInService;
//        this.signUpService = signUpService;
//    }

    @GetMapping("/signIn")
    public CompletableFuture<ResponseEntity<?>> checkCollegeExists(@RequestParam String collegeName) {
        return signInService.signInWithCollegeName(collegeName)
                .thenApply(collegeId -> {
                    if (collegeId != null) {
                        return ResponseEntity.<Object>ok(
                                Map.of("college_id", collegeId, "college_name", collegeName));
                    } else {
                        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("College '" + collegeName + "' not found.");
                    }
                })
                .exceptionally(ex -> {
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error checking college: " + ex.getMessage());
                });
    }

    @PostMapping("/signUp")
    public CompletableFuture<ResponseEntity<Object>> signUp(@RequestBody SignUpModel request) {
        return signUpService.createOrganization(request)
                // Add a type witness <Object> to guide the compiler to the correct generic type.
                .thenApply(collegeId -> ResponseEntity.<Object>ok(Map.of(
                        "message", "Organization created successfully.",
                        "college_id", collegeId
                )))
                .exceptionally(ex -> {
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                            "message", "Error creating organization.",
                            "error", ex.getCause() != null ? ex.getCause().getMessage() : ex.getMessage()
                    ));
                });

    }
    
  @GetMapping("/home/recent-orders")
    public ResponseEntity<List<OrderModel>> getRecentOrders(@RequestParam String collegeId, @RequestParam(defaultValue = "10") int limit) {
        try {
            List<OrderModel> orders = orderService.getRecentOrdersByCollege(collegeId, limit);
            return ResponseEntity.ok(orders);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
    
}