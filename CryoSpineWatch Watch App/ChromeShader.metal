#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 liquidChrome(float2 position, half4 color, float time, float2 size) {
    // Normalisation des coordonnées (0.0 à 1.0)
    float2 uv = position / size.y;
    
    // Algorithme de distorsion type "plasma" pour l'effet liquide
    float2 p = uv * 3.0;
    for(int n = 1; n < 4; n++) {
        float i = float(n);
        p += float2(0.7 / i * sin(i * p.y + time + 0.3 * i) + 0.8,
                    0.4 / i * sin(i * p.x + time + 0.3 * i) + 1.6);
    }
    
    // Calcul de la luminosité pour l'aspect chrome
    float col = 0.5 + 0.5 * sin(p.x + p.y);
    
    // Accentuation des blancs (spécularité)
    float metallic = pow(col, 2.5);
    
    return half4(half3(metallic), 1.0);
}
