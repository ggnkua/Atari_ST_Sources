/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/

#include <math.h>

static char buf[34];

/*         fp0         d0         a0       a1        */
char * ecvt(double x, int ndig, int *dec, int *sign)
{
	long cr;
	double y;
	char *s = buf;

	*sign = 0;
	*dec = 0;

	if (ndig > 32)
		ndig = 32;

	if (x)
	{
		if (x < 0)
			x = -x, *sign = 1;

		y = log10(x);

		cr = __FPCR__;
		__FPCR__ = 32;		/* round toward minus infinity */
		y = __FINT__ y;
		__FPCR__ = cr;

		*dec = (long)y + 1;
		x /= pow10(y);
		x += pow10(-ndig) * 5;

		if (x >= 10)
			(*dec)++, x /= 10;

		if (ndig > 0)
			while (ndig)
			{
				y = fintrz(x);		/* fintrz() does not involve a data register!!!! */
				x -= y;
				*s++ = (char)y + '0';
				x *= 10;
				--ndig;
			}
		else
			*s++ = '0';

		*s = 0;
		return buf;
	}

	while (ndig)
		*s++ = '0', --ndig;
	*s = 0;
	return buf;
}
