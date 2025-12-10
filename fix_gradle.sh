#!/bin/bash

echo "🔍 Checking Gradle configuration..."

# Check if using Kotlin DSL or Groovy
if [ -f "android/build.gradle.kts" ]; then
    echo "✅ Using Kotlin DSL (build.gradle.kts)"
    GRADLE_TYPE="kts"
elif [ -f "android/build.gradle" ]; then
    echo "✅ Using Groovy (build.gradle)"
    GRADLE_TYPE="groovy"
else
    echo "❌ No build.gradle file found!"
    exit 1
fi

echo "📝 Updating Gradle wrapper..."
cd android
./gradlew wrapper --gradle-version 8.4 --distribution-type all
cd ..

echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔄 Running Gradle sync..."
cd android
./gradlew clean
cd ..

echo "✅ Gradle configuration updated!"
echo "Now run: flutter build apk --release"
