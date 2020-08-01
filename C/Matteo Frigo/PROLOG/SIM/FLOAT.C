/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/*  WAM representation of floats:
 *     bits 0-2 : tag (010);
 *     bits 3-7 : absolute value of exponent;
 *     bits 8-28: absolute value of mantissa;
 *     bit    29: sign of exponent (1: negative);
 *     bit    30: sign of mantissa (1: negative).
*/

#include "sim.h"
#include "aux.h"

#define Bit20          0x100000
#define Bits15to19     0x0f8000

#define MIN(x, y)      (x > y ? y : x)

#define EXP_SIGN       0x20000000
#define MANT_SIGN      0x40000000
#define EXP_MAGN(op)   (((unsigned)(op & 0xf8)) >> 3)
#define MANT_MAGN(op)  (((unsigned)(op & 0x1fffff00)) >> 8)

double frexp(), ldexp();   /* C library routines */

/* "floatval" converts floats from the WAM representation to
 *            the machine representation.
*/
double floatval(op)
LONG op;
{
   LONG   exponent, exp;
   double fval;

   fval = (double)MANT_MAGN(op);
   exponent = EXP_MAGN(op);
   exp = (op & EXP_SIGN) ? -exponent : exponent;
   if (op & MANT_SIGN)
      fval = -fval;
   fval = ldexp(fval, exp);
   return fval;
}

/* "makefloat" converts floats from the machine representation
 *             to the WAM representation.
*/
LONG makefloat(op)
double op;
{
   LONG         exp_sign, mant_sign, int_op;
   int          exponent, nshift;
   WORD         num_gaps;
   unsigned int mask;

   if (op < 0) {
      mant_sign = MANT_SIGN;
      op = -op;
   }
   else mant_sign = 0;
   op = frexp(op, &exponent);
   if (op == 0.0 || exponent <= -32) {
      int_op = 0;
      exponent = 0;
   } else {
      while(!((int_op = (int)(op + 0.5)) & Bit20) && exponent > -31) {
         /* keep top 10 bits clear for shifting */
         mask = (int_op & Bits15to19) >> 15;
         switch (mask) {
            case  0: num_gaps = 6;  break;
            case  1: num_gaps = 5;  break;
            case  2:
            case  3: num_gaps = 4;  break;
            case  4:
            case  5:
            case  6:
            case  7: num_gaps = 3;  break;
            case  8:
            case  9:
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15: num_gaps = 2;  break;
            default: /* cases 16 to 31 */
                     num_gaps = 1;  break;
         }
         nshift = MIN(exponent - (-31), num_gaps);
         switch (nshift) {
            case 0 : break;
            case 1 : op *= 2;   break;
            case 2 : op *= 4;   break;
            case 3 : op *= 8;   break;
            case 4 : op *= 16;  break;
            case 5 : op *= 32;  break;
            case 6 : op *= 64;  break;
            default: printf("makefloat: unexpected multiplier %d\n", nshift);
         }
         exponent -= nshift;
      }  /* while */
   }  /* else */

   if (exponent < 0) {
      exponent = -exponent;
      exp_sign = EXP_SIGN;
   } else exp_sign = 0;

   return (((LONG)int_op << 8) | (exponent << 3) |
	   exp_sign | mant_sign | FLOAT_TAG);
}


