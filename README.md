# VetAnalytics – Bloodwork Analysis Front-End

VetAnalytics is a cross-platform Flutter application that allows veterinary clinics to visualise, track and manage patients' bloodwork results in real-time. It provides a modern, responsive UI designed entirely with Material 3, powered by Provider state-management and Go Router navigation.

---

## ✨ Features

- **Patient Management** – add, update and archive patient records.
- **Bloodwork Dashboard** – interactive charts for CBC, biochemistry and hormonal panels.
- **File Upload & Parsing** – drag-and-drop CSV/Excel import or manual entry.
- **Adaptive UI** – desktop, tablet, web and mobile layouts from a single code-base.
- **Dark / Light Theme** – instant toggling via the in-app theme switcher.
- **Offline Ready** – cached data & graceful connectivity handling.
- **Locale-Aware Dates** – automatic date formatting based on device locale.
- **Secure Auth** – token-based login with automatic refresh & logout.

---

## 🏗️ Tech Stack

| Layer            | Package(s)                          | Notes                                  |
| ---------------- | ----------------------------------- | -------------------------------------- |
| UI Toolkit       | `flutter` (Material 3)              | Custom design system in `lib/theme`    |
| State Management | `provider`                          | Simple, lightweight & testable         |
| Navigation       | `go_router`                         | Declarative, URL-aware routing         |
| Networking       | `dio`, `http`, `connectivity_plus`  | Robust API calls & connectivity checks |
| Persistence      | `shared_preferences`                | Secure token & theme storage           |
| Code Generation  | `json_serializable`, `build_runner` | Immutable models with `*.g.dart`       |
| Charts           | `fl_chart`                          | Animated line, bar & pie charts        |

---

## 📂 Project Structure (simplified)

```
lib/
  components/      # Reusable widgets (buttons, forms, cards…)
  core/
    api/           # REST client wrappers
    models/        # JSON serialised DTOs
    providers/     # App-wide ChangeNotifiers
    services/      # Low-level helpers (storage, auth, logout…)
  navigation/      # Go Router setup
  pages/           # Feature screens (dashboard, profile…)
  theme/           # Colours, typography, spacing, gradients
  utils/           # Global helpers & extensions
```

---

## 🚀 Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-org/bloodwork-frontend-flutter.git
   cd bloodwork-frontend-flutter
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Generate model code** (build runner)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Run the app**
   ```bash
   flutter run -d <device_id>
   ```

> Need web? `flutter run -d chrome`. Want desktop? Enable the platform in `flutter config` first.

---

## 🧩 Environment Configuration

The API base URL and other secrets are read from **environment variables** at build time. Create a `.env` file at project root:

```
API_BASE_URL=https://api.vetanalytics.io
```

Then run with:

```bash
flutter run --dart-define-from-file=.env
```

---

## 🛠️ Useful Commands

| Task                    | Command                                |
| ----------------------- | -------------------------------------- |
| Analyse & format code   | `dart format . && flutter analyze`     |
| Run unit / widget tests | `flutter test`                         |
| Upgrade dependencies    | `flutter pub upgrade --major-versions` |
| Clean build artefacts   | `flutter clean`                        |

---

## 🤝 Contributing

1. Fork the repo & create your branch: `git checkout -b feat/my-feature`.
2. Commit your changes with clear messages (conventional commits preferred).
3. Ensure `flutter analyze` & tests pass.
4. Open a Pull Request – template will guide you.

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
