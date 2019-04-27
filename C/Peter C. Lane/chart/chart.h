#if !defined(CHART_H)
#define CHART_H

/* This header file contains all the publicly available functions and
structs, to use the chart library.

There are three kinds of chart: bar, line and pie.

The interface attempts to be consistent:

	chart_make_X: creates chart type X
	chart_add_X: extends property X of a given chart
	chart_set_X:  sets property X of a given chart
	chart_draw_X: draws chart type X to a given position
	free_X:       frees memory used by chart type X

Where colour, point, line or fill styles can be set, these values are
standard AES/VDI values.

For points: 1 = dot, 2 = plus, 3 = star, 4 = square, 5 = cross, 6 = diamond
For lines: 1 = solid, 2 = long dash, 3 = dots, 4 = dash dot, 5 = dash, 6 = dash dot dot
For interior: 0 = hollow, 1 = solid, 2 = pattern, 3 = hatch
Interior 2 allows 24 different styles, and
interior 3 allows 12 different styles.

*/

#include <aes.h>
#include <vdi.h>
#include <stdlib.h>
#include <string.h>

/* Display uses the system font
   -- character sizes defined here for different components
 */
#define TITLE_FONT 14
#define AXES_TITLE_FONT 12
#define AXES_LABEL_FONT 6

/* ************************ Bar Charts ************************ */

/* Struct to hold information about the bar_chart */
struct bar_chart {
	char * title;
	char * x_label;
	char * y_label;
	int num_bars;
	int * values;
	char ** labels;
	int * colours;
	int * interior;
	int * style;
};

/* Create a bar_chart.  Note the num_bars and size of values must be equal.

   Inputs:
   	title: a string to display at top of chart
   	x_label: a string to display below x axis
   	y_label: a string to display along y axis
   	num_bars: the number of bars in the bar chart
   	values: the values for the bars in the bar chart
   Returns:
      	a pointer to a bar_chart.
 */
struct bar_chart * chart_make_bar (char * title,
	char * x_label, char * y_label,
	int num_bars, int values[]);

/* Assigns a string as the label for the numbered bar along the x-axis.
   Bar numbers start from 0.  It is assumed that bar_number is within
   range.

   Inputs:
   	bc: a bar_chart
   	bar_number: number of bar to set
   	label: string value, to set as the bar's label
 */
void chart_set_bar_x_label (struct bar_chart * bc, int bar_number, char * label);

/* Assigns the colour to use when displaying the numbered bar.
   Bar numbers start from 0.  It is assumed that bar_number is within
   range.

   Inputs:
   	bc: a bar_chart
   	bar_number: number of bar to set
   	colour: a palette colour number, to set as the bar's colour
 */
void chart_set_bar_colour (struct bar_chart * bc, int bar_number, int colour);

/* Assigns a fill interior and style to the given bar.
   Bar numbers start from 0.  It is assumed that bar_number is within
   range.

   Inputs:
   	bc: a bar_chart
   	bar_number: number of bar to set
   	interior, style: style index, for fill pattern
 */
void chart_set_bar_style (struct bar_chart * bc, int bar_number, int interior, int style);

/* Draw the bar chart in the given space.  Assume that clipping has been set.

   Inputs:
   	bc: a bar_chart
   	app_handle: handle of work station to draw on
   	x,y,w,h: x,y position and w,h size of area in which to draw the chart
 */
void chart_draw_bar (struct bar_chart * bc, int app_handle, int x, int y, int w, int h);

/* Free space used by a bar chart */
void free_bar (struct bar_chart * bc);

/* ************************ Line Charts *********************** */

/* struct to hold information about a single line */
struct a_line {
	char * label;
	int num_points;
	int colour;
	int point_style;
	int line_style;
	int * xs;
	int * ys;
};

/* struct to hold information about a line chart */
struct line_chart {
	char * title;
	char * x_label;
	char * y_label;
	int num_lines;
	struct a_line ** lines;
};

/* Create a line_chart.

   Inputs:
   	title: a string to display at top of chart
   	x_label: a string to display below x axis
   	y_label: a string to display along y axis
   	num_lines: the number of lines to appear in the line chart
   Returns:
      	a pointer to a line_chart.
 */
struct line_chart * chart_make_line (char * title,
	char * x_label, char * y_label,
	int num_lines);

/* Set a line to the given line_chart.
   It is assumed that num_points equals the size of xs and ys,
   and that line_number is within range of lc->num_lines.

   Inputs:
   	lc: a line_chart
   	line_number: number of line to set
   	label: a label for the line
   	num_points: the number of points in line
   	xs: an array of the x values for the line
   	ys: an array of the y values for the line
   	colour: colour to draw the line
   	point_style: style of point to use when plotting points
   	line_style: style of line to use to connect points
 */
void chart_set_line (struct line_chart * lc,
	int line_number, char * label,
	int num_points, int xs[], int ys[],
	int colour, int point_style, int line_style);

/* Draw the line chart in the given space.  Assume that clipping has been set.

   Inputs:
   	lc: a line_chart
   	app_handle: handle of work station to draw on
   	x,y,w,h: x,y position and w,h size of area in which to draw the chart
 */
void chart_draw_line (struct line_chart * lc, int app_handle,
	int x, int y, int w, int h);

/* Free space used by a line chart */
void free_line (struct line_chart * lc);

/* ************************ Pie Charts ************************ */

/* Struct to hold information about the pie_chart */
struct pie_chart {
	char * title;
	int num_slices;
	int * values;
	char ** labels;
	int * colours;
	int * interior;
	int * style;
};

/* Create a pie_chart.  Note the num_slices and size of values must be equal.
   The values should be positive integers, and their relative proportions
   are used to compute the size of the different arcs.

   Inputs:
   	title: a string to display at top of chart
   	num_slices: the number of slices in the pie chart
   	values: the values for the slices in the bar chart
   Returns:
      	a pointer to a pie_chart.
 */
struct pie_chart * chart_make_pie (char * title,
	int num_slices, int values[]);

/* Assigns a string as the label for the numbered slice.
   Slice numbers start from 0.  It is assumed that slice_number is within
   range.

   Inputs:
   	pc: a pie_chart
   	slice_number: number of slice to set
   	label: string value, to set as the slice's label
 */
void chart_set_pie_label (struct pie_chart * pie, int slice_number, char * label);

/* Assigns the colour to use when displaying the numbered slice.
   Slice numbers start from 0.  It is assumed that slice_number is within
   range.

   Inputs:
   	pc: a pie_chart
   	slice_number: number of slice to set
   	colour: a palette colour number, to set as the slice's colour
 */
void chart_set_pie_colour (struct pie_chart * pc, int slice_number, int colour);

/* Assigns a fill style for the given slice.
   Slice numbers start from 0.  It is assumed that slice_number is within
   range.

   Inputs:
   	pc: a pie_chart
   	slice_number: number of slice to set
   	interior, style: style index, for fill pattern
 */
void chart_set_pie_style (struct pie_chart * pc, int slice_number, int interior, int style);

/* Draw the pie chart in the given space.  Assume that clipping has been set.

   Inputs:
   	pc: a pie_chart
   	app_handle: handle of work station to draw on
   	x,y,w,h: x,y position and w,h size of area in which to draw the chart
 */
void chart_draw_pie (struct pie_chart * pc, int app_handle, int x, int y, int w, int h);

/* Free space used by a pie chart */
void free_pie (struct pie_chart * pc);

#endif

