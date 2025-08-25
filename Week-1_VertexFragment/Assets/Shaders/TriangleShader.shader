Shader "Unlit/TriangleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_height("height", Float) = 0.0
		_Shininess("shininess", Float) = 256.0
		_SpecularColor("SpecularColor", Color) = (1.0, 1.0, 1.0)
		_SpecularStrength("SpecularStrength", Range(0,1)) = 0.1
		_AmbientStrength("AmbientStrength", Float) = 0.5
	}
	
	
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float _height;
			float _Shininess;
			float4 _SpecularColor;
			float _SpecularStrength;
			float _AmbientStrength;


			struct VertexData
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 localPosition : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			VertexData vert(VertexData input)
			{
				VertexData output;

				output.localPosition = input.position;
				output.uv = input.uv;

				//use world to object matrix to convert vertex to local space
				//then cast it to a 3x3 matrix and use the transpose to calculate the proper normal
				output.normal = mul(transpose((float3x3)unity_WorldToObject), input.normal);
				output.normal = normalize(output.normal);

				//float yPos = tex2Dlod(_MainTex, float4(input.uv.xy, 0.0, 0));
				//input.position = float4(input.position.x, yPos * _height, input.position.z, 1.0f);
				input.position = float4(input.position.xyz, 1.0f);

				output.worldPos = mul(unity_ObjectToWorld, input.position);

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

				 //set albedo
				 float4 albedo = color;

				 //normalize per pixel
				 input.normal = normalize(input.normal);

				 //diffuse
				 float3 lightDir = _WorldSpaceLightPos0.xyz;
				 float3 lightColor = _LightColor0.rgb;
				 float3 diffuse = saturate(dot(lightDir, input.normal)) * lightColor;

				 //spec
				 float3 viewDir = normalize(_WorldSpaceCameraPos - input.worldPos);

				 //phong
				 //float3 reflectionDir = reflect(-lightDir, input.normal);
				 //float clampedSpecValue = saturate(dot(reflectionDir, viewDir));

				 //blinn-phong
				 float3 halfVector = normalize(lightDir + viewDir);
				 float clampedSpecValue = saturate(dot(halfVector, input.normal));

				 float specularPower = pow(clampedSpecValue, _SpecularStrength * _Shininess);
				 float3 specular = _SpecularColor.rgb * specularPower * lightColor;

				 //ambient
				 float ambient = _AmbientStrength * lightColor;

				 float3 totalColor = (diffuse + specular + ambient) * albedo;
				  
				 return float4(totalColor, 1.0f);
					
			}

			ENDCG
		}
	}
}
