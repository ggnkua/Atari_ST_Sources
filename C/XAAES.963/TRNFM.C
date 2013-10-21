/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* This code is from Mario Becroft.  Thanks a lot Mario! 
   modifications:
   		use C.vh
   		call xmalloc for temps
   		kept control over allocated permanent areas outside
   		cast void *fd_addr to char *
   		just return true or false
   		source level optimizations for bit handling (partly faster, partly smaller)
    	see below
*/

#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "xalloc.h"
#include "trnfm.h"

static
long map_size(MFDB *m, int i)
{
	long l = m->fd_wdwidth * 2L * m->fd_h * m->fd_nplanes;		/* HR 270302: 2L!!!!! */
/*	DIAGS(("[%d]map_size: wd %d, h %d, planes %d --> %ld\n", i, m->fd_wdwidth, m->fd_h, m->fd_nplanes, l));
*/	return l;
}

global
bool transform_gem_bitmap_data(MFDB msrc, MFDB mdest, int src_planes, int dst_planes)
{
	static G_i devtovdi8[] 
	={0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255,
	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,
	48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
	80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,
	113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,
	141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,
	169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,
	197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,
	225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,1};
	static G_i devtovdi4[] = {0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1};
	static G_i devtovdi2[] = {0,2,3,1};
	static G_i devtovdi1[] = {0,1};

	if (src_planes <= 8 and dst_planes <= 8)
		vr_trnfm( C.vh, &msrc, &mdest );
	else if (src_planes <= 8)
	{
		int i;
		G_i x, y, pxy[8], colours[2];
		long plane_int_size = msrc.fd_wdwidth * msrc.fd_h;
		G_i *colour_lut,
		     bits[8], bit, mask;
		char used_colours[256];
		MFDB tmp, tmp2;
DIAGS(("dst_planes %d\n", dst_planes));
		tmp = msrc;
		tmp.fd_nplanes = 1;
		tmp.fd_h = 1 << (src_planes);
		tmp.fd_addr = xmalloc(map_size(&tmp,1), 21);
		if (!tmp.fd_addr)
			return false;

		tmp2 = tmp;
		tmp2.fd_stand = 0;
		tmp2.fd_addr = xmalloc(map_size(&tmp2,2), 22);
		if (!tmp2.fd_addr)
			tmp2.fd_addr = tmp.fd_addr;
		
		colours[1] = 0;
		pxy[4] = pxy[0] = 0;
		pxy[5] = pxy[1] = 0;
		pxy[6] = pxy[2] = mdest.fd_w - 1;
		pxy[7] = pxy[3] = mdest.fd_h - 1;
		/*vro_cpyfm( C.vh, ALL_WHITE, pxy, &mdest, &mdest );*/
		/* The above line crashes in Falcon TC (w/o NVDI) for some reason ?! */
		DIAGS(("mdest planes %d\n", mdest.fd_nplanes));
		memset( mdest.fd_addr, 0, map_size(&mdest,3));
		mask = (1 << src_planes) - 1;
		
		switch (src_planes)
		{
			case 8:	colour_lut = devtovdi8;	break;
			case 4:	colour_lut = devtovdi4;	break;
			case 2:	colour_lut = devtovdi2;	break;
			case 1: colour_lut = devtovdi1;	break;
			default:
				/* This should never happen */
				free( tmp.fd_addr );
				if (tmp2.fd_addr != tmp.fd_addr)
					free( tmp2.fd_addr );
				return false;
		}

		for ( y = 0; y < msrc.fd_h; y++ )
		{
			pxy[4] = pxy[0] = 0;
			pxy[5] = pxy[1] = 0;
			pxy[6] = pxy[2] = tmp.fd_w - 1;
			pxy[7] = pxy[3] = tmp.fd_h - 1;
			/*vro_cpyfm( C.vh, ALL_WHITE, pxy, &tmp, &tmp );*/
			/* The above line crashes in Falcon TC (w/o NVDI) for some reason ?! */
			memset( tmp.fd_addr, 0, map_size(&tmp,4));
			memset( used_colours, 0, sizeof( used_colours ) );
			for ( x = 0; x < msrc.fd_wdwidth; x++ )
			{		
				G_i *ptr = (G_i *)((char *)msrc.fd_addr + (y * msrc.fd_wdwidth * 2) + (x << 1));
				G_i *step = ptr;

/* Get the 16 bit from each plane in bits[8] */
				i = 0;
				while (i < src_planes)
					bits[i++] = *step,
					step += plane_int_size;
			
/* Now built the colour index number from them by taking 1 bit from each bits[j]. */
				for ( i = 0; i < 16; i++ )
				{
					int j;
					bit = 0;
					for (j = src_planes - 1; j >= 0; j--)		/* HR: works also for j = 0 */
					{
						bit <<= 1;
						bit |= (bits[j] >> i) & 1;
					}

					bit &= mask;
					
					if (bit < tmp.fd_h)
					{
						ptr = (G_i *)((char *)tmp.fd_addr + (bit * msrc.fd_wdwidth * 2) + (x << 1));
						*ptr |= 1 << i;
						used_colours[bit] = 1;
					}
				}
			}

			pxy[5] = pxy[7] = y;
			vr_trnfm( C.vh, &tmp, &tmp2 );

			for ( i = 0; i < tmp.fd_h; i++ )
			{
				if (used_colours[i])
				{
					colours[0] = colour_lut[i];
					pxy[1] = pxy[3] = i;
					vrt_cpyfm( C.vh, MD_TRANS, pxy, &tmp2, &mdest, colours );
				}
			}
		}
		
		if (tmp2.fd_addr != tmp.fd_addr)
			free( tmp2.fd_addr );
		free( tmp.fd_addr );
	}
	else
		return false;
	
	return true;
}

