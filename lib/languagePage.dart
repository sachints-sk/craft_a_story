import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:lottie/lottie.dart';
import 'processingpagetest.dart';
import 'package:page_transition/page_transition.dart';
import 'processingpageaudio.dart';
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

enum UserMembership { normal,  proPremium }


class LanguageAudioPage extends StatefulWidget {
  final String prompt; // Receive the prompt
  final String title;
  final String mode;
  final bool isvideo;


  const LanguageAudioPage({Key? key, required this.prompt,required this.title,required this.mode,required this.isvideo}) : super(key: key);

  @override
  State<LanguageAudioPage> createState() => _LanguageAudioPageState();
}

class _LanguageAudioPageState extends State<LanguageAudioPage> {
  String? _selectedLanguage;
  String? _selectedVoice;
  List<String> _availableVoices = [];
  bool _isLoading = false;
  bool _subscribed =false;

   List<Map<String, String>> _languages = [
    {'name': 'Afrikaans (South Africa)', 'code': 'af-ZA'},
    {'name': 'Arabic', 'code': 'ar-XA'},
    {'name': 'Basque (Spain)', 'code': 'eu-ES'},
    {'name': 'Bengali (India)', 'code': 'bn-IN'},
    {'name': 'Bulgarian (Bulgaria)', 'code': 'bg-BG'},
    {'name': 'Catalan (Spain)', 'code': 'ca-ES'},
    {'name': 'Chinese (Hong Kong)', 'code': 'yue-HK'},
    {'name': 'Czech (Czech Republic)', 'code': 'cs-CZ'},
    {'name': 'Danish (Denmark)', 'code': 'da-DK'},
    {'name': 'Dutch (Belgium)', 'code': 'nl-BE'},
    {'name': 'Dutch (Netherlands)', 'code': 'nl-NL'},
    {'name': 'English (Australia)', 'code': 'en-AU'},
    {'name': 'English (India)', 'code': 'en-IN'},
    {'name': 'English (UK)', 'code': 'en-GB'},
    {'name': 'English (US)', 'code': 'en-US'},
    {'name': 'Filipino (Philippines)', 'code': 'fil-PH'},
    {'name': 'Finnish (Finland)', 'code': 'fi-FI'},
    {'name': 'French (Canada)', 'code': 'fr-CA'},
    {'name': 'French (France)', 'code': 'fr-FR'},
    {'name': 'Galician (Spain)', 'code': 'gl-ES'},
    {'name': 'German (Germany)', 'code': 'de-DE'},
    {'name': 'Greek (Greece)', 'code': 'el-GR'},
    {'name': 'Gujarati (India)', 'code': 'gu-IN'},
    {'name': 'Hebrew (Israel)', 'code': 'he-IL'},
    {'name': 'Hindi (India)', 'code': 'hi-IN'},
    {'name': 'Hungarian (Hungary)', 'code': 'hu-HU'},
    {'name': 'Icelandic (Iceland)', 'code': 'is-IS'},
    {'name': 'Indonesian (Indonesia)', 'code': 'id-ID'},
    {'name': 'Italian (Italy)', 'code': 'it-IT'},
    {'name': 'Japanese (Japan)', 'code': 'ja-JP'},
    {'name': 'Kannada (India)', 'code': 'kn-IN'},
    {'name': 'Korean (South Korea)', 'code': 'ko-KR'},
    {'name': 'Latvian (Latvia)', 'code': 'lv-LV'},
    {'name': 'Lithuanian (Lithuania)', 'code': 'lt-LT'},
    {'name': 'Malay (Malaysia)', 'code': 'ms-MY'},
    {'name': 'Malayalam (India)', 'code': 'ml-IN'},
    {'name': 'Mandarin Chinese', 'code': 'cmn-CN'},
    {'name': 'Marathi (India)', 'code': 'mr-IN'},
    {'name': 'Norwegian (Norway)', 'code': 'nb-NO'},
    {'name': 'Polish (Poland)', 'code': 'pl-PL'},
    {'name': 'Portuguese (Brazil)', 'code': 'pt-BR'},
    {'name': 'Portuguese (Portugal)', 'code': 'pt-PT'},
    {'name': 'Punjabi (India)', 'code': 'pa-IN'},
    {'name': 'Romanian (Romania)', 'code': 'ro-RO'},
    {'name': 'Russian (Russia)', 'code': 'ru-RU'},
    {'name': 'Serbian (Cyrillic)', 'code': 'sr-RS'},
    {'name': 'Slovak (Slovakia)', 'code': 'sk-SK'},
    {'name': 'Spanish (Spain)', 'code': 'es-ES'},
    {'name': 'Spanish (US)', 'code': 'es-US'},
    {'name': 'Swedish (Sweden)', 'code': 'sv-SE'},
    {'name': 'Tamil (India)', 'code': 'ta-IN'},
    {'name': 'Telugu (India)', 'code': 'te-IN'},
    {'name': 'Thai (Thailand)', 'code': 'th-TH'},
    {'name': 'Turkish (Turkey)', 'code': 'tr-TR'},
    {'name': 'Ukrainian (Ukraine)', 'code': 'uk-UA'},
    {'name': 'Vietnamese (Vietnam)', 'code': 'vi-VN'},
  ];

  final Map<String, List<String>> _voicesByLanguage = {
    'af-ZA': ['af-ZA-Standard-A'],
    'ar-XA': ['ar-XA-Standard-A', 'ar-XA-Standard-B', 'ar-XA-Standard-C', 'ar-XA-Standard-D', 'ar-XA-Wavenet-A', 'ar-XA-Wavenet-B', 'ar-XA-Wavenet-C', 'ar-XA-Wavenet-D'],
    'eu-ES': ['eu-ES-Standard-A', 'eu-ES-Standard-B'],
    'bn-IN': ['bn-IN-Standard-A', 'bn-IN-Standard-B', 'bn-IN-Standard-C', 'bn-IN-Standard-D', 'bn-IN-Wavenet-A', 'bn-IN-Wavenet-B', 'bn-IN-Wavenet-C', 'bn-IN-Wavenet-D'],
    'bg-BG': ['bg-BG-Standard-A', 'bg-BG-Standard-B'],
    'ca-ES': ['ca-ES-Standard-A', 'ca-ES-Standard-B'],
    'yue-HK': ['yue-HK-Standard-A', 'yue-HK-Standard-B', 'yue-HK-Standard-C', 'yue-HK-Standard-D'],
    'cs-CZ': ['cs-CZ-Standard-A', 'cs-CZ-Wavenet-A'],
    'da-DK': ['da-DK-Standard-A', 'da-DK-Standard-C', 'da-DK-Standard-D', 'da-DK-Standard-E', 'da-DK-Standard-F','da-DK-Standard-G', 'da-DK-Wavenet-A', 'da-DK-Wavenet-C', 'da-DK-Wavenet-D', 'da-DK-Wavenet-E', 'da-DK-Neural2-D'],
    'nl-BE': ['nl-BE-Standard-A', 'nl-BE-Standard-B', 'nl-BE-Standard-C', 'nl-BE-Standard-D', 'nl-BE-Wavenet-A', 'nl-BE-Wavenet-B'],
    'nl-NL': ['nl-NL-Standard-A', 'nl-NL-Standard-B', 'nl-NL-Standard-C', 'nl-NL-Standard-D', 'nl-NL-Standard-E', 'nl-NL-Standard-F', 'nl-NL-Standard-G',  'nl-NL-Wavenet-A', 'nl-NL-Wavenet-B', 'nl-NL-Wavenet-C', 'nl-NL-Wavenet-D', 'nl-NL-Wavenet-E'],
    'en-AU': ['en-AU-Standard-A', 'en-AU-Standard-B', 'en-AU-Standard-C', 'en-AU-Standard-D', 'en-AU-Wavenet-A', 'en-AU-Wavenet-B', 'en-AU-Wavenet-C', 'en-AU-Wavenet-D', 'en-AU-Neural2-A', 'en-AU-Neural2-B', 'en-AU-Neural2-C', 'en-AU-Neural2-D',  'en-AU-News-E', 'en-AU-News-F', 'en-AU-News-G'],
    'en-IN': ['en-IN-Standard-A', 'en-IN-Standard-B', 'en-IN-Standard-C', 'en-IN-Standard-D', 'en-IN-Standard-E', 'en-IN-Standard-F','en-IN-Wavenet-A', 'en-IN-Wavenet-B', 'en-IN-Wavenet-C', 'en-IN-Wavenet-D', 'en-IN-Wavenet-E','en-IN-Wavenet-F', 'en-IN-Neural2-A', 'en-IN-Neural2-B', 'en-IN-Neural2-C','en-IN-Neural2-D', 'en-IN-Journey-D', 'en-IN-Journey-F'],
    'en-GB': ['en-GB-Standard-A', 'en-GB-Standard-B', 'en-GB-Standard-C', 'en-GB-Standard-D', 'en-GB-Standard-F','en-GB-Wavenet-A', 'en-GB-Wavenet-B', 'en-GB-Wavenet-C', 'en-GB-Wavenet-D', 'en-GB-Wavenet-F', 'en-GB-Neural2-A', 'en-GB-Neural2-B', 'en-GB-Neural2-C', 'en-GB-Neural2-D','en-GB-Neural2-F', 'en-GB-News-G', 'en-GB-News-H', 'en-GB-News-I','en-GB-News-J', 'en-GB-News-K', 'en-GB-News-L', 'en-GB-News-M','en-GB-Journey-D','en-GB-Journey-F'],

    'en-US': ['en-US-Standard-A', 'en-US-Standard-B', 'en-US-Standard-C', 'en-US-Standard-D', 'en-US-Standard-E', 'en-US-Standard-F', 'en-US-Standard-G', 'en-US-Standard-H', 'en-US-Standard-I','en-US-Standard-J',  'en-US-Wavenet-A', 'en-US-Wavenet-B', 'en-US-Wavenet-C', 'en-US-Wavenet-D', 'en-US-Wavenet-E', 'en-US-Wavenet-F', 'en-US-Wavenet-G', 'en-US-Wavenet-H', 'en-US-Wavenet-I', 'en-US-Wavenet-J','en-US-Neural2-A','en-US-Neural2-C','en-US-Neural2-D','en-US-Neural2-E','en-US-Neural2-F','en-US-Neural2-G','en-US-Neural2-H','en-US-Neural2-I','en-US-Neural2-J','en-US-News-K','en-US-News-L','en-US-News-N','en-US-Casual-K','en-US-Journey-D','en-US-Journey-F','en-US-Journey-O','en-US-Studio-O','en-US-Studio-Q'],
    'fil-PH': ['fil-PH-Standard-A', 'fil-PH-Standard-B', 'fil-PH-Standard-C', 'fil-PH-Standard-D','fil-PH-Wavenet-A', 'fil-PH-Wavenet-B', 'fil-PH-Wavenet-C', 'fil-PH-Wavenet-D','fil-PH-Neural2-A','fil-PH-Neural2-D'],
    'fi-FI': ['fi-FI-Standard-A', 'fi-FI-Standard-B','fi-FI-Wavenet-A'],
    'fr-CA': ['fr-CA-Standard-A', 'fr-CA-Standard-B', 'fr-CA-Standard-C', 'fr-CA-Standard-D','fr-CA-Wavenet-A', 'fr-CA-Wavenet-B', 'fr-CA-Wavenet-C', 'fr-CA-Wavenet-D','fr-CA-Neural2-A','fr-CA-Neural2-B','fr-CA-Neural2-C','fr-CA-Neural2-D','fr-CA-Journey-D','fr-CA-Journey-F'],
    'fr-FR': ['fr-FR-Standard-A', 'fr-FR-Standard-B', 'fr-FR-Standard-C', 'fr-FR-Standard-D', 'fr-FR-Standard-E', 'fr-FR-Standard-F','fr-FR-Standard-G', 'fr-FR-Wavenet-A', 'fr-FR-Wavenet-B', 'fr-FR-Wavenet-C', 'fr-FR-Wavenet-D', 'fr-FR-Wavenet-E', 'fr-FR-Wavenet-F', 'fr-FR-Wavenet-G', 'fr-FR-Neural2-A','fr-FR-Neural2-B','fr-FR-Neural2-C','fr-FR-Neural2-D','fr-FR-Neural2-E','fr-FR-Journey-D','fr-FR-Journey-F'],
    'gl-ES': ['gl-ES-Standard-A', 'gl-ES-Standard-B'],
    'de-DE': ['de-DE-Standard-A', 'de-DE-Standard-B', 'de-DE-Standard-C', 'de-DE-Standard-D', 'de-DE-Standard-E','de-DE-Standard-F','de-DE-Standard-G','de-DE-Standard-H', 'de-DE-Wavenet-A', 'de-DE-Wavenet-B', 'de-DE-Wavenet-C', 'de-DE-Wavenet-D','de-DE-Wavenet-E','de-DE-Wavenet-F', 'de-DE-Wavenet-G','de-DE-Wavenet-H','de-DE-Neural2-A','de-DE-Neural2-B','de-DE-Neural2-C','de-DE-Neural2-D','de-DE-Neural2-F', 'de-DE-Journey-D', 'de-DE-Journey-F'],
    'el-GR': ['el-GR-Standard-A', 'el-GR-Standard-B','el-GR-Wavenet-A'],
    'gu-IN': ['gu-IN-Standard-A', 'gu-IN-Standard-B', 'gu-IN-Standard-C', 'gu-IN-Standard-D', 'gu-IN-Wavenet-A', 'gu-IN-Wavenet-B', 'gu-IN-Wavenet-C', 'gu-IN-Wavenet-D'],
    'he-IL': ['he-IL-Standard-A', 'he-IL-Standard-B', 'he-IL-Standard-C', 'he-IL-Standard-D', 'he-IL-Wavenet-A', 'he-IL-Wavenet-B', 'he-IL-Wavenet-C', 'he-IL-Wavenet-D'],
    'hi-IN': ['hi-IN-Standard-A', 'hi-IN-Standard-B', 'hi-IN-Standard-C', 'hi-IN-Standard-D', 'hi-IN-Standard-E', 'hi-IN-Standard-F','hi-IN-Wavenet-A', 'hi-IN-Wavenet-B', 'hi-IN-Wavenet-C', 'hi-IN-Wavenet-D', 'hi-IN-Wavenet-E','hi-IN-Wavenet-F','hi-IN-Neural2-A','hi-IN-Neural2-B','hi-IN-Neural2-C','hi-IN-Neural2-D'],
    'hu-HU': ['hu-HU-Standard-A', 'hu-HU-Standard-B','hu-HU-Wavenet-A'],
    'is-IS': ['is-IS-Standard-A', 'is-IS-Standard-B'],
    'id-ID': ['id-ID-Standard-A', 'id-ID-Standard-B', 'id-ID-Standard-C', 'id-ID-Standard-D', 'id-ID-Wavenet-A', 'id-ID-Wavenet-B', 'id-ID-Wavenet-C', 'id-ID-Wavenet-D'],
    'it-IT': ['it-IT-Standard-A', 'it-IT-Standard-B', 'it-IT-Standard-C', 'it-IT-Standard-D', 'it-IT-Wavenet-A', 'it-IT-Wavenet-B', 'it-IT-Wavenet-C', 'it-IT-Wavenet-D','it-IT-Neural2-A','it-IT-Neural2-C', 'it-IT-Journey-D','it-IT-Journey-F'],
    'ja-JP': ['ja-JP-Standard-A', 'ja-JP-Standard-B', 'ja-JP-Standard-C', 'ja-JP-Standard-D','ja-JP-Wavenet-A', 'ja-JP-Wavenet-B', 'ja-JP-Wavenet-C', 'ja-JP-Wavenet-D','ja-JP-Neural2-B','ja-JP-Neural2-C','ja-JP-Neural2-D'],
    'kn-IN': ['kn-IN-Standard-A', 'kn-IN-Standard-B', 'kn-IN-Standard-C', 'kn-IN-Standard-D', 'kn-IN-Wavenet-A', 'kn-IN-Wavenet-B', 'kn-IN-Wavenet-C', 'kn-IN-Wavenet-D'],
    'ko-KR': ['ko-KR-Standard-A', 'ko-KR-Standard-B', 'ko-KR-Standard-C', 'ko-KR-Standard-D','ko-KR-Wavenet-A', 'ko-KR-Wavenet-B', 'ko-KR-Wavenet-C', 'ko-KR-Wavenet-D','ko-KR-Neural2-A','ko-KR-Neural2-B','ko-KR-Neural2-C'],
    'lv-LV': ['lv-LV-Standard-A','lv-LV-Standard-B'],
    'lt-LT': ['lt-LT-Standard-A'],
    'ms-MY': ['ms-MY-Standard-A', 'ms-MY-Standard-B', 'ms-MY-Standard-C', 'ms-MY-Standard-D','ms-MY-Wavenet-A', 'ms-MY-Wavenet-B', 'ms-MY-Wavenet-C', 'ms-MY-Wavenet-D'],
    'ml-IN': ['ml-IN-Standard-A', 'ml-IN-Standard-B', 'ml-IN-Standard-C', 'ml-IN-Standard-D', 'ml-IN-Wavenet-A', 'ml-IN-Wavenet-B', 'ml-IN-Wavenet-C', 'ml-IN-Wavenet-D'],
    'cmn-CN': ['cmn-CN-Standard-A', 'cmn-CN-Standard-B', 'cmn-CN-Standard-C', 'cmn-CN-Standard-D','cmn-CN-Wavenet-A','cmn-CN-Wavenet-B','cmn-CN-Wavenet-C','cmn-CN-Wavenet-D'],
    'mr-IN': ['mr-IN-Standard-A', 'mr-IN-Standard-B', 'mr-IN-Standard-C', 'mr-IN-Wavenet-A', 'mr-IN-Wavenet-B', 'mr-IN-Wavenet-C'],
    'nb-NO': ['nb-NO-Standard-A', 'nb-NO-Standard-B', 'nb-NO-Standard-C', 'nb-NO-Standard-D', 'nb-NO-Standard-E', 'nb-NO-Standard-F','nb-NO-Standard-G', 'nb-NO-Wavenet-A', 'nb-NO-Wavenet-B', 'nb-NO-Wavenet-C', 'nb-NO-Wavenet-D','nb-NO-Wavenet-E'],
    'pl-PL': ['pl-PL-Standard-A', 'pl-PL-Standard-B', 'pl-PL-Standard-C', 'pl-PL-Standard-D', 'pl-PL-Standard-E','pl-PL-Wavenet-A','pl-PL-Wavenet-B','pl-PL-Wavenet-C','pl-PL-Wavenet-D','pl-PL-Wavenet-E'],
    'pt-BR': ['pt-BR-Standard-A', 'pt-BR-Standard-B', 'pt-BR-Standard-C', 'pt-BR-Standard-D', 'pt-BR-Standard-E','pt-BR-Wavenet-A','pt-BR-Wavenet-B','pt-BR-Wavenet-C','pt-BR-Wavenet-D','pt-BR-Wavenet-E','pt-BR-Neural2-A','pt-BR-Neural2-B','pt-BR-Neural2-C'],
    'pt-PT': ['pt-PT-Standard-A', 'pt-PT-Standard-B', 'pt-PT-Standard-C', 'pt-PT-Standard-D','pt-PT-Standard-E','pt-PT-Standard-F', 'pt-PT-Wavenet-A','pt-PT-Wavenet-B','pt-PT-Wavenet-C','pt-PT-Wavenet-D'],
    'pa-IN': ['pa-IN-Standard-A','pa-IN-Standard-B','pa-IN-Standard-C','pa-IN-Standard-D','pa-IN-Wavenet-A','pa-IN-Wavenet-B','pa-IN-Wavenet-C','pa-IN-Wavenet-D'],
    'ro-RO': ['ro-RO-Standard-A','ro-RO-Standard-B', 'ro-RO-Wavenet-A'],
    'ru-RU': ['ru-RU-Standard-A', 'ru-RU-Standard-B', 'ru-RU-Standard-C', 'ru-RU-Standard-D', 'ru-RU-Standard-E','ru-RU-Wavenet-A','ru-RU-Wavenet-B','ru-RU-Wavenet-C','ru-RU-Wavenet-D','ru-RU-Wavenet-E'],
    'sr-RS': ['sr-RS-Standard-A'],
    'sk-SK': ['sk-SK-Standard-A','sk-SK-Standard-B','sk-SK-Wavenet-A'],
    'es-ES': ['es-ES-Standard-A', 'es-ES-Standard-B', 'es-ES-Standard-C', 'es-ES-Standard-D', 'es-ES-Standard-E', 'es-ES-Standard-F', 'es-ES-Wavenet-B', 'es-ES-Wavenet-C', 'es-ES-Wavenet-D','es-ES-Wavenet-E','es-ES-Wavenet-F', 'es-ES-Neural2-A','es-ES-Neural2-B','es-ES-Neural2-C','es-ES-Neural2-D','es-ES-Neural2-E','es-ES-Neural2-F',],
    'es-US': ['es-US-Standard-A', 'es-US-Standard-B', 'es-US-Standard-C', 'es-US-Wavenet-A', 'es-US-Wavenet-B', 'es-US-Wavenet-C','es-US-Neural2-A','es-US-Neural2-B','es-US-Neural2-C','es-US-News-D','es-US-News-E','es-US-News-F','es-US-News-G','es-US-Journey-D','es-US-Journey-F'],
    'sv-SE': ['sv-SE-Standard-A', 'sv-SE-Standard-B', 'sv-SE-Standard-C', 'sv-SE-Standard-D', 'sv-SE-Standard-E', 'sv-SE-Standard-F','sv-SE-Standard-G', 'sv-SE-Wavenet-A', 'sv-SE-Wavenet-B', 'sv-SE-Wavenet-C', 'sv-SE-Wavenet-D','sv-SE-Wavenet-E'],
    'ta-IN': ['ta-IN-Standard-A', 'ta-IN-Standard-B', 'ta-IN-Standard-C', 'ta-IN-Standard-D', 'ta-IN-Wavenet-A', 'ta-IN-Wavenet-B', 'ta-IN-Wavenet-C', 'ta-IN-Wavenet-D'],
    'te-IN': ['te-IN-Standard-A','te-IN-Standard-B'],
    'th-TH': ['th-TH-Standard-A', 'th-TH-Neural2-C'],
    'tr-TR': ['tr-TR-Standard-A', 'tr-TR-Standard-B', 'tr-TR-Standard-C', 'tr-TR-Standard-D','tr-TR-Standard-E', 'tr-TR-Wavenet-A', 'tr-TR-Wavenet-B', 'tr-TR-Wavenet-C', 'tr-TR-Wavenet-D','tr-TR-Wavenet-E'],
    'uk-UA': ['uk-UA-Standard-A', 'uk-UA-Wavenet-A'],
    'vi-VN': ['vi-VN-Standard-A', 'vi-VN-Standard-B', 'vi-VN-Standard-C', 'vi-VN-Standard-D','vi-VN-Wavenet-A','vi-VN-Wavenet-B','vi-VN-Wavenet-C','vi-VN-Wavenet-D','vi-VN-Neural2-A','vi-VN-Neural2-D'],
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
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,),
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
              if (_currentMembership == UserMembership.normal)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Unlock more language choices with a premium subscription.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),


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
                          child: ProcessingPage(prompt: widget.prompt, title: widget.title,language :_selectedLanguage!,voice: _selectedVoice!,mode:widget.mode),
                        ),
                      );
                    }else{
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ProcessingPageAudio (prompt: widget.prompt, title: widget.title,language :_selectedLanguage!,voice: _selectedVoice!,mode:widget.mode),
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