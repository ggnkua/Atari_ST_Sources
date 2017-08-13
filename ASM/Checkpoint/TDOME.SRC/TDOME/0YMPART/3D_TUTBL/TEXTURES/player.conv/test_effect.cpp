//
// 
// Polygon Animation 
// (w)2014 lsl/checkpoint
//
//

#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <windows.h>



#include <math.h>
#include "test_effect.h"

#include "bresenham_line.h"
#include "polygon_flat.h"


#include "tri_map_fixed.h"



#include "quicksort.h"

#include "board.h"

#include "obj_reader.h"


double _3d_result[265536][3];
double _normals_result[265536][3];


int _uv_result[265536][3];

double _2d_result[265536][2];
double _2d_result_Nend[265536][2];
double _normals_faces_result[265536][3];	//nx,ny,nz
double _normals_faces_lines[265536][4];		//x0,y0, x1,y1


// read & init
double	_3ds_vertices[65536][3];
int		_3ds_faces[65536][3];
double  _3ds_normals[65536][3];

// multiple objects
int		_3ds_objinfo_frames[MAX_FRAMES][16];
double	_3ds_vertices_frames[MAX_FRAMES][4096][3];
double	_3ds_vt_frames[MAX_FRAMES][4096][2];

int		_3ds_faces_frames[MAX_FRAMES][4096][3];
int		_3ds_faces_tex_frames[MAX_FRAMES][4096][3];

double  _3ds_normals_frames[MAX_FRAMES][4096][3];


int frames_used = 0;

int current_frame = 0;


void make_normals_object();


void render_polyoutput_wire_hidden();

void render_polyoutput_flat();

void render_polyoutput_env();


//-----------------------------------------------------------------------
u32 draw_edge_line_color = 0x00ffffff;

//------------------------------------
double scale_x_in = 1;	//60.f;
double scale_y_in = 1;	//60.f;
double scale_z_in = 1;	//60.f;

double proj_z =		-200;
double z_zoom =     -150;

double z_clip_min =	-150;	// clipz in BOARD.S

double zf_scale	 =  2;

double view_x_lt =  0;
double view_y_lt =	0; //1200;
double view_z_lt =	8000;

double yt_trans = 0; 

double object_x	= 0;
double object_y	= 0;
double object_z	= 0; //4*2048; //-5000;	//-5000;

double camera_x = 0;
double camera_y = 0;
double camera_z = 0;
//------------------------------------


double xr = 0;
double yr = 0;
double zr = 0;

//-----------------------------------------------------------------------


PolyOut_Zsort polyoutput_Zsort_list[565536];
PolyOut polyoutput_list[565536];

int polyoutput_amount;


vertex vert0,vert1,vert2;



int _3ds_vertices_amount	= 0;
int _3ds_faces_amount		= 0;

int _3ds_vertices_base		= 0;
int _3ds_faces_base			= 0;

void add_3ds_vertice(double x,double y,double z)
{
	_3ds_vertices[_3ds_vertices_amount][0] = x;
	_3ds_vertices[_3ds_vertices_amount][1] = y;
	_3ds_vertices[_3ds_vertices_amount][2] = z;
	_3ds_vertices_amount++;
}

void add_3ds_face(int v0,int v1,int v2)
{
	_3ds_faces[_3ds_faces_amount][0] = v0+_3ds_vertices_base;
	_3ds_faces[_3ds_faces_amount][1] = v1+_3ds_vertices_base;
	_3ds_faces[_3ds_faces_amount][2] = v2+_3ds_vertices_base;
	_3ds_faces_amount++;
}



#define ts 200 

double test_vertices[4][3] = {
	-ts,-ts, ts,
	-ts, ts, ts,
	 ts, ts, ts,
	 ts,-ts, ts
};



void set_point(int x,int y)
{
	u32 color = 0xff0000;
	if( (x<1) || (x>XW-1) || (y<1) || (y>YW-1) ) return;

	rgbBuffer[y-1][x-1] = color;
	rgbBuffer[y-1][x]	= color;
	rgbBuffer[y-1][x+1] = color;
	rgbBuffer[y][x-1]	= color;
	rgbBuffer[y][x]		= color;
	rgbBuffer[y][x+1]	= color;
	rgbBuffer[y+1][x-1] = color;
	rgbBuffer[y+1][x]	= color;
	rgbBuffer[y+1][x+1] = color;
}


void rotate_xyz(double *xp,double *yp,double *zp)
{
	double xx,yy,zz;
	double x = *xp;
	double y = *yp;
	double z = *zp;

	double ysin = sin(yr);
	double ycos = cos(yr);

	double xsin = sin(xr);
	double xcos = cos(xr);

	double zsin = sin(zr);
	double zcos = cos(zr);


	x-=camera_x;
	y-=camera_y;
	z-=camera_z;

	// y-axxis
	xx	= x;
	x	= x*ycos +  z*ysin;
	z	= z*ycos - xx*ysin;
	
	// x-axxis
	yy	= y;
	y	= y*xcos +  z*xsin;
	z	= z*xcos - yy*xsin;

	// z-axxis
	xx	= x;
	x	= x*zcos +  y*zsin;
	y	= y*zcos - xx*zsin;


	// NEW!!
	x+=view_x_lt;
	y+=view_y_lt;
	z+=view_z_lt;

	*xp = x;
	*yp = y;
	*zp = z;
}

void rotate_xyz_NORMALS(double *xp,double *yp,double *zp)
{
	double xx,yy,zz;
	double x = *xp;
	double y = *yp;
	double z = *zp;

	double ysin = sin(yr);
	double ycos = cos(yr);

	double xsin = sin(xr);
	double xcos = cos(xr);

	// y-axxis
	xx	= x;
	x	= x*ycos +  z*ysin;
	z	= z*ycos - xx*ysin;
	
	// x-axxis
	yy	= y;
	y	= y*xcos +  z*xsin;
	z	= z*xcos - yy*xsin;

	*xp = x;
	*yp = y;
	*zp = z;
}


void trans_3d_2d(double *xp,double *yp,double *zp)
{
	double zf;
	double x = *xp;
	double y = *yp;
	double z = *zp;

	/*
	x+=view_x_lt;
	y+=view_y_lt;
	z+=view_z_lt;
	*/

	zf = 1.f - (z_zoom-z)/(proj_z-z);
	
	zf*=zf_scale;
	
	x*= zf;
	y*= zf;
	x+= XW/2.f;

	//	y+= YW/2.f;
	y = YW/2.f - y + yt_trans;
	
	*xp = x;
	*yp = y;
}


void draw_edge_line(int v0,int v1)
{
	DrawLineClipped( 
		_2d_result[v0][0], _2d_result[v0][1],
		_2d_result[v1][0], _2d_result[v1][1],
		draw_edge_line_color);
}

void draw3v_lines(int v0,int v1,int v2)
{
	draw_edge_line(v0,v1);
	draw_edge_line(v1,v2);
	draw_edge_line(v2,v0);
}


void drawTri_flat(int v0,int v1,int v2, u32 color)
{
	polygon_flat(_2d_result[v0][0], _2d_result[v0][1],
				 _2d_result[v1][0], _2d_result[v1][1],
				 _2d_result[v2][0], _2d_result[v2][1],
				 color);
}

void drawTri_flat_lines(int v0,int v1,int v2, u32 color)
{
	u32 pcolor = 0x112233;
	polygon_flat(_2d_result[v0][0], _2d_result[v0][1],
				 _2d_result[v1][0], _2d_result[v1][1],
				 _2d_result[v2][0], _2d_result[v2][1],
				 pcolor);
	draw3v_lines(v0,v1,v2); 
}


void copy_to_vertex( int v, vertex *vert)
{
	vert->xt = _2d_result[v][0];
	vert->yt = _2d_result[v][1];

	vert->x  = _3d_result[v][0];
	vert->y  = _3d_result[v][1];
	vert->z  = _3d_result[v][2];
}


// ------------------------------------------------------------------------------
// form a x,y,z vector from a vertex a to vertex b
void vector_from_vertex(vertex *a, vertex *b, double *x, double *y, double *z)
{
	*x = ( b->x - a->x );
	*y = ( b->y - a->y );
	*z = ( b->z - a->z );
}
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// form a x,y,z vector from a vertex a to vertex b
void vector_from_vertex_2d(vertex *a, vertex *b, double *x, double *y, double *z)
{
	*x = ( b->xt - a->xt );
	*y = ( b->yt - a->yt );
	*z = 0;
}
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// form a x,y,z vector from a vertex a to vertex b
void vector_from_vertex_3d(vertex *a, vertex *b, double *x, double *y, double *z)
{
	*x = ( b->x - a->x );
	*y = ( b->y - a->y );
	*z = ( b->z - a->z );
}
// ------------------------------------------------------------------------------




// ------------------------------------------------------------------------------
// normalize x,y,z
void normalize(double *xp,double *yp,double *zp)
{
	double x=*xp,y=*yp,z=*zp;
	double denom=sqrt(x*x+y*y+z*z);
	*xp=x/denom;
	*yp=y/denom;
	*zp=z/denom;
}
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------
// normalvector (vectorproduct & unitlength)
void calc_normal(	double x0,double y0,double z0,double x1,double y1,double z1,
					double *nxp,double *nyp,double *nzp)
{
	double nx,ny,nz;

//	normalize(&x0,&y0,&z0);
//	normalize(&x1,&y1,&z1);

	nx=y0*z1 - z0*y1;
	ny=z0*x1 - x0*z1;
	nz=x0*y1 - y0*x1;

	normalize(&nx,&ny,&nz);

	*nxp=nx;
	*nyp=ny;
	*nzp=nz;
}
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// normalvector (vectorproduct & unitlength)
void calc_normal_notNorm(	double x0,double y0,double z0,double x1,double y1,double z1,
					double *nxp,double *nyp,double *nzp)
{
	double nx,ny,nz;
	nx=y0*z1 - z0*y1;
	ny=z0*x1 - x0*z1;
	nz=x0*y1 - y0*x1;
	*nxp=nx;
	*nyp=ny;
	*nzp=nz;
}
// ------------------------------------------------------------------------------


double normals_object_init[265536][3];


void copy_to_vertex_from_object( int v, vertex *vert)
{
	vert->x  = _3ds_vertices[v][0];
	vert->y  = _3ds_vertices[v][1];
	vert->z  = _3ds_vertices[v][2];
}


void make_normals_object()
{
	int i,v;
	int v0,v1,v2, vn;
	vertex vert0,vert1,vert2;
	double x0,y0,z0;
	double x1,y1,z1;
	double nx,ny,nz;
	double nscale;

	for(i=0;i<_3ds_faces_amount;i++)
	{
		v0 = _3ds_faces[i][0];
		v1 = _3ds_faces[i][1];
		v2 = _3ds_faces[i][2];

		copy_to_vertex_from_object(v0, &vert0);
		copy_to_vertex_from_object(v1, &vert1);
		copy_to_vertex_from_object(v2, &vert2);

		vector_from_vertex_3d( &vert0,&vert1, &x0,&y0,&z0 );
		vector_from_vertex_3d( &vert0,&vert2, &x1,&y1,&z1 );

		calc_normal_notNorm(x0,y0,z0, x1,y1,z1, &nx,&ny,&nz );

//		calc_normal_notNorm(x1,y1,z1, x0,y0,z0, &nx,&ny,&nz );
/*
		nx*=-1;
		ny*=-1;
		nz*=-1;
*/
		normalize(&nx,&ny,&nz);

		normals_object_init[i][0] = nx;
		normals_object_init[i][1] = ny;
		normals_object_init[i][2] = nz;
	}

	for(i=0;i<_3ds_vertices_amount;i++)
	{
		nx = ny = nz = 0;
		for(v=0;v<_3ds_faces_amount;v++)
		{
			if( (_3ds_faces[v][0]==i)||(_3ds_faces[v][1]==i)||(_3ds_faces[v][2]==i) )
			{
				nx+=normals_object_init[v][0];
				ny+=normals_object_init[v][1];
				nz+=normals_object_init[v][2];
			}
		}

		normalize(&nx,&ny,&nz);
		nscale = 128.f;
		nx=nscale*nx;
		ny=nscale*ny;
		nz=nscale*nz;

		_3ds_normals[i][0] = nx;
		_3ds_normals[i][1] = ny;
		_3ds_normals[i][2] = nz;
	}
}



void draw_normals_polyoutput();

void draw_normals_faces();


//QQQ
void test_3ds_V2()
{
	int i;
	double x,y,z;
	double nx,ny,nz;
	double xs,ys,zs;
	double xe,ye,ze;

	double light;

	int v0,v1,v2;
	int u,v;

	int color;


	 _3ds_vertices_amount	= _3ds_objinfo_frames[current_frame][0];
	 _3ds_faces_amount		= _3ds_objinfo_frames[current_frame][1];


	for(i=0;i<_3ds_vertices_amount;i++)
	{
		x = _3ds_vertices_frames[current_frame][i][0];
		y = _3ds_vertices_frames[current_frame][i][1];
		z = _3ds_vertices_frames[current_frame][i][2];

		x*=scale_x_in;
		y*=scale_y_in;
		z*=scale_z_in;

		y = (200+150)-y;

		x+=object_x;
		y+=object_y;
		z+=object_z;		
		
		rotate_xyz(&x,&y,&z);

		_3d_result[i][0] = x;
		_3d_result[i][1] = y;
		_3d_result[i][2] = z;

		xs=x; ys=y; zs=z;

		trans_3d_2d(&x,&y,&z);

		_2d_result[i][0] = x;
		_2d_result[i][1] = y;
		//------------------------------------------
		// rotate normals
		nx = _3ds_normals_frames[current_frame][i][0];
		ny = _3ds_normals_frames[current_frame][i][1];
		nz = _3ds_normals_frames[current_frame][i][2];

		rotate_xyz_NORMALS(&nx,&ny,&nz);

		x = 0.5f*nx;
		y = 0.5f*ny;

		_normals_result[i][0] = nx;
		_normals_result[i][1] = ny;
		_normals_result[i][2] = nz;

		double nl=0.3f; //48;
		xe = xs+nl*nx;
		ye = ys+nl*ny;
		ze = zs+nl*nz;

		trans_3d_2d(&xe,&ye,&ze);

		_2d_result_Nend[i][0] = xe;
		_2d_result_Nend[i][1] = ye;


		x = x/2;
		y = y/2;

		x+=(128);
		y+=(128);

		u = x;
		v = y;
		_uv_result[i][0] = u; //&255;
		_uv_result[i][1] = v; //&255;
	}

	double x0,y0,z0;
	double x1,y1,z1;
	double x2,y2,z2;

	polyoutput_amount = 0;

	for(i=0;i<_3ds_faces_amount;i++)
	{
		/*
		v0 = _3ds_faces_frames[current_frame][i][0];
		v1 = _3ds_faces_frames[current_frame][i][1];
		v2 = _3ds_faces_frames[current_frame][i][2];
		*/
		v0 = _3ds_faces_frames[0][i][0];
		v1 = _3ds_faces_frames[0][i][1];
		v2 = _3ds_faces_frames[0][i][2];

		copy_to_vertex(v0, &vert0);
		copy_to_vertex(v1, &vert1);
		copy_to_vertex(v2, &vert2);

		vector_from_vertex_2d( &vert0,&vert1, &x0,&y0,&z0 );
		vector_from_vertex_2d( &vert0,&vert2, &x1,&y1,&z1 );

		// Z is Zero for visibilty check!!
		calc_normal(x0,y0,0, x1,y1,0, &nx,&ny,&nz );

		if(nz<0.0f)
		{
			copy_to_vertex(v0, &vert0);
			copy_to_vertex(v1, &vert1);
			copy_to_vertex(v2, &vert2);

			vector_from_vertex_3d( &vert0,&vert1, &x0,&y0,&z0 );
			vector_from_vertex_3d( &vert0,&vert2, &x1,&y1,&z1 );

			// calc_normal(x1,y1,z1, x0,y0,z0, &nx,&ny,&nz );
			calc_normal(x0,y0,z0, x1,y1,z1, &nx,&ny,&nz );

			nx*=-1;
			ny*=-1;
			nz*=-1;

			_normals_faces_result[polyoutput_amount][0] = nx;
			_normals_faces_result[polyoutput_amount][1] = ny;
			_normals_faces_result[polyoutput_amount][2] = nz;

			x0 = _3d_result[v0][0];
			y0 = _3d_result[v0][1];
			z0 = _3d_result[v0][2];
			double nl=48;
			x1 = x0+nl*nx;
			y1 = y0+nl*ny;
			z1 = z0+nl*nz;
			trans_3d_2d(&x0,&y0,&z0);
			trans_3d_2d(&x1,&y1,&z1);			
			_normals_faces_lines[polyoutput_amount][0] = x0;
			_normals_faces_lines[polyoutput_amount][1] = y0;
			_normals_faces_lines[polyoutput_amount][2] = x1;
			_normals_faces_lines[polyoutput_amount][3] = y1;

			light = (64+128+256)*(-nz) -128-64;

			color = light;
			if(color<0)		color=0;
			if(color>255)	color=255;

			color=color*0x010101;
			//color=i*0x111111;

			// check z_min frustum
			z0 = _3d_result[v0][2];
			z1 = _3d_result[v1][2];
			z2 = _3d_result[v2][2];

			if( (z0<z_clip_min)||(z1<z_clip_min)||(z2<z_clip_min) );
			else
			{
				polyoutput_list[polyoutput_amount].color	= color;
				polyoutput_list[polyoutput_amount].v0		= v0;
				polyoutput_list[polyoutput_amount].v1		= v1;
				polyoutput_list[polyoutput_amount].v2		= v2;
				//z = _3d_result[v0][2] + _3d_result[v1][2] + _3d_result[v2][2];
				z = z0+z1+z2;
				polyoutput_Zsort_list[polyoutput_amount].polygon   = &polyoutput_list[polyoutput_amount];
				polyoutput_Zsort_list[polyoutput_amount].z_average = z;
				polyoutput_amount++;
			}
		}
	}

	//------------------------------
	//render_polyoutput_env();
	//------------------------------

	//render_polyoutput_flat();

	render_polyoutput_wire_hidden();

	
	//draw_normals_polyoutput();

	//draw_normals_faces();

}



void rotate_object()
{
	int i;
	double x,y,z;

	 _3ds_vertices_amount	= _3ds_objinfo_frames[current_frame][0];
	 _3ds_faces_amount		= _3ds_objinfo_frames[current_frame][1];

	for(i=0;i<_3ds_vertices_amount;i++)
	{
		x = _3ds_vertices_frames[current_frame][i][0];
		y = _3ds_vertices_frames[current_frame][i][1];
		z = _3ds_vertices_frames[current_frame][i][2];

//		y = -y;

		rotate_xyz(&x,&y,&z);

		_3d_result[i][0] = x;
		_3d_result[i][1] = y;
		_3d_result[i][2] = z;

		trans_3d_2d(&x,&y,&z);

		_2d_result[i][0] = x;
		_2d_result[i][1] = y;
	}
}

void display_vertices()
{
	int i;
	double x,y,z;

	 _3ds_vertices_amount	= _3ds_objinfo_frames[current_frame][0];
	 _3ds_faces_amount		= _3ds_objinfo_frames[current_frame][1];

	for(i=0;i<_3ds_vertices_amount;i++)
	{
		x = _2d_result[i][0];
		y = _2d_result[i][1];
		set_point(x,y);
	}
}



void read_vertex_2d(int v, double *x, double *y)
{
	*x = _2d_result[v][0];
	*y = _2d_result[v][1];
}

void read_texuv(int vt, double *u, double *v)
{
	*u = _3ds_vt_frames[0][vt][0];
	*v = _3ds_vt_frames[0][vt][1];
}


void test_3d_wire_all()
{
	int i;
	int v0,v1,v2;
	double x0,y0, x1,y1, x2,y2;

	 _3ds_faces_amount		= _3ds_objinfo_frames[current_frame][1];

	for(i=0;i<_3ds_faces_amount;i++)
	{
		v0 = _3ds_faces_frames[current_frame][i][0];
		v1 = _3ds_faces_frames[current_frame][i][1];
		v2 = _3ds_faces_frames[current_frame][i][2];
		read_vertex_2d( v0, &x0,&y0);
		read_vertex_2d( v1, &x1,&y1);
		read_vertex_2d( v2, &x2,&y2);

		DrawLineClipped(x0,y0, x1,y1, 0xffffff);
		DrawLineClipped(x1,y1, x2,y2, 0xffffff);
		DrawLineClipped(x2,y2, x0,y0, 0xffffff);
	}
}

//AAA
void test_3d_filled()
{
	int i;
	u32 color;
	int v0,v1,v2;
	int vt0,vt1,vt2; // texture vertex
	double x0,y0,z0, x1,y1,z1, x2,y2,z2;
	double nx,ny,nz;
	double light, z;

	 _3ds_faces_amount		= _3ds_objinfo_frames[current_frame][1];

	polyoutput_amount = 0;

	for(i=0;i<_3ds_faces_amount;i++)
	{
		v0 = _3ds_faces_frames[current_frame][i][0];
		v1 = _3ds_faces_frames[current_frame][i][1];
		v2 = _3ds_faces_frames[current_frame][i][2];


		
		if(display_mode==RENDER_LINES)
		{
			//color = 0xffffff;
			//drawTri_flat_lines(v0,v1,v2, color);
		
			draw_edge_line_color = 0xffffff;
			draw3v_lines(v0,v1,v2);		
		}


		// texture vertices
		vt0 = _3ds_faces_tex_frames[current_frame][i][0];
		vt1 = _3ds_faces_tex_frames[current_frame][i][1];
		vt2 = _3ds_faces_tex_frames[current_frame][i][2];

		copy_to_vertex(v0, &vert0);
		copy_to_vertex(v1, &vert1);
		copy_to_vertex(v2, &vert2);

		vector_from_vertex_2d( &vert0,&vert1, &x0,&y0,&z0 );
		vector_from_vertex_2d( &vert0,&vert2, &x1,&y1,&z1 );

		// Z is Zero for visibilty check!!
		calc_normal(x0,y0,0, x1,y1,0, &nx,&ny,&nz );

		if(nz>0.f)
		{		
			copy_to_vertex(v0, &vert0);
			copy_to_vertex(v1, &vert1);
			copy_to_vertex(v2, &vert2);

			vector_from_vertex_3d( &vert0,&vert1, &x0,&y0,&z0 );
			vector_from_vertex_3d( &vert0,&vert2, &x1,&y1,&z1 );

			// calc_normal(x1,y1,z1, x0,y0,z0, &nx,&ny,&nz );
			calc_normal(x0,y0,z0, x1,y1,z1, &nx,&ny,&nz );
			
			//light = 256.f*nz;

			light = -256.f*nz;

			color = light;

			//color=i;
			
			if(color<0)		color=0;
			if(color>255)	color=255;

			color=color*0x010101;

//			drawTri_flat(v0,v1,v2, color);

			// check z_min frustum
			z0 = _3d_result[v0][2];
			z1 = _3d_result[v1][2];
			z2 = _3d_result[v2][2];

			//if( (z0<z_clip_min)||(z1<z_clip_min)||(z2<z_clip_min) );
			//else
			{
				// texture vertices
				polyoutput_list[polyoutput_amount].vt0		= vt0;
				polyoutput_list[polyoutput_amount].vt1		= vt1;
				polyoutput_list[polyoutput_amount].vt2		= vt2;


				polyoutput_list[polyoutput_amount].color	= color;
				polyoutput_list[polyoutput_amount].v0		= v0;
				polyoutput_list[polyoutput_amount].v1		= v1;
				polyoutput_list[polyoutput_amount].v2		= v2;
				//z = _3d_result[v0][2] + _3d_result[v1][2] + _3d_result[v2][2];
				z = z0+z1+z2;
				polyoutput_Zsort_list[polyoutput_amount].polygon   = &polyoutput_list[polyoutput_amount];
				polyoutput_Zsort_list[polyoutput_amount].z_average = z;
				polyoutput_amount++;
			}		
		
		}

	}
	//------------------------------------------------------------------------


	PolyOut *polygon;
	double _u0,_v0, _u1,_v1, _u2,_v2;

	qsort_polyoutput_list(0,polyoutput_amount-1);
	
	for(i=0;i<polyoutput_amount;i++)
//	for(i=polyoutput_amount-1;i>=0;i--)
	{
		polygon = polyoutput_Zsort_list[i].polygon;

		v0 = polygon->v0;
		v1 = polygon->v1;
		v2 = polygon->v2;

		vt0 = polygon->vt0;
		vt1 = polygon->vt1;
		vt2 = polygon->vt2;

		color = polygon->color;

		read_vertex_2d( v0, &x0,&y0);
		read_vertex_2d( v1, &x1,&y1);
		read_vertex_2d( v2, &x2,&y2);

		read_texuv( vt0, &_u0,&_v0);
		read_texuv( vt1, &_u1,&_v1);
		read_texuv( vt2, &_u2,&_v2);

		switch (display_mode)
		{
			case RENDER_TEXMAPPED:
				tri_map(	x0,y0, x1,y1, x2,y2,
 							_u0,_v0, _u1,_v1, _u2,_v2,
							(u32*)texture_tc_256x256,(u32*)rgbBuffer);
				break;

			case RENDER_FLAT_LIGHT:
				drawTri_flat(v0,v1,v2, color);
				break;

			case RENDER_LINES_HIDDEN:
				color = 0xffffff;
				drawTri_flat_lines(v0,v1,v2, color);
				break;

			case RENDER_LINES:
				break;	

			default:
				tri_map(	x0,y0, x1,y1, x2,y2,
 							_u0,_v0, _u1,_v1, _u2,_v2,
							(u32*)texture_tc_256x256,(u32*)rgbBuffer);
				break;
		}
	}

}



void render_polyoutput_flat()
{
	int i;
	int vt0,vt1,vt2;

	int u0,v0,u1,v1,u2,v2;
	int x0,y0,x1,y1,x2,y2;

	u32 color;
	PolyOut *polygon;


	qsort_polyoutput_list(0,polyoutput_amount-1);

	
//	for(i=0;i<polyoutput_amount;i++)

	for(i=polyoutput_amount-1;i>=0;i--)
	{
		polygon = polyoutput_Zsort_list[i].polygon;
		vt0 = polygon->v0;
		vt1 = polygon->v1;
		vt2 = polygon->v2;
		color = polygon->color;
		drawTri_flat(vt0,vt1,vt2, color);
	}
}



void draw_normal(int v)
{
	int x0,y0;
	u32 color = 0xff0000;

	x0 = _2d_result[v][0];
	y0 = _2d_result[v][1];

	DrawLineClipped( 
		x0,y0,
		_2d_result_Nend[v][0],	_2d_result_Nend[v][1],
		color);

	y0--;
	rgbBuffer[y0][x0-1]		= color;
	rgbBuffer[y0][x0]		= color;
	rgbBuffer[y0][x0+1]		= color;
	y0++;
	rgbBuffer[y0][x0-1]		= color;
	rgbBuffer[y0][x0]		= color;
	rgbBuffer[y0][x0+1]		= color;
	y0++;
	rgbBuffer[y0][x0-1]		= color;
	rgbBuffer[y0][x0]		= color;
	rgbBuffer[y0][x0+1]		= color;
}


void draw_normals(int vt0,int vt1,int vt2)
{
	draw_normal(vt0);
	draw_normal(vt1);
	draw_normal(vt2);
}


void draw_normals_polyoutput()
{
	int i;
	int vt0,vt1,vt2;

	PolyOut *polygon;
	
//	for(i=0;i<polyoutput_amount;i++)

	for(i=polyoutput_amount-1;i>=0;i--)
	{
		polygon = polyoutput_Zsort_list[i].polygon;
		vt0 = polygon->v0;
		vt1 = polygon->v1;
		vt2 = polygon->v2;

		draw_normals(vt0,vt1,vt2);
	}
}


void draw_normals_faces()
{
	int i;
	int vt0,vt1,vt2;
	int x0,y0,x1,y1;

	u32 color = 0xff0000;

	PolyOut *polygon;
	
//	for(i=0;i<polyoutput_amount;i++)

	for(i=polyoutput_amount-1;i>=0;i--)
	{
		polygon = polyoutput_Zsort_list[i].polygon;
		vt0 = polygon->v0;
		vt1 = polygon->v1;
		vt2 = polygon->v2;
		x0 = _normals_faces_lines[i][0];
		y0 = _normals_faces_lines[i][1];
		x1 = _normals_faces_lines[i][2];
		y1 = _normals_faces_lines[i][3];

		DrawLineClipped( x0,y0, x1,y1, color);

		y0--;
		rgbBuffer[y0][x0-1]		= color;
		rgbBuffer[y0][x0]		= color;
		rgbBuffer[y0][x0+1]		= color;
		y0++;
		rgbBuffer[y0][x0-1]		= color;
		rgbBuffer[y0][x0]		= color;
		rgbBuffer[y0][x0+1]		= color;
		y0++;
		rgbBuffer[y0][x0-1]		= color;
		rgbBuffer[y0][x0]		= color;
		rgbBuffer[y0][x0+1]		= color;
	}
}





void render_polyoutput_env()
{
	int i;
	int vt0,vt1,vt2;

	int u0,v0,u1,v1,u2,v2;
	int x0,y0,x1,y1,x2,y2;

	u32 color;
	PolyOut *polygon;


	qsort_polyoutput_list(0,polyoutput_amount-1);

	//for(i=polyoutput_amount-1;i>=0;i--)
	for(i=0;i<polyoutput_amount;i++)
	{
		polygon = polyoutput_Zsort_list[i].polygon;
		vt2 = polygon->v0;
		vt1 = polygon->v1;
		vt0 = polygon->v2;

		x0 = _2d_result[vt0][0]; y0 = _2d_result[vt0][1];
		x1 = _2d_result[vt1][0]; y1 = _2d_result[vt1][1];
		x2 = _2d_result[vt2][0]; y2 = _2d_result[vt2][1];

		u0 = _uv_result[vt0][0]; v0 = _uv_result[vt0][1];
		u1 = _uv_result[vt1][0]; v1 = _uv_result[vt1][1];
		u2 = _uv_result[vt2][0]; v2 = _uv_result[vt2][1];

		tri_map(	x0,y0, x1,y1, x2,y2,
 					u0,v0, u1,v1, u2,v2,
					(u32*)texture_tc_256x256,(u32*)rgbBuffer);
	}
}


void render_polyoutput_wire_hidden()
{
	int i;
	int vt0,vt1,vt2;

	u32 color;
	PolyOut *polygon;

	qsort_polyoutput_list(0,polyoutput_amount-1);

	
//	for(i=0;i<polyoutput_amount;i++)

	for(i=polyoutput_amount-1;i>=0;i--)
	{
		polygon = polyoutput_Zsort_list[i].polygon;
		vt0 = polygon->v0;
		vt1 = polygon->v1;
		vt2 = polygon->v2;
		
		//color = polygon->color;
		color = 0x000000;
		drawTri_flat(vt0,vt1,vt2, color);

		draw3v_lines(vt0,vt1,vt2);
	}
}

void swap_xia()
{
	int i;
	double x,y,z;
	for(i=0;i<_3ds_vertices_amount;i++)
	{
		x = _3ds_vertices[i][0];
		y = _3ds_vertices[i][1];
		z = _3ds_vertices[i][2];
		_3ds_vertices[i][0] = x;
		_3ds_vertices[i][1] = z;
		_3ds_vertices[i][2] = y;
	}	
}


u8 buffer_3dout[2512000];
u8 *buffer_3doutPtr;

double x_scale_save = 512.f;
double y_scale_save = 512.f;
double z_scale_save = 512.f;

int save_3d_animation = 1;
int single_file_mode_save = 0;
int save_output		  = 0;

// ------------------------------------------------------------------------------
void write32_BE_3dout(int v)
{
	*buffer_3doutPtr++=(v>>24);
	*buffer_3doutPtr++=(v>>16);
	*buffer_3doutPtr++=(v>>8);
	*buffer_3doutPtr++=(v);
}
// ------------------------------------------------------------------------------
void write16_BE_3dout(int v)
{
	*buffer_3doutPtr++=(v>>8);
	*buffer_3doutPtr++=(v);
}
// ------------------------------------------------------------------------------
void output_3dout(double v, double scale)
{
	int vint;
	v*=scale;
	vint = (int)v;
	// write32_BE_3dout(vint);
	write16_BE_3dout(vint);
}
// ------------------------------------------------------------------------------
void check_minmax(double *val, double *min, double *max)
{
	double x = *val;
	if(x<*min) *min=x;
	if(x>*max) *max=x;
}
// ------------------------------------------------------------------------------

// verts: 181
// faces: 358

void copy_object_to_frame(int frame)
{
	int i;
	int v0,v1,v2;
	double x,y,z;
	double nx,ny,nz;

	double x_min =  8512000.f;
	double x_max = -8512000.f;
	double y_min =  8512000.f;
	double y_max = -8512000.f;
	double z_min =  8512000.f;
	double z_max = -8512000.f;

	double nx_min =  8512000.f;
	double nx_max = -8512000.f;
	double ny_min =  8512000.f;
	double ny_max = -8512000.f;
	double nz_min =  8512000.f;
	double nz_max = -8512000.f;

	_3ds_objinfo_frames[frame][0] = _3ds_vertices_amount;
	_3ds_objinfo_frames[frame][1] = _3ds_faces_amount;


if( (save_3d_animation==1) && (frames_used==0) ) // anim & 1st frame-->only 1 polylist
{
	//----------------------------------------------------------------
	// Faces
	write16_BE_3dout(_3ds_faces_amount);

	for(i=0;i<_3ds_faces_amount;i++)
	{
		v0 = _3ds_faces[i][0];
		v1 = _3ds_faces[i][1];
		v2 = _3ds_faces[i][2];
		_3ds_faces_frames[frame][i][0] = v0;
		_3ds_faces_frames[frame][i][1] = v1;
		_3ds_faces_frames[frame][i][2] = v2;
		/*
		write32_BE_3dout(v0);
		write32_BE_3dout(v1);
		write32_BE_3dout(v2);
		*/
		write16_BE_3dout(v0);
		write16_BE_3dout(v1);
		write16_BE_3dout(v2);
	}
	//----------------------------------------------------------------
}
	// Vertices
	write16_BE_3dout(_3ds_vertices_amount);

	for(i=0;i<_3ds_vertices_amount;i++)
	{
		x = _3ds_vertices[i][0]; // x
		y = _3ds_vertices[i][1]; // y
		z = _3ds_vertices[i][2]; // z

		x = scale_x_in*x;
		y = scale_y_in*y;
		z = scale_z_in*z;

		_3ds_vertices_frames[frame][i][0] = x; // x
		_3ds_vertices_frames[frame][i][1] = y; // y
		_3ds_vertices_frames[frame][i][2] = z; // z

		output_3dout(x, x_scale_save);
		output_3dout(y, y_scale_save);
		output_3dout(z, z_scale_save);

		check_minmax(&x, &x_min, &x_max);
		check_minmax(&y, &y_min, &y_max);
		check_minmax(&z, &z_min, &z_max);

		// Normals
		nx = _3ds_normals[i][0];	// nx
		ny = _3ds_normals[i][1];	// ny
		nz = _3ds_normals[i][2];	// nz

		_3ds_normals_frames[frame][i][0] = nx;	// nx
		_3ds_normals_frames[frame][i][1] = ny;	// ny
		_3ds_normals_frames[frame][i][2] = nz;	// nz	

		output_3dout(nx, 1);
		output_3dout(ny, 1);
		output_3dout(nz, 1);

		check_minmax(&nx, &nx_min, &nx_max);
		check_minmax(&ny, &ny_min, &ny_max);
		check_minmax(&nz, &nz_min, &nz_max);	
	}
	//----------------------------------------------------------------

	printf("\nx_min: %f", x_min);
	printf("x_max: %f", x_max);
	printf("\ny_min: %f", y_min);
	printf("y_max: %f", y_max);
	printf("\nz_min: %f", z_min);
	printf("z_max: %f", z_max);
	printf("\n");

	printf("\nnx_min: %f", nx_min);
	printf("nx_max: %f", nx_max);
	printf("\nny_min: %f", ny_min);
	printf("ny_max: %f", ny_max);
	printf("\nnz_min: %f", nz_min);
	printf("nz_max: %f", nz_max);
	printf("\n");

	//getch();

}



//QQQ
int init_test_effect()
{

	obj_reader( obj_fname );


//	make_normals_object();

	return 0;
}


//	DrawLineClipped(0,0, XW-1,YW-1,0x00ffffff);
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
int do_test_effect()
{
	static double f=0;
	double w,w2,w3;

	int i;
	double x,y,z;

	clip_2d_init(0,XW-1,0,YW-1);

	current_frame = 0;

	view_x_lt = 0;
	view_y_lt =	0;
	view_z_lt =	1800; //8000;

	yt_trans = 30; //100;


	camera_y = 0; // -1000;

	w  = 0.02f*f;
	w2 = 0.034*f;
	w3 = 0.0376*f;

	double amp1 = 500;
	double amp2 = 500;
/*
	camera_x = amp1*cos(w) + amp2*sin(w2);
	camera_z = amp1*sin(w) + amp2*sin(w3);
	yr = PI*sin(0.125*w) + PI*sin(0.125*w2);

	camera_y = -1500+1000*sin(w*1.123f);
	double xr_amp=0.3*PI;
	xr = -(xr_amp + 0.5*xr_amp*(sin(0.5*w2)+sin(0.125*w3) ));

	double s = 1.f;

	xr*=s;
	yr*=s;
*/

	camera_x = 0;
	camera_y = 0;
	camera_z = 0;


	xr = yr = zr = 0;

//	yr = 0.7f*sin(0.05f*f);
//	xr = 0.4f + 0.5f*cos(0.05f*f);


//	xr = deg2rad(90);
//	zr = 0.05f*f;

	yr = PI*sin(0.015f*f);
	xr = 0.6f + 0.25f*cos(0.025f*f);


	init_board();
	display_board();

	zf_scale = 2;


//	test_3ds_V2();


	view_y_lt = 300; //550;


	rotate_object();

//	display_vertices();

//	test_3d_wire_all();

	test_3d_filled();


	//xr = 0; // -PI/6.f;

//	yr+=0.0071f;
//	xr+=0.004f;

	f+=0.75f;

	return 0;
}



