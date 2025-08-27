#!/bin/bash
set -e

echo "Installing Flutter..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz

echo "Setting up Flutter PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter doctor..."
flutter doctor --android-licenses || true
flutter doctor

echo "Getting dependencies..."
flutter pub get

echo "Building web app..."
flutter build web --release
