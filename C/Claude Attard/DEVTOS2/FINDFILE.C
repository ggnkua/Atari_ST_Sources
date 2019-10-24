/*	FINDFILE : Recherche de fichiers
		FINDFILE.C : Module principal */

/* D‚finitions :																									*/
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include "findfile.h"
#include "ff_defs.h"
#include "ff_intrf.h"

#define RESSOURCE "FINDFILE.RSC"
#define NOTRSC "[3][ Le fichier FINDFILE.RSC| est introuvable !][ Quitter ]"
#define NB_TREE 9
#define B_SELEC 18
#define FILEAIDE "FINDFILE.HLP"
#define FILEPREF "FINDFILE.PRF"

#define CHOIXCHE 0
#define CHOIXFIL 1
#define CHOIXMOD 2

typedef struct posi {					/* Structure position formulaire */
	int x;
	int y;
} Posi;

typedef struct preferences {	/* Structure pour les pr‚f‚rences */
		/* Chemin */
	char filtre1 [12];		/* Filtres de recherche */
	char filtre2 [12];
	char filtre3 [12];
	int rech_lect;				/* Flag recherche par lecteurs */
	int lecteurs;					/* Masque de bits lecteurs */
	int rech_chem;				/* Flag recherche par chemin */
		/* Filtre */
	int f_date;						/* Flag filtre de date */
	int f_bornes;					/* 1, 2 ou 3 : Avant, AprŠs ou Entre */
	int f_arch;						/* Flag filtre bit d'archive */
	int f_on;							/* 1 ou 2 : Oui ou Non */
	int f_etat;						/* Flag filtre ‚tat */
	int f_lect;						/* 1 ou 2 : Lect-Ecri ou Lect seule */
	int f_hide;						/* Flag chercher fichiers cach‚s */
		/* Modifs */
	int m_date;						/* Flag modif date */
	int m_newdate;				/* 1 ou 2 : Actuelle ou fixe */
	int m_arch;						/* Flag modif bit d'archive */
	int m_on;							/* 1 ou 2 : Mettre ou Annuler */
	int m_hide;						/* Flag modif fichiers cach‚s */
	int m_mc;							/* 1 ou 2 : Montrer ou Cacher */
	int m_etat;						/* Flag modif ‚tat */
	int m_lect;						/* 1 ou 2 : Lect-Ecri ou Lect seule */
		/* Liste */
	int p_liste;					/* ParamŠtres de liste : masque de bits */
		/* Menu */
	int mode;							/* 1, 2 ou 3 : Liste, Recherche, Effacement */
	int confirme;					/* Flag de confirmation */
		/* Bureau */
	Posi box;							/* BoŒte infos bureau */
		/* Fenˆtres */
	Posi p_rec;						/* Formulaire paramŠtres recherche */
	Posi p_lis;						/* Formulaire paramŠtres liste */
	GRECT liste;					/* Fenˆtre liste */
	GRECT help;						/* Fenˆtre d'aide */
} Preferences;

/* Variables globales :																					*/
int ap_id;													/* ID application */
int handle;													/* Handle VDI */
int ask = TRUE;											/* Demande confirmation */
int mode = MREC;										/* Mode de recherche */
int wcell, hcell;										/* Largeur et hauteur caractŠres */
int xb, yb, wb, hb;									/* Coordonn‚es bureau */
int objet;													/* Dernier objet cliqu‚ */
int buf[8];													/* Buffer d'‚v‚nements */
int mx, my, mk, kbd, key, clik;			/* Posi souris, clavier, nbre clics */
char ext[3][13];										/* Filtre de recherche */
char pat[128];											/* Chemin par d‚faut */
char chrec[128];										/* Chemin de recherche */
OBJECT *adrm, *adrb;								/* Adresse menu, bureau */
OBJECT *adrpr, *adrpl, *adrt, *adre;	/* Adresses par rech, par list, trouve, efface */
OBJECT *adru;												/* Adresses images de Userdefs */
DTA dtabuffer;											/* Tampon DTA */
typedef char dossiers[13];					/* Type dossier pour recursivit‚ */
Wind *win;													/* Travail avec les fenˆtres */
USERBLK *adr_usr;										/* Objets UserDefs */

/* Prototypage :																									*/
void main (void);
int initial (int nb_tree);
void lire_pref (void);
void save_pref (void);
void scan_disques (void);
void select_parrec (int *choix);
void select_parlis (void);
void select_menu (int *quit);
void print_liste (void);
int test_imp (void);
void deplace (void);
int open_wform (OBJECT *adr, int index, int title);
void aff_infos (void);
void open_vwork (void);
void formate (char *str);
void chercher (void);
int find (char *acces, int fhlis, int *draw);
void write_liste (int fh, char *file);
int ask_fil (char *nom, char *lec);
int ask_del (char *nom, char *lec);
void modif_file (char *nom, char *acces);
void fnom (char *name, char *str);
long exist (char *name, int att);
char *path (char *chemin);
int selector (char *chemin, char *ext, char *file, char *title);
void extension (char *filename, char *ext);
void litdate (char *dat, unsigned int fdate);
void convdate (char *date, unsigned int *fdate);

/* main () Initialisations et gestion :													*/
void main (void)
{
int evnt, quit = FALSE, i, choix, index;
char p[128], date[7];

	if (initial (NB_TREE))
	{
		path (pat);
		strcpy (chrec, pat);
		strcpy (p, chrec);
		if (strlen (p) > 30)
		{
			strcpy (p + 3, p + (strlen (p) - 27));
			p[1] = p[2] = '.';
		}
		strcpy (adrpr[C_CHEMIN].ob_spec.tedinfo->te_ptext, p);

		scan_disques ();
		dcl_wind (NB_WIND);
		Fsetdta (&dtabuffer);								/* Fixer adresse tampon DTA */
		choix = CHOIXCHE;
		litdate (date, ZERO);
		strcpy (adrpr[F_DAT1].ob_spec.tedinfo->te_ptext, date);
		strcpy (adrpr[F_DAT2].ob_spec.tedinfo->te_ptext, date);
		strcpy (adrpr[F_MDATCHOIX].ob_spec.tedinfo->te_ptext, date);
		if (NOT exist (FILEAIDE, ZERO))
			adrm[M_AIDE].ob_state |= DISABLED;
		lire_pref ();
		open_wform (adrpr, WPARREC, P_REC);	/* Ouvrir fenˆtre param. recherche */
		adrb[B_BOX].ob_flags &= ~HIDETREE;
	  form_dial (FMD_FINISH, 0, 0, 0, 0, xb, yb, wb, hb); /* Afficher le bureau */

		do
		{
			evnt = dialog ((MU_TIMER|MU_KEYBD|MU_BUTTON|MU_MESAG), adrb);
			if (evnt & MU_BUTTON)								/* Ev‚nement bouton */
			{
				if (buf[0] == EV_WFORM)						/* Si ‚venement formulaire en fenˆtre */
				{
					if (buf[3] == WPARREC)					/* Fenˆtre paramŠtres recherche */
						select_parrec (&choix);
					else if (buf[3] == WPARLIS)			/* Fenˆtre paramŠtres liste */
						select_parlis ();
				}
				else if (objet == B_MOVE);
					deplace ();
			}
			else if (evnt & MU_MESAG)						/* Ev‚nement de message */
			{
				if (buf[0] == MN_SELECTED)				/* Message de menu */
					select_menu (&quit);
				else if (buf[0] == WM_REDRAW)
					redraw ();
				else if ((buf[0] == WM_MOVED) || (buf[0] == WM_SIZED))
				{
					index = find_index (buf[3]);
					if (index > BLANK)
					{
		        wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
		        wind_get (buf[3], WF_CURRXYWH,
		        					&win[index].curr.g_x, &win[index].curr.g_y,
		        					&win[index].curr.g_w, &win[index].curr.g_h);
		        win[index].full = FALSE;
		        if (win[index].type == WTYPFORM)
		        {
			        wind_get (buf[3], WF_WORKXYWH,
			        					&win[index].cont.form->ob_x,
			        					&win[index].cont.form->ob_y,
			        					&win[index].cont.form->ob_width,
			        					&win[index].cont.form->ob_height);
		        }
		        else
		        	sliders (index);
	        }
				}
				else if (buf[0] == WM_FULLED)
					fulled ();
				else if (buf[0] == WM_CLOSED)
				{
					index = find_index (buf[3]);
					if (index > BLANK)
					{
						wind_close (buf[3]);
						wind_delete (buf[3]);
						win[index].hg = ZERO;
						win[index].full = FALSE;
						if (win[index].type == WTYPTEXT)
						{
							win[index].lin = win[index].col = ZERO;
							if (index == WLISTE)
								adrm[M_PRINTL].ob_state |= DISABLED;
						}
					}
				}
				else if (buf[0] == WM_ARROWED)
					arrow ();
				else if (buf[0] == WM_HSLID)
					hslider ();
				else if (buf[0] == WM_VSLID)
					vslider ();
				else if (buf[0] == WM_TOPPED)
					wind_set (buf[3], WF_TOP);
			}
		} while (NOT quit);
		wind_set (0, WF_NEWDESK, 0, 0); 		/* Rendre le bureau */
		for (i = ZERO ; i < NB_WIND ; i++)	/* Fermer et d‚truire les fenˆtres */
		{
			if (win[i].hg > ZERO)
			{
				wind_close (win[i].hg);
				wind_delete (win[i].hg);
			}
		}
	}
	free (adr_usr);				/* Lib‚rer m‚moire UserDefs */
	free (win);						/* Lib‚rer m‚moire fenˆtres */
	if (win[WHELP].cont.lignes)
	{
		free (win[WHELP].cont.lignes[0]);
		free (win[WHELP].cont.lignes);
	}
	if (win[WLISTE].cont.lignes)
	{
		free (win[WLISTE].cont.lignes[0]);
		free (win[WLISTE].cont.lignes);
	}
	v_clsvwk (handle);		/* Fermer station */
	appl_exit ();					/* Virer AES */
	exit (ZERO);					/* Quitter */
}

/* initial () Initialisations diverses :													*/
int initial (int nb_tree)
{
register int i, j, k = ZERO;
int nb_usr = ZERO, dummy;
OBJECT *adr;

	ap_id = appl_init (); 							/* D‚clarer l'application */
	open_vwork ();											/* Ouvrir station */
	if (rsrc_load (RESSOURCE) == ZERO)			/* Charger RSC */
	{
		form_alert (1, NOTRSC);
		return FALSE;
	}

	for (i = ZERO ; i < nb_tree ; i++)		/* Chercher et compter les UserDefs */
	{
		j = ZERO;
		do
		{
			rsrc_gaddr (R_TREE, i, &adr);
			if ((adr[j].ob_type >> 8) == B_SELEC)
				nb_usr++;
		} while (NOT (adr[j++].ob_flags & LASTOB));
	}
	adr_usr = (USERBLK *)malloc (sizeof (USERBLK) * nb_usr);	/* M‚moire UserDefs */
	for (i = ZERO ; i < nb_tree ; i++)		/* Faire pointer les UserDefs */
	{
		j = ZERO;
		do
		{
			rsrc_gaddr (R_TREE, i, &adr);
			if ((adr[j].ob_type >> 8) == B_SELEC)				/* Bouton coch‚ ou radio */
			{
				adr_usr[k].ub_code = userdf;
				adr_usr[k].ub_parm = (long) adr[j].ob_spec.free_string;
				adr[j].ob_spec.userblk = adr_usr + k;
				adr[j].ob_type = (adr[j].ob_type & 0xFF00) + G_USERDEF;									
				k++;
			}
			else if (adr[j].ob_flags & EDITABLE)							/* Si ‚ditable */
				strcpy (adr[j].ob_spec.tedinfo->te_ptext, "");	/* Vider champ */
		} while (NOT (adr[j++].ob_flags & LASTOB));
	}

		/* Adresses formulaires */
	rsrc_gaddr (R_TREE, MENUBAR, &adrm);
	rsrc_gaddr (R_TREE, BUREAU, &adrb);
	rsrc_gaddr (R_TREE, PARAMR, &adrpr);
	rsrc_gaddr (R_TREE, PARAML, &adrpl);
	rsrc_gaddr (R_TREE, TROUVE, &adrt);
	rsrc_gaddr (R_TREE, EFFACE, &adre);
	rsrc_gaddr (R_TREE, IMG_USER, &adru);

	adrpr[BOXFILTRE].ob_flags |= HIDETREE;				/* Cacher options filtre */
	adrpr[BOXFILTRE].ob_x = ZERO;									/* Repositionner */
	adrpr[BOXMODIF].ob_flags |= HIDETREE;					/* Cacher options modif */
	adrpr[BOXMODIF].ob_x = ZERO;									/* Repositionner */
	adrpr->ob_width = adrpr[BOXCHEMINS].ob_width;	/* Redimmensionner racine */

	form_center (adrpr, &dummy, &dummy, &dummy, &dummy);		/* Centrer formulaires */
	form_center (adrpl, &dummy, &dummy, &dummy, &dummy);
	form_center (adrt, &dummy, &dummy, &dummy, &dummy);
	form_center (adre, &dummy, &dummy, &dummy, &dummy);

  adrb->ob_x = xb;        /* Mettre le bureau aux bonnes dimensions */
  adrb->ob_y = yb;
  adrb->ob_width = wb;
  adrb->ob_height = hb;
  wind_set (0, WF_NEWDESK, adrb, 0);  /* Fixer le nouveau bureau */

  menu_bar (adrm, 1);           			/* Afficher le menu */
	graf_mouse (ARROW, ZERO);						/* Souris -> flŠche */
	return TRUE;
}

/* lire_pref () Lit les pr‚f‚rences :														*/
void lire_pref (void)
{
Preferences pref;
int fh, i, j;
char *str;

	graf_mouse (BUSYBEE, ZERO);
	fh = (int)Fopen (FILEPREF, FA_READONLY);
	if (fh >= ZERO)
	{
		Fread (fh, sizeof (pref), &pref);
		Fclose (fh);
	}
	else
	{
		graf_mouse (ARROW, ZERO);
		return;
	}

	strcpy (adrpr[C_FILTRE1].ob_spec.tedinfo->te_ptext, pref.filtre1);
	strcpy (adrpr[C_FILTRE2].ob_spec.tedinfo->te_ptext, pref.filtre2);
	strcpy (adrpr[C_FILTRE3].ob_spec.tedinfo->te_ptext, pref.filtre3);
	if (pref.rech_lect == TRUE)
		adrpr[C_RECLECT].ob_state |= SELECTED;
	else
		adrpr[C_RECLECT].ob_state &= ~SELECTED;
	for (i = LEC_A, j = 1 ; i <= LEC_P ; i++, j <<= 1)
	{
		if (pref.lecteurs & j)
			adrpr[i].ob_state |= SELECTED;
	}
	if (pref.rech_chem == TRUE)
		adrpr[C_RECCHEM].ob_state |= SELECTED;
	else
		adrpr[C_RECCHEM].ob_state &= ~SELECTED;

	if (pref.f_date == TRUE)
		adrpr[F_DATES].ob_state |= SELECTED;
	else
		adrpr[F_DATES].ob_state &= ~SELECTED;
	adrpr[F_DATAVANT].ob_state &= ~SELECTED;
	adrpr[F_DATAPRES].ob_state &= ~SELECTED;
	adrpr[F_DATENTRE].ob_state &= ~SELECTED;
	if (pref.f_bornes == 1)
		adrpr[F_DATAVANT].ob_state |= SELECTED;
	else if (pref.f_bornes == 2)
		adrpr[F_DATAPRES].ob_state |= SELECTED;
	else if (pref.f_bornes == 3)
		adrpr[F_DATENTRE].ob_state |= SELECTED;
	if (pref.f_arch == TRUE)
		adrpr[F_ARCH].ob_state |= SELECTED;
	else
		adrpr[F_ARCH].ob_state &= ~SELECTED;
	if (pref.f_on == 1)
	{
		adrpr[F_ARCHOUI].ob_state |= SELECTED;
		adrpr[F_ARCHNON].ob_state &= ~SELECTED;
	}
	else if (pref.f_on == 2)
	{
		adrpr[F_ARCHOUI].ob_state &= ~SELECTED;
		adrpr[F_ARCHNON].ob_state |= SELECTED;
	}
	if (pref.f_etat == TRUE)
		adrpr[F_ETAT].ob_state |= SELECTED;
	else
		adrpr[F_ETAT].ob_state &= ~SELECTED;
	if (pref.f_lect == 1)
	{
		adrpr[F_ETATLEC].ob_state |= SELECTED;
		adrpr[F_ETATLECECR].ob_state &= ~SELECTED;
	}
	else if (pref.f_lect == 2)
	{
		adrpr[F_ETATLEC].ob_state &= ~SELECTED;
		adrpr[F_ETATLECECR].ob_state |= SELECTED;
	}
	if (pref.f_hide == TRUE)
		adrpr[F_HIDE].ob_state |= SELECTED;
	else
		adrpr[F_HIDE].ob_state &= ~SELECTED;

	if (pref.m_date == TRUE)
		adrpr[F_MDAT].ob_state |= SELECTED;
	else
		adrpr[F_MDAT].ob_state &= ~SELECTED;
	if (pref.m_newdate == 1)
	{
		adrpr[F_MDATACT].ob_state |= SELECTED;
		adrpr[F_MDATFIXE].ob_state &= ~SELECTED;
	}
	else if (pref.m_newdate == 2)
	{
		adrpr[F_MDATACT].ob_state &= ~SELECTED;
		adrpr[F_MDATFIXE].ob_state |= SELECTED;
	}
	if (pref.m_arch == TRUE)
		adrpr[F_MARCH].ob_state |= SELECTED;
	else
		adrpr[F_MARCH].ob_state &= ~SELECTED;
	if (pref.m_on == 1)
	{
		adrpr[F_MARCHOUI].ob_state |= SELECTED;
		adrpr[F_MARCHNON].ob_state &= ~SELECTED;
	}
	else if (pref.m_on == 2)
	{
		adrpr[F_MARCHOUI].ob_state &= ~SELECTED;
		adrpr[F_MARCHNON].ob_state |= SELECTED;
	}
	if (pref.m_hide == TRUE)
		adrpr[F_MHIDE].ob_state |= SELECTED;
	else
		adrpr[F_MHIDE].ob_state &= ~SELECTED;
	if (pref.m_mc == 1)
	{
		adrpr[F_MUNHIDEFILE].ob_state |= SELECTED;
		adrpr[F_MHIDEFILE].ob_state &= ~SELECTED;
	}
	else if (pref.m_mc == 2)
	{
		adrpr[F_MUNHIDEFILE].ob_state &= ~SELECTED;
		adrpr[F_MHIDEFILE].ob_state |= SELECTED;
	}
	if (pref.m_etat == TRUE)
		adrpr[F_METAT].ob_state |= SELECTED;
	else
		adrpr[F_METAT].ob_state &= ~SELECTED;
	if (pref.m_lect == 1)
	{
		adrpr[F_MLECECR].ob_state |= SELECTED;
		adrpr[F_MLECSEU].ob_state &= ~SELECTED;
	}
	else if (pref.m_lect == 2)
	{
		adrpr[F_MLECECR].ob_state &= ~SELECTED;
		adrpr[F_MLECSEU].ob_state |= SELECTED;
	}

	for (i = PL_ARCH, j = 1 ; i <= PL_SIZE ; i++, j <<= 1)
	{
		if (pref.p_liste & j)
			adrpl[i].ob_state |= SELECTED;
	}
	adrm[M_MODELIST].ob_state &= ~CHECKED;
	adrm[M_MODERECH].ob_state &= ~CHECKED;
	adrm[M_MODEEFFA].ob_state &= ~CHECKED;
	if (pref.mode == 1)
	{
		adrm[M_MODELIST].ob_state |= CHECKED;
		adrm[M_ASK].ob_state |= DISABLED;
		mode = MLIS;
		rsrc_gaddr (R_FRSTR, LISTE, &str);
		str = *((char **)str);
		strcpy (adrb[B_MODE].ob_spec.free_string, str);
	}
	else if (pref.mode == 2)
	{
		adrm[M_MODERECH].ob_state |= CHECKED;
		mode = MREC;
		rsrc_gaddr (R_FRSTR, RECHERCHE, &str);
		str = *((char **)str);
		strcpy (adrb[B_MODE].ob_spec.free_string, str);
	}
	else if (pref.mode == 3)
	{
		adrm[M_MODEEFFA].ob_state |= CHECKED;
		mode = MEFF;
		rsrc_gaddr (R_FRSTR, EFFACEMENT, &str);
		str = *((char **)str);
		strcpy (adrb[B_MODE].ob_spec.free_string, str);
	}
	if (pref.confirme == TRUE)
	{
		adrm[M_ASK].ob_state |= CHECKED;
		rsrc_gaddr (R_FRSTR, OUI, &str);
	}
	else
	{
		adrm[M_ASK].ob_state &= ~CHECKED;
		rsrc_gaddr (R_FRSTR, NON, &str);
	}
	str = *((char **)str);
	strcpy (adrb[B_CONF].ob_spec.free_string, str);

	adrb[B_BOX].ob_x = pref.box.x;					/* Position boŒte du bureau */
	adrb[B_BOX].ob_y = pref.box.y;
	if (adrb[B_BOX].ob_x + adrb[B_BOX].ob_width > wb)
		adrb[B_BOX].ob_x = wb - adrb[B_BOX].ob_width;
	if (adrb[B_BOX].ob_y + adrb[B_BOX].ob_height > wb)
		adrb[B_BOX].ob_y = wb - adrb[B_BOX].ob_height;

	adrpr->ob_x = pref.p_rec.x;							/* Position formulaire recherche */
	adrpr->ob_y = pref.p_rec.y;
	if (adrpr->ob_x > wb)
		adrpr->ob_x = wb - 20;
	if (adrpr->ob_y > hb)
		adrpr->ob_y = hb - 20;
	adrpl->ob_x = pref.p_lis.x;							/* Position formulaire liste */
	adrpl->ob_y = pref.p_lis.y;
	if (adrpl->ob_x > wb)
		adrpl->ob_x = wb - 20;
	if (adrpl->ob_y > hb)
		adrpl->ob_y = hb - 20;

	win[WLISTE].curr.g_x = pref.liste.g_x;	/* Coord. fenˆtre liste */
	win[WLISTE].curr.g_y = pref.liste.g_y;
	win[WLISTE].curr.g_w = pref.liste.g_w;
	win[WLISTE].curr.g_h = pref.liste.g_h;
	if (win[WLISTE].curr.g_x > wb)
		win[WLISTE].curr.g_x = wb - 20;
	if (win[WLISTE].curr.g_y > hb)
		win[WLISTE].curr.g_y = hb - 20;
	win[WHELP].curr.g_x = pref.help.g_x;		/* Coord. fenˆtre d'aide */
	win[WHELP].curr.g_y = pref.help.g_y;
	win[WHELP].curr.g_w = pref.help.g_w;
	win[WHELP].curr.g_h = pref.help.g_h;
	if (win[WHELP].curr.g_x > wb)
		win[WHELP].curr.g_x = wb - 20;
	if (win[WHELP].curr.g_y > hb)
		win[WHELP].curr.g_y = hb - 20;
	graf_mouse (ARROW, ZERO);
}

/* save_pref () Sauve les pr‚f‚rences :													*/
void save_pref (void)
{
Preferences pref;
int fh, i, j;

	graf_mouse (BUSYBEE, ZERO);
	strcpy (pref.filtre1, adrpr[C_FILTRE1].ob_spec.tedinfo->te_ptext);
	strcpy (pref.filtre2, adrpr[C_FILTRE2].ob_spec.tedinfo->te_ptext);
	strcpy (pref.filtre3, adrpr[C_FILTRE3].ob_spec.tedinfo->te_ptext);
	pref.rech_lect = (adrpr[C_RECLECT].ob_state & SELECTED) ? TRUE : FALSE;
	pref.lecteurs = ZERO;
	for (i = LEC_A, j = 1 ; i <= LEC_P ; i++, j <<= 1)
	{
		if (adrpr[i].ob_state & SELECTED)
			pref.lecteurs |= j;
	}
	pref.rech_chem = (adrpr[C_RECCHEM].ob_state & SELECTED) ? TRUE : FALSE;

	pref.f_date = (adrpr[F_DATES].ob_state & SELECTED) ? TRUE : FALSE;
	if (adrpr[F_DATAVANT].ob_state & SELECTED)
		pref.f_bornes = 1;
	else if (adrpr[F_DATAPRES].ob_state & SELECTED)
		pref.f_bornes = 2;
	else if (adrpr[F_DATENTRE].ob_state & SELECTED)
		pref.f_bornes = 3;
	pref.f_arch = (adrpr[F_ARCH].ob_state & SELECTED) ? TRUE : FALSE;
	if (adrpr[F_ARCHOUI].ob_state & SELECTED)
		pref.f_on = 1;
	else if (adrpr[F_ARCHNON].ob_state & SELECTED)
		pref.f_on = 2;
	pref.f_etat = (adrpr[F_ETAT].ob_state & SELECTED) ? TRUE : FALSE;
	if (adrpr[F_ETATLEC].ob_state & SELECTED)
		pref.f_lect = 1;
	else if (adrpr[F_ETATLECECR].ob_state & SELECTED)
		pref.f_lect = 2;
	pref.f_hide = (adrpr[F_HIDE].ob_state & SELECTED) ? TRUE : FALSE;

	pref.m_date = (adrpr[F_MDAT].ob_state & SELECTED) ? TRUE : FALSE;
	if (adrpr[F_MDATACT].ob_state & SELECTED)
		pref.m_newdate = 1;
	else if (adrpr[F_MDATFIXE].ob_state & SELECTED)
		pref.m_newdate = 2;
	pref.m_arch = (adrpr[F_MARCH].ob_state & SELECTED) ? TRUE : FALSE;
	if (adrpr[F_MARCHOUI].ob_state & SELECTED)
		pref.m_on = 1;
	else if (adrpr[F_MARCHNON].ob_state & SELECTED)
		pref.m_on = 2;
	pref.m_hide = (adrpr[F_MHIDE].ob_state & SELECTED) ? TRUE : FALSE;
	if (adrpr[F_MUNHIDEFILE].ob_state & SELECTED)
		pref.m_mc = 1;
	else if (adrpr[F_MHIDEFILE].ob_state & SELECTED)
		pref.m_mc = 2;
	pref.m_etat = (adrpr[F_METAT].ob_state & SELECTED) ? TRUE : FALSE;
	if (adrpr[F_MLECECR].ob_state & SELECTED)
		pref.m_lect = 1;
	else if (adrpr[F_MLECSEU].ob_state & SELECTED)
		pref.m_lect = 2;

	pref.p_liste = ZERO;
	for (i = PL_ARCH, j = 1 ; i <= PL_SIZE ; i++, j <<= 1)
	{
		if (adrpl[i].ob_state & SELECTED)
			pref.p_liste |= j;
	}
	if (adrm[M_MODELIST].ob_state & CHECKED)
		pref.mode = 1;
	else if (adrm[M_MODERECH].ob_state & CHECKED)
		pref.mode = 2;
	else if (adrm[M_MODEEFFA].ob_state & CHECKED)
		pref.mode = 3;
	if (adrm[M_ASK].ob_state & CHECKED)
		pref.confirme = 1;

	pref.box.x = adrb[B_BOX].ob_x;					/* Position boŒte du bureau */
	pref.box.y = adrb[B_BOX].ob_y;

	pref.p_rec.x = adrpr->ob_x;							/* Position formulaire recherche */
	pref.p_rec.y = adrpr->ob_y;
	pref.p_lis.x = adrpl->ob_x;							/* Position formulaire liste */
	pref.p_lis.y = adrpl->ob_y;
	pref.liste.g_x = win[WLISTE].curr.g_x;	/* Coord. fenˆtre liste */
	pref.liste.g_y = win[WLISTE].curr.g_y;
	pref.liste.g_w = win[WLISTE].curr.g_w;
	pref.liste.g_h = win[WLISTE].curr.g_h;
	pref.help.g_x = win[WHELP].curr.g_x;		/* Coord. fenˆtre d'aide */
	pref.help.g_y = win[WHELP].curr.g_y;
	pref.help.g_w = win[WHELP].curr.g_w;
	pref.help.g_h = win[WHELP].curr.g_h;

	fh = (int)Fcreate (FILEPREF, ZERO);
	if (fh >= ZERO)
	{
		Fwrite (fh, sizeof (pref), &pref);
		Fclose (fh);
	}
	graf_mouse (ARROW, ZERO);
}

/* scan_disques () Scanner les disques pr‚sents :								*/
void scan_disques (void)
{
int k, i;
unsigned long map, bit;

	map = Drvmap ();														/* Lecteurs dispos */
	k = 2;																			/* A et B : toujours */
	for (bit = 4 ; bit <= 65536L ; bit *= 2)		/* Pour chaque bit */
	{
		if (map & bit)														/* Si lecteur */
			adrpr[k + LEC_A].ob_state &= ~DISABLED;	/* Activer le bouton */
		k++;																			/* Bouton suivant */
	}
	if (map == 3)																/* Si seulement A et B */
		adrpr[C_SUPC].ob_state |= DISABLED;				/* Virer bouton ">=C" */
	if (map > 3)																/* Si disque dur */
	{
		for (i = LEC_C ; i <= LEC_P ; i++)				/* Pour chaque bouton DD */
		{
			if (NOT (adrpr[i].ob_state & DISABLED))	/* Si actif */
				adrpr[i].ob_state |= SELECTED;				/* S‚lectionner */
		}
	}
}

/* select_parrec () GŠre fenˆtre paramŠtres recherche :					*/
void select_parrec (int *choix)
{
int i;
char p[128], fname[13] = {0}, *texte;

	switch (buf[4])								/* Selon l'objet */
	{
	case P_CHEMIN :
		if (NOT (*choix == CHOIXCHE))
		{
			adrpr[BOXCHEMINS].ob_flags &= ~HIDETREE;
			adrpr[BOXFILTRE].ob_flags |= HIDETREE;
			adrpr[BOXMODIF].ob_flags |= HIDETREE;
			draw_object (WPARREC, BOXCHEMINS);
			*choix = CHOIXCHE;
		}
		break;
	case P_FILTRE :
		if (NOT (*choix == CHOIXFIL))
		{
			adrpr[BOXFILTRE].ob_flags &= ~HIDETREE;
			adrpr[BOXCHEMINS].ob_flags |= HIDETREE;
			adrpr[BOXMODIF].ob_flags |= HIDETREE;
			draw_object (WPARREC, BOXFILTRE);
			*choix = CHOIXFIL;
		}
		break;
	case P_MODIF :
		if (NOT (*choix == CHOIXMOD))
		{
			adrpr[BOXMODIF].ob_flags &= ~HIDETREE;
			adrpr[BOXCHEMINS].ob_flags |= HIDETREE;
			adrpr[BOXFILTRE].ob_flags |= HIDETREE;
			draw_object (WPARREC, BOXMODIF);
			*choix = CHOIXMOD;
		}
		break;
	case C_RECLECT :
		adrpr[C_RECCHEM].ob_state ^= SELECTED;
		draw_object (WPARREC, C_RECCHEM);
		break;
	case C_RECCHEM :
		adrpr[C_RECLECT].ob_state ^= SELECTED;
		draw_object (WPARREC, C_RECLECT);
		break;
	case C_TOUS :															/* TOUS */
		for (i = LEC_A ; i <= LEC_P ; i++)				/* Pour chaque bouton */
		{
			if (NOT (adrpr[i].ob_state & DISABLED))	/* Si actif */
				adrpr[i].ob_state |= SELECTED;					/* S‚lectionner */
		}
		adrpr[C_TOUS].ob_state &= ~SELECTED;			/* D‚selectionner */
		draw_object (WPARREC, C_TOUS);						/* Redessiner */
		draw_object (WPARREC, LECTEURS);
		break;
	case C_AUCUN :														/* AUCUN */
		for (i = LEC_A ; i <= LEC_P ; i++)				/* Pour chaque bouton */
		{
			if (NOT (adrpr[i].ob_state & DISABLED))	/* Si actif */
				adrpr[i].ob_state &= ~SELECTED;				/* D‚s‚lectionner */
		}
		adrpr[C_AUCUN].ob_state &= ~SELECTED;
		draw_object (WPARREC, C_AUCUN);
		draw_object (WPARREC, LECTEURS);
		break;
	case C_SUPC :															/* >=C */
		adrpr[LEC_A].ob_state &= ~SELECTED;				/* D‚s‚lectionner A */
		adrpr[LEC_B].ob_state &= ~SELECTED;				/* D‚s‚lectionner B */
		for (i = LEC_C ; i <= LEC_P ; i++)				/* Pour chaque bouton DD */
		{
			if (NOT (adrpr[i].ob_state & DISABLED))	/* Si actif */
				adrpr[i].ob_state |= SELECTED;				/* S‚lectionner */
		}
		adrpr[C_SUPC].ob_state &= ~SELECTED;
		draw_object (WPARREC, C_SUPC);
		draw_object (WPARREC, LECTEURS);
		break;
	case C_CHEMIN :
		strcpy (p, chrec);
		rsrc_gaddr (R_FRSTR, CHOIXCHEM, &texte);	/* Adr chaŒne pointeur sur pointeur */
		texte = *((char **)texte);								/* Pointeur sur le texte */
		if (selector (p, "*.*", fname, texte))
		{
			strcpy (chrec, p);
			if (strlen (p) > 30)
			{
				strcpy (p + 3, p + (strlen (p) - 27));
				p[1] = p[2] = '.';
			}
			strcpy (adrpr[C_CHEMIN].ob_spec.tedinfo->te_ptext, p);
			draw_object (WPARREC, C_CHEMIN);
		}
		break;
	case F_DATAVANT :
	case F_DATAPRES :
		adrpr[F_DAT2].ob_state |= DISABLED;
		draw_object (WPARREC, F_DAT2);
		break;
	case F_DATENTRE :
		adrpr[F_DAT2].ob_state &= ~DISABLED;
		draw_object (WPARREC, F_DAT2);
		break;
	}
}

/* select_parlis () GŠre fenˆtre paramŠtres liste :							*/
void select_parlis (void)
{
	if (buf[4] == PL_TOUS)					/* Si "Tous" */
	{
		adrpl[PL_ARCH].ob_state |= SELECTED;
		adrpl[PL_HIDE].ob_state |= SELECTED;
		adrpl[PL_ETAT].ob_state |= SELECTED;
		adrpl[PL_DATE].ob_state |= SELECTED;
		adrpl[PL_SIZE].ob_state |= SELECTED;
		adrpl[PL_TOUS].ob_state &= ~SELECTED;
		draw_object (WPARLIS, ROOT);
	}
	else if (buf[4] == PL_AUCUN)		/* Si "Aucun" */
	{
		adrpl[PL_ARCH].ob_state &= ~SELECTED;
		adrpl[PL_HIDE].ob_state &= ~SELECTED;
		adrpl[PL_ETAT].ob_state &= ~SELECTED;
		adrpl[PL_DATE].ob_state &= ~SELECTED;
		adrpl[PL_SIZE].ob_state &= ~SELECTED;
		adrpl[PL_AUCUN].ob_state &= ~SELECTED;
		draw_object (WPARLIS, ROOT);
	}
}

/* select_menu () GŠre ‚v‚nements menu :													*/
void select_menu (int *quit)
{
int x, y, old_buf3;
char *str, ch[128], fname[13] = {0}, *texte;

	old_buf3 = buf[3];
	switch (buf[4])
	{
	case M_INFOS :
		aff_infos ();
		break;
	case M_OPEN :
		strcpy (ch, pat);
		rsrc_gaddr (R_FRSTR, CHOIXLIS, &texte);	/* Adr chaŒne pointeur sur pointeur */
		texte = *((char **)texte);							/* Pointeur sur le texte */
		if ((selector (ch, "*.LIS", fname, texte)) && (strlen (fname)))
		{
			strcat (ch, fname);
			open_file (ch, WLISTE);
		}
		break;
	case M_PRINTL :
		print_liste ();
		break;
	case M_AIDE :
		open_file (FILEAIDE, WHELP);
		break;
	case M_PREF :
		save_pref ();
		break;
	case M_QUITTER :
		*quit = TRUE;
		break;
	case M_MODELIST :
		adrm[M_MODELIST].ob_state |= CHECKED;
		adrm[M_MODERECH].ob_state &= ~CHECKED;
		adrm[M_MODEEFFA].ob_state &= ~CHECKED;
		adrm[M_ASK].ob_state |= DISABLED;
		mode = MLIS;
		rsrc_gaddr (R_FRSTR, LISTE, &str);
		str = *((char **)str);
		strcpy (adrb[B_MODE].ob_spec.free_string, str);
		objc_offset (adrb, B_MODE, &x, &y);
		form_dial (FMD_FINISH, ZERO, ZERO, ZERO, ZERO,
							 x, y, adrb[B_MODE].ob_width, adrb[B_MODE].ob_height);
		break;
	case M_MODERECH :
		adrm[M_MODERECH].ob_state |= CHECKED;
		adrm[M_MODELIST].ob_state &= ~CHECKED;
		adrm[M_MODEEFFA].ob_state &= ~CHECKED;
		adrm[M_ASK].ob_state &= ~DISABLED;
		mode = MREC;
		rsrc_gaddr (R_FRSTR, RECHERCHE, &str);
		str = *((char **)str);
		strcpy (adrb[B_MODE].ob_spec.free_string, str);
		objc_offset (adrb, B_MODE, &x, &y);
		form_dial (FMD_FINISH, ZERO, ZERO, ZERO, ZERO,
							 x, y, adrb[B_MODE].ob_width, adrb[B_MODE].ob_height);
		break;
	case M_MODEEFFA :
		adrm[M_MODEEFFA].ob_state |= CHECKED;
		adrm[M_MODELIST].ob_state &= ~CHECKED;
		adrm[M_MODERECH].ob_state &= ~CHECKED;
		adrm[M_ASK].ob_state &= ~DISABLED;
		mode = MEFF;
		rsrc_gaddr (R_FRSTR, EFFACEMENT, &str);
		str = *((char **)str);
		strcpy (adrb[B_MODE].ob_spec.free_string, str);
		objc_offset (adrb, B_MODE, &x, &y);
		form_dial (FMD_FINISH, ZERO, ZERO, ZERO, ZERO,
							 x, y, adrb[B_MODE].ob_width, adrb[B_MODE].ob_height);
		break;
	case M_ASK :
		adrm[M_ASK].ob_state ^= CHECKED;
		if (adrm[M_ASK].ob_state & CHECKED)
			ask = TRUE;
		else
			ask = FALSE;
		if (ask)
			rsrc_gaddr (R_FRSTR, OUI, &str);
		else
			rsrc_gaddr (R_FRSTR, NON, &str);
		str = *((char **)str);
		strcpy (adrb[B_CONF].ob_spec.free_string, str);
		objc_offset (adrb, B_CONF, &x, &y);
		form_dial (FMD_FINISH, ZERO, ZERO, ZERO, ZERO,
							 x, y, adrb[B_CONF].ob_width, adrb[B_CONF].ob_height);
		break;
	case M_PARAMREC :
		open_wform (adrpr, WPARREC, P_REC);	/* Ouvrir fenˆtre param. recherche */
		break;
	case M_PARAMLIS :
		open_wform (adrpl, WPARLIS, P_LIS);	/* Ouvrir fenˆtre param. liste */
		break;
	case M_CHERCHER :
		chercher ();
		break;
	}
	menu_tnormal (adrm, old_buf3, TRUE);
}

/* print_liste () Imprime la liste courante:											*/
void print_liste (void)
{
int i, j, len;

	if (win[WLISTE].hg > ZERO)
	{
		if (test_imp () == TRUE)
		{
			graf_mouse (BUSYBEE, ZERO);
			i = ZERO;
			while (i < win[WLISTE].nbrel)
			{
				len = (int)strlen (win[WLISTE].cont.lignes[i]);
				for (j = ZERO ; j < len ; j++)
					Cprnout ((int)win[WLISTE].cont.lignes[i][j]);
				Cprnout ('\n');		/* Saut de ligne */
				Cprnout ('\r');
				i++;
			}
			Cprnout ('\f');		/* Saut de page */
			graf_mouse (ARROW, ZERO);
		}
	}
}

/* test_imp () Teste si imprimante prˆte :												*/
int test_imp (void)
`{
int r = TRUE;
char *alrt;

	rsrc_gaddr (R_FRSTR, NOT_IMP, &alrt);		/* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);								/* Pointeur sur le texte */
	while (Cprnos () == FALSE && r == TRUE) /* V‚rifier imprimante prˆte */
	{
		if (form_alert (2, alrt) == 1)				/* Gueuler au besoin */
			r = FALSE;
	}
	return r;
}

/* deplace () D‚place boŒte sur le bureau :											*/
void deplace (void)
{
int old_x, old_y, new_x, new_y, dummy;

	evnt_timer (70, 0);		/* D‚lai */
	graf_mkstate (&dummy, &dummy, &mk, &dummy);
	if (mk == 1)
	{													/* Ic“ne encore cliqu‚e -> d‚placement */
		old_x = adrb[B_BOX].ob_x;
		old_y = adrb[B_BOX].ob_y;
		graf_dragbox (adrb[B_BOX].ob_width, adrb[B_BOX].ob_height,
									adrb[B_BOX].ob_x + xb, adrb[B_BOX].ob_y + yb,
									xb, yb, wb, hb, &new_x, &new_y);
		adrb[B_BOX].ob_x = new_x - xb;
		adrb[B_BOX].ob_y = new_y - yb;
		form_dial (FMD_FINISH, 0, 0, 0, 0, old_x + xb, old_y + yb,
							 adrb[B_BOX].ob_width, adrb[B_BOX].ob_height);
		form_dial (FMD_FINISH, 0, 0, 0, 0,
							 adrb[B_BOX].ob_x + xb, adrb[B_BOX].ob_y + yb,
							 adrb[B_BOX].ob_width, adrb[B_BOX].ob_height);
	}
}

/* open_wform () Ouvrir fenˆtre formulaire :											*/
int open_wform (OBJECT *adr, int index, int title)
{
int xf, yf, wf, hf, attr = (NAME|MOVER|CLOSER);
char *str;

	if (win[index].hg > ZERO)
		wind_set (win[index].hg, WF_TOP);
	else
	{
		wind_calc (WC_BORDER, attr,
							 adr->ob_x, adr->ob_y, adr->ob_width, adr->ob_height,
							 &xf, &yf, &wf, &hf);
		win[index].hg = wind_create (attr, xf, yf, wf, hf);
		if (win[index].hg)
		{
			win[index].attr = attr;
			win[index].type = WTYPFORM;
			win[index].curr.g_x = xf;
			win[index].curr.g_y = yf;
			win[index].curr.g_w = wf;
			win[index].curr.g_h = hf;
			win[index].cont.form = adr;
			rsrc_gaddr (R_FRSTR, title, &str);	/* Adr chaŒne pointeur sur pointeur */
			win[index].title = *((char **)str);	/* Pointeur sur le texte */
      wind_set (win[index].hg, WF_NAME, win[index].title); /* Titre fenˆtre */
			wind_open (win[index].hg, xf, yf, wf, hf);
		}
	}
	return win[index].hg;
}

/* aff_infos () Affiche boŒte d'infos :													*/
void aff_infos (void)
{
int x, y, w, h, ob;
OBJECT *adr;

	rsrc_gaddr (R_TREE, INFORM, &adr);		/* Prendre adresse */
	strcpy (adr[DATEVER].ob_spec.tedinfo->te_ptext, DATEVERSION);
	form_center (adr, &x, &y, &w, &h);		/* Centrer formulaire */
	wind_update (BEG_MCTRL);							/* Bloquer menu */
	objc_draw (adr, 0, MAX_DEPTH, x, y, w, h);					/* Affichage par le GEM */
	ob = form_do (adr, BLANK);													/* Gestion par le GEM */
	objc_change (adr, ob, 0, x, y, w, h, NONE, FALSE);	/* R‚inverser bouton */
	wind_update (END_MCTRL);							/* D‚bloquer menu */
	form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h);			/* Effacer formulaire */
}

/* open_vwork () Ouvrir station travail virtuelle :							*/
void open_vwork (void)
{
int i, a, b, ecart[5], effets[3], hc, dummy;

	for (i = 1 ; i < 10 ; _VDIParBlk.intin[i++] = 1);	/* R‚glages par d‚faut */
	_VDIParBlk.intin[10] = 2;													/* Coordonn‚es RC */
	_VDIParBlk.intin[0] = Getrez () + 2;
	handle = graf_handle (&a, &b, &i, &i);						/* Handle station ‚cran */
	v_opnvwk (_VDIParBlk.intin, &handle, _VDIParBlk.intout);	/* Ouvrir station */

	wind_get (ZERO, WF_WORKXYWH, &xb, &yb, &wb, &hb); /* Dimensions bureau */
	vqt_fontinfo (handle, &dummy, &dummy, ecart, &dummy, effets);
	hc = ecart[4];
	vst_height (handle, hc, &dummy, &dummy, &wcell, &hcell);
}

/* formate () Formate une chaŒne nom de fichier :								*/
void formate (char *str)
{
int i = ZERO, k = 1;
char temp[13];

		/* Avant : "NOM    EXT" AprŠs : "NOM.EXT" */
	if (strlen (str) > 8)
	{
		if (NOT (strchr (str, (int)' ')))
		{
			strcpy (temp, str);
			temp[8] = '.';
			strcpy (temp + 9, str + 8);
		}
		else
		{
			while (str[i] != ' ')
			{
				temp[i] = str[i];
				i++;
				k++;
			}
			temp[i] = '.';
			while (str[i] == ' ')
				i++;
			strcpy (temp + k, str + i);
		}
		strcpy (str, temp);
	}
}

/* chercher () Chercher fichiers :																*/
void chercher (void)
{
int i, result = TRUE, fh, draw = ZERO, x, y, w, h;
char p[] = {0, ':', '\\', 0},
		 ch[128], fname[13] = {0}, *texte, lec[2] = {ZERO, ZERO};
OBJECT *adrrec;

	if (mode == MLIS)												/* Si mode liste */
	{
		rsrc_gaddr (R_FRSTR, CHOIXLIS, &texte);	/* Adr chaŒne pointeur sur pointeur */
		texte = *((char **)texte);							/* Pointeur sur le texte */
		strcpy (ch, pat);
		if ((selector (ch, "*.LIS", fname, texte)) && (strlen (fname)))
		{
			extension (fname, ".LIS");
			strcat (ch, fname);
			fh = (int)Fcreate (ch, ZERO);
		}
		else
			return;
	}

	strcpy (ext[0], adrpr[C_FILTRE1].ob_spec.tedinfo->te_ptext);
	strcpy (ext[1], adrpr[C_FILTRE2].ob_spec.tedinfo->te_ptext);
	strcpy (ext[2], adrpr[C_FILTRE3].ob_spec.tedinfo->te_ptext);
	if ((ext[0][0] == '\0') && (ext[1][0] == '\0') && (ext[2][0] == '\0'))
		return;
	formate (ext[0]);
	formate (ext[1]);
	formate (ext[2]);
	graf_mouse (BUSYBEE, ZERO);
	if (adrpr[C_RECLECT].ob_state & SELECTED)		/* Si recherche par lecteurs */
	{
		rsrc_gaddr (R_TREE, REC_LECT, &adrrec);		/* Adresse infos recherche */
		form_center (adrrec, &x, &y, &w, &h);			/* Le centrer */
		y = adrrec->ob_y = yb + hb - adrrec->ob_height - 2;	/* En bas du bureau */
		strcpy (adrrec[RL_LEC].ob_spec.tedinfo->te_ptext, "");	/* Pas de lecteur */
		objc_draw (adrrec, ROOT, MAX_DEPTH, x, y, w, h);	/* Dessiner */
		for (i = LEC_A ; i <= LEC_P ; i++)		/* Pour chaque lecteur */
		{
			if ((adrpr[i].ob_state & SELECTED) && (result))	/* Si s‚lectionn‚ */
			{
				lec[0] = (i - LEC_A + 'A');				/* Lettre du lecteur */
				strcpy (adrrec[RL_LEC].ob_spec.tedinfo->te_ptext, lec);	/* Copier */
				objc_draw (adrrec, RL_LEC, 1, x, y, w, h);							/* Dessiner */
				p[0] = i - LEC_A + 'A';						/* Constituer chemin */
				result = find (p, fh, &draw);			/* Chercher */
			}
		}
		form_dial (FMD_FINISH, x, y, w, h, x, y, w, h);	/* Effacer infos lecteur */
	}
	else																				/* Si recherche par chemin */
	{
		result = find (chrec, fh, &draw);
	}
	graf_mouse (ARROW, ZERO);
	if (mode == MLIS)
	{
		Fclose (fh);
		open_file (ch, WLISTE);
	}

	if (draw == 1)
	{
		form_dial (FMD_FINISH, ZERO, ZERO, ZERO, ZERO,
							 adrt->ob_x - 3, adrt->ob_y - 3, adrt->ob_width + 6, adrt->ob_height + 6);
		adrt[T_DELETE].ob_flags &= ~DEFAULT;
		adrt[T_MODIF].ob_flags &= ~DEFAULT;
		adrt[T_SKIP].ob_flags &= ~DEFAULT;
	}
	else if (draw == 2)
	{
		form_dial (FMD_FINISH, ZERO, ZERO, ZERO, ZERO,
							 adre->ob_x - 3, adre->ob_y - 3, adre->ob_width + 6, adre->ob_height + 6);
		adre[E_DELETE].ob_flags &= ~DEFAULT;
		adre[E_SKIP].ob_flags &= ~DEFAULT;
	}
}

/* find () Cherche dans ce chemin d'accŠs :											*/
int find (char *acces, int fhlis, int *draw)
{
int ret, result, del, k = ZERO, i, fh, ok, filtre;
unsigned int vdate1, vdate2;
char chemin[128], suite[128], fichier[128], temp[128], sdate1[7], sdate2[7];
DOSTIME fdate;
dossiers *fold;

	Fsetdta (&dtabuffer);								/* Fixer adresse tampon DTA */
	for (i = ZERO ; i < 3 ; i++)
	{
		if (strlen (ext[i]))
		{
			strcpy (chemin, acces);							/* Recherche des extensions */
			strcat (chemin, ext[i]);
			filtre = FA_SUBDIR;									/* Filtre de recherche */
			if (adrpr[F_HIDE].ob_state & SELECTED)	/* Si aussi fichiers cach‚s */
				filtre |= FA_HIDDEN;
				/* Lecture et convertion dates de filtre */
			strcpy (sdate1, adrpr[F_DAT1].ob_spec.tedinfo->te_ptext);
			convdate (sdate1, &vdate1);
			strcpy (sdate2, adrpr[F_DAT2].ob_spec.tedinfo->te_ptext);
			convdate (sdate2, &vdate2);
			ret = Fsfirst (chemin, filtre);			/* Premier fichier ou dossier */
			while (ret >= 0)										/* Tant qu'il y en a un, on boucle */
			{
				ok = TRUE;
				if (NOT (dtabuffer.d_attrib & FA_SUBDIR))	/* Si ce n'est pas un dossier */
				{
					if ((NOT (adrpr[F_HIDE].ob_state & SELECTED)) &&
							((dtabuffer.d_attrib & FA_ARCHIVE) && (dtabuffer.d_attrib & FA_HIDDEN)))
						ok = FALSE;
					if ((ok) && (adrpr[F_DATES].ob_state & SELECTED))	/* Si filtre date */
					{
						strcpy (temp, acces);
						strcat (temp, dtabuffer.d_fname);
						fh = (int)Fopen (temp, FO_READ);
						Fdatime (&fdate, fh, FALSE);			/* Lire date fichier */
						Fclose (fh);
						if (adrpr[F_DATAVANT].ob_state & SELECTED)
						{
							if (fdate.date >= vdate1)
								ok = FALSE;
						}
						else if (adrpr[F_DATAPRES].ob_state & SELECTED)
						{
							if (fdate.date <= vdate1)
								ok = FALSE;
						}
						else if (adrpr[F_DATENTRE].ob_state & SELECTED)
						{
							if ((fdate.date <= vdate1) || (fdate.date >= vdate2))
								ok = FALSE;
						}
					}
					if ((ok) && (adrpr[F_ARCH].ob_state & SELECTED))	/* Si filtre archive */
					{
						if (adrpr[F_ARCHOUI].ob_state & SELECTED)
						{
							if (NOT (dtabuffer.d_attrib & FA_ARCHIVE))
								ok = FALSE;
						}
						else if (adrpr[F_ARCHNON].ob_state & SELECTED)
						{
							if (dtabuffer.d_attrib & FA_ARCHIVE)
								ok = FALSE;
						}
					}
					if ((ok) && (adrpr[F_ETAT].ob_state & SELECTED))	/* Si filtre ‚tat lecture */
					{
						if (adrpr[F_ETATLEC].ob_state & SELECTED)
						{
							if (NOT (dtabuffer.d_attrib & FA_READONLY))
								ok = FALSE;
						}
						else if (adrpr[F_ETATLECECR].ob_state & SELECTED)
						{
							if (dtabuffer.d_attrib & FA_READONLY)
								ok = FALSE;
						}
					}

					if (ok)
					{
						del = TRUE;
						if (mode == MREC)											/* Si mode recherche */
						{
							if (ask)														/* Si demande confirmation */
							{
								del = ask_fil (dtabuffer.d_fname, acces);
								*draw = 1;
							}
							else
								del = FALSE;
						}
						else if (mode == MEFF)								/* Si mode effacement */
						{
							if (ask)														/* Si demande confirmation */
							{
								del = ask_del (dtabuffer.d_fname, acces);
								*draw = 2;
							}
						}
      
						if (del == TRUE)											/* Si effacement ou liste ok */
						{
							strcpy (fichier, acces);
							strcat (fichier, dtabuffer.d_fname);
							if (mode != MLIS)										/* Si mode recherche ou effacement */
							{
								Fattrib (fichier, TRUE, ZERO);		/* D‚prot‚ger */
								Fdelete (fichier);								/* D‚truire fichier */
							}
							else if (mode == MLIS)							/* Si mode liste */
								write_liste (fhlis, fichier);
						}
						else if ((mode == MREC) && (del == FALSE) && (NOT ask))	/* Recherche sans confirmation */
							modif_file (dtabuffer.d_fname, acces);
						else if (del == BLANK)
							return FALSE;
					}
				}
				ret = Fsnext ();									/* Fichier ou dossier suivant */
			}																		/* Fin de la bouche de recherche */
		}
	}

		/* R‚server m‚moire pour liste dossiers */
	fold = (dossiers *)malloc (120 * sizeof (dossiers));
	strcpy (chemin, acces);							/* Recherche des dossiers */
	strcat (chemin, "*.*");
	ret = Fsfirst (chemin, FA_SUBDIR);	/* Premier fichier ou dossier */
	while (ret >= 0)										/* Tant qu'il y en a un, on boucle */
	{
		if (dtabuffer.d_attrib & FA_SUBDIR)		/* Si c'est un dossier */
		{
			if ((strcmp (dtabuffer.d_fname, ".")) &&		/* Sauter dossiers bidons */
					(strcmp (dtabuffer.d_fname, "..")))
			{
				strcpy (fold[k], dtabuffer.d_fname);	/* Enregistrer nom */
				k++;
			}
		}
		ret = Fsnext ();									/* Fichier ou dossier suivant */
	}																		/* Fin de la bouche de recherche */

	i = ZERO;
	while (i < k)												/* On repasse la liste */
	{																		/* Pour chaque dossier */
		strcpy (suite, acces);
		strcat (suite, fold[i]);
		strcat (suite, "\\");							/* Constituer chemin */
		result = find (suite, fhlis, draw);			/* Recursivit‚ */
		if (NOT result)
		{
			free (fold);
			return FALSE;
		}
		i++;															/* Dossier suivant */
	}
	free (fold);							/* Lib‚rer m‚moire liste dossiers */
	return TRUE;
}

/* write_liste () Ecrit le fichier liste :												*/
void write_liste (int fh, char *file)
{
register int i;
char ligne[255], date[9], temp[10];

	strcpy (ligne, " ");										/* Constituer ligne de liste */
	if (adrpl[PL_ARCH].ob_state & SELECTED)	/* Si bit d'archive */
	{
		if (dtabuffer.d_attrib & FA_ARCHIVE)
			strcat (ligne, "a ");
		else
			strcat (ligne, "- ");
	}

	if (adrpl[PL_HIDE].ob_state & SELECTED)	/* Si ‚tat cach‚ */
	{
		if (dtabuffer.d_attrib & FA_HIDDEN)
			strcat (ligne, "h ");
		else
			strcat (ligne, "v ");
	}

	if (adrpl[PL_ETAT].ob_state & SELECTED)	/* Si ‚tat lecture */
	{
		if (dtabuffer.d_attrib & FA_READONLY)
			strcat (ligne, "r ");
		else
			strcat (ligne, "w ");
	}

	if (adrpl[PL_DATE].ob_state & SELECTED)	/* Si date */
	{
		litdate (date, dtabuffer.d_date);
		memcpy (date + 3, date + 2, 5);
		date[2] = '/';
		memcpy (date + 6, date + 5, 3);
		date[5] = '/';
		strcat (ligne, date);
		strcat (ligne, " ");
	}

	if (adrpl[PL_SIZE].ob_state & SELECTED)	/* Si taille */
	{
		ltoa (dtabuffer.d_length, temp, 10);
		strcat (ligne, temp);
		for (i = (int)strlen (temp) ; i < 11 ; i++)
			strcat (ligne, " ");
	}

	strcat (ligne, file);								/* Nom du fichier */

	Fwrite (fh, strlen (ligne), ligne);	/* Sauver la ligne */
	Fwrite (fh, 2, "\r\n");							/* et CR/LF */
}

/* ask_fil () Demande confirmation sur fichier :									*/
int ask_fil (char *nom, char *lec)
{
int bouton, x, y, w, h, retour, attr, oldread = FALSE, fh;
unsigned int fdate;
char path[128], oldname[128], newname[128], nomaff[13], temp[13],
		 size[9], date[9], ouvre[128], *str1, *str2;
DOSTIME dat;

	strcpy (path, lec);
	strcpy (oldname, path);
	if (strlen (path) > 40)
	{
		strcpy (path + 3, lec + (strlen (lec) - 37));
		path[1] = path[2] = '.';
	}
	attr = dtabuffer.d_attrib;

	strcpy (adrt[T_PATH].ob_spec.free_string, path);
	fnom (nom, nomaff);
	strcpy (adrt[T_NAME].ob_spec.tedinfo->te_ptext, nomaff);
	ltoa (dtabuffer.d_length, size, 10);
	strcpy (adrt[T_SIZE].ob_spec.tedinfo->te_ptext, size);

	if (dtabuffer.d_attrib & FA_ARCHIVE)		/* Etat bit d'archive */
	{
		rsrc_gaddr (R_FRSTR, OUI, &str1);	/* Adr chaŒne pointeur sur pointeur */
		rsrc_gaddr (R_FRSTR, ARCHNON, &str2);
	}
	else
	{
		rsrc_gaddr (R_FRSTR, NON, &str1);	/* Adr chaŒne pointeur sur pointeur */
		rsrc_gaddr (R_FRSTR, ARCHOUI, &str2);
	}
	str1 = *((char **)str1);						/* Pointeur sur le texte */
	strcpy (adrt[T_ARCH].ob_spec.free_string, str1);
	str2 = *((char **)str2);
	strcpy ((char *)adrt[T_FARCH].ob_spec.userblk->ub_parm, str2);

	if (dtabuffer.d_attrib & FA_HIDDEN)		/* Etat cach‚ / visible */
	{
		rsrc_gaddr (R_FRSTR, OUI, &str1);	/* Adr chaŒne pointeur sur pointeur */
		rsrc_gaddr (R_FRSTR, MONTRER, &str2);
	}
	else
	{
		rsrc_gaddr (R_FRSTR, NON, &str1);	/* Adr chaŒne pointeur sur pointeur */
		rsrc_gaddr (R_FRSTR, CACHER, &str2);
	}
	str1 = *((char **)str1);						/* Pointeur sur le texte */
	strcpy (adrt[T_HIDE].ob_spec.free_string, str1);
	str2 = *((char **)str2);
	strcpy ((char *)adrt[T_FHIDE].ob_spec.userblk->ub_parm, str2);

	if (dtabuffer.d_attrib & FA_READONLY)		/* Etat lecture - ‚criture */
	{
		rsrc_gaddr (R_FRSTR, LECTSEUL, &str1);	/* Adr chaŒne pointeur sur pointeur */
		rsrc_gaddr (R_FRSTR, LECTECRI, &str2);
	}
	else
	{
		rsrc_gaddr (R_FRSTR, LECTECRI, &str1);	/* Adr chaŒne pointeur sur pointeur */
		rsrc_gaddr (R_FRSTR, LECTSEUL, &str2);
	}
	str1 = *((char **)str1);						/* Pointeur sur le texte */
	strcpy (adrt[T_ETAT].ob_spec.free_string, str1);
	str2 = *((char **)str2);
	strcpy ((char *)adrt[T_FETAT].ob_spec.userblk->ub_parm, str2);

	litdate (date, dtabuffer.d_date);
	memcpy (date + 3, date + 2, 5);
	date[2] = '/';
	memcpy (date + 6, date + 5, 3);
	date[5] = '/';
	strcpy (adrt[T_DATE].ob_spec.free_string, date);

	adrt[T_FARCH].ob_state &= ~SELECTED;	/* Tout d‚s‚lectionner */
	adrt[T_FHIDE].ob_state &= ~SELECTED;
	adrt[T_DACTU].ob_state &= ~SELECTED;
	adrt[T_FETAT].ob_state &= ~SELECTED;
	form_center (adrt, &x, &y, &w, &h);
	objc_draw (adrt, ROOT, MAX_DEPTH, x, y, w, h);	/* Dessiner formulaire */

	graf_mouse (ARROW, ZERO);							/* Souris -> flŠche */
	bouton = form_do (adrt, T_NAME);
	adrt[T_DELETE].ob_flags &= ~DEFAULT;
	adrt[T_MODIF].ob_flags &= ~DEFAULT;
	adrt[T_SKIP].ob_flags &= ~DEFAULT;
	if (bouton == T_DELETE)					/* D‚truire */
	{
		retour = TRUE;
		adrt[T_DELETE].ob_flags |= DEFAULT;
	}
	else if (bouton == T_MODIF)			/* Modifier */
	{
		strcpy (ouvre, oldname);			/* Nom actuel */
		strcat (ouvre, nom);
		if (attr & FA_READONLY)				/* Si prot‚g‚ */
		{
			attr &= ~FA_READONLY;				/* D‚prot‚ger provisoirement */
			Fattrib (ouvre, TRUE, attr);
			oldread = TRUE;
		}
		if (adrt[T_DACTU].ob_state & SELECTED)	/* Actualiser date */
		{
			litdate (date, ZERO);			/* Lire date systŠme */
			convdate (date, &fdate);	/* Convertir en valeur */
			dat.time = ZERO;
			dat.date = fdate;
			fh = (int)Fopen (ouvre, FO_READ);
			Fdatime (&dat, fh, TRUE);
			Fclose (fh);
		}
			/* Changer le nom */
		if (strcmp (nomaff, adrt[T_NAME].ob_spec.tedinfo->te_ptext))
		{
			strcat (oldname, nom);								/* Renommer */
			strcpy (temp, adrt[T_NAME].ob_spec.tedinfo->te_ptext);
			formate (temp);
			strcpy (newname, path);
			strcat (newname, temp);
			Frename (ZERO, oldname, newname);
		}
		if (adrt[T_FARCH].ob_state & SELECTED)	/* Changer bit d'archive */
			attr ^= FA_ARCHIVE;
		if (adrt[T_FHIDE].ob_state & SELECTED)	/* Changer ‚tat cach‚ */
			attr ^= FA_HIDDEN;
		Fattrib (ouvre, TRUE, attr);
		if (oldread)						/* S'il ‚tait prot‚g‚ */
		{
			attr |= FA_READONLY;	/* On restaure l'‚tat */
			Fattrib (ouvre, TRUE, attr);
		}
		if (adrt[T_FETAT].ob_state & SELECTED)	/* Changer ‚tat lecture */
		{
			attr ^= FA_READONLY;
			Fattrib (ouvre, TRUE, attr);
		}
		retour = FALSE;
		adrt[T_MODIF].ob_flags |= DEFAULT;
	}
	else if (bouton == T_SKIP)			/* Sauter */
	{
		retour = FALSE;
		adrt[T_SKIP].ob_flags |= DEFAULT;
	}
	else if (bouton == T_ANN)				/* Annuler */
		retour = BLANK;

	adrt[bouton].ob_state &= ~SELECTED;			/* D‚s‚lectionner bouton */
	graf_mouse (BUSYBEE, ZERO);							/* Souris -> abeille */
	return retour;
}

/* ask_del () Demande confirmation sur fichier :									*/
int ask_del (char *nom, char *lec)
{
int bouton, x, y, w, h, retour;
char path[128];

	strcpy (path, lec);
	if (strlen (path) > 40)
	{
		strcpy (path + 3, lec + (strlen (lec) - 37));
		path[1] = path[2] = '.';
	}

	strcpy (adre[E_PATH].ob_spec.free_string, path);
	strcpy (adre[E_NAME].ob_spec.free_string, nom);
	form_center (adrt, &x, &y, &w, &h);
	objc_draw (adre, ROOT, MAX_DEPTH, x, y, w, h);	/* Dessiner formulaire */

	graf_mouse (ARROW, ZERO);							/* Souris -> flŠche */
	bouton = form_do (adre, BLANK);
	if (bouton == E_DELETE)					/* D‚truire */
	{
		retour = TRUE;
		adre[E_DELETE].ob_flags |= DEFAULT;
	}
	else if (bouton == E_SKIP)			/* Sauter */
	{
		retour = FALSE;
		adre[E_SKIP].ob_flags |= DEFAULT;
	}
	else if (bouton == E_ANN)				/* Annuler */
		retour = BLANK;

	adre[bouton].ob_state &= ~SELECTED;			/* D‚s‚lectionner bouton */
	graf_mouse (BUSYBEE, ZERO);							/* Souris -> abeille */
	return retour;
}

/* modif_file () Modif automatiques sur fichier :								*/
void modif_file (char *nom, char *acces)
{
int fh;
unsigned int fdate, attr, oldread = FALSE;
char ouvre[128], date[9];
DOSTIME dat;

	strcpy (ouvre, acces);			/* Nom actuel */
	strcat (ouvre, nom);
	attr = dtabuffer.d_attrib;
	if (attr & FA_READONLY)				/* S'il est prot‚g‚ */
	{
		attr &= ~FA_READONLY;				/* D‚prot‚ger provisoirement */
		Fattrib (ouvre, TRUE, attr);
		oldread = TRUE;
	}
	if (adrpr[F_MDAT].ob_state & SELECTED)		/* Modifier la date */
	{
		if (adrpr[F_MDATACT].ob_state & SELECTED)
		{
			litdate (date, ZERO);			/* Lire date systŠme */
			convdate (date, &fdate);	/* Convertir en valeur */
			dat.time = ZERO;
			dat.date = fdate;
			fh = (int)Fopen (ouvre, FO_READ);
			Fdatime (&dat, fh, TRUE);
			Fclose (fh);
		}
		else if (adrpr[F_MDATFIXE].ob_state & SELECTED)
		{
			strcpy (date, adrpr[F_MDATCHOIX].ob_spec.tedinfo->te_ptext);	/* Lire date fixe */
			convdate (date, &fdate);	/* Convertir en valeur */
			dat.time = ZERO;
			dat.date = fdate;
			fh = (int)Fopen (ouvre, FO_READ);
			Fdatime (&dat, fh, TRUE);
			Fclose (fh);
		}
	}

	if (oldread)									/* S'il ‚tait prot‚g‚ */
	{
		attr |= FA_READONLY;				/* Restaurer ‚tat */
		Fattrib (ouvre, TRUE, attr);
	}

	if (adrpr[F_MARCH].ob_state & SELECTED)	/* Changer bit d'archive */
	{
		if (adrpr[F_MARCHOUI].ob_state & SELECTED)
			attr |= FA_ARCHIVE;
		else if (adrpr[F_MARCHNON].ob_state & SELECTED)
			attr &= ~FA_ARCHIVE;
	}

	if (adrpr[F_MHIDE].ob_state & SELECTED)	/* Changer ‚tat cach‚ */
	{
		if (adrpr[F_MUNHIDEFILE].ob_state & SELECTED)
			attr &= ~FA_HIDDEN;
		else if (adrpr[F_MHIDEFILE].ob_state & SELECTED)
			attr |= FA_HIDDEN;
	}

	if (adrpr[F_METAT].ob_state & SELECTED)	/* Changer ‚tat lecture */
	{
		if (adrpr[F_MLECECR].ob_state & SELECTED)
			attr &= ~FA_READONLY;
		else if (adrpr[F_MLECSEU].ob_state & SELECTED)
			attr |= FA_READONLY;
	}
	Fattrib (ouvre, TRUE, attr);
}

/* fnom () Formate le nom du fichier :														*/
void fnom (char *name, char *str)
{
int i = ZERO, k = 1;

		/* Avant : "NOM.EXT" AprŠs : "NOM    EXT" */
	if (strlen (name) == 12)
	{
		strcpy (str, name);
		strcpy (str + 8, name + 9);
	}
	else
	{
		if (strchr (name, (int)'.'))
		{
			while (name[i] != '.')
			{
				str[i] = name[i];
				i++;
				k++;
			}
			while (i < 8)
				str[i++] = ' ';
			strcpy (str + 8, name + k);
		}
		else
			strcpy (str, name);
	}
}

/* exist () Fichier existe :																			*/
long exist (char *name, int att)
{
int re;

	re = Fsfirst (name, att);
	if ((re == -34) || (re == -33))		/* Si rien n'est trouv‚ */
		return (FALSE);									/* retourner FALSE */
	else															/* Sinon */
	{
		if ((att & FA_SUBDIR) != FA_SUBDIR)	/* Si ce n'est pas un dossier */
			return dtabuffer.d_length;				/* Retourner la taille */
		else																/* Si c'est un dossier */
			return (TRUE);										/* Retourner TRUE */
	}
}

/* path () Cherche et retourne le chemin de l'application :			*/
char *path (char *chemin)
{
int drive;

	drive = Dgetdrv ();							/* Lecteur courant */
	chemin[0] = (char) (65 + drive);
	chemin[1] = ':';
	Dgetpath (&chemin[2], drive + 1);	/* Chemin lecteur courant */
	strcat (chemin, "\\");
	return chemin;
}

/* selector () S‚lecteur : 																			*/
int selector (char *chemin, char *ext, char *file, char *title)
{
char ch[120], fi[13];
int retour, i;

	strcpy (ch, chemin);
	strcat (ch, ext); 						/* Chemin et s‚lection */
	strcpy (fi, file);
	if ((Sversion () >> 8) <= 20)
		fsel_input (ch, fi, &retour); 					/* Appel du s‚lecteur */
	else
		fsel_exinput (ch, fi, &retour, title);	/* Appel du s‚lecteur */
	if (retour)										/* Si pas ANNULER... */
	{
		for (i = (int)strlen (ch) ; ch[i] != '\\' ; ch[i--] = '\0') ;
		strcpy (chemin, ch);
		strcpy (file, fi);
	}
	return retour;
}

/* extension () Ajuste extension :																*/
void extension (char *filename, char *ext)
{ 							/* L'EXTENSION DOIT ETRE TRANSMISE AVEC LE POINT */
int t;

	t = (int)strlen (filename);								/* Longueur du nom de fichier */
	while (filename[t] != '.' && t > ZERO) 	/* Chercher le '.' … partir de la droite */
		t--;
	if (t > ZERO)										/* Si trouv‚, */
	{
		memcpy (filename + t, ext, 4); 			/* ajouter l'extention … partir de l… */
		filename[t + 4] = '\0';
	}
	else														/* Sinon, */
		strcat (filename, ext);							/* l'ajouter … la fin */
}

/* litdate () Lit la date systŠme ou fichier et conv. chaŒne :		*/
void litdate (char *dat, unsigned int fdate)
{
int d, a, m, j;
char ac[3], mc[3], jc[3];

	if (fdate == ZERO)
		d = Tgetdate ();
	else
		d = fdate;
	j = d & 0x1f;
	m = (d >> 5) & 0x0f;
	a = ((d >> 9) & 0x7f) + 80;

	itoa (j, jc, 10);
	if (strlen (jc) == 1)
	{
		jc[1] = jc[0];
		jc[0] = '0';
		jc[2] = '\0';
	}
	itoa (m, mc, 10);
	if (strlen (mc) == 1)
	{
		mc[1] = mc[0];
		mc[0] = '0';
		mc[2] = '\0';
	}
	itoa (a, ac, 10);
	if (strlen (ac) == 1)
	{
		ac[1] = ac[0];
		ac[0] = '0';
		ac[2] = '\0';
	}

	strcpy (dat, jc);
	strcat (dat, mc);
	strcat (dat, ac);
}

/* convdate () Convertir date chaŒne en valeur :									*/
void convdate (char *date, unsigned int *fdate)
{
int j, m, a, new_date = ZERO;
char jc[3], mc[3], ac[3];

	jc[0] = date[0];
	jc[1] = date[1];
	jc[2] = '\0';

	mc[0] = date[2];
	mc[1] = date[3];
	mc[2] = '\0';

	ac[0] = date[4];
	ac[1] = date[5];
	ac[2] = '\0';

	j = atoi (jc);
	m = atoi (mc);
	a = atoi (ac) - 80;

	new_date |= j;
	new_date |= (m << 5);
	new_date |= (a << 9);

	*fdate = new_date;
}

