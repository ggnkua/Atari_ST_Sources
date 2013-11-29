/***************************
 * link.c                  *
 ***************************
 ***************************
 * [1998-06-02, tm]        *
 * - first C version       *
 ***************************/

#include "link.h"
#include "manager.h"
#include "doc.h"


int unLink(int pv, int gv, int *pipe)
{
	int ret = 0;
	char *pc = (pv) ? (*(char **)&pipe[3]) : NULL;
	Link *pld;

	_unlink:
	pld = links;
	
	while (pld)
	{
		if (pld->apID == pipe[1])
		{
			if (gv)
			{
				if (pld->Group != pipe[5]) goto _next;
			}
			
			if (pv)
			{
				if (stricmp(pld->Path,pc)) goto _next;
			}
			
			globalFree(pld->Path);
			
			if ((!pld->Prev) && (!pld->Next)) links = NULL;
			else
			{
				if (!pld->Prev) links = pld->Next;
				else
					pld->Prev->Next = pld->Next;
				
				if (pld->Next) pld->Next->Prev = pld->Prev;
			}
			
			free(pld);
			linkCount--;

			if (pv) ret++;
			
			goto _unlink;
		}

		_next:
		pld = pld->Next;
	}
	
	return(ret);
}



void olga_linkrenamed(int *pipe)
{
	Link *pld = links;
	char *pc = *(char **)&pipe[3], *pc2 = *(char **)&pipe[5];

	#ifdef DEBUG
	printf("OLGA: OLGA_LINKRENAMED App %i Group %i  %s -> %s\n",pipe[1],pipe[7],pc,pc2);
	#endif

	while (pld)
	{
		if (pld->Group == pipe[7])
		{
			if (pld->Path == pc)
			{
				char *p = globalAlloc(strlen(pc2)+1L);
				
				if (p)
				{
					strcpy(p,pc2);
					globalFree(pld->Path);
					pld->Path = p;
				}
			}
		}
		
		pld = pld->Next;
	}
}



void olga_breaklink(int *pipe)
{
	Link *pld = links;
	char *p = *(char **)&pipe[3];
	int answ[8];

	#ifdef DEBUG
	printf("OLGA: OLGA_BREAKLINK App %i  %s\n",pipe[1],p);
	#endif

	answ[0] = OLGA_LINKBROKEN;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[6] = 0;
	answ[7] = 0;
	
	while (pld)
	{
		if (!stricmp(pld->Path,p))
		{
			#ifdef DEBUG
			printf("      LinkBroken -> App %i Group %i\n",pld->apID,pld->Group);
			#endif

			answ[3] = (int)(((long)pld->Path >> 16) & 0x0000ffffL);
			answ[4] = (int)((long)pld->Path & 0x0000ffffL);
			answ[5] = pld->Group;

			appl_write(pld->apID,16,answ);
		}
		
		pld = pld->Next;
	}

	answ[0] = OLGA_ACK;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = 0;
	answ[7] = OLGA_BREAKLINK;

	appl_write(pipe[1],16,answ);
}



void olga_unlink(int *pipe)
{
	int answ[8];
	
	#ifdef DEBUG
	printf("OLGA: OLGA_UNLINK App %i Group %i  %s\n",pipe[1],pipe[5],*(char **)&pipe[3]);
	#endif
	
	answ[6] = unLink(TRUE,TRUE,pipe);
	answ[0] = OLGA_ACK;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = pipe[5];
	answ[7] = OLGA_UNLINK;

	appl_write(pipe[1],16,answ);
}



void olga_rename(int *pipe)
{
	int answ[8];
	char *pc = *(char **)&pipe[3];
	Link *pld = links;
	
	#ifdef DEBUG
	printf("OLGA: OLGA_RENAME App %i  %s -> %s\n",pipe[1],pc,*(char **)&pipe[5]);
	#endif
	
	answ[0] = OLGA_RENAMELINK;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[5] = pipe[5];
	answ[6] = pipe[6];
	
	while (pld)
	{
		if (!stricmp(pld->Path,pc))
		{
			#ifdef DEBUG
			printf("      RenameLink -> App %i Group %i\n",pld->apID,pld->Group);
			#endif
			
			answ[3] = (int)(((long)pld->Path >> 16) & 0x0000ffffL);
			answ[4] = (int)((long)pld->Path & 0x0000ffffL);
			answ[7] = pld->Group;

			appl_write(pld->apID,16,answ);
		}
		
		pld = pld->Next;
	}

	answ[0] = OLGA_ACK;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[7] = OLGA_RENAME;

	appl_write(pipe[1],16,answ);
}



void olga_link(int *pipe)
{
	int answ[8], found = FALSE;
	char *pc = *(char **)&pipe[3];
	Document *docd = docs;
	
	#ifdef DEBUG
	printf("OLGA: OLGA_LINK App %i Group %i  %s\n",pipe[1],pipe[5],pc);
	#endif
	
	while (docd)
	{
		if (docd->apID == pipe[1])
		{
			found = TRUE;
			break;
		}
		
		docd = docd->Next;
	}
	
	if (!found) open_doc(pipe);
	
	answ[6] = 0;
	
	if (pc)
	{
		Link *pl = (Link *)malloc(sizeof(Link));
		
		if (pl)
		{
			pl->apID  = pipe[1];
			pl->Group = pipe[5];
			pl->Path  = globalAlloc(strlen(pc)+1L);
			
			if (!pl->Path) free(pl);
			else
			{
				strcpy(pl->Path,pc);
				
				pl->Prev = NULL;
				pl->Next = NULL;
				
				if (!links) links = pl;
				else
				{
					Link *pld = links;
					
					while (pld->Next) pld = pld->Next;
					pld->Next = pl;
					pl->Prev = pld;
				}
				
				answ[6] = 1;
				linkCount++;
			}
		}
	}

	answ[0] = OLGA_ACK;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = pipe[5];
	answ[7] = OLGA_LINK;
	
	appl_write(pipe[1],16,answ);
}



void olga_update(int *pipe)
{
	int answ[8];
	char *pc = *(char **)&pipe[3];
	Link *pld = links;

	#ifdef DEBUG
	printf("OLGA: OLGA_UPDATE App %i  %s  Info %i\n",pipe[1],pc,pipe[5]);
	#endif

	answ[0] = OLGA_UPDATED;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[5] = pipe[5];
	answ[6] = pipe[1];
	
	while (pld)
	{
		if (!stricmp(pld->Path,pc))
		{
			#ifdef DEBUG
			printf("      Update -> App %i Group %i\n",pld->apID,pld->Group);
			#endif
			
			answ[3] = (int)(((long)pld->Path >> 16) & 0x0000ffffL);
			answ[4] = (int)((long)pld->Path & 0x0000ffffL);
			answ[7] = pld->Group;

			appl_write(pld->apID,16,answ);
		}
		
		pld = pld->Next;
	}
	
	if (notes)
	{
		char *p1 = strrchr(pc,'.'), *p2 = strrchr(pc,'\\');
		Note *pn = notes;
		int e4,e5;
		
		if (p1 > p2)
		{
			char ext[6];
			
			strncpy(ext,p1,5L);
			
			e4 = (toupper(ext[0]) << 8) | toupper(ext[1]);
			e5 = (toupper(ext[2]) << 8) | toupper(ext[3]);
		}
		else
		{
			e4 = e5 = 0;
		}

		answ[0] = OLGA_NOTIFY;
		answ[5] = 0;
		answ[6] = 0;
		answ[7] = 0;
		
		while (pn)
		{
			if (((pn->ext4 == e4) && (pn->ext5 == e5)) || ((!pn->ext4) && (!pn->ext5)))
			{
				char *p = globalAlloc(strlen(pc)+1L);

				#ifdef DEBUG
				printf("      Notify -> App %i\n",pn->apID);
				#endif
				
				if (p)
				{
					strcpy(p,pc);
					
					answ[3] = (int)(((long)p >> 16) & 0x0000ffffL);
					answ[4] = (int)((long)p & 0x0000ffffL);

					appl_write(pn->apID,16,answ);
				}
			}
			
			pn = pn->Next;
		}
	}

	answ[0] = OLGA_ACK;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = 0;
	answ[6] = 0;
	answ[7] = OLGA_UPDATE;
	
	appl_write(pipe[1],16,answ);
}
