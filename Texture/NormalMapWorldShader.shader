Shader "Custom/NormalMapWorldShader" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8, 256)) = 20
		_MainTex("MainTex", 2D) = "White" {}
		_BumpTex("BumpTex", 2D) = "White" {}
		_BumpScale("BumpScale", Float) = 1.0
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
			float _BumpScale;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;

			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 tangent: TANGENT;
				float4 texcoord: TEXCOORD0;  	
			}; 

			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 uv: TEXCOORD0;
				float4 T2W0: TEXCOORD1;
				float4 T2W1: TEXCOORD2;
				float4 T2W2: TEXCOORD3; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 frag(v2f i): SV_Target{
				float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
				bump.xy *= _BumpScale;
				bump = normalize(half3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(bump, worldLightDir));

				fixed3 halfDir = normalize(worldViewDir + worldLightDir);
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(halfDir, bump)), _Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
}
