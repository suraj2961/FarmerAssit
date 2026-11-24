# 🌾 FarmerAssist (ನೇಗಿಲು ಕೃಷಿ - Negilu Krishi)

> **Empowering Agriculture with AI & Real-time Market Intelligence**  
> *ಕರ್ನಾಟಕದ ರೈತ ಬಾಂಧವರಿಗಾಗಿ ನಿಖರ APMC ಮಾರುಕಟ್ಟೆ ದರಗಳು, ಕೃತಕ ಬುದ್ಧಿಮತ್ತೆ (AI) ಆಧಾರಿತ ಮಾರಾಟ ಸಲಹೆ ಮತ್ತು ಕೃಷಿ ಹವಾಮಾನ ಮುನ್ಸೂಚನೆ.*

---

## 🚀 Key Features

- **📊 APMC Mandi Rates:** Real-time wholesale prices across Karnataka APMC markets with dynamic price spread analysis, Kg/Quintal unit toggles, and WhatsApp 1-tap sharing.
- **🤖 AI Sell Advisory Engine:** Machine learning time-series regression calculating expected 7-day price movements, season percentiles, and optimal sell vs. hold recommendations.
- **💰 Holding Profit Calculator:** Interactive harvest quantity slider computing gross returns and estimated net advantages from holding crops.
- **🌦️ Agri Weather & Field Advisories:** Live OpenWeather integration delivering weather-based suitability alerts for pesticide spraying, crop yard drying, and harvesting windows.
- **🏛️ Karnataka Govt Schemes:** Comprehensive directory of agricultural subsidies, machinery rentals (Yanthradhare), and welfare programs.
- **📺 Agri News & Video Guides:** Categorized video guides with topic filters (Market Rates, Arecanut, Organic, Machinery, Disease Control).
- **📱 Fully Responsive:** Adaptive layout engine tailored for phones, tablets, and desktop browsers with bilingual Kannada & English support.

---

## 🏗️ Project Architecture

```
farmerassist/
├── farmer_assit/               # Multiplatform Flutter Frontend (Mobile & Web)
│   ├── lib/
│   │   ├── config/             # Negilu Design System tokens & API configuration
│   │   ├── models/             # Data models (MandiPrice, SellAdvisory, Weather, Schemes)
│   │   ├── screens/            # Responsive screen views
│   │   ├── services/           # REST API clients with offline fallback engines
│   │   └── widgets/            # Reusable UI components & custom charts
│   └── assets/images/          # Official FarmerAssist brand assets & logos
│
└── farmerassist-backend/       # Spring Boot 3 Java Backend
    ├── src/main/java/          # REST controllers, caching layer & client integrations
    └── src/main/resources/     # Application configuration & security headers
```

---

## 🛠️ Getting Started

### Prerequisites
- **Flutter SDK:** $\ge 3.24.0$
- **Java JDK:** 17+
- **Maven:** 3.8+

### Running Frontend (Flutter)
```bash
cd farmer_assit
flutter pub get
flutter run -d chrome      # Web preview
flutter run -d emulator-5554  # Android emulator
```

### Running Backend (Spring Boot)
```bash
cd farmerassist-backend
./mvnw spring-boot:run
```

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
