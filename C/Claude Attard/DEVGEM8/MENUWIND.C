/*		D‚velopper sous GEM (8)
		Gestion d'un menu en fenˆtre
		Claude ATTARD pour ST MAG
				Septembre 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "MENUWIND.H"

/* Prototypages */
void main (void);
void menu_wind (OBJECT *adr, int ob);
int boite (int ob);
int parent (OBJECT *adr, int object);
void	get_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
void	put_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
void open_work (void);
void afficher_alerte (int index);
void open_wind (void);
void redraw (int f, int x, int y, int w, int h);
int rc_intersect (GRECT *p1, GRECT *p2);
void set_clip (int clip_flag, GRECT *area);
void wmenu_tnormal (int title, int flag);
void sized (void);
void fulled (void);

/* D‚finitions et globales */
	/* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))

#define BARMENU 1
#define BARTITLE 2
#define WMN_SELECTED 100

	/* Variables globales */
int xb, yb, wb, hb; /* Coordonn‚es du bureau */
int xf, yf, wf, hf; /* Coordonn‚es de la fenˆtre */
int ap_id;					/* Identificateur application */
int handle; 				/* handle station de travail VDI */
int n_plane;				/* Nbre de plans de couleurs */
int buf[8]; 				/* Buffer d'‚v‚nements */
int mx, my, mk;			/* Position et ‚tat de la souris */
char titre[] = " Oh, le b“ menu !!! ";
int ful = 0;				/* Flag pour le traitement du "plein ‚cran" */
int hwind = 0;			/* handle fenˆtre */
int attr = (NAME|CLOSER|FULLER|MOVER|SIZER);	/* Attributs fenˆtre */

#define LIGNE 0
#define TRAME 1
#define ELLIPSE 2
int outil = LIGNE;	/* Outil de dessin courant (Ligne au d‚part) */
int color = RED;		/* Couleur courante (Rouge au d‚part) */

OBJECT *adr_desk; 	/* Adresse du bureau */
OBJECT *adr_menu; 	/* Adresse du menu principal */
OBJECT *adr_wmenu; 	/* Adresse du menu en fenˆtre */

/*  Main */
void main (void)
{
int dummy;					/* Variable "pour rien" */
int xw, yw, ww, hw;	/* Zone de travail de la fenˆtre */
int ti;							/* Titre de menu en fenˆtre cliqu‚ */
int quit = 0; 			/* Flag pour quitter */
int event;					/* Type d'‚v‚nement */

	ap_id = appl_init (); /* D‚clarer l'application au GEM */
	open_work (); 				/* Ouvrir station de travail */
	if (rsrc_load ("MENUWIND.RSC"))		/* Charger le ressource */
	{
		rsrc_gaddr (0, BUREAU, &adr_desk);	/* Demander adresse bureau */
		wind_get (0, WF_WORKXYWH, &xb, &yb, &wb, &hb);	/* Coordonn‚es du bureau */
		adr_desk->ob_x = xb;				/* Mettre le bureau aux bonnes dimensions */
		adr_desk->ob_y = yb;
		adr_desk->ob_width = wb;
		adr_desk->ob_height = hb;
		wind_set (0, WF_NEWDESK, adr_desk, 0);							/* Fixer le nouveau bureau */
		form_dial (FMD_FINISH, 0, 0, 0, 0, xb, yb, wb, hb); /* et l'afficher */

		rsrc_gaddr (0, MENUBAR, &adr_menu);	/* Demander adresse menu principal */
		menu_bar (adr_menu, 1); 						/* Afficher le menu */
		graf_mouse (ARROW, 0);							/* Souris : forme de flŠche */

		rsrc_gaddr (0, MENUW, &adr_wmenu);	/* Demander adresse menu de fenˆtre */

		xf = 25;		/* Coordonn‚es de d‚part de la fenˆtre */
		yf = 30;
		wf = 300;
		hf = 150;

		do		/* BOUCLE PRINCIPALE DU PROGRAMME */
		{ 	/* Boucle pour surveiller les ‚v‚nements */
			event = evnt_multi ((MU_BUTTON|MU_MESAG|MU_TIMER), 2, 1, 1,
													0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
													buf, 10, 0,
													&mx, &my, &mk,
													&dummy, &dummy, &dummy);
			if (event & MU_MESAG) 				/* SI EVENEMENT DE MESSAGE */
			{
				if (buf[0] == MN_SELECTED)		/* Si message de menu */
				{
					switch (buf[4]) 	/* Selon l'option de menu cliqu‚e */
					{
					case M_PROPOS : 			/* Si c'est "Infos" */
						afficher_alerte (INFOS);
						break;
					case M_OPEN :					/* Si c'est "Ouvrir fenˆtre" */
						open_wind ();
						break;
					case M_QUITTER :			/* Si c'est "Quitter" */
						quit = 1;
						break;
					}
					menu_tnormal (adr_menu, buf[3], 1); /* R‚inverser le titre de menu */
				}
				else if (buf[0] == WM_REDRAW) 	/* Si message de redraw */
					redraw (buf[3], buf[4], buf[5], buf[6], buf[7]);
				else if (buf[0] == WM_TOPPED) 	/* Si message de Top */
					wind_set (buf[3], WF_TOP);		/* Mettre la fenˆtre au 1ø plan */
				else if (buf[0] == WM_CLOSED) 	/* Si message de close */
				{
					wind_close (buf[3]);		/* Fermer la fenˆtre */
					wind_delete (buf[3]); 	/* D‚truire la fenˆtre */
					hwind = 0;	/* Noter que la fenˆtre a ‚t‚ ferm‚e */
				}
				else if (buf[0] == WM_FULLED) 	/* Si message de full */
					fulled ();
				else if (buf[0] == WM_SIZED)		/* Si message de size */
					sized ();
				else if (buf[0] == WM_MOVED)		/* Si message de move */
				{
						/* Nouvelles coordonn‚es : */
					wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
					wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);
					ful = 0;						/* Annuler le flag de pleine ouverture */
				  wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
				  adr_wmenu->ob_x = xw;		/* On repositionne le menu entier */
				  adr_wmenu->ob_y = yw;
				}
				else if (buf[0] == WMN_SELECTED)	/* Si ‚v‚nement de menu en fenˆtre */
				{
				  wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
					switch (buf[4]) 	/* Selon l'option de menu cliqu‚e */
					{
					case WM_PROPOS1 : 			/* Si c'est "Infos" */
					case WM_PROPOS2 :
					case WM_PROPOS3 :
					case WM_PROPOS4 :
					case WM_PROPOS5 :
					case WM_PROPOS6 :
					case WM_PROPOS7 :
					case WM_PROPOS8 :
					case WM_PROPOS9 :
						afficher_alerte (INFOS);
						break;
					case WM_LIGNES :			/* Si c'est "Lignes" */
						menu_icheck (adr_wmenu, outil + WM_LIGNES, 0);
						outil = LIGNE;
						menu_icheck (adr_wmenu, outil + WM_LIGNES, 1);
						redraw (hwind, xw, yw, ww, hw);
						break;
					case WM_TRAME :				/* Si c'est "Trame" */
						menu_icheck (adr_wmenu, outil + WM_LIGNES, 0);
						outil = TRAME;
						menu_icheck (adr_wmenu, outil + WM_LIGNES, 1);
						redraw (hwind, xw, yw, ww, hw);
						break;
					case WM_ELLIPSE :			/* Si c'est "Ellipse" */
						menu_icheck (adr_wmenu, outil + WM_LIGNES, 0);
						outil = ELLIPSE;
						menu_icheck (adr_wmenu, outil + WM_LIGNES, 1);
						redraw (hwind, xw, yw, ww, hw);
						break;
					case WM_NOIR :				/* Si c'est "Noir" */
						menu_icheck (adr_wmenu, color + WM_NOIR - 1, 0);
						color = BLACK;
						menu_icheck (adr_wmenu, color + WM_NOIR - 1, 1);
						redraw (hwind, xw, yw, ww, hw);
						break;
					case WM_ROUGE :				/* Si c'est "Rouge" */
						menu_icheck (adr_wmenu, color + WM_NOIR - 1, 0);
						color = RED;
						menu_icheck (adr_wmenu, color + WM_NOIR - 1, 1);
						redraw (hwind, xw, yw, ww, hw);
						break;
					case WM_VERT :				/* Si c'est "Vert" */
						menu_icheck (adr_wmenu, color + WM_NOIR - 1, 0);
						color = GREEN;
						menu_icheck (adr_wmenu, color + WM_NOIR - 1, 1);
						redraw (hwind, xw, yw, ww, hw);
						break;
					}
					wmenu_tnormal (buf[3], 1);	/* D‚s‚lectionner le titre */
				}
			}
			else if (event & MU_BUTTON)
			{
				if (wind_find (mx, my) == hwind)				/* Si clic sur notre fenˆtre */
				{
					ti = objc_find (adr_wmenu, BARTITLE, MAX_DEPTH, mx, my);	/* Objet cliqu‚ */
					if (adr_wmenu[ti].ob_type == G_TITLE)	/* Si clic sur un titre */
						menu_wind (adr_wmenu, ti);					/* On gŠre le menu en fenˆtre */
				}
			}
		} while (quit == 0);
	}
	else		/* Si le ressource n'a pas ‚t‚ charg‚ */
	{
		v_clsvwk (handle);		/* Fermer station de travail */
		appl_exit (); 				/* Quitter */
	}

		/* Avant de quitter l'application : */
	if (hwind > 0) /* Si la fenˆtre est encore ouverte */
	{
		wind_close (hwind);		/* La fermer */
		wind_delete (hwind);	/* La d‚truire */
	}
	menu_bar (adr_menu, 0); 				/* Virer la barre de menu */
	wind_set (0, WF_NEWDESK, 0, 0); /* Rendre le bureau */
	rsrc_free (); 									/* Lib‚rer le ressource */
	v_clsvwk (handle);							/* Fermer station de travail */
	appl_exit (); 									/* Quitter */
}

/*  Menu_wind : gestion principale */
void menu_wind (OBJECT *adr, int ob)
{
int xw, yw, ww, hw, bmenu, etat,
		x, y, w, h, dummy, obj, old_obj = -1, tit,
		evnt, b[8], sortie = 0;
MFDB img;

	wind_update (BEG_MCTRL);				/* Bloquer menu principal */
	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);

	while (mk)
		graf_mkstate (&dummy, &dummy, &mk, &dummy); /* Attente relacher bouton souris */

	wmenu_tnormal (ob, 0);				/* S‚lectionner titre */
	bmenu = boite (ob);						/* Chercher la boŒte de menu correspondante */
	w = adr[bmenu].ob_width;			/* Largeur de la boŒte */
	h = adr[bmenu].ob_height;			/* Hauteur de la boŒte */
	adr[bmenu].ob_x = adr[ob].ob_x + 16;	/* Replacer la boŒte sous le titre */
	adr[bmenu].ob_y = 0;
	objc_offset (adr, bmenu, &x, &y);
	if (x + w > xb + wb - 5)			/* Corriger la position si on sort du bureau */
	{
		adr[bmenu].ob_x -= ((x + w) - (xb + wb) + 5);
		objc_offset (adr, bmenu, &x, &y);
	}
	if (y + h > yb + hb - 5)
	{
		adr[bmenu].ob_y -= ((y + h) - (yb + hb) + 5);
		objc_offset (adr, bmenu, &x, &y);
	}
	get_bkgr (x, y, w, h, &img);		/* Copier l'image du fond */
	objc_draw (adr, bmenu, MAX_DEPTH, x - 3, y - 3, w + 6, h + 6);
	tit = ob;

	do
	{		/* BOUCLE D'ATTENTE */
		evnt = evnt_multi (MU_BUTTON | MU_TIMER,
											 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
											 b, 10, 0, &mx, &my, &mk, &dummy, &dummy, &dummy);
		if (evnt & MU_BUTTON)				/* Si on clique */
		{
			put_bkgr (x, y, w, h, &img);	/* Virer le menu d‚roul‚ */
			while (mk)	/* Attend que le bouton de la souris soit relƒch‚ */
				graf_mkstate (&dummy, &dummy, &mk, &dummy);
			sortie = 1;			/* On peut sortir */
		}
		else if (evnt == MU_TIMER)	/* S'il ne c'est "rien" pass‚ */
		{
			graf_mkstate (&mx, &my, &dummy, &dummy);					/* Position actuelle de la sourie */
			obj = objc_find (adr, bmenu, MAX_DEPTH, mx, my);	/* Chercher objet point‚ dans le menu */
			if (obj == -1)																		/* S'il n'y en a pas */
				obj = objc_find (adr, BARTITLE, MAX_DEPTH, mx, my);	/* Chercher titre point‚ dans la barre */

			if ((adr[obj].ob_type == G_TITLE) && (mx < (xw + ww)))	/* Si on est sur un titre et dans la fenˆtre */
			{
				if (old_obj != -1)								/* S'il on ‚tait avant sur une option */
				{
					etat = adr[old_obj].ob_state & ~SELECTED;	/* La d‚s‚lectionner */
					objc_change (adr, old_obj, 0, x, y, w, h, etat, 1);
				}
				if (obj != tit)				/* Si on a chang‚ de titre */
				{
					put_bkgr (x, y, w, h, &img);					/* Effacer l'ancien menu */
					wmenu_tnormal (tit, 1);								/* D‚s‚lectionner l'ancien */
					tit = obj;														/* Enregistrer nouveau titre courant */
					wmenu_tnormal (tit, 0);								/* S‚lectionner titre */
					bmenu = boite (tit);									/* Menu correspondant */
					w = adr[bmenu].ob_width;							/* Largeur du menu */
					h = adr[bmenu].ob_height;							/* Hauteur du menu */
					adr[bmenu].ob_x = adr[tit].ob_x + 16;	/* Le positionner sous son titre */
					adr[bmenu].ob_y = 0;
					objc_offset (adr, bmenu, &x, &y);
					if (x + w > xb + wb - 5)							/* Correction s'il sort du bureau */
					{
						adr[bmenu].ob_x -= ((x + w) - (xb + wb) + 5);
						objc_offset (adr, bmenu, &x, &y);
					}
					if (y + h > yb + hb - 5)
					{
						adr[bmenu].ob_y -= ((y + h) - (yb + hb) + 5);
						objc_offset (adr, bmenu, &x, &y);
					}
					get_bkgr (x, y, w, h, &img);
					objc_draw (adr, bmenu, MAX_DEPTH, x - 3, y - 3, w + 6, h + 6);
				}
				old_obj = -1;										/* Annuler objet courant */
			}
			else if (adr[obj].ob_type == G_STRING)	/* Si on est sur une option */
			{
				if (old_obj != obj)										/* Si objet diff‚rent de l'ancien */
				{
					if ((old_obj != -1) && (! (adr[old_obj].ob_state & DISABLED)))
					{					/* S'il y avait un objet courant non inactif */
						etat = adr[old_obj].ob_state & ~SELECTED;	/* Le d‚s‚lectionner */
						objc_change (adr, old_obj, 0, x, y, w, h, etat, 1);
					}
					if ((obj > -1) && (! (adr[obj].ob_state & DISABLED)))
					{					/* Si le nouvel objet n'est pas inactif */
						etat = adr[obj].ob_state | SELECTED;			/* Le s‚lectionner */
						objc_change (adr, obj, 0, x, y, w, h, etat, 1);
					}
					old_obj = obj;		/* Enregistrer option courante */
				}
			}
		}
	} while (! sortie);					/* Tourner jusqu'… un clic */

	if ((obj != -1) && (! (adr[obj].ob_state & DISABLED)))
	{			/* Si une option non inactive a ‚t‚ cliqu‚e */
		adr[obj].ob_state &= ~SELECTED;	/* D‚s‚lectionner l'option en m‚moire */
		buf[0] = WMN_SELECTED;	/* Num‚ro du message */
		buf[1] = ap_id; 	/* Indentificateur exp‚diteur du message */
		buf[2] = 0;     	/* Pas d'exc‚dent au message */
		buf[3] = tit;			/* Titre de menu */
		buf[4] = obj;			/* Option cliqu‚e */
		appl_write (ap_id, 16, buf);  		/* Envoi du message si option choisie */
	}
	else	/* Si on a cliqu‚ "dans le vide" ou une option inactive */
		wmenu_tnormal (tit, 1);	/* D‚s‚lectionner titre courant */

	wind_update (END_MCTRL);		/* D‚bloquer menu normal */
}

/* boite correspondant … un titre */
int boite (int ob)
{
int b, i;

	b= adr_wmenu->ob_tail;			/* Fond des boŒtes */
	b= adr_wmenu[b].ob_head;		/* 1ø boŒte */
	for (i = 3 ; i < ob ; i++)
		b= adr_wmenu[b].ob_next;	/* BoŒte suivante */
	return b;
}

/* Cherche le pŠre d'un objet */
int parent (OBJECT *adr, int object)
{
register int i;

	i = object;											/* Partir de cet objet */
	do
	{
		i = adr[i].ob_next;						/* Passer au suivant... */
	} while (i > object);						/* Jusqu'… revenir au pŠre. */

	return i;												/* Retourner le pŠre */
}

/* Sauve le fond d'un formulaire */
void	get_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img)
{
int pxy[8];
size_t taille;
MFDB ecr = {0};		/* Ecran logique */

	of_x -= 3;	/* Pr‚voir une marge de s‚curit‚ autour */
	of_y -= 3;	/* de la zone, pour le cas o— on aurait */
	of_w += 5;	/* besoin de sauvegarder le fond d'un */
	of_h += 5;	/* formulaire avec un attribut OUTLINED. */

			/* Taille tampon de copie fond */
	taille = ((((size_t)(of_w / 16) + 1) * 2 * (size_t)n_plane) * (size_t)of_h) + 256;
	img->fd_addr = malloc (taille);			/* R‚server tampon */
	img->fd_w = of_w;		/* Remplir la structure MFDB */
	img->fd_h = of_h;
	img->fd_wdwidth = (of_w / 16) + ((of_w % 16) != 0);
	img->fd_stand = 1;
	img->fd_nplanes = n_plane;

	pxy[0] = of_x;		/* Remplir la tableau */
	pxy[1] = of_y;
	pxy[2] = pxy[0] + of_w;
	pxy[3] = pxy[1] + of_h;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = of_w;
	pxy[7] = of_h;
	v_hide_c (handle);				/* Virer la souris */
	vro_cpyfm (handle, S_ONLY, pxy, &ecr, img);	/* Copier l'image */
	v_show_c (handle, 1);	/* Remettre la souris */
}

/* Restaure le fond d'un formulaire */
void	put_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img)
{
int pxy[8];
MFDB ecr = {0};		/* Ecran logique */

	of_x -= 3;	/* Pr‚voir une marge de s‚curit‚ autour */
	of_y -= 3;	/* de la zone, pour le cas o— on aurait */
	of_w += 5;	/* besoin de sauvegarder le fond d'un */
	of_h += 5;	/* formulaire avec un attribut OUTLINED. */

	pxy[0] = 0;		/* Remplir le tableau */
	pxy[1] = 0;
	pxy[2] = of_w;
	pxy[3] = of_h;
	pxy[4] = of_x;
	pxy[5] = of_y;
	pxy[6] = pxy[4] + pxy[2];
	pxy[7] = pxy[5] + pxy[3];
	v_hide_c (handle);			/* Remettre la souris */
	vro_cpyfm (handle, S_ONLY, pxy, img, &ecr);	/* Copier l'image */
	v_show_c (handle, 1);	/* Virer la souris */
	free (img->fd_addr);		/* Lib‚rer la m‚moire */
}

/* Ouvre station de travail */
void open_work (void)
{
int i, a, b, work_out[57];

		/* Remplir le tableau intin[] */
	for (i = 0 ; i < 10 ; _GemParBlk.intin[i++] = 1);
		/* L'identificateur physique d‚pend de la r‚solution */
	_GemParBlk.intin[0] = Getrez() + 2;
		/* SystŠme de coordonn‚es RC */
	_GemParBlk.intin[10] = 2;
		/* Handle de la station que l'AES ouvre automatiquement */
	handle = graf_handle (&a, &b, &i, &i);
		/* Ouverture station de travail virtuelle */
	v_opnvwk (_GemParBlk.intin, &handle, _GemParBlk.intout);
		/* R‚cuperation d'informations suppl‚mentaires	*/
	vq_extnd (handle, 1, work_out);
	n_plane = work_out[4];	/* Nbre de plans de couleurs */
}

/* Afficher alerte */
void afficher_alerte (int index)
{
char *alrt;

	rsrc_gaddr (R_FRSTR, index, &alrt); /* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);						/* Pointeur sur le texte */
	form_alert (1, alrt); 							/* Afficher l'alerte */
}

/* Ouvre la fenˆtre */
void open_wind (void)
{
int xw, yw, ww, hw;

	if (hwind > 0) /* Si la fenˆtre est d‚j… ouverte */
	{
		wind_set (hwind, WF_TOP);  /* On la passe au premier plan */
	}
	else
	{
		hwind = wind_create (attr, xf, yf, wf, hf);			/* Cr‚er la fenˆtre */
		if (hwind > 0)																	/* Si fenˆtre bien cr‚‚e */
		{
			wind_set (hwind, WF_NAME, titre); 	/* Titre fenˆtre */
				/* On d‚duit les coordonn‚es de la zone de travail */
		  wind_calc (WC_WORK, attr, xf, yf, wf, hf, &xw, &yw, &ww, &hw);
		  adr_wmenu->ob_x = xw;		/* On repositionne le menu entier */
		  adr_wmenu->ob_y = yw;
		  	/* Pas de trame, cadre 1 pixel vers l'ext‚rieur */
			adr_wmenu[BARMENU].ob_spec.index = 0xFF1101L;
			wind_open (hwind, xf, yf, wf, hf);	/* Ouverture fenˆtre */
		}
		else													/* Si la fenˆtre n'a pu ˆtre cr‚‚e */
		{
			hwind = 0;
			afficher_alerte (NOTWIND);	/* Pr‚venir */
		}
	}
}

/* Redraw */
void redraw (int f, int x, int y, int w, int h)
{
int fen, xw, yw, ww, hw, yz, hz, pxy[4];
GRECT r, rd;

	fen = f;			/* Fenˆtre concern‚e */
	rd.g_x = x; 	/* Coordonn‚es rectangle … redessiner */
	rd.g_y = y;
	rd.g_w = w;
	rd.g_h = h;

	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
	yz = yw + adr_wmenu[2].ob_height;
	hz = hw - adr_wmenu[2].ob_height;
	v_hide_c (handle);	/* Virer la souris */
	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris */

		/* Demande les coord. et dimensions du 1ø rectangle de la liste */
	wind_get (fen, WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)			/* Tant qu'il y a largeur ou hauteur... */
	{
		if (rc_intersect (&rd, &r)) /* Si intersection des 2 zones */
		{
			/* On commence par afficher la barre de menu */
			objc_draw (adr_wmenu, BARMENU, MAX_DEPTH, r.g_x, r.g_y, r.g_w, r.g_h);

			set_clip (1, &r); 	/* Clipping ON */
			vswr_mode (handle, MD_REPLACE); 	/* Dessin en mode Remplacement */
			vsf_perimeter (handle, 0);
			pxy[0] = xw;								/* Pr‚parer effacement fenˆtre */
			pxy[1] = yz;
			pxy[2] = xw + ww - 1;
			pxy[3] = yz + hz - 1;
			vsf_color (handle, 0);						/* Couleur blanche */
			v_bar (handle, pxy);							/* "Vider" la fenˆtre */
			switch (outil)		/* Selon l'outil de dessin */
			{
			case LIGNE :
				vsl_color (handle, color);				/* Tracer les lignes */
				pxy[2] = xw + ww - 1;
				pxy[3] = yz + hz - 1;
				v_pline (handle, 2, pxy);
				pxy[1] = yz + hz - 1;
				pxy[2] = xw + ww - 1;
				pxy[3] = yz;
				v_pline (handle, 2, pxy);
				break;
			case TRAME :
				pxy[0] = xw + 10;									/* Rectangle tram‚ */
				pxy[1] = yz + 10;
				pxy[2] = xw + ww - 1 - 10;
				pxy[3] = yz + hz - 1 - 10;
				vsf_interior (handle, 2);
				vsf_style (handle, 3);
				vsf_color (handle, color);
				v_bar (handle, pxy);							/* "Vider" la fenˆtre */
				break;
			case ELLIPSE :
				vsf_interior (handle, 2);
				vsf_style (handle, 2);
				vsf_color (handle, color);
				v_ellipse (handle, xw + (ww / 2), yz + (hz / 2), ww / 2, hz / 2);
				break;
			}
			set_clip (0, &r); 	/* Clipping OFF */
		}
			/* Rectangle suivant */
		wind_get (fen, WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris */
	v_show_c (handle, 1); 			/* Rappeler la souris */
}

/* Intersection de rectangles */
int rc_intersect (GRECT *p1, GRECT *p2)
{
int tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return ((tw > tx) && (th > ty));
}

/* Clipping */
void set_clip (int clip_flag, GRECT *area)
{   /* Active ou d‚sactive le clipping d'une zone */
int pxy[4];

  pxy[0] = area->g_x;
  pxy[1] = area->g_y;
  pxy[2] = area->g_w + area->g_x - 1;
  pxy[3] = area->g_h + area->g_y - 1;
  vs_clip (handle, clip_flag, pxy);
}

/* Inverse un titre de menu en fenˆtre */
void wmenu_tnormal (int title, int flag)
{
int x, y;

	if (! flag)
		adr_wmenu[title].ob_state |= SELECTED;
	else
		adr_wmenu[title].ob_state &= ~SELECTED;
	objc_offset (adr_wmenu, title, &x, &y);
	redraw (hwind, x, y, adr_wmenu[title].ob_width, adr_wmenu[title].ob_height);
}

/* Redimensionnement fenˆtre */
void sized (void)
{
int xw, yw, ww, hw;

	if (buf[6] < 100)			/* Largeur minimum */
		buf[6] = 100;
	if (buf[7] < 100)			/* Hauteur minimum */
		buf[7] = 100;
	wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
	if ((buf[6] <= wf) && (buf[7] <= hf))	/* Si largeur ET hauteur <= anciennes */
	{
		wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
		redraw (hwind, xw, yw, ww, hw);	/* Demender redraw de la fenˆtre */
	}
	wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);	/* Enregistrer les coordonn‚es */
	ful = 0;						/* Annuler le flag de pleine ouverture */
}

/* Fenˆtre pleine ouverture ou retour */
void fulled (void)
{
int x, y, w, h, xw, yw, dummy;

	if (ful)					/* Si elle est d‚j… plein pot */
	{
		wind_get (buf[3], WF_PREVXYWH, &x, &y, &w, &h); /* Coord. pr‚c‚dentes */
		ful = 0;									/* Annuler flag */
	}
	else											/* Sinon */
	{
		x = xb; /* Coord. maxi	= bureau */
		y = yb;
		w = wb;
		h = hb;
		ful = 1;									/* Positionner flag */
	}
	wind_set (buf[3], WF_CURRXYWH, x, y, w, h); 				/* Nouvelles coordonn‚es */
	wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);	/* Enregistrer les coordonn‚es */
  wind_get (hwind, WF_WORKXYWH, &xw, &yw, &dummy, &dummy);
  adr_wmenu->ob_x = xw;		/* On repositionne le menu entier */
  adr_wmenu->ob_y = yw;
}

