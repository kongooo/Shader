﻿Shader "Custom/AlphaBlend" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("MainTex", 2D) = "White" {}
		_AlphaScale("AlphaScale", Range(0, 1)) = 0.5
	}

	SubShader{
		Tags{"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}

		Pass{
			Tags{"LightMode" = "ForwardBase"}

			ZWrite Off 
			Blend SrcAlpha OneMinusSrcAlpha   

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			struct a2v{
				float4 Vertexs : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			
			struct v2f{
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.Vertexs);
				o.worldPos = mul(unity_ObjectToWorld, v.Vertexs);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i): SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);

				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Color;

				fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldNormal, worldLightDir));

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
			}

			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
