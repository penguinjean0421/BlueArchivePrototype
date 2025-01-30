Shader "URP/HammerToonShader/SH_hToon"
{
    Properties
    { 
        [Header(DiffuseTex)]
        [Space(20)]
        _DiffuseTex("DiffuseTex", 2D) = "white" {}
        _DiffuseColor("DiffuseColor", Color) = (1, 1, 1, 1)

        [Header(Shadow)]
        [Space(20)]
        _ShadowMask("ShadowTex", 2D) = "white" {}
        _ShadowRange("ShadowRange", Range(0,1)) = 0
        _ShadowSmooth("ShadowSmooth", Range(0,1)) = 0
        _ShadowColor("ShadowColor", color) = (0,0,0,1)

        [Header(Normal)]
        [Space(20)]
        _NormalTex("NormalTex", 2D) = "white" {}
        _NormalIntensity("NormalIntensity", Range(0,1)) = 0

        [Header(AO)]
        [Space(20)]
        _AOMask("AOTex", 2D) = "white" {}
        _AOIntensity("AOIntensity", Range(0,1)) = 0

        [Header(Emissive)]
        [Space(20)]
        _EmissiveMask("EmissiveTex", 2D) = "white" {}
        _fEmissiveColor("fEmissiveColor", color) = (0,0,0,1)
        _sEmissiveColor("sEmissiveColor", color) = (0,0,0,1)
        _GradientRange("GradientRange", Range(0,1)) = 0
        _EmissivePower("EmissivePower", Range(0,1)) = 0

        [Header(Outline)]
        [Space(20)]
        _OutlineMask("OutlineMask", 2D) = "white" {}
        _OutlineWidth("OutlineWidth", Range(0,1)) = 0
        _OutlineColor("OutlineColor", color) = (0,0,0,1)
        _OutlineFadeStart("OutlineFadeStartDist", float) = 0
        _OutlineFadeEnd("OutlineFadeEndDist", float) = 0
    }

    SubShader
    {
        Tags 
        { 
        "RenderType" = "Opaque" 
        "RenderPipeline" = "UniversalPipeline"
        "LightMode" = "UniversalForwardOnly"
        }
        LOD 200

        Pass
        {
            Name "Outline"
            Tags 
            {
                "LightMode" = "Outline"
                "RenderType" = "Transparent"
                "Queue" = "Transparent" 
            }
            ZWrite Off
            cull front

            // using URP render
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _OutlineMask_ST;
                float _OutlineWidth;
                float4 _OutlineColor;
                float _OutlineFadeStart;
                float _OutlineFadeEnd;  
            CBUFFER_END

            TEXTURE2D(_OutlineMask);            SAMPLER(sampler_OutlineMask);

            struct Attributes
            {
                float3 normal : NORMAL;
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);
                float3 normal = 0;

                normal = mul(normalInput.normalWS, (float3x3)GetViewToWorldMatrix());
                float4 offset = TransformWViewToHClip(normal);

                output.vertex = TransformObjectToHClip(input.vertex);

                output.vertex.xy += offset.xy * _OutlineWidth * 0.003 * (1-smoothstep(_OutlineFadeStart, _OutlineFadeEnd, output.vertex));


                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                half outlineMask = SAMPLE_TEXTURE2D(_OutlineMask, sampler_OutlineMask, input.uv).r;
                if (outlineMask < 0.5) discard;
                return _OutlineColor;
            }
            ENDHLSL
        }

        // main pass
        Pass
        {
            ZWrite On
            cull back
            
            // using URP render
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _SHADOWS_SCREEN

            #ifndef CHARACTER_PASS_INCLUDED
            #define CHARACTER_PASS_INCLUDED

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            CBUFFER_START(UnityPerMaterial)
                // diffuse properties
                float4 _DiffuseTex_ST;
                float4 _DiffuseColor;

                // shadow properties
                float4 _ShadowMask_ST;
                float _ShadowRange;
                float _ShadowSmooth;
                float4 _ShadowColor;

                // normal properties
				float4 _NormalTex_ST;
                float4 _NormalIntensity;

                // ao properties
                float4 _AOMask_ST;
                float _AOIntensity;

                // emissive properties
                float4 _EmissiveMask_ST;
                float4 _fEmissiveColor;
                float4 _sEmissiveColor;
                float _GradientRange;
                float _EmissivePower;
            CBUFFER_END

            TEXTURE2D(_DiffuseTex);         SAMPLER(sampler_DiffuseTex);
            TEXTURE2D(_ShadowMask);         SAMPLER(sampler_ShadowMask);
            TEXTURE2D(_NormalTex);          SAMPLER(sampler_NormalTex);
            TEXTURE2D(_AOMask);             SAMPLER(sampler_AOMask);
            TEXTURE2D(_EmissiveMask);       SAMPLER(sampler_EmissiveMask);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 vertexColor : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 positionVS : TEXCOORD1;
                float4 positionNDC : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
                float3 bitangentWS : TEXCOORD5;
                float4 vertexClor : COLOR;
                float2 uv : TEXCOORD6;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInput = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionCS = positionInput.positionCS;
                output.positionWS = positionInput.positionWS;
                output.positionVS = positionInput.positionVS;
                output.positionNDC = positionInput.positionNDC;
                output.normalWS = normalInput.normalWS;
                output.tangentWS = normalInput.tangentWS;
                output.bitangentWS = normalInput.bitangentWS;
                output.vertexClor = input.vertexColor;
                output.uv = input.uv;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                // diffuse
                float4 diffuse = SAMPLE_TEXTURE2D(_DiffuseTex, sampler_DiffuseTex, input.uv) * _DiffuseColor;

                // normal
                float3 bump = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, input.uv), _NormalIntensity);
                float3x3 tangent = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
                float3 normalWS = TransformTangentToWorld(bump, tangent, true);

                // View
                float3 viewWS = GetWorldSpaceNormalizeViewDir(input.positionWS);

                // AO
                half aoMask = SAMPLE_TEXTURE2D(_AOMask, sampler_AOMask, input.uv).r;
                float ao = saturate(pow(_AOIntensity, aoMask));

                // shadow
                half4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                float halfLambert = 0.5 * dot(normalWS, mainLight.direction) + 0.5;
                float halfLambertAO = halfLambert * ao * mainLight.shadowAttenuation;
                half shadowMask = SAMPLE_TEXTURE2D(_ShadowMask, sampler_ShadowMask, input.uv).r;
                float shadowRange = _ShadowRange * shadowMask;
                half mainLightShadow = smoothstep(shadowRange - _ShadowSmooth, shadowRange + _ShadowSmooth, halfLambertAO);

                // Additional Light
                half3 additionalLightColor = half3(0, 0, 0);
                float additionalLightAttenuation = 0.0;
                InputData inputData = (InputData) 0;
                inputData.positionWS = input.positionWS;
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS.xy);
                #ifdef _ADDITIONAL_LIGHTS
                uint pixelLightCount = GetAdditionalLightsCount();
                LIGHT_LOOP_BEGIN(pixelLightCount)
                Light additionalLight = GetAdditionalLight(lightIndex, input.positionWS, shadowMask);
                additionalLightColor += additionalLight.color * additionalLight.distanceAttenuation;
                additionalLightAttenuation += additionalLight.shadowAttenuation * additionalLight.distanceAttenuation * ao;
                LIGHT_LOOP_END
                #endif

                // Mix Light
                float mixAttenuation = saturate(mainLight.shadowAttenuation + additionalLightAttenuation) * mainLightShadow;
                half3 mixAttenuationColor = (1 - mixAttenuation) * _ShadowColor;
                half3 mixLight = mainLight.color + clamp(additionalLightColor, 0.0, 2.0);
                half3 mixLightColor = mixLight * saturate(mixAttenuation + mixAttenuationColor);

                // emission
                half emissionMask = SAMPLE_TEXTURE2D(_EmissiveMask, sampler_EmissiveMask, input.uv).a;

                // final
                half3 diffuseColor = lerp(diffuse * _ShadowColor, diffuse, mainLightShadow);
                float gradientUV = _GradientRange * input.vertexClor.x;
                half3 emissiveColor = emissionMask * (_EmissivePower * 5) * lerp(_fEmissiveColor, _sEmissiveColor, gradientUV);
                half3 lightColor = mixLightColor;
                half3 final = (diffuseColor * lightColor) + emissiveColor;
                return half4(final, diffuse.a);
            }
            #endif
            ENDHLSL
        }

        // shadow casting pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 2.0

            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma skip_variants SHADOWS_SOFT
            #pragma multi_compile_shadowcaster

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
    }
}