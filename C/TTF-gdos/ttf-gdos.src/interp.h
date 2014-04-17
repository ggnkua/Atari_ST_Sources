/****************** (c) Trevor Blight 2002 ***********************
*
* definitions for the ttf interpreter for ttf-gdos
*
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
*
******************/

#define I_SHOW 0

#if I_SHOW
#define iprintf(s)   printf s
#else
#define iprintf(s)
#endif

typedef const uint8 INSTRUCTION;

extern INSTRUCTION *prepp;	/* points to copy of cvt program */
extern FWord *cvtOrgp;
extern int32 *stack_ptr;
extern INSTRUCTION *ins_ptr;

void svtcay( void );
void svtcax( void );
void spvtcay( void );
void spvtcax( void );
void sloop( void );
void instctrl( void );
void scanctrl( void );
void scantype( void );
void mppem( void );
void rthg( void );
void rtg( void );
void rtdg( void );
void rdtg( void );
void rutg( void );
void roff( void );
void round_gr( void );
void round_bl( void );
void round_wh( void );
void nround_gr( void );
void nround_bl( void );
void nround_wh( void );
void sround( void );
void srp0( void);
void srp1( void);
void srp2( void);
void szp0( void);
void szp1( void);
void szp2( void);
void szps( void);
void miap0( void );
void miap1( void );
void mdap0( void );
void mdap1( void );
void mirp( void );
void mdrp( void );
void alignrp( void );
void gc0( void );
void gc1( void );
void ip( void );
void scvtci( void );
void rcvt( void );
void wcvtf( void );
void wcvtp( void );
void deltap1( void );
void deltap2( void );
void deltap3( void );
void deltac1( void );
void deltac2( void );
void deltac3( void );
void sdb( void );
void sds( void );
void scfs( void );
void sfvfs( void );
void spvfs( void );

void interpret( INSTRUCTION *begin, INSTRUCTION *end );

extern int32 *stack_Base;
extern INSTRUCTION *prg_start;
extern char *prg_str;

__inline__ static int32 pop( void )
{
   assert( stack_ptr > stack_Base );	/* there must be something to pop */
   return *--stack_ptr;
} /* pop() */

void free_interp1( void );

extern const F26Dot6 do_round( F26Dot6 );
extern void reset_ibug( void );
