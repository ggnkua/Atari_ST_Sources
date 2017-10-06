/*
 * Draw a 2d box outline (allows 'proper' thickness - 1, 2, 3, etc)
 * Note: expects writing mode to be set up by caller.
 */
global
void draw_2d_box(short x, short y, short w, short h, short border_thick, short colour)
{
	short coords[4];

	f_interior(FIS_SOLID);
	f_color(colour);
			
	if (border_thick > 0)
	{
		coords[0] = x;
		coords[1] = y;
		coords[2] = x + w - 1;
		coords[3] = y + (border_thick - 1);
		v_bar(V_handle, coords);

		coords[1] = y + h - 1 - (border_thick - 1);
		coords[3] = y + h - 1;
		v_bar(V_handle, coords);

		coords[1] = y + border_thick;
		coords[2] = x + (border_thick - 1);
		coords[3] = y + h - 2 - (border_thick - 1);
		v_bar(V_handle, coords);

		coords[0] = x + w - 1 - (border_thick - 1);
		coords[2] = x + w - 1;
		v_bar(V_handle, coords);
	} else if (border_thick < 0)
	{
		border_thick = -border_thick;
		coords[0] = x - border_thick;
		coords[1] = y - border_thick;
		coords[2] = x + w - 1 + border_thick;
		coords[3] = y - 1;
		v_bar(V_handle, coords);

		coords[1] = y + h;
		coords[3] = y + h + (border_thick - 1);
		v_bar(V_handle, coords);

		coords[1] = y - border_thick;
		coords[2] = x - 1;
		coords[3] = y + h - 1;
		v_bar(V_handle, coords);

		coords[0] = x + w;
		coords[2] = x + w + (border_thick - 1);
		v_bar(V_handle, coords);
	}
}

void g2d_box(short b, RECT *r, short colour)
{
	draw_2d_box(r.x, r.y, r.w, r.h, sb, colour);
}


