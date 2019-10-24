/*	D‚velopper sous GEM
		4ø listing d'exemple
	 Gestion de menus pop-ups
	Claude ATTARD pour ST MAG
				Mars 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "devgem4.h"

/* #[ Prototypage : 														*/
void main (void);
void open_work (void);
void pop_up (OBJECT *adr, int obj, int pu);
int get_popup (OBJECT *adr, int button, int pu);
void set_popup (OBJECT *adr, int button, int option, int pu);
void afficher_alerte (int index);
char *trim (char *str);
void set_text (OBJECT *adr, int object, char *string);
char *get_text (OBJECT *adr, int object);
void	get_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
void	put_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
int verdict (OBJECT *adr);
/* #] Prototypage : 														*/ 
/* #[ D‚finitions et globales : 								*/
#define TRUE 1
#define FALSE 0

int ap_id;		/* Identificateur application */
int handle;		/* Handle station de travail */
int n_plane;	/* Nbre de plans de couleurs */
int xd, yd, wd, hd;		/* Coordonn‚es du bureau */
/* #] D‚finitions et globales : 								*/ 

/* #[ Main :																													*/
void main (void)
{
int x, y, w, h; 		/* Pour centrer le formulaire en fenˆtre */
int xo, yo;					/* Coordonn‚es de l'objet */
int quit = FALSE; 	/* Flag pour quitter */
int objet;					/* Objet cliqu‚ */
OBJECT *adr;				/* Adresse formulaire */

	ap_id = appl_init (); /* D‚clarer l'application au GEM */
	open_work (); 				/* Ouvrir station de travail */
	wind_get (0, WF_WORKXYWH, &xd, &yd, &wd, &hd);	/* Coordonn‚es du bureau */
	rsrc_load ("DEVGEM4.RSC");				/* Charger le ressource */
	graf_mouse (ARROW, 0);						/* Souris : forme de flŠche */

	rsrc_gaddr (0, DIALOG, &adr); 			/* Adresse formulaire */
	form_center (adr, &x, &y, &w, &h);	/* Centrer le formulaire */
	wind_update (BEG_MCTRL);						/* Bloquer menu */
	form_dial (FMD_START, 0, 0, 0, 0, x, y, w, h);	/* Pr‚parer l'affichage */
	objc_draw (adr, 0, MAX_DEPTH, x, y, w, h);			/* Affichage par le GEM */

	do		/* BOUCLE PRINCIPALE */
	{
		objet = form_do (adr, 0);	/* Gestion du formulaire par le GEM */
		if (objet == FIN)			/* Si on a cliqu‚ le bouton de sortie */
		{
			if (verdict (adr) == TRUE)	/* Tester les r‚ponses */
				quit = TRUE;				/* Si c'est bon, on quitte */
			objc_change (adr, objet, 0, x, y, w, h, 0, TRUE);  /* R‚inverser bouton */
		}
		else				/* Si on a cliqu‚ un autre bouton EXIT (un pop-up) */
		{
			pop_up (adr, objet, POPUP);		/* Gestion de ce pop-up */
			objc_change (adr, objet, 0, x, y, w, h, SHADOWED, FALSE);  /* R‚inverser bouton */
			objc_offset (adr, objet, &xo, &yo);				/* Prendre ses coordonn‚es */
			objc_draw (adr, objet, MAX_DEPTH, xo, yo,	/* Le redessiner */
								 adr[objet].ob_width, adr[objet].ob_height);
		}
	} while (quit == FALSE);	/* Fin de la boucle : tant qu'on ne quitte pas */

	form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h); /* Effacer formulaire */
	wind_update (END_MCTRL);	 /* D‚bloquer menu */
	rsrc_free (); 						 /* Lib‚rer le ressource */
	v_clsvwk (handle);				 /* Fermer la station de travail */
	appl_exit (); 						 /* Quitter */
}
/* #] Main :																													*/ 
/* #[ Open_work : 																										*/
void open_work (void)
{		/* Ouvrir la station de travail */
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
	vq_extnd (handle, TRUE, work_out);
	n_plane = work_out[4];	/* Nbre de plans de couleurs */
}
/* #] Open_work : 																										*/ 
/* #[ pop_up :																												*/
void pop_up (OBJECT *adr, int obj, int pu)
{	/* Gestion d'un formulaire pop-up */
OBJECT *adr_pu;
int x, y, w, h, dummy, old_ob = -1, ob = 0, b[8], xm, ym, km,
		evnt, sortie = FALSE, etat, old = 0;
MFDB image;

	rsrc_gaddr (R_TREE, pu, &adr_pu);	/* Adresse formulaire pop-up */

	objc_offset (adr, obj, &x, &y);		/* Position bouton cliqu‚ */
	y += (adr[obj].ob_height);				/* Se placer juste dessous par d‚faut */
	adr_pu->ob_x = x;									/* Positionner le */
	adr_pu->ob_y = y;									/* formulaire pop_up. */
	w = adr_pu->ob_width;							/* Prendre ses */
	h = adr_pu->ob_height;						/* dimensions. */

	old = get_popup (adr, obj, POPUP);	/* Chercher correspondance */
	if (old)	/* Si le texte du bouton correspond d‚j… … une option du pop-up */
	{			/* On fait co‹ncider les positions de l'option et du bouton */
		x = adr_pu->ob_x = x - adr_pu[old].ob_x;
		y = adr_pu->ob_y = y - adr_pu[old].ob_y - adr[obj].ob_height;
		adr_pu[old].ob_state |= CHECKED;	/* On "Checke" l'option */
	}

	if (x + w > xd + wd - 5)		/* Si on sort du bureau, d‚caler le pop-up */
		x = adr_pu->ob_x = wd + xd - w - 5;	/* avec une marge de 5 pixels */
	if (x < xd + 5)
		x = adr_pu->ob_x = xd + 5;
	if (y + h > yd + hd - 5)
		y = adr_pu->ob_y = hd + yd - h - 5;
	if (y < yd + 5)
		y = adr_pu->ob_y = yd + 5;

	get_bkgr (x, y, w, h, &image);	/* Copier l'image de fond */
	objc_draw (adr_pu, ROOT, MAX_DEPTH, x - 3, y - 3, w + 6, h + 6);	/* Dessiner le pop-up */

	do		/* BOUCLE PRINCIPALE DE GESTION DU POP-UP */
	{
		evnt = evnt_multi (MU_BUTTON | MU_TIMER,	/* Seuls les clic et le timer nous int‚ressent */
											 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
											 b, 10, 0, &xm, &ym, &km, &dummy, &dummy, &dummy);
		if (evnt & MU_BUTTON)					/* Si ‚v‚nement de clic souris */
		{
			while (km)	/* On attend que le bouton de la souris soit relƒch‚ */
				graf_mkstate (&dummy, &dummy, &km, &dummy);
			sortie = TRUE;	/* On peut sortir, puisqu'on a cliqu‚ */
		}
		else if (evnt == MU_TIMER)	/* Si ‚v‚nement Timer */
		{
			graf_mkstate (&xm, &ym, &dummy, &dummy);	/* Demander coordonn‚es de la souris */
				/* Demander l'option de pop-up … cette position */
			ob = objc_find (adr_pu, ROOT, MAX_DEPTH, xm, ym);
			if (old_ob != ob)	/* Si option diff‚rente de la pr‚c‚dente */
			{
				if ((old_ob != -1) && (! (adr_pu[old_ob].ob_state & DISABLED)))
				{		/* On d‚s‚lectionne l'ancienne */
					etat = adr_pu[old_ob].ob_state & ~SELECTED;
					objc_change (adr_pu, old_ob, 0, x, y, w, h, etat, TRUE);
				}
				if ((ob > ROOT) && (! (adr_pu[ob].ob_state & DISABLED)))
				{	/* Si la nouvelle option existe (on n'est pas sorti du pop-up)
						 et si elle n'est pas DISABLED */
					etat = adr_pu[ob].ob_state | SELECTED;			/* On la s‚lectionne */
					objc_change (adr_pu, ob, 0, x, y, w, h, etat, TRUE);
				}
				old_ob = ob;	/* L'option courante devient l'ancienne option */
			}
		}
	} while (sortie == FALSE);	/* Fin de boucle : tant qu'on n'a pas cliqu‚ */
	put_bkgr (x, y, w, h, &image);	/* Restaurer l'image de fond */
	adr_pu[old].ob_state &= ~CHECKED;	/* D‚-checker l'option de d‚part */

	if ((ob > 0) && (! (adr_pu[ob].ob_state & DISABLED)))
	{	/* Si l'option existe (on n'est pas sorti du pop-up)
			 et si elle n'est pas DISABLED */
		etat = adr_pu[ob].ob_state &= ~SELECTED;	/* La d‚s‚lectionner */
		objc_change (adr_pu, ob, 0, x, y, w, h, etat, FALSE);
		set_popup (adr, obj, ob, POPUP);	/* Copier son texte dans le bouton */
	}
}
/* #] pop_up :																												*/ 
/* #[ get_popup () Cherche correspondance bouton et pop-up :					*/
int get_popup (OBJECT *adr, int button, int pu)
{	/* Chercher correspondance entre le texte d'un bouton et un formulaire pop-up */
int i = 1;
char bouton[MAX_LEN], option[MAX_LEN];
OBJECT *adrpu;

	if (! (adr[button].ob_state & SHADOWED))	/* Si pas pop-up */
		return FALSE;															/* Retourner 0 */

	rsrc_gaddr (R_TREE, pu, &adrpu);	/* Adresse formulaire pop-up */

	strcpy (bouton, get_text (adr, button));	/* Lire le texte du bouton */
	trim (bouton);	/* Virer les espaces au d‚but et … la fin */
	do		/* D‚but de boucle : pour chaque objet du formulaire pop-up */
	{
		if (adrpu[i].ob_type == G_STRING)	/* Si c'est une G_STRING */
		{
			strcpy (option, get_text (adrpu, i));	/* Lire le texte de l'option */
			trim (option);			/* Virer les espaces au d‚but et … la fin */
			if (strcmp (bouton, option) == 0)				/* Si correspondance */
				return i;															/* retourner le nø de l'option */
		}
	} while (! (adrpu[i++].ob_flags & LASTOB));	/* Fin de boucle : dernier objet */
	return FALSE;										/* Si pas occurence, retourner 0 */
}
/* #] get_popup () Cherche correspondance bouton et pop-up :					*/ 
/* #[ set_popup () Fixe une option de bouton pop_up :									*/
void set_popup (OBJECT *adr, int button, int option, int pu)
{	/* Faire correspondre le texte d'un bouton pop-up avec celui d'une option */
char texte[MAX_LEN];
OBJECT *adrpu;

	if (! (adr[button].ob_state & SHADOWED))	/* Si pas pop-up */
		return;																		/* Ressortir */

	rsrc_gaddr (R_TREE, pu, &adrpu);		/* Adresse formulaire pop-up */

	if ((adr[button].ob_type) == G_BUTTON)	/* Si c'est bien un G_BUTTON */
	{
		strcpy (texte, get_text (adrpu, option));	/* Lire le texte de l'option */
		trim (texte);	/* Virer les espaces de d‚but et de fin */
		set_text (adr, button, texte);	/* Copier le texte dans le bouton */
	}
}
/* #] set_popup () Fixe une option de bouton pop_up :									*/ 
/* #[ Afficher alerte : 																							*/
void afficher_alerte (int index)
{
char *alrt;

	rsrc_gaddr (R_FRSTR, index, &alrt); /* Adr chaŒne pointeur sur pointeur */
	alrt = *((char **)alrt);						/* Pointeur sur le texte */
	form_alert (1, alrt); 							/* Afficher l'alerte */
}
/* #] Afficher alerte : 																							*/ 
/* #[ trim () Vire espaces d‚but et fin de chaŒne : 									*/
char *trim (char *str)
{
register char *s;
register int i = 0;
char chaine[MAX_LEN];

	while (*(str + i) == ' ')
		i++;	/* Virer les espaces au d‚but */
	strcpy (chaine, (str + i));

	s = chaine + strlen (chaine) - 1;
	for( ; (*s == ' ') && (s >= chaine) ; *s-- = 0);
	strcpy (str, chaine);	/* Virer les espaces … la fin */
	return str;	/* Retourner opinteur sur la chaŒne */
}
/* #] trim () Vire espaces d‚but et fin de chaŒne : 									*/ 
/* #[ set_text () Ecrire une G_STRING ou un G_TEXT :									*/
void set_text (OBJECT *adr, int object, char *string)
{
int type;

	type = adr[object].ob_type;	/* Lire le type de l'objet */

			/* Si ob_spec d‚signe le texte */
	if ((type == G_STRING) || (type == G_BUTTON))
		strcpy (adr[object].ob_spec.free_string, string);
			/* Si ob_spec d‚signe une structure TEDINFO */
	else if ((type == G_TEXT) || (type == G_BOXTEXT) ||
					 (type == G_FTEXT) || (type == G_FBOXTEXT))
		strcpy (adr[object].ob_spec.tedinfo->te_ptext, string);
}
/* #] set_text () Ecrire une G_STRING ou un G_TEXT :									*/ 
/* #[ get_text () Lire une G_STRING ou un G_TEXT:											*/
char *get_text (OBJECT *adr, int object)
{
int type;
char *retour = "";

	type = adr[object].ob_type;	/* Lire le type de l'objet */

			/* Si ob_spec d‚signe le texte */
	if ((type == G_STRING) || (type == G_BUTTON))
		retour = (adr[object].ob_spec.free_string);
			/* Si ob_spec d‚signe une structure TEDINFO */
	else if ((type == G_TEXT) || (type == G_BOXTEXT) ||
					 (type == G_FTEXT) || (type == G_FBOXTEXT))
		retour = (adr[object].ob_spec.tedinfo->te_ptext);

	return retour;	/* Retourner pointeur sur la chaŒne */
}
/* #] get_text () Lire une G_STRING ou un G_TEXT:											*/ 
/* #[ get_bkgr () Sauve le fond d'un formulaire :											*/
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
	v_show_c (handle, TRUE);	/* Remettre la souris */
}
/* #] get_bkgr () Sauve le fond d'un formulaire :											*/ 
/* #[ put_bkgr () Restaure le fond d'un formulaire :									*/
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
	v_show_c (handle, TRUE);	/* Virer la souris */
	free (img->fd_addr);		/* Lib‚rer la m‚moire */
}
/* #] put_bkgr () Restaure le fond d'un formulaire :									*/ 
/* #[ verdict :																												*/
int verdict (OBJECT *adr)
{	/* V‚rifier les r‚ponses */
int ok = TRUE, i,
		bouton[] = {CORBEAU, ARBRE, BEC, FROMAGE, RENARD, ODEUR, TINT, LANGAGE},
		reponses[] = {3, 1, 2, 4, 7, 6, 8, 5};

		/* bouton est le tableau des boutons pop-up dans l'ordre
			 reponses est le tableau des bonnes r‚ponses dans le mˆme ordre */
	for (i = 0 ; i < 8 ; i++)	/* Pour chaque bouton pop-up */
	{			/* Si la r‚ponse n'est pas bonne */
		if (get_popup (adr, bouton[i], POPUP) != reponses[i])
			ok = FALSE;		/* Flag … FALSE */
	}

	if (ok == TRUE)				/* Si bonnes r‚ponses */
		afficher_alerte (BRAVO);	/* BoŒte d'alerte "Bravo" */
	else if (ok == FALSE)	/* Si au moins une mauvaise r‚ponse */
		afficher_alerte (RATE);		/* BoŒte d'alerte "Rat‚" */
	return (ok);	/* Retourner le r‚sultat */
}
/* #] verdict :																												*/ 

