#version 460

uniform sampler2D gtexture; // bloc texture
uniform sampler2D lightmap; // lightmap texture

uniform mat4 gbufferModelViewInverse;

uniform float far;
uniform float dhNearPlane;

uniform vec3 shadowLightPosition;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;

void main() {

    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;

    float lightBrightness = clamp(dot(shadowLightDirection, worldGeoNormal), 0.2, 1.0);

    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));

    vec4 outputColorData = texture(gtexture, texCoord);
    vec3 outputColor = pow(outputColorData.rgb, vec3(2.2)) * pow(foliageColor, vec3(2.2)) * lightColor;
    float transparency = outputColorData.a;

    if (transparency < .1) {
        discard;
    }

    float distanceFromCamera = distance(viewSpacePosition, vec3(0));
    float dhBlend = smoothstep(far-.5*far, far, distanceFromCamera);
    transparency = mix(0.0, transparency, pow((1-dhBlend), 0.6));
    outputColor *= lightBrightness;

    outColor0 = vec4(pow(outputColor, vec3(1/2.2)), transparency); // output color of each fragment
}