/***************************/
/* GEMfunktionen fÅr DTE 2 */
/***************************/

#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include "GEM_INEX.H"
#include "WINDLIB.H"
#include "EASYFSEL.H"
#include "SCANCODE.H"
#include "DTE2.H"
#include "DTE2DEFS.H"
#include "DTE2GLBL.H"

/* globale Variablen */
int infox = -1;
int infoy = -1;
int geschwx = -1;
int geschwy = -1;
int schwerx = -1;
int schwery = -1;
int allgx = -1;
int allgy = -1;
int anlx = -1;
int anly = -1;

/* Funktionsprototypen */
void handle_menu(int msg[]);
void menu_tasten(int scan);
void highscore(boolean nur_zeigen);

extern void spielende(void);
extern boolean spiel_start(void);

/* Funktionen */
void handle_menu(int msg[])
{
	boolean neu;
	OBJECT *infobox;

	if(msg[0] == MN_SELECTED)
	{
		switch(msg[4])
		{
			case INFOA:
				rsrc_gaddr(0, PRGINFO, &infobox);
				Dosound(titelsnd);
				do_extdialog(infobox, &infox, &infoy, 0);
				Dosound(offsnd);
			break;
			case NEUESSPI:
				neu = TRUE;
				if(w_handle > -1)
				{
					if(form_alert(1, "[3][ Wollen Sie das aktuelle | Spiel abbrechen? ][ Ja | Nein ]") == 1)
						spielende();
					else
						neu = FALSE;
				}
				if(neu)
					spiel_start();
			break;
			case SPIELABB:
				if(w_handle > -1)
					if(form_alert(1, "[2][ Wollen Sie das Spiel | abbrechen? ][ Ja | Nein ]") == 1)
						spielende();
			break;
			case HIGHSCOR:
				highscore(TRUE);
			break;
			case PRGENDE:
				neu = TRUE;
				if(w_handle > -1)
				{
					if(form_alert(1, "[2][ Wollen Sie das Spiel | abbrechen? ][ Ja | Nein ]") == 1)
						spielende();
					else
						neu = FALSE;
				}
				if(neu)
					prgende = TRUE;
			break;
			case SCHWIERI:
				rsrc_gaddr(0, SCHWIERB, &infobox);
				einstell_sw_werd = 5 - (do_extdialog(infobox, &schwerx, &schwery, 0) - SCHWER1);
			break;
			case GESCHWIN:
				rsrc_gaddr(0, GESCHWIB, &infobox);
				einstell_timergeschw = (do_extdialog(infobox, &geschwx, &geschwy, 0) - GESCHWI1) * 20;
			break;
			case ALLGHELP:
				rsrc_gaddr(0, ALLGEMEI, &infobox);
				do_extdialog(infobox, &allgx, &allgy, 0);
			break;
			case ANLEITHE:
				rsrc_gaddr(0, SPIELANL, &infobox);
				do_extdialog(infobox, &anlx, &anly, 0);
			break;
		}
		menu_tnormal(hauptmenu, msg[3], 1);
	}
}

void menu_tasten(int scan)
{
	boolean neu;
	OBJECT *infobox;

	switch(scan)
	{
		case CNTRL_N:
			neu = TRUE;
			if(w_handle > -1)
			{
				if(form_alert(1, "[3][ Wollen Sie das aktuelle | Spiel abbrechen? ][ Ja | Nein ]") == 1)
					spielende();
				else
					neu = FALSE;
			}
			if(neu)
				spiel_start();
		break;
		case CNTRL_U:
			if(w_handle > -1)
				if(form_alert(1, "[2][ Wollen Sie das Spiel | abbrechen? ][ Ja | Nein ]") == 1)
					spielende();
		break;
		case CNTRL_Q:
			neu = TRUE;
			if(w_handle > -1)
			{
				if(form_alert(1, "[2][ Wollen Sie das Spiel | abbrechen? ][ Ja | Nein ]") == 1)
					spielende();
				else
					neu = FALSE;
			}
			if(neu)
				prgende = TRUE;
		break;
		case CNTRL_W:
			rsrc_gaddr(0, SCHWIERB, &infobox);
			einstell_sw_werd = 5 - (do_extdialog(infobox, &schwerx, &schwery, 0) - SCHWER1);
		break;
		case CNTRL_G:
			rsrc_gaddr(0, GESCHWIB, &infobox);
			einstell_timergeschw = (do_extdialog(infobox, &geschwx, &geschwy, 0) - GESCHWI1) * 20;
		break;
	}
}

void highscore(boolean nur_zeigen)
{
	FILE *datei;
	int i, pos, hpunkte[10];
	char hname[10][20], str[10];
	boolean eintrag = FALSE;
	OBJECT *tree;

	static int namex = -1;
	static int namey = -1;
	static int hiscrx = -1;
	static int hiscry = -1;

	datei = fopen("DTE2HISC.DAT", "rb");
	if(datei)
	{
		for(i = 0; i < 10; i++)
		{
			fread(&hpunkte[i], 2, 1, datei);
			fread(hname[i], 20, 1, datei);
		}
		fclose(datei);
	}
	else
	{
		for(i = 0; i < 10; i++)
		{
			hpunkte[i] = 20 - i * 2;
			strcpy(hname[i], "Irgendwer");
		}
	}

	if(!nur_zeigen)
	{
		pos = 0;
		while((spieler.punkte < hpunkte[pos]) && (pos < 10))
			pos++;
		if(pos < 10)
		{
			eintrag = TRUE;
			for(i = 8; i > pos - 1; i--)
			{
				hpunkte[i + 1] = hpunkte[i];
				strcpy(hname[i + 1], hname[i]);
			}
			hpunkte[pos] = spieler.punkte;
			rsrc_gaddr(0, NAMENEIN, &tree);
			strcpy(tree[NAMESTR].ob_spec.tedinfo->te_ptext, "");
			do_extdialog(tree, &namex, &namey, 0);
			strcpy(hname[pos], tree[NAMESTR].ob_spec.tedinfo->te_ptext);
		}

		if(eintrag)
		{
			datei = fopen("DTE2HISC.DAT", "wb");
			if(datei)
			{
				for(i = 0; i < 10; i++)
				{
					fwrite(&hpunkte[i], 2, 1, datei);
					fwrite(hname[i], 20, 1, datei);
				}
				fclose(datei);
			}
		}
	}

	rsrc_gaddr(0, HISCOREB, &tree);
	for(i = 0; i < 10; i++)
	{
		strcpy(tree[PUNKTE1 + i].ob_spec.tedinfo->te_ptext, itoa(hpunkte[i], str, 10));
		strcpy(tree[NAME1 + i].ob_spec.tedinfo->te_ptext, hname[i]);
	}
	Dosound(hiscore);
	if(!nur_zeigen && eintrag)
	{
		tree[PUNKTE1 + pos].ob_state = SELECTED;
		tree[NAME1 + pos].ob_state = SELECTED;
	}
	do_extdialog(tree, &hiscrx, &hiscry, 0);
	if(!nur_zeigen && eintrag)
	{
		tree[PUNKTE1 + pos].ob_state &= ~SELECTED;
		tree[NAME1 + pos].ob_state &= ~SELECTED;
	}
	Dosound(offsnd);
