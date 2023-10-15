/*
	Testprogramm als Beispiel fÅr die VerÑnderung, die die
	Library an den Menuzeilen vornimmt (Sie verÑndert die Trenn-
	striche)
	
	written '92 by Axel SchlÅter
*/

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <fly_deal.h>
#include "resource.h"

void main();					/* Die Hauptfunktion */
void ShowInfoBox(OBJECT *box);	/* Zeigt eine kleine Infobox */
void Error(char *string);		/* Eine Errorfunktion, UNIX(TM) gemÑûe Fehler-
							   	   meldungen */

void main()
{
	OBJECT *menu,*info;
	int msg[8],work_in[11],work_out[57];
	
	if(FLY_init(work_in,work_out)==ERROR) 	/* Initialisierung */
		Error("No Workstation avaliable");	
	if(!rsrc_load("resource.rsc")) 			/* Resource laden */
		Error("It's not possible to load resource file");
	
	rsrc_gaddr(R_TREE,MENU,&menu);	/* Adressenbestimmung */
	rsrc_gaddr(R_TREE,INFOBOX,&info);
	
	FLY_menu_make(menu);			/* Hier werden die VerÑnderungen durchgefÅhrt */	
	
	graf_mouse(ARROW,0L); 			/* Laut GEM-Konvention */
	menu_bar(menu,1);				/* Und das MenÅ darstellen */
	
	for(;;)							/* Endlosschleife */
	{
		evnt_mesag(msg);					/* Ereignis abwarten */
		
		if(msg[0]==MN_SELECTED)
		{
			switch(msg[4])
			{
				case QUIT:					/* Verlassen des Programs */
					menu_bar(menu,0);		/* MenÅleiste weg */
					FLY_exit();				/* GEM abmelden */
					exit(0);	
				case INFOBUTT:				/* Info im Desk-MenÅ */
					ShowInfoBox(info);		/* Infobox zeigen */
					break;
				default:
					FLY_alert(0,"{1}{|MenÅtitel angeklickt !!!}{[OK}");
			}
			menu_tnormal(menu,msg[3],1);	/* MenÅtitel normal */
		}
	}
}

void ShowInfoBox(OBJECT *box)
{
	long *mem;
	
	mem=FLY_deal_start(box);
	box[FLY_deal_do(0,mem,RADIONOEXIT)].ob_state&=~SELECTED;
	FLY_deal_stop(mem);
}		
	
void Error(char *string)
{
	fprintf(stderr,"MENU: %s\n",string);
	exit(1);
}	