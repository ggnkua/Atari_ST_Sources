

#include "datatypes.h"


int DrawLineClipped(double x0, double y0, double x1, double y1,  u32 color);


int DrawLineClipped_Map(double x0, double y0, double x1, double y1, u32 color, int add_flag);


int bresenham_line(int x0, int y0, int x1, int y1,  u32 color);
int bresenham_line_Map(int x0, int y0, int x1, int y1,  u32 color_in);

void clip_2d_init(double x_left, double x_right, double y_top, double y_bottom);
int clip_2d(double *x0_p,double *y0_p, double *x1_p,double *y1_p);



int clip_line_3D(double x0,double y0,double z0,double x1,double y1,double z1, u32 color);

