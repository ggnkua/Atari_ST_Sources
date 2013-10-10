/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

#include "globals.h"
#include "zorg.h"

#include "brut.h"
#include "dialog.h"
#include "divers.h"
#include "fat.h"
#include "fenetre.h"
#include "init.h"
#include "ouvre.h"
#include "update.h"
#include "wind.h"
#include "tampon.h"

typedef struct
{
	int part;
	long nb_files;
	int drive;
	char *buffer;
	dir_elt_short *dir;
	char nom[FILENAME_MAX];
} directory_var_short;

typedef struct
{
	int part;
	long nb_files;
	int drive;
	char *buffer;
	dir_elt_vfat *dir;
	char nom[FILENAME_MAX];
} directory_var_vfat;

/****************************************************************
*																*
*			tronque un nom de fichier trop long					*
*																*
****************************************************************/
void get_max_name(char *nom, char *dest, int size, boolean menu)
{
	if (menu)
	{
		/* texte pour le menu */
		memset(dest, ' ', size);

		if (strlen(nom) > size-2)
		{
			char *pos;
	
			sprintf(dest, "  %c:\\.", nom[0]);
			pos = strchr(nom, '\\');
			while (strlen(pos) > size-6)
				pos = strchr(pos+1, '\\');
			strcat(dest, pos);
			pos = dest + strlen(dest);
		}
		else
			sprintf(dest, "  %s", nom);

		/* remplace le \0 par ' ' car il y a le raccourcis clavier aprŠs */
		dest[strlen(dest)] = ' ';
	}
	else
	{
		if (strlen(nom) > size-2)
		{
			char *pos;
	
			sprintf(dest, " %c:\\...", nom[0]);
			pos = strchr(nom, '\\');
			while (strlen(pos) > size-7)
				pos = strchr(pos+1, '\\');
			strcat(dest, pos);
			pos = dest + strlen(dest);
			*pos++ = ' ';
			*pos++ = '\0';
		}
		else
			sprintf(dest, " %s ", nom);
	}
} /* get_max_name */

/****************************************************************
*																*
*			voir un fichier avec ST-Guide et autres				*
*																*
****************************************************************/
void voir_fichier(void)
{
	char nom[FILENAME_MAX] = "";

	if (selecteur(nom, NULL, Messages(OUVRE_24)))
	{
		strcpy(nom, Chemin);
		strcat(nom, FselTable[0]);
		really_voir_fichier(nom);
	}
} /* voir_fichier */

/****************************************************************
*																*
*			voir un fichier avec ST-Guide et autres				*
*																*
****************************************************************/
void really_voir_fichier(char *filename)
{
	int id, msg[8];
	char text[FILENAME_MAX], name[FILENAME_MAX];

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	if ((id = AppLoaded("ST-GUIDE")) < 0)
		if ((id = AppLoaded("1STGUIDE")) < 0)
			if ((id = AppLoaded("1STVIEW ")) < 0)
			{
				error_msg(Z_VIEWER_NOT_LOADED);
				return;
			}

	strcpy(HelpString, filename);
	*(char **)&msg[3] = HelpString;
	msg[5] = msg[6] = msg[7] = 0;

	if (!AvSendMsg(id, VA_START, msg))
		error_msg(Z_ERROR_WITH_VIEWER);
	else
	{
		get_max_name(filename, name, MAX_TITLE, FALSE);
		sprintf(text, Messages(OUVRE_23), name);
	}
} /* really_voir_fichier */

/****************************************************************
*																*
*			ouvre un fichier avec Fopen et compagnie			*
*																*
****************************************************************/
void open_file_other_fs(void)
{
	char nom[FILENAME_MAX] = "";
	int no;

	no = selecteur(nom, NULL, Messages(OUVRE_1));
	for (no--; no>=0; no--)
	{
		strcpy(nom, Chemin);
		strcat(nom, FselTable[no]);
		really_open_file_other_fs(nom);
	}
} /* open_file_other_fs */

/****************************************************************
*																*
*			ouvre un fichier avec Fopen et compagnie			*
*																*
****************************************************************/
void really_open_file_other_fs(char *nom)
{
	windowptr thewin;
	char text[FILENAME_MAX];
	int fd, len;

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	get_max_name(nom, text, MAX_TITLE, FALSE);

	my_getbpb(toupper(nom[0])-'A');

	if ((fd = (int)Fopen(nom, 2)) > 0)
	{
		if ((thewin = new_window(SIZER | MOVER | FULLER | CLOSER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE, text, NULL, secteurproc, FICHIER_FS, 3)) != NULL)
		{
			if ((thewin -> fonction.fichier_fs.secteurBin = sector_alloc(512)) == NULL)
			{
				dispose_window(thewin);
				return;
			}

			/* entr‚e dans le menu */
			get_menu_entry(thewin, nom);

			thewin -> fonction.fichier_fs.sector_size = 1;
			thewin -> fonction.fichier_fs.page = 0;
			thewin -> fonction.secteur.device = 0;	/* pour avoir un tampon de disquette */

			thewin -> fonction.fichier_fs.ascii = TRUE;
			thewin -> fonction.fichier_fs.dirty = FALSE;
			thewin -> fonction.fichier_fs.curseur_x = FAIL;
			thewin -> fonction.fichier_fs.curseur_y = FAIL;
			thewin -> fonction.fichier_fs.decimal = TRUE;

			thewin -> fonction.fichier_fs.goto_liste = NULL;

			strcpy(thewin -> fonction.fichier_fs.nom, nom);
			strcpy(nom, text);	/* copie le nom transform‚ */
			thewin -> fonction.fichier_fs.size = Fseek(0L, fd, 2);
			thewin -> fonction.fichier_fs.secteur = 0L;
			thewin -> fonction.fichier_fs.max = (thewin -> fonction.fichier_fs.size + 511L) / 512L;
			thewin -> fonction.fichier_fs.file_desc = -fd;

			if ((thewin -> fonction.fichier_fs.slide = make_slide(&thewin -> win -> work, thewin -> fonction.fichier_fs.max)) == NULL)
			{
				dispose_window(thewin);
				return;
			}

			if (my_rwabs(0, thewin -> fonction.fichier_fs.secteurBin, 1, 0L, -fd))
			{
				GRECT box = thewin -> win -> curr;

				form_dial(FMD_START, 0, 0, 0, 0, box.g_x, box.g_y, box.g_w, box.g_h);	/* pour forcer un redessin */
				form_dial(FMD_FINISH, 0, 0, 0, 0, box.g_x, box.g_y, box.g_w, box.g_h);
			}

			len = sprintf(thewin -> fonction.fichier_fs.Ligne[0], Messages(CURSEUR_3), 0L, thewin -> fonction.fichier_fs.size);

			for (; len<SECTEURLINESIZE*2; len++)	/* on efface la fin de la ligne */
				thewin -> fonction.secteur.Ligne[0][len] = ' ';
			thewin -> fonction.secteur.Ligne[0][SECTEURLINESIZE*2-1] = '\0';

			strncpy(thewin -> fonction.fichier_fs.Ligne[1], "      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[2], "      0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[3], "                                                                    ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[4], "0000  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[5], "0020  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[6], "0040  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[7], "0060  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[8], "0080  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[9], "00A0  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[10], "00C0  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[11], "00E0  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[12], "0100  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[13], "0120  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[14], "0140  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[15], "0160  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[16], "0180  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[17], "01A0  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[18], "01C0  ", SECTEURLINESIZE);
			strncpy(thewin -> fonction.fichier_fs.Ligne[19], "01E0  ", SECTEURLINESIZE);
	
			convert_sect(thewin -> fonction.fichier_fs.secteurBin, thewin -> fonction.text.Ligne, TRUE);

			make_frontwin(thewin);

			sprintf(text, Messages(OUVRE_2), nom);
			ajoute(Firstwindow, text);
		}
	}
	else
	{
		error_msg(fd);
		strcpy(nom, text);
		sprintf(text, Messages(OUVRE_3), nom);
		ajoute(Firstwindow, text);
	}
} /* open_file_other_fs */

/****************************************************************
*																*
*					ouvre un disque								*
*																*
****************************************************************/
void open_disk(void)
{
	char titre[MAX_TITLE+2];
	windowptr thewin;
	int len, err;
	BPB bpb;	/* Bios Parameter Bloc */

	if (Drive < 2)
		sprintf(titre, Messages(FENETRE_1), 'A'+Drive);
	else
		sprintf(titre, Messages(FENETRE_2), 'A'+Drive);

	bpb = my_getbpb(Drive);
	if (bpb.clsiz == 0)
		return;

	if ((thewin = new_window(SIZER | MOVER | FULLER | CLOSER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE, titre, NULL, secteurproc, SECTEUR, 3)) != NULL)
	{
		if ((thewin -> fonction.secteur.secteurBin = sector_alloc(bpb.recsiz)) == NULL)
		{
			dispose_window(thewin);
			return;
		}

		/* entr‚e dans le menu */
		get_menu_entry(thewin, titre+1);

		thewin -> fonction.secteur.sector_size = bpb.recsiz/512;
		thewin -> fonction.secteur.page = 0;

		thewin -> fonction.secteur.secteur = 0;
		thewin -> fonction.secteur.device = Drive;
		thewin -> fonction.secteur.ascii = TRUE;
		thewin -> fonction.secteur.dirty = FALSE;

		thewin -> fonction.secteur.curseur_x = FAIL;
		thewin -> fonction.secteur.curseur_y = FAIL;
		thewin -> fonction.secteur.decimal = TRUE;

		thewin -> fonction.secteur.fichier = FALSE;
		thewin -> fonction.secteur.goto_liste = NULL;

		thewin -> fonction.secteur.max = bpb.datrec + bpb.numcl * bpb.clsiz;

		if ((thewin -> fonction.secteur.slide = make_slide(&thewin -> win -> work, thewin -> fonction.secteur.max)) == NULL)
		{
			dispose_window(thewin);
			return;
		}

		len = sprintf(thewin -> fonction.secteur.Ligne[0], Messages(FENETRE_7),
		 0L, thewin -> fonction.secteur.max, (unsigned int)floor((float)-bpb.datrec / bpb.clsiz +2), bpb.numcl +1);

		for (; len<SECTEURLINESIZE*2; len++)	/* on efface la fin de la ligne */
			thewin -> fonction.secteur.Ligne[0][len] = ' ';
		thewin -> fonction.secteur.Ligne[0][SECTEURLINESIZE*2-1] = '\0';

		strncpy(thewin -> fonction.secteur.Ligne[1], "      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[2], "      0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[3], "                                                                    ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[4], "0000  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[5], "0020  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[6], "0040  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[7], "0060  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[8], "0080  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[9], "00A0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[10], "00C0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[11], "00E0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[12], "0100  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[13], "0120  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[14], "0140  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[15], "0160  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[16], "0180  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[17], "01A0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[18], "01C0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.secteur.Ligne[19], "01E0  ", SECTEURLINESIZE);

		err = my_rwabs(0, thewin -> fonction.secteur.secteurBin, 1, 0, Drive);

		convert_sect(thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, TRUE);

		make_frontwin(thewin);

		if (Drive < 2)
			sprintf(titre, Messages(OUVRE_4), 'A'+Drive);
		else
			sprintf(titre, Messages(OUVRE_5), 'A'+Drive);
		ajoute(Firstwindow, titre);

		if (err == -14)
			change_disque(Drive, TRUE);
	}
} /* open_disk */

/****************************************************************
*																*
*					ouvre un fichier							*
*																*
****************************************************************/
void open_file(void)
{
	windowptr thewin;
	char nom[FILENAME_MAX] = "", text[FILENAME_MAX];
	int len;
	long size, *table, max;
	BPB bpb;
	int no;

	no = selecteur(nom, NULL, Messages(OUVRE_1));
	for (no--; no>=0; no--)
	{
		strcpy(nom, Chemin);
		strcat(nom, FselTable[no]);

		get_max_name(nom, text, MAX_TITLE, FALSE);

		if ((max = create_file_table(nom, &table, &size)) != 0)
		{
			if ((thewin = new_window(SIZER | MOVER | FULLER | CLOSER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE, text, NULL, secteurproc, FICHIER, 3)) != NULL)
			{
				bpb = my_getbpb(toupper(nom[0])-'A');

				if ((bpb.recsiz == 0) || (thewin -> fonction.fichier.secteurBin = sector_alloc(bpb.recsiz)) == NULL)
				{
					dispose_window(thewin);
					return;
				}

				/* entr‚e dans le menu */
				get_menu_entry(thewin, nom);

				thewin -> fonction.fichier.sector_size = bpb.recsiz/512;
				thewin -> fonction.secteur.page = 0;

				thewin -> fonction.fichier.ascii = TRUE;
				thewin -> fonction.fichier.dirty = FALSE;
				thewin -> fonction.fichier.curseur_x = FAIL;
				thewin -> fonction.fichier.curseur_y = FAIL;
				thewin -> fonction.fichier.decimal = TRUE;

				thewin -> fonction.fichier.max = max;

				thewin -> fonction.fichier.secteur = 0;
				thewin -> fonction.fichier.device = toupper(nom[0])-'A';

				thewin -> fonction.fichier.goto_liste = NULL;

				strcpy(thewin -> fonction.fichier.nom, nom);
				strcpy(nom, text);	/* copie le nom transform‚ */
				thewin -> fonction.fichier.size = size;
				thewin -> fonction.fichier.table = table;

				if ((thewin -> fonction.secteur.slide = make_slide(&thewin -> win -> work, thewin -> fonction.secteur.max * thewin -> fonction.secteur.sector_size)) == NULL)
				{
					dispose_window(thewin);
					return;
				}

				if (my_rwabs(0, thewin -> fonction.fichier.secteurBin, 1, table[0], thewin -> fonction.fichier.device))
				{
					GRECT box = thewin -> win -> curr;

					form_dial(FMD_START, 0, 0, 0, 0, box.g_x, box.g_y, box.g_w, box.g_h);	/* pour forcer un redessin */
					form_dial(FMD_FINISH, 0, 0, 0, 0, box.g_x, box.g_y, box.g_w, box.g_h);
				}

				len = sprintf(thewin -> fonction.fichier.Ligne[0], Messages(CURSEUR_1), 0L, thewin -> fonction.fichier.size, (unsigned int)floor((double)(table[0] - bpb.datrec) / bpb.clsiz +2), 0L, thewin -> fonction.fichier.max);

				for (; len<SECTEURLINESIZE*2; len++)	/* on efface la fin de la ligne */
					thewin -> fonction.secteur.Ligne[0][len] = ' ';
				thewin -> fonction.secteur.Ligne[0][SECTEURLINESIZE*2-1] = '\0';

				strncpy(thewin -> fonction.fichier.Ligne[1], "      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[2], "      0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[3], "                                                                    ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[4], "0000  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[5], "0020  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[6], "0040  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[7], "0060  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[8], "0080  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[9], "00A0  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[10], "00C0  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[11], "00E0  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[12], "0100  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[13], "0120  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[14], "0140  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[15], "0160  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[16], "0180  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[17], "01A0  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[18], "01C0  ", SECTEURLINESIZE);
				strncpy(thewin -> fonction.fichier.Ligne[19], "01E0  ", SECTEURLINESIZE);
	
				convert_sect(thewin -> fonction.fichier.secteurBin, thewin -> fonction.text.Ligne, TRUE);

				make_frontwin(thewin);

				sprintf(text, Messages(OUVRE_2), nom);
				ajoute(Firstwindow, text);
			}
		}
		else
		{
			strcpy(nom, text);
			sprintf(text, Messages(OUVRE_3), nom);
			ajoute(Firstwindow, text);
		}
	}
} /* open_file */

/****************************************************************
*																*
*					ouvre un r‚pertoire							*
*																*
****************************************************************/
void open_directory_short(void)
{
	char text[FILENAME_MAX];
	directory_var_short *var = Dialog[DIRECTORY_INFO].var;
	int i;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(directory_var_short))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[DIRECTORY_INFO].var = var;
	}

	var -> nom[0] = '\0';
	Fichier[0] = '\0';

	if(!selecteur(var -> nom, NULL, Messages(OUVRE_6)))
		return;

	if (var -> nom[1] != ':')
	{
		sprintf(text, Messages(OUVRE_7), var -> nom);
		ajoute(Firstwindow, text);
		return;
	}

	if (var -> nom[strlen(var -> nom)-1] != '\\')
	{
		sprintf(text, Messages(OUVRE_8), var -> nom);
		ajoute(Firstwindow, text);
		ajoute(Firstwindow, Messages(OUVRE_9));
		return;
	}

	var -> drive = var -> nom[0] - 'A';

	if (load_arbo_file(var -> drive, var -> nom +3))
		return;

	if ((var -> buffer = sector_alloc(Bpb[var -> drive].recsiz)) == NULL)
		return;

	if (var -> nom[3] == '\0')	/* r‚pertoire racine */
	{
		var -> dir = (Arbo[toupper(var -> nom[0])-'A'] +1);
	}
	else
		if ((var -> dir = find_file_short(var -> nom)) == NULL)
		{
			sprintf(text, Messages(OUVRE_7), var -> nom);
			ajoute(Firstwindow, text);
			return;
		}

	var -> part = 0;

	var -> nb_files = var -> dir[-1].size;	/* nombre d'entr‚es dans le r‚pertoire */

	sprintf(text, Messages(OUVRE_10), var -> nom);
	ajoute(Firstwindow, text);

	if (var -> nom[3] == '\0')
		strcpy(Dialog[DIRECTORY_INFO].tree[DIR_NAME].ob_spec.free_string, "Root");
	else
	{
		char *ptr_src, *ptr_dst;

		ptr_src = strrchr(var -> nom, '\\');	/* dernier \ */
		while (*(--ptr_src) != '\\')	/* remonte … l'avant dernier */
			;
		ptr_dst = Dialog[DIRECTORY_INFO].tree[DIR_NAME].ob_spec.free_string;
		while (*(++ptr_src) != '\\')	/* copie le dernie ‚lement du chemin */
			*(ptr_dst++) = *ptr_src;
		*ptr_dst = '\0';				/* un \0 final */
	}

	Dialog[DIRECTORY_INFO].tree[DIR_PREVIOUS].ob_state |= DISABLED;
	if (var -> nb_files == 16)
		Dialog[DIRECTORY_INFO].tree[DIR_NEXT].ob_state |= DISABLED;
	else
		Dialog[DIRECTORY_INFO].tree[DIR_NEXT].ob_state &= ~DISABLED;

	/* entr‚es 0 … 7 */
	for (i=0; i<8; i++)
	{
		char *t = Dialog[DIRECTORY_INFO].tree[DIR1+i].ob_spec.tedinfo -> te_ptext;
		char *c = var -> dir[i + var -> part].name;
		int j, att = var -> dir[i+ var -> part].attribut;

		for (j=0; j<8+3; j++)
			if (*c)
				*t++ = *c++;
			else
			{
				*t++ = ZeroChar;
				c++;
			}
			
		*t++ = att & FA_READONLY ? 'R' : ' ';
		*t++ = att & FA_HIDDEN ? 'H' : ' ';
		*t++ = att & FA_SYSTEM ? 'S' : ' ';
		*t++ = att & FA_VOLUME ? 'V' : ' ';
		*t++ = att & FA_SUBDIR ? 'D' : ' ';
		*t = att & FA_ARCHIVE ? 'A' : ' ';
	}

	/* entr‚es 8 … 15 */
	for (i=8; i<16; i++)
	{
		char *t = Dialog[DIRECTORY_INFO].tree[DIR9-8+i].ob_spec.tedinfo -> te_ptext;
		char *c = var -> dir[i + var -> part].name;
		int j, att = var -> dir[i + var -> part].attribut;

		for (j=0; j<8+3; j++)
			if (*c)
				*t++ = *c++;
			else
			{
				*t++ = ZeroChar;
				c++;
			}
			
		*t++ = att & FA_READONLY ? 'R' : ' ';
		*t++ = att & FA_HIDDEN ? 'H' : ' ';
		*t++ = att & FA_SYSTEM ? 'S' : ' ';
		*t++ = att & FA_VOLUME ? 'V' : ' ';
		*t++ = att & FA_SUBDIR ? 'D' : ' ';
		*t++ = att & FA_ARCHIVE ? 'A' : ' ';
	}

	Dialog[DIRECTORY_INFO].proc = open_directory_proc_short;
	my_open_dialog(&Dialog[DIRECTORY_INFO], AUTO_DIAL, FAIL);
} /* open_directory_short */

/****************************************************************
*																*
*					ouvre un r‚pertoire (VFAT)					*
*																*
****************************************************************/
void open_directory_vfat(void)
{
	char text[FILENAME_MAX];
	directory_var_vfat *var = Dialog[DIRECTORY_INFO].var;
	int i;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(directory_var_vfat))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[DIRECTORY_INFO].var = var;
	}

	var -> nom[0] = '\0';
	Fichier[0] = '\0';

	if(!selecteur(var -> nom, NULL, Messages(OUVRE_6)))
		return;

	if (var -> nom[1] != ':')
	{
		sprintf(text, Messages(OUVRE_7), var -> nom);
		ajoute(Firstwindow, text);
		return;
	}

	if (var -> nom[strlen(var -> nom)-1] != '\\')
	{
		sprintf(text, Messages(OUVRE_8), var -> nom);
		ajoute(Firstwindow, text);
		ajoute(Firstwindow, Messages(OUVRE_9));
		return;
	}

	var -> drive = var -> nom[0] - 'A';

	if (load_arbo_file(var -> drive, var -> nom +3))
		return;

	if ((var -> buffer = sector_alloc(Bpb[var -> drive].recsiz)) == NULL)
		return;

	if (var -> nom[3] == '\0')	/* r‚pertoire racine */
	{
		var -> dir = (dir_elt_vfat *)(Arbo[toupper(var -> nom[0])-'A']) +1;
	}
	else
		if ((var -> dir = find_file_vfat(var -> nom)) == NULL)
		{
			sprintf(text, Messages(OUVRE_7), var -> nom);
			ajoute(Firstwindow, text);
			return;
		}

	var -> part = 0;

	var -> nb_files = var -> dir[-1].size;	/* nombre d'entr‚es dans le r‚pertoire */

	sprintf(text, Messages(OUVRE_10), var -> nom);
	ajoute(Firstwindow, text);

	if (var -> nom[3] == '\0')
		strcpy(Dialog[DIRECTORY_INFO].tree[DIR_NAME].ob_spec.free_string, "Root");
	else
	{
		char *ptr_src, *ptr_dst;

		ptr_src = strrchr(var -> nom, '\\');	/* dernier \ */
		while (*(--ptr_src) != '\\')	/* remonte … l'avant dernier */
			;
		ptr_dst = Dialog[DIRECTORY_INFO].tree[DIR_NAME].ob_spec.free_string;
		while (*(++ptr_src) != '\\')	/* copie le dernie ‚lement du chemin */
			*(ptr_dst++) = *ptr_src;
		*ptr_dst = '\0';				/* un \0 final */
	}

	Dialog[DIRECTORY_INFO].tree[DIR_PREVIOUS].ob_state |= DISABLED;
	if (var -> nb_files == 16)
		Dialog[DIRECTORY_INFO].tree[DIR_NEXT].ob_state |= DISABLED;
	else
		Dialog[DIRECTORY_INFO].tree[DIR_NEXT].ob_state &= ~DISABLED;

	/* entr‚es 0 … 7 */
	for (i=0; i<8; i++)
	{
		char *t = Dialog[DIRECTORY_INFO].tree[DIR1+i].ob_spec.tedinfo -> te_ptext;
		char *c = var -> dir[i + var -> part].name;
		int j, att = var -> dir[i+ var -> part].attribut;

		for (j=0; j<8+3; j++)
			if (*c)
				*t++ = *c++;
			else
			{
				*t++ = ZeroChar;
				c++;
			}
			
		*t++ = att & FA_READONLY ? 'R' : ' ';
		*t++ = att & FA_HIDDEN ? 'H' : ' ';
		*t++ = att & FA_SYSTEM ? 'S' : ' ';
		*t++ = att & FA_VOLUME ? 'V' : ' ';
		*t++ = att & FA_SUBDIR ? 'D' : ' ';
		*t = att & FA_ARCHIVE ? 'A' : ' ';
	}

	/* entr‚es 8 … 15 */
	for (i=8; i<16; i++)
	{
		char *t = Dialog[DIRECTORY_INFO].tree[DIR9-8+i].ob_spec.tedinfo -> te_ptext;
		char *c = var -> dir[i + var -> part].name;
		int j, att = var -> dir[i + var -> part].attribut;

		for (j=0; j<8+3; j++)
			if (*c)
				*t++ = *c++;
			else
			{
				*t++ = ZeroChar;
				c++;
			}
			
		*t++ = att & FA_READONLY ? 'R' : ' ';
		*t++ = att & FA_HIDDEN ? 'H' : ' ';
		*t++ = att & FA_SYSTEM ? 'S' : ' ';
		*t++ = att & FA_VOLUME ? 'V' : ' ';
		*t++ = att & FA_SUBDIR ? 'D' : ' ';
		*t++ = att & FA_ARCHIVE ? 'A' : ' ';
	}

	Dialog[DIRECTORY_INFO].proc = open_directory_proc_vfat;
	my_open_dialog(&Dialog[DIRECTORY_INFO], AUTO_DIAL, FAIL);
} /* open_directory_vfat */

/****************************************************************
*																*
*				ouvre un r‚pertoire (gestion)					*
*																*
****************************************************************/
boolean open_directory_proc_short(t_dialog *dialog, int exit)
{
	directory_var_short *var = dialog -> var;
	char text[FILENAME_MAX];
	int i, entry;

	switch (exit)
	{
		case DIR_OK:
			sector_free(var -> buffer);

			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> info -> di_tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			my_close_dialog(dialog);

			sprintf(text, Messages(OUVRE_11), var -> nom);
			ajoute(Firstwindow, text);
			return TRUE;

		case DIR_NEXT:
			var -> part += 16;
			dialog -> tree[DIR_PREVIOUS].ob_state &= ~DISABLED;
			ob_draw_chg(dialog -> info, DIR_PREVIOUS, NULL, FAIL);
			if (var -> part == var -> nb_files-16)
			{
				dialog -> tree[DIR_NEXT].ob_state |= DISABLED;
				ob_draw_chg(dialog -> info, DIR_NEXT, NULL, FAIL);
			}

			for (i=0; i<8; i++)
			{
				char *t = dialog -> tree[DIR1+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR1+i);
			}

			/* entr‚es 8 … 15 */
			for (i=8; i<16; i++)
			{
				char *t = dialog -> tree[DIR9-8+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR9-8+i);
			}
			break;

		case DIR_PREVIOUS:
			var -> part -= 16;
			dialog -> tree[DIR_NEXT].ob_state &= ~DISABLED;
			ob_draw_chg(dialog -> info, DIR_NEXT, NULL, FAIL);
			if (var -> part == 0)
			{
				dialog -> tree[DIR_PREVIOUS].ob_state |= DISABLED;
				ob_draw_chg(dialog -> info, DIR_PREVIOUS, NULL, FAIL);
			}

			for (i=0; i<8; i++)
			{
				char *t = dialog -> tree[DIR1+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR1+i);
			}

			/* entr‚es 8 … 15 */
			for (i=8; i<16; i++)
			{
				char *t = dialog -> tree[DIR9-8+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR9-8+i);
			}
			break;

		case DIR1:
		case DIR1+1:
		case DIR1+2:
		case DIR1+3:
		case DIR1+4:
		case DIR1+5:
		case DIR1+6:
		case DIR8:
			/* on a cliqu‚ sur une entr‚e */
			entry = exit - DIR1;
			goto suite;

		case DIR9:
		case DIR9+1:
		case DIR9+2:
		case DIR9+3:
		case DIR9+4:
		case DIR9+5:
		case DIR9+6:
		case DIR9+7:
			entry = exit - DIR9 + 8;

suite:
			if (directory_entry((dir_elt_vfat *)&var -> dir[var -> part + entry]))
			{
				char *t, *c;
				int j, att;
#ifndef TEST_VERSION
				unsigned int cluster = var -> dir[-1].first_cluster;

				if (var -> dir[-1].attribut)	/* c'est la racine */
				{
					if (!my_rwabs(0, var -> buffer, 1, cluster + var -> part/(Bpb[var -> drive].recsiz/32), var -> drive))
					{
						re_trans_dir_elt_short((real_dir_elt *)(var -> buffer + (entry + var -> part - (var -> part/(Bpb[var -> drive].recsiz/32))*(Bpb[var -> drive].recsiz/32))*sizeof(real_dir_elt)), &var -> dir[var -> part + entry]);
						my_rwabs(1, var -> buffer, 1, cluster + var -> part/(Bpb[var -> drive].recsiz/32), var -> drive);
					}
				}
				else
				{
					long *table;

					create_table(cluster, &table, var -> drive);

					if (!my_rwabs(0, var -> buffer, 1, table[var -> part/(Bpb[var -> drive].recsiz/32)], var -> drive))
					{
						re_trans_dir_elt_short((real_dir_elt *)(var -> buffer + (entry + var -> part - (var -> part/(Bpb[var -> drive].recsiz/32))*(Bpb[var -> drive].recsiz/32))*sizeof(real_dir_elt)), &var -> dir[var -> part + entry]);
						my_rwabs(1, var -> buffer, 1, table[var -> part/(Bpb[var -> drive].recsiz/32)], var -> drive);
					}

					free(table);
				}

#endif
				t = dialog -> tree[entry < 8 ? entry +DIR1 : entry -8 +DIR9].ob_spec.tedinfo -> te_ptext;
				c = var -> dir[entry + var -> part].name;
				att = var -> dir[entry + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, entry < 8 ? entry +DIR1 : entry -8 +DIR9);
			}
			break;
	}

	/* Exit-Objekt selektiert? */
	if (ob_isstate(dialog -> tree, exit, SELECTED))
	{
		/* angew„hltes Objekt deselektieren und neu zeichnen */
		ob_undostate(dialog -> tree, exit, SELECTED);
		ob_draw_chg(dialog -> info, exit, NULL, FAIL);
	}

	return FALSE;
} /* open_directory_proc_short */

/****************************************************************
*																*
*				ouvre un r‚pertoire (gestion) (VFAT)			*
*																*
****************************************************************/
boolean open_directory_proc_vfat(t_dialog *dialog, int exit)
{
	directory_var_vfat *var = dialog -> var;
	char text[FILENAME_MAX];
	int i, entry;

	switch (exit)
	{
		case DIR_OK:
			sector_free(var -> buffer);

			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> info -> di_tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			my_close_dialog(dialog);

			sprintf(text, Messages(OUVRE_11), var -> nom);
			ajoute(Firstwindow, text);
			return TRUE;

		case DIR_NEXT:
			var -> part += 16;
			dialog -> tree[DIR_PREVIOUS].ob_state &= ~DISABLED;
			ob_draw_chg(dialog -> info, DIR_PREVIOUS, NULL, FAIL);
			if (var -> part == var -> nb_files-16)
			{
				dialog -> tree[DIR_NEXT].ob_state |= DISABLED;
				ob_draw_chg(dialog -> info, DIR_NEXT, NULL, FAIL);
			}

			for (i=0; i<8; i++)
			{
				char *t = dialog -> tree[DIR1+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR1+i);
			}

			/* entr‚es 8 … 15 */
			for (i=8; i<16; i++)
			{
				char *t = dialog -> tree[DIR9-8+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR9-8+i);
			}
			break;

		case DIR_PREVIOUS:
			var -> part -= 16;
			dialog -> tree[DIR_NEXT].ob_state &= ~DISABLED;
			ob_draw_chg(dialog -> info, DIR_NEXT, NULL, FAIL);
			if (var -> part == 0)
			{
				dialog -> tree[DIR_PREVIOUS].ob_state |= DISABLED;
				ob_draw_chg(dialog -> info, DIR_PREVIOUS, NULL, FAIL);
			}

			for (i=0; i<8; i++)
			{
				char *t = dialog -> tree[DIR1+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR1+i);
			}

			/* entr‚es 8 … 15 */
			for (i=8; i<16; i++)
			{
				char *t = dialog -> tree[DIR9-8+i].ob_spec.tedinfo -> te_ptext;
				char *c = var -> dir[i + var -> part].name;
				int j, att = var -> dir[i + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, DIR9-8+i);
			}
			break;

		case DIR1:
		case DIR1+1:
		case DIR1+2:
		case DIR1+3:
		case DIR1+4:
		case DIR1+5:
		case DIR1+6:
		case DIR8:
			/* on a cliqu‚ sur une entr‚e */
			entry = exit - DIR1;
			goto suite;

		case DIR9:
		case DIR9+1:
		case DIR9+2:
		case DIR9+3:
		case DIR9+4:
		case DIR9+5:
		case DIR9+6:
		case DIR9+7:
			entry = exit - DIR9 + 8;

suite:
			if (directory_entry(&var -> dir[var -> part + entry]))
			{
				char *t, *c;
				int j, att;
#ifndef TEST_VERSION
				unsigned int cluster = var -> dir[-1].first_cluster;

				if (var -> dir[-1].attribut)	/* c'est la racine */
				{
					if (!my_rwabs(0, var -> buffer, 1, cluster + var -> part/(Bpb[var -> drive].recsiz/32), var -> drive))
					{
						re_trans_dir_elt_vfat((real_dir_elt *)(var -> buffer + (entry + var -> part - (var -> part/(Bpb[var -> drive].recsiz/32))*(Bpb[var -> drive].recsiz/32))*sizeof(real_dir_elt)), &var -> dir[var -> part + entry]);
						my_rwabs(1, var -> buffer, 1, cluster + var -> part/(Bpb[var -> drive].recsiz/32), var -> drive);
					}
				}
				else
				{
					long *table;

					create_table(cluster, &table, var -> drive);

					if (!my_rwabs(0, var -> buffer, 1, table[var -> part/(Bpb[var -> drive].recsiz/32)], var -> drive))
					{
						re_trans_dir_elt_vfat((real_dir_elt *)(var -> buffer + (entry + var -> part - (var -> part/(Bpb[var -> drive].recsiz/32))*(Bpb[var -> drive].recsiz/32))*sizeof(real_dir_elt)), &var -> dir[var -> part + entry]);
						my_rwabs(1, var -> buffer, 1, table[var -> part/(Bpb[var -> drive].recsiz/32)], var -> drive);
					}

					free(table);
				}

#endif
				t = dialog -> tree[entry < 8 ? entry +DIR1 : entry -8 +DIR9].ob_spec.tedinfo -> te_ptext;
				c = var -> dir[entry + var -> part].name;
				att = var -> dir[entry + var -> part].attribut;

				for (j=0; j<8+3; j++)
					if (*c)
						*t++ = *c++;
					else
					{
						*t++ = ZeroChar;
						c++;
					}
			
				*t++ = att & FA_READONLY ? 'R' : ' ';
				*t++ = att & FA_HIDDEN ? 'H' : ' ';
				*t++ = att & FA_SYSTEM ? 'S' : ' ';
				*t++ = att & FA_VOLUME ? 'V' : ' ';
				*t++ = att & FA_SUBDIR ? 'D' : ' ';
				*t++ = att & FA_ARCHIVE ? 'A' : ' ';

				ob_draw(dialog -> info, entry < 8 ? entry +DIR1 : entry -8 +DIR9);
			}
			break;
	}

	/* Exit-Objekt selektiert? */
	if (ob_isstate(dialog -> tree, exit, SELECTED))
	{
		/* angew„hltes Objekt deselektieren und neu zeichnen */
		ob_undostate(dialog -> tree, exit, SELECTED);
		ob_draw_chg(dialog -> info, exit, NULL, FAIL);
	}

	return FALSE;
} /* open_directory_proc_vfat */

/****************************************************************
*																*
*				modifie une entr‚e de r‚pertoire				*
*																*
****************************************************************/
boolean directory_entry(dir_elt_vfat *file)
{
	DIAINFO *info;
	OBJECT *tree = Dialog[FILE_INFO].tree;
	int exit;
	UWORD time;
	int heure, minutes, secondes;
	int annee, mois, jour;
	long size;
	unsigned int cluster;
	int i, j;
	char *t = tree[FILE_NAME].ob_spec.tedinfo -> te_ptext, *c = file -> name;

	for (j=0; j<8+3; j++)
		if (*c)
			*t++ = *c++;
		else
		{
			*t++ = ZeroChar;
			c++;
		}

	i = file -> attribut;

	if (i & FA_READONLY)
		tree[READ_ONLY].ob_state |= SELECTED;
	else
		tree[READ_ONLY].ob_state &= ~SELECTED;

	if (i & FA_HIDDEN)
		tree[HIDDEN].ob_state |= SELECTED;
	else
		tree[HIDDEN].ob_state &= ~SELECTED;

	if (i & FA_SYSTEM)
		tree[SYSTEM].ob_state |= SELECTED;
	else
		tree[SYSTEM].ob_state &= ~SELECTED;

	if (i & FA_VOLUME)
		tree[VOLUME].ob_state |= SELECTED;
	else
		tree[VOLUME].ob_state &= ~SELECTED;

	if (i & FA_SUBDIR)
		tree[DIRECTORY].ob_state |= SELECTED;
	else
		tree[DIRECTORY].ob_state &= ~SELECTED;

	if (i & FA_ARCHIVE)
		tree[ARCHIVE].ob_state |= SELECTED;
	else
		tree[ARCHIVE].ob_state &= ~SELECTED;

	time = file -> time;
	heure = time >> (6+5);
	minutes = (time >> 5) & 63;
	secondes = (time & 31)*2;

	time = file -> date;
	annee = 80 + (time >> (4+5));
	mois = (time >> 5) & 15;
	jour = time & 31;
	if (annee > 99)
		annee -= 100;
	if (annee > 99)
		annee = 99;

	sprintf(tree[FILE_DATE].ob_spec.tedinfo -> te_ptext, "%02d%02d%02d", jour, mois, annee);
	sprintf(tree[FILE_TIME].ob_spec.tedinfo -> te_ptext, "%02d%02d%02d", heure, minutes, secondes);

	sprintf(tree[FILE_CLUSTER_DEC].ob_spec.tedinfo -> te_ptext, "%u", (unsigned int)file -> first_cluster);
	sprintf(tree[FILE_CLUSTER_HEX].ob_spec.tedinfo -> te_ptext, "%04X", (unsigned int)file -> first_cluster);

	sprintf(tree[FILE_SIZE_DEC].ob_spec.tedinfo -> te_ptext, "%lu", file -> size);
	sprintf(tree[FILE_SIZE_HEXA].ob_spec.tedinfo -> te_ptext, "%08lX", file -> size);

	tree[FILE_SAUVER].ob_state &= ~SELECTED;
	tree[FILE_ANNULER].ob_state &= ~SELECTED;

	info = open_dialog(Dialog[FILE_INFO].tree, NULL, NULL, NULL, TRUE, TRUE, AUTO_DIAL|MODAL|NO_ICONIFY, 0, NULL, NULL);

	do
	{
		exit = X_Form_Do(NULL);
		if (exit!=W_ABANDON && exit!=W_CLOSED)
		{
			exit &= 0x7FFF;
			ob_undostate(Dialog[ASCII].tree, exit, SELECTED);
		}
		else
			exit = FILE_ANNULER;

		switch (exit)
		{
			case FILE_DATE_TOUCH:
				time = (UWORD)(Gettime() >> 16);

				annee = 80 + (time >> (4+5));
				mois = (time >> 5) & 15;
				jour = time & 31;
				if (annee > 99)
					annee -= 100;

				sprintf(tree[FILE_DATE].ob_spec.tedinfo -> te_ptext, "%02d%02d%02d", jour, mois, annee);
				ob_draw(info, FILE_DATE);
				break;

			case FILE_TIME_TOUCH:
				time = (UWORD)(Gettime() & 0xFFFF);

				heure = time >> (6+5);
				minutes = (time >> 5) & 63;
				secondes = (time & 31)*2;

				sprintf(tree[FILE_TIME].ob_spec.tedinfo -> te_ptext, "%02d%02d%02d", heure, minutes, secondes);
				ob_draw(info, FILE_TIME);
				break;

			case FILE_ANNULER:
				close_dialog(info, TRUE);
				return FALSE;
		}
	} while (exit != FILE_SAUVER);

	close_dialog(info, TRUE);

	for (i=0; i<8+3 && tree[FILE_NAME].ob_spec.tedinfo -> te_ptext[i]; i++)
		file -> name[i] = tree[FILE_NAME].ob_spec.tedinfo -> te_ptext[i];
	for (; i<8+3; i++)
		file -> name[i] = ' ';

	i = 0;
	if (ob_isstate(tree, READ_ONLY, SELECTED))
		i |= FA_READONLY;
	if (ob_isstate(tree, HIDDEN, SELECTED))
		i |= FA_HIDDEN;
	if (ob_isstate(tree, SYSTEM, SELECTED))
		i |= FA_SYSTEM;
	if (ob_isstate(tree, VOLUME, SELECTED))
		i |= FA_VOLUME;
	if (ob_isstate(tree, DIRECTORY, SELECTED))
		i |= FA_SUBDIR;
	if (ob_isstate(tree, ARCHIVE, SELECTED))
		i |= FA_ARCHIVE;
	file -> attribut = i;

	sscanf(tree[FILE_TIME].ob_spec.tedinfo -> te_ptext, "%02d%02d%02d", &heure, &minutes, &secondes);
	file -> time = (heure << (6+5)) | (minutes << 5) | (secondes/2);

	sscanf(tree[FILE_DATE].ob_spec.tedinfo -> te_ptext, "%02d%02d%02d", &jour, &mois, &annee);
	file -> date = ((annee < 80 ? annee+20 : annee-80) << (4+5)) | (mois << 5) | jour;

	if (tree[FILE_CLUSTER_DEC].ob_spec.tedinfo -> te_ptext[0] != '\0')
	{
		sscanf(tree[FILE_CLUSTER_DEC].ob_spec.tedinfo -> te_ptext, "%u", &cluster);
		if (file -> first_cluster != cluster)
			file -> first_cluster = cluster;
		else
		{
			if (tree[FILE_CLUSTER_HEX].ob_spec.tedinfo -> te_ptext[0] != '\0')
			{
				sscanf(tree[FILE_CLUSTER_HEX].ob_spec.tedinfo -> te_ptext, "%04X", &cluster);
				if (file -> first_cluster != cluster)
					file -> first_cluster = cluster;
			}
			else
				file -> first_cluster = 0;
		}
	}
	else
		file -> first_cluster = 0;

	if (tree[FILE_SIZE_DEC].ob_spec.tedinfo -> te_ptext[0] != '\0')
	{
		sscanf(tree[FILE_SIZE_DEC].ob_spec.tedinfo -> te_ptext, "%ld", &size);
		if (file -> size != size)
			file -> size = size;
		else
		{
			if (tree[FILE_SIZE_HEXA].ob_spec.tedinfo -> te_ptext[0] != '\0')
			{
				sscanf(tree[FILE_SIZE_HEXA].ob_spec.tedinfo -> te_ptext, "%08lX", &size);
				if (file -> size != size)
					file -> size = size;
			}
			else
				file -> size = 0L;
		}
	}
	else
		file -> size = 0L;

	return TRUE;
} /* directory_entry */

/****************************************************************
*																*
*						fermer									*
*																*
****************************************************************/
void fermer(int handle)
{
	register windowptr thewin = findwindowptr(handle);
	t_dialog *dialog;
	char text[FILENAME_MAX];
	int i;

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	/* ferme toutes les dialog-window avant */
	while ((dialog = find_dialog(thewin)) != NULL)
	{
		my_close_dialog(dialog);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);
	}

	/* sauvegarde la position courante */
	for (i=0; i<WinEntrees; i++)
		if (Windows[i].fenetre == thewin)
		{
			Windows[i].box = thewin -> win -> curr;
			break;
		}

	switch (thewin -> type)
	{
		case SECTEUR:
			if (thewin -> fonction.secteur.device <2)
				sprintf(text, Messages(OUVRE_12), 'A'+thewin -> fonction.secteur.device);
			else
				sprintf(text, Messages(OUVRE_13), 'A'+thewin -> fonction.secteur.device);
			ajoute(Firstwindow, text);

			/* libŠre la fenˆtre */
			dispose_window(thewin);
			break;

		case FICHIER:
			sprintf(text, Messages(OUVRE_14), thewin -> title);
			ajoute(Firstwindow, text);

			/* libŠre la fenˆtre */
			dispose_window(thewin);
			break;

		case OCCUP:
			sprintf(text, Messages(OUVRE_15), 'A'+thewin -> fonction.occup.device);
			ajoute(Firstwindow, text);

			/* libŠre la fenˆtre */
			dispose_window(thewin);
			break;

		case RAW_FLOPPY:
			ajoute(Firstwindow, Messages(OUVRE_16));

			/* libŠre la fenˆtre */
			dispose_window(thewin);
			break;

		case RAW_HARD:
			if (thewin -> fonction.raw_hard.device < 8)
				sprintf(text, Messages(OUVRE_17), thewin -> fonction.raw_hard.device);
			else
				if (thewin -> fonction.raw_hard.device < 16)
					sprintf(text, Messages(OUVRE_18), thewin -> fonction.raw_hard.device -8);
				else
					if (thewin -> fonction.raw_hard.device < 24)
						sprintf(text, Messages(OUVRE_19), thewin -> fonction.raw_hard.device -16);
					else
						sprintf(text, Messages(OUVRE_20), thewin -> fonction.raw_hard.device -24);
			ajoute(Firstwindow, text);

			/* libŠre la fenˆtre */
			dispose_window(thewin);
			break;

		case FICHIER_FS:
			sprintf(text, Messages(OUVRE_14), thewin -> title);
			ajoute(Firstwindow, text);

			/* libŠre la fenˆtre */
			dispose_window(thewin);
			break;

		case TAMPON:
			ajoute(Firstwindow, Messages(OUVRE_21));

			/* libŠre la fenˆtre */
			fermer_tampon();
			break;
	}
} /* fermer */
