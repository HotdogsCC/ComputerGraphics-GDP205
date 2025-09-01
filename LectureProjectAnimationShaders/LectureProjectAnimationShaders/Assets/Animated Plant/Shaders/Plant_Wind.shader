Shader "Custom/Plant_Wind"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5

        _WindStrength ("Wind Strength", Float) = 0.5
        _WindSpeed ("Wind Speed", Float) = 1.0
        _WindDirection ("Wind Direction", Vector) = (1, 0, 0, 0)

        _MinY ("Min Y Height", Float) = 0.0 // Minimum Y height of the model
        _MaxY ("Max Y Height", Float) = 1.0 // Maximum Y height of the model
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
            float _MinY; // add this to define the minimum Y height of the model
            float _MaxY; // add this to define the maximum Y height of the model

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

            // Function to calculate height factor based on vertex Y position
            float GetHeightFactor(float y)
            {
                return saturate((y - _MinY) / (_MaxY - _MinY)); // Normalize Y position to a 0 - 1 range because we want to use it as a factor
            }

            float3 ApplyWind(float heightFactor)
            {
                float windPhase = sin(_Time.y * _WindSpeed); // Calculate wind phase based on time and speed
                float windStrengthOverTime = (windPhase + 1.0) * 0.5; // Normalize to 0–1
                float3 windDir = normalize(_WindDirection.xyz); // Get wind direction and make sure it's normalized
                return windDir * windStrengthOverTime * _WindStrength * heightFactor; // Apply wind strength and height factor
            }

            v2f vert(appdata v)
            {
                v2f o;
                float heightFactor = GetHeightFactor(v.vertex.y);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // move the vetex from object space to world space

                float3 offset = ApplyWind(heightFactor); // Calculate wind offset
                float3 displacedWorld = worldPos + offset; // Apply wind offset to world position
                float4 displacedLocal = mul(unity_WorldToObject, float4(displacedWorld, 1.0)); // Convert back to local space

                o.vertex = UnityObjectToClipPos(displacedLocal); // Convert to clip space
                o.uv = v.uv;
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
