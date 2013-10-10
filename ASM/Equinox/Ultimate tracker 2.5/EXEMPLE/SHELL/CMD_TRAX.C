/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* Mini Shell 2.2 for Ultimate Tracker  */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/* -------------------------------------------------------------------- */
/* Includes & defines												    */
/* -------------------------------------------------------------------- */

#include <string.h>
#include <stdlib.h>
#include <aes.h>
#include <tos.h>
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

#define		FALSE	0
#define		TRUE	1
#define		NULL	((void*)0L)

void	fin(int);
void	texte(char *);
extern	COOKIE	*get_cookie(long);

/* -------------------------------------------------------------------- */
/* programme															*/
/* -------------------------------------------------------------------- */

int main(int argc,char *argv[])
	{
	int		ok_send=FALSE;
	int		trax_id;
	int 	msg_buf[12];
	int		id_appl;

	id_appl=appl_init();
	msg_buf[2]=0;
	msg_buf[1]=id_appl;

	trax_id=appl_find("U_TRACK ");

	if (trax_id<0)
	   {	
	   COOKIE	*cookie;

	   cookie=(COOKIE *)malloc(sizeof(COOKIE));
       if	(cookie==NULL) fin(-1);
 	   cookie=get_cookie('UTRK');
	   if	(cookie==NULL) trax_id=-1;
	   else trax_id=cookie->v.i[0];
	   free(cookie);
	   }	

	if	(trax_id<0)
		{
		texte("Ultimate Tracker isn't in memory.");
		fin(-1);
		}
		
	if  (argc==1)
		{
		texte("Missing parameters. Type CMD_TRAX HE for help.");
		fin(-1);
		}
		
	strupr(argv[1]);

	/* ~~~ Load a module ~~~ */

	if	(!strcmp(argv[1],"LOAD"))
		{
		long adr_file;
		int	 h;

		if 	(argc==2)
			{
			texte("Missing filename.");
			fin(-1);
			}
		if	((h=(int)Fopen(argv[2],FO_READ))<0)
			{
			texte("Filename error. Check path and name.");
			fin(-1);
			}
		Fclose(h);
		msg_buf[0]=T_LOAD;
		adr_file=(long)argv[2];
		msg_buf[4]=(int)(adr_file>>16);
		msg_buf[3]=(int)(adr_file & 0xFFFF);
		Cconws("Loading module ");
		Cconws(argv[2]);
		texte(" ");
		ok_send=TRUE;
		}
		
	/* ~~~ Play music  ~~~ */
		
	if	(!strcmp(argv[1],"PLAY"))
		{
		texte("Playing module...");
		msg_buf[0]=T_PLAY;
		ok_send=TRUE;
		}

	/* ~~~ Forward ~~~ */

	if	(!strcmp(argv[1],"FORWARD"))
		{
		texte("Forward module...");
		msg_buf[0]=T_FORWARD;
		ok_send=TRUE;
		}

	/* ~~~ Rewind ~~~ */

	if	(!strcmp(argv[1],"REWIND"))
		{
		texte("Rewind module...");
		msg_buf[0]=T_REWIND;
		ok_send=TRUE;
		}
		
	/* ~~~ Pause ~~~ */
		
	if	(!strcmp(argv[1],"PAUSE"))
		{
		texte("Switch Pause ON/OFF");
		msg_buf[0]=T_PAUSE;
		ok_send=TRUE;
		}
		
	/* ~~~ STOP ~~~ */
		
	if	(!strcmp(argv[1],"STOP"))
		{
		texte("Stop and clear module.");
		msg_buf[0]=T_STOP;
		ok_send=TRUE;
		}
		
	/* ~~~ About box... ~~~ */
		
	if	(!strcmp(argv[1],"ABOUT"))
		{
		texte("About Ultimate Tracker...");
		msg_buf[0]=T_ABOUT;
		ok_send=TRUE;
		}
		
	/* ~~~ Open window ~~~ */
		
	if	(!strcmp(argv[1],"OPEN"))
		{
		texte("Opening Ultimate Tracker window...");
		msg_buf[0]=T_OPEN;
		ok_send=TRUE;
		}
		
	/* ~~~ Close window ~~~ */
		
	if	(!strcmp(argv[1],"CLOSE"))
		{
		texte("Closing Ultimate Tracker window...");
		msg_buf[0]=T_CLOSE;
		ok_send=TRUE;
		}
		
	/* ~~~ Choose frequency ~~~ */
		
	if	(!strcmp(argv[1],"FREQ"))
		{
		if 	(argc==2)
			{
			texte("Missing frequency (0/1/2/3)");
			fin(-1);
			}
		texte("Changing frequency...");
		msg_buf[0]=T_FREQ;
		msg_buf[3]=atoi(argv[2]);
		ok_send=TRUE;
		}

	/* ~~~ Loop ~~~ */
	
	if 	(!strcmp(argv[1],"LOOP"))
		{
		texte("Switch loop ON/OFF");
		msg_buf[0]=T_LOOP;
		ok_send=TRUE;
		}

	/* ~~~ Informations ~~~ */

	if 	(!strcmp(argv[1],"INFOS"))
		{
		texte("Ask informations...");
		msg_buf[0]=T_INFOS;
		ok_send=TRUE;
		}

	/* ~~~ Ouvre la fenˆtre oscillo ~~~ */
	
	if	(!strcmp(argv[1],"OPEN_OSCILLO"))
		{
		texte("Opening oscilloscope window...");
		msg_buf[0]=T_OPN_OSCILLO;
		ok_send=TRUE;
		}
		
	/* ~~~ Ferme la fenˆtre oscillo ~~~ */
	
	if	(!strcmp(argv[1],"CLOSE_OSCILLO"))
		{
		texte("Closing oscilloscope window...");
		msg_buf[0]=T_CLS_OSCILLO;
		ok_send=TRUE;
		}

	/* ~~~ Ouvre fenˆtre play list ~~~~ */
	
	if	(!strcmp(argv[1],"OPEN_PLAYLIST"))
		{
		texte("Opening Play List window...");
		msg_buf[0]=T_OPN_PLAYLIST;
		ok_send=TRUE;
		}

	/* ~~~ Ferme fenˆtre play list ~~~~ */
	
	if	(!strcmp(argv[1],"CLOSE_PLAYLIST"))
		{
		texte("Closing Play List window...");
		msg_buf[0]=T_CLS_PLAYLIST;
		ok_send=TRUE;
		}

	/* ~~~ Module suivant ~~~~ */
	
	if	(!strcmp(argv[1],"NEXT_MOD"))
		{
		texte("Initializing next module...");
		msg_buf[0]=T_NEXT_MOD;
		ok_send=TRUE;
		}

	/* ~~~ Module pr‚c‚dent ~~~~ */
	
	if	(!strcmp(argv[1],"PREVIOUS_MOD"))
		{
		texte("Initializing previous module...");
		msg_buf[0]=T_PREV_MOD;
		ok_send=TRUE;
		}
	
	/* ~~~ Ouvre fenˆtre vu metre ~~~~ */
	
	if	(!strcmp(argv[1],"OPEN_VU_METER"))
		{
		texte("Opening Vu-meter window...");
		msg_buf[0]=T_OPN_VUM;
		ok_send=TRUE;
		}

	/* ~~~ Ferme fenˆtre vu metre ~~~~ */
	
	if	(!strcmp(argv[1],"CLOSE_VU_METER"))
		{
		texte("Closing Vu-meter window...");
		msg_buf[0]=T_CLS_VUM;
		ok_send=TRUE;
		}
	
	/* ~~~ Selectionne un module ~~~~ */
	
	if	(!strcmp(argv[1],"SELECT_MOD"))
		{
		texte("Selecting module...");
		msg_buf[0]=T_SEL_PLST;
		msg_buf[3]=atoi(argv[2]);
		ok_send=TRUE;
		}

	/* ~~~ Efface un mod de la liste ~~~~ */
	
	if	(!strcmp(argv[1],"REMOVE_MOD"))
		{
		texte("Deleting module from play list...");
		msg_buf[0]=T_REMOVE_PLST;
		ok_send=TRUE;
		}

	/* ~~~ Ajoute un module … la liste ~~~~ */
	
	if	(!strcmp(argv[1],"ADD_MOD"))
		{
		long adr_file;
		int	 h;

		if 	(argc==2)
			{
			texte("Missing filename.");
			fin(-1);
			}
		if	((h=(int)Fopen(argv[2],FO_READ))<0)
			{
			texte("Filename error. Check path and name.");
			fin(-1);
			}
		Fclose(h);
		msg_buf[0]=T_ADD_PLST;
		adr_file=(long)argv[2];
		msg_buf[4]=(int)(adr_file>>16);
		msg_buf[3]=(int)(adr_file & 0xFFFF);
		ok_send=TRUE;
		texte("Adding module to play list...");
		ok_send=TRUE;
		}

	/* ~~~ Efface la liste ~~~~ */
	
	if	(!strcmp(argv[1],"NEW_PLAYLIST"))
		{
		texte("Deleting the playlist...");
		msg_buf[0]=T_NEW_PLST;
		ok_send=TRUE;
		}

	/* ~~~ Load une playlist ~~~~ */
	
	if	(!strcmp(argv[1],"LOAD_PLAYLIST"))
		{
		long adr_file;
		int	 h;
		
		if 	(argc==2)
			{
			texte("Missing filename.");
			fin(-1);
			}
		if	((h=(int)Fopen(argv[2],FO_READ))<0)
			{
			texte("Filename error. Check path and name.");
			fin(-1);
			}
		Fclose(h);
		msg_buf[0]=T_LOAD_PLST;
		adr_file=(long)argv[2];
		msg_buf[4]=(int)(adr_file>>16);
		msg_buf[3]=(int)(adr_file & 0xFFFF);
		ok_send=TRUE;
		texte("Loading play list...");
		ok_send=TRUE;
		}

	/* ~~~ Save une playlist ~~~~ */
	
	if	(!strcmp(argv[1],"SAVE_PLAYLIST"))
		{
		long adr_file;

		if 	(argc==2)
			{
			texte("Missing filename.");
			fin(-1);
			}
		msg_buf[0]=T_SAVE_PLST;
		adr_file=(long)argv[2];
		msg_buf[4]=(int)(adr_file>>16);
		msg_buf[3]=(int)(adr_file & 0xFFFF);
		ok_send=TRUE;
		texte("Saving play list...");
		ok_send=TRUE;
		}

	/* ~~~ Loop liste ~~~~ */
	
	if	(!strcmp(argv[1],"LOOP_PLAYLIST"))
		{
		texte("Switch ON/OFF playlist repeat flag...");
		msg_buf[0]=T_LOOP_PLST;
		ok_send=TRUE;
		}

	/* ~~~ Cycle fenetres ~~~~ */
	
	if	(!strcmp(argv[1],"CYCLE_WINDOWS"))
		{
		texte("Cycling windows...");
		msg_buf[0]=T_CYCLE_WIN;
		ok_send=TRUE;
		}

	/* ~~~ Ask playlist ~~~~ */
	
	if	(!strcmp(argv[1],"PLAYLIST_ADR"))
		{
		texte("Asks for the playlist address...");
		msg_buf[0]=T_PLAYLIST;
		ok_send=TRUE;
		}
			
	/* ~~~ play time ~~~~ */
	
	if	(!strcmp(argv[1],"PLAY_TIME"))
		{
		char *c=argv[2];
		int  h,m,s;
		
		if 	(argc==2)
			{
			texte("Missing parameter.");
			texte("Syntax : PLAY_TIME HH:MM:SS");
			fin(-1);
			}
		s=atoi((strrchr(c,':')+1));
		*strrchr(c,':')=0;
		m=atoi((strrchr(c,':')+1));
		*strrchr(c,':')=0;
		h=atoi(c);
		if	((h>23)||(m>59)||(s>59))
			{
			texte("Invalid time.");
			texte("Syntax : PLAY_TIME HH:MM:SS");
			texte("0<HH<23 - 0<MM<59 - 0<SS<59");
			fin(-1);
			}
		texte("Initializing new play time...");
		msg_buf[0]=T_TIME_PLST;
		msg_buf[3]=h;
		msg_buf[4]=m;
		msg_buf[5]=s;
		ok_send=TRUE;
		}
						
			
	/* ~~~ Help ~~~ */
	
	if	(!strcmp(argv[1],"HF"))
		{
		texte("* T‚l‚commande de Ultimate Tracker *");
		texte(" ");
		texte("LOAD nom_de_fichier: Chargement d'un module");
		texte("PLAY: Joue le module");
		texte("FORWARD: Avance rapide de la musique");
		texte("REWIND: Retour rapide de la musique");
		texte("PAUSE: Pause de la musique");
		texte("STOP: Stoppe la musique et efface le module");
		texte("FREQ frequence: Change la fr‚quence");
		texte("0 -> 6.25 KHz / 1 -> 12.5 KHz / 2 -> 25   KHz / 3 -> 50KHz");
		texte("ABOUT: Message d'informations");
		texte("OPEN: Ouvre la fenˆtre du player");
		texte("CLOSE: Ferme la fenˆtre du player");
	    texte("LOOP: Fait boucler ou non le module");
		texte("INFOS: Demande des informations sur le player");
		texte("OPEN_OSCILLO: Ouvre la fenˆtre de l'oscilloscope");
		texte("CLOSE_OSCILLO: Ferme la fenˆtre de l'oscilloscope");
		texte("OPEN_PLAYLIST: Ouvre la fenˆtre Play List");
		texte("CLOSE_PLAYLIST : Ferme la fenˆtre Play List");
		texte("NEXT_MOD : Passe au module suivant");
		texte("PREVIOUS_MOD : Passe au module pr‚c‚dent");
		texte("OPEN_VU_METER : Ouvre la fenˆtre vu-mˆtre");
		texte("CLOSE_VU_METER : Ferme la fenˆtre vu-mˆtre");
		texte("SELECT_MOD : S‚lectionne le module pass‚ en paramŠtre");
		texte("REMOVE_MOD : Supprime le module s‚lectionn‚ de la liste");
		texte("ADD_MOD : Ajoute un module … la liste");
		texte("NEW_PLAYLIST : Efface la Play List courante");
		texte("LOAD_PLAYLIST : Charge une nouvelle Play List");
		texte("SAVE_PLAYLIST : Sauve la Play List courante");
		texte("LOOP_PLAYLIST : Switch ON/OFF la r‚p‚tition de liste");
		texte("PLAY_TIME : Initialise la dur‚e du module (HH:MM:SS)");
		texte("CYCLE_WINDOWS : Passe … la fenˆtre suivante");
		texte("PLAYLIST_ADR : Demande l'adresse de la Play List");
		texte("HF: Cette aide en Fran‡ais");
		texte("HE: Cette aide en Anglais");
		texte(" ");
		fin(0);
		}
		
	if	(!strcmp(argv[1],"HE"))
		{
		texte("* Telecommand of Ultimate Tracker *");
		texte(" ");
		texte("LOAD Filename: Load a module");
		texte("PLAY: Play a module");
		texte("FORWARD: Forward the music");
		texte("REWIND: Rewind the music");
		texte("PAUSE: Pause the music");
		texte("STOP: Stop the music and clear the module");
		texte("FREQ Frequency: Changes frequency");
		texte("(0 -> 6.25 KHz / 1 -> 12.5 KHz / 2 -> 25 KHz	/ 3 -> 50 KHz");
		texte("ABOUT: Display informations message");
		texte("OPEN: Open the player window");
		texte("CLOSE: Close the player window");
		texte("LOOP: Switche loop mode on/off");
		texte("INFOS: Ask infos about the player");
		texte("OPEN_OSCILLO: Open the oscilloscope window");
		texte("CLOSE_OSCILLO: Close the oscilloscope window");
		texte("OPEN_PLAYLIST: Open the Play List window");
		texte("CLOSE_PLAYLIST : Close the Play List window");
		texte("NEXT_MOD : Load & Initialize next module");
		texte("PREVIOUS_MOS : Load & Initialize previous module");
		texte("OPEN_VU_METER : Open vu-meter window");
		texte("CLOSE_VU_METER : Close vu-meter window");
		texte("SELECT_MOD : Select a module in the list");
		texte("REMOVE_MOD : Delete the selected module from the list");
		texte("ADD_MOD : Add a module to the list");
		texte("NEW_PLAYLIST : Erase the current play list");
		texte("LOAD_PLAYLIST : Load a new play list");
		texte("SAVE_PLAYLIST : Save the current play list");
		texte("LOOP_PLAYLIST : Switch ON/OFF the list repeat flag");
		texte("PLAY_TIME : Initialize the play time (HH:MM:SS)");
		texte("CYCLE_WINDOWS : Set the next window topped");
		texte("PLAYLIST_ADR : Ask the play list address");
		texte("HF: This help screen in French");
		texte("HE: This help screen in English");
		texte(" ");
		fin(0);
		}
		
	if	(!ok_send)
		{
		texte("Invalid parameters. Type CMD_TRAX HE for more informations.");
		texte(" ");
		fin(0);
		}
		
	/* Envoi la commande */	
	
	wind_update(BEG_UPDATE);
	appl_write(trax_id,16,msg_buf); 	
	wind_update(END_UPDATE);
	evnt_timer(1000,0);				
	appl_exit();
	return 0;
	}

/* ~~~~~~~~~~~~~~ */
/* end of program */
/* ~~~~~~~~~~~~~~ */

void fin(int v)
	{
	appl_exit();
	exit (v);
	}
	
/* ~~~~~~~~~~~~~~~ */
/* Displays a text */	
/* ~~~~~~~~~~~~~~~ */

void texte(char *t)
	{
	Cconws(t);
	Cconws("\n\r");
	}
	
	