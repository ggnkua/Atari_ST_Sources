/*
	Dieses Program demonstriert die Verwendung von Popupboxen
	in eigenen Dialogboxen
	ACHTUNG: Als Demonstration der Exitmîglichkeit in Popups sind
	die EintrÑge "ZYAN" und "HELLZYAN" als Exit-Buttons definiert,
	sodaû bei deren Anwahl die Verarbeitung automatisch beendet wird.
	Weitere Informationen siehe Artikel in TOS 12/92 
	
	written '92 by Axel SchÅter
*/

#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include <fly_deal.h>
#include "resource.h"

void main(void);			/* Das Hauptprogramm */
void Error(char *string);	/* Ein (einfacher) Errorhandler */

void main(void)
{
	int in[11],out[57],back;
	long *mem;
	char string[100];
	OBJECT *popbox,*colors;
	POPUP setPopup[1];
	
	if(FLY_init(in,out)==ERROR)	Error("No Workstation avaliable");
	
	if(!rsrc_load("resource.rsc")) Error("No Resourcefile");
	rsrc_gaddr(R_TREE,POPUPBOX,&popbox);
	rsrc_gaddr(R_TREE,COLOR,&colors);
	
	setPopup[0].tastSel=COLSLECT;
	setPopup[0].tree=colors;
	setPopup[0].object=COLSHOW;
	FLY_radio_set(setPopup,1);

	graf_mouse(ARROW,0L);
		
	mem=FLY_deal_start(popbox);
	FLY_deal_do(0,mem,EXIT);
	FLY_deal_stop(mem);
	
	back=FLY_test_radio_set(setPopup,0);
	
	sprintf(string,"{1}{| Farbe %s gewÑhlt }{ [OK }",colors[back].ob_spec.free_string);
	FLY_alert(0,string);
	
	FLY_exit();
}

void Error(char *string)
{
	fprintf(stderr,"ERROR: %s\n",string);
	exit(1);
}	