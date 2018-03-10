Shader "Custom/SpecularFrag" {
	
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}

	SubShader {
		Pass {
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				fixed4 vertex: POSITION;
				fixed4 normal: NORMAL; 	
			}; 

			struct v2f
			{
				fixed4 pos: SV_POSITION;
				fixed3 worldNormal: TEXCOORD0; 
				fixed3 viewDir: TEXCOORD1;
				fixed3 worldLightDir: TEXCOORD2; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.viewDir = normalize(UnityWorldSpaceViewDir(v.vertex));
				o.worldLightDir = normalize(UnityWorldSpaceLightDir(v.vertex));
				return o;
			}

			fixed3 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed3 diffuse = unity_LightColor0 * _Diffuse * (0.5 * dot(i.worldLightDir, i.worldNormal) + 0.5);

				fixed3 reflectDir = normalize(reflect(-i.worldLightDir, i.worldNormal));
				fixed3 specular = unity_LightColor0 * _Specular * pow(saturate(dot(i.viewDir, reflectDir)), _Gloss);

				fixed3 color = ambient + diffuse + specular;

				return color;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
