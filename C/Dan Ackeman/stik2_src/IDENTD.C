/* identd.c			(c)FreeSTiK Team 1999
 *
 * small module ran off of the main interupt.  
 * manages identd server requests
 *
 */

#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include <display.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"

extern CCB ctn[];  /* Connection Control Block list */

void
do_identd(GPKT *blk)
{
	char cline[256] = "";
	int16 hlen;
    register OUTQ *oq = ctn[config.identdcn].tcb->outq;   
	TCP_HDR *tcph = (TCP_HDR *)blk->mp;

    hlen = tcph->ofst * 4;         /* Calc header len  */

    blk->data = &blk->mp[hlen];     /* set generic data pointer to first char   */
    blk->dlen = blk->mlen - hlen;   /* after TCP header, and set the data size  */

	if (blk->dlen>0)
		{
			strncpy(cline,blk->data,(blk->dlen-2));
			strcat(cline," : USERID : UNIX : ");
			strcat(cline,config.username);
			strcat(cline,"\r\n");
	
/*			disp_info("identd hit");
			disp_info("resp = %s",cline);
*/
			/* TCP_send would take to long so
				we are just going to fake the send
				from here and output the packet */
				
			memcpy(&oq->buf[oq->nw], cline, (int16)strlen(cline));
			oq->nw += (int16)strlen(cline);
			oq->cnt += (int16)strlen(cline);
			ctn[config.identdcn].tcb->sndcnt += (int16)strlen(cline);
			
			tcp_output(config.identdcn);
		}

	/* Kill the packet it won't be anywhere else */
    delete_packet(blk, NT_QUEUEDOK);
}