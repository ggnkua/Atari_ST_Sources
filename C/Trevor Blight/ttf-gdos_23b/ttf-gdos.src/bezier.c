/***** (C) 1998-2021, Trevor Blight *****
*
*  $Id: bezier.c 3271 2021-08-27 14:45:25Z trevor $
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
********************************************
*
*  implement the gem vdi bezier functions
*
****************************************/

#include "osbind.h"
#include "ttf-gdos.h"
#include "ttf-defs.h"

#define MIN_QUAL 0

/** mode values for draw_segs() **/
#define FILL    9	/* v_pline() */
#define NO_FILL 6	/* v_fill_area() */

#define IS_BEZ(f) ((f&1)!=0)
#define IS_JUMP(f) ((f&2)!=0)

static int16 driver_vertices; /* limit for current driver */

/********************
 * implement vdi function v_bez_control
 * just return bez quality to indicate bezier functions are available
 */
void v_bez_control( const Vdi_Params *vdi_param_adr )
{
const ACTIVE_WKS_REC *const pw = find_wkstnp( vdi_param_adr->contrl_adr->handle );
   vdi_param_adr->intout_adr[0] = pw->bez_qual;
   vdi_param_adr->contrl_adr->nptsout = 1;
} /* v_bez_control() */


/***********
* set bezier quality
* note: bez_qual > 7 will cause overflow in gen_segs()
**/
static const int16 pcarr[] = {0, 10, 23, 39, 55, 71, 86, 100};
void v_bez_qual( const Vdi_Params *vdi_param_adr )
{
ACTIVE_WKS_REC *const pw = find_wkstnp( vdi_param_adr->contrl_adr->handle );
register int q = vdi_param_adr->intin_adr[2];
   if( q>=95 ) {
      q = 7;
   }
   else if( q<5 ) {
      q = MIN_QUAL;
   }
   else {
      q = (q>>4) + 1;
   } /* if */
   pw->bez_qual = q;
   vdi_param_adr->intout_adr[0] = pcarr[q-MIN_QUAL];
   vdi_param_adr->contrl_adr->nintout = 1;
} /* v_bez_qual() */


/****************************
*
* compute bezier function by difference method
* last point is included
* one dimension only, so use alternate elements of array & px
* array[0] : anchor 1
* array[2] : control 1
* array[4] : control 2
* array[6] : anchor 2
*/
static void gen_segs( int16 *const array, uint16 *px, const int bez_qual, uint16 *const pmin, uint16 *const pmax, int16 rc_flag )
{
register int32 d3x, d2x, d1x;
register int32 x0;
int q = 3*bez_qual;
int qd = 0;
int i;
register int16 x;

   /*** calculate 1st, 2nd & 3rd order differences ***/

   d1x = (int32)array[2]-array[0];
   d2x = (int32)array[4]-array[2];
   d3x = -array[0] - 3*d2x + array[6];
   d2x -= d1x;

   if( !rc_flag && q>=3 ) {
      d1x>>=1; d2x>>=1; d3x>>=1;
      q--;
   } /* if */
   d1x = ((3L*d1x)<<(2*bez_qual)) + ((3L*d2x)<<bez_qual) + d3x;
   /* assert( d1x <=  0x5f408000 ); */
   /* assert( d1x >= -0x5f408000 ); */

   d3x = 6L*d3x;
   assert( d3x <=  0xbffe8 );
   assert( d3x >= -0xbffe8 );

   d2x = ((6L*d2x)<<bez_qual) + d3x;
   /* assert( d2x <=  0x2f6fa12 ); */
   /* assert( d2x >= -0x2f6fa12 ); */

   x0 = abs(array[0]);
   while( x0 >= (0x7fffffffL>>q) ) q--, qd++;
   x0 = (((int32)array[0])<<q) + (1L<<(q-1));

   for( i=1<<bez_qual; i>0; i-- ) {
      x = (int16)(x0 >> q);
      *px = x;
      if( x < *pmin ) *pmin = x;
      if( x > *pmax ) *pmax = x;
      px+=2;

      if( abs( (x0>>1) + (d1x>>(qd+1)) ) >= 0x3ffffffeL ) {
         /** halve scale to avoid overflow **/
         x0 = x0>>1;
         q--, qd++;
         assert( abs(x0+(d1x>>qd)) >= 0x40000000L );
      } /* if */

      x0 += d1x>>qd;

      if( qd>0 && abs(x0) < 0x40000000L ) {
         /** double scale to maximise accuracy **/
         x0 = (x0<<1)|1;
         q++, qd--;
      } /* if */

      assert( d2x<0 || d1x <=  0x7fffffff-d2x );
      assert( d2x>0 || d1x >= -0x7fffffff-d2x );
      d1x += d2x;

      d2x += d3x;
      assert( d2x <=  0x30bf9e8 );
      assert( d2x >= -0x30bf9e8 );
   } /* for */

   /** add the last point .. */
   *px = x = array[6];
   if( x < *pmin ) *pmin = x;
   if( x > *pmax ) *pmax = x;

} /* gen_segs() */


/****************************
* get max nr vertices a driver can accept
* set global variable driver_vertices
*/
static void get_driver_vertices( const ACTIVE_WKS_REC * const pw )
{
Vdi_Params xpb = { &xcontrl, xintin, xptsin, xintout, xptsout };
register int16 n;
   xcontrl.opcode = 102;  /* opcode for vq_extend */
   xcontrl.nptsin = 0;     /* entries in ptsin[] */
   xcontrl.nintin = 1;   /* entries in intin[] */
   xintin[0] = 1;
   xcall_driver( &xpb, pw );   /* get info from driver */
   n = xpb.intout_adr[14];   /* nr vertices for driver, -1 == unlimited */
   driver_vertices = n==-1? 1024: n;
} /* get_driver_vertices() */


/***********************************
* draw segments in lptsin array
* do piece-wise if input array is too big
* not guaranteed to work if FILL, but still better than anything else
*/
static void draw_segs( const ACTIVE_WKS_REC * const pw,
                       int16 nr_vertices,
                       const uint16 *const lptsin, const int16 mode )
{
     Vdi_Params xpb = { &xcontrl, xintin, (int16 *)lptsin, xintout, xptsout };
   assert( mode == FILL || mode == NO_FILL );
   while( nr_vertices >= 2 ) {
      xcontrl.opcode = mode;        /* opcode for v_pline/v_fill_area */
      xcontrl.nintin = 0;           /* entries in intin[] */
      xcontrl.nptsin = nr_vertices>driver_vertices? driver_vertices: nr_vertices; /* entries in ptsin[] */
      call_driver( &xpb, pw );   /* output to driver, converting ndc if necessary */
      if( nr_vertices>driver_vertices ) {
         xpb.ptsin_adr += 2*(driver_vertices-1); /* include end point in next call */
      } /* if */
      nr_vertices -= driver_vertices-1;
   } /* while */
 }/* draw_segs() */


/********************************
 * implement vdi function v_bez()
 * draw a bezier curve
 */
void v_bez( register const Vdi_Params *vdi_param_adr )
{
int16  const nr_ptsin = vdi_param_adr->contrl_adr->nptsin;
const uint8 *const bezarr = (uint8*)vdi_param_adr->intin_adr;	/* index with xor 1 to byte swap !! */
register const ACTIVE_WKS_REC * const pw = find_wkstnp( vdi_param_adr->contrl_adr->handle );
int16 bez_qual;
uint16 xmin, xmax, ymin, ymax;
int16 total_vertices = nr_ptsin;
int16 total_jumps = 0;
uint16 vertices_per_bez;
int16 i;
int16 *ptsin = vdi_param_adr->ptsin_adr;
uint16 *xptsin;

   if( pw==NULL ) goto error;

   /* don't expand if metafile */
   if( pw->pdev->id>=31 && pw->pdev->id<=40 ) {
      call_driver( vdi_param_adr, pw );
      return;
   } /* if */

   bez_qual = pw->bez_qual;
   vertices_per_bez = 1<<bez_qual;
   xmin = ymin = 32767;
   xmax = ymax = 0;

   get_driver_vertices( pw );
   xptsin = malloc( (vertices_per_bez+1)*4 );	/* 4 bytes for a coord pair */
   if( xptsin == NULL ) goto error;

   i = 0;
   while( i < nr_ptsin ) {
   int flag = bezarr[i^1];

      if( IS_BEZ(flag) ) {  /** bezier start point found **/
         if( i+3 >= nr_ptsin ) break;

         if( IS_JUMP(flag) ) total_jumps++;   /* count jump point */

         /** generate line segments from bez points **/
         gen_segs( ptsin, xptsin, bez_qual, &xmin, &xmax, pw->rc_flag );	/* x coords */
         gen_segs( ptsin+1, xptsin+1, bez_qual, &ymin, &ymax, pw->rc_flag );	/* y coords */
         i += 3;	/* skip to coord pairs at end of bez curve */
         ptsin += 6;
         total_vertices += vertices_per_bez-3;
         draw_segs( pw, vertices_per_bez+1, xptsin, NO_FILL );
      }
      else {     /** polyline **/
      int16 output_vertices = 0;
      int16 *const ptsin0 = ptsin;
         do {
         register int t;
            t = ptsin[0];
            if( t < xmin ) xmin = t;
            if( t > xmax ) xmax = t;
            t = ptsin[1];
            if( t < ymin ) ymin = t;
            if( t > ymax ) ymax = t;
            output_vertices++;
            if( IS_BEZ(flag) ) break;
            /* continue polyline, stop if a jump point is next */
            i++;
            if( i>=nr_ptsin ) break;
            ptsin += 2;
            {
            register int old_flag = flag;
            flag = bezarr[i^1];
            if( !IS_JUMP(old_flag) && IS_JUMP(flag) ) total_jumps++;   /* count jump point */
            }
         } while( !IS_JUMP(flag) );
         draw_segs( pw, output_vertices, (uint16 *)ptsin0, NO_FILL );
      } /* if */

   } /* while */

   free( xptsin );

   vdi_param_adr->intout_adr[0] = total_vertices; /* total nr points */
   vdi_param_adr->intout_adr[1] = total_jumps;    /* total moves */
   vdi_param_adr->ptsout_adr[0] = xmin;
   vdi_param_adr->ptsout_adr[1] = ymin;
   vdi_param_adr->ptsout_adr[2] = xmax;
   vdi_param_adr->ptsout_adr[3] = ymax;

   return;

error:
   vdi_param_adr->intout_adr[0] = 0;
   vdi_param_adr->intout_adr[1] = 0;

} /* v_bez() */


/********************************
 * implement vdi function v_bez_fill()
 * draw a filled bezier curve
 */
void v_bez_fill( register const Vdi_Params *vdi_param_adr )
{
int16  const nr_ptsin = vdi_param_adr->contrl_adr->nptsin;
const uint8 *const bezarr = (uint8*)vdi_param_adr->intin_adr;	/* index with xor 1 to byte swap !! */
register const ACTIVE_WKS_REC * const pw = find_wkstnp( vdi_param_adr->contrl_adr->handle );
int16 bez_qual;
uint16 xmin, xmax, ymin, ymax;
int16 total_vertices = nr_ptsin;
int16 total_jumps = 0;
int16 vertices_per_bez;
int16 i, i0;
int16 *ptsin;
int16 *ptsin0;
uint16 *xptsin;
uint16 *xptsin0;
int16 nr_bez;
uint16 output_vertices = 0;

   if( pw==NULL ) goto error;

   /* don't expand if metafile */
   if( pw->pdev->id>=31 && pw->pdev->id<=40 ) {
      call_driver( vdi_param_adr, pw );
      return;
   } /* if */

   bez_qual = pw->bez_qual;
   vertices_per_bez = 1<<bez_qual;
   xmin = ymin = 32767;
   xmax = ymax = 0;

   get_driver_vertices( pw );

   xptsin = xptsin0 = malloc( driver_vertices*4 ); /* use too much memory if unlimited driver vertices */
   if( xptsin0 == NULL ) goto error;

   nr_bez = 0;
   i = i0 = 0;
   ptsin0 = ptsin = vdi_param_adr->ptsin_adr;
   while( i<nr_ptsin ) {
   int flag = bezarr[i^1];

      if( IS_BEZ( flag ) ) {
         if( i+3 >= nr_ptsin ) break;   /* incomlete curve, omit it */

         if( IS_JUMP(flag) ) total_jumps++;   /* count jump point */

         /* keep this curve within nr vertices for the driver's ptsin[]
         ** with one spare for the end point */
         if( output_vertices+vertices_per_bez+1 > driver_vertices ) {
            if( bez_qual > MIN_QUAL ) {
               /* try to reduce bezier quality & start this polygon again */
               bez_qual--;
               i = i0; ptsin = ptsin0; xptsin = xptsin0; output_vertices = 0;
               continue;
            } /* if */
            /* too bad if we get here. refuse to add vertices to output */
         }
         else {
            if( i!=i0 ) {
               /* the end point will be copied in again */
               xptsin -= 2;
               output_vertices--;
            } /* if */

            output_vertices += vertices_per_bez+1;
            total_vertices += vertices_per_bez-3;
            gen_segs( ptsin, xptsin, bez_qual, &xmin, &xmax, pw->rc_flag );	/* x coords */
            gen_segs( ptsin+1, xptsin+1, bez_qual, &ymin,  &ymax, pw->rc_flag );	/* y coords */
            xptsin = xptsin0 + 2*output_vertices;
         } /* if */
         assert( vdi_param_adr->ptsin_adr + 2*i == ptsin );
         i+=3;
         ptsin += 6;
         flag = bezarr[i^1];
      }
      else {     /** polyline **/

         if( i!=i0 ) {
            /* the end point will be copied in again */
            xptsin -= 2;
            output_vertices--;
         } /* if */

         do {
         register int t;
            if( output_vertices < driver_vertices ) {	/* need room for at least one more */
               t = ptsin[0];
               if( t < xmin ) xmin = t;
               if( t > xmax ) xmax = t;
               *xptsin++ = t;
               t = ptsin[1];
               if( t < ymin ) ymin = t;
               if( t > ymax ) ymax = t;
               *xptsin++ = t;
               output_vertices++;
            } /* if */
            assert( xptsin0 + 2*output_vertices == xptsin );
            assert( vdi_param_adr->ptsin_adr + 2*i == ptsin );
            if( IS_BEZ(flag) ) break;
            i++;
            ptsin += 2;
            if( i>=nr_ptsin ) break;
            /* continue polyline, stop if a jump point is next */
            {
            register int old_flag = flag;
            flag = bezarr[i^1];
            if( !IS_JUMP(old_flag) && IS_JUMP(flag) ) total_jumps++;   /* count jump point */
            }
         } while( !IS_JUMP(flag) );
      } /* if */

      if( i>=nr_ptsin || IS_JUMP(flag) ) {
         draw_segs( pw, output_vertices, xptsin0, FILL );
         bez_qual = pw->bez_qual;
         i0 = i; ptsin0 = ptsin; xptsin = xptsin0; output_vertices = 0;
      } /* if */
   } /* while */

   free( xptsin0 );

   vdi_param_adr->intout_adr[0] = total_vertices; /* total nr points */
   vdi_param_adr->intout_adr[1] = total_jumps;    /* total moves */
   vdi_param_adr->ptsout_adr[0] = xmin;
   vdi_param_adr->ptsout_adr[1] = ymin;
   vdi_param_adr->ptsout_adr[2] = xmax;
   vdi_param_adr->ptsout_adr[3] = ymax;

   return;

error:
   vdi_param_adr->intout_adr[0] = 0;
   vdi_param_adr->intout_adr[1] = 0;
   return;
} /* v_bez_fill() */

/********************* end of bezier.c *********************/

