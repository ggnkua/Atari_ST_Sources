/*								BIGDEMO.C			>>> Big Is Gem <<<
				Programme de d‚mo de BIG : Librairie de d‚veloppement sous GEM
										version 1.05 du 16/06/93													*/

#include <big.h>
#define INTGR 0

#if INTGR						/* Si on travaille avec un ressource int‚gr‚ */
#include "BIGDEMO.RSH"
#define TRINDEX (OBJECT *)rs_trindex
#define FRSTR (char *)rs_frstr
#define NB_TREE 16
#else								/* Si on travaille avec un ressource externe */
#include "bigdemo.h"
#define TRINDEX 0
#define FRSTR 0
#define NB_TREE 0
#endif

#define NB_FENETRES 6
#define PETIT_FORM 0
#define GRAND_FORM 1
#define TEXTE 2
#define IMAGE 3
#define WINDMENU 4
#define HISTO 5

/* #[ Prototypage :																									*/
void main (void);
void aff_infos (void);
void formulaire (void);
void test_alerte (void);
void pform_wind (void);
void trame_desk (void);
void gform_wind (void);
void objets_desk (void);
void charge_texte (void);
void aff_texte (void);
void close_txt (void);
void charge_image (void);
void close_img (void);
void cree_histo (void);
void aff_histo (void);
void sized_histo (void);
void fulled_histo (void);
void close_histo (void);
void close_wmenu (void);
void icone (void);
/* #] Prototypage :																									*/
/* #[ main () Initialisations et gestion :													*/
void main (void)
{
int evnt, quit = FALSE, i, old_x, old_y, new_x, new_y, dummy;
MFDB img;

			/* Initialiser */
	if (initial ("BIGDEMO.RSC", MENU, BUREAU,
							 NB_TREE, TRINDEX, FRSTR, NB_FENETRES))
	{
			/* Affecter fonctions aux pointeurs */
		fnc[0] = (void *) aff_infos;			/* Infos du menu principal */
		fnc[1] = (void *) formulaire;			/* Formulaire du menu principal */
		fnc[2] = (void *) pform_wind;			/* Petit form. menu principal */
		fnc[3] = (void *) gform_wind;			/* Grand form. menu principal */
		fnc[4] = (void *) test_alerte;		/* Alerte formulaire libre */
		fnc[5] = (void *) aff_infos;			/* Infos menu en fenˆtre */
		fnc[6] = (void *) charge_texte;		/* Charger texte menu hierarchique */
		fnc[7] = (void *) charge_image;		/* Charger image menu hierarchique */
		fnc[8] = (void *) formulaire;			/* Formulaire libre pop-up libre */
		fnc[9] = (void *) pform_wind;			/* Petit form. pop-up libre */
		fnc[10] = (void *) gform_wind;		/* Grand form. pop-up libre */
		fnc[11] = (void *) charge_texte;	/* Charger texte pop-up libre */
		fnc[12] = (void *) charge_image;	/* Charger image pop-up libre */
		fnc[13] = (void *) cree_histo;		/* Ouvrir histo pop-up libre */
		fnc[14] = (void *) icone;					/* Alerte avec choix ic“ne */
		fnc[15] = (void *) icone;					/* Alerte avec choix ic“ne */
		fnc[16] = (void *) icone;					/* Alerte avec choix ic“ne */
		fnc[17] = (void *) icone;					/* Alerte avec choix ic“ne */
		fnc[18] = (void *) icone;					/* Alerte avec choix ic“ne */
		fnc[19] = (void *) icone;					/* Alerte avec choix ic“ne */
		fnc[20] = (void *) icone;					/* Alerte avec choix ic“ne */
		fnc[21] = (void *) icone;					/* Alerte avec choix ic“ne */

		do
		{
			evnt = dialog (DLG_DESK, adr_desk, TRUE, INTGR, TRUE, PU_LIBRE, &img, FALSE);
			if (evnt & MU_MESAG)
			{
				if (buf[0] == MN_SELECTED)
				{
					switch (buf[4])
					{
					case M_ALERTE :
						menu_tnormal (adr_menu, T_FICHIER, 0);
						big_alert (2, ALERTE, "", TRUE, INTGR);
						menu_tnormal (adr_menu, T_FICHIER, 1);
						break;
					case M_WMENU :
						menu_tnormal (adr_menu, T_FENETRES, 0);
						if (win[WINDMENU].w_hg <= ZERO)
						{
							win[WINDMENU].w_cont.w_img.w_pal = (int *)Malloc (16 *sizeof (int));
							for (i = 0 ; i < 16 ; i++)
								win[WINDMENU].w_cont.w_img.w_pal[i] = palette[i];
							open_window (WINDMENU, WTYP_PICT, WATR_CURR,
													 xd + (wd / 5), yd + (hd / 5), wd / 3, hd / 2,
													 100, 100, 10, 10, TRUE, FALSE, THIN_CROSS,
													 ZERO, close_wmenu, get_string (TIT_MENU, INTGR), "",
													 (long) wd, (long) hd, TRUE, W_MENU, INTGR);
						}
						else
						{
							buf[3] = win[WINDMENU].w_hg;
							(*win[WINDMENU].w_top)();
						}
						menu_tnormal (adr_menu, T_FENETRES, 1);
						break;
					case M_QUITTER :
						menu_tnormal (adr_menu, T_FICHIER, 0);
						quit = TRUE;
						menu_tnormal (adr_menu, T_FICHIER, 1);
						break;
					}
				}
				else if (buf[0] == BEV_HIERM)	/* Ev‚nement menu hi‚rarchique */
				{
					if (buf [6] == MH_HISTO)
						cree_histo ();
				}
			}
			if ((evnt & MU_BUTTON) && (buf[0] == BEV_FREEPU))
			{
				switch (buf[4])
				{
					case PUL_ALERT :
						menu_tnormal (adr_menu, T_FICHIER, 0);
						big_alert (2, ALERTE, "", TRUE, INTGR);
						menu_tnormal (adr_menu, T_FICHIER, 1);
						break;
					case PUL_WMENU :
						menu_tnormal (adr_menu, T_FENETRES, 0);
						if (win[WINDMENU].w_hg <= ZERO)
						{
							win[WINDMENU].w_cont.w_img.w_pal = Malloc (16 * sizeof (int));
							for (i = 0 ; i < 16 ; i++)
								win[WINDMENU].w_cont.w_img.w_pal[i] = palette[i];
							open_window (WINDMENU, WTYP_PICT, WATR_CURR,
													 xd + (wd / 5), yd + (hd / 5), wd / 3, hd / 2,
													 100, 100, 16, 16, TRUE, FALSE, THIN_CROSS,
													 ZERO, close_wmenu, get_string (TIT_MENU, INTGR), "",
													 (long) wd, (long) hd, TRUE, W_MENU, INTGR);
						}
						else
						{
							buf[3] = win[WINDMENU].w_hg;
							(*win[WINDMENU].w_top)();
						}
						menu_tnormal (adr_menu, T_FENETRES, 1);
						break;
				}
			}
			if ((evnt & MU_BUTTON) && (buf[0] == BEV_WFORM))
			{
				win[buf[3]].w_cont.w_form.w_tree[buf[4]].ob_state &= ~SELECTED;
				if (buf[3] == PETIT_FORM)
				{
					switch (buf[4])
					{
					case PF_CONFIRME :
					case PF_APPLIQUE :
						Mfree (&win[PETIT_FORM].w_cont.w_form.w_bak);	/* Lib‚rer m‚moire */
						bak_rsc (win[PETIT_FORM].w_cont.w_form.w_tree, &win[PETIT_FORM].w_cont.w_form.w_bak);
						trame_desk ();
						break;
					case PF_ANNULE :
					case PF_RAZ :
						res_rsc (win[PETIT_FORM].w_cont.w_form.w_tree, &win[PETIT_FORM].w_cont.w_form.w_bak);
						break;
					}
					if (buf[4] == PF_RAZ)
						print_page (PETIT_FORM);
				}
				else if (buf[3] == GRAND_FORM)
				{
					switch (buf[4])
					{
					case GF_CONFIRME :
					case GF_APPLIQUE :
						Mfree (&win[GRAND_FORM].w_cont.w_form.w_bak);	/* Lib‚rer m‚moire */
						bak_rsc (win[GRAND_FORM].w_cont.w_form.w_tree, &win[GRAND_FORM].w_cont.w_form.w_bak);
						objets_desk ();
						break;
					case GF_ANNULE :
					case GF_RAZ :
						res_rsc (win[GRAND_FORM].w_cont.w_form.w_tree, &win[GRAND_FORM].w_cont.w_form.w_bak);
						break;
					}
					if ((buf[4] == GF_RAZ) || (buf[4] == GF_APPLIQUE))
						print_page (GRAND_FORM);
				}
			}
			if ((evnt & MU_BUTTON) && (buf[0] == BEV_WMENU))
			{
				switch (buf[4] - 3)		/* 3 objets ont ‚t‚ ajout‚s au menu */
				{
				case MW_IMAGE :
					charge_image ();
					break;
				case MW_ALERTE :
					win[buf[5]].w_menu[buf[3]].ob_state |= SELECTED;
					draw_object (buf[3], buf[5]);
					big_alert (2, ALERTE, "", TRUE, INTGR);
					if (win[buf[5]].w_menu[buf[4]].ob_state & CHECKED)
						menu_icheck (win[buf[5]].w_menu, buf[4], FALSE);
					else
						menu_icheck (win[buf[5]].w_menu, buf[4], TRUE);
					win[buf[5]].w_menu[buf[3]].ob_state &= ~SELECTED;
					draw_object (buf[3], buf[5]);
					break;
				}
			}
			if ((evnt & MU_BUTTON) && (buf[0] == BEV_WHIER))
			{
				switch (buf[6])
				{
				case MWH_ICN0 :
					buf[6] = MWH_ICN0;
					icone ();
					break;
				case MWH_ICN1 :
					buf[6] = MWH_ICN1;
					icone ();
					break;
				}
			}
			else if ((evnt & MU_BUTTON) && (NOT wind_find (mx, my)))
			{
				evnt_timer (70, 0);		/* D‚lai */
				graf_mkstate (&dummy, &dummy, &mk, &dummy);

				if ((object == BU_ICN) && (mk == 1))
				{													/* Ic“ne encore cliqu‚e -> d‚placement */
					old_x = adr_desk[BU_ICN].ob_x;
					old_y = adr_desk[BU_ICN].ob_y;
					graf_dragbox (adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height,
												adr_desk[BU_ICN].ob_x + xd, adr_desk[BU_ICN].ob_y + yd,
												xd, yd, wd, hd, &new_x, &new_y);
					adr_desk[BU_ICN].ob_x = new_x - xd;
					adr_desk[BU_ICN].ob_y = new_y - yd;
					form_dial (FMD_FINISH, 0, 0, 0, 0, old_x + xd, old_y + yd,
										 adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height);
					form_dial (FMD_FINISH, 0, 0, 0, 0,
										 adr_desk[BU_ICN].ob_x + xd, adr_desk[BU_ICN].ob_y + yd,
										 adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height);
				}
				else if (((object == BU_BOXTXT) || (object == BU_TXT1) || (object == BU_TXT2)) && (mk == 1))
				{		/* textes encore cliqu‚s -> d‚placement */
					old_x = adr_desk[BU_BOXTXT].ob_x;
					old_y = adr_desk[BU_BOXTXT].ob_y;
					graf_dragbox (adr_desk[BU_BOXTXT].ob_width, adr_desk[BU_BOXTXT].ob_height,
												adr_desk[BU_BOXTXT].ob_x + xd, adr_desk[BU_BOXTXT].ob_y + yd,
												xd, yd, wd, hd, &new_x, &new_y);
					adr_desk[BU_BOXTXT].ob_x = new_x - xd;
					adr_desk[BU_BOXTXT].ob_y = new_y - yd;
					form_dial (FMD_FINISH, 0, 0, 0, 0, old_x + xd, old_y + yd,
										 adr_desk[BU_BOXTXT].ob_width, adr_desk[BU_BOXTXT].ob_height);
					form_dial (FMD_FINISH, 0, 0, 0, 0,
										 adr_desk[BU_BOXTXT].ob_x + xd, adr_desk[BU_BOXTXT].ob_y + yd,
										 adr_desk[BU_BOXTXT].ob_width, adr_desk[BU_BOXTXT].ob_height);
				}
				else if ((object == ZERO) && (adr_desk[BU_ICN].ob_state & SELECTED) && (mk == 0))
				{		/* Bureau cliqu‚ -> d‚s‚lectionner */
					adr_desk[BU_ICN].ob_state &= ~SELECTED;
					form_dial (FMD_FINISH, 0, 0, 0, 0,
									 adr_desk[BU_ICN].ob_x + xd, adr_desk[BU_ICN].ob_y + yd,
									 adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height);
				}
				else if ((object == BU_ICN) && NOT (adr_desk[BU_ICN].ob_state & SELECTED) && (mk == 0))
				{		/* Ic“ne clic simple -> s‚lectionner */
					adr_desk[BU_ICN].ob_state |= SELECTED;
					form_dial (FMD_FINISH, 0, 0, 0, 0,
									 adr_desk[BU_ICN].ob_x + xd, adr_desk[BU_ICN].ob_y + yd,
									 adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height);
				}
			}
		} while (NOT quit);
		end (INTGR);
	}
}
/* #] main () Initialisations et gestion :													*/
/* #[ formulaire () Formulaire libre :															*/
void formulaire (void)
{
OBJECT *adr;
int quit = FALSE;
char *adr_bakrsc = 0L;			/* Ptr sur ‚tat formulaire */
MFDB img;

	img.fd_addr = NULL;
	menu_tnormal (adr_menu, T_FICHIER, 0); 	/* Inverser titre */
	wind_update (BEG_MCTRL);								/* Bloquer menu */
#if INTGR
	adr = rs_trindex[FORMULAIRE];
#else
	rsrc_gaddr (R_TREE, FORMULAIRE, &adr);
#endif
	bak_rsc (adr, &adr_bakrsc);
	formm_draw (adr, TXT1, TRUE, &img);
	do
	{
		dialog (DLG_FORM, adr, FALSE, INTGR, FALSE, BLANK, &img, TRUE);
		switch (object)
		{
		case P_CONFIRME :
			quit = TRUE;
			break;
		case P_ANNULE :
			quit = TRUE;
			res_rsc (adr, &adr_bakrsc);
			break;
		}
	} while (NOT quit);
	formm_undraw (adr, &img);
	if (adr_bakrsc)							/* Si ‚tat formulaire sauvegard‚ */
		Mfree (adr_bakrsc);
	wind_update (END_MCTRL);								/* D‚bloquer menu */
	menu_tnormal (adr_menu, T_FICHIER, 1); 	/* Inverser titre */
}
/* #] formulaire () Formulaire libre :															*/
/* #[ aff_infos () Infos sur BIG :																	*/
void aff_infos (void)
{
OBJECT *adr;
int quit = FALSE, index, tit, menuf = FALSE;
MFDB img;

	if (buf[0] == BEV_WMENU)
	{
		index = buf[5];
		tit = buf[3];
		menuf = TRUE;
		win[index].w_menu[tit].ob_state |= SELECTED;
		draw_object (tit, index);
	}
	menu_tnormal (adr_menu, T_BUREAU, 0); /* Inverser titre */
	wind_update (BEG_MCTRL);							/* Bloquer menu */
#if INTGR
	adr = rs_trindex[INFOS];
#else
	rsrc_gaddr (R_TREE, INFOS, &adr);
#endif
	formm_draw (adr, BLANK, FALSE, &img);
	do
	{
		dialog (DLG_FORM, adr, FALSE, INTGR, FALSE, BLANK, &img, FALSE);
		if (object == INF_SORTIE)
			quit = TRUE;
	} while (NOT quit);
	formm_undraw (adr, &img);
	wind_update (END_MCTRL);							/* D‚bloquer menu */
	menu_tnormal (adr_menu, T_BUREAU, 1); /* Inverser titre */
	if (menuf)
	{
		win[index].w_menu[tit].ob_state &= ~SELECTED;
		draw_object (tit, index);
	}
}
/* #] aff_infos () Infos sur BIG :																	*/
/* #[ test_alerte () Affichage d'alertes BIG :											*/
void test_alerte (void)
{
	big_alert (1, AL_POINTEUR, "", TRUE, INTGR);
}
/* #] test_alerte () Affichage d'alertes BIG :											*/
/* #[ pform_wind () Affichage petit formulaire en fenˆtre :					*/
void pform_wind (void)
{
register int i;
OBJECT *adr;

#if INTGR
	adr = rs_trindex[PETITFORM];
#else
	rsrc_gaddr (R_TREE, PETITFORM, &adr);
#endif
	menu_tnormal (adr_menu, T_FENETRES, 0);
	for (i = TRAME_1 ; i <= TRAME_8 ; i++)
	{
		adr[i].ob_state &= ~SELECTED;
		if (adr_desk->ob_spec.obspec.fillpattern == adr[i].ob_spec.obspec.fillpattern)
			adr[i].ob_state |= SELECTED;
	}
	formw_draw (adr, PETIT_FORM, TITRE_PF, BLANK, PF_CHAMP1, TRUE, INTGR, WATR_FORM);
	menu_tnormal (adr_menu, T_FENETRES, 1);
}
/* #] pform_wind () Affichage petit formulaire en fenˆtre :					*/
/* #[ trame_desk ()Modification trame du bureau :										*/
void trame_desk (void)
{
register int i;
OBJECT *adr;

	adr = win[PETIT_FORM].w_cont.w_form.w_tree;
	for (i = TRAME_1 ; i <= TRAME_8 ; i++)
		if (adr[i].ob_state & SELECTED)
			adr_desk->ob_spec.obspec.fillpattern = adr[i].ob_spec.obspec.fillpattern;
	form_dial (FMD_FINISH, 0, 0, 0, 0, xd, yd, wd, hd);
}
/* #] trame_desk ()Modification trame du bureau :										*/
/* #[ gform_wind () Affichage grand formulaire en fenˆtre :					*/
void gform_wind (void)
{
OBJECT *adr;

#if INTGR
	adr = rs_trindex[GRANDFORM];
#else
	rsrc_gaddr (R_TREE, GRANDFORM, &adr);
#endif
	menu_tnormal (adr_menu, T_FENETRES, 0);
	formw_draw (adr, GRAND_FORM, TITRE_GF, BLANK, BLANK, FALSE, INTGR, WATR_CURR);
	menu_tnormal (adr_menu, T_FENETRES, 1);
}
/* #] gform_wind () Affichage grand formulaire en fenˆtre :					*/
/* #[ objets_desk () Modifications objets du bureau :								*/
void objets_desk (void)
{
OBJECT *adr;

	adr = win[GRAND_FORM].w_cont.w_form.w_tree;
	set_text (adr_desk, BU_TXT1, get_text (adr, GF_PU1));
	set_text (adr_desk, BU_TXT2, get_text (adr, GF_PU2));
	form_dial (FMD_FINISH, 0, 0, 0, 0,
						 adr_desk[BU_TXT1 - 1].ob_x, adr_desk[BU_TXT1 - 1].ob_y + yd,
						 adr_desk[BU_TXT1 - 1].ob_width, adr_desk[BU_TXT1 - 1].ob_height);
	adr_desk[BU_ICN].ob_spec.iconblk->ib_pdata = adr[GF_ICN].ob_spec.bitblk->bi_pdata;
	form_dial (FMD_FINISH, 0, 0, 0, 0,
						 adr_desk[BU_ICN].ob_x, adr_desk[BU_ICN].ob_y + yd,
						 adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height);
}
/* #] objets_desk () Modifications objets du bureau :								*/
/* #[ charge_texte () Chargement texte Ascii en fenˆtre :						*/
void charge_texte (void)
{
char chemin[125], fname[13] = "", fichier[125], *selec, *ptr;
DTA dtabuffer;
long longueur;
int fh, count = 1, dummy, w_cell, h_cell;

	menu_tnormal (adr_menu, T_FENETRES, 0);
			/* Prendre la taille boŒtes caractŠres */ 
	vst_height (handle, hc, &dummy, &dummy, &w_cell, &h_cell);
	Fsetdta (&dtabuffer);							/* Adresse infos sur le fichier */
	path (chemin);										/* Chemin de l'application */
	selec = get_string (CHARGETXT, INTGR);		/* R‚cup‚rer message s‚lecteur */
	if (selector (chemin, "\*.TXT", fname, selec) == TRUE && strlen (fname))
	{					/* Si un fichier a ‚t‚ choisi */
		strcpy (fichier, chemin);
		strcat (fichier, fname);					/* Reconstituer son chemin d'accŠs */
		if (Fsfirst (fichier, 0) == 0)		/* S'il existe */
		{
			longueur = dtabuffer.d_length;	/* Prendre sa longueur */
			if (win[TEXTE].w_cont.w_adr)
				Mfree (win[TEXTE].w_cont.w_adr);	/* Lib‚rer le pr‚c‚dent s'il y en a */
			win[TEXTE].w_cont.w_adr = (char *)Malloc (longueur);	/* R‚server m‚moire */
			if (win[TEXTE].w_cont.w_adr)
			{
				fh = (int)Fopen (fichier, FO_READ);							/* Ouvrir le fichier */
				Fread (fh, longueur, win[TEXTE].w_cont.w_adr);	/* Le charger */
				Fclose (fh);																		/* Refermer */

				for (ptr = win[TEXTE].w_cont.w_adr ; ptr < win[TEXTE].w_cont.w_adr + longueur ; ptr++)
				{
					if (*ptr == '\r')
					{
						*ptr = '\0';
						count++;
					}
				}
				open_window (TEXTE, WTYP_NORM, WATR_CURR,
										 xd + (wd / 4), yd + (hd / 4), wd / 2, hd / 2,
										 100, 100, w_cell, h_cell, TRUE, FALSE, TEXT_CRSR,
										 aff_texte, close_txt, get_string (TIT_TXT, INTGR), "",
										 (long) ((long) MAX_LEN * (long) w_cell),
										 (long) ((long) count * (long) h_cell),
										 FALSE, BLANK, INTGR);
			}
		}
	}
	menu_tnormal (adr_menu, T_FENETRES, 1);
}
/* #] charge_texte () Chargement texte Ascii en fenˆtre :						*/
/* #[ aff_texte () Affichage du texte :															*/
void aff_texte (void)
{
char *ptr;
int i, x, y, h, pxy[4], count = 0, lignes, xw, yw, ww, hw, dummy;

	if (win[TEXTE].w_cont.w_adr)
	{
		lignes = (int)(win[TEXTE].w_htot / (long)win[TEXTE].w_hunit) - 1;	/* Nbre de lignes */
		h = win[TEXTE].w_hunit;
		vst_alignment (handle, 0, 5, &dummy, &dummy);	/* En haut … gauche */
		vst_effects (handle, 0);		/* D‚sactiver tous les effets */
		ptr = win[TEXTE].w_cont.w_adr;								/* D‚but du texte */
		for (i = 0 ; i < (win[TEXTE].w_lin / win[TEXTE].w_hunit) ; i++)
		{
			ptr += (strlen (ptr) + 2);		/* Sauter au d‚but de l'affichage */
			count++;
		}
		wind_get (win[TEXTE].w_hg, WF_WORKXYWH, &xw, &yw, &ww, &hw);
		pxy[0] = xw;											/* Pr‚parer effacement fenˆtre */
		pxy[1] = yw;
		pxy[2] = xw + ww;
		pxy[3] = yw + hw;
		vswr_mode (handle, 1);		/* Dessin en mode Remplacement */
		vsf_color (handle, 0);						/* Couleur blanche */
		vsf_interior (handle, 0); 				/* Motif de remplissage vide */
		v_bar (handle, pxy);							/* "Vider" la fenˆtre */
		x = xw;										/* Positionner l'affichage des lignes */
		y = yw;
		while ((y < yw + hw) && (count < lignes))
		{
			if ((win[TEXTE].w_col / win[TEXTE].w_wunit) <= strlen (ptr))
				v_gtext (handle, x, y, ptr + (win[TEXTE].w_col / win[TEXTE].w_wunit));	/* Ecrire chaque ligne */
			count++;
			ptr += strlen (ptr) + 2;
			y += h;
		}
	}
}
/* #] aff_texte () Affichage du texte :															*/
/* #[ close_txt () Ferme la fenˆtre texte :													*/
void close_txt (void)
{
	if (win[TEXTE].w_hg > 0)
	{
		buf[3] = win[TEXTE].w_hg;
		closed ();
		if (win[TEXTE].w_cont.w_adr)
		{
			Mfree (win[TEXTE].w_cont.w_adr);
			win[TEXTE].w_cont.w_adr = 0L;
		}
	}
}
/* #] close_txt () Ferme la fenˆtre texte :													*/
/* #[ charge_image () Chargement image Degas en fenˆtre :						*/
void charge_image (void)
{
char chemin[125], fname[13] = "", fichier[125], *selec;
int longueur = 32000, reso, fh, index, fmenu, menu, souris;

	if (buf[0] == BEV_WMENU)
	{
		index = WINDMENU;
		win[buf[5]].w_menu[buf[3]].ob_state |= SELECTED;
		draw_object (buf[3], buf[5]);
		fmenu = TRUE;
		menu = W_MENU;
		souris = THIN_CROSS;
	}
	else
	{
		index = IMAGE;
		menu_tnormal (adr_menu, T_FENETRES, 0);
		fmenu = FALSE;
		menu = BLANK;
		souris = POINT_HAND;
	}

	path (chemin);										/* Chemin de l'application */
	selec = get_string (CHARGEIMG, INTGR);		/* R‚cup‚rer message s‚lecteur */
	if (selector (chemin, "\*.PI?", fname, selec) == TRUE && strlen (fname))
	{					/* Si un fichier a ‚t‚ choisi */
		strcpy (fichier, chemin);
		strcat (fichier, fname);					/* Reconstituer son chemin d'accŠs */
		if (exist (fichier, 0))					/* S'il existe */
		{
			if (win[index].w_cont.w_img.w_blk.fd_addr)
				Mfree (win[index].w_cont.w_img.w_blk.fd_addr);	/* Lib‚rer le pr‚c‚dent s'il y en a */
			win[index].w_cont.w_img.w_blk.fd_addr = (char *)Malloc (longueur);	/* R‚server m‚moire */
			if (win[index].w_cont.w_img.w_blk.fd_addr)
			{
				fh = (int)Fopen (fichier, FO_READ);								/* Ouvrir le fichier */
				Fread (fh, 2, &reso);
				win[index].w_cont.w_img.w_blk.fd_w = 640 - ((reso == 0) * 320);
				win[index].w_cont.w_img.w_blk.fd_h = 200 + ((reso == 2) * 200);
				win[index].w_cont.w_img.w_blk.fd_wdwidth = win[index].w_cont.w_img.w_blk.fd_w / 16;
				win[index].w_cont.w_img.w_blk.fd_stand = 1;
				win[index].w_cont.w_img.w_blk.fd_nplanes = n_plane;
				if (index == WINDMENU)
					Mfree (win[WINDMENU].w_cont.w_img.w_pal);
				win[index].w_cont.w_img.w_pal = (int *)Malloc (16 * sizeof (int));
				Fread (fh, 32, win[index].w_cont.w_img.w_pal);

				Fread (fh, longueur, win[index].w_cont.w_img.w_blk.fd_addr);	/* Le charger */
				Fclose (fh);																	/* Refermer */

				if (open_window (index, WTYP_PICT, WATR_CURR,
												 xd + (wd / 3), yd + (hd / 3), wd / 2, hd / 2,
												 100, 100, 10, 10, TRUE, FALSE, souris,
												 ZERO, close_img, get_string (TIT_IMG, INTGR), "",
												 (long) win[index].w_cont.w_img.w_blk.fd_w,
												 (long) win[index].w_cont.w_img.w_blk.fd_h,
												 fmenu, menu, INTGR))
				{
					if (index == WINDMENU)
						win[index].w_close = close_wmenu;
				}
			}
		}
	}
	if (index == WINDMENU)
	{
		win[buf[5]].w_menu[buf[3]].ob_state &= ~SELECTED;
		draw_object (buf[3], buf[5]);
		height_sliders (index);
	}
	else
		menu_tnormal (adr_menu, T_FENETRES, 1);
}
/* #] charge_image () Chargement image Degas en fenˆtre :						*/
/* #[ close_img () Ferme la fenˆtre image :													*/
void close_img (void)
{
	if (win[IMAGE].w_hg > 0)
	{
		buf[3] = win[IMAGE].w_hg;
		closed ();
		if (win[IMAGE].w_cont.w_img.w_blk.fd_addr)
		{
			Mfree (win[IMAGE].w_cont.w_img.w_blk.fd_addr);
			win[IMAGE].w_cont.w_img.w_blk.fd_addr = 0L;
			Mfree (win[IMAGE].w_cont.w_img.w_pal);	/* Lib‚rer la m‚moire palette */
			win[IMAGE].w_cont.w_img.w_pal = (int *)ZERO;
		}
	}
}
/* #] close_img () Ferme la fenˆtre image :													*/
/* #[ cree_histo () Cr‚er histo et ouvrir fenˆtre :									*/
void cree_histo (void)
{
register int i;

	if (win[HISTO].w_cont.w_adr)
		Mfree (win[HISTO].w_cont.w_adr);		/* Lib‚rer le pr‚c‚dent s'il y en a */
	win[HISTO].w_cont.w_adr = Malloc (8);
	for (i = 0 ; i < 8 ; i++)
		*(win[HISTO].w_cont.w_adr + i) = (rand () & 0xFF);
	if (open_window (HISTO, WTYP_NORM, (NAME|CLOSER|MOVER|SIZER|FULLER|INFO),
									 xd + (wd / 6), yd + (hd / 6), wd / 3, hd / 3,
									 100, 100, 1, 1, TRUE, TRUE, ZERO, aff_histo, close_histo,
									 get_string (TIT_HIST, INTGR), get_string (INF_HIST, INTGR),
									 1L, 1L, FALSE, BLANK, INTGR))
	{
		win[HISTO].w_size = sized_histo;
		win[HISTO].w_full = fulled_histo;
		win[HISTO].w_flags |= WFREDRAW;
	}
}
/* #] cree_histo () Cr‚er histo et ouvrir fenˆtre :									*/
/* #[ aff_histo () Affichage de l'histogramme :											*/
void aff_histo (void)
{
int pxy[4], xw, yw, ww, hw, i, largeur, hauteur,
		datas[8], maxi = ZERO;

	for (i = 0 ; i < 8 ; i++)
		datas[i] = *(win[HISTO].w_cont.w_adr + i);
	zone_work (HISTO, &xw, &yw, &ww, &hw);
	pxy[0] = xw;							/* Pr‚parer effacement fenˆtre */
	pxy[1] = yw;
	pxy[2] = xw + ww;
	pxy[3] = yw + hw;
	vswr_mode (handle, 1);		/* Dessin en mode Remplacement */
	vsf_perimeter (handle, TRUE);	/* Dessiner le p‚rimŠtre */
	vsf_color (handle, 0);		/* Couleur blanche */
	vsf_interior (handle, 0); /* Motif de remplissage vide */
	v_bar (handle, pxy);			/* "Vider" la fenˆtre */
		/* 8 pixels de chaque cot‚ et entre chaque histo */
	largeur = (ww - (16) - (7 * 8)) / 8;
	for (i = 0 ; i < 8 ; i++)
		maxi = max (maxi, datas[i]);
	vsf_color (handle, 2);		/* Couleur rouge */
	vsf_interior (handle, FIS_PATTERN); /* Motif de remplissage tram‚ */
	pxy[3] = yw + hw - 8;
	for (i = 0 ; i < 8 ; i++)
	{
		vsf_style (handle, i + 1);	/* La trame */
		pxy[0] += 8;
		hauteur = (int)((double)datas[i] / (double)maxi * ((double)hw - 16));
		pxy[1] = yw + hw - 8 - hauteur;
		pxy[2] = pxy[0] + largeur;
		v_bar (handle, pxy);			/* Dessiner l'histo */
		pxy[0] += largeur;
	}
}
/* #] aff_histo () Affichage de l'histogramme :											*/
/* #[ sized_histo () Redraw si dimensionnement :										*/
void sized_histo (void)
{
int w, h;

	w = win[HISTO].w_wcurr;	/* Enregistrer dimensions courantes */
	h = win[HISTO].w_hcurr;
	sized ();								/* Redimensionner la fenˆtre */
	if ((buf[6] <= w) && (buf[7] <= h))	/* Si plus petite dans les deux sens */
		print_page (HISTO);			/* Forcer le redraw */
}
/* #] sized_histo () Redraw si dimensionnement :										*/
/* #[ fulled_histo () Histogramme plein ‚cran :											*/
void fulled_histo (void)
{
int x, y, w, h;

	if (win[HISTO].w_flags & WFFULL)
	{
		wind_get (win[HISTO].w_hg, WF_PREVXYWH, &x, &y, &w, &h);
		wind_set (win[HISTO].w_hg, WF_CURRXYWH, x, y, w, h);
		win[HISTO].w_flags &= ~WFFULL;
		print_page (HISTO);
	}
	else
	{
		buf[3] = win[HISTO].w_hg;
		fulled ();
	}
	wind_get (win[HISTO].w_hg, WF_CURRXYWH,
						&win[HISTO].w_xcurr, &win[HISTO].w_ycurr,
						&win[HISTO].w_wcurr, &win[HISTO].w_hcurr);
}
/* #] fulled_histo () Histogramme plein ‚cran :											*/
/* #[ close_histo () Ferme la fenˆtre histo :												*/
void close_histo (void)
{
	if (win[HISTO].w_hg > 0)
	{
		buf[3] = win[HISTO].w_hg;
		closed ();
		if (win[HISTO].w_cont.w_adr)
		{
			Mfree (win[HISTO].w_cont.w_adr);
			win[HISTO].w_cont.w_adr = 0L;
		}
	}
}
/* #] close_histo () Ferme la fenˆtre histo :												*/
/* #[ close_wmenu () Ferme la fenˆtre image avec menu :							*/
void close_wmenu (void)
{
	if (win[WINDMENU].w_hg > 0)
	{
		buf[3] = win[WINDMENU].w_hg;
		closed ();
		if (win[WINDMENU].w_cont.w_img.w_blk.fd_addr)
		{
			Mfree (win[WINDMENU].w_cont.w_img.w_blk.fd_addr);
			win[WINDMENU].w_cont.w_img.w_blk.fd_addr = 0L;
			Mfree (win[WINDMENU].w_cont.w_img.w_pal);	/* Lib‚rer la m‚moire palette */
			win[WINDMENU].w_cont.w_img.w_pal = (int *)ZERO;
		}
	}
}
/* #] close_wmenu () Ferme la fenˆtre image avec menu :							*/
/* #[ icone () Alerte avec choix ic“ne :														*/
void icone (void)
{
char icn;
char *alrt;

	win[buf[7]].w_menu[buf[3]].ob_state |= SELECTED;
	draw_object (buf[3], buf[7]);
	icn = buf[6] + 47;
	alrt = get_string (AL_ICONES, INTGR);
	alrt[1] = icn;
	big_alert (1, BLANK, alrt, TRUE, INTGR);
	win[buf[7]].w_menu[buf[3]].ob_state &= ~SELECTED;
	draw_object (buf[3], buf[7]);
}
/* #] icone () Alerte avec choix ic“ne :														*/
