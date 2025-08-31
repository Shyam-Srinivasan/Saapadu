package com.saapadu.admin.backend.backend.services;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.saapadu.admin.backend.backend.FirebaseUtils;
import com.saapadu.admin.backend.backend.models.OrderModel;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderService {

    public List<OrderModel> getRecentOrdersByCollege(String collegeId, int limit) throws InterruptedException {
        DatabaseReference db = FirebaseDatabase.getInstance().getReference();
        DataSnapshot snapshot = FirebaseUtils.getDataSnapshot(db.child("orders"));

        List<OrderModel> orders = new ArrayList<>();

        if (snapshot.exists()) {
            for (DataSnapshot orderSnap : snapshot.getChildren()) {
                
                String oid = orderSnap.getKey();
                String cId = orderSnap.child("college_id").getValue(String.class);

                if (collegeId.equals(cId)) {
                    String userId = orderSnap.child("user_id").getValue(String.class);
                    String shopId = orderSnap.child("shop_id").getValue(String.class);
                    Long timestamp = orderSnap.child("timestamp").getValue(Long.class);
                    Double amount = orderSnap.child("total_amount").getValue(Double.class);
                    Boolean isPurchased = orderSnap.child("isPurchased").getValue(Boolean.class);

                    // fetch user name
                    DataSnapshot userSnap = FirebaseUtils.getDataSnapshot(db.child("users").child(userId));
                    String userName = userSnap.child("user_name").getValue(String.class);

                    // fetch shop name
                    DataSnapshot shopSnap = FirebaseUtils.getDataSnapshot(db.child("shops").child(shopId));
                    String shopName = shopSnap.child("shop_name").getValue(String.class);

                    // fetch items
                    List<OrderModel.Item> itemList = new ArrayList<>();
                    for (DataSnapshot itemSnap : orderSnap.child("items").getChildren()) {
                        String itemName = itemSnap.child("item_name").getValue(String.class);
                        Integer qty = itemSnap.child("quantity").getValue(Integer.class);
                        itemList.add(new OrderModel.Item(itemName, qty));
                    }

                    orders.add(new OrderModel(
                            oid,
                            userId,
                            userName,
                            itemList,
                            shopName,
                            amount != null ? amount : 0,
                            timestamp != null ? timestamp : 0,
                            isPurchased != null && isPurchased
                    ));
                }
            }
        }

        // sort + top 10
        return orders.stream()
                .sorted((o1, o2) -> Long.compare(o2.getTimeStamp(), o1.getTimeStamp()))
                .limit(limit)
                .collect(Collectors.toList());
    }
}
