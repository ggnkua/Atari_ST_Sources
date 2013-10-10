/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>
#include <ctype.h>

#include "globals.h"
#include "zorg.h"

#include "fat.h"
#include "brut.h"
#include "dialog.h"
#include "divers.h"
#include "fenetre.h"
#include "ouvre.h"
#include "update.h"

/********************************************************************
*																	*
*					trouve des secteurs contigs					*
*																	*
********************************************************************/
unsigned int find_place(int drive, unsigned int size, unsigned int max)
{
	unsigned int *fat = FAT[drive];
	unsigned int clst, i;

	for (clst = max +1; clst >= 2; clst--)
		if (fat[clst] == 0)
		{
			for (i=0; i<size && fat[clst] == 0 && clst >= 2; clst--)
				i++;
			if (i == size)
				return clst+1;
		}
	return 0;
} /* find_place */

/********************************************************************
*																	*
*				sauvegarde la FAT et l'arborescence					*
*																	*
********************************************************************/
#ifndef TEST_VERSION
boolean save_arbo_short(int drive)
{
	BPB bpb = my_getbpb(drive);
	long *table;
	int i, d;

	if (bpb.recsiz == 0)
		return TRUE;

	if (save_FAT(drive))
		return TRUE;

	paraminfo(Messages(FAT_1), Messages(FAT_2));

	if ((table = calloc((size_t)bpb.rdlen, sizeof(long))) == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	d = bpb.fatrec + bpb.fsiz;
	for (i = 0; i < bpb.rdlen; i++)
		table[i] = d + i;
	if (save_dir_short(Arbo[drive], table, bpb.rdlen, drive))
	{
		paraminfo(NULL, NULL);	/* efface la boŒte des messages */
		free(table);
		return TRUE;
	}

	paraminfo(NULL, NULL);	/* efface la boŒte des messages */
	free(table);

	return FALSE;
} /* save_arbo_short */
#endif

/********************************************************************
*																	*
*				sauvegarde la FAT et l'arborescence (VFAT)			*
*																	*
********************************************************************/
#ifndef TEST_VERSION
boolean save_arbo_vfat(int drive)
{
	BPB bpb = my_getbpb(drive);
	long *table;
	int i, d;

	if (bpb.recsiz == 0)
		return TRUE;

	if (save_FAT(drive))
		return TRUE;

	paraminfo(Messages(FAT_1), Messages(FAT_2));

	if ((table = calloc((size_t)bpb.rdlen, sizeof(long))) == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	d = bpb.fatrec + bpb.fsiz;
	for (i = 0; i < bpb.rdlen; i++)
		table[i] = d + i;
	if (save_dir_vfat((dir_elt_vfat *)Arbo[drive], table, bpb.rdlen, drive))
	{
		paraminfo(NULL, NULL);	/* efface la boŒte des messages */
		free(table);
		return TRUE;
	}

	paraminfo(NULL, NULL);	/* efface la boŒte des messages */
	free(table);

	return FALSE;
} /* save_arbo_vfat */
#endif

/****************************************************************
*																*
*		sauve l'arborescence d'un r‚p‚rtoire et ses fils		*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean save_dir_short(dir_elt_short arbo[], long table[], long max, int drive)
{
	real_dir_elt *buffer;	/* un secteur de r‚pertoire */
	int err, i, sect = 0;
	int dirsiz = Bpb[drive].recsiz/32;

	/* un tampon de la taille d'un secteur */
	if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
		return TRUE;

	arbo++;	/* on saute le premier enregistrement qui est Info.dir */

	for (sect=0; sect<max; sect++)
	{
		for (i=0; i<dirsiz; i++)
			re_trans_dir_elt_short(&buffer[i], arbo + i + sect*dirsiz);

		if ((err = my_rwabs(1, (char *)buffer, 1, table[sect], drive)) != 0)
		{
			if (err == -14)
				change_disque(drive, TRUE);

			/* libŠre le tampon */
			sector_free(buffer);

			/* erreur */
			return TRUE;
		}
	}

	/* libŠre le tampon */
	sector_free(buffer);

	for (i=0; i<max * dirsiz; i++)
	{
		if (arbo -> attribut & FA_SUBDIR && !arbo -> norealdir && arbo -> name[0] != 0xE5 && arbo -> name[0] != 0x00)
		{
			long *table;
			long max;
			char rep[40];

			sprintf(rep, Messages(FAT_3), arbo -> name, &arbo -> name[8]);
			paraminfo(NULL, rep);	/* Sauvegarde de l'arborescence */

			max = create_table(arbo -> first_cluster, &table, drive);
			if (save_dir_short(arbo -> dir, table, max, drive))
				/* erreur */
				return TRUE;

			free(table);
		}

		arbo++;
	}

	/* Ok pas d'erreur */
	return FALSE;
} /* save_dir_short */
#endif

/****************************************************************
*																*
*	sauve l'arborescence d'un r‚p‚rtoire et ses fils (VFAT)		*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean save_dir_vfat(dir_elt_vfat arbo[], long table[], long max, int drive)
{
	real_dir_elt *buffer;	/* un secteur de r‚pertoire */
	int err, i, sect = 0;
	int dirsiz = Bpb[drive].recsiz/32;

	/* un tampon de la taille d'un secteur */
	if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
		return TRUE;

	arbo++;	/* on saute le premier enregistrement qui est Info.dir */

	for (sect=0; sect<max; sect++)
	{
		for (i=0; i<dirsiz; i++)
			re_trans_dir_elt_vfat(&buffer[i], arbo + i + sect*dirsiz);

		if ((err = my_rwabs(1, (char *)buffer, 1, table[sect], drive)) != 0)
		{
			if (err == -14)
				change_disque(drive, TRUE);

			/* libŠre le tampon */
			sector_free(buffer);

			/* erreur */
			return TRUE;
		}
	}

	/* libŠre le tampon */
	sector_free(buffer);

	for (i=0; i<max * dirsiz; i++)
	{
		if (arbo -> attribut & FA_SUBDIR && !arbo -> norealdir && arbo -> name[0] != 0xE5 && arbo -> name[0] != 0x00)
		{
			long *table;
			long max;
			char rep[40];

			sprintf(rep, Messages(FAT_3), arbo -> name, &arbo -> name[8]);
			paraminfo(NULL, rep);	/* Sauvegarde de l'arborescence */

			max = create_table(arbo -> first_cluster, &table, drive);
			if (save_dir_vfat(arbo -> dir, table, max, drive))
				/* erreur */
				return TRUE;

			free(table);
		}

		arbo++;
	}

	/* Ok pas d'erreur */
	return FALSE;
} /* save_dir_vfat */
#endif

/********************************************************************
*																	*
*				ne se sert que des infos de ZORG.INF				*
*																	*
********************************************************************/
void from_zorg_inf(boolean zorg)
{
	int x, y, drive;
	GRECT icones, r1;

	ZorgInf = zorg ? 1 : 0;

	menu_icheck(Menu, DONNEES_ZORG, ZorgInf);
	menu_icheck(Menu, DONNEES_SYSTEME, 1 - ZorgInf);

	for (drive=2; drive<MAX_DEVICES; drive++)
		change_disque(drive, TRUE);

	if (ZorgInf)
	{
		ajoute(Firstwindow, Messages(FAT_4));

		if (Bureau)
		{
			if (!Partition[Drive].bpb.recsiz)
			{
				Bureau[1 + Drive].ob_state &= ~SELECTED;
				Bureau[1].ob_state |= SELECTED;
				Drive = 0;
			}

			for (drive=2; drive<MAX_DEVICES; drive++)
				if (Partition[drive].bpb.recsiz && Partition[drive].devno >= 0)
				{
					Bureau[1+drive].ob_flags |= SELECTABLE;
					Bureau[1+drive].ob_flags &= ~HIDETREE;
				}
				else
				{
					Bureau[1+drive].ob_flags &= ~SELECTABLE;
					Bureau[1+drive].ob_flags |= HIDETREE;
				}
		}
		else
			if (!Partition[Drive].bpb.recsiz)
				Drive = 0;		
	}
	else
	{
		unsigned int active_drives = (unsigned int)Drvmap();

		ajoute(Firstwindow, Messages(FAT_5));

		if (Bureau)
		{
			if (!(active_drives & (1<<Drive)))
			{
				Bureau[1 + Drive].ob_state &= ~SELECTED;
				Bureau[1].ob_state |= SELECTED;
				Drive = 0;
			}

			for (drive=0; drive<MAX_DEVICES; drive++)
				if ((active_drives & (1<<drive)))
				{
					Bureau[1+drive].ob_flags |= SELECTABLE;
					Bureau[1+drive].ob_flags &= ~HIDETREE;
				}
				else
				{
					Bureau[1+drive].ob_flags &= ~SELECTABLE;
					Bureau[1+drive].ob_flags |= HIDETREE;
				}
		}
		else
			if (!(active_drives & (1<<Drive)))
				Drive = 0;
	}

	if (!Bureau)
		return;

	objc_offset(Bureau, 1+15, &x, &y);
	icones.g_x = 0;
	icones.g_y = y;
	icones.g_w = x + Bureau[1].ob_width;
	icones.g_h = Bureau[1].ob_height;

	wind_update(BEG_UPDATE);
	MouseOff();

	wind_set(0, WF_NEWDESK, (int)((long)Bureau >> 16), (int)((long)Bureau & 0xFFFF), 0, 0);

	wind_get(0, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	while (r1.g_w && r1.g_h)
	{
		if (rc_intersect(&icones, &r1))
		{
			form_dial(FMD_START, 0, 0, 0, 0, r1.g_x, r1.g_y, r1.g_w-1, r1.g_h-1);
			form_dial(FMD_FINISH, 0, 0, 0, 0, r1.g_x, r1.g_y, r1.g_w-1, r1.g_h-1);
		}

		wind_get(0, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}

	MouseOn();
	wind_update(END_UPDATE);
} /* from_zorg_inf */

/********************************************************************
*																	*
*					Force un changement de device					*
*																	*
********************************************************************/
void update_systeme(int drive)
{
	char text[80];

	sprintf(text, Messages(FAT_7), 'A'+drive);
	ajoute(Firstwindow, text);

	mediach(drive);

	drive_changed(drive);
} /* update_systeme */

/********************************************************************
*																	*
*						change de disque							*
*																	*
********************************************************************/
boolean change_disque(int drive, boolean verbose)
{
	char text[80];
	windowptr thewin;

	if (Bpb[drive].recsiz == 0)
	{
		if (verbose)
		{
			sprintf(text, Messages(FAT_11), drive +'A');
			ajoute(Firstwindow, text);
		}

		return FALSE;
	}

	sprintf(text, Messages(FAT_6), 'A'+drive);
	ajoute(Firstwindow, text);

	/*	referme les fenˆtres concern‚es	*/
	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
		if (thewin -> type == SECTEUR && thewin -> fonction.secteur.device == drive || thewin -> type == FICHIER && thewin -> fonction.fichier.device == drive || thewin -> type == FICHIER_FS && thewin -> fonction.fichier_fs.nom[0] == drive+'A' || thewin -> type == OCCUP && thewin -> fonction.occup.device == drive)
		{
			/* ferme la fenˆtre */
			fermer(thewin -> win -> handle);

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);
		}

	if (FAT[drive])
	{
		free(FAT[drive]);
		FAT[drive] = NULL;
	}

	if (Arbo[drive])
	{
		if (ManageVFAT)
			free_arbo_vfat((dir_elt_vfat *)Arbo[drive]);
		else
			free_arbo_short(Arbo[drive]);
		Arbo[drive] = NULL;
	}

	if (Cluster[drive])
	{
		free(Cluster[drive]);
		Cluster[drive] = NULL;
	}

	Bpb[drive].recsiz = 0;
	Bpb[drive].clsiz = 0;
	Bpb[drive].clsizb = 0;
	Bpb[drive].rdlen = 0;
	Bpb[drive].fsiz = 0;
	Bpb[drive].fatrec = 0;
	Bpb[drive].datrec = 0;
	Bpb[drive].numcl = 0;
	Bpb[drive].bflags = 0;

	/* c'est plus bon */
	/* StructureTest[drive] = FALSE; */

	/* force un changement de disque */
	mediach(drive);

	return TRUE;
} /* change_disque */

/****************************************************************
*																*
*				charge la File Allocation Table					*
*																*
****************************************************************/
boolean load_FAT(int drive)
{
	BPB bpb = my_getbpb(drive);
	int err;
	unsigned int *local_FAT;
	size_t size;

	if (bpb.recsiz == 0)
		return TRUE;

	if (FAT[drive])
		return FALSE;

	paraminfo(Messages(FAT_8), NULL);

	size = drive < 2 ? (bpb.numcl +2L) * sizeof(unsigned int) : (long)bpb.fsiz * bpb.recsiz;
	if ((FAT[drive] = malloc(size)) == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	if ((local_FAT = malloc((size_t)bpb.fsiz * bpb.recsiz)) == NULL)
	{
		free(FAT[drive]);
		FAT[drive] = NULL;

		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	if ((err = my_rwabs(0, (char *)local_FAT, bpb.fsiz, bpb.fatrec, drive)) != 0)
	{
		free(local_FAT);
		free(FAT[drive]);
		FAT[drive] = NULL;

		if (err == -14)
			change_disque(drive, TRUE);
		return TRUE;
	}

	if (drive < 2)
		swap_flopy_FAT(FAT[drive], local_FAT, bpb.numcl +2);
	else
		swap_FAT(FAT[drive], local_FAT, (bpb.recsiz/512) * bpb.fsiz);

	free(local_FAT);

	paraminfo(NULL, NULL);	/* efface la boŒte des messages */
	return FALSE;
} /* load_FAT */

/****************************************************************
*																*
*				sauve la File Allocation Table					*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean save_FAT(int drive)
{
	BPB bpb = my_getbpb(drive);
	int err1, err2 = 0;
	unsigned int *local_FAT;

	if (bpb.recsiz == 0)
		return TRUE;

	if (!FAT[drive])
		return FALSE;

	paraminfo(Messages(FAT_9), NULL);

	if ((local_FAT = calloc((size_t)bpb.fsiz, (size_t)bpb.recsiz)) == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	if (drive < 2)
		re_swap_flopy_FAT(local_FAT, FAT[drive], bpb.numcl +2);
	else
		swap_FAT(local_FAT, FAT[drive], (bpb.recsiz/512) * bpb.fsiz);

	if ((err1 = my_rwabs(1, (char *)local_FAT, bpb.fsiz, 1L, drive)) == 0)
		err2 = my_rwabs(1, (char *)local_FAT, bpb.fsiz, (long)bpb.fatrec, drive);

	free(local_FAT);

	paraminfo(NULL, NULL);	/* efface la boŒte des messages */

	if (err1 || err2)
	{
		if (err1 == -14 || err2 == -14)
			change_disque(drive, TRUE);
		return TRUE;
	}

	return FALSE;
} /* save_FAT */
#endif

/****************************************************************
*																*
*			rend la liste des secteurs d'un fichier				*
*																*
****************************************************************/
long create_file_table(char nom[], long *(table[]), long *size)
{
	dir_elt_vfat *file;

	if (nom[1] != ':')
		return 0;

	if (load_arbo_file(toupper(nom[0])-'A', nom+3))
		return 0;

	file = ManageVFAT ? find_file_vfat(nom) : find_file_short(nom);
	if (file == NULL)
		return 0;

	*size = file -> size;
	return create_table((int)file -> first_cluster, table, toupper(nom[0])-'A');
} /* create_file_table */

/****************************************************************
*																*
*				renvoie le descriptif du fichier				*
*																*
****************************************************************/
dir_elt_short *find_file_short(char *name)
{
	int i, j, size;
	boolean last = FALSE;
	dir_elt_short *courant = Arbo[toupper(name[0])-'A'];
	char c, nom[8+3+1];	/* nom du r‚pertoire sans . et avec espaces */

	name += 3;		/* saute A:\ */

	if (name[0] == '\0')	/* pas de nom donc directory racine, impossible */
		return NULL;

	while (!last)
	{
		size = (int)courant -> size;
		courant++;	/* saute le premier fichier qui contient des infos ZORG */

		/* forme le nom sous forme 8+3 avec les blancs */
		strcpy(nom, "           ");	/* 11 blancs */
		for (i=0 ; ; i++)
		{
			c = *name++;

			if (c == '.')
			{
				i = 7;
				continue;
			}

			if (c == '\\')
				break;

			if (c == '\0')
			{
				last = TRUE;
				break;
			}

			nom[i] = c;
		}

		if (i == 0)		/* pas de nom de fichier donc directory . */
			nom[0] = '.';

		for (j=0 ;j<size && strncmp(nom, courant -> name, 8+3); j++, courant++)
			;
		if (j == size)	/* on fait tout le r‚pertoire */
			return NULL;

		if (!last)
			if (courant -> dir == NULL)
				return NULL;
			else
				courant = courant -> dir;
	}
	return courant;
} /* find_file_short */

/****************************************************************
*																*
*				renvoie le descriptif du fichier (VFAT)			*
*																*
****************************************************************/
dir_elt_vfat *find_file_vfat(char *name)
{
	int i, j, size;
	boolean last = FALSE;
	dir_elt_vfat *courant = (dir_elt_vfat *)Arbo[toupper(name[0])-'A'];
	char c, nom[8+3+1];	/* nom du r‚pertoire sans . et avec espaces */

	name += 3;		/* saute A:\ */

	if (name[0] == '\0')	/* pas de nom donc directory racine, impossible */
		return NULL;

	while (!last)
	{
		size = (int)courant -> size;
		courant++;	/* saute le premier fichier qui contient des infos ZORG */

		/* forme le nom sous forme 8+3 avec les blancs */
		strcpy(nom, "           ");	/* 11 blancs */
		for (i=0 ; ; i++)
		{
			c = *name++;

			if (c == '.')
			{
				i = 7;
				continue;
			}

			if (c == '\\')
				break;

			if (c == '\0')
			{
				last = TRUE;
				break;
			}

			nom[i] = c;
		}

		if (i == 0)		/* pas de nom de fichier donc directory . */
			nom[0] = '.';

		for (j=0 ;j<size && strncmp(nom, courant -> name, 8+3); j++, courant++)
			;
		if (j == size)	/* on fait tout le r‚pertoire */
			return NULL;

		if (!last)
			if (courant -> dir == NULL)
				return NULL;
			else
				courant = courant -> dir;
	}
	return courant;
} /* find_file */

/****************************************************************
*																*
*			cr‚e la liste des secteurs d'un fichier				*
*																*
****************************************************************/
long create_table(unsigned int first_cluster, long *(table[]), int drive)
{
	BPB bpb = Bpb[drive];
	int clsiz = bpb.clsiz, datrec = bpb.datrec, i;
	unsigned int cluster;
	long *table_bis, nb_sect = clsiz;

	if (bpb.recsiz == 0)
		return TRUE;

	if (load_FAT(drive))
		return 0;

	cluster = first_cluster;
	if (cluster == 0)
		return 0;
	while ((cluster = FAT[drive][cluster]) < 0xFFF0)
		nb_sect += clsiz;

	*table = calloc(nb_sect, sizeof(long));
	table_bis = *table;
	if (table_bis == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return 0;
	}

	nb_sect = 0;
	cluster = first_cluster;
	do
	{
		for (i=0; i<clsiz; i++)
			table_bis[nb_sect++] = (cluster-2) * clsiz + datrec + i;
	} while ((cluster = FAT[drive][cluster]) < 0xFFF0);

	return nb_sect;
} /* create_table */

/****************************************************************
*																*
*			charge l'arborescence pour UN fichier				*
*																*
****************************************************************/
boolean load_arbo_file(int drive, char *filename)
{
	BPB bpb = my_getbpb(drive);
	long *table;
	int i, d;

	if (bpb.recsiz == 0)
		return TRUE;

	if (load_FAT(drive))
		return TRUE;

	/* d‚j… charg‚e en entier ? */
	if (Arbo[drive] && Arbo[drive] -> time)
		return FALSE;

	if ((table = calloc((size_t)bpb.rdlen, sizeof(long))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	d = bpb.fatrec + bpb.fsiz;
	for (i = 0; i < bpb.rdlen; i++)
		table[i] = d + i;
	if (ManageVFAT ? load_dir_file_vfat((dir_elt_vfat **)&(Arbo[drive]), table, bpb.rdlen, drive, 0, filename) : load_dir_file_short(&(Arbo[drive]), table, bpb.rdlen, drive, 0, filename))
	{
		free(table);
		if (ManageVFAT)
			free_arbo_vfat((dir_elt_vfat *)Arbo[drive]);
		else
			free_arbo_short(Arbo[drive]);
		Arbo[drive] = NULL;
		return TRUE;
	}

	free(table);

	return FALSE;
} /* load_arbo_file */

/****************************************************************
*																*
*			charge l'arborescence pour UN fichier				*
*																*
****************************************************************/
boolean load_dir_file_short(dir_elt_short *(arbo[]), long table[], long max, int drive, unsigned int first_cluster, char *filename)
{
	real_dir_elt *buffer;
	dir_elt_short *local_arbo;
	int err, i, sect = 0;
	int dirsiz = Bpb[drive].recsiz/32;
	char nom[8+3+1], c;

	/* le r‚pertoire n'a pas encore ‚t‚ charg‚ */
	if (*arbo == NULL)
	{
		*arbo = calloc(max * dirsiz + 1L, sizeof(dir_elt_short));
		local_arbo = *arbo;
		if (local_arbo == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
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
		local_arbo -> size = (long)max * dirsiz; /* nombre d'entr‚es dans le r‚pertoire */
		local_arbo -> dir = NULL;
		local_arbo++;

		if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
			return TRUE;

		for (sect=0; sect<max; sect++)
		{
			if ((err = my_rwabs(0, (char *)buffer, 1, table[sect], drive)) != 0)
			{
				free(*arbo);
				*arbo = NULL;

				if (err == -14)
					change_disque(drive, TRUE);

				sector_free(buffer);

				return TRUE;
			}

			for (i=0; i<dirsiz; i++)
				trans_dir_elt_short(local_arbo + i + sect*dirsiz, &buffer[i]);
		}

		sector_free(buffer);

		if (first_cluster)
		{
			local_arbo -> norealdir = TRUE;	/* marque '.' et '..' */
			(local_arbo + 1) -> norealdir = TRUE;
		}
	}
	else
		local_arbo = (*arbo)+1;

	/* forme le nom sous forme 8+3 avec les blancs */
	strcpy(nom, "           ");	/* 11 blancs */
	for (i=0 ; ; i++)
	{
		c = *filename++;

		if (c == '.')
		{
			i = 7;
			continue;
		}

		if (c == '\\')
			break;

		/* le fichier est dans ce dossier */
		if (c == '\0')
			return FALSE;

		nom[i] = c;
	}

	if (i == 0)		/* pas de nom de fichier donc directory . */
		nom[0] = '.';

	for (i=0; i<max * dirsiz; i++)
	{
		if (strncmp(nom, local_arbo -> name, 8+3) == 0)
		{
			if (local_arbo -> attribut & FA_SUBDIR && !local_arbo -> norealdir && local_arbo -> name[0] != 0xE5 && local_arbo -> name[0] != 0x00)
			{
				long *table;
				long max;

				max = create_table(local_arbo -> first_cluster, &table, drive);
				if (load_dir_file_short(&local_arbo -> dir, table, max, drive, local_arbo -> first_cluster, filename))
					return TRUE;

				local_arbo -> dir[1].dir = local_arbo -> dir; /* r‚pertoire . */
				local_arbo -> dir[2].dir = local_arbo;	/* r‚petoire .. */
				free(table);
			}

			/* on a trouv‚ */
			break;
		}

		local_arbo++;
	}

	return FALSE;
} /* load_dir_file_short */

/****************************************************************
*																*
*			charge l'arborescence pour UN fichier (VFAT)		*
*																*
****************************************************************/
boolean load_dir_file_vfat(dir_elt_vfat *(arbo[]), long table[], long max, int drive, unsigned int first_cluster, char *filename)
{
	real_dir_elt *buffer;
	dir_elt_vfat *local_arbo;
	int err, i, sect = 0;
	int dirsiz = Bpb[drive].recsiz/32;
	char nom[8+3+1], c;

	/* le r‚pertoire n'a pas encore ‚t‚ charg‚ */
	if (*arbo == NULL)
	{
		*arbo = calloc(max * dirsiz + 1L, sizeof(dir_elt_vfat));
		local_arbo = *arbo;
		if (local_arbo == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
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
		local_arbo -> size = (long)max * dirsiz; /* nombre d'entr‚es dans le r‚pertoire */
		local_arbo -> dir = NULL;
		local_arbo++;

		if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
			return TRUE;

		for (sect=0; sect<max; sect++)
		{
			if ((err = my_rwabs(0, (char *)buffer, 1, table[sect], drive)) != 0)
			{
				free(*arbo);
				*arbo = NULL;

				if (err == -14)
					change_disque(drive, TRUE);

				sector_free(buffer);

				return TRUE;
			}

			for (i=0; i<dirsiz; i++)
				trans_dir_elt_vfat(local_arbo + i + sect*dirsiz, &buffer[i]);
		}

		sector_free(buffer);

		if (first_cluster)
		{
			local_arbo -> norealdir = TRUE;	/* marque '.' et '..' */
			(local_arbo + 1) -> norealdir = TRUE;
		}
	}
	else
		local_arbo = (*arbo)+1;

	/* forme le nom sous forme 8+3 avec les blancs */
	strcpy(nom, "           ");	/* 11 blancs */
	for (i=0 ; ; i++)
	{
		c = *filename++;

		if (c == '.')
		{
			i = 7;
			continue;
		}

		if (c == '\\')
			break;

		/* le fichier est dans ce dossier */
		if (c == '\0')
			return FALSE;

		nom[i] = c;
	}

	if (i == 0)		/* pas de nom de fichier donc directory . */
		nom[0] = '.';

	for (i=0; i<max * dirsiz; i++)
	{
		if (strncmp(nom, local_arbo -> name, 8+3) == 0)
		{
			if (local_arbo -> attribut & FA_SUBDIR && !local_arbo -> norealdir && local_arbo -> name[0] != 0xE5 && local_arbo -> name[0] != 0x00)
			{
				long *table;
				long max;

				max = create_table(local_arbo -> first_cluster, &table, drive);
				if (load_dir_file_vfat(&local_arbo -> dir, table, max, drive, local_arbo -> first_cluster, filename))
					return TRUE;

				local_arbo -> dir[1].dir = local_arbo -> dir; /* r‚pertoire . */
				local_arbo -> dir[2].dir = local_arbo;	/* r‚petoire .. */
				free(table);
			}

			/* on a trouv‚ */
			break;
		}

		local_arbo++;
	}

	return FALSE;
} /* load_dir_file */

/****************************************************************
*																*
*				charge l'arborescence d'un disque				*
*																*
****************************************************************/
boolean load_arbo(int drive)
{
	BPB bpb = my_getbpb(drive);
	long *table;
	int i, d;

	if (bpb.recsiz == 0)
		return TRUE;

	if (load_FAT(drive))
		return TRUE;

	/* d‚j… charg‚e en entier ? */
	if (Arbo[drive] && Arbo[drive] -> time)
		return FALSE;

	paraminfo(Messages(FAT_10), Messages(FAT_2));

	if ((table = calloc((size_t)bpb.rdlen, sizeof(long))) == NULL)
	{
		paraminfo(NULL, NULL);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	d = bpb.fatrec + bpb.fsiz;
	for (i = 0; i < bpb.rdlen; i++)
		table[i] = d + i;
	if (ManageVFAT)
	{
		if (load_dir_vfat((dir_elt_vfat **)&(Arbo[drive]), table, bpb.rdlen, drive, 0))
		{
			paraminfo(NULL, NULL);	/* efface la boŒte des messages */
			free(table);
			free_arbo_vfat((dir_elt_vfat *)Arbo[drive]);
			Arbo[drive] = NULL;
			return TRUE;
		}
	}
	else
	{
		if (load_dir_short(&(Arbo[drive]), table, bpb.rdlen, drive, 0))
		{
			paraminfo(NULL, NULL);	/* efface la boŒte des messages */
			free(table);
			free_arbo_short(Arbo[drive]);
			Arbo[drive] = NULL;
			return TRUE;
		}
	}

	paraminfo(NULL, NULL);	/* efface la boŒte des messages */
	free(table);

	/* l'arborescence est charg‚e en entier */
	Arbo[drive] -> time = TRUE;

	return FALSE;
} /* load_arbo */

/****************************************************************
*																*
*		charge l'arborescence d'un r‚p‚rtoire et ses fils		*
*																*
****************************************************************/
boolean load_dir_short(dir_elt_short *(arbo[]), long table[], long max, int drive, unsigned int first_cluster)
{
	real_dir_elt *buffer;
	dir_elt_short *local_arbo;
	int err, i, sect = 0;
	int dirsiz = Bpb[drive].recsiz/32;

	/* le r‚pertoire n'a pas encore ‚t‚ charg‚ */
	if (*arbo == NULL)
	{
		*arbo = calloc(max * dirsiz + 1L, sizeof(dir_elt_short));
		local_arbo = *arbo;
		if (local_arbo == NULL)
		{
			paraminfo(NULL, NULL);
			error_msg(Z_NOT_ENOUGH_MEMORY);
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
		local_arbo -> size = (long)max * dirsiz; /* nombre d'entr‚es dans le r‚pertoire */
		local_arbo -> dir = NULL;
		local_arbo++;

		if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
			return TRUE;

		for (sect=0; sect<max; sect++)
		{
			if ((err = my_rwabs(0, (char *)buffer, 1, table[sect], drive)) != 0)
			{
				free(*arbo);
				*arbo = NULL;

				if (err == -14)
					change_disque(drive, TRUE);

				sector_free(buffer);

				return TRUE;
			}

			for (i=0; i<dirsiz; i++)
				trans_dir_elt_short(local_arbo + i + sect*dirsiz, &buffer[i]);
		}

		sector_free(buffer);

		if (first_cluster)
		{
			local_arbo -> norealdir = TRUE;	/* marque '.' et '..' */
			(local_arbo + 1) -> norealdir = TRUE;
		}
	}
	else
		local_arbo = (*arbo)+1;

	for (i=0; i<max * dirsiz; i++)
	{
		if (local_arbo -> attribut & FA_SUBDIR && !local_arbo -> norealdir && local_arbo -> name[0] != 0xE5 && local_arbo -> name[0] != 0x00)
		{
			long *table;
			long max;
			char rep[40];

			sprintf(rep, Messages(FAT_3), local_arbo -> name, &local_arbo -> name[8]);
			paraminfo(NULL, rep);	/* Chargement de l'arborescence */

			max = create_table(local_arbo -> first_cluster, &table, drive);
			if (load_dir_short(&local_arbo -> dir, table, max, drive, local_arbo -> first_cluster))
				return TRUE;

			local_arbo -> dir[1].dir = local_arbo -> dir; /* r‚pertoire . */
			local_arbo -> dir[2].dir = local_arbo;	/* r‚petoire .. */
			free(table);
		}

		local_arbo++;
	}

	return FALSE;
} /* load_dir_short */

/****************************************************************
*																*
*	charge l'arborescence d'un r‚p‚rtoire et ses fils (VFAT)	*
*																*
****************************************************************/
boolean load_dir_vfat(dir_elt_vfat *(arbo[]), long table[], long max, int drive, unsigned int first_cluster)
{
	real_dir_elt *buffer;
	dir_elt_vfat *local_arbo;
	int err, i, sect = 0;
	int dirsiz = Bpb[drive].recsiz/32;

	/* le r‚pertoire n'a pas encore ‚t‚ charg‚ */
	if (*arbo == NULL)
	{
		*arbo = calloc(max * dirsiz + 1L, sizeof(dir_elt_vfat));
		local_arbo = *arbo;
		if (local_arbo == NULL)
		{
			paraminfo(NULL, NULL);
			error_msg(Z_NOT_ENOUGH_MEMORY);
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
		local_arbo -> size = (long)max * dirsiz; /* nombre d'entr‚es dans le r‚pertoire */
		local_arbo -> dir = NULL;
		local_arbo++;

		if ((buffer = sector_alloc(Bpb[drive].recsiz)) == NULL)
			return TRUE;

		for (sect=0; sect<max; sect++)
		{
			if ((err = my_rwabs(0, (char *)buffer, 1, table[sect], drive)) != 0)
			{
				free(*arbo);
				*arbo = NULL;

				if (err == -14)
					change_disque(drive, TRUE);

				sector_free(buffer);

				return TRUE;
			}

			for (i=0; i<dirsiz; i++)
				trans_dir_elt_vfat(local_arbo + i + sect*dirsiz, &buffer[i]);
		}

		sector_free(buffer);

		if (first_cluster)
		{
			local_arbo -> norealdir = TRUE;	/* marque '.' et '..' */
			(local_arbo + 1) -> norealdir = TRUE;
		}
	}
	else
		local_arbo = (*arbo)+1;

	for (i=0; i<max * dirsiz; i++)
	{
		if (local_arbo -> attribut & FA_SUBDIR && !local_arbo -> norealdir && local_arbo -> name[0] != 0xE5 && local_arbo -> name[0] != 0x00)
		{
			long *table;
			long max;
			char rep[40];

			sprintf(rep, Messages(FAT_3), local_arbo -> name, &local_arbo -> name[8]);
			paraminfo(NULL, rep);	/* Chargement de l'arborescence */

			max = create_table(local_arbo -> first_cluster, &table, drive);
			if (load_dir_vfat(&local_arbo -> dir, table, max, drive, local_arbo -> first_cluster))
				return TRUE;

			local_arbo -> dir[1].dir = local_arbo -> dir; /* r‚pertoire . */
			local_arbo -> dir[2].dir = local_arbo;	/* r‚petoire .. */
			free(table);
		}

		local_arbo++;
	}

	return FALSE;
} /* load_dir */

/****************************************************************
*																*
*				efface l'arborescence d'un disque				*
*																*
****************************************************************/
void free_arbo_short(dir_elt_short *dir)
{
	int i, size;

	if (dir == NULL)
		return;

	size = (int)dir[0].size;

	dir++;	/* saute le premier enregistrement */

	for (i=0; i<size; i++)
		if (dir[i].attribut & FA_SUBDIR && !dir[i].norealdir && dir[i].name[0] != 0xE5 && dir[i].name[0] != 0x00)
			free_arbo_short(dir[i].dir);

	free(dir - 1);
} /* free_arbo_short */

/****************************************************************
*																*
*				efface l'arborescence d'un disque (VFAT)		*
*																*
****************************************************************/
void free_arbo_vfat(dir_elt_vfat *dir)
{
	int i, size;

	if (dir == NULL)
		return;

	size = (int)dir[0].size;

	dir++;	/* saute le premier enregistrement */

	for (i=0; i<size; i++)
		if (dir[i].attribut & FA_SUBDIR && !dir[i].norealdir && dir[i].name[0] != 0xE5 && dir[i].name[0] != 0x00)
			free_arbo_vfat(dir[i].dir);

	free(dir - 1);
} /* free_arbo_vfat */

/********************************************************************
*																	*
*						ma fonction Getbp							*
*																	*
********************************************************************/
BPB my_getbpb(int drive)
{
	BPB *bpb;

	/* le device a ‚t‚ chang‚ ? */
	if (Mediach(drive))
		mediach(drive);

	if (Bpb[drive].recsiz == 0)
	{
		if (ZorgInf && drive > 1)	/* partition */
			Bpb[drive] = Partition[drive].bpb;
		else
		{
			bpb = Getbpb(drive);
			mediach(drive);
			if (bpb)
				Bpb[drive] = *bpb;
			else
			{
				change_disque(drive, TRUE);
				error_msg(Z_NO_BPB);
			}
		}
	}
	return Bpb[drive];
} /* my_getbpb */

/****************************************************************
*																*
*		cr‚e la table de correspondance fichier/cluster 		*
*																*
****************************************************************/
void create_map_short(dir_elt_short *dir, dir_elt_short *cluster[], unsigned int fat[])
{
	int i, size = (int)dir[0].size;
	unsigned int clst;

	dir++;	/* saute le premier enregistrement */

	for (i=0; i<size; i++)
	{
		if (dir[i].norealdir || dir[i].name[0] == 0xE5 || dir[i].name[0] == 0x00 || dir[i].attribut & FA_VOLUME)
			continue;

		clst = dir[i].first_cluster;

		if (clst == 0)
			continue;

		cluster[clst] = &dir[i];
		while ((clst = fat[clst]) < 0xFFF0)
			cluster[clst] = &dir[i];

		if (dir[i].attribut & FA_SUBDIR)
			create_map_short(dir[i].dir, cluster, fat);
	}
} /* create_map_short */

/****************************************************************
*																*
*	cr‚e la table de correspondance fichier/cluster (VFAT)		*
*																*
****************************************************************/
void create_map_vfat(dir_elt_vfat *dir, dir_elt_vfat *cluster[], unsigned int fat[])
{
	int i, size = (int)dir[0].size;
	unsigned int clst;

	dir++;	/* saute le premier enregistrement */

	for (i=0; i<size; i++)
	{
		if (dir[i].norealdir || dir[i].name[0] == 0xE5 || dir[i].name[0] == 0x00 || dir[i].attribut & FA_VOLUME)
			continue;

		clst = dir[i].first_cluster;

		if (clst == 0)
			continue;

		cluster[clst] = &dir[i];
		while ((clst = fat[clst]) < 0xFFF0)
			cluster[clst] = &dir[i];

		if (dir[i].attribut & FA_SUBDIR)
			create_map_vfat(dir[i].dir, cluster, fat);
	}
} /* create_map_vfat */
