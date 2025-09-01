Shader "Custom/SimpleSpriteSheet"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Columns ("Columns", Float) = 4
        _Rows ("Rows", Float) = 4
        _Speed ("Frames Per Second", Float) = 8
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Columns;
            float _Rows;
            float _Speed;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate total frames
                float totalFrames = _Columns * _Rows;

                // Calculate current frame based on time and speed
                float frame = floor(_Time.y * _Speed) % totalFrames;

                // Get column and row from frame index
                float col = fmod(frame, _Columns);
                float row = floor(frame / _Columns);

                // Calculate frame size in UV space
                float2 frameSize = float2(1.0 / _Columns, 1.0 / _Rows);

                // Calculate offset
                float2 uvOffset = float2(col, 1.0 - row - 1) * frameSize;

                // Remap UVs to frame
                float2 uv = i.uv * frameSize + uvOffset;

                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
