/**
 *
 * RenderPipeline
 *
 * Copyright (c) 2014-2016 tobspr <tobias.springer1@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#pragma once

#define SHADING_MODEL_DEFAULT 0
#define SHADING_MODEL_EMISSIVE 1
#define SHADING_MODEL_CLEARCOAT 2
#define SHADING_MODEL_TRANSPARENT 3
#define SHADING_MODEL_SKIN 4
#define SHADING_MODEL_FOLIAGE 5

// Pandas material representation
struct Panda3DMaterial {
    vec4 baseColor;
    vec4 emission;
    float roughness;
    float metallic;
    float refractiveIndex;
};

// Structure passed from the vertex to the fragment shader
struct MaterialBaseInput {
    vec3  color;
    int shading_model;
    float specular_ior;
    float metallic;
    float roughness;
    float normalfactor;
    float arbitrary0;
    // float arbitrary1;
};

// Converts from a Panda3D Material to a render pipeline material
MaterialBaseInput get_input_from_p3d(Panda3DMaterial m) {
    MaterialBaseInput mi;
    mi.color          = m.baseColor.xyz;
    mi.specular_ior   = m.refractiveIndex;
    mi.metallic       = m.metallic;
    mi.roughness      = m.roughness;
    mi.shading_model  = int(m.emission.x);
    mi.normalfactor   = m.emission.y;
    mi.arbitrary0     = m.emission.z;
    // mi.arbitrary1     = m.emission.w;
    return mi;
}

// Structure used in the Material Templates
struct MaterialShaderOutput {
    int shading_model;
    vec3 basecolor;
    vec3 normal;
    float roughness;
    float specular_ior;
    float metallic;
    float shading_model_param0;
};


// Structure actually stored in the GBuffer, this *may* differ but not necessarily has to:
struct Material {
    int shading_model;
    vec3 basecolor;
    vec3 normal;
    vec3 position;
    float roughness;
    float specular;
    float specular_ior;
    float metallic;
    float shading_model_param0;
    float linear_roughness;
};
