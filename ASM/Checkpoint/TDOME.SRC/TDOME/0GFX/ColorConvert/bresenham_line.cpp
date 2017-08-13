/*								*/
/* LINEROUT: BRESENHAM			*/
/*								*/

#include "bresenham_line.h"

#include "main.h"
#include "display.h"
#include "gfx_load.h"



int bresenham_line_Map_ADD_COLOR(int x0, int y0, int x1, int y1,  u32 color_in);

/*------------------------------------------------------------------------------*/
/*                                        2D - CLIPPER                                                                                                */
/*                                                                                                                                                                */
double xl_c2d, xr_c2d, yt_c2d, yb_c2d;

/* swap 2 double values ...  better do it with a macro                                                        */
void swap_double(double *a,double *b) { double t=*a; *a=*b; *b=t; }


int DrawLineClipped(double x0, double y0, double x1, double y1,  u32 color)
{
	if ( clip_2d(&x0,&y0,&x1,&y1) == 0)
	{
		bresenham_line((int)x0,(int)y0,(int)x1,(int)y1,color);
		return 0;
	}
	return 1;
}


int DrawLineClipped_Map(double x0, double y0, double x1, double y1, u32 color, int add_flag)
{
	if ( clip_2d(&x0,&y0,&x1,&y1) == 0)
	{
		if(add_flag)
			bresenham_line_Map_ADD_COLOR((int)x0,(int)y0,(int)x1,(int)y1,color);
		else
			bresenham_line_Map((int)x0,(int)y0,(int)x1,(int)y1,color);
		return 0;
	}
	return 1;
}


void clip_2d_init(double x_left, double x_right, double y_top, double y_bottom)
{
	xl_c2d = x_left;
	xr_c2d = x_right;
	yt_c2d = y_top;
	yb_c2d = y_bottom;
}


int clip_2d(double *x0_p,double *y0_p, double *x1_p,double *y1_p)
{
	double x0=*x0_p;
    double y0=*y0_p;
    double x1=*x1_p;
    double y1=*y1_p;

        /*----------------------------------------------------------------------*/
        /*---- CLIP Y ----------------------------------------------------------*/
        if (y0 > y1)                                                                /* von Oben nach Unten !        */
                { swap_double(&x0,&x1); swap_double(&y0,&y1); }
                                                //if( (y0 < yt_c2d) || (y1 > yb_c2d) ) return 1; /* GENERAL CLIP */
        /* Clip y top       yt_c2d        */
        if (y0<yt_c2d) {        if (y1<yt_c2d)        return 1;        /* line out of viewwindow */
                x0 = x0 + ((yt_c2d-y0) * (x1-x0))/(y1-y0);
                y0 = yt_c2d;
        }
        /* Clip y bottom    yb_c2d        */
        if (y1>yb_c2d) {        if (y0>yb_c2d)        return 1;        /* line out of viewwindow */
                x1 = x1 + ((yb_c2d-y1) * (x1-x0))/(y1-y0);
                y1 = yb_c2d;
        }


        /*----------------------------------------------------------------------*/
        /*---- CLIP X ----------------------------------------------------------*/
        if(x0 > x1)                                                                        /* von Links nach Rechts !        */
                { swap_double(&x0,&x1); swap_double(&y0,&y1); }
                                                //if( (x0 < xl_c2d) || (x1 > xr_c2d) ) return 1; /* GENERAL CLIP */
        /* Clip x left                xl_c2d        */
        if (x0<xl_c2d) {        if (x1<xl_c2d)        return 1;        /* line out of viewwindow */
                y0 = y0 + ((xl_c2d-x0) * (y1-y0))/(x1-x0);
                x0 = xl_c2d;
        }
        /* Clip x right                xr_c2d        */
        if (x1>xr_c2d) {        if (x0>xr_c2d)        return 1;        /* line out of viewwindow */
                y1 = y1 + ((xr_c2d-x1) * (y1-y0))/(x1-x0);
                x1 = xr_c2d;
        }



        /* writeback clipped points */
        *x0_p = x0;
        *y0_p = y0;
        *x1_p = x1;
        *y1_p = y1;
        return 0;                /* 0 = line is visible */
}

/*                                                                                                                                                                */
/*------------------------------------------------------------------------------*/



int bresenham_line(int x0, int y0, int x1, int y1,  u32 color_in)
{
	int delta_ne;

	register u32 *frameBuffer;
	register const u32 color = color_in;
	register int y_step;
	register int dx,dy;
	register int d,delta_e,ne_e;

	if (x1<x0)  // immer von Links nach Rechts
	{
		d=x0;		x0=x1;		x1=d;
		d=y0;		y0=y1;		y1=d;
	}

	frameBuffer=rgbBuffer[y0];

	dx=(x1-x0);
	dy=(y1-y0);

	y_step = 1*XW;
	if (dy<0)
	{
		y_step	= -y_step;
		dy		= -dy;		// abs(dy)
	}


	if ( dx > dy )
	{
		d=(2*dy-dx);
		delta_e=(2*dy);
		delta_ne=(2*(dy-dx));

		d-=delta_e;
		ne_e=(delta_ne-delta_e);

		frameBuffer+=x0;
		dx++;					// adjust length for pre-decrement do/while loop
		do
		{
			*frameBuffer++=color;
			
			d+=delta_e;
			if ( d>0 )
			{
				frameBuffer+=y_step;
				d+=ne_e;		//(delta_ne-delta_e);
			}
		}while(--dx);			//compiles better
	}
	else
	{
		d=(2*dx-dy);
		delta_e=(2*dx);
		delta_ne=(2*(dx-dy));

		d-=delta_e;
		ne_e=(delta_ne-delta_e);

		frameBuffer+=x0;
		dy++;					// adjust length for pre-decrement do/while loop
		do
		{
			*frameBuffer=color;
			frameBuffer+=y_step;

			d+=delta_e;
			if (d>0)
			{
				frameBuffer++;
				d+=ne_e;		// (delta_ne-delta_e);
			}
		}while(--dy);			//compiles better
	}
	return 0;
}



int bresenham_line_Map(int x0, int y0, int x1, int y1,  u32 color_in)
{
	int delta_ne;

	register u32 *frameBuffer;
	register const u32 color = color_in;
	register int y_step;
	register int dx,dy;
	register int d,delta_e,ne_e;

	if (x1<x0)  // immer von Links nach Rechts
	{
		d=x0;		x0=x1;		x1=d;
		d=y0;		y0=y1;		y1=d;
	}

	frameBuffer = map_window_rgb[y0];

	dx=(x1-x0);
	dy=(y1-y0);

	y_step = 1*512; //XW;
	if (dy<0)
	{
		y_step	= -y_step;
		dy		= -dy;		// abs(dy)
	}

	if ( dx > dy )
	{
		d=(2*dy-dx);
		delta_e=(2*dy);
		delta_ne=(2*(dy-dx));

		d-=delta_e;
		ne_e=(delta_ne-delta_e);

		frameBuffer+=x0;
		dx++;					// adjust length for pre-decrement do/while loop
		do
		{
			*frameBuffer++=color;
			
			d+=delta_e;
			if ( d>0 )
			{
				frameBuffer+=y_step;
				d+=ne_e;		//(delta_ne-delta_e);
			}
		}while(--dx);			//compiles better
	}
	else
	{
		d=(2*dx-dy);
		delta_e=(2*dx);
		delta_ne=(2*(dx-dy));

		d-=delta_e;
		ne_e=(delta_ne-delta_e);

		frameBuffer+=x0;
		dy++;					// adjust length for pre-decrement do/while loop
		do
		{
			*frameBuffer=color;
			frameBuffer+=y_step;

			d+=delta_e;
			if (d>0)
			{
				frameBuffer++;
				d+=ne_e;		// (delta_ne-delta_e);
			}
		}while(--dy);			//compiles better
	}
	return 0;
}


int bresenham_line_Map_ADD_COLOR(int x0, int y0, int x1, int y1,  u32 color_in)
{
	int delta_ne;

	register u32 *frameBuffer;
	register const u32 color = color_in;
	register int y_step;
	register int dx,dy;
	register int d,delta_e,ne_e;

	if (x1<x0)  // immer von Links nach Rechts
	{
		d=x0;		x0=x1;		x1=d;
		d=y0;		y0=y1;		y1=d;
	}

	frameBuffer = map_window_rgb[y0];

	dx=(x1-x0);
	dy=(y1-y0);

	y_step = 1*512; //XW;
	if (dy<0)
	{
		y_step	= -y_step;
		dy		= -dy;		// abs(dy)
	}

	if ( dx > dy )
	{
		d=(2*dy-dx);
		delta_e=(2*dy);
		delta_ne=(2*(dy-dx));

		d-=delta_e;
		ne_e=(delta_ne-delta_e);

		frameBuffer+=x0;
		dx++;					// adjust length for pre-decrement do/while loop
		do
		{
			*frameBuffer+=color;
			frameBuffer++;

			d+=delta_e;
			if ( d>0 )
			{
				frameBuffer+=y_step;
				d+=ne_e;		//(delta_ne-delta_e);
			}
		}while(--dx);			//compiles better
	}
	else
	{
		d=(2*dx-dy);
		delta_e=(2*dx);
		delta_ne=(2*(dx-dy));

		d-=delta_e;
		ne_e=(delta_ne-delta_e);

		frameBuffer+=x0;
		dy++;					// adjust length for pre-decrement do/while loop
		do
		{
			*frameBuffer+=color;
			frameBuffer+=y_step;

			d+=delta_e;
			if (d>0)
			{
				frameBuffer++;
				d+=ne_e;		// (delta_ne-delta_e);
			}
		}while(--dy);			//compiles better
	}
	return 0;



}