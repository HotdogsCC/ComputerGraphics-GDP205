Shader "Custom/FlowMapPanner"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _FlowMap ("Flow Map", 2D) = "gray" {}
        _FlowStrength ("Flow Strength", Float) = 1
        _FlowSpeed ("Flow Speed", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _FlowMap;
            float _FlowStrength;
            float _FlowSpeed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 flowUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float4 _MainTex_ST;
            float4 _FlowMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.flowUV = TRANSFORM_TEX(v.uv, _FlowMap);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Sample the flow map
                float2 flow = tex2D(_FlowMap, i.flowUV).rg * 2 - 1; // Map from [0, 1] to [ - 1, 1]

                // Calculate offset based on time, flow direction, strength, and speed
                float2 offset = flow * _FlowStrength * _Time.y * _FlowSpeed;

                // Sample the main texture with offset
                fixed4 col = tex2D(_MainTex, i.uv + offset);

                return col;
            }
            ENDCG
        }
    }
}
