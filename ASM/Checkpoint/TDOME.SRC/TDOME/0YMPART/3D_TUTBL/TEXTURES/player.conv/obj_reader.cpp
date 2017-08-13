//
//
// Wavefront OBJ reader
// (w)2104 lsl/checkpoint
//
//

#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <windows.h>

#include <math.h>

#include "filestuff.h"

#include "test_effect.h"

#include "bresenham_line.h"
#include "polygon_flat.h"

#include "tri_map_fixed.h"

#include "quicksort.h"

#include "board.h"
//------------------------------------------------------------


char st_output_fname[512] = "TRNTBL.ST3";


void save_ST_format();


double obj_scale_x = 700.f;
double obj_scale_y = 700.f;
double obj_scale_z = 700.f;


int obj_size;
char  *obj_alloc;
char  *obj;

int obj_frame;

int vertices_amount;
int vert_tex_amount;
int faces_amount;


char *vertices_start;



void skip_line()
{
	while(*obj!=0x0A)
	{
		if(*obj==0x0D) obj++; 		
		obj++;
	}
	obj++;
	if(*obj==0x0D) obj++; 
}


void skip_lines_until_id(char *id)
{
	char i0 = id[0];
	char i1 = id[1];
	int hit=0;
	do
	{
		hit = (obj[0]==i0) & (obj[1]==i1);
		if(hit==0) skip_line();
	}while(hit==0);
}

double read_obj_float()
{
	double v;
	double vi = 0;
	double vf = 0;
	double fract_power = 1;
	int sign=1;
	int digit;

	if(*obj=='-') { obj++; sign=-1; }

	// integer part
	do
	{
		vi*=10;
		digit = *obj++;
		vi+=digit-'0';
	}while(*obj!='.');
	obj++;	// skip '.'

	// fractional part
	do
	{
		fract_power*=10;
		vf*=10;
		digit = *obj++;
		vf+=digit-'0';
	}while( (*obj!=' ') && (*obj!=0x0A) );
	//while(*obj!=' ');
	obj++;	// skip ' '

	vf/=fract_power;

	v = vi+vf;
	if(sign==-1) v=-v;
	return v;
}

int read_obj_int()
{
	int v=0;
	int digit;
	do
	{
		v*=10;
		digit = *obj++;
		v+=digit-'0';
	}while( (*obj!='/') && (*obj!=' ') && (*obj!=0x0A) );
	obj++;	// skip terminal
	return v;
}

double deg2rad(double w)
{
	w = w*2.f*PI/360.f;
	return w;
}

int obj_reader(char *obj_fname)
{
	int i;
	int end_flag;

	printf("\nWavefront OBJ loader - (w)2014 lsl/checkpoint\n");


	obj_frame = 0;

	vertices_amount = 0;
	vert_tex_amount	= 0;
	faces_amount	= 0;

	xr = deg2rad( 0*45 );
	yr = deg2rad( 180 );
	zr = deg2rad( 0 );

	view_x_lt = 0.f;
	view_y_lt = 0.f;
	view_z_lt = 0.f;


	printf("\nOBJ: %s",obj_fname);
	obj_size = get_filesize(obj_fname);
	if(obj_size==-1) { printf("\n***ERROR***\n"); getch(); return -1; }
	printf("\n%i bytes",obj_size);

	obj_alloc = (char*)calloc(obj_size+16384, 1);
	load_file(obj_fname, (u8*)obj_alloc);
	obj = obj_alloc;

	skip_lines_until_id("v ");
	vertices_start = obj;

	//-----------------------------------------------------------------------
	// read vertices
	double x,y,z,t;
	printf("\n\nparsing vertices...\n");
	do
	{
		obj+=2;		// skip "v "
		x = read_obj_float();	
		y = read_obj_float();
		z = read_obj_float();
		obj--;	// whitespace skip from z

		printf("\n%f %f %f",x,y,z);


		rotate_xyz(&x,&y,&z);		


		x*=obj_scale_x;
		y*=obj_scale_y;
		z*=obj_scale_z;

		_3ds_vertices_frames[obj_frame][vertices_amount][0] = x;
		_3ds_vertices_frames[obj_frame][vertices_amount][1] = y;
		_3ds_vertices_frames[obj_frame][vertices_amount][2] = z;

		vertices_amount++;

		skip_line();
		end_flag = (obj[0]=='v') & (obj[1]==' ');
	}while(end_flag==1);

	printf("\n\n%i vertices",vertices_amount);

	//-----------------------------------------------------------------------
	// read vertex texture coordinates
	double u,v;
	printf("\n\nparsing texture coordinates...\n");
	do
	{
		obj+=3;		// skip "vt "
		u = read_obj_float();	
		v = 1.f - read_obj_float();
		obj--;	// whitespace skip from v

		printf("\n%f %f",u,v);

		u*=255.f;
		v*=255.f;

		_3ds_vt_frames[obj_frame][vert_tex_amount][0] = u;
		_3ds_vt_frames[obj_frame][vert_tex_amount][1] = v;

		vert_tex_amount++;

		skip_line();
		end_flag = (obj[0]=='v') & (obj[1]=='t') & (obj[2]==' ');
	}while(end_flag==1);

	printf("\n\n%i vert_tex",vert_tex_amount);

	//-----------------------------------------------------------------------
	// read faces
	skip_lines_until_id("f ");
	printf("\n\nparsing faces...\n");
	int v0,v1,v2;
	int vt0,vt1,vt2;
	do
	{
		obj+=2;		// skip "f "

		v0 = read_obj_int() -1;	
		vt0= read_obj_int() -1;		
		obj+=0;
		v1 = read_obj_int() -1;	
		vt1= read_obj_int() -1;		
		obj+=0;
		v2 = read_obj_int() -1;	
		vt2= read_obj_int() -1;		
		obj+=0;
		
		obj--;	// whitespace skip from v

		printf("\n%i/%i %i/%i %i/%i",v0,vt0, v1,vt1, v2,vt2);

		_3ds_faces_frames[obj_frame][faces_amount][0] = v0;
		_3ds_faces_frames[obj_frame][faces_amount][1] = v1;
		_3ds_faces_frames[obj_frame][faces_amount][2] = v2;

		_3ds_faces_tex_frames[obj_frame][faces_amount][0] = vt0;
		_3ds_faces_tex_frames[obj_frame][faces_amount][1] = vt1;
		_3ds_faces_tex_frames[obj_frame][faces_amount][2] = vt2;

		faces_amount++;

		skip_line();
		end_flag = (obj[0]=='f') & (obj[1]==' ');
	}while(end_flag==1);
	printf("\n\n%i faces",faces_amount);
	//-----------------------------------------------------------------------



	_3ds_objinfo_frames[obj_frame][0] = vertices_amount;
	_3ds_objinfo_frames[obj_frame][1] = faces_amount;	
	_3ds_objinfo_frames[obj_frame][2] = vert_tex_amount;
	 

	save_ST_format();
	
	free(obj_alloc);

	printf("\n\nDONE!");
//	getch();

	return 0;
}



u8 st_buffer[66000];
u8 *stp;
int st_size;

void w16(u32 v)  
{
	*stp++=v>>8;
	*stp++=v;
}
void w32(u32 v)  
{
	*stp++=v>>24;
	*stp++=v>>16;
	*stp++=v>>8;
	*stp++=v;
}


void save_ST_format()
{
	int i;
	int xi,yi,zi;
	int ui,vi;
	int v0,v1,v2;

	stp = st_buffer;

	obj_frame = 0;

	vertices_amount	= _3ds_objinfo_frames[obj_frame][0];
	faces_amount	= _3ds_objinfo_frames[obj_frame][1];	
	vert_tex_amount	= _3ds_objinfo_frames[obj_frame][2];

	//-----------------------------------------------------------------
	// vertices
	w32('VERT');
	w16(vertices_amount);
	for(i=0;i<vertices_amount;i++)
	{
		xi = _3ds_vertices_frames[obj_frame][i][0];
		yi = _3ds_vertices_frames[obj_frame][i][1];
		zi = _3ds_vertices_frames[obj_frame][i][2];
		w16(xi);
		w16(yi);
		w16(zi);
	}
	//-----------------------------------------------------------------

	//-----------------------------------------------------------------
	// vertices texture
	w32('VTEX');
	w16(vert_tex_amount);
	for(i=0;i<vert_tex_amount;i++)
	{
		ui = _3ds_vt_frames[obj_frame][i][0];
		vi = _3ds_vt_frames[obj_frame][i][1];
		w16(ui);
		w16(vi);
	}
	//-----------------------------------------------------------------

	//-----------------------------------------------------------------
	// faces
	w32('FACE');
	w16(faces_amount);
	for(i=0;i<faces_amount;i++)
	{
		// vertices
		v0 = _3ds_faces_frames[obj_frame][i][0];
		v1 = _3ds_faces_frames[obj_frame][i][1];
		v2 = _3ds_faces_frames[obj_frame][i][2];
		w16(v0);
		w16(v1);
		w16(v2);

		// vertices texture
		v0 = _3ds_faces_tex_frames[obj_frame][i][0];
		v1 = _3ds_faces_tex_frames[obj_frame][i][1];
		v2 = _3ds_faces_tex_frames[obj_frame][i][2];
		w16(v0);
		w16(v1);
		w16(v2);
	}


	st_size = stp-st_buffer;
	save_file(st_output_fname, st_buffer, st_size);
}





