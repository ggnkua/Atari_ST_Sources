

#ifndef __polygon_flat_h
#define __polygon_flat_h


// #include "render_common.h"


int polygon_flat(double xd0,double yd0,
				 double xd1,double yd1,
				 double xd2,double yd2,
				 u32 color_in);

//extern struct Polygon_2D;


typedef struct Polygon_2D
{
	int amount_vertices;

	u32 color;
	u32 color_num;

	double x[32];
	double y[32];
	double z[32];	// for z-buffer

	double xt[32];	// transformed to 2D
	double yt[32];

	double u[32];
	double v[32];
}Polygon_2D;


int draw_Polygon_n_vertices(Polygon_2D *p);



#endif

