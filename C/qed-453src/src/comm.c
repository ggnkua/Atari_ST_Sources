#include "global.h"
#include "av.h"
#include "clipbrd.h"
#include "dd.h"
#include "olga.h"
#include "se.h"
#include "comm.h"

/* Document-History fr StartMeUp ********************************************/
#define DHST_ADD 0xDADD

typedef struct
{
	char	*appname,
       	*apppath,
       	*docname,
       	*docpath;
} DHSTINFO;

/* exportierte Variablen *****************************************************/
char	*global_str1,
		*global_str2;
int	msgbuff[8]; 			/* Buffer, den send_msg verschickt */


/* lokale Variablen **********************************************************/
static DHSTINFO	*dhst = NULL;
static int			dhst_id = -1;

/*****************************************************************************/

bool send_msg(int id)
{
	int	ret;
	
	msgbuff[1] = gl_apid;
	msgbuff[2] = 0;
	ret = appl_write(id, (int) sizeof(msgbuff), msgbuff);
	return (ret > 0);
}


void send_clip_change(void)
{
	if ((av_shell_id >= 0) && (av_shell_status & 512))	/* Desktop informieren */
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_PATH_UPDATE;
		strcpy(global_str1, clip_dir);
		*(char **) (msgbuff + 3) = global_str1;
		send_msg(av_shell_id);
	}
	send_scchanged();
}

void send_dhst(char *filename)
{
	if (dhst_id == -1)
	{
		long	l;

		if (getcookie("DHST", &l))
			dhst_id = (int)l;
		else
			dhst_id = 0;
	}
	if (dhst_id > 0)
	{
		if (dhst == NULL)
		{
			dhst = malloc_global(sizeof(DHSTINFO));
			dhst->appname = malloc_global(4);
			strcpy(dhst->appname, "qed");
			dhst->apppath = malloc_global(strlen(gl_appdir) + strlen("qed.app") + 1);
			strcpy(dhst->apppath, gl_appdir);
			strcat(dhst->apppath, "qed.app");
			dhst->docname = malloc_global(sizeof(FILENAME));
			dhst->docpath = malloc_global(sizeof(PATH));
		}
		split_filename(filename, NULL, dhst->docname);
		strcpy(dhst->docpath, filename);
		
		msgbuff[0] = DHST_ADD;
		*(DHSTINFO **)(msgbuff + 3) = dhst;
		msgbuff[5] = 0;
		msgbuff[6] = 0;
		msgbuff[7] = 0;
		send_msg(dhst_id);
	}
}

void init_comm(void)
{
	global_str1 = malloc_global(256);
	global_str2 = malloc_global(256);
	init_av();
	init_se();
	init_olga();
}

void term_comm(void)
{
	term_olga();
	term_se();
	term_av();
	if (global_str1 != NULL)
		Mfree(global_str1);
	if (global_str2 != NULL)
		Mfree(global_str2);
	if (dhst != NULL)
	{
		Mfree(dhst->appname);
		Mfree(dhst->apppath);
		Mfree(dhst->docname);
		Mfree(dhst->docpath);
		Mfree(dhst);
	}
}
