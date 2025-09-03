#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#include <xstrings.h> /* Erweiterte Stringverwaltung */

#define E_NOERROR	0					/* Kein Fehler					  */
#define E_ABORT		-1					/* Allgemeiner Fehler			  */
#define E_NOTFOUND	-33					/* Fehler: Datei nicht gefunden	  */
#define CONTROL_Z	26					/* Pufferende-Markierung		  */
#define pathlen		81					/* Maximale PfadlÑnge			  */
#define max_buflen	2048				/* Maximale LÑnge fÅr DESKTOP.INF */
#define _bootdev	Supexec(__bootdev)	/* BootgerÑt ermitteln			  */
#define _bd			0x446				/* Adresse fÅr BootgerÑt		  */

int __bootdev(void)
{
	return (*(int *)_bd);
}

void main(int argc,char *argv[])
{
	char loadfile[pathlen];
	char shellbuffer[max_buflen];
	FILE *the_handle;

	if (argc==1) {
		s_assign(loadfile,"x:\\DESKTOP.INF"); /* Standardname */
		*loadfile=(char)(_bootdev+65); /* Standardlaufwerk einsetzen */
	}
	else {
		if (argc>2) {
			form_alert(1,"[1][|UnzulÑssige Anzahl|Kommandozeilenparameter!]"
				"[Abbruch]");
			exit (E_ABORT); /* Nur max. ein Kommando erlaubt */
		}
		if (s_len(argv[1])>pathlen-1) {
			form_alert(1,"[1][|Parameter zu lang!][Abbruch]");
			exit (E_ABORT); /* Maximale PfadlÑnge Åberschritten */
		}
		s_assign(loadfile,argv[1]);
	}
	if ((the_handle=fopen(loadfile,"rb"))==NULL)
		exit (E_NOTFOUND); /* Datei kann nicht geîffnet werden */
	shellbuffer[fread(shellbuffer,sizeof(*shellbuffer),max_buflen-1,
		the_handle)]=CONTROL_Z; /* Pufferende korrekt kennzeichnen */
	fclose(the_handle);
	shel_put(shellbuffer,max_buflen);
	exit (E_NOERROR);
}
