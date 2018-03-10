Shader "Custom/SingleTextureShader" {
	Properties{
		_Color("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8,256)) = 20
		_MainTex("MainTex", 2D) = "While" {}
	}

	SubShader {
		Pass {
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc" 

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v
			{
				float3 vertex: POSITION;
				fixed3 normal: NORMAL;
				float4 texcoord: TEXCOORD0; 
			};

			struct v2f
			{
				fixed4 pos: SV_POSITION;
				fixed3 worldNormal: TEXCOORD0;
				fixed3 worldPos: TEXCOORD1;
				float2 uv: TEXCOORD2; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed3 frag(v2f i) : SV_Target{
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldNormal));

				fixed3 albedo = tex2D(_MainTex, i.uv) * _Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldLightDir, i.worldNormal));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(i.worldNormal, worldLightDir)), _Gloss);

				fixed3 color = ambient + diffuse + specular;

				return color;
			}

			ENDCG
		}
	}

	FallBack "Specular"
}
