Shader "Custom/AnimatedPlant"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5

        _WindStrength ("Wind Strength", Float) = 0.5
        _WindSpeed ("Wind Speed", Float) = 1.0
        _WindDirection ("Wind Direction", Vector) = (1, 0, 0, 0)

        _MinY ("Min Y Height", Float) = 0.0
        _MaxY ("Max Y Height", Float) = 1.0

        _EffectorSource ("Effector Source (xyz) + Radius (w)", Vector) = (0, 0, 0, 0)
        _EffectorStrength ("Effector Strength", Float) = 1.0
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

            float _MinY;
            float _MaxY;

            float4 _EffectorSource;
            float _EffectorStrength;

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

            float GetHeightFactor(float y)
            {
                return saturate((y - _MinY) / (_MaxY - _MinY));
            }

            float3 ApplyWind(float heightFactor)
            {
                float windPhase = sin(_Time.y * _WindSpeed);
                float windStrengthOverTime = (windPhase + 1.0) * 0.5; // Normalize to 0–1
                float3 windDir = normalize(_WindDirection.xyz);
                return windDir * windStrengthOverTime * _WindStrength * heightFactor;
            }

            float3 ApplyEffector(float3 worldPos, float heightFactor)
            {
                float3 effectorPos = _EffectorSource.xyz;
                float effectorRadius = _EffectorSource.w;

                float3 toEffector = worldPos - effectorPos;
                float dist = length(toEffector);

                if (dist >= effectorRadius)
                return 0;

                float3 away = normalize(toEffector);
                float bendAmount = saturate((effectorRadius - dist) / effectorRadius) * _EffectorStrength;

                float3 bendDir = normalize(away + float3(0, - 1, 0));
                return bendDir * bendAmount * heightFactor;
            }

            v2f vert(appdata v)
            {
                v2f o;
                float heightFactor = GetHeightFactor(v.vertex.y);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 offset = ApplyWind(heightFactor) + ApplyEffector(worldPos, heightFactor);
                float3 displacedWorld = worldPos + offset;
                float4 displacedLocal = mul(unity_WorldToObject, float4(displacedWorld, 1.0));

                o.vertex = UnityObjectToClipPos(displacedLocal);
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
