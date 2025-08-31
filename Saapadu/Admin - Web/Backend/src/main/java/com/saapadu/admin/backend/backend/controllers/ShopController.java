package com.saapadu.admin.backend.backend.controllers;

import com.saapadu.admin.backend.backend.models.ShopModel;
import com.saapadu.admin.backend.backend.services.ShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
public class ShopController {
    
    @Autowired
    private ShopService shopService;

    @GetMapping("/shopList/fetchShop")
    ResponseEntity<List<ShopModel>> fetchShops(@RequestParam String collegeId){
        try{
            List<ShopModel> shops = shopService.fetchShops(collegeId);
            if(shops.isEmpty() || shops == null){
                return new ResponseEntity<>(null, HttpStatus.NO_CONTENT);
            }
            return new ResponseEntity<>(shops, HttpStatus.FOUND);
        } catch (Exception e){
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/shopList/fetchShop-shopId")
    ResponseEntity<ShopModel> fetchShopById(@RequestParam String shopId){
        try{
            ShopModel shop = shopService.fetchShopById(shopId);
            if(shop == null){
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
            return new ResponseEntity<>(shop, HttpStatus.FOUND);
        } catch (Exception e){
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/shopList/updateShop")
    ResponseEntity<ShopModel> updateShop(@RequestParam String shopId, @RequestBody ShopModel updatedShop){
        try{
            // TODO Should check updatedShop.getCollegeId() == null and set shop.setCollegeId(updatedShop.getCollegeId())
            if(updatedShop == null || updatedShop.getShopName() == null || updatedShop.getPassword() == null ){
                return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
            }
            ShopModel shop = shopService.fetchShopById(shopId);

            shop.setShopName(updatedShop.getShopName());
            shop.setPassword(updatedShop.getPassword());

            return new ResponseEntity<>(shopService.updateShop(shop), HttpStatus.CREATED);
        } catch (Exception e){
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/shopList/createShop")
    ResponseEntity<ShopModel> createShop(@RequestBody ShopModel shop){
        try{
            if(shop == null || shop.getShopName() == null || shop.getPassword() == null || shop.getCollegeId() == null){
                return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
            }
            return new ResponseEntity<>(shopService.createShop(shop), HttpStatus.CREATED);
        } catch (Exception e){
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/shopList/deleteShop")
    void deleteShopById(@RequestParam String shopId){
        try{
            shopService.deleteShop(shopId);
        } catch (Exception e){
            throw new RuntimeException();
        }
    }
}
