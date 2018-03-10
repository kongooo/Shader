Shader "Custom/DiffuseFragLight" {
	
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}

	SubShader {
		Pass {
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc" 

			fixed3 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.xyz * _Diffuse * saturate(dot(i.worldNormal, lightWorldDir));
				fixed3 color = ambient + diffuse;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
