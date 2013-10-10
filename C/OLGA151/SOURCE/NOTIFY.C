/*********************************************
 * notify.c                                  *
 *********************************************
 *********************************************
 * [1998-06-02, tm]                          *
 * - first C version                         *
 * [1998-06-10, tm]                          *
 * - bug in denotify() removed, now it reads *
 *   "while (pn)" and not "while (pn);"...   *
 *********************************************/

#include "notify.h"
#include "manager.h"


void denotify(int orgID, int e4, int e5)
{
	Note *pn;
	
	_again:
	pn = notes;
	
	while (pn)
	{
		if (pn->apID == orgID)
		{
			if (((pn->ext4 == e4) && (pn->ext5 == e5)) || ((!e4) && (!e5)))
			{
				if ((!pn->Prev) && (!pn->Next)) notes = NULL;
				else
				{
					if (!pn->Prev) notes = pn->Next;
					else
						pn->Prev->Next = pn->Next;
					
					if (pn->Next) pn->Next->Prev = pn->Prev;
				}
				
				free(pn);
				goto _again;
			}
		}
		
		pn = pn->Next;
	}
}



void olga_requestnotification(int *pipe)
{
	Note *pn = (Note *)malloc(sizeof(Note));
	
	if (pn)
	{
		denotify(pipe[1],pipe[3],pipe[4]);
		
		pn->apID = pipe[1];
		pn->ext4 = pipe[3];
		pn->ext5 = pipe[4];
		pn->Prev = NULL;
		pn->Next = NULL;
		
		if (!notes) notes = pn;
		else
		{
			Note *pnd = notes;
			
			while (pnd->Next) pnd = pnd->Next;
			pnd->Next = pn;
			pn->Prev = pnd;
		}
	}
}



void olga_releasenotification(int *pipe)
{
	#ifdef DEBUG
	printf("OLGA: OLGA_RELEASENOTIFICATION App %i (",pipe[1]);
	if ((!pipe[3]) && (!pipe[4])) printf("all)\n");
	else
		printf("%c%c%c%c)\n",(pipe[3] >> 8) & 0x00ff,pipe[3] & 0x00ff,(pipe[4] >> 8) & 0x00ff,pipe[4] & 0x00ff);
	#endif
	
	denotify(pipe[1],pipe[3],pipe[4]);
}



void olga_notified(int *pipe)
{
	char *p = *(char **)&pipe[3];

	#ifdef DEBUG
	printf("OLGA: OLGA_NOTIFIED App %i  %s\n",pipe[1],p);
	#endif

	globalFree(p);
}
