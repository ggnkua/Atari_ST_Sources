#include <stdio.h>
#include <stdlib.h>
#include <math.h>
//#include <signal.h>
//#include <sys/time.h>
#include <string.h>
#include <vdi.h>

#define arraysize(X)	(sizeof(X) / sizeof((X)[0]))


typedef struct {
  int colour;
  int x1, y1, z1;
  int x2, y2, z2;
} LineVectorObject;

typedef struct {
  int colour;
  int x1, y1, z1;
  int x2, y2, z2;
  int x3, y3, z3;
  int x4, y4, z4;
} PlaneVectorObject;

typedef struct {
  int colour;
  int size;
  int x, y, z;
} PointVectorObject;


void init_graph( void );
void deinit_graph( void );
void main_loop( void );
void draw_frame( void );
void draw_vector_line( LineVectorObject * );
void draw_vector_point( PointVectorObject * );
void draw_vector_plane( PlaneVectorObject *obj);
void init_vector_points( void );
void calc_vector_point( PointVectorObject * );
void draw_vector_points( void );
void precalc_3d( short, short, short );
void project_point( int, int, int, int *, int *, int * );

#define X 0
#define Y 1
#define W 2
#define H 3

#define X1 0
#define Y1 1
#define X2 2
#define Y2 3

short appl_id , graph_id;
short work_in[11], work_out[57];
short xy[10],screenx,screeny,screenw,screenh;
long Sin[]={0,268,572,857,1143,1428,1713,1997,2280,2563,
            2845,3126,3406,3686,3964,4240,4516,4790,5063,5334,
            5604,5872,6138,6402,6664,6924,7182,7438,7692,7943,
            8192,8438,8682,8923,9162,9397,9630,9860,10087,10311,
            10531,10749,10963,11174,11381,11585,11786,11982,12176,12365,
            12551,12733,12911,13085,13255,13421,13583,13741,13894,14044,
            14189,14330,14466,14598,14726,14849,14962,15082,15191,15296,
            15396,15491,15582,15668,15749,15826,15897,15964,16026,16083,
            16135,16182,16225,16262,16294,16322,16344,16362,16374,16382,
            16384};

int main( void )
{
  init_graph();

  main_loop();

  deinit_graph();
  return 0;
}


void init_graph( void )
{
  appl_id=appl_init();
  work_in[0]=1;
  work_in[1]=0;
  work_in[2]=1;
  work_in[3]=0;
  work_in[4]=0;
  work_in[5]=0;
  work_in[6]=1;
  work_in[7]=1;
  work_in[8]=0;
  work_in[9]=0;
  work_in[10]=2;
  graph_id=appl_id;
  v_opnvwk(work_in,&graph_id,work_out);
  screenx=0;
  screeny=0;
  screenw=work_out[0];
  screenh=work_out[1];
  graf_mouse(256,0);
}

void deinit_graph( void )
{
  v_clsvwk(graph_id);
  graf_mouse(257,0);
  appl_exit();
}

void main_loop( void )
{
  xy[ Y2 ] = screenh + screeny ;
  xy[ Y1 ] = screeny ;
  xy[ X2 ] = screenw + screenx ;
  xy[ X1 ] = screenx ;
  vr_recfl(graph_id,xy);
  for( ;; ) 
  {

    draw_frame();

//    if(kbhit())
    if(getch()==27)
      break;
  }
}

PlaneVectorObject walls[]= {
  /* Left side */
  { 1, -60, 60, 60,		-60, -60, 60,	-60, -60, -60,	-60, 60, -60},
  /* Right side */
  { 1, 60, 60, 60,		60, -60, 60,	60, -60, -60,	60, 60, -60},
  /* Top side */
  { 1, -60, 60, 60,		-60, -60, 60,	60, -60, 60,	60, 60, 60},
  /* bottom Side */
  { 1, -60, 60, -60,		-60, -60, -60,	60, -60, -60,	60, 60, -60},
};

LineVectorObject cube[] = {
  /* front */
  { 1,	-60, -60, -60,	60, -60, -60 },
  { 2,	60, -60, -60,	60, 60, -60 },
  { 3,	60, 60, -60,	-60, 60, -60 },
  { 4,	-60, 60, -60,	-60, -60, -60 },

  /* middle */
  { 5,	-60, -60, 60,	60, -60, 60 },
  { 6,	60, -60, 60,	60, 60, 60 },
  { 7,	60, 60, 60,		-60, 60, 60 },
  { 8,	-60, 60, 60,	-60, -60, 60 },

  /* joining lines */
  { 1,	-60, -60, -60,	-60, -60, 60 },
  { 2,	60, -60, -60,	60, -60, 60 },
  { 3,	60, 60, -60,	60, 60, 60 },
  { 4,	-60, 60, -60,	-60, 60, 60 },
};

#define BS 200

PointVectorObject points[] = {
  { 1,	BS,	-60, -60, -60 },
  { 2,	BS,	60, -60, -60 },
  { 3,	BS,	60, 60, -60 },
  { 4,	BS,	-60, 60, -60 },
  { 5,	BS,	-60, -60, 60 },
  { 6,	BS,	60, -60, 60 },
  { 7,	BS,	60, 60, 60 },
  { 8,	BS,	-60, 60, 60 },
};


void draw_frame( void )
{
  int c;
  static short v1 = 0, v2 = 0, v3 = 0;

  vsl_color(graph_id,0);
//  for( c = 0 ; c < arraysize( cube ) ; c++ )
//  {
//    draw_vector_line( &cube[ c ] );
//  }
  for( c = 0 ; c < arraysize( walls ) ; c++ )
  {
    draw_vector_plane( &walls[ c ] );
  }
  v1 += 1;
  v2 += 2;
  v3 += 3;

  if( v1 >= 360 )	v1 -= 360;
  if( v2 >= 360 )	v2 -= 360;
  if( v3 >= 360 )	v3 -= 360;

  
  precalc_3d( v1, v2, v3 );
  
//  for( c = 0 ; c < arraysize( cube ) ; c++ )
//  {
//    vsl_color(graph_id,cube[ c ].colour);
//    draw_vector_line( &cube[ c ] );
//  }

  for( c = 0 ; c < arraysize( walls ) ; c++ )
  {
    vsl_color(graph_id,walls[ c ].colour);
    draw_vector_plane( &walls[ c ] );
  }

//  init_vector_points();
//  for( c = 0 ; c < arraysize( points ) ; c++ ) {
//    calc_vector_point( &points[ c ] );
//  }
//  draw_vector_points();
}

void draw_vector_line( LineVectorObject *obj )
{
  int x1,y1,x2,y2;
  int dummy;

  project_point( obj->x1, obj->y1, obj->z1, &x1, &y1, &dummy );
  project_point( obj->x2, obj->y2, obj->z2, &x2, &y2, &dummy );
  xy[X1]=x1;
  xy[X2]=x2;
  xy[Y1]=y1;
  xy[Y2]=y2;
  v_pline(graph_id,2,xy);

}

void draw_vector_plane( PlaneVectorObject *obj)
{
  int x1,x2,x3,x4,y1,y2,y3,y4;
  int dummy;
  project_point( obj->x1, obj->y1, obj->z1, &x1, &y1, &dummy );
  project_point( obj->x2, obj->y2, obj->z2, &x2, &y2, &dummy );
  project_point( obj->x3, obj->y3, obj->z3, &x3, &y3, &dummy );
  project_point( obj->x4, obj->y4, obj->z4, &x4, &y4, &dummy );
  xy[0]=x1;
  xy[2]=x2;
  xy[4]=x3;
  xy[6]=x4;
  xy[8]=x1;
  xy[1]=y1;
  xy[3]=y2;
  xy[5]=y3;
  xy[7]=y4;
  xy[9]=y1;
  v_pline(graph_id,5,xy);
  xy[2]=x3;
  xy[3]=y3;
  v_pline(graph_id,2,xy);
  xy[0]=x2;
  xy[1]=y2;
  xy[2]=x4;
  xy[3]=y4;
  v_pline(graph_id,2,xy);
}

typedef struct {
  int colour;
  int size;
  int sx, sy, sz;
} PointlistEntry;

static PointlistEntry pointlist[ 1000 ];
static int num_points = 0;

void init_vector_points( void )
{
  num_points = 0;
}

void calc_vector_point( PointVectorObject *obj )
{
  int x1, y1, z1;

  project_point( obj->x, obj->y, obj->z, &x1, &y1, &z1 );
  pointlist[ num_points ].colour = obj->colour;
  pointlist[ num_points ].size = obj->size;
  pointlist[ num_points ].sx = x1;
  pointlist[ num_points ].sy = y1;
  pointlist[ num_points ].sz = z1;
  num_points++;
}

int compare_point( const void *obj1, const void *obj2 )
{
  PointlistEntry *point1 = (PointlistEntry *)obj1;
  PointlistEntry *point2 = (PointlistEntry *)obj2;

  if( point1->sz < point2->sz ) {
    return -1;
  }
  else if( point1->sz > point2->sz ) {
    return 1;
  }
  else {
    return 0;
  }
}

void draw_vector_points( void )
{
  int c;
  int width;

  qsort( pointlist, num_points, sizeof( PointlistEntry ), compare_point );

  for( c = 0 ; c < num_points ; c++ )
  {
    width = pointlist[ c ].size / ((400 - (pointlist[ c ].sz + 200)) /
				   400.0 + 1);
    /*    XFillArc( display, draw_buf, colour_gcs[ pointlist[ c ].colour ],
	      pointlist[ c ].sx - width / 2, pointlist[ c ].sy - width / 2,
	      width, width, 0, 360 * 64 );*/
    /*    XFillArc( display, draw_buf, colour_gcs[ pointlist[ c ].colour ],
	      pointlist[ c ].sx - width / 2, pointlist[ c ].sy - width / 2,
	      width, width, 0, 360 * 64 );*/
  }
}
  

void draw_vector_point( PointVectorObject *obj )
{
  int x1, y1, z1;
  int width;

  project_point( obj->x, obj->y, obj->z, &x1, &y1, &z1 );

  width = obj->size / ((400 - (z1 + 200)) / 400.0 + 1);

  /* XFillArc( display, draw_buf, colour_gcs[ obj->colour ],
	    x1 - width / 2, y1 - width / 2,
	    width, width, 0, 360 * 64 ); */
}




/*
 *       x * (           cy*cz           cy*sz     sy )
 *                         +               +       +
 *       y * (  sx*sy*cz-cx*sz  sx*sy*sz+cx*cz -sx*cy )
 *                         +               +       +
 *       z * ( -sy*cx*cz-sx*sz -sy*cx*sz+sx*cz  cx*cy )
 *                         =               =       =
 *                        x1              y1      z1
 */

#define PERSP_RHO	400.0
#define PERSP_D		250.0

static long pre_3d[ 3 ][ 3 ];

void precalc_3d( short v1, short v2, short v3 )
{
  long sx,cx,sy,cy,sz,cz;
  if(v1>270)
  {
    sx=-Sin[360-v1];   // 90 0       -1  0
    cx=Sin[v1-270];    // 0  90       0  1
  }
  else if(v1>180)
  {
    sx=-Sin[v1-180];   // 0  90       0 -1
    cx=-Sin[270-v1];   // 90 0        -1 0 
  }
  else if(v1>90)
  {
    sx=Sin[180-v1];    // 90 0        1  0
    cx=-Sin[v1-90];    // 0  90       0 -1
  }
  else
  {
    sx=Sin[v1];        // 0 90        0  1
    cx=Sin[90-v1];    // 90 0        1  0
  }
  if(v2>270)
  {
    sy=-Sin[360-v2];   // 90 0       -1  0
    cy=Sin[v2-270];    // 0  90       0  1
  }
  else if(v2>180)
  {
    sy=-Sin[v2-180];   // 0  90       0 -1
    cy=-Sin[270-v2];   // 90 0        -1 0 
  }
  else if(v2>90)
  {
    sy=Sin[180-v2];    // 90 0        1  0
    cy=-Sin[v2-90];    // 0  90       0 -1
  }
  else
  {
    sy=Sin[v2];        // 0 90        0  1
    cy=Sin[90-v2];    // 90 0        1  0
  }
  if(v3>270)
  {
    sz=-Sin[360-v3];   // 90 0       -1  0
    cz=Sin[v3-270];    // 0  90       0  1
  }
  else if(v3>180)
  {
    sz=-Sin[v3-180];   // 0  90       0 -1
    cz=-Sin[270-v3];   // 90 0        -1 0 
  }
  else if(v3>90)
  {
    sz=Sin[180-v3];    // 90 0        1  0
    cz=-Sin[v3-90];    // 0  90       0 -1
  }
  else
  {
    sz=Sin[v3];        // 0 90        0  1
    cz=Sin[90-v3];    // 90 0        1  0
  }
  pre_3d[ 0 ][ 0 ] = cy * cz;
  pre_3d[ 0 ][ 1 ] = cy * sz;
  pre_3d[ 0 ][ 2 ] = sy;
  pre_3d[ 1 ][ 0 ] = sx * sy * cz - cx * sz;
  pre_3d[ 1 ][ 1 ] = sx * sy * sz + cx * cz;
  pre_3d[ 1 ][ 2 ] = -sx * cy;
  pre_3d[ 2 ][ 0 ] = -sy * cx * cz - sx * sz;
  pre_3d[ 2 ][ 1 ] = -sy * cx * sz + sx * cz;
  pre_3d[ 2 ][ 2 ] = cx * cy;
  printf("%d %d %d\n",pre_3d[0][0],pre_3d[0][1],pre_3d[0][2]);
  printf("%d %d %d\n",pre_3d[1][0],pre_3d[1][1],pre_3d[1][2]);
  printf("%d %d %d\n",pre_3d[2][0],pre_3d[2][1],pre_3d[2][2]);
}


void project_point( int x, int y, int z, int *sx, int *sy, int *sz )
{
  long tx, ty, tz;
  double persp_factor;
  static int max_sz = -100000, min_sz = 100000;

  tx = (x * pre_3d[ 0 ][ 0 ] +
	y * pre_3d[ 1 ][ 0 ] +
	z * pre_3d[ 2 ][ 0 ]);

  ty = (x * pre_3d[ 0 ][ 1 ] +
	y * pre_3d[ 1 ][ 1 ] +
	z * pre_3d[ 2 ][ 1 ]);

  tz = (x * pre_3d[ 0 ][ 2 ] +
	y * pre_3d[ 1 ][ 2 ] +
	z * pre_3d[ 2 ][ 2 ]);
  
  persp_factor = (PERSP_RHO + tz) / PERSP_D;

  *sx = (trunc(tx * persp_factor))>>14;
  *sy = (trunc(ty * persp_factor))>>14;
  *sz = (trunc(tz * persp_factor))>>14;
printf("%d %d %d\n",*sx,*sy,*sz);
  *sx=*sx;
  *sy=*sy;
  *sz=*sz;
  *sx += screenw / 2;
  *sy += screenh / 2;


  if( *sz < min_sz )  min_sz = *sz;
  if( *sz > max_sz )  max_sz = *sz;

}