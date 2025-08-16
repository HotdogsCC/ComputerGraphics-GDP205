Shader "Unlit/TriangleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_height("height", Float) = 0.0
	}
	
	
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _height;
			struct VertexData
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float3 localPosition : TEXCOORD1;
			};

			VertexData vert(VertexData input)
			{
				VertexData output;

				output.localPosition = input.position;
				output.uv = input.uv;

				float yPos = tex2Dlod(_MainTex, float4(input.uv.xy, 0.0, 0));
				input.position = float4(input.position.x, yPos * _height, input.position.z, 1.0f);
				
				output.position = UnityObjectToClipPos(input.position);

				return output; 
			}

			float4 frag(VertexData input) : SV_TARGET
			{
				//get colour of texture at this pixel
				float4 texColour = tex2D(_MainTex, input.uv);

				//create a new float4 variable for colour
				float4 color;

				//set colour based on height
				 if(texColour.r < 0.10f)
				 {
				 	color = float4(0.2f, 0.46f, 0.92f, 1.0f); // blue
				 }
				 else if (texColour.r < 0.40f)
				 {
				 	color = float4(0.48f, 0.77f, 0.46f, 1.0f); // light green
				 }
				 else if (texColour.r < 0.70f)
				 {
				 	color = float4(0.10f, 0.48f, 0.19f, 1.0f); // dark green
				 }
				 else if (texColour.r < 0.90f)
				 {
				 	color = float4(0.45f, 0.39f, 0.34f, 1.0f); // gray
				 }
				 else
				 {
				 	color = float4(1.0f, 1.0f, 1.0f, 1.0f); // white
				 }
				
				 return color;
					
			}

			ENDCG
		}
	}
}
