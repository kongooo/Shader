Shader "Custom/HarfLambertShader" {
	
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

			fixed4 _Diffuse;

			struct a2v
			{
				fixed4 vertex: POSITION;
				fixed4 normal: NORMAL; 	
			}; 

			struct v2f
			{
				fixed4 pos: SV_POSITION;
				fixed3 worldNormal: TEXCOORD0; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed3 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);
				fixed3 diffuse = _LightColor0 * _Diffuse * (0.5 * dot(i.worldNormal, worldLightDir) + 0.5);
				fixed3 color = ambient + diffuse;
				return color;
			}

			ENDCG
		}

		



	}

	FallBack "Diffuse"
}
