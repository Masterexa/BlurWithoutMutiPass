Shader "BlurShader/Unlit"
{
	Properties
	{
		_Color					("Tint", Color)=(1,1,1,1)
		_MainTex				("Texture", 2D) = "white" {}
		[Toggle]_FactorByTime	("Factor by Time", Float)=1
		_Factor					("Factor", Range(0,1))=0
		_Frequency				("Frequency", Range(0,1))=0.5

		_MaskTex	("Mask", 2D)="white"{}
	}
	CGINCLUDE
	#include <Assets/SinglePassBlur/Includes/SinglePassBlur.cginc>

	/* --- Uniforms --- */
		fixed4		_Color;
		sampler2D	_MainTex;
		float4		_MainTex_ST;
		
		fixed		_FactorByTime;
		float		_Factor;
		float		_Frequency;
		float2		_BlurShift;
		sampler2D	_MaskTex;

	/* --- Pixel Shader Function --- */
		fixed4 calcBlur(float4 vertex, float2 uv)
		{
			float fDiv2 = _Factor*0.5;
			float factor = lerp(_Factor, sin(_Time*10.0)*fDiv2+fDiv2, _FactorByTime);
			// Mask
			factor *= tex2D(_MaskTex, uv).r;

			return tex2D(
				_MainTex,
				spb_calculateBlurCoord(factor, _Frequency, vertex.xy, uv)
			) * _Color;
		}
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog	// make fog work


			/* --- Typedefs --- */
				struct appdata {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f {
					float2 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
						float4 vertex : SV_POSITION;
				};


			/* --- Kernels --- */
				/* Vertex Shader
				 */
				v2f vert(appdata v)
				{
					v2f o;
					o.vertex	= UnityObjectToClipPos(v.vertex);
					o.uv		= TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o, o.vertex);
					return o;
				}

				/* Pixel Shader
				 */
				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 color;
					color = calcBlur(i.vertex, i.uv);

					// apply fog
					UNITY_APPLY_FOG(i.fogCoord, color);
					return color;
				}
			ENDCG
		}
	}
}
