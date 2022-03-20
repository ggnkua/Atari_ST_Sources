/*	"Les fenˆtres de dialogue non modales Faciles...."
*	WINFDEMO.C
*	Routines de gestion dans WINDFORM.C et d‚clarations dans WINDFORM.H
*	par Jacques DELAVOIX	Janvier 1995
*	modifi‚ par R‚mi Vanel le 20/9/95
*	Mise … jour du 24/03/96 par J. Delavoix
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "windform.h"
#include "winfdemo.h"

/*	Prototypes : */

void main(void);
void end_prog(void);
void informe(int event);
void fiche_client(int event);
void color_window(int event);
void init_prog(void);
void window_texte(int event);
void open_text(void);
void close_text(void);
void redraw(int w_handle, int x, int y, int w, int h);
void sized(void);
void fulled(void);
void arrow(void);
void vslider(void);
void sliders(void);
void set_clip(int clip_flag, GRECT *area);

/* Attributs fenˆtre principale */
#define wind_attr NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE

int x_desk, y_desk, w_desk, h_desk; /* Coordonn‚es du bureau */
int app_id, vdi_handle;
int buff[8]; 				/* Buffer d'‚v‚nements */
int mousex, mousey, key, key_s;	/* Variables de retour pour evnt_multi() */
int ligne_0 = 0; 			/* 1ø ligne de l'affichage */
int full_flag = FALSE;
int baseline;				/* pour v_gtext() */
int w_char, h_char;			/* Largeur et hauteur d'un caractŠre */
int color_3d1, color_3d2;	/* Couleurs pour objets 3D.	*/
int xf, yf, wf, hf; 		/* Coordonn‚es de la fenˆtre texte */
int hauteur_totale = 50;	/* Hauteur totale en nbr. de lignes de texte*/
int text_handle = 0;		/* handle fenˆtre */
int couleur;				/* couleur de fond pour la fenˆtre texte. */
int wtop;					/* fenetre actuellement active */
OBJECT *adr_menu;			/* Adresse du menu */

WINDFORM_VAR infos_var;		/* Structures de variables pour form_windows */
WINDFORM_VAR client_var;
WINDFORM_VAR color_var;

/************************************************************************/

void main(void)
{
	int quit = 0, event, dummy;
	init_prog();
	menu_bar(adr_menu, 1);

	xf = x_desk + 10;	/* Coordonn‚es de d‚part de la fenˆtre */
	yf = y_desk + 10;
	wf = w_desk / 2;
	hf = h_desk / 2;
	open_text();		/* Ouverture de la fenˆtre de texte */
	informe(OPEN_DIAL);
	color_window(OPEN_DIAL);
	fiche_client(OPEN_DIAL);
	graf_mouse(ARROW, 0);

	do		/* BOUCLE PRINCIPALE DU PROGRAMME */
	{
		event = evnt_multi((MU_MESAG|MU_BUTTON|MU_KEYBD), 2, 1, 1,
								0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
								buff, 10, 0,
								&mousex, &mousey, &dummy, &key_s, &key, &dummy);

		wind_get(0, WF_TOP, &wtop, &dummy, &dummy, &dummy); /* R‚mi Vanel */

		if ((event & MU_MESAG) && buff[0] == MN_SELECTED)
		{
			switch (buff[4])
			{
			case INFOS :
				informe(OPEN_DIAL);
				break;
			case FICHE_CLI :
				fiche_client(OPEN_DIAL);
				break;
			case COLOR_WIND :
				color_window(OPEN_DIAL);
				break;
			case OPENW :
				open_text();
				break;
			case QUITTER :
				quit = 1;
				break;
			}
			menu_tnormal(adr_menu, buff[3], 1);
		}
		else
		{

/* *** Affecter un Handle de fenˆtre aux ‚venements qui en sont d‚pourvus : *** */

			if (event & MU_KEYBD)
				buff[3] = wtop;
			else if (event & MU_BUTTON)
				buff[3] = wind_find(mousex, mousey);

/* *** Aiguillage en fonction du Handle : *** */

			if (buff[3] > 0)						/* Si W_Handle > 0 .... */
			{
				if (buff[3] == infos_var.w_handle)
					informe(event);
				else if (buff[3] == client_var.w_handle)
					fiche_client(event);
				else if (buff[3] == color_var.w_handle)
					color_window(event);
				else if (buff[3] == text_handle)
					window_texte(event);
			}
/*			else
				gere_bureau(event); ... sinon gestion d'un objet sur le Bureau.	*/
		}
	} while (quit == 0);

/*	Avant de quitter, fermeture des fenˆres ‚ventuellement ouvertes, on peut
	aussi utiliser "wind_new()"	: */
	close_text();
	close_dialog(&infos_var);
	close_dialog(&client_var);
	close_dialog(&color_var);

	menu_bar(adr_menu, 0);
	rsrc_free();
	end_prog();
}

void end_prog(void)
{
	v_clsvwk(vdi_handle);
	appl_exit();
	exit(0);
}

/************************************************************************/
/*	Quelques routines "Utilisateur" pour l'exemple :					*/
/************************************************************************/

void informe(int event)
{
	WINDFORM_VAR *ptr_var = &infos_var;
	int choix;

	if (event == OPEN_DIAL)
	{	open_dialog(ptr_var, "Informations", 0);
		wind_set(ptr_var->w_handle,WF_BEVENT,1,0,0,0);
	}
	else
	{
		choix = windform_do(ptr_var, event);
		if (choix != 0)
		{
			if (choix == RETOUR)
			{
				change(ptr_var, choix, NORMAL, 0);
			}
			else if(choix == B_BISTABLE)
				Cconout(7);					/* "Ping" */

/* Exemple des conditions de fermeture de la fenˆtre : */
			if (choix != B_BISTABLE)
				close_dialog(ptr_var);
		}
	}
}

void fiche_client(int event)
{
	WINDFORM_VAR *ptr_var = &client_var;
	int choix;

	if (event == OPEN_DIAL)
	{	open_dialog(ptr_var, "Fiche Client", NOM);
		wind_set(ptr_var->w_handle,WF_BEVENT,1,0,0,0);
	}
	else
	{
		choix = windform_do(ptr_var, event);
		if (choix != 0)
		{
			if (choix > 0)
				change(ptr_var, choix, NORMAL, 0);
			close_dialog(ptr_var);
		}
	}
}

void color_window(int event)
{
	WINDFORM_VAR *ptr_var = &color_var;
	int choix, i, mbuf[8];
	OBJECT *ptr_col = ptr_var->adr_form;

	if (event == OPEN_DIAL)	/* Partie "Ouverture : " */
	{
		/* Exemple d'initialisation avant chaque ouverture : */
		if (ptr_var->w_handle == FALSE)	/* Test obligatoire ! */
		{
			*(ptr_col[COL_EDIT].ob_spec.tedinfo->te_ptext) = '\0';
		}
		open_dialog(ptr_var, "Couleur fond de fenˆtre", COL_EDIT);
		wind_set(ptr_var->w_handle,WF_BEVENT,1,0,0,0); /* ++ R‚mi Vanel ++ */
	}
	else		/* Sinon Partie "Gestion du dialogue" */
	{
		choix = windform_do(ptr_var, event);

		if (choix != 0)
		{
			if (choix == COL_APPLI)
				change(ptr_var, choix, NORMAL, 1); /* avec Redessin */
			else if (choix > 0)
				change(ptr_var, choix, NORMAL, 0);

			if (choix == CLOSE_DIAL) /* Transforme le clic sur case fermeture */
				choix = COL_ANNULE;  /* en choix d'Annulation. */

			if (choix > COL_ANNULE) /* Action sur "Confirmer" */
			{
				for (i = COL_0; i <= COL_15; i++)
				{
					if ((ptr_col[i].ob_state & SELECTED) != 0)
						break;
				}
				couleur = i - COL_0; /* i contient l'index du radio_button selectionn‚ */
				if (text_handle)	/* si la fenˆtre de texte est ouverte....*/
				{
					wind_get(0, WF_WORKXYWH, &mbuf[4], &mbuf[5], &mbuf[6], &mbuf[7]);
					/* envoi d'un message "WM_REDRAW" … cette fenˆtre. */
					mbuf[0] = WM_REDRAW;
					mbuf[1] = app_id;
					mbuf[2] = 0;
					mbuf[3] = text_handle;
					appl_write(app_id, 16, mbuf);
				}
			}	/* Fin de l'action "Confirmer" */
			if (choix < COL_APPLI)
				close_dialog(ptr_var); /* fermeture du dialogue */
		}
	/* Fin de "Gestion du dialogue" */
	}
}

/************************************************************************/
/*	Routine d'initialisations du programme :							*/
/************************************************************************/

void init_prog(void)
{
	int i, attributes[12], work_in[11], work_out[57];
	OBJECT *ptr_client;
	app_id = appl_init();

	vdi_handle = graf_handle(&w_char, &h_char, &i, &i);
	h_char++; /* hauteur des caractŠres + 1 pour ‚viter que les lignes de textes
ne se touchent. */

	for (i = 0 ; i < 9 ; work_in[i++] = 1);
	work_in[9] = 0;		/* Couleur de Remplissage = 0 */
	work_in[10] = 2;	/* SystŠme de coordonn‚es RC */
	v_opnvwk(work_in, &vdi_handle, work_out);

	if (work_out[13] < 16)	/* Etablissement des couleurs 3D */
	{
		color_3d1 = WHITE;	/* color index 0	*/
		color_3d2 = BLACK;	/* color index 1	*/
	}
	else
	{
		color_3d1 = LWHITE;	/* color index 8	*/
		color_3d2 = LBLACK;	/* color index 9	*/
	}

	vqt_attributes(vdi_handle, attributes);
	baseline = 1 + attributes[7]; /* Ligne de base des caractŠres + 1 pour ‚viter
que la premiŠre ligne de texte ne touche le haut de la fenˆtre. */

	/* Coordonn‚es du bureau : */
	wind_get(0, WF_WORKXYWH, &x_desk, &y_desk, &w_desk, &h_desk);

	if (load_rsc("winfdemo.rsc", NO_WINDOW) == FALSE)
	{
		end_prog();
	}
	rsrc_gaddr(0, LE_MENU, &adr_menu);
	init_var(&infos_var, INFORME, 3, 400);
	init_var(&client_var, FICHE_CLIENT, 640, 0);
	init_var(&color_var, BACK_COLOR, 0, 0);
	
/* Exemple d'initialisations de champs de texte en d‚but de programme : */

	ptr_client = client_var.adr_form;
	for (i = NOM; i <= VILLE; i++)
		*(ptr_client[i].ob_spec.tedinfo->te_ptext) = '\0';
}


/************************************************************************/
/*	et ensuite la gestion d'une fenˆtre de texte classique :			*/
/************************************************************************/

void window_texte(event)
{
	if (event & MU_MESAG)
	{
		switch(buff[0])
		{
			case WM_REDRAW :
				redraw(buff[3], buff[4], buff[5], buff[6], buff[7]);
				break;
			case WM_TOPPED :
				wind_set(buff[3], WF_TOP);
				break;
			case WM_CLOSED : 
				close_text();
				break;
			case WM_FULLED :
				fulled();
				break;
			case WM_ARROWED :
				arrow();
				break;
			case WM_VSLID :
				vslider();
				break;
			case WM_SIZED :
				sized();
				break;
			case WM_MOVED :
				wind_set(buff[3], WF_CURRXYWH, buff[4], buff[5], buff[6], buff[7]);
				xf = buff[4]; yf = buff[5]; /* m‚moriser les nouvelles coordonn‚es */
				break;
		}
	}
}

void open_text(void)
{
	if (text_handle != 0)				/* Si la fenˆtre est d‚j… ouverte */
		wind_set(text_handle, WF_TOP);	/* On la passe au premier plan */
	else
	{
		ligne_0 = 0;
		if ((text_handle = wind_create(wind_attr, x_desk, y_desk,
										w_desk, h_desk)) != 0)
		{
			wind_set(text_handle, WF_NAME, " Fenˆtre de Texte ");
			wind_open(text_handle, xf, yf, wf, hf);
			sliders();					/* Position et taille du slider V */
		}
		else
		{
			form_alert(1, rsrc_get_string(NO_WINDOW));
		}
	}
}

void close_text(void)
{
	if (text_handle)
	{
		wind_close(buff[3]);
		wind_delete(buff[3]);
		text_handle = 0;
	}
}

void redraw(int w_handle, int x, int y, int w, int h)
{
	GRECT r, rd;
	int xo, yo, wo, ho, xy[4];
	int i, y_base;
	char texte[80];
	rd.g_x = x;
	rd.g_y = y;
	rd.g_w = w;
	rd.g_h = h;
	wind_get(w_handle, WF_WORKXYWH, &xo, &yo, &wo, &ho);
	v_hide_c(vdi_handle);
	wind_update(BEG_UPDATE);
	wind_get(w_handle, WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)
	{
		if (rc_intersect(&rd, &r))
		{
			set_clip(1, &r);
			y_base = yo + baseline; /* D‚but de l'affichage en Y */
			xy[0] = r.g_x;
			xy[1] = r.g_y;
			xy[2] = xy[0]+r.g_w-1;
			xy[3] = xy[1]+r.g_h-1;
			vsf_color(vdi_handle, couleur);
			vr_recfl(vdi_handle, xy);
			vswr_mode(vdi_handle, MD_TRANS);
			for (i = ligne_0; i <= 50; i++)
			{
				sprintf(texte, " Ligne nø %d%s", i,
						" Essai d'une fenˆtre de texte.");
				v_gtext(vdi_handle, xo, y_base, texte);
				y_base += h_char; /* Prˆt pour ligne suivante. */
			}
			vswr_mode(vdi_handle, MD_REPLACE);
		}
		wind_get(w_handle, WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	wind_update(END_UPDATE);
	v_show_c(vdi_handle, 1);
}

void sized(void)
{
	wind_set(buff[3], WF_CURRXYWH, buff[4], buff[5], buff[6], buff[7]);
	full_flag = FALSE;		/* Annuler le flag de pleine ouverture */
	sliders();
	/* Enregistrer les coordonn‚es */
	wind_get(buff[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);
}

void fulled(void)
{
	int x, y, w, h;
	int mode;
	if (full_flag)	/* Si elle est d‚j… plein ‚cran */
	{
		mode = WF_PREVXYWH;
		full_flag = FALSE;
	}
	else
	{
		mode = WF_FULLXYWH;
		full_flag = TRUE;
	}
	wind_get(buff[3], mode, &x, &y, &w, &h);
	wind_set(buff[3], WF_CURRXYWH, x, y, w, h);	/* Nouvelles coordonn‚es */
	/* Enregistrer les coordonn‚es */
	wind_get(buff[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);
	sliders();	/* Ajuster tailles et positions sliders */
}

void arrow(void)
{
	int xw, yw, ww, hw;
	int action = FALSE, hauteur_page;

	wind_get(buff[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
	hauteur_page = hw / h_char;	/* Hauteur fenˆtre en lignes de caractŠres */
	switch (buff[4])
	{
	case WA_UPPAGE :				/* Page vers le haut */
		if (ligne_0 > 0)
		{
			ligne_0 = max (ligne_0 - hauteur_page, 0);
			action = TRUE;
		}
		break;
	case WA_DNPAGE :				/* Page vers le bas */
		if ((ligne_0 + hauteur_page) < hauteur_totale)
		{
			ligne_0 = min (ligne_0 + hauteur_page, hauteur_totale - hauteur_page);
			action = TRUE;
		}
		break;
	case WA_UPLINE :				/* Ligne vers le haut */
		if (ligne_0 > 0)
		{
			ligne_0--;
			action = TRUE;
		}
		break;
	case WA_DNLINE :				/* Ligne vers le bas */
		if ((ligne_0 + hauteur_page) < hauteur_totale)
		{
			ligne_0++;
			action = TRUE;
		}
		break;
	}
	if (action)
	{
		sliders();
		redraw(text_handle, xw, yw, ww, hw);
	}
}

void vslider(void)
{
	int slide, xw, yw, ww, hw, hauteur_page;
	wind_get(buff[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
	slide = buff[4];
	hauteur_page = hw / h_char;	/* Hauteur en lignes de texte */
	ligne_0 = (int)((long)slide * (hauteur_totale - hauteur_page) / 1000);
	wind_set(buff[3], WF_VSLIDE, slide);
	redraw(text_handle, xw, yw, ww, hw);
}

/*	Taille et position slider V : */

void sliders(void)
{
	int xw, yw, ww, hw, hauteur_page;
	wind_get(text_handle, WF_WORKXYWH, &xw, &yw, &ww, &hw);
	hauteur_page = hw / h_char;
	/* Taille slider vertical */
	wind_set(text_handle, WF_VSLSIZE, (int)((1000L * hauteur_page) / hauteur_totale));
	ligne_0 = min(ligne_0, hauteur_totale - hauteur_page);

	/* Position slider vertical */
	wind_set(text_handle, WF_VSLIDE, (int)((1000L * ligne_0)
			/ (hauteur_totale - hauteur_page)));
}

/***********************************************************************/

/*	Clipping :	*/

void set_clip(int clip_flag, GRECT *area)
{
	int pxy[4];
	pxy[0] = area->g_x;
	pxy[1] = area->g_y;
	pxy[2] = area->g_w + area->g_x - 1;
	pxy[3] = area->g_h + area->g_y - 1;
	vs_clip(vdi_handle, clip_flag, pxy);
}

