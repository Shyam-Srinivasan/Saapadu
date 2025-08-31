package com.saapadu.admin.backend.backend.controllers;

import com.saapadu.admin.backend.backend.models.ItemModel;
import com.saapadu.admin.backend.backend.services.ItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
public class ItemController {
    @Autowired
    private ItemService itemService;


    @PostMapping("/itemList/createItem")
    ResponseEntity<ItemModel> createItem(@RequestBody ItemModel item) {
        try {
            if (item == null || item.getItemName() == null || item.getCategoryId() == null || item.getImagePath() == null || item.getPrice() == 0 || item.getStockQuantity() == 0) {
                return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
            }
            return new ResponseEntity<>(itemService.createItem(item), HttpStatus.CREATED);
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/itemList/updateItem")
    ResponseEntity<ItemModel> updateItem(@RequestParam String itemId, @RequestBody ItemModel updatedItem) {
        try {
            if (updatedItem == null || itemId == null) {
                return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
            }

            ItemModel item = itemService.fetchItemById(itemId);

            if (item == null) {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }

            item.setItemName(updatedItem.getItemName());
            item.setCategoryId(updatedItem.getCategoryId());
            item.setImagePath(updatedItem.getImagePath());
            item.setStockQuantity(updatedItem.getStockQuantity());

            ItemModel save = itemService.updateItem(item);
            return new ResponseEntity<>(save, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/itemList/fetchItem")
    ResponseEntity<ItemModel> fetchItem(@RequestParam String itemId) {
        try {
            ItemModel item = itemService.fetchItemById(itemId);
            if (item == null) {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
            return new ResponseEntity<>(item, HttpStatus.FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/itemList/fetchItems")
    ResponseEntity<List<ItemModel>> fetchItems(@RequestParam String categoryId) {
        try {
            List<ItemModel> items = itemService.fetchItems(categoryId);
            if (items.isEmpty() || items == null) {
                return new ResponseEntity<>(null, HttpStatus.NO_CONTENT);
            }
            return new ResponseEntity<>(items, HttpStatus.FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/itemList/deleteItem")
    ResponseEntity<ItemModel> deleteItem(@RequestParam String categoryId) {
        try {
            if (itemService.deleteItem(categoryId)) {
                return new ResponseEntity<>(null, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
