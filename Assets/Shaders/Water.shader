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
                    float noise = waterNoise(i.uv, t);
                    float fTagU = (waterNoise(i.uv + float2(i.du, 0), t)  - noise) / i.du;
                    float fTagV = (waterNoise(i.uv + float2(0, i.dv), t)  - noise) / i.dv;
                    float s = i.bumpScale;
                    float3 nh = normalize(float3(-s * fTagU, -s * fTagV, 1));
                    float3 b = normalize(cross(i.tangent, i.normal));
                    float3 nWorld = normalize((i.tangent * nh.x) + (i.normal * nh.z) + (b * nh.y));
                    return nWorld;
                }

                
                bumpMapData createBumpMesh(float3 n, float2 uv, float4 tangent){
                    bumpMapData bumpMesh;
                    bumpMesh.normal = normalize(n);
                    bumpMesh.tangent = normalize(tangent); 
                    bumpMesh.uv = uv;
                    bumpMesh.du = DELTA;
                    bumpMesh.dv = DELTA;
                    bumpMesh.bumpScale = _BumpScale;
                    return bumpMesh;
                }

                // v2f vert (appdata input)
                // {
                //     v2f output;
                //     input.normal = normalize(input.normal);
                //     input.vertex += float4(input.normal * waterNoise(input.uv * _NoiseScale, 0) * _BumpScale,0);
                //     output.pos = UnityObjectToClipPos(input.vertex);
                //     output.uv = input.uv;
                //     output.normal = input.normal;
                //     output.tangent = input.tangent;
                //     output.worldPos = mul(input.vertex, unity_ObjectToWorld);
                //     return output;
                // }

                v2f vert (appdata input)
                {
                    v2f output;
                    //todo: understand how to move the vertices
                    
                    float noise = waterNoise(input.uv * _NoiseScale, 0);
                    float4 newPos = input.vertex + float4(input.normal * waterNoise(input.uv * _NoiseScale, 0) * _BumpScale,0);
                    // float4 newPos = input.vertex + float4(0, noise * _BumpScale , 0, 0);
                    output.pos = UnityObjectToClipPos(newPos);
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.tangent = input.tangent;
                    output.worldPos = mul(newPos, unity_ObjectToWorld);
                    return output;
                }


                // fixed4 frag (v2f input) : SV_Target
                // {
                //     bumpMapData bumpMesh = createBumpMesh(input.normal ,input.uv, input.tangent);
                //     // float3 n = getWaterBumpMappedNormal(bumpMesh, 0);
                //     float3 n = normalize(input.normal);
                //     float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz);
                //     float3 r = (2*(dot(v,n)*n))-v;
                //     // float3 r = reflect(v, n);
                //     fixed4 reflectedColor = texCUBE(_CubeMap, r);
                //     fixed4 color = (1-max(0,dot(n,v)) + 0.2) * reflectedColor;
                //     return color;
                // }

                fixed4 frag (v2f input) : SV_Target
                {
                    float noise = 0.5 * waterNoise(input.uv * _NoiseScale, 0) + 0.5;

                    bumpMapData bumpMesh = createBumpMesh(input.normal ,input.uv, input.tangent);
                    // float3 n = getWaterBumpMappedNormal(bumpMesh, 0);
                    float3 n = normalize(input.normal);
                    //todo: understand v
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz) ;
                    float3 r = (2*(dot(v,n)*n))-v;
                    // float3 r = reflect(v, n);
                    fixed4 reflectedColor = texCUBE(_CubeMap, r);
                    fixed4 color = (1-max(0,dot(n,v)) + 0.2) * reflectedColor;
                    return color;
                }

            ENDCG
        }
    }
}
