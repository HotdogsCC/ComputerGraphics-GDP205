Shader "Custom/Mask"
{
    Properties
    {
        _StencilRef("Stencil Reference", Range(0, 255)) = 1 // stencil reference value
        _Cutoff ("Cutoff Threshold", Range(0,1)) = 0.5
        _MaskTex ("Mask Texture", 2D) = "white" {}

    }
    SubShader
    {
        //tell unity this is opaque
        Tags{"RenderType"="Opaque"}

        Pass
        {
            //Stencil buffer setup block
            Stencil 
            {
                //reference value to write to the stencil buffer
                Ref [_StencilRef]
                //always pass the stencil test
                Comp always
                //on passing the stencil test, replcae the stencil buffer value with the reference
                Pass replace
            }

            //disables writing to the colour buffer
            ColorMask 0
            //always pass the depth test
            ZTest Always 
            //do not write to the depth buffer
            ZWrite Off

            CGPROGRAM // Begins a Cg / HLSL shader block
            #pragma vertex vert  // Sets the vertex shader function to "vert"
            #pragma fragment frag // Sets the fragment shader function to "frag"
            #include "UnityCG.cginc"// Includes Unity's common shader utilities (macros, functions, etc.) this is used for TRANSFORM_TEX() within this shader.
            
            sampler2D _MaskTex; // The mask texture input
            float4 _MaskTex_ST; // The _ST suffix stands for Scale and Translate, and Unity packs the texture's Tiling and Offset values (from the Material inspector) into this float4 variable.
            float _Cutoff; // Threshold for discarding pixels based on mask intensity
            
            // this is the struct that is passed to the vertex shader. it can be named anything you want.
            // the variables inside map to the vertex attributes in the mesh.
            // more info here : https://docs.unity3d.com/ScriptReferenceRendering.VertexAttribute.html
            struct appdata
            {
                float4 vertex : POSITION; // Object - space position of the vertex
                float2 uv : TEXCOORD0; // Texture coordinates of the vertex
            };
            
            // this is the struct that is passed to the fragment shader from the ver. once again it can be named anything you want.
            // the variables inside map to the output attributes of the vertex shader.
            struct v2f
            {
                float4 pos : SV_POSITION; // Clip - space position (for screen rendering)
                float2 uv : TEXCOORD0; // Texture coordinates
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // Converts object position to clip space for rendering
                o.uv = TRANSFORM_TEX(v.uv, _MaskTex); // Applies tiling and offset to UVs
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
            
                float mask = tex2D(_MaskTex, i.uv).r; // Sample the mask texture using the UV coordinates passed from the vertex shader. we only need the red channel for this shader.
                if (mask.r < _Cutoff) // Compare the sampled mask value against the cutoff threshold
                discard; // If the mask value is below the cutoff, discard the fragment (do not render it)
                // else, we will render the fragment normally.
                // in this case we can just return 0, which is black.
                // this is because we are not writing to the color buffer in this pass, only the stencil buffer.
                return 0;
            
            }
            ENDCG // Ends the Cg / HLSL shader block

        }
    }

}
