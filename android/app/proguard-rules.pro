# Flutter specific
#keep class io.flutter.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class androidx.** { *; }
-keep class com.bumptech.glide.** {*;}
-keep class com.facebook.** { *; }
-keep class com.squareup.** { *; }
-keep class okhttp3.** {*;}
-keep class com.github.** {*;}
-keep class com.revenuecat.** { *; }
-keep class com.google.firebase.** { *; }
-keepattributes *Annotation*

# Keep for revenuecat
-keep class com.revenuecat.purchases.common.attribution.** { *; }
-keep class com.revenuecat.purchases.common.networking.** { *; }
-keep class com.revenuecat.purchases.common.verification.** { *; }
-keep class com.revenuecat.purchases.subscriberattributes.** { *; }
-keep class com.android.billingclient.** {*;}
# Keep for url launcher
-keep class dev.flutter.pigeon.url_launcher_android.** { *; }

# Keep for flutter lottie
-keep class com.airbnb.lottie.** {*;}
-keep class androidx.vectordrawable.** {*;}
-keep class androidx.annotation.** {*;}


# Keep for firebase
 -keep class com.google.firebase.firestore.** { *; }
 -keep class com.google.firebase.messaging.** { *; }
  -keep class com.google.firebase.crashlytics.** {*;}
 -keep class com.google.firebase.analytics.** {*;}
  -keep class com.google.firebase.appcheck.** {*;}
  -keep class com.google.firebase.remoteconfig.** {*;}
# keep for algolia
  -keep class com.algolia.** {*;}

  # Keep for audio and video players
-keep class com.google.android.exoplayer.** { *; }
  -keep class com.github.vkay94.dtpv.** { *; }
# keep for cached network image
-keep class com.bumptech.glide.** { *; }
-keep class com.squareup.picasso.** {*;}
-keep class com.facebook.drawee.** {*;}