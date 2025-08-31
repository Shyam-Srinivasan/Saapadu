package com.saapadu.admin.backend.backend.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryModel {
    @JsonProperty("category_id")
    private String categoryId;
    
    @JsonProperty("shop_id")
    private String shopId;
    
    @JsonProperty("category_name")
    private String categoryName;
    
    @JsonProperty("image_path")
    private String imagePath;
    
}
