#!/bin/bash

echo "🔧 Fixing Gradle version to 8.11.1..."

# Update gradle wrapper
cd android

echo "📝 Updating Gradle wrapper..."
./gradlew wrapper --gradle-version 8.11.1 --distribution-type all

cd ..

echo "🧹 Cleaning project..."
flutter clean
rm -rf android/.gradle
rm -rf android/app/build
rm -rf android/build
rm -rf build

echo "📦 Getting dependencies..."
flutter pub get

echo "🔄 Syncing Gradle..."
cd android
./gradlew clean --refresh-dependencies
cd ..

echo "✅ Gradle updated to 8.11.1!"
echo ""
echo "Now run one of these commands:"
echo "  flutter run --release"
echo "  flutter build apk --release"
