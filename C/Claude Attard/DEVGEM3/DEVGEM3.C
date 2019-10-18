/*	D‚velopper sous GEM 3ø listing d'exemple
				Nouvelles fonctions GEM
		Claude ATTARD pour ST MAG - Mars 1994 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include "devgem3.h"

/* Prototypage : */
void main (void);
void open_work (void);
void attach (void);
char *trim (char *str);
void afficher_alerte (int index, char *ligne);
void infos (void);
void formulaire (void);
void hierarchique (OBJECT *adr);

/* D‚finitions et variables globales : */
#define TRUE 1
#define FALSE 0

	/* Variables globales */
int xb, yb, wb, hb; /* Coordonn‚es du bureau */
int ap_id;					/* Identificateur application */
int handle; 				/* handle station de travail VDI */
int buf[8]; 				/* Buffer d'‚v‚nements */

OBJECT *adr_menu; 		/* Adresse du menu */
OBJECT *adr_desk; 		/* Adresse du bureau */

void main (void)
{
int quit = FALSE; 			/* Flag pour quitter */
int evnt;								/* Type d'‚v‚nement */
int dummy;
OBJECT **ptr, *adr;
MN_SET values;

	ap_id = appl_init (); /* D‚clarer l'application au GEM */
	open_work (); 				/* Ouvrir station de travail */
	rsrc_load ("DEVGEM3.RSC");				/* Charger le ressource */

	rsrc_gaddr (R_TREE, BUREAU, &adr_desk);			/* Demander adresse bureau */
	rsrc_gaddr (R_TREE, MENUBAR, &adr_menu);		/* Demander adresse menu */
	rsrc_gaddr (R_TREE, HIERAR, &adr);  /* Demander adresse formulaire menu hi‚rarchique */
	attach ();			/* Mettre en place les liens */

	values.Display = 200;	/* D‚lai avant que le sous-menu soit affich‚ */
	values.Drag = 0;			/* D‚lai avant disparition du sous-menu */
	values.Delay = 100;		/* D‚lai avant que le scroll commence (1ø clic sur une flŠche) */
	values.Speed = 0;			/* D‚lai entre chaque scroll */
	values.Height = 15;		/* Hauteur du sous-menu en nbre d'options */
	menu_settings (TRUE, &values);	/* Param‚trage des sous-menus */

	wind_get (0, WF_WORKXYWH, &xb, &yb, &wb, &hb);	/* Coordonn‚es du bureau */
	adr_desk->ob_x = xb;				/* Mettre le bureau aux bonnes dimensions */
	adr_desk->ob_y = yb;
	adr_desk->ob_width = wb;
	adr_desk->ob_height = hb;
	wind_set (0, WF_NEWDESK, adr_desk, 0);	/* Fixer le nouveau bureau */
	form_dial (FMD_FINISH, 0, 0, 0, 0, xb, yb, wb, hb); /* et l'afficher */

	menu_bar (adr_menu, TRUE);					 /* Afficher le menu */
	graf_mouse (ARROW, 0);						/* Souris : forme de flŠche */

	do		/* BOUCLE PRINCIPALE DU PROGRAMME */
	{ 	/* Appel fonction xform_do() qui gŠre le bureau */
		evnt = evnt_multi (0x30, 0, 0, 0,
											 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
											 buf, 10, 0,
											 &dummy, &dummy, &dummy, &dummy, &dummy, &dummy);
		if (evnt & MU_MESAG)		/* On ne s'occupe que des messages */
		{
			if (buf[0] == MN_SELECTED)		/* Si ‚v‚nement menu */
			{
				ptr = (OBJECT **)&buf[5];
				if (*ptr == adr_menu)						/* Si menu principal */
				{
					if (buf[4] == M_QUITTER)					/* Option quitter */
						quit = TRUE;
					else if (buf[4] == M_INFOS)				/* Option informations */
						infos ();
					else if (buf[4] == M_POPUP)				/* Option pop-up (dans un formulaire) */
						formulaire ();
				}
				else if (*ptr == adr)						/* Si menu hi‚rarchique */
					hierarchique (adr);								/* Afficher l'option cliqu‚e */
				menu_tnormal (adr_menu, buf[3], TRUE);	/* Remettre le titre en normal */
			}
		}
	} while (quit == FALSE);

	menu_bar (adr_menu, FALSE); 		/* Virer la barre de menu */
	wind_set (0, WF_NEWDESK, 0, 0); /* Rendre le bureau */
	rsrc_free (); 									/* Lib‚rer le ressource */
	v_clsvwk (handle);							/* Fermer station de travail */
	appl_exit (); 									/* Quitter */
}

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

void attach (void)
{
MENU menu;
OBJECT *adr1, *adr2;

		/* Menu Hi‚rarchique du menu principal */
	/* Demander adresse formulaire du menu hi‚rarchique */
	rsrc_gaddr (R_TREE, HIERAR, &adr1);
	menu.mn_tree = adr1;
	menu.mn_menu = ROOT;
	menu.mn_item = 1;
	menu.mn_scroll = 5;
	menu_attach (1, adr_menu, M_HIERAR, &menu);
	menu_istart (TRUE, adr1, ROOT, 1);

		/* Menu Hi‚rarchique du menu pop-up */
	/* Demander adresse formulaire du menu pop-up */
	rsrc_gaddr (R_TREE, POPUP1, &adr1);
	/* Demander adresse formulaire du menu hi‚rarchique du pop-up */
	rsrc_gaddr (R_TREE, POPUP2, &adr2);
	menu.mn_tree = adr2;
	menu.mn_menu = ROOT;
	menu.mn_item = 1;
	menu.mn_scroll = 5;
	menu_attach (1, adr1, DDD, &menu);
	menu_istart (TRUE, adr2, ROOT, 1);
}

char *trim (char *str)
{
register char	*s;
register int i = 0;

	while ((*(str + i) == ' ') || (*(str + i) == '\t'))
		i++;
	strcpy (str, (str + i));

	s = str + strlen (str) - 1;
	for( ; ((*s == ' ') || (*s == '\t')) && (s >= str) ; *s-- = 0);
	return str;
}

void afficher_alerte (int index, char *ligne)
{
char *alrt, texte[255];

	rsrc_gaddr (R_FRSTR, index, &alrt); /* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);						/* Pointeur sur le texte */
	sprintf (texte, alrt, ligne);
	form_alert (1, texte); 							/* Afficher l'alerte */
}

void infos (void)
{
char *alrt;

	rsrc_gaddr (R_FRSTR, INFORMATIONS, &alrt); /* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);						/* Pointeur sur le texte */
	form_alert (1, alrt); 							/* Afficher l'alerte */
}

void formulaire (void)
{
int x, y, w, h, xpos, ypos, objet, quit = FALSE, old_item2;
static int old_item1 = 1;
char texte[20];
OBJECT *adr1, *adr2, *adr_form;
MENU pu, data;

	rsrc_gaddr (R_TREE, FORMULAIRE, &adr_form);
	rsrc_gaddr (R_TREE, POPUP1, &adr1);
	rsrc_gaddr (R_TREE, POPUP2, &adr2);
	form_center (adr_form, &x, &y, &w, &h);			/* Centrer le formulaire */
	form_dial (FMD_START, 0, 0, 0, 0, x, y, w, h);	/* R‚server fond */
	objc_draw (adr_form, ROOT, MAX_DEPTH, x, y, w, h);	/* Dessiner formulaire */
	do
	{
		objet = form_do (adr_form, 0);		/* Gestion par le GEM */
		if (objet == F_CONFIRME)
			quit = TRUE;
		else if (objet == F_POPUP)
		{
			pu.mn_tree = adr1;
			pu.mn_menu = ROOT;
			pu.mn_item = old_item1;
			pu.mn_scroll = 5;
			objc_offset (adr_form, F_POPUP, &xpos, &ypos);
			if (menu_popup (&pu, xpos, ypos, &data))
			{
				strcpy (texte, data.mn_tree[data.mn_item].ob_spec.free_string);
				trim (texte);	/* Lire le texte de l'option cliqu‚e */
				if ((data.mn_tree == adr1) && (data.mn_item != DDD))	/* Si c'est une option du pop-up */
				{
					strcpy (adr_form[F_POPUP].ob_spec.free_string, texte);	/* L'afficher dans le bouton pop-up */
					objc_draw (adr_form, F_POPUP, 1, x, y, w, h);	/* Redessiner le bouton */
					adr1[old_item1].ob_state &= ~CHECKED;	/* D‚-checker l'ancienne option */
					old_item1 = data.mn_item;	/* Retenir l'option courante */
					adr1[data.mn_item].ob_state |= CHECKED;	/* Checker l'option active du pop-up */
				}
				else if (data.mn_tree == adr2)				/* Si c'est une option du sous-menu */
				{
					strcpy (adr_form[SOUSOPTION].ob_spec.free_string, texte);		/* L'afficher dans la STRING */
					objc_draw (adr_form, BOX_SO, 2, x, y, w, h);	/* Redessiner la STRING */
					old_item2 = menu_istart (FALSE, adr2, ROOT, 1);	/* Demander l'ancienne option courante */
					adr2[old_item2].ob_state &= ~CHECKED;	/* D‚-checker l'ancienne option */
					adr2[data.mn_item].ob_state |= CHECKED;	/* Checker l'option active du sous-menu */
					menu_istart (TRUE, adr2, ROOT, data.mn_item);	/* Nouvel objet de d‚part */
				}
			}
			objc_change (adr_form, objet, 0, x, y, w, h, SHADOWED, TRUE);	/* D‚s‚lectionner le bouton */
		}
	} while (quit == FALSE);
	form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h);	/* Lib‚rer fond */
	
	objc_change (adr_form, objet, 0, x, y, w, h, 0, FALSE);	/* D‚s‚lectionner le bouton */
}

void hierarchique (OBJECT *adr)
{
char texte[20];
int old_option;

	old_option = menu_istart (FALSE, adr, ROOT, 1);	/* Demander l'ancienne option courante */
	adr[old_option].ob_state &= ~CHECKED;		/* D‚-checker l'ancienne option */
	adr[buf[4]].ob_state |= CHECKED;		/* Checker la nouvelle option */
	menu_istart (TRUE, adr, ROOT, buf[4]);	/* Nouvelle option courante */
	strcpy (texte, adr[buf[4]].ob_spec.free_string);
	trim (texte);
	afficher_alerte (OP_MHIER, texte);
}

