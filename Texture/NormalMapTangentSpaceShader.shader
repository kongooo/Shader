Shader "Custom/NormalMapTangentSpaceShader" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("MainTex", 2D) = "White" {}
		_BumpMap("NormalMap", 2D) = "bump" {}
		_BumpScale("BumpScale", Float) = 1.0
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

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

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
				float3 LightDir: TEXCOORD1;
				float3 ViewDir: TEXCOORD2;				
			};


			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//_MainTex和_BumpMap使用一组纹理坐标可以减少差值寄存器的使用数目
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				//得到从模型空间到切线空间的变换矩阵rotation
				TANGENT_SPACE_ROTATION;
				
				//得到切线空间下的光线和视野方向
				o.LightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.ViewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
			}

			fixed3 frag(v2f i) : SV_Target{

				fixed3 tangentLightDir = normalize(i.LightDir);
				fixed3 tangentViewDir = normalize(i.ViewDir);

				//对法线纹理进行采样
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));;
				//当Texture Type为NormalMap时
				//把像素值反映射回法线
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;
               
				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)), _Gloss);

				fixed3 color = ambient + diffuse + specular;

				return color;
			}

			ENDCG
		}
	}

	FallBack "Specular"
}
