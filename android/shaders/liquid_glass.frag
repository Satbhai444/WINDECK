#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform vec2 tilt;
uniform float time;
uniform vec4 baseColor;

out vec4 fragColor;

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float liquidNoise(vec2 p) {
    p *= 2.5; // Scale
    float f = 0.0;
    
    // Animate with time and tilt
    p += vec2(time * 0.15 + tilt.x * 2.0, time * 0.1 + tilt.y * 2.0);
    
    // Multi-octave wave interference
    for (int i = 0; i < 3; i++) {
        p = rot(1.5) * p;
        p.x += sin(p.y * 3.0 + time * 0.5) * 0.5;
        p.y += cos(p.x * 3.0 + time * 0.4) * 0.5;
        f += sin(length(p) * 4.0) * 0.5;
    }
    
    return f;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / resolution;
    
    // Create liquid waves
    float wave = liquidNoise(uv);
    float wave2 = liquidNoise(uv + vec2(0.1, 0.1));
    
    // Calculate normal from waves for lighting
    vec2 normal = vec2(wave2 - wave, liquidNoise(uv + vec2(0.0, 0.1)) - wave) * 3.0;
    
    // Specular lighting (Caustics)
    vec3 lightDir = normalize(vec3(0.5 - tilt.x * 2.0, 0.5 - tilt.y * 2.0, 1.0));
    vec3 n = normalize(vec3(normal, 1.0));
    float specular = pow(max(dot(n, lightDir), 0.0), 32.0);
    
    // Diffuse / base lighting
    float diffuse = max(dot(n, lightDir), 0.0) * 0.5 + 0.5;
    
    // Edge fresnel glow
    float dist = length(uv - 0.5) * 2.0;
    float edge = pow(dist, 4.0);
    
    // Build colors
    // Base color of the glass (dark translucent)
    vec4 glassColor = vec4(0.03, 0.03, 0.07, 0.85); 
    
    // Specular highlight is white/bright cyan
    vec4 highlight = vec4(1.0, 1.0, 1.0, 1.0) * specular * 1.5;
    
    // Add baseColor (app theme color) to edges and waves
    vec4 themeGlow = baseColor * diffuse * 0.3;
    vec4 edgeGlow = baseColor * edge * 0.8;
    
    fragColor = glassColor + themeGlow + highlight + edgeGlow;
}
