import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaywallScreen extends StatefulWidget {
  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late InAppPurchase _inAppPurchase;
  late Stream<List<PurchaseDetails>> _purchaseStream;
  bool _isAvailable = false;
  ProductDetails? _productDetails; // Holds the fetched product details
  final List<String> _productIds = ['craftastory_mothly_premium'];

  @override
  void initState() {
    super.initState();
    _inAppPurchase = InAppPurchase.instance;
    _initialize();
    _fetchProductDetails();
  }

  // Initialize InAppPurchase
  void _initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    setState(() {
      _isAvailable = isAvailable;
    });

    if (_isAvailable) {
      _purchaseStream = _inAppPurchase.purchaseStream;
    }
  }
// Fetch product details from Google Play
  Future<void> _fetchProductDetails() async {
    final ProductDetailsResponse response =
    await InAppPurchase.instance.queryProductDetails(_productIds.toSet());

    if (response.error != null) {
      print("Error fetching product details: ${response.error}");
    } else if (response.productDetails.isNotEmpty) {
      setState(() {
        _productDetails = response.productDetails.first; // First product detail
      });
    } else {
      print("No product details found.");
    }
  }
  // Handle subscription purchase
  void _handlePurchase() async {
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails({'craftastory_mothly_premium'}.toSet());

    if (response.notFoundIDs.isEmpty) {
      final ProductDetails product = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Image Section
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/personwritting2.png', // Replace with your image path
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),

                // Headline Section
                Text(
                  'Ignite Your Child’s Creativity',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock all premium features trusted by thousands of parents.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Premium Features List
                _buildPremiumFeatures(),
                const SizedBox(height: 10),

                // Pricing Section
                if (_productDetails != null)
                  Text(
                    'Monthly subscription for ${_productDetails!.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  const CircularProgressIndicator(), // Show loading spinner while fetching price
                const SizedBox(height: 15),


                // Call-to-Action Button
                ElevatedButton(
                  onPressed: _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start with 3 Days Trial',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 10),
                // Legal Disclaimer
                Text(
                  'Cancel anytime. Terms and conditions apply.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    final features = [
      '+100 Credits for Crafting stories',
      'Multi-language story generation',
      'High-quality premium voices',
      'Exclusive premium stories',
    ];

    return Column(
      children: features
          .map(
            (feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}
