shader_type spatial;
render_mode unshaded, blend_mix;
uniform sampler2D DepthTex : HintDepthTexture;
uniform vec3 OutlineColor : SourceColor = vec3(0.0, 0.0, 0.0);

float LinearDepthProjection(float RawDepth, vec2 ScreenUV, mat4 InvProj){
    vec3 NDC = vec3(ScreenUV * 2.0 - 1.0, RawDepth);
    vec4 View = InvProj * vec4(NDC, 1.0);
    return -View.z / View.w;
}

float LinearDepth(float RawDepth, float Near, float Far){
    return 1.0 / ((1.0 - Far / Near) * RawDepth + 1.0 / Near);
}

void vertex() {
    VERTEX += NORMAL * 0.003;
}

void fragment() {
    float Near = LinearDepthProjection(0.0, SCREEN_UV, INV_PROJECTION_MATRIX);
    float Far = LinearDepthProjection(1.0, SCREEN_UV, INV_PROJECTION_MATRIX);

    float RawDepth = texture(DepthTex, SCREEN_UV).x;
    float DepthLinear = LinearDepth(RawDepth, Near, Far);

    vec2 PixelSize = (1.0 / DepthLinear) / vec2(textureSize(DepthTex, 0));

    float NeighborNW = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(-1, 1),  0).r, Near, Far);
    float NeighborN  = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(0, 1),   0).r, Near, Far);
    float NeighborNE = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(1, 1),   0).r, Near, Far);
    float NeighborW  = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(-1, 0),  0).r, Near, Far);
    float NeighborE  = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(1, 0),   0).r, Near, Far);
    float NeighborSW = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(-1, -1), 0).r, Near, Far);
    float NeighborS  = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(0, -1),  0).r, Near, Far);
    float NeighborSE = LinearDepth(textureLod(DepthTex, SCREEN_UV + vec2(PixelSize.x, PixelSize.y) * vec2(-1, 1),  0).r, Near, Far);

    float MaxDistance = 0.075;

    float EdgeNW = step(MaxDistance, abs(NeighborNW - DepthLinear));
    float EdgeN  = step(MaxDistance, abs(NeighborN  - DepthLinear));
    float EdgeNE = step(MaxDistance, abs(NeighborNE - DepthLinear));
    float EdgeW  = step(MaxDistance, abs(NeighborW  - DepthLinear));
    float EdgeE  = step(MaxDistance, abs(NeighborE  - DepthLinear));
    float EdgeSW = step(MaxDistance, abs(NeighborSW - DepthLinear));
    float EdgeS  = step(MaxDistance, abs(NeighborS  - DepthLinear));
    float EdgeSE = step(MaxDistance, abs(NeighborSE - DepthLinear));

    float AllEdges = EdgeNW + EdgeN + EdgeNE + EdgeW + EdgeE + EdgeSW + EdgeS + EdgeE;

    if (AllEdges > 0.5)
    {
      ALBEDO = OutlineColor;
      ALPHA =1.0;
    }