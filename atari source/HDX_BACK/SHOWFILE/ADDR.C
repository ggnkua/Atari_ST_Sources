/* addr.c */
/*  04-Apr-92	ml.	Get addresses of all dialogues. */

#include "obdefs.h"
#include "mydefs.h"
#include "addr.h"
#include "show.h"

getalladdr()
{
    /* Dialogues shared by routines */
    if ((rsrc_gaddr(0, SCRPNL, &scrpnl) == 0) ||
    	(rsrc_gaddr(5, CNFDF, &cnfdf) == 0) ||
    	(rsrc_gaddr(5, CNRDF, &cnrdf) == 0) ||
    	(rsrc_gaddr(5, CNOPF, &cnopf) == 0) ||
    	(rsrc_gaddr(5, CNOPEN, &cnopen) == 0) ||
    	(rsrc_gaddr(5, BINONLY, &binonly) == 0) ||
    	(rsrc_gaddr(5, NEEDFILE, &needfile) == 0) ||
    	(rsrc_gaddr(5, CNSDIR, &cnsdir) == 0) ||
    	(rsrc_gaddr(5, OUTMEM, &outmem) == 0))  {
        return ERROR;

	}
    return OK;
}
