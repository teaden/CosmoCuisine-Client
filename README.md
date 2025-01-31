# CosmoCuisine - Client

CosmoCuisine is an iOS application that utilizes the OCR capabilities of Apple Vision to recognize the packages of international food items and return the associated nutritional facts. Since CosmoCuisine allows users to simply capture multiple packages on store shelves via the iPhone camera, the app's goal is to improve upon traditional barcode scanning applications, which may require users to first pick up products and locate the corresponding barcodes. Additionally, CosmoCuisine is specifically designed for scenarios that may occur during international travel, where users may need to shop at stores that contain products in an unfamiliar language. If an English speaker is shopping in Japan, for example, CosmoCuisine can recognize products from the Japanese text on product packaging and return the associated nutritional details in English (e.g, following FDA standards and measurements for a tourist from the US).

CosmoCuisine can also use audio data from the iPhone microphone to aid in the food search or shopping process. The app uses an ECAPA-TDNN model accessible via [a web server API](https://github.com/teaden/CosmoCuisine-Server) to identify spoken language via user-recorded queries. The ECAPA-TDNN model predicts the spoken language, which serves as the locale for the Apple Speech framework. Through keywords parsed from the recorded search query, CosmoCuisine can find matching foods and return the associated nutrition facts in the user's preferred language.

## Building and Running

1. Open the project in Xcode.
2. Select the desired target (e.g., simulator or device).
3. Press the "Build and Run" button (or use the Cmd + R shortcut).

Note: To use the speech recognition features, additionally follow the [steps outlined for the server code](https://github.com/teaden/CosmoCuisine-Server).

## Prerequisites:

* Xcode 16.1 or later
* iOS 18 SDK or later
* Core Data
