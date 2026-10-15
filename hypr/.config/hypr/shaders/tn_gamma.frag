precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Power curve (exponent 1.35) corrects TN washed-out midtones
    // Darks stay deep, whites stay white, but midtone grays drop down to become visible
    pixColor.rgb = pow(pixColor.rgb, vec3(1.00));

    gl_FragColor = pixColor;
}
