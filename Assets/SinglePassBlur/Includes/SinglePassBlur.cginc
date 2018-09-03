#ifndef SPB_SINGLEPASSBLUR_INCLUDE
#define SPB_SINGLEPASSBLUR_INCLUDE

/* include */
#include <UnityCG.cginc>

/* --- Functions --- */
	inline float2 spb_calculateBlurCoord(float factor, float frequency, float2 coefCoord, float2 texcoord)
	{
		frequency *= UNITY_TWO_PI;
		texcoord.x += cos(coefCoord.x*frequency + UNITY_HALF_PI)*factor;
		texcoord.y += sin(coefCoord.y*frequency)*factor;
		return texcoord;
	}

#endif