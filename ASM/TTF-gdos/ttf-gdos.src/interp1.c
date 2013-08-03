/****************** (c) Trevor Blight 2002 ***********************
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
*
*  this file implements part of the true type font interpreter
*  for CVT & graphics state instructions
*  (not finished)
******************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "ttf.h"
#include "interp.h"

#define IBUG 0
#if IBUG
#include "ibug.h"
#else
#define reset_ibug()
#endif
enum { rsHG=0x100, rsG, rsDG, rsDTG, rsUTG, rsOFF };

/* for freedom & projection vectors */
typedef struct {
   F2Dot14 x, y;
} VECTOR;

static const VECTOR X_AXIS = { 0x4000, 0 };
static const VECTOR Y_AXIS = { 0, 0x4000 };

typedef struct {
   BOOL  auto_flip;
   F26Dot6  control_value_cut_in;
   int32    delta_base;
   int32    delta_shift;
   VECTOR   dual_projection_vectors;
   VECTOR   freedom_vector;
   int   zp0;
   int   zp1;
   int   zp2;
   uint16   instruct_Control;
   int   loop;
   F26Dot6  minimum_distance;
   VECTOR   projection_vector;
   uint16   round_state;
   uint16   rp0;
   uint16   rp1;
   uint16   rp2;
   BOOL  scan_control;
   F26Dot6  single_width_cut_in;
   F26Dot6  single_width_value;
} GRAPHICS_STATE;

static const GRAPHICS_STATE default_Graphics_State = {
   TRUE,    /* auto_flip */
   68,      /* control_value_cut_in, 17/16 pixels */
   9,       /* delta_base */
   3,       /* delta_shift */
   {0, 0},  /* dual_projection_vectors */
   {0x4000, 0},  /* freedom_vector := x-axis */
   1,       /* gep0 */
   1,       /* gep1 */
   1,       /* gep2 */
   0,       /* instruct_Control */
   1,       /* loop */
   64,      /* minimum_distance, 1 pixel */
   {0x4000, 0},  /* projection_vector := x-axis */
   rsG,     /* round_state */
   0,       /* rp0 */
   0,       /* rp1 */
   0,       /* rp2 */
   FALSE,   /* scan_control */
   0,       /* single_width_cut_in */
   0        /* single_width_value */
};

static GRAPHICS_STATE Graphics_State0, Graphics_State;
static point_Rec *tw_Zonep;
static point_Rec *orgtw_Zonep;
static point_Rec *orgGlyf_Point;

/* declarations for control value table */
static FWord *cvtOrgp;
static FWord *cvtDefaultp;
static FWord *cvtWorkp;
static int    nr_cvt_entries;
static uint32 cvt_Size;


/* prepp points to copy of cvt program,
*  prepp == NULL iff no pre-program defined */
static INSTRUCTION *prepp = NULL;
static INSTRUCTION *prep_end;

#define abs(x)  ({ int _x = x; _x>=0? _x: -_x; })

__inline__ static
point_Rec * const get_point( const int zp, const uint16 pn )
{
   assert( (zp!=0) || (pn<maxpp->maxTwilightPoints) );
   assert( (zp==0) || (pn<maxpp->maxPoints) );
   return (zp ? Glyf_Point : tw_Zonep) + pn;
} /* get_point() */

__inline__ static
point_Rec * const get_org_point( const int zp, const uint16 pn )
{
   assert( (zp!=0) || (pn<maxpp->maxTwilightPoints) );
   assert( (zp==0) || (pn<maxpp->maxPoints) );
   return (zp ? orgGlyf_Point : orgtw_Zonep) + pn;
} /* get_org_point() */


static F26Dot6 const
get_distance( register const point_Rec *const a,
              register const point_Rec *const b )
{
register F26Dot6 result;

   iprintf(( "projvector delta is %lx\n",
           (int32)Graphics_State.projection_vector.x*Graphics_State.projection_vector.x
         + (int32)Graphics_State.projection_vector.y*Graphics_State.projection_vector.y
	 - 0xfffffe0 ));
   assert( (int32)Graphics_State.projection_vector.x*Graphics_State.projection_vector.x
         + (int32)Graphics_State.projection_vector.y*Graphics_State.projection_vector.y
	 - 0xfffffe0 < 0x200 );

   if( Graphics_State.projection_vector.x == 0x4000 ) {
      result = b->xcoord - a->xcoord;
   }
   else if( Graphics_State.projection_vector.x == -0x4000 ) {
      result = a->xcoord - b->xcoord;
   }
   else if( Graphics_State.projection_vector.y == 0x4000 ) {
      result = b->ycoord - a->ycoord;
   }
   else if( Graphics_State.projection_vector.y == -0x4000 ) {
      result = a->ycoord - b->ycoord;
   }
   else {
      iprintf(( "get_distance(): oblique projection vector!\n" ));
      result = ( (b->xcoord - a->xcoord)*Graphics_State.projection_vector.x
               + (b->ycoord - a->ycoord)*Graphics_State.projection_vector.y )
	       >> 14;
   } /* if */
   return result;
} /* get_distance() */

/** move point along freedom vector from a to b,
*   so its coord along projection vector changes by d
*   note ap and bp might point to same point_Rec **/
static void
move_point( register point_Rec *const ap, register point_Rec *const bp, F26Dot6 d )
{
   iprintf(( "freedomvector delta is %lx\n",
           (int32)Graphics_State.freedom_vector.x*Graphics_State.freedom_vector.x
         + (int32)Graphics_State.freedom_vector.y*Graphics_State.freedom_vector.y
	 - 0xfffffe0 ));
   assert( (int32)Graphics_State.freedom_vector.x*Graphics_State.freedom_vector.x
         + (int32)Graphics_State.freedom_vector.y*Graphics_State.freedom_vector.y
	 - 0xfffffe0 < 0x200 );

   if( Graphics_State.projection_vector.x == 0x4000 ) {
      bp->xcoord = ap->xcoord+d;
   }
   else if( Graphics_State.projection_vector.y == 0x4000 ) {
      bp->ycoord = ap->ycoord+d;
   }
   else if( Graphics_State.projection_vector.x == -0x4000 ) {
      bp->xcoord = ap->xcoord-d;
   }
   else if( Graphics_State.projection_vector.y == -0x4000 ) {
      bp->ycoord = ap->ycoord-d;
   }
   else {
   int32  alpha = (d<<16) /
	  (( (int32)Graphics_State.projection_vector.x*Graphics_State.freedom_vector.x
	   + (int32)Graphics_State.projection_vector.y*Graphics_State.freedom_vector.y )
	    >> 12);

      bp->xcoord = ap->xcoord + (Graphics_State.freedom_vector.x*alpha >> 14);
      bp->ycoord = ap->ycoord + (Graphics_State.freedom_vector.y*alpha >> 14);
   } /* if */
} /* move_point() */

static F26Dot6 const
get_Scale64( void )
{
register F26Dot6 result;
   if( Graphics_State.projection_vector.x == 0x4000 ) {
      result = fxScale64;
   }
   else if( Graphics_State.projection_vector.y == 0x4000 ) {
      result = fyScale64;
   }
   else {
      iprintf(( "oblique projection vector!\n" ));
      result = (fyScale64 + fxScale64) >> 1;	/* <<< */
   } /* if */
   return result;
} /* get_Scale64() */


/******************
*  set graphics state ...
******************/

void srp0( void)
{
uint32 n = pop();
   iprintf(( "srp0 = %d\n", n));
   assert( (n<maxpp->maxTwilightPoints) || (n<maxpp->maxPoints) );
   Graphics_State.rp0 = n;
} /* srp0() */

void srp1( void)
{
uint32 n = pop();
   iprintf(( "srp1 = %d\n", n));
   assert( (n<maxpp->maxTwilightPoints) || (n<maxpp->maxPoints) );
   Graphics_State.rp1 = n;
} /* srp1() */

void srp2( void)
{
uint32 n = pop();
   iprintf(( "srp2 = %d\n", n));
   assert( (n<maxpp->maxTwilightPoints) || (n<maxpp->maxPoints) );
   Graphics_State.rp2 = n;
} /* srp2() */

void szp0( void)
{
uint32 n = pop();
   iprintf(( "szp0 = %d\n", n));
   assert( n<=1 );
   assert( (n!=0) || (maxpp->maxZones==2) );
   Graphics_State.zp0 = n;
} /* szp0() */

void szp1( void)
{
uint32 n = pop();
   iprintf(( "szp1 = %d\n", n));
   assert( n<=1 );
   assert( (n!=0) || (maxpp->maxZones==2) );
   Graphics_State.zp1 = n;
} /* szp1() */

void szp2( void)
{
uint32 n = pop();
   iprintf(( "szp2 = %d\n", n));
   assert( n<=1 );
   assert( (n!=0) || (maxpp->maxZones==2) );
   Graphics_State.zp2 = n;
} /* szp2() */

void szps( void)
{
uint32 n = pop();
   iprintf(( "szps = %d\n", n));
   Graphics_State.zp0 = Graphics_State.zp1 = Graphics_State.zp2 = n;
} /* szps() */

void sdb( void )
{
   Graphics_State.delta_base = pop();
   iprintf(( "set delta base to %ld\n", Graphics_State.delta_base ));
} /* sdb() */

void sds( void )
{
   Graphics_State.delta_shift = pop();
   iprintf(( "set delta shift to %ld\n", Graphics_State.delta_shift ));
} /* sdb() */

/** set vectors to coordinate axis ... **/

void svtcay( void )
{
   iprintf(( "set vectors to y-axis\n" ));
   Graphics_State.projection_vector = Graphics_State.freedom_vector = Y_AXIS;
} /* svtcay() */

void svtcax( void )
{
   iprintf(( "set vectors to x-axis\n" ));
   Graphics_State.projection_vector = Graphics_State.freedom_vector = X_AXIS;
} /* svtcax() */

void spvtcay( void )
{
   iprintf(( "set projection vector to y-axis\n" ));
   Graphics_State.projection_vector = Y_AXIS;
} /* spvtcay() */


void spvtcax( void )
{
   iprintf(( "set projection vector to x-axis\n" ));
   Graphics_State.projection_vector = X_AXIS;
} /* spvtcax() */


void sfvfs( void )
{
   Graphics_State.freedom_vector.y = pop();
   Graphics_State.freedom_vector.x = pop();
   iprintf(( "sfvfs: freedom vector is now (%d, %d)\n",
            (int)Graphics_State.freedom_vector.x,
            (int)Graphics_State.freedom_vector.x ));
} /* sfvfs() */

void spvfs( void )
{
   Graphics_State.projection_vector.y = pop();
   Graphics_State.projection_vector.x = pop();
   iprintf(( "sfvfs: projection vector is now (%d, %d)\n",
            (int)Graphics_State.projection_vector.x,
            (int)Graphics_State.projection_vector.x ));
} /* spvfs() */


void mppem( void )
{
   if( Graphics_State.projection_vector.y == 0 ) {
      iprintf(( "ppem in x direction = %d\n", ppemx ));
      *stack_ptr++ = ppemx;
   }
   else if( Graphics_State.projection_vector.x == 0 ) {
      iprintf(( "ppem in y direction = %d\n", ppemy ));
      *stack_ptr++ = ppemy;
   }
   else {
      iprintf(( "warning: ppem in oblique direction is approximated" ));
      iprintf(( "\n", getchar() ));
      *stack_ptr++ = (ppemx + ppemy)>>1;
   } /* if */
} /* mppem */

void sloop( void )
{

   if( Graphics_State.loop != 1 ) {
      iprintf(( "warning: expected loop to be 1, [it's %ld]",
                              (uint32)Graphics_State.loop ));
      iprintf(( "\n", getchar() ));
   } /* if */
   Graphics_State.loop = pop();
   iprintf(( "sloop, loop -> %ld\n", (uint32)Graphics_State.loop ));
} /* sloop() */

void instctrl( void )
{
/*** only in prep **/
uint16 value;
uint32 sel;
   sel = pop();
   value = pop();
   iprintf(( "instctrl, sel is %ld, val is %ld\n",sel, (uint32)value ));
   Graphics_State.instruct_Control = value;
} /* instctrl() */

void scanctrl( void )
{
uint32 n = pop();	/* <<< */
   iprintf(( "scancntrl, %s, %s, %s, %s, %s, %s, %d\n",
             n&0x100?"on":"", n&0x200?"on(rotn)":"", n&0x400?"on(stretch)":"",
             n&0x800?"off":"", n&0x1000?"off(rotn)":"", n&0x2000?"off(stretch)":"",
	     (int)n&0xff ));
} /* scanctrl() */

void scantype( void )
{
uint32 n = pop();	/* <<< */
   iprintf(( "scantype, dropout rules %s\n",
             n==0?"1, 2 & 4": ( n==1?"1, 2 & 3": (n==2?"1 & 2":"default")) ));
} /* scanctrl() */


/******************
*  manage exceptions
******************/

void deltap1( void )
{
   iprintf(( "deltap1: \n" ));
} /* deltap1() */

void deltap2( void )
{
   iprintf(( "deltap2: \n" ));
} /* deltap2() */

void deltap3( void )
{
   iprintf(( "deltap3: \n" ));
} /* deltap3() */

void deltac1( void )
{
   iprintf(( "deltac1: \n" ));
} /* deltac1() */

void deltac2( void )
{
   iprintf(( "deltac2: \n" ));
} /* deltac2() */

void deltac3( void )
{
   iprintf(( "deltac3: \n" ));
} /* deltac3() */


/******************
*  set the round state
******************/

static const COMP_black = 0;
static const COMP_white = 0;

const
F26Dot6 do_round( F26Dot6 v )
{
register F26Dot6 r;

   switch( Graphics_State.round_state ) {
   case rsHG:
      r = (v&~63L) + 32;
      assert( (r&63L) == 32 );
      assert( abs(r-v) <= 32 );
      break;
   case rsG:
      r = (v+32L)&~63L;
      assert( (r&63L) == 0 );
      assert( abs(r-v) <= 32 );
      break;
   case rsDG:
      r = (v+16L)&~31L;
      assert( (r&31L) == 0 );
      assert( abs(r-v) <= 16 );
      break;
   case rsDTG:
      r = v&~63L;
      assert( (r&63L) == 0 );
      assert( r <= v );
      assert( r+64L > v );
      break;
   case rsUTG:
      r = (v+63L)&~63L;
      assert( (r&63L) == 0 );
      assert( r >= v );
      assert( r-64L < v );
      break;
   case rsOFF:
      r = v;
      break;
   default: {
   register F26Dot6 period;
   register F26Dot6 threshold;
   register F26Dot6 phase;

      switch( Graphics_State.round_state&0xc0 ) {
      case 0x00:
         period = 32L;
	 break;
      default:
      case 0x40:
         period = 64L;
	 break;
      case 0x80:
         period = 128L;
	 break;
      } /* switch */

      switch( Graphics_State.round_state&0x30 ) {
      case 0x00:
         phase = 0;
	 break;
      case 0x10:
         phase = period>>2;
	 break;
      case 0x20:
         phase = period>>1;
	 break;
      case 0x30:
         phase = 48L;
      } /* switch */
      assert( phase < period );

      threshold = (Graphics_State.round_state&0xf) ?
                  (((Graphics_State.round_state&0x0f)-4) * period)>>3 :
		  period-1L;
      r = ((v+threshold-phase) & ~(period-1L)) + phase;
      assert( (r & (period-1L)) ==  phase );
      assert(v + threshold >= r );
      assert( v + threshold < r + period );

   } /* default, super round */
   } /* switch */

   return r;

} /* do_round() */

void round_gr( void )
{
F26Dot6 n1;
   n1 = pop();
   *stack_ptr = do_round( n1 );
   iprintf(( "round_gr( %ld ) -> %ld\n", n1, *stack_ptr ));
   stack_ptr++;
} /* round_gr() */

void round_bl( void )
{
F26Dot6 n1;
   n1 = pop();
   *stack_ptr = do_round( n1+COMP_black );
   iprintf(( "round_bl( %ld ) -> %ld\n", n1, *stack_ptr ));
   stack_ptr++;
} /* round_bl() */

void round_wh( void )
{
F26Dot6 n1;
   n1 = pop();
   *stack_ptr = do_round( n1+COMP_white );
   iprintf(( "round_wh( %ld ) -> %ld\n", n1, *stack_ptr ));
   stack_ptr++;
} /* round_wh() */

void nround_gr( void )
{
F26Dot6 n1;
   n1 = pop();
   iprintf(( "nround_gr( %ld )\n", n1 ));
   *stack_ptr++ = n1;
} /* nround_gr() */

void nround_bl( void )
{
F26Dot6 n1;
   n1 = pop()+COMP_black;
   iprintf(( "nround_bl( %ld )\n", n1 ));
   *stack_ptr++ = n1;
} /* nround_bl() */

void nround_wh( void )
{
F26Dot6 n1;
   n1 = pop()+COMP_white;
   iprintf(( "nround_wh( %ld )\n", n1 ));
   *stack_ptr++ = n1;
} /* nround_wh() */

void rthg( void )
{
   iprintf(( "rthg: round_state = rsHG\n" ));
   Graphics_State.round_state = rsHG;
} /* rthg() */

void rtg( void )
{
   iprintf(( "rtg: round_state = rsG\n" ));
   Graphics_State.round_state = rsG;
} /* rtg() */

void rtdg( void )
{
   iprintf(( "rtdg: round_state = rsDG\n" ));
   Graphics_State.round_state = rsDG;
} /* rtdg() */

void rdtg( void )
{
   iprintf(( "rdtg: round_state = DTG\n" ));
   Graphics_State.round_state = rsDTG;
} /* rdtg() */

void rutg( void )
{
   iprintf(( "rutg: round_state = rsUTG\n" ));
   Graphics_State.round_state = rsUTG;
} /* rutg() */

void roff( void )
{
   iprintf(( "roff: round_state = rsOFF\n" ));
   Graphics_State.round_state = rsOFF;
} /* roff() */

void sround( void )
{
uint16 n = pop();
   iprintf(( "sround: round_state = 0x%x\n", (int)n ));
   Graphics_State.round_state = n;
} /* sround() */


/******************
*  cvt operations
******************/

const static F26Dot6 get_CVT( int n )
{
   assert( n < nr_cvt_entries );
   return (get_Scale64() * cvtWorkp[n]) >> fScaleShift;   /* cvt is in FUnits */
} /* get_CVT() */

void rcvt( void )
{
int n = pop();
int32 c;
   c = get_CVT( n );
   iprintf(( "rcvt[%d] is %ld\n", n, c ));
   assert( n < nr_cvt_entries );
   *stack_ptr++ = c;
} /* rcvt() */

void wcvtf( void )
{
int n;	/* location */
int32 c;	/* value */
   c = pop();
   n = pop();
   iprintf(( "wcvtf[%d] is %ld\n", n, c ));
   assert( n < nr_cvt_entries );
   cvtWorkp[n] = c;
} /* wcvtf() */

void wcvtp( void )
{
int n;	/* location */
int32 c;	/* value, in (F26Dot6) pixel coords */
   c = pop();
   n = pop();
   assert( n < nr_cvt_entries );
   cvtWorkp[n] = (c << fScaleShift)/get_Scale64();
   iprintf(( "wcvtp[%d] is %ld pixels, %ld FUnits\n", n, c, (long)cvtWorkp[n] ));
} /* wcvtp() */

void scvtci( void )
{

F26Dot6 n = pop();
   iprintf(( "set cvt cut in = %ld\n", n ));
   Graphics_State.control_value_cut_in = n;
} /* scvtci() */


/******************
*  point operations
******************/

void miap0( void )
{
uint16 n;	/* cvt entry nr */
uint16 pn;	/* point nr */
point_Rec *pp;
register F26Dot6 t;
   n = pop();
   assert( n < nr_cvt_entries );
   pn = pop();	/* <<< touch!!! */
   Graphics_State.rp0 = Graphics_State.rp1 = pn;
   pp = get_point( Graphics_State.zp0, pn );
   t = get_CVT(n);
   if( Graphics_State.projection_vector.y == 0 ) {
      pp->xcoord = t;
   }
   else if( Graphics_State.projection_vector.x == 0 ) {
      pp->ycoord = t;
   }
   else {
      iprintf(( "oblique projection vector!\n" ));
      pp->xcoord = (t*Graphics_State.projection_vector.x) >> 14;
      pp->ycoord = (t*Graphics_State.projection_vector.y) >> 14;
   } /* if */
   iprintf(( "miap[0], move %s point %d to (%ld,%ld). cvt(%d) is %ld\n",
               Graphics_State.zp0 ? "Glyf" : "twilite",
	       pn, (uint32)pp->xcoord, (uint32)pp->ycoord, n, (uint32)t ));
} /* miap0() */


void miap1( void )
{
uint16 n;	/* cvt entry nr */
uint16 pn;	/* point nr */
point_Rec *pp;
point_Rec org_pos;
register F26Dot6 t;
   n = pop();
   assert( n < nr_cvt_entries );
   pn = pop();	/* <<< touch!!! */
   Graphics_State.rp0 = Graphics_State.rp1 = pn;
   pp = get_point( Graphics_State.zp0, pn );
   org_pos = *pp;
   t = get_CVT(n);
   if( Graphics_State.projection_vector.y == 0 ) {
      pp->xcoord = do_round(abs(pp->xcoord - t ) > Graphics_State.control_value_cut_in ?
                        pp->xcoord : t );
   }
   else if( Graphics_State.projection_vector.x == 0 ) {
      pp->ycoord = do_round(abs(pp->ycoord - t ) > Graphics_State.control_value_cut_in ?
                        pp->ycoord : t );
   }
   else {
      iprintf(( "miap[1] not imlemented for oblique projection vector,!" ));
      iprintf(( "\n", getchar() ));
      return;
   } /* if */
   iprintf(( "miap[1], move %s point %d from (%ld,%ld) -> (%ld,%ld). cvt(%d) is %ld\n",
               Graphics_State.zp0 ? "Glyf" : "twilite",
	       pn, (uint32)org_pos.xcoord, (uint32)org_pos.ycoord,
	       (uint32)pp->xcoord, (uint32)pp->ycoord, n, (uint32)t ));
} /* miap1() */


void mdap0( void )
{
uint16 pn;	/* point nr */
   pn = pop();	/* <<< touch!!! */
   Graphics_State.rp0 = Graphics_State.rp1 = pn;
   iprintf(( "mdap[0], touch %s point %d\n",
               Graphics_State.zp0 ? "Glyf" : "twilite", pn ));
} /* mdap0() */


void mdap1( void )
{
uint16 pn;	/* point nr */
point_Rec *pp;
point_Rec org_pos;
   pn = pop();	/* <<< touch!!! */
   Graphics_State.rp0 = Graphics_State.rp1 = pn;
   pp = get_point( Graphics_State.zp0, pn );
   org_pos = *pp;
   if( Graphics_State.projection_vector.y == 0 ) {
      pp->xcoord = do_round( pp->xcoord );
   }
   else if( Graphics_State.projection_vector.x == 0 ) {
      pp->ycoord = do_round( pp->ycoord );
   }
   else {
      iprintf(( "mdap[1] no rounding for oblique projection vector,!" ));
      iprintf(( "\n", getchar() ));
   } /* if */
   iprintf(( "mdap[1], move %s point %d from (%ld,%ld) -> (%ld,%ld)\n",
               Graphics_State.zp0 ? "Glyf" : "twilite",
	       pn, (uint32)org_pos.xcoord, (uint32)org_pos.ycoord,
	       (uint32)pp->xcoord, (uint32)pp->ycoord ));
} /* mdap1() */


void mdrp( void )
{
uint16 pn;	     /* touch!!! <<< */     /* point nr */
point_Rec *ap, *bp, *arp0, *brp0;
F26Dot6   d;	/* distance to move */
uint8     flags = ins_ptr[-1]&31;

   pn = pop();	/* <<< touch!!! */
   ap = get_org_point( Graphics_State.zp1, pn );
   arp0 = get_org_point( Graphics_State.zp0, Graphics_State.rp0 );

   d = get_distance( arp0, ap );

   if( abs( abs(d)-Graphics_State.single_width_value )
                   < Graphics_State.single_width_cut_in ) {
      d = d>=0 ? Graphics_State.single_width_value
               : -Graphics_State.single_width_value;
   } /* if */

   if( flags&4) {
      assert( (flags&3) != 3 );
      if( flags&1 ) {
         d += COMP_black;
      }
      else if( flags&2 ) {
         d += COMP_white;
      } /* if */
      d = do_round( d );
   } /* if */

   if( flags&8 ) {
      if( abs(d) < Graphics_State.minimum_distance ) {
         d = d>0 ? Graphics_State.minimum_distance
	         : -Graphics_State.minimum_distance;
      } /* if */
   } /* if */

   /* assert( reference point is already rounded ) */
   brp0 = get_point( Graphics_State.zp0, Graphics_State.rp0 );
   d += get_distance( arp0, brp0 );
   move_point( ap, bp, d );

   Graphics_State.rp1 = Graphics_State.rp0;
   Graphics_State.rp2 = pn;
   if( flags&16 ) {
      Graphics_State.rp0 = pn;
   } /* if */

   iprintf(( "mdrp[%x], move %s point %d from (%ld,%ld) -> (%ld,%ld)\n",
               flags, Graphics_State.zp1 ? "Glyf" : "twilite",
	       pn, (uint32)ap->xcoord, (uint32)ap->ycoord,
	       (uint32)bp->xcoord, (uint32)bp->ycoord ));
} /* mdrp() */

void mirp( void ) {

  /** .......  **/

} /* mirp */


/* align point to rp0 */
void alignrp( void ) {
uint16 pn;	     /* touch!!! <<< */     /* point nr */
point_Rec *p, *rp0;
point_Rec org_p;
F26Dot6   d;	/* distance to move */

   rp0 = get_point( Graphics_State.zp0, Graphics_State.rp0 );
   while( Graphics_State.loop > 0 ) {
      pn = pop();  /* <<< touch!!! */
      p = get_point( Graphics_State.zp1, pn );
      org_p = *p;
      d = get_distance( p, rp0 );
      move_point( p, p, d ); /* what if fv & pv are not parallel? <<< */
      iprintf(( "alignrp, move %s point %d from (%ld,%ld) -> (%ld,%ld)\n",
		  Graphics_State.zp1 ? "Glyf" : "twilite",
		  pn, (uint32)org_p.xcoord, (uint32)org_p.ycoord,
		  (uint32)p->xcoord, (uint32)p->ycoord ));
      Graphics_State.loop--;
   } /* while */
   Graphics_State.loop = 1;
} /* alignrp() */

void gc0( void )
{
int n = pop();   	/* point nr */
point_Rec *p;
   p = get_point(Graphics_State.zp2, n );
   if( Graphics_State.projection_vector.y == 0 ) {
      *stack_ptr++ = p->xcoord;
   }
   else if( Graphics_State.projection_vector.x == 0 ) {
      *stack_ptr++ = p->ycoord;
   }
   else {
      iprintf(( "oblique projection vector!\n" ));
      *stack_ptr++ = (p->xcoord*Graphics_State.projection_vector.x
                   + p->ycoord*Graphics_State.projection_vector.y) >> 14;
   } /* if */
   iprintf(( "current coord of %s point %d = %ld\n",
             Graphics_State.zp2 ? "glyf" : "twilite", n, stack_ptr[-1] ));

} /* gc0() */

void gc1( void )
{
int n = pop();   	/* point nr */
point_Rec *p;
   assert( (Graphics_State.zp2!=0) || (n<maxpp->maxTwilightPoints) );
   assert( (Graphics_State.zp2==0) || (n<maxpp->maxTwilightPoints) );
   if( Graphics_State.zp2 == 0 ) {
      /** original twilite points are at origin **/
      *stack_ptr++ = 0;
   }
   else {
      p = orgGlyf_Point + n;
      if( Graphics_State.projection_vector.y == 0 ) {
	 *stack_ptr++ = p->xcoord;
      }
      else if( Graphics_State.projection_vector.x == 0 ) {
	 *stack_ptr++ = p->ycoord;
      }
      else {
	 iprintf(( "oblique projection vector!\n" ));
	 *stack_ptr++ = (p->xcoord*Graphics_State.projection_vector.x
		      + p->ycoord*Graphics_State.projection_vector.y) >> 14;
      } /* if */
   } /* if */
   iprintf(( "orig coord of %s point %d = %ld\n",
             Graphics_State.zp2 ? "glyf" : "twilite", n, stack_ptr[-1] ));

} /* gc1() */


/* interpolate point
** this instruction is affected by Graphics_State.loop */
void ip( void )
{
F26Dot6 ad0, bd0;			    /* distances beteween points */
point_Rec *arp1, *arp2, *brp1, *brp2;  /* point coords */
   arp1 = get_org_point( Graphics_State.zp0, Graphics_State.rp1 );
   brp1 = get_point( Graphics_State.zp0, Graphics_State.rp1 );
   arp2 = get_org_point( Graphics_State.zp1, Graphics_State.rp2 );
   brp2 = get_point( Graphics_State.zp1, Graphics_State.rp2 );
   ad0 = get_distance( arp1, arp2 );
   bd0 = get_distance( brp1, brp2 );

   while( Graphics_State.loop > 0 ) {

   uint16 pn = pop();	     /* touch!!! <<< */     /* point nr */
   F26Dot6 ad1, bd1;	     /* distances beteween points */
   point_Rec *ap, *bp;       /* point coords */
      ap = get_org_point( Graphics_State.zp2, pn );
      bp = get_point( Graphics_State.zp2, pn );

      ad1 = get_distance( arp1, ap );

      if( ad0 == bd0 ) {
	 bd1 = ad1;
      }
      else {
	 assert( bd0 != 0 );
	 bd1 = ad1*ad0/bd0;
      } /* if */

      move_point( ap, bp, bd1 );

      iprintf(( "interpolate point %d: (%d, %d) --> (%d, %d), error is %d \n",
		  pn, ap->xcoord, ap->ycoord, bp->xcoord, bp->ycoord,

      abs(get_distance(ap, arp2)*bd0 - get_distance(bp, brp2)*ad0) ));

      Graphics_State.loop--;
   } /* while */
   Graphics_State.loop = 1;

} /* ip() */

/* set coordinate from stack */
void scfs( void )
{
uint16 pn;
F26Dot6 bd1;
point_Rec *bp;
   bd1 = pop();
   pn = pop();
   bp = get_point( Graphics_State.zp2, pn );

   /** move point along freedom vector,
   *   so its coord along projection vector changes by bd1 **/
   if( Graphics_State.projection_vector.x == 0x4000 ) {
      bp->xcoord = bd1;
   }
   else if( Graphics_State.projection_vector.y == 0x4000 ) {
      bp->ycoord = bd1;
   }
   else {
   int32  alpha = (bd1<<16) /
          (( (int32)Graphics_State.projection_vector.x*Graphics_State.freedom_vector.x
           + (int32)Graphics_State.projection_vector.y*Graphics_State.freedom_vector.y )
	    >> 12);

      bp->xcoord = (Graphics_State.freedom_vector.x*alpha >> 14);
      bp->ycoord = (Graphics_State.freedom_vector.y*alpha >> 14);
   } /* if */

   iprintf(( "set point %d to %ld --> (%ld, %ld), error is %ld\n",
             (int)pn, (long) bd1, (long)bp->xcoord, (long)bp->ycoord,
            (long)(Graphics_State.projection_vector.x*bp->xcoord>>14)
                + (Graphics_State.projection_vector.y*bp->ycoord>>14) ));
} /* scfs() */


/******************
*  load the control value table for the current font
******************/
void pr_cvt ( const void *tableptr, const uint32 length )
{
int i;
point_Rec *pp;

   iprintf(( "cvt : control value table\n" ));

   cvtOrgp = (FWord *)tableptr;
   cvt_Size = length;
   nr_cvt_entries = length/sizeof(cvtOrgp[0]);
   cvtDefaultp = malloc( 2*length );
   cvtWorkp = cvtDefaultp + nr_cvt_entries;
   for( i=0; i<nr_cvt_entries; i++ ) {
      iprintf(( "cvt[%d] is %d\n", i, cvtOrgp[i] ));
   } /* for */
   /** set up twilight zone **/
   /* <<< maxpp->maxZones == 1 ??, ie no tw_Zone !! */
   pp = tw_Zonep = malloc( maxpp->maxTwilightPoints * sizeof(point_Rec) );
   assert( tw_Zonep );
   for( i=maxpp->maxTwilightPoints; i>0; pp++,i-- ) {
      pp->xcoord = pp->ycoord = 0;
   } /* for */
   pp = orgtw_Zonep = malloc( maxpp->maxTwilightPoints * sizeof(point_Rec) );
   assert( orgtw_Zonep );
   for( i=maxpp->maxTwilightPoints; i>0; pp++,i-- ) {
      pp->xcoord = pp->ycoord = 0;
   } /* for */
   orgGlyf_Point = malloc( maxpp->maxPoints*sizeof(point_Rec ) );
   Graphics_State = default_Graphics_State;

} /* pr_cvt () */


/******************
*  CVT program
*  set CVT for current point size
******************/
void pr_prep( const void *tableptr, const uint32 length )
{
   iprintf(( "define cvt pre-program, %ld instructions\n", length ));
   assert( length >= 1 );
   prepp = tableptr;
   prep_end = prepp + length;
} /* pr_prep() */

void run_prep( void )
{
   if( prepp != NULL ) {
      /*** there is a pre-program ***/
      iprintf(( "run cvt pre-program\n" ));
#if IBUG
      prg_start = prepp;
      prg_str = "pre";
      reset_ibug();
#endif
      Graphics_State = default_Graphics_State;
      memcpy( cvtWorkp, cvtOrgp, cvt_Size );
      interpret( prepp, prep_end );
      memcpy( cvtDefaultp, cvtWorkp, cvt_Size );
      Graphics_State0 = Graphics_State;
   } /* if */
} /* run_prep */

void instruct_glyph( BYTE *program_ptr, uint16 length, char gem_char )
{
#if IBUG
char s[8];
   sprintf( s, "'%c'", gem_char );
   prg_str = s;
   prg_start = program_ptr;
   reset_ibug();
#endif
   iprintf(( "\ninstruct glyph '%c', %d instructions\n", gem_char, length ));
   Graphics_State = Graphics_State0;
   memcpy( cvtWorkp, cvtDefaultp, cvt_Size );
   memcpy( orgGlyf_Point, Glyf_Point, maxpp->maxPoints*sizeof(point_Rec) );
   interpret( program_ptr, program_ptr + length );
} /* instruct_glyph() */

void free_interp1( void )
{
   free( cvtDefaultp );
   prepp = NULL;
   free( tw_Zonep );
   free( orgtw_Zonep );
   free( orgGlyf_Point );
} /* free_interp */

/********************* end of interp1.c **********************/


