void main() {
    vec2 uv = v_tex_coord;
    float t = u_time * 0.4; // Vitesse légèrement plus lente pour plus de classe
    
    // On déforme les coordonnées pour créer l'aspect "liquide"
    vec2 p = uv * 4.0;
    for(int n = 1; n < 6; n++) { // Plus d'itérations = plus de détails de plis
        float i = float(n);
        p += vec2(
            0.6 / i * sin(i * p.y + t + 0.5 * i) + 0.5,
            0.4 / i * sin(i * p.x + t + 0.5 * i) + 1.2
        );
    }
    
    // Calcul de la base du relief
    float wave = sin(p.x + p.y);
    
    // L'EFFET CHROME :
    // On utilise une fonction de mapping pour forcer les blancs très brillants
    // et les noirs profonds, typiques du métal poli.
    float chrome = abs(wave); // Créé des "arrêtes" vives
    chrome = pow(0.2 / chrome, 0.6); // Inverse et accentue la brillance
    
    // Teinte légèrement bleutée/froide pour un look premium
    vec3 color = vec3(chrome);
    color.r *= 0.95; // Un peu moins de rouge
    color.b *= 1.05; // Un peu plus de bleu
    
    // Vignettage léger pour ne pas brûler les bords de l'écran OLED
    float dist = distance(uv, vec2(0.5));
    color *= smoothstep(0.8, 0.2, dist);

    gl_FragColor = vec4(color, 1.0);
}
