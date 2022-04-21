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
	int 	msg_buf[8];

	appl_init();
	msg_buf[0]=ID_TRACK;

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
		msg_buf[1]=T_LOAD;
		adr_file=(long)argv[2];
		msg_buf[2]=(int)(adr_file>>16);
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
		msg_buf[1]=T_PLAY;
		ok_send=TRUE;
		}

	/* ~~~ Forward ~~~ */

	if	(!strcmp(argv[1],"FORWARD"))
		{
		texte("Forward module...");
		msg_buf[1]=T_FORWARD;
		ok_send=TRUE;
		}

	/* ~~~ Rewind ~~~ */

	if	(!strcmp(argv[1],"REWIND"))
		{
		texte("Rewind module...");
		msg_buf[1]=T_REWIND;
		ok_send=TRUE;
		}
		
	/* ~~~ Pause ~~~ */
		
	if	(!strcmp(argv[1],"PAUSE"))
		{
		texte("Switch Pause ON/OFF");
		msg_buf[1]=T_PAUSE;
		ok_send=TRUE;
		}
		
	/* ~~~ STOP ~~~ */
		
	if	(!strcmp(argv[1],"STOP"))
		{
		texte("Stop and clear module.");
		msg_buf[1]=T_STOP;
		ok_send=TRUE;
		}
		
	/* ~~~ About box... ~~~ */
		
	if	(!strcmp(argv[1],"ABOUT"))
		{
		texte("About Ultimate Tracker...");
		msg_buf[1]=T_ABOUT;
		ok_send=TRUE;
		}
		
	/* ~~~ Open window ~~~ */
		
	if	(!strcmp(argv[1],"OPEN"))
		{
		texte("Opening Ultimate Tracker window...");
		msg_buf[1]=T_OPEN;
		ok_send=TRUE;
		}
		
	/* ~~~ Close window ~~~ */
		
	if	(!strcmp(argv[1],"CLOSE"))
		{
		texte("Closing Ultimate Tracker window...");
		msg_buf[1]=T_CLOSE;
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
		msg_buf[1]=T_FREQ;
		msg_buf[2]=atoi(argv[2]);
		ok_send=TRUE;
		}

	/* ~~~ Loop ~~~ */
	
	if 	(!strcmp(argv[1],"LOOP"))
		{
		texte("Switch loop ON/OFF");
		msg_buf[1]=T_LOOP;
		ok_send=TRUE;
		}

	/* ~~~ Informations ~~~ */

	if 	(!strcmp(argv[1],"INFOS"))
		{
		texte("Ask informations...");
		msg_buf[1]=T_INFOS;
		ok_send=TRUE;
		}

	/* ~~~ Ouvre la fenˆtre oscillo ~~~ */
	
	if	(!strcmp(argv[1],"OPEN_OSCILLO"))
		{
		texte("Opening oscilloscope window...");
		msg_buf[1]=T_OPN_OSCILLO;
		ok_send=TRUE;
		}
		
	/* ~~~ Ferme la fenˆtre oscillo ~~~ */
	
	if	(!strcmp(argv[1],"CLOSE_OSCILLO"))
		{
		texte("Closing oscilloscope window...");
		msg_buf[1]=T_CLS_OSCILLO;
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
		texte("HF: Cette aide en Fran‡ais");
		texte("HE: Cette aide en Anglais");
		texte(" ");
		fin(0);
		}
		
	if	(!strcmp(argv[1],"HE"))
		{
		texte("* Telecommand of Ultimate Tracker *");
		texte(" ");
		texte("LOAD Filename: Loads a module");
		texte("PLAY: Plays a module");
		texte("FORWARD: Forwards the music");
		texte("REWIND: Rewinds the music");
		texte("PAUSE: Pauses the music");
		texte("STOP: Stops the music and clear the module");
		texte("FREQ Frequency: Changes frequency");
		texte("(0 -> 6.25 KHz / 1 -> 12.5 KHz / 2 -> 25 KHz	/ 3 -> 50 KHz");
		texte("ABOUT: Displays informations message");
		texte("OPEN: Opens the player window");
		texte("CLOSE: Closes the player window");
		texte("LOOP: Switches loop mode on/off");
		texte("INFOS: Asks infos about the player");
		texte("OPEN_OSCILLO: Opens the oscilloscope window");
		texte("CLOSE_OSCILLO: Closes the oscilloscope window");
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
	
	