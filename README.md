<p align="center">
  <img src="assets/icon/app_icon.png" width="140" height="140" style="border-radius: 28px;" alt="Batch Audio Birding Logo">
</p>

<h1 align="center">Batch Audio Birding (BAB)</h1>

<p align="center">
  <strong>A premium, high-efficiency mobile application for offline batch bird song recognition, powered by BirdNET TFLite model
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android Badge">
  <img src="https://img.shields.io/badge/License-CC_BY--NC--SA_4.0-lightgrey?style=for-the-badge" alt="License CC BY-NC-SA 4.0">
</p>

---

## 📖 Project Overview

**Batch Audio Birding (BAB)** is a modern mobile application developed using **Flutter** and **Dart** designed for ornithologists, researchers, and birdwatching enthusiasts. The app allows users to analyze multiple audio files or long-duration field recordings in batch directly on their mobile device to identify bird species by their songs and calls.

Unlike other solutions, BAB performs **all processing entirely locally (offline)** using an optimized **BirdNET TFLite** model. No internet connection is required for audio analysis, spectrogram generation, or playback, ensuring complete privacy, zero server costs, and seamless operation deep in the field or in remote areas.

---

## 📸 Application Screenshots

*Below are real screenshots captured from a device showing the application's clean, modern interface in both Light and Dark themes:*

<table align="center">
  <tr>
    <td align="center" width="33%">
      <img src="assets/screenshots/home_screen.png" alt="Home Screen" width="100%"><br>
      <b>1. Home Screen (Audio Upload)</b>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/results_screen.png" alt="Analysis Results" width="100%"><br>
      <b>2. Detections & Results</b>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/detail_modal.png" alt="Spectrogram Detail" width="100%"><br>
      <b>3. Interactive Spectrogram & Player</b>
    </td>
  </tr>
</table>

---

## ✨ Core Features

*   🚀 **Local Batch Analysis**: Analyze multiple files or extremely long audio recordings in background isolates without freezing the user interface.
*   🧠 **Integrated BirdNET AI Core**: Highly accurate bird song classification powered by ByrdNET TFLite model.
*   🗺️ **Advanced Spatial & Temporal Filtering**: Input GPS coordinates (Latitude/Longitude) and the week of the year to automatically filter species by geographical distribution and seasonality, drastically reducing false positives.
*   📈 **Interactive & High-Resolution Spectrogram**:
    *   Generates gorgeous, detailed FFT spectrogram plots locally in milliseconds.
    *   Auto-centered and dynamically scaled based on clip duration (3s, 6s, 9s) for perfect modal balance.
    *   Real-time playback cursor synced perfectly with the scrolling spectrogram.
*   🎵 **Premium Integrated Audio Player**:
    *   Play and pause the specific wav clip corresponding to any detection.
    *   Toggle loop playback.
    *   Seek manually by dragging the spectrogram or tapping anywhere along the waveform timeline.
*   💾 **Audio Clip Exporting**: Instantly export the isolated WAV audio fragment of any detection to share or catalog.
*   📋 **Custom Species Lists**: Build custom allowed species lists to restrict the model's outputs to specific families of interest.
*   🎨 **Beautiful, Theme-Aware UX**:
    *   **Dark Theme**: Sleek, immersive theme with ambient glows, glassmorphism, and neon confidence tags.
    *   **Light Theme**: Optimized for extreme outdoor legibility under direct sunlight, featuring WCAG-compliant high-contrast forest green and deep orange tags (minimum contrast ratio > 4.5:1).
    *   Dynamic popup-based localizer for languages.

---

## 🧠 AI Model & Licensing Information

Batch Audio Birding integrates the **BirdNET** audio classification model developed by the **K. Lisa Yang Center for Conservation Bioacoustics** at the **Cornell Lab of Ornithology** in collaboration with **Chemnitz University of Technology**.

### 📄 Model License
The BirdNET TFLite model (`assets/model/`) and the associated species list are distributed under the **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)** license.
*   **Permitted Use**: You are free to use, adapt, and share the model for non-commercial, educational, and research purposes.
*   **Commercial Use**: Commercial use of the model or its derivatives is strictly prohibited without prior authorization from the Cornell Lab of Ornithology.

### 🌐 Official Resources & Credits
*   **Official Website**: [BirdNET - Cornell Lab of Ornithology](https://birdnet.cornell.edu/)
*   **Reference Repository**: [GitHub - BirdNET-Analyzer](https://github.com/birdnet-team/BirdNET-Analyzer)

### 📚 Academic Citation
If you use this app or the integrated model for academic research or scientific publications, please cite the official BirdNET paper:
> Kahl, S., Wood, C. M., Eibl, M., & Klinck, H. (2021). **BirdNET: A deep learning solution for avian diversity monitoring.** *Ecological Informatics*, 61, 101236. [https://doi.org/10.1016/j.ecoinf.2021.101236](https://doi.org/10.1016/j.ecoinf.2021.101236)

---

## 🛠️ Getting Started (Development Setup)

### Prerequisites
*   **Flutter SDK**: `>=3.3.0`
*   **Dart SDK**: `>=3.0.0`
*   **Android SDK / Xcode** (for target native platform compiling)

### Installation & Execution

1. **Clone the repository**:
   ```bash
   git clone https://github.com/simogogo/BatchAudioBirding.git
   cd BatchAudioBirding
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Connect a device/emulator and run in Debug Mode**:
   ```bash
   flutter run
   ```

4. **Compile the optimized production APK (for Android)**:
   ```bash
   flutter build apk --release
   ```

---

## 📁 Repository Structure

```text
BatchAudioBirding/
├── android/                  # Android native directories and configurations
├── assets/
│   ├── icon/                 # Application assets (premium borderless squircle logo)
│   ├── model/                # Embedded BirdNET TFLite model and metadata
│   └── screenshots/          # Real application screenshots for GitHub
├── lib/
│   ├── models/               # Data classes (Detection, AnalysisResult, etc.)
│   ├── screens/              # App views (Home, Results List, Custom Allowed Lists)
│   ├── services/             # Background audio processing & local FFT spectrogram generator
│   └── widgets/              # Modular UI components (Player Card, Lang Selector, Detail Modal)
├── README.md                 # Project documentation (this file)
└── pubspec.yaml              # Flutter dependencies and assets configurations
```

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are very welcome!
1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

<p align="center">
  <i>Developed with passion to connect technology, deep learning, and bird conservation. 🌿🦉</i>
</p>
