/******************************
 * getserv.c                  *
 ******************************
 ******************************
 * [1998-06-02, tm]           *
 * - first C version          *
 ******************************/

#include "getserv.h"
#include "manager.h"


void olga_ack(int *pipe)
{
	#ifdef DEBUG
	printf("OLGA: OLGA_ACK App %i  (%i)\n",pipe[1],pipe[7]);
	#endif

	if (pipe[7] == OLGA_SERVERPATH) globalFree(*(char **)&pipe[5]);
}



void olga_getserverpath(int *pipe)
{
	int answ[8];
	char *rets = NULL;
	Extension *pe = extensions;

	#ifdef DEBUG
	printf("OLGA: OLGA_GETSERVERPATH App %i (%c%c%c%c)\n",pipe[1],(pipe[3] >> 8) & 0x00ff,pipe[3] & 0x0ff,(pipe[4] >> 8) & 0x00ff,pipe[4] & 0x0ff);
	#endif
	
	answ[0] = OLGA_SERVERPATH;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = 0;
	answ[6] = 0;
	answ[7] = 0;
	
	while (pe)
	{
		if (pe->ext5 == pipe[4])
		{
			if (pe->ext4 == pipe[3])
			{
				rets = globalAlloc(512L);
				
				if (rets)
				{
					strcpy(rets,pe->path);
					expand_path(rets);
				}
				
				break;
			}
		}
		
		pe = pe->next;
	}
	
	if (rets)
	{
		Object *po = objects;

		answ[5] = (int)(((long)rets >> 16) & 0x0000ffffL);
		answ[6] = (int)((long)rets & 0x0000ffffL);
		
		while (po)
		{
			if (po->ext5 == pipe[4])
			{
				if (po->ext4 == pipe[3])
				{
					answ[7] |= OL_SRV_ID4;
					break;
				}
			}
			
			po = po->next;
		}
	}

	appl_write(pipe[1],16,answ);
}
