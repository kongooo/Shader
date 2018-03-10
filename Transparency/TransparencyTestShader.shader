Shader "Custom/TransparencyTestShader" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("MainTex", 2D) = "White" {}
		_Cutoff("Alpha CutOff", Range(0, 1)) = 0.5
	}

	SubShader {

		Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutut"}

		Pass {
			Tags{"LightMode" = "Forward"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _Cutoff; 

			struct a2v
			{
				float4 vertex: POSITION;
				float4 texcoord: TEXCOORD0;
				float3 normal: NORMAL; 
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float4 worldPos: TEXCOORD1;
				float2 uv: TEXCOORD2;  
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i): SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				float4 texColor = tex2D(_MainTex, i.uv);

				clip(texColor.a - _Cutoff);

				fixed3 albedo = texColor * _Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldLightDir, worldNormal));

				fixed3 color = ambient + diffuse;

				return fixed4(color, 1);
			}

			ENDCG
		}
	}

	FallBack "Transparent/Cutout/VertexLit"
}
