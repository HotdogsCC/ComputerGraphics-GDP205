Shader "Unlit/TriangleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				
				output.position = UnityObjectToClipPos(input.position);

				return output; 
			}

			float4 frag(VertexData input) : SV_TARGET
			{
				float4 texColour = tex2D(_MainTex, input.uv);

				float4 outColour = texColour;

				return outColour;
				
				//return float4(1.0f, 0.0f, 0.0f, 1.0f);

				// divide local y position by 8; results in -1 and 1
				//float normalizedY = input.localPosition.y / 8.0f;

				//use clamp to discard negative values
				//float clampedY = clamp(normalizedY, 0.0f, 1.0f);

				//create a new float4 variable for colour
				//float4 color;

				//set colour based on height
				// if(clampedY < 0.10f)
				// {
				// 	color = float4(1.0f, 0.96f, 0.62f, 1.0f); // baige
				// }
				// else if (clampedY < 0.40f)
				// {
				// 	color = float4(0.48f, 0.77f, 0.46f, 1.0f); // light green
				// }
				// else if (clampedY < 0.70f)
				// {
				// 	color = float4(0.10f, 0.48f, 0.19f, 1.0f); // dark green
				// }
				// else if (clampedY < 0.90f)
				// {
				// 	color = float4(0.45f, 0.39f, 0.34f, 1.0f); // gray
				// }
				// else
				// {
				// 	color = float4(1.0f, 1.0f, 1.0f, 1.0f); // white
				// }
				//
				// return color;
					
			}

			ENDCG
		}
	}
}
