/******************************
 * exitman.c                  *
 ******************************
 ******************************
 * [1998-06-02, tm]           *
 * - first C version          *
 ******************************/

#include "exitman.h"
#include "manager.h"
#include "language.h"


void exit_manager(void)
{
	int  answ[8];
	App *pad = apps;
	
	#ifdef DEBUG
	printf(DEBUG_DEACTIVATED);
	#endif
	
	answ[0] = OLE_EXIT;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = 0;
	answ[4] = 0;
	answ[5] = 0;
	answ[6] = 0;
	answ[7] = 0;
	
	while (pad)
	{
		appl_write(pad->apID,16,answ);
		pad = pad->Next;
	}
	
	appl_exit();
}
