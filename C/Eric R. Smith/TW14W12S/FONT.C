/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#include <stdlib.h>
#include <string.h>
#include "xgem.h"
#include "toswin_w.h"
#include "twdefs.h"
#include "twproto.h"

char *blank = "";
FONTDESC *fontdesc;

static void
blankcopy(dest, src)
	char *dest, *src;
{
	while (*dest && *src) {
		*dest++ = *src++;
	}
	while (*dest)
		*dest++ = ' ';
}

void
init_fontdesc()
{
	int i;
	int attrib[10];
	int charw, charh, boxw, boxh;
	char font_name[32];
	int orig_font, orig_size;
	int font_index;
	int prev_size, point_size;

	vqt_attributes(vdi_handle, attrib);
	orig_font = attrib[0];
	orig_size = attrib[7];

	fontdesc = malloc(gl_numfonts * sizeof(FONTDESC));
	for (i = 0; i < gl_numfonts; i++) {
		font_index = vqt_name(vdi_handle, i+1, font_name);
		if (font_name[BOXLEN]) {	/* FSM font */
			fontdesc[i].isfsm = 1;
		} else {
			fontdesc[i].isfsm = 0;
		}
		font_name[BOXLEN] = 0;
		if (!strcmp(font_name, "6x6 system font"))
			strcpy(font_name, "System Font");
		strcpy(fontdesc[i].name, font_name);
		fontdesc[i].fontidx = font_index;
		fontdesc[i].points = 0L;
		vst_font(vdi_handle, font_index);
		point_size = 32;
		fontdesc[i].num_points = 0;
		for(;;) {
			prev_size = point_size - 1;
			point_size = vst_point(vdi_handle, prev_size,
				&charw, &charh, &boxw, &boxh);
			if (point_size > prev_size) break;
			fontdesc[i].points |= (1L << (long)point_size);
			fontdesc[i].num_points++;
		}
	}
	vst_font(vdi_handle, orig_font);
	vst_height(vdi_handle, orig_size, &charw, &charh, &boxw, &boxh);
}

#define NUMLINES 8
#define FNTLIN      FNTLIN1
#define FNTLINLAST  (FNTLIN+NUMLINES-1)
#define SIZLIN      SIZLIN1
#define SIZLINLAST  (SIZLIN+NUMLINES-1)

void
set_fontbox(off, maxfntoff, draw)
	int off, maxfntoff, draw;
{
	int i;
	int n = FNTLIN;
	int fntoff = off;

	for (i = 0; i < gl_numfonts; i++) {
		if (off == 0) {
			blankcopy((char *)fontdial[n].ob_spec,
				fontdesc[i].name);
			fontdial[n].ob_flags |= TOUCHEXIT;
			fontdial[n].ob_state = NORMAL;
			if (++n > FNTLINLAST) break;
		} else
			--off;
	}

	while (n <= FNTLINLAST) {
		blankcopy((char *)fontdial[n].ob_spec, blank);
		fontdial[n].ob_flags &= ~TOUCHEXIT;
		fontdial[n].ob_state = NORMAL;
		n++;
	}

	if (gl_numfonts <= NUMLINES) {
		fontdial[FNTSLIDE].ob_y = 0;
		fontdial[FNTSLIDE].ob_height = fontdial[FNTSLIBX].ob_height;
		fontdial[FNTSLIDE].ob_flags &= ~TOUCHEXIT;
		fontdial[FNTSLIBX].ob_flags &= ~TOUCHEXIT;
		fontdial[FNTUPARR].ob_flags &= ~TOUCHEXIT;
		fontdial[FNTDNARR].ob_flags &= ~TOUCHEXIT;
	} else {
		i = (fontdial[FNTSLIBX].ob_height * NUMLINES) / gl_numfonts;
		if (i <= 0) i = 1;
		fontdial[FNTSLIDE].ob_y =
			(fontdial[FNTSLIBX].ob_height * fntoff) / gl_numfonts;
		fontdial[FNTSLIDE].ob_height = i;
		fontdial[FNTSLIDE].ob_flags |= TOUCHEXIT;
		fontdial[FNTSLIBX].ob_flags |= TOUCHEXIT;
		fontdial[FNTUPARR].ob_flags |= TOUCHEXIT;
		fontdial[FNTDNARR].ob_flags |= TOUCHEXIT;
	}
	if (draw) {
		objc_draw(fontdial, FNTSLIBX, 1, xdesk, ydesk, wdesk, hdesk);
		objc_draw(fontdial, FONTBOX, 1, xdesk, ydesk, wdesk, hdesk);
	}
}

static char *pointstr(d)
	int d;
{
	static char foo[16];
	char *s;

	s = valdec(d);
	if (s[0] == '0') {
		s[0] = ' ';
		if (s[1] == '0') s[1] = ' ';
	}
	strcpy(foo, s);
	strcat(foo, " points");
	return foo;
}

void
set_sizebox(f, off, draw)
	FONTDESC *f;
	int off, draw;
{
	int i, j;
	int n = SIZLIN;
	int sizoff = off;

	for (j = 0; j < 32; j++) {
		if (f->points & (1L << (long)j)) {
			if (off == 0) {
				blankcopy((char *)fontdial[n].ob_spec,
					 pointstr(j));
				fontdial[n].ob_flags |= TOUCHEXIT;
				fontdial[n].ob_state = NORMAL;
				if (++n > SIZLINLAST) break;
			} else {
				--off;
			}
		}
	}
	while (n <= SIZLINLAST) {
		blankcopy((char *)fontdial[n].ob_spec, blank);
		fontdial[n].ob_flags &= ~TOUCHEXIT;
		fontdial[n].ob_state = NORMAL;
		n++;
	}
	if (f->num_points <= NUMLINES) {
		fontdial[SIZSLIDE].ob_y = 0;
		fontdial[SIZSLIDE].ob_height = fontdial[SIZSLIBX].ob_height;
		fontdial[SIZSLIBX].ob_flags &= ~TOUCHEXIT;
		fontdial[SIZSLIDE].ob_flags &= ~TOUCHEXIT;
		fontdial[SIZUPARR].ob_flags &= ~TOUCHEXIT;
		fontdial[SIZDNARR].ob_flags &= ~TOUCHEXIT;
	} else {
		i = (fontdial[SIZSLIBX].ob_height * NUMLINES) / gl_numfonts;
		if (i <= 0) i = 1;
		fontdial[SIZSLIDE].ob_y =
			(fontdial[SIZSLIBX].ob_height * sizoff) / gl_numfonts;
		fontdial[SIZSLIDE].ob_height = i;
		fontdial[SIZSLIDE].ob_flags |= TOUCHEXIT;
		fontdial[SIZSLIBX].ob_flags |= TOUCHEXIT;
		fontdial[SIZUPARR].ob_flags |= TOUCHEXIT;
		fontdial[SIZDNARR].ob_flags |= TOUCHEXIT;
	}
	if (draw) {
		objc_draw(fontdial, SIZSLIBX, 1, xdesk, ydesk, wdesk, hdesk);
		objc_draw(fontdial, SIZEBOX, 1, xdesk, ydesk, wdesk, hdesk);
	}
}

/*
 * slide a box around, and return the new position for it
 */

int
slide(tree, box, slider, maxoff)
	OBJECT *tree;
	int box, slider, maxoff;
{
	int totsiz = maxoff + NUMLINES;
	long r;

	r = graf_slidebox(tree, box, slider, 1);
	/* r is now scaled from 0-1000 */
	r = (totsiz * r) / 1000 - (NUMLINES/2);
	if (r < 0) r = 0;
	if (r > maxoff) r = maxoff;
	return r;
}

/*
 * respond to a click in the "page" area of a slider box
 */

int
page(tree, box, slider, off, maxoff)
	OBJECT *tree;
	int box, slider, off, maxoff;
{
	int x1, y1, x2, y2;
	int x, y, dummy;

	graf_mkstate(&x, &y, &dummy, &dummy);

/* mouse sanity check */
	objc_offset(tree, box, &x1, &y1);
	if (x < x1 || x > x + tree[box].ob_width || y < y1 ||
	    y > y + tree[box].ob_height) return off;

/* check first rectangle */
	objc_offset(tree, slider, &x2, &y2);
	if (y >= y1 && y < y2) {		/* yes, it's a page up */
		off -= NUMLINES;
		if (off < 0) off = 0;
		return off;
	}
/* OK, check second rectangle */
	y1 += tree[box].ob_height;
	y2 += tree[slider].ob_height;
	if (y > y2 && y <= y1) {
		off += NUMLINES;
		if (off > maxoff) off = maxoff;
	}
	return off;
}

#define update_sizebox() objc_draw(fontdial, SIZNMBOX, 3, x, y, w, h);

static
int	same_font_name(name,pattern)
	char* name;
	char* pattern;
{
	while (*name && *name==*pattern) {
		name++;
		pattern++;
	}

	while (*name==' ') name++; /* skip spaces */

	return (*name==*pattern);
}

int
find_font_named(name)
	char* name;
{
	int i;
	for (i = 0; i < gl_numfonts; i++) {
		if (same_font_name(fontdesc[i].name,name))
			return fontdesc[i].fontidx;
	}
	return -1;
}

int
get_font(font, size)
	int *font, *size;
{
	int i, x, y, w, h;
	int ret;
	int doubleclick;
	int oldfnt = -1;
	int fntoff, sizoff;
	int oldsiz = -1;
	FONTDESC *f;
	int maxfntoff, maxsizoff;
	char *sizestr;
	TEDINFO *ted;

	fntoff = sizoff = maxsizoff = 0;

	ted = (TEDINFO *)fontdial[SIZNMPTS].ob_spec;
	sizestr = (char *)ted->te_ptext;

	maxfntoff = gl_numfonts - NUMLINES;

/* see if we can find the already existing font and size */
	f = 0;
	for (i = 0; i < gl_numfonts; i++) {
		if (fontdesc[i].fontidx == *font) {
			f = &fontdesc[i];
			break;
		}
	}
	if (f) {
		blankcopy((char *)fontdial[FNTNMSTR].ob_spec, f->name);
		maxsizoff = f->num_points - NUMLINES;
		set_sizebox(f, 0, 0);
	} else {
		blankcopy((char *)fontdial[FNTNMSTR].ob_spec, blank);
		for (i = SIZLIN; i <= SIZLINLAST; i++) {
			blankcopy((char *)fontdial[i].ob_spec, blank);
			fontdial[i].ob_flags &= ~TOUCHEXIT;
		}
		fontdial[SIZSLIDE].ob_height = fontdial[FNTSLIBX].ob_height;
		fontdial[SIZSLIDE].ob_flags &= ~TOUCHEXIT;
		fontdial[SIZUPARR].ob_flags &= ~TOUCHEXIT;
		fontdial[SIZDNARR].ob_flags &= ~TOUCHEXIT;
	}

	if (f && (f->points & (1L << (long)*size))) {
		char *s = pointstr(*size);
		sizestr[0] = s[1];
		sizestr[1] = s[2];
	} else {
		sizestr[0] = sizestr[1] = ' ';
	}

	form_center(fontdial, &x, &y, &w, &h);
	set_fontbox(fntoff, maxfntoff, 0);

	wind_update(1);
	form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
	if (win_flourishes)
		form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);
	objc_draw(fontdial, 0, 5, x, y, w, h);

	for(;;) {
		doubleclick = 0;
		ret = form_do(fontdial, SIZNMPTS);
		if (ret & 0x8000) {
			doubleclick = 1;
			ret &= 0x7fff;
		}
		if (ret == FNTOK || ret == FNTCAN) {
			objc_change(fontdial, ret, 0, x, y, w, h, NONE, 0);
			break;
		}
		else if (ret >= FNTLIN && ret <= FNTLINLAST) {
			if (oldfnt >= 0) {
				objc_change(fontdial, oldfnt, 0, x, y, w, h,
					    NONE, 1);
			}
			if (ret != oldfnt) {
				sizestr[0] = sizestr[1] = ' ';
				update_sizebox();
			}
			oldfnt = ret;
			objc_change(fontdial, ret, 0, x, y, w, h, SELECTED, 1);
			f = &fontdesc[ret-FNTLIN+fntoff];
			blankcopy((char *)fontdial[FNTNMSTR].ob_spec, f->name);
			objc_draw(fontdial, FNTNMBOX, 1, x, y, w, h);
			sizoff = 0; oldsiz = -1;
			maxsizoff = f->num_points - NUMLINES;
			set_sizebox(f, sizoff, 1);
		}
		else if (ret >= SIZLIN && ret <= SIZLINLAST) {
			if (oldsiz >= 0) {
				objc_change(fontdial, oldsiz, 0, x, y, w, h,
					NONE, 1);
			}
			oldsiz = ret;
			objc_change(fontdial, ret, 0, x, y, w, h, SELECTED, 1);
			sizestr[0] = ((char *)fontdial[ret].ob_spec)[1];
			sizestr[1] = ((char *)fontdial[ret].ob_spec)[2];
			update_sizebox();
			if (doubleclick) break;
		}
		else if (ret == FNTUPARR && fntoff > 0) {
			fntoff--;
			set_fontbox(fntoff, maxfntoff, 1);
		} else if (ret == FNTDNARR && fntoff < maxfntoff) {
			fntoff++;
			set_fontbox(fntoff, maxfntoff, 1);
		} else if (ret == SIZUPARR && sizoff > 0) {
			sizoff--;
			set_sizebox(f, sizoff, 1);
		} else if (ret == SIZDNARR && sizoff < maxsizoff) {
			sizoff++;
			set_sizebox(f, sizoff, 1);
		} else if (ret == FNTSLIDE) {
			fntoff = slide(fontdial, FNTSLIBX, FNTSLIDE, maxfntoff);
			set_fontbox(fntoff, maxfntoff, 1);
		} else if (ret == SIZSLIDE) {
			sizoff = slide(fontdial, SIZSLIBX, SIZSLIDE, maxsizoff);
			set_sizebox(f, sizoff, 1);
		} else if (ret == SIZSLIBX) {
			sizoff = page(fontdial, SIZSLIBX, SIZSLIDE, sizoff, 
					maxsizoff);
			set_sizebox(f, sizoff, 1);
		} else if (ret == FNTSLIBX) {
			fntoff = page(fontdial, FNTSLIBX, FNTSLIDE, fntoff,
					maxfntoff);
			set_fontbox(fntoff, maxfntoff, 1);
		}
	}
	if (win_flourishes)
		form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);
	form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);
	wind_update(0);

	if (ret == FNTCAN || !f)
		return FAIL;

	while (*sizestr == ' ') sizestr++;
	i = (*sizestr - '0'); sizestr++;
	if (i < 0 || i > 9) return FAIL;
	if (*sizestr >= '0' && *sizestr <= '9') {
		i = 10 * i + (*sizestr - '0');
	}

	*font = f->fontidx;
	*size = i;

	return OK;
}
