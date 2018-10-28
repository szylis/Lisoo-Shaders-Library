Shader "Lisoo/GridHologram"
{

	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

		[Header(Front Side)]
		_MainColor("Main Color", Color) = (1, 1, 1, 1)
		_FrontIntensity("Front Side Intensity", Range(0,1)) = 0.0

		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimIntensity("Rim Intensity", Range(0, 10)) = 1

		[Header(Back Side)]
		_BackIntensity("Back Side Intensity", Range(0, 1)) = 0.1

		[Header(Grid)]
		_CycleCount("Cycle Count", Range(0,40)) = 1
		_LineDefinition("Line Definition", Range(0, 32)) = 1
	}

	CGINCLUDE

		#include "UnityCG.cginc"

		#define PI 3.14159265
		#define TWO_PI 6.2831853

		sampler2D _MainTex;
		float4 _MainTex_ST;

		float _CycleCount;
		float _LineDefinition;
		
		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float3 worldNormal : NORMAL;
			float2 uv : TEXCOORD0;
			float3 viewDir : TEXCOORD1;
			float4 localVertex : TEXCOORD2;
		};

		v2f vert(appdata v)
		{
			v2f o;

			o.localVertex = v.vertex;

			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);

			// transform normal from object to world space
			o.worldNormal = UnityObjectToWorldNormal(v.normal);

			//transfrom vertex from object to world space
			float4 worldVertex = mul(unity_ObjectToWorld, v.vertex);

			// compute world space view direction				
			o.viewDir = normalize(UnityWorldSpaceViewDir(worldVertex.xyz));
			return o;
		}

		float GridMask(float4 vertex)
		{
			// Y - axis
			float maskY = cos(PI * vertex.y * _CycleCount);
			maskY = (maskY + 1.0) * 0.5f;
			maskY = pow(maskY, _LineDefinition);

			// X - axis
			float maskX = cos(PI * vertex.x * _CycleCount);
			maskX = (maskX + 1.0) * 0.5f;
			maskX = pow(maskX, _LineDefinition);

			// Z - axis
			float maskZ = cos(PI * vertex.z * _CycleCount);
			maskZ = (maskZ + 1.0) * 0.5f;
			maskZ = pow(maskZ, _LineDefinition);

			return (maskX + maskY + maskZ) / 3.0;
		}

	ENDCG

	SubShader
	{

		Tags{ "RenderType" = "Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha
		
		// Render the back facing parts of the model
		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 _MainColor;
			float _FrontIntensity;

			float4 _RimColor;
			float _RimIntensity;

			float _BackIntensity;

			fixed4 frag(v2f i) : SV_Target
			{

				float VNdot = abs(dot(i.viewDir, i.worldNormal));
				float rim = pow(1 - VNdot, _RimIntensity);

				fixed4 col = _MainColor + _RimColor * rim;
				col.a = (rim + _FrontIntensity);

				float mask = GridMask(i.localVertex) * _BackIntensity;

				col.a *= mask;

				return col;
			}

			ENDCG
		}

		// Render the front facing parts of the model
		Pass
		{
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 _MainColor;
			float _FrontIntensity;
			
			float4 _RimColor;
			float _RimIntensity;

			fixed4 frag(v2f i) : SV_Target
			{
				
				float VNdot = abs(dot(i.viewDir, i.worldNormal));
				float rim = pow(1 - VNdot, _RimIntensity);
				
				fixed4 col = _MainColor + _RimColor*rim;
				col.a = (rim + _FrontIntensity);

				float mask = GridMask(i.localVertex);

				col.a *= mask;

				return col;
			}

			ENDCG
		}
	}
}

