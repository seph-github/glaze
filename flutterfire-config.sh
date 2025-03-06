#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
# Feel free to reuse and adapt this script for your own projects

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'development', or 'production'."
  exit 1
fi

case $1 in
  development)
    flutterfire config \
      --project=glaze-development \
      --out=lib/firebase_options_development.dart \
      --ios-bundle-id=com.glaze.glazeApp.development \
      --ios-out=ios/flavors/development/GoogleService-Info.plist \
      --android-package-name=com.glaze.glaze_app.development \
      --android-out=android/app/src/development/google-services.json
    ;;
  production)
    flutterfire config \
      --project=glaze-production \
      --out=lib/firebase_options_production.dart \
      --ios-bundle-id=com.glaze.glazeApp \
      --ios-out=ios/flavors/production/GoogleService-Info.plist \
      --android-package-name=com.glaze.glaze_app \
      --android-out=android/app/src/production/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'development', or 'production'."
    exit 1
    ;;
esac