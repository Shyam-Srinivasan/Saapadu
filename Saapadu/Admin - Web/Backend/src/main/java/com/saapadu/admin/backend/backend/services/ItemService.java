package com.saapadu.admin.backend.backend.services;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.saapadu.admin.backend.backend.FirebaseUtils;
import com.saapadu.admin.backend.backend.models.ItemModel;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class ItemService {
    public ItemModel createItem(ItemModel item) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        String itemId = dbRef.child("items").push().getKey();
        item.setItemId(itemId);
        dbRef.child("items").child(itemId).child("item_name").setValueAsync(item.getItemName());
        dbRef.child("items").child(itemId).child("image_path").setValueAsync(item.getImagePath());
        dbRef.child("items").child(itemId).child("category_id").setValueAsync(item.getCategoryId());
        dbRef.child("items").child(itemId).child("price").setValueAsync(item.getPrice());
        dbRef.child("items").child(itemId).child("stock_quantity").setValueAsync(item.getStockQuantity());

        return item;
    }

    public ItemModel updateItem(ItemModel item) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        dbRef.child("items").child(item.getItemId()).child("item_name").setValueAsync(item.getItemName());
        dbRef.child("items").child(item.getItemId()).child("image_path").setValueAsync(item.getImagePath());
        dbRef.child("items").child(item.getItemId()).child("category_id").setValueAsync(item.getCategoryId());
        dbRef.child("items").child(item.getItemId()).child("price").setValueAsync(item.getPrice());
        dbRef.child("items").child(item.getItemId()).child("stock_quantity").setValueAsync(item.getStockQuantity());

        return item;
    }

    public ItemModel fetchItemById(String itemId) throws InterruptedException {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        DataSnapshot snapshot = FirebaseUtils.getDataSnapshot(dbRef.child("items").child(itemId));

        if (snapshot.exists()) {
            String itemName = snapshot.child("item_name").getValue(String.class);
            String imagePath = snapshot.child("image_path").getValue(String.class);
            String categoryId = snapshot.child("category_id").getValue(String.class);
            double price = snapshot.child("price").getValue(double.class);
            Integer stockQuantity = snapshot.child("stock_quantity").getValue(Integer.class);

            return new ItemModel(itemId, itemName, imagePath, categoryId, price, stockQuantity);
        }
        return null;
    }

    public List<ItemModel> fetchItems(String categoryId) throws InterruptedException {
        DatabaseReference db = FirebaseDatabase.getInstance().getReference();
        DataSnapshot snapshot = FirebaseUtils.getDataSnapshot(db.child("items"));

        List<ItemModel> items = new ArrayList<>();

        if (snapshot.exists()) {
            for (DataSnapshot itemSnap : snapshot.getChildren()) {
                String itemId = itemSnap.getKey();
                String cId = itemSnap.child("category_id").getValue(String.class);

                if (categoryId.equals(cId)) {
                    String itemName = snapshot.child("item_name").getValue(String.class);
                    String imagePath = snapshot.child("image_path").getValue(String.class);
                    double price = snapshot.child("price").getValue(double.class);
                    Integer stockQuantity = snapshot.child("stock_quantity").getValue(Integer.class);

                    items.add(new ItemModel(itemId, itemName, imagePath, cId, price, stockQuantity));
                }
            }
        }
        return items;
    }

    public boolean deleteItem(String itemId) {
        try {
            DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
            dbRef.child("items").child(itemId).removeValueAsync();
            return true;
        } catch (Exception e){
            return false;
        }
    }
}
