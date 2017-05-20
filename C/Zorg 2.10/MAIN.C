/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#define VERSION "2.10"

/* #define TEST_VERSION */

#ifdef TEST_VERSION
#define TEST_VERSION_TEXT "TEST VERSION"
char SharewareSound[] = {0x00, 0x00, 0x01, 0x00, 0x07, 0xFE, 0x08, 0x10, 0x0B, 0xCF, 0x0C, 0x58, 0x0D, 0x00, 0x80, 0x00, 0x81, 0x00, 0x29, 0x00, 0xFF, 0x00};
#endif

extern char Registred;

#define FRENCH_RESSOURCE_FILE "ZORG.RSC"
#define ENGLISH_RESSOURCE_FILE "ZORG_E.RSC"

/************************************************
*												*
*		Boite Ö outils pour disques durs		*
*												*
*************************************************/

#include <e_gem.h>
#include <string.h>

#include "zorg.h"
#define  Extern
#include "globals.h"
#undef	 Extern

#include "main.h"
#include "config.h"
#include "curseur.h"
#include "desk.h"
#include "dialog.h"
#include "fenetre.h"
#include "init.h"
#include "menu.h"
#include "ouvre.h"
#include "tampon.h"
#include "update.h"
#include "wind.h"

#define TIMER 460

/* variable dÇfinie dans CONFIG.H */
typedef struct
{
	int menu;
	int entree;
	int key;
	int state;
} raccourcis_var;

/***********************************************************************
 Initialisierungs-Routine, welche von X_Form_Do bzw. Event_Multi aufge-
 rufen wird und die Event-Struktur setzt sowie die Ereignisse, die von der
 Applikation benîtigt werden, zurÅckgibt
***********************************************************************/
int InitMsg(XEVENT *evt, int events_available)
{
	int x, y;

	/* timer */
	evt -> ev_mt2count = Timer;
	evt -> ev_mt2last = 0L;

	/* clic souris */
	evt -> ev_mb2clicks = MaxClics;
	evt -> ev_mb2mask = 3;
	evt -> ev_mb2state = 0;

	/* on redessine tout */
	Efface = TRUE;

	/* on remet le pointeur comme on veut */
	if (Zone.g_w)
	{
		mouse(&x, &y);

		if (x>=Zone.g_x && x<=Zone.g_x+Zone.g_w && y>=Zone.g_y && y<=Zone.g_y+Zone.g_h)
		{
			Sens = 1;
			MousePointHand();
		}
		else
		{
			Sens = 0;
			MouseArrow();
		}

		/* zone */
		evt -> ev_mm2flags = Sens;
		evt -> ev_mm2x = Zone.g_x;
		evt -> ev_mm2y = Zone.g_y;
		evt -> ev_mm2width = Zone.g_w;
		evt -> ev_mm2height = Zone.g_h;

		EventMask |= MU_M2;
	}
	else
	{
		EventMask &= ~MU_M2;
		MouseArrow();
	}

	/* les Çvenements Ö surveiller */
	return EventMask & events_available;
} /* InitMsg */

/***********************************************************************
 Ereignisauswertung (AES-Nachrichten, TastendrÅcke, Timer ), welche sowohl
 von Event_Multi() als auch von X_Form_Do() aufgerufen wird
***********************************************************************/
int Messag(XEVENT *event)
{
	reg int ev = event -> ev_mwich, *msg = event -> ev_mmgpbuf;
	reg int used = 0;
	reg windowptr thewin = Thefrontwin;

	/* Nachricht vom AES ? */
	if (ev & MU_MESAG)
	{
		/* Nachrichtenereignis wurde ausgewertet */
		used |= MU_MESAG;

		switch (*msg)
		{
			/* MenÅeintrag angeklickt ? */
			case MN_SELECTED:
				/* MenÅeintrag deselektieren */
				menu_tnormal(Menu, msg[3], 1);

				/* gewÅnschte Funktion ausfÅhren */
				if (MenuSelect(msg[4], 0, 0, FAIL) == FALSE)
					/* Nachricht konnte nicht ausgewertet werden
					   (sollte NIE vorkommen) */
					used &= ~MU_MESAG;
				break;

			case WM_REDRAW:
			case WM_TOPPED:
			case WM_CLOSED:
			case WM_FULLED:
			case WM_ARROWED:
			case WM_HSLID:
			case WM_VSLID:
			case WM_SIZED:
			case WM_MOVED:
			case WM_NEWTOP:
			case WM_UNTOPPED:
			case WM_ONTOP:
			case WM_BOTTOM:
				do_window(msg);
				break;

			/* Applikation beenden/rÅcksetzen */
			case AP_TERM:
			case AC_CLOSE:
				shutdown(Reset);
				break;

			/* Accessory îffnen (Hauptdialog îffnen) */
			case AC_OPEN:
				break;

			/* Applikation hat sich an- oder abgemeldet */
			case XACC_AV_INIT:
			case XACC_AV_EXIT:
				break;

			default:
			/* unbekannte Nachricht konnte nicht ausgewertet werden */
				used &= ~MU_MESAG;
		}
	}

	/* Tastatur-Ereignis auswerten */
	if (ev & MU_KEYBD && !ob_isstate(Menu, MENU_ETAT, DISABLED))
	{
		int key = event -> ev_mkreturn & 0xFF;
		int maj = key & ~0x20;
		int top;

		wind_get(0, WF_TOP, &top);
		if (Dialog[CONFIG_MENU].info != NULL && Dialog[CONFIG_MENU].info -> di_flag > CLOSED && top == Dialog[CONFIG_MENU].info -> di_win -> handle)
		{	/* la configuration des raccourcis est ouverte */
			((raccourcis_var *)Dialog[CONFIG_MENU].var) -> state = event -> ev_mmokstate;
			((raccourcis_var *)Dialog[CONFIG_MENU].var) -> key = event -> ev_mkreturn;
			(*Dialog[CONFIG_MENU].proc)(&Dialog[CONFIG_MENU], FAIL);
		}
		else
		{
			/* gewÅnschte Funktion ausfÅhren */
			if (MenuSelect(FAIL, event -> ev_mkreturn, event -> ev_mmokstate, FAIL))
				used |= MU_KEYBD;	/* Tastaturereignis wurde ausgewertet */
			else
				if (scantoascii(event -> ev_mkreturn) == 0)
				{	/* touches spÇciales */
					key = event -> ev_mkreturn >> 8;
					switch (event -> ev_mmokstate)
					{
						case K_RSHIFT:
						case K_LSHIFT:
							switch (key)
							{
								case SCANUP:
									if (thewin -> type >= TAMPON)
									{
										if (thewin -> fonction.fichier.curseur_x < 0)
										{
											if (thewin -> type != TAMPON)
												MenuSelect(BLOC_PRECEDENT, 0, 0, FAIL);
											else
											{
												msg[4] = PAGE_UP;
												msg[0] = WM_ARROWED;
												msg[3] = thewin -> win -> handle;
												do_window(msg);
											}
										}
										else
											curseur_up(thewin, TRUE);
									}
									else
									{
										msg[4] = PAGE_UP;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;

								case SCANDOWN:
									if (thewin -> type >= TAMPON)
									{
										if (thewin -> fonction.fichier.curseur_x < 0)
										{
											if (thewin -> type != TAMPON)
												MenuSelect(BLOC_SUIVANT, 0, 0, FAIL);
											else
											{
												msg[4] = PAGE_DOWN;
												msg[0] = WM_ARROWED;
												msg[3] = thewin -> win -> handle;
												do_window(msg);
											}
										}
										else
											curseur_down(thewin, TRUE);
									}
									else
									{
										msg[4] = PAGE_DOWN;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;

								case SCANLEFT:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0)
										curseur_left(thewin, FALSE, TRUE);
									else
									{
										msg[4] = PAGE_LEFT;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;

								case SCANRIGHT:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0)
										curseur_right(thewin, FALSE, TRUE);
									else
									{
										msg[4] = PAGE_RIGHT;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;

								case SCANHOME:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0)
										curseur_home(thewin, TRUE);
									break;
							}
							break;

						case K_CTRL:
							switch (key)
							{
								case CTRLLEFT:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0 && !thewin -> fonction.secteur.ascii)
										curseur_left(thewin, FALSE, FALSE);
									break;

								case CTRLRIGHT:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0 && !thewin -> fonction.secteur.ascii)
										curseur_right(thewin, FALSE, FALSE);
									break;

								case SCANUP:
									if (thewin -> type >= SECTEUR)
										MenuSelect(SECTEUR_PRECEDEN, 0, 0, FAIL);
									break;

								case SCANDOWN:
									if (thewin -> type >= SECTEUR)
										MenuSelect(SECTEUR_SUIVANT, 0, 0, FAIL);
									break;
							}
							break;

						case 0:
							switch (key)
							{
								case SCANHOME:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0)
										curseur_home(thewin, FALSE);
									break;

								case SCANUP:
									if (thewin -> type >= TAMPON)
									{
										if (thewin -> fonction.fichier.curseur_x < 0)
										{
											if (thewin -> type != TAMPON)
												MenuSelect(SECTEUR_PRECEDEN, 0, 0, FAIL);
											else
											{
												msg[4] = LINE_UP;
												msg[0] = WM_ARROWED;
												msg[3] = thewin -> win -> handle;
												do_window(msg);
											}
										}
										else
											curseur_up(thewin, FALSE);
									}
									else
									{
										msg[4] = LINE_UP;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;

								case SCANDOWN:
									if (thewin -> type >= TAMPON)
									{
										if (thewin -> fonction.fichier.curseur_x < 0)
										{
											if (thewin -> type != TAMPON)
												MenuSelect(SECTEUR_SUIVANT, 0, 0, FAIL);
											else
											{
												msg[4] = LINE_DOWN;
												msg[0] = WM_ARROWED;
												msg[3] = thewin -> win -> handle;
												do_window(msg);
											}
										}
										else
											curseur_down(thewin, FALSE);
									}
									else
									{
										msg[4] = LINE_DOWN;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;

								case SCANLEFT:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0)
										curseur_left(thewin, TRUE, FALSE);
									else
									{
										msg[4] = LINE_LEFT;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;

								case SCANRIGHT:
									if (thewin -> type >= TAMPON && thewin -> fonction.fichier.curseur_x >= 0)
										curseur_right(thewin, TRUE, FALSE);
									else
									{
										msg[4] = LINE_RIGHT;
										msg[0] = WM_ARROWED;
										msg[3] = thewin -> win -> handle;
										do_window(msg);
									}
									break;
							}
							break;
					}
				}
				else
					if (thewin -> type >= TAMPON && thewin -> fonction.secteur.curseur_x >= 0)
						if ((event -> ev_mmokstate & K_LSHIFT) || (event -> ev_mmokstate & K_RSHIFT))
						/* shift */
							if (thewin -> fonction.secteur.ascii)
								edit(thewin, key, TRUE);
							else
								if (maj >= 'A' && maj <='Z' && (Kbshift(FAIL) & 16))	/* minuscule mais avec CapsLock donc en fait MAJUSCULE */
									edit(thewin, key, TRUE);
								else
									edit(thewin, key | 0x20, TRUE);
						else
							edit(thewin, key, FALSE);
					else
						if ('A' <= maj && maj <= 'P')
							do_desk(0, 0, FALSE, maj);
		}
	}

	/* un clic prolongÇ */
	if (ev & MU_TIMER2)
	{
		/* on maintient le clic dans la fenàtre */
		int wind = wind_find(event -> ev_mmox, event -> ev_mmoy);

		if (wind)
		{
			windowptr thewin;
			if ((thewin = findwindowptr(wind)) != NULL && event -> ev_mmox >= thewin -> win -> work.g_x && event -> ev_mmox <= thewin -> win -> work.g_x + thewin -> win -> work.g_w && event -> ev_mmoy >= thewin -> win -> work.g_y && event -> ev_mmoy <= thewin -> win -> work.g_y + thewin -> win -> work.g_h)
				if (thewin -> type >= TAMPON)
					do_mouse(thewin, event -> ev_mmox, event -> ev_mmoy, FALSE);
				else
					if (thewin -> type == OCCUP && thewin -> fonction.occup.fichier)
						do_mouse_occupation(thewin, event -> ev_mmox, event -> ev_mmoy);

			Timer = 1;
		}

		used |= MU_TIMER2;
	}

	/* un clic bouton ? */
	if (ev & MU_BUTTON2)
	{
		if (event -> ev_mmobutton == 1)
		{
			int wind = wind_find(event -> ev_mmox, event -> ev_mmoy);

			if (!wind)	/* on est sur le bureau */
			{
				if (DrawParam)	/* la boåte d'information est affichÇe ? */
					do_desk(event -> ev_mmox, event -> ev_mmoy, event -> ev_mb2return == 2, 0);
			}
			else	/* on est sur une fenàtre */
			{
				windowptr thewin = findwindowptr(wind);

				if  (thewin)
				{
					if (thewin -> type >= TAMPON && do_mouse(thewin, event -> ev_mmox, event -> ev_mmoy, event -> ev_mb2return == 2))
					{
						if (thewin -> type != TAMPON && event -> ev_mmox >= thewin -> fonction.fichier.slide[SLIDER_FOND].ob_x)
							/* on est dans la zone de dÇplacement */
							Timer = TIMER;
						else
							/* on est dans la fenàtre elle-màme */
							Timer = 1;

						EventMask |= MU_TIMER2;
					}
					else
						if (thewin -> type == OCCUP && thewin -> fonction.occup.fichier)
						{
							do_mouse_occupation(thewin, event -> ev_mmox, event -> ev_mmoy);

							Timer = 1;
							EventMask |= MU_TIMER2;
						}
						else
							make_frontwin(thewin);
				}
				else
					if (event -> ev_mb2return == 2 && !ob_isstate(Menu, MENU_ETAT, DISABLED))	/* si on n'est pas en MODAL */
					/* double clic et c'est pas une fenàtre Ö nous */
						wind_set(wind, WF_TOP, wind);
			}
		}
		else
		{
			if (event -> ev_mmobutton == 2 && !ob_isstate(Menu, MENU_ETAT, DISABLED))	/* si on n'est pas en MODAL */
				cycle_window();

			EventMask &= ~MU_TIMER2;
		}

	/*
		il faut ajouter 256 au nombre de clics pour inverser la
		signification de l'attente (2, 3, 0) = attend toutes les touches
		relachÇes et (256+2, 3, 0) = attend au moins une touche enffoncÇe
	*/
		MaxClics = 256+4 - MaxClics;

		used |= MU_BUTTON2;
	}

	/* On entre/sort de la boåte ? */
	if (ev & MU_M2)
	{
		wind_update(BEG_UPDATE);	/* attend que le curseur sorte du menu et autre truc dans ce genre */
		Sens = Sens ? 0 : 1;
		graf_mouse(Sens ? POINT_HAND : ARROW, NULL);
		wind_update(END_UPDATE);

		EventMask &= ~MU_TIMER2;

		used |= MU_M2;
	}

	return used;
} /* Messag */

/****************************************************************
*																*
*							main								*
*	executes initialization code and the starts the application.*
*																*
****************************************************************/
int main(argc, argv)
	int argc;
	char *argv[];
{
	/* Resource-File laden und Bibliothek sowie AES und VDI initialisieren
	   MenÅ-Eintrag: "Zorg" (unter MTOS)
	   XAcc-Name:    "EnhancedGEM\0XDSC\01GEM-Library\0"
	   AV-Name:      "EXAMPLE"
	   keine spezielle AV/VA/XAcc-Nachrichtenauswertung
	*/
	switch (open_rsc((int)(Kbshift(FAIL) & (1<<3)) ? ENGLISH_RESSOURCE_FILE : FRENCH_RESSOURCE_FILE, "Zorg " VERSION, "  Zorg " VERSION, "Zorg " VERSION,"ZORG", 0, 0, 0))
	{
		/* Resource-Datei konnte nicht geladen werden */
		case FAIL:
			my_alert(1, FAIL, X_ICN_INFO, "|Resource-File not found or not enough memory!", NULL);
			break;

		/* Fehler wÑhrend der Inititialisierung von AES/VDI */
		case FALSE:
			my_alert(1, FAIL, X_ICN_INFO, "|Couldn't open workstation!", NULL);
			break;
	
		/* Äa roule */
		case TRUE:
		{
			/* wind_update(BEG_UPDATE/END_UPDATE)-Klammerung fÅr Accessories
			   wÑhrend der Initialisierung */
			wind_update(BEG_UPDATE);

			{
				int x, y, w, h;

				wind_get(0, WF_WORKXYWH, &x, &y, &w, &h);
				if (w < 640)
				{
					my_alert(1, FAIL, X_ICN_STOP, Messages(MAIN_7), NULL);
					close_rsc(TRUE, -1);
				}
			}

			/* Resource (ObjektbÑume) initialisieren */
			init_resources();

			/* Erstellungsdatum und Versionsnummer im Informationsdialog setzen */
			ob_set_text(Dialog[PRESENTATION].tree, DATE_TXT, __DATE__);
			strcpy(ob_get_text(Dialog[PRESENTATION].tree, VERSION_TEXT, FALSE)+8, VERSION);
#ifdef TEST_VERSION
			ob_set_text(Dialog[PRESENTATION].tree, REGISTRED_TEXT, TEST_VERSION_TEXT);
#else
/*			ob_set_text(Dialog[PRESENTATION].tree, REGISTRED_TEXT, &Registred);*/
#endif

			/* Routinen zur Ereignisauswertung anmelden */
			Event_Handler(InitMsg, Messag);

			/* Dialog-Optionen setzen, u.a. Hintergrundbedienung von
			  Fensterdialogen u. TastendrÅcke an Dialog unter Mauszeiger,
			  Return selektiert DEFAULT-Objekt bei letztem Eingabefeld,
			  Fliegen/Verschieben von Dialogen durch Anklicken eines nicht
			  selektierbaren Objekts */
			dial_options(TRUE,	/* round */
				TRUE,		/* niceline */
				FALSE,		/* standard */
				RETURN_DEFAULT,	/* return_default */
				ALWAYS_BACK,	/* background */
				TRUE	,	/* nonselectable */
				KEY_STD,	/* always_keys */
				FALSE,		/* toMouse */
				TRUE,		/* clipboard */
				3);			/* hz */

			/* Titel-Optionen setzen */
			title_options(FALSE, /* mode */
				RED,	/* color */
				FALSE);	/* size */

			/* automatischen 3D-Look bei Eingabefeldern ausschalten, weiûer
			   Hintergrund im Hilfe-Dialog */
			dial_colors(7, /* dial_pattern:   Hintergrundmuster des Dialogs (0-7) */
				FAIL, 	/* dial_color:     Hintergrundfarbe des Dialogs */
				BLACK,	/* dial_frame:     Farbe des Dialograhmens */
				RED,	/* hotkey:         Farbe des Hotkey-Unterstrichs */
				RED,	/* alert:          Farbe des Alert-Icons */
				GREEN,	/* cycle_button:   Cycle-Button-Farbe */
				GREEN,	/* check_box:      Checkbox-Farbe */
				GREEN,	/* radio_button:   Radio-Button-Farbe */
				BLACK,	/* arrow:          Slider-Arrow-Farbe */
				WHITE,	/* cycle_backgrnd: Cycle-Button-Hintergrundfarbe */
				FAIL,	/* check_backgrnd: Checkbox-Hintergrundfarbe */
				FAIL,	/* radio_backgrnd: Radio-Button-Hintergrundfarbe */
				FAIL,	/* arrow_backgrnd: Slider-Arrow-Hintergrundfarbe */
				FALSE,	/* edit_3d */
				TRUE);	/* draw_3d */

            /* HÑkchen als Image fÅr Check-Boxen */
			check_image(5, NULL);

			/* on peut utilise WM_BOTTOM ? */
			{
				int a1, a2;

				if ((appl_xgetinfo(11, &a1, &a2, &a2, &a2) != 0) && (a1 & (1<<6)))
					BottomIsMeaningful = TRUE;
			}

			/* initialise le menu */
			init_menu();

			/* Pull-Down-MenÅ anmelden */
			menu_install(Menu, TRUE);

			/* les raccourcis EGem */
			{
				MITEM dummy = {0, 0, 0, 0};

				MenuItems(&dummy, &dummy, &dummy, &dummy, &dummy, &dummy, &dummy, &dummy, &dummy, NULL, 0);
			}

			/* le menu n'est pas encore utilisable */
			menu_enable(FALSE);

			/* Initialise le bureau */
			init_desk(TRUE);

			/* Lecture de la config */
			if (read_config())
				shutdown(FALSE);

			/* Create the Initial window */
			Firstwindow = new_window(SIZER | MOVER | FULLER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE, "Ze ORGanizer " __DATE__, NULL, textproc, TEXT, 0);
			if (Firstwindow == NULL)
				shutdown(FALSE);

			make_frontwin(Firstwindow);

			/* crÇe une entrÇe de fenàtre pour le tampon */
			creer_tampon();
			if (Tampon == NULL)
				shutdown(FALSE);

			wind_update(END_UPDATE);

			MouseOff();
			rc_sc_clear(&Firstwindow -> win -> work);

			ajoute(Firstwindow, Messages(MAIN_1));
			ajoute(Firstwindow, Messages(MAIN_2));
			ajoute(Firstwindow, "");
			ajoute(Firstwindow, Messages(MAIN_3));
			ajoute(Firstwindow, Messages(MAIN_4));
			ajoute(Firstwindow, Messages(MAIN_5));
			ajoute(Firstwindow, "");
			ajoute(Firstwindow, Messages(MAIN_6));
			ajoute(Firstwindow, "");

			/* initialise le lecteur par dÇfaut */
			init_drive();

			for (; argc>1; argc--)
				really_open_file_other_fs(argv[argc-1]);

			/* ok pour la souris */
			MouseOn();

#ifdef TEST_VERSION
			if (Sound)
				Dosound(SharewareSound);
			my_alert(FAIL, FAIL, X_ICN_INFO, Messages(MAIN_8), NULL);
#else
			{
				int i;
				char *c = &Registred;

				for (i=0; i<30; i++)
					*c++ = ~*c;
			}
#endif

			if (multi && MultiWarning)
				my_alert(1, FAIL, X_ICN_INFO, Messages(MAIN_10), NULL);

			/* ok pour le menu, on y va */
			menu_enable(TRUE);

			/* on passe la fenàtre de devant devant pour bien initialiser le menu */
			{
				int top;

				wind_get(0, WF_TOP, &top);
				make_frontwin(findwindowptr(top));
			}

            /* Auf Ereignis (Nachrichten/TastendrÅcke) warten und dieses
               auswerten. In diesem Fall werden die benîtigten Events be-
               reits durch die Funktionen InitMsg() und Messag() gesetzt und
               ausgewertet. ZusÑtzlich kînnte man natÅrlich hier noch wei-
               tere Events angeben, die speziell ausgewertet werden, oder
               den Event_Handler abmelden und alle Ereignisse hier auswerten.
               Dann mÅûte man allerdings die Funktion Event_Multi in eine
               Endlosschleife integrieren */

			Event_Multi(NULL);	/* und los geht's */
		}
	}

	return 0;
} /* main */

/****************************************************************
*																*
*			Converti une touche en son code ASCII				*
*																*
****************************************************************/
int scantoascii(int keycode)
{
	static KEYTAB *kt = NULL;
	int scan;
	
	if (!kt)
		kt = Keytbl((void *)-1, (void *)-1, (void *)-1);

	if ((scan = keycode >> 8) == 0)	/* ScanCode == 0 -> Alternate et pavÇ numÇrique */
		return keycode & 0xFF;

	switch (scan)
	{
		case SCANESC:
		case SCANTAB:
		case SCANRET:
		case SCANDEL:
		case SCANBS:
		case SCANENTER:
			return 0;

		default:
			return kt -> unshift[scan];
	}
} /* scantoascii */
