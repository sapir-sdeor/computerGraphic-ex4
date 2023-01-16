Shader "CG/Bonus"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
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
                #include "..\Shaders\CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;

                struct appdata
                { 
                    float4 vertex : POSITION;
                    float3 normal   : NORMAL;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv  : TEXCOORD0;
                    float4 worldPos: TEXCOORD1;
                    float3 normal   : TEXCOORD2;
                };
               
                

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.worldPos = mul(unity_ObjectToWorld, input.vertex);
                    output.uv = getCylindricalUV(input.vertex, 2);
                    output.normal = input.normal;
                    return output;
                }


                fixed4 frag (v2f input) : SV_Target
                {
                    float3 n = normalize(input.normal);
                    fixed4 albedo = tex2D(_AlbedoMap, input.uv);
                    fixed4 spectular = tex2D(_SpecularMap, input.uv);
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz);
                    float3 l = normalize(_WorldSpaceLightPos0.xyz);
                    float lambert = max(0, dot(n,l));
                    fixed4 blinnP = fixed4(blinnPhong(n,v,l,_Shininess,albedo,spectular,_Ambient), 1);
                    return blinnP;
                }

            ENDCG
        }
    }
}

