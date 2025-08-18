Shader "Unlit/ScreenShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScrollSpeed("Scroll Speed", Float) = 10
        _Contrast("Contrast", Float) = 0.03
        _LineCount("Line Count", Float) = 200
        _WobbleFrequency("Wobble Frequency", Float) = 10
        _WobbleSpeed("Wobble Speed", Float)= 1
        _WobbleSize("Wobble Size", Float) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            float _ScrollSpeed;
            float _Contrast;
            float _LineCount;
            float _WobbleFrequency;
            float _WobbleSpeed;
            float _WobbleSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //add warpiness
                fixed2 warp = i.uv -=(sin((i.uv.y * _WobbleFrequency) + (_Time.w*_WobbleSpeed))) * _WobbleSize;
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, warp);

                //constant for luminocity
                fixed3 lum = fixed3(0.299f, 0.587f, 0.114f);

                //covert to b and w
                fixed intensity = dot(col.rgb, lum);

                //add lines
                intensity -= (sin((i.uv.y*_LineCount) +  (_Time.w*_ScrollSpeed))) * _Contrast;

                
                
                col = fixed4(intensity, intensity, intensity, col.a);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
