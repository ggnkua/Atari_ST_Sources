/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>

#include "globals.h"
#include "zorg.h"

#include "desk.h"
#include "fenetre.h"
#include "menu.h"
#include "wind.h"
#include "init.h"

/****************************************************************
*																*
*						Gestion du bureau						*
*																*
****************************************************************/
void read_desktop(void)
{
	char *sh_ptr;
	char sh_gaddr[4096];
	int desk_pattern, desk_color, tmp;

	/*  R‚cupŠre le desktop/newdesk
	Si AES >= 140, le buffer est de 4096 octets, sinon
	de 1024 octets. cf compendium */

	if (_GemParBlk.global[0] >= 0x140)
		shel_get(sh_gaddr, 4096);
	else
		shel_get(sh_gaddr, 1024);

	/*  Cherche #Q, qui pr‚cŠde les donnees qui nous int‚ressent */
	sh_ptr = strstr(sh_gaddr, "#Q");

	/*  On a trouv‚ quelque chose ? */
	if (sh_ptr > 0)
	{
		/* Cas particuliers, pour les modes graphiques 1 et 2 plans */
		switch (planes)
		{
			case 1:
				sh_ptr += 3;    /*  On passe '#Q ' */
				break;

			case 2:
				sh_ptr += 9;    /*  On passe '#Q xx xx ' */
				break;

			default:
				/*  Plus de 2 plans */
				sh_ptr += 15;   /*  On passe '#Q xx xx yy yy ' */
				break;
		}

		/*  Prend les valeurs */
		tmp = *sh_ptr;
		desk_pattern = tmp <= '9' ? tmp - '0' : tmp - 'A' + 10;
		tmp = *(sh_ptr+1);
		desk_color = tmp <= '9' ? tmp - '0' : tmp - 'A'+ 10;
	}
	else
	{
		/*  On n'a pas trouv‚ la chaŒne dans le desktop/newdesk, on
		active les choix par d‚faut. */

		switch (colors)
		{
			case 2:
				desk_pattern = 4;
				desk_color = 1;
				break;

			case 4:
				desk_pattern = 7;
				desk_color = 3;
				break;

			case 16:
			case 256:
			default:
				desk_pattern = 7;
				desk_color = 13;
				break;
		}
	}

	/*  On applique ensuite ces valeurs au bureau */
	Bureau[0].ob_spec.obspec.fillpattern = desk_pattern;
	Bureau[0].ob_spec.obspec.interiorcol = desk_color;
} /* read_desktop */

/****************************************************************
*																*
*						Gestion du bureau						*
*																*
****************************************************************/
void do_desk(int mousex, int mousey, int double_clic, int key)
{
	int objet;
	GRECT r1, icones;

	if (Bureau == NULL)	/* y'a pas de bureau sous MultiTOS */
	{
		if (key)
		{
			char text[40];

			Drive = key - 'A';
			Chemin[0] = '\0';	/* annule le chemin courant */
	
			if (Drive <2)
				sprintf(text, Messages(INIT_2), 'A'+Drive);
			else
				sprintf(text, Messages(INIT_3), 'A'+Drive);
	
			ajoute(Firstwindow, text);
		}
		return;
	}

	objet = key ? 1 + key-'A' : objc_find(Bureau, ROOT, MAX_DEPTH, mousex, mousey);

	/* attend qu'on relache la souris */
	NoClick();

	if (Bureau[objet].ob_flags & SELECTABLE && (Drive != objet-1 || double_clic))
	{
		int x, y;
		int d;
		char text[40];

		if (Drive != objet-1)
		{
			wind_update(BEG_UPDATE);
			MouseOff();
	
			objc_offset(Bureau, 1+MAX_DEVICES-1, &x, &y);
			icones.g_x = 0;
			icones.g_y = y;
			icones.g_w = x + Bureau[1].ob_width;
			icones.g_h = Bureau[1].ob_height;
	
			for (d=0; d<MAX_DEVICES; d++)		/* des‚lectionne toutes les icones */
				Bureau[1 + d].ob_state &= ~SELECTED;

			Bureau[objet].ob_state |= SELECTED;
	
			wind_get(0, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
			while (r1.g_w && r1.g_h)
			{
				if (rc_intersect(&icones, &r1))
				{
					form_dial(FMD_START, 0, 0, 0, 0, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
					form_dial(FMD_FINISH, 0, 0, 0, 0, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
				}
		
				wind_get(0, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
			}

			MouseOn();
			wind_update(END_UPDATE);
	
			Drive = objet-1;
			Chemin[0] = '\0';	/* annule le chemin courant */
	
			if (Drive <2)
				sprintf(text, Messages(INIT_2), 'A'+Drive);
			else
				sprintf(text, Messages(INIT_3), 'A'+Drive);
	
			ajoute(Firstwindow, text);
		}

		if (double_clic)
			MenuSelect(UNITE_LOGIQUE, 0, 0, 0);
	}
} /* do_desk */

/****************************************************************
*																*
*					initialise le bureau						*
*																*
****************************************************************/
void init_desk(boolean mode)
{
	int screenx, screeny, screenw, screenh;
	OBJECT *desk;

	if (multi)
	{	/* on est sous un systŠme multitache (par ex. MultiTOS) */
		Bureau = NULL;
		return;
	}

	wind_get(0, WF_WORKXYWH, &screenx, &screeny, &screenw, &screenh);
	if (mode)
	{
		int drive;
		unsigned int active_drives;

		/* r‚cupŠre l'adresse de l'arbre */
		if (aes_version < 0x330)
			rsrc_gaddr(R_TREE, DESK, &desk);
		else
			rsrc_gaddr(R_TREE, COLOR_DESK, &desk);

		/* met une taille de 32x32 */
		/* la taille de l'icone est mal initialis‚e */
		desk[1].ob_height = 32;
		desk[2].ob_height = 32;

		if (aes_version < 0x330)
		{
			/* cr‚e la description des icones couleur */
			Ciconblk[0].monoblk = *desk[1].ob_spec.iconblk;	/* lecteur de disquette */
			Ciconblk[1].monoblk = *desk[1].ob_spec.iconblk;

			for (drive=2; drive<MAX_DEVICES; drive++)
				Ciconblk[drive].monoblk = *desk[2].ob_spec.iconblk;	/* partition de disque dur */
		}
		else
		{
			/* cr‚e la description des icones couleur */
			Ciconblk[0] = *desk[1].ob_spec.ciconblk;	/* lecteur de disquette */
			Ciconblk[1] = *desk[1].ob_spec.ciconblk;

			for (drive=2; drive<MAX_DEVICES; drive++)
				Ciconblk[drive] = *desk[2].ob_spec.ciconblk;	/* partition de disque dur */
		}

		/* cr‚‚ un arbre pour le bureau */
		Bureau = calloc(MAX_DEVICES+1, sizeof(OBJECT));

		Bureau[0] = desk[0];	/* le fond */
		Bureau[0].ob_next = FAIL;
		Bureau[0].ob_head = 1;
		Bureau[0].ob_tail = 1+MAX_DEVICES-1;

		Bureau[1] = desk[1];	/* Lecteur A */
		Bureau[1].ob_next = 2;
		Bureau[1].ob_head = Bureau[1].ob_tail = FAIL;
		Bureau[1].ob_spec.ciconblk = &Ciconblk[0];
		Bureau[1].ob_spec.iconblk -> ib_char |= 'A';

		Bureau[2] = desk[1];	/* Lecteur B */
		Bureau[2].ob_next = 3;
		Bureau[2].ob_head = Bureau[2].ob_tail = FAIL;
		Bureau[2].ob_x = 56;
		Bureau[2].ob_spec.ciconblk = &Ciconblk[1];
		Bureau[2].ob_spec.iconblk -> ib_char |= 'B';

		for (drive=3; drive<MAX_DEVICES; drive++)
		{
			Bureau[drive] = desk[2];	/* partition n */
			Bureau[drive].ob_next = drive+1;
			Bureau[drive].ob_head = Bureau[drive].ob_tail = FAIL;
			Bureau[drive].ob_x = 16-40+40*drive;
			Bureau[drive].ob_spec.ciconblk = &Ciconblk[drive-1];
			Bureau[drive].ob_spec.iconblk -> ib_char |= 'A'-1+drive;
			Bureau[drive].ob_flags &= ~LASTOB;
		}

		Bureau[1+MAX_DEVICES-1] = desk[2];	/* partition 15 */
		Bureau[1+MAX_DEVICES-1].ob_next = 0;
		Bureau[1+MAX_DEVICES-1].ob_head = Bureau[1+MAX_DEVICES-1].ob_tail = FAIL;
		Bureau[1+MAX_DEVICES-1].ob_x = 16+40*15;
		Bureau[1+MAX_DEVICES-1].ob_spec.ciconblk = &Ciconblk[15];
		Bureau[1+MAX_DEVICES-1].ob_spec.iconblk -> ib_char |= 'A'-1+drive;

		Bureau[0].ob_x = screenx;
		Bureau[0].ob_y = screeny;
		Bureau[0].ob_width = screenw;
		Bureau[0].ob_height = screenh;

		active_drives = (unsigned int)Drvmap();
		for (drive=0; drive<MAX_DEVICES; drive++)
			if ((active_drives & (1<<drive)) != 0)
			{
				Bureau[1+drive].ob_flags |= SELECTABLE;
				Bureau[1+drive].ob_flags &= ~HIDETREE;
			}
			else
			{
				Bureau[1+drive].ob_flags &= ~SELECTABLE;
				Bureau[1+drive].ob_flags |= HIDETREE;
			}

		read_desktop();
		wind_set(0, WF_NEWDESK, (int)((long)Bureau >> 16), (int)((long)Bureau & 0xFFFF), 0);
	}
	else
		wind_set(0, WF_NEWDESK, 0, 0, 0);
	form_dial(FMD_FINISH, 0 , 0, 0, 0, screenx, screeny, screenw, screenh);
} /* init_desk */

/****************************************************************
*																*
*					redessine le bureau							*
*																*
****************************************************************/
void redraw_desk(void)
{
	GRECT r;

	wind_update(BEG_UPDATE);
	MouseOff();

	wind_get(0, WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)
	{
		form_dial(FMD_START, 0, 0, 0, 0, r.g_x, r.g_y, r.g_w, r.g_h);
		form_dial(FMD_FINISH, 0, 0, 0, 0, r.g_x, r.g_y, r.g_w, r.g_h);

		wind_get(0, WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}

	MouseOn();
	wind_update(END_UPDATE);
} /* redraw_desk */
