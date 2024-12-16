import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop/Implemention/wishlist_service.dart';
import 'package:shop/components/buy_full_ui_kit.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import 'package:shop/route/screen_export.dart';

import '../../../Implemention/product_service.dart';
import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  var productId;
  var userId;
  ProductDetailsScreen(
      {super.key, required this.productId, required this.userId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String productId;
  ProductService apiService = ProductService();
  // final PageController _pageController = PageController();
  Map<String, dynamic>? product;
  List<String> _imageList = [];
  List<String> sizes = [];
  List<String> colors = [];
  String? selectedSize;
  String? selectedColor;
  WishListService wishListService = WishListService();
  bool isInBookmark = false;

  @override
  void initState() {
    super.initState();

    // Extract the product ID from arguments
    // final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    productId = widget.productId;
    // Fetch product details based on the ID (if needed)
    _fetchProductDetails(productId);
    _getWishListStatus();
  }

  Future<void> _fetchProductDetails(String productID) async {
    try {
      final fetchedProduct = await apiService.getProductById(productID);
      if (fetchedProduct != null) {
        setState(() {
          product = fetchedProduct;
          _imageList =
              List<String>.from(product!['images']?.map((e) => e['url']) ?? []);
          sizes = List<String>.from(product!['sizes'] ?? []);
          colors = List<String>.from(product!['colors'] ?? []);
        });
      } else {
        print('No product found for ID: $productID');
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  // Method to fetch the wishlist status
  void _getWishListStatus() async {
    final result = await wishListService.getWishListStatus(
        widget.userId, widget.productId);
    if (result["success"]) {
      setState(() {
        isInBookmark = result["isInWishlist"];
      });
    } else {
      print("Error fetching wishlist status: ${result["message"]}");
    }
  }

  Future<void> handleToggleWishList() async {
    final result =
        await wishListService.toggleWishList(widget.userId, widget.productId);
    if (result["success"]) {
      setState(() {
        isInBookmark = result["isInWishlist"];
      });
    } else {
      print("Error toggling Bookmark: ${result["message"]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: product == null
          ? const SizedBox.shrink() // No bottom navigation if loading
          : product?["isAvailable"] == true
              ? CartButton(
                  price: product!["discountPrice"].toString(),
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const ProductBuyNowScreen(),
                    );
                  },
                )
              : NotifyMeCard(
                  isNotify: false,
                  onChanged: (value) {},
                ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                Positioned(
                  right: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: IconButton(
                      onPressed: handleToggleWishList,
                      icon: Icon(
                        CupertinoIcons.heart_fill,
                        color: isInBookmark ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ProductImages(
              images: _imageList,
            ),
            ProductInfo(
              brand: product?["brand"] ?? "Unknown",
              title: product?["name"] ?? "No Title",
              isAvailable: product?["isAvailable"] == true,
              description: product?["description"] ?? "No description",
              rating: product?['ratings']?['averageRating']?.toString() ??
                  'No rating available',
              numOfReviews:
                  product?['ratings']?['numberOfRatings']?.toString() ??
                      'No reviews',
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "Product Details",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const BuyFullKit(
                      images: ["assets/screens/Product detail.png"]),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Shipping Information",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const BuyFullKit(
                    images: ["assets/screens/Shipping information.png"],
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Returns",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            // const SliverToBoxAdapter(
            //   child: Padding(
            //     padding: EdgeInsets.all(defaultPadding),
            //     child: ReviewCard(
            //       rating: 4.3,
            //       numOfReviews: 128,
            //       numOfFiveStar: 80,
            //       numOfFourStar: 30,
            //       numOfThreeStar: 5,
            //       numOfTwoStar: 4,
            //       numOfOneStar: 1,
            //     ),
            //   ),
            // ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: index == 4 ? defaultPadding : 0),
                    child: ProductCard(
                      image: productDemoImg2,
                      title: "Sleeveless Tiered Dobby Swing Dress",
                      brandName: "LIPSY LONDON",
                      price: 24.65,
                      priceAfetDiscount: 20.99,
                      dicountpercent: 25,
                      press: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
