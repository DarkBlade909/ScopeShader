// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ScopeMathDistort"
{
	Properties
	{
		[HideInInspector]_RenderTexture("Render Texture", 2D) = "white" {}
		[NoScaleOffset][Header(Shader by DarkBlade909)][Space(10)][Header(____________________________TEXTURES______________________________)][Space(10)]_Reticle("Reticle", 2D) = "white" {}
		[HDR]_ReticleTint("Reticle Tint", Color) = (1,1,1,1)
		_ReticleScale("Reticle Scale", Range( 0 , 1)) = 0
		_ReticleParallax("Reticle Parallax", Range( 0 , 1)) = 0.005
		_RoughnessMap("Roughness Map", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_MetallicMap("Metallic Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[Space(25)][Header(_________________________SCOPE SETTINGS______________________________)][Space(10)]_Parallax("Parallax", Range( 0 , 1)) = 0.734
		_EmissionStrength("Emission Strength", Range( 0 , 1)) = 0
		_LensShadowDepth("Lens Shadow Depth", Float) = 4.72
		_ScopeDistortionsize("Scope Distortion size", Range( 0 , 1)) = 0.7
		_ScopeDistortionStrength("Scope Distortion Strength", Range( -10 , 10)) = 0.6
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv2_texcoord2;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _RenderTexture;
		uniform float _Parallax;
		uniform float _LensShadowDepth;
		uniform float _ScopeDistortionsize;
		uniform float _ScopeDistortionStrength;
		uniform sampler2D _Reticle;
		uniform float _ReticleScale;
		uniform float _ReticleParallax;
		uniform float4 _ReticleTint;
		uniform float _EmissionStrength;
		uniform float _Metallic;
		uniform sampler2D _MetallicMap;
		uniform float4 _MetallicMap_ST;
		uniform float _Smoothness;
		uniform sampler2D _RoughnessMap;
		uniform float4 _RoughnessMap_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 ase_tanViewDir = mul( ase_worldToTangent, ase_worldViewDir );
			float3 lerpResult16 = lerp( float3( i.uv2_texcoord2 ,  0.0 ) , (( 10.0 * -ase_tanViewDir )*0.05 + ( 0.0 + 0.5 )) , _Parallax);
			float3 _Vector1 = float3(0,0,0);
			float2 temp_output_35_0 = ((float2( -1,-1 ) + (i.uv2_texcoord2 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )))*1.0 + ( ( _LensShadowDepth * _Parallax ) * -ase_tanViewDir ).xy);
			float2 temp_output_137_0 = (temp_output_35_0*0.25 + 0.0);
			float2 normalizeResult99 = normalize( temp_output_137_0 );
			float3 appendResult104 = (float3(normalizeResult99 , 0.0));
			float temp_output_109_0 = length( temp_output_137_0 );
			float smoothstepResult119 = smoothstep( ( ( 1.0 - _ScopeDistortionsize ) * 0.5 ) , 0.6 , temp_output_109_0);
			float3 lerpResult118 = lerp( _Vector1 , appendResult104 , pow( smoothstepResult119 , 4.0 ));
			float3 lerpResult122 = lerp( _Vector1 , lerpResult118 , step( temp_output_109_0 , 0.5 ));
			float2 temp_output_32_0 = (float2( -1,-1 ) + (i.uv2_texcoord2 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
			float3 lerpResult66 = lerp( ( ( ( lerpResult16 - float3( 0.5,0.5,0 ) ) * ( ( 1.0 - _ReticleScale ) * 4.0 ) ) + float3( 0.5,0.5,0 ) ) , float3( (temp_output_32_0*1.0 + 0.5) ,  0.0 ) , ( 1.0 - _ReticleParallax ));
			float4 tex2DNode5 = tex2D( _Reticle, ( 1.0 - lerpResult66 ).xy );
			float4 lerpResult172 = lerp( tex2D( _RenderTexture, ( lerpResult16 - ( lerpResult122 * _ScopeDistortionStrength ) ).xy ) , ( tex2DNode5 * _ReticleTint ) , tex2DNode5.a);
			float smoothstepResult28 = smoothstep( 1.09 , 0.85 , length( (temp_output_32_0*1.0 + 0.0) ));
			float smoothstepResult33 = smoothstep( 1.77 , 0.1 , length( temp_output_35_0 ));
			float4 lerpResult40 = lerp( float4( 0,0,0,0 ) , ( lerpResult172 * smoothstepResult28 ) , smoothstepResult33);
			o.Albedo = lerpResult40.rgb;
			o.Emission = ( lerpResult40 * _EmissionStrength ).rgb;
			float2 uv_MetallicMap = i.uv_texcoord * _MetallicMap_ST.xy + _MetallicMap_ST.zw;
			o.Metallic = ( _Metallic * tex2D( _MetallicMap, uv_MetallicMap ) ).r;
			float2 uv_RoughnessMap = i.uv_texcoord * _RoughnessMap_ST.xy + _RoughnessMap_ST.zw;
			o.Smoothness = ( _Smoothness * tex2D( _RoughnessMap, uv_RoughnessMap ) ).r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv2_texcoord2;
				o.customPack1.xy = v.texcoord1;
				o.customPack1.zw = customInputData.uv_texcoord;
				o.customPack1.zw = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv2_texcoord2 = IN.customPack1.xy;
				surfIN.uv_texcoord = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;543;1499;496;2408.326;62.50302;1.520788;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-3133.464,235.6836;Inherit;True;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;18;-3174.285,432.1385;Inherit;False;Property;_Parallax;Parallax;9;0;Create;True;0;0;0;False;3;Space(25);Header(_________________________SCOPE SETTINGS______________________________);Space(10);False;0.734;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2442.416,868.4968;Inherit;False;Property;_LensShadowDepth;Lens Shadow Depth;11;0;Create;True;0;0;0;False;0;False;4.72;2.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;23;-2519.589,226.5484;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2698.133,470.1659;Inherit;True;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-2058.686,904.5251;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1825.092,899.2753;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;36;-1467.595,771.3503;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2632.08,45.36019;Inherit;False;Constant;_ViewDirPower;ViewDirPower;8;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2429.852,275.873;Inherit;False;Constant;_Offset;Offset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-2337.964,106.6946;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;145;-2254.292,205.4311;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-2875.591,-319.2891;Inherit;False;Property;_ScopeDistortionsize;Scope Distortion size;12;0;Create;True;0;0;0;False;0;False;0.7;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;35;-1120.474,795.5624;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-2027.284,277.5513;Inherit;False;Property;_ReticleScale;Reticle Scale;3;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;11;-2100.693,98.57967;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.05;False;2;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;160;-2601.531,-315.182;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;137;-3241.91,-156.0897;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.25;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;109;-2450.111,-150.3126;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-2433.531,-314.182;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;16;-1835.277,66.67851;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;169;-1764.484,282.3166;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-1620.434,281.9182;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;119;-2227.155,-339.0383;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;99;-3017.628,-573.7895;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;165;-1580.706,94.52005;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-1433.083,107.2514;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1514.315,393.0192;Inherit;False;Property;_ReticleParallax;Reticle Parallax;4;0;Create;True;0;0;0;False;0;False;0.005;0.995;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;32;-2140.074,468.3802;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;123;-2121.767,-738.5435;Inherit;False;Constant;_Vector1;Vector 1;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;104;-2180.634,-574.5835;Inherit;True;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;149;-1985.892,-335.1566;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;114;-1888.427,-152.1831;Inherit;True;2;0;FLOAT;0.48;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;144;-1247.073,392.1132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;166;-1297.706,107.5201;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;118;-1831.813,-386.3163;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;69;-1751.19,377.62;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1567.179,-181.6632;Inherit;False;Property;_ScopeDistortionStrength;Scope Distortion Strength;13;0;Create;True;0;0;0;False;0;False;0.6;0.6;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;122;-1525.26,-410.2679;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;66;-1150.821,107.5951;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1246.28,-304.4254;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;170;-1000.307,110.1554;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;151;-960.2283,-249.8029;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;175;-769.6111,270.6854;Inherit;False;Property;_ReticleTint;Reticle Tint;2;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-859.3759,83.41558;Inherit;True;Property;_Reticle;Reticle;1;1;[NoScaleOffset];Create;True;0;0;0;False;4;Header(Shader by DarkBlade909);Space(10);Header(____________________________TEXTURES______________________________);Space(10);False;-1;None;2722613c06c72e94b9ff65f1a4edf3d0;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;31;-1756.887,528.2501;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-724.0307,-250.8238;Inherit;True;Property;_RenderTexture;Render Texture;0;1;[HideInInspector];Create;True;2;Shader by Darkblade9094623;Space(25);0;0;False;0;False;-1;None;a57793dc6fc164c4b8208d6b8064fb1a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;27;-1511.781,530.7991;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;-464.8498,87.00754;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;172;-164.999,-51.05428;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;28;-706.3793,449.2462;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1.09;False;2;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;34;-877.1961,800.4113;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;33;-685.9753,782.0211;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1.77;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;82.73876,-51.28327;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;44;153.2671,336.2198;Inherit;True;Property;_MetallicMap;Metallic Map;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;40;272.9941,-78.33441;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;47;173.8971,177.7995;Inherit;False;Property;_EmissionStrength;Emission Strength;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;174.6704,258.8206;Inherit;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;42;152.5535,625.9918;Inherit;True;Property;_RoughnessMap;Roughness Map;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;171.6888,553.8389;Inherit;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;0;False;0;False;0;0.897;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;19;-2829.775,177.4999;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;469.6829,287.7729;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;477.307,78.6683;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;455.4286,582.1582;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-1151.479,971.8618;Inherit;False;Property;_ScopeViewSize;Scope View Size;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;705.9724,33.17169;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ScopeMathDistort;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;10;0
WireConnection;146;0;39;0
WireConnection;146;1;18;0
WireConnection;38;0;146;0
WireConnection;38;1;23;0
WireConnection;36;0;15;0
WireConnection;20;0;22;0
WireConnection;20;1;23;0
WireConnection;145;0;21;0
WireConnection;35;0;36;0
WireConnection;35;2;38;0
WireConnection;11;0;20;0
WireConnection;11;2;145;0
WireConnection;160;0;156;0
WireConnection;137;0;35;0
WireConnection;109;0;137;0
WireConnection;159;0;160;0
WireConnection;16;0;15;0
WireConnection;16;1;11;0
WireConnection;16;2;18;0
WireConnection;169;0;162;0
WireConnection;167;0;169;0
WireConnection;119;0;109;0
WireConnection;119;1;159;0
WireConnection;99;0;137;0
WireConnection;165;0;16;0
WireConnection;161;0;165;0
WireConnection;161;1;167;0
WireConnection;32;0;15;0
WireConnection;104;0;99;0
WireConnection;149;0;119;0
WireConnection;114;0;109;0
WireConnection;144;0;67;0
WireConnection;166;0;161;0
WireConnection;118;0;123;0
WireConnection;118;1;104;0
WireConnection;118;2;149;0
WireConnection;69;0;32;0
WireConnection;122;0;123;0
WireConnection;122;1;118;0
WireConnection;122;2;114;0
WireConnection;66;0;166;0
WireConnection;66;1;69;0
WireConnection;66;2;144;0
WireConnection;51;0;122;0
WireConnection;51;1;52;0
WireConnection;170;0;66;0
WireConnection;151;0;16;0
WireConnection;151;1;51;0
WireConnection;5;1;170;0
WireConnection;31;0;32;0
WireConnection;1;1;151;0
WireConnection;27;0;31;0
WireConnection;174;0;5;0
WireConnection;174;1;175;0
WireConnection;172;0;1;0
WireConnection;172;1;174;0
WireConnection;172;2;5;4
WireConnection;28;0;27;0
WireConnection;34;0;35;0
WireConnection;33;0;34;0
WireConnection;29;0;172;0
WireConnection;29;1;28;0
WireConnection;40;1;29;0
WireConnection;40;2;33;0
WireConnection;19;0;10;0
WireConnection;45;0;3;0
WireConnection;45;1;44;0
WireConnection;46;0;40;0
WireConnection;46;1;47;0
WireConnection;43;0;2;0
WireConnection;43;1;42;0
WireConnection;0;0;40;0
WireConnection;0;2;46;0
WireConnection;0;3;45;0
WireConnection;0;4;43;0
ASEEND*/
//CHKSM=1CF6AD013C36FDC98D7837E0D949831A81BA00C1