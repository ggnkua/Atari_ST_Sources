/* addr.c */
/*  04-Feb-88	ml.	Get addresses of all dialogues. */

#include "obdefs.h"
#include "mydefs.h"
#include "hdx.h"
#include "addr.h"

getalladdr()
{

    /* Dialogues for Format */        
    if (rsrc_gaddr(0, FWARNING, &fwarning) == 0
		|| rsrc_gaddr(0, FMTMSG, &fmtmsg) == 0
		|| rsrc_gaddr(0, DMRKMSG, &dmrkmsg) == 0
	 	|| rsrc_gaddr(0, PARTMSG, &partmsg) == 0)
		return ERROR;
	
	return OK;
}
