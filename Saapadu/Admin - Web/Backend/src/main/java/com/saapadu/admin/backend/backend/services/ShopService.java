package com.saapadu.admin.backend.backend.services;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.saapadu.admin.backend.backend.FirebaseUtils;
import com.saapadu.admin.backend.backend.models.ShopModel;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ShopService {

    public ShopModel createShop(ShopModel shop) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        String shopId = dbRef.child("shops").push().getKey();
        shop.setShopId(shopId);
        dbRef.child("shops").child(shopId).child("shop_name").setValueAsync(shop.getShopName());
        dbRef.child("shops").child(shopId).child("password").setValueAsync(shop.getPassword());
        dbRef.child("shops").child(shopId).child("college_id").setValueAsync(shop.getCollegeId());

        return shop;
    }

    public ShopModel updateShop(ShopModel shop) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        dbRef.child("shops").child(shop.getShopId()).child("shop_name").setValueAsync(shop.getShopName());
        dbRef.child("shops").child(shop.getShopId()).child("password").setValueAsync(shop.getPassword());

        return shop;
    }

    public ShopModel fetchShopById(String shopId) throws InterruptedException {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        DataSnapshot snapshot = FirebaseUtils.getDataSnapshot(dbRef.child("shops").child(shopId));

        if (snapshot.exists()) {
            String shopName = snapshot.child("shop_name").getValue(String.class);
            String password = snapshot.child("password").getValue(String.class);
            String collegeId = snapshot.child("college_id").getValue(String.class);

            return new ShopModel(shopId, shopName, password, collegeId);
        }
        return null;
    }

    public List<ShopModel> fetchShops(String collegeId) throws InterruptedException {
        DatabaseReference db = FirebaseDatabase.getInstance().getReference();
        DataSnapshot snapshot = FirebaseUtils.getDataSnapshot(db.child("shops"));

        List<ShopModel> shops = new ArrayList<>();

        if (snapshot.exists()) {
            for (DataSnapshot shopSnap : snapshot.getChildren()) {
                String shopId = shopSnap.getKey();
                String cId = shopSnap.child("college_id").getValue(String.class);

                if (collegeId.equals(cId)) {
                    String shopName = shopSnap.child("shop_name").getValue(String.class);
                    String password = shopSnap.child("password").getValue(String.class);
                    shops.add(new ShopModel(shopId, shopName, password, cId));
                }
            }
        }
        return shops;
    }
    
    public void deleteShop(String shopId) {
        DatabaseReference dbRef = FirebaseDatabase.getInstance().getReference();
        dbRef.child("shops").child(shopId).removeValueAsync();

    }

}
