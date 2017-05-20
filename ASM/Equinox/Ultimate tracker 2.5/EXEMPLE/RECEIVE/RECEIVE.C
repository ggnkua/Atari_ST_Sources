/* ~~~~~~~~~~~~~~~~~~ */
/* Messages reception */
/* ~~~~~~~~~~~~~~~~~~ */

/* -------------------------------------------------------------------- */
/* This source shows how to communicate in two directions with the      */
/* player. These news features were especially added in the player for  */
/* DMViolator :)														*/
/* To exit this program, press the '*' key.								*/
/* The best way to test this program is under Multitos your favorite.   */
/* shell.																*/
/* -------------------------------------------------------------------- */

/* -------------------------------------------------------------------- */
/* Includes & Defines													*/
/* -------------------------------------------------------------------- */

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
	
typedef struct liste_mod
	{
	char				*nom;
	struct liste_mod	*suivant;
	struct liste_mod	*precedent;
	}LISTE_MOD;

#define		FALSE		0
#define		TRUE		1
#define		AP_TERM		50			/* message fin app multitos */
#define		swap(a)		((a & 0xFFFF)<<16)+((a >> 16) & 0xFFFF)

void	fin_prg(int);
void	texte(char *);
extern	COOKIE	*get_cookie(long);

int		event_buffer[20];
int		clavier(int);
int		mesag(void);
int		PLAYER_OUT=FALSE;

/* ---------------------------------------------------------------- */
/* Program															*/
/* ---------------------------------------------------------------- */

int	main(void)
	{
	int 	id_appl,trax_id;
	int		event,key,dummy;
	int		fin=FALSE;
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* Search AES id of the player */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	id_appl=appl_init();
	trax_id=appl_find("U_TRACK ");

	if (trax_id<0)
	   {	
	   COOKIE	*cookie;

	   cookie=(COOKIE *)malloc(sizeof(COOKIE));
	   if (cookie==NULL) fin_prg(-1);
	   cookie=get_cookie('UTRK');
	   if (cookie==NULL) trax_id=-1;
	   else trax_id=cookie->v.i[0];
	   free(cookie);
	   }

	if (trax_id<0)
	   {
	   printf("\nUltimate Tracker isn't in memory.\n");
	   fin_prg(-1);
	   }
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* Send my AES id to the player */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	event_buffer[0]=T_IDENT;
	event_buffer[1]=id_appl;
	event_buffer[2]=0;
	wind_update(BEG_UPDATE);
	appl_write(trax_id,16,event_buffer);
	wind_update(END_UPDATE);
	evnt_timer(1000,0);

	printf("RECEIVE.TOS 1.2\n\n");
	printf("Current AES id = %d - Player AES id = %d\n\n",id_appl,trax_id);
	
	/* ~~~~~~~~~ */
	/* Main loop */
	/* ~~~~~~~~~ */
	
	while(!fin)
		{
		event=evnt_multi(MU_KEYBD|MU_MESAG,0,0,0,0,0,0,0,0,0,0,0,0,0,event_buffer,
						 0,0,&dummy,&dummy,&dummy,&dummy,&key,&dummy);
		if (event & MU_KEYBD) fin=clavier(key);
		if (event & MU_MESAG) fin=mesag();
		}

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* End of program : say to the player i'm gone */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */	
	
	if	(!PLAYER_OUT)
		{
		event_buffer[0]=T_FIDENT;
		event_buffer[1]=id_appl;
		event_buffer[2]=0;
		wind_update(BEG_UPDATE);
		appl_write(trax_id,16,event_buffer);
		wind_update(END_UPDATE);
		evnt_timer(1000,0);
		}
	appl_exit();
	return 0;
	}
	
void fin_prg(int ret)
	{
	appl_exit();
	exit(ret);
	}
	
/* ------------------------------------------------------------------------ */
/* test clavier																*/
/* ------------------------------------------------------------------------ */

int	clavier(int key)
	{
	if ((char)key=='*') return TRUE;
	return FALSE;
	}
	
/* ------------------------------------------------------------------------ */
/* Message																	*/
/* ------------------------------------------------------------------------ */

int mesag(void)
	{
	char	ver,niv;
	
	switch(event_buffer[0])
		{
		case AP_TERM:		return TRUE;

		case R_PLAY: 		printf("Playing module...\n");
					 		break;
		case R_FORWARD:		printf("Forward...\n");
							break;
		case R_REWIND:		printf("Rewind...\n");
							break;
		case R_PAUSE_ON:	printf("Pause ON\n");
							break;
		case R_PAUSE_OFF:	printf("Pause OFF\n");
							break;
		case R_STOP:		printf("Stop & reinitialize module.\n");
							break;
		case R_OPEN:		printf("Opening player window.\n");
							break;
		case R_CLOSE:		printf("Closing player window.\n");
							break;
		case R_FREQ:		printf("Changing Frequency to ");
							switch(event_buffer[3])
								{
								case 0:	printf("6.25 Khz\n");
										break;
								case 1: printf("12.5 Khz\n");
										break;
								case 2: printf("25 Khz\n");
										break;
								case 3: printf("50 Khz\n");
										break;
								}
							break;
		case R_QUIT:		printf("Exiting player. I quit too...\n");
							PLAYER_OUT=TRUE;
							return TRUE;
		case R_LOOP_ON:		printf("Switching loop ON.\n");
							break;
		case R_LOOP_OFF:	printf("Switching loop OFF.\n");
							break;
		case R_ENDMOD:		printf("End of module.\n");
							break;
		case R_BEGLOAD:		{
							char *pm;
							long ad2,stack;
			
							/* as the MiNT flag of the player is Super  */
							/* you have to be in Supervisor mode to get */
							/* the module filename						*/
				
							stack=Super(0L);
							ad2=event_buffer[3];
							ad2=swap(ad2);
							(int)ad2=event_buffer[4];
							pm=(char *)ad2;
							printf("Loading %s\n",pm);
							Super((void *)stack);
							}
							break;
		case R_ENDLOAD:		printf("End of loading module.\n");
							break;
		case R_FAILOAD:		printf("Error during loading module.\n");
							break;
		case R_MOVE:		printf("Tracker Window moved to X=%d, Y=%d\n",event_buffer[3],event_buffer[4]);
							break;
		case R_POSIT:		printf("Position : %d / %d\n",event_buffer[3]+1,event_buffer[4]);
							break;
		case R_INFOS:		ver=*((char *)(event_buffer+5));
							niv=*((char *)(event_buffer+6));
							printf("Informations about the player: \n");
							printf("Tracker Window handle = %d\n",event_buffer[3]);
							printf("VDI Graphic handle = %d\n",event_buffer[4]);
							printf("AES Id = %d\n",event_buffer[1]);
							printf("Version = %c.%c\n",ver+'0',niv+'0');
							printf("Oscilloscope window handle = %d\n",event_buffer[6]);
							printf("Play List window handle = %d\n",event_buffer[7]);
							printf("Vu-meter window handle = %d\n",event_buffer[8]);
							break;
		case R_OPN_OSCILLO:	printf("Opening oscilloscope window.\n");
							break;
		case R_CLS_OSCILLO:	printf("Closing oscilloscope window.\n");
							break;
		case R_MOVE_OSCILLO:printf("Oscillo window moved to X=%d, Y=%d\n",event_buffer[3],event_buffer[4]);
							break;
		case R_PROTECMOD:	printf("Module is protected. No informations about its size.\n");
							break;
		case R_OPN_PLAYLIST:printf("Opening Play List window.\n");
							break;
		case R_CLS_PLAYLIST:printf("Closing Play List window.\n");
							break;
		case R_MOVE_PLAYLIST:
							printf("Play List window moved to X=%d, Y=%d\n",event_buffer[3],event_buffer[4]);
							break;
		case R_NEXT_MOD:	{
							char *pm;
							long ad2,stack;
			
							/* as the MiNT flag of the player is Super  */
							/* you have to be in Supervisor mode to get */
							/* the module filename						*/
				
							stack=Super(0L);
							ad2=event_buffer[3];
							ad2=swap(ad2);
							(int)ad2=event_buffer[4];
							pm=(char *)ad2;
							printf("Loading & initializing next module : %s\n",pm);
							Super((void *)stack);
							}
							break;
		case R_PREV_MOD:	{
							char *pm;
							long ad2,stack;
			
							/* as the MiNT flag of the player is Super  */
							/* you have to be in Supervisor mode to get */
							/* the module filename						*/
				
							stack=Super(0L);
							ad2=event_buffer[3];
							ad2=swap(ad2);
							(int)ad2=event_buffer[4];
							pm=(char *)ad2;
							printf("Loading & initializing previous module : %s\n",pm);
							Super((void *)stack);
							}
							break;
		case R_OPN_VUM:		printf("Opening Vu-Meter window.\n");
							break;
		case R_CLS_VUM:		printf("Closing Vu-Meter window.\n");
							break;
		case R_MOVE_VUM:	printf("Vu-Meter window is moved to X=%d, Y=%d\n",event_buffer[3],event_buffer[4]);							
							break;
		case R_PLAYLIST:	{
							long 		ad2,stack;
							LISTE_MOD	*liste;
			
							printf("Current Play List\n\n");
							printf("Number of modules : %d\n\n",event_buffer[5]);
							printf("Modules names\n\n");

							/* as the MiNT flag of the player is Super  */
							/* you have to be in Supervisor mode to get */
							/* the playlist address						*/
				
							stack=Super(0L);
							ad2=event_buffer[3];
							ad2=swap(ad2);
							(int)ad2=event_buffer[4];
							liste=(LISTE_MOD *)ad2;
							while (liste!=NULL)
								{
								printf("%s\n",liste->nom);
								liste=liste->suivant;
								}	
							Super((void *)stack);
							}
							break;
		case R_SEL_PLST:	printf("Selected module in the Play List = %d\n",event_buffer[3]);
							break;
		case R_REMOVE_PLST:	printf("Selected module is removed from the list.\n");
							break;
		case R_ADD_PLST:	printf("A new module has been added to the list.\n");
							break;
		case R_NEW_PLST:	printf("The current list has been erased to create a new one.\n");
							break;
		case R_BEG_LOAD_PLST:
							{
							char *pm;
							long ad2,stack;
			
							/* as the MiNT flag of the player is Super  */
							/* you have to be in Supervisor mode to get */
							/* the playlist filename					*/
				
							stack=Super(0L);
							ad2=event_buffer[3];
							ad2=swap(ad2);
							(int)ad2=event_buffer[4];
							pm=(char *)ad2;
							printf("Loading Play List : %s\n",pm);
							Super((void *)stack);
							}
							break;
		case R_END_LOAD_PLST:
							printf("End of loading Play List.\n");
							break;
		case R_FAIL_LOAD_PLST:
							printf("Error during loading Play List.\n");
							break;
		case R_BEG_SAVE_PLST:
							{
							char *pm;
							long ad2,stack;
			
							/* as the MiNT flag of the player is Super  */
							/* you have to be in Supervisor mode to get */
							/* the playlist filename					*/
				
							stack=Super(0L);
							ad2=event_buffer[3];
							ad2=swap(ad2);
							(int)ad2=event_buffer[4];
							pm=(char *)ad2;
							printf("Saving Play List : %s\n",pm);
							Super((void *)stack);
							}
							break;
		case R_END_SAVE_PLST:
							printf("End of saving Play List.\n");
							break;
		case R_FAIL_SAVE_PLST:
							printf("Error during saving Play List.\n");
							break;
		case R_LOOP_PLST_ON:printf("Switching Play List loop ON.\n");
							break;
		case R_LOOP_PLST_OFF:
							printf("Switching Play List loop OFF.\n");
							break;
		case R_TIME_PLST:	printf("Current Play Time = %d:%d:%d\n",event_buffer[3],event_buffer[4],event_buffer[5]);
							break;
		case R_CUR_TIME:	printf("Module time : %d:%d:%d\n",event_buffer[3],event_buffer[4],event_buffer[5]);
							break;
		case R_CYCLE_WIN:	printf("Current topped window handle = %d\n",event_buffer[3]);
							break;
		case R_DEL_PLST:	printf("The current play list is deleted.\n");
							break;
		}
	return FALSE;
	}