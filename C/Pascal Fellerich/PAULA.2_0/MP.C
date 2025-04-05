/*
 * Mini-Interface: MP.TTP
 * ----------------------
 * -> Paula Access from command shells:
 * Gemini - MUPFEL
 * Desktop - install application (!)
 * MultiTOS - MiNTShell
 *
 * !! Achtung: bei MultiTOS darauf achten, daž MP's Speicher als
 * !! 'readable' deklariert wird (shared memory!)
 */

#include <stdio.h>
#include <aes.h>
#include <tos.h>
#include <string.h>


/* VA_START: Accessory wird aktiviert. Word 3 + 4 enthalten einen
 * Pointer auf eine Kommandozeile, der auch NULL sein kann.
 * In der Kommandozeile stehen Pfade oder Dateinamen.
 */
#define VA_START			0x4711

int 	msgbuf[8];
char	tmpstr[256];
char	ownpath[128];
char	va_string[4096];

int main(int argc, char *argv[])
{
	int 	i, gl_apid, paula_id;

	gl_apid=appl_init();
	
	ownpath[0]=Dgetdrv()+'A';		/* our own path... */
	ownpath[1]=':';
	Dgetpath(&ownpath[2], 0);
	strcat(ownpath, "\\");
	
	if ((paula_id=appl_find("PAULA   "))>=0 && argc>1)
	{
		va_string[0]=0;
		for(i=1; i<argc; i++)
		{
			strcpy(tmpstr, argv[i]);		/* copy... */
			shel_find(tmpstr);				/* Suchen! */
			if (strchr(tmpstr,'\\')==NULL)	/* pfad angegeben? */
			{								/* nein. */
				strcat(va_string, ownpath);
			}
			strcat(va_string, tmpstr);
			strcat(va_string, ";"); 		/* separator */
		}

		Cconws("Paula plays: ");
		Cconws(va_string); Cconws("\n\r");	/* to Console */
		wind_update(BEG_UPDATE);
		msgbuf[0]=VA_START; 				/* prepare MSG */
		msgbuf[1]=gl_apid;
		*(char **)&msgbuf[3] = va_string;
		msgbuf[6]=1;
		msgbuf[7]=0;
		appl_write(paula_id,16,msgbuf); 	/* send MSG */
		wind_update(END_UPDATE);
		
		/* Vorsicht MTOS: Dem Empf„nger Zeit lassen, den String
		 * zu kopieren. Sonst Memory Protection Violation!
		 */
		evnt_timer(1000,0);					/* wait 1 sec */
	}
	appl_exit();
	return(argc-1);
}


/* eof. */
