Shader "MinecraftShader"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
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
				float4 screenPos : TEXCOORD2;
			};

			sampler2D _MainTexture;

			VertexData vert(VertexData input)
			{
				VertexData output;
				
				output.localPosition = input.position;
				
				output.position = input.position;
				
				//transform to clip space
				output.position = UnityObjectToClipPos(input.position);
				output.screenPos = ComputeScreenPos(output.position); 
				
				
				return output; 
			}

			float4 frag(VertexData input) : SV_TARGET
			{

				return tex2D(_MainTexture, input.screenPos);

				//return color;
					
			}

			ENDCG
		}
	}
}
