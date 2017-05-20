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

#include "info.h"
#include "brut.h"
#include "dialog.h"
#include "divers.h"
#include "fat.h"
#include "fenetre.h"
#include "ouvre.h"
#include "update.h"
#include "wind.h"

/********************************************************************
*																	*
*		retrouve le nom entier … partir du num‚ro de cluster 		*
*																	*
********************************************************************/
void get_name_from_cluster_short(int drive, unsigned int cluster, char *name, int size)
{
	dir_elt_short *file, *pere, *peres[8];
	int i, len, nb_peres;

	sprintf(name, "%c:\\", drive + 'A');

	file = Cluster[drive][cluster];
	if (file)
	{
		pere = file;	/* on cherche le r‚pertoire pŠre */
		while ((pere -> name[0] != 'I' || strcmp(pere -> name, "Info.dir")) && pere != Arbo[drive])
			pere--;

		len = 3;
		nb_peres = 0;
		while (pere != Arbo[drive] && len < size-(2*(8+1+3)+3) && nb_peres<8-1) /* pas encore … la racine */
		{
			pere = (pere +2) -> dir;	/* passe de Info.dir … .. */

			peres[nb_peres++] = pere;

			/* ajoute la taille du r‚pertoire */
			for (i=0; i<8+3 && pere -> name[i] != ' '; i++)
				len++;

			while ((pere -> name[0] != 'I' || strcmp(pere -> name, "Info.dir")) && pere != Arbo[drive])
				pere--;
		}

		if (pere != Arbo[drive])	/* pas assez de place pour tout le monde */
		{
			strcat(name, "...\\");
			len = 7;
		}
		else
			len = 3;

		for (--nb_peres; nb_peres>=0; nb_peres--)
		{
			pere = peres[nb_peres];

			for (i=0; i<8 && pere -> name[i] != ' '; i++)
				name[len++] = pere -> name[i];
			if (pere -> name[8] != ' ')
			{
				name[len++] = '.';
				for (i=8; i<8+3 && pere -> name[i] != ' '; i++)
					name[len++] = pere -> name[i];
			}

			name[len++] = '\\';
		}

		for (i=0; i<8 && file -> name[i] != ' '; i++)
			name[len++] = file -> name[i];
		if (file -> name[8] != ' ')
		{
			name[len++] = '.';
			for (i=8; i<8+3 && file -> name[i] != ' '; i++)
				name[len++] = file -> name[i];
		}
		name[len] = '\0';
	}
	else
		if (FAT[drive][cluster] >= 0xFFF0 && FAT[drive][cluster] <= 0xFFF7)
			strcat(name, Messages(INFO_1));
		else
			strcat(name, Messages(INFO_2));
} /* get_name_from_cluster_short */

/********************************************************************
*																	*
*	retrouve le nom entier … partir du num‚ro de cluster (VFAT)		*
*																	*
********************************************************************/
void get_name_from_cluster_vfat(int drive, unsigned int cluster, char *name, int size)
{
	dir_elt_vfat *file, *pere, *peres[8];
	int i, len, nb_peres;

	sprintf(name, "%c:\\", drive + 'A');

	file = (dir_elt_vfat *)Cluster[drive][cluster];
	if (file)
	{
		pere = file;	/* on cherche le r‚pertoire pŠre */
		while ((pere -> name[0] != 'I' || strcmp(pere -> name, "Info.dir")) && pere != (dir_elt_vfat *)Arbo[drive])
			pere--;

		len = 3;
		nb_peres = 0;
		while (pere != (dir_elt_vfat *)Arbo[drive] && len < size-(2*(8+1+3)+3) && nb_peres<8-1) /* pas encore … la racine */
		{
			pere = (pere +2) -> dir;	/* passe de Info.dir … .. */

			peres[nb_peres++] = pere;

			/* ajoute la taille du r‚pertoire */
			for (i=0; i<8+3 && pere -> name[i] != ' '; i++)
				len++;

			while ((pere -> name[0] != 'I' || strcmp(pere -> name, "Info.dir")) && pere != (dir_elt_vfat *)Arbo[drive])
				pere--;
		}

		if (pere != (dir_elt_vfat *)Arbo[drive])	/* pas assez de place pour tout le monde */
		{
			strcat(name, "...\\");
			len = 7;
		}
		else
			len = 3;

		for (--nb_peres; nb_peres>=0; nb_peres--)
		{
			pere = peres[nb_peres];

			for (i=0; i<8 && pere -> name[i] != ' '; i++)
				name[len++] = pere -> name[i];
			if (pere -> name[8] != ' ')
			{
				name[len++] = '.';
				for (i=8; i<8+3 && pere -> name[i] != ' '; i++)
					name[len++] = pere -> name[i];
			}

			name[len++] = '\\';
		}

		for (i=0; i<8 && file -> name[i] != ' '; i++)
			name[len++] = file -> name[i];
		if (file -> name[8] != ' ')
		{
			name[len++] = '.';
			for (i=8; i<8+3 && file -> name[i] != ' '; i++)
				name[len++] = file -> name[i];
		}
		name[len] = '\0';
	}
	else
		if (FAT[drive][cluster] >= 0xFFF0 && FAT[drive][cluster] <= 0xFFF7)
			strcat(name, Messages(INFO_1));
		else
			strcat(name, Messages(INFO_2));
} /* get_name_from_cluster_vfat */

/********************************************************************
*																	*
*				teste la structure de la partition					*
*																	*
********************************************************************/
void structure_test_short(int drive)
{
	char text[80], *fat1, *fat2;
	int err, d, error = 0, fatsiz;
#ifndef TEST_VERSION
	int dirty_fat = FALSE;
#endif
	BPB bpb;
	unsigned int *fat = NULL;
	dir_elt_short *arbo = NULL, **cluster = NULL;
	long *table, i;

	change_disque(drive, FALSE);

	bpb = my_getbpb(drive);

	sprintf(text, Messages(INFO_3), drive + 'A');
	ajoute(Firstwindow, text);

	if (bpb.recsiz == 0)
		return;

	/* par d‚faut c'est pas bon */
	StructureTest[drive] = FALSE;

	/*
		FAT de mauvaise taille
	*/
	if (drive < 2)
		fatsiz = (int)(((bpb.numcl +2L) *3 /2 + bpb.recsiz-1) /bpb.recsiz);
	else
		fatsiz = (int)(((bpb.numcl +2L) *2 + bpb.recsiz-1) /bpb.recsiz);

	if (bpb.fsiz < fatsiz)
	{
		sprintf(text, Messages(INFO_4), bpb.fsiz, fatsiz);
		ajoute(Firstwindow, text);
		return;
	}

	if (bpb.fsiz > fatsiz)
	{
		sprintf(text, Messages(INFO_5), bpb.fsiz, fatsiz);
		ajoute(Firstwindow, text);
		error++;
		/* problŠme courant et pas g‚nant */
	}

	/*
		Mauvais d‚but de la deuxiŠme FAT
	*/
	if (bpb.fatrec != bpb.fsiz +1)
	{
		sprintf(text, Messages(INFO_6), bpb.fatrec, bpb.fsiz+1);
		ajoute(Firstwindow, text);
		return;
	}

	if ((fat1 = malloc((size_t)bpb.recsiz * bpb.fsiz)) == NULL || (fat2 = malloc((size_t)bpb.recsiz * bpb.fsiz)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return;
	}

	paraminfo(Messages(FAT_8), NULL);
	if (my_rwabs(0, fat1, bpb.fsiz, 1L, drive))
	{
		free (fat1);
		free (fat2);
		return;
	}

	if (my_rwabs(0, fat2, bpb.fsiz, (long)bpb.fatrec, drive))
	{
		free(fat1);
		free(fat2);
		return;
	}

	paraminfo(NULL, NULL);

	/*
		Les deux FATs ne sont pas identiques
	*/
	i = bpb.bflags & 1 ? 4 : 3;	/* on saute les 2 premiers clusters */

	/* compare les deux premies clusters */
	if (memcmp(fat1, fat2, (size_t)i))
	{
		sprintf(text, Messages(INFO_72));
		ajoute(Firstwindow, text);
	}

	/* les clusters suivants 2 -> ... */
	for (; i<bpb.fsiz * bpb.recsiz; i++)
		if (fat1[i] != fat2[i])	/* fat1 et fat2 sont des (char *) et pas (unsigned int *) */
		{
			sprintf(text, Messages(INFO_7), i, (int)(i / ((bpb.bflags & 1) ? 2.0 : 1.5)) -2);
			ajoute(Firstwindow, text);
			sprintf(text, Messages(INFO_67), (int)(i/bpb.recsiz)+1, (int)(bpb.fatrec + i/bpb.recsiz), i % bpb.recsiz );
			ajoute(Firstwindow, text);

			free(fat1);
			free(fat2);

			return;
		}
	free(fat2);

	if ((fat = malloc(drive < 2 ? (bpb.numcl +2L) * sizeof(unsigned int) : bpb.fsiz * (size_t)bpb.recsiz)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(fat1);
		return;
	}

	if (drive < 2)
		swap_flopy_FAT(fat, (unsigned int *)fat1, bpb.numcl +2);
	else
		swap_FAT(fat, (unsigned int *)fat1, (bpb.recsiz/512) * bpb.fsiz);
	free(fat1);

	paraminfo(Messages(INFO_8), Messages(FAT_2));
	if ((table = calloc((size_t)bpb.rdlen, sizeof(long))) == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(fat);
		return;
	}

	if ((cluster = calloc(bpb.numcl+2L, sizeof(char *))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(fat);
		free(table);
		return;
	}

	d = bpb.fatrec + bpb.fsiz;
	for (i = 0; i < bpb.rdlen; i++)
		table[i] = d + i;
	err = info_load_dir_short(&arbo, table, bpb.rdlen, drive, 0, fat, (long)bpb.datrec, (long)(bpb.numcl +2) * bpb.clsiz + bpb.datrec, &error, "Root       ", cluster);
	paraminfo(NULL, NULL);

	FAT[drive] = fat;
	Arbo[drive] = arbo;

	/* l'arborescence est charg‚e en entier */
	Arbo[drive] -> time = TRUE;

	if (!err)
	{
		unsigned int i, j;
#ifndef TEST_VERSION
		int res = 0;
		char name[FILENAME_MAX];
#endif

		/*
			Blocs occup‚s et pas dans un fichier
		*/
		for (i=2; i<bpb.numcl +2; i++)
		{
			if (fat[i] && !cluster[i] && (fat[i] < 0xFFF0 || fat[i] > 0xFFF7))	/* bloc occup‚ … rien et pas endommag‚ */
			{
				for (j=i; j<bpb.numcl +2 && fat[j]; j++)
					if (fat[j] && cluster[j])
						break;

				j--;	/* ramŠne au dernier cluster 'libre' */

				if (j == i)
				{
					sprintf(text, Messages(INFO_9), i);
					ajoute(Firstwindow, text);
#ifndef TEST_VERSION
					if (res != 2 && (res = my_alert(1, 2, X_ICN_QUESTION, Messages(INFO_10), Messages(INFO_68))) == 0)
					{
						sprintf(name, "FILE%04XZRG", i);
						if (create_file_short(name, i, (long)bpb.clsizb, arbo, drive))
						{
							fat[i] = 0xFFFF;
							dirty_fat = TRUE;

							ajoute(Firstwindow, Messages(INFO_11));
						}
					}
#endif
				}
				else
				{
					sprintf(text, Messages(INFO_12), i, j);
					ajoute(Firstwindow, text);
#ifndef TEST_VERSION
					if (res != 2 && (res = my_alert(1, 2, X_ICN_QUESTION, Messages(INFO_10), Messages(INFO_68))) == 0)
					{
						sprintf(name, "FILE%04XZRG", i);
						if (create_file_short(name, i, (j - i +1) * (long)bpb.clsizb, arbo, drive))
						{
							unsigned int k;

							for (k=i; k<j; k++)
								fat[k] = k+1;

							fat[j] = 0xFFFF;

							dirty_fat = TRUE;

							ajoute(Firstwindow, Messages(INFO_11));
						}
					}
#endif

					i = j+1;	/* et on continue */
				}

				error++;
			}
		}
	}

#ifndef TEST_VERSION
	if (dirty_fat)
		save_FAT(drive);
#endif

	if (error == 0 || (error == 1 && bpb.fsiz > fatsiz))
	{
		ajoute(Firstwindow, Messages(INFO_15));

		/* c'est bon pour cette partition */
		StructureTest[drive] = TRUE;
	}
	else
		if (err)
		{
			sprintf(text, Messages(INFO_13), error);
			ajoute(Firstwindow, text);
		}
		else
		{
			sprintf(text, Messages(INFO_14), error);
			ajoute(Firstwindow, text);
		}

	free(table);

	Cluster[drive] = cluster;

	if (!KeepStructure)
		change_disque(drive, FALSE);
} /* structure_test_short */

/********************************************************************
*																	*
*				teste la structure de la partition (VFAT)			*
*																	*
********************************************************************/
void structure_test_vfat(int drive)
{
	char text[80], *fat1, *fat2;
	int err, d, error = 0, fatsiz;
#ifndef TEST_VERSION
	int dirty_fat = FALSE;
#endif
	BPB bpb;
	unsigned int *fat = NULL;
	dir_elt_vfat *arbo = NULL, **cluster = NULL;
	long *table, i;

	change_disque(drive, FALSE);

	bpb = my_getbpb(drive);

	sprintf(text, Messages(INFO_3), drive + 'A');
	ajoute(Firstwindow, text);

	if (bpb.recsiz == 0)
		return;

	/* par d‚faut c'est pas bon */
	StructureTest[drive] = FALSE;

	/*
		FAT de mauvaise taille
	*/
	if (drive < 2)
		fatsiz = (int)(((bpb.numcl +2L) *3 /2 + bpb.recsiz-1) /bpb.recsiz);
	else
		fatsiz = (int)(((bpb.numcl +2L) *2 + bpb.recsiz-1) /bpb.recsiz);

	if (bpb.fsiz < fatsiz)
	{
		sprintf(text, Messages(INFO_4), bpb.fsiz, fatsiz);
		ajoute(Firstwindow, text);
		return;
	}

	if (bpb.fsiz > fatsiz)
	{
		sprintf(text, Messages(INFO_5), bpb.fsiz, fatsiz);
		ajoute(Firstwindow, text);
		error++;
		/* problŠme courant et pas g‚nant */
	}

	/*
		Mauvais d‚but de la deuxiŠme FAT
	*/
	if (bpb.fatrec != bpb.fsiz +1)
	{
		sprintf(text, Messages(INFO_6), bpb.fatrec, bpb.fsiz+1);
		ajoute(Firstwindow, text);
		return;
	}

	if ((fat1 = malloc((size_t)bpb.recsiz * bpb.fsiz)) == NULL || (fat2 = malloc((size_t)bpb.recsiz * bpb.fsiz)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return;
	}

	paraminfo(Messages(FAT_8), NULL);
	if (my_rwabs(0, fat1, bpb.fsiz, 1L, drive))
	{
		free (fat1);
		free (fat2);
		return;
	}

	if (my_rwabs(0, fat2, bpb.fsiz, (long)bpb.fatrec, drive))
	{
		free(fat1);
		free(fat2);
		return;
	}

	paraminfo(NULL, NULL);

	/*
		Les deux FATs ne sont pas identiques
	*/
	i = bpb.bflags & 1 ? 4 : 3;	/* on saute les 2 premiers clusters */

	/* compare les deux premies clusters */
	if (memcmp(fat1, fat2, (size_t)i))
	{
		sprintf(text, Messages(INFO_72));
		ajoute(Firstwindow, text);
	}

	/* les clusters suivants 2 -> ... */
	for (; i<bpb.fsiz * bpb.recsiz; i++)
		if (fat1[i] != fat2[i])	/* fat1 et fat2 sont des (char *) et pas (unsigned int *) */
		{
			sprintf(text, Messages(INFO_7), i, (int)(i / ((bpb.bflags & 1) ? 2.0 : 1.5)) -2);
			ajoute(Firstwindow, text);
			sprintf(text, Messages(INFO_67), (int)(i/bpb.recsiz)+1, (int)(bpb.fatrec + i/bpb.recsiz), i % bpb.recsiz );
			ajoute(Firstwindow, text);

			free(fat1);
			free(fat2);

			return;
		}
	free(fat2);

	if ((fat = malloc(drive < 2 ? (bpb.numcl +2L) * sizeof(unsigned int) : bpb.fsiz * (size_t)bpb.recsiz)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(fat1);
		return;
	}

	if (drive < 2)
		swap_flopy_FAT(fat, (unsigned int *)fat1, bpb.numcl +2);
	else
		swap_FAT(fat, (unsigned int *)fat1, (bpb.recsiz/512) * bpb.fsiz);
	free(fat1);

	paraminfo(Messages(INFO_8), Messages(FAT_2));
	if ((table = calloc((size_t)bpb.rdlen, sizeof(long))) == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(fat);
		return;
	}

	if ((cluster = calloc(bpb.numcl+2L, sizeof(char *))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(fat);
		free(table);
		return;
	}

	d = bpb.fatrec + bpb.fsiz;
	for (i = 0; i < bpb.rdlen; i++)
		table[i] = d + i;
	err = info_load_dir_vfat(&arbo, table, bpb.rdlen, drive, 0, fat, (long)bpb.datrec, (long)(bpb.numcl +2) * bpb.clsiz + bpb.datrec, &error, "Root       ", cluster);
	paraminfo(NULL, NULL);

	FAT[drive] = fat;
	Arbo[drive] = (dir_elt_short *)arbo;

	/* l'arborescence est charg‚e en entier */
	Arbo[drive] -> time = TRUE;

	if (!err)
	{
		unsigned int i, j;
#ifndef TEST_VERSION
		int res = 0;
		char name[FILENAME_MAX];
#endif

		/*
			Blocs occup‚s et pas dans un fichier
		*/
		for (i=2; i<bpb.numcl +2; i++)
		{
			if (fat[i] && !cluster[i] && (fat[i] < 0xFFF0 || fat[i] > 0xFFF7))	/* bloc occup‚ … rien et pas endommag‚ */
			{
				for (j=i; j<bpb.numcl +2 && fat[j]; j++)
					if (fat[j] && cluster[j])
						break;

				j--;	/* ramŠne au dernier cluster 'libre' */

				if (j == i)
				{
					sprintf(text, Messages(INFO_9), i);
					ajoute(Firstwindow, text);
#ifndef TEST_VERSION
					if (res != 2 && (res = my_alert(1, 2, X_ICN_QUESTION, Messages(INFO_10), Messages(INFO_68))) == 0)
					{
						sprintf(name, "FILE%04XZRG", i);
						if (create_file_vfat(name, i, (long)bpb.clsizb, arbo, drive))
						{
							fat[i] = 0xFFFF;
							dirty_fat = TRUE;

							ajoute(Firstwindow, Messages(INFO_11));
						}
					}
#endif
				}
				else
				{
					sprintf(text, Messages(INFO_12), i, j);
					ajoute(Firstwindow, text);
#ifndef TEST_VERSION
					if (res != 2 && (res = my_alert(1, 2, X_ICN_QUESTION, Messages(INFO_10), Messages(INFO_68))) == 0)
					{
						sprintf(name, "FILE%04XZRG", i);
						if (create_file_vfat(name, i, (j - i +1) * (long)bpb.clsizb, arbo, drive))
						{
							unsigned int k;

							for (k=i; k<j; k++)
								fat[k] = k+1;

							fat[j] = 0xFFFF;

							dirty_fat = TRUE;

							ajoute(Firstwindow, Messages(INFO_11));
						}
					}
#endif

					i = j+1;	/* et on continue */
				}

				error++;
			}
		}
	}

#ifndef TEST_VERSION
	if (dirty_fat)
		save_FAT(drive);
#endif

	if (error == 0 || (error == 1 && bpb.fsiz > fatsiz))
	{
		ajoute(Firstwindow, Messages(INFO_15));

		/* c'est bon pour cette partition */
		StructureTest[drive] = TRUE;
	}
	else
		if (err)
		{
			sprintf(text, Messages(INFO_13), error);
			ajoute(Firstwindow, text);
		}
		else
		{
			sprintf(text, Messages(INFO_14), error);
			ajoute(Firstwindow, text);
		}

	free(table);

	Cluster[drive] = (dir_elt_short **)cluster;

	if (!KeepStructure)
		change_disque(drive, FALSE);
} /* structure_test_vfat */

/****************************************************************
*																*
*			cr‚‚ une entr‚‚ dans le r‚pertoire principal		*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean create_file_short(char *name, unsigned int first_cluster, long size, dir_elt_short arbo[], int drive)
{
	int i, entrees = (int)arbo[0].size;
	char *buffer;
	dir_elt_short elt;

	arbo++;

	for (i=0; i<entrees; i++)
		if (arbo[i].name[0] == 0x00 || arbo[i].name[0] == 0xE5)
			break;

	if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
		return FALSE;

	if (i<entrees && !my_rwabs(0, buffer, 1, (long)arbo[-1].first_cluster + i/(Bpb[drive].recsiz/32), drive))
	{
		strncpy(elt.name, name, 8+3);
		elt.attribut = 0;
		elt.time = Tgettime();
		elt.date = Tgetdate();
		elt.first_cluster = first_cluster;
		elt.size = size;

		arbo[i] = elt;

		re_trans_dir_elt_short((real_dir_elt *)(buffer + sizeof(real_dir_elt) * (i & ((Bpb[drive].recsiz/32)-1))), &elt);
		my_rwabs(1, buffer, 1, (long)arbo[-1].first_cluster + i/(Bpb[drive].recsiz/32), drive);

		sector_free(buffer);

		return TRUE;
	}

	sector_free(buffer);

	return FALSE;
} /* create_file_short */
#endif

/****************************************************************
*																*
*		cr‚‚ une entr‚‚ dans le r‚pertoire principal (VFAT)		*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean create_file_vfat(char *name, unsigned int first_cluster, long size, dir_elt_vfat arbo[], int drive)
{
	int i, entrees = (int)arbo[0].size;
	char *buffer;
	dir_elt_vfat elt;

	arbo++;

	for (i=0; i<entrees; i++)
		if (arbo[i].name[0] == 0x00 || arbo[i].name[0] == 0xE5)
			break;

	if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
		return FALSE;

	if (i<entrees && !my_rwabs(0, buffer, 1, (long)arbo[-1].first_cluster + i/(Bpb[drive].recsiz/32), drive))
	{
		strncpy(elt.name, name, 8+3);
		elt.attribut = 0;
		elt.time = Tgettime();
		elt.date = Tgetdate();
		elt.first_cluster = first_cluster;
		elt.size = size;
		memset(elt.filler, 0, 10L);

		arbo[i] = elt;

		re_trans_dir_elt_vfat((real_dir_elt *)(buffer + sizeof(real_dir_elt) * (i & ((Bpb[drive].recsiz/32)-1))), &elt);
		my_rwabs(1, buffer, 1, (long)arbo[-1].first_cluster + i/(Bpb[drive].recsiz/32), drive);

		sector_free(buffer);

		return TRUE;
	}

	sector_free(buffer);

	return FALSE;
} /* create_file_vfat */
#endif

/****************************************************************
*																*
*			charge l'arborescence avec v‚rification				*
*																*
****************************************************************/
boolean info_load_dir_short(dir_elt_short *(arbo[]), long table[], int max, int drive, unsigned int first_cluster, unsigned int *fat, long s_min, long s_max, int *minor, char *name, dir_elt_short **cluster)
{
	real_dir_elt *buffer;
	dir_elt_short *local_arbo;
	int sect, i;
	char text[100];
	BPB bpb = Bpb[drive];
	int dirsiz = bpb.recsiz/32;
	int err;
	unsigned int nb_clst, clst;

	*arbo = calloc(max * dirsiz + 1L, sizeof(dir_elt_short));
	local_arbo = *arbo;
	if (local_arbo == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		(*minor)++;
		return TRUE;
	}

	strcpy(local_arbo -> name, "Info.dir");
	local_arbo -> time = 0;
	local_arbo -> date = 0;
	if (first_cluster)
	{
		local_arbo -> first_cluster = first_cluster;	/* premier cluster */
		local_arbo -> attribut = FALSE;
	}
	else
	{
		local_arbo -> first_cluster = (unsigned int)table[0];	/* premier secteur */
		local_arbo -> attribut = TRUE;	/* c'est la racine */
	}
	local_arbo -> size = max * (long)dirsiz; /* nombre d'entr‚es dans le r‚pertoire */
	local_arbo -> dir = NULL;
	local_arbo++;

	if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
		return TRUE;

	for (sect=0; sect<max; sect++)
	{
		if (my_rwabs(0, (char *)buffer, 1, table[sect], drive))
		{
			free(*arbo);
			*arbo = NULL;
			(*minor)++;

			sector_free(buffer);

			return TRUE;
		}

		for (i=0; i<dirsiz; i++)
			trans_dir_elt_short(local_arbo + i + sect*dirsiz, &buffer[i]);
	}

	/* c'est un r‚pertoire normal */
	if (first_cluster)
	{
		local_arbo -> norealdir = TRUE;	/* marque '.' et '..' */
		(local_arbo + 1) -> norealdir = TRUE;

		if (strncmp(local_arbo -> name, ".          ", 8+3))
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_16), name, &name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
		}

		if (strncmp((local_arbo + 1) -> name, "..         ", 8+3))
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_17), name, &name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
		}

		if (local_arbo -> first_cluster != first_cluster)
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_18), name, &name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
		}
	}

	for (i=0; i<max * dirsiz; i++, local_arbo++)
	{
		err = FALSE;

		if (local_arbo -> norealdir || local_arbo -> name[0] == 0xE5 || local_arbo -> name[0] == 0x00 || local_arbo -> attribut & FA_VOLUME)
			continue;

		clst = local_arbo -> first_cluster;

		if (clst == 0)
			if (local_arbo -> size == 0)
				if (local_arbo -> attribut & FA_SUBDIR)
				{
					paraminfo(NULL, NULL);
					sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
					ajoute(Firstwindow, text);
					(*minor)++;
					continue;
				}
				else
					continue;	/* fichier vide */
			else
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
				ajoute(Firstwindow, text);
				(*minor)++;
				continue;
			}

		/*
			cluster hors du disque
		*/
		if (clst < 2 || clst > bpb.numcl +2)
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
			ajoute(Firstwindow, text);
			(*minor)++;
			continue;
		}

		/*
			cluster partag‚
		*/
		if (cluster[clst])
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_25), clst, local_arbo -> name, &local_arbo -> name[8], cluster[clst] -> name, &cluster[clst] -> name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
			continue;
		}

		/*
			D‚tecte une boucle infinie sur un fichier
		*/
		nb_clst = 1;
		while ((clst = fat[clst]) < 0xFFF0)
		{
			nb_clst++;
			if (nb_clst > bpb.numcl)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_26), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}

			if (clst < 2 || clst > bpb.numcl +2)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}
		}
		if (err)
			continue;

		/*
			Ad‚quation nombre de clusters et taille du fichier
		*/
		if (!(local_arbo -> attribut & FA_SUBDIR) && (local_arbo -> size <= (nb_clst -1) * bpb.clsiz * (long)bpb.recsiz || local_arbo -> size > nb_clst * bpb.clsiz * (long)bpb.recsiz))
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_27), local_arbo -> name, &local_arbo -> name[8], nb_clst, local_arbo -> size);
			ajoute(Firstwindow, text);
			(*minor)++;
		}

		/*
			V‚rifie que les clusters d'un fichier ne sont pas d‚j… occup‚s
		*/
		clst = local_arbo -> first_cluster;

		cluster[clst] = local_arbo;
		while ((clst = fat[clst]) < 0xFFF0 && clst >= 2 && clst < bpb.numcl+2)
		{
			/*
				On est tomb‚ sur un bloc libre
			*/
			if (cluster == 0)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_28), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}

			if (cluster[clst])
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_29), clst, local_arbo -> name, &local_arbo -> name[8], cluster[clst] -> name, &cluster[clst] -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}

			cluster[clst] = local_arbo;
		}
		if (err)
			continue;

		/* un sous-r‚pertoire */
		if (local_arbo -> attribut & FA_SUBDIR && !local_arbo -> norealdir && local_arbo -> name[0] != 0xE5 && local_arbo -> name[0] != 0x00)
		{
			long *table;
			int max, j;
			char rep[40];

			sprintf(rep, Messages(FAT_3), local_arbo -> name, &local_arbo -> name[8]);
			paraminfo(NULL, rep);	/* Chargement et v‚rification de l'arborescence */

			max = info_create_table(local_arbo -> first_cluster, &table, drive, fat, local_arbo -> name);

			if (max == 0)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_19), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;

				sector_free(buffer);

				return TRUE;
			}

			for (j=0; j<max; j++)
				if (table[j] > s_max || table[j] < s_min)
				{
					paraminfo(NULL, NULL);
					sprintf(text, Messages(INFO_20), j, local_arbo -> name, &local_arbo -> name[8], table[0]);
					ajoute(Firstwindow, text);
					(*minor)++;

					sector_free(buffer);

					return TRUE;
				}

			if (info_load_dir_short(&local_arbo -> dir, table, max, drive, local_arbo -> first_cluster, fat, s_min, s_max, minor, local_arbo -> name, cluster))
			{
				sector_free(buffer);
				return TRUE;
			}
			local_arbo -> dir[1].dir = local_arbo -> dir; /* r‚pertoire . */
			local_arbo -> dir[2].dir = local_arbo;	/* r‚petoire .. */
			free(table);

			if (first_cluster != local_arbo -> dir[2].first_cluster)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_21), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
			}

			sprintf(rep, Messages(FAT_3), name, &name[8]);
			paraminfo(NULL, rep);	/* Chargement et v‚rification de l'arborescence */
		}
	}

	sector_free(buffer);

	return FALSE;
} /* info_load_dir_short */

/****************************************************************
*																*
*			charge l'arborescence avec v‚rification				*
*																*
****************************************************************/
boolean info_load_dir_vfat(dir_elt_vfat *(arbo[]), long table[], int max, int drive, unsigned int first_cluster, unsigned int *fat, long s_min, long s_max, int *minor, char *name, dir_elt_vfat **cluster)
{
	real_dir_elt *buffer;
	dir_elt_vfat *local_arbo;
	int sect, i;
	char text[100];
	BPB bpb = Bpb[drive];
	int dirsiz = bpb.recsiz/32;
	int err;
	unsigned int nb_clst, clst;

	*arbo = calloc(max * dirsiz + 1L, sizeof(dir_elt_vfat));
	local_arbo = *arbo;
	if (local_arbo == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		(*minor)++;
		return TRUE;
	}

	strcpy(local_arbo -> name, "Info.dir");
	local_arbo -> time = 0;
	local_arbo -> date = 0;
	if (first_cluster)
	{
		local_arbo -> first_cluster = first_cluster;	/* premier cluster */
		local_arbo -> attribut = FALSE;
	}
	else
	{
		local_arbo -> first_cluster = (unsigned int)table[0];	/* premier secteur */
		local_arbo -> attribut = TRUE;	/* c'est la racine */
	}
	local_arbo -> size = max * (long)dirsiz; /* nombre d'entr‚es dans le r‚pertoire */
	local_arbo -> dir = NULL;
	local_arbo++;

	if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
		return TRUE;

	for (sect=0; sect<max; sect++)
	{
		if (my_rwabs(0, (char *)buffer, 1, table[sect], drive))
		{
			free(*arbo);
			*arbo = NULL;
			(*minor)++;

			sector_free(buffer);

			return TRUE;
		}

		for (i=0; i<dirsiz; i++)
			trans_dir_elt_vfat(local_arbo + i + sect*dirsiz, &buffer[i]);
	}

	/* c'est un r‚pertoire normal */
	if (first_cluster)
	{
		local_arbo -> norealdir = TRUE;	/* marque '.' et '..' */
		(local_arbo + 1) -> norealdir = TRUE;

		if (strncmp(local_arbo -> name, ".          ", 8+3))
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_16), name, &name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
		}

		if (strncmp((local_arbo + 1) -> name, "..         ", 8+3))
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_17), name, &name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
		}

		if (local_arbo -> first_cluster != first_cluster)
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_18), name, &name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
		}
	}

	for (i=0; i<max * dirsiz; i++, local_arbo++)
	{
		err = FALSE;

		if (local_arbo -> norealdir || local_arbo -> name[0] == 0xE5 || local_arbo -> name[0] == 0x00 || local_arbo -> attribut & FA_VOLUME)
			continue;

		clst = local_arbo -> first_cluster;

		if (clst == 0)
			if (local_arbo -> size == 0)
				if (local_arbo -> attribut & FA_SUBDIR)
				{
					paraminfo(NULL, NULL);
					sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
					ajoute(Firstwindow, text);
					(*minor)++;
					continue;
				}
				else
					continue;	/* fichier vide */
			else
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
				ajoute(Firstwindow, text);
				(*minor)++;
				continue;
			}

		/*
			cluster hors du disque
		*/
		if (clst < 2 || clst > bpb.numcl +2)
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
			ajoute(Firstwindow, text);
			(*minor)++;
			continue;
		}

		/*
			cluster partag‚
		*/
		if (cluster[clst])
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_25), clst, local_arbo -> name, &local_arbo -> name[8], cluster[clst] -> name, &cluster[clst] -> name[8]);
			ajoute(Firstwindow, text);
			(*minor)++;
			continue;
		}

		/*
			D‚tecte une boucle infinie sur un fichier
		*/
		nb_clst = 1;
		while ((clst = fat[clst]) < 0xFFF0)
		{
			nb_clst++;
			if (nb_clst > bpb.numcl)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_26), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}

			if (clst < 2 || clst > bpb.numcl +2)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_24), local_arbo -> name, &local_arbo -> name[8], clst);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}
		}
		if (err)
			continue;

		/*
			Ad‚quation nombre de clusters et taille du fichier
		*/
		if (!(local_arbo -> attribut & FA_SUBDIR) && (local_arbo -> size <= (nb_clst -1) * bpb.clsiz * (long)bpb.recsiz || local_arbo -> size > nb_clst * bpb.clsiz * (long)bpb.recsiz))
		{
			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_27), local_arbo -> name, &local_arbo -> name[8], nb_clst, local_arbo -> size);
			ajoute(Firstwindow, text);
			(*minor)++;
		}

		/*
			V‚rifie que les clusters d'un fichier ne sont pas d‚j… occup‚s
		*/
		clst = local_arbo -> first_cluster;

		cluster[clst] = local_arbo;
		while ((clst = fat[clst]) < 0xFFF0 && clst >= 2 && clst < bpb.numcl+2)
		{
			/*
				On est tomb‚ sur un bloc libre
			*/
			if (cluster == 0)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_28), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}

			if (cluster[clst])
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_29), clst, local_arbo -> name, &local_arbo -> name[8], cluster[clst] -> name, &cluster[clst] -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
				err = TRUE;
				break;
			}

			cluster[clst] = local_arbo;
		}
		if (err)
			continue;

		/* un sous-r‚pertoire */
		if (local_arbo -> attribut & FA_SUBDIR && !local_arbo -> norealdir && local_arbo -> name[0] != 0xE5 && local_arbo -> name[0] != 0x00)
		{
			long *table;
			int max, j;
			char rep[40];

			sprintf(rep, Messages(FAT_3), local_arbo -> name, &local_arbo -> name[8]);
			paraminfo(NULL, rep);	/* Chargement et v‚rification de l'arborescence */

			max = info_create_table(local_arbo -> first_cluster, &table, drive, fat, local_arbo -> name);

			if (max == 0)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_19), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;

				sector_free(buffer);

				return TRUE;
			}

			for (j=0; j<max; j++)
				if (table[j] > s_max || table[j] < s_min)
				{
					paraminfo(NULL, NULL);
					sprintf(text, Messages(INFO_20), j, local_arbo -> name, &local_arbo -> name[8], table[0]);
					ajoute(Firstwindow, text);
					(*minor)++;

					sector_free(buffer);

					return TRUE;
				}

			if (info_load_dir_vfat(&local_arbo -> dir, table, max, drive, local_arbo -> first_cluster, fat, s_min, s_max, minor, local_arbo -> name, cluster))
			{
				sector_free(buffer);
				return TRUE;
			}
			local_arbo -> dir[1].dir = local_arbo -> dir; /* r‚pertoire . */
			local_arbo -> dir[2].dir = local_arbo;	/* r‚petoire .. */
			free(table);

			if (first_cluster != local_arbo -> dir[2].first_cluster)
			{
				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_21), local_arbo -> name, &local_arbo -> name[8]);
				ajoute(Firstwindow, text);
				(*minor)++;
			}

			sprintf(rep, Messages(FAT_3), name, &name[8]);
			paraminfo(NULL, rep);	/* Chargement et v‚rification de l'arborescence */
		}
	}

	sector_free(buffer);

	return FALSE;
} /* info_load_dir_vfat */

/****************************************************************
*																*
*	cr‚e la liste des secteurs d'un fichier avec v‚rification	*
*																*
****************************************************************/
int info_create_table(unsigned int first_cluster, long *(table[]), int drive, unsigned int *fat, char *name)
{
	BPB bpb = Bpb[drive];
	int clsiz = bpb.clsiz, datrec = bpb.datrec, i;
	unsigned int cluster, nb_sect = clsiz;
	long *table_bis;

	cluster = first_cluster;

	if (cluster == 0)
		return 0;

	while ((cluster = fat[cluster]) < 0xFFF0)
		if (cluster == 0)
		{
			char text[80];

			paraminfo(NULL, NULL);
			sprintf(text, Messages(INFO_22), name, &name[8]);
			ajoute(Firstwindow, text);
			return 0;
		}
		else
		{
			nb_sect += clsiz;
			if (nb_sect > bpb.numcl*clsiz)
			{
				char text[80];

				paraminfo(NULL, NULL);
				sprintf(text, Messages(INFO_23), name, &name[8]);
				ajoute(Firstwindow, text);
				return 0;
			}
		}

	*table = calloc((size_t)nb_sect, sizeof(long));
	table_bis = *table;
	if (table_bis == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return 0;
	}

	nb_sect = 0;
	cluster = first_cluster;
	do
	{
		for (i=0; i<clsiz; i++)
			table_bis[nb_sect++] = (cluster-2) * clsiz + datrec + i;
	} while ((cluster = fat[cluster]) < 0xFFF0);

	return nb_sect;
} /* info_create_table */

/********************************************************************
*																	*
*					statistiques du disque							*
*																	*
********************************************************************/
void statistiques(int drive)
{
	char text[80];
	BPB bpb;
	unsigned int *fat;
	int occupe = 0, morceaux, bad = 0;
	unsigned int prev, i;
	int file = 0, file_frac = 0, dir = 0;
	float f;

	if (drive < 2)
		sprintf(text, Messages(INFO_30), 'A'+drive);
	else
		sprintf(text, Messages(INFO_31), 'A'+drive);
	ajoute(Firstwindow, text);

	/************* infos sur la FAT *************/
	if (load_FAT(drive))
		return;

	bpb = Bpb[drive];
	fat = FAT[drive];

	if (fat[2])
		morceaux = 1;	/* le bloc commence dŠs le d‚but */
	else
		morceaux = 0;

	prev = 1;
	for (i=2; i<bpb.numcl+2; i++)
	{
		/* fichier */
		if (fat[i] && (fat[i] < 0xFFF0 || fat[i] > 0xFFF7))
		{
			if (i-1 != prev)	/* un nouveau bloc ? */
				morceaux++;
			prev = i;

			occupe++;
		}

		/* bad bloc */
		if (fat[i] >= 0xFFF0 && fat[i] <= 0xFFF7)
			bad++;
	}

	f = 100. * occupe / bpb.numcl;
	/* % d'occupation */
	sprintf(text, Messages(INFO_32), bpb.numcl, occupe, f, bpb.numcl-occupe, 100-f);
	ajoute(Firstwindow, text);

	/* morceaux */
	sprintf(text, Messages(INFO_33), morceaux, morceaux>1 ? 'x' : ' ');
	ajoute(Firstwindow, text);

	/* bad blocs */
	if (bad)
	{
		int len = 2;

		sprintf(text, Messages(INFO_70), bad);
		ajoute(Firstwindow, text);

		strcpy(text, "  ");
		for (i=2; i<bpb.numcl+2; i++)
			if (fat[i] >= 0xFFF0 && fat[i] <= 0xFFF7)
			{
				sprintf(&text[len], "%04X ", i);
				len += 5;
				if (len > 70)	/* la ligne est pleine */
				{
					ajoute(Firstwindow, text);
					len = 2;
				}
			}

		if (len > 2)
			ajoute(Firstwindow, text);
	}
	else
	{
		strcpy(text, Messages(INFO_71));
		ajoute(Firstwindow, text);
	}

	/************ infos sur l'arborescence **************/
	if (load_arbo(drive))
		return;

	if (!Cluster[drive])
		if ((Cluster[drive] = calloc(bpb.numcl +2L, sizeof(char *))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}
		else
			if (ManageVFAT)
				create_map_vfat((dir_elt_vfat *)Arbo[drive], (dir_elt_vfat **)Cluster[drive], FAT[drive]);
			else
				create_map_short(Arbo[drive], Cluster[drive], FAT[drive]);

	if (ManageVFAT)
		compte_fichiers_vfat(drive, (dir_elt_vfat *)Arbo[drive], FAT[drive], &file, &dir, &file_frac);
	else
		compte_fichiers_short(drive, Arbo[drive], FAT[drive], &file, &dir, &file_frac);
	sprintf(text, Messages(INFO_34), file, dir);
	ajoute(Firstwindow, text);

	f = file ? 100. * file_frac / file : 0.;
	sprintf(text, Messages(INFO_35), file_frac, f);
	ajoute(Firstwindow, text);

} /* statistiques */

/********************************************************************
*																	*
*				Compte les fichiers du disque						*
*																	*
********************************************************************/
void compte_fichiers_short(int drive, dir_elt_short dir[], unsigned int fat[], int *file, int *directory, int *file_frac)
{
	int i, size;
	unsigned int cluster, prev;

	size = (int)dir[0].size;
	dir++;

	for (i=0; i<size; i++)
	{
		if (dir[i].norealdir || dir[i].name[0] == '\xE5' || dir[i].name[0] == '\0')
			continue;

		(*file)++;
		cluster = dir[i].first_cluster;
		prev = cluster;
		if (cluster != 0)
			while ((cluster = fat[cluster]) < 0xFFF0)
			{
				if ((cluster != prev+1) && Cluster[drive][cluster])
				{
					char file[FILENAME_MAX], text[FILENAME_MAX];

					get_name_from_cluster_short(drive, cluster, file, FILENAME_MAX);
					if (Cluster[drive][cluster] -> attribut & FA_SUBDIR)
						sprintf(text, Messages(INFO_36), file);
					else
						sprintf(text, Messages(INFO_37), file);
					ajoute(Firstwindow, text);

					(*file_frac)++;
					break;
				}
				prev = cluster;
			}

		if (dir[i].attribut & FA_SUBDIR && dir[i].dir != NULL)
		{
			(*directory)++;
			compte_fichiers_short(drive, dir[i].dir, fat, file, directory, file_frac);
		}
	}
} /* compte_fichiers_short */

/********************************************************************
*																	*
*				Compte les fichiers du disque (VFAT)				*
*																	*
********************************************************************/
void compte_fichiers_vfat(int drive, dir_elt_vfat dir[], unsigned int fat[], int *file, int *directory, int *file_frac)
{
	int i, size;
	unsigned int cluster, prev;

	size = (int)dir[0].size;
	dir++;

	for (i=0; i<size; i++)
	{
		if (dir[i].norealdir || dir[i].name[0] == '\xE5' || dir[i].name[0] == '\0')
			continue;

		(*file)++;
		cluster = dir[i].first_cluster;
		prev = cluster;
		if (cluster != 0)
			while ((cluster = fat[cluster]) < 0xFFF0)
			{
				if ((cluster != prev+1) && Cluster[drive][cluster])
				{
					char file[FILENAME_MAX], text[FILENAME_MAX];

					get_name_from_cluster_vfat(drive, cluster, file, FILENAME_MAX);
					if (Cluster[drive][cluster] -> attribut & FA_SUBDIR)
						sprintf(text, Messages(INFO_36), file);
					else
						sprintf(text, Messages(INFO_37), file);
					ajoute(Firstwindow, text);

					(*file_frac)++;
					break;
				}
				prev = cluster;
			}

		if (dir[i].attribut & FA_SUBDIR && dir[i].dir != NULL)
		{
			(*directory)++;
			compte_fichiers_vfat(drive, dir[i].dir, fat, file, directory, file_frac);
		}
	}
} /* compte_fichiers */

/********************************************************************
*																	*
*					Occupation du disque							*
*																	*
********************************************************************/
void occupation(int drive)
{
	register windowptr thewin;
	char titre[MAX_TITLE];

	if (load_FAT(drive))
	{
		ajoute(Firstwindow, Messages(INFO_38));
		return;
	}

	sprintf(titre, Messages(INFO_39), drive+'A');
	if ((thewin = new_window(CLOSER | SIZER | MOVER | FULLER | NAME, titre, NULL, occupationproc, OCCUP, 2)) != NULL)
	{
		thewin -> fonction.occup.device = drive;

		thewin -> fonction.occup.decimal = FALSE;
		thewin -> fonction.occup.fichier = FALSE;

		/* entr‚e dans le menu */
		get_menu_entry(thewin, titre+1);

		make_frontwin(thewin);
		taille_ideale(thewin);

		sprintf(titre, Messages(INFO_69), drive+'A');
		ajoute(Firstwindow, titre);
	}
} /* occupation */

/********************************************************************
*																	*
*					Informations sur un disque						*
*																	*
********************************************************************/
void informations(int drive)
{
	BPB bpb;
	char text[80], *buffer;
	int i;
	UWORD crc;

	if (drive < 2)
		sprintf(text, Messages(INFO_40), 'A'+drive);
	else
		sprintf(text, Messages(INFO_41), 'A'+drive);
	ajoute(Firstwindow, text);

	bpb = my_getbpb(drive);
	if (bpb.recsiz == 0)
	{
		ajoute(Firstwindow, Messages(INFO_42));
		return;
	}

	sprintf(text, Messages(INFO_43), bpb.recsiz);
	ajoute(Firstwindow, text);

	sprintf(text, Messages(INFO_44), bpb.clsiz, (long)bpb.clsiz * bpb.recsiz);
	ajoute(Firstwindow, text);

	sprintf(text, Messages(INFO_45), bpb.fsiz);
	ajoute(Firstwindow, text);

	sprintf(text, Messages(INFO_46), bpb.fatrec);
	ajoute(Firstwindow, text);

	sprintf(text, Messages(INFO_47), bpb.fatrec + bpb.fsiz, bpb.rdlen);
	ajoute(Firstwindow, text);

	sprintf(text, Messages(INFO_48), bpb.numcl, bpb.datrec);
	ajoute(Firstwindow, text);

	sprintf(text, Messages(INFO_49), bpb.bflags);
	ajoute(Firstwindow, text);
	sprintf(text, Messages(INFO_50), bpb.bflags & 1 ? 16 : 12);
	ajoute(Firstwindow, text);

	if ((buffer = sector_alloc(bpb.recsiz)) == NULL)
		return;

	/********************* informations du boot ******************/
	if ((i = my_rwabs(0, buffer, 1, 0, drive)) != 0)
	{
		if (i == -14)
			change_disque(drive, TRUE);
		return;
	}

	ajoute(Firstwindow, Messages(INFO_51));
	crc = 0;
	for (i=0; i<256; i++)
		crc += ((UWORD *)buffer)[i];
	if (crc == 0x1234)
		ajoute(Firstwindow, Messages(INFO_52));
	else
		ajoute(Firstwindow, Messages(INFO_53));

	sprintf(text, "  OEM : %.6s", &buffer[2]);
	ajoute(Firstwindow, text);
	
	sprintf(text, Messages(INFO_54), (unsigned long)(((unsigned long)(buffer[0xA])<<16) + ((unsigned long)(buffer[9])<<8) + (unsigned long)buffer[8]));
	ajoute(Firstwindow, text);
	
	sprintf(text, Messages(INFO_55), (buffer[0xF]<<8) + buffer[0xE]);
	ajoute(Firstwindow, text);
	
	sprintf(text, Messages(INFO_56), (buffer[0x12]<<8) + buffer[0x11]);
	ajoute(Firstwindow, text);
	
	sprintf(text, Messages(INFO_57), (buffer[0x14]<<8) + buffer[0x13]);
	ajoute(Firstwindow, text);
	
	sprintf(text, Messages(INFO_58), buffer[0x15]);
	ajoute(Firstwindow, text);
	
	if (drive < 2)
	{
		ajoute(Firstwindow, Messages(INFO_59));

		sprintf(text, Messages(INFO_60), (buffer[0x1B]<<16) + buffer[0x1A]);
		ajoute(Firstwindow, text);
	
		sprintf(text, Messages(INFO_61), (buffer[0x19]<<8) + buffer[0x18]);
		ajoute(Firstwindow, text);
	
		sprintf(text, Messages(INFO_62), ((buffer[0x14]<<8) + buffer[0x13])/((buffer[0x19]<<8) + buffer[0x18])/((buffer[0x1B]<<16) + buffer[0x1A]));
		ajoute(Firstwindow, text);
	}

	sector_free(buffer);
} /* informations */

/********************************************************************
*																	*
*						trace un fichier							*
*																	*
********************************************************************/
void trace_file(void)
{
	char nom[FILENAME_MAX] = "", text[FILENAME_MAX], tmp[FILENAME_MAX];
	dir_elt_vfat *file;
	int device;
	int no;

	no = selecteur(nom, NULL, Messages(INFO_63));

	for (no--; no>=0; no--)
	{
		strcpy(nom, Chemin);
		strcat(nom, FselTable[no]);

		get_max_name(nom, tmp, MAX_TITLE, FALSE);

		sprintf(text, Messages(INFO_64), tmp);
		ajoute(Firstwindow, text);

		device = toupper(nom[0])-'A';

		if (load_arbo_file(device, nom +3))
			return;

		if (load_FAT(device))
			return;

		if ((file = ManageVFAT ? find_file_vfat(nom) : find_file_short(nom)) != NULL)
		{
			int len = 6;
			unsigned int cluster, last;

			if (file -> first_cluster == 0)
			{
				ajoute(Firstwindow, Messages(INFO_65));
				return;
			}

			ajoute(Firstwindow, Messages(INFO_66));

			cluster = file -> first_cluster;
			last = cluster;
			sprintf(text, " %04X ", cluster);
			while ((cluster = FAT[device][cluster]) < 0xFFF0)
			{
				if (cluster != last+1 && len>1)	/* coupure dans la chaŒne (saut) */
				{
					text[len-1] = '/';
					ajoute(Firstwindow, text);
					len = 1;
				}

				last = cluster;
				sprintf(&text[len], "%04X ", cluster);
				len += 5;
				if (len > 70)	/* la ligne est pleine */
				{
					if ((FAT[device][cluster] < 0xFFF0) && (FAT[device][cluster]!= last+1))
						text[len-1] = '/';

					ajoute(Firstwindow, text);
					len = 1;
				}

				if (cluster == 0)
					break;
			}
			if (len > 1)
				ajoute(Firstwindow, text);
		}
	}
} /* trace_file */
