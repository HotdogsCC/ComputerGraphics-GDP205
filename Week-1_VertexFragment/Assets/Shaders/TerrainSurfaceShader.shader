Shader "Custom/TerrainSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            float4 texColour = c;

            float4 color;
            //set colour based on height
			if(texColour.r < 0.30f)
			{
				color = float4(0.2f, 0.46f, 0.92f, 1.0f); // blue
			}
			else if (texColour.r < 0.40f)
			{
				color = float4(0.48f, 0.77f, 0.46f, 1.0f); // light green
			}
			else if (texColour.r < 0.50f)
			{
				color = float4(0.10f, 0.48f, 0.19f, 1.0f); // dark green
			}
			else if (texColour.r < 0.70f)
			{
				color = float4(0.45f, 0.39f, 0.34f, 1.0f); // gray
			}
			else
			{
				color = float4(1.0f, 1.0f, 1.0f, 1.0f); // white
			}

            o.Albedo = color.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
