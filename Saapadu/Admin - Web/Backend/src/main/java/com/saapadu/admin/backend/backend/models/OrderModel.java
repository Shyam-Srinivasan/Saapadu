package com.saapadu.admin.backend.backend.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderModel {
    @JsonProperty("order_id")
    private String orderId;
    @JsonProperty("user_id")
    private String userId;
    @JsonProperty("user_name")
    private String userName;
    private List<Item> items;
    @JsonProperty("shop_name")
    private String shopName;
    @JsonProperty("total_amount")
    private double totalAmount;
    private long timeStamp;
    private boolean isPurchased;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Item {
        @JsonProperty("item_name")
        private String itemName;
        private int quantity;
    }
}
