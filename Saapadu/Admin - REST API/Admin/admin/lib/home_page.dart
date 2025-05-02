import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'RealtimeDatabaseConnection.dart';
import 'stock.dart';
import 'quantity_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  final String collegeName;
  final String shopName;

  @override
  State<HomePage> createState() => _HomePageState();
  const HomePage({super.key, required this.collegeName, required this.shopName});
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  late final PageController _pageController;
  Map<String, List<Map<String, dynamic>>> _categoryItems = {};
  List<String> _categories = [];
  String _selectedCategory = '';
  Map<String, Stock> _stockItems = {};
  File? _selectedImage; // For mobile
  Uint8List? _selectedImageBytes; // For web

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
    // _activateListeners();
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    RealtimeDatabaseService.listenToShopData(
      collegeName: widget.collegeName,
      shopName: widget.shopName,
      onData: (data) {
        if (mounted) {
          setState(() {
            _processData(data);
            _isLoading = false;
          });
        }
      },
    );
  }

  void _processData(Map<String, dynamic> data) {
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
              collegeName: widget.collegeName,
              shopName: widget.shopName,
            );
            stockItems[item['name']] = stock;
            items.add(item);
          }
        });

        categoryItems[categoryName] = items;
      }
    });

    _categoryItems = categoryItems;
    _categories = categories;
    _stockItems = stockItems;
    _selectedCategory = categories.isNotEmpty ? categories.first : '';
  }

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
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    RealtimeDatabaseService.cancelAllListeners();
    _stockItems.forEach((key, value) => value.dispose());
    super.dispose();
  }

  void _activateListeners() async {
    String? shopName = widget.shopName;
    String? collegeName = widget.collegeName;

    final url = Uri.parse(
        "https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/$collegeName/Shops/$shopName/Categories.json");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || data is! Map) {
          // print('Error: Data is null or not a Map');
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
              _getPageIndexFromCategory(_selectedCategory));
        });
      } else {
        // print("Error: Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // print("Error: An exception occurred while fetching data: $e");
    }
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
    // print("Index: $index");
    // print("Categories length: ${_categories.length}");
    if (index >= 0 && index < _categories.length) {
      // print("Category: ${_categories[index]}");
      return _categories[index];
    }
    // print("Category: All");
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
                  if (_categoryController.text.isNotEmpty) {
                    _addCategoryToFirebase(
                        _categoryController.text,
                        _imageController.text
                    );

                    setState(() {
                      _selectedImage = null;
                      _selectedImageBytes = null;
                    });

                    Navigator.of(context).pop();
                  }
                }
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCategoryToFirebase(String categoryName,
      String? imageUrl) async {
    String? shopName = widget.shopName;
    String? collegeName = widget.collegeName;

    final String firebaseUrl =
        "https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/$collegeName/Shops/$shopName/Categories/$categoryName.json";

    try {
      final response = await http.put(
        Uri.parse(firebaseUrl),
        body: jsonEncode({"image": imageUrl}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        // print("Category '$categoryName' added to Firebase successfully.");
        setState(() {
          _categories.add(categoryName);
        });
      } else {
        // print("Failed to add category. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Failed to add category. Status code: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // print("Failed to add category: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add category: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Food Name",
                  ),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: "Price",
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: "Quantity",
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imgPathController,
                  decoration: const InputDecoration(
                    labelText: "Image Path",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  _addFoodToFirebase(
                    category,
                    nameController.text,
                    int.parse(priceController.text),
                    int.parse(quantityController.text),
                    imgPathController.text.isNotEmpty
                        ? imgPathController.text
                        : "assets/img/default.jpeg",
                  );

                  Navigator.pop(context);
                } else {
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

  Future<void> _addFoodToFirebase(String category, String foodName, int price,
      int quantity, String imagePath) async {
    String? shopName = widget.shopName;
    String? collegeName = widget.collegeName;

    final String firebaseUrl =
        "https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/$collegeName/Shops/$shopName/Categories/$category/$foodName.json";

    try {
      final response = await http.put(
        Uri.parse(firebaseUrl),
        body: jsonEncode({
          "name": foodName,
          "price": price,
          "quantity": quantity,
          "img": imagePath,
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        // print("Food item '$foodName' added to Firebase successfully.");
        setState(() {
          _categoryItems[category]?.add({
            'name': foodName,
            'price': price,
            'quantity': quantity,
            'image': imagePath,
          });
        });
      } else {
        // print("Failed to add food item. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Failed to add food item. Status code: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // print("Failed to add food item: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add food item: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildImagePreview() {
    if (kIsWeb) {
      return _selectedImageBytes != null
          ? Image.memory(
        _selectedImageBytes!,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      )
          : Text("No image selected");
    } else {
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

  Future<void> showLottieDialog(BuildContext parentContext, String animation,
      String message) async {
    late BuildContext dialogContext;
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
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

    await Future.delayed(Duration(seconds: 1));
    if (Navigator.canPop(dialogContext)) {
      Navigator.pop(dialogContext);
    }
  }

  void editFoodItem(BuildContext context, String collegeName, String shopName,
      String categoryName, String foodName) async {
    final Uri databaseUrl = Uri.parse(
        "https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/$collegeName/Shops/$shopName/Categories/$categoryName/$foodName.json");
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController imgPathController = TextEditingController();

    try {
      final response = await http.get(databaseUrl);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        nameController.text = data['name'] ?? foodName;
        priceController.text = data['price'].toString();
        quantityController.text = data['quantity'].toString();
        imgPathController.text = data['img'] ?? '';
      }
    } catch (e) {
      // print("Error fetching data: $e");
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
                    TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Food Name",
                        )
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                          labelText: "Price"
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                          labelText: "Quantity"
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: imgPathController,
                      decoration: const InputDecoration(
                          labelText: "Image Path"
                      ),
                    ),
                  ]
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Food Item"),
                            content: const Text(
                                "Are you sure you want to delete this food item?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await showLottieDialog(
                                      context, "Processing.json",
                                      "Deleting...");

                                  try {
                                    await http.delete(databaseUrl);
                                    await showLottieDialog(
                                        context, "Success.json",
                                        "Deleted Successfully!");

                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    Navigator.pop(context);
                                  } catch (error) {
                                    await showLottieDialog(
                                        context, "Failed.json",
                                        "Delete Failed!");
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                  }
                                },
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        }
                    );
                  },
                  icon: Icon(
                      Icons.delete,
                      color: Colors.deepPurple,
                      size: 24
                  )
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await showLottieDialog(
                      context, "Processing.json", "Saving Changes...");

                  try {
                    await http.patch(
                      databaseUrl,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "name": nameController.text,
                        "price": int.parse(priceController.text),
                        "quantity": int.parse(quantityController.text),
                        "img": imgPathController.text.isNotEmpty
                            ? imgPathController.text
                            : "assets/img/default.jpeg",
                      }),
                    );

                    await showLottieDialog(
                        context, "Success.json", "Changes Saved Successfully!");

                    await Future.delayed(const Duration(seconds: 2));
                  } catch (error) {
                    await showLottieDialog(
                        context, "Failed.json", "Update Failed!: $error");
                    await Future.delayed(const Duration(seconds: 2));
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        }
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
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
                          child: ElevatedButton(
                            onPressed: () => _navigateToPage(_categories.indexOf(category), category),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: isSelected ? Colors.white : Colors.deepPurple,
                              backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(category),
                          )
                      );
                    }).toList(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
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
                    )
                  ],
                ),
              ),
            ),
            Divider(
              height: height*0.02,
              thickness: 1,
              color: Colors.deepPurple,
            ),
            Expanded(
              child: LiquidPullToRefresh(
                onRefresh: _handleRefresh,
                color:Colors.deepPurple,
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
            )
          ],
        )
    );
  }

  Widget _buildFoodGrid(String category){
    final items = category == 'All'
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
        itemBuilder: (context, index){
          if(index == items.length){
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
                            offset: const Offset(0, 3)
                          )
                        ]
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 50,
                              color: Colors.deepPurple,
                            ),
                            Text(
                              "Add Food",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple
                              ),
                            )
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
            builder: (context, constraints){
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
                    )
                  ]
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
                                color: itemQuantity == 0 ? Colors.red : Colors.deepPurple
                              )
                            ),
                            onPressed: () => stock?.updateStock(),
                          ),
                          IconButton(
                            onPressed: () => editFoodItem(context, widget.collegeName, widget.shopName, category, itemName),
                            icon: Icon(
                              Icons.edit,
                              color: Colors.deepPurple,
                              size: 16,
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.asset(
                            itemImage ?? 'assets/img/default.jpeg',
                            width: double.infinity,
                            height: double.infinity,  // Set to fill the height as well
                            fit: BoxFit.cover,        // This will cover the container and fill the width/height
                          ),
                        ),
                      ),

                      Text(
                        " $itemName",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(
                          height: 5
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹${itemPrice.toInt()}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
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
                                color: Colors.red
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }
}