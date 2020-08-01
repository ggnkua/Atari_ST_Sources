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
/* substuff.c */

#include "../sim.h"

power(x, n)
int x, n;
{
   int p;

   for (p = 1; n > 0; n--)
      p = p * x;
   return p;
}

getnum(nbytes, ptr)
LONG     nbytes;
CHAR_PTR ptr;
{
   LONG i, sum = 0, digit;

   for (i = nbytes; i > 0; i--) {
      digit = ptr[nbytes-i] - '0';
      sum = sum + digit * power(10, i-1);
   }
   return sum;
}

itoa(n, s)
int  n;
CHAR s[];
{
   int  i = 0, j;
   CHAR c;

   do {
      s[i++]  = n % 10 + '0';
   } while ((n /= 10) > 0);
   s[i] = '\0';

   /* reverse the string */

   for (i = 0, j = strlen(s) - 1; i < j; i++, j--) {
      c = s[i];
      s[i] = s[j];
      s[j] = c;
   }
}

numlength(n)
LONG n;
{
   WORD i;

   if (n < 0) {
      n = -n;
      i = 2;
   }
   else i = 1;
   while ((n /= 10) > 0)
      i++;
   return i;
}
