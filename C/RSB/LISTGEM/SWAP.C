/************************************************************************
 * Datei: Swap.c    	Zweck: 	Bildschirmumschaltung GEM-konform		*
 * Autor: RSB                                                           *
 * Datum 23.05.90       Grund: 	SwapScreen(), SwapScreenFast() und		*
 *								ChainOnNewScreen() fÅr TOS Magazin		*
 * -------------------------------------------------------------------- *
 * Anmerkung: 	Geschrieben in ANSI-C mit Turbo C 2.0 auf Atari fÅr 	*
 *				GEM unter TOS und MSDOS  								*
 ************************************************************************/

#include <stdlib.h>		/* malloc() */
#include <stddef.h>		/* NULL */
#include <vdi.h>		/* MFDB */
#include <aes.h>		/* OBJECT */
#include <string.h>		/* strcpy(), strlen() */
#include <errno.h>		/* errno, EACCES, EMFILE, ENOENT, ENOMEM, EPLFMT */
#include <process.h>	/* exec */
#include "GEMWork.h"	/* ScreenWidth, ... */
#include "FName.h"		/* strsfn() */
#include "ApplUtil.h"   /* HoleVollName(), Clear() */
#include "Swap.h"

/* unumgehbare Betriebssystem/Umgebungs-AbhÑngigkeiten */
#ifdef __MSDOS__
	#include <MSDOS.h>	/* exec(), malloc, dos_alloc(), ... */
	#include <dir.h>	/* getcurdir(), MAXPATH, MAXDRIVE */
#else
	#include "GEMDOS.H" /* SetDisk() */
	#include <ext.h>	/* getcurdir(), MAXPATH, MAXDRIVE */
#endif

/************************************************************************
 * allgemeine statische Funktionen										*
 ************************************************************************/

static int Max(int x, int y)
{	return (x < y) ? y : x; }

static int Min(int x, int y)
{	return (x < y) ? x : y; }

/* i in den Bereich [l..u] zwÑngen */
static int Inside(int l, int u, int i)
{	return Min(Max(l,i),u); }

/************************************************************************
 * externe Variablen                                                    *
 ************************************************************************/

/************************************************************************
 * modulglobale Variablen                                          		*
 ************************************************************************/

static MFDB VirtualScreen;			/* fÅr ChainOnNewScreen */
static MFDB RingTauschBildschirm;	/* fÅr SwapScreenFast */

static OBJECT TOSDesktop[] = {
-1, -1, -1, G_BOX, LASTOB, NORMAL, 0xFF1001L, 0,0, 65,11};

static OBJECT GEMDesktop[] = {
-1, -1, -1, G_BOX, LASTOB, NORMAL, 0xFF1041L, 0,0, 65,11};

/************************************************************************
 * Aktuellen Pfad samt Laufwerk holen und setzen, umgebungsabhÑngig     *
 ************************************************************************/

char *GetActualPath(void)
{	static char path[MAXDRIVE+MAXPATH];
	strcpy (path, " :\\");
	path[0] = 'A' + getdisk();  /* Laufwerk */
	getcurdir(0, path+3);
	return path;
} /* GetActualPath */

int SetActualPath(char *NewPath)	/* z.B.: "E:\\SYS\\COMMAND.TOS" */
{
	char path[MAXPATH], drive[MAXDRIVE], dummy[MAXPATH+MAXDRIVE];
    int lw;

  /* neues Laufwerk und Pfad aus NewPath ablesen */
  strsfn(NewPath,drive,path,dummy,dummy);
  /* neues aktuelles Laufwerk setzen */
  if (strlen(drive) > 0) {
    lw = (drive[0]-'A');
	if (!setdisk(lw)) {
      form_alert(1,"[3][Das angewÑhlte Laufwerk|ist nicht bekannt][Abbruch]");
      return 0;
    }
  }
  /* neuen aktuellen Pfad setzen */
  if (strlen(path) > 0) {
    if (chdir(path) != 0) {
      form_error(errno);
      return 0;
    }
  }
  return 1;
} /* SetActualPath */

/************************************************************************
 * Ein anderes Programm als Prozedur aufrufen            				*
 ************************************************************************/

int ChainOnNewScreen(	int isGemDa, char *Head, char *Tail,
						OBJECT *MenuTree, OBJECT *DeskTree)
{
  	int rc;
	char aktPfad[MAXDRIVE+MAXPATH];

	/* alten MenÅbalken abmelden */
	menu_bar(MenuTree,0);
	/* TOS-Programme brauchen einen Cursor, aber keine Maus */
	if (!isGemDa) {
		TOSDesktop[0].ob_width = ScreenWidth;
		TOSDesktop[0].ob_height = ScreenLength;
		wind_set(0,WF_NEWDESK,&TOSDesktop,0);
		v_hide_c(VDIHandle);
		/* sicherheitshalber lîschen */
		Clear(0,0, ScreenWidth-1,ScreenLength-1);
		v_enter_cur(VDIHandle);
	}
	else {
		GEMDesktop[0].ob_y = BoxHeight;
		GEMDesktop[0].ob_width = ScreenWidth;
		GEMDesktop[0].ob_height = ScreenLength;
		wind_set(0,WF_NEWDESK,&GEMDesktop,0);
	}
	strcpy(aktPfad,GetActualPath());
	SetActualPath(Head);
	SwapScreen();
	/* Redraw Message fÅr gesamten Bildschirm (mit neuem Desktop) absetzen */
	form_dial(FMD_FINISH,0,0,0,0,0,0,ScreenWidth,ScreenLength);
	/* Info-Anzeige auf neuem Bildschim, aber nur bei GEM */
	if (isGemDa) {
		ShowInfo(Head);
		exec(Head,Tail,"PATH=C:\\TEXTVER\\;E:\\SYS;E:\\",&rc);
	}
	else
	#ifdef __MSDOS__
		execDOS(Head,Tail,"PATH=C:\\TEXTVER\\;E:\\SYS;E:\\",&rc);
	#else
		exec(Head,Tail,"PATH=C:\\TEXTVER\\;E:\\SYS;E:\\",&rc);
	#endif
	SwapScreen();
	/* alten Pfad wieder als aktuellen anmelden */
	SetActualPath(aktPfad);
  	/* Cursor ausschalten, wenn nîtig */
	if (!isGemDa)
		v_exit_cur(VDIHandle);
  	/* altes Desktop anmelden */
  	wind_set(0,WF_NEWDESK,DeskTree,0,0);
  	/* Maus einschalten */
	v_show_c(VDIHandle,0);
  	/* MenÅbalken wieder anmelden */
  	menu_bar(MenuTree,1);
  	/* Redraw-Message */
	form_dial(FMD_FINISH,0,0,0,0,0,0,ScreenWidth,ScreenLength);
	if (rc < 0) {
		switch (errno) {	/* Fehlerbehandlung */
			case EACCES:
			case EMFILE:
			case ENOENT:
			case ENOMEM:
			default:
				form_error(errno);
		}
	}
	return rc;
} /* ChainOnNewScreen */

int SoftCopy(int direction)	/* 1: to Mem, 0: to Screen */
{
	int pxyarray[8];
	MFDB Scr = { NULL,  };

	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = ScreenWidth;
	pxyarray[3] = ScreenLength;
	pxyarray[4] = 0;
	pxyarray[5] = 0;
	pxyarray[6] = ScreenWidth;
	pxyarray[7] = ScreenLength;
	if (!VirtualScreen.fd_addr) {	/* Pufferbereich initialisieren */
		VirtualScreen.fd_w = ScreenWidth;
		VirtualScreen.fd_h = ScreenLength;
	    VirtualScreen.fd_wdwidth = ScreenWidth/16;
		VirtualScreen.fd_stand = 1;
	    VirtualScreen.fd_nplanes = ScreenPlanes;
		if ((VirtualScreen.fd_addr = calloc((size_t)2*VirtualScreen.fd_wdwidth,(size_t)VirtualScreen.fd_h*VirtualScreen.fd_nplanes)) == NULL) {
			form_alert(1,"[1][Nicht mehr genÅgend Speicher|fÅr SoftCopy][Schade!]");
			return 0;
		}
	}
	if (direction) /* Screen to Memory */
		vro_cpyfm(VDIHandle,S_ONLY,pxyarray,&Scr,&VirtualScreen);
	else vro_cpyfm(VDIHandle,S_ONLY,pxyarray,&VirtualScreen,&Scr);
	return 1;
} /* SoftCopy */

int SwapScreenFast(void)	/* mit Pufferspeicher */
{
	int pxyarray[8];
	MFDB Scr = { NULL,  };

	v_hide_c(VDIHandle);
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = ScreenWidth-1;
	pxyarray[3] = ScreenLength-1;
	pxyarray[4] = 0;
	pxyarray[5] = 0;
	pxyarray[6] = ScreenWidth-1;
	pxyarray[7] = ScreenLength-1;
    RingTauschBildschirm.fd_w = ScreenWidth;
    RingTauschBildschirm.fd_h = ScreenLength;
    RingTauschBildschirm.fd_wdwidth = ScreenWidth/16;
    RingTauschBildschirm.fd_stand = 1;
    RingTauschBildschirm.fd_nplanes = ScreenPlanes;
	if ((RingTauschBildschirm.fd_addr = calloc(2,RingTauschBildschirm.fd_wdwidth*ScreenLength*ScreenPlanes)) == NULL) {
		v_show_c(VDIHandle,0);
		form_alert(1,"[1][kein Speicherplatz fÅr|Ringtauschbildschirm verfÅgbar][Abbruch]");
		return 0;	/* kein Speicher mehr */
	}
	vro_cpyfm(VDIHandle,S_ONLY,pxyarray,&Scr,&RingTauschBildschirm);
	SoftCopy(toScr);
	vro_cpyfm(VDIHandle,S_ONLY,pxyarray,&RingTauschBildschirm,&VirtualScreen);
	free(RingTauschBildschirm.fd_addr);
	v_show_c(VDIHandle,0);
	return 1;
}

int SwapScreen(void)	/* ohne Pufferspeicher */
{
	int pxyarray[8];
	MFDB Scr = { NULL,  };

	v_hide_c(VDIHandle);
	pxyarray[0] = 0;
	pxyarray[1] = 0;
	pxyarray[2] = ScreenWidth-1;
	pxyarray[3] = ScreenLength-1;
	pxyarray[4] = 0;
	pxyarray[5] = 0;
	pxyarray[6] = ScreenWidth-1;
	pxyarray[7] = ScreenLength-1;
	if (!VirtualScreen.fd_addr) { /* Initialisierung des Speicherbereichs */
	    VirtualScreen.fd_w = ScreenWidth;
	    VirtualScreen.fd_h = ScreenLength;
	    VirtualScreen.fd_wdwidth = ScreenWidth/16;
	    VirtualScreen.fd_stand = 1;
	    VirtualScreen.fd_nplanes = ScreenPlanes;
		if ((VirtualScreen.fd_addr = calloc(2,VirtualScreen.fd_wdwidth*ScreenLength*ScreenPlanes)) == NULL)
			return 0;
	}
	vro_cpyfm(VDIHandle,S_XOR_D,pxyarray,&Scr,&VirtualScreen);
	vro_cpyfm(VDIHandle,S_XOR_D,pxyarray,&VirtualScreen,&Scr);
	vro_cpyfm(VDIHandle,S_XOR_D,pxyarray,&Scr,&VirtualScreen);
	v_show_c(VDIHandle,0);
	return 1;
}

