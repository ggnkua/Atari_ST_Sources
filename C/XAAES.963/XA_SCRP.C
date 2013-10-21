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

#include <string.h>
#include "xa_types.h"
#include "xa_globl.h"

/*
 *	Scrap/clipboard directory stuff
 */

/* HR */
AES_function XA_scrap_read	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,1,1)

	pb->intout[0] = 0;
	if (pb->addrin[0])		/* HR check pb */
	{
/* display("scrap_read: [%s]\n",cfg.scrap_path); */
		if (*cfg.scrap_path)		/* HR return 0 if not initialized */
		{
			strcpy(pb->addrin[0], cfg.scrap_path);
			pb->intout[0] = 1;
		}
	}

	return XAC_DONE;
}

AES_function XA_scrap_write	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char *new_path = pb->addrin[0];

	CONTROL(0,1,1)

/* display("scrap_write: %lx\n",new_path);	*/
	if (new_path and strlen(new_path) < 128)		/* HR check pb */
	{
/* display("scrap_write: [%s]\n",new_path);	*/
		strcpy(cfg.scrap_path, new_path);
		pb->intout[0] = 1;
	}
	else
		pb->intout[0] = 0;
	
	return XAC_DONE;
}
