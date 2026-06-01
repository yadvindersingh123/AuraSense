# 🌿 AuraSense

AuraSense is a Flutter-based IoT monitoring application that provides real-time sensor data visualization using Firebase Realtime Database. The app allows users to monitor environmental and electrical parameters such as temperature, humidity, and voltage directly from connected IoT devices.

## ✨ Features

* 📡 Real-time sensor monitoring
* 🌡️ Temperature tracking
* 💧 Humidity monitoring
* ⚡ Voltage measurement display
* 🔄 Live Firebase Realtime Database synchronization
* 📱 Clean and responsive Flutter UI
* ☁️ Cloud-based data storage and updates

## 🛠️ Technology Stack

* Flutter
* Dart
* Firebase Realtime Database
* Firebase Authentication
* IoT Sensor Integration

## 📊 Database Structure

```json
{
  "sensors": {
    "temperature": 25.5,
    "voltage": 12.3,
    "humidity": 65.0
  }
}
```

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Android Studio or VS Code
* Firebase Project Setup
* Android/iOS Device or Emulator

### Installation

```bash
git clone https://github.com/yadvindersingh123/AuraSense.git
cd AuraSense
flutter pub get
flutter run
```

## 🔥 Firebase Setup

1. Create a Firebase project.
2. Enable Realtime Database.
3. Add Android and/or iOS applications.
4. Download configuration files:

   * `google-services.json` (Android)
   * `GoogleService-Info.plist` (iOS)
5. Run the application.

The app automatically initializes the required database structure and listens for real-time updates.

## 🎯 Use Cases

* Smart Home Monitoring
* Environmental Monitoring Systems
* Industrial Sensor Dashboards
* IoT Research Projects
* Educational IoT Applications

## 👨‍💻 Developer

**Yadvinder Singh**

GitHub: https://github.com/yadvindersingh123

## 📄 License

This project is available for learning and development purposes.
