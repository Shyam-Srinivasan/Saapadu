package com.saapadu.admin.backend.backend.controllers;

import com.saapadu.admin.backend.backend.models.CategoryModel;
import com.saapadu.admin.backend.backend.services.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@CrossOrigin(origins = "*")
public class CategoryController {
    @Autowired
    private CategoryService categoryService;

    @PostMapping("categoryList/createCategory")
    ResponseEntity<CategoryModel> createCategory(@RequestBody CategoryModel category){
        try{
            if(category == null || category.getCategoryName() == null || category.getShopId() == null || category.getImagePath() == null){
                return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
            }
            return new ResponseEntity<>(categoryService.createCategory(category), HttpStatus.CREATED);
        } catch (Exception e){
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
        @PutMapping("/categoryList/updateCategory")
    ResponseEntity<CategoryModel> updateCategory(@RequestParam String categoryId, @RequestBody CategoryModel updatedCategory) {
        try {
            if (updatedCategory == null || categoryId == null || updatedCategory.getCategoryName() == null) {
                return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
            }
            CategoryModel category = categoryService.fetchCategoryById(categoryId);
            if (category == null) {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
            category.setCategoryId(categoryId);
            category.setCategoryName(updatedCategory.getCategoryName());

            CategoryModel save = categoryService.updateCategory(categoryId, category);
            return new ResponseEntity<>(save, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/categoryList/fetchCategory")
    ResponseEntity<CategoryModel> fetchCategory(@RequestParam String categoryId) {
        try {
            CategoryModel category = categoryService.fetchCategoryById(categoryId);
            if (category == null) {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
            return new ResponseEntity<>(category, HttpStatus.FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/categoryList/fetchCategories")
    ResponseEntity<List<CategoryModel>> fetchCategories(@RequestParam String shopId) {
        try {
            List<CategoryModel> categories = categoryService.fetchCategories(shopId);
            if (categories.isEmpty() || categories == null) {
                return new ResponseEntity<>(null, HttpStatus.NO_CONTENT);
            }
            return new ResponseEntity<>(categories, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/categoryList/deleteCategory")
    ResponseEntity<CategoryModel> deleteCategory(@RequestParam String categoryId) {
        categoryService.deleteCategory(categoryId);
        return new ResponseEntity<>(null, HttpStatus.OK);
    }

}
