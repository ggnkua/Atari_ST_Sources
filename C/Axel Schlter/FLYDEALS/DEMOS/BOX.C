/*
	Dieses Testprogramm zeigt die Bearbeitung und Verwaltung
	von Dialogboxen mit Hilfe der FLY-DEALs
	
	written '92 by Axel SchlÅter
*/

#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include <fly_deal.h>
#include "resource.h"

void main();				/* Hauptfunktion */
void Error(char *string);	/* Error-Funktion */

void main()
{
	int erg,			/* Testvariable */
		work_in[11],	/* Die Standard-GEM-Array */
		work_out[57];
	OBJECT *box;		/* Das normale GEM-Object */
	long *mem;			/* Hier liegt der Hintergrundspeicher */
	
	erg=FLY_init(work_in,work_out);		/* GEM-Anmeldung */
		
	if(erg==ERROR)						/* Bei nichtgelingen raus */
		Error("No Workstation avaliable");
	if(!rsrc_load("resource.rsc"))			/* Resource laden */
		Error("No Resourcefile");
		
	rsrc_gaddr(R_TREE,INFOBOX,&box);		/* Adresse bestimmen */
	graf_mouse(ARROW,0L);
	
	mem=FLY_deal_start(box);	  			/* Box vorbereiten und darstellen */
	erg=FLY_deal_do(0,mem,RADIONOEXIT);		/* Box abarbeiten */
		FLY_deal_stop(mem);					/* Box nachbereiten */
		
	fprintf(stdout,"Nummer des Exit-Buttons: %d",erg);
	
	FLY_exit();			/* GEM abmelden */
}

void Error(char *string)
{
	fprintf(stderr,"ERROR: %s\n",string);
	exit(1);
}