/*  Copyright (c) (c)1990 Han Driesen
 *
 * This file is part of TTDIGGER.
 *
 * TTDIGGER is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTDIGGER is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with TTDIGGER; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <prelude.h>
#define LSEL 40		/* must be same as in aaaa.h */

global
uchar *zkey,
	  nxk[256],
	  td1[256];
global
long qpkl;

global
void qpfind_prepare(long l,uchar *key)
{
	long i,kp=0;

	qpkl = l;
	zkey = key;
	nxk[0]=255;
	for (i=1;i<=l-1;i++)
	{
		nxk[i]=kp;
		do
		{
			if (key[i] eq key[kp])
			{
				nxk[i]=nxk[kp];
				break;
			}
			kp=nxk[kp];
		}
		while (kp ne 255);
		kp=(kp+1)&0xff;
	}
	for(i=0;i<=LSEL;i++)
		td1[i]=l;
	for(i=1;i<=l;i++)
		td1[key[i-1]]=l-i;
}
