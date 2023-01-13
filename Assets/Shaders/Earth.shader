Shader "CG/Earth"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(1, 100)) = 30
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "black" {}
        _AtmosphereColor ("Atmosphere Color", Color) = (0.8, 0.85, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;
                uniform sampler2D _CloudMap;
                uniform fixed4 _AtmosphereColor;

                struct appdata
                { 
                    float4 vertex : POSITION;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv  : TEXCOORD0;
                    float4 worldPos: TEXCOORD1;
                    float3 normal   : NORMAL;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.uv = getSphericalUV(input.vertex);
                    output.worldPos = mul(unity_ObjectToWorld, input.vertex);
                    output.normal = normalize(input.vertex);
                    return output;
                }


                bumpMapData createBumpMesh(float3 n, float2 uv){
                    bumpMapData bumpMesh;
                    bumpMesh.normal = n;
                    bumpMesh.tangent = normalize(cross(n, float3(0,1,0))); 
                    bumpMesh.uv = uv;
                    bumpMesh.heightMap = _HeightMap;
                    bumpMesh.du = _HeightMap_TexelSize.x;
                    bumpMesh.dv = _HeightMap_TexelSize.y;
                    bumpMesh.bumpScale = _BumpScale / 10000;
                    return bumpMesh;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 n = normalize(input.normal);
                    bumpMapData bumpMesh = createBumpMesh(n, input.uv);
                    float3 bumpMappedNormal = getBumpMappedNormal(bumpMesh);
                    
                    fixed4 albedo = tex2D(_AlbedoMap, input.uv);
                    fixed4 spectular = tex2D(_SpecularMap, input.uv);
                    
                    float3 finalNormal = ((1 - spectular) * bumpMappedNormal) + (spectular * n);
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz);
                    float3 l = normalize(_WorldSpaceLightPos0.xyz);
                    float lambert = max(0, dot(n,l));
                    fixed4 atmosphere = (1-max(0,dot(n,v))) * sqrt(lambert) *_AtmosphereColor;
                    fixed4 clouds = tex2D(_CloudMap, input.uv) * (sqrt(lambert) + _Ambient);
                    fixed4 blinnP = fixed4(blinnPhong(finalNormal,v,l,_Shininess,albedo,spectular,_Ambient), 1);
                    return blinnP + clouds + atmosphere;
                }

            ENDCG
        }
    }
}
