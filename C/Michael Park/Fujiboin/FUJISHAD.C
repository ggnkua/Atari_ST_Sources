/***************************************************************************/
/*                                                                         */
/*  FujiShade!  Written by Xanth Park.  23 Apr 86 (START mod: 27 Jun 86)   */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/***************************************************************************/
/*
 *      generates shading for fuji
 *      (probably a lot more work than it was worth)
 */

#include <osbind.h>

#define SHADOW          2
#define FACE            4
#define NEARSIDE        6
#define BARSIDE         8
#define FARSIDE         10
#define BARX            7.5 /* bar extends from -BARX to +BARX */
#define BACKDROPZ       60.0 /* distance to checkerboard (for shadow-casting) */
#define LITELEFT        11.25 /* lite source LITELEFT degs to left */
#define LITEELEV        10.0  /* lite source LITEELEV degs above horizon */
#define LITEBEER        tastes great
#define LITEBEER        less filling
#define pi              3.1415926536    /* pi */
#define deg             0.01745329252   /* pi/180. */
#define D2              7.85    /* 1/2*thickness of fuji */
#define XOFF            55.5

extern double sin(),cos(),exp(),log(),sqrt();

int
  contrl[12],intin[128],ptsin[128],intout[128],ptsout[128], /* GEM globals */
  dummy,
  gfh;  /* G.F.Handle */

char shadbuff[72];      /* NEARSIDE colors... */

float atanxp[45];

typedef struct victor { float x,y,z; } vector;

double power( y, x ) double y,x;
{
  return( exp( x * log( y ) ) );
}

double tan( x ) double x;
{
  return( sin(x)/cos(x) );
}

int round( x ) float x;
{
  return( x + 0.5 );
}

main(){
  int
    intin[11],intout[57],
    view,
    fhandle,
    i;
  appl_init();
  gfh = graf_handle( &dummy, &dummy, &dummy, &dummy );
  for( i=0; i<10; i++ ) intin[i] = 1;
  intin[10] = 2;
  v_opnvwk( intin, &gfh, intout );
  v_hide_c( gfh );

  fhandle = Fcreate( "FUJISHAD.D8A", 0 );
  initatanxp();
  for( view=0; view<32; view++ ){
    fujishad( view );
    rite( fhandle, shadbuff );
  }/* for */
  Fclose( fhandle );
  v_clsvwk( gfh );
  appl_exit();
}/* main */

fujishad( view )
int view;
{
  int
    y;
  for( y=0; y<72; y++ ){
    shadbuff[ y ] = shad( y, view );
  }
}/* fujishad */

rite( fhandle, buff )
int fhandle, *buff;
{
  int i;
  Fwrite( fhandle, 72L, buff );
}/* rite */

#define A       2.2
#define Q       9.0
#define KD      0.7     /* diffuse component */
#define KS      0.3     /* specular component */
#define SPECN   5.0     /* specular n: cos^n( a ) */
#define NUMSHADES 255

shad( y, view )
int y, view;
{
  double
    in10sity,k,xp,cosa,cosi,rot,
    DotProd(),Norm();
  static vector
    L,R,S={ 0.0, 0.0, -1.0 };

  if( (y<16)||(y>60) ){
    xp = 0.0;
  }else{
    xp = atanxp[ y-16 ];
  }
  L.x = sin( LITELEFT*deg );
  L.z = cos( LITELEFT*deg );
  L.y = L.z * tan( LITEELEV*deg );
  rot = (double)view/32.0*pi;
  Rot8( &L.z, &L.x, pi/2.0-rot );
  Rot8( &L.y, &L.z, xp );
  R.x = L.x; R.y = L.y; R.z = -L.z;
  cosi = -DotProd( &L, &S ) / Norm( &L );
  Rot8( &R.y, &R.z, -xp );
  Rot8( &R.z, &R.x, rot-pi/2.0 );
  cosa = DotProd( &R, &S ) / Norm( &R );
  if( cosa >= 0.0 )
    cosa=power( cosa, SPECN );
  else
    cosa = 0.0;
  in10sity = KD*cosi + KS*cosa;
  if( cosi < 0.0 ) in10sity = 0;
  return( (int)(NUMSHADES * in10sity) );
}/* shad */

double DotProd( u, v )
vector *u,*v;
{
  return( u->x * v->x + u->y * v->y + u->z * v->z );
}

double Norm( u )
vector *u;
{
  return( sqrt( DotProd( u, u )));
}

Rot8( u, v, t )
double *u,*v,t;
{
  double temp;
  temp = *u * cos(t) - *v * sin(t);
  *v = *u * sin(t) + *v * cos(t);
  *u = temp;
}/* Rot8 */

initatanxp()
{
  atanxp[ 0 ] = .173688 ;  atanxp[ 1 ] = .180495 ;  atanxp[ 2 ] = .188077 ;
  atanxp[ 3 ] = .195825 ;  atanxp[ 4 ] = .203744 ;  atanxp[ 5 ] = .211839 ;
  atanxp[ 6 ] = .220114 ;  atanxp[ 7 ] = .228575 ;  atanxp[ 8 ] = .238687 ;
  atanxp[ 9 ] = .249067 ;  atanxp[ 10 ] = .258183 ;  atanxp[ 11 ] = .267507 ;
  atanxp[ 12 ] = .280273 ;  atanxp[ 13 ] = .290104 ;  atanxp[ 14 ] = .301862 ;
  atanxp[ 15 ] = .313938 ;  atanxp[ 16 ] = .328141 ;  atanxp[ 17 ] = .34093 ;
  atanxp[ 18 ] = .354068 ;  atanxp[ 19 ] = .369522 ;  atanxp[ 20 ] = .385458 ;
  atanxp[ 21 ] = .40189 ;  atanxp[ 22 ] = .418832 ;  atanxp[ 23 ] = .4363 ;
  atanxp[ 24 ] = .454306 ;  atanxp[ 25 ] = .47759 ;  atanxp[ 26 ] = .496853 ;
  atanxp[ 27 ] = .521747 ;  atanxp[ 28 ] = .547562 ;  atanxp[ 29 ] = .574315 ;
  atanxp[ 30 ] = .602018 ;  atanxp[ 31 ] = .630677 ;  atanxp[ 32 ] = .660293 ;
  atanxp[ 33 ] = .697086 ;  atanxp[ 34 ] = .735224 ;  atanxp[ 35 ] = .774666 ;
  atanxp[ 36 ] = .822246 ;  atanxp[ 37 ] = .871384 ;  atanxp[ 38 ] = .929231 ;
  atanxp[ 39 ] = .988574 ;  atanxp[ 40 ] = 1.04904 ;  atanxp[ 41 ] = 1.14092 ;
  atanxp[ 42 ] = 1.23286 ;  atanxp[ 43 ] = 1.33815 ;  atanxp[ 44 ] = 1.56056 ;
/*
 *      no, I didn't type all those numbers; the table was generated
 *      by a BASIC program which I seem to have lost...
 *      So, why didn't I just do the whole thing in BASIC?  Well,
 *      if I had known how uncooperative this C compiler was going
 *      to be, I would have...
 */

}/* initatanxp */

