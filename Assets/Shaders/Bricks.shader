Shader "CG/Bricks"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(-100, 100)) = 40
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

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv  : TEXCOORD0;
                    float4 worldPos: TEXCOORD1;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.worldPos = mul(input.vertex, unity_ObjectToWorld);
                    output.normal = normalize(input.normal);
                    output.tangent = normalize(input.tangent);
                    output.uv = input.uv;
                    return output;
                }

                bumpMapData createBumpMesh(float3 normal, float4 tangent, float2 uv){
                    bumpMapData bumpMesh;
                    bumpMesh.normal = normal;
                    bumpMesh.tangent = tangent; 
                    bumpMesh.uv = uv;
                    bumpMesh.heightMap = _HeightMap;
                    bumpMesh.du = _HeightMap_TexelSize.x;
                    bumpMesh.dv = _HeightMap_TexelSize.y;
                    bumpMesh.bumpScale = _BumpScale / 10000;
                    return bumpMesh;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    bumpMapData bumpMesh = createBumpMesh(input.normal, input.tangent, input.uv);
                    float3 n = getBumpMappedNormal(bumpMesh);
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz);
                    float3 l = _WorldSpaceLightPos0.xyz;
                    fixed4 albedo = tex2D(_AlbedoMap, input.uv);
                    fixed4 spectular = tex2D(_SpecularMap, input.uv);
                    fixed4 blinnP = fixed4(blinnPhong(n,v,l,_Shininess,albedo,spectular,_Ambient), 1);
                    return blinnP;
                }

            ENDCG
        }
    }
}
