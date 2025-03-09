/* OPTOBELL.C
 *
 * Ersetzt die Ausgabe des BEL-Zeichens durch ein kurzes
 * Invertieren des Bildschirms.
 *
 * Geschrieben mit TC 2.0 und MAS
 *
 * 1991 by Robert Tolksdorf
 * (C) ST-Computer
 */

/************************************************
 * TOS-, VDI- und LINEA-Definitionen
 */
#include <tos.h>
#include <vdi.h>
#include <linea.h>

#include <ext.h>
/************************************************
 * Die Definitionen zur Kommunikation
 */
#include "optobell.h"

/************************************************
 *	In OPTOBIOS.S definiert
 */
extern	void	my_bios();
extern	void	*XB_BIOS;

#define NULL        ( ( void * ) 0L )

/* MFDB fr den Bildschirm, auf 0L initialisiert	*/
MFDB				screen = {NULL};
/* Quellen- und Zielkoordinaten						*/
int					pxy[8];
/* Fr den Zielwert des 200Hz-Z„hlers				*/
unsigned	long	wait;

/* Der 200Hz-Z„hler									*/
#define	HZ200		*(long *) 0x04BA
/* Fr andere Wartezeit HIER „ndern!				*/
#define WAIT		10
/* WAIT auf 50Hz-Wert anpassen						*/
#define	_WAIT_		((WAIT/5) & 0xFFFF)
/* Ein VDI-Handle, das es geben muž, da ein
   graf_handle im BIOS-Trap einen eigenen Stack
   erfordern wrde.									*/
#define	VDI_HANDLE	1

void blink(void)
{
	/* Bildschirmausmaže anfordern	*/
	/* Clipping aus					*/
	vs_clip(VDI_HANDLE,0,pxy);
	/* Bildschirmausmaže auslesen
	   und Rechteck bilden			*/
	pxy[2]=pxy[6]=Vdiesc->v_rez_hz-1;
	pxy[3]=pxy[7]=Vdiesc->v_rez_vt-1;
	/* Maus aus */
	v_hide_c(VDI_HANDLE);
	/* 1. Invertieren				*/
	vro_cpyfm(VDI_HANDLE, D_INVERT, pxy, &screen, &screen);
	/* Warten						*/
	for (wait=HZ200+_WAIT_/Linea->v_planes; wait>HZ200;);
	/* 2. Invertieren				*/
	vro_cpyfm(VDI_HANDLE, D_INVERT, pxy, &screen, &screen);
	/* Maus ein						*/
	v_show_c(VDI_HANDLE,1);
}

long	super_stack;
long	stackcorr;
int		OptoConf = O_BLINK;

/* Cookie-Jar einrichten, Zeiger auf ersten Cookie abliefern */
COOKIE *install_cookie_jar(long n)
{
	COOKIE	*cookie;
	
	cookie=Malloc(sizeof(COOKIE)*n);
	Super(0L);
	*(long *)0x5A0L=cookie;
	Super((void *) super_stack);
	cookie->id=0L;
	cookie->val=n;
	return (cookie);
}

void main(void)
{
	char	*mess1	=	"\r\n\x1Bp     OptoBell V 1.0     \x1Bq\r\n" \
						"1991 by Robert Tolksdorf\r\n" \
						"(C) ST-Computer\r\n";
	char	*mess2	=	"\r\n\x1Bp     OptoBell V 1.0     \x1Bq\r\n" \
						"Already installed\r\n";
	COOKIE	*cookie, *cookieo;
	int		ncookie = 0;
	long	jarsize;
	
	/* Systemvariablen lesen */
	super_stack=Super(0L);
	cookie=cookieo= *(long *)0x5A0L;
	stackcorr = (*(int *)0x59EL) ? 2 : 0 ;
	Super((void *) super_stack);
	/* Kein Cookie-Jar vorhanden -> neuen einrichten */
	if (!cookie)
	{
		cookie=install_cookie_jar(8L);
		ncookie=0;
	}
	else
		/* sonst durchsuchen */
		for (;((cookie->id) && (cookie->id!=OPTOID));cookie++, ncookie++);
	/* cookie zeigt auf RTOB-Cookie oder Null-Cookie */
	if (!cookie->id)	/* OptoBell noch nicht installiert */
	{
		/* Ist noch Platz ?? (nur, wenn Jar schon eingerichtet!) */
		if (cookie->val<=ncookie)
		{
			/* nein -> neuen einrichten, alten kopieren */
			cookie=install_cookie_jar(cookie->val+8L);
			for (;cookieo->id!=0L; (*cookie++)=(*cookieo++));
			cookie->id=0L;
			cookie->val=cookieo->val+8L;
		}
		/* Cookie hinterlassen */
		jarsize=cookie->val;	/* Groesse des Cookie-Jars merken */
		cookie->id=OPTOID;
		cookie++->val=&OptoConf;
		cookie->id=0L;
		cookie->val=jarsize;
		linea_init();
		/* Installieren */
		XB_BIOS=Setexc(45,my_bios);
		/* "Installiert"-Meldung */
		Cconws(mess1);
		/* Und resident im Speicher bleiben */
		Ptermres(_PgmSize,0);
	}
	else
		Cconws(mess2);
}

/* Ende von OPTOBELL.C */
