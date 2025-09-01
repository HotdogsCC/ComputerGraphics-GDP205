Shader "Unlit/SimplePan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PanSpeed ("Pan Speed", Float) = 1.0
        _PanDirection ("Pan Direction", Vector) = (1, 0, 0, 0)
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _PanSpeed;
            float4 _PanDirection;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                // rename the variables to be more descriptive
                float2 UV = i.uv;
                float time = _Time.y;
                float speed = _PanSpeed;
                float2 direction = normalize(_PanDirection.xy);
                // calculate the offset UV coordinates
                float2 offsetUV = UV + direction * speed * time;
                // wrap the UV coordinates to create a seamless panning effect
                offsetUV = frac(offsetUV);
                // sample the texture using the offset UV coordinates
                fixed4 fragmentColour = tex2D(_MainTex, offsetUV);
                // output the final color
                return fragmentColour;
            }
            ENDCG
        }
    }
}
