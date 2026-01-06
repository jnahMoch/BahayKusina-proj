# Google Maps Setup Guide for BahayKusina

## Overview
This guide helps you set up Google Maps integration for real-time order tracking in the BahayKusina app.

## Step 1: Get Google Maps API Key

### For Android:
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select an existing one
3. Enable the Maps SDK for Android
4. Go to Credentials → Create Credentials → API Key
5. Copy the API key

### For iOS:
1. Follow the same steps above
2. Restrict the key to iOS apps if needed

## Step 2: Configure Android

1. Open `android/app/build.gradle.kts`
2. Add your Google Maps API key in `AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
</application>
```

3. Ensure you have the Google Play Services dependency in `build.gradle.kts`:
```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-maps:18.2.0'
}
```

## Step 3: Configure iOS

1. Open `ios/Runner/GeneratedPluginRegistrant.m`
2. Ensure Google Maps SDK is listed
3. Add API key in `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 4: Request Location Permissions

### Android:
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS:
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>BahayKusina needs access to your location to show order tracking</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>BahayKusina needs access to your location for delivery tracking</string>
```

## Step 5: Install Dependencies

Run this command:
```bash
flutter pub get
```

## Step 6: Update Track Order Page

The `TrackOrderPage` now includes:
- **Real-time Google Map** with rider and delivery location markers
- **Polyline** showing the route from rider to delivery
- **Distance calculation** showing how far the rider is from destination
- **Draggable bottom sheet** with order status and delivery info
- **Animated camera** that centers on the rider's current location

## Features Implemented

### LocationService (`lib/services/location_service.dart`)
- `getCurrentLocation()` - Get user's current GPS location
- `getLocationUpdates()` - Stream of real-time location updates
- `calculateDistance()` - Calculate distance between two points
- `calculateBearing()` - Calculate bearing/direction between points
- Permission handling for both Android and iOS

### TrackOrderPage (`lib/screens/track_order_page.dart`)
- **Google Map integration** with custom markers
- **Rider marker** (blue) showing delivery rider position
- **Destination marker** (red) showing delivery location
- **Route polyline** showing the path
- **Real-time distance** calculation
- **ETA display** with status indicators
- **Order status timeline** showing progress
- **Draggable sheet** for detailed order information

## Usage Example

```dart
TrackOrderPage(
  orderId: 'ORD-123',
  riderName: 'Juan dela Cruz',
  eta: '10 mins',
  deliveryAddress: '123 Main St, Manila',
  riderLocation: const LatLng(14.5994, 120.9842),
  deliveryLocation: const LatLng(14.6091, 120.9824),
)
```

## Troubleshooting

### Map not showing?
- Verify API key is correct
- Check AndroidManifest.xml and Info.plist have API key
- Ensure Google Maps API is enabled in Cloud Console

### Location not updating?
- Check location permissions are granted
- Verify `geolocator` package is properly installed
- For Android 12+, ensure `NEARBY_WIFI_DEVICES` permission is set (if needed)

### Build errors?
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the app

## Testing

To test on an emulator:
1. Android Emulator already supports Google Maps
2. iOS Simulator requires real device or use a location simulator

## Production Considerations

1. **API Key Restrictions**: Restrict your API key to specific apps in Google Cloud Console
2. **Cost**: Google Maps API charges for usage. Set up billing alerts
3. **Security**: Never commit API keys to version control
4. **Testing API Key**: Create separate API keys for development and production
5. **Monitoring**: Use Google Cloud Console to monitor API usage
