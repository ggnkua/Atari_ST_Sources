/*								BIGDEMO.C			>>> Big Is Gem <<<
		Programme de d‚mo de BIG : Librairie de d‚veloppement sous GEM
								cr‚‚e et d‚velopp‚e par Claude ATTARD
										version 1.80 du 02/11/93
*/

#include <big.h>
int fgdos, fid, size;
#define INTGR 0

/* #[ D‚finitions :																									*/
#if INTGR						/* Si on travaille avec un ressource int‚gr‚ */
#include "BIGDEMO.RSH"
#define TRINDEX (OBJECT *)rs_trindex
#define FRSTR (char *)rs_frstr
#define NUM_TREE 20
#else								/* Si on travaille avec un ressource externe */
#include "bigdemo.h"
#define TRINDEX 0
#define FRSTR 0
#define NUM_TREE 0
#endif

#define NB_FENETRES 7
#define WINDACC 0
#define PETIT_FORM 1
#define GRAND_FORM 2
#define TEXTE 3
#define IMAGE 4
#define WINDMENU 5
#define HISTO 6
/* #] D‚finitions :																									*/ 

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
void set_font (void);
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
void winicn (void);
void red_acc (void);
void clos_acc (void);
void acc_loop (void);
void relief (void);
/* #] Prototypage :																									*/ 
/* #[ main () Initialisations et gestion :													*/
void main (void)
{
int evnt, quit = FALSE, i, old_x, old_y, new_x, new_y, dummy,
		flacc = FALSE, nb_fonts;
char fontname[128], temp[35];
OBJECT *adr;
MFDB img;

			/* Initialiser */
	if (initial ("BIGDEMO.RSC", MENU, BUREAU, NUM_TREE,
							 TRINDEX, FRSTR, NB_FENETRES, TITREACC))
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

		if (vq_vgdos () == GDOS_FSM)
		{
			graf_mouse (BUSYBEE , 0);
			nb_fonts = vst_load_fonts (work_display.handle, 0);
			fgdos = TRUE;
#if INTGR
			adr = rs_trindex[FONTS];
#else
			rsrc_gaddr (R_TREE, FONTS, &adr);
#endif
			i = 2;
			do
			{
				vqt_name (work_display.handle, i, temp);
				strcpy (fontname, "  ");
				strcat (fontname, temp);
				if (strlen (fontname) > 33)
					fontname[33] = '\0';
				set_text (adr, i, fontname);
				adr[i].ob_state &= ~DISABLED;
				i++;
			} while (((i - 1) <= nb_fonts) && (i <= 41));
			graf_mouse (ARROW, 0);
			fid = 1;
		}
		size = 13;

		if (work_display.n_color >= 16)	/* Si on est pas en couleurs */
			relief ();

		do
		{
			if ((_app == ZERO) && (NOT flacc))	/* Si on tourne en accessoire */
			{
				acc_loop ();
				flacc = TRUE;
			}

			evnt = dialog (DLG_DESK, adr_desk, TRUE, TRUE, PU_LIBRE, &img, FALSE);
			if (evnt & MU_MESAG)
			{
				if (buf[0] == MN_SELECTED)
				{
					switch (buf[4])
					{
					case M_ALERTE :
						menu_tnormal (adr_menu, T_FICHIER, 0);
						big_alert (2, ALERTE, "", TRUE);
						menu_tnormal (adr_menu, T_FICHIER, 1);
						break;
					case M_WMENU :
						menu_tnormal (adr_menu, T_FENETRES, 0);
						if (win[WINDMENU].w_hg <= ZERO)
						{
							win[WINDMENU].w_pal = (Palette *)malloc (work_display.n_color *sizeof (Palette));
							for (i = 0 ; i < work_display.n_color ; i++)
							{
								win[WINDMENU].w_pal[i][0] = work_display.palette[i][0];
								win[WINDMENU].w_pal[i][1] = work_display.palette[i][1];
								win[WINDMENU].w_pal[i][2] = work_display.palette[i][2];
							}
							open_window (WINDMENU, WTYP_PICT, WATR_CURR,
													 bureau.xd + (bureau.wd / 5), bureau.yd + (bureau.hd / 5), 320, 150,
													 100, 100, 16, 16, TRUE, TRUE, THIN_CROSS,
													 winicn, ZERO, close_wmenu, get_string (TIT_MENU), "",
													 (long) bureau.wd, (long) bureau.hd, TRUE, FALSE, W_MENU);
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
				else if (buf[0] == AC_CLOSE)
				{
					clos_acc ();
					flacc = FALSE;
				}
				else if ((buf[0] == WM_CLOSED) && (buf[3] == win[WINDACC].w_hg))
					flacc = FALSE;
			}
			if ((evnt & MU_BUTTON) && (buf[0] == BEV_FREEPU))
			{
				switch (buf[4])
				{
					case PUL_ALERT :
						if (_app)
							menu_tnormal (adr_menu, T_FICHIER, 0);
						else
						{
							win[WINDACC].w_bar[T_FICHIER + 3].ob_state |= SELECTED;
							draw_object (T_FICHIER + 3, WINDACC);
						}
						big_alert (2, ALERTE, "", TRUE);
						if (_app)
							menu_tnormal (adr_menu, T_FICHIER, 1);
						else
						{
							win[WINDACC].w_bar[T_FICHIER + 3].ob_state &= ~SELECTED;
							draw_object (T_FICHIER + 3, WINDACC);
						}
						break;
					case PUL_WMENU :
						if (_app)
							menu_tnormal (adr_menu, T_FENETRES, 0);
						else
						{
							win[WINDACC].w_bar[T_FENETRES + 3].ob_state |= SELECTED;
							draw_object (T_FENETRES + 3, WINDACC);
						}
						if (win[WINDMENU].w_hg <= ZERO)
						{
							win[WINDMENU].w_pal = (Palette *)malloc (work_display.n_color * sizeof (Palette));
							for (i = 0 ; i < work_display.n_color ; i++)
							{
								win[WINDMENU].w_pal[i][0] = work_display.palette[i][0];
								win[WINDMENU].w_pal[i][1] = work_display.palette[i][1];
								win[WINDMENU].w_pal[i][2] = work_display.palette[i][2];
							}
							open_window (WINDMENU, WTYP_PICT, WATR_CURR,
													 bureau.xd + (bureau.wd / 5), bureau.yd + (bureau.hd / 5), 320, 150,
													 100, 100, 16, 16, TRUE, TRUE, THIN_CROSS,
													 winicn, ZERO, close_wmenu, get_string (TIT_MENU), "",
													 (long) bureau.wd, (long) bureau.hd, TRUE, FALSE, W_MENU);
						}
						else
						{
							buf[3] = win[WINDMENU].w_hg;
							(*win[WINDMENU].w_top)();
						}
						if (_app)
							menu_tnormal (adr_menu, T_FENETRES, 1);
						else
						{
							win[WINDACC].w_bar[T_FENETRES + 3].ob_state &= ~SELECTED;
							draw_object (T_FENETRES + 3, WINDACC);
						}
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
						free (&win[PETIT_FORM].w_cont.w_form.w_bak);	/* Lib‚rer m‚moire */
						bak_rsc (win[PETIT_FORM].w_cont.w_form.w_tree, &win[PETIT_FORM].w_cont.w_form.w_bak);
						if (_app)
							trame_desk ();
						break;
					case PF_ANNULE :
					case PF_RAZ :
						res_rsc (win[PETIT_FORM].w_cont.w_form.w_tree, &win[PETIT_FORM].w_cont.w_form.w_bak);
						break;
					}
					if ((buf[4] == PF_RAZ) || (buf[4] == PF_APPLIQUE))
						print_page (PETIT_FORM);
				}
				else if (buf[3] == GRAND_FORM)
				{
					switch (buf[4])
					{
					case GF_CONFIRME :
					case GF_APPLIQUE :
						free (&win[GRAND_FORM].w_cont.w_form.w_bak);	/* Lib‚rer m‚moire */
						bak_rsc (win[GRAND_FORM].w_cont.w_form.w_tree, &win[GRAND_FORM].w_cont.w_form.w_bak);
						if (_app)
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
				if (buf[5] == WINDMENU)
				{
					switch (buf[4] - 3)		/* 3 objets ont ‚t‚ ajout‚s au menu */
					{
					case MW_IMAGE :
						charge_image ();
						break;
					case MW_ALERTE :
						win[buf[5]].w_bar[buf[3]].ob_state |= SELECTED;
						draw_object (buf[3], buf[5]);
						big_alert (2, ALERTE, "", TRUE);
						if (win[buf[5]].w_bar[buf[4]].ob_state & CHECKED)
							menu_icheck (win[buf[5]].w_bar, buf[4], FALSE);
						else
							menu_icheck (win[buf[5]].w_bar, buf[4], TRUE);
						win[buf[5]].w_bar[buf[3]].ob_state &= ~SELECTED;
						draw_object (buf[3], buf[5]);
						break;
					}
				}
			/* Ev‚nements du menu principal, si on est en accessoire : */
				else if (buf[5] == WINDACC)
				{
					switch (buf[4] - 3)		/* 3 objets ont ‚t‚ ajout‚s au menu */
					{
					case M_ALERTE :
						win[buf[5]].w_bar[buf[3]].ob_state |= SELECTED;
						draw_object (buf[3], buf[5]);
						big_alert (2, ALERTE, "", TRUE);
						win[buf[5]].w_bar[buf[3]].ob_state &= ~SELECTED;
						draw_object (buf[3], buf[5]);
						break;
					case M_WMENU :
						win[buf[5]].w_bar[buf[3]].ob_state |= SELECTED;
						draw_object (buf[3], buf[5]);
						win[buf[5]].w_bar[buf[3]].ob_state &= ~SELECTED;
						draw_object (buf[3], buf[5]);
						if (win[WINDMENU].w_hg <= ZERO)
						{
							win[WINDMENU].w_pal = (Palette *)malloc (work_display.n_color *sizeof (Palette));
							for (i = 0 ; i < work_display.n_color ; i++)
							{
								win[WINDMENU].w_pal[i][0] = work_display.palette[i][0];
								win[WINDMENU].w_pal[i][1] = work_display.palette[i][1];
								win[WINDMENU].w_pal[i][2] = work_display.palette[i][2];
							}
							open_window (WINDMENU, WTYP_PICT, WATR_CURR,
													 bureau.xd + (bureau.wd / 5), bureau.yd + (bureau.hd / 5), 320, 150,
													 100, 100, 16, 16, TRUE, TRUE, THIN_CROSS,
													 winicn, ZERO, close_wmenu, get_string (TIT_MENU), "",
													 (long) bureau.wd, (long) bureau.hd, TRUE, FALSE, W_MENU);
						}
						else
						{
							buf[3] = win[WINDMENU].w_hg;
							(*win[WINDMENU].w_top)();
						}
						break;
					case M_QUITTER :
						win[buf[5]].w_bar[buf[3]].ob_state |= SELECTED;
						draw_object (buf[3], buf[5]);
						clos_acc ();
						win[buf[5]].w_bar[buf[3]].ob_state &= ~SELECTED;
						flacc = FALSE;
						break;
					}
				}
			}
			if ((evnt & MU_BUTTON) && (buf[0] == BEV_WHIER))
			{
				if (buf[7] == WINDMENU)
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
				else if (buf[7] == WINDACC)
				{
					switch (buf[6])
					{
					case MH_HISTO :
						cree_histo ();
					}
				}
			}
			if ((evnt & MU_BUTTON) && (buf[0] == BEV_TOOL))
			{
				if (buf[3] == TEXTE)
				{
					if ((buf[4] == TL_FONT) || (buf[4] == TL_SIZE))
						set_font ();
					print_page (TEXTE);
				}
			}
			else if ((evnt & MU_BUTTON) && (NOT wind_find (mx, my)))
			{
				evnt_timer (70, 0);		/* D‚lai */
				graf_mkstate (&dummy, &dummy, &mk, &dummy);

				if ((object == BU_ICN) && (mk == 1))
				{													/* Ic“ne encore cliqu‚e -> d‚placement */
					old_x = adr_desk[object].ob_x;
					old_y = adr_desk[object].ob_y;
					graf_dragbox (adr_desk[object].ob_width, adr_desk[object].ob_height,
												adr_desk[object].ob_x + bureau.xd, adr_desk[object].ob_y + bureau.yd,
												bureau.xd, bureau.yd, bureau.wd, bureau.hd, &new_x, &new_y);
					adr_desk[object].ob_x = new_x - bureau.xd;
					adr_desk[object].ob_y = new_y - bureau.yd;
					form_dial (FMD_FINISH, 0, 0, 0, 0, old_x + bureau.xd, old_y + bureau.yd,
										 adr_desk[object].ob_width, adr_desk[object].ob_height);
					form_dial (FMD_FINISH, 0, 0, 0, 0,
										 adr_desk[object].ob_x + bureau.xd, adr_desk[object].ob_y + bureau.yd,
										 adr_desk[object].ob_width, adr_desk[object].ob_height);
				}
				else if (((object == BU_BOXTXT) || (object == BU_TXT1) || (object == BU_TXT2)) && (mk == 1))
				{		/* textes encore cliqu‚s -> d‚placement */
					old_x = adr_desk[BU_BOXTXT].ob_x;
					old_y = adr_desk[BU_BOXTXT].ob_y;
					graf_dragbox (adr_desk[BU_BOXTXT].ob_width, adr_desk[BU_BOXTXT].ob_height,
												adr_desk[BU_BOXTXT].ob_x + bureau.xd, adr_desk[BU_BOXTXT].ob_y + bureau.yd,
												bureau.xd, bureau.yd, bureau.wd, bureau.hd, &new_x, &new_y);
					adr_desk[BU_BOXTXT].ob_x = new_x - bureau.xd;
					adr_desk[BU_BOXTXT].ob_y = new_y - bureau.yd;
					form_dial (FMD_FINISH, 0, 0, 0, 0, old_x + bureau.xd - 3, old_y + bureau.yd - 3,
										 adr_desk[BU_BOXTXT].ob_width + 6, adr_desk[BU_BOXTXT].ob_height + 6);
					form_dial (FMD_FINISH, 0, 0, 0, 0,
										 adr_desk[BU_BOXTXT].ob_x + bureau.xd - 3, adr_desk[BU_BOXTXT].ob_y + bureau.yd - 3,
										 adr_desk[BU_BOXTXT].ob_width + 6, adr_desk[BU_BOXTXT].ob_height + 6);
				}
				else if ((object == ZERO) && (adr_desk[BU_ICN].ob_state & SELECTED) && (mk == 0))
				{		/* Bureau cliqu‚ -> d‚s‚lectionner */
					adr_desk[BU_ICN].ob_state &= ~SELECTED;
					form_dial (FMD_FINISH, 0, 0, 0, 0,
									 adr_desk[BU_ICN].ob_x + bureau.xd, adr_desk[BU_ICN].ob_y + bureau.yd,
									 adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height);
				}
				else if ((object == BU_ICN) && NOT (adr_desk[BU_ICN].ob_state & SELECTED) && (mk == 0))
				{		/* Ic“ne clic simple -> s‚lectionner */
					adr_desk[BU_ICN].ob_state |= SELECTED;
					form_dial (FMD_FINISH, 0, 0, 0, 0,
									 adr_desk[BU_ICN].ob_x + bureau.xd, adr_desk[BU_ICN].ob_y + bureau.yd,
									 adr_desk[BU_ICN].ob_width, adr_desk[BU_ICN].ob_height);
				}
			}
		} while (NOT quit);
		if (fgdos)
			vst_unload_fonts (work_display.handle, 0);
		end ();
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
	if (_app)
		menu_tnormal (adr_menu, T_FICHIER, 0); 	/* Inverser titre */
	else
	{
		win[WINDACC].w_bar[T_FICHIER + 3].ob_state |= SELECTED;
		draw_object (T_FICHIER + 3, WINDACC);
	}
	wind_update (BEG_MCTRL);								/* Bloquer menu */
#if INTGR
	adr = rs_trindex[FORMULAIRE];
#else
	rsrc_gaddr (R_TREE, FORMULAIRE, &adr);
#endif
	if (work_display.n_color >= 16)
	{
		adr->ob_spec.obspec.interiorcol = 8;
		adr->ob_spec.obspec.fillpattern = 7;
		adr[TXT1].ob_spec.tedinfo->te_color = 8;
		adr[TXT1].ob_spec.tedinfo->te_color |= 7 << 4;
		adr[TXT1].ob_spec.tedinfo->te_color |= (1 << 8);
		adr[TXT2].ob_spec.tedinfo->te_color = 8;
		adr[TXT2].ob_spec.tedinfo->te_color |= 7 << 4;
		adr[TXT2].ob_spec.tedinfo->te_color |= (1 << 8);
	}
	bak_rsc (adr, &adr_bakrsc);
	formm_draw (adr, TXT1, TRUE, &img);
	do
	{
		if (dialog (DLG_FORM, adr, FALSE, FALSE, BLANK, &img, TRUE))
		{
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
		}
	} while (NOT quit);
	formm_undraw (adr, &img);
	if (adr_bakrsc)							/* Si ‚tat formulaire sauvegard‚ */
		free (adr_bakrsc);
	wind_update (END_MCTRL);								/* D‚bloquer menu */
	if (_app)
		menu_tnormal (adr_menu, T_FICHIER, 1); 	/* Inverser titre */
	else
	{
		win[WINDACC].w_bar[T_FICHIER + 3].ob_state &= ~SELECTED;
		draw_object (T_FICHIER + 3, WINDACC);
	}
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
		win[index].w_bar[tit].ob_state |= SELECTED;
		draw_object (tit, index);
	}
	if (_app)
		menu_tnormal (adr_menu, T_BUREAU, 0); /* Inverser titre */
	wind_update (BEG_MCTRL);							/* Bloquer menu */
#if INTGR
	adr = rs_trindex[INFOS];
#else
	rsrc_gaddr (R_TREE, INFOS, &adr);
#endif
	if (work_display.n_color >= 16)
	{
		adr->ob_spec.obspec.interiorcol = 8;
		adr->ob_spec.obspec.fillpattern = 7;
	}
	formm_draw (adr, BLANK, FALSE, &img);
	do
	{
		dialog (DLG_FORM, adr, FALSE, FALSE, BLANK, &img, FALSE);
		if (object == INF_SORTIE)
			quit = TRUE;
	} while (NOT quit);
	formm_undraw (adr, &img);
	wind_update (END_MCTRL);							/* D‚bloquer menu */
	if (_app)
		menu_tnormal (adr_menu, T_BUREAU, 1); /* Inverser titre */
	if (menuf)
	{
		win[index].w_bar[tit].ob_state &= ~SELECTED;
		draw_object (tit, index);
	}
}
/* #] aff_infos () Infos sur BIG :																	*/ 
/* #[ test_alerte () Affichage d'alertes BIG :											*/
void test_alerte (void)
{
	big_alert (1, AL_POINTEUR, "", TRUE);
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
	if (work_display.n_color >= 16)
	{
		adr->ob_spec.obspec.interiorcol = 8;
		adr->ob_spec.obspec.fillpattern = 7;
		adr[PF_CHAMP1].ob_spec.tedinfo->te_color = 8;
		adr[PF_CHAMP1].ob_spec.tedinfo->te_color |= 7 << 4;
		adr[PF_CHAMP1].ob_spec.tedinfo->te_color |= (1 << 8);
		adr[PF_CHAMP2].ob_spec.tedinfo->te_color = 8;
		adr[PF_CHAMP2].ob_spec.tedinfo->te_color |= 7 << 4;
		adr[PF_CHAMP2].ob_spec.tedinfo->te_color |= (1 << 8);
		adr[PF_CHAMP3].ob_spec.tedinfo->te_color = 8;
		adr[PF_CHAMP3].ob_spec.tedinfo->te_color |= 7 << 4;
		adr[PF_CHAMP3].ob_spec.tedinfo->te_color |= (1 << 8);
		adr[PF_CHAMP4].ob_spec.tedinfo->te_color = 8;
		adr[PF_CHAMP4].ob_spec.tedinfo->te_color |= 7 << 4;
		adr[PF_CHAMP4].ob_spec.tedinfo->te_color |= (1 << 8);
	}
	if (_app)
		menu_tnormal (adr_menu, T_FENETRES, 0);
	else
	{
		win[WINDACC].w_bar[T_FENETRES + 3].ob_state |= SELECTED;
		draw_object (T_FENETRES + 3, WINDACC);
		win[WINDACC].w_bar[T_FENETRES + 3].ob_state &= ~SELECTED;
		draw_object (T_FENETRES + 3, WINDACC);
	}
	if (_app)
	{
		for (i = TRAME_1 ; i <= TRAME_8 ; i++)
		{
			adr[i].ob_state &= ~SELECTED;
			if (adr_desk->ob_spec.obspec.fillpattern == adr[i].ob_spec.obspec.fillpattern)
				adr[i].ob_state |= SELECTED;
		}
	}
	formw_draw (adr, PETIT_FORM, TITRE_PF, BLANK, PF_CHAMP1, TRUE, WATR_FORM, winicn);
	if (_app)
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
	form_dial (FMD_FINISH, 0, 0, 0, 0, bureau.xd, bureau.yd, bureau.wd, bureau.hd);
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
	if (work_display.n_color >= 16)
	{
		adr->ob_spec.obspec.interiorcol = 8;
		adr->ob_spec.obspec.fillpattern = 7;
	}
	if (_app)
		menu_tnormal (adr_menu, T_FENETRES, 0);
	else
	{
		win[WINDACC].w_bar[T_FENETRES + 3].ob_state |= SELECTED;
		draw_object (T_FENETRES + 3, WINDACC);
		win[WINDACC].w_bar[T_FENETRES + 3].ob_state &= ~SELECTED;
		draw_object (T_FENETRES + 3, WINDACC);
	}
	formw_draw (adr, GRAND_FORM, TITRE_GF, BLANK, BLANK, FALSE, WATR_CURR, winicn);
	if (_app)
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
						 adr_desk[BU_TXT1 - 1].ob_x, adr_desk[BU_TXT1 - 1].ob_y + bureau.yd,
						 adr_desk[BU_TXT1 - 1].ob_width, adr_desk[BU_TXT1 - 1].ob_height);
	adr_desk[BU_ICN].ob_spec.iconblk->ib_pdata = adr[GF_ICN].ob_spec.bitblk->bi_pdata;
	form_dial (FMD_FINISH, 0, 0, 0, 0,
						 adr_desk[BU_ICN].ob_x, adr_desk[BU_ICN].ob_y + bureau.yd,
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

	if (win[TEXTE].w_icon > BLANK)
		return;

	if (_app)
		menu_tnormal (adr_menu, T_FENETRES, 0);
	else
	{
		win[WINDACC].w_bar[T_FENETRES + 3].ob_state |= SELECTED;
		draw_object (T_FENETRES + 3, WINDACC);
		win[WINDACC].w_bar[T_FENETRES + 3].ob_state &= ~SELECTED;
		draw_object (T_FENETRES + 3, WINDACC);
	}
	if ((fgdos) && (fid != 1))		/* Prendre la taille boŒtes caractŠres */
	{
		vst_font (work_display.handle, fid);
		vst_arbpt (work_display.handle, size, &dummy, &dummy, &dummy, &h_cell);
		vst_setsize (work_display.handle, size, &dummy, &dummy, &w_cell, &dummy);
	}
	else
		vst_height (work_display.handle, size, &dummy, &dummy, &w_cell, &h_cell);
	Fsetdta (&dtabuffer);							/* Adresse infos sur le fichier */
	path (chemin);										/* Chemin de l'application */
	selec = get_string (CHARGETXT);		/* R‚cup‚rer message s‚lecteur */
	if (selector (chemin, "\*.TXT", fname, selec) == TRUE && strlen (fname))
	{					/* Si un fichier a ‚t‚ choisi */
		strcpy (fichier, chemin);
		strcat (fichier, fname);					/* Reconstituer son chemin d'accŠs */
		if (Fsfirst (fichier, 0) == 0)		/* S'il existe */
		{
			longueur = dtabuffer.d_length;	/* Prendre sa longueur */
			if (win[TEXTE].w_cont.w_adr)
				free (win[TEXTE].w_cont.w_adr);	/* Lib‚rer le pr‚c‚dent s'il y en a */
			win[TEXTE].w_cont.w_adr = (char *)malloc (longueur);	/* R‚server m‚moire */
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
										 bureau.xd + 10, bureau.yd + (bureau.hd / 4), bureau.wd - 20, bureau.hd / 2,
										 100, 100, w_cell, h_cell, TRUE, FALSE, TEXT_CRSR,
										 winicn, aff_texte, close_txt, get_string (TIT_TXT), "",
										 (long) ((long) MAX_LEN * (long) w_cell),
										 (long) ((long) count * (long) h_cell),
										 FALSE, TRUE, TOOL);
			}
		}
	}
	if (_app)
		menu_tnormal (adr_menu, T_FENETRES, 1);
}
/* #] charge_texte () Chargement texte Ascii en fenˆtre :						*/ 
/* #[ aff_texte () Affichage du texte :															*/
void aff_texte (void)
{
char *ptr;
int i, x, y, pxy[4], count = 0, lignes, xw, yw, ww, hw, dummy, 	id, wcell, hcell, extent[8], largeur;
char fontname [35];

	if (win[TEXTE].w_cont.w_adr)
	{
		if (fgdos)
		{
			vst_font (work_display.handle, fid);
			vst_arbpt (work_display.handle, size, &dummy, &dummy, &dummy, &hcell);
			vst_setsize (work_display.handle, size, &dummy, &dummy, &wcell, &dummy);
		}
		else
			vst_height (work_display.handle, size, &dummy, &dummy, &wcell, &hcell);
		lignes = (int)(win[TEXTE].w_htot / (long)win[TEXTE].w_hunit) - 1;	/* Nbre de lignes */
		vst_alignment (work_display.handle, 0, 5, &dummy, &dummy);	/* En haut … gauche */
		vst_effects (work_display.handle, 0);		/* D‚sactiver tous les effets */
		ptr = win[TEXTE].w_cont.w_adr;								/* D‚but du texte */
		for (i = 0 ; i < (win[TEXTE].w_lin / win[TEXTE].w_hunit) ; i++)
		{
			ptr += (strlen (ptr) + 2);		/* Sauter au d‚but de l'affichage */
			count++;
		}
		zone_work (TEXTE, &xw, &yw, &ww, &hw);
		pxy[0] = xw;								/* Pr‚parer effacement fenˆtre */
		pxy[1] = yw - 1;
		pxy[2] = xw + ww - 1;
		pxy[3] = yw + hw - 1;
		vswr_mode (work_display.handle, MD_REPLACE);		/* Dessin en mode Remplacement */
		if (win[TEXTE].w_bar[TL_INV].ob_state & SELECTED)	/* Si invers‚ */
		{
			vsf_color (work_display.handle, 1);						/* Couleur noire */
			vsf_interior (work_display.handle, 1);
			vst_color (work_display.handle, 0);
		}
		else
		{
			vsf_color (work_display.handle, 0);						/* Couleur blanche */
			vsf_interior (work_display.handle, 0);
			vst_color (work_display.handle, 1);
		}
		v_bar (work_display.handle, pxy);							/* "Vider" la fenˆtre */
		y = yw;										/* Positionner l'affichage des lignes */
		vswr_mode (work_display.handle, MD_TRANS);		/* Dessin en mode Transparent */
		while ((y < yw + hw) && (count < lignes))
		{
			if (fgdos)
				vqt_f_extent (work_display.handle, ptr, extent);
			else
				vqt_extent (work_display.handle, ptr, extent);
			largeur = extent[2] - extent[0];
			if (win[TEXTE].w_bar[TL_LEFT].ob_state & SELECTED)
				x = xw - (int)win[TEXTE].w_col;
			else if (win[TEXTE].w_bar[TL_CENTER].ob_state & SELECTED)
				x = xw + (((int)win[TEXTE].w_wtot - largeur) / 2) - (int)win[TEXTE].w_col;
			else if (win[TEXTE].w_bar[TL_RIGHT].ob_state & SELECTED)
				x = xw + ((int)win[TEXTE].w_wtot - largeur) - (int)win[TEXTE].w_col;

			if (fgdos)								/* Ecrire chaque ligne */
				v_ftext (work_display.handle, x, y, ptr);
			else
				v_gtext (work_display.handle, x, y, ptr);

			count++;
			ptr += strlen (ptr) + 2;
			y += hcell;
		}
		if (fgdos)
		{
			id = vqt_name (work_display.handle, 1, fontname);
			vst_font (work_display.handle, id);
			vst_arbpt (work_display.handle, 13, &dummy, &dummy, &dummy, &hcell);
			vst_setsize (work_display.handle, 13, &dummy, &dummy, &wcell, &dummy);
		}
	}
}
/* #] aff_texte () Affichage du texte :															*/ 
/* #[ set_font () Choix fonte et taille :														*/
void set_font (void)
{
int id, ident, wcell, hcell, dummy;
char chaine[35];

	size = atoi (get_text (win[TEXTE].w_bar, TL_SIZE));
	ident = match (win[TEXTE].w_bar, TL_FONT);
	if (ident)
	{
		fid = vqt_name (work_display.handle, ident, chaine);
		vst_font (work_display.handle, fid);
		if (ident > 1)
		{
			vst_arbpt (work_display.handle, size, &dummy, &dummy, &dummy, &hcell);
			vst_setsize (work_display.handle, size, &dummy, &dummy, &wcell, &dummy);
		}
		else
			vst_height (work_display.handle, size, &dummy, &dummy, &wcell, &hcell);
		win[TEXTE].w_htot = (win[TEXTE].w_htot / (long)win[TEXTE].w_hunit) * hcell;
		win[TEXTE].w_col = (win[TEXTE].w_col / (long)win[TEXTE].w_wunit) * wcell;
		win[TEXTE].w_lin = (win[TEXTE].w_lin / (long)win[TEXTE].w_hunit) * hcell;
		win[TEXTE].w_wunit = wcell;
		win[TEXTE].w_hunit = hcell;
		id = vqt_name (work_display.handle, 1, chaine);
		vst_font (work_display.handle, id);
	}
	height_sliders (TEXTE);
}
/* #] set_font () Choix fonte et taille :														*/ 
/* #[ close_txt () Ferme la fenˆtre texte :													*/
void close_txt (void)
{
	if (win[TEXTE].w_hg > 0)
	{
		buf[3] = win[TEXTE].w_hg;
		closed ();
		if (win[TEXTE].w_cont.w_adr)
		{
			free (win[TEXTE].w_cont.w_adr);
			win[TEXTE].w_cont.w_adr = 0L;
		}
	}
}
/* #] close_txt () Ferme la fenˆtre texte :													*/ 
/* #[ charge_image () Chargement image Degas en fenˆtre :						*/
void charge_image (void)
{
char chemin[125], fname[13] = "", fichier[125], *selec;
int longueur = 32000, reso, fh, index, fmenu, menu, souris, i, pal;
static int table[] = {0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 1};

	if (buf[0] == BEV_WMENU)
	{
		index = WINDMENU;
		win[buf[5]].w_bar[buf[3]].ob_state |= SELECTED;
		draw_object (buf[3], buf[5]);
		fmenu = TRUE;
		menu = W_MENU;
		souris = THIN_CROSS;
	}
	else if (buf[0] == BEV_WHIER)
	{
		index = IMAGE;
		win[buf[7]].w_bar[buf[3]].ob_state |= SELECTED;
		draw_object (buf[3], buf[7]);
		win[buf[7]].w_bar[buf[3]].ob_state &= ~SELECTED;
		draw_object (buf[3], buf[7]);
		fmenu = FALSE;
		menu = MENU;
		souris = POINT_HAND;
	}
	else
	{
		index = IMAGE;
		menu_tnormal (adr_menu, T_FENETRES, 0);
		fmenu = FALSE;
		menu = BLANK;
		souris = POINT_HAND;
	}

	if ((index == IMAGE) && (win[index].w_icon > BLANK))
	{
		if (_app)
			menu_tnormal (adr_menu, T_FENETRES, 1);
		else
		{
			win[WINDACC].w_bar[T_FENETRES + 3].ob_state &= ~SELECTED;
			draw_object (T_FENETRES + 3, WINDACC);
			win[WINDACC].w_bar[T_FENETRES + 3].ob_state &= ~SELECTED;
			draw_object (T_FENETRES + 3, WINDACC);
		}
		return;
	}

	path (chemin);										/* Chemin de l'application */
	selec = get_string (CHARGEIMG);		/* R‚cup‚rer message s‚lecteur */
	if (selector (chemin, "\*.PI?", fname, selec) == TRUE && strlen (fname))
	{					/* Si un fichier a ‚t‚ choisi */
		strcpy (fichier, chemin);
		strcat (fichier, fname);					/* Reconstituer son chemin d'accŠs */
		if (exist (fichier, 0))					/* S'il existe */
		{
			if (win[index].w_cont.w_img.fd_addr)
				free (win[index].w_cont.w_img.fd_addr);	/* Lib‚rer le pr‚c‚dent s'il y en a */
			win[index].w_cont.w_img.fd_addr = (char *)malloc (longueur);	/* R‚server m‚moire */
			if (win[index].w_cont.w_img.fd_addr)
			{
				fh = (int)Fopen (fichier, FO_READ);								/* Ouvrir le fichier */
				Fread (fh, 2, &reso);
				win[index].w_cont.w_img.fd_w = 640 - ((reso == 0) * 320);
				win[index].w_cont.w_img.fd_h = 200 + ((reso == 2) * 200);
				win[index].w_cont.w_img.fd_wdwidth = win[index].w_cont.w_img.fd_w / 16;
				win[index].w_cont.w_img.fd_stand = 1;
				win[index].w_cont.w_img.fd_nplanes = work_display.n_plane;
				if (index == WINDMENU)
					free (win[WINDMENU].w_pal);
				win[index].w_pal = (Palette *)malloc (16 * sizeof (Palette));
				for (i = 0 ; i < 16 ; i++)
				{				/* Charger la palette et la changer en indexs VDI */
					Fread (fh, 2, &pal);
					win[index].w_pal[table[i]][0] = ((pal >> 8) * 143) - 72;
					win[index].w_pal[table[i]][1] = (((pal >> 4) & 0xf) * 143) - 72;
					win[index].w_pal[table[i]][2] = ((pal & 0xf) * 143) - 72;
				}

				Fread (fh, longueur, win[index].w_cont.w_img.fd_addr);	/* Charger image */
				Fclose (fh);																	/* Refermer fichier */

				if (open_window (index, WTYP_PICT, WATR_CURR,
												 bureau.xd + (bureau.wd / 3), bureau.yd + (bureau.hd / 3), 320, 150,
												 100, 100, 16, 16, TRUE, TRUE, souris,
												 winicn, ZERO, close_img, get_string (TIT_IMG), "",
												 (long) win[index].w_cont.w_img.fd_w,
												 (long) win[index].w_cont.w_img.fd_h,
												 fmenu, FALSE, menu))
				{
					if (index == WINDMENU)
						win[index].w_close = close_wmenu;
				}
			}
		}
	}
	if (index == WINDMENU)
	{
		win[buf[5]].w_bar[buf[3]].ob_state &= ~SELECTED;
		draw_object (buf[3], buf[5]);
		height_sliders (index);
	}
	else
	{
		if (_app)
			menu_tnormal (adr_menu, T_FENETRES, 1);
	}
}
/* #] charge_image () Chargement image Degas en fenˆtre :						*/ 
/* #[ close_img () Ferme la fenˆtre image :													*/
void close_img (void)
{
	if (win[IMAGE].w_hg > 0)
	{
		buf[3] = win[IMAGE].w_hg;
		closed ();
		if (win[IMAGE].w_cont.w_img.fd_addr)
		{
			free (win[IMAGE].w_cont.w_img.fd_addr);
			win[IMAGE].w_cont.w_img.fd_addr = 0L;
			free (win[IMAGE].w_pal);	/* Lib‚rer la m‚moire palette */
			win[IMAGE].w_pal = (Palette *)ZERO;
		}
	}
}
/* #] close_img () Ferme la fenˆtre image :													*/ 
/* #[ cree_histo () Cr‚er histo et ouvrir fenˆtre :									*/
void cree_histo (void)
{
register int i;

	if (win[HISTO].w_icon > BLANK)
		return;						/* Pas si fenˆtre ic“nis‚e */
	if (win[HISTO].w_cont.w_adr)
		free (win[HISTO].w_cont.w_adr);		/* Lib‚rer le pr‚c‚dent s'il y en a */
	win[HISTO].w_cont.w_adr = malloc (8);
	for (i = 0 ; i < 8 ; i++)
		*(win[HISTO].w_cont.w_adr + i) = (rand () & 0xFF);
	if (open_window (HISTO, WTYP_NORM, (NAME|CLOSER|MOVER|SIZER|FULLER|INFO|SMALLER),
									 bureau.xd + (bureau.wd / 6), bureau.yd + (bureau.hd / 6), bureau.wd / 3, bureau.hd / 3,
									 100, 100, 1, 1, TRUE, TRUE, ZERO, winicn, aff_histo, close_histo,
									 get_string (TIT_HIST), get_string (INF_HIST),
									 1L, 1L, FALSE, FALSE, BLANK))
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
	vswr_mode (work_display.handle, MD_REPLACE);		/* Dessin en mode Remplacement */
	vsf_perimeter (work_display.handle, TRUE);	/* Dessiner le p‚rimŠtre */
	vsf_color (work_display.handle, 0);		/* Couleur blanche */
	vsf_interior (work_display.handle, 0); /* Motif de remplissage vide */
	v_bar (work_display.handle, pxy);			/* "Vider" la fenˆtre */
		/* 8 pixels de chaque cot‚ et entre chaque histo */
	largeur = (ww - (16) - (7 * 8)) / 8;
	for (i = 0 ; i < 8 ; i++)
		maxi = max (maxi, datas[i]);
	vsf_color (work_display.handle, 2);		/* Couleur rouge */
	vsf_interior (work_display.handle, FIS_PATTERN); /* Motif de remplissage tram‚ */
	pxy[3] = yw + hw - 8;
	for (i = 0 ; i < 8 ; i++)
	{
		vsf_style (work_display.handle, i + 1);	/* La trame */
		pxy[0] += 8;
		hauteur = (int)((double)datas[i] / (double)maxi * ((double)hw - 16));
		pxy[1] = yw + hw - 8 - hauteur;
		pxy[2] = pxy[0] + largeur;
		v_bar (work_display.handle, pxy);			/* Dessiner l'histo */
		pxy[0] += largeur;
	}
}
/* #] aff_histo () Affichage de l'histogramme :											*/ 
/* #[ sized_histo () Redraw si dimensionnement :										*/
void sized_histo (void)
{
int w, h;

	w = win[HISTO].w_curr.g_w;	/* Enregistrer dimensions courantes */
	h = win[HISTO].w_curr.g_h;
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
						&win[HISTO].w_curr.g_x, &win[HISTO].w_curr.g_y,
						&win[HISTO].w_curr.g_w, &win[HISTO].w_curr.g_h);
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
			free (win[HISTO].w_cont.w_adr);
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
		if (win[WINDMENU].w_cont.w_img.fd_addr)
		{
			free (win[WINDMENU].w_cont.w_img.fd_addr);
			win[WINDMENU].w_cont.w_img.fd_addr = 0L;
			free (win[WINDMENU].w_pal);	/* Lib‚rer la m‚moire palette */
			win[WINDMENU].w_pal = (Palette *)ZERO;
		}
	}
}
/* #] close_wmenu () Ferme la fenˆtre image avec menu :							*/ 
/* #[ icone () Alerte avec choix ic“ne :														*/
void icone (void)
{
char icn;
char *alrt;

	win[buf[7]].w_bar[buf[3]].ob_state |= SELECTED;
	draw_object (buf[3], buf[7]);
	icn = buf[6] + 47;
	alrt = get_string (AL_ICONES);
	alrt[1] = icn;
	big_alert (1, BLANK, alrt, TRUE);
	win[buf[7]].w_bar[buf[3]].ob_state &= ~SELECTED;
	draw_object (buf[3], buf[7]);
}
/* #] icone () Alerte avec choix ic“ne :														*/ 
/* #[ winicn () Routine de redraw de fenˆtre ic“nifi‚e :						*/
void winicn (void)
{
int index, xw, yw, ww, hw, pxy[8], w, h, color[2];
BITBLK *img;
MFDB nul = {0}, pic;

	index = find_index (buf[3]);

#if INTGR
	if (win[index].w_type == WTYP_FORM)		/* R‚cup‚rer l'image */
		img = rs_frimg[ICN_WF];
	else
		img = rs_frimg[ICN_WN];
#else
	if (win[index].w_type == WTYP_FORM)
		rsrc_gaddr (R_FRIMG, ICN_WF, &img);	/* Adr image pointeur sur pointeur */
	else
		rsrc_gaddr (R_FRIMG, ICN_WN, &img);
	img = *((BITBLK **)img);							/* Pointeur sur l'image */
#endif

	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);

	vswr_mode (work_display.handle, MD_REPLACE);				/* Vider la fenˆtre */
	vsf_perimeter (work_display.handle, 0);
	vsf_color (work_display.handle, 0);
	pxy[0] = xw;
	pxy[1] = yw;
	pxy[2] = xw + ww - 1;
	pxy[3] = yw + hw - 1;
	v_bar (work_display.handle, pxy);

	w = 31;							/* Pr‚parer affichage de l'image */
	h = 31;
	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = w;
	pxy[3] = h;
	pxy[4] = xw + ((ww - w) / 2);
	pxy[5] = yw + ((hw - h) / 2);
	pxy[6] = pxy[4] + w;
	pxy[7] = pxy[5] + h;
	pic.fd_addr = (void *) img->bi_pdata;
	pic.fd_w = w;
	pic.fd_h = h;
	pic.fd_wdwidth = 2;
	pic.fd_stand = 0;
	pic.fd_nplanes = 1;

	color[0] = BLACK;
	color[1] = WHITE;
  vrt_cpyfm (work_display.handle, MD_REPLACE, pxy, &pic, &nul, color);
}
/* #] winicn () Routine de redraw de fenˆtre ic“nifi‚e :						*/ 
/* #[ red_acc () Redraw fenˆtre ppale si accessoire :								*/
void red_acc (void)
{
int xw, yw, ww, hw, pxy[4];

	zone_work (WINDACC, &xw, &yw, &ww, &hw);
	vswr_mode (work_display.handle, MD_REPLACE);
	vsf_perimeter (work_display.handle, FALSE);
	vsf_color (work_display.handle, 2);
	vsf_interior (work_display.handle, 2);
	vsf_style (work_display.handle, 2);
	pxy[0] = xw;
	pxy[1] = yw;
	pxy[2] = pxy[0] + ww - 1;
	pxy[3] = pxy[1] + hw - 1;
	v_bar (work_display.handle, pxy);
}
/* #] red_acc () Redraw fenˆtre ppale si accessoire :								*/ 
/* #[ clos_acc () Fermeture fenˆtre ppale si accessoire :						*/
void clos_acc (void)
{
int i = ZERO;

	do			/* Pour chaque fenˆtre */
	{
		if (((win[i].w_hg > ZERO) || (win[i].w_icon > BLANK)) && (i != WINDACC))
		{				/* Fermer chaque fenˆtre */
			if (NOT (win[i].w_icon > BLANK))	/* Si pas ic“nis‚e */
			{
				buf[3] = win[i].w_hg;
				(*win[i].w_close)();
			}
			else if (win[i].w_icon > BLANK)		/* Si ic“nis‚e */
			{
				win[i].w_attr = win[i].w_old.w_att;						/* Restaurer attributs */
				win[i].w_curr.g_x = win[i].w_old.w_coord.g_x;	/* Restaurer coordonn‚es */
				win[i].w_curr.g_y = win[i].w_old.w_coord.g_y;
				win[i].w_curr.g_w = win[i].w_old.w_coord.g_w;
				win[i].w_curr.g_h = win[i].w_old.w_coord.g_h;
				win[i].w_old.w_coord.g_x = win[i].w_old.w_coord.g_y =
						win[i].w_old.w_coord.g_w = win[i].w_old.w_coord.g_h = ZERO;
				if (win[i].w_icon == i)					/* Si ic“nis‚e seule */
				{
					buf[3] = win[i].w_hg;		/* appeler sa fonction de fermeture */
					(*win[i].w_close)();
				}
				win[i].w_icon = BLANK;
			}
		}
	} while (NOT (win[i++].w_flags & WFLAST));
	if (win[WINDACC].w_icon > BLANK)
	{
		win[WINDACC].w_attr = win[WINDACC].w_old.w_att;
		win[WINDACC].w_curr.g_x = win[WINDACC].w_old.w_coord.g_x;
		win[WINDACC].w_curr.g_y = win[WINDACC].w_old.w_coord.g_y;
		win[WINDACC].w_curr.g_w = win[WINDACC].w_old.w_coord.g_w;
		win[WINDACC].w_curr.g_h = win[WINDACC].w_old.w_coord.g_h;
		win[WINDACC].w_old.w_coord.g_x = win[WINDACC].w_old.w_coord.g_y =
				win[WINDACC].w_old.w_coord.g_w = win[WINDACC].w_old.w_coord.g_h = ZERO;
		win[WINDACC].w_icon = BLANK;
	}
	if (buf[0] != AC_CLOSE)
	{
		wind_close (win[WINDACC].w_hg);
		wind_delete (win[WINDACC].w_hg);
	}
	win[WINDACC].w_hg = ZERO;
}
/* #] clos_acc () Fermeture fenˆtre ppale si accessoire :						*/ 
/* #[ acc_loop () Boucle d'attente appel accessoire :								*/
void acc_loop (void)
{
int accrun = FALSE;

	do
	{
		evnt_mesag (buf);
		if (buf[0] == AC_OPEN)
		{
			if (open_window (WINDACC, WTYP_NORM,
											 (NAME|CLOSER|FULLER|MOVER|SIZER|SMALLER),
											 bureau.xd + 20, bureau.yd + (bureau.hd / 3), bureau.wd / 2, bureau.hd / 3,
											 100, 100, 10, 10, TRUE, TRUE, FALSE,
											 winicn, red_acc, clos_acc,
											 get_string (TW_ACC), "",
											 (long) bureau.wd, (long) bureau.hd,
											 TRUE, FALSE, MENU))
				accrun = TRUE;
		}
	} while (NOT accrun);
}
/* #] acc_loop () Boucle d'attente appel accessoire :								*/ 
/* #[ relief () effet de relief en monochrome :											*/
void relief (void)
{
OBJECT *adr;
int i, tab[] = {AIDE1, CONTACT, AIDE2, MERCI, TOOL};

	for (i = 0 ; i < 5 ; i++)
	{
#if INTGR
		adr = rs_trindex[tab[i]];
#else
		rsrc_gaddr (R_TREE, tab[i], &adr);
#endif
		adr->ob_spec.obspec.interiorcol = 8;
		adr->ob_spec.obspec.fillpattern = 7;
	}
}
/* #] relief () effet de relief en monochrome :											*/ 

