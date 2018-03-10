Shader "Custom/DiffuseVertexLight" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}

	SubShader {
		Pass {
			//定义改pass在unity光照流水线中的角色
			Tags{ "LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			//方便使用Unity内置变量
			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v{
			 	fixed4 vertex : POSITION;//访问顶点坐标
			 	fixed4 normal : NORMAL;//访问顶点法线
			}; 

			struct v2f{
				fixed4 pos : SV_POSITION;//必须包含，使渲染器得到裁减空间中的顶点坐标
				fixed3 color : COLOR;
			};

			v2f vert(a2v v){
				v2f o;
				//把顶点坐标从模型空间转换到世界空间
				o.pos = UnityObjectToClipPos(v.vertex);
				//得到环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				//把法线从模型空间转换到世界空间并归一化
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//得到归一化的世界空间下的光线方向
				fixed3 worldLightDir = _WorldSpaceLightPos0;
				//计算漫反射光
				fixed3 diffuse = (_LightColor0 * _Diffuse) * saturate(dot(worldNormal, worldLightDir));

				o.color = diffuse + ambient;

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
