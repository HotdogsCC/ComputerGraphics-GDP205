Shader "Unlit/TriangleShader"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct VertexData
			{
				float4 position : POSITION;
				float3 localPosition : TEXCOORD1;
			};

			VertexData vert(VertexData input)
			{
				VertexData output;

				output.localPosition = input.position;
				output.position = UnityObjectToClipPos(input.position);

				return output; 
			}

			float4 frag(VertexData input) : SV_TARGET
			{
				//return float4(1.0f, 0.0f, 0.0f, 1.0f);

				// divide local y position by 8; results in -1 and 1
				float normalizedY = input.localPosition.y / 8.0f;

				//use clamp to discard negative values
				float clampedY = clamp(normalizedY, 0.0f, 1.0f);

				//create a new float4 variable for colour
				float4 color;

				//set colour based on height
				if(clampedY < 0.10f)
				{
					color = float4(1.0f, 0.96f, 0.62f, 1.0f); // baige
				}
				else if (clampedY < 0.40f)
				{
					color = float4(0.48f, 0.77f, 0.46f, 1.0f); // light green
				}
				else if (clampedY < 0.70f)
				{
					color = float4(0.10f, 0.48f, 0.19f, 1.0f); // dark green
				}
				else if (clampedY < 0.90f)
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
