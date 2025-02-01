import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallPage extends StatefulWidget {
  @override
  _PaywallPageState createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  String _selectedOption = "Monthly"; // Default selected option
  Package? monthlyPackage;
  Package? annualPackage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if(mounted)
      setState(() {
        monthlyPackage = offerings.current?.monthly;
        annualPackage = offerings.current?.annual;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching offerings: $e");
      if(mounted)
      setState(() {
        isLoading = false;
      });
    }
  }

  String _calculateDiscount(Package? monthly, Package? annual) {
    if (monthly != null && annual != null) {
      // Access pricing details for monthly and annual plans
      final monthlyOption = monthly.storeProduct.subscriptionOptions?.first;
      final annualOption = annual.storeProduct.subscriptionOptions?.first;

      if (monthlyOption != null && annualOption != null) {
        final monthlyPrice = monthlyOption.pricingPhases.first.price.amountMicros;
        final annualPrice = annualOption.pricingPhases.first.price.amountMicros;

        // Calculate the discount
        double totalMonthlyCost = monthlyPrice * 12;
        double discount = ((totalMonthlyCost - annualPrice) / totalMonthlyCost) * 100;

        return "${discount.toStringAsFixed(0)}% OFF";
      }
    }
    return "";
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // Top image
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/paywallimage.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Title and Features
                          Text(
                            "Experience Storytelling Like Never Before with Premium!",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          featureRow("💎   Extra Credits for Crafting Stories."),
                          featureRow("🌍   Multi-language story generation."),
                          featureRow("🎙️   High-quality premium voices."),
                          featureRow("✨   Enjoy an ad-free experience"),
                          const SizedBox(height: 20),
                          // Subscription Options
                          if (monthlyPackage != null)
                            subscriptionOption(
                              "Monthly",
                              "Full access for just ${monthlyPackage!.storeProduct.priceString}/month\n+ Get 100 Credits for Crafting Stories Monthly",
                              isSelected: _selectedOption == "Monthly",
                              onTap: () {
                                if(mounted)
                                setState(() {
                                  _selectedOption = "Monthly";
                                });
                              },
                            ),
                          const SizedBox(height: 10),
                          if (annualPackage != null)
                            subscriptionOption(
                              "Annual",
                              "Full access for just ${annualPackage!.storeProduct.subscriptionOptions?.first.pricingPhases.first.price.formatted}/year \n+ Get 1200 Credits for Crafting Stories Yearly",
                              discount: _calculateDiscount(monthlyPackage, annualPackage),
                              isSelected: _selectedOption == "Annual",
                              onTap: () {
                                if(mounted)
                                setState(() {
                                  _selectedOption = "Annual";
                                });
                              },
                            ),
                          const SizedBox(height: 20),
                          // Continue Button
                          ElevatedButton(
                            onPressed: () async {
                              await _purchaseSelectedOption();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A2259),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Center(
                              child: Text(
                                "Continue",
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Restore Purchases
                          TextButton(
                            onPressed: () async {
                              await _restorePurchases();
                            },
                            child: Text(
                              "Restore",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Close Button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the page
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseSelectedOption() async {
    try {
      Package? selectedPackage =
      _selectedOption == "Monthly" ? monthlyPackage : annualPackage;
      if (selectedPackage != null) {
        CustomerInfo customerInfo = await Purchases.purchasePackage(selectedPackage);
        print("Purchase successful: ${customerInfo.entitlements.active}");
        Navigator.pop(context);
      } else {
        print("No package selected");
      }
    } catch (e) {
      print("Purchase error: $e");
    }
  }

  Future<void> _restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      print("Restore successful: ${customerInfo.entitlements.active}");
    } catch (e) {
      print("Restore error: $e");
    }
  }

  Widget featureRow(String text) {
    return Row(
      children: [

        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget subscriptionOption(String title, String description,
      {String? discount, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF1A2259) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and CircleAvatar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isSelected
                          ? const Color(0xFF1A2259)
                          : Colors.grey.shade300,
                      child: isSelected
                          ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                  ],
                ),
                // Discount Badge
                if (discount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A2259)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      discount,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : const Color(0xFF1A2259),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
