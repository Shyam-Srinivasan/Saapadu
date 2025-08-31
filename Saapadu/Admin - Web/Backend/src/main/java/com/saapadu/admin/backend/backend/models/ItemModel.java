package com.saapadu.admin.backend.backend.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ItemModel {
    @JsonProperty("item_id")
    private String itemId;
    
    @JsonProperty("item_name")
    private String itemName;
    
    @JsonProperty("image_path")
    private String imagePath;
    
    @JsonProperty("category_id")
    private String categoryId;
    
    @JsonProperty("price")
    private double price;
    
    @JsonProperty("stock_quantity")
    private int stockQuantity;
}
