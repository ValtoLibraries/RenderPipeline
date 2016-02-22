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

#version 420

#define USE_MAIN_SCENE_DATA
#pragma include "render_pipeline_base.inc.glsl"
#pragma include "includes/gbuffer.inc.glsl"

uniform GBufferData GBuffer;
uniform sampler2D CurrentTex;
uniform sampler2D LastTex;

out vec4 result;

void main() {

    vec2 texcoord = get_texcoord();
    ivec2 coord = ivec2(gl_FragCoord.xy);

    vec2 velocity = get_gbuffer_velocity(GBuffer, texcoord);
    vec2 old_coord = texcoord - velocity;
    vec4 current_color = textureLod(CurrentTex, texcoord, 0);

    vec4 last_color = textureLod(LastTex, old_coord, 0);

    // Out of screen
    if (old_coord.x < 0.0 || old_coord.x > 1.0 || old_coord.y < 0.0 || old_coord.y > 1.0) {
        result = current_color;
        return;
    }

    // Get last frame bounding box
    const int radius = 2;
    vec4 color_min = vec4(1e10);
    vec4 color_max = vec4(0);
    ivec2 last_coord = ivec2( 0.5 + texcoord * SCREEN_SIZE );
    for (int i = -radius; i <= radius; ++i) {
        for (int j = -radius; j <= radius; ++j) {
            vec4 sample_color = texelFetch(LastTex, last_coord + ivec2(i, j), 0);
            color_min = min(color_min, sample_color);
            color_max = max(color_max, sample_color);
        }
    }

    // Compute  weight
    float weight = 0.0;

    float bias = 6.0 / 255.0;
    color_min -= bias;
    color_max += bias;
    if (current_color.r >= color_min.r && current_color.g >= color_min.g && current_color.b >= color_min.b) {
        if (current_color.r <= color_max.r && current_color.g <= color_max.g && current_color.b <= color_max.b) {
            weight = 0.5;
        }
    }

    // Fade out when velocity gets too different
    const float max_velocity_diff = 5.0 / WINDOW_HEIGHT;
    float current_diff = abs(current_color.w - last_color.w);
    weight *= 0.5 - 0.5 * saturate(current_diff / max_velocity_diff);

    result = mix(current_color, last_color, weight);
    // result.xyz = vec3(weight);
}