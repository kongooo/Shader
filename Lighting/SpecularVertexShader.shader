Shader "Custom/SpecularVertexShader" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_Specular("Specular", Color) = (1, 1, 1, 1)
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
				fixed3 color: COLOR;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				fixed3 diffuse = _LightColor0 * _Diffuse * (0.5 * dot(worldNormal, worldLightDir) + 0.5);

				fixed3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(viewDir, reflectDir)), _Gloss);

				o.color = ambient + diffuse + specular;
				
				return o;
			}

			fixed3 frag(v2f i) : SV_Target{
				return i.color;
			}

			ENDCG
		}
	}


	FallBack "Diffuse"
}
