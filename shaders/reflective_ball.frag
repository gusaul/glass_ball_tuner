#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uReflectionIntensity; // 0.0 - 1.0
uniform vec2 uReflectionPos;        // 0.0 - 1.0 (Top-Left 0,0)
uniform float uRimIntensity;        // 0.0 - 1.0
uniform vec3 uBallColor;            // RGB
uniform float uSmoothness;          // 0.0 - 1.0

out vec4 fragColor;

// SDF for a sphere
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

// Raymarching function
float rayMarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for(int i = 0; i < 64; i++) {
        vec3 p = ro + rd * dO;
        float dS = sdSphere(p, 0.45); // Sphere radius 0.45 just under 0.5 bounds
        dO += dS;
        if(dO > 10.0 || dS < 0.001) break;
    }
    return dO;
}

// Calculate normal
vec3 getNormal(vec3 p) {
    float d = sdSphere(p, 0.45);
    vec2 e = vec2(0.001, 0.0);
    vec3 n = d - vec3(
        sdSphere(p - e.xyy, 0.45),
        sdSphere(p - e.yxy, 0.45),
        sdSphere(p - e.yyx, 0.45));
    return normalize(n);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    // Map UV directly to -0.5 to 0.5 range for easier 3D math, preserving aspect if needed
    // But for a single ball filling the widget, we assume widget is square-ish.
    vec2 p = uv - 0.5;
    
    // Correct aspect ratio if non-square
    if(uResolution.x > uResolution.y) {
        p.x *= uResolution.x / uResolution.y;
    } else {
        p.y *= uResolution.y / uResolution.x;
    }

    // Camera setup
    vec3 ro = vec3(0.0, 0.0, 2.0); // Camera position
    vec3 rd = normalize(vec3(p, -1.0)); // Ray direction

    float d = rayMarch(ro, rd);

    if(d > 10.0) {
        fragColor = vec4(0.0); // Transparent background
        return;
    }

    vec3 hitP = ro + rd * d;
    vec3 n = getNormal(hitP);
    vec3 viewDir = normalize(ro - hitP);

    // --- Lighting Calculations ---

    // 1. Fresnell / Rim Light (Outer Layer)
    float fresnel = pow(1.0 - max(dot(viewDir, n), 0.0), 3.0);
    
    // 2. Main Soft Reflection (Softbox/Window) based on uReflectionPos
    // Remap uReflectionPos (0-1) to -1 to 1 range
    vec3 lightPos = vec3((uReflectionPos.x - 0.5) * 2.0, -(uReflectionPos.y - 0.5) * 2.0, 1.0);
    lightPos = normalize(lightPos);
    
    vec3 refVec = reflect(-viewDir, n);
    float specBase = max(dot(refVec, lightPos), 0.0);
    float specular = pow(specBase, 10.0 + (uSmoothness * 50.0)) * uReflectionIntensity;
    
    // A nice sharp highlight inside the soft reflection
    float sharpHighlight = pow(specBase, 100.0) * uReflectionIntensity * 1.5;

    // 3. Inner Transparency/Volume
    // Simple faked refraction view (distorted background or just color)
    // We mix the ball color with some transparency based on facing ratio to make edge thicker
    float alpha = 0.2 + 0.8 * fresnel; // Edges are more opaque
    
    // Color composition
    vec3 col = uBallColor * 0.2; // Ambient base
    col += vec3(1.0) * specular; // Soft Reflection
    col += vec3(1.0) * sharpHighlight; // Sharp Hotspot
    col += vec3(0.8, 0.9, 1.0) * fresnel * uRimIntensity; // Rim light (bluish tint often looks glassy)

    // Final mix
    fragColor = vec4(col, clamp(alpha + specular, 0.0, 1.0));
}
