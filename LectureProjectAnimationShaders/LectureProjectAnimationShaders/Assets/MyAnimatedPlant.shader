Shader "Unlit/MyAnimatedPlant"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5

        _WindStrength ("Wind Strength", Float) = 0.5
        _WindSpeed ("Wind Speed", Float) = 1.0
        _WindDirection ("Wind Direction", Vector) = (1, 0, 0, 0)

        _MinY("Min Y Height", Float) = 0.0
        _MaxY("Max Y Height", Float) = 1.0

        _EffectorSource ("Effector Source (xyz) + Radius (w)", Vector) = (0, 0, 0, 0)
        _EffectorStrength ("Effector Strength", Float) = 1.0
    }

    SubShader
    {
        Tags {"Queue" = "AlphaTest" "RenderType"="TransparentCutout" }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Cutoff;

            float _WindStrength;
            float _WindSpeed;
            float3 _WindDirection;

            float _MinY;
            float _MaxY;

            float4 _EffectorSource; 
            float _EffectorStrength;


            //float4 _MainTex_ST;

            float GetHeightFactor(float y)
            {
                return saturate((y - _MinY) / (_MaxY - _MinY));

            }

            float3 ApplyWind(float heightFactor)
            {
                float windPhase = sin(_Time.y * _WindSpeed); // Calculate wind phase based on time and speed
                float windStrengthOverTime = (windPhase + 1.0) * 0.5; // Normalize to 0–1
                float3 windDir = normalize(_WindDirection.xyz); // Get wind direction and make sure it's normalized
                return windDir * windStrengthOverTime * _WindStrength * heightFactor; // Apply wind strength and height factor

            }

            float3 ApplyEffector(float3 worldPos, float heightFactor)
            {
                float3 effectorPos = _EffectorSource.xyz; // this is the position of the effector in world space 
                float effectorRadius = _EffectorSource.w; // this is the radius of the effector 
 
                float3 toEffector = worldPos - effectorPos; // vector from the vertex to the effector 
                float dist = length(toEffector); // distance from the vertex to the effector 
                if (dist >= effectorRadius) return 0; // if the vertex is outside the effector radius, return 0 no offset shorthand for returning float3(0,0,0) 
 
                float3 away = normalize(toEffector); // direction from the effector to the vertex 
                float bendAmount = saturate((effectorRadius - dist) / effectorRadius) * _EffectorStrength; // how much to bend the vertex based on the distance to the effector 
                float3 bendDir = normalize(away + float3(0, - 1, 0));// this is the direction to bend the vertex, we add a downward vector to give a bias to bending downwards 
 
                return bendDir * bendAmount * heightFactor; // create the bend offset and return it 

            }

            v2f vert (appdata v)
            {
                v2f o;
                float heightFactor = GetHeightFactor(v.vertex.y);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 offset = float3(0,0,0);
                offset += ApplyWind(heightFactor); 
                offset += ApplyEffector(worldPos, heightFactor);

                float3 displacedWorld = worldPos + offset;
                float4 displacedLocal = mul(unity_WorldToObject, float4(displacedWorld, 1.0));


                o.vertex = UnityObjectToClipPos(displacedLocal);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                clip(col.a - _Cutoff);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
