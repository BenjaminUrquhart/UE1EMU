draw_primitive_begin(pr_linelist);
draw_vertex_color(x, y, c_lime, 1);
draw_vertex_color(x + size, y, c_lime, 1);
draw_vertex_color(x + size, y + size, c_lime, 1);
draw_vertex_color(x, y + size, c_lime, 1);
if(checked || hovered) {
	var alpha = hovered ? 0.5 : 1;
	draw_vertex_color(x, y, c_lime, alpha);
	draw_vertex_color(x + size, y + size, c_lime, alpha);
	draw_vertex_color(x, y + size, c_lime, alpha);
	draw_vertex_color(x + size, y, c_lime, alpha);
}
draw_primitive_end();