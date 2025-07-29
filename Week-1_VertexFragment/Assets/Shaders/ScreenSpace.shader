// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ScreenSpace" {
 Properties {
  _MainTex ("Color Texture", 2D) = "white" {}     
  _SSUVScale("UV Scale", Range(0,1)) = 0.2
	}

CGINCLUDE
	sampler2D _MainTex;
	float _SSUVScale; 

	struct appdata {
		float4 vertex : POSITION;
	};

	struct v2f {
		float4 pos : POSITION;
	};

ENDCG

SubShader {
  	Tags { "RenderType" = "Opaque" }

  	Pass 
	{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		v2f vert(appdata input) {
			//declare output vector positions
			v2f output;

			//get vector positions transformed to screen spcae
			output.pos = UnityObjectToClipPos(input.vertex);

			//return the output
			return output;
		}		

		half4 frag(v2f i) : COLOR 
		{ 				
			//confine the pixel (which is between 1920 and 1080 for HD) between 0 and 1
			float2 screenUV = float2(i.pos.x/_ScreenParams.x,i.pos.y/_ScreenParams.y);

			//get the aspect ratio of the view port
			float screenRatio = _ScreenParams.y/_ScreenParams.x;

			//shift everything over so the uv scales from the centre
			screenUV.x -= 0.5f;
			screenUV.y -= 0.5f;

			//multiply the y by the aspect ratio of the viewport to avoid skewing
			screenUV.y *= screenRatio;

			//multiply by the uv scale (variable that controls tiling)
			screenUV *= 1/_SSUVScale; 

			//get the colour of the texture at that position
			half4 screenTexture = tex2D (_MainTex, screenUV);

			//return that colour
			return screenTexture; 
		} 
		ENDCG				 
	} 
}
}