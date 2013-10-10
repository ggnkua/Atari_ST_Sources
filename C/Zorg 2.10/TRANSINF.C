/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <stdio.h>
#include <aes.h>
#include <tos.h>
#include <stdlib.h>

#include "zorg_inf.h"
#include "transinf.h"

#define ZORG_INF_VERSION	8
#define TMP_FILENAME	"ZORG.IN_"

/********************************************************************
*																	*
*					Lecture d'un boot (secteur 0)					*
*																	*
********************************************************************/
void main(void)
{
	int fd, fd_copy;
	int choix;
	t_raw_floppy raw_floppy[6];
	t_raw_hard raw_hard[6];
	raccourcis_var raccourcis;
	t_partition partition;

	atexit((void (*)())Cconin);

	puts("Conversion of ZORG.INF file\nLudovic Rousseau, Version 1.1, " __DATE__ "\n");

	if ((fd = (int)Fopen("ZORG.INF", FO_READ)) < 0)
	{
		puts("Can't open ZORG.INF");
		return;
	}

	Fread(fd, sizeof(int), &choix);
	if (choix != ZORG_VERSION)
	{
		puts("The configuration file is corrupted !");
		Fclose(fd);
		return;
	}

	Fread(fd, sizeof(int), &choix);
	if (choix > ZORG_VERSION)
	{
		puts("Wrong version number !");
		Fclose(fd);
		return;
	}

	if (choix == ZORG_INF_VERSION)
	{
		puts("This file does not need conversion");
		Fclose(fd);
		return;
	}

	if ((fd_copy = (int)Fcreate(TMP_FILENAME, 0)) < 0)
	{
		puts("Can't open " TMP_FILENAME);
		return;
	}

	/* version du fichier ZORG.INF */
	choix = ZORG_VERSION;
	Fwrite(fd_copy, sizeof(int), &choix);
	choix = ZORG_INF_VERSION;
 	Fwrite(fd_copy, sizeof(int), &choix);

	while (Fread(fd, sizeof(int), &choix) > 0)
		switch (choix)
		{
			case WIN_DEF:
				Fwrite(fd_copy, sizeof(int), &choix);

				/* taille des caractäres */
				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);

				/* taille de l'Çcran */
				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);

				{
					char *tmp;

					if ((tmp = calloc(choix, sizeof(t_win_coord))) == NULL)
						return;

					if (Fread(fd, choix * sizeof(t_win_coord), tmp) < 0)
						puts("Read error !");
					Fwrite(fd_copy, choix * sizeof(t_win_coord), tmp);

					free(tmp);
				}
				break;

			case CARACTERE_ZERO_DEF:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case FLOPPY_RAW:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(t_raw_floppy_entry)*6, raw_floppy) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(t_raw_floppy_entry)*6, raw_floppy);
				break;

			case HARD_RAW:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(t_raw_hard_entry)*6, raw_hard) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(t_raw_hard_entry)*6, raw_hard);
				break;

			case ZORG_INF:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case CLEAR_SCREEN:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case FLUSH_CACHE:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case MAKE_PAUSE:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case BLOC_SIZE:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case TOS_40x_BUG:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case SOUND_FLAG:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case SAVE_POS:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case SCROLL_TIMER:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case RESET_FLAG_INF:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case SHORTCUTS:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(raccourcis_var), &raccourcis) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(raccourcis_var), &raccourcis);
				break;

			case DEVICE:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				if (Fread(fd, sizeof(t_partition), &partition) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(t_partition), &partition);
				break;

			case DIALOG_WINDOW:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case 19: /* DEFINE_DESK */
				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				break;

			case MULTI_WARNING_FLAG:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case KEEP_STRUCTURE:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			case MANAGE_VFAT_OPT:
				Fwrite(fd_copy, sizeof(int), &choix);

				if (Fread(fd, sizeof(int), &choix) < 0)
					puts("Read error !");
				Fwrite(fd_copy, sizeof(int), &choix);
				break;

			default:
				puts("The configuration file is corrupted !");
				Fclose(fd);	/* on ferme pour ne plus le lire */
		}

	Fclose(fd);
	Fclose(fd_copy);

	Fdelete("zorg.inf");
	Frename(0, TMP_FILENAME, "zorg.inf");

	puts("Conversion ended");
} /* main */
