Shader "Custom/LitWithShadowMap"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainColor ("Main Colour", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        // turn off culling so we can see the back faces of the mesh
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 clipSpacePosition : SV_POSITION;
                float2 textureCoordinates : TEXCOORD0;
                float3 worldSpaceNormal : TEXCOORD1;
            };

            v2f vert(appdata vertexData)
            {
                v2f output;
                // Transform the vertex position to clip space
                output.clipSpacePosition = UnityObjectToClipPos(vertexData.vertex);
                // Pass through the texture coordinates
                output.textureCoordinates = vertexData.uv;
                // Calculate the world space normal used for lambert shading
                output.worldSpaceNormal = UnityObjectToWorldNormal(vertexData.normal);

                return output;
            }

            fixed4 frag(v2f input) : SV_Target
            {
                // Sample the main texture
                fixed4 mainTexColor = tex2D(_MainTex, input.textureCoordinates);

                // Combine the texture color with the main color
                fixed4 finalColor = mainTexColor * _MainColor;

                // Return the final color
                return finalColor;
            }

            ENDCG
        }
    }
}
