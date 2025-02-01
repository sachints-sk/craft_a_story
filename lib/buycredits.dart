import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async'; // Import the dart:async library
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreditsBalanceCard.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class PurchaseCreditsPage extends StatefulWidget {
  const PurchaseCreditsPage({Key? key}) : super(key: key);

  @override
  State<PurchaseCreditsPage> createState() => _PurchaseCreditsPageState();
}

class _PurchaseCreditsPageState extends State<PurchaseCreditsPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = []; // Store loaded product details
  bool _isAvailable = false; // Check if IAP is available
  bool _isPurchasing = false; // Track purchase process
  bool _isLoading = true; // Track initial product loading
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  RewardedAd? _rewardedAd;
  final String adUnitId = 'ca-app-pub-7424152248887728/9532778651';


  @override
  void initState() {
    super.initState();

    // Set up listener for purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
          (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        print('PurchaseStream error: $error');
      },
    );

    // Initialize and load products
    _initIAP();
    _loadRewardedAd();
  }

  // Function to load the rewarded ad with SSV (userId)
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
          });
          print("Rewarded Ad Loaded");

          // Set userId for Server-Side Verification (SSV)
          ad.setImmersiveMode(true); // Optional: Enables full-screen immersive mode
          ad.setServerSideOptions(ServerSideVerificationOptions(userId: _getFirebaseUID()));

        },
        onAdFailedToLoad: (LoadAdError error) {
          print("Rewarded Ad Failed to Load: ${error.message}");
        },
      ),
    );
  }

  // Function to show the rewarded ad
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          print("Rewarded Ad Dismissed");

          ad.dispose();
          _loadRewardedAd(); // Load a new ad after the previous one is dismissed
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          print("Failed to show ad: ${error.message}");
          ad.dispose();
          _loadRewardedAd();
        },
      );

      _rewardedAd!.setServerSideOptions(
        ServerSideVerificationOptions(userId: _getFirebaseUID()),
      );


      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print("User earned reward: ${reward.amount} ${reward.type}");
          // You can give the user their reward here, e.g., unlocking content
        },
      );

      _rewardedAd = null; // Set ad to null to prevent re-use
    } else {
      print("Ad not ready yet");
    }
  }



  Future<void> _initIAP() async {
    // Check for availability
    final available = await _inAppPurchase.isAvailable();
    setState(() {
      _isAvailable = available;
    });

    if (available) {
      await _loadProducts(); // Load product details
    }
  }

  // Load product details
  Future<void> _loadProducts() async {
    Set<String> productIds = {
      '40_credits',
      '100_credits',
      '200_credit',

    };

    ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    } else {
      setState(() {
        _products = response.productDetails;
      });
    }

    setState(() {
      _isLoading = false; // Hide the loading indicator
    });
  }

// Buy a product
  Future<void> _buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    // Buy consumable
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    setState(() {
      _isPurchasing = true; // Set purchasing state
    });
  }

  // Function to get the Firebase UID
  String _getFirebaseUID() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? "default_uid"; // Use "default_uid" if user is not signed in
  }

  // Handle purchase updates
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('Purchase pending: ${purchaseDetails.productID}');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print('Purchase error: ${purchaseDetails.error}');
          setState(() {
            _isPurchasing = false; // Reset purchasing state on error
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print('Purchase successful: ${purchaseDetails.productID}');
          // Deliver the product
          await _deliverProduct(purchaseDetails);
          // Call the Cloud Function to update credits
          await _updateCredits(purchaseDetails);
          // ...
          // Complete the purchase
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
            setState(() {
              _isPurchasing = false; // Reset purchasing state after completing
            });
          }
        }
      }
    });
  }

  // Deliver the purchased product (update balance, unlock features, etc.)
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Add your logic here to handle the purchased product
    // For example, update user's story balance or unlock features.
  }

  Future<void> _updateCredits(PurchaseDetails purchaseDetails) async {
    // 1. Get the product ID
    final productId = purchaseDetails.productID;
    if (productId == null) {
      print('Error: Product ID is null');
      return; // Exit the function if productId is null
    }

    // 2. Get the purchase token
    final purchaseToken = purchaseDetails.verificationData?.serverVerificationData;
    if (purchaseToken == null) {
      print('Error: Purchase token is null');
      return; // Exit the function if purchaseToken is null
    }

    // 3. Get the user's ID token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Error: User is not signed in');
      return; // Exit the function if user is not signed in
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      print('Error: Failed to fetch ID token');
      return; // Exit the function if ID token is null
    }

    // 4. Create the data to send to the Cloud Function
    final data = {
      'productId': productId,
      'purchaseToken': purchaseToken,
    };

    try {
      // 5. Call the Cloud Function using http.post
      final response = await http.post(
        Uri.parse('https://us-central1-craft-a-story.cloudfunctions.net/updateUserCredits'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Send ID token in the header
        },
        body: jsonEncode(data),
      );

      // 6. Handle the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Credits updated successfully: ${responseData['message']}');

        // Display a success message, check if the widget is still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credits updated!')),
          );
        }
      } else {
        print('Error updating credits: ${response.statusCode}');
        print('Error message: ${response.body}');

        // Display an error message, check if the widget is still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update credits.')),
          );
        }
      }
    } catch (e) {
      print('Error calling Cloud Function: $e');

      // Handle the error appropriately, check if the widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update credits.')),
        );
      }
    }
  }



  @override
  void dispose() {
    _subscription.cancel(); // Cancel the listener
    _rewardedAd?.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black, ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text("Shop Credits",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black, fontWeight: FontWeight.bold)),
      ),
      body:  _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
          //  _buildBalanceCard(balance: 25), // Replace with actual balance

            _buildBalanceCard(),
            const SizedBox(height: 10),
            watchad(),
            const SizedBox(height: 18),
             Text(
              'Buy More Credits!',
               style: GoogleFonts.poppins(
                 fontWeight: FontWeight.w700, // Use Bold 700
                 fontSize: 24,                // Font size example
               ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose from our curated story packages.',
              style: GoogleFonts.poppins(
                 // Use Bold 700
                fontSize: 16,                // Font size example
              ),
            ),
            const SizedBox(height: 20),

            // Updated Story Packages with In-App Purchase
            if (_isAvailable)
              ..._products.map((product) {
                // Assuming your product IDs are named the same as your titles (adjust if needed)
                int discount = 0;
                String desciptionofproduct="4 Stories (40 credits)";
                String imagepath='assets/book4.png';

                if (product.description == "Storytime Bundle") {
                  desciptionofproduct="10 Stories (100 Credits)";
                  discount = 10;
                 imagepath= 'assets/book10.png';
                } else if (product.description == 'Epic Tale Collection') {
                  desciptionofproduct="20 Stories (200 Credits)";
                  discount = 15;
                  imagepath='assets/book20.png';
                }
                return _buildStoryPackageCard(
                  imagePath: imagepath,
                  // Replace with actual image paths based on product ID
                  title: product.description,
                  description:desciptionofproduct,
                  originalPrice: product.rawPrice.toString(),
                  discountedPrice: product.price.toString(),
                  discountPercentage: discount,
                  product: product, // Disable button during purchase
                );
              }).toList(),

            const SizedBox(height: 20),

            // Restore Purchases Button


            // Terms and Conditions Link

          ],
        ),
      ),
    );
  }
Widget watchad(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.0)
      ),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Image.asset('assets/coin.png',
                    height: 65,
                    width: 65),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Get Free Credits',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                          'Watch a short video ad to earn 2 free Credits instantly!',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _rewardedAd != null ? _showRewardedAd : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF010137),
                              padding: const EdgeInsets.symmetric(vertical: 12)
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, color: Colors.white, size: 20,),
                              SizedBox(width: 8,),
                              Text(
                                'Watch Ad',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )
                            ],),
                        ),
                      ),
                    ],
                  ),
                ),
              ])
      ),
    );
}
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF00001E),
                Color(0xFF17148E),
              ]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monetization_on, // You can change to your specific coin icon
                color: Colors.yellow,
                size: 30.0,
              ),
              const SizedBox(width: 10.0),
              const Text(
                'Your Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  '...',
                  style: TextStyle(color: Colors.white, fontSize: 22 ,  fontWeight: FontWeight.bold),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  'Error',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                final userCredits = userData?['credits'] ?? 0;

                return Text(
                  '$userCredits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }

              return const Text(
                '0',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPackageCard({
    required String imagePath,
    required String title,
    required String originalPrice,
    required String discountedPrice,
    required String description,
    required int discountPercentage,
    required ProductDetails product,
  }) {


    // Get the currency symbol from the product details
    final currencySymbol = NumberFormat.simpleCurrency(name: product.currencyCode).currencySymbol;
    return Card(
      elevation: 3,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Card Content
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins( // Apply GoogleFonts here
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],

                        ),
                      ),


                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$currencySymbol $originalPrice',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          if (!_isPurchasing)
                            ElevatedButton(
                              onPressed: () => _buyProduct(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A2259),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Discount Badge (only show if there's a discount)

        ],
      ),
    );
  }

// ... your existing code ...
}