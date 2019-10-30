/********************************************************************
 *																0.91*
 *	XAES: Extended Object Types										*
 *	Code by Ken Hollis												*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	Enhanced object routines that supposedly couldn't be done		*
 *	in an orderly fashion, or so GEM-List people said.  What do they*
 *	know, anyway?  I created six 3D drawing types.  Isn't this		*
 *	satisfactory?  I'm missing a few drawing bits, but no worries.. *
 *																	*
 ********************************************************************/

#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <ctype.h>

#include "xaes.h"

#ifdef __TURBOC__
#pragma warn -pia
#endif

LOCAL void FixThick(int thickness, OBJECT *obj)
{
	if (thickness < 0) {
		obj->ob_x -= (abs(thickness));
		obj->ob_y -= (abs(thickness));
		obj->ob_width += ((abs(thickness)) * 2);
		obj->ob_height += ((abs(thickness)) * 2);
	}
}

LOCAL void FixShadow(int thickness, OBJECT *obj)
{
	if (obj->ob_state & SHADOWED) {
		obj->ob_width += (abs(thickness)) * 2;
		obj->ob_height += (abs(thickness)) * 2;
	}
}

LOCAL void FixPositioning(char *te_ptext, OBJECT *obj)
{
	if (strchr(te_ptext, '[')) {
		obj->ob_y -= 2;
		obj->ob_height += 4;
	}
}

LOCAL void FixMovement(OBJECT *obj)
{
	obj->ob_x++;
	obj->ob_y++;
}

LOCAL void FixSizing(char *te_ptext, OBJECT *obj)
{
	if (strchr(te_ptext, '['))
		switch(obj->ob_type >> 8) {
			case SLIDERLEFT:
			case SLIDERRIGHT:
			case SLIDERUP:
			case SLIDERDOWN:
			case SLIDERTRACK:
			case SLIDERSLIDE:
				obj->ob_y += 2;
				obj->ob_height -= 4;
				break;
		}
}

LOCAL void pb_doobject(PARMBLK *pb, int xoff, int yoff)
{
	int dummy, attr[10], fillattr[5], lineattr[6], effects = 0;
	int interiorpxy[4], shadowed[20];
	int extent[8], x, y, gr_ch, gr_bw;
	EXTINFO *ex = (EXTINFO *) pb->pb_parm;
	char *string, *ptr, *unformatted = ex->te_ptext;
	int hotkey = -1, i = 0;
	int flags = pb->pb_tree[pb->pb_obj].ob_flags;
	int tempcalc = (abs(ex->te_thickness)) * 2;

	pb->pb_x = pb->pb_x;
	pb->pb_y = pb->pb_y;
	pb->pb_w = pb->pb_tree[pb->pb_obj].ob_width - 1;
	pb->pb_h = pb->pb_tree[pb->pb_obj].ob_height - 1;

	if (pb->pb_tree[pb->pb_obj].ob_state & SHADOWED) {
		pb->pb_w -= tempcalc;
		pb->pb_h -= tempcalc;
	}

	if (ptr = string = strdup(unformatted)) {
		while (*unformatted) {
			if (*unformatted == '[')
				if (*(++unformatted))
					hotkey = i;
				else
					break;

			*(ptr++) = *(unformatted++);
			i++;
		}
		*ptr = 0;

		pb->pb_x += xoff;
		pb->pb_y += yoff;

		vqt_attributes(VDIhandle, attr);
		vqf_attributes(VDIhandle, fillattr);
		vql_attributes(VDIhandle, lineattr);

		vst_height(VDIhandle, ex->te_font == 3 ? large_font : small_font, &dummy, &gr_ch, &gr_bw, &dummy);
		vst_color(VDIhandle, ex->te_color.text_color);
		vswr_mode(VDIhandle, MD_TRANS);

		if (pb->pb_currstate & 0x100) effects |= 1;
		if (pb->pb_currstate & 0x800) effects |= 2;
		if (pb->pb_currstate & 0x400) effects |= 4;
		if (pb->pb_currstate & 0x200) effects |= 8;
		if (pb->pb_currstate & 0x1000) effects |= 16;

		vst_effects(VDIhandle, effects);
		vqt_extent(VDIhandle, string, extent);

		y = pb->pb_y + ((pb->pb_h - (extent[7] - extent[1])) / 2) + ((((xaes.config1 & X_GENEVACOMPAT) && GenevaInstalled)) ? 1 : (gr_ch + 1));
		x = pb->pb_x + 1;

		switch (ex->te_just) {
			case 2:
				x += (pb->pb_w - (extent[2] - extent[0])) / 2;
				break;
			case 1:
				x += pb->pb_w - (extent[2] - extent[0]);
				break;
		}

		interiorpxy[2] = (interiorpxy[0] = pb->pb_x) + pb->pb_w;
		interiorpxy[3] = (interiorpxy[1] = pb->pb_y) + pb->pb_h;

		interiorpxy[0] += (abs(ex->te_thickness));
		interiorpxy[1] += (abs(ex->te_thickness));
		interiorpxy[2] -= (abs(ex->te_thickness));
		interiorpxy[3] -= (abs(ex->te_thickness));

		if (xaes.config2 & X_INTERFACE) {
			interiorpxy[0]--;	interiorpxy[1]--;
			interiorpxy[2]++;	interiorpxy[3]++;
		}

		vsf_interior(VDIhandle, FIS_SOLID);
		vsf_color(VDIhandle, WHITE);
		vswr_mode(VDIhandle, MD_REPLACE);
		vr_recfl(VDIhandle, interiorpxy);

		if ((num_colors > 4) ||
			((num_colors == 4) && (xaes.config1 & X_MEDEMUL))) {
			vsf_style(VDIhandle, 8);
			vsf_interior(VDIhandle, FIS_SOLID);
			vsf_color(VDIhandle, ((num_colors == 4) && (xaes.config1 & X_MEDEMUL)) ? 2 : 8);
			vr_recfl(VDIhandle, interiorpxy);
		}

		if ((ex->te_color.fill_ptn) ||
			(((xaes.config1 & X_DRAW3DCOMPAT) && (num_colors == 2)))) {
			vsf_style(VDIhandle, ((xaes.config1 & X_DRAW3DCOMPAT) && (num_colors == 2)) ? ((pb->pb_currstate & DISABLED) ? 8 : 4) : (ex->te_color.fill_ptn == 7 ? 8 : ex->te_color.fill_ptn));
			vsf_interior(VDIhandle, FIS_PATTERN);
			vsf_color(VDIhandle, ((xaes.config1 * X_DRAW3DCOMPAT) && (num_colors == 2)) ? BLACK : ex->te_color.in_color);
			vr_recfl(VDIhandle, interiorpxy);
		}

		if (xaes.config2 & X_INTERFACE) {
			interiorpxy[0]++;	interiorpxy[1]++;
			interiorpxy[2]--;	interiorpxy[3]--;
		}

		if ((ex->te_thickness) &&
		   ((pb->pb_tree[pb->pb_obj].ob_type >> 8) != UNDERLINE) &&
		   ((xaes.draw_3d == DRAW_STANDARD) || (xaes.draw_3d == DRAW_LTMF) ||
			(xaes.draw_3d == DRAW_MULTITOS) || (xaes.draw_3d == DRAW_GENEVA)))
			for (i = 0; i <= ((abs(ex->te_thickness)) - 1); i++)
				box(pb->pb_x + i, pb->pb_y + i, pb->pb_w - (2 * i), pb->pb_h - (2 * i), 1);

		if (flags & 0x200 && (xaes.draw_3d == DRAW_MULTITOS || xaes.draw_3d == DRAW_GENEVA)) {
			int col1, col2, pxyarray[8];

			if (pb->pb_currstate & SELECTED && flags & 0x0400)
				col1 = 1, col2 = ((xaes.draw_3d == DRAW_GENEVA) && num_colors > 4) ? 8 : 0;
			else
				col1 = 0, col2 = ((num_colors == 4) && (xaes.config1 & X_MEDEMUL)) ? 3 : 9;

			vsl_color(VDIhandle, col1);
			pxyarray[0] = pxyarray[2] = interiorpxy[0];
			pxyarray[1] = (xaes.draw_3d==DRAW_GENEVA) ? interiorpxy[3] : interiorpxy[3] - 1;
			pxyarray[3] = pxyarray[5] = interiorpxy[1];
			pxyarray[4] = (xaes.draw_3d==DRAW_GENEVA) ? interiorpxy[2] : interiorpxy[2] - 1;
			v_pline(VDIhandle, 3, pxyarray);

			vsl_color(VDIhandle, col2);
			pxyarray[0] = pxyarray[0] + 1;
			pxyarray[1] = pxyarray[3] = interiorpxy[3];
			pxyarray[2] = pxyarray[4] = interiorpxy[2];
			pxyarray[5] = interiorpxy[1] + 1;
			v_pline(VDIhandle, 3, pxyarray);

			if (xaes.draw_3d!=DRAW_GENEVA) {
				vsm_color(VDIhandle, (num_colors>4) ? 8 : 0);
				pxyarray[0] = interiorpxy[0];
				pxyarray[1] = interiorpxy[3];
				pxyarray[2] = interiorpxy[2];
				pxyarray[3] = interiorpxy[1];
				v_pmarker(VDIhandle, 2, pxyarray);
			}
		}

		if ((ex->te_thickness) && ((xaes.draw_3d == DRAW_ZOOM) || (xaes.draw_3d == DRAW_MOTIF))) {
			int col1, col2;

			if (pb->pb_currstate & SELECTED && flags & 0x0400)
				col1 = 0, col2 = ((num_colors == 4) && (xaes.config1 & X_MEDEMUL)) ? 3 : 9;
			else
				col1 = ((num_colors == 4) && (xaes.config1 & X_MEDEMUL)) ? 3 : 9, col2 = 0;

			for (i = 0; i <= (abs(ex->te_thickness)); i++) {
				int pxyarray[8];

				vsl_color(VDIhandle, col1);

				pxyarray[0] = pb->pb_x + i;
				pxyarray[1] = pxyarray[3] = pb->pb_y + pb->pb_h - i;
				pxyarray[2] = pxyarray[4] = pb->pb_x + pb->pb_w - i;
				pxyarray[5] = pb->pb_y + i;
				v_pline(VDIhandle, 3, pxyarray);

				vsl_color(VDIhandle, col2);

				pxyarray[0] = pb->pb_x + i;
				pxyarray[1] = pb->pb_y + pb->pb_h - i;
				pxyarray[2] = pb->pb_x + i;
				pxyarray[3] = pb->pb_y + i;
				pxyarray[4] = pb->pb_x + pb->pb_w - i;
				v_pline(VDIhandle, 3, pxyarray);

				vsm_color(VDIhandle, (num_colors>4) ? 8 : 0);

				pxyarray[0] = pb->pb_x + i;
				pxyarray[1] = pb->pb_y + pb->pb_h - i;
				pxyarray[2] = pb->pb_x + pb->pb_w - i;
				pxyarray[3] = pb->pb_y + i;
				v_pmarker(VDIhandle, 2, pxyarray);
			}

			if (xaes.draw_3d != DRAW_MOTIF)
				box(pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, 1);
		}

		switch (xaes.draw_3d) {
			case DRAW_STANDARD:
			case DRAW_LTMF:
			case DRAW_MULTITOS:
			case DRAW_GENEVA:
				vswr_mode(VDIhandle, MD_TRANS);
				vst_color(VDIhandle, ((xaes.config1 & X_DRAW3DCOMPAT) && (num_colors == 2) && (pb->pb_currstate & DISABLED)) ? 0 : ex->te_color.text_color);

				if (((xaes.draw_3d == DRAW_MULTITOS) || (xaes.draw_3d == DRAW_GENEVA)) &&
					(pb->pb_currstate & SELECTED) && (flags & 0x0400))
					v_gtext(VDIhandle, x + 1, y + 1, string);
				else
					v_gtext(VDIhandle, x, y, string);
				break;

			case DRAW_ZOOM:
			case DRAW_MOTIF:
				vswr_mode(VDIhandle, MD_TRANS);
				vst_color(VDIhandle, ((xaes.config1 & X_DRAW3DCOMPAT) && (num_colors == 2) && (pb->pb_currstate & DISABLED)) ? 0 : ex->te_color.text_color);

				if ((pb->pb_currstate & SELECTED) && (flags & 0x0400))
					v_gtext(VDIhandle, x + (abs(ex->te_thickness)), y + (abs(ex->te_thickness)), string);
				else
					v_gtext(VDIhandle, x, y, string);
				break;
		}

		if (hotkey >= 0) {
			int pxyarray[4];

			vsl_color(VDIhandle, xaes.hotkey_color);
			vswr_mode(VDIhandle, MD_TRANS);

			if (((xaes.draw_3d == DRAW_MOTIF) ||
				(xaes.draw_3d == DRAW_ZOOM)) &&
				(pb->pb_currstate & SELECTED) &&
				(flags & 0x0400)) {
				pxyarray[2] = (pxyarray[0] = x + (abs(ex->te_thickness)) + gr_bw * hotkey) + gr_bw;
				pxyarray[1] = pxyarray[3] = y + (abs(ex->te_thickness)) + (gr_ch / 6);
			} else if (((xaes.draw_3d == DRAW_MULTITOS) ||
						(xaes.draw_3d == DRAW_GENEVA)) &&
						(pb->pb_currstate & SELECTED) &&
						(flags & 0x0400)) {
				pxyarray[2] = (pxyarray[0] = x + gr_bw * hotkey) + gr_bw + 1;
				pxyarray[1] = pxyarray[3] = y + (gr_ch / 6) + 1;
				if ((xaes.config1 & X_GENEVACOMPAT) && GenevaInstalled) {
					pxyarray[1] += gr_ch;
					pxyarray[3] += gr_ch;
				}
			} else {
				pxyarray[2] = (pxyarray[0] = x + gr_bw * hotkey) + gr_bw;
				pxyarray[1] = pxyarray[3] = y + (gr_ch / 6);
				if ((xaes.config1 & X_GENEVACOMPAT) && GenevaInstalled) {
					pxyarray[1] += gr_ch;
					pxyarray[3] += gr_ch;
				}
			}

			v_pline(VDIhandle, 2, pxyarray);
		}

		if ((pb->pb_currstate & SELECTED) &&
			((!(flags & 0x0400)) ||
			(xaes.draw_3d == DRAW_STANDARD) ||
			(xaes.draw_3d == DRAW_LTMF))) {
			vsf_interior(VDIhandle, FIS_SOLID);
			vsf_color(VDIhandle, BLACK);
			vswr_mode(VDIhandle, MD_XOR);
			vr_recfl(VDIhandle, interiorpxy);

			if (xaes.draw_3d == DRAW_LTMF) {
				vswr_mode(VDIhandle, MD_REPLACE);
				box(pb->pb_x + ((abs(ex->te_thickness)) - 1),
					pb->pb_y + ((abs(ex->te_thickness)) - 1),
					(pb->pb_w - (2 * (abs(ex->te_thickness)))) + 2,
					(pb->pb_h - (2 * (abs(ex->te_thickness)))) + 2, 0);
				vswr_mode(VDIhandle, MD_XOR);
			}
		}

		if (pb->pb_tree[pb->pb_obj].ob_state & SHADOWED) {
			pb->pb_w += tempcalc;
			pb->pb_h += tempcalc;

			vsf_interior(VDIhandle, FIS_SOLID);
			vswr_mode(VDIhandle, MD_REPLACE);
			vsf_color(VDIhandle, BLACK);
			vsl_color(VDIhandle, BLACK);

			/* Wow, look, mommie!  I optimized it all by myself! */
			shadowed[0] = shadowed[10] = shadowed[12] = pb->pb_x + pb->pb_w - tempcalc + 1;
			shadowed[1] = shadowed[3] = shadowed[13] = pb->pb_y + tempcalc;
			shadowed[2] = shadowed[4] = pb->pb_x + pb->pb_w;
			shadowed[5] = shadowed[7] = pb->pb_y + pb->pb_h;
			shadowed[6] = shadowed[8] = pb->pb_x + tempcalc;
			shadowed[9] = shadowed[11] = pb->pb_y + pb->pb_h - tempcalc + 1;

			v_fillarea(VDIhandle, 7, shadowed);

			if (xaes.config1 & X_ROUNDSHADOW) {
				point(pb->pb_x + pb->pb_w, pb->pb_y + tempcalc, (num_colors > 4) ? 8 : 0);
				point(pb->pb_x + pb->pb_w, pb->pb_y + pb->pb_h, (num_colors > 4) ? 8 : 0);
				point(pb->pb_x + tempcalc, pb->pb_y + pb->pb_h, (num_colors > 4) ? 8 : 0);
			}

			pb->pb_w -= tempcalc;
			pb->pb_h -= tempcalc;
		}

		if (effects)
			vst_effects(VDIhandle, 0);

		if (xaes.config1 & X_ROUNDOBJECTS)
			if (pb->pb_tree->ob_state & DRAW3D) {
				point(pb->pb_x, pb->pb_y, (num_colors > 4) ? 8 : 0);
				point(pb->pb_x + pb->pb_w, pb->pb_y, (num_colors > 4) ? 8 : 0);
				point(pb->pb_x, pb->pb_y + pb->pb_h, (num_colors > 4) ? 8 : 0);
				if (!(pb->pb_tree[pb->pb_obj].ob_state & SHADOWED))
					point(pb->pb_x + pb->pb_w, pb->pb_y + pb->pb_h, (num_colors > 4) ? 8 : 0);
			} else {
				point(pb->pb_x, pb->pb_y, 0);
				point(pb->pb_x + pb->pb_w, pb->pb_y, 0);
				point(pb->pb_x, pb->pb_y + pb->pb_h, 0);
				if (!(pb->pb_tree[pb->pb_obj].ob_state & SHADOWED))
					point(pb->pb_x + pb->pb_w, pb->pb_y + pb->pb_h, 0);
			}				

		if (pb->pb_currstate & DISABLED) {
			vsf_interior(VDIhandle, FIS_PATTERN);

			interiorpxy[0] = pb->pb_x + (abs(ex->te_thickness));
			interiorpxy[1] = pb->pb_y + (abs(ex->te_thickness));
			interiorpxy[2] = pb->pb_x + pb->pb_w - (abs(ex->te_thickness)) - 1;
			interiorpxy[3] = pb->pb_y + pb->pb_h - (abs(ex->te_thickness)) - 1;

			if (num_planes >= 4)
				vsf_color(VDIhandle, 8);
			else
				vsf_color(VDIhandle, 0);

			vsf_style(VDIhandle, 4);
			vswr_mode(VDIhandle, MD_TRANS);
			vr_recfl(VDIhandle, interiorpxy);
		}

		vst_height(VDIhandle, attr[7], &dummy, &dummy, &dummy, &dummy);
		vst_color(VDIhandle, attr[1]);
		vswr_mode(VDIhandle, attr[5]);

		vsf_color(VDIhandle, fillattr[1]);
		vsf_interior(VDIhandle, fillattr[0]);
		vsf_style(VDIhandle, fillattr[2]);

		vsl_color(VDIhandle, BLACK);

		pb->pb_x -= xoff;
		pb->pb_y -= yoff;
	}

	if (pb->pb_tree[pb->pb_obj].ob_state & SHADOWED) {
		pb->pb_w += tempcalc;
		pb->pb_h += tempcalc;
	}
}

LOCAL int cdecl	draw_specialtext(PARMBLK *pb)
{
	EXTINFO *ex = (EXTINFO *) pb->pb_parm;

	if (((ex->oldtype & 0xFF) != G_ICON) && ((ex->oldtype & 0xFF) != G_IMAGE))
		pb_doobject(pb, 0, 0);

	return pb->pb_currstate & ~(SELECTED | OUTLINED | DISABLED);
}

LOCAL int cdecl draw_menuline(PARMBLK *pb)
{
	int attr[10], fillattr[5], lineattr[6];
	GRECT line1, line2;

	vqt_attributes(VDIhandle, attr);
	vqf_attributes(VDIhandle, fillattr);
	vql_attributes(VDIhandle, lineattr);

	line1.g_x = line2.g_x = pb->pb_x;
	line1.g_y = line1.g_h = pb->pb_y + (pb->pb_h / 2) - 1;
	line1.g_w = line2.g_w = pb->pb_x + pb->pb_w - 1;
	line2.g_y = line2.g_h = pb->pb_y + (pb->pb_h / 2);

	vsl_color(VDIhandle, ((((EXTINFO *) pb->pb_parm)->te_color.bord_color == 0) ?
						  1 : (((EXTINFO *) pb->pb_parm)->te_color.bord_color)));

	if (xaes.config1 & X_NICELINE) {
		vsl_type(VDIhandle, 7);
		vsl_udsty(VDIhandle, 0xAAAA);
	}

	line(line1.g_x, line1.g_y, line1.g_w, line1.g_h);

	if (xaes.config1 & X_NICELINE)
		vsl_udsty(VDIhandle, 0x5555);

	line(line2.g_x, line2.g_y, line2.g_w, line2.g_h);

	vst_color(VDIhandle, attr[1]);
	vswr_mode(VDIhandle, attr[5]);

	vsf_color(VDIhandle, fillattr[1]);
	vsf_interior(VDIhandle, fillattr[0]);
	vsf_style(VDIhandle, fillattr[2]);

	vsl_color(VDIhandle, lineattr[1]);
	vsl_type(VDIhandle, 7);
	vsl_udsty(VDIhandle, 0xFFFF);

	return FALSE;
}

LOCAL int cdecl	draw_underline(PARMBLK *pb)
{
	int pxyarray[4], dummy;
	int attr[10], fillattr[5], lineattr[6];

	vqt_attributes(VDIhandle, attr);
	vqf_attributes(VDIhandle, fillattr);
	vql_attributes(VDIhandle, lineattr);

	pb_doobject(pb, 0, 0);

	pxyarray[0] = pb->pb_xc;
	pxyarray[1] = pb->pb_yc;
	pxyarray[2] = pb->pb_xc + pb->pb_wc - 1;
	pxyarray[3] = pb->pb_yc + pb->pb_hc - 1;
	vs_clip(VDIhandle, 1, pxyarray);

	if (pb->pb_tree[pb->pb_obj].ob_state & DISABLED) {
		vsl_type(VDIhandle, 7);
		vsl_udsty(VDIhandle, 0x5555);
	}

	vswr_mode(VDIhandle, MD_REPLACE);
	vsl_color(VDIhandle, ((EXTINFO *) pb->pb_parm)->te_color.bord_color);

	pxyarray[0] = pb->pb_x;
	pxyarray[2] = pb->pb_x + pb->pb_w;
	pxyarray[1] = pxyarray[3] = (pb->pb_y + pb->pb_h) + 1;
	v_pline(VDIhandle, 2, pxyarray);

	vst_height(VDIhandle, attr[7], &dummy, &dummy, &dummy, &dummy);
	vst_color(VDIhandle, attr[1]);
	vswr_mode(VDIhandle, attr[5]);

	vsf_color(VDIhandle, fillattr[1]);
	vsf_interior(VDIhandle, fillattr[0]);
	vsf_style(VDIhandle, fillattr[2]);

	vsl_color(VDIhandle, BLACK);

	return FALSE;
}

LOCAL int cdecl draw_boxframe(PARMBLK *pb)
{
	int pxyarray[10], dummy;
	EXTINFO *ex = (EXTINFO *) pb->pb_parm;
	char *unformatted = ex->te_ptext;
	int state = pb->pb_tree[pb->pb_obj].ob_state;
	int this_ch, this_bw;
	int attr[10], fillattr[5], lineattr[6];

	vqt_attributes(VDIhandle, attr);
	vqf_attributes(VDIhandle, fillattr);
	vql_attributes(VDIhandle, lineattr);

	pxyarray[0] = pb->pb_xc;
	pxyarray[1] = pb->pb_yc;
	pxyarray[2] = pb->pb_xc + pb->pb_wc - 1;
	pxyarray[3] = pb->pb_yc + pb->pb_hc - 1;
	vs_clip(VDIhandle, 1, pxyarray);

	vswr_mode(VDIhandle, MD_REPLACE);
	vsl_color(VDIhandle, ((EXTINFO *) pb->pb_parm)->te_color.bord_color);

	if ((num_colors<=4) || !(state & DRAW3D) || (xaes.draw_3d == DRAW_STANDARD))
		box(pb->pb_x, pb->pb_y, pb->pb_w - 1, pb->pb_h - 1, ((EXTINFO *) pb->pb_parm)->te_color.bord_color);

	if ((state & DRAW3D) && (num_colors > 4) && (xaes.draw_3d != DRAW_STANDARD)) {
		vsl_color(VDIhandle, 9);
		pxyarray[0] = pb->pb_x + pb->pb_w - 1;
		pxyarray[1] = pxyarray[3] = pb->pb_y;
		pxyarray[2] = pxyarray[4] = pb->pb_x;
		pxyarray[5] = pb->pb_y + pb->pb_h - 1;
		v_pline(VDIhandle, 3, pxyarray);

		vsl_color(VDIhandle, 0);
		pxyarray[0] = pxyarray[2] = pb->pb_x + pb->pb_w - 1;
		pxyarray[1] = pb->pb_y + 1;
		pxyarray[3] = pxyarray[5] = pb->pb_y + pb->pb_h - 1;
		pxyarray[4] = pb->pb_x + 1;
		v_pline(VDIhandle, 3, pxyarray);

		vsf_interior(VDIhandle, FIS_SOLID);

		if (state & 0x0040)
			vsf_color(VDIhandle, WHITE);
		else
			vsf_color(VDIhandle, 8);

		pxyarray[0] = pb->pb_x + 1;
		pxyarray[1] = pb->pb_y + 1;
		pxyarray[2] = pb->pb_x + pb->pb_w - 3;
		pxyarray[3] = pb->pb_y + pb->pb_h - 3;
		vr_recfl(VDIhandle, pxyarray);

		box(pb->pb_x + 1, pb->pb_y + 1, pb->pb_w - 3, pb->pb_h - 3, (state & 0x0040) ? 8 : WHITE);

		if (!(state & 0x0040)) {
			vsl_color(VDIhandle, 9);

			pxyarray[0] = pxyarray[2] = pb->pb_x + pb->pb_w - 2;
			pxyarray[1] = pb->pb_y + 2;
			pxyarray[3] = pxyarray[5] = pb->pb_y + pb->pb_h - 2;
			pxyarray[4] = pb->pb_x + 2;

			v_pline(VDIhandle, 3, pxyarray);
		}
	}

	vst_height(VDIhandle, ex->te_font == 3 ? large_font : small_font, &dummy, &this_ch, &this_bw, &dummy);
	v_gtext(VDIhandle, pb->pb_x + gr_cw, pb->pb_y + (this_ch / 2), unformatted);

	if (pb->pb_tree[pb->pb_obj].ob_flags & BOXFRAMETITLE) {
		vsl_color(VDIhandle, 9);
		pxyarray[0] = pxyarray[2] = pb->pb_x + gr_cw;
		pxyarray[1] = pxyarray[7] = pb->pb_y;
		pxyarray[3] = pxyarray[5] = pb->pb_y - (gr_ch / 2);
		pxyarray[4] = pxyarray[6] = pb->pb_x + (int)((strlen(unformatted) + 1) * gr_cw);
		v_pline(VDIhandle, 4, pxyarray);

		vsl_color(VDIhandle, 8);

		pxyarray[0] = pxyarray[2] = pb->pb_x + gr_cw;
		pxyarray[1] = pxyarray[7] = pb->pb_y + 1;
		pxyarray[3] = pxyarray[5] = pb->pb_y + (gr_ch / 2) + 1;
		pxyarray[4] = pxyarray[6] = pb->pb_x + (int)((strlen(unformatted) + 1) * gr_cw);
		v_pline(VDIhandle, 4, pxyarray);
	}

	vst_height(VDIhandle, attr[7], &dummy, &dummy, &dummy, &dummy);
	vst_color(VDIhandle, attr[1]);
	vswr_mode(VDIhandle, attr[5]);

	vsf_color(VDIhandle, fillattr[1]);
	vsf_interior(VDIhandle, fillattr[0]);
	vsf_style(VDIhandle, fillattr[2]);

	vsl_color(VDIhandle, BLACK);

	return pb->pb_currstate & ~(SELECTED | OUTLINED | DISABLED);
}

/*
 *	Fix resource objects to include customised objects
 *
 *	*obj = pointer to object to fix
 *
 *	Returns: TRUE on success
 */
GLOBAL int fix_object(OBJECT *obj, BOOL pos, BOOL repos)
{
	int object = -1;
	USERBLK *ub;

	do {
		object++;

/* DJH - Couldn't you compress this into one big switch {} statement? */
		if (((obj[object].ob_type >> 8) == FLYING) ||
			((obj[object].ob_type >> 8) == CUSTOM) ||
			((obj[object].ob_type >> 8) == UNDERLINE) ||
			((obj[object].ob_type >> 8) == BOXFRAME) ||
			((obj[object].ob_type >> 8) == HELPBTN) ||
			((obj[object].ob_type >> 8) == CYCLEBTN) ||
			((obj[object].ob_type >> 8) == TEXTEFFECTS) ||
			((obj[object].ob_type >> 8) == CUSTBTN) ||
			((obj[object].ob_type >> 8) == DROPDOWN) ||
			((obj[object].ob_type >> 8) == MENUTEAR) ||
			((obj[object].ob_type >> 8) == UNDOBTN) ||
			((obj[object].ob_type >> 8) == MENULINE) ||
			((obj[object].ob_type >> 8) == SLIDERLEFT) ||
			((obj[object].ob_type >> 8) == SLIDERRIGHT) ||
			((obj[object].ob_type >> 8) == SLIDERUP) ||
			((obj[object].ob_type >> 8) == SLIDERDOWN) ||
			((obj[object].ob_type >> 8) == SLIDERTRACK) ||
			((obj[object].ob_type >> 8) == SLIDERSLIDE)) {
			if (ub = malloc(sizeof(USERBLK) + sizeof(EXTINFO))) {
				EXTINFO *ex = (EXTINFO *) (ub + 1);

				switch(obj[object].ob_type & 0xff) {
					case G_TEXT:
						memset(ex, 0, sizeof(EXTINFO));
						memcpy(ex, obj[object].ob_spec.tedinfo, sizeof(TEDINFO));
						ex->te_thickness = 0;
						break;

					case G_BOXTEXT:
						memset(ex, 0, sizeof(EXTINFO));
						memcpy(ex, obj[object].ob_spec.tedinfo, sizeof(TEDINFO));

						FixThick(ex->te_thickness, &obj[object]);
						FixShadow(ex->te_thickness, &obj[object]);

						if (pos) {
							FixPositioning(ex->te_ptext, &obj[object]);
							FixSizing(ex->te_ptext, &obj[object]);
						}

						if (repos)
							FixMovement(&obj[object]);

						break;

					case G_STRING:
						memset(ex, 0, sizeof(EXTINFO));
						ex->te_ptext = obj[object].ob_spec.free_string;
						ex->te_font = 3;
						ex->te_color.bord_color = ex->te_color.text_color = 1;
						ex->te_thickness = 0;
						break;

					case G_BUTTON:
						memset(ex, 0, sizeof(EXTINFO));
						ex->te_ptext = obj[object].ob_spec.free_string;
						ex->te_font = 3;
						ex->te_just = 2;
						ex->te_thickness = obj[object].ob_flags & EXIT ? (obj[object].ob_flags & DEFAULT ? -3 : -2) : -1;
						ex->te_color.bord_color = ex->te_color.text_color = 1;

						FixThick(ex->te_thickness, &obj[object]);
						FixShadow(ex->te_thickness, &obj[object]);

						if (pos) {
							FixPositioning(ex->te_ptext, &obj[object]);
							FixSizing(ex->te_ptext, &obj[object]);
						}

						if (repos)
							FixMovement(&obj[object]);

						break;

					case G_BOX:
						memset(ex, 0, sizeof(EXTINFO));
						ex->te_ptext = "";
						ex->te_font = 3;
						ex->te_just = 2;
						ex->te_thickness = obj[object].ob_spec.obspec.framesize;
						ex->te_color.bord_color = obj[object].ob_spec.obspec.framecol;
						ex->te_color.text_color = obj[object].ob_spec.obspec.textcol;
						ex->te_color.in_color = obj[object].ob_spec.obspec.interiorcol;
						ex->te_color.fill_ptn = obj[object].ob_spec.obspec.fillpattern;
						if (ex->te_color.fill_ptn == 1)
							ex->te_color.fill_ptn = 0;

						FixThick(ex->te_thickness, &obj[object]);
						FixShadow(ex->te_thickness, &obj[object]);
						break;

					case G_IBOX:
						memset(ex, 0, sizeof(EXTINFO));
						ex->te_ptext = "";
						ex->te_font = 3;
						ex->te_just = 2;
						ex->te_thickness = obj[object].ob_spec.obspec.framesize;
						ex->te_color.bord_color = obj[object].ob_spec.obspec.framecol;
						ex->te_color.text_color = obj[object].ob_spec.obspec.textcol;
						ex->te_color.in_color = obj[object].ob_spec.obspec.interiorcol;
						ex->te_color.fill_ptn = 0;

						FixThick(ex->te_thickness, &obj[object]);
						FixShadow(ex->te_thickness, &obj[object]);
						break;

					case G_BOXCHAR:
						memset(ex, 0, sizeof(EXTINFO));
						ex->te_ptext = "X";
						*ex->te_ptext = (char) obj[object].ob_spec.obspec.character;
						ex->te_font = 3;
						ex->te_just = 2;
						ex->te_thickness = obj[object].ob_spec.obspec.framesize;
						ex->te_color.bord_color = obj[object].ob_spec.obspec.framecol;
						ex->te_color.text_color = obj[object].ob_spec.obspec.textcol;
						ex->te_color.in_color = obj[object].ob_spec.obspec.interiorcol;
						ex->te_color.fill_ptn = (obj[object].ob_spec.obspec.fillpattern == 1) ? 1 : obj[object].ob_spec.obspec.fillpattern;

						FixThick(ex->te_thickness, &obj[object]);
						FixShadow(ex->te_thickness, &obj[object]);
						break;

					default:
						break;
				}

				ex->te_routines.mouse_down	= NULL;
				ex->te_routines.mouse_up	= NULL;
				ex->te_routines.mouse_move	= NULL;
				ex->te_routines.mouse_click	= NULL;

				ex->oldparm = obj[object].ob_spec.userblk;
				ex->oldtype = obj[object].ob_type;

				switch(obj[object].ob_type >> 8) {
					case SLIDERLEFT:
						ex->te_ptext = "\4";
						break;

					case SLIDERRIGHT:
						ex->te_ptext = "\3";
						break;

					case SLIDERUP:
						ex->te_ptext = "\1";
						break;

					case SLIDERDOWN:
						ex->te_ptext = "\2";
						break;
				}

				ub->ub_parm = (long) ex;

				switch(obj[object].ob_type >> 8) {
					case MENULINE:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_menuline;
						obj[object].ob_type = (MENULINE << 8) + G_USERDEF;
						break;

					case UNDERLINE:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_underline;
						obj[object].ob_type = (UNDERLINE << 8) + G_USERDEF;
						break;

					case BOXFRAME:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_boxframe;
						obj[object].ob_type = (BOXFRAME << 8) + G_USERDEF;
						break;

					case SLIDERLEFT:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_specialtext;
						obj[object].ob_type = (SLIDERLEFT << 8) + G_USERDEF;
						break;

					case SLIDERRIGHT:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_specialtext;
						obj[object].ob_type = (SLIDERRIGHT << 8) + G_USERDEF;
						break;

					case SLIDERUP:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_specialtext;
						obj[object].ob_type = (SLIDERUP << 8) + G_USERDEF;
						break;

					case SLIDERDOWN:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_specialtext;
						obj[object].ob_type = (SLIDERDOWN << 8) + G_USERDEF;
						break;

					case SLIDERTRACK:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_specialtext;
						obj[object].ob_type = (SLIDERTRACK << 8) + G_USERDEF;
						break;

					case SLIDERSLIDE:
						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_specialtext;
						obj[object].ob_type = (SLIDERSLIDE << 8) + G_USERDEF;
						break;

					default:
						{
							char *ptr;

							if (((obj[object].ob_type >> 8) != FLYING))
								if ((ptr = strchr(ex->te_ptext, '[')) && *(++ptr))
									ex->te_hotkey = ((toupper(*ptr)) & 0x7f);
								else
									ex->te_hotkey = 0;
							else
								ex->te_hotkey = 0;
						}

						ub->ub_code = (int cdecl (*)(PARMBLK *))draw_specialtext;
						obj[object].ob_type = G_USERDEF;
						break;
				}

				obj[object].ob_spec.userblk = ub;
			}
		}
	} while(!(obj[object].ob_flags & LASTOB));

	return TRUE;
}

GLOBAL void unfix_object(OBJECT *obj)
{
	USERBLK *ub;
	EXTINFO *ex;

	if (obj->ob_type != G_TITLE)
		if ((obj->ob_type & 0xFF) == G_USERDEF) {
			ub = obj->ob_spec.userblk;
			ex = (EXTINFO *) ub->ub_parm;

			if (ex != NULL) {
				if (ex->te_thickness < 0) {
					obj->ob_width += ex->te_thickness * 2;
					obj->ob_height += ex->te_thickness * 2;
					obj->ob_x -= ex->te_thickness;
					obj->ob_y -= ex->te_thickness;
				}

				obj->ob_spec.userblk = ex->oldparm;
				obj->ob_type = ex->oldtype;
				free(ub);
			}
		}
}
