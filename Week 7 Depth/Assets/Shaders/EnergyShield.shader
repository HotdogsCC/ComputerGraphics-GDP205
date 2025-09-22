Shader "Custom/EnergyShield" 
{ 
    Properties 
    { 
        _MainTex("Base Texture", 2D) = "white" {}
        _BaseColour ("Base Colour", Color) = (0, 0, 1, 0.25) 

        [Space]
        _PannerSpeed ("Panner Speed", Range(0,1)) = 0.5
        _PannerDirection ("Panner Direction", Vector) = (0.5, 0.5, 0.0)

        [Space]
        _RimColour ("Rim Glow Colour", Color) = (0.2, 0.8, 1, 0.5)
        _RimPower ("Rim Power", Range(0, 10)) = 3

        [Space]
        _IntersectColour ("Intersection Glow Colour", Color) = (1.0, 0.0, 0.0, 1.0) //the colour of the intersection glow
        _IntersectionPower ("Intersection Power", Range(0.0001, 1)) = 0.25 //this controls the thickness of the intersection glow
    } 
 
    SubShader 
    { 
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" } // Set render queue to transparent 
        ZWrite Off // Disable depth writing for transparency 
        Blend SrcAlpha OneMinusSrcAlpha // Alpha blending 
        Cull Back // Cull back faces 
 
        Pass 
        { 
            CGPROGRAM 
            #pragma vertex vert // Vertex shader nameing it vert 
            #pragma fragment frag // Fragment shader nameing it frag 
            #include "UnityCG.cginc" // Include Unity's common shader functions 
 
            sampler2D _MainTex; //a sampler for the main texture
            float4 _MainTex_ST; //a special macro that holds the texture tiling and offset values
            float4 _BaseColour; // Base colour uniform variable passed from the properties block 

            float _PannerSpeed;
            float2 _PannerDirection;

            float4 _RimColour;
            float _RimPower;

            sampler2D _CameraDepthTexture;
            float4 _IntersectColour;
            float _IntersectionPower;
 
            // Vertex shader input structure 
            struct appdata 
            { 
                float4 vertex : POSITION; // Vertex position 
                float2 uv : TEXCOORD0; // Texture coordinates 
                float3 normal : NORMAL;
            }; 
 
            // Vertex shader output structure 
            struct v2f 
            { 
                float4 pos : SV_POSITION; // Clip space position 
                float2 uv : TEXCOORD0; // Texture coordinates 
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float4 screenPos :TEXCOORD3;
            }; 
 
            v2f vert(appdata v) 
            { 
                v2f o; // Create output structure 
                o.pos = UnityObjectToClipPos(v.vertex); // Transform to clip space 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // Transform UVs for texture samplign

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex); //where this vert is in world space
                o.worldNormal = UnityObjectToWorldNormal(v.normal); //normal of this ver in world space
                o.viewDir = normalize(UnityWorldSpaceViewDir(worldPos.xyz)); //direction of the vertex in reference to the camera
                o.screenPos = ComputeScreenPos(o.pos);

                return o; // Return output structure 
            } 
 
            fixed4 frag(v2f i) : SV_Target 
            { 
                //texture Colour
                float2 panner = _PannerDirection.xy * (_PannerSpeed * _Time.y);
                //wrap the uvs to create a seamless panning effect
                float2 texUV = frac(i.uv+panner);

                //colour
                float4 tex = tex2D(_MainTex, texUV); //sample texture
                float4 baseCol = tex * _BaseColour;

                //rim glow
                float cosTheta = dot(i.viewDir, i.worldNormal);
                float rim = 1.0 - saturate(pow(cosTheta, _RimPower));
                float3 rimGlow = _RimColour.rgb * rim;

                // this gets the depth of the object in world space
                // i.screenPos.xy / i.screenPos.w gets the screen space uv coordinates of the object.
                // unlike the i.uv which is the uv coordinates of the texture on the object, this is the uv of the object on the screen
                // the w component of the screenPos is the depth of the object in world space so if we divide the xy coordinates by w we get the uv coordinates of the object in screen space
                // once we find out where we want to sample the depth texture we can use the SAMPLE_DEPTH_TEXTURE function to get the depth of the scene at that point
                float rawSceneDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.screenPos.xy / i.screenPos.w);
                // LinearEyeDepth converts the raw depth value which is between 0 and 1 to a linear depth value
                // so 0 will be the near plane and 1 will be the far plane of the camera
                // because we will be comparing the world space depth of the object to the scene depth we need to convert the raw depth value to linear
                float sceneEyeDepth = LinearEyeDepth(rawSceneDepth);

                // screenPos.z is the depth of the object in clip space so we need to convert it to eye space
                float fragEyeDepth = LinearEyeDepth(i.screenPos.z / i.screenPos.w); 

                // find the difference between the two depths
                float diff = sceneEyeDepth - fragEyeDepth;
                
                // clamp and invert
                float intersection = 1.0 - saturate(diff);

                //control the thickness
                intersection = pow(intersection, 1.0 / max(_IntersectionPower, 0.5));

                // For debugging purposes
                //return float4(intersection, intersection, intersection, 1);




                //intersection flow
                //float intersection = 1.0;
                float3 intersectionGlow = _IntersectColour.rgb * intersection;

                //Blend Alphas
                float finalAlpha = baseCol.a;
                finalAlpha += (rim * _RimColour.a);
                finalAlpha += (intersection * _IntersectColour.a);
                // Clamp alpha to [0, 1]
                finalAlpha = saturate(finalAlpha);

                // Blend Colours
                float3 finalCol = baseCol.rgb;
                finalCol += rimGlow;
                finalCol += intersectionGlow;
                // Clamp final color to [0, 1]
                finalCol = saturate(finalCol);

                // Output
                return float4(finalCol.rgb, finalAlpha);

            } 
            ENDCG 
        } 
    }
} 