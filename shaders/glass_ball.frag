#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform vec3 uColor; // Base color tint (e.g. cyan/blue)
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    vec2 p = -1.0 + 2.0 * uv;
    float rSq = dot(p, p);

    if (rSq > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

    float f = sqrt(1.0 - rSq);
    vec3 normal = vec3(p.x, p.y, f);
    vec3 viewDir = vec3(0.0, 0.0, 1.0);

    // Light Directions
    vec3 mainLightDir = normalize(vec3(-0.5, -0.5, 1.0)); // Top-Left
    
    // ------------------------------------------------------------------
    // 1. FRESNEL (The Rim)
    // ------------------------------------------------------------------
    float fresnelBase = 1.0 - max(dot(normal, viewDir), 0.0);
    float fresnel = pow(fresnelBase, 3.0);
    
    // ------------------------------------------------------------------
    // 2. INNER GLOW / THICKNESS (The "Edge Ring")
    // ------------------------------------------------------------------
    // Instead of black/dark, we want a vibrant, saturated color.
    // pow(< 1.0) on color makes it brighter/washer out, pow(> 1.0) makes it richer/darker.
    // We'll make a "Deep" version of the uColor.
    vec3 deepColor = pow(uColor, vec3(1.2)) * 1.5; 

    // The inner volume is the area just inside the rim.
    float innerAlpha = pow(fresnelBase, 0.6); 

    // ------------------------------------------------------------------
    // 3. HIGHLIGHTS (Specular)
    // ------------------------------------------------------------------
    // Main Highlight (Top-Left, sharp and bright white)
    vec3 halfVecMain = normalize(mainLightDir + viewDir);
    float specMain = pow(max(dot(normal, halfVecMain), 0.0), 80.0);
    
    // Secondary "Caustic" Highlight (Bottom-Right, soft, colored)
    vec3 secLightDir = normalize(vec3(0.6, 0.6, 0.5));
    vec3 halfVecSec = normalize(secLightDir + viewDir);
    float specSec = pow(max(dot(normal, halfVecSec), 0.0), 20.0);

    // ------------------------------------------------------------------
    // 4. COMPOSITION
    // ------------------------------------------------------------------
    vec3 col = vec3(0.0);
    
    // Add the "Deep" volume color. 
    // This provides the "body" of the glass without looking black.
    col += deepColor * innerAlpha;
    
    // Add the sharp Rim Light (brightens the edge)
    // We tint it slightly with the base color so it's not purely white/grey
    col += mix(uColor, vec3(1.0), 0.8) * fresnel * 1.2;
    
    // Add Highlights
    col += vec3(1.0) * specMain * 1.5; // Bright white main
    col += mix(uColor, vec3(1.0), 0.5) * specSec * 0.8; // Tinted secondary

    // Calculate Final Alpha
    // We keep the center transparent, but ensure color areas have opacity.
    float alpha = 0.05 + (innerAlpha * 0.5) + fresnel + specMain + specSec;
    
    // Clamp alpha
    alpha = clamp(alpha, 0.0, 1.0);

    // Premultiply for Flutter
    fragColor = vec4(col * alpha, alpha);
}
