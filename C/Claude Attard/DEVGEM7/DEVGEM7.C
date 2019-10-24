/*			D‚velopper sous GEM 7
			Les images en fenˆtres
		Claude ATTARD pour ST MAG
						Juillet 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "DEVGEM7.H"

/* Prototypages : */
void main (void);
int load_img (void);
long exist (char *name);
void open_work (void);
void afficher_alerte (int index);
void open_wind (void);
void redraw (int x, int y, int w, int h);
int rc_intersect (GRECT *p1, GRECT *p2);
void sized (void);
void fulled (void);
void arrow (void);
void hslider (void);
void vslider (void);
void sliders (void);

/* D‚finitions et globales : */
	/* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))

	/* Variables globales */
int xb, yb, wb, hb; /* Coordonn‚es du bureau */
int xf, yf, wf, hf; /* Coordonn‚es de la fenˆtre */
int ap_id;					/* Identificateur application */
int handle; 				/* handle station de travail VDI */
int buf[8]; 				/* Buffer d'‚v‚nements */
char titre[] = " La Lune, il y a 25 ans ";
int lin = 0, col = 0; 	/* 1ø ligne et colonne fenˆtres texte */
int ful = 0;						/* Flag pour le traitement du "plein ‚cran" */
int lt, ht, hwind = 0;	/* Largeur et hauteur totales, handle fenˆtre */
int attr = (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE);	/* Attributs fenˆtre */

OBJECT *adr_menu; 	/* Adresse du menu */
OBJECT *adr_desk; 	/* Adresse du bureau */

MFDB img;						/* Description de l'image en m‚moire */

/* Main : */
void main (void)
{
int dummy;					/* Variable "pour rien" */
int quit = 0; 			/* Flag pour quitter */
int event;					/* Type d'‚v‚nement */

	ap_id = appl_init (); /* D‚clarer l'application au GEM */
	open_work (); 				/* Ouvrir station de travail */
	rsrc_load ("DEVGEM7.RSC");					/* Charger le ressource */
	rsrc_gaddr (0, BUREAU, &adr_desk);	/* Demander adresse bureau */
	wind_get (0, WF_WORKXYWH, &xb, &yb, &wb, &hb);	/* Coordonn‚es du bureau */
	adr_desk->ob_x = xb;				/* Mettre le bureau aux bonnes dimensions */
	adr_desk->ob_y = yb;
	adr_desk->ob_width = wb;
	adr_desk->ob_height = hb;
	wind_set (0, WF_NEWDESK, adr_desk, 0);							/* Fixer le nouveau bureau */
	form_dial (FMD_FINISH, 0, 0, 0, 0, xb, yb, wb, hb); /* et l'afficher */

	rsrc_gaddr (0, MENUBAR, &adr_menu);	/* Demander adresse menu */
	menu_bar (adr_menu, 1); 						/* Afficher le menu */
	graf_mouse (ARROW, 0);							/* Souris : forme de flŠche */

	if (load_img ())		/* Charger l'image */
	{										/* Si elle est bien charg‚e */
		xf = 25;		/* Coordonn‚es de d‚part de la fenˆtre */
		yf = 30;
		wf = 300;
		hf = 150;

		do		/* BOUCLE PRINCIPALE DU PROGRAMME */
		{ 	/* Boucle pour surveiller les ‚v‚nements */
			event = evnt_multi ((MU_MESAG|MU_TIMER), 2, 1, 1,
													0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
													buf, 10, 0,
													&dummy, &dummy, &dummy, &dummy, &dummy, &dummy);
			if (event & MU_MESAG) 				/* SI EVENEMENT DE MESSAGE */
			{
				if (buf[0] == MN_SELECTED)		/* Si message de menu */
				{
					switch (buf[4]) 	/* Selon l'option de menu cliqu‚e */
					{
					case PROPOS : 			/* Si c'est "Infos" */
						afficher_alerte (INFOS);
						break;
					case OPENW :				/* Si c'est "Ouvrir fenˆtre" */
						open_wind ();
						break;
					case QUITTER :			/* Si c'est "Quitter" */
						quit = 1;
						break;
					}
					menu_tnormal (adr_menu, buf[3], 1); /* R‚inverser le titre de menu */
				}
				else if (buf[0] == WM_REDRAW) 	/* Si message de redraw */
					redraw (buf[4], buf[5], buf[6], buf[7]);
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
				else if (buf[0] == WM_ARROWED)	/* Si message d'ascenseur */
					arrow ();
				else if (buf[0] == WM_HSLID)		/* Si message de slider H */
					hslider ();
				else if (buf[0] == WM_VSLID)		/* Si message de slider V */
					vslider ();
				else if (buf[0] == WM_SIZED)		/* Si message de size */
					sized ();
				else if (buf[0] == WM_MOVED)		/* Si message de move */
				{
						/* Nouvelles coordonn‚es : */
					wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
					wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);
					ful = 0;						/* Annuler le flag de pleine ouverture */
				}
			}
		} while (quit == 0);
	}
	else		/* Si l'image n'a pas ‚t‚ charg‚e */
		afficher_alerte (NOTIMG);		/* On pr‚vient */

		/* Avant de quitter l'application : */
	if (hwind > 0) /* Si la fenˆtre est encore ouverte */
	{
		wind_close (hwind);		/* La fermer */
		wind_delete (hwind);	/* La d‚truire */
	}
	free (img.fd_addr);							/* Lib‚rer la m‚moire de l'image */
	menu_bar (adr_menu, 0); 				/* Virer la barre de menu */
	wind_set (0, WF_NEWDESK, 0, 0); /* Rendre le bureau */
	rsrc_free (); 									/* Lib‚rer le ressource */
	v_clsvwk (handle);							/* Fermer station de travail */
	appl_exit (); 									/* Quitter */
}

/* Chargement de l'image : */
int load_img (void)
{
int fh, retour = 0;

	if (exist ("DEVGEM7.PI3"))									/* Si le fichier est l… */
	{
		fh = (int)Fopen ("DEVGEM7.PI3", FO_READ);	/* Ouvrir le fichier */
		if (fh >= 0)															/* Si fichier bien ouvert */
		{
			img.fd_addr = malloc (32000);						/* R‚server la m‚moire pour l'image */
			if (img.fd_addr)												/* Si m‚moire bien r‚serv‚e */
			{
				Fseek (34, fh, 0);										/* Sauter les 34 octets d'en-tˆte */
				Fread (fh, 32000, img.fd_addr);				/* Lire les 32000 octets d'image */
				Fclose (fh);													/* Fermer le fichier */
				img.fd_w = 640;												/* Largeur image en octets */
				img.fd_h = 200;												/* Hauteur image en octets */
				img.fd_wdwidth = img.fd_w / 16;				/* Largeur image en mots */
				img.fd_stand = 0;											/* Mode coordonn‚es */
				img.fd_nplanes = 1;										/* Nombre de plans de couleurs */
				img.fd_r1 = img.fd_r2 = img.fd_r3 = 0;	/* El‚ments r‚serv‚s */
				retour = 1;														/* Chargement ok */
			}
		}
	}
	return retour;	/* Retourner le r‚sultat (0 si problŠme) */
}

/* Fichier existe : */
long exist (char *name)
{
int re;
DTA dtabuffer;

	Fsetdta (&dtabuffer);
	re = Fsfirst (name, 0);
	if ((re == -34) || (re == -33))		/* Si rien n'est trouv‚ */
		return 0;												/* retourner 0 */
	else															/* Sinon */
		return 1;												/* Retourner 1 */
}

/* Open_work : */
void open_work (void)
{
int i, a, b;

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
}

/* Afficher alerte : */
void afficher_alerte (int index)
{
char *alrt;

	rsrc_gaddr (R_FRSTR, index, &alrt); /* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);						/* Pointeur sur le texte */
	form_alert (1, alrt); 							/* Afficher l'alerte */
}

/* Ouvre la fenˆtre image : */
void open_wind (void)
{
	if (hwind > 0) /* Si la fenˆtre est d‚j… ouverte */
	{
		wind_set (hwind, WF_TOP);  /* On la passe au premier plan */
	}
	else
	{
		hwind = wind_create (attr, xf, yf, wf, hf);			/* Cr‚er la fenˆtre */
		if (hwind > 0)																	/* Si fenˆtre bien cr‚‚e */
		{
			lt = 640;														/* Dimensions maxi = dimension de l'image */
			ht = 400;
			wind_set (hwind, WF_NAME, titre); 	/* Titre fenˆtre */
			wind_open (hwind, xf, yf, wf, hf);	/* Ouverture fenˆtre */
			sliders ();													/* Position et taille des sliders */
		}
		else													/* Si la fenˆtre n'a pu ˆtre cr‚‚e */
		{
			hwind = 0;
			afficher_alerte (NOTWIND);	/* Pr‚venir */
		}
	}
}

/* Redraw : */
void redraw (int x, int y, int w, int h)
{
int xw, yw, ww, hw, pxy[8];
GRECT r, rd;
MFDB nul = {0};
int color[2];

	rd.g_x = x; 	/* Coordonn‚es rectangle … redessiner */
	rd.g_y = y;
	rd.g_w = w;
	rd.g_h = h;

	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
	v_hide_c (handle);	/* Virer la souris */
	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris */

		/* Demande les coord. et dimensions du 1ø rectangle de la liste */
	wind_get (buf[3], WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)			/* Tant qu'il y a largeur ou hauteur... */
	{
		if (rc_intersect (&rd, &r)) /* Si intersection des 2 zones */
		{
				/* Zone source dans l'image en m‚moire : */
			pxy[0] = col + (r.g_x - xw);	/* Gauche */
			pxy[1] = lin + (r.g_y - yw);	/* Haut */
			pxy[2] = pxy[0] + r.g_w - 1;	/* Droite */
			pxy[3] = pxy[1] + r.g_h - 1;	/* Bas */
				/* Zone destination dans la fenˆtre … l'‚cran */
			pxy[4] = r.g_x;								/* Gauche */
			pxy[5] = r.g_y;								/* Haut */
			pxy[6] = pxy[4] + r.g_w - 1;	/* Droite */
			pxy[7] = pxy[5] + r.g_h - 1;	/* Bas */
			color[0] = BLUE;			/* Couleur des ponts */
			color[1] = WHITE;
			vrt_cpyfm (handle, MD_REPLACE, pxy, &img, &nul, color);	/* Copie transparent */
			/*vro_cpyfm (handle, S_ONLY, pxy, &img, &nul); Si image en couleur : copie opaque */
		}
			/* Rectangle suivant */
		wind_get (buf[3], WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris */
	v_show_c (handle, 1); 			/* Rappeler la souris */
}

/* Intersection : */
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

/* Redimensionnement fenˆtre : */
void sized (void)
{
int xw, yw, ww, hw;		/* Coordonn‚es zone de travail */

		/* Calculer coordonn‚es zone de travail */
	wind_calc (WC_WORK, attr, buf[4], buf[5], buf[6], buf[7], &xw, &yw, &ww, &hw);
	if (lt - ww < 0)	/* Si c'est plus large que l'image */
		ww = lt;				/* On ajuste */
	if (ht - hw < 0)	/* Si c'est plus haut que l'image */
		hw = ht;				/* On ajuste */
		/* Recalculer coordonn‚es totales fenˆtre */
	wind_calc (WC_BORDER, attr, xw, yw, ww, hw, &buf[4], &buf[5], &buf[6], &buf[7]);
		/* Nouvelles coordonn‚es : */
	wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
	wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);	/* Enregistrer les coordonn‚es */
	ful = 0;						/* Annuler le flag de pleine ouverture */
	sliders ();					/* Tailles et positions sliders */
}

/* Fulled : */
void fulled (void)
{
int x, y, w, h, xw, yw, ww, hw;

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
		/* Coordonn‚es zone de travail */
	wind_calc (WC_WORK, attr, x, y, w, h, &xw, &yw, &ww, &hw);
	if (lt - ww < 0)	/* Si plus large que l'image */
		ww = lt;				/* Ajuster */
	if (ht - hw < 0)	/* Si plus haut que l'image */
		hw = ht;				/* Ajuster */
		/* Recalculer coordonn‚es totales fenˆtre */
	wind_calc (WC_BORDER, attr, xw, yw, ww, hw, &x, &y, &w, &h);
	wind_set (buf[3], WF_CURRXYWH, x, y, w, h); 				/* Nouvelles coordonn‚es */
	wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);	/* Enregistrer les coordonn‚es */
	sliders (); /* Ajuster tailles et positions sliders */
}

/* Arrow : */
void arrow (void)
{
int xw, yw, ww, hw;

	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
	switch (buf[4])
	{
	case WA_UPPAGE :				/* Page vers le haut */
		if (lin > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			lin = max (lin - hw, 0);	/* Nouvelle ligne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	case WA_DNPAGE :				/* Page vers le bas */
		if ((lin + hw) < ht)	/* Si pas d‚j… … la fin */
		{
			lin = min (lin + hw, ht - hw);	/* Nouvelle ligne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	case WA_UPLINE :				/* Ligne vers le haut */
		if (lin > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			lin -= 10;		/* Nouvelle ligne */
			if (lin < 0)
				lin = 0;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	case WA_DNLINE :				/* Ligne vers le bas */
		if ((lin + hw) < ht)	/* Si pas d‚j… … la fin */
		{
			lin += 10;		/* Nouvelle ligne */
			if (lin + hw > ht)
				lin = ht - hw;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	case WA_LFPAGE :				/* Page vers la gauche */
		if (col > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			col = max (col - ww, 0);	/* Nouvelle colonne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	case WA_RTPAGE :				/* Page vers la droite */
		if ((col + ww) < lt)	/* Si pas d‚j… … la fin */
		{
			col = min (col + ww, lt - ww);	/* Nouvelle colonne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	case WA_LFLINE :				/* Ligne vers la gauche */
		if (col > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			col -= 10;		/* Nouvelle colonne */
			if (col < 0)
				col = 0;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	case WA_RTLINE :				/* Ligne vers la droite */
		if ((col + ww) < lt)	/* Si pas d‚j… … la fin */
		{
			col += 10;		/* Nouvelle colonne */
			if (col + ww > lt)
				col = lt - ww;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (); 				/* Actualiser les sliders */
		}
		break;
	}
}

/* Slider H : */
void hslider (void)
{
int slide, xw, yw, ww, hw;

	slide = buf[4];
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
		/* Calcul de la colonne : */
	col = ((long)slide * (lt - (long)ww) / 1000.0);
	if (col + ww > lt)	/* Corrections */
		col = lt - ww;
	if (col < 0)
		col = 0;
	wind_set (buf[3], WF_HSLIDE, slide);
	redraw (xw, yw, ww, hw);	/* R‚affichage */
}

/* Slider V : */
void vslider (void)
{
int slide, xw, yw, ww, hw;

	slide = buf[4];
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
		/* Calcul de la ligne : */
	lin = ((long)slide * (ht - (long)hw) / 1000.0);
	if (lin + hw > ht)	/* Corrections */
		lin = ht - hw;
	if (lin < 0)
		lin = 0;
	wind_set (buf[3], WF_VSLIDE, slide);
	redraw (xw, yw, ww, hw);	/* R‚affichage */
}

/* Taille et position sliders : */
void sliders (void)
{
int slide, xw, yw, ww, hw;

		/* Coordonn‚es zone de travail : */
	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);

	wind_set (hwind, WF_VSLSIZE,				/* Taille slider vertical */
						(int)((double)1000 * (double)((double)hw /
						(double)ht)));
	lin = min (lin, ht - hw); /* Calculer la ligne */
	lin = max (0, lin);

	wind_set (hwind, WF_HSLSIZE,				/* Taille slider horizontal */
						(int)((double)1000 * (double)((double)ww /
						(double)lt)));
	col = min (col, lt - ww); /* Calculer la colonne */
	col = max (0, col);

	slide = lin * 1000.0 / (ht - hw); 	/* Position slider vertical */
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (hwind, WF_VSLIDE, slide);

	slide = col * 1000.0 / (lt - ww); 	/* Position slider horizontal */
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (hwind, WF_HSLIDE, slide);
}

