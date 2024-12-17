import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:lottie/lottie.dart';
import 'processingpageUserCreatedStory.dart';
import 'package:page_transition/page_transition.dart';
import 'processingpageaudioUserCreatedStory.dart';
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

enum UserMembership { normal,  proPremium }


class LanguageAudioPageUserCreatedStory extends StatefulWidget {
  final String story; // Receive the prompt
  final String title;
  final String mode;
  final bool isvideo;


  const LanguageAudioPageUserCreatedStory({Key? key, required this.story,required this.isvideo , required this.title, required this.mode}) : super(key: key);

  @override
  State<LanguageAudioPageUserCreatedStory> createState() => _LanguageAudioPageUserCreatedStoryState();
}

class _LanguageAudioPageUserCreatedStoryState extends State<LanguageAudioPageUserCreatedStory> {
  String? _selectedLanguage;
  String? _selectedVoice;
  List<String> _availableVoices = [];
  bool _isLoading = false;
  bool _subscribed =false;


  List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'code': 'en-US'},

  ];

  final Map<String, List<String>> _voicesByLanguage = {

    'en-US': ['en-US-Standard-A', 'en-US-Standard-B', 'en-US-Standard-C', 'en-US-Standard-D', 'en-US-Standard-E', 'en-US-Standard-F', 'en-US-Standard-G', 'en-US-Standard-H', 'en-US-Standard-I','en-US-Standard-J',  'en-US-Wavenet-A', 'en-US-Wavenet-B', 'en-US-Wavenet-C', 'en-US-Wavenet-D', 'en-US-Wavenet-E', 'en-US-Wavenet-F', 'en-US-Wavenet-G', 'en-US-Wavenet-H', 'en-US-Wavenet-I', 'en-US-Wavenet-J','en-US-Neural2-A','en-US-Neural2-C','en-US-Neural2-D','en-US-Neural2-E','en-US-Neural2-F','en-US-Neural2-G','en-US-Neural2-H','en-US-Neural2-I','en-US-Neural2-J','en-US-News-K','en-US-News-L','en-US-News-N','en-US-Casual-K','en-US-Journey-D','en-US-Journey-F','en-US-Journey-O','en-US-Studio-O','en-US-Studio-Q'],
    };

  UserMembership _currentMembership = UserMembership.normal;

  // Function to fetch the user's membership level
  Future<UserMembership> _fetchUserMembership() async {
    if (_subscribed)
      return UserMembership.proPremium;
    else
      return UserMembership.normal;
  }

  @override
  void initState() {
    super.initState();
    _configureSDK();
    _setupIsPro();
    // Fetch the user's membership level first
    _fetchUserMembership().then((membership) {
      _currentMembership = membership; // Update _currentMembership

      // Then, fetch available voices based on the membership
      _fetchAvailableVoices();
    });
  }



  Future<void> _fetchAvailableVoices() async {
    _updateAvailableVoices();
  }

  Future<void> _setupIsPro() async{
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['Premium'];
      setState(() {
        _subscribed= entitlement?.isActive ?? false;
      });
    });
  }
  Future<void> _configureSDK() async {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration? configuration;

    if(Platform.isAndroid){
      configuration=PurchasesConfiguration("goog_ROHmfEQIqmPakpNaNfXYdMByLKh");
    }


    if(configuration != null){
      await Purchases.configure(configuration);
      //  final paywallResult =await RevenueCatUI.presentPaywallIfNeeded("Premium",displayCloseButton: true);
      //  print('Paywall Result: $paywallResult');
    }

  }



  void _updateAvailableVoices() {
    setState(() {
      // Filter voices based on user membership
      _availableVoices = _voicesByLanguage[_selectedLanguage] ?? [];

      if (_currentMembership == UserMembership.normal) {
        // Normal users: Only English (US) available
        // Create a new _languages list based on filtering
        final newLanguages = _languages.where((language) => language['code'] == 'en-US').toList();
        _languages = newLanguages; // Assign the new list to _languages

        // Only standard voices for normal users
        _availableVoices = _availableVoices.where((voice) => voice.contains('Standard')).toList();
      }  else if (_currentMembership == UserMembership.proPremium) {
        // Pro Premium users: Can choose any language and voice
        // No filtering needed
      }

      // Set the initially selected voice
      _selectedVoice = _availableVoices.isNotEmpty ? _availableVoices[0] : null;
    });
  }


  // Custom dropdown button builder (only two parameters now)
  Widget _customDropdownBuilder(BuildContext context, String? item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute elements
        children: [
          Text(
            item ?? 'Select Language',
            style: const TextStyle(fontSize: 16),
          ),
          // Premium tag only if the user is not Pro Premium

        ],
      ),
    );
  }

  Widget _customPopupItemBuilder(
      BuildContext context, String item, bool isSelected, bool isDisabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item,
            style: TextStyle(
              color: isDisabled ? Colors.grey : Colors.black,
            ),
          ),
          // Show Pro Premium tag only if the item is disabled

        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,color: Colors.black,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Select Audio & Language',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              SizedBox(
                height: 250,
                child: Lottie.asset('assets/language2.json'),
              ),

              const SizedBox(height: 20),



              // Subheading
              const Text(
                'Let your story come to life with the perfect language and voice.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),


              // Searchable dropdown for language selection
              DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  showSearchBox: true, // Enable search box
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: "Search Language",
                      hintText: "Type to search...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                    ),
                  ),
                  itemBuilder: _customPopupItemBuilder, // Updated to match new signature
                  disabledItemFn: (String s) {
                    // Disable items based on membership
                    if (_currentMembership == UserMembership.normal ) {
                      return !s.contains("English (US)"); // Disable non-English (US) languages
                    } else {
                      return false; // All languages are enabled
                    }
                  },
                ),
                items: (String filter, LoadProps? props) {
                  return _languages.map((language) => language['name']!).toList();
                },

                dropdownBuilder: _customDropdownBuilder, // Updated to match new signature


                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = _languages.firstWhere((lang) => lang['name'] == newValue)['code'];
                  });
                  _updateAvailableVoices();
                },
                selectedItem: _selectedLanguage != null
                    ? _languages.firstWhere((lang) => lang['code'] == _selectedLanguage)!['name']
                    : null,
              ),

// Show the "Note" only if the user is not Pro Premium



              const SizedBox(height: 20),
              // Dropdown for voice selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(

                  labelText: "Select Voice",
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                value: _selectedVoice,
                items: _availableVoices.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged:
                _currentMembership == UserMembership.normal
                    ? null // Disable voice selection
                    : (String? newValue) {
                  setState(() {
                    _selectedVoice = newValue;
                  });
                },
              ),
// Show the "Note" only if the user is not Pro Premium
              if (_currentMembership != UserMembership.proPremium)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Upgrade to Premium to explore premium voice selections.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),


              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedLanguage != null && _selectedVoice != null) {

                    if(widget.isvideo){
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ProcessingPageUserCreatedStory(story: widget.story, title: widget.title,language :_selectedLanguage!,voice: _selectedVoice!,mode:widget.mode),
                        ),
                      );
                    }else{
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ProcessingPageAudioUserCreatedStory (story: widget.story, title: widget.title,language :_selectedLanguage!,voice: _selectedVoice!,mode:widget.mode),
                        ),
                      );
                    }




                    // Pass selected language and voice to next screen or function

                  } else {
                    // Show a message asking the user to select both language and voice
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select both language and voice'),
                      ),
                    );
                  }
                },style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2259),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
                child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),


              if (_isLoading) // Show loading indicator while fetching voices
                const Center(child: CircularProgressIndicator()),

            ],
          ),
        ));
  }
}