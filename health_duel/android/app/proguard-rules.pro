# Flutter engine + plugin classes (io.flutter.**) are kept automatically by the
# Flutter Gradle plugin's own proguard rules — no need to duplicate that here.

# Play Core: referenced by Flutter's deferred-components support even though this
# app doesn't use deferred components or ship the play-core dependency. Without
# this, R8 fails the release build with "Missing class
# com.google.android.play.core.splitcompat.SplitCompatApplication" and friends.
-dontwarn com.google.android.play.core.**

# cloud_firestore / firebase_auth pull in gRPC, which references several
# optional transport/telemetry dependencies (Conscrypt, OpenCensus, Perfmark,
# GAE) that aren't on the classpath. These are documented false-positive
# warnings from the FlutterFire/grpc-java projects, not code this app uses.
-dontwarn io.grpc.**
-dontwarn io.opencensus.**
-dontwarn io.perfmark.**
-dontwarn org.conscrypt.**
-dontwarn org.jboss.marshalling.**
-dontwarn com.google.appengine.**
-dontwarn com.google.api.**
-dontwarn com.google.cloud.audit.**
