/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <strings.h>
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
