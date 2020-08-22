/************************************************************************
 *																		*
 * 	Modul CHNGERES.C													*
 *																		*
 *	Copyright 1991: Oliver Spornitz und Detlev Nolte					*
 *																		*
 *	Funktion: Sofern der GEMDOS-Traphandler installiert wurde, wird bei	*
 *	jedem PEXEC-Aufruf in die Funktion _pexec_setres() verzweigt.		*
 *	Analog bei jedem PTERM in die Funktion	_pterm_setres().			*
 *																		*		
 ************************************************************************/

/*
 * Die Åblichen Headerfiles
 */
#include <string.h>
#include <stdio.h>
#include <linea.h>
#include <tos.h>

/*
 * Modulheader
 */
#include "piwobind.h"
#include "global.h"
#include "savescrn.h"
#include "chngeres.h"


/*
 * Externe Globale Definition 
 */
extern char* pexec_name;	/* Wird durch die GEMDOS-Trap-Routine
							   initialisiert (siehe TRAP_1.S) */

/*
 * Globale Definition des Moduls
 */
long SCREENSIZE;	/* Grîûe des Bildschirmspeichers */
void *SCRN_BUF;		/* Buffer zur Restaurierung des Bildschirms */
GPB	RESOLD;			/* Buffer fÅr aktuelle Auflîsung */




/*
 * Function _pexec_setres()
 *	Wurde ein Programm durch die GEMDOS-Funktion PEXEC gestartet, wird
 *	zunÑchst ÅberprÅft ob der Name des Programms in der Datei PWSWITCH.DAT
 *	steht ( programm_in_list() ).
 *	Falls ja, wird die momentan gesetzte Auflîsung ermittelt, und in die
 *	Original Auflîsung umgeschaltet.
 *
 *	Return: 0 = Programm gefunden, Auflîsung wurde umgeschaltet
 *			1 = War nicht das richtige Programm
 */
_pexec_setres()
{

	if(program_in_list()==1)	/* Programm in der Liste suchen */
	{
		if((SCREENSIZE = getres(&RESOLD))>=0)	/* Aktuelle Auflîsung sichern */
		{
			hide_mouse();
			
			/* Bildschirm sichern */
    		if((SCRN_BUF = Malloc(SCREENSIZE))!=NULL)
    		{
				/* Bildschirm restaurieren und in Original Auflîsung schalten */
				save_screen();
				setres(&RESBUF,3);
				copy_screen();
			}
			else
				/* Nicht genÅgend Speicher, dann wird der Bildchirm nicht
				 * restauriert
				 */
				setres(&RESBUF,1);

			show_mouse(1);
			return 0;	/* Hat alles geklappt */
		}
	}
	
	return 1;	/* War nicht das richtige Programm */
}
/* End of Function _pexec_setres() */


/*
 * Function _pterm_setres()
 * 	Analog zu _pexec_setres().
 *	Bei Beendigung des Programms wird in die alte Auflîsung zurÅckgeschaltet.
 */
_pterm_setres()
{
	hide_mouse();
	

	if(SCRN_BUF != NULL)
	{
		/* Bildschirm restaurieren */
		restore_screen();
	    Mfree(SCRN_BUF);
	}
	/* Alte Auflîsung setzen */
	setres(&RESOLD,3);
	show_mouse(1);
	return 0;
}
/* End of Function _pterm_setres() */


/*
 * Function program_in_list()
 *	Der GEMDOS-Traphandler initiallisiert die globale Variable 'pexec_name'
 *	mit dem Programmnamen, das via PEXEC gestartet wurde.
 *	Diese Funktion ÅberprÅft nun ob der Name in der Liste steht.
 */
int program_in_list(void)
{
	char p_name[8+1+3+1];
	char *p;
	int i;
	
	p=strrchr(pexec_name,'\\');
	if(p!=0l) 
		strcpy(p_name,++p);
	else
		strcpy(p_name,pexec_name);
	
	i=0;
	while(*PROGRAMMLISTE[i]!='\0')
	{
		if(strcmp(strupr(PROGRAMMLISTE[i]),strupr(p_name))==0)
			return 1; /* Programmname gefunden */
		i++;
	}
	return 0;	/* Keinen Eintrag gefunden */
}
/* End of Function program_in_list() */


/******************* End of Modul CHNGERES.C ******************/

	
