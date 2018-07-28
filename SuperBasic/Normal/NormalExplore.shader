Shader "Lisoo/Normal/NMask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MaskThreshold ("Mask Threshold", Range(0, 1)) = 0.5
		[Toggle] _WorldNormal ("Use World Normal", Float) = 0		
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;				
				float3 normal : NORMAL;
				float3 worldNormal : TEXCOORD1;
			};


			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _WorldNormal;
			float _MaskThreshold;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;

				//transform normal vector from object to world system
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				float mask;
				if (_WorldNormal == 1)
				{
					mask = step(_MaskThreshold, abs(i.worldNormal.b));
				}
				else
				{
					mask = step(_MaskThreshold, abs(i.normal.b));
				}

				col *= mask;
				col.a = 1.0;

				return col;
			}
			ENDCG
		}
	}
}
