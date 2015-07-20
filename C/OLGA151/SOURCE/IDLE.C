/***************************
 * idle.c                  *
 ***************************
 ***************************
 * [1998-06-02, tm]        *
 * - first C version       *
 ***************************/

#include "manager.h"
#include "idle.h"


void olga_idle(int *pipe)
{
	#ifdef DEBUG
	printf("OLGA: OLGA_IDLE App %i (",pipe[1]);
	if (!pipe[3]) printf("reply)\n");
	else
		printf("request) -> reply\n");
	#endif
	
	if (pipe[3])
	{
		int answ[8];
		
		answ[0] = OLGA_IDLE;
		answ[1] = ap_id;
		answ[2] = 0;
		answ[3] = 0;
		answ[4] = pipe[4];
		answ[5] = pipe[5];
		answ[6] = pipe[6];
		answ[7] = pipe[7];

		appl_write(pipe[1],16,answ);
	}
}
