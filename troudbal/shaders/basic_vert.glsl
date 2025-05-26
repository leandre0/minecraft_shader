#version 460

// attributes
in vec3 vaPosition; // vertex position vertex=dot vertice=lines-between-vertexes
in vec2 vaUV0;
in vec3 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;

// uniforms
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat3 normalMatrix;

out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;

void main() {

    geoNormal = normalMatrix * vaNormal;

    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    lightMapCoords = vaUV2 * (1.0 / 256) + (1.0 / 32.0);

    vec4 viewSpacePositionVec4 = modelViewMatrix * vec4(vaPosition+chunkOffset, 1);

    viewSpacePosition = viewSpacePositionVec4.xyz;

    gl_Position = projectionMatrix * viewSpacePositionVec4;
}