/*															 */
/* Just a little program which allows you to listen modules  */
/* just by clicking onto their icons. This way of listening  */
/* modules is only available when player is in memory (like) */
/* desk accessory or with MultiTOS.							 */
/* Declare this program as an application for .MOD files in  */
/* the menu Options of the desktop.							 */
/*															 */
/* Of course, if you use the player as an application, this  */
/* program is useless, just declare the player as an appli-	 */
/* cation for MOD files...									 */

/* --------------------------------------------------------- */
/* declarations												 */
/* --------------------------------------------------------- */

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include "..\u_trax.h"

typedef struct
	{
	long	ident;
	union
		{
		void *pt;
		long l;
		int	 i[2];
		char c[4];
		}v;
	}COOKIE;

#define		FALSE		0
#define		TRUE		1

extern	COOKIE	*get_cookie(long);

/* -------------------------------------------------------- */
/* main program												*/
/* -------------------------------------------------------- */

int main(int argc,char *argv[])
	{
	int		trax_id;
	int 	msg_buf[8];
	int		handle;
	long	adr_file;

	appl_init();
	msg_buf[0]=ID_TRACK;

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* verifie que ultimate tracker est en m‚moire */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

	trax_id=appl_find("U_TRACK ");

	if 	(trax_id<0)
		{
		COOKIE	*cookie;

		cookie=(COOKIE *)malloc(sizeof(cookie));
		if (cookie==NULL) {appl_exit();return -1;}
		cookie=get_cookie('UTRK');
		if	(cookie==NULL) trax_id=-1;
		else trax_id=cookie->v.i[0];
		free(cookie);
		}
	
	if	(trax_id<0)
		{
		printf("Ultimate Tracker isn't in memory.\n");
		Crawcin();
		appl_exit();
		return -1;
		}
		
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* V‚rifie la validit‚ des param‚tres */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	if	(argc==1)
		{
		printf("Missing parameters. You must enter\n");
		printf("the path and the name of the module.\n");
		Crawcin();
		appl_exit();
		return -1;
		}
		
	handle=Fopen(argv[1],FO_READ);
	if	(handle<0)
		{
		printf("Error. The module doesn't exist.\n");
		printf("Check the type of parameters given\n");
		printf("in the 'Option' menu of the desktop\n");
		printf("and try again.\n");
		Crawcin();
		appl_exit();
		return -1;
		}
	Fclose(handle);
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 
	/* Envoie les infos au player */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	/* --- load --- */

	msg_buf[1]=T_LOAD;
	adr_file=(long)argv[1];
	msg_buf[2]=(int)(adr_file>>16);
	msg_buf[3]=(int)(adr_file & 0xFFFF);
	wind_update(BEG_UPDATE);
	appl_write(trax_id,16,msg_buf); 	
	wind_update(END_UPDATE);
	evnt_timer(1000,0);				

	/* --- play --- */
	
	msg_buf[1]=T_PLAY;
	wind_update(BEG_UPDATE);
	appl_write(trax_id,16,msg_buf);
	wind_update(END_UPDATE);
	evnt_timer(1000,0);
	
	/* ~~~~~~~~~ */
	/* Et quitte */
	/* ~~~~~~~~~ */
	
	appl_exit();
	return 0;
	}
	
