//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <windows.h>
//---------------------------------------------------------------------------------
#include "datatypes.h"
#include "main.h"
#include "filestuff.h"
#include "display.h"

#include "bresenham_line.h"
#include "test_effect.h"


#include "tri_map_fixed.h"

//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------

#define T	9
#define M	(4096+4096)	//	(4096+2048)
#define MZ	M

#define board_vertices (T*T)

typedef struct board
{
	double x;
	double y;
	double z;
	double xt;
	double yt;
}board;


double object_board[board_vertices][3];

board object_board_result[board_vertices];


void plot_vertice_2d(int v, u32 color)
{
	int x,y;
	double z = object_board_result[v].z;
	if(z<z_clip_min) return;
	
	x = object_board_result[v].xt;
	y = object_board_result[v].yt;

	if( (x<0) || (x>XW-1) ) return;
	if( (y<0) || (y>YW-1) ) return;
	rgbBuffer[y][x] = color;
}


void init_board()
{
	int i;
	//build_cube_board   amount_vertices = T*T
	double d1 = 0;
	double o  = 2*(M-1);
	double a2 = o/(T-1);
	double d2 = M-1;
	double d0;
	int d6,d7;

	double scale_adjust = 1;

	i = 0;
	for(d7=0;d7<T;d7++)
	{
		d0 = M-1;
		for(d6=0;d6<T;d6++)
		{
			object_board[i][0] = scale_adjust*d0;	// x
			object_board[i][1] = scale_adjust*d1;	// y
			object_board[i][2] = scale_adjust*d2;	// z
			d0-=a2;
			i++;
		}
		d2-=a2;
	}
}



void draw_edge_board(int v0,int v1)
{
	u32 color = 0xa04040;
	clip_line_3D(
		object_board_result[v0].x, object_board_result[v0].y, object_board_result[v0].z,
		object_board_result[v1].x, object_board_result[v1].y, object_board_result[v1].z,
		color);
}


void draw_wire_board()
{
	int xi,yi;
	int t;
	// zeilen
	for(yi=0;yi<T;yi++)
	{	
		for(xi=0;xi<T-1;xi++)
		{
			t = yi*T + xi;
			draw_edge_board(t,t+1);
		}
	}
	// spalten
	for(yi=0;yi<T;yi++)
	{	
		for(xi=0;xi<T-1;xi++)
		{
			t = xi*T + yi;
			draw_edge_board(t,t+T);
		}
	}
}


void display_board()
{
	int i;
	double x,y,z;

	static int scroll_x=0;
	static int scroll_z=0;

	double zf_scale_save = zf_scale;

//	zf_scale = 2;
	//zf_scale = 4;

	// rotation
	for(i=0;i<board_vertices;i++)
	{
		x = object_board[i][0];
		y = object_board[i][1];
		z = object_board[i][2];

//		z+=scroll_z;

		rotate_xyz  (&x,&y,&z);

		object_board_result[i].x = x;
		object_board_result[i].y = y;
		object_board_result[i].z = z;

		trans_3d_2d (&x,&y,&z);

		object_board_result[i].xt = x;
		object_board_result[i].yt = y;

		plot_vertice_2d(i, 0xff4040);
	}

	draw_wire_board();

	//scroll_z+= 4; //32;
	
				//scroll_z=scroll_z%( (2*(M-1))/(T-1) );

	scroll_z=scroll_z%( (2*(M))/(T-1) );

	//--------------------------------------
	zf_scale = zf_scale_save;
}
