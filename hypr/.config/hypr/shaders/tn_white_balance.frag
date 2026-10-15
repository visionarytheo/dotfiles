// Simple Gamma & White Balance Correction for TN Panels
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    
    // Apply a subtle gamma curve (1.2 lowers harsh blown-out whites)
    vec3 corrected = pow(pixColor.rgb, vec3(1.20));
    
    // Slightly cap the absolute white point
    corrected *= 0.95;

    gl_FragColor = vec4(corrected, pixColor.a);
}
