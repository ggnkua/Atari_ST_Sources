/* addr.c */
/*  04-Feb-88	ml.	Get addresses of all dialogues. */

#include "obdefs.h"
#include "mydefs.h"
#include "hdxpch.h"
#include "ipart.h"
#include "addr.h"

getalladdr()
{
    /* Dialogues shared by routines */
    if (rsrc_gaddr(0, MENUBAR, &menuobj) == 0
        || rsrc_gaddr(0, ABOUT, &abtdial) == 0
		|| rsrc_gaddr(0, PHYSDEV, &physdial) == 0
    	|| rsrc_gaddr(0, SCANMSG, &scanmsg) == 0
		|| rsrc_gaddr(0, PARTMSG, &partmsg) == 0
    	|| rsrc_gaddr(5, ROOTREAD, &rootread) == 0
    	|| rsrc_gaddr(5, NOMEMORY, &nomemory) == 0
    	|| rsrc_gaddr(5, OLDFMT, &oldfmt) == 0
		|| rsrc_gaddr(5, MDMCHNG, &mdmchng) == 0
		|| rsrc_gaddr(5, DRVNRDY, &drvnrdy) == 0
		|| rsrc_gaddr(5, INSTDRV, &instdrv) == 0)
		return ERROR;
	
    return OK;
}
