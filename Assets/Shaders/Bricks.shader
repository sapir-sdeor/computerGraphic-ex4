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
                    output.normal = input.normal;
                    output.worldPos = mul(input.vertex, unity_WorldToObject);
                    output.tangent = input.tangent;
                    output.uv = input.uv;
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    
                    float3 normalDirection = normalize(input.normal);
                    bumpMapData bumpMesh;
                    bumpMesh.normal = normalDirection;
                    bumpMesh.tangent = input.tangent; 
                    bumpMesh.uv = input.uv;
                    bumpMesh.heightMap = _HeightMap;
                    bumpMesh.du = _HeightMap_TexelSize.x;
                    bumpMesh.dv = _HeightMap_TexelSize.y;
                    bumpMesh.bumpScale = _BumpScale/10000;
                    float3 n = getBumpMappedNormal(bumpMesh);
                    float3 l = normalize(_WorldSpaceLightPos0.xyz);
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz);
                    float3 h = normalize(l + v);
                    fixed4 albedo = tex2D(_AlbedoMap, input.uv);
                    fixed4 spectular = tex2D(_SpecularMap, input.uv);
                    fixed4 blinnP = fixed4(blinnPhong(n,h,l,_Shininess,albedo,spectular,_Ambient), 0);
                    return blinnP;
                }

            ENDCG
        }
    }
}
