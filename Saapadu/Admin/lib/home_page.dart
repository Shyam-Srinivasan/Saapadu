import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'stock.dart';
import 'quantity_manager.dart';

// import 'package:rmart/Widgets/popular_items_widget.dart';
// import 'package:rmart/quantity_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  final String collegeName;
  final String shopName;

  @override
  State<HomePage> createState() => _HomePageState();

  const HomePage({
    super.key,
    required this.collegeName,
    required this.shopName,
  });
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  late final PageController _pageController;
  late DatabaseReference _databaseRef;
  Map<String, List<Map<String, dynamic>>> _categoryItems = {};
  List<String> _categories = [];
  StreamSubscription<DatabaseEvent>? _streamSubscription;
  String _selectedCategory = '';
  Map<String, Stock> _stockItems = {};
  File? _selectedImage; // For mobile
  Uint8List? _selectedImageBytes; // For web

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
    _activateListeners();
  }

  /* Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Allow only image files
    );

    if (result != null) {
      if (kIsWeb) {
        // For web, read the file as bytes
        setState(() {
          _selectedImageBytes = result.files.single.bytes;
        });
      } else {
        // For mobile, use the file path
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
      }
    }
  }

  */

  Future<String?> getSelectedShop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedShop');
  }

  Future<void> _loadData() async {
    // Simulate a delay for loading animation
    await Future.delayed(const Duration(milliseconds: 500));
    await getSelectedShop(); // Refresh shop name

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
    return await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _stockItems.forEach((key, value) => value.dispose());
    super.dispose();
  }

  void _activateListeners() async {
    String? shopName = widget.shopName;
    String? collegeName = widget.collegeName;

    _streamSubscription = _databaseRef
        .child('AdminDatabase/$collegeName/Shops/$shopName/Categories/')
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          print("Data from Firebase: $data");

          if (data == null || data is! Map) {
            print('Error: Data is null or not a Map');
            return;
          }

          final Map<String, List<Map<String, dynamic>>> categoryItems = {};
          final List<String> categories = [];
          final Map<String, Stock> stockItems = {};

          data.forEach((categoryName, categoryValue) {
            if (categoryValue is Map) {
              categories.add(categoryName);
              final items = <Map<String, dynamic>>[];

              categoryValue.forEach((itemName, itemValue) {
                if (itemValue is Map) {
                  final item = {
                    'name': itemValue['name'] ?? itemName,
                    'price': itemValue['price'] ?? 0,
                    'image': itemValue['img'] ?? 'assets/img/default.jpeg',
                    'quantity': itemValue['quantity'] ?? 0,
                  };
                  final stock = Stock(
                    foodItem: item,
                    categoryName: categoryName,
                    quantity: item['quantity'],
                    collegeName: collegeName,
                    shopName: shopName,
                  );
                  stockItems[item['name']] = stock;
                  items.add(item);
                }
              });

              categoryItems[categoryName] = items;
            }
          });

          setState(() {
            _isLoading = false;
            _categoryItems = categoryItems;
            _categories = categories;
            _stockItems = stockItems;
            print("Categories: $_categories");
            _selectedCategory = categories.isNotEmpty ? categories.first : '';
            print("Selected Category: $_selectedCategory");
            _pageController.jumpToPage(
              _getPageIndexFromCategory(_selectedCategory),
            );
          });
        });
  }

  void _onPageChanged() {
    final pageIndex = _pageController.page?.round() ?? 0;
    if (_categories.isNotEmpty) {
      final newCategory = _getCategoryFromIndex(pageIndex);
      if (_selectedCategory != newCategory) {
        setState(() {
          _selectedCategory = newCategory;
        });
      }
    }
  }

  void _navigateToPage(int pageIndex, String category) {
    setState(() {
      _selectedCategory = category;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getCategoryFromIndex(int index) {
    print("Index: $index");
    print("Categories length: ${_categories.length}");
    if (index >= 0 && index < _categories.length) {
      print("Category: ${_categories[index]}");
      return _categories[index];
    }
    print("Category: All");
    return 'All';
  }

  int _getPageIndexFromCategory(String category) {
    final index = _categories.indexOf(category);
    return index != -1 ? index : 0;
  }

  void _showAddCategoryDialog() {
    TextEditingController _categoryController = TextEditingController();
    TextEditingController _imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(hintText: "Enter category name"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _imageController,
                decoration: InputDecoration(hintText: "Enter Image Path"),
              ),
              buildImagePreview(), // Display the selected image
              SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: _pickImage,
              //   child: Text("Select Image"),
              // ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                // if (_categoryController.text.isNotEmpty) {
                //   // Upload image to Firebase Storage and get the download URL
                //   String? imageUrl;
                //   if (kIsWeb && _selectedImageBytes != null) {
                //     imageUrl = await _uploadImageToFirebaseWeb(_selectedImageBytes!);
                //   } else if (_selectedImage != null) {
                //     imageUrl = await _uploadImageToFirebase(_selectedImage!);
                //   }

                if (_categoryController.text.isNotEmpty) {
                  // Add the category to Firebase with the image URL
                  _addCategoryToFirebase(
                    _categoryController.text,
                    _imageController.text,
                    // imageUrl ?? 'assets/img/default.jpeg',
                  );

                  // Clear the selected image
                  setState(() {
                    _selectedImage = null;
                    _selectedImageBytes = null;
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addCategoryToFirebase(String categoryName, String? imageUrl) {
    String? shopName = widget.shopName;
    String? collegeName = widget.collegeName;

    // Debugging: Print the Firebase path
    final String firebasePath =
        'AdminDatabase/$collegeName/Shops/$shopName/Categories/$categoryName';
    print("Firebase Path: $firebasePath");

    // Add the category to Firebase with the image URL
    _databaseRef
        .child(firebasePath)
        .set({
          "image": imageUrl, // Image URL
        })
        .then((_) {
          print("Category '$categoryName' added to Firebase successfully.");
          setState(() {
            _categories.add(categoryName); // Update the UI
          });
        })
        .catchError((error) {
          print("Failed to add category: $error");
          // Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to add category: $error"),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  void _showAddFoodDialog(String category) {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController imgPathController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Food Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Food Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Food Name"),
                ),
                // Price
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                // Quantity
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "Quantity"),
                  keyboardType: TextInputType.number,
                ),
                // Image Path
                TextField(
                  controller: imgPathController,
                  decoration: const InputDecoration(labelText: "Image Path"),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            // Add Button
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  // Add the food item to Firebase
                  _addFoodToFirebase(
                    category,
                    nameController.text,
                    int.parse(priceController.text),
                    int.parse(quantityController.text),
                    imgPathController.text.isNotEmpty
                        ? imgPathController.text
                        : "assets/img/default.jpeg",
                  );

                  // Close the dialog
                  Navigator.pop(context);
                } else {
                  // Show an error message if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all fields!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addFoodToFirebase(
    String category,
    String foodName,
    int price,
    int quantity,
    String imagePath,
  ) {
    String? shopName = widget.shopName;
    String? collegeName = widget.collegeName;

    // Debugging: Print the Firebase path
    final String firebasePath =
        'AdminDatabase/$collegeName/Shops/$shopName/Categories/$category/$foodName';
    print("Firebase Path: $firebasePath");

    // Add the food item to Firebase
    _databaseRef
        .child(firebasePath)
        .set({
          "name": foodName,
          "price": price,
          "quantity": quantity,
          "img": imagePath,
        })
        .then((_) {
          print("Food item '$foodName' added to Firebase successfully.");
          setState(() {
            // Update the UI to reflect the new food item
            _categoryItems[category]?.add({
              'name': foodName,
              'price': price,
              'quantity': quantity,
              'image': imagePath,
            });
          });
        })
        .catchError((error) {
          print("Failed to add food item: $error");
          // Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to add food item: $error"),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  // Function to upload image to Firebase Storage
  /* Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('category_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      await storageRef.putFile(imageFile);

      // Get the download URL
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Failed to upload image: $e");
      return null;
    }
  } */

  /* Future<String?> _uploadImageToFirebaseWeb(Uint8List imageBytes) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('category_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      await storageRef.putData(imageBytes);

      // Get the download URL
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Failed to upload image: $e");
      return null;
    }
  } */

  Widget buildImagePreview() {
    if (kIsWeb) {
      // Display image for web
      return _selectedImageBytes != null
          ? Image.memory(
            _selectedImageBytes!,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          )
          : Text("No image selected");
    } else {
      // Display image for mobile
      return _selectedImage != null
          ? Image.file(
            _selectedImage!,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          )
          : Text("No image selected");
    }
  }

  Future<void> showLottieDialog(
    BuildContext parentContext,
    String animation,
    String message,
  ) async {
    late BuildContext dialogContext;
    showDialog(
      context: parentContext,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0, // Remove shadow
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset("img/$animation", height: 150, repeat: false),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Automatically close the dialog after `durationInSeconds`
    await Future.delayed(Duration(seconds: 1));
    if (Navigator.canPop(dialogContext)) {
      Navigator.pop(dialogContext);
    }
  }

  // Edit Food Item
  void editFoodItem(
    BuildContext context,
    String collegeName,
    String shopName,
    String categoryName,
    String foodName,
  ) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child(
      "AdminDatabase/$collegeName/Shops/$shopName/Categories/$categoryName/$foodName",
    );
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController imgPathController = TextEditingController();

    try {
      DatabaseEvent event = await databaseRef.once();
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        nameController.text = data['name'] ?? foodName;
        priceController.text = data['price'].toString();
        quantityController.text = data['quantity'].toString();
        imgPathController.text = data['img'] ?? '';
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Food Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Food Name"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "Quantity"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imgPathController,
                  decoration: const InputDecoration(labelText: "Image Path"),
                ),
              ],
            ),
          ),
          actions: [
            // Delete Food item
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Delete Food Item"),
                      content: const Text(
                        "Are you sure you want to delete this food item?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close Confirmation Dialog
                            await showLottieDialog(
                              context,
                              "Processing.json",
                              "Deleting...",
                            );

                            try {
                              // Delete from database
                              await databaseRef.remove();
                              await showLottieDialog(
                                context,
                                "Success.json",
                                "Deleted Successfully!",
                              );

                              // Close success dialog after 2 seconds
                              await Future.delayed(const Duration(seconds: 2));
                              Navigator.pop(context); // Close edit dialog
                            } catch (error) {
                              await showLottieDialog(
                                context,
                                "Failed.json",
                                "Delete Failed!",
                              );
                              await Future.delayed(const Duration(seconds: 2));
                            }
                            // Navigator.pop(context);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.delete, color: Colors.deepPurple, size: 24),
            ),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            //Save button
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close Edit Dialog
                await showLottieDialog(
                  context,
                  "Processing.json",
                  "Saving Changes...",
                );

                try {
                  // Update database
                  await databaseRef.update({
                    "name": nameController.text,
                    "price": int.parse(priceController.text),
                    "quantity": int.parse(quantityController.text),
                    "img":
                        imgPathController.text.isNotEmpty
                            ? imgPathController.text
                            : "assets/img/default.jpeg",
                  });

                  await showLottieDialog(
                    context,
                    "Success.json",
                    "Changes Saved Successfully!",
                  );

                  // Close success dialog after 2 seconds
                  await Future.delayed(const Duration(seconds: 2));
                } catch (error) {
                  await showLottieDialog(
                    context,
                    "Failed.json",
                    "Update Failed!: $error",
                  );
                  await Future.delayed(const Duration(seconds: 2));
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(
          child: Text(
            widget.shopName,
            style: TextStyle(
              fontSize: height * 0.04,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Row(
                children: [
                  ..._categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.06,
                      ),
                      child: ElevatedButton(
                        onPressed:
                            () => _navigateToPage(
                              _categories.indexOf(category),
                              category,
                            ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              isSelected ? Colors.white : Colors.deepPurple,
                          backgroundColor:
                              isSelected ? Colors.deepPurple : Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(category),
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06,
                    ),
                    child: ElevatedButton(
                      onPressed: _showAddCategoryDialog,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text('+ Add Category'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: height * 0.02,
            thickness: 1,
            color: Colors.deepPurple,
          ),
          Expanded(
            child: LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: Colors.deepPurple,
              backgroundColor: Colors.deepPurple[200],
              animSpeedFactor: 2,
              springAnimationDurationInMilliseconds: 500,

              showChildOpacityTransition: false,

              child: PageView.builder(
                controller: _pageController,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildFoodGrid(_categories[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid(String category) {
    final items =
        category == 'All'
            ? _categoryItems.values.expand((e) => e).toList()
            : _categoryItems[category]?.toList() ?? [];
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    // print("Width is ");
    // print(width);
    // print((width*0.005).toInt());

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (width * 0.005).toInt(),
        crossAxisSpacing: 25,
        mainAxisSpacing: 25,
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              double height = constraints.maxHeight;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showAddFoodDialog(category),
                  child: Container(
                    width: 170,
                    height: 225,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 50, color: Colors.deepPurple),
                          Text(
                            "Add Food",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
        final item = items[index];
        final itemName = item['name'];
        final itemPrice = item['price'];
        final itemImage = item['image'];
        final itemQuantity = item['quantity'];
        final stock = _stockItems[itemName];
        return LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;

            // print("Layout Builder width: $width");
            // print("Layout Builder height:  $height");

            return Container(
              width: 170,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: itemQuantity == 0 ? Colors.red : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.001,
                  vertical: height * 0.001,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(
                            "Out of Stock",
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  itemQuantity == 0
                                      ? Colors.red
                                      : Colors.deepPurple,
                            ),
                          ),
                          onPressed: () => stock?.updateStock(),
                        ),
                        IconButton(
                          onPressed:
                              () => editFoodItem(
                                context,
                                widget.collegeName,
                                widget.shopName,
                                category,
                                itemName,
                              ),
                          icon: Icon(
                            Icons.edit,
                            color: Colors.deepPurple,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          itemImage ?? 'assets/img/default.jpeg',
                          width: double.infinity,
                          height: double.infinity,
                          // Set to fill the height as well
                          fit:
                              BoxFit
                                  .cover, // This will cover the container and fill the width/height
                        ),
                      ),
                    ),

                    Text(
                      " $itemName",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${itemPrice.toInt()}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          itemQuantity > 0
                              ? QuantityManage(
                                foodItem: item,
                                categoryName: category,
                                collegeName: widget.collegeName,
                                shopName: widget.shopName,
                              )
                              : Text(
                                'Out of Stock',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
