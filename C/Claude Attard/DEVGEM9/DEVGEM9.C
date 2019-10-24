/*			D‚velopper sous GEM 9
			Des ic“nes dans des fenˆtres
			Claude ATTARD pour ST MAG
						Octobre 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "DEVGEM9.H"
/* #[ Prototypages : */
void main (void);
void catalogue (void);
void set_clip (int clip_flag, GRECT *area);
void open_work (void);
void afficher_alerte (int index);
void open_wind (void);
void redraw (int wind, int x, int y, int w, int h);
void dessin (GRECT *zone);
int rc_intersect (GRECT *p1, GRECT *p2);
void sized (void);
void fulled (void);
void arrow (void);
void vslider (void);
void sliders (void);
char *path (char *pat);
/* #] Prototypages : */ 
/* #[ D‚finitions et globales : */
	/* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))
#define TRUE 1
#define FALSE 0

	/* Variables globales */
int xb, yb, wb, hb; /* Coordonn‚es du bureau */
int xf, yf, wf, hf; /* Coordonn‚es de la fenˆtre */
int ap_id;					/* Identificateur application */
int handle; 				/* handle station de travail VDI */
int buf[8]; 				/* Buffer d'‚v‚nements */
int lin = 0; 				/* 1ø ligne de l'affichage */
int ful = 0;				/* Flag pour le traitement du "plein ‚cran" */
int ht;							/* Hauteur totale */
int hwind = 0;			/* handle fenˆtre */
int attr = (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE);	/* Attributs fenˆtre */
char chemin[128];		/* Chemin de l'application et de travail */

typedef struct {
	char nom[13];
	int type;
} Fichier;						/* Structure pour stocker les fichiers */
Fichier file[255];		/* Pour stocker les noms de fichiers */
int nbre_icon = 0;		/* Nbre d'ic“nes */
int largeur, hauteur;	/* Largeur et hauteur d'une ic“ne */

OBJECT *adr_menu; 	/* Adresse du menu */
OBJECT *adr_desk; 	/* Adresse du bureau */
/* #] D‚finitions et globales : */ 
/* #[ Main : */
void main (void)
{
int dummy;					/* Variable "pour rien" */
int quit = 0; 			/* Flag pour quitter */
int event;					/* Type d'‚v‚nement */
OBJECT *adr;				/* Adresse du formulaire des ic“nes */

	ap_id = appl_init ();								/* D‚clarer l'application au GEM */
	open_work (); 											/* Ouvrir station de travail */
	rsrc_load ("DEVGEM9.RSC");					/* Charger le ressource */
	rsrc_gaddr (0, BUREAU, &adr_desk);	/* Demander adresse bureau */
	wind_get (0, WF_WORKXYWH, &xb, &yb, &wb, &hb);	/* Coordonn‚es du bureau */
	adr_desk->ob_x = xb;								/* Mettre le bureau aux bonnes dimensions */
	adr_desk->ob_y = yb;
	adr_desk->ob_width = wb;
	adr_desk->ob_height = hb;
	wind_set (0, WF_NEWDESK, adr_desk, 0);							/* Fixer le nouveau bureau */
	form_dial (FMD_FINISH, 0, 0, 0, 0, xb, yb, wb, hb); /* et l'afficher */

	rsrc_gaddr (0, MENUBAR, &adr_menu);	/* Demander adresse menu */
	menu_bar (adr_menu, 1); 						/* Afficher le menu */
	graf_mouse (ARROW, 0);							/* Souris : forme de flŠche */

	path (chemin);		/* Chercher chemin de l'application = chemin de travail */
	xf = xb + 10;			/* Coordon‚nes de d‚part de la fenˆtre */
	yf = yb + 10;
	wf = wb / 2;
	hf = hb / 2;

	rsrc_gaddr (R_TREE, ICONES, &adr);	/* Adresse formulaire ic“nes */
	largeur = adr[ICD].ob_width;				/* Largeur ic“ne */
	hauteur = adr[ICD].ob_height;				/* Hauteur ic“ne */
	open_wind ();												/* Ouverture de la fenˆtre */

	do		/* BOUCLE PRINCIPALE DU PROGRAMME */
	{ 		/* Boucle pour surveiller les ‚v‚nements */
		event = evnt_multi ((MU_MESAG|MU_TIMER), 2, 1, 1,
												0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
												buf, 10, 0,
												&dummy, &dummy, &dummy, &dummy, &dummy, &dummy);
		if (event & MU_MESAG) 					/* SI EVENEMENT DE MESSAGE */
		{
			if (buf[0] == MN_SELECTED)		/* Si message de menu */
			{
				switch (buf[4]) 						/* Selon l'option de menu cliqu‚e */
				{
				case PROPOS : 							/* Si c'est "Infos" */
					afficher_alerte (INFOS);	/* Une boŒte d'alerte */
					break;
				case OPENW :								/* Si c'est "Ouvrir fenˆtre" */
					open_wind ();							/* Ouvrir la fenˆtre */
					break;
				case QUITTER :							/* Si c'est "Quitter" */
					quit = 1;									/* On peut sortir */
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
				hwind = 0;							/* Noter que la fenˆtre a ‚t‚ ferm‚e */
			}
			else if (buf[0] == WM_FULLED) 	/* Si message de full */
				fulled ();
			else if (buf[0] == WM_ARROWED)	/* Si message d'ascenseur */
				arrow ();
			else if (buf[0] == WM_VSLID)		/* Si message de slider V */
				vslider ();
			else if (buf[0] == WM_SIZED)		/* Si message de size */
				sized ();
			else if (buf[0] == WM_MOVED)		/* Si message de move */
			{
					/* Nouvelles coordonn‚es : */
				wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
				wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);
				ful = 0;											/* Annuler le flag de pleine ouverture */
			}
		}
	} while (quit == 0);

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
/* #] Main : */ 
/* #[ open_wind : */
void open_wind (void)
{
	if (hwind > 0)								/* Si la fenˆtre est d‚j… ouverte */
		wind_set (hwind, WF_TOP);		/* On la passe au premier plan */
	else													/* Sinon */
	{
		catalogue ();								/* Catalogue du chemin de travail */
		lin = 0;										/* On est en haut de la fenˆtre */
		hwind = wind_create (attr, xf, yf, wf, hf);	/* Cr‚er la fenˆtre */
		if (hwind > 0)												/* Si fenˆtre bien cr‚‚e */
		{
			wind_set (hwind, WF_NAME, chemin); 	/* Titre fenˆtre */
			wind_open (hwind, xf, yf, wf, hf);	/* Ouverture fenˆtre */
			sliders ();													/* Position et taille du slider V */
		}
		else																	/* Si la fenˆtre n'a pu ˆtre cr‚‚e */
		{
			hwind = 0;
			afficher_alerte (NOTWIND);					/* Pr‚venir par une alerte */
		}
	}
}
/* #] open_wind : */ 
/* #[ Cr‚ation catalogue : */
void catalogue (void)
{
int retour;
DTA dtabuffer;

	Fsetdta (&dtabuffer);								/* Fixer adresse tampon DTA */
	nbre_icon = 0;											/* On part de z‚ro */
	retour = Fsfirst (chemin, 0x10);		/* Premier fichier ou dossier */
	while (retour >= 0)									/* Tant qu'il y en a un, on boucle */
	{
		if (dtabuffer.d_attrib & 0x10)							/* Si c'est un dossier */
		{
			if ((strcmp (dtabuffer.d_fname, ".")) &&	/* Si c'est pas un des */
					(strcmp (dtabuffer.d_fname, "..")))		/* dossiers "pour rien" */
			{
				strcpy (file[nbre_icon].nom, dtabuffer.d_fname);	/* On copie le nom */
				file[nbre_icon].type = ICD;												/* On note le type "dossier" */
				nbre_icon++;																			/* Une ic“ne de plus */
			}
		}
		else																				/* Si ce n'est pas un dossier */
		{
			strcpy (file[nbre_icon].nom, dtabuffer.d_fname);		/* On copie le nom */
			if (strcmp (dtabuffer.d_fname + strlen(dtabuffer.d_fname) - 3, "PRG") == 0)
				file[nbre_icon].type = ICP;												/* On note le type */
			else																								/* en fonction de */
				file[nbre_icon].type = ICF;												/* l'extension du fichier */
			nbre_icon++;																				/* Une ic“ne de plus */
		}
		retour = Fsnext ();								/* Fichier ou dossier suivant */
	}																		/* Fin de la bouche de recherche */
}
/* #] Cr‚ation catalogue : */ 
/* #[ Clipping :                                                      */
void set_clip (int clip_flag, GRECT *area)
{   /* Active ou d‚sactive le clipping d'une zone */
int pxy[4];

  pxy[0] = area->g_x;
  pxy[1] = area->g_y;
  pxy[2] = area->g_w + area->g_x - 1;
  pxy[3] = area->g_h + area->g_y - 1;
  vs_clip (handle, clip_flag, pxy);
}
/* #] Clipping :                                                      */ 
/* #[ Open_work : */
void open_work (void)
{		/* Ouverture station de travail virtuelle */
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
/* #] Open_work : */ 
/* #[ Afficher alerte : */
void afficher_alerte (int index)
{
char *alrt;

	rsrc_gaddr (R_FRSTR, index, &alrt); /* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);						/* Pointeur sur le texte */
	form_alert (1, alrt); 							/* Afficher l'alerte */
}
/* #] Afficher alerte : */ 
/* #[ Redraw : */
void redraw (int wind, int x, int y, int w, int h)
{
GRECT r, rd;

	rd.g_x = x; 	/* Coordonn‚es rectangle … redessiner */
	rd.g_y = y;
	rd.g_w = w;
	rd.g_h = h;

	v_hide_c (handle);					/* Virer la souris */
	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris */

		/* Demande les coord. et dimensions du 1ø rectangle de la liste */
	wind_get (wind, WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)			/* Tant qu'il y a largeur ou hauteur... */
	{
		if (rc_intersect (&rd, &r)) /* Si intersection des 2 zones */
		{
			set_clip (1, &r);   /* Clipping ON */
			dessin (&r);				/* Dessin de la fenˆtre */
			set_clip (0, &r);   /* Clipping OFF */
		}
			/* Rectangle suivant */
		wind_get (wind, WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris */
	v_show_c (handle, 1); 			/* Rappeler la souris */
}
/* #] Redraw : */ 
/* #[ Dessin lui-mˆme : */
void dessin (GRECT *zone)
{
int xw, yw, ww, hw, pxy[4], x, y, i, clip[4];
OBJECT *adr;

	rsrc_gaddr (R_TREE, ICONES, &adr);	/* Adresse formulaire ic“nes */
		/* Coordonn‚es zone de travail : */
	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
	pxy[0] = xw;                			/* Pr‚parer effacement fenˆtre */
	pxy[1] = yw;
	pxy[2] = xw + ww - 1;
	pxy[3] = yw + hw - 1;
	vswr_mode (handle, MD_REPLACE);   /* Dessin en mode Remplacement */
	vsf_color (handle, 0);            /* Couleur blanche */
	v_bar (handle, pxy);              /* "Vider" la fenˆtre */

	x = xw;														/* On cale le d‚but de l'affichage */
	y = yw - (lin * hauteur);

	for (i = 0 ; i < nbre_icon ; i++)	/* Pour chaque ic“ne une par une */
	{
		if (x + largeur > xw + ww)			/* Si on est trop … droite */
		{
			x = xw;												/* On repart … gauche */
			y += hauteur;									/* Ligne suivante */
		}
		if ((x < zone->g_x + zone->g_w - 1) && (y < zone->g_y + zone->g_h - 1))
		{
			adr->ob_x = x;									/* On positionne l'ic“ne */
			adr->ob_y = y;
				/* On copie le nom du fichier dans le texte de l'ic“ne */
			strcpy (adr[file[i].type].ob_spec.iconblk->ib_ptext, file[i].nom);
			clip[0] = max (x, zone->g_x);		/* On v‚rifie qu'on ne d‚borde */
			clip[1] = max (y, zone->g_y);		/* pas de la fenˆtre */
			clip[2] = min (largeur, (zone->g_x + zone->g_w) - clip[0]);
			clip[3] = min (hauteur, (zone->g_y + zone->g_h) - clip[1]);
				/* Dessine de l'ic“ne selon le type de fichier */
			objc_draw (adr, file[i].type, 1, clip[0], clip[1], clip[2], clip[3]);
		}
		x += largeur;										/* Position suivante … droite */
	}
}
/* #] Dessin lui-mˆme : */
/* #[ Intersection : */
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
/* #] Intersection : */ 
/* #[ Redimensionnement fenˆtre : */
void sized (void)
{
int xw, yw, ww, hw;

			/* Coordonn‚es internes de la fenˆtre */
	wind_calc (WC_WORK, attr, buf[4], buf[5], buf[6], buf[7], &xw, &yw, &ww, &hw);
	if (ww < largeur)			/* Corrections pour la taille minimum */
		ww = largeur + 1;
	if (hw < hauteur)
		hw = hauteur + 1;
			/* Coordonn‚es externes de la fenˆtre */
	wind_calc (WC_BORDER, attr, xw, yw, ww, hw, &buf[4], &buf[5], &buf[6], &buf[7]);
		/* Nouvelles coordonn‚es : */
	wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
	ful = 0;						/* Annuler le flag de pleine ouverture */
	sliders ();					/* Tailles et positions sliders */
	if ((buf[6] <= wf) && (buf[7] <= hf))	/* Si largeur ET hauteur <= anciennes */
	{																			/* il faut tout redessiner */
		wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
		redraw (hwind, xw, yw, ww, hw);	/* Demander redraw de la fenˆtre */
	}
	wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);	/* Enregistrer les coordonn‚es */
}
/* #] Redimensionnement fenˆtre : */ 
/* #[ Fulled : */
void fulled (void)
{
int x, y, w, h;

	if (ful)					/* Si elle est d‚j… plein pot */
	{
		wind_get (buf[3], WF_PREVXYWH, &x, &y, &w, &h); /* Coord. pr‚c‚dentes */
		ful = 0;								/* Annuler flag */
	}
	else											/* Sinon */
	{
		x = xb; 								/* Coord. maxi	= bureau */
		y = yb;
		w = wb;
		h = hb;
		ful = 1;								/* Positionner flag */
	}
	wind_set (buf[3], WF_CURRXYWH, x, y, w, h); 				/* Nouvelles coordonn‚es */
	wind_get (buf[3], WF_CURRXYWH, &xf, &yf, &wf, &hf);	/* Enregistrer les coordonn‚es */
	sliders (); 							/* Ajuster tailles et positions sliders */
}
/* #] Fulled : */ 
/* #[ Arrow : */
void arrow (void)
{
int xw, yw, ww, hw, henline;

	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);	/* Coord. zone de travail */
	henline = hw / hauteur;					/* Hauteur en lignes */

	switch (buf[4])					/* Selon le message */
	{
	case WA_UPPAGE :				/* Page vers le haut */
		if (lin > 0)					/* Si on n'est pas d‚j… au d‚but */
		{
			lin = max (lin - henline, 0);	/* Nouvelle ligne */
			sliders (); 				/* Actualiser le slider */
			redraw (hwind, xw, yw, ww, hw);	/* R‚affichage */
		}
		break;
	case WA_DNPAGE :				/* Page vers le bas */
		if ((lin + henline) < ht)	/* Si pas d‚j… … la fin */
		{
			lin = min (lin + henline, ht - henline);	/* Nouvelle ligne */
			sliders (); 				/* Actualiser le slider */
			redraw (hwind, xw, yw, ww, hw);	/* R‚affichage */
		}
		break;
	case WA_UPLINE :				/* Ligne vers le haut */
		if (lin > 0)					/* Si on n'est pas d‚j… au d‚but */
		{
			lin--;							/* Nouvelle ligne */
			sliders (); 				/* Actualiser le slider */
			redraw (hwind, xw, yw, ww, hw);	/* R‚affichage */
		}
		break;
	case WA_DNLINE :				/* Ligne vers le bas */
		if ((lin + henline) < ht)	/* Si pas d‚j… … la fin */
		{
			lin++;							/* Nouvelle ligne */
			sliders (); 				/* Actualiser le slider */
			redraw (hwind, xw, yw, ww, hw);	/* R‚affichage */
		}
		break;
	}
}
/* #] Arrow : */ 
/* #[ Slider V : */
void vslider (void)
{
int slide, xw, yw, ww, hw, henline;

	slide = buf[4];
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);	/* Coord. zone de travail */
	henline = hw / hauteur;					/* Hauteur en lignes */
		/* Calcul de la ligne : */
	lin = ((long)slide * (ht - (long)henline) / 1000.0);
	if (lin + henline > ht)					/* Corrections */
		lin = ht - henline;
	if (lin < 0)
		lin = 0;
	wind_set (buf[3], WF_VSLIDE, slide);	/* Positionner le slider */
	redraw (hwind, xw, yw, ww, hw);	/* R‚affichage */
}
/* #] Slider V : */ 
/* #[ Taille et position slider V : */
void sliders (void)
{
int slide, xw, yw, ww, hw, nbre_larg, henline;

		/* Coordonn‚es zone de travail : */
	wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
	nbre_larg = max (1, ww / largeur);					/* Nbre d'ic“nes en largeur */
	ht = (nbre_icon + (nbre_larg - 1)) / nbre_larg;	/* Nbre de lignes (hauteur totale) */
	henline = hw / hauteur;											/* Hauteur en lignes */

	wind_set (hwind, WF_VSLSIZE,								/* Taille slider vertical */
						(int)((double)1000 * (double)((double)henline /
						(double)ht)));
	lin = min (lin, ht - henline); /* Calculer la ligne */
	lin = max (0, lin);

	slide = lin * 1000.0 / (ht - henline); 			/* Position slider vertical */
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (hwind, WF_VSLIDE, slide);					/* Positionner le slider */
}
/* #] Taille et position slider V : */ 
/* #[ path () Cherche et retourne le chemin de l'application :		*/
char *path (char *pat)
{
int drive;

	drive = Dgetdrv ();							/* Lecteur courant */
	pat[0] = (char) (65 + drive);
	pat[1] = ':';
	Dgetpath (&pat[2], drive + 1);	/* Chemin lecteur courant */
	strcat (pat, "\\*.*");					/* Ajout masque de recherche */
	return pat;
}
/* #] path () Cherche et retourne le chemin de l'application :		*/ 

