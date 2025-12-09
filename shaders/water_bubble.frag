#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uBackgroundTexture; // The background image to refract

out vec4 fragColor;

// Simple iridescence function based on cosine (spectral approximation)
vec3 iridescent(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.00, 0.33, 0.67);
    return a + b * cos(6.28318 * (c * t + d));
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    
    // 1. Geometry: Sphere Map
    vec2 p = -1.0 + 2.0 * uv;
    float rSq = dot(p, p);

    // If outside the sphere, return transparent
    if (rSq > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

    float f = sqrt(1.0 - rSq);
    vec3 normal = vec3(p.x, p.y, f);
    vec3 viewDir = vec3(0.0, 0.0, 1.0);

    // 2. Refraction (Distort the UVs)
    // Physical approximation: Snell's law implies light bends towards the normal.
    // For a sphere, this looks like "magnification" or "fish-eye" effect.
    // We offset the lookup UV based on the XY normal.
    float refractionStrength = 0.25; 
    vec2 refractedUV = uv - normal.xy * refractionStrength;
    
    // Sample the background at the *distorted* location
    vec3 bgCol = texture(uBackgroundTexture, refractedUV).rgb;

    // 3. Thin-Film Interference (Iridescence)
    // Depends on viewing angle (Fresnel) and "thickness" variation.
    // We add a swirling effect using uTime to simulate surface fluid movement.
    float fresnel = 1.0 - max(dot(normal, viewDir), 0.0);
    
    // Perturb the iridescence lookup with noise or time-varying sines
    float spectrumInput = fresnel * 3.0 + (p.y * 0.5) + sin(uTime * 0.5 + p.x * 3.0) * 0.2;
    vec3 rainbow = iridescent(spectrumInput);

    // 4. Specular Highlights
    vec3 lightDir = normalize(vec3(-0.5, -0.8, 1.0));
    vec3 halfVec = normalize(lightDir + viewDir);
    float spec = pow(max(dot(normal, halfVec), 0.0), 120.0); // Very sharp, wet highlight

    // 5. Fresnel Rim
    // Sharp rim light
    float rim = pow(fresnel, 4.0);

    // 6. Composition
    vec3 col = bgCol; // Start with the refracted background
    
    // Add Iridescence (additive, like an oil film)
    // Stronger at edges (Fresnel)
    col += rainbow * fresnel * 0.6;
    
    // Add Specular (White reflection of light source)
    col += vec3(1.0) * spec * 2.0;
    
    // Add Rim Light (White/Blueish)
    col += vec3(0.8, 0.9, 1.0) * rim;

    // Output
    // Alpha is 1.0 because we are drawing over the background ourselves
    fragColor = vec4(col, 1.0);
}
