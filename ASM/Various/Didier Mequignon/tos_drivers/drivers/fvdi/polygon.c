/*
 * fVDI polygon fill functions
 *
 * $Id: polygon.c,v 1.4 2004/10/17 21:44:11 johan Exp $
 *
 * Copyright 1999-2003, Johan Klockars 
 * This software is licensed under the GNU General Public License.
 * Please, see LICENSE.TXT for further information.
 *
 * Based on some code found on the net,
 * but very heavily modified.
 */

#include "fvdi.h"
#include "function.h"
#include <mint/osbind.h>

#ifdef __GNUC__
#ifdef COLDFIRE
extern short SMUL_DIV(short x, short y, short z);
#else
#define SMUL_DIV(x,y,z)	((short)(((short)(x)*(long)((short)(y)))/(short)(z)))
#endif
#else
 #ifdef __PUREC__
  #define SMUL_DIV(x,y,z)	((short)(((x)*(long)(y))/(z)))
 #else
int SMUL_DIV(int, int, int);   //   d0d1d0d2
#pragma inline d0 = SMUL_DIV(d0, d1, d2) { "c1c181c2"; }
 #endif
#endif


void filled_poly(Virtual *vwk, short p[][2], long n, long colour,
                 short *pattern, short *points, long mode, long interior_style)
{
	int i, j;
	short tmp, y;
	short miny, maxy;
	short x1, y1;
	short x2, y2;
	int ints;
	int spans;
	short *coords;
	
	if (!n)
		return;
		
#if 0
	{
	int k;
	char buf[16];
	Cconws("filled_poly: n:");
	Funcs_ltoa(buf, n, 10);
	Cconws(buf);
	for(k=0;k<n;k++)
	{
	Cconws(" ");
	Funcs_ltoa(buf, (long)p[k][0], 10);
	Cconws(buf);
	Cconws(",");
	Funcs_ltoa(buf, (long)p[k][1], 10);
	Cconws(buf);
	}
	Cconws("\r\n");
	}
#endif

	if ((p[0][0] == p[n - 1][0]) && (p[0][1] == p[n - 1][1]))
		n--;

	miny = maxy = p[0][1];
	coords = &p[1][1];
	for(i = 1; i < n; i++) {
#if 0
		y = p[i][1];
#endif
		y = *coords;
		coords += 2;		/* Skip to next y */
		if (y < miny) {
			miny = y;
		}
		if (y > maxy) {
			maxy = y;
		}
	}
	if (vwk->clip.on) {
		if (miny < vwk->clip.rectangle.y1)
			miny = vwk->clip.rectangle.y1;
		if (maxy > vwk->clip.rectangle.y2)
			maxy = vwk->clip.rectangle.y2;
	}

	spans = 0;
	coords = &points[n];

	for(y = miny; y <= maxy; y++) {
		ints = 0;
		x1 = p[n - 1][0];
		y1 = p[n - 1][1];
#if 0
		coords = &p[0][0];
#endif
		for(i = 0; i < n; i++) {
			x2 = p[i][0];
			y2 = p[i][1];
#if 0
			x2 = *coords++;
			y2 = *coords++;
#endif
			if (y1 < y2) {
				if ((y >= y1) && (y < y2)) {
#if 0
					points[ints++] = (long)(y - y1) * (x2 - x1) / (y2 - y1) + x1;
#endif
					points[ints++] = SMUL_DIV((y - y1), (x2 - x1), (y2 - y1)) + x1;
				}
			} else if (y1 > y2) {
				if ((y >= y2) && (y < y1)) {
#if 0
					points[ints++] = (long)(y - y2) * (x1 - x2) / (y1 - y2) + x2;
#endif
					points[ints++] = SMUL_DIV((y - y2), (x1 - x2), (y1 - y2)) + x2;
				}
			}
			x1 = x2;
			y1 = y2;
		}
		
		for(i = 0; i < ints - 1; i++) {
			for(j = i + 1; j < ints; j++) {
				if (points[i] > points[j]) {
					tmp = points[i];
					points[i] = points[j];
					points[j] = tmp;
				}
			}
		}

		if (spans > 1000) {			/* Should really check against size of points array! */
			fill_spans(vwk, &points[n], spans, colour, pattern, mode, interior_style);
			spans = 0;
			coords = &points[n];
		}

		x1 = vwk->clip.rectangle.x1;
		x2 = vwk->clip.rectangle.x2;
		for(i = 0; i < ints - 1; i += 2) {
			y1 = points[i];		/* Really x-values, but... */
			y2 = points[i + 1];
			if (y1 < x1)
				y1 = x1;
			if (y2 > x2)
				y2 = x2;
			if (y1 <= y2) {
				*coords++ = y;
				*coords++ = y1;
				*coords++ = y2;
				spans++;
			}
		}
	}
	if (spans)
		fill_spans(vwk, &points[n], spans, colour, pattern, mode, interior_style);
}

#if 0

#if 0
void filled_poly_m(Virtual *vwk, short p[][2], long n, long colour, short *pattern,
                   short *points, short index[], long moves, long mode, long interior_style)
{
	short movepnt, pos;

	moves--;
	if (index[moves] == -4)
		moves--;
	if (index[moves] == -2)
		moves--;

	pos = 0;
	do {
		movepnt = (index[moves] + 4) / 2;
		filled_poly(vwk, &p[pos], movepnt - pos, colour, pattern, points);
		pos = movepnt;
	} while (--moves >= 0);
	
	if (pos < n)
		filled_poly(vwk, &p[pos], n - pos, colour, pattern, points);
}
#else
void filled_poly_m(Virtual *vwk, short p[][2], long n, long colour, short *pattern,
                   short *points, short index[], long moves, long mode, long interior_style)
{
	int i, j;
	short tmp, y;
	short miny, maxy;
	short x1, y1;
	short x2, y2;
	int ints;
	int spans;
	short *coords;
	short movepnt, move_n;

	if (!n)
		return;

#if 0
	if ((p[0][0] == p[n - 1][0]) && (p[0][1] == p[n - 1][1]))
		n--;
#endif

	moves--;
	if (index[moves] == -4)
		moves--;
	if (index[moves] == -2)
		moves--;
		
	miny = maxy = p[0][1];
	coords = &p[1][1];
	for(i = 1; i < n; i++) {
#if 0
		y = p[i][1];
#endif
		y = *coords;
		coords += 2;		/* Skip to next y */
		if (y < miny) {
			miny = y;
		}
		if (y > maxy) {
			maxy = y;
		}
	}
	if (vwk->clip.on) {
		if (miny < vwk->clip.rectangle.y1)
			miny = vwk->clip.rectangle.y1;
		if (maxy > vwk->clip.rectangle.y2)
			maxy = vwk->clip.rectangle.y2;
	}

	spans = 0;
	coords = &points[n];

	for(y = miny; y <= maxy; y++) {
		move_n = moves;
		movepnt = (index[move_n] + 4) / 2;
		ints = 0;
#if 0
		x1 = p[n - 1][0];
		y1 = p[n - 1][1];
#else
		x2 = p[0][0];
		y2 = p[0][1];
#endif
#if 0
		coords = &p[0][0];
#endif
#if 0
		for(i = 0; i < n; i++) {
#else
		for(i = 1; i < n; i++) {
#endif
			x1 = x2;
			y1 = y2;
			x2 = p[i][0];
			y2 = p[i][1];
			if (i == movepnt) {
				if (--move_n >= 0)
					movepnt = (index[move_n] + 4) / 2;
				else
					movepnt = -1;		/* Never again equal to n */
				continue;
			}
#if 0
			if (!index && (n == length - 1)) {
				table -= length * 2;		/* Back to beginning */
				if ((table[0] != x2) || (table[1] != y2)) {
					n--;					/* An extra point */
					index = (short *)-1;	/* Don't check this 'if' again */
				}
			}
#endif
#if 0
			x2 = *coords++;
			y2 = *coords++;
#endif
			if (y1 < y2) {
				if ((y >= y1) && (y < y2)) {
#if 0
					points[ints++] = (long)(y - y1) * (x2 - x1) / (y2 - y1) + x1;
#endif
					points[ints++] = SMUL_DIV((y - y1), (x2 - x1), (y2 - y1)) + x1;
				}
			} else if (y1 > y2) {
				if ((y >= y2) && (y < y1)) {
#if 0
					points[ints++] = (long)(y - y2) * (x1 - x2) / (y1 - y2) + x2;
#endif
					points[ints++] = SMUL_DIV((y - y2), (x1 - x2), (y1 - y2)) + x2;
				}
			}
#if 0
			x1 = x2;
			y1 = y2;
#endif
		}
		
		for(i = 0; i < ints - 1; i++) {
			for(j = i + 1; j < ints; j++) {
				if (points[i] > points[j]) {
					tmp = points[i];
					points[i] = points[j];
					points[j] = tmp;
				}
			}
		}

		if (spans > 1000) {			/* Should really check against size of points array! */
			fill_spans(vwk, &points[n], spans, colour, pattern, mode, interior_style);
			spans = 0;
			coords = &points[n];
		}

		x1 = vwk->clip.rectangle.x1;
		x2 = vwk->clip.rectangle.x2;
		for(i = 0; i < ints - 1; i += 2) {
			y1 = points[i];		/* Really x-values, but... */
			y2 = points[i + 1];
			if (y1 < x1)
				y1 = x1;
			if (y2 > x2)
				y2 = x2;
			if (y1 <= y2) {
				*coords++ = y;
				*coords++ = y1;
				*coords++ = y2;
				spans++;
			}
		}
	}
	if (spans)
		fill_spans(vwk, &points[n], spans, colour, pattern, mode, interior_style);
}
#endif

#endif
