Shader "Custom/Plant_Wind_Uniform"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5

        _WindStrength ("Wind Strength", Float) = 0.5
        _WindSpeed ("Wind Speed", Float) = 1.0
        _WindDirection ("Wind Direction", Vector) = (1, 0, 0, 0)
    }

    SubShader
    {
        Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Cutoff;

            float _WindStrength;
            float _WindSpeed;
            float4 _WindDirection;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float3 ApplyWind()
            {
                float3 result = float3(0, 0, 0);

                float windPhase = sin(_Time.y * _WindSpeed); // Calculate winds ocillation phase over time
                float windStrengthOverTime = (windPhase + 1.0) * 0.5; // Normalize to 0–1 so that it wont move in the opposite direction
                float3 windDir = normalize(_WindDirection.xyz); // Get wind direction and make sure it's normalized

                // Create a wind velocity vector base on the wind direction and strength
                result = windDir * (windStrengthOverTime * _WindStrength);

                return result;
            }

            v2f vert(appdata v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // Converts the vertex position to world space

                float3 offset = ApplyWind(); // Get the wind offset
                float3 displacedWorld = worldPos + offset; // apply the effect to the world position
                float4 displacedLocal = mul(unity_WorldToObject, float4(displacedWorld, 1.0)); // convert back to local space

                o.vertex = UnityObjectToClipPos(displacedLocal); // Convert to clip space
                o.uv = v.uv; // Pass through UV coordinates
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _Cutoff);
                return col;
            }
            ENDCG
        }
    }
}
