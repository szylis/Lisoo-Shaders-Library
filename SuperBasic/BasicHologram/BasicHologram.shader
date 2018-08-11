Shader "Lisoo/BasicHologram"
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
		_SecondColor("Back Side Color", Color) = (1, 1, 1, 1)
		_BackIntensity("Back Side Intensity", Range(0, 1)) = 0.1
	}

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

			#include "UnityCG.cginc"

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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _SecondColor;
			float _BackIntensity;

			v2f vert(appdata v)
			{
				v2f o;
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

			fixed4 frag(v2f i) : SV_Target
			{
				float VNdot = abs(dot(i.viewDir, i.worldNormal));
				fixed4 col = _SecondColor;
				
				col.a = VNdot * _BackIntensity;
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

			#include "UnityCG.cginc"

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
			};


			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _MainColor;
			float _FrontIntensity;
			
			float4 _RimColor;
			float _RimIntensity;

			v2f vert(appdata v)
			{
				v2f o;
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

			fixed4 frag(v2f i) : SV_Target
			{
				float VNdot = abs(dot(i.viewDir, i.worldNormal));
				float rim = pow(1 - VNdot, _RimIntensity);
				
				fixed4 col = _MainColor + _RimColor*rim;

				col.a = rim + _FrontIntensity;

				return col;
			}

			ENDCG
		}
	}
}

