/**************************
 * doc.c                  *
 **************************
 **************************
 * [1998-06-02, tm]       *
 * - first C version      *
 **************************/

#include "doc.h"
#include "link.h"
#include "manager.h"


void open_doc(int *pipe)
{
	Document *doc = (Document *)malloc(sizeof(Document));

	if (doc)
	{
		doc->apID  = pipe[1];
		doc->Group = pipe[5];
		doc->Prev  = NULL;
		doc->Next  = NULL;
		
		if (!docs) docs = doc;
		else
		{
			Document *docd = docs;
			
			while (docd->Next) docd = docd->Next;
			docd->Next = doc;
			doc->Prev = docd;
		}
		
		docCount++;
	}
}



void close_doc(int gv, int *pipe)
{
	Document *docd;
	
	_closedoc:
	docd = docs;
	
	while (docd)
	{
		if (docd->apID == pipe[1])
		{
			if (gv)
			{
				if (docd->Group != pipe[5]) goto _next;
			}
			
			if ((!docd->Prev) && (!docd->Next)) docs = NULL;
			else
			{
				if (!docd->Prev) docs = docd->Next;
				else
					docd->Prev->Next = docd->Next;
				
				if (docd->Next) docd->Next->Prev = docd->Prev;
			}
			
			free(docd);
			docCount--;
			goto _closedoc;
		}

		_next:
		docd = docd->Next;
	}
}



void olga_opendoc(int *pipe)
{
	int answ[8];

	#ifdef DEBUG
	printf("OLGA: OLGA_OPENDOC App %i Group %i\n",pipe[1],pipe[5]);
	#endif
	
	open_doc(pipe);

	answ[0] = OLGA_ACK;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = 0;
	answ[4] = 0;
	answ[5] = pipe[5];
	answ[6] = 0;
	answ[7] = OLGA_OPENDOC;

	appl_write(pipe[1],16,answ);
}



void olga_closedoc(int *pipe)
{
	int answ[8];
	
	#ifdef DEBUG
	printf("OLGA: OLGA_CLOSEDOC App %i Group %i\n",pipe[1],pipe[5]);
	#endif

	unLink(FALSE,TRUE,pipe);
	close_doc(TRUE,pipe);

	answ[0] = OLGA_ACK;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = 0;
	answ[4] = 0;
	answ[5] = pipe[5];
	answ[6] = 0;
	answ[7] = OLGA_CLOSEDOC;
	
	appl_write(pipe[1],16,answ);
}
