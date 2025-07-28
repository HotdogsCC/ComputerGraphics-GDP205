Shader "Unlit/TriangleShader"
{
	Properties
	{
		_WaterColour ("Water Colour", Color) = (1, 1, 1, 1)
		_FoamColour ("Foam Colour", Color) = (1, 1, 1, 1)
		
		_FoamHeight("Foam Height", Float) = 1
		
		_Wave1Amplitude ("Wave 1 Amplitude", Float) = 1
		_Wave1Frequency ("Wave 1 Frequency", Float) = 1
		
		_Wave2Amplitude ("Wave 2 Amplitude", Float) = 1
		_Wave2Frequency ("Wave 2 Frequency", Float) = 1
		
		_Wave3Amplitude ("Wave 3 Amplitude", Float) = 1
		_Wave3Frequency ("Wave 3 Frequency", Float) = 1
	}
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

			float4 _WaterColour;
			float4 _FoamColour;
			float _Wave1Amplitude;
			float _Wave1Frequency;
			float _Wave2Amplitude;
			float _Wave2Frequency;
			float _Wave3Amplitude;
			float _Wave3Frequency;
			float _FoamHeight;

			VertexData vert(VertexData input)
			{
				VertexData output;

				output.position = input.position;
				
				//alters y
				output.position[1] += sin((_Time * _Wave1Frequency) + input.position[0]) * _Wave1Amplitude;
				output.position[1] += sin((_Time * _Wave3Frequency) + input.position[0]) * _Wave3Amplitude;
				output.position[1] += cos((_Time * _Wave2Frequency) + input.position[2]) * _Wave2Amplitude;

				output.localPosition = output.position;
				
				//transform to clip space
				output.position = UnityObjectToClipPos(output.position);
				

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
				if(input.localPosition[1] > _FoamHeight)
				{
					color = _FoamColour;
				}
				else
				{
					color = _WaterColour;
				}

				return color;
					
			}

			ENDCG
		}
	}
}
