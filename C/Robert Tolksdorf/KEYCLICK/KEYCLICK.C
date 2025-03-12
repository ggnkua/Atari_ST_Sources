/***********************************************
*	KEYCLICK.C
*	Fenster-Elemente per Tastatur anklicken																*
*
*	1991 by Robert Tolksdorf
*
*	Geschrieben mit TURBO-C V2.0 mit MAS-68K 
*
************************************************/

/***********************************************
 * GEM-, VDI- und TOS-Definitionen
 */
#include <aes.h>
#include <vdi.h>
#include <tos.h>

#include "keyclick.h"

/***********************************************
 * Definition der Schrittweiten fr grobe und 
 * feine Ver„nderungen, minimale Gr”že der
 * Arbeitsfl„che
 */
#define COARSESTEP	16
#define FINESTEP	1
#define MINWORK		48
#define CYCLETIME	100


char	mentit[]	=	"  KeyClick";

/***********************************************
*
*	main()
*
*	Als Applikation und Accessory anmelden, 
*	Tastatur-Tests installieren und Dialog
*	zum An- und Abschalten durchfhren.
*	Bei Vorliegen von Zeichen im internen
*	 Puffer, Mitteilungen verschicken.
*/

void main()
{
	int			changestep = 16,
				wx,wy,ww,wh,		/* Fensterausmaže */
				mwx,mwy,mww,mwh,	/* maximale Gr”že */
				sy,sw,sh,			/* Bildschirmausmasse */
				wkind, topowner,
				event, message[8],
				wmessage[8],	
				workout[57];
	long		Stack;
	/* Die Texte fr die vier m”glichen Dialoge */
	char 		alert[2][2][65] = {
		"[2][KeyClick|Robert Tolksdorf][KC ein|ALT ein|Abbruch]",
		"[2][KeyClick|Robert Tolksdorf][KC aus|ALT ein|Abbruch]",
		"[2][KeyClick|Robert Tolksdorf][KC ein|ALT aus|Abbruch]",
	 	"[2][KeyClick|Robert Tolksdorf][KC aus|ALT aus|Abbruch]"};
	
	COOKIE		*cookie;
	KCC			*kc;
	
	/*	Anmeldung als Applikation 
		anmelden, dabei KeyClick gleich als 
		Sender von Mitteilungen vermerken   */
	wmessage[1]=appl_init();
	/* Standardmitteilungs */
	wmessage[2]=0;
	/* Ausmaže des Bildschirms ermitteln */
	vq_extnd(graf_handle(&wx,&wx,&wx,&sy),0,workout);
	sw=workout[0];
	sh=workout[1];
	/* Adress von kbshift ermitteln */
	Stack=Super(0L);
	cookie= *(long *)0x5A0L;
	Super((void *)Stack);
	if (cookie)
		for (;((cookie->id) && (cookie->id!=COOKIEID));
			 cookie++);
		if (cookie->id==COOKIEID)
		{
			kc=cookie->val;
			if (!kc->installed)
				kc->init();
			menu_register(wmessage[1], mentit);
			/* Hauptschleife, wartet auf Ereignis 
			   und stellt dann kleinen Dialog zum 
			   An- und Abschalten dar oder 
			   verarbeitet eine gepufferte Fenster-Taste */
			do
			{
				/* Auf Mitteilung oder das 
				   Vergehen von 100ms warten */
				event=evnt_multi(MU_MESAG | MU_TIMER,
								0,0,0,0,0,0,0,0,0,0,0,0,0,
								message, CYCLETIME, 0,
								&wx,&wx,&wx,&wx,&wx,&wx);
				/* AC_OPEN-Mitteilung eingetroffen ? */
				if ((event & MU_MESAG) &&
					(message[0]==AC_OPEN))
					/* Kleinen Dialog mit Alert-Box durchfhren */
					switch (form_alert(3,alert[kc->watchalt][kc->klickon]))
						{
							/* Button Ja */
							case 1:	 kc->klickon=!kc->klickon;
									 break;
							/* Button Nein */
							case 2:  kc->watchalt=!kc->watchalt;
									 break;
							/* Button Abbruch */
							default: break;
						}
				/* 100ms vergangen und Fenstertaste vorhanden ? */
				if ((event & MU_TIMER) &&
					(kc->windex!=kc->rindex))
				{
					/* Welches Handle hat das oberste Fenster ? */
					if ((wind_get(-1,WF_TOP,&wmessage[3])) &&
						(wmessage[3]))
					{
						topowner=kc->id[wmessage[3]];
						wkind=kc->kind[wmessage[3]];
						if (topowner==-1)
						{
							topowner=0;
							wkind=NAME+CLOSER+FULLER+MOVER+SIZER+
								  UPARROW+DNARROW+VSLIDE+LFARROW+
								  RTARROW+HSLIDE;
						}
						/* Mitteilung vorbereiten,
						   Sliderver„nderung als Default */
						wmessage[0]=0;	
						/* Fenstertaste verarbeiten */
						switch (kc->scans[kc->rindex])
						{
							case KEY_0:
								/* Window-Closed Mitteilung */
								if (wkind & CLOSER)
									wmessage[0]=WM_CLOSED;
								break;
							case KEY_ENTER:
								/* Window-Fulled Mitteilung */
								if (wkind & FULLER)
									wmessage[0]=WM_FULLED;
								break;
							case KEY_LBRACE:
								/* Seite nach links */
								if (wkind & HSLIDE)
								{
									wmessage[4]=WA_LFPAGE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_RBRACE:
								/* Spalte nach links */
								if (wkind & LFARROW)
								{
									wmessage[4]=WA_LFLINE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_SLASH:
								/* Spalte nach rechts */
								if (wkind & RTARROW)
								{
									wmessage[4]=WA_RTLINE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_STAR:
								/* Seite nach rechts */
								if (wkind & HSLIDE)
								{
									wmessage[4]=WA_RTPAGE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_9:
								/* Seite nach oben */
								if (wkind & VSLIDE)
								{
									wmessage[4]=WA_UPPAGE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_6:
								/* Zeile nach oben */
								if (wkind & UPARROW)
								{
									wmessage[4]=WA_UPLINE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_3:
								/* Zeile nach unten */
								if (wkind & DNARROW)
								{
									wmessage[4]=WA_DNLINE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_DOT:
							 	/* Seite nach unten */
								if (wkind & VSLIDE)
								{
									wmessage[4]=WA_DNPAGE;
									wmessage[0]=WM_ARROWED;
								}
								break;
							case KEY_MINUS:
								/* Verkleinern */
								if (wkind & SIZER)
								{
									wind_get(wmessage[3],WF_CURRXYWH,
											 &wmessage[4],&wmessage[5],
											 &ww,&wh);
									wind_get(wmessage[3],WF_WORKXYWH,
											 &mwx,&mwy,&mww,&mwh);
									wmessage[0]=WM_SIZED;
									wmessage[6]=((mww-changestep)>MINWORK ?
												 ww-changestep : ww);
									wmessage[7]=((mwh-changestep)>MINWORK ? 
												 wh-changestep : wh);
								}
								break;
							case KEY_PLUS:
								/* Vergr”žern */
								if (wkind & SIZER)
								{
									wind_get(wmessage[3],WF_CURRXYWH,
											 &wmessage[4],&wmessage[5],
											 &ww,&wh);
									wind_get(wmessage[3],WF_FULLXYWH,
											 &mwx,&mwy,&mww,&mwh);
									wmessage[0]=WM_SIZED;
									wmessage[6]=((ww+changestep)<mww ?
												 ww+changestep : mww);
									wmessage[7]=((wh+changestep)<mwh ?
												 wh+changestep : mwh);
								}
								break;
							case KEY_5:
								/* Grob verschieben/Gr”že „ndern */
								changestep=COARSESTEP;
								break;
							case KEY_2:
								/* Fein verschieben/Gr”že „ndern */
								changestep=FINESTEP;
								break;
							case KEY_7:
								/* Nach links verschieben */
								if (wkind & MOVER)
								{
									wind_get(wmessage[3],WF_CURRXYWH,
											 &wx,&wmessage[5],
											 &wmessage[6],&wmessage[7]);
									wmessage[0]=WM_MOVED;
									wmessage[4]=((wx-changestep)>changestep ?
												 wx-changestep : changestep);
								}
								break;
							case KEY_8:
								/* Nach rechts verschieben */
								if (wkind & MOVER)
								{
									wind_get(wmessage[3],WF_CURRXYWH,
											 &wx,&wmessage[5],
											 &wmessage[6],&wmessage[7]);
									wmessage[0]=WM_MOVED;
									wmessage[4]=((wx+changestep)<
												  sw-changestep ?
												 wx+changestep :
												 sw-changestep);
								}
								break;
							case KEY_4:
								/* Nach oben verschieben */
								if (wkind & MOVER)
								{
									wind_get(wmessage[3],WF_CURRXYWH,
											 &wmessage[4],&wy,
											 &wmessage[6],&wmessage[7]);
									wmessage[0]=WM_MOVED;
									wmessage[5]=((wy-changestep)>sy ?
												 wy-changestep : sy);
								}
								break;
							case KEY_1:
								/* Nach unten verschieben */
								if (wkind & MOVER)
								{
									wind_get(wmessage[3],WF_CURRXYWH,
											 &wmessage[4],&wy,
											 &wmessage[6],&wmessage[7]);
									wmessage[0]=WM_MOVED;
									wmessage[5]=((wy+changestep)<
												  sh-changestep ?
												 wy+changestep :
												 sh-changestep);
								}
								break;
		 				}
						/* Mitteilung mit 16 Bytes L„nge an
						   Applikation 0 abschicken */
						if (wmessage[0])
							appl_write(topowner,16,wmessage);
					}
					/* Fenstertaste aus Buffer nehmen */
					kc->rindex=(kc->rindex+1) & (BUFFERSIZE-1);
				}
			} while(1);
			/* Old Accessories never die -
			   they just loop again */
		}
	else
	{
		form_alert(1,"[3][Ohne den residenten|"\
						"Teil in KEYCLICK.PRG|"\
						"kann KEYCLICK nicht|"\
						"arbeiten][Abbruch]");
		do
			evnt_mesag(message);
		while(1);
	}
}
/* Ende von KEYCLICK.C */

