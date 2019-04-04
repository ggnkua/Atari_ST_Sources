/************************************************************************
 *                                                                      *
 *  Name: SwapDemo.c  	Zweck: 	Demoprogramm zum Bildschirmumschalten	*
 *                              Aufruf eines Programms                  *
 *  Autor: RSB                                                          *
 *  Datum: 23.05.90  	Grund: 	TOS-Magazin                     		*
 *                                                                      *
 ************************************************************************/

#include <aes.h>
#include <vdi.h>			/* vq_key_s() */
#ifdef __MSDOS__
	#include <dir.h>        /* MAXPATH, ... */
#else
	#include <ext.h>		/* MAXPATH, ... */
#endif
#include <stdio.h>		/* sprintf() */
#include <ScanCode.h>	/* F1, F2, HELP, CTRL_Q; auf der TC-Originaldiskette im Ordner DEMO_ATC */
#include "GEMWork.h"
#include "ApplUtil.h"	/* HoleVollName() */
#include "Swap.h"
#include "SwapDemo.h"

/************************************************************************
 *  globale Variable                                       				*
 ************************************************************************/

OBJECT *pDeskTop, *pHauptMen, *pAboutbox;

char ExecHead[MAXPATH]     		= "";
char ExecTail[MAXPATH]  		= "";
#ifdef __MSDOS__
char ExecTOSPfad[MAXPATH]		= "C:\\*.COM,*.EXE";
char ExecTOS[MAXFILE+MAXEXT]	= "COMMAND.COM";
char ExecPRGPfad[MAXPATH] 		= "C:\\GEMAPPS\\*.APP";
char ExecPRG[MAXFILE+MAXEXT] 	= "";
#else
char ExecTOSPfad[MAXPATH]		= "C:\\*.TOS";
char ExecTOS[MAXFILE+MAXEXT]	= "COMMAND.TOS";
char ExecPRGPfad[MAXPATH] 		= "C:\\*.PRG";
char ExecPRG[MAXFILE+MAXEXT] 	= "";
#endif

#define RSCName "SwapDemo.RSC"
#define RSCfehlt "[3][Ohne die Datei|%s|geht leider gar nichts!][ au weh ]"


/************************************************************************
 * Initialisierung, Terminierung                                        *
 ************************************************************************/

void Terminate(void)
{
	menu_bar(pHauptMen,0);
	rsrc_free();
	GemExit(VDIHandle);
} /* Terminate */

int Init(void) /* rc = true | false */
{
	static char Meldung[200];
	int xDesk, yDesk, wDesk, hDesk;

	VDIHandle = GemInit();
	if (rsrc_load(RSCName) == 0) {
		sprintf(Meldung,RSCfehlt,RSCName);
		form_alert(1,Meldung);
		GemExit(VDIHandle);
		return (0);
	}
	/* Desktopgrîûe holen */
	wind_get(0,WF_WORKXYWH,&xDesk,&yDesk,&wDesk,&hDesk);
	rsrc_gaddr(R_TREE,DESKTOP,&pDeskTop);
	/* Desktop-Objekt auf richtige Grîûe bringen */
	pDeskTop[0].ob_x = xDesk;
	pDeskTop[0].ob_y = yDesk;
	pDeskTop[0].ob_width  = wDesk;
	pDeskTop[0].ob_height = hDesk;
	/* Desktop-Objekte positionieren */
	pDeskTop[MAXL].ob_x = wDesk-pDeskTop[MAXL].ob_width;
	pDeskTop[MAXL].ob_y = hDesk-pDeskTop[MAXL].ob_height;
	/* neues DeskTop anmelden und zeichnen */
	wind_set(0,WF_NEWDESK,pDeskTop,0,0);
	rsrc_gaddr(R_TREE,HAUPTMEN,&pHauptMen); /* Strukturzeiger merken */
	rsrc_gaddr(R_TREE,ABOUTBOX,&pAboutbox);
	SwapScreen();
	#ifdef __MSDOS__
	{	void ReInstallDesktop(void);
		ReInstallDesktop();
	}
	#endif
	menu_bar(pHauptMen,1);    /* MenÅbalken aktivieren */
	objc_draw(pDeskTop,0,8,xDesk,yDesk,wDesk,hDesk);
	return (1);
} /* Init */

/************************************************************************
 *  MenÅ-Verarbeitung                                                   *
 ************************************************************************/

int MenueAuswahl(int Menue, int Punkt) /* Ende des Programms? ja | nein */
{
	int rc = 0;

	switch (Menue) {
		case DATEI:
			switch (Punkt) {
				case TOSEXEC:
					menu_tnormal(pHauptMen,Menue,1);
					if (HoleVollName(ExecTOSPfad,ExecTOS,"TOS-Programm aufrufen")) {
						ChainOnNewScreen(0,ExecTOS,"",pHauptMen,pDeskTop);
          			}
          			else menu_bar(pHauptMen,1);
          			break;
        		case GEMEXEC:
		          	menu_tnormal(pHauptMen,Menue,1);
          			if (HoleVollName(ExecPRGPfad,ExecPRG,"PROGRAMM - AUFRUF"))
            			ChainOnNewScreen(1,ExecPRG,"",pHauptMen,pDeskTop);
			        else menu_bar(pHauptMen,1);
          			break;
                case ENDE:
                    rc = 1;
                    break;
                default:
                	break;
			}
			break;
		case DESK:
			if (Punkt == ABOUT)
				DoDialog(pAboutbox,0);
		default:
			break;
	}
	menu_tnormal(pHauptMen,Menue,1);
	return (rc);
} /* MenueAuswahl */

/************************************************************************
 *  Event-Verwaltung                                                    *
 ************************************************************************/

void Arbeitsschleife(void)
{
	int MouseX, MouseY, MouseBut, MouseClicks, KeyCode, CtrlCode;
	int pipeBuf[8];
	int result;
	int done = 0;

	graf_mouse(ARROW,NULL);
	while (!done) {	/* Dauerschleife des Programms, Eventverwaltung */
		result = evnt_multi(MU_MESAG | MU_BUTTON | MU_KEYBD,
		              1,1,1, 0,0,0,0,0, 0,0,0,0,0,
		              pipeBuf, 0,0,
		              &MouseX,&MouseY,&MouseBut,
		              &CtrlCode,&KeyCode, &MouseClicks);
		if (result & MU_MESAG) { /* Message erhalten */
		    if (pipeBuf[0] == MN_SELECTED) {
		  	    done = MenueAuswahl(pipeBuf[3],pipeBuf[4]);
			}
		}
		/* Tastaturereignisse bearbeiten */
		else if (result & MU_KEYBD) { /* Taste gedrÅckt */
			switch (KeyCode) {
				#ifdef __MSDOS__
					int echo_xy[2] = {0,0};
					char string[2];
				#endif
				case F10:
					SwapScreen();
					#ifdef __MSDOS__
						vrq_string(VDIHandle,1,0,echo_xy,string);
					#else
						getch();
					#endif
					SwapScreen();
					break;
				case F9:
					SwapScreenFast();
					#ifdef __MSDOS__
						vrq_string(VDIHandle,1,0,echo_xy,string);
					#else
						getch();
					#endif
					SwapScreenFast();
					break;
				/* folgende Funktionen undokumentiert */
				case F3:
					Clear(50,50,50,50);
					break;
				case F4:
					SoftCopy(toMem);
					break;
				case F5:
					SoftCopy(toScr);
					break;
				case HELP:
					DoDialog(pAboutbox,0);
					break;
				case CNTRL_Q:
					done = 1;
				default:
					break;
			}
		}
	}
} /* Arbeitsschleife */


int main()
{
	if (!Init())
		return 1;
	Arbeitsschleife();
	Terminate();
	return 0;
} /* main */