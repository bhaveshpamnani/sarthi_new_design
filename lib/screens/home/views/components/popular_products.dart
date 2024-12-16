import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../Implemention/product_service.dart';
import '../../../../components/skleton/product/products_skelton.dart';
import '../../../../constants.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  final ProductService _productService = ProductService();
  List<dynamic> _popularProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPopularProducts();
  }

  Future<void> _fetchPopularProducts() async {
    try {
      final products = await _productService.getPopularProducts();
      setState(() {
        _popularProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching popular products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Popular products",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        _isLoading
            ? const ProductsSkelton()
            : SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularProducts.length,
            itemBuilder: (context, index) {
              final product = _popularProducts[index];

              // Safely extract fields with fallback values
              final imageUrl = (product['images'] != null &&
                  product['images'].isNotEmpty &&
                  product['images'][0]['url'] is String)
                  ? product['images'][0]['url']
                  : ''; // Fallback to an empty string

              final brandName = product['brand'] ?? 'Unknown Brand';
              final title = product['name'] ?? 'Untitled Product';
              final price = (product['mrpPrice'] ?? 0).toDouble(); // Convert to double
              final priceAfterDiscount = (product['discountPrice'] ?? 0).toDouble(); // Convert to double
              final discountPercent = (product['discount'] ?? 0).toInt(); // Convert to double

              return Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == _popularProducts.length - 1
                      ? defaultPadding
                      : 0,
                ),
                child: ProductCard(
                  image: imageUrl,
                  brandName: brandName,
                  title: title,
                  price: price, // Pass price as int
                  priceAfetDiscount: priceAfterDiscount, // Pass price after discount as int
                  dicountpercent: discountPercent, // Pass discount percent as int
                  press: () async { // Verify the ID is printed correctly
                    final prefs = await SharedPreferences.getInstance();
                    String? userId = prefs.getString('userId');
                   Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductDetailsScreen(productId: product['_id'],userId: userId,)));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
