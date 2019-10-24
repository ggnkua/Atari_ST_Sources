/*	FINDFILE : Recherche de fichiers
		FF_INTRF.C : Module d'interface */

/* D‚finitions :																									*/
#include <string.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "findfile.h"
#include "ff_defs.h"
#include "ff_intrf.h"

/* Variables globales :																					*/
extern int handle;											/* Handle VDI */
extern int ask;													/* Demande confirmation */
extern int mode;												/* Mode de recherche */
extern int wcell, hcell;								/* Largeur et hauteur caractŠres */
extern int xb, yb, wb, hb;							/* Coordonn‚es bureau */
extern int objet;												/* Dernier objet cliqu‚ */
extern int buf[8];											/* Buffer d'‚v‚nements */
extern int mx, my, mk, kbd, key, clik;	/* Posi souris, clavier, nbre clics */
extern char chrec[128];									/* Chemin de recherche */
extern OBJECT *adrm, *adrb;							/* Adresse menu, bureau */
extern OBJECT *adrpr, *adrpl, *adrt, *adre;	/* Adresses par rech, par list, trouve */
extern OBJECT *adru;										/* Adresse images Userdefs */
extern Wind *win;												/* Travail avec les fenˆtres */
extern USERBLK *adr_usr;								/* Objets UserDefs */

/* Prototypage :																									*/
long exist (char *name, int att);
void editer (OBJECT *adr, int edit);
int next (OBJECT *adr, int edit);
int prev (OBJECT *adr, int edit);
void sim_redraw (int f, int x, int y, int w, int h);
void draw_texte (int index);
void fill_tab (int *pxy, int n, ...);
int verif_date (char *string);
void open_texte (int index);
void print_lin (int x, int y, int w, int h, int f, int index, int decal);
void print_col (int x, int y, int w, int h, int f, int index, int decal);

/* dcl_wind () D‚clare les fenˆtres :														*/
void dcl_wind (int nbre)
{
register int i;

	win = (Wind *)malloc (sizeof (Wind) * nbre);
	for (i = ZERO ; i < nbre ; i++)
	{
		win[i].hg = BLANK;							/* Handle GEM */
		win[i].attr = ZERO;							/* Attributs GEM */
		win[i].type = BLANK;						/* Type formulaire ou texte */
		win[i].full = FALSE;						/* Pas pleine ouverture */
		if (i + 1 < nbre)
			win[i].last = FALSE;
		else
			win[i].last = TRUE;
		win[i].curr.g_x = xb;					/* Position courante */
		win[i].curr.g_y = yb;
		win[i].curr.g_w = wb;
		win[i].curr.g_h = hb;
		win[i].cont.form = (OBJECT *)ZERO;		/* Contenu de la fenˆtre */
		win[i].nbrel = ZERO;
		win[i].title = ZERO;						/* Pointeur sur le titre */
		win[i].wtot = ZERO;							/* Largeur totale */
		win[i].htot = ZERO;							/* Hauteur totale */
		win[i].lin = ZERO;							/* 1ø ligne de pixels */
		win[i].col = ZERO;							/* 1ø colonne de pixels */
	}
	win[WLISTE].curr.g_w = wb / 2;
	win[WHELP].curr.g_h = hb / 2;
}

/* userdf () Routine bouton Coch‚ :															*/
int cdecl userdf (PARMBLK *para)
{
int tab[4], pxy[8], pox, poy, sel,
		dummy, obj, color[2];
char *texte;
MFDB nul = {0}, pic, msk;

	vst_font (handle, 1);
	fill_tab (tab, 4,			/* Zone de clip */
							para->pb_xc, para->pb_yc,
							para->pb_wc + para->pb_xc - 1, para->pb_hc + para->pb_yc - 1);
	vs_clip (handle, TRUE, tab);	/* Clip ON */

	sel = para->pb_currstate & SELECTED;

	if (para->pb_tree[para->pb_obj].ob_flags & RBUTTON)
		obj = sel ? RBS : RBN;
	else
		obj = sel ? BCS : BCN;

	pic.fd_addr = (void *) adru[obj].ob_spec.iconblk->ib_pdata;
	msk.fd_addr = (void *) adru[obj].ob_spec.iconblk->ib_pmask;
	pic.fd_w = msk.fd_w = 16;
	pic.fd_h = msk.fd_h = 16;
	pic.fd_wdwidth = msk.fd_wdwidth = 1;
	pic.fd_nplanes = msk.fd_nplanes = 1;
	pic.fd_stand = msk.fd_stand = ZERO;

	fill_tab (pxy, 8,
						ZERO, ZERO, pic.fd_w - 1, pic.fd_h - 1,
						para->pb_x, para->pb_y,
						para->pb_x + pic.fd_w - 1,
						para->pb_y + pic.fd_h - 1);

	color[0] = WHITE;
	color[1] = WHITE;
	vrt_cpyfm (handle, MD_TRANS, pxy, &msk, &nul, color);
	color[0] = BLACK;
	vrt_cpyfm (handle, MD_TRANS, pxy, &pic, &nul, color);

	texte = (char *)para->pb_parm;	/* R‚cup‚rer pointeur sur le texte */
	vst_color (handle, BLACK);
	vst_alignment (handle, 0, 5, &dummy, &dummy);
	vswr_mode (handle, MD_TRANS);		/* Texte en mode transparent */
	vst_effects (handle, ZERO);		/* D‚sactiver tous les effets */
	pox = para->pb_x + hcell + wcell;				/* Position en x */
	poy = para->pb_y;								/* et en y. */
	v_gtext (handle, pox, poy, texte);	/* ‚crire. */
	vs_clip (handle, FALSE, tab);	/* Clip OFF */
	return (para->pb_currstate & ~SELECTED);
}

/* dialog () Gestion GEM ‚tendue : 															*/
int dialog (int flags, OBJECT *address)
{ 	/* Fonction qui remplace le form_do du GEM */
int evnt; 							/* Type d'‚v‚nement */
int dummy, i, j;				/* Divers */
int whandle;						/* Handle fenˆtre cliqu‚e */
int top;								/* Handle fenˆtre de premier plan */
int obflags, obstate; 	/* ob_flags et ob_state objet cliqu‚ */
int pere, hide = FALSE;	/* PŠre de l'objet, cach‚ */
int index;							/* Index fenˆtre */
OBJECT *adr;						/* Adresse formulaire sur lequel on travaille */
char option[50], ctr; 	/* Pour la recherche dans le menu */
unsigned char touc;			/* Pour les raccourcis clavier */

	objet = ZERO;		/* Mise … z‚ro avant de commencer */

	while (TRUE) 				/* BOUCLE "SANS FIN" */
	{ 	/* Surveillance des ‚v‚nements Clavier, Clic, Message et Timer */
		evnt = evnt_multi (flags, 2, 1, 1,
											 ZERO, ZERO, ZERO, ZERO, ZERO,
											 ZERO, ZERO, ZERO, ZERO, ZERO,
											 buf, 10, 0, &mx, &my, &mk, &kbd, &key, &clik);

		if (evnt & MU_KEYBD)		/* Si ‚v‚nement clavier */
		{
			if (address == adrb)	/* Si on travaille sur le bureau */
			{
				wind_get (ZERO, WF_TOP, &top, &dummy, &dummy, &dummy);
				index = find_index (top);
				if (index > BLANK)
				{
					if (win[index].type == WTYPFORM)
						adr = win[index].cont.form;
					else
						adr = adrb;
				}
			}
			else			/* Si on travaille sur un formulaire */
				adr = address;	/* R‚cup‚rer adresse formulaire */

			if ((key == RETURN) || (key == ENTER)) /* Si <Return> ou <Enter> */
			{ 		/* Chercher bouton DEFAULT s'il y en a */
				i = ZERO;	/* En partant de la racine */
				do				/* Pour chaque objet */
				{
					if (adr[i].ob_flags & DEFAULT)	/* Si objet d‚faut */
					{
						adr[i].ob_state |= SELECTED;	/* S‚lectionner l'objet */
						objc_draw (adr, i, MAX_DEPTH, /* Le redessiner */
											 adr->ob_x, adr->ob_y,
											 adr->ob_width, adr->ob_height);
						evnt = MU_BUTTON; /* Modifier type d'‚v‚nement */
						objet = i;				/* Enregistrer l'objet */
						return (evnt);		/* Retourner l'‚v‚nement */
					}
				} while (NOT (adr[i++].ob_flags & LASTOB)); /* Jusqu'au dernier objet */
			}
			else			/* Sinon, chercher raccourcis dans le menu */
			{
				kbd = (int)Kbshift (BLANK);	/* Prendre ‚tat des touches sp‚ciales */
				kbd &= ~0x10;								/* Annuler bit CapsLock */
				if ((kbd == K_RSHIFT) || (kbd == K_LSHIFT))
					ctr = 0x01;		/* CaractŠre repr‚sentant la touche sp‚ciale */
				else if (kbd == K_CTRL)
					ctr = 0x05E;
				else if (kbd == K_ALT)
					ctr = 0x07;
				else
					ctr = ZERO;
				if (ctr)
				{
					stdkey (&touc); 	/* Recherche code Ascii */
					i = ZERO;
					do		/* Pour chaque objet du menu */
					{
						if (adrm[i].ob_type == G_STRING)	/* Si c'est une option */
						{
							strcpy (option, adrm[i].ob_spec.free_string); /* La lire */
							trim (option);	/* Virer les espaces */
							if ((*(option + strlen (option) - 1) == touc) &&
									(*(option + strlen (option) - 2) == ctr))
							{ 	/* Si le caractŠre et la touche sp‚ciale correspondent */
								if (NOT (adrm[i].ob_state & DISABLED))	/* Si actif */
								{
									evnt = MU_MESAG;	/* Fabriquer un ‚v‚nement */
									buf[0] = MN_SELECTED;
									buf[3] = m_title (adrm, i); /* Titre de l'option */
									buf[4] = i;
									menu_tnormal (adrm, buf[3], FALSE);
								}
							}
						}
					} while (NOT (adrm[i++].ob_flags & LASTOB));
				}
			}
		}

		if (evnt & MU_MESAG)					/* Si ‚v‚nement message */
			return evnt;

		if (evnt & MU_BUTTON) 	/* Si ‚v‚nement clic souris */
		{
			adr = address;						/* Adresse de travail */
			if (address == adrb)			/* Si on travaille sur le bureau */
			{
				whandle = wind_find (mx, my); /* A t-on cliqu‚ sur une fenˆtre ? */
				if (whandle)									/* Si oui */
				{ 	/* Chercher fenˆtre de premier plan */
					wind_get (ZERO, WF_TOP, &top, &dummy, &dummy, &dummy);
					if (whandle == top) 	/* Si on a cliqu‚ la fenˆtre de 1ø plan */
					{
						index = find_index (top);
						if (index > BLANK)
						{
							if (win[index].type == WTYPFORM)
								adr = win[index].cont.form;
						}
					}
				}
			}

			objet = objc_find (adr, ROOT, MAX_DEPTH, mx, my); /* Objet cliqu‚ */
			if (objet > BLANK) 		/* Si on a cliqu‚ sur un objet */
			{
				obflags = adr[objet].ob_flags;	/* Noter ob_flags objet */
				obstate = adr[objet].ob_state;	/* Noter ob_state objet */
	
				if (obstate & DISABLED) 				/* Si l'objet est d‚sactiv‚ */
					return (evnt);		/* Sortir de suite */
	
				if (NOT (obflags & TOUCHEXIT))		/* Si ce n'est pas un TOUCHEXIT */
				{
					while (mk)	/* Attendre bouton souris relach‚ */
						graf_mkstate (&dummy, &dummy, &mk, &dummy);
				}
	
				if ((obflags & SELECTABLE) &&
						(NOT (obflags & RBUTTON)))		/* Si s‚lectable simple */
				{
					adr[objet].ob_state ^= SELECTED;		/* Inverser l'‚tat de l'objet */
					objc_draw (adr, objet, MAX_DEPTH, 	/* Redessiner l'objet */
										 adr->ob_x, adr->ob_y,
										 adr->ob_width, adr->ob_height);
				}
	
				if ((obflags & SELECTABLE) &&
						(obflags & RBUTTON) &&
						(NOT (obstate & SELECTED))) 	/* Si radio-bouton */
				{
					j = objet;											/* Partir de cet objet */
					adr[objet].ob_state |= SELECTED;	/* Le s‚lectionner */
					objc_draw (adr, objet, MAX_DEPTH, adr->ob_x, adr->ob_y,
										 adr->ob_width, adr->ob_height);
					i = parent (adr, j);				/* Chercher le pŠre */
					j = adr[i].ob_head; 				/* Partir du 1ø enfant... */
					i = adr[i].ob_tail; 				/* jusqu'au dernier. */
					do
					{
						if ((adr[j].ob_flags & RBUTTON) && (j != objet) &&
								(adr[j].ob_state & SELECTED))
						{ 	/* Les mettre en normal si RBUTTON sauf l'objet cliqu‚. */
							adr[j].ob_state &= ~SELECTED;
							objc_draw (adr, j, MAX_DEPTH, adr->ob_x, adr->ob_y,
												 adr->ob_width, adr->ob_height);
						}
						j = adr[j].ob_next; 											/* Au suivant... */
					} while ((j <= i) && (j > adr[i].ob_next)); /* jusqu'au dernier. */
				}
	
				if (obflags & EDITABLE) 				/* Si ‚ditable */
				{
					pere = parent (adr, objet);
					if (adr[pere].ob_flags & HIDETREE)
						hide = TRUE;
					while ((pere > ROOT) && (NOT hide))
					{
						pere = parent (adr, pere);
						if (adr[pere].ob_flags & HIDETREE)
							hide = TRUE;
					}
					if (NOT hide)
						editer (adr, objet);
				}
			}
			if ((adr != adrb) && (adr != address))
			{
				evnt = MU_BUTTON;		/* Fabriquer un ‚v‚nement */
				buf[0] = EV_WFORM;	/* Clic dans une fenˆtre formulaire */
				buf[3] = index; 		/* Index de la fenˆtre */
				buf[4] = objet;			/* Objet cliqu‚ */
			}
			return (evnt);
		}
	}
}

/* editer () G‚rer champs ‚ditables :														*/
void editer (OBJECT *adr, int edit)
{
int b[8], evnt, xm, ym, km, k, dummy, quit = FALSE, result,
		champ, pos, object, pere, base = BLANK, hide = FALSE;
char date1[7], date2[7], *alrt;

	if ((edit == C_FILTRE1) || (edit == C_FILTRE2) || (edit == C_FILTRE3))
	{
		adr[C_FILTRE1].ob_state |= SELECTED;
		adr[C_FILTRE2].ob_state |= SELECTED;
		adr[C_FILTRE3].ob_state |= SELECTED;
		draw_object (WPARREC, C_FILTRE1);
		draw_object (WPARREC, C_FILTRE2);
		draw_object (WPARREC, C_FILTRE3);
		base = BOXCHEMINS;
	}
	else if ((edit == F_DAT1) || (edit == F_DAT2))
	{
		adr[F_DAT1].ob_state |= SELECTED;
		adr[F_DAT2].ob_state |= SELECTED;
		draw_object (WPARREC, F_DAT1);
		draw_object (WPARREC, F_DAT2);
		base = BOXFILTRE;
	}
	else if (edit == F_MDATCHOIX)
	{
		adr[F_MDATCHOIX].ob_state |= SELECTED;
		draw_object (WPARREC, F_MDATCHOIX);
		base = BOXMODIF;
	}
	if (edit == BLANK)
		return;

	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris */
	objc_edit (adr, edit, 0, &pos, ED_INIT);	/* Activer */
	do
	{
		evnt = evnt_multi ((MU_KEYBD|MU_BUTTON|MU_TIMER), 2, 1, 1,
											 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
											 b, 10, 0, &xm, &ym, &km, &dummy, &k, &dummy);
		if (evnt & MU_KEYBD)
		{
			if ((k == RETURN) || (k == ENTER))
			{
				result = TRUE;
				if (base == BOXFILTRE)
				{
					strcpy (date1, adrpr[F_DAT1].ob_spec.tedinfo->te_ptext);
					if (adrpr[F_DATENTRE].ob_state & SELECTED)
						strcpy (date2, adrpr[F_DAT2].ob_spec.tedinfo->te_ptext);
					else
						strcpy (date2, "061294");
					if (NOT ((verif_date (date1)) && (verif_date (date2))))
						result = FALSE;
				}
				else if (base == BOXMODIF)
				{
					strcpy (date1, adrpr[F_MDATCHOIX].ob_spec.tedinfo->te_ptext);
					if (NOT (verif_date (date1)))
						result = FALSE;
				}
				if (result)
					quit = TRUE;
				else
				{
					rsrc_gaddr (R_FRSTR, BADDATE, &alrt);	/* Adr chaŒne pointeur sur pointeur */
					alrt = *((char **)alrt);							/* Pointeur sur le texte */
					form_alert (1, alrt); 								/* Afficher l'alerte */
				}
			}
			else if (k == ARDN)			/* Si flŠche vers le bas */
			{
				champ = next (adr, edit); /* Chercher champ suivant */
				if (champ > -1) /* S'il y en a un */
				{
					objc_edit (adr, edit, 0, &pos, ED_END); 	/* D‚sactiver */
					edit = champ; 	/* Nouvel ‚ditable */
					objc_edit (adr, edit, 0, &pos, ED_INIT);	/* R‚activer */
				}
			}
			else if (k == ARUP) /* Si flŠche vers le haut */
			{
				champ = prev (adr, edit); /* Chercher champ pr‚c‚dent */
				if (champ > -1) /* S'il y en a un */
				{
					objc_edit (adr, edit, 0, &pos, ED_END); 	/* D‚sactiver */
					edit = champ; 	/* Nouvel ‚ditable */
					objc_edit (adr, edit, 0, &pos, ED_INIT);	/* R‚activer */
				}
			}
			else										/* Si autre touche */
			{ 	/* Le GEM s'occupe de tout */
				objc_edit (adr, edit, k, &pos, ED_CHAR);
			}
		}
		else if (evnt& MU_BUTTON)
		{
			object = objc_find (adr, base, MAX_DEPTH, xm, ym);
			if ((adr[object].ob_flags & EDITABLE) &&				/* Si ‚ditable */
					(NOT (adr[object].ob_state & DISABLED)))
			{
				pere = parent (adr, object);
				if (adr[pere].ob_flags & HIDETREE)
					hide = TRUE;
				while ((pere > ROOT) && (NOT hide))
				{
					pere = parent (adr, pere);
					if (adr[pere].ob_flags & HIDETREE)
						hide = TRUE;
				}
				if (NOT hide)
				{
					objc_edit (adr, edit, 0, &pos, ED_END); 	/* D‚sactiver */
					edit = object;
					objc_edit (adr, edit, 0, &pos, ED_INIT);	/* R‚activer */
				}
			}
		}
	} while (NOT quit);
	objc_edit (adr, edit, 0, &pos, ED_END); 	/* D‚sactiver */
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris */

	switch (base)
	{
	case BOXCHEMINS :
		adr[C_FILTRE1].ob_state &= ~SELECTED;
		adr[C_FILTRE2].ob_state &= ~SELECTED;
		adr[C_FILTRE3].ob_state &= ~SELECTED;
		draw_object (WPARREC, C_FILTRE1);
		draw_object (WPARREC, C_FILTRE2);
		draw_object (WPARREC, C_FILTRE3);
		break;
	case BOXFILTRE :
		adr[F_DAT1].ob_state &= ~SELECTED;
		adr[F_DAT2].ob_state &= ~SELECTED;
		draw_object (WPARREC, F_DAT1);
		draw_object (WPARREC, F_DAT2);
		break;
	case BOXMODIF :
		adr[F_MDATCHOIX].ob_state &= ~SELECTED;
		draw_object (WPARREC, F_MDATCHOIX);
	}
}

/* find_index () Cherche index fenˆtre GEM :									*/
int find_index (int wh)
{
register int i = ZERO;

	if (wh > ZERO)
	{
		do
		{
			if (wh == win[i].hg)
				return i;
		} while (NOT (win[i++].last));
	}
	return BLANK;
}

/* parent () Cherche le pŠre d'un objet :												*/
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

/* next () Champ suivant : 																			*/
int next (OBJECT *adr, int edit)
{ 	/* Chercher l'‚ditable suivant */
int pere, vu = 1, ob = edit;

	while (NOT (adr[ob++].ob_flags & LASTOB))
	{ 	/* Tant qu'on n'est pas au dernier objet */
		pere = parent (adr, ob);	/* Chercher son pŠre */
			/* Si ce n'est pas la racine et pas HIDETREE */
		while ((pere > 0) && (vu))
		{ 	/* Si le pŠre est HIDETREE */
			if (adr[pere].ob_flags & HIDETREE)
				vu = 0; 	/* l'objet n'est pas visible */
			pere = parent (adr, pere);	/* PŠre suivant */
		}
		if (vu) /* Si l'objet est visible */
			if ((adr[ob].ob_flags & EDITABLE) &&
					(NOT (adr[ob].ob_flags & HIDETREE)) &&
					(NOT (adr[ob].ob_state & DISABLED)))	/* Si ‚ditable actif */
				return ob;	/* Retourner son num‚ro */
	}
	return -1;	/* Sinon, -1 */
}

/* prev () Champ pr‚c‚dent : 																		*/
int prev (OBJECT *adr, int edit)
{ 	/* Chercher l'‚ditable pr‚c‚dent */
int pere, vu = 1, ob = edit;

	while (ob-- > 0)		/* En arriŠre jusqu'… la racine */
	{
		pere = parent (adr, ob);		/* PŠre de l'objet */
			/* Si ce n'est pas la racine et pas HIDETREE */
		while ((pere > 0) && (vu))
		{ 	/* Si le pŠre est HIDETREE */
			if (adr[pere].ob_flags & HIDETREE)
				vu = 0; 	/* L'objet n'est pas visible */
			pere = parent (adr, pere);	/* PŠre suivant */
		}
		if (vu) /* Si l'objet est visible */
			if ((adr[ob].ob_flags & EDITABLE) &&
					(NOT (adr[ob].ob_flags & HIDETREE)) &&
					(NOT (adr[ob].ob_state & DISABLED)))	/* Si ‚ditable actif */
				return ob;	/* Retourner son num‚ro */
	}
	return -1;	/* Sinon, -1 */
}

/* stdkey () Test tous claviers :																*/
void stdkey (unsigned char *k)
{
KEYTAB *kt;

	kt = Keytbl((void *)-1, (void *)-1, (void *)-1);
	*k = toupper (kt->shift[(char)(key >> 8)]);
}

/* trim () Vire espaces d‚but et fin de chaŒne :									*/
char *trim (char *str)
{
register char	*s;
register int i = ZERO;

	while ((*(str + i) == ' ') || (*(str + i) == '\t'))
		i++;
	strcpy (str, (str + i));

	s = str + strlen (str) - 1;
	for( ; ((*s == ' ') || (*s == '\t')) && (s >= str) ; *s-- = ZERO);
	return str;
}

/* m_title () Cherche le titre de menu d'une option :						*/
int m_title (OBJECT *adresse, int option)
{
register menu = 1, k = 2;
int pere, titre;

	pere = parent (adresse, option);
	while (adresse[(k++) + 1].ob_type != G_BOX) ; /* Chercher 1ø G_BOX */

	while (k != pere)
	{
		k = adresse[k].ob_next; 		/* Chercher menu correspondant */
		menu++; 										/* Les compter */
	}

	k = 3;
	do
	{
		titre = k++;				/* L'affecter */
	} while ((k - 3) != menu);

	return titre;
}

/* rc_intersect () Intersection :																*/
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

/* set_clip () Clipping :																				*/
void set_clip (int clip_flag, GRECT *area)
{ 	/* Active ou d‚sactive le clipping d'une zone */
int pxy[4];

	pxy[0] = area->g_x;
	pxy[1] = area->g_y;
	pxy[2] = area->g_w + area->g_x - 1;
	pxy[3] = area->g_h + area->g_y - 1;
	vs_clip (handle, clip_flag, pxy);
}

/* open_file () Charge un fichier Liste ou Aide :								*/
void open_file (char *file, int fen)
{
int fh, nlines = ZERO, i, maxi = ZERO;
long taille;
char *zone, *ptr;

	taille = exist (file, ZERO);					/* Prendre la taille du fichier */
	if (taille)														/* S'il existe */
	{
		if (win[fen].cont.lignes)						/* Lib‚rer m‚moires pr‚c‚dentes */
		{
			free (win[fen].cont.lignes[0]);
			free (win[fen].cont.lignes);
		}

		zone = (char *)malloc (taille);			/* R‚server m‚moire */
		if (zone)
		{
			fh = (int)Fopen (file, FO_READ);	/* Ouvrir fichier */
			Fread (fh, taille, zone);					/* Charger en m‚moire */
			Fclose (fh);											/* Fermer fichier */
			ptr = zone;
			do
			{
				if (*ptr == '\r')								/* Remplacer fins de lignes par '\0' */
				{
					*ptr = '\0';
					nlines++;											/* Compter les lignes */
					ptr++;
				}
				ptr++;
			} while (ptr < zone + taille);
			win[fen].cont.lignes = (char **)malloc (nlines * sizeof (char **));	/* M‚moire pointeurs sur les lignes */
			ptr = zone;												/* Partir du d‚but */
			for (i = ZERO ; i < nlines ; i++)	/* Pour chaque ligne */
			{
				win[fen].cont.lignes[i] = ptr;	/* Pointer dessus */
				maxi = max (maxi, (int)strlen (ptr));	/* Ligne la plus longue */
				ptr += (strlen (ptr) + 2);			/* Ligne suivante */
			}
			win[fen].htot = hcell * nlines;			/* Hauteur totale */
			win[fen].wtot = wcell * (maxi + 1);	/* Largeur maxi */
			win[fen].nbrel = nlines;						/* Enregistrer nbre de lignes */
			open_texte (fen);									/* Ouvrir la fenˆtre */
		}
	}
	else																	/* Si le fichier n'existe pas */
	{
		if (win[fen].hg > ZERO)							/* Si la fenˆtre est ouverte */
		{
			wind_close (win[fen].hg);					/* La fermer */
			wind_delete (win[fen].hg);
			win[fen].hg = ZERO;								/* Tout remettre … 0 */
			win[fen].full = FALSE;
			win[fen].lin = win[fen].col = ZERO;
			if (fen == WLISTE)
				adrm[M_PRINTL].ob_state |= DISABLED;
		}
	}
}

/* open_texte () Ouvre fenˆtre de texte :												*/
void open_texte (int index)
{
int attr = (NAME|MOVER|CLOSER|FULLER|SIZER|UPARROW|DNARROW|LFARROW|RTARROW|VSLIDE|HSLIDE);
int old_buf3;
char *str;

	if (win[index].hg > ZERO)
	{
		wind_set (win[index].hg, WF_TOP);
		win[index].lin = win[index].col = ZERO;
		sliders (index);
		sim_redraw (win[index].hg,			/* R‚affichage */
								win[index].curr.g_x, win[index].curr.g_y,
								win[index].curr.g_w, win[index].curr.g_h);
	}
	else
	{
		win[index].hg = wind_create (attr,
																 win[index].curr.g_x, win[index].curr.g_y,
																 win[index].curr.g_w, win[index].curr.g_h);
		if (win[index].hg)
		{
			win[index].attr = attr;
			win[index].type = WTYPTEXT;
			if (index == WHELP)
				rsrc_gaddr (R_FRSTR, F_AIDE, &str);	/* Adr chaŒne pointeur sur pointeur */
			else if (index == WLISTE)
				rsrc_gaddr (R_FRSTR, F_LISTE, &str);
			win[index].title = *((char **)str);		/* Pointeur sur le texte */
			wind_set (win[index].hg, WF_NAME, win[index].title); /* Titre fenˆtre */
			wind_open (win[index].hg,
								 win[index].curr.g_x, win[index].curr.g_y,
								 win[index].curr.g_w, win[index].curr.g_h);
			old_buf3 = buf[3];
			buf[3] = win[index].hg;
			sliders (index);
			buf[3] = old_buf3;
		}
	}
	if (index == WLISTE)
		adrm[M_PRINTL].ob_state &= ~DISABLED;
}

/* draw_object () Dessin objet dans fenˆtre formulaire :					*/
void draw_object (int index, int object)
{
GRECT rd, r, z;
OBJECT *adr;

	if (win[index].hg <= ZERO)
		return;
	if (win[index].type != WTYPFORM)
		return;

	adr = win[index].cont.form;

	wind_get (win[index].hg, WF_FIRSTXYWH,
						&rd.g_x, &rd.g_y, &rd.g_w, &rd.g_h);
	objc_offset (adr, object, &r.g_x, &r.g_y);
	r.g_w = adr[object].ob_width;
	r.g_h = adr[object].ob_height;
	wind_get (win[index].hg, WF_WORKXYWH, &z.g_x, &z.g_y, &z.g_w, &z.g_h);
	while((rd.g_w > ZERO) && (rd.g_h > ZERO))
	{
		if (rc_intersect (&r, &rd))
		{
			rc_intersect (&z, &rd);
			if ((rd.g_w > ZERO) && (rd.g_h > ZERO))
				objc_draw (adr, ROOT, MAX_DEPTH, rd.g_x, rd.g_y, rd.g_w, rd.g_h);
		}
		wind_get (win[index].hg, WF_NEXTXYWH,
						&rd.g_x, &rd.g_y, &rd.g_w, &rd.g_h);
	}
}

/* sim_redraw () Simule un redraw :															*/
void sim_redraw (int f, int x, int y, int w, int h)
{
	buf[3] = f;
	buf[4] = x;
	buf[5] = y;
	buf[6] = w;
	buf[7] = h;
	redraw ();
}

/* redraw () Redraw :																						*/
void redraw (void)
{ 	/* Gestion des redraws */
GRECT r, rd;
int index;

	index = find_index (buf[3]);

	rd.g_x = buf[4];	/* Coordonn‚es rectangle … redessiner */
	rd.g_y = buf[5];
	rd.g_w = buf[6];
	rd.g_h = buf[7];

	v_hide_c (handle);	/* Virer la souris */
	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris */

		/* Demande les coord. et dimensions du 1ø rectangle de la liste */
	wind_get (buf[3], WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)			/* Tant qu'il y a largeur ou hauteur... */
	{
		if (rc_intersect (&rd, &r)) /* Si intersection des 2 zones */
		{
			if (win[index].type == WTYPFORM)				/* Si fenˆtre formulaire */
				objc_draw (win[index].cont.form, ROOT, MAX_DEPTH, r.g_x, r.g_y, r.g_w, r.g_h);
			else			/* Si fenˆtre Aide ou Liste */
			{
				set_clip (1, &r); 	/* Clipping ON */
				draw_texte (index);
				set_clip (0, &r); 	/* Clipping OFF */
			}
		}
			/* Rectangle suivant */
		wind_get (buf[3], WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris */
	v_show_c (handle, 1); 			/* Rappeler la souris */
}

/* draw_texte () Affiche texte aide ou liste :										*/
void draw_texte (int index)
{
int first, nbre, i, xw, yw, ww, hw, x, y, pxy[4], dummy;

	first = (int)(win[index].lin / (long)hcell);
	wind_get (win[index].hg, WF_WORKXYWH, &xw, &yw, &ww, &hw);
	nbre = hw / hcell;

	pxy[0] = xw;								/* Pr‚parer effacement fenˆtre */
	pxy[1] = yw;
	pxy[2] = xw + ww - 1;
	pxy[3] = yw + hw - 1;
	vswr_mode (handle, MD_REPLACE);		/* Dessin en mode Remplacement */
	vsf_color (handle, WHITE);				/* Couleur blanche */
	v_bar (handle, pxy);							/* "Vider" la fenˆtre */

	vst_alignment (handle, 0, 5, &dummy, &dummy);
	x = xw + wcell - (int)win[index].col;
	y = yw;
	i = first;
	while ((i <= (first + nbre)) && (y < yw + hw) && (i < win[index].nbrel))
	{
		v_gtext (handle, x, y, win[index].cont.lignes[i]);
		y += hcell;
		i++;
	}
}

/* fill_tab () Remplissage d'un tableau :												*/
void fill_tab (int *pxy, int n, ...)
{
int i, val;
va_list pa;

	va_start (pa, n);
	for (i = ZERO ; i < n ; i++)
	{
		val = va_arg (pa, int);
		*(pxy + i) = val;
	}
	va_end (pa);
}

/* fulled () Plein pot ou retour : 															*/
void fulled (void)
{
int index, x, y, w, h;

	index = find_index (buf[3]);
	if (index == BLANK)
		return;

	if (win[index].full) 					/* Si elle est d‚j… plein pot */
	{
		wind_get (buf[3], WF_PREVXYWH, &x, &y, &w, &h); /* Coord. pr‚c‚dentes */
		wind_set (buf[3], WF_CURRXYWH, x, y, w, h); 		/* Nouvelles coord. */
		win[index].full = FALSE; 									/* Annuler flag */
	}
	else											/* Sinon */
	{
		wind_set (buf[3], WF_CURRXYWH, xb, yb, wb, hb); /* Coord. maxi */
		win[index].full = TRUE; 									/* Positionner flag */
	}
	sliders (index); /* Ajuster tailles et positions sliders */
}

/* arrow () Traitement ascenseurs : 															*/
void arrow (void)
{
int xw, yw, ww, hw, index, decal, pxy[8];
MFDB ecr = {0};

	index = find_index (buf[3]);
	if (index == BLANK)
		return;

	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
	switch (buf[4])
	{
	case WA_UPPAGE :				/* Page vers le haut */
		if (win[index].lin > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			win[index].lin = max (win[index].lin - hw, 0);	/* Nouvelle ligne */
			win[index].lin = ((win[index].lin + (hcell / 2)) / hcell) * hcell;
			sim_redraw (win[index].hg, xw, yw, ww, hw);	/* R‚affichage */
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	case WA_DNPAGE :				/* Page vers le bas */
		if ((win[index].lin + hw) < win[index].htot)	/* Si pas d‚j… … la fin */
		{
			win[index].lin = min (win[index].lin + hw, win[index].htot - hw);	/* Nouvelle ligne */
			win[index].lin = ((win[index].lin + (hcell / 2)) / hcell) * hcell;
			sim_redraw (win[index].hg, xw, yw, ww, hw);	/* R‚affichage */
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	case WA_UPLINE :				/* Ligne vers le haut */
		if (win[index].lin > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			decal = (int)min (hcell, win[index].lin);
			win[index].lin -= decal; /* Nouvelle ligne */
			if (win[index].lin < 0)
				win[index].lin = 0;
			fill_tab (pxy, 8,
								xw, yw, xw + ww - 1, yw + hw - decal - 1,
								xw, yw + decal, xw + ww - 1, yw + hw - 1);
			v_hide_c (handle);
			vro_cpyfm (handle, S_ONLY, pxy, &ecr, &ecr);
			v_show_c (handle, TRUE);
			print_lin (xw, yw, ww, hw, FALSE, index, decal);
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	case WA_DNLINE :				/* Ligne vers le bas */
		if ((win[index].lin + hw) < win[index].htot)	/* Si pas d‚j… … la fin */
		{
			decal = (int)min (hcell, win[index].htot - (win[index].lin + (long)hw));
			win[index].lin += decal; /* Nouvelle ligne */
			if (win[index].lin + hw > win[index].htot)
				win[index].lin = win[index].htot - hw;
			fill_tab (pxy, 8,
								xw, yw + decal, xw + ww - 1, yw + hw - 1,
								xw, yw, xw + ww - 1, yw + hw - 1 - decal);
			v_hide_c (handle);
			vro_cpyfm (handle, S_ONLY, pxy, &ecr, &ecr);
			v_show_c (handle, TRUE);
			print_lin (xw, yw, ww, hw, TRUE, index, decal);
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	case WA_LFPAGE :				/* Page vers la gauche */
		if (win[index].col > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			win[index].col = max (win[index].col - ww, 0);	/* Nouvelle colonne */
			win[index].col = ((win[index].col + (wcell / 2)) / wcell) * wcell;
			sim_redraw (win[index].hg, xw, yw, ww, hw);	/* R‚affichage */
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	case WA_RTPAGE :				/* Page vers la droite */
		if ((win[index].col + ww) < win[index].wtot)	/* Si pas d‚j… … la fin */
		{
			win[index].col = min (win[index].col + ww, win[index].wtot - ww);	/* Nouvelle colonne */
			win[index].col = ((win[index].col + (wcell / 2)) / wcell) * wcell;
			sim_redraw (win[index].hg, xw, yw, ww, hw);	/* R‚affichage */
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	case WA_LFLINE :				/* Ligne vers la gauche */
		if (win[index].col > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			decal = (int)min (wcell, win[index].col);
			win[index].col -= decal; /* Nouvelle colonne */
			if (win[index].col < 0)
				win[index].col = 0;
			fill_tab (pxy, 8,
								xw, yw, xw + ww - 1 - decal, yw + hw - 1,
								xw + decal, yw, xw + ww - 1, yw + hw - 1);
			v_hide_c (handle);
			vro_cpyfm (handle, S_ONLY, pxy, &ecr, &ecr);
			v_show_c (handle, TRUE);
			print_col (xw, yw, ww, hw, FALSE, index, decal);
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	case WA_RTLINE :				/* Ligne vers la droite */
		if ((win[index].col + ww) < win[index].wtot)	/* Si pas d‚j… … la fin */
		{
			decal = (int)min (wcell, win[index].wtot - (win[index].col + (long)ww));
			win[index].col += decal; /* Nouvelle colonne */
			if (win[index].col + ww > win[index].wtot)
				win[index].col = win[index].wtot - ww;
			fill_tab (pxy, 8,
								xw + decal, yw, xw + ww - 1, yw + hw - 1,
								xw, yw, xw + ww - 1 - decal, yw + hw - 1);
			v_hide_c (handle);
			vro_cpyfm (handle, 3, pxy, &ecr, &ecr);
			v_show_c (handle, TRUE);
			print_col (xw, yw, ww, hw, TRUE, index, decal);
			sliders (index); 				/* Actualiser les sliders */
		}
		break;
	}
}

/* print_lin () Affiche une ligne de texte :											*/
void print_lin (int x, int y, int w, int h, int f, int index, int decal)
{
	buf[3] = win[index].hg;
	buf[4] = x;
	if (f)
		buf[5] = y + h - decal;
	else
		buf[5] = y;
	buf[6] = w;
	buf[7] = decal;
	redraw ();
}

/* print_col () Affiche une colonne de texte :										*/
void print_col (int x, int y, int w, int h, int f, int index, int decal)
{
	buf[3] = win[index].hg;
	if (f)
	 buf[4] = x + w - decal;
	else
		buf[4] = x;
	buf[5] = y;
	buf[6] = decal;
	buf[7] = h;
	redraw ();
}

/* hslider () Slider H :																					*/
void hslider (void)
{
int slide, xw, yw, ww, hw, index;

	index = find_index (buf[3]);
	if (index == BLANK)
		return;
	slide = buf[4];
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
		/* Calcul de la colonne : */
	if (slide != 1000)
	{
		win[index].col = ((long)slide * (win[index].wtot - (long)ww) / 1000.0);
		win[index].col = ((win[index].col + (wcell / 2)) / wcell) * wcell;
		if (win[index].col + ww > win[index].wtot)	/* Corrections */
			win[index].col = win[index].wtot - ww;
		if (win[index].col < 0)
			win[index].col = 0;
	}
	else
	{
		win[index].col = win[index].wtot - ww + wcell;
	}
	wind_set (buf[3], WF_HSLIDE, slide);
	sim_redraw (win[index].hg, xw, yw, ww, hw);	/* R‚affichage */
}

/* vslider () Slider V :																					*/
void vslider (void)
{
int slide, xw, yw, ww, hw, index;

	index = find_index (buf[3]);
	if (index == BLANK)
		return;
	slide = buf[4];
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
		/* Calcul de la ligne : */
	if (slide != 1000)
	{
		win[index].lin = ((long)slide * (win[index].htot - (long)hw) / 1000.0);
		win[index].lin = ((win[index].lin + (hcell / 2)) / hcell) * hcell;
		if (win[index].lin + hw > win[index].htot)	/* Corrections */
			win[index].lin = win[index].htot - hw;
		if (win[index].lin < 0)
			win[index].lin = 0;
	}
	else
	{
		win[index].lin = win[index].htot - hw + hcell;
	}
	wind_set (buf[3], WF_VSLIDE, slide);
	sim_redraw (win[index].hg, xw, yw, ww, hw);	/* R‚affichage */
}

/* sliders () Taille et positions sliders :											*/
void sliders (int index)
{
int slide, xw, yw, ww, hw;

	if (index == BLANK)
		return;
		/* Coordonn‚es zone de travail : */
	wind_get (win[index].hg, WF_WORKXYWH, &xw, &yw, &ww, &hw);

	wind_set (win[index].hg, WF_VSLSIZE, 				/* Taille slider vertical */
						(int)((double)1000 * (double)((double)hw /
						(double)win[index].htot)));

	wind_set (win[index].hg, WF_HSLSIZE, 				/* Taille slider horizontal */
						(int)((double)1000 * (double)((double)ww /
						(double)win[index].wtot)));

	slide = win[index].lin * 1000.0 / (win[index].htot - hw); /* Position vertical */
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (win[index].hg, WF_VSLIDE, slide);

	slide = win[index].col * 1000.0 / (win[index].wtot - ww); /* Position horizontal */
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (win[index].hg, WF_HSLIDE, slide);
}

/* verif_date () V‚rif date :																		*/
int verif_date (char *string)
{
int jour, mois, annee;
char nbre[3] = {ZERO, ZERO, ZERO};

	if (strlen (string) != 6) 	/* Si pas 6 caractŠres, */
		return FALSE; 						/* A d‚gager */
	else															/* Enregistre comme nombres... */
	{
		memcpy (nbre, string, 2);
		jour = atoi (nbre); 						/* Le jour */
		memcpy (nbre, string + 2, 2);
		mois = atoi (nbre); 						/* Le mois */
		memcpy (nbre, string + 4, 2);
		annee = atoi (nbre);						/* l'ann‚e */
	}

	if (jour < 1 || jour > 31)				/* Jour entre 1 et 31 */
		return FALSE;
	else if (mois < 1 || mois > 12) 	/* Mois entre 1 et 12 */
		return FALSE;
	else if (annee < 1) 							/* Annee pas sous (19)01 */
		return FALSE;
	else if ((mois == 4 || mois == 6 || mois == 9 || mois == 11) && jour > 30)	/* Mois … 30 jours -> jour < 31 */
		return FALSE;
	else if (mois == 2 && fmod ((double)annee, 4) != 0 && jour > 28)	/* F‚vrier non bisextile -> jour < 29 */
		return FALSE;
	else if (mois == 2 && fmod ((double)annee, 4) == 0 && jour > 29)	/* F‚vrier bisextile -> jour < 30 */
		return FALSE;

	return TRUE;				/* Si arriv‚ jusque l…, c'est bon, ouf ! */
}

