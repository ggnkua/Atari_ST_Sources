
#ifndef __test_effect_h
#define __test_effect_h


#include "main.h"
#include "display.h"


int init_test_effect();
int do_test_effect();

void add_3ds_vertice(double x,double y,double z);
void add_3ds_face(int v0,int v1,int v2);


void rotate_xyz(double *xp,double *yp,double *zp);

void trans_3d_2d(double *xp,double *yp,double *zp);


#define MAX_FRAMES 256

// multiple objects
extern int		_3ds_objinfo_frames[MAX_FRAMES][16];
extern double	_3ds_vertices_frames[MAX_FRAMES][4096][3];
extern double	_3ds_vt_frames[MAX_FRAMES][4096][2];

extern int		_3ds_faces_frames[MAX_FRAMES][4096][3];
extern int		_3ds_faces_tex_frames[MAX_FRAMES][4096][3];

extern double   _3ds_normals_frames[MAX_FRAMES][4096][3];



extern int _3ds_vertices_amount;
extern int _3ds_faces_amount;
extern int _3ds_faces_base;
extern int _3ds_vertices_base;


extern double	_3ds_vertices[65536][3];
extern int		_3ds_faces[65536][3];
extern double   _3ds_normals[65536][3];


typedef struct vertex
{
	double xt,yt;
	double x,y,z;
	double nx,ny,nz;
	u32	color;
	double iso;
}vertex;


typedef struct PolyOut
{
	int v0,v1,v2;
	int vt0,vt1,vt2;	// texture vertex
	u32 color;
}PolyOut;


typedef struct PolyOut_Zsort
{
	int z_average;
	PolyOut *polygon;
}PolyOut_Zsort;


extern PolyOut_Zsort polyoutput_Zsort_list[565536];

extern PolyOut polyoutput_list[565536];


//------------------------------------
extern double proj_z;
extern double z_zoom;

extern double z_clip_min;


extern double zf_scale;

extern double view_x_lt;
extern double view_y_lt;
extern double view_z_lt;

extern double object_x;
extern double object_y;
extern double object_z;

extern double camera_x;
extern double camera_y;
extern double camera_z;

//------------------------------------
extern double xr;
extern double yr;
extern double zr;
//------------------------------------


#endif

