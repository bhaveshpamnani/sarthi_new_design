import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Implemention/wishlist_service.dart';
import '../../../components/product/product_card.dart';
import '../../product/views/product_details_screen.dart';

class WishListScreen extends StatefulWidget {
  WishListScreen({super.key, required this.userId});
  final String userId;

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  late WishListService _wishlistService;
  List<dynamic> _wishlistItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _wishlistService = WishListService();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    try {
      final result = await _wishlistService.getUserWishList(widget.userId);
      if (result["success"]) {
        setState(() {
          _wishlistItems = result["wishlist"] ?? [];
          _isLoading = false;
        });
        print("Wishlist fetched successfully: ${_wishlistItems.length} items");
      } else {
        setState(() {
          _errorMessage = result["message"] ?? "An error occurred.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load wishlist: $e";
        _isLoading = false;
      });
      print("Error fetching wishlist: $e"); // For debugging purposes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
          ? Center(
        child: Text(
          _errorMessage.isNotEmpty
              ? _errorMessage
              : "Your wishlist is empty",
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverPadding(
            padding:  EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  // Guard against invalid indices
                  if (index >= _wishlistItems.length) {
                    print("Index out of range: $index");
                    return SizedBox.shrink();
                  }

                  final wishList = _wishlistItems[index];
                  // Extract fields safely
                  final imageUrl = (wishList['image'] != null &&
                      wishList['image'].isNotEmpty &&
                      wishList['image'][0]['url'] is String)
                      ? wishList['image'][0]['url']
                      : 'https://via.placeholder.com/150'; // Default image
                  return ProductCard(
                    image: imageUrl,
                    brandName: _wishlistItems[index]['brand'] ?? 'Unknown',
                    title: wishList['name'] ?? 'No Name',
                    price: (wishList['mrpPrice'] ?? 0).toDouble(),
                    priceAfetDiscount:
                    (wishList['discountPrice'] ?? 0).toDouble(),
                    dicountpercent:
                    (wishList['discount'] ?? 0).toInt(),
                    press: () async {
                      final prefs = await SharedPreferences.getInstance();
                      String? userId = prefs.getString('userId');
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(
                              productId: wishList['productId'],
                              userId: userId,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not authenticated")),
                        );
                      }
                    },
                  );
                },
                childCount: _wishlistItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
