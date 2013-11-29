/*************** (c) 1995-2002, Trevor Blight ******************
*
*  $Id: glyph.c 1.12 2001/03/23 22:09:52 tbb Exp $
*
*
* This file is part of ttf-gdos.
*
* ttf-gdos is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*********************************************************************
*
* this file parses ttf glyph data and creates a gem bitmap or font header info
*
*  get the points defining outline curves for a glyph.
*  the glyph curves are converted into an (approximate) equivalent set of
*  straight lines.  From these lines, lists of on & off edges are generated.  
*  These edge lists are then used to generate gem bitmaps.
*
*  assumed format for gem bitmap font data is:
*	top, yMax must contain centre of top scan line
*	...
*	1
*	baseline
*	-1
*	...
*	-bottom, yMin must contain centre of bottom scan line
*
*	height = top + bottom + 1;
******************************************************************/

#include <osbind.h>

#define D_SHOW 0
#define G_SHOW 0

#include "ttf-gdos.h"
#include "ttf-defs.h"


#if !defined (GDOS)
   #include <stdio.h>
   #include <stdlib.h>
   #if G_SHOW
      #include <vdibind.h>
   #endif
#endif /* GDOS */

#include "ttf.h"

#if G_SHOW
#define gprintf(s) printf s
#else
#define gprintf(s)
#endif

typedef int16  tDot;	   /* dot coord, in pixels */

F26Dot6 yMax64, yMin64;	/* <<< bounds for current glyph */

/** make these globals to share with interpreter **/
F26Dot6 xppem64, yppem64;	/* pixels per M */

F26Dot6 fxScale64;   /* scale factor FUnits to dots * 64 */
F26Dot6 fyScale64;
static int16   fScaleShift;

static __inline__ F26Dot6
fx_to_dots64( FWord x )
{
register F26Dot6 r;
   __asm__ ( "muls %2,%0" : "=d"(r) : "0"(fxScale64), "mdi"(x) );
   assert( r == (x*fxScale64) );
   return r>>fScaleShift;
}

static __inline__ F26Dot6
fy_to_dots64( FWord y )
{
register F26Dot6 r;
   __asm__ ( "muls %2,%0" : "=d"(r) : "0"(fyScale64), "mdi"(y) );
   assert( r == (y*fyScale64) );
   return r>>fScaleShift;
}

#if V_SHOW
int pxyarray[500];
short xyi;
static __inline__ int vxscale( int x )
{
register int x1 = 100 + (x>>4);
   assert(x1 <= 640);
   return x1;
} /* vxscale() */

static __inline__ int vyscale( int y )
{
register int y1 = 300 - (y>>4);
   assert(y1 <= 400);
   return y1;
} /* vxscale() */
#endif V_SHOW

typedef struct {
   int16 on_index;
   int16 off_index;
} SCAN_HDR;

static SCAN_HDR *ppHead;        /* table of points for outline ppHead[-bottom] .. ppHead[top] */
static tGEM_FONT_HDR *gemFontp;	/* only used for assertions **/


/*** these arrays define the edge lists ***/

typedef struct {
   tDot  pos;
   int16 next;
} tEdge;

static uint16 nr_scan_points;
static tEdge *on, *off;
static int16 on_index;
static int16 off_index;

static enum { off_edge=-1, nil_edge=0, on_edge=1 } prev_edge, first_edge;
#define is_off_edge(e) (e<0)
#define is_on_edge(e)  (e>0)
#define is_nil_edge(e) (e==0)

/******************
*  get the coordinates of the defining points for the glyf
*  coordp points to the glyph coordinate data
*  put the reults in point array, assume point[-1] is origin
*  np is number of points
******************/
static void get_points( const BYTE *coordp, point_Rec point[], const int np )
{
BYTE  nf = 0;
register int j;
register point_Rec *p;
register uint16 t;   

   for( j=np, p=point; j>0; j--, p++ ) {
      if( nf == 0 ) {
	 p->flags = *coordp++;
	 if( p->flags & 8 ) {
	    nf = *coordp++;
	 } /* if */
      }
      else {
	 nf--;
	 p->flags = p[-1].flags;
      } /* if */
   } /* for */
   
   for( j=np, p=point; j>0; j--, p++ ) {
      if( (p->flags & 2) != 0 ) {
	 p->xcoord =  *coordp++;
	 if( (p->flags & 16) == 0) {
	    p->xcoord = -p->xcoord;
	 } /* if */
	 p->xcoord += p[-1].xcoord;
   
      }
      else if( (p->flags & 16) == 0) {
	 t = *coordp++ << 8;
	 t += *coordp++;
	 p->xcoord = t + p[-1].xcoord;
      } 
      else {
	 p->xcoord = p[-1].xcoord;  /* xcoord same */
      } /* if */
   } /* for */
   
   for( j=np, p=point; j>0; j--, p++ ) {
      if( (p->flags & 4) != 0 ) {
	 p->ycoord =  *coordp++;
	 if( (p->flags & 32) == 0) {
	    p->ycoord = -p->ycoord;
	 } /* if */
	 p->ycoord += p[-1].ycoord;
      }
      else if( (p->flags & 32) == 0) {
	 t = *coordp++ << 8;
	 t += *coordp++;
	 p->ycoord = t + p[-1].ycoord;
      } 
      else {
	 p->ycoord = p[-1].ycoord;  /* ycoord same */
      } /* if */
   } /* for */

} /* get_points() */


/************************************
* 
*  add_points() -- add points from line (x1,y1) .. (x2,y2) to edge list
*  
*  since x2 is x1 for next line segment, we
*  include x1 in line and exclude x2 to save duplicating points
*  - if next line reverses direction, no need for x1 in next line because
*    the on edge & off edge coincide, and cancel each other
*  - left end of horizontal line is on edge, right end is off edge
*  - start of contour needs separate processing
*  
*  use a bresenham type algorithm co create dot positions
*  
***/

static void add_last_off( const PCOORD x2, const PCOORD y2 )
{
register const tDot x0 = ((x2+31) & ~63)>>6;
register int16 i;
int16 qi;
int16 *pi = &ppHead[y2>>6].off_index;

   dprintf(( "add last off point, x2 y2 is %x %x\n", (int)x2, (int)y2 ));
   assert( (y2&63) == 32 );
   assert( y2>>6 >= -gemFontp->bottom );
   assert( y2>>6 <= gemFontp->top );
   while( ((i=*pi) != -1) && (off[i].pos > x0) ) {
      assert( (unsigned)i < nr_scan_points );
      assert( (unsigned)i <= off_index );
      assert( off[i].next == -1 || off[i].pos >= off[off[i].next].pos );
      pi = &off[i].next;
      assert( *pi==(unsigned)(-1) || *pi < nr_scan_points );
   } /* while */

   if( off_index < nr_scan_points ) {
      *pi = qi = off_index;
      off_index++;
      off[qi].pos = x0;
      off[qi].next = i;
      assert( off[qi].next == -1 || off[qi].pos >= off[i].pos );
   } /* if */
   gprintf(( "add last off point @ %d, %d.5, off index is %d\n", x0, y2>>6, (int)qi ));
} /* add_last_off() */


static void add_last_on( const PCOORD x2, const PCOORD y2 )
{
register const tDot x0 = ((x2+31) & ~63)>>6;
register int16 i;
int16 qi;
int16 *pi = &ppHead[y2>>6].on_index;
   dprintf(( "add last on point, x2 y2 is %x %x\n", (int)x2, (int)y2 ));
   assert( (y2&63) == 32 );
   assert( y2>>6 >= -gemFontp->bottom );
   assert( y2>>6 <= gemFontp->top );
   while( ((i=*pi) != -1) && (on[i].pos > x0) ) {
      assert( (unsigned)i < nr_scan_points );
      assert( (unsigned)i <= on_index );
      assert( on[i].next == -1 || on[i].pos >= on[on[i].next].pos );
      pi = &on[i].next;
      assert( *pi==(unsigned)(-1) || *pi < nr_scan_points );
   } /* while */

   if( on_index < nr_scan_points ) {
      *pi = qi = on_index;
      on_index++;
      on[qi].pos = x0;
      on[qi].next = i;
      assert( on[qi].next == -1 || on[qi].pos >= on[i].pos );
   } /* if */
   gprintf(( "add last on point @ %d, %d.5, off index is %d\n", x0, y2>>6, (int)qi ));
} /* add_last_on() */


static void add_points( const PCOORD x1, const PCOORD y1, const PCOORD x2, const PCOORD y2 )
{
PCOORD  y0;
register int32  dxy;
register tDot x0;
register int16 i;
int16 qi;
int16 *pi;

   assert( y1 <= yMax64 );
   assert( y1 >= yMin64 );
   assert( y2 <= yMax64 );
   assert( y2 >= yMin64 );

   dprintf(( "line from (%d,%d) to (%d,%d)\n", (int)x1, (int)y1, (int)x2, (int)y2 ));
   x0 = ((x1+31) & ~63);	/* dot that includes the line at x1 */
   assert( x1 > x0-32 );
   assert( x1 <= x0+32 );
   if( y2 > y1 ) {
      /* +ve gradient ==> on points */
      y0 = ((y1+31)&~63) + 32;	/* centre of next scan line */
      assert( y0 >= y1 );
      assert( y0 < y1+64 );
      if( y0==y1 ) {
         if( !is_on_edge(prev_edge) ) y0+=64;	/* x1 not needed */
	 if( prev_edge == nil_edge ) {
	    assert( is_nil_edge(first_edge) );
	    first_edge = on_edge;
	    dprintf(( "omit first on point, x1 y1 is %x %x\n", (int)x1, (int)y1 ));
	 } /* if */
      } /* if */
      prev_edge = on_edge;
      if( y0 < y2 ) {
         dxy = ((int32)(y2-y1)*(x1-x0+32) + (int32)(y0-y1)*(x2-x1))>>6;
	 x0 >>= 6;	/* make a dot position */
	 do {
	    /* add (x0, y0) to list of on points */

	    while( dxy >= y2-y1 ) {
	       x0++;
	       dxy -= y2-y1;
	    } /* while */
	    while( dxy < 0 ) {
	       x0--;
	       dxy += y2-y1;
	    } /* while */

	    assert( dxy >= 0 );
	    assert( dxy < y2-y1 );
	    assert( (int32)(x2-x1)*(y0-y1) >=  (int32)(y2-y1)*((x0*64)-32-x1)+dxy*64 );
	    assert( (int32)(x2-x1)*(y0-y1) < (int32)(y2-y1)*((x0*64)-32-x1)+(dxy+1)*64 );
	    assert( (y0>>6) >= -gemFontp->bottom );
	    assert( (y0>>6) <= gemFontp->top );

	    if( (y0>>6) > gemFontp->top || (y0>>6) < -gemFontp->bottom ) break;
	    pi = &ppHead[y0>>6].on_index;
	    while( ((i=*pi) != -1) && (on[i].pos > x0) ) {
	       assert( (unsigned)i < nr_scan_points );
	       assert( (unsigned)i <= on_index );
	       assert( on[i].next == -1 || on[i].pos >= on[on[i].next].pos );
	       pi = &on[i].next;
	       assert( *pi==(unsigned)(-1) || *pi < nr_scan_points );
	    } /* while */
   
	    if( on_index < nr_scan_points ) {
	       *pi = qi = on_index;
	       on_index++;
	       on[qi].pos = x0;
	       on[qi].next = i;
	       assert( on[qi].next == -1 || on[qi].pos >= on[i].pos );
	    } /* if */
	    dprintf(( "add on point @ %d, %d.5, on index is %d\n", x0, y0>>6, (int)qi ));

	    y0 += 64;	   /* pixel coord of next scan line */
	    dxy += x2-x1;
	 } while( y0 < y2 );
      }
      else {
         gprintf(( "saved processing\a\n!" ));
      } /* if */
   }
   else if( y2 < y1 ) {
      /* -ve gradient ==> off points */
      y0 = ((y1-32)&~63) + 32;      	/* centre of scan line */
      assert( y0 <= y1 );
      assert( y0 > y1-64 );
      if( y0==y1 ) {
         if( !is_off_edge(prev_edge)  ) y0-=64;	/* x1 not needed */
	 if( prev_edge == nil_edge ) {
	    assert( is_nil_edge(first_edge) );
	    first_edge = off_edge;
	    dprintf(( "omit first off point, x1 y1 is %x %x\n", (int)x1, (int)y1 ));
	 } /* if */
      } /* if */
      prev_edge = off_edge;
      if( y0 > y2 ) {
	 dxy = ((int32)(x1-x0+32)*(y2-y1) + (int32)(y0-y1)*(x2-x1))>>6;
	 x0 >>= 6;	/* make a dot position */
	 do {
	    /* add (x0, y0) to list of off points */

	    while( dxy <= y2-y1 ) {
	       x0++;
	       dxy -= y2-y1;
	    } /* while */
	    while( dxy > 0 ) {
	       x0--;
	       dxy += y2-y1;
	    } /* while */

	    assert( dxy <= 0 );
	    assert( dxy > y2-y1 );
	    assert( (int32)(x2-x1)*(y0-y1) >=  (int32)(y2-y1)*((x0*64)-32-x1)+dxy*64 );
	    assert( (int32)(x2-x1)*(y0-y1) < (int32)(y2-y1)*((x0*64)-32-x1)+(dxy+1)*64 );
	    assert( (y0>>6) >= -gemFontp->bottom );
	    assert( (y0>>6) <= gemFontp->top );

	    if( (y0>>6) > gemFontp->top || (y0>>6) < -gemFontp->bottom ) break;
	    pi = &ppHead[y0>>6].off_index;
	    while( ((i=*pi) != -1) && (off[i].pos > x0) ) {
	       assert( (unsigned)i < nr_scan_points );
	       assert( (unsigned)i <= off_index );
	       assert( off[i].next == -1 || off[i].pos >= off[off[i].next].pos );
	       pi = &off[i].next;
	       assert( *pi==(unsigned)(-1) || *pi < nr_scan_points );
	    } /* while */

	    if( off_index < nr_scan_points ) {
	       *pi = qi = off_index;
	       off_index++;
	       off[qi].pos = x0;
	       off[qi].next = i;
	       assert( off[qi].next == -1 || off[qi].pos >= off[i].pos );
	    } /* if */
	    dprintf(( "add off point @ %d, %d.5, off index is %d\n", x0, y0>>6, (int)qi ));
	    dxy -= x2-x1;
	    y0 -= 64;	   /* pixel coord of next scan line */
	 } while( y0 > y2 );
      }
      else {
         gprintf(( "saved processing\a\n!" ));
      } /* if */
   }
   else if( (y1&63) == 32 ) {
      /** horizontal line, on scan line **/
      if( is_on_edge(prev_edge) ){
         if( x2>x1) { /* adjust on edge */
	    add_last_on( x1, y1 );
	    prev_edge = off_edge;
	 } /* if */
      }
      else if( is_off_edge(prev_edge) ) {
         /* adjust off edge */
	 if( x2<x1 ) {
	    add_last_off( x1, y1 );
	    prev_edge = on_edge;
	 } /* if */
      }
      else {
         assert( is_nil_edge(prev_edge) );
	 if( x2<x1 ) {
	    prev_edge = on_edge;
	    first_edge = off_edge;
	 }
	 else if( x2>x1 ) {
	    prev_edge = off_edge;
	    first_edge = on_edge;
         } /* if */
      } /* if */
   } /* if */

} /* add_points() */


/********************************
*
*  break the glyph contours into straight line segments
*
*  the glyf is defined by the points in point[]
*  there are np points in the point[] array
*  there are nc contours in the glyf
*  contour[] defines the end point of each contour in the glyf
*  
***/
static void get_segments(const point_Rec point[], const int np, const uint16 contour[], int nc )
{
int ic;   /* contour index */
int first_point = 0;

   for( ic=0; ic<nc; ic++ ) {	    /* for each contour ... */
   PCOORD   ax, ay, bx, by, cx, cy;
   int last_point = contour[ic]; /* of this contour */
   int ip = first_point;   /* point index */
   BOOL end_flag = FALSE;
      /* assert( (unsigned)last_point <= pg->maxp.maxPoints ); */
      dprintf(( "next contour ends at point %d\n", last_point ));
      /* step thru the points on this contour */
      if( (point[last_point].flags&1) != 0 ) {
	/* last point on curve */
	 ax = point[last_point].xcoord;
	 ay = point[last_point].ycoord;
	 ip = first_point;
      }
      else if( (point[first_point].flags&1) != 0 ) {
	/* last point off curve, first point on curve */
	 ax = point[first_point].xcoord;
	 ay = point[first_point].ycoord;
	 ip = first_point+1;
      }
      else {
	/* last point & first point both off curve */
	 ax = (point[first_point].xcoord + point[last_point].xcoord) >> 1;
	 ay = (point[first_point].ycoord + point[last_point].ycoord) >> 1;
	 ip = first_point;
      } /* if */
#if V_SHOW
      xyi = 0;
      pxyarray[xyi++] = vxscale(ax);
      pxyarray[xyi++] = vyscale(ay);
#endif

      prev_edge = first_edge = nil_edge;
      assert( ip < np );
      while( TRUE ) {	      /* loop for each point in contour */

	 if( ip >= last_point ) {
	    end_flag = TRUE;
	 } /* if */

	 if( (point[ip].flags&1) != 0 ) {
	    /* this is an on curve point */
	    cx = point[ip].xcoord;
	    cy = point[ip].ycoord;
	    /* curve is straight line from (ax,ay) to (cx,cy) */
	    dprintf(( "[%d]: line thru a=(%d.%02d,%d.%02d), c=(%d.%02d,%d.%02d)\n",
		     ip, ax>>6, (ax&0x3f)*25/16, ay>>6, (ay&0x3f)*25/16,
		     cx>>6, (cx&0x3f)*25/16, cy>>6, (cy&0x3f)*25/16 ));
#if V_SHOW
	    pxyarray[xyi++] = vxscale(cx);
	    pxyarray[xyi++] = vyscale(cy);
#endif V_SHOW
	    add_points  ( ax, ay, cx, cy );
	 }
	 else {
	 int ip1;
	    /* this is an off-curve point */
	    /* look at next point to find cx & cy */
	    bx = point[ip].xcoord;
	    by = point[ip].ycoord;

	    assert(( ip >= last_point) == end_flag);
	    ip1 = end_flag ? first_point : ip+1;

	    assert( ip1 < np );
	    cx = point[ip1].xcoord;
	    cy = point[ip1].ycoord;
	    if( (point[ip1].flags&1) == 0 ) {
	       /* the next point is off-curve, */
	       /* (cx,cy) is mid-point */
	       cx = (bx + cx) >> 1;
	       cy = (by + cy) >> 1;
	    }
	    else {
	       ip = ip1;
	       if( ip >= last_point ) {
		  end_flag = TRUE;
	       } /* if */
	    } /* if */

	    /** curve is a q-spline defined by a, b, c **/
	    dprintf(( "[%d]: q-spline thru a=(%d.%02d,%d.%02d), b=(%d.%02d,%d.%02d), c=(%d.%02d,%d.%02d)\n",
		     ip, ax>>6, (ax&0x3f)*25/16, ay>>6, (ay&0x3f)*25/16, 
		     bx>>6, (bx&0x3f)*25/16, by>>6, (by&0x3f)*25/16, 
		     cx>>6, (cx&0x3f)*25/16, cy>>6, (cy&0x3f)*25/16 ));
	    

	    /*** subdivide the q-spline into straight line segments ***/

	    {
	    const int32 ddy = (int32)(ay - by - by + cy) << 1;
	    const int32 ddx = (int32)(ax - bx - bx + cx) << 1;
	    int32 dx;
	    int32 dy;
	    int nl;	   /* number of line segments in q-spline */
	    int ns = 0;    /* number of subdivisions, nl == ns ** 2 */
	    long x0, x1, y0, y1;
	       {
	       #define MAXERR 8  /* 1/8th of a dot, in units of dots/64 */
	       int ex = abs(ddx);
	       int ey = abs(ddy);
	       int error16 = ex + ey + (ex>ey ? ex : ey);  /* 16*error */
	       assert( error16 >= 0 );
	       while( (MAXERR<<4) < error16 ) { /* each subdivision quarters the error */
		  error16 >>= 2;
		  ns++;
	       } /* while */
	       nl = 1 << ns;
	       dprintf(( "there %s %d line segment%s required to approximate the q-spline\n", (nl==1)? "is": "are", nl, (nl==1)? "": "s" ));
	       }

	    /** there are 2 ** ns line segments required to approximate the q-spline **/
	       
	       dx = ((int32)(bx - ax) << (ns+1)) + (ddx >> 1);  /* x'(dt/2) */
	       dy = ((int32)(by - ay) << (ns+1)) + (ddy >> 1);

	       ns <<= 1;
	       x0 = ax;
	       y0 = ay;
	       x0 <<= ns;
	       y0 <<= ns;
	       while( nl-- > 0 ) {
		  x1 = x0 + dx;
		  y1 = y0 + dy;
		  dx += ddx;
		  dy += ddy;
		  {
		  int xx0 = x0 >> ns;
		  int yy0 = y0 >> ns;
		  int xx1 = x1 >> ns;
		  int yy1 = y1 >> ns;
		  dprintf(( "line segment from (%d.%02d, %d.%02d) to (%d.%02d,%d.%02d)\n",
		     xx0>>6, (xx0&0x3f)*25/16, yy0>>6, (yy0&0x3f)*25/16, xx1>>6, (xx1&0x3f)*25/16, yy1>>6, (yy1&0x3f)*25/16 ));
#if V_SHOW
		  pxyarray[xyi++] = vxscale(xx1);
		  pxyarray[xyi++] = vyscale(yy1);
#endif
		  add_points( xx0, yy0, xx1, yy1 );
		  }
		  x0 = x1;
		  y0 = y1;
	       } /* while */
	    }
	 } /* if q-spline */

	 assert((( ip >= last_point) == end_flag) || (ip==first_point) );
	 if( end_flag ) break;

	 ip++;
	 ax = cx; 
	 ay = cy;
      } /* while loop for each point */
      
      /** fix up join between first & last points in contour, if necessary **/
      if( !is_nil_edge(prev_edge) && first_edge == prev_edge ) {
         if( (is_on_edge(first_edge)) ) {
	    add_last_on(cx, cy);
	 }
	 else {
	    add_last_off(cx, cy);
	 } /* if */
      } /* if */
#if V_SHOW
      assert( xyi <= HIGH(pxyarray) );
      v_pline(handle, xyi>>1, pxyarray);     /* draw the contour */
#endif V_SHOW
      first_point = last_point+1;
      assert( on_index == off_index );
   } /* for each contour */

} /* get_segments */


#if 0
static void prOutLine( void )
{
register int line;
register SCAN_HDR *p;
   for( line=gemFontp->form_height, p=ppHead+gemFontp->top; line>0; line--, p-- ) {
   register int i;
      gprintf(( "\n\nline[%2d] (on): ", line ));
      i = p->on_index;
      while( i!=-1 ) {
	 gprintf(( "[%ld]->", (long)on[i].pos ));
	 i = on[i].next;
      } /* while */
      gprintf(( "\nline[%2d] (off): ", line ));
      i = p->off_index;
      while( i!=-1 ) {
	 gprintf(( "[%ld]->", (long)off[i].pos ));
	 i = off[i].next;
      } /* while */
   } /* for */
   getchar();
} /* prOutLine */
#endif

/******************
*  
*  make a gem font bit map from the edge list
*/
static void make_bit_map( tGEM_FONT_HDR * const fontp, const int16 gem_char )
{

int   line_count = fontp->top;
uint8 *p0 = fontp->form_data;      /* points to start of scan line */
const tDot c_offset = fontp->off_table[gem_char-fontp->first_ade];

   gprintf(( "char offset is %d\n", c_offset ));
   while( line_count >= -fontp->bottom ) {
   register int16 oni, offi;
      oni = ppHead[line_count].on_index;
      offi = ppHead[line_count].off_index;
      gprintf(( "\nline %d\n", line_count));

      while( oni != -1 && offi != -1 ) {
      register tDot  onpos;
      register tDot  offpos;
	 onpos = on[oni].pos;
	 offpos = off[offi].pos;

	 if( onpos > offpos ) {
	 register tDot t = onpos;
	    onpos = offpos; offpos = t;
	 } /* if */

	 {
	 uint16 onbyte;
	 register int nr_bytes;
	 uint16 onmask, offmask;
	 register BYTE *p;
	    onpos += c_offset;
	    onbyte = onpos>>3; 	     /* make byte index */
	    onmask = 0xff>>(onpos&7);
	    offpos += c_offset;
	    nr_bytes = (offpos>>3) - onbyte;
	    offmask = 0xff00>>(offpos&7);
	    gprintf(( "on @ %x:%d (%2x); off @ %x:%d (%2x)\n",
		     onbyte, onpos&7, onmask, offpos>>3, offpos&7, offmask ));
	    p = p0 + onbyte;
	    if( nr_bytes == 0 ) {
	       *p |= onmask & offmask;
	    }
	    else {
	       assert( nr_bytes > 0 );
	       *p++ |= onmask;
	       while( --nr_bytes > 0 ) {
		  *p++ = 0xff;
	       } /* while */
	       *p |= offmask;
	    } /* if */
	    assert( p >= p0 );
	    assert( p <= p0+fontp->form_width );
	    assert( p < fontp->form_data + (uint32)(fontp->form_height) * (uint32)(fontp->form_width) );
	    assert( p >= fontp->form_data );
	 } /* if */
	 oni = on[oni].next;
	 offi = off[offi].next;
	 assert( offi != -1 || oni == -1 );	/* will fail if too many points for edge buffer */
	 assert( offi == -1 || oni != -1 );
      } /* while loop for points in a scan line */

      line_count--;
      p0 += fontp->form_width; /* start of next scan line */
   } /* while loop for lines in font */

} /* make_bit_map() */


typedef struct {
   int16 numberOfContours;
   FWord xMin;
   FWord yMin;
   FWord xMax;
   FWord yMax;
   uint16 endPtsOfContours[0];
   } glyf_Rec;

/**********************************************************
*  
*  generate a gem font header & width table from ttf data
*/
void gen_font_header( const int16 ttf_nr, tGEM_FONT_HDR * const fontp,
                   const uint16 dpix, const uint16 dpiy  )
{
uint16 gem_char;
const tTTF_GDATA *const pg = &gdata[ttf_nr];		/* general ttf data for font */
tDot  c_offset;	/* char offset in width table */
   
   assert( pg->ptbl != NULL );	/* must have table data */
   assert( fontp != NULL );
   assert( fontp->off_table == (uint16*)(fontp+1) );

   fScaleShift = pg->fScaleShift;
   xppem64 = ((uint32)(fontp->size<<3)*dpix) / 9;
   fxScale64 = ((xppem64<<fScaleShift)+(pg->unitsPerEm>>1))/pg->unitsPerEm;

   yppem64 = ((uint32)(fontp->size<<3)*dpiy) / 9;
   fyScale64 = ((yppem64<<fScaleShift)+(pg->unitsPerEm>>1))/pg->unitsPerEm;

   assert( (fxScale64 == xppem64) || ((1<<fScaleShift) > pg->unitsPerEm) && ((1<<(fScaleShift-1)) < pg->unitsPerEm) );
   assert( abs(fx_to_dots64(pg->unitsPerEm) - xppem64 ) < 10 );
   assert( abs(fy_to_dots64(pg->unitsPerEm) - yppem64 ) < 10 );

#if V_SHOW
   work_in[0] = 1;    /* device id */
   work_in[1] = 1;
   work_in[2] = 1;
   work_in[3] = 1;
   work_in[4] = 1;
   work_in[5] = 1;
   work_in[6] = 1;
   work_in[7] = 1;
   work_in[8] = 1;
   work_in[9] = 1;
   work_in[10] = 2;    /* 2 = raster coords */
   handle = 0;
   v_opnvwk(work_in, &handle, work_out);
   assert( handle != 0 );
#endif V_SHOW


   /**** gem header ***/
   
   assert( (fontp->flags&4) != 0 ); /* Motorola format */

   {
   /* <<< if point x exists! */
   const glyf_Rec *const xp = (glyf_Rec*)((uint32)glyfTablep + pg->ptbl->glyphLoc[pg->ptbl->charMap['x']]);
   assert( ((int)xp&1) == 0 );
   fontp->half = fy_to_dots64(xp->yMax) >> 6;
   }
   fontp->ascent = (fy_to_dots64(pg->ttAscender)-32) >> 6;
   fontp->descent = -((fy_to_dots64(pg->ttDescender)+31) >> 6);
   dprintf(( "half line is %d pixels\n", (int)fontp->half));
   dprintf(( "ttAscender is %d FUnits (%d pixels), ttDescender is %d\n",
      (int)pg->ttAscender, (int)fontp->ascent, (int)pg->ttDescender));

   dprintf(( "yMax, yMin is %d, %d\n", pg->yMax, pg->yMin ));
   fontp->top = (fy_to_dots64(pg->yMax)-32) >> 6;
   assert( pg->yMin<pg->yMax );
   fontp->bottom = -((fy_to_dots64(pg->yMin)+31) >> 6);
   fontp->form_height = fontp->top + fontp->bottom + 1;
   fontp->left_offset = (fontp->bottom+1)>>1;
   fontp->right_offset = fontp->top>>1;
   fontp->thicken = 1 + (fontp->form_height >> 5);
   fontp->ul_size = 1 + (fontp->form_height >> 5);

   dprintf(( "estimated bottom is %d pixels, top is %d pixels, form height is %d pixels\n",
             fontp->bottom, fontp->top, fontp->form_height ));
/*   assert( fontp->top >= fontp->ascent ); */
/*   assert( -fontp->bottom <= -fontp->descent ); fails for mazam */



   /******* generate width table & font form height *******/

   fontp->off_table[0] = c_offset = 0;

   for( gem_char=fontp->first_ade; gem_char<=fontp->last_ade; gem_char++ ) {
   const uint16 glyph_index = pg->ptbl->charMap[gem_char];

      if( glyph_index != 0 ) {         /* implemented char ?? */
      FUnit wadv = pg->ptbl->advWid[gem_char];	/* working value of advance width */
      const glyf_Rec *const glyf_datap = (glyf_Rec*)((uint32)glyfTablep + pg->ptbl->glyphLoc[glyph_index]);
      FUnit wlsb = pg->ptbl->leftsb[gem_char];	  /* working value of left side bearing */
      FUnit char_align;

	 /*** process the glyph data ... ***/
	 assert( ((int)glyf_datap&1) == 0 );
   
	 dprintf(( "box '%c' is (%d,%d) .. (%d,%d)\n",
	       gem_char, glyf_datap->xMin, glyf_datap->yMin, glyf_datap->xMax, glyf_datap->yMax ));
	 dprintf(( "left sb is %d, advWidth is %d\n",
		      (int)pg->pt->leftsb[gem_char], (int)pg->pt->advWid[gem_char] ));

/*	 assert( glyf_datap->xMin >= pg->xMin );
	 assert( glyf_datap->xMax <= pg->xMax );
*/	 assert( glyf_datap->yMin >= pg->yMin );
	 assert( glyf_datap->yMax <= pg->yMax );
	 
	 if( wlsb < 0 ) wlsb = 0;    /* shift lsb if left overhang */
	 char_align = wlsb - glyf_datap->xMin;
	 if( wadv < glyf_datap->xMax + char_align )  /* shift rsb if right overhang */
	    wadv = glyf_datap->xMax + char_align;
	 dprintf(( "char_align is %d\n", char_align ));
	 {
	 register tDot charwid = fx_to_dots64(glyf_datap->xMax - glyf_datap->xMin) >> 6;
	    if( charwid > fontp->max_char_width ) {
	       fontp->max_char_width = charwid;
	    } /* if */
	 }
	 {
	 register tDot cellwid = fx_to_dots64(wadv+32) >> 6;
	    if( cellwid > fontp->max_cell_width ) {
	       fontp->max_cell_width = cellwid;
	    } /* if */
	    c_offset += cellwid;
	 }
      }
      else {
         dprintf(( "char %c is not implemented\n", gem_char ));
      } /* if */

      fontp->off_table[gem_char-fontp->first_ade+1] = c_offset;
      assert( (long)fontp->max_cell_width*(gem_char-fontp->first_ade+1) >= fontp->off_table[gem_char-fontp->first_ade+1] );
      assert( fontp->max_cell_width >= fontp->max_char_width ); /* <<< */
   } /* for each gem char ... */

   fontp->form_width = ((c_offset+15)>>3) & ~1;
   dprintf(( "fontp->form_width is %d, c_offset is %d\n",
	    (int)fontp->form_width, c_offset ));
   assert( ((uint32)fontp->form_width-2 << 3) < c_offset );	/* not too small */
   assert( (fontp->form_width & 1) == 0 );	/* must end on word boundary */

} /* gen_font_header() */


/**********************************************************
*  
* generate font data for each char in gem_char array
* extract contour info from font, convert into bitmap
*/
void gen_font_data( FILE_H fh, const int16 ttf_nr, tGEM_FONT_HDR *const fontp, 
         const ACTIVE_WKS_REC *const pd, int16 nr_chars, const uint16 *gem_chars )
{
const tTTF_GDATA *const pg = &gdata[ttf_nr];
SCAN_HDR *pp0 = pd->wks_fonts.scratch_adr;

   /* the edge list shares the scratch buffer */
   {
   uint16 size2 = fontp->form_height * sizeof(SCAN_HDR); /* size pp0 */
   uint16 size3 = pd->wks_fonts.scratch_size - size2/2; /* size on[] & off[] array, in bytes */
      off = (void*)((uint8*)pp0+size2);
      nr_scan_points = size3/sizeof(*off);
      on = off + nr_scan_points;
      assert( ((int)on&1) == 0 );
      assert( ((int)off&1) == 0 );
      assert( nr_scan_points*sizeof(*on) + nr_scan_points*sizeof(*off) + size2 <= 2*pd->wks_fonts.scratch_size );
   }

   assert( glyfTablep == NULL );

   dprintf(( "calling gen_font_data, ttf_nr is %d, nr_chars is %d, chars are %.8s\n",
            ttf_nr, nr_chars, gem_chars ));

   if( pg->ptbl != NULL && fontp->form_data != NULL) {
      /** glyf_point0 is an array of 0..maxPoints-1 point records,
      **  + left & right side bearings, + char align at index -1 **/
   point_Rec *glyf_point0 = malloc( (pg->maxp.maxPoints+3)*sizeof(point_Rec) );
   point_Rec *const Glyf_Point = glyf_point0 + 1;

      if( glyf_point0 == NULL ) goto error1;

      fScaleShift = pg->fScaleShift;
      xppem64 = ((uint32)(fontp->size<<3)*pd->dpix) / 9;
      fxScale64 = ((xppem64<<fScaleShift)+(pg->unitsPerEm>>1))/pg->unitsPerEm;
   
      yppem64 = ((uint32)(fontp->size<<3)*pd->dpiy) / 9;
      fyScale64 = ((yppem64<<fScaleShift)+(pg->unitsPerEm>>1))/pg->unitsPerEm;
   
      gemFontp = fontp;
      ppHead = pp0 + fontp->bottom;
   
      /* run_prep();  run preprogram */
      while( nr_chars-- > 0 )	   /* each char in string */
      {
      int nc, np;	/* nr contours, nr points in glyf */
      uint16   *instructionLengthPtr;
      BYTE     *glyf_pgm;
      uint16	glyph_index;
      const int16 gem_char = *gem_chars++;
      int j;
   
	 assert( gem_char <= 255 );
	 assert( gem_char >= 0 );
	 glyph_index = pg->ptbl->charMap[gem_char];
	 dprintf(( "%s, %d:pp0 glyph index %c is %d\n", __FILE__, __LINE__, gem_char, (int)glyph_index ));
	 if( glyph_index == 0) {
	    /* unimplemented char */
	    np = 0;
	    Glyf_Point[np+1].xcoord = 0;
	 }
	 else {
	 glyf_Rec *glyf_datap;
	 int16 wadv = pg->ptbl->advWid[gem_char];   /* working value of advance width */
	 uint32    *poffset = pg->ptbl->glyphLoc+glyph_index;
	 uint32     offset = *poffset;
	 uint32   glyf_size = poffset[1] - offset;	/* does this exist? <<< */
   
	    if( glyf_size == 0 ) {
	       /* character with no contours, eg space character */
	       np = 0;
	    }
	    else {
	    /*** process the glyph data ... ***/
	    int16 wlsb = pg->ptbl->leftsb[gem_char];	/* working value of left side bearing */
	    int16 char_align;
   
	       dprintf(( "char '%c', size is %d, offset is %d\n", gem_char, (int)glyf_size, (int)(pg->glyf_dir.offset+offset) ));
	       glyf_datap = malloc( glyf_size );
	       if( glyf_datap == NULL ) goto error2;
	       if( Fseek( pg->glyf_dir.offset+offset, fh, 0 ) <= 0 
	       ||  Fread( fh, glyf_size, glyf_datap ) < glyf_size ) goto error2;
   
	       dprintf(( "box is (%d,%d) .. (%d,%d)\n",
		     glyf_datap->xMin, glyf_datap->yMin, glyf_datap->xMax, glyf_datap->yMax ));
	       dprintf(( "left sb is %d, advWidth is %d\n",
			    (int)pg->ptbl->leftsb[gem_char], (int)pg->ptbl->advWid[gem_char] ));
	       yMax64 = fy_to_dots64( glyf_datap->yMax );
	       yMin64 = fy_to_dots64( glyf_datap->yMin );
   
	       assert( glyf_datap->yMin >= pg->yMin );
	       assert( glyf_datap->yMax <= pg->yMax );
	       
	       if( wlsb < 0 ) wlsb = 0;    /* shift lsb if left overhang */
	       char_align = wlsb - glyf_datap->xMin;
	       if( wadv < glyf_datap->xMax + char_align )  /* shift rsb if right overhang */
		  wadv = glyf_datap->xMax + char_align;
	       dprintf(( "char_align is %d\n", char_align ));
   
	       nc = glyf_datap->numberOfContours;
	       if( nc <= 0 ) goto end_glyph;  /* composite character, skip for now <<< */
	       np = glyf_datap->endPtsOfContours[nc-1] + 1;
   
	       instructionLengthPtr = (uint16 *)&glyf_datap->endPtsOfContours[nc];
	       glyf_pgm = (BYTE *)(instructionLengthPtr + 1);
	       dprintf(( "num contours[%c (%d)] is %d, ", gem_char>' '?gem_char:' ', gem_char, nc ));
	 
	       dprintf(( "there are %d instructions, %d points\n",
			*instructionLengthPtr, np ));
	       Glyf_Point[-1].xcoord = char_align;  /* align lsb to y axis */
	       Glyf_Point[-1].ycoord = 0;
   
	       /*** fill Glyf_Point[] with the x & y coords & flags from the glyf table */
	       get_points( glyf_pgm + *instructionLengthPtr, Glyf_Point, np );
      
	       /*** scale the Glyf_Point coordinates into 10.6 format ***/
	    
	       for( j=0; j<np; j++ ) {
		  assert( Glyf_Point[j].ycoord <= glyf_datap->yMax );
		  assert( Glyf_Point[j].ycoord >= glyf_datap->yMin );
		  assert( Glyf_Point[j].xcoord <= glyf_datap->xMax+char_align );
		  assert( Glyf_Point[j].xcoord >= glyf_datap->xMin+char_align );
      
		  Glyf_Point[j].xcoord = fx_to_dots64(Glyf_Point[j].xcoord);
		  Glyf_Point[j].ycoord = fy_to_dots64(Glyf_Point[j].ycoord);
		  dprintf(( "Glyf_Point[%d]: (%d.%02d, %d.%02d) is %s curve: flags are %x\n", j,
		     Glyf_Point[j].xcoord>>6, (Glyf_Point[j].xcoord&0x3f)*25/16, 
		     Glyf_Point[j].ycoord >> 6, (Glyf_Point[j].ycoord & 0x3f)*25/16 , 
		     (Glyf_Point[j].flags&1)?"on":"off", Glyf_Point[j].flags ));
		  assert( Glyf_Point[j].ycoord <= yMax64 );
		  assert( Glyf_Point[j].ycoord >= yMin64 );
	       } /* for */
	    } /* if glyf_size != 0 */
	    assert( np <= pg->maxp.maxPoints );
      
	    Glyf_Point[np].xcoord = 0;
	    Glyf_Point[np].ycoord = 0;
	    Glyf_Point[np+1].xcoord = fx_to_dots64( wadv );
	    Glyf_Point[np+1].ycoord = 0;
      
      #if V_SHOW
	    pxyarray[0] = vxscale(Glyf_Point[np].xcoord);  /* left sb */
	    pxyarray[1] = vyscale(fy_to_dots64(ttDescender));
	    pxyarray[2] = pxyarray[0];
	    pxyarray[3] = vyscale(fx_to_dots64(ttAscender));
	    pxyarray[4] = vxscale(Glyf_Point[np+1].xcoord);  /* advance width */
	    pxyarray[5] = pxyarray[3];
	    pxyarray[6] = pxyarray[4];
	    pxyarray[7] = pxyarray[1];
	    pxyarray[8] = pxyarray[0];
	    pxyarray[9] = pxyarray[1];
	    
	    v_clrwk(handle);  /* clear old char image */
	    vsl_type( handle, 3 ); /* dotted line */
	    v_pline( handle, 5, pxyarray );
	    vsl_type( handle, 1 ); /* solid line */
      #endif V_SHOW
   
	    /*** create an edge list for glyph outline ***/
	    if( np > 0 ) {
	       /* instruct_glyph( glyf_pgm, *instructionLengthPtr, gem_char ); << apple_char?? */
	       {
	       register int i;
	       register SCAN_HDR *hp;
		  for( i=fontp->form_height, hp=pp0; i>0; i--, hp++ ) {
		     hp->on_index = hp->off_index = -1;
		  } /* for */
	       }
	       dprintf(( "%s, %d: getting segments ...\n", __FILE__, __LINE__ ));
	       on_index = off_index = 0;
	       get_segments( Glyf_Point, np, glyf_datap->endPtsOfContours, nc );
   
	       dprintf(( "char is %c, on_index is %d, off_index is %d\n",
		  gem_char, (int)on_index, (int)off_index ));
   
	       dprintf(( "%s, %d: making bitmap ...\n", __FILE__, __LINE__ ));
	       make_bit_map( fontp, gem_char );
	       dprintf(( "%s, %d: bit map done ...\n", __FILE__, __LINE__ ));
end_glyph:
	       free( glyf_datap );
	    } /* if np > 0 ... */
	 } /* if char implemented */
   
	 dprintf(( "============================= end of glyph(%c) \n", gem_char ));
   #if V_SHOW || G_SHOW
	 gprintf(( "============================= end of glyph(%c)", gem_char ));
	 getchar();
	 v_clsvwk(handle);
   #endif
      } /* while chars remain */ 
   
   /** tidy up before return **/
   
error2:
      free( glyf_point0 );
   } /* if( pg-> ...) */
error1:
   return;

} /* gen_font_data() */

/************************ end of glyph.c ************************/
