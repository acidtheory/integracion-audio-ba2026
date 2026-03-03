shader_type canvas_item;

uniform float inner = 0.45;
uniform float outer = 0.5;

uniform vec4 color : source_color;
uniform float progress : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 center = vec2(0.5);
    vec2 p = UV - center;
    float dist = length(p);
    float angle = atan(p.y, p.x);
    float normalized = (angle + PI) / (2.0 * PI);

    if (dist > inner && dist < outer && normalized <= progress) {
        COLOR = color;
    } else {
        COLOR = vec4(0.0);
    }
}