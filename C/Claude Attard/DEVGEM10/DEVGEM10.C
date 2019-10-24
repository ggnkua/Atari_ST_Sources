/*	D‚velopper sous GEM 10
		ToolBar en fenˆtre
	Claude ATTARD pour ST MAG
				Novembre 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "devgem10.h"

/* #[ Prototypage : 														*/
void main (void);
void open_work (void);
void open_wind (void);
void afficher_alerte (int index);
void redraw (int x, int y, int w, int h);
void red_dessin (void);
int rc_intersect (GRECT *p1, GRECT *p2);
void set_clip (int clip_flag, GRECT *area);
void fulled (void);

int xform_do (int flags, OBJECT *address);
int parent (OBJECT *adr, int object);
/* #] Prototypage : 														*/ 
/* #[ D‚finitions et globales : 								*/
	/* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))
	/* Message construit pour la ToolBar */
#define WM_TOOL 101

	/* Variables globales */
int xb, yb, wb, hb; 	/* Coordonn‚es du bureau */
int ap_id;						/* Identificateur application */
int handle; 					/* handle station de travail VDI */
int buf[8]; 					/* Buffer d'‚v‚nements */
int mx, my, mk; 			/* Gestion de la souris */
int objet;						/* Objet cliqu‚ */
int hwind = 0;				/* Handle fenˆtre */
int ful = 0;					/* Flag pour le traitement du "plein ‚cran" */
char *titre = " Fenˆtre et ToolBar ";

OBJECT *adr_menu; 		/* Adresse du menu */
OBJECT *adr_desk; 		/* Adresse du bureau */
OBJECT *adr_tool;			/* Adresse ToolBar */

int dessin = T_ELL;		/* Type de dessin */
/* #] D‚finitions et globales : 								*/ 

/* #[ Main :																													*/
void main (void)
{
int xw, yw, ww, hw,	/* Coordonn‚es zone de travail */
		quit = 0, 			/* Flag pour quitter */
		event; 					/* Type d'‚v‚nement, index de boucle */

	ap_id = appl_init (); 							/* D‚clarer l'application au GEM */
	open_work (); 											/* Ouvrir station de travail */
	rsrc_load ("DEVGEM10.RSC"); 				/* Charger le ressource */
	rsrc_gaddr (0, BUREAU, &adr_desk);	/* Demander adresse bureau */
	wind_get (0, WF_WORKXYWH, &xb, &yb, &wb, &hb);	/* Coordonn‚es du bureau */
	adr_desk->ob_x = xb;								/* Mettre le bureau */
	adr_desk->ob_y = yb;								/* bonnes dimensions */
	adr_desk->ob_width = wb;
	adr_desk->ob_height = hb;
	wind_set (0, WF_NEWDESK, adr_desk, 0);	/* Fixer le nouveau bureau */
	form_dial (FMD_FINISH, 0, 0, 0, 0, xb, yb, wb, hb); /* et l'afficher */

	rsrc_gaddr (0, MENUBAR, &adr_menu);		/* Demander adresse menu */
	menu_bar (adr_menu, 1); 							/* Afficher le menu */
	graf_mouse (ARROW, 0);								/* Souris : forme de flŠche */

	rsrc_gaddr (0, TOOL, &adr_tool); 			/* Adresse formulaire toolbar */
	open_wind ();													/* Ouvrir la fenˆtre */

	do		/* BOUCLE PRINCIPALE DU PROGRAMME */
	{ 	/* Appel fonction xform_do() qui gŠre le bureau */
		event = xform_do ((MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER), adr_desk);
		if (event & MU_MESAG) 				/* SI EVENEMENT DE MESSAGE */
		{
			if (buf[0] == MN_SELECTED)		/* Si message de menu */
			{
				switch (buf[4]) 	/* Selon l'option de menu cliqu‚e */
				{
				case M_PROPOS : 	/* Si c'est "Infos", afficher une alerte */
					afficher_alerte (INFOS);
					break;
				case M_OPEN :			/* Ouvrir la fenˆtre */
					open_wind ();
					break;
				case M_QUITTER :	/* Si c'est "Quitter" */
					quit = 1;
					break;
				}
				menu_tnormal (adr_menu, buf[3], 1); /* R‚inverser le titre de menu */
			}
			else if (buf[0] == WM_REDRAW) 	/* Si message de redraw */
			{
				redraw (buf[4], buf[5], buf[6], buf[7]);
			}
			else if (buf[0] == WM_TOPPED) 	/* Si message de Top */
			{
				wind_set (buf[3], WF_TOP);		/* Mettre la fenˆtre au 1ø plan */
			}
			else if (buf[0] == WM_CLOSED) 	/* Si message de close */
			{
				wind_close (buf[3]);					/* Fermer la fenˆtre */
				wind_delete (buf[3]); 				/* D‚truire la fenˆtre */
				hwind = 0; 										/* Noter que la fenˆtre a ‚t‚ ferm‚e */
			}
			else if (buf[0] == WM_FULLED) 	/* Si message de full */
			{
				fulled ();										/* Plein pot ou retour */
			}
			else if (buf[0] == WM_SIZED)		/* Si message de size */
			{
				if (buf[6] < 150)							/* Largeur minimum */
					buf[6] = 150;
				if (buf[7] < 150)							/* Hauteur minimum */
					buf[7] = 150;
					/* Nouvelles coordonn‚es : */
				wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
				ful = 0; 						/* Annuler le flag de pleine ouverture */
			}
			else if (buf[0] == WM_MOVED)		/* Si message de move */
			{
					/* Nouvelles coordonn‚es : */
				wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
				ful = 0; 						/* Annuler le flag de pleine ouverture */
				wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
				adr_tool->ob_x = xw;	/* Ajuster position ToolBar */
				adr_tool->ob_y = yw;
			}
			else if (buf[0] == WM_TOOL)			/* Si message de ToolBar */
			{
				if ((buf[4] >= T_REC) && (buf[4] <= T_ELL))
				{
					dessin = buf[4];							/* Nouveau type de dessin */
					wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
					yw += adr_tool->ob_height;
					hw -= adr_tool->ob_height;
					redraw (xw, yw, ww, hw);			/* Redessiner la fenˆtre */
				}
			}
		}
	} while (quit == 0);

		/* Avant de quitter l'application : */
	if (hwind > 0) /* Si la fenˆtre est encore ouverte */
	{
		wind_close (hwind);		/* La fermer */
		wind_delete (hwind); 	/* La d‚truire */
	}
	menu_bar (adr_menu, 0); 				/* Virer la barre de menu */
	wind_set (0, WF_NEWDESK, 0, 0); /* Rendre le bureau */
	rsrc_free (); 									/* Lib‚rer le ressource */
	appl_exit (); 									/* Quitter */
}
/* #] Main :																													*/
/* #[ Open_work : 																										*/
void open_work (void)
{
int i, a, b;

		/* Remplir le tableau intin[] */
	for (i = 0 ; i < 10 ; _VDIParBlk.intin[i++] = 1);
		/* L'identificateur physique d‚pend de la r‚solution */
	_VDIParBlk.intin[0] = Getrez() + 2;
		/* SystŠme de coordonn‚es RC */
	_VDIParBlk.intin[10] = 2;
		/* Handle de la station que l'AES ouvre automatiquement */
	handle = graf_handle (&a, &b, &i, &i);
		/* Ouverture station de travail virtuelle */
	v_opnvwk (_VDIParBlk.intin, &handle, _VDIParBlk.intout);
}
/* #] Open_work : 																										*/ 
/* #[ Ouvrir fenˆtre :																								*/
void open_wind (void)
{
int xw, yw, ww, hw, attr = (NAME|CLOSER|FULLER|MOVER|SIZER), xf, yf, wf, hf;

	if (hwind == 0)					/* Si la fenˆtre est ferm‚e */
	{
		xf = xb + 20;					/* Coordonn‚es de d‚part */
		yf = yb + 20;
		wf = wb / 2;
		hf = hb / 2;
		hwind = wind_create (attr, xf, yf, wf, hf);	/* Cr‚ation fenˆtre */
		if (hwind > 0)															/* Si cr‚ation ok */
		{
				/* Demander coordonn‚es zone de travail et  placer la ToolBar */
			wind_calc (WC_WORK, attr, xf, yf, wf, hf, &xw, &yw, &ww, &hw);
			adr_tool->ob_x = xw;
			adr_tool->ob_y = yw;
			adr_tool->ob_width = wb;
				/* Modifier attributs racine ToolBAr */
			adr_tool->ob_state &= ~OUTLINED;					/* Pas Outline */
			adr_tool->ob_spec.obspec.framesize = 1;		/* Cadre : 1 vers l'ext‚rieur */
			adr_tool->ob_spec.obspec.textmode = 1;		/* Objet racine opaque */
			wind_set (hwind, WF_NAME, titre);					/* Titre fenˆtre */
			wind_open (hwind, xf, yf, wf, hf);				/* Ouverture fenˆtre */
		}
		else																				/* Si fenˆtre pasd cr‚‚e */
			afficher_alerte (NOTWIND);								/* Pr‚venir */
	}
	else					/* Si la fenˆtre est d‚j… ouverte */
		wind_set (hwind, WF_TOP);	/* Mettre la fenˆtre au 1ø plan */
}
/* #] Ouvrir fenˆtre :																								*/ 
/* #[ Afficher alerte : 																							*/
void afficher_alerte (int index)
{
char *alrt;

	rsrc_gaddr (R_FRSTR, index, &alrt); /* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);						/* Pointeur sur le texte */
	form_alert (1, alrt); 							/* Afficher l'alerte */
}
/* #] Afficher alerte : 																							*/ 
/* #[ Redraw :																												*/
void redraw (int x, int y, int w, int h)
{ 	/* Gestion des redraws */
GRECT r, rd, z;

	rd.g_x = x; 	/* Coordonn‚es rectangle … redessiner */
	rd.g_y = y;
	rd.g_w = w;
	rd.g_h = h;

		/* Demander coordonn‚es zone de travail fenˆtre */
	wind_get (hwind, WF_WORKXYWH, &z.g_x, &z.g_y, &z.g_w, &z.g_h);
	z.g_y += adr_tool->ob_height;	/* Correction … cause de la ToolBar */
	z.g_h -= adr_tool->ob_height;

	v_hide_c (handle);	/* Virer la souris */
	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris */

		/* Demande les coord. et dimensions du 1ø rectangle de la liste */
	wind_get (buf[3], WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)			/* Tant qu'il y a largeur ou hauteur... */
	{
		if (rc_intersect (&rd, &r)) /* Si intersection des 2 zones */
		{
				/* Dessiner la ToolBar */
			objc_draw (adr_tool, 0, MAX_DEPTH, r.g_x, r.g_y, r.g_w, r.g_h);
			rc_intersect (&z, &r);						/* Faut-il dessiner le contenu ? */
			if ((r.g_w > 0) && (r.g_h > 0))		/* Si oui */
			{
				set_clip (1, &r); 							/* Clipping ON */
				red_dessin ();									/* Tracer du graphique */
				set_clip (0, &r); 							/* Clipping OFF */
			}
		}
			/* Rectangle suivant */
		wind_get (buf[3], WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris */
	v_show_c (handle, 1); 			/* Rappeler la souris */
}
/* #] Redraw :																												*/ 
/* #[ Dessin :																												*/
void red_dessin (void)
{
int xw, yw, ww, hw, i, pxy[4];

	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);	/* Zone de travail */
	yw += adr_tool->ob_height;													/* Corrections */
	hw -= adr_tool->ob_height;
	pxy[0] = xw;                			/* Pr‚parer effacement fenˆtre */
	pxy[1] = yw;
	pxy[2] = xw + ww - 1;
	pxy[3] = yw + hw - 1;
	vswr_mode (handle, MD_REPLACE);   /* Dessin en mode Remplacement */
	vsf_color (handle, 0);            /* Couleur blanche */
	v_bar (handle, pxy);              /* "Vider" la fenˆtre */
	vsf_color (handle, 1);						/* Couleur noire */
	vsf_perimeter (handle, 1);				/* Tracer le contour */

	switch (dessin)										/* Selon le type de dessin */
	{
	case T_REC :													/* Rectangles */
		vswr_mode (handle, MD_REPLACE);   	/* Dessin en mode Remplacement */
		vsf_interior (handle, FIS_PATTERN);	/* Trames */
		for (i = 1 ; i < (hw / 2) ; i += 5)	/* Boucle de dessin */
		{
			pxy[0] = xw + i;
			pxy[1] = yw + i;
			pxy[2] = xw + ww - i;
			pxy[3] = yw + hw - i;
			vsf_style (handle, i % 24);				/* Type de trame */
			v_bar (handle, pxy);							/* Rectangle */
		}
		break;
	case T_CIR :													/* Cercles */
		vswr_mode (handle, MD_REPLACE);   	/* Dessin en mode Remplacement */
		vsf_interior (handle, FIS_PATTERN);	/* Trames */
		for (i = hw ; i > 0; i -= 5)				/* Boucle de dessin */
		{
			vsf_style (handle, i % 24);				/* Type de trame */
			v_circle (handle, xw + (ww / 2), yw + (hw / 2), i);	/* Cercle */
		}
		break;
	case T_ELL :													/* Ellipses */
		vsf_interior (handle, FIS_HOLLOW);	/* Vide */
		vswr_mode (handle, MD_TRANS);				/* Mode transparent */
		for (i = 0 ; i < hw ; i += 3)				/* Boucle de dessin */
			v_ellipse (handle, xw + (ww / 2), yw + (hw / 2), i, (hw / 2) - i); /* Ellipse */
		break;
	}
}
/* #] Dessin :																												*/ 
/* #[ Intersection :																									*/
int rc_intersect (GRECT *p1, GRECT *p2)
{ 	/* Calcule l'intersection de 2 rectangles */
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
/* #] Intersection :																									*/ 
/* #[ Clipping :																											*/
void set_clip (int clip_flag, GRECT *area)
{ 	/* Active ou d‚sactive le clipping d'une zone */
int pxy[4];

	pxy[0] = area->g_x;
	pxy[1] = area->g_y;
	pxy[2] = area->g_w + area->g_x - 1;
	pxy[3] = area->g_h + area->g_y - 1;
	vs_clip (handle, clip_flag, pxy);
}
/* #] Clipping :																											*/ 
/* #[ Fulled :																												*/
void fulled (void)
{ 	/* Fenˆtre plein pot ou retour */
int x, y, w, h, xw, yw, dummy;

	if (ful) 					/* Si elle est d‚j… plein pot */
	{
		wind_get (buf[3], WF_PREVXYWH, &x, &y, &w, &h); /* Coord. pr‚c‚dentes */
		wind_set (buf[3], WF_CURRXYWH, x, y, w, h); 		/* Nouvelles coord. */
		ful = 0; 																				/* Annuler flag */
	}
	else							/* Sinon */
	{
		wind_set (buf[3], WF_CURRXYWH, xb, yb, wb, hb); /* Coord. maxi */
		ful = 1; 																				/* Positionner flag */
	}
	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &dummy, &dummy);
	adr_tool->ob_x = xw;				/* Positionner la ToolBar dans */
	adr_tool->ob_y = yw;				/* la zone de travail. */
}
/* #] Fulled :																												*/ 

/* #[ xform_do :																											*/
int xform_do (int flags, OBJECT *address)
{ 	/* Fonction qui remplace le form_do du GEM */
int evnt; 							/* Type d'‚v‚nement */
int dummy, i, j;				/* Divers */
int whandle;						/* Handle fenˆtre cliqu‚e */
int top;								/* Handle fenˆtre de premier plan */
int obflags, obstate; 	/* ob_flags et ob_state objet cliqu‚ */
int xo, yo;							/* Position objet … l'‚cran */
OBJECT *adr;						/* Adresse formulaire sur lequel on travaille */

	objet = 0;		/* Mise … z‚ro avant de commencer */

	while (1) 				/* BOUCLE "SANS FIN" */
	{ 	/* Surveillance des ‚v‚nements Clavier, Clic, Message et Timer */
		evnt = evnt_multi (flags, 2, 1, 1,
											 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
											 buf, 10, 0, &mx, &my, &mk, &dummy, &dummy, &dummy);

		if (evnt & MU_MESAG)					/* Si ‚v‚nement message */
		{
			return (evnt);
		}

		if (evnt & MU_BUTTON) 	/* Si ‚v‚nement clic souris */
		{
			if (address == adr_desk)			/* Si on travaille sur le bureau */
			{
				whandle = wind_find (mx, my); /* A t-on cliqu‚ sur une fenˆtre ? */
				if (whandle)									/* Si oui */
				{ 	/* Chercher fenˆtre de premier plan */
					wind_get (0, WF_TOP, &top, &dummy, &dummy, &dummy);
					if (whandle == top) 	/* Si on a cliqu‚ la fenˆtre de 1ø plan */
					{
						if (whandle == hwind)	/* Si c'est la fenˆtre avec ToolBar */
						{
							adr = adr_tool;			/* Adresse ToolBar en fenˆtre */
							evnt = MU_MESAG;		/* Message */
							buf[0] = WM_TOOL;		/* Ev‚nement de ToolBar */
						}
					}
				}
			}

			objet = objc_find (adr, 0, MAX_DEPTH, mx, my); /* Objet cliqu‚ */
			if (objet > -1) 		/* Si on a cliqu‚ sur un objet */
			{
				buf[3] = hwind;		/* Le handle de la fenˆtre sera retourn‚ */
				buf[4] = objet;		/* L'objet sera retourn‚ */

				obflags = adr[objet].ob_flags;	/* Noter ob_flags objet */
				obstate = adr[objet].ob_state;	/* Noter ob_state objet */
	
				if (obstate & DISABLED) 				/* Si l'objet est d‚sactiv‚ */
					return (evnt);								/* Sortir de suite */
	
				if (! (obflags & TOUCHEXIT))		/* Si ce n'est pas un TOUCHEXIT */
				{
					while (mk)	/* Attendre bouton souris relach‚ */
						graf_mkstate (&dummy, &dummy, &mk, &dummy);
				}
	
				if ((obflags & SELECTABLE) &&
						(! (obflags & RBUTTON)))		/* Si s‚lectable simple */
				{
					adr[objet].ob_state ^= SELECTED;		/* Inverser l'‚tat de l'objet */
					objc_draw (adr, objet, MAX_DEPTH, 	/* Redessiner l'objet */
										 adr->ob_x, adr->ob_y,
										 adr->ob_width, adr->ob_height);
				}
	
				if ((obflags & SELECTABLE) &&
						(obflags & RBUTTON) &&
						(! (obstate & SELECTED))) 	/* Si radio-bouton */
				{
					j = objet;												/* Partir de cet objet */
					adr[objet].ob_state |= SELECTED;	/* Le s‚lectionner */
					objc_offset (adr, objet, &xo, &yo);
					redraw (xo, yo, adr[objet].ob_width, adr[objet].ob_height);
					i = parent (adr, j);				/* Chercher le pŠre */
					j = adr[i].ob_head; 				/* Partir du 1ø enfant... */
					i = adr[i].ob_tail; 				/* jusqu'au dernier. */
					do
					{
						if ((adr[j].ob_flags & RBUTTON) && (j != objet) &&
								(adr[j].ob_state & SELECTED))
						{ 	/* Les mettre en normal si RBUTTON sauf l'objet cliqu‚. */
							adr[j].ob_state &= ~SELECTED;
							objc_offset (adr, j, &xo, &yo);
							redraw (xo, yo, adr[j].ob_width, adr[j].ob_height);
						}
						j = adr[j].ob_next; 											/* Au suivant... */
					} while ((j <= i) && (j > adr[i].ob_next)); /* jusqu'au dernier. */
				}
			}
			return (evnt);
		}
	}
}
/* #] xform_do :																											*/ 
/* #[ parent () Cherche le pŠre d'un objet :													*/
int parent (OBJECT *adr, int object)
{ 	/* Retourne l'objet pŠre d'un objet */
register int i;

	i = object; 										/* Partir de cet objet */
	do
	{
		i = adr[i].ob_next; 					/* Passer au suivant... */
	} while (i > object); 					/* Jusqu'… revenir au pŠre. */

	return i; 											/* Retourner le pŠre */
}
/* #] parent () Cherche le pŠre d'un objet :													*/ 

