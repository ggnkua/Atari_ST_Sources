#include "chart.h"
#include <stdio.h>

/* -- some private functions and structures used by public functions below -- */

/* Clear given area of screen */
void clear_area (int app_handle, int x, int y, int w, int h) {
	int pxy[4];

	vsf_interior (app_handle, SOLID);
	vsf_color (app_handle, WHITE);
	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + w - 1;
	pxy[3] = y + h - 1;
	vr_recfl (app_handle, pxy);
}

/* scale given point within min/max range to a point in screen of size 'size' */
int rescale (int pt, int min, int max, int size) {
	int range = max-min;
	int num = (pt-min) / range;
	int den = (pt-min) % range;

	return size*num + (int)((long)size*den/range);
}

/* Calculate dimensions of interior chart region, allowing for
   axes and title */
void find_chart_dimensions (int app_handle, int min_y_value, int max_y_value, int x, int y, int w, int h,
	int * max_value_width, int * bx, int * by, int * bw, int * bh) {
	char str[20];
	int title_w, title_h, axis_title_w, axis_title_h, axis_label_w, axis_label_h, dum;

	/* find dimension of title_font */
	vst_point (app_handle, TITLE_FONT, &dum, &dum, &title_w, &title_h);
	vst_point (app_handle, AXES_TITLE_FONT, &dum, &dum, &axis_title_w, &axis_title_h);
	vst_point (app_handle, AXES_LABEL_FONT, &dum, &dum, &axis_label_w, &axis_label_h);

	sprintf (str, "%d", max_y_value);
	*max_value_width = strlen(str);
	sprintf (str, "%d", min_y_value);
	if (strlen(str) > *max_value_width) {
		*max_value_width = strlen (str);
	}
	*bx = x + *max_value_width * axis_label_w + 2*axis_title_h; /* allow twice height of label + size of max_value chars on left */
	*bw = w - *max_value_width * axis_label_w - 3*axis_title_h; /* allow extra label height on right */
	*by = y + h - 2*axis_title_h - 2*axis_label_h; /* allow space for labels and axis title */
	*bh = h - 2*title_h - 2*axis_title_h - 2*axis_label_h;     /* allow extra 2 chars above, for title */
}

/* Draw the two lines for the axes */
void draw_axes_lines (int app_handle, int x, int y, int w, int h) {
	int axes[6];

	vsl_color (app_handle, BLACK);
	vsl_type (app_handle, SOLID);
	vsl_width (app_handle, 1);

	axes[0] = x; axes[1] = y-h;
	axes[2] = x; axes[3] = y;
	axes[4] = x+w; axes[5] = y;

	v_pline (app_handle, 3, axes);
}

void draw_main_labels (int app_handle, char * title, char * x_label, char * y_label,
	int x, int y, int w, int h, int y_value_width) {

	int offset;
	int char_w, char_h, cell_w, cell_h;

	vsf_color (app_handle, BLACK);
	vst_point (app_handle, TITLE_FONT, &char_w, &char_h, &cell_w, &cell_h);

	offset = cell_w * (w/cell_w - strlen(title))/2;
	if (offset < 0) offset = 0;
	v_gtext (app_handle, x + offset, y-h-cell_h, title);

	vst_point (app_handle, AXES_TITLE_FONT, &char_w, &char_h, &cell_w, &cell_h);

	offset = cell_w * (w/cell_w - strlen(x_label))/2;
	if (offset < 0) offset = 0;
	v_gtext (app_handle, x + offset, y+2*cell_h, x_label);

	offset = cell_h * (h/cell_h - strlen(y_label))/2;
	if (offset < 0) offset = 0;
	vst_rotation (app_handle, 900);
	v_gtext (app_handle, x-(y_value_width+1)*cell_w, y-offset, y_label);
	vst_rotation (app_handle, 0);
}

/* display numeric range and tick marks of x-axis */
void draw_x_axis_labels (int app_handle, int min_x, int max_x, int x, int y, int w) {
	char str[20];
	int pxy[4];
	int i;
	int char_w, char_h, cell_w, cell_h;
	int range = max_x - min_x;
	int largest_val;

	sprintf (str, "%d", min_x);
	largest_val = strlen (str);
	sprintf (str, "%d", max_x);
	if (strlen(str) > largest_val) largest_val = strlen(str);

	vsf_color (app_handle, BLACK);
	vst_point (app_handle, AXES_LABEL_FONT, &char_w, &char_h, &cell_w, &cell_h);
	vsl_width (app_handle, 1);

	/* print values on x-axis, depending on space available */
	if (w > largest_val * 2 * cell_w) { /* print left and right values in most cases */
		pxy[0] = x;
		pxy[1] = y;
		pxy[2] = pxy[0];
		pxy[3] = y+5;

		v_pline (app_handle, 2, pxy);
		sprintf (str, "%d", min_x);
		v_gtext (app_handle, pxy[2]-strlen(str)*cell_w/2, pxy[3]+cell_h*15/10, str);

		pxy[0] = x+w;
		pxy[1] = y;
		pxy[2] = pxy[0];
		pxy[3] = y+5;

		v_pline (app_handle, 2, pxy);
		sprintf (str, "%d", max_x);
		v_gtext (app_handle, pxy[2]-strlen(str)*cell_w/2, pxy[3]+cell_h*15/10, str);
	}

	if (w > largest_val * 10 * cell_w) { /* print remaining depending on space available */
		int i;

		for (i=1; i<=8; i += 1) {
			int val = min_x + range * i / 8; /* do eighths */

			pxy[0] = x + rescale (val, min_x, max_x, w);
			pxy[1] = y;
			pxy[2] = pxy[0];
			pxy[3] = y+5;

			sprintf (str, "%d", val);
			v_pline (app_handle, 2, pxy);
			v_gtext (app_handle, pxy[2]-strlen(str)*cell_w/2, pxy[3]+cell_h*15/10, str);
		}
	} else if (w > largest_val * 6 * cell_w) {
		int i;

		for (i=1; i<=3; i += 1) {
			int val = min_x + range * i / 4; /* do quarters */

			pxy[0] = x + rescale (val, min_x, max_x, w);
			pxy[1] = y;
			pxy[2] = pxy[0];
			pxy[3] = y+5;

			sprintf (str, "%d", val);
			v_pline (app_handle, 2, pxy);
			v_gtext (app_handle, pxy[2]-strlen(str)*cell_w/2, pxy[3]+cell_h*15/10, str);
		}
	} else if (w > largest_val * 4 * cell_w) {
		int val = min_x + range / 2; /* find nearest int to half-way */

		pxy[0] = x + rescale (val, min_x, max_x, w);
		pxy[1] = y;
		pxy[2] = pxy[0];
		pxy[3] = y+5;

		sprintf (str, "%d", val);
		v_pline (app_handle, 2, pxy);
		v_gtext (app_handle, pxy[2]-strlen(str)*cell_w/2, pxy[3]+cell_h*15/10, str);
	}
}

/* draw the specified number of intermediate y labels, equally spaced */
void draw_intermediate_y_labels (int app_handle, int number, int min_y, int max_y, int x, int y, int h, cell_w, cell_h) {
	int i;
	int pxy[4];
	char str[20];

	for (i=1; i<=number; i += 1) {
		int val = min_y + (max_y-min_y) * i / number;

		pxy[0] = x;
		pxy[1] = y - rescale (val, min_y, max_y, h);
		pxy[2] = x-5;
		pxy[3] = pxy[1];

		sprintf (str, "%d", val);
		v_pline (app_handle, 2, pxy);
		v_gtext (app_handle, pxy[2]-strlen(str)*cell_w, pxy[3]+cell_h/2, str);
	}
}

/* display numeric range and tick marks of y-axis */
void draw_y_axis_labels (int app_handle, int min_y, int max_y, int x, int y, int h) {
	char str[20];
	int pxy[4];
	int i;
	int char_w, char_h, cell_w, cell_h;
	int range = max_y - min_y;

	vsf_color (app_handle, BLACK);
	vst_point (app_handle, AXES_LABEL_FONT, &char_w, &char_h, &cell_w, &cell_h);
	vsl_width (app_handle, 1);

	/* print 2,3,5 or 9 values on y-axis, depending on space available */
	if (h > 3 * cell_h) { /* print lower and top values in most cases */
		pxy[0] = x;
		pxy[1] = y;
		pxy[2] = x-5;
		pxy[3] = y;

		v_pline (app_handle, 2, pxy);
		sprintf (str, "%d", min_y);
		v_gtext (app_handle, pxy[2]-strlen(str)*cell_w, pxy[3]+cell_h/2, str);

		pxy[0] = x;
		pxy[1] = y-h;
		pxy[2] = x-5;
		pxy[3] = pxy[1];

		sprintf (str, "%d", max_y);
		v_pline (app_handle, 2, pxy);
		v_gtext (app_handle, pxy[2]-strlen(str)*cell_w, pxy[3]+cell_h/2, str);
	}

	if (h > 10 * cell_h) { /* print remaining labels depending on space available */
		draw_intermediate_y_labels (app_handle, 8, min_y, max_y, x, y, h, cell_w, cell_h);
	} else if (h > 6 * cell_h) {
		draw_intermediate_y_labels (app_handle, 4, min_y, max_y, x, y, h, cell_w, cell_h);
	} else if (h > 4 * cell_h) {
		draw_intermediate_y_labels (app_handle, 2, min_y, max_y, x, y, h, cell_w, cell_h);
	}
}

/* Find the maximum value in an array of ints */
int find_max (int values[], int n) {
	int result, i;

	result = values[0];

	for (i = 1; i < n; i += 1) {
		if (values[i] > result) {
			result = values[i];
		}
	}

	return result;
}

/* Find the minimum value in an array of ints */
int find_min (int values[], int n) {
	int result, i;

	result = values[0];

	for (i = 1; i < n; i += 1) {
		if (values[i] < result) {
			result = values[i];
		}
	}

	return result;
}

/* draw the given set of points using a mark:
   this replaces v_pmarker, which is not implemented in fVDI on the Firebee

   1 = dot, 2 = plus, 3 = star, 4 = square, 5 = cross, 6 = diamond

   Note: only 3-pt size used here.  Not adjustable in line-chart.
   vsm_height can alter the size, for the built in pmarker.
 */
void my_pmarker (int app_handle, int point_style, int num_points, int * points) {
	int i;
	int s = 3; /* size of graphic to draw */

	/* ensure line style solid */
	vsl_type (app_handle, SOLID);

	for (i = 0; i < num_points; i += 1) {
		int x = points[2*i];
		int y = points[2*i+1];
		int pxy[10];

		switch (point_style) {
			case 1: /* dot */
				v_circle (app_handle, x, y, 1);
				break;

			case 2: /* plus */
				pxy[0] = x;
				pxy[1] = y-s;
				pxy[2] = x;
				pxy[3] = y+s;
				v_pline (app_handle, 2, pxy);
				pxy[0] = x-s;
				pxy[1] = y;
				pxy[2] = x+s;
				pxy[3] = y;
				v_pline (app_handle, 2, pxy);
				break;

			case 3: /* star */
				pxy[0] = x;
				pxy[1] = y-s;
				pxy[2] = x;
				pxy[3] = y+s;
				v_pline (app_handle, 2, pxy);
				pxy[0] = x-s;
				pxy[1] = y;
				pxy[2] = x+s;
				pxy[3] = y;
				v_pline (app_handle, 2, pxy);
				pxy[0] = x-s;
				pxy[1] = y-s;
				pxy[2] = x+s;
				pxy[3] = y+s;
				v_pline (app_handle, 2, pxy);
				pxy[0] = x+s;
				pxy[1] = y-s;
				pxy[2] = x-s;
				pxy[3] = y+s;
				v_pline (app_handle, 2, pxy);
				break;

			case 4: /* square */
				pxy[0] = x-s;
				pxy[1] = y-s;
				pxy[2] = x+s;
				pxy[3] = y-s;
				pxy[4] = x+s;
				pxy[5] = y+s;
				pxy[6] = x-s;
				pxy[7] = y+s;
				pxy[8] = x-s;
				pxy[9] = y-s;
				v_pline (app_handle, 5, pxy);
				break;

			case 5: /* cross */
				pxy[0] = x-s;
				pxy[1] = y-s;
				pxy[2] = x+s;
				pxy[3] = y+s;
				v_pline (app_handle, 2, pxy);
				pxy[0] = x+s;
				pxy[1] = y-s;
				pxy[2] = x-s;
				pxy[3] = y+s;
				v_pline (app_handle, 2, pxy);
				break;

			case 6: /* diamond */
				pxy[0] = x;
				pxy[1] = y-s;
				pxy[2] = x-s;
				pxy[3] = y;
				pxy[4] = x;
				pxy[5] = y+s;
				pxy[6] = x+s;
				pxy[7] = y;
				pxy[8] = x;
				pxy[9] = y-s;
				v_pline (app_handle, 5, pxy);
				break;
		}
	}
}

/* ************************ Bar Charts ************************ */

struct bar_chart * chart_make_bar (char * title,
	char * x_label, char * y_label,
	int num_bars, int values[]) {

	int i;
	struct bar_chart * bc = malloc (sizeof(struct bar_chart));

	bc->title = strdup (title);
	bc->x_label = strdup (x_label);
	bc->y_label = strdup (y_label);
	bc->num_bars = num_bars;
	bc->values = malloc (sizeof(int)*num_bars);
	bc->labels = malloc (sizeof(char *)*num_bars);
	bc->colours = malloc (sizeof(int)*num_bars);
	bc->interior = malloc (sizeof(int)*num_bars);
	bc->style = malloc (sizeof(int)*num_bars);

	for (i=0; i<num_bars; i += 1) {
		bc->values[i] = (values[i]>=0 ? values[i] : -values[i]);
		bc->labels[i] = strdup (" ");
		bc->labels[i][0] = i+'1'; /* set label to index number */
		bc->colours[i] = BLUE;
		bc->interior[i] = 2;
		bc->style[i] = 1;
	}

	return bc;
}

void chart_set_bar_x_label (struct bar_chart * bc, int bar_number, char * label) {
	if ((bar_number < 0) || (bar_number >= bc->num_bars)) return;

	free (bc->labels[bar_number]);
	bc->labels[bar_number] = strdup (label);
}

void chart_set_bar_colour (struct bar_chart * bc, int bar_number, int colour) {
	if ((bar_number < 0) || (bar_number >= bc->num_bars)) return;

	bc->colours[bar_number] = colour;
}

void chart_set_bar_style (struct bar_chart * bc, int bar_number, int interior, int style) {
	if ((bar_number < 0) || (bar_number >= bc->num_bars)) return;

	bc->interior[bar_number] = interior;
	bc->style[bar_number] = style;
}

void chart_draw_bar (struct bar_chart * bc, int app_handle, int x, int y, int w, int h) {
	int pxy[4];
	int i, curr_x, curr_y;
	int scale_x_num, scale_x_den, scale_y_num, scale_y_den;
	int max_value, max_value_width, bar_chars, offset;
	char str[20]; /* numbers won't be larger than 20 */
	int bx, by, bw, bh; /* dimensions for bar chart */
	int char_w, char_h, cell_w, cell_h;

	clear_area (app_handle, x, y, w, h);
	if ((w < 50) || (h < 50)) return; /* too small to draw anything */

	max_value = find_max (bc->values, bc->num_bars);

	/* Find dimensions for display of bar chart */
	find_chart_dimensions (app_handle, 0, max_value, x, y, w, h, &max_value_width, &bx, &by, &bw, &bh);

	scale_x_num = bw/bc->num_bars;
	scale_x_den = bw%bc->num_bars;
	scale_y_num = bh/max_value;
	scale_y_den = bh%max_value;

	draw_axes_lines (app_handle, bx, by, bw, bh);
	draw_main_labels (app_handle, bc->title, bc->x_label, bc->y_label,
		bx, by, bw, bh, max_value_width);

	vsf_color (app_handle, BLACK);
	vst_point (app_handle, AXES_LABEL_FONT, &char_w, &char_h, &cell_w, &cell_h);
	vsl_width (app_handle, 1);
	bar_chars = scale_x_num / cell_w; /* the number of chars that will fit in a bar */

	for (i = 0; i < bc->num_bars; i += 1) {
		pxy[0] = bx + i*scale_x_num+(i*scale_x_den)/bc->num_bars + scale_x_num/2;
		pxy[1] = by;
		pxy[2] = pxy[0];
		pxy[3] = by+5;

		v_pline (app_handle, 2, pxy);

		if (strlen (bc->labels[i]) < bar_chars) {
			/* label fits, so center and display */
			int offset = cell_w * (bar_chars - strlen (bc->labels[i]))/2;
			v_gtext (app_handle, pxy[0]-scale_x_num/2+cell_w/2+offset, pxy[3]+15*cell_h/10, bc->labels[i]);
		} else {
			/* label will not fit, so take only first part */
			int j;

			for (j=0; j<bar_chars; j+=1) {
				str[j] = bc->labels[i][j];
			}
			str[bar_chars]=0;
			v_gtext (app_handle, pxy[0]-scale_x_num/2+cell_w/2, pxy[3]+15*cell_h/10, str);
		}
	}
	draw_y_axis_labels (app_handle, 0, max_value, bx, by, bh);

	/* draw the bars */
	for (i = 0; i < bc->num_bars; i += 1) {
		vsf_color (app_handle, bc->colours[i]);
		vsf_interior (app_handle, bc->interior[i]);
		vsf_style (app_handle, bc->style[i]);

		pxy[0] = bx + i*scale_x_num + (i*scale_x_den)/bc->num_bars + 1;
		pxy[1] = by-1;
		pxy[2] = bx + (i+1)*scale_x_num+((i+1)*scale_x_den)/bc->num_bars;
		pxy[3] = by - bc->values[i]*scale_y_num-(bc->values[i]*scale_y_den)/max_value;

		v_bar (app_handle, pxy);
	}

}

void free_bar (struct bar_chart * bc) {
	int i;

	free (bc->title);
	free (bc->x_label);
	free (bc->y_label);
	free (bc->values);
	for (i=0; i<bc->num_bars; i+= 1) {
		free (bc->labels[i]);
	}
	free (bc->labels);
	free (bc->colours);
	free (bc->interior);
	free (bc->style);
	free (bc);
}

/* ************************ Line Charts *********************** */

struct line_chart * chart_make_line (char * title,
	char * x_label, char * y_label,
	int num_lines) {

	int i;
	struct line_chart * lc = malloc (sizeof(struct line_chart));

	lc->title = strdup(title);
	lc->x_label = strdup (x_label);
	lc->y_label = strdup (y_label);
	lc->num_lines = num_lines;
	lc->lines = malloc(sizeof(struct a_line *)*num_lines);

	for (i=0; i < num_lines; i += 1) {
		lc->lines[i] = NULL;
	}

	return lc;
}

void chart_set_line (struct line_chart * lc,
	int line_number, char * label,
	int num_points, int xs[], int ys[],
	int colour, int point_style, int line_style) {

	int i;
	struct a_line * al;

	if ((line_number < 0) || (line_number >= lc->num_lines)) return;

 	al = malloc (sizeof(struct a_line));

	al->label = strdup(label);
	al->num_points = num_points;

	al->colour = colour;
	al->point_style = point_style;
	al->line_style = line_style;

	al->xs = malloc(sizeof(int)*num_points);
	al->ys = malloc(sizeof(int)*num_points);

	for (i=0; i < num_points; i += 1) {
		al->xs[i] = xs[i];
		al->ys[i] = ys[i];
	}
	lc->lines[line_number] = al;
}

void chart_draw_line (struct line_chart * lc, int app_handle,
	int x, int y, int w, int h) {

	int lx, ly, lw, lh; /* dimensions of area in which to draw the line chart */
	int max_y_value, min_y_value, max_value_width;
	int min_x_value, max_x_value;
	int i;
	int dum, key_char_w, key_char_h;
	int kx, ky; /* position of key */

	clear_area (app_handle, x, y, w, h);
	if ((w < 50) || (h < 50)) return; /* too small to draw anything */
	if (lc->lines[0] == NULL) return; /* no line, so don't draw anything */

	max_y_value = find_max (lc->lines[0]->ys, lc->lines[0]->num_points);
	min_y_value = find_min (lc->lines[0]->ys, lc->lines[0]->num_points);
	for (i = 1; i < lc->num_lines; i += 1) {
		int t = find_max (lc->lines[i]->ys, lc->lines[i]->num_points);
		if (t > max_y_value) max_y_value = t;
		t = find_min (lc->lines[i]->ys, lc->lines[i]->num_points);
		if (t < min_y_value) min_y_value = t;
	}
	max_x_value = find_max (lc->lines[0]->xs, lc->lines[0]->num_points);
	min_x_value = find_min (lc->lines[0]->xs, lc->lines[0]->num_points);
	for (i = 1; i < lc->num_lines; i += 1) {
		int t = find_max (lc->lines[i]->xs, lc->lines[i]->num_points);
		if (t > max_x_value) max_x_value = t;
		t = find_min (lc->lines[i]->xs, lc->lines[i]->num_points);
		if (t < min_x_value) min_x_value = t;
	}

	/* Find dimensions for display of chart */
	find_chart_dimensions (app_handle, min_y_value, max_y_value, x, y, w, h,
				&max_value_width, &lx, &ly, &lw, &lh);

	vst_point (app_handle, AXES_TITLE_FONT, &dum, &dum, &key_char_w, &key_char_h);

	/* adjust dimensions to fit in a key */
	if (w > h) {
		/* wide area, so key on right */
		int max_width, i;

		max_width = strlen(lc->lines[0]->label);
		for (i=1; i<lc->num_lines; i+=1) {
			if (strlen(lc->lines[i]->label) > max_width) {
				max_width = strlen(lc->lines[i]->label);
			}
		}

		kx = x + w - key_char_w*(4 + max_width);
		ky = y + 2*key_char_h;
		lw = kx - lx - key_char_w;
	} else {
		/* tall area, so key below */
		int diff_y = key_char_h*(2+2+lc->num_lines);
		kx = x+5*key_char_w;
		ly -= diff_y;
		lh -= diff_y;
		ky = ly + 4*key_char_h; /* remember gap for labels */
	}

	draw_axes_lines (app_handle, lx, ly, lw, lh);
	draw_main_labels (app_handle, lc->title, lc->x_label, lc->y_label,
		lx, ly, lw, lh, max_value_width);
	draw_x_axis_labels (app_handle, min_x_value, max_x_value, lx, ly, lw);
	draw_y_axis_labels (app_handle, min_y_value, max_y_value, lx, ly, lh);

	/* draw points and lines */
	for (i = 0; i < lc->num_lines; i += 1) {
		int p;
		int * pts;
		pts = malloc(sizeof(int)*lc->lines[i]->num_points*2);

		for (p = 0; p < lc->lines[i]->num_points; p += 1) {
			pts[2*p] = lx + rescale (lc->lines[i]->xs[p], min_x_value, max_x_value, lw);
			pts[2*p+1] = ly - rescale (lc->lines[i]->ys[p], min_y_value, max_y_value, lh);
		}

		/* set colour/styles */
		vsl_width (app_handle, 1);
		vsl_color (app_handle, lc->lines[i]->colour);
		vsm_color (app_handle, lc->lines[i]->colour);
	#ifdef PMARKS /* use own pmarker code */
		vsf_color (app_handle, lc->lines[i]->colour);
		my_pmarker (app_handle, lc->lines[i]->point_style, lc->lines[i]->num_points, pts);
	#else /* use builtin pmarker code */
		vsm_type (app_handle, lc->lines[i]->point_style);
		/* call v_pmarker to draw points */
		v_pmarker (app_handle, lc->lines[i]->num_points, pts);
	#endif
		vsl_type (app_handle, lc->lines[i]->line_style);
		/* call v_pline to draw lines */
		v_pline (app_handle, lc->lines[i]->num_points, pts);

		free (pts);
	}

	/* draw key */
	vsf_color (app_handle, BLACK);
	vst_point (app_handle, AXES_TITLE_FONT, &dum, &dum, &dum, &dum);
	v_gtext (app_handle, kx, ky, "  KEY");
	ky += 2*key_char_h;

	for (i = 0; i < lc->num_lines; i += 1) {
		int pxy[4];

		pxy[0]=kx;
		pxy[1]=ky;
		pxy[2]=kx+25*key_char_w/10;
		pxy[3]=pxy[1];

		vsl_color (app_handle, lc->lines[i]->colour);
		vsl_width (app_handle, 1);
		vsm_color (app_handle, lc->lines[i]->colour);
	#ifdef PMARKS /* use own pmarker code */
		vsf_color (app_handle, lc->lines[i]->colour);
		my_pmarker (app_handle, lc->lines[i]->point_style, 2, pxy);
	#else /* use builtin pmarker code */
		vsm_type (app_handle, lc->lines[i]->point_style);
		v_pmarker (app_handle, 2, pxy);
	#endif
		vsl_type (app_handle, lc->lines[i]->line_style);
		v_pline (app_handle, 2, pxy);

		v_gtext (app_handle, kx+35*key_char_w/10, ky, lc->lines[i]->label);
		ky += key_char_h;
	}
}

void free_line (struct line_chart * lc) {
	int i;

	free (lc->title);
	free (lc->x_label);
	free (lc->y_label);
	for (i=0; i < lc->num_lines; i+=1) {
		free (lc->lines[i]->label);
		free (lc->lines[i]->xs);
		free (lc->lines[i]->ys);
		free (lc->lines[i]);
	}
	free (lc->lines);
	free (lc);
}

/* ************************ Pie Charts ************************ */

struct pie_chart * chart_make_pie (char * title,
	int num_slices, int values[]) {

	int i;
	struct pie_chart * pc = malloc (sizeof(struct pie_chart));

	pc->title = strdup (title);
	pc->num_slices = num_slices;
	pc->values = malloc (sizeof(int)*num_slices);
	pc->labels = malloc (sizeof(char *)*num_slices);
	pc->colours = malloc (sizeof(int)*num_slices);
	pc->interior = malloc (sizeof(int)*num_slices);
	pc->style = malloc (sizeof(int)*num_slices);

	for (i=0; i<num_slices; i += 1) {
		pc->values[i] = (values[i]>=0 ? values[i] : -values[i]);
		pc->labels[i] = strdup (" ");
		pc->labels[i][0] = i+'1'; /* set label to index number */
		pc->colours[i] = BLUE;
		pc->interior[i] = 2;
		pc->style[i] = 1;
	}

	return pc;
}

void chart_set_pie_label (struct pie_chart * pc, int slice_number, char * label) {
	if ((slice_number < 0) || (slice_number >= pc->num_slices)) return;

	free (pc->labels[slice_number]);
	pc->labels[slice_number] = strdup (label);
}

void chart_set_pie_colour (struct pie_chart * pc, int slice_number, int colour) {
	if ((slice_number < 0) || (slice_number >= pc->num_slices)) return;

	pc->colours[slice_number] = colour;
}

void chart_set_pie_style (struct pie_chart * pc, int slice_number, int interior, int style) {
	if ((slice_number < 0) || (slice_number >= pc->num_slices)) return;

	pc->interior[slice_number] = interior;
	pc->style[slice_number] = style;
}

void chart_draw_pie (struct pie_chart * pc, int app_handle, int x, int y, int w, int h) {
	int cx, cy, radius; /* centre and size of circle */
	int kx, ky; /* coordinates to start printing key */
	int i, total_values, bang;
	int char_h, char_w, cell_w, cell_h;

	clear_area (app_handle, x, y, w, h);
	if ((w < 50) || (h < 50)) return; /* too small to draw anything */

	vst_point (app_handle, TITLE_FONT, &char_w, &char_h, &cell_w, &cell_h);

	/* calculate circle bounds */
	if (w < h) {
		int wo_key_height = h-(pc->num_slices + 2)*cell_h+cell_h*35/10;

		/* dimensions if width less than height, allow for key below */
		radius = w/2 - cell_w;
		if (2*radius > wo_key_height) {
			radius = wo_key_height/2;
		}
		cx = x + w/2;
		cy = y + radius + cell_h + 15*cell_h/10;
		kx = x + 2*cell_w;
		ky = cy + radius + 15*cell_h/10;
	} else {
		int max_width=0;
		int wo_key_width;

		for (i=0; i<pc->num_slices; i+=1) {
			if (max_width < strlen(pc->labels[i])) {
				max_width = strlen(pc->labels[i]);
			}
		}
		/* dimensions if height less than width, allow for key to right */
		radius = h/2 - cell_h;
		wo_key_width = w-(2+max_width)*cell_w;
		if (2*radius + 2*cell_w > wo_key_width) {
			radius = wo_key_width/2 - cell_w;
		}
		cx = x + radius + cell_w;
		cy = y + radius + 15*cell_h/10; /* space for title */
		kx = cx + radius + 2*cell_w;
		ky = y+25*cell_h/10;
	}

	for (i=0, total_values=0; i<pc->num_slices; i += 1) {
		total_values += pc->values[i];
	}

	/* draw the title and key */
	vsf_color (app_handle, BLACK);
	v_gtext (app_handle, x+2*cell_w, y+cell_h+2, pc->title);

	vst_point (app_handle, AXES_TITLE_FONT, &char_w, &char_h, &cell_w, &cell_h);
	v_gtext (app_handle, kx, ky, "  KEY");
	ky += 15*cell_h/10;

	/* draw the slices */
	bang = 0;
	for (i=0; i < pc->num_slices; i += 1) {
		int eang = bang + 1 + rescale (pc->values[i], 0, total_values, 3600);
		// int eang = bang + 1 + (int)(3600*((float)pc->values[i]/total_values));
		int pxy[4];

		vsf_color (app_handle, pc->colours[i]);
		vsf_interior (app_handle, pc->interior[i]);
		vsf_style (app_handle, pc->style[i]);

		v_pieslice (app_handle, cx, cy, radius, bang, eang);

		bang = eang;

		/* draw the key */
		pxy[0] = kx;
		pxy[1] = ky;
		pxy[2] = kx + 15*cell_w/10-1;
		pxy[3] = ky - cell_h+4; /* leave a small gap between rows */
		v_bar (app_handle, pxy);

		vsf_color (app_handle, BLACK);
		v_gtext (app_handle, kx+2*cell_w, ky, pc->labels[i]);
		ky += cell_h;
	}
}

void free_pie (struct pie_chart * pc) {
	int i;

	free (pc->title);
	free (pc->values);
	for (i=0; i<pc->num_slices; i+= 1) {
		free (pc->labels[i]);
	}
	free (pc->labels);
	free (pc->colours);
	free (pc->interior);
	free (pc->style);
	free (pc);
}
