import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
// import 'package:rmart/Widgets/popular_items_widget.dart';
import 'package:user/add_to_cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Categories extends StatefulWidget {
  final String category;

  const Categories({super.key, required this.category});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  bool _isLoading = true;
  late final PageController _pageController;
  late DatabaseReference _databaseRef;
  Map<String, List<Map<String, dynamic>>> _categoryItems = {};
  List<String> _categories = [];
  Map<String, String> _categoryImages = {};
  late StreamSubscription<DatabaseEvent> _streamSubscription;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
    _activateListeners();
  }

  Future<String?> getSelectedShop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedShop');
  }

  Future<String?> getCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName');
  }

  Future<void> _loadData() async {
    // Simulate a delay for loading animation
    await Future.delayed(const Duration(milliseconds: 500));
    await getSelectedShop(); // Refresh shop name

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async{
    setState(() {
      _isLoading = true;
    });
    await _loadData();
    return await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      false;
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _activateListeners() async {
    String? shopName = await getSelectedShop();
    String? collegeName = await getCollegeName();
    _streamSubscription = _databaseRef
        .child('AdminDatabase/$collegeName/Shops/$shopName/Categories/')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      print('Data received: $data');

      if (data == null || data is! Map) {
        print('Error: Data is null or not a Map');
        return;
      }

      final Map<String, List<Map<String, dynamic>>> categoryItems = {};
      final List<String> categories = [];
      final Map<String, String> categoryImages = {};

      (data as Map<dynamic, dynamic>).forEach((key, value) {
        print("key: $key");
        print("value: $value");

        final categoryName = key as String;
        categories.add(categoryName);

        if (value is Map<dynamic, dynamic>) {
          final items = value.entries.map((e) {
            if (e.value is Map<dynamic, dynamic>) {
              final itemData = e.value as Map<dynamic, dynamic>;
              return {
                'name': itemData['name'],
                'price': itemData['price'],
                'image': itemData['img'],
                'quantity': itemData['quantity'],
              };
            } else {
              return null;
            }
          }).where((item) => item != null).toList();

          categoryItems[categoryName] = items.cast<Map<String, dynamic>>();
        } else if (value is String) {
          // Handle the case where the value is a string (e.g., the "image" field)
          categoryImages[categoryName] = value;
          print("Image got: ${categoryImages[categoryName]}");
          print("value of image is $value");
        }
      });

      setState(() {
        _isLoading = false;
        _categoryItems = categoryItems;
        _categories = categories;
        _selectedCategory = widget.category.isEmpty ? categories.first : widget.category;
        _categoryImages = categoryImages;
        _pageController.jumpToPage(_getPageIndexFromCategory(_selectedCategory));
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
    if (index >= 0 && index < _categories.length) {
      return _categories[index];
    }
    return 'All';
  }

  int _getPageIndexFromCategory(String category) {
    final index = _categories.indexOf(category);
    return index != -1 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          children: [
            AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              backgroundColor: Colors.white,
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, top: 8),
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              color: const Color(0x61693BB8),
              height: 1.0,
            ),
          ],
        ),
      ),
      body: LiquidPullToRefresh(
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
    );
  }

  Widget _buildFoodGrid(String category) {
    // Get the items based on the selected category, filter by quantity > 0
    final items = category == 'All'
        ? _categoryItems.values.expand((e) => e).toList()
        : _categoryItems[category]?.toList() ?? [];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/img/Empty.json', // Ensure this path is correct
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            const Text(
              'No items available in this category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 25,
        mainAxisSpacing: 25,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        print(item);
        final itemName = item['name'] ?? 'Unknown Item';
        final itemPrice = item['price'] ?? 0;
        final itemImage = item['image'] ?? 'assets/img/default.jpeg';
        final itemQuantity = item['quantity'] ?? 0;

        return Container(
          width: 170,
          height: 225, // Ensure this matches the height in PopularItemsWidget
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure content is spaced evenly
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.asset(
                      itemImage,
                      height: 150,
                      width: 200,
                      fit: BoxFit.cover, // Ensure the image covers the full height
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      " $itemName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 10),
                      child: Text(
                        "₹${itemPrice.toInt()}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: itemQuantity > 0
                          ? AddToCartButton(foodItem: item) // Show Add to Cart button if in stock
                          : const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
