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
#include <string.h>
#include <screen.h>

#define FILENAME "MESSGS"
#define LINE_SIZE 4096

char Ligne[LINE_SIZE];

typedef struct
{
	int rsh_vrsn;	/* num‚ro de version */
	int rsh_object;	/* offset to the OBJECT structure */
	int rsh_tedinfo;	/* offset to the TEDINFO structure */
	int rsh_iconblk;	/* offset to the ICONBLK structure */
	int rsh_bitblk;	/* offset to the BITBLK structure */
	int rsh_frstr;	/* offset to the string pointer table */
	int rsh_string;	/* offset to the string data */
	int rsh_imdata;	/* offset to the image data */
	int rsh_frimg;	/* offset to the image pointer table */
	int rsh_trindex;	/* offset to the tree pointer table */
	int rsh_nobs;	/* number of OBJECTs */
	int rsh_ntree;	/* number of trees */
	int rsh_nted;	/* number of TEDINFO */
	int rsh_nib;	/* number of ICONBLK */
	int rsh_nbb;	/* number of BITBLK */ 
	int rsh_nstring;	/* number of free strings */
	int rsh_nimages;	/* number of images */
	int rsh_rssize;	/* size of the resource file */
} t_rsc_header;

/********************************************************************
*																	*
*				convertit MESSAGES.TXT en MESSAGES.RSC				*
*																	*
********************************************************************/
int main(void)
{
	FILE *fd_txt;
	int fd_rsc_f, fd_hrd_f;
	int fd_rsc_e, fd_hrd_e;
	t_rsc_header header, header_e;
	int nb;
	OBJECT obj_f, obj_e;
	long l;

	if ((fd_txt = fopen(FILENAME ".TXT", "r")) == NULL)
	{
		perror(FILENAME ".TXT");
		return 1;
	}

	if ((fd_rsc_f = (int)Fcreate(FILENAME "_F.RSC", 0)) < 0)
	{
		perror(FILENAME "_F.RSC");
		return 2;
	}

	if ((fd_hrd_f = (int)Fcreate(FILENAME "_F.HRD", 0)) < 0)
	{
		perror(FILENAME "_F.HRD");
		return 2;
	}

	if ((fd_rsc_e = (int)Fcreate(FILENAME "_E.RSC", 0)) < 0)
	{
		perror(FILENAME "_E.RSC");
		return 2;
	}

	if ((fd_hrd_e = (int)Fcreate(FILENAME "_E.HRD", 0)) < 0)
	{
		perror(FILENAME "_E.HRD");
		return 2;
	}

	header.rsh_vrsn = 0;
	header.rsh_string = 0x24;
	header.rsh_ntree = 1;
	header.rsh_nted = 0;
	header.rsh_nib = 0;
	header.rsh_nbb = 0;
	header.rsh_nstring = 0;
	header.rsh_nimages = 0;

	Fwrite(fd_rsc_f, sizeof(t_rsc_header), &header);
	Fwrite(fd_rsc_e, sizeof(t_rsc_header), &header);

	Fwrite(fd_hrd_f, 14L, "\0\1\0\1\0\1\1\0\0\0\0\0\0\0");
	Fwrite(fd_hrd_e, 14L, "\0\1\0\1\0\1\1\0\0\0\0\0\0\0");

	Fwrite(fd_hrd_f, 7L, "TEXTES");
	Fwrite(fd_hrd_e, 7L, "TEXTES");

	nb = 0;
	while(fgets(Ligne, LINE_SIZE, fd_txt))
	{
		/* vire le \n */
		Ligne[strlen(Ligne)-1] = '\0';
		if (Ligne[0] == '\0')
			continue;

		/* un text de plus */
		nb++;

		Fwrite(fd_hrd_f, 4L, "\5\0\0\0");
		Fwrite(fd_hrd_f, 2L, &nb);
		Fwrite(fd_hrd_f, strlen(Ligne)+1, Ligne);

		Fwrite(fd_hrd_e, 4L, "\5\0\0\0");
		Fwrite(fd_hrd_e, 2L, &nb);
		Fwrite(fd_hrd_e, strlen(Ligne)+1, Ligne);

		fgets(Ligne, LINE_SIZE, fd_txt);
		Ligne[strlen(Ligne)-1] = '\0';

		Fwrite(fd_rsc_f, strlen(Ligne)+1, Ligne);

		fgets(Ligne, LINE_SIZE, fd_txt);
		Ligne[strlen(Ligne)-1] = '\0';

		Fwrite(fd_rsc_e, strlen(Ligne)+1, Ligne);

		printf(CUR_HOME "Ligne: %d", nb);
	}

	Fwrite(fd_hrd_f, 1L, "\6");
	Fwrite(fd_hrd_e, 1L, "\6");

	Fclose(fd_hrd_f);
	Fclose(fd_hrd_e);

	header.rsh_nobs = nb+1;
	header.rsh_object = (int)Fseek(0L, fd_rsc_f, 1);
	header.rsh_tedinfo = header.rsh_object;
	header.rsh_iconblk = header.rsh_object;
	header.rsh_bitblk = header.rsh_object;
	header.rsh_frstr = header.rsh_object;
	header.rsh_imdata = header.rsh_object;
	header.rsh_frimg = header.rsh_object;

	header_e = header;
	header_e.rsh_object = (int)Fseek(0L, fd_rsc_e, 1);

	/* le fond */
	obj_f.ob_next = -1;
	obj_f.ob_head = 1;
	obj_f.ob_tail = nb;
	obj_f.ob_type = G_BOX;
	obj_f.ob_flags = 0;
	obj_f.ob_state = 0;
	obj_f.ob_spec.index = 0xFF1100L;
	obj_f.ob_x = 0;
	obj_f.ob_y = 0;
	obj_f.ob_width = 255;
	obj_f.ob_height = 255;
	Fwrite(fd_rsc_f, sizeof(obj_f), &obj_f);
	Fwrite(fd_rsc_e, sizeof(obj_f), &obj_f);

	/* un texte */
	obj_f.ob_next = 1;
	obj_f.ob_head = -1;
	obj_f.ob_tail = -1;
	obj_f.ob_type = G_STRING;
	obj_f.ob_flags = 0;
	obj_f.ob_state = 0;
	obj_f.ob_spec.index = 0x24;
	obj_f.ob_x = 0;
	obj_f.ob_y = 0;
	obj_f.ob_height = 1;

	obj_e = obj_f;

	fseek(fd_txt, 0L, SEEK_SET);
	while(fgets(Ligne, LINE_SIZE, fd_txt))
	{
		/* vire le \n */
		Ligne[strlen(Ligne)-1] = '\0';
		if (Ligne[0] == '\0')
		{
			obj_f.ob_y++;
			obj_e.ob_y++;
			continue;
		}

		obj_f.ob_next++;
		obj_e.ob_next++;

		if (--nb == 0)
		{
			obj_f.ob_next = 0;
			obj_f.ob_flags = LASTOB;

			obj_e.ob_next = 0;
			obj_e.ob_flags = LASTOB;
		}

		fgets(Ligne, LINE_SIZE, fd_txt);
		Ligne[strlen(Ligne)-1] = '\0';
		obj_f.ob_width = (int)strlen(Ligne);

		Fwrite(fd_rsc_f, sizeof(obj_f), &obj_f);

		fgets(Ligne, LINE_SIZE, fd_txt);
		Ligne[strlen(Ligne)-1] = '\0';
		obj_e.ob_width = (int)strlen(Ligne);

		Fwrite(fd_rsc_e, sizeof(obj_e), &obj_e);

		obj_f.ob_y++;
		obj_e.ob_y++;
		if (obj_f.ob_y > 250)
		{
			obj_f.ob_x += 90;
			obj_f.ob_y = 0;

			obj_e.ob_x += 90;
			obj_e.ob_y = 0;
		}
		obj_f.ob_spec.index += obj_f.ob_width+1;
		obj_e.ob_spec.index += obj_e.ob_width+1;
	}

	/* fran‡ais */
	header.rsh_trindex = (int)Fseek(0L, fd_rsc_f, 1);
	l = header.rsh_object;
	Fwrite(fd_rsc_f, sizeof(l), &l);

	header.rsh_rssize = (int)Fseek(0L, fd_rsc_f, 1);
	Fseek(0L, fd_rsc_f, 0);
	Fwrite(fd_rsc_f, sizeof(t_rsc_header), &header);

	/* anglais */
	header_e.rsh_trindex = (int)Fseek(0L, fd_rsc_e, 1);
	l = header_e.rsh_object;
	Fwrite(fd_rsc_e, sizeof(l), &l);

	header_e.rsh_rssize = (int)Fseek(0L, fd_rsc_e, 1);
	Fseek(0L, fd_rsc_e, 0);
	Fwrite(fd_rsc_e, sizeof(t_rsc_header), &header_e);

	/* referme tout */
	Fclose(fd_rsc_f);
	Fclose(fd_rsc_e);
	fclose(fd_txt);

	return 0;
} /* main */
