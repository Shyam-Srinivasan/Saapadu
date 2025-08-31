package com.saapadu.admin.backend.backend.services;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.saapadu.admin.backend.backend.FirebaseUtils;
import com.saapadu.admin.backend.backend.models.CategoryModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class CategoryService {
    public CategoryModel createCategory(CategoryModel category) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        String categoryId = dbRef.child("categories").push().getKey();
        category.setCategoryId(categoryId);
        dbRef.child("categories").child(categoryId).child("category_name").setValueAsync(category.getCategoryName());
        dbRef.child("categories").child(categoryId).child("image_path").setValueAsync(category.getImagePath());
        dbRef.child("categories").child(categoryId).child("shop_id").setValueAsync(category.getShopId());
        return category;
    }

    public CategoryModel updateCategory(String categoryId, CategoryModel updatedCategory) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        dbRef.child("categories").child(categoryId).child("category_name").setValueAsync(updatedCategory.getCategoryName());
        dbRef.child("categories").child(categoryId).child("image_path").setValueAsync(updatedCategory.getImagePath());
        dbRef.child("categories").child(categoryId).child("shop_id").setValueAsync(updatedCategory.getShopId());
        return updatedCategory;
    }

    public CategoryModel fetchCategoryById(String categoryId) throws InterruptedException {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        DataSnapshot snapshot = FirebaseUtils.getDataSnapshot(dbRef.child("categories").child(categoryId));
        if (snapshot.exists()) {

            String categoryName = snapshot.child("category_name").getValue(String.class);
            String imagePath = snapshot.child("image_path").getValue(String.class);
            String shopId = snapshot.child("shop_id").getValue(String.class);

            return new CategoryModel(categoryId, shopId, categoryName, imagePath);
        }
        return null;
    }

    public List<CategoryModel> fetchCategories(String shopId) throws InterruptedException {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        DataSnapshot snapshot = FirebaseUtils.getDataSnapshot(dbRef.child("categories"));
        List<CategoryModel> categories = new ArrayList<>();
        if (snapshot.exists()) {
            for (DataSnapshot categorySnap : snapshot.getChildren()) {
                String categoryId = categorySnap.getKey();
                String sId = categorySnap.child("shop_id").getValue(String.class);

                if (shopId.equals(sId)) {
                    String categoryName = categorySnap.child("category_name").getValue(String.class);
                    String imagePath = categorySnap.child("image_path").getValue(String.class);
                    categories.add(new CategoryModel(categoryId, shopId, categoryName, imagePath));
                }
            }
        }
        return categories;
    }

    public void deleteCategory(String categoryId) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        dbRef.child("categories").child(categoryId).removeValueAsync();
    }
}
