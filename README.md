# Smart Parking App

## Overview

The Smart Parking App is designed to help users find and book parking spots conveniently. It features a real-time map of available parking spots, vehicle selection, and QR code verification for booking slots.

## Features

- **Real-time Map**: View available parking spots on a map.
- **Vehicle Selection**: Select from a list of registered vehicles or manually enter a vehicle number.
- **QR Code Verification**: Scan QR codes to verify and book parking slots.
- **Slot Booking**: Book parking slots for a specified duration.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/smart_parking_app.git
   cd smart_parking_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Configuration

### Supabase Setup

1. Create a Supabase project at [Supabase](https://supabase.io/).
2. Obtain your Supabase URL and Anon Key.
3. Update `lib/config/supabase_config.dart` with your Supabase credentials.

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

## Usage

### Booking a Slot

1. Launch the app and navigate to the map view.
2. Select a parking slot.
3. Choose a vehicle or enter the vehicle number manually.
4. Scan the QR code associated with the slot.
5. Confirm the booking.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any improvements or bug fixes.

This app is free to use, can you create your own versions.
