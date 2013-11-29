#include "extern.h"

int filltype = 4;

/* --------- */
/* | Linie | */
/* --------- */
void draw_a_line(int flg, int *xy)
{
vsl_type(vdi_handle, 1);
v_pline(vdi_handle, 2, xy);
}

/* --------- */
/* | Boxen | */
/* --------- */
void draw_a_box(int flg, int *xy)
{
int xyb[10];

vsl_type(vdi_handle, 1);
vsf_interior(vdi_handle, 2);

switch(flg)
	{
	case 0:
		xyb[6] = xyb[8] = xyb[0] = xy[0];
		xyb[9] = xyb[3] = xyb[1] = xy[1];
		xyb[4] = xyb[2] = xy[2];
		xyb[7] = xyb[5] = xy[3];
		v_pline(vdi_handle, 5, xyb);
		break;

	case 1:
		vsf_perimeter(vdi_handle, FALSE);
		vr_recfl(vdi_handle, xy);
		break;
		
	case 2:
		vsf_perimeter(vdi_handle, TRUE);
		v_bar(vdi_handle, xy);
		break;
	}
}

/* ---------- */
/* | Kreise | */
/* ---------- */
void draw_a_circle(int flg, int *xy)
{
vsl_type(vdi_handle, 1);
vsf_interior(vdi_handle, 2);

xy[3] = xy[1] + abs(xy[2] - xy[0]);

switch(flg)
	{
	case 0:
		vsf_perimeter(vdi_handle, TRUE);
		v_arc(vdi_handle, xy[0], xy[1], abs(xy[2] - xy[0]), 0, 3600);
		break;

	case 1:
		vsf_perimeter(vdi_handle, FALSE);
		v_circle(vdi_handle, xy[0], xy[1], abs(xy[2] - xy[0]));
		break;
		
	case 2:
		vsf_perimeter(vdi_handle, TRUE);
		v_circle(vdi_handle, xy[0], xy[1], abs(xy[2] - xy[0]));
		break;
	}
}

/* ----------- */
/* | Ellipse | */
/* ----------- */
void draw_a_ellip(int flg, int *xy)
{
vsl_type(vdi_handle, 1);
vsf_interior(vdi_handle, 2);

switch(flg)
	{
	case 0:
		vsf_perimeter(vdi_handle, TRUE);
		v_ellarc(vdi_handle, xy[0], xy[1], abs(xy[2] - xy[0]), abs(xy[3] - xy[1]), 0, 3600);
		break;

	case 1:
		vsf_perimeter(vdi_handle, FALSE);
		v_ellipse(vdi_handle, xy[0], xy[1], abs(xy[2] - xy[0]), abs(xy[3] - xy[1]));
		break;
		
	case 2:
		vsf_perimeter(vdi_handle, TRUE);
		v_ellipse(vdi_handle, xy[0], xy[1], abs(xy[2] - xy[0]), abs(xy[3] - xy[1]));
		break;
	}
}

/* --------------- */
/* | Minipainter | */
/* --------------- */
void do_paint(void)
{
register int eo;

rsrc_gaddr(ROOT, M_PAINT, &form_adr);

vsf_style(vdi_handle, 4);

do
	{
	eo = dialog(0) & 0x7FFF;

	if (eo != MP_BACK)
		redraw(w_handles[akt_id], fx, fy, fw, fh);
	
	switch(eo)
		{
		case MP_LINE:
			draw(draw_a_line, 0);
			break;
			
		case MP_BOX:
			draw(draw_a_box, 0);
			break;
			
		case MP_PBBOX:
			draw(draw_a_box, 2);
			break;
			
		case MP_PBOX:
			draw(draw_a_box, 1);
			break;

		case MP_PBCIR:
			draw(draw_a_circle, 2);
			break;

		case MP_PCIRC:
			draw(draw_a_circle, 1);
			break;

		case MP_CIRCL:
			draw(draw_a_circle, 0);
			break;

		case MP_ELLI:
			draw(draw_a_ellip, 0);
			break;

		case MP_PELLI:
			draw(draw_a_ellip, 1);
			break;

		case MP_PBELL:
			draw(draw_a_ellip, 2);
			break;
						
		case MP_ARC:
		case MP_PARC:
		case MP_FUNC:
		case MP_FILL:
			break;
		}
		
	}while(eo != MP_BACK);

set_fullclip();
}

/* ------------------ */
/* | Linie zeichnen | */
/* ------------------ */
void draw(void (*rout)(), int flg)
{
int xy1[4], xy2[4], dummy, xyl[4];

mouse_off();
vswr_mode(vdi_handle, 3);

get_work(w_handles[akt_id]);
xy1[0] = wx + 24;
xy1[1] = wy + (ruler_flag << 4);
xy1[2] = wx + ww - 1;
xy1[3] = wy + wh - 1;
vs_clip(vdi_handle, TRUE, xy1);

xy1[0] = 0;
xy1[2] = 639;

xy2[1] = 0;
xy2[3] = 399;

vsl_type(vdi_handle, 7);
vsl_udsty(vdi_handle, 0x5555);

xy1[1] = xy1[3] = mousey;
v_pline(vdi_handle, 2, xy1);

xy2[0] = xy2[2] = mousex;
v_pline(vdi_handle, 2, xy2);

do
	{
	graf_mkstate(&mousex, &mousey, &mousek, &dummy);

	if (mousey != xy1[1])
		{
		v_pline(vdi_handle, 2, xy1);
		xy1[1] = xy1[3] = mousey;
		v_pline(vdi_handle, 2, xy1);
		}

	if (mousex != xy2[0])
		{
		v_pline(vdi_handle, 2, xy2);
		xy2[0] = xy2[2] = mousex;
		v_pline(vdi_handle, 2, xy2);
		}
		
	}while(!mousek);

v_pline(vdi_handle, 2, xy1);
v_pline(vdi_handle, 2, xy2);

if (mousek & 2)
	{
	mouse_on();
	return;
	}

/* ---------------- */
xyl[2] = xyl[0] = mousex;
xyl[3] = xyl[1] = mousey;

do
	{
	graf_mkstate(&mousex, &mousey, &mousek, &dummy);
	}while(mousek & 1);
	
/* ---------------- */
v_pline(vdi_handle, 2, xy1);
v_pline(vdi_handle, 2, xy2);

(*rout)(flg, xyl);

do
	{
	graf_mkstate(&mousex, &mousey, &mousek, &dummy);

	if (mousey != xy1[1] || mousex != xy2[0])
		{
		Vsync();
		(*rout)(0, xyl);
		xyl[2] = mousex;
		xyl[3] = mousey;
		(*rout)(0, xyl);
		vsl_type(vdi_handle, 7);
		}

	if (mousey != xy1[1])
		{
		v_pline(vdi_handle, 2, xy1);
		xy1[1] = xy1[3] = xyl[3];
		v_pline(vdi_handle, 2, xy1);
		}

	if (mousex != xy2[0])
		{
		v_pline(vdi_handle, 2, xy2);
		xy2[0] = xy2[2] = xyl[2];
		v_pline(vdi_handle, 2, xy2);
		}
		
	}while(!mousek);

v_pline(vdi_handle, 2, xy1);
v_pline(vdi_handle, 2, xy2);
(*rout)(0, xyl);

if (mousek & 2)
	{
	mouse_on();
	return;
	}

vswr_mode(vdi_handle, 2);
(*rout)(flg, xyl);

do
	{
	graf_mkstate(&mousex, &mousey, &mousek, &dummy);
	}while(mousek & 1);

mouse_on();
}

