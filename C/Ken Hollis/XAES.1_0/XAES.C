/********************************************************************
 *																1.00*
 *	XAES: Extended AES Control Functions							*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	Extended AES routines.  Enough said.							*
 *																	*
 ********************************************************************/

#include "xaes.h"

LOCAL void draw_rubber(int *pxy)
{
	graf_mouse(M_OFF,0l);

	vsl_udsty(VDIhandle,(pxy[0] & 1) == (pxy[1] & 1) ? 21845 : (int) 43690L);
	line(pxy[0],pxy[1],pxy[0],pxy[3]);
	
	vsl_udsty(VDIhandle,(pxy[2] & 1) == (pxy[1] & 1) ? 21845 : (int) 43690L);
	line(pxy[2],pxy[1],pxy[2],pxy[3]);

	vsl_udsty(VDIhandle,(pxy[1] & 1) ? (int) 43690L : 21845);
	line(pxy[0],pxy[1],pxy[2],pxy[1]);
	
	vsl_udsty(VDIhandle,(pxy[3] & 1) ? (int) 43690L : 21845);
	line(pxy[0],pxy[3],pxy[2],pxy[3]);

	graf_mouse(M_ON,0l);
}

GLOBAL void WGraf_Rubberbox(int bx, int by, int *endx, int *endy)
{
	int mx, my, button, dummy, origx, origy, cntr = 0, oldx, oldy,
		boundx, boundy, boundw, boundh, moved = FALSE;
	int pxy[8];
	int attr[10], fillattr[5], lineattr[6];
	GRECT pos;

	*endx = 0;
	*endy = 0;

	vqt_attributes(VDIhandle, attr);
	vqf_attributes(VDIhandle, fillattr);
	vql_attributes(VDIhandle, lineattr);

	graf_mkstate(&origx, &origy, &dummy, &dummy);

	pxy[0] = desk.g_x;
	pxy[1] = desk.g_y;
	pxy[2] = desk.g_x + desk.g_w;
	pxy[3] = desk.g_y + desk.g_h;

	vs_clip(VDIhandle, 1, pxy);

	vsl_color(VDIhandle, BLACK);
	vsl_type(VDIhandle, 7);

	vswr_mode(VDIhandle, MD_XOR);

	pos.g_x = bx;
	pos.g_y = by;
	pos.g_w = 0;
	pos.g_h = 0;

	pxy[0] = pos.g_x;
	pxy[1] = pos.g_y;
	pxy[2] = pos.g_x + pos.g_w;
	pxy[3] = pos.g_y + pos.g_h;
	draw_rubber(pxy);

	boundx = desk.g_x;
	boundy = desk.g_y;
	boundw = desk.g_x + desk.g_w;
	boundh = desk.g_y + desk.g_h;

	do {
		graf_mkstate(&mx, &my, &button, &dummy);

		cntr++;

		if ((mx != oldx) ||
			(my != oldy)) {
			moved = TRUE;
			oldx = mx;
			oldy = my;
		}

		if (moved) {
			pxy[0] = pos.g_x;
			pxy[1] = pos.g_y;
			pxy[2] = pos.g_x + pos.g_w;
			pxy[3] = pos.g_y + pos.g_h;
			draw_rubber(pxy);
		}

		pos.g_w = mx - pos.g_x;
		pos.g_h = my - pos.g_y;

		if (boundw!=-1) {
			int tx;

			if ((tx = (pos.g_x + pos.g_w) - (boundw)) < 0)
				tx = 0;
			else
				tx += 1;

			pos.g_x -= tx;
		}

		if (boundh != -1 && boundy != -1) {
			int ty;

			if ((ty = (pos.g_y + pos.g_h) - (boundy + boundh)) < 0)
				ty = 0;
			else
				ty += 1;

			pos.g_y -= ty;
		}

		if (boundx != -1)
			if (pos.g_x < boundx)
				pos.g_x = boundx;

		if (boundy != -1)
			if (pos.g_y < boundy)
				pos.g_y = boundy;

		if (moved) {
			pxy[0] = pos.g_x;
			pxy[1] = pos.g_y;
			pxy[2] = pos.g_x + pos.g_w;
			pxy[3] = pos.g_y + pos.g_h;
			draw_rubber(pxy);
			moved = FALSE;
		}
	} while (button);

	pxy[0] = pos.g_x;
	pxy[1] = pos.g_y;
	pxy[2] = pos.g_x + pos.g_w;
	pxy[3] = pos.g_y + pos.g_h;
	draw_rubber(pxy);

	vst_height(VDIhandle, attr[7], &dummy, &dummy, &dummy, &dummy);
	vst_color(VDIhandle, attr[1]);
/*	vswr_mode(VDIhandle, attr[5]); */
	vswr_mode(VDIhandle, MD_XOR);

	vsf_color(VDIhandle, fillattr[1]);
	vsf_interior(VDIhandle, fillattr[0]);
	vsf_style(VDIhandle, fillattr[2]);

	vsl_type(VDIhandle, lineattr[0]);
	vsl_color(VDIhandle, lineattr[1]);
	vsl_udsty(VDIhandle, 0xFFFF);

	*endx = pos.g_x;
	*endy = pos.g_y;
}

GLOBAL void WDragBox(int width, int height, int beginx, int beginy,
			int boundx, int boundy, int boundw, int boundh,
			int *endx, int *endy)
{
	int mx = 0, my = 0, button, dummy, origx, origy, cntr = 0, xo,
		yo, dx = 0, dy = 0, moved = FALSE;
	int pxy[8];
	int attr[10], fillattr[5], lineattr[6];
	GRECT pos;

	*endx = 0;
	*endy = 0;

	vqt_attributes(VDIhandle, attr);
	vqf_attributes(VDIhandle, fillattr);
	vql_attributes(VDIhandle, lineattr);

	graf_mkstate(&origx, &origy, &dummy, &dummy);

	pxy[0] = desk.g_x;
	pxy[1] = desk.g_y;
	pxy[2] = desk.g_x + desk.g_w;
	pxy[3] = desk.g_y + desk.g_h;

	vs_clip(VDIhandle, 1, pxy);

	vsl_color(VDIhandle, BLACK);
	vsl_type(VDIhandle, 7);

	vswr_mode(VDIhandle, MD_XOR);

	pos.g_x = beginx;
	pos.g_y = beginy;
	pos.g_w = width;
	pos.g_h = height;

	pxy[0] = pos.g_x;
	pxy[1] = pos.g_y;
	pxy[2] = pos.g_x + pos.g_w;
	pxy[3] = pos.g_y + pos.g_h;
	draw_rubber(pxy);

	do {
		xo = mx;
		yo = my;

		graf_mkstate(&mx, &my, &button, &dummy);

		dx = mx - xo;
		dy = my - yo;

		cntr++;

		if (dx || dy)
			moved = TRUE;

		if (moved) {
			pxy[0] = pos.g_x;
			pxy[1] = pos.g_y;
			pxy[2] = pos.g_x + pos.g_w;
			pxy[3] = pos.g_y + pos.g_h;
			draw_rubber(pxy);
		}

		pos.g_x = beginx + (mx - origx);
		pos.g_y = beginy + (my - origy);

		if (boundw != -1) {
			int tx;

			if ((tx = (pos.g_x + pos.g_w) - (boundw)) < 0)
				tx = 0;
			else
				tx += 1;

			pos.g_x -= tx;
		}

		if (boundh != -1 && boundy != -1) {
			int ty;

			if ((ty = (pos.g_y + pos.g_h) - (boundy + boundh)) < 0)
				ty = 0;
			else
				ty += 1;

			pos.g_y -= ty;
		}

		if (boundx != -1)
			if (pos.g_x < boundx)
				pos.g_x = boundx;

		if (boundy != -1)
			if (pos.g_y < boundy)
				pos.g_y = boundy;

		if (moved) {
			pxy[0] = pos.g_x;
			pxy[1] = pos.g_y;
			pxy[2] = pos.g_x + pos.g_w;
			pxy[3] = pos.g_y + pos.g_h;
			draw_rubber(pxy);

			moved = FALSE;
		}
	} while (button);

	pxy[0] = pos.g_x;
	pxy[1] = pos.g_y;
	pxy[2] = pos.g_x + pos.g_w;
	pxy[3] = pos.g_y + pos.g_h;
	draw_rubber(pxy);

	pxy[0] = beginx;
	pxy[1] = beginy;
	pxy[2] = width;
	pxy[3] = height;

	vs_clip(VDIhandle, 1, pxy);

	vst_height(VDIhandle, attr[7], &dummy, &dummy, &dummy, &dummy);
	vst_color(VDIhandle, attr[1]);
	vswr_mode(VDIhandle, attr[5]);

	vsf_color(VDIhandle, fillattr[1]);
	vsf_interior(VDIhandle, fillattr[0]);
	vsf_style(VDIhandle, fillattr[2]);

	vsl_type(VDIhandle, lineattr[0]);
	vsl_color(VDIhandle, lineattr[1]);
	vsl_udsty(VDIhandle, 0xFFFF);

	*endx = pos.g_x;
	*endy = pos.g_y;
}

GLOBAL void WSizeBox(WINDOW *win, int mode)
{
	int mx = 0, my = 0, button, dummy, origx, origy, xo, yo, dx = 0,
		dy = 0, moved = FALSE;
	int pxy[8];
	int attr[10], fillattr[5], lineattr[6];
	GRECT pos;

	if (win) {
		vqt_attributes(VDIhandle, attr);
		vqf_attributes(VDIhandle, fillattr);
		vql_attributes(VDIhandle, lineattr);

		graf_mkstate(&origx, &origy, &dummy, &dummy);

		pxy[0] = desk.g_x;
		pxy[1] = desk.g_y;
		pxy[2] = desk.g_x + desk.g_w;
		pxy[3] = desk.g_y + desk.g_h;

		vs_clip(VDIhandle, 1, pxy);

		vsl_color(VDIhandle, BLACK);
		vsl_type(VDIhandle, 7);

		vswr_mode(VDIhandle, MD_XOR);

		pos.g_x = win->size.g_x;
		pos.g_y = win->size.g_y;
		pos.g_w = win->size.g_w;
		pos.g_h = win->size.g_h;

		pxy[0] = pos.g_x;
		pxy[1] = pos.g_y;
		pxy[2] = pos.g_x + pos.g_w;
		pxy[3] = pos.g_y + pos.g_h;
		draw_rubber(pxy);

		if (xaes.config1 & X_MOUSEGADGETS)
			switch(mode) {
				case S_BOTTOM:
					WGrafMouse(BSIZER_MOUSE);
					break;

				case S_LOWERRIGHT:
					WGrafMouse(LRMOVE_MOUSE);
					break;

				case S_RIGHT:
					WGrafMouse(RSIZER_MOUSE);
					break;

				case S_UPPERRIGHT:
					WGrafMouse(URMOVE_MOUSE);
					break;

				case S_TOP:
					WGrafMouse(TSIZER_MOUSE);
					break;

				case S_UPPERLEFT:
					WGrafMouse(ULMOVE_MOUSE);
					break;

				case S_LEFT:
					WGrafMouse(LSIZER_MOUSE);
					break;

				case S_LOWERLEFT:
					WGrafMouse(LLMOVE_MOUSE);
					break;
			}
		else
			WGrafMouse(ARROW);

		do {
			xo = mx;
			yo = my;

			graf_mkstate(&mx, &my, &button, &dummy);

			if (!(win->state & W_UNSIZABLE)) {
				dx = mx - xo;
				dy = my - yo;

				if (dx || dy)
					moved = TRUE;

				if (moved) {
					pxy[0] = pos.g_x;
					pxy[1] = pos.g_y;
					pxy[2] = pos.g_x + pos.g_w;
					pxy[3] = pos.g_y + pos.g_h;
					draw_rubber(pxy);
				}

				switch(mode) {
					case S_BOTTOM:
						pos.g_h = my - win->size.g_y;
						break;

					case S_LOWERRIGHT:
						pos.g_w = mx - win->size.g_x;
						pos.g_h = my - win->size.g_y;
						break;

					case S_RIGHT:
						pos.g_w = mx - win->size.g_x;
						break;

					case S_UPPERRIGHT:
						pos.g_y = my;
						pos.g_w = mx - win->size.g_x;
						pos.g_h = (win->size.g_y + win->size.g_h) - my;
						break;

					case S_TOP:
						pos.g_y = my;
						pos.g_h = (win->size.g_y + win->size.g_h) - my;
						break;

					case S_UPPERLEFT:
						pos.g_x = mx;
						pos.g_y = my;
						pos.g_w = (win->size.g_x + win->size.g_w) - mx;
						pos.g_h = (win->size.g_y + win->size.g_h) - my;
						break;

					case S_LEFT:
						pos.g_x = mx;
						pos.g_w = (win->size.g_x + win->size.g_w) - mx;
						break;

					case S_LOWERLEFT:
						pos.g_x = mx;
						pos.g_w = (win->size.g_x + win->size.g_w) - mx;
						pos.g_h = my - win->size.g_y;
						break;
				}

				if (pos.g_x > win->minimum.g_x)
					pos.g_x = win->minimum.g_x;

				if (pos.g_y > win->minimum.g_y)
					pos.g_y = win->minimum.g_y;

				if (pos.g_w < win->minimum.g_w)
					pos.g_w = win->minimum.g_w;

				if (pos.g_h < win->minimum.g_h)
					pos.g_h = win->minimum.g_h;

				if (moved) {
					pxy[0] = pos.g_x;
					pxy[1] = pos.g_y;
					pxy[2] = pos.g_x + pos.g_w;
					pxy[3] = pos.g_y + pos.g_h;
					draw_rubber(pxy);

					moved = FALSE;
				}
			}
		} while (button);

		pxy[0] = pos.g_x;
		pxy[1] = pos.g_y;
		pxy[2] = pos.g_x + pos.g_w;
		pxy[3] = pos.g_y + pos.g_h;
		draw_rubber(pxy);

		pxy[0] = win->size.g_x;
		pxy[1] = win->size.g_y;
		pxy[2] = win->size.g_w;
		pxy[3] = win->size.g_h;

		vst_height(VDIhandle, attr[7], &dummy, &dummy, &dummy, &dummy);
		vst_color(VDIhandle, attr[1]);
		vswr_mode(VDIhandle, attr[5]);

		vsf_color(VDIhandle, fillattr[1]);
		vsf_interior(VDIhandle, fillattr[0]);
		vsf_style(VDIhandle, fillattr[2]);

		vsl_type(VDIhandle, lineattr[0]);
		vsl_color(VDIhandle, lineattr[1]);
		vsl_udsty(VDIhandle, 0xFFFF);

		vs_clip(VDIhandle, 1, pxy);

		win->size.g_x = pos.g_x;
		win->size.g_y = pos.g_y;
		win->size.g_w = pos.g_w;
		win->size.g_h = pos.g_h;

		WGrafMouse(ARROW);
	}
}