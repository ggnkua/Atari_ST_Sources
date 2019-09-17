/*	$Id: GET_PUT.C,v 1.23 1994/06/12 22:00:00 SCR Exp SCR $ */

#include <aes.h>
#include <vdi.h>
#include <osbind.h>

#include "general.h"
#include "get_put.h"

#define MENU_MAGIC	(0x4d454e55)	/*	'MENU'	*/

static long Magic;
static MFDB Dst, Src;
static short Pxy0[4];
static short Pxy1[4];
static short Pxy2[4];
static short wd, ht;
static long  size;
static long  *Addr;

#define	LONG	(sizeof(long))

int menu_get(int vid, GRECT *area, int planes)
{
	if(Magic == MENU_MAGIC)
		return 0;

	rc_adjust(area, -4);

	wd = ((area->g_x + area->g_w - 1) | 15) - (area->g_x & ~15) + 1;
	ht = area->g_h;

	Src.fd_addr = NULL;

	size = (((long)wd * ht * planes) >> 3) + (LONG * 3);
	if((Addr = Malloc(size)) == NULL)
		return 0;
	size /= LONG;

	Magic			= MENU_MAGIC;
	Addr[0]			= MENU_MAGIC;
	Addr[1]			= size;
	Addr[size - 1]	= MENU_MAGIC;

	Dst.fd_addr = &Addr[2];
	Dst.fd_w = wd;
	Dst.fd_h = ht;
	Dst.fd_wdwidth = wd >> 4;
	Dst.fd_stand = 0;
	Dst.fd_nplanes = planes;
	Dst.fd_r1 = 0;
	Dst.fd_r2 = 0;
	Dst.fd_r3 = 0;

	gtovrect(area, Pxy0);
	gtovrect(area, Pxy2);

	Pxy1[0] = area->g_x & 15;
	Pxy1[1] = 0;
	Pxy1[2] = Pxy1[0] + area->g_w - 1;
	Pxy1[3] = area->g_h - 1;

	vro_cpyfm(vid, S_ONLY, Pxy0, &Src, &Dst);
	
	return 1;
}

void menu_put(int vid)
{
	long *Addr;
	long  size;

	Src.fd_addr = NULL;
	if(Magic == MENU_MAGIC)
	{
		Addr = Dst.fd_addr;
		if(Addr[-2] == MENU_MAGIC)
		{
			size = Addr[-1];
			if(Addr[size - 3] == MENU_MAGIC)
			{
				Magic					= 0L;
				Addr[-1]				= 0L;
				vro_cpyfm(vid, S_ONLY, Pxy1, &Dst, &Src);
				Mfree(Addr);
			}
		}
	}
}
