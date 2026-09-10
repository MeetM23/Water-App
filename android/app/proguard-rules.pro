# The Flutter embedding references Google Play Feature Delivery classes from
# FlutterPlayStoreSplitApplication and PlayStoreDeferredComponentManager even
# when an app does not use deferred components. This app does not, and the
# Play Core library is not a dependency, so R8 finds the references unresolved
# and fails the release build. These classes are never loaded at runtime.
-dontwarn com.google.android.play.core.**

# Flutter and its plugins ship their own consumer ProGuard rules, so no blanket
# keep is needed here. MainActivity is kept automatically because the manifest
# names it.
