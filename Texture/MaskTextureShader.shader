Shader "Custom/MaskTextureShader" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8, 256)) = 20
		_MainTex("MainTex", 2D) = "White" {}
		_MaskTex("MaskTex", 2D) = "White" {}
		_BumpTex("BumpTex", 2D) = "White" {}
		_MaskScale("MaskScale", Float) = 1.0
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
			sampler2D _MainTex;
			float4 _MainTex_ST;//三张纹理均使用一个纹理平铺系数，可以节省需要储存的纹理坐标数目
			sampler2D _MaskTex;
			sampler2D _BumpTex;
			float _MaskScale;
			float _BumpScale;

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
				float2 uv: TEXCOORD0;
				float3 viewDir: TEXCOORD1;
				float3 lightDir: TEXCOORD2; 
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				//得到切线空间下的视角和光照方向
				TANGENT_SPACE_ROTATION;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

				return  o;
			}

			fixed4 frag(v2f i): SV_Target{
				fixed3 tangentViewDir = normalize(i.viewDir);
				fixed3 tangentLightDir = normalize(i.lightDir);

				fixed3 tangentNormal = normalize(UnpackNormal(tex2D(_BumpTex, i.uv)) * _BumpScale);

				fixed3 albedo = tex2D(_MainTex, i.uv) * _Color;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * _Color;

				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(tangentNormal, tangentLightDir));

				fixed3 specularMask = tex2D(_MaskTex, i.uv).r * _MaskScale;

				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
				fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(halfDir, tangentNormal)), _Gloss) * specularMask;

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
}
