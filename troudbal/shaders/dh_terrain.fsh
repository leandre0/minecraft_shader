#version 460 compatibility

uniform sampler2D lightmap; // lightmap texture
uniform sampler2D depthTex0; // depth texture

uniform float viewHeight;
uniform float viewWidth;

uniform vec3 fogColor;
uniform vec3 shadowLightPosition;

uniform mat4 gbufferModelViewInverse;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

in vec4 blockColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;

void main() {

    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;

    float lightBrightness = clamp(dot(shadowLightDirection, worldGeoNormal), 0.2, 1.0);

    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));

    vec4 outputColorData = blockColor;
    vec3 outputColor = pow(outputColorData.rgb, vec3(2.2)) * lightColor;
    float transparency = outputColorData.a;

    if (transparency < 0.1) {
        discard;
    }

    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthTex0, texCoord).r;

    // if (depth != 1) {
    //     discard;
    // }

    float distanceFromCamera = distance(vec3(0), viewSpacePosition);

    float maxFogDistance = 5000;
    float minFogDistance = 2500;

    float fogBlendValue = clamp((distanceFromCamera - minFogDistance) / (maxFogDistance - minFogDistance), 0, 1);

    outputColor = mix(outputColor, pow(fogColor, vec3(2.2)), fogBlendValue);

    outputColor *= lightBrightness;

    outColor0 = vec4(pow(outputColor, vec3(1/2.2)), transparency); // output color of each fragment
}