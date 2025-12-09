# Reflective Glass Ball Shader Tuner

A Flutter project demonstrating a high-fidelity, ray-traced glass ball fragment shader. This application serves as a **tuning workbench** to interactively adjust shader parameters and match specific lighting/material references.

## Features

*   **Ray-Traced Sphere**: Uses SDF (Signed Distance Field) raymarching for mathematically perfect sphere geometry.
*   **Physical-ish Rendering**:
    *   **Fresnel Rim Lighting**: Simulate the realistic glow/opacity at the edges of the glass.
    *   **Softbox Reflection**: A configurable rectangular light source reflection.
    *   **Specular Highlights**: Sharp hotspots for added realism.
    *   **Transparency**: The ball is transparent, composited over a checkerboard background to visualize refraction/opacity.
*   **Interactive Tuner**:
    *   Adjust light position (X/Y).
    *   Control reflection intensity and smoothness.
    *   Tweak Fresnel rim intensity.
*   **Debug Output**: Real-time logging of parameter values to the console for easy copy-pasting into production code.

## Getting Started

### Prerequisites

*   Flutter SDK (3.10+ recommended for shader support)
*   A platform that supports Flutter Fragment Shaders (Android, iOS, macOS, Linux, Windows).
    *   *Note: Web support for custom fragment shaders can be limited or require specific renderers (CanvasKit).*

### Running the App

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/gusaul/glass_ball_tuner.git
    cd glass_ball_tuner
    ```

2.  **Run the Flutter app**:
    ```bash
    flutter run
    ```
    (Specify a device if needed, e.g., `flutter run -d linux` or `flutter run -d macos`).

## How to Use

1.  **Launch the App**: You will see a split view. The left side shows the Glass Ball on a checkerboard background. The right side contains the styling controls.
2.  **Tune the Shader**:
    *   **Reflection Position**: Move the sliders to position the main "softbox" reflection.
    *   **Reflection Intensity**: Make the reflection brighter or dimmer.
    *   **Rim Intensity**: Adjust the strength of the glowing edge (Fresnel effect).
    *   **Smoothness**: Adjust how sharp or blurry the reflection appears.
3.  **Capture Values**:
    *   Open your terminal/debug console while moving sliders.
    *   The app prints the exact values (e.g., `Reflection Pos: 0.35, 0.25`).
    *   Copy these values to your own `ReflectiveGlassBall` widget instantiation to lock in the look.

## Project Structure

*   `lib/main.dart`: The main application shell and the Tuning UI logic.
*   `lib/reflective_glass_ball.dart`: A reusable Flutter Widget that wraps the shader execution.
*   `shaders/reflective_ball.frag`: The GLSL fragment shader code implementing the raymarching and lighting logic.

## License

This project is open source and available for personal or commercial use.
