Shader "Custom/ForwardRenderingShader" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}

	SubShader {
		Tags{ "RenderType" = "Opaque"}
		Pass {
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			//保证使用光找衰减等光照变量时可以被正确赋值
			#pragma multi_compile_fdbase

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
			 	float4 vertex: POSITION;
			 	float3 normal: NORMAL;
			}; 

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float4 worldPos: TEXCOORD1; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i): SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0 * _Color * saturate(dot(worldNormal, worldLightDir));

				fixed3 halfDir = normalize(worldViewDir + worldLightDir);
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

				fixed atten = 1.0;

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}

		Pass {
			Tags{"LightMode" = "ForwardAdd"}

			//使计算得到的光照结果在缓存中与之前的光照结果叠加
			Blend One One 

			CGPROGRAM

			//保证使用光找衰减等光照变量时可以被正确赋值
			#pragma multi_compile_fwdadd

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
			 	float4 vertex: POSITION;
			 	float3 normal: NORMAL;
			}; 

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float4 worldPos: TEXCOORD1; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i): SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0 * _Color * saturate(dot(worldNormal, worldLightDir));

				fixed3 halfDir = normalize(worldViewDir + worldLightDir);
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					float3 lightCoord = mul(unity_WorldToLight, i.worldPos).xyz;
					fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord)).UNITY_ATTEN_CHANNEL;
				#endif

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
