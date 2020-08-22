/****************************************************************************
 *																			*
 * 	PWSWITCH.C																*
 *																			*
 *	Copyright 1991: Oliver Spornitz und Detlev Nolte						*
 *																			*
 *	Funktion: Automatische Umschaltung in die Originalauflîsung unter		*
 *			  Pixel Wonder.													*
 *			  Das Programm wird resident im Speicher gehalten und hÑngt 	*
 *			  sich in den GEMDOS-Trap ein. Bei jedem Programmstart			*
 *			  (PEXEC), wird der Name des zustartenden Progamms mit denen	*
 *			  in der Datei PWSWITCH.DAT verglichen. Befindet sich der		*
 *			  entsprechende Name in der Datei, wird in die Original			*
 *			  Auflîsung umgeschaltet, das Programm ausgefÅhrt und nach		*
 *			  Beendigung des Programms wird in die alte Auflîsung zurÅck-	*
 *			  geschaltet.													*
 *	Achtung:  Das Programm funktioniert nur im Monochrom-Modus des			*
 *			  ATARI ST.														*
 *																			*
 ****************************************************************************/


/*
 * Die Åblichen Headerfiles
 */
#include <tos.h>
#include <stdio.h>
#include <linea.h>

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
extern long install();	/* Installations-Routine fÅr GEMDOS-Trap;
						   siehe in TRAP_1.S */


/*
 * Globale Definition des Moduls
 */
ENTRY PROGRAMMLISTE[100];	/* Nimmt die Programm EintrÑge aus der Datei
							 * PWSWITCH.DAT auf
							 */
GPB	RESBUF;					/* FÅr die Auflîsungsparameter der Datei */


/*
 * Prototypen
 */
int read_table(void);
void err_mess(void);
void install_mess(void);


/*
 * Function main()
 *	Installation von PWSWITCH:
 *	Falls in dem aktuellen Verzeichniss (da wo PWSWITCH.PRG steht) die
 *	Datei PWSWITCH.DAT gefunden wurde, wird  via Supexec der GEMDOS-Traphandler
 *	installiert, und das Programm resident im Speicher gehalten.
 */
void main(void)
{

	if(read_table()==0)
	{
		Supexec(install);
		linea_init();
		install_mess();
		Ptermres(_PgmSize,0);
	}
	else
	{
		err_mess();
		Pterm(1);
	}
	
}
/* End of Function main() */


/*
 * Function read_table()
 *	Lieût aus der Datei PWSWITCH.DAT die Parameter fÅr die zusetzende Auflîsung,
 *	sowie die Namen der Programme, bei deren Start der Switcher aktiv werden soll.
 *	Die Parameter der Auflîsung werden in die globale GPB-Struktur RESBUF eingetragen
 *	und die Namen der Programme in das globale Array PROGRAMMLISTE.
 *	
 *	Return:
 *		1 = Datei PWSWITCH.DAT konnte nicht gefunden werden,
 *		0 = Doch gefunden
 */
int read_table(void)
{
	FILE *programlist;
	int i=0;
	int imax = 100;
	int status;
	
	programlist = fopen(SWITCHDATA,"r");
	if (programlist == 0) 
		return 1;		/* Nichts gefunden, dann raus */
	
	/* Die Auflîsungsparameter in die GPB-Struktur einlesen */
	
	fscanf(programlist,"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%[^\n],\n",
			&RESBUF.xtotal,&RESBUF.ytotal,&RESBUF.xdisplayed,
			&RESBUF.ydisplayed,&RESBUF.HSpos,&RESBUF.VSpos,
			&RESBUF.HSwidth,&RESBUF.ausgleich,&RESBUF.planes,
			&RESBUF.interlace,RESBUF.Gname);

	/* In das globale Array 'PROGRAMMLISTE' werden die Namen der Programme
	 * eingetragen
	 */
	do
	{
		status=fscanf(programlist,"%s\n",PROGRAMMLISTE[i]);
		i++;
	}
	while(i<imax && status ==1);
	
	return 0;	/* Alles klar! */
}
/* End of Function read_table() */


/*
 * Function err_mess()
 */
void err_mess(void)
{
	Cconws("\r\nFehler beim Lesen der Datei ");
	Cconws(SWITCHDATA);
	Cconws("\r\nAutoswitch Version ");
	Cconws(VERSION);
	Cconws(" fÅr PixelWonder nicht installiert\r\n");
}
/* End of Function err_mess() */


/*
 * Function install_mess()
 */
void install_mess(void)
{
	Cconws("\r\nAutoswitch Version ");
	Cconws(VERSION);
	Cconws(" fÅr PixelWonder installiert\r\n");
}
/* End of Function install_mess() */


/************************* End of Modul ****************************/

