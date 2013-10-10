/*****************************
 * getset.c                  *
 *****************************
 *****************************
 * [1998-06-02, tm]          *
 * - first C version         *
 *****************************/

#include "manager.h"
#include "getset.h"


void olga_getsettings(int *pipe)
{
	int answ[8];
	
	#ifdef DEBUG
	printf("OLGA: OLGA_GETSETTINGS App %i: %i\n",pipe[1],pipe[3]);
	#endif

	answ[0] = OLGA_SETTINGS;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = 1;
	answ[5] = 0;
	answ[6] = 0;
	answ[7] = 0;
	
	switch(pipe[3])
	{
	case 0x4711:
		answ[4] = 0x0815;
		break;

	default:
		answ[3] = 0;
		answ[4] = 0;
	}

	appl_write(pipe[1],16,answ);
}
