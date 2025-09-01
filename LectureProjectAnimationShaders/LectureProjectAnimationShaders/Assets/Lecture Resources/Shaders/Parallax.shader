Shader "Custom/UnlitLayeredParallaxAlphaCutout"
{
    Properties
    {
        _BackgroundTexture("Background Layer (Farthest)", 2D) = "white" {}
        _MiddlegroundTexture("Middleground Layer", 2D) = "white" {}
        _ForegroundTexture("Foreground Layer (Closest)", 2D) = "white" {}

        _DepthBackground("Depth - Background", Range(-1, 1)) = 0.01
        _DepthMiddleground("Depth - Middle", Range(-1, 1)) = 0.02
        _DepthForeground("Depth - Foreground", Range(-1, 1)) = 0.03

        _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "TransparentCutout" }
        LOD 100
        Pass
        {
            Cull Off
            ZWrite On
            AlphaTest Greater [_Cutoff]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _BackgroundTexture, _MiddlegroundTexture, _ForegroundTexture;
            float _DepthBackground, _DepthMiddleground, _DepthForeground;
            float _Cutoff;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = _WorldSpaceCameraPos - worldPos;

                o.uv = v.uv;
                o.worldPos = worldPos;
                return o;
            }

            float2 ParallaxOffset(float2 uv, float3 viewDir, float depth)
            {
                float2 offset = normalize(viewDir) * depth;
                return uv + offset;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv1 = ParallaxOffset(i.uv, i.viewDir, _DepthBackground);
                float2 uv2 = ParallaxOffset(i.uv, i.viewDir, _DepthMiddleground);
                float2 uv3 = ParallaxOffset(i.uv, i.viewDir, _DepthForeground);

                fixed4 backgroundColour = tex2D(_BackgroundTexture, uv1);
                fixed4 middlegroundColour = tex2D(_MiddlegroundTexture, uv2);
                fixed4 foregroundColour = tex2D(_ForegroundTexture, uv3);

                fixed4 finalCol = backgroundColour;
                if (middlegroundColour.a > _Cutoff)
                finalCol = middlegroundColour;
                if (foregroundColour.a > _Cutoff)
                finalCol = foregroundColour;

                clip(finalCol.a - _Cutoff);
                return finalCol;
            }
            ENDCG
        }
    }
    FallBack Off
}
