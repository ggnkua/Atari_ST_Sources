/***************************************************************************/
/*                                                                         */
/*  FujiDraw!   Written by Xanth Park.  23 Apr 86 (START mod: 27 Jun 86)   */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/***************************************************************************/
/*
 *      draw the fuji
 *
 *      32 images of fuji and shadow
 *      NOTE: run in lo-rez
 */

#include <osbind.h>

extern double sin(),cos();

int
  contrl[12],intin[128],ptsin[128],intout[128],ptsout[128], /* GEM globals */
  dummy,
  gfh;  /* G.F.Handle */

static int
  xmin,ymin,xmax,ymax,fxmax,fxmin,
  pixel[]={ 0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 1 };

typedef struct pernt { float x,y,z; } punkt;

double tan( a ) double a;
{
  return( sin( a )/cos( a ) );
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

  fhandle = Fcreate( "FUJIDRAW.D8A", 0 );
  for( view=0; view<32; view++ ){
    v_clrwk( gfh );
    xmin = 999; ymin = 999; xmax = 0; ymax = 0; fxmin = 999; fxmax = 0;
    fujidraw( view );
    rite( fhandle, (int)(xmin/16), (int)(xmax/16), ymax );
  }/* for */
  Fclose( fhandle );
  v_clsvwk( gfh );
  appl_exit();
}/* main */

#define SHADOW          2
#define FACE            4
#define NEARSIDE        6
#define BARSIDE         8
#define FARSIDE         10
#define BARX            7.5 /* bar extends from -BARX to +BARX */
#define BACKDROPZ       60.0 /* distance to checkerboard (for shadow-casting) */
#define LITELEFT        11.25 /* lite source LITELEFT degs to left */
#define LITEELEV        10.0  /* lite source LITEELEV degs above horizon */
#define deg             0.01745329252   /* pi/180. */
#define D2              7.85    /* 1/2*thickness of fuji */
#define XOFF            55.5

fujidraw( view )
int view;
{
  int
    y;
  float
    s,t;
  static int
    st[]={
      10,17,10,17,10,17,10,17,10,17,10,17,10,17,10,17,
      10,17,10,17,10,17,10,17,10,17,10,17,10,17,10,17,
      10,17,10,17,10,17,10,18,10,18,10,18,10,18,10,18,
      10,18,10,18,10,19,10,19,10,19,10,19,10,20,10,20,
      10,20,11,20,11,21,11,21,11,21,12,22,12,22,12,23,
      12,23,12,24,13,24,13,25,14,25,14,26,14,27,15,27,
      15,28,16,29,16,30,17,31,17,32,18,33,18,34,19,35,
      20,37,21,39,21,41,22,45,23,51,24,51,25,51,26,51,
      27,51,28,51,30,51,32,51,34,51,36,51,40,51,44,51
    };

  for( y=0; y<72; y++ ){
    s = st[ y+y ]+0.5; t = st[ y+y+1 ]+0.5;
    section( -t, -s, (float)y, FARSIDE, view, 0 );
    section( -BARX, BARX, (float)y, BARSIDE, view, 1 );
    section( s, t, (float)y, NEARSIDE, view, 2 );
  }
}/* fujidraw */

static int ix;

section( u0, u1, why, sidecolor, view, sect )
float
  u0,u1,why;
int
  sidecolor,view,sect;
{
  punkt p[4],q;
  double c,s,dz,ftemp,rot;
  int i,pxy[8],oldpxy[3][8];

  p[0].x = u0;  p[0].y = why;   p[0].z = -D2;
  p[1].x = u1;  p[1].y = why;   p[1].z = -D2;
  p[2].x = u1;  p[2].y = why;   p[2].z = D2;
  p[3].x = u0;  p[3].y = why;   p[3].z = D2;
  rot = (view*180.0/32.0)*deg;
  s = sin( rot ); c = cos( rot );
  ix = ( ( view < 7 ) ? ( view + 25 ) : ( view - 7 ) ) * 2 - 10;
  for( i=0; i<4; i++ ){
    ftemp = p[i].x*c + p[i].z*s;
    p[i].z = -p[i].x*s + p[i].z*c; p[i].x = ftemp;
    dz = BACKDROPZ - p[i].z;
    q.x = p[i].x + dz*tan( LITELEFT*deg );
    q.y = p[i].y + dz*tan( LITEELEV*deg );
    pxy[i+i] = round( q.x+XOFF )+ix; pxy[i+i+1] = round( q.y );
    minmaxq( pxy[i+i], pxy[i+i+1] );
  }
  vsf_color( gfh, pixel[ SHADOW ] );
  v_fillarea( gfh, 4, pxy );
  if( why==0.0 ){
    for( i=0; i<8; i++ ) oldpxy[sect][i]=pxy[i];
  }
  shmooze( pxy, oldpxy[sect] );
  for( i=0; i<8; i++ ) oldpxy[sect][i]=pxy[i];
  hline( sidecolor, p[1].x, p[2].x, why );
  if( view < 16 ){
    hline( FACE, p[0].x, p[1].x, why );
  }else if( view > 16 ){
    hline( FACE, p[2].x, p[3].x, why );
  }/* if view=16 do nuthin' */
}/* section */

hline( color, x0, x1, y )
int color;
float x0,x1,y;
{
  int pxy[4];
  vsl_color( gfh, pixel[ color ] );
  pxy[0] = round( x0+XOFF )+ix; pxy[2] = round( x1+XOFF )+ix;
  pxy[1] = pxy[3] = round( y );
  minmaxq( pxy[0], pxy[1] );
  minmaxq( pxy[2], pxy[3] );
  if( pxy[0]<fxmin ) fxmin=pxy[0];
  if( pxy[2]<fxmin ) fxmin=pxy[2];
  if( pxy[0]>fxmax ) fxmax=pxy[0];
  if( pxy[2]>fxmax ) fxmax=pxy[2];
  v_pline( gfh, 2, pxy );
}/* hline */

minmaxq( x, y )
int x,y;
{
   if( x<xmin ) xmin=x;
   if( y<ymin ) ymin=y;
   if( x>xmax ) xmax=x;
   if( y>ymax ) ymax=y;
}/* minmaxq */

shmooze( a, b )
int *a,*b;
{
  blah( a, b, 0, 1 );
  blah( a, b, 1, 2 );
  blah( a, b, 2, 3 );
  blah( a, b, 3, 0 );
}/* shmooze */

blah( a, b, j, k )
int *a,*b,j,k;
{
  int i,pxy[8];
  pxy[0]=a[j+j]; pxy[1]=a[j+j+1];
  pxy[2]=a[k+k]; pxy[3]=a[k+k+1];
  pxy[4]=b[k+k]; pxy[5]=b[k+k+1];
  pxy[6]=b[j+j]; pxy[7]=b[j+j+1];
  v_fillarea( gfh, 4, pxy );
}/* blah */

rite( fhandle, u0, u1, v )
int fhandle,u0,u1,v;
{
  long
    bi,screen;
  int
    i,j,*p,buff[80];
  screen = Physbase();
  for( i=0; i<=v; i++ ){
    bi = 0;
    p = screen + 160*i + u0*8;
    for( j=u0; j<=u1; j++ ){
      p++;      /* skip bit plane 0 */
      buff[bi++] = *p; *p++ ^= 0xffff;  /* bit plane 1, complement
                                             for no real reason */
      buff[bi++] = *p; *p++ ^= 0xffff;  /* bit plane 2 */
      buff[bi++] = *p; *p++ ^= 0xffff;  /* bit plane 3 */
    }
   Fwrite(fhandle,bi*2L,buff);
  }
}/* rite */

