package com.saapadu.admin.backend.backend;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicReference;

public class FirebaseUtils {
    public static DataSnapshot getDataSnapshot(DatabaseReference ref) throws InterruptedException {
        final CountDownLatch latch = new CountDownLatch(1);
        final AtomicReference<DataSnapshot> result = new AtomicReference<>();

        ref.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                result.set(dataSnapshot);
                latch.countDown();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                latch.countDown();
            }
        });

        latch.await(); // block until response
        return result.get();
    }
}
