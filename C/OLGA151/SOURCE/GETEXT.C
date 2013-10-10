/*****************************
 * getext.c                  *
 *****************************
 *****************************
 * [1998-06-02, tm]          *
 * - first C version         *
 *****************************/

#include "getext.h"
#include "manager.h"


void olga_getextension(int *pipe)
{
	int answ[8];
	char *p1, *p2, *pc = *(char **)&pipe[3];
	
	#ifdef DEBUG
	printf("OLGA: OLGA_GETEXTENSION App %i  %s\n",pipe[1],pc);
	#endif

	answ[0] = OLGA_EXTENSION;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = 0;
	answ[6] = 0;
	answ[7] = 1;
	
	p1 = strrchr(pc,'.');
	p2 = strrchr(pc,'\\');
	
	if (p1 > p2)
	{
		char s[8];
		
		strncpy(s,p1,7);
		s[7] = 0;
		strupr(s);
		
		answ[7] = 0;

		if (strlen(s) > 4)
		{
			if (!stricmp(s,".JPEG")) strcpy(s,".JPG");
			else if (!stricmp(s,".MPEG")) strcpy(s,".MPG");
			else if (!stricmp(s,".AIFF")) strcpy(s,".AIF");
			else if (!stricmp(s,".HTML")) strcpy(s,".HTM");
			else if (!stricmp(s,".CLASS")) strcpy(s,".CLA");
			else if (!stricmp(s,".TIFF")) strcpy(s,".TIF");
			else
			{
				answ[7] = 1;
			}
		}
		
		answ[5] = (s[0] << 8) | s[1];
		answ[6] = (s[2] << 8) | s[3];
	}

	appl_write(pipe[1],16,answ);
}
