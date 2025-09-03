/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#define MINSIZEBUFCLEAR 128*512L	/* taille du buffer d'effacage des clusters libres */
#define MINSIZEBUFMOVE 256*512L		/* taille minimale du buffer de d‚placement (128 ko) */

#include <e_gem.h>
#include <string.h>

#include "globals.h"
#include "zorg.h"

#include "reorg.h"
#include "brut.h"
#include "dialog.h"
#include "fat.h"
#include "fenetre.h"
#include "ouvre.h"
#include "update.h"

/********************************************************************
*																	*
*						Nettoie les r‚pertoires						*
*																	*
********************************************************************/
#ifndef TEST_VERSION
void nettoie_repertoire(int drive)
{
	windowptr thewin;
	char text[80];

	if ((StructureTest[drive] != TRUE) || load_arbo(drive))
	{
		char text[160];

		sprintf(text, Messages(REORG_9), drive +'A');
		my_alert(1, FAIL, X_ICN_STOP, text, NULL);
		return;
	}

	/*	referme les fenˆtres concern‚es	*/
	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
		if ((thewin -> type == SECTEUR || thewin -> type == FICHIER) && thewin -> fonction.fichier.device == drive || thewin -> type == FICHIER_FS && thewin -> fonction.fichier_fs.nom[0] == drive+'A' || thewin -> type == OCCUP && thewin -> fonction.occup.device == drive)
		{
			/* ferme la fenˆtre */
			fermer(thewin -> win -> handle);

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);
		}

	sprintf(text, Messages(REORG_18), drive +'A');
	ajoute(Firstwindow, text);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	if (ManageVFAT ? nettoie_dir_vfat(((dir_elt_vfat *)Arbo[drive])+1, (int)Arbo[drive][0].size) : nettoie_dir_short(Arbo[drive]+1, (int)Arbo[drive][0].size))
		return;

	if (ManageVFAT)
		save_arbo_vfat(drive);
	else
		save_arbo_short(drive);

	/* la structure est OK */
	StructureTest[drive] = TRUE;

	/* force un changement de disque */
	update_systeme(drive);

	if (Cluster[drive])
	{
		free(Cluster[drive]);
		Cluster[drive] = NULL;
	}
} /* nettoie_repertoire */
#endif

/****************************************************************
*																*
*				Nettoie les entr‚es du r‚pertoire				*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean nettoie_dir_short(dir_elt_short arbo[], int max)
{
	int file, max2;
	boolean ko = TRUE;
	dir_elt_short tmp_dir_elt;

	/* nombre d'entr‚es -1 */
	for (max2=max-1; max2>0; max2--)
		if (arbo[max2].name[0] != '\0' && arbo[max2].name[0] != 0xE5)
			break;

	/* il y a 0 ou 1 entr‚e, pas triable */
	if (max2 < 1)
		return FALSE;

	/* d‚gage les entr‚es effac‚es ou vides */
	for (file=max2-1; file>=0; file--)
		if (arbo[file].name[0] == 0xE5 || arbo[file].name[0] == '\0')
		{
			/* swap */
			tmp_dir_elt = arbo[file];
			arbo[file] = arbo[max2];
			arbo[max2] = tmp_dir_elt;

			/* on a d‚plac‚ un sous-r‚pertoire */
			if (arbo[file].attribut & FA_SUBDIR)
				arbo[file].dir[2].dir = &arbo[file];

			/* un fichier en moins a traiter */
			max2--;
		}

	/* trie les entr‚es du r‚pertoire */
	while (ko)
	{
		ko = FALSE; /* il n'y a pas de changements */

		for (file=0; file<max2; file++)
		{
			/* l'entr‚e suivante est un r‚pertoire */
			if (arbo[file+1].attribut & FA_SUBDIR)
			{
				/* l'entr‚e courante aussi */
				if (arbo[file].attribut & FA_SUBDIR)
				{
					if (strncmp(arbo[file].name, arbo[file+1].name, 8+3) > 0)
					{
						/* swap les deux entr‚es */
						tmp_dir_elt = arbo[file];
						arbo[file] = arbo[file+1];
						arbo[file+1] = tmp_dir_elt;
	
						/* met … jour le lien .. */
						arbo[file].dir[2].dir = &arbo[file];
						arbo[file+1].dir[2].dir = &arbo[file+1];
	
						/* encore un tour */
						ko = TRUE;
					}
					else
						/* deux r‚pertoires d‚ja dans l'ordre */
						continue;
				}
				/* une entr‚e normale suivie d'un r‚pertoire */
				else
				{
					/* swap les deux entr‚es */
					tmp_dir_elt = arbo[file];
					arbo[file] = arbo[file+1];
					arbo[file+1] = tmp_dir_elt;

					/* met … jour le lien .. */
					arbo[file].dir[2].dir = &arbo[file];

					/* encore un tour */
					ko = TRUE;
				}
			}

			/* la suivante n'est pas un r‚pertoire */
			if (arbo[file].attribut & FA_SUBDIR)
				continue;

			/* deux entr‚es de fichiers */
			if (strncmp(arbo[file].name, arbo[file+1].name, 8+3) > 0)
			{
				/* swap les deux entr‚es */
				tmp_dir_elt = arbo[file];
				arbo[file] = arbo[file+1];
				arbo[file+1] = tmp_dir_elt;

				/* encore un tour */
				ko = TRUE;
			}
		}
	}

	/* recherche r‚cursive */
	for (file=0; file<max2; file++, arbo++)
	{
		if (arbo -> name[0] == 0xE5 || arbo -> name[0] == 0x00 || arbo -> first_cluster == 0 || arbo -> norealdir)
			continue;

		if (arbo -> attribut & FA_SUBDIR)
			if (nettoie_dir_short(arbo -> dir +3, (int)arbo -> dir -> size -2))
				return TRUE;
	}

	return FALSE;
} /* nettoire_dir_short */
#endif

/****************************************************************
*																*
*				Nettoie les entr‚es du r‚pertoire (VFAT)		*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean nettoie_dir_vfat(dir_elt_vfat arbo[], int max)
{
	int file, max2;
	boolean ko = TRUE;
	dir_elt_vfat tmp_dir_elt;

	/* nombre d'entr‚es -1 */
	for (max2=max-1; max2>0; max2--)
		if (arbo[max2].name[0] != '\0' && arbo[max2].name[0] != 0xE5)
			break;

	/* il y a 0 ou 1 entr‚e, pas triable */
	if (max2 < 1)
		return FALSE;

	/* d‚gage les entr‚es effac‚es ou vides */
	for (file=max2-1; file>=0; file--)
		if (arbo[file].name[0] == 0xE5 || arbo[file].name[0] == '\0')
		{
			/* swap */
			tmp_dir_elt = arbo[file];
			arbo[file] = arbo[max2];
			arbo[max2] = tmp_dir_elt;

			/* on a d‚plac‚ un sous-r‚pertoire */
			if (arbo[file].attribut & FA_SUBDIR)
				arbo[file].dir[2].dir = &arbo[file];

			/* un fichier en moins a traiter */
			max2--;
		}

	/* trie les entr‚es du r‚pertoire */
	while (ko)
	{
		ko = FALSE; /* il n'y a pas de changements */

		for (file=0; file<max2; file++)
		{
			/* l'entr‚e suivante est un r‚pertoire */
			if (arbo[file+1].attribut & FA_SUBDIR)
			{
				/* l'entr‚e courante aussi */
				if (arbo[file].attribut & FA_SUBDIR)
				{
					if (strncmp(arbo[file].name, arbo[file+1].name, 8+3) > 0)
					{
						/* swap les deux entr‚es */
						tmp_dir_elt = arbo[file];
						arbo[file] = arbo[file+1];
						arbo[file+1] = tmp_dir_elt;
	
						/* met … jour le lien .. */
						arbo[file].dir[2].dir = &arbo[file];
						arbo[file+1].dir[2].dir = &arbo[file+1];
	
						/* encore un tour */
						ko = TRUE;
					}
					else
						/* deux r‚pertoires d‚ja dans l'ordre */
						continue;
				}
				/* une entr‚e normale suivie d'un r‚pertoire */
				else
				{
					/* swap les deux entr‚es */
					tmp_dir_elt = arbo[file];
					arbo[file] = arbo[file+1];
					arbo[file+1] = tmp_dir_elt;

					/* met … jour le lien .. */
					arbo[file].dir[2].dir = &arbo[file];

					/* encore un tour */
					ko = TRUE;
				}
			}

			/* la suivante n'est pas un r‚pertoire */
			if (arbo[file].attribut & FA_SUBDIR)
				continue;

			/* deux entr‚es de fichiers */
			if (strncmp(arbo[file].name, arbo[file+1].name, 8+3) > 0)
			{
				/* swap les deux entr‚es */
				tmp_dir_elt = arbo[file];
				arbo[file] = arbo[file+1];
				arbo[file+1] = tmp_dir_elt;

				/* encore un tour */
				ko = TRUE;
			}
		}
	}

	/* recherche r‚cursive */
	for (file=0; file<max2; file++, arbo++)
	{
		if (arbo -> name[0] == 0xE5 || arbo -> name[0] == 0x00 || arbo -> first_cluster == 0 || arbo -> norealdir)
			continue;

		if (arbo -> attribut & FA_SUBDIR)
			if (nettoie_dir_vfat(arbo -> dir +3, (int)arbo -> dir -> size -2))
				return TRUE;
	}

	return FALSE;
} /* nettoire_dir_vfat */
#endif

/********************************************************************
*																	*
*			Copie le tampon dans les clusters inoccup‚s				*
*																	*
********************************************************************/
void nettoie_clusters_libres(int drive)
{
	OBJECT *wait = Dialog[WAIT].tree;
	int width, button, dummy;
	char *buffer, *secteur_text;
	BPB bpb;
	unsigned int *fat, cluster, max, len, buffer_size_clst;
	unsigned int cur_clst, max_clst, i;
	long buffer_size, l;
	char text[80];

	sprintf(text, Messages(REORG_1), drive +'A');
	ajoute(Firstwindow, text);

	buffer_size = (long)Malloc(-1L)/2;

	/* limite le buffer … 16 Mo */
	if (buffer_size > 32767*512L)
		buffer_size = 32767*512L;

	buffer_size = ((long)((buffer_size-100*1024L) / (128*512L)))*128*512L;
	if ((buffer_size < MINSIZEBUFCLEAR) || ((buffer = malloc(buffer_size)) == NULL))
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return;
	}

	for (l=0; l<buffer_size/512L; l++)
		memcpy(buffer + l*512L, Tampon -> fonction.secteur.secteurBin, 512L);

	if (load_FAT(drive))
		return;

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	fat = FAT[drive];

	bpb = my_getbpb(drive);
	max = bpb.numcl;

	/* calcul du nombre de clusters … effacer */
	max_clst = cur_clst = 0;
	for (i=2; i<bpb.numcl; i++)
		if (fat[i] == 0)
			max_clst++;

	/* nombre de clusters trait‚s … chaque fois */
	buffer_size_clst = (int)(buffer_size / (bpb.recsiz * bpb.clsiz));

	wait[WAIT_MESSAGE].ob_spec.free_string = Messages(REORG_2);
	wait[WAIT_INFO].ob_spec.tedinfo -> te_ptext = Messages(REORG_14);

	width = wait[SLIDE_PERE].ob_width -3;
	wait[SLIDE_FILS].ob_width = 3;

	secteur_text = wait[INDICATEUR_WAIT].ob_spec.tedinfo -> te_ptext;
	strcpy(secteur_text, "0");
	sprintf(wait[MAX_WAIT].ob_spec.free_string, "/%d", max_clst);

	my_open_dialog(&Dialog[WAIT], AUTO_DIAL|NO_ICONIFY|MODAL, FAIL);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	cluster = 2;
	max += 2;	/* de 2 … max+2 */
	while (cluster < max)
	{
		if (evnt_multi(MU_TIMER | MU_BUTTON,
		 256+1, 3, 0,	/* button */
		 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* mouse */
		 NULL,	/* message */
		 1, 0,	/* timer */
		 &dummy, &dummy, &button, &dummy, &dummy, &dummy) == MU_BUTTON
		 && my_alert(1, 2, X_ICN_QUESTION, Messages(REORG_3), Messages(BOOT_32)) == 0)
			break;

		/* saute les blocs occup‚s */
		while (fat[cluster] && cluster < max)
			cluster++;

		sprintf(secteur_text, "%d", cur_clst);
		ob_draw(Dialog[WAIT].info, INDICATEUR_WAIT);
		wait[SLIDE_FILS].ob_width = (int)((long)width * cur_clst / max_clst) +3;
		ob_draw(Dialog[WAIT].info, SLIDE_FILS);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);

		/* mesure le bloc libre */
		len = 0;
		while (fat[cluster+len] == 0 && cluster+len < max && len+1 <= buffer_size_clst)
			len++;

		/* ‚criture */
		if (len && my_rwabs(1, buffer, len*bpb.clsiz, (long)((cluster-2) * bpb.clsiz + bpb.datrec), drive))
			break;

		cluster += len;
		cur_clst += len;
	}
	wait[SLIDE_FILS].ob_width = width +3;
	ob_draw(Dialog[WAIT].info, SLIDE_FILS);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	free(buffer);

	my_close_dialog(&Dialog[WAIT]);
} /* nettoie_clusters_libres */

/********************************************************************
*																	*
*				Inscrit les fichiers de fa‡on contige				*
*																	*
********************************************************************/
#ifndef TEST_VERSION
void reconnect(int drive)
{
	windowptr thewin;

	if ((StructureTest[drive] != TRUE) || load_arbo(drive))
	{
		char text[160];

		sprintf(text, Messages(REORG_9), drive +'A');
		my_alert(1, FAIL, X_ICN_STOP, text, NULL);
		return;
	}

	/*	referme les fenˆtres concern‚es	*/
	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
		if ((thewin -> type == SECTEUR || thewin -> type == FICHIER) && thewin -> fonction.fichier.device == drive || thewin -> type == FICHIER_FS && thewin -> fonction.fichier_fs.nom[0] == drive+'A' || thewin -> type == OCCUP && thewin -> fonction.occup.device == drive)
		{
			/* ferme la fenˆtre */
			fermer(thewin -> win -> handle);

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);
		}

	if (reconnect2(drive))
		return;

	/* ‚crit la nouvelle arborescence */
	if (ManageVFAT)
		save_arbo_vfat(drive);
	else
		save_arbo_short(drive);

	/* la structure est OK */
	StructureTest[drive] = TRUE;

	/* force un changement de disque */
	update_systeme(drive);

	if (Cluster[drive])
	{
		free(Cluster[drive]);
		Cluster[drive] = NULL;
	}

	/* reset … la sortie du programme */
	if (ResetFlag)
	{
		menu_icheck(Menu, RESET, 1);
		Reset = TRUE;
	}
} /* reconnect */
#endif

/********************************************************************
*																	*
*				Inscrit les fichiers de fa‡on contige				*
*																	*
********************************************************************/
#ifndef TEST_VERSION
boolean reconnect2(int drive)
{
	BPB bpb = my_getbpb(drive);
	char *buffer;
	long buffer_size;

	buffer_size = (long)Malloc(-1L) / 2L;

	/* limite le buffer … 16 Mo */
	if (buffer_size > 32767*512L)
		buffer_size = 32767*512L;

	buffer_size = ((long)( (buffer_size - 100*1024L) / (128*512L) ) ) * 128*512L;
	if ((buffer_size < MINSIZEBUFMOVE) || ((buffer = malloc(buffer_size)) == NULL))
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	{
		char text[80];

		sprintf(text, Messages(REORG_15), drive +'A');
		ajoute(Firstwindow, text);
	}

	if (ManageVFAT ? reconnect_dir_vfat((dir_elt_vfat *)Arbo[drive], bpb.rdlen * bpb.recsiz/32, drive, &bpb, buffer, buffer_size) : reconnect_dir_short(Arbo[drive], bpb.rdlen * bpb.recsiz/32, drive, &bpb, buffer, buffer_size))
		return TRUE;

	free(buffer);

	return FALSE;
} /* reconnect2 */
#endif

/****************************************************************
*																*
*			reconnect les fichiers du r‚pertoire				*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean reconnect_dir_short(dir_elt_short arbo[], int max, int drive, BPB *bpb, char *buffer, long buffer_size)
{
	int c, file;
	char cont;
	unsigned int *fat = FAT[drive];
	unsigned int clst, last_clst, dummy_clst, nb_clst;
	int max_size = (int)(buffer_size / (bpb -> recsiz * bpb -> clsiz));

	arbo++;	/* on saute le premier enregistrement qui est Info.dir */

	for (file=0; file<max; file++, arbo++)
	{
		if (arbo -> name[0] == 0xE5 || arbo -> name[0] == 0x00 || arbo -> first_cluster == 0 || arbo -> norealdir)
			continue;

		last_clst = arbo -> first_cluster;
		clst = fat[last_clst];
		cont = TRUE;	/* le fichier est continue au d‚part */
		nb_clst = 1;
		while (clst < 0xFFF0)
		{
			if (clst != last_clst +1 && cont)
			{
				char text[80];

				sprintf(text, Messages(REORG_4), (arbo -> attribut & FA_SUBDIR) ? Messages(REORG_5) : Messages(REORG_6), arbo -> name, &arbo -> name[8]);
				ajoute(Firstwindow, text);
				cont = FALSE;
			}

			last_clst = clst;
			clst = fat[clst];
			nb_clst++;
		}

		if (!cont)
		{
			unsigned int src, dst;
			unsigned int old, new;
			int size;

			if ((new = find_place(drive, nb_clst, Tos40xBug ? bpb -> numcl -1 : bpb -> numcl)) == 0)
			{
				ajoute(Firstwindow, Messages(REORG_7));
				continue;
			}

			old = arbo -> first_cluster;	/* ancien 1er cluster */
			arbo -> first_cluster = new;	/* nouveau 1er cluster */
			src = old;	/* cluster de d‚part source */
			size = 0;	/* taille du plus gros morceau copiable en une seule fois */
			dst = new;	/* cluster de d‚part destination */

			if (arbo -> attribut & FA_SUBDIR)
			{
				dir_elt_short *arbo_bis;
				int i;
				
				/* le r‚pertoire lui mˆme */
				arbo -> dir[1].first_cluster = new;	/* . */

				/* ses fils */
				arbo_bis = arbo -> dir;
				for (i=3; i<arbo_bis -> size; i++)	/* on saute Info.dir, . et .. */
					if ((arbo_bis[i].attribut & FA_SUBDIR) && (arbo_bis[i].name[0] != 0xE5) && (arbo_bis[i].name[0] != 0x00))
						arbo_bis[i].dir[2].first_cluster = new;	/* .. des sous r‚pertoires */ 
			}

			for (c=0; c<nb_clst; c++)
			{
				fat[new] = new+1;	/* nouveau chaŒnage */

				dummy_clst = old;	/* on libŠre l'ancien emplacement */
				old = fat[old];
				fat[dummy_clst] = 0;

				new++;	/* suivant */
				size += bpb -> clsiz;	/* et un en plus */

				if (old != dummy_clst+1 || size == max_size)	/* coupure ou buffer plein */
				{
					/* lecture */
					if (my_rwabs(0, buffer, size, (long)((src-2L) * bpb -> clsiz + bpb -> datrec), drive))
						return TRUE;

					/* ‚criture */
					if (my_rwabs(1, buffer, size, (long)((dst-2L) * bpb -> clsiz + bpb -> datrec), drive))
						return TRUE;

					size = 0;
					src = old;	/* nouveau d‚buts des blocs */
					dst = new;
				}
			}

			fat[new-1] = 0xFFFF;
		}

		if (arbo -> attribut & FA_SUBDIR)
			if (reconnect_dir_short(arbo -> dir, (int)arbo -> dir -> size, drive, bpb, buffer, buffer_size))
				return TRUE;
	}

	return FALSE;
} /* reconnect_dir_short */
#endif

/****************************************************************
*																*
*			reconnect les fichiers du r‚pertoire (VFAT)			*
*																*
****************************************************************/
#ifndef TEST_VERSION
boolean reconnect_dir_vfat(dir_elt_vfat arbo[], int max, int drive, BPB *bpb, char *buffer, long buffer_size)
{
	int c, file;
	char cont;
	unsigned int *fat = FAT[drive];
	unsigned int clst, last_clst, dummy_clst, nb_clst;
	int max_size = (int)(buffer_size / (bpb -> recsiz * bpb -> clsiz));

	arbo++;	/* on saute le premier enregistrement qui est Info.dir */

	for (file=0; file<max; file++, arbo++)
	{
		if (arbo -> name[0] == 0xE5 || arbo -> name[0] == 0x00 || arbo -> first_cluster == 0 || arbo -> norealdir)
			continue;

		last_clst = arbo -> first_cluster;
		clst = fat[last_clst];
		cont = TRUE;	/* le fichier est continue au d‚part */
		nb_clst = 1;
		while (clst < 0xFFF0)
		{
			if (clst != last_clst +1 && cont)
			{
				char text[80];

				sprintf(text, Messages(REORG_4), (arbo -> attribut & FA_SUBDIR) ? Messages(REORG_5) : Messages(REORG_6), arbo -> name, &arbo -> name[8]);
				ajoute(Firstwindow, text);
				cont = FALSE;
			}

			last_clst = clst;
			clst = fat[clst];
			nb_clst++;
		}

		if (!cont)
		{
			unsigned int src, dst;
			unsigned int old, new;
			int size;

			if ((new = find_place(drive, nb_clst, Tos40xBug ? bpb -> numcl -1 : bpb -> numcl)) == 0)
			{
				ajoute(Firstwindow, Messages(REORG_7));
				continue;
			}

			old = arbo -> first_cluster;	/* ancien 1er cluster */
			arbo -> first_cluster = new;	/* nouveau 1er cluster */
			src = old;	/* cluster de d‚part source */
			size = 0;	/* taille du plus gros morceau copiable en une seule fois */
			dst = new;	/* cluster de d‚part destination */

			if (arbo -> attribut & FA_SUBDIR)
			{
				dir_elt_vfat *arbo_bis;
				int i;
				
				/* le r‚pertoire lui mˆme */
				arbo -> dir[1].first_cluster = new;	/* . */

				/* ses fils */
				arbo_bis = arbo -> dir;
				for (i=3; i<arbo_bis -> size; i++)	/* on saute Info.dir, . et .. */
					if ((arbo_bis[i].attribut & FA_SUBDIR) && (arbo_bis[i].name[0] != 0xE5) && (arbo_bis[i].name[0] != 0x00))
						arbo_bis[i].dir[2].first_cluster = new;	/* .. des sous r‚pertoires */ 
			}

			for (c=0; c<nb_clst; c++)
			{
				fat[new] = new+1;	/* nouveau chaŒnage */

				dummy_clst = old;	/* on libŠre l'ancien emplacement */
				old = fat[old];
				fat[dummy_clst] = 0;

				new++;	/* suivant */
				size += bpb -> clsiz;	/* et un en plus */

				if (old != dummy_clst+1 || size == max_size)	/* coupure ou buffer plein */
				{
					/* lecture */
					if (my_rwabs(0, buffer, size, (long)((src-2L) * bpb -> clsiz + bpb -> datrec), drive))
						return TRUE;

					/* ‚criture */
					if (my_rwabs(1, buffer, size, (long)((dst-2L) * bpb -> clsiz + bpb -> datrec), drive))
						return TRUE;

					size = 0;
					src = old;	/* nouveau d‚buts des blocs */
					dst = new;
				}
			}

			fat[new-1] = 0xFFFF;
		}

		if (arbo -> attribut & FA_SUBDIR)
			if (reconnect_dir_vfat(arbo -> dir, (int)arbo -> dir -> size, drive, bpb, buffer, buffer_size))
				return TRUE;
	}

	return FALSE;
} /* reconnect_dir_vfat */
#endif

/********************************************************************
*																	*
*					Compresse les secteurs occup‚s					*
*																	*
********************************************************************/
#ifndef TEST_VERSION
void compresse(int drive)
{
	windowptr thewin;

	if ((StructureTest[drive] != TRUE) || load_arbo(drive))
	{
		char text[160];

		sprintf(text, Messages(REORG_9), drive +'A');
		my_alert(1, FAIL, X_ICN_STOP, text, NULL);
		return;
	}

	/*	referme les fenˆtres concern‚es	*/
	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
		if ((thewin -> type == SECTEUR || thewin -> type == FICHIER) && thewin -> fonction.fichier.device == drive || thewin -> type == FICHIER_FS && thewin -> fonction.fichier_fs.nom[0] == drive+'A' || thewin -> type == OCCUP && thewin -> fonction.occup.device == drive)
		{
			/* ferme la fenˆtre */
			fermer(thewin -> win -> handle);

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);
		}

	if (compresse2(drive))
		return;

	/* ‚crit la nouvelle arborescence */
	if (ManageVFAT)
		save_arbo_vfat(drive);
	else
		save_arbo_short(drive);

	/* la structure est OK */
	StructureTest[drive] = TRUE;

	/* force un changement de disque */
	update_systeme(drive);

	if (Cluster[drive])
	{
		free(Cluster[drive]);
		Cluster[drive] = NULL;
	}

	/* reset … la sortie du programme */
	if (ResetFlag)
	{
		menu_icheck(Menu, RESET, 1);
		Reset = TRUE;
	}
} /* compresse */
#endif

/********************************************************************
*																	*
*					Compresse les secteurs occup‚s					*
*																	*
********************************************************************/
#ifndef TEST_VERSION
boolean compresse2(int drive)
{
	unsigned int *fat, *fat2, *redirect;	/* redirect[i] = nouveau num‚ro du cluster i */
	long redirect_size;
	BPB bpb = my_getbpb(drive);
	char *buffer;
	long buffer_size;
	unsigned int src, dst;
	int size, max_size;
	OBJECT *wait = Dialog[WAIT].tree;
	int width;
	char *secteur_text;
	unsigned int max_clst, nb_clst = 0;

	/* buffer pour la renum‚rotation des clusters */
	redirect_size = drive < 2 ? (bpb.numcl +2L) * sizeof(unsigned int) : (long)bpb.fsiz * bpb.recsiz;
	if ((redirect = malloc(redirect_size)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	/* une copie de la FAT */
	if ((fat2 = malloc(redirect_size)) == NULL)
	{
		free(redirect);

		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	/* alloue le buffer pour la copie */
	buffer_size = (long)(Malloc(-1L))/2L;

	/* limite la taille sinon max_size (int) va dans les choux */
	if (buffer_size > 32767*512L)
		buffer_size = 32767*512L;

	buffer_size = ( (long)( (buffer_size - 100*1024L) / (128*512L) ) ) * 128*512L;
	if ((buffer_size < MINSIZEBUFMOVE) || ((buffer = malloc(buffer_size)) == NULL))
	{
		free(fat2);
		free(redirect);

		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	/* nombre max de secteurs … lire */
	max_size = (int)(buffer_size / ((long)bpb.clsiz * bpb.recsiz));

	fat = FAT[drive];

	for (src=0; src < bpb.numcl+2; src++)
	{
		redirect[src] = src;	/* … priori un bloc ne bouge pas */
		fat2[src] = fat[src];
	}

	/* on attends que ca se calme */
	Event_Timer(0, 0, TRUE);

	{
		unsigned int i;

		for (i=Tos40xBug ? bpb.numcl : bpb.numcl +1; i>0; i--)
			if (fat[i] == 0)
				break;

		max_clst = 0;
		for (; i>0; i--)
			if (fat[i])
				max_clst++;
	}

	width = wait[SLIDE_PERE].ob_width -3;
	wait[SLIDE_FILS].ob_width = 3;

	wait[WAIT_MESSAGE].ob_spec.free_string = Messages(REORG_8);
	wait[WAIT_INFO].ob_spec.tedinfo -> te_ptext = Messages(REORG_12);

	secteur_text = wait[INDICATEUR_WAIT].ob_spec.tedinfo -> te_ptext;
	sprintf(secteur_text, "0");
	sprintf(wait[MAX_WAIT].ob_spec.free_string, "/%u", max_clst);

	{
		char text[80];

		sprintf(text, Messages(REORG_16), drive +'A');
		ajoute(Firstwindow, text);
	}

	my_open_dialog(&Dialog[WAIT], AUTO_DIAL|NO_ICONIFY|MODAL, FAIL);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	/* tout se fait de la fin vers le d‚but */
	dst = Tos40xBug ? bpb.numcl : bpb.numcl +1;
	while (dst >= 2)
	{
		/* on recherche un d‚but de bloc libre … partir de la fin
		  (c'est le dernier cluster du bloc libre */
		for (; fat[dst] != 0 && dst >= 2; dst--)
			;
		if (dst < 2)
			break;

		/* on recherche la fin du bloc libre
		  (c'est le premier cluster du bloc libre)
		  on compte comme libre les bad blocks, ils ne sont pas … recopier */
		for (src = dst-1; (fat[src] == 0 || (fat[src] >= 0xFFF0 && fat[src] <= 0xFFF7)) && src > 1; src--)
			;
		if (src < 2)	/* le dernier bloc libre va jusqu'au d‚but de la partition */
			break;

		/* recule jusqu'…: remplir le buffer ou fin du bloc occup‚ ou fin du bloc libre */
		for (size=0; size < max_size /* encore de la place dans le tampon de copie */
		 && fat[src]	/* le bloc est occup‚, on d‚place */
		 && (fat[src] < 0xFFF0 || fat[src] > 0xFFF7)	/* le bloc n'est pas un bad bloc */
		 && fat[dst] == 0	/* il reste de la place pour copier le bloc */
		 && src>=2; size++, src--, dst--)
		{
			redirect[src] = dst;
			fat[dst] = 1;	/* valeur sp‚ciale, ‡a ne peut pas ˆtre un clusteur car <2 */
			fat[src] = 0;
		}

		/* le bloc a d‚lacer est juste un bad block */
		if (size == 0)
			continue;

		/* on a un peu trop recul‚ */
		src++;
		dst++;

		/* on fait avancer la barre de progression */
		nb_clst += size;

		/* lecture */
		wait[WAIT_INFO].ob_spec.tedinfo -> te_ptext = Messages(REORG_12);
		ob_draw(Dialog[WAIT].info, WAIT_INFO);
		if (my_rwabs(0, buffer, size * bpb.clsiz, (long)((src-2) * bpb.clsiz + bpb.datrec), drive) && my_alert(2, FAIL, X_ICN_QUESTION, Messages(REORG_10), Messages(BOOT_32)) == 2)
			break;

		/* ‚criture */
		wait[WAIT_INFO].ob_spec.tedinfo -> te_ptext = Messages(REORG_13);
		ob_draw(Dialog[WAIT].info, WAIT_INFO);
		if (my_rwabs(1, buffer, size * bpb.clsiz, (long)((dst-2) * bpb.clsiz + bpb.datrec), drive) && my_alert(2, FAIL, X_ICN_QUESTION, Messages(REORG_11), Messages(BOOT_32)) == 2)
			break;

		sprintf(secteur_text, "%u", nb_clst);
		ob_draw(Dialog[WAIT].info, INDICATEUR_WAIT);
		wait[SLIDE_FILS].ob_width = (int)((long)width *  nb_clst / max_clst) +3;
		ob_draw(Dialog[WAIT].info, SLIDE_FILS);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);	
	}
	wait[SLIDE_FILS].ob_width = width +3;
	ob_draw(Dialog[WAIT].info, SLIDE_FILS);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);	

	free(buffer);

	my_close_dialog(&Dialog[WAIT]);

	/* modifie les first_cluster de l'arborescence */
	if (ManageVFAT)
		compresse_dir_vfat((dir_elt_vfat *)Arbo[drive], bpb.rdlen * bpb.recsiz / 32, redirect);
	else
		compresse_dir_short(Arbo[drive], bpb.rdlen * bpb.recsiz / 32, redirect);

	/* modifie la FAT */
	for (src=2; src < bpb.numcl+2; src++)
		if (fat[redirect[src]] == 1)	/* si c'est un fichier d‚plac‚ */
			fat[redirect[src]] = fat2[src] > 0xFFF0 ? fat2[src] : redirect[fat2[src]];

	free(redirect);
	free(fat2);

	return FALSE;
} /* compresse2 */
#endif

/****************************************************************
*																*
*				modifie les first_cluster						*
*																*
****************************************************************/
#ifndef TEST_VERSION
void compresse_dir_short(dir_elt_short *arbo, int max, unsigned int redirect[])
{
	int file;

	arbo++;	/* on saute le premier enregistrement qui est Info.dir */

	for (file=0; file<max; file++, arbo++)
	{
		if (arbo -> name[0] == 0xE5 || arbo -> name[0] == 0x00 || arbo -> first_cluster == 0 || arbo -> norealdir)
			continue;

		arbo -> first_cluster = redirect[arbo -> first_cluster];

		if (arbo -> attribut & FA_SUBDIR)
		{
			arbo -> dir[1].first_cluster = redirect[arbo -> dir[1].first_cluster];	/* . */
			arbo -> dir[2].first_cluster = redirect[arbo -> dir[2].first_cluster];	/* .. */
			compresse_dir_short(arbo -> dir, (int)arbo -> dir -> size, redirect);
		}
	}
} /* compresse_dir_short */
#endif

/****************************************************************
*																*
*				modifie les first_cluster (VFAT)				*
*																*
****************************************************************/
#ifndef TEST_VERSION
void compresse_dir_vfat(dir_elt_vfat *arbo, int max, unsigned int redirect[])
{
	int file;

	arbo++;	/* on saute le premier enregistrement qui est Info.dir */

	for (file=0; file<max; file++, arbo++)
	{
		if (arbo -> name[0] == 0xE5 || arbo -> name[0] == 0x00 || arbo -> first_cluster == 0 || arbo -> norealdir)
			continue;

		arbo -> first_cluster = redirect[arbo -> first_cluster];

		if (arbo -> attribut & FA_SUBDIR)
		{
			arbo -> dir[1].first_cluster = redirect[arbo -> dir[1].first_cluster];	/* . */
			arbo -> dir[2].first_cluster = redirect[arbo -> dir[2].first_cluster];	/* .. */
			compresse_dir_vfat(arbo -> dir, (int)arbo -> dir -> size, redirect);
		}
	}
} /* compresse_dir_vfat */
#endif

/********************************************************************
*																	*
*					Les deux ‚tapes d'un coup						*
*																	*
********************************************************************/
#ifndef TEST_VERSION
void restauration_complete(int drive)
{
	windowptr thewin;

	if ((StructureTest[drive] != TRUE) || load_arbo(drive))
	{
		char text[160];

		sprintf(text, Messages(REORG_9), drive +'A');
		my_alert(1, FAIL, X_ICN_STOP, text, NULL);
		return;
	}

	/*	referme les fenˆtres concern‚es	*/
	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
		if ((thewin -> type == SECTEUR || thewin -> type == FICHIER) && thewin -> fonction.fichier.device == drive || thewin -> type == FICHIER_FS && thewin -> fonction.fichier_fs.nom[0] == drive+'A' || thewin -> type == OCCUP && thewin -> fonction.occup.device == drive)
		{
			/* ferme la fenˆtre */
			fermer(thewin -> win -> handle);

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);
		}

	if (compresse2(drive))
		return;

	if (reconnect2(drive))
		return;

	if (compresse2(drive))
		return;

	/* ‚crit la nouvelle arborescence */
	if (ManageVFAT)
		save_arbo_vfat(drive);
	else
		save_arbo_short(drive);

	/* la structure est OK */
	StructureTest[drive] = TRUE;

	/* force un changement de disque */
	update_systeme(drive);

	if (Cluster[drive])
	{
		free(Cluster[drive]);
		Cluster[drive] = NULL;
	}

	/* reset … la sortie du programme */
	if (ResetFlag)
	{
		menu_icheck(Menu, RESET, 1);
		Reset = TRUE;
	}
} /* restauration_complete */
#endif
