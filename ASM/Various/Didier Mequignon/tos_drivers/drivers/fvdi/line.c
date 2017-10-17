/*
 * fVDI line code
 *
 * $Id: line.c,v 1.4 2004/10/17 17:52:55 johan Exp $
 *
 * Copyright 1999/2001-2003, Johan Klockars 
 * This software is licensed under the GNU General Public License.
 * Please, see LICENSE.TXT for further information.
 *
 * The wide line parts are extracted and modified from code with an
 * original copyright as follows.
 */

/*************************************************************************
**       Copyright 1999, Caldera Thin Clients, Inc.                     ** 
**       This software is licenced under the GNU Public License.        **
**       Please see LICENSE.TXT for further information.                ** 
**                                                                      ** 
**                  Historical Copyright                                ** 
**                                                                      **
**  Copyright (c) 1987, Digital Research, Inc. All Rights Reserved.     **
**  The Software Code contained in this listing is proprietary to       **
**  Digital Research, Inc., Monterey, California and is covered by U.S. **
**  and other copyright protection.  Unauthorized copying, adaptation,  **
**  distribution, use or display is prohibited and may be subject to    **
**  civil and criminal penalties.  Disclosure to others is prohibited.  **
**  For the terms and conditions of software code use refer to the      **
**  appropriate Digital Research License Agreement.                     **
**                                                                      **
**************************************************************************/

#include "fvdi.h"
#include "function.h"
#include "utility.h"
#include <mint/osbind.h>

#define MAX_L_WIDTH	32
#define X_ASPECT 1
#define Y_ASPECT 1

#define SQUARED 0
#define ARROWED 1

#if 1
#ifdef COLDFIRE
extern short SMUL_DIV(short x, short y, short z);
#else
#define SMUL_DIV(x,y,z)	((short)(((short)(x)*(long)((short)(y)))/(short)(z)))
#endif
#else
int SMUL_DIV(int, int, int);   //   d0d1d0d2
#pragma inline d0 = SMUL_DIV(d0, d1, d2) { "c1c181c2"; }
#endif


/* m_dot, m_plus, m_star, m_square, m_cross, m_dmnd */
static signed char row1[] = { 1, 2, 0, 0, 0, 0 };
static signed char row2[] = { 2, 2, 0, -3, 0, 3, 2, -4, 0, 4, 0 };
static signed char row3[] = { 3, 2, 0, -3, 0, 3, 2, 3, 2, -3, -2, 2, 3, -2, -3, 2};
static signed char row4[] = { 1, 5, -4, -3, 4, -3, 4, 3, -4, 3, -4, -3}; 
static signed char row5[] = { 2, 2, -4, -3, 4, 3, 2, -4, 3, 4, -3 };
static signed char row6[] = { 1, 5, -4, 0, 0, -3, 4, 0, 0, 3, -4, 0 };
static signed char *marker[] = {row1, row2, row3, row4, row5, row6};

extern short solid;

#if 1
void do_circ(Virtual *vwk, short *points, int cx, int cy, int num_qc_lines, short *q_circle, long colour, long mode)
{
	int k, x1, y1, x2, y2, vx=1, vy=1;

	/* Only perform the act if the circle has radius. */
	if (num_qc_lines > 0) {
		/* Do the horizontal line through the center of the circle. */
		x1 = cx - q_circle[0];
		y1 = cy;
		x2 = cx + q_circle[0];
		y2 = cy;
		points[0] = x1 + vx;
		points[1] = y1 + vy;
		points[2] = x1 - vx;
		points[3] = y1 - vy;
		points[4] = x2 - vx;
		points[5] = y2 - vy;
		points[6] = x2 + vx;
		points[7] = y2 + vy;
		fill_poly(vwk, points, 4, colour, &solid, &points[8], mode, 0x00010000L);
		/* Do the upper and lower semi-circles. */
		for(k = 1; k < num_qc_lines; k++) {
			/* Upper semi-circle. */
			x1 = cx - q_circle[k];
			y1 = cy - k;
			x2 = cx + q_circle[k];
			y2 = cy - k;
			points[0] = x1 + vx;
			points[1] = y1 + vy;
			points[2] = x1 - vx;
			points[3] = y1 - vy;
			points[4] = x2 - vx;
			points[5] = y2 - vy;
			points[6] = x2 + vx;
			points[7] = y2 + vy;
			fill_poly(vwk, points, 4, colour, &solid, &points[8], mode, 0x00010000L);
			/* Lower semi-circle. */
			x1 = cx - q_circle[k];
			y1 = cy + k;
			x2 = cx + q_circle[k];
			y2 = cy + k;
			points[0] = x1 + vx;
			points[1] = y1 + vy;
			points[2] = x1 - vx;
			points[3] = y1 - vy;
			points[4] = x2 - vx;
			points[5] = y2 - vy;
			points[6] = x2 + vx;
			points[7] = y2 + vy;
			fill_poly(vwk, points, 4, colour, &solid, &points[8], mode, 0x00010000L);
		}
	}
}
#endif


int wide_setup(Virtual *vwk, int width, short *q_circle)
{
	int i, j, x, y, d, low, high;
	int xsize, ysize;
	int num_qc_lines;

	/* Limit the requested line width to a reasonable value. */

	if (width < 1)
		width = 1;
	else if (width > MAX_L_WIDTH)
		width = MAX_L_WIDTH;

	/* Make the line width an odd number (one less, if even). */

	width = (width - 1) | 1;

	/* Set the line width internals and the return parameters.  
	 * Return if the line width is being set to one.
	 */
#if 0
	if ((line_qw = width) == 1)
#else
	if (width == 1)
#endif
		return 0;

	/* Initialize the circle DDA.  "y" is set to the radius. */

	x = 0;
	y = (width + 1) / 2;
	d = 3 - 2 * y;

#if Y_ASPECT >= X_ASPECT
	for(i = 0; i < MAX_L_WIDTH; i++) {
		q_circle[i] = 0 ;
	}
#else
	for(i = 0; i < ((MAX_L_WIDTH * X_ASPECT / Y_ASPECT) / 2 + 1); i++) {
		 q_circle[i] = 0 ;
	}
#endif

	/* Do an octant, starting at north.  
	 * The values for the next octant (clockwise) will
	 * be filled by transposing x and y.
	 */
	while (x < y) {
		q_circle[y] = x;
		q_circle[x] = y;

		if (d < 0) {
			d = d + (4 * x) + 6;
		} else {
			d = d + (4 * (x - y)) + 10;
			y--;
		}
		x++;
	}

	if (x == y)
		q_circle[x] = x;

	 /* Calculate the number of vertical pixels required. */

	xsize = vwk->real_address->screen.pixel.width;
	ysize = vwk->real_address->screen.pixel.height;
	num_qc_lines = (width * xsize / ysize) / 2 + 1;

	/* Fake a pixel averaging when converting to 
	 * non-1:1 aspect ratio.
	 */

#if Y_ASPECT > X_ASPECT
	low = 0;
	for(i = 0; i < num_qc_lines; i++) {
		high = ((2 * i + 1) * ysize / xsize) / 2;
		d = 0;

		for (j = low; j <= high; j++) {
			d += q_circle[j];
		}

		q_circle[i] = d / (high - low + 1);
		low = high + 1;
	} 
#else
	if(low);
	if(high);
	if(j);
	for(i = num_qc_lines - 1; i >= 0; i--) {
		q_circle[i] = q_circle[(2 * i * ysize / xsize + 1) / 2];
	}
#endif

	return num_qc_lines;
}

void quad_xform(int quad, int x, int y, int *tx, int *ty)
{
	if (quad & 2)
		*tx = -x;		/* 2, 3 */
	else
		*tx = x;		/* 1, 4 */

	if (quad > 2)
		*ty = -y;		/* 3, 4 */
	else
		*ty = y;		/* 1, 2 */
}


void perp_off(int *vx, int *vy, short *q_circle, int num_qc_lines)
{
	int x, y, u, v, quad, magnitude, min_val, x_val, y_val;

	/* Mirror transform the vector so that it is in the first quadrant. */
	if (*vx >= 0)
		quad = (*vy >= 0) ? 1 : 4;
	else
		quad = (*vy >= 0) ? 2 : 3;

	quad_xform(quad, *vx, *vy, &x, &y);

	/* Traverse the circle in a dda-like manner and find the coordinate pair
	 * (u, v) such that the magnitude of (u*y - v*x) is minimized.  In case of
	 * a tie, choose the value which causes (u - v) to be minimized.  If not
	 * possible, do something.
	 */
	min_val = 32767;
	x_val = u = q_circle[0];		/* x_val/y_val new here */
	y_val = v = 0;
	while (1) {
		/* Check for new minimum, same minimum, or finished. */
		if (((magnitude = ABS(u * y - v * x)) < min_val ) ||
		    ((magnitude == min_val) && (ABS(x_val - y_val) > ABS(u - v)))) {
			min_val = magnitude;
			x_val = u;
			y_val = v;
		} else
			break;

		/* Step to the next pixel. */
		if (v == num_qc_lines - 1) {
			if (u == 1)
				break;
			else
				u--;
		} else {
			if (q_circle[v + 1] >= u - 1) {
				v++;
				u = q_circle[v];
			} else {
				u--;
			}
		}
	}

	/* Transform the solution according to the quadrant. */
	quad_xform(quad, x_val, y_val, vx, vy);
}


void wide_line(Virtual *vwk, short *pts, long numpts, long colour, short *points, long mode)
{
	int i, j, k;
	int wx1, wy1, wx2, wy2, vx, vy;
#if 0
# if Y_ASPECT >= X_ASPECT
	short q_circle[MAX_L_WIDTH];
# else
	short q_circle[(MAX_L_WIDTH * X_ASPECT / Y_ASPECT) / 2 + 1];
# endif
#else
	short *q_circle;
#endif
	int num_qc_lines;
	int xsize, ysize;

	/* Don't attempt wide lining on a degenerate polyline. */
	if (numpts < 2)
		return;

	q_circle = points;
#if Y_ASPECT >= X_ASPECT
	points += MAX_L_WIDTH;
#else
	points += (MAX_L_WIDTH * X_ASPECT / Y_ASPECT) / 2 + 1;
#endif

	num_qc_lines = wide_setup(vwk, vwk->line.width, q_circle);

	/* If the ends are arrowed, output them. */
	if ((vwk->line.ends.beginning | vwk->line.ends.end) & ARROWED)
		do_arrow(vwk, pts, numpts, colour, points, mode);

	/* Initialize the starting point for the loop. */
	j = 0;
	wx1 = pts[j++];
	wy1 = pts[j++];

#if 1
	/* If the end style for the first point is not squared, output a circle. */
	if (vwk->line.ends.beginning != SQUARED)
		do_circ(vwk, points, wx1, wy1, num_qc_lines, q_circle, colour, mode);
#endif

	/* Loop over the number of points passed in. */
	for(i = 1; i < numpts; i++) {
		/* Get the ending point for the line segment and the vector from the
		 * start to the end of the segment.
		 */
		wx2 = pts[j++];
		wy2 = pts[j++];  

		vx = wx2 - wx1;
		vy = wy2 - wy1;

		/* Ignore lines of zero length. */
		if ((vx == 0) && (vy == 0))
			continue;

		/* Calculate offsets to fatten the line.  If the line segment is
		 * horizontal or vertical, do it the simple way.
		 */
		if (vx == 0) {
			vx = q_circle[0];
			vy = 0;
		} else if (vy == 0) {
			vx = 0;
			vy = num_qc_lines - 1;
		} else {
			/* Find the offsets in x and y for a point perpendicular to the line
			 * segment at the appropriate distance.
			 */

			xsize = vwk->real_address->screen.pixel.width;
			ysize = vwk->real_address->screen.pixel.height;

			k = SMUL_DIV(-vy, ysize, xsize);
			vy = SMUL_DIV(vx, xsize, ysize);
			vx = k;
			perp_off(&vx, &vy, q_circle, num_qc_lines);
		}

		/* Prepare the points parameters for the polygon call. */
		points[0] = wx1 + vx;
		points[1] = wy1 + vy;
		points[2] = wx1 - vx;
		points[3] = wy1 - vy;
		points[4] = wx2 - vx;
		points[5] = wy2 - vy;
		points[6] = wx2 + vx;
		points[7] = wy2 + vy;
		fill_poly(vwk, points, 4, colour, &solid, &points[8], mode, 0x00010000L);

#if 1
		/* If the terminal point of the line segment is an internal joint,
		 * or the end style is not squared, output a filled circle.
		 */
		if ((vwk->line.ends.end != SQUARED) || (i < numpts - 1))
			do_circ(vwk, points, wx2, wy2, num_qc_lines, q_circle, colour, mode);
#endif

		/* The line segment end point becomes the starting point for the next
		 * line segment.
		 */
		wx1 = wx2;
		wy1 = wy2;
	}
}


static void
draw_line(int x1, int y1, int x2, int y2, int w, char* addr)
{
  unsigned int pos = (short)y1 * (short)w + x1;
  int count;
  int one_step, both_step;
  int d, incrE, incrNE;
  int dx, dy;
  int x_step = 1;
  int y_step = w;

  dx = x2 - x1;
  if (dx < 0) {
    dx = -dx;
    x_step = -x_step;
  }

  dy = y2 - y1;
  if (dy < 0) {
    dy = -dy;
    y_step = -y_step;
  }

  if (dx > dy) {
    count = dx;
    one_step = x_step;
    both_step = y_step;
    incrE = 2 * dy;
    incrNE = -2 * dx;
    d = -dx;
  } else {
    count = dy;
    one_step = y_step;
    both_step = x_step;
    incrE = 2 * dx;
    incrNE = -2 * dy;
    d = -dy;
  }

  for(; count >= 0; count--) {
    addr[pos / 8] |= 1 << (7 - pos % 8);
    d += incrE;
    if (d >= 0) {
      d += incrNE;
      pos += both_step;
    }
    pos += one_step;
  }
}


void
pmarker(int type, int size, int w_in, int h_in, char *buf)
{
  short i, j, num_lines;
  int x_center, y_center;
  int num_points;
  signed char *m_ptr;
  int w, h;
  signed char nwidth[5], width[5], nheight[5], height[5];
  short tmp;
  int x1, y1, x2, y2;

  for(i = 0; i <= 4; i++) {
    if (!w_in) {
#if 0
      tmp = (short)((short)(((short)size * 30 + 11) / 22) * i * 4 + 15) / 30 + 1;
#else
      tmp = (short)((short)size * i * 4 + 11) / 22 + 1;
#endif
    } else
      tmp = ((short)w_in * i + 2) / 4;
    nwidth[i] = -(tmp / 2);
    width[i] = tmp + nwidth[i] - 1;
    if (!h_in)
      tmp = (short)((short)size * i * 4 + 11) / 22 + 1;
    else
      tmp = (short)((short)h_in * i * 2 + 3) / 6;
    nheight[i] = -(tmp / 2);
    height[i] = tmp + nheight[i] - 1;
  }

  w = width[4] - nwidth[4] + 1;
  h = height[3] - nheight[3] + 1;
  x_center = w / 2;
  y_center = h / 2;

  m_ptr = marker[type];
  num_lines = *m_ptr++;
  x1 = y1 = 0;    /* To make the compiler happy */
  for(i = 0; i < num_lines; i++) {
    num_points = *m_ptr++;
    for(j = 0; j < num_points; j++) {
      x2 = *m_ptr++;
      y2 = *m_ptr++;

      if (x2 <= 0)
        x2 = nwidth[-x2] + x_center;
      else
        x2 = width[x2] + x_center;
      if (y2 <= 0)
        y2 = nheight[-y2] + y_center;
      else
        y2 = height[y2] + y_center;

      if (j > 0)
        draw_line(x1, y1, x2, y2, w, buf);

      x1 = x2;
      y1 = y2;
    }
  }
}


void arrow(Virtual *vwk, short *xy, short inc, int numpts, int colour, short *points, long mode)
{
	short i, arrow_len, arrow_wid, line_len;
	short *xybeg;
	short dx, dy;
	short base_x, base_y, ht_x, ht_y;
	long arrow_len2, line_len2;
	int xsize, ysize;

	dx=dy=0;
	line_len2=0;
	
	xsize = vwk->real_address->screen.pixel.width;
	ysize = vwk->real_address->screen.pixel.height;

	/* Set up the arrow-head length and width as a function of line width. */
	if (vwk->line.width == 1)
		arrow_len = 8;
	else
		arrow_len = 3 * vwk->line.width - 1;
	arrow_len2 = arrow_len * arrow_len;
	arrow_wid = arrow_len / 2;

	/* Initialize the beginning pointer. */
	xybeg = xy;

	/* Find the first point which is not so close to the end point that it
	 * will be obscured by the arrowhead.
	 */
	for(i = 1; i < numpts; i++) {
		/* Find the deltas between the next point and the end point.
		 * Transform to a space such that the aspect ratio is uniform
		 * and the x axis distance is preserved.
		 */
		xybeg += inc;
		dx = *xy - *xybeg;
		dy = SMUL_DIV(*(xy + 1) - *(xybeg + 1), ysize, xsize);

		/* Get the length of the vector connecting the point with the end point.
		 * If the vector is of sufficient length, the search is over.
		 */
#if 0
		if ((line_len = vec_len(ABS(dx), ABS(dy))) >= arrow_len)
#else
		line_len2 = (long)dx * dx + (long)dy * dy;
		if (line_len2 >= arrow_len2)
#endif
			break;
	}

	/* If the longest vector is insufficiently long, don't draw an arrow. */
#if 0
	if (line_len < arrow_len)
#else
	if (line_len2 < arrow_len2)
#endif
		return;

	line_len = isqrt(line_len2);
	
	/* Rotate the arrow-head height and base vectors.
	 * Perform calculations in 1000x space.
	 */
	ht_x = SMUL_DIV(arrow_len, SMUL_DIV(dx, 1000, line_len), 1000);
	ht_y = SMUL_DIV(arrow_len, SMUL_DIV(dy, 1000, line_len), 1000);
	base_x = SMUL_DIV(arrow_wid, SMUL_DIV(dy, -1000, line_len), 1000);
	base_y = SMUL_DIV(arrow_wid, SMUL_DIV(dx, 1000, line_len), 1000);

	/* Transform the y offsets back to the correct aspect ratio space. */
	ht_y = SMUL_DIV(ht_y, xsize, ysize);
	base_y = SMUL_DIV(base_y, xsize, ysize);

	/* Build a polygon to send to plygn.  Build into a local array
	 * first since xy will probably be pointing to the PTSIN array.
	 */
	points[0] = *xy + base_x - ht_x;
	points[1] = *(xy + 1) + base_y - ht_y;
	points[2] = *xy - base_x - ht_x;
	points[3] = *(xy + 1) - base_y - ht_y;
	points[4] = *xy;
	points[5] = *(xy + 1);
	fill_poly(vwk, points, 3, colour, &solid, &points[6], mode, 0x00010000L);

	/* Adjust the end point and all points skipped. */
	*xy -= ht_x;
	*(xy + 1) -= ht_y;
	while ((xybeg -= inc) != xy) {
		*xybeg = *xy;
		*(xybeg + 1) = *(xy + 1);
	}
}


void do_arrow(Virtual *vwk, short *pts, int numpts, int colour, short *points, long mode)
{
	short x_start, y_start, new_x_start, new_y_start;

	/* Function "arrow" will alter the end of the line segment.
	 * Save the starting point of the polyline in case two calls to "arrow"
	 * are necessary.
	 */
	new_x_start = x_start = pts[0];
	new_y_start = y_start = pts[1];

	if (vwk->line.ends.beginning & ARROWED) {
		arrow(vwk, &pts[0], 2, numpts, colour, points, mode);
		new_x_start = pts[0];
		new_y_start = pts[1];
	}

	if (vwk->line.ends.end & ARROWED) {
		pts[0] = x_start;
		pts[1] = y_start;
		arrow(vwk, &pts[2 * numpts - 2], -2, numpts, colour, points, mode);
		pts[0] = new_x_start;
		pts[1] = new_y_start;
	}
}


