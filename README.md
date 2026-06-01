# wifi_connect

A Flutter project with Firebase Realtime Database integration for sensor data.

## Getting Started

This project is a starting point for a Flutter application.

## Firebase Realtime Database Setup

The app displays real-time sensor data (temperature, voltage, humidity) from Firebase Realtime Database.

### Database Structure

The app **automatically creates** the database structure when it first runs:

```json
{
  "sensors": {
    "temperature": 25.5,
    "voltage": 12.3,
    "humidity": 65.0
  }
}
```

### Setting up Firebase Realtime Database:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **aurasense-920b6**
3. Navigate to **Realtime Database** from the left menu
4. Click **Create Database**
5. Start in **test mode** (for development) or set up security rules as needed
6. **That's it!** The app will automatically create the structure on first run

### Auto-Initialization

The app automatically:
- ✅ Checks if the `/sensors` path exists in Firebase
- ✅ Creates the structure with default values if it doesn't exist
- ✅ Sets up real-time listeners for live updates

### Updating Sensor Data

Your IoT device should update the database in real-time using this path:
```
/sensors
```

The app will automatically display the latest values when they change in Firebase. No manual setup required!

## Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Firebase Realtime Database Docs](https://firebase.google.com/docs/database)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# AuraSense
