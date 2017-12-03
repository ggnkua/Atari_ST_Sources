/************************************************************************/
/*																		*/
/*		ACC_FORM.C	: Squelette pour la r‚alisation d'Accessoires		*/
/*					utilisant les routines WINDFORM.					*/
/*		Copyright (c) Mars-Avril 1995 par Delavoix Jacques.				*/
/*																		*/
/*	Modifs :															*/
/*																		*/
/* le 12/04/1995 : Mise en conformit‚ pour le fonctionnement en ACC		*/
/* le 31/07/1995 : Retouches sur la pr‚sentation et les commentaires.	*/
/*																		*/
/************************************************************************/

#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include "windform.h"
#include "acc_rsc.h"

/*	D‚finition des variables Globales.	*/

int	 vdi_handle;
int	 app_id, menu_id;		/* Identificateurs programme et menu. */
int mousex, mousey, key, key_s;	/* Variables de retour pour evnt_multi() */
int buff[8];
int color_3d1, color_3d2;	/* Couleurs pour la 3D */

WINDFORM_VAR dialog_var;	/* Fenˆtre de dialogue.	*/

/*	Prototypes de fonctions. */

void main(void);
int init_prog(void);			/* Initialisations du programme.	*/
void event_loop(void);			/* Boucle principale	*/
int utilisateur(int event);		/* Votre routine.....	*/

/* -------------------------------------------------------------------- */
/*	 main()	:															*/
/* -------------------------------------------------------------------- */

void main(void)
{
	int test;

	app_id = appl_init();	/* Handle d'application.	*/
	test = init_prog();
	if (test != 0 || _app == FALSE)	/* Si initialisations r‚ussies ou accessoire */
	{
		if (_app == FALSE && test != 0)
			menu_id = menu_register(app_id, "  My_acc");
		if (_app)	/* Si lancement en programme...	*/
		{
			graf_mouse(ARROW, 0);
			utilisateur(OPEN_DIAL);
		}
		event_loop();			/* Boucle principale commune aux deux modes. */

		v_clsvwk(vdi_handle);	/* Retour en cas de lancement en programme. */
		rsrc_free();
	}
	appl_exit();
}

/* -------------------------------------------------------------------- */
/*	 init_prog() : Initialisations du programme.						*/
/* -------------------------------------------------------------------- */

int init_prog(void)
{
	int i, work_in[11], work_out[57];

	if (rsrc_load("acc_rsc.rsc") == 0) /*	Nom de votre Ressource.	*/
	{
		form_alert(1,"[2][| Le Fichier Ressource |     acc_rsc.rsc"
				"| n'a pu ˆtre trouv‚.][ Quitter ]");
		return FALSE;
	}

	vdi_handle = graf_handle(&i, &i, &i, &i);
	for (i = 0 ; i < 10 ; work_in[i++] = 1);
		work_in[10] = 2;	/* SystŠme de coordonn‚es RC */
	v_opnvwk(work_in, &vdi_handle, work_out);	/* ouverture station virtuelle */

	if (work_out[13] < 16) /* Etablissement des couleurs 3D */
	{
		color_3d1 = WHITE;	/* color index 0	*/
		color_3d2 = BLACK;	/* color index 1	*/
	}
	else
	{
		color_3d1 = LWHITE;	/* color index 8	*/
		color_3d2 = LBLACK;	/* color index 9	*/
	}

	init_var(&dialog_var, INDEX, 0, 0);	/* INDEX de votre formulaire.	*/
	return TRUE;
}

/* -------------------------------------------------------------------- */
/*	 event_loop()														*/
/* -------------------------------------------------------------------- */

void event_loop(void)
{
	int event, quit = 0;
	int dummy;
	do
	{
		event = evnt_multi(MU_MESAG | MU_BUTTON | MU_KEYBD, 2, 1, 1,
								0, 0, 0, 0, 0, 0, 0, 0, 0, 0, buff, 10, 0,
								&mousex, &mousey, &dummy, &key_s, &key, &dummy);

		if (event & MU_MESAG)
		{
			switch (buff[0])
			{
				case AC_OPEN:
					/*	if (buff[4] == menu_id)	*/
					utilisateur(OPEN_DIAL);
					event = FALSE;
					break;
				case AC_CLOSE:
					/*	if (buff[3] == menu_id)	*/
					dialog_var.w_handle = 0;
					event = FALSE;
			}
		}

		if (event)
		{
			if (event & MU_KEYBD)
				wind_get(0, WF_TOP, &buff[3], &dummy, &dummy, &dummy);
			else if (event & MU_BUTTON)
				buff[3] = wind_find(mousex, mousey);

			if (buff[3] > 0)	/* Si W_Handle > 0 .... */
			{
				if (buff[3] == dialog_var.w_handle)
					quit = utilisateur(event);
				/* Mettre ici d'autres tests si d'autres fenˆtres de pr‚vues...	*/
			}
		}
	} while (quit == 0);
}

/* -------------------------------------------------------------------- */
/*	Routine "utilisateur()" :											*/
/* -------------------------------------------------------------------- */

int utilisateur(int event)
{
	WINDFORM_VAR *ptr_var = &dialog_var;
	int choix;

	if (event == OPEN_DIAL)
	{
		open_dialog(ptr_var, "Mon Accessoire", 0);
	}
	else
	{
		choix = windform_do(ptr_var, event); /* Gestion du dialogue. */
		if (choix != 0)
		{
			if (choix > 0)	/* Remettre le bouton de sortie en NORMAL...*/
							/* ... ici, il est redessin‚ (TRUE).		*/
				objc_change(ptr_var->adr_form, choix, 0, ptr_var->w_x,
						ptr_var->w_y, ptr_var->w_w, ptr_var->w_h, 0, TRUE);

			if (choix == CLOSE_DIAL)
			{
				close_dialog(ptr_var);
				if (_app)
					return TRUE; /* Si lancement en programme. */
			}
		}
	}
	return FALSE;
}
