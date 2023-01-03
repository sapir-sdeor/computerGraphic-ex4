Shader "CG/Water"
{
    Properties
    {
        _CubeMap("Reflection Cube Map", Cube) = "" {}
        _NoiseScale("Texture Scale", Range(1, 100)) = 10 
        _TimeScale("Time Scale", Range(0.1, 5)) = 3 
        _BumpScale("Bump Scale", Range(0, 0.5)) = 0.05
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"
                #include "CGRandom.cginc"

                #define DELTA 0.01

                // Declare used properties
                uniform samplerCUBE _CubeMap;
                uniform float _NoiseScale;
                uniform float _TimeScale;
                uniform float _BumpScale;

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
                    float2 uv       : TEXCOORD0;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float4 worldPos: TEXCOORD1;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    return perlin2d(uv);
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    float fTagV = (waterNoise(i.uv+i.dv,t)  - waterNoise(i.uv,t))/i.dv;
                    float fTagU = (waterNoise(i.uv+i.du,t)  - waterNoise(i.uv,t))/i.du;
                    float3 tv = float3(0,1,fTagV);
                    float3 tu = float3(1,0,fTagU);
                    float3 beforeBumpScale = cross(tv,tu);
                    float3 nh = UnityObjectToWorldDir
                            (normalize(float3(beforeBumpScale.x * i.bumpScale, beforeBumpScale.y * i.bumpScale, 1)));
                    i.normal = UnityObjectToWorldDir(i.normal);
                    i.tangent = UnityObjectToWorldDir(i.tangent);
                    float3 b = cross(i.normal, i.tangent);
                    float3 nWorld = (i.tangent * nh.x) + (i.normal * nh.z) + (b * nh.y);
                    return nWorld.xyz;
                    return 0;
                }

                
                bumpMapData createBumpMesh(float3 n, float2 uv, float3 tangent){
                    bumpMapData bumpMesh;
                    bumpMesh.normal = n;
                    bumpMesh.tangent = tangent; 
                    bumpMesh.uv = uv;
                    bumpMesh.du = DELTA;
                    bumpMesh.dv = DELTA;
                    bumpMesh.bumpScale = _BumpScale;
                    return bumpMesh;
                }

                v2f vert (appdata input)
                {
                    v2f output;
                    input.normal = normalize(input.normal);
                    input.vertex += float4(input.normal * waterNoise(input.uv * _NoiseScale, 0) * _BumpScale,0);
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.tangent = input.tangent;
                    output.worldPos = mul(input.vertex, unity_WorldToObject);
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 n = normalize(input.normal);
                    bumpMapData bumpMesh = createBumpMesh(n,input.uv, input.tangent);
                    float3 bumpMappedNormal = getWaterBumpMappedNormal(bumpMesh, 0);
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz);
                    float3 r = 2*(dot(v,n)*n)-v;
                    fixed4 reflectedColor = texCUBE(_CubeMap, r);
                    fixed4 color = (1-max(0,dot(bumpMappedNormal,v)) + 0.2) * reflectedColor;
                    return color;
                }

            ENDCG
        }
    }
}
