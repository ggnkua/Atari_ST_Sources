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

void
do_identd(void)
{
	int16 count;
/*	char cline[80] = "";*/

	NDB *blk;

	count = CNbyte_count(config.identdcn);
	
	if (count > 0)
		{
			disp_info("We've gotten an identd hit\n");

			blk = CNget_NDB(config.identdcn);

        	if (blk != (NDB *)NULL) 
        		{
        			char cline[80] = "";
        		
					strncpy(cline,blk->ndata,(blk->len-2));
					strcat(cline," : USERID : UNIX : ");
					strcat(cline,config.username);
					strcat(cline,"\r\n");

				    TCP_send(config.identdcn, cline, (int16)strlen(cline));
	
					
					intfree_NDB(config.identdcn, blk);	
		        }
		}
	else if (count < -2)
		{
			if (count != E_LISTEN && count != E_BADHANDLE)
				{
					/* close old identd server */
					TCP_close(config.identdcn,0);
			
					/* open new one */
					config.identdcn = TCP_open( 0L, 113, 0, 2000);
				}
		}

}