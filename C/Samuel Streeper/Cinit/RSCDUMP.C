/*********************************************
*	Rscdump.c
*	A program to dump resource files as C
*	structures. Dumps the file listed on the command
*	line to standard output, which may be redirected
*	to a file:
*
*		rscdump file.rsc >file.out
*
*       by Samuel Streeper
*       Copyright 1989 Antic Publishing
*********************************************/
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>

int num_trees = 0;

/************************************************************
*	Note: nulls and spaces follow the strings below because	*
*	Laser C 2.0 will mung 2 dimentional	character			*
*	array generation. Fixed in Laser 2.1					*
************************************************************/
char types[][12] ={
	"G_BOX\0     ",
	"G_TEXT\0    ",
	"G_BOXTEXT\0 ",
	"G_IMAGE\0   ",
	"G_PROGDEF\0 ",
	"G_IBOX\0    ",
	"G_BUTTON\0  ",
	"G_BOXCHAR\0 ",
	"G_STRING\0  ",
	"G_FTEXT\0   ",
	"G_FBOXTEXT\0",
	"G_ICON\0    ",
	"G_TITLE\0   "
		};

main(argc,argv)
char *argv[];
{
	RSHDR *header;
	OBJECT *op;
	TEDINFO *tp;
	long size;
	int read, in, num_objs = 0, num_teds = 0, ndx;
	char *buffer;

	Bconws("Rscdump 1.02 890611 SGS\r\n");

	if (argc < 2)
	{
		printf("Usage: rscdump file.rsc [>file.out]\n");
		Pterm(0);
	}

	/* allocate space for the resource file */
	buffer = (char *)Malloc(65000L);
	if ((long)buffer <= 0L) Pterm(-1);

	header = (RSHDR *)buffer;
	in = Fopen(argv[1],0);
	if (in < 0)
	{
		printf("can't open %s\n",argv[1]);
		Pterm(-1);
	}

	size = Fread(in,64000L,buffer);
	if (size <= 0L)
	{
		printf("unable to read %s\n",argv[1]);
		Pterm(-1);
	}
	Fclose(in);

	/* Get index of tedinfos */

	tp = (TEDINFO *)(((long)buffer) + header->rsh_tedinfo);
	while (num_teds < header->rsh_nted)
	{
		printf("TEDINFO ted%d = {\n",num_teds);
		printf("\t\"%s\",\n",&buffer[(long)tp->te_ptext]);
		printf("\t\"%s\",\n",&buffer[(long)tp->te_ptmplt]);
		printf("\t\"%s\",\n",&buffer[(long)tp->te_pvalid]);
		printf("\t%d, %d, %d, 0x%x, %d, 0x%x, %d, %d\t", tp->te_font,
			tp->te_junk1, tp->te_just, tp->te_color, tp->te_junk2,
			tp->te_thickness, tp->te_txtlen, tp->te_tmplen);
		printf("	};\n\n");
		tp++;
		num_teds++;
	}

	op = (OBJECT *)(((long)buffer) + header->rsh_object);

	while (num_objs < header->rsh_nobs)
	{
		if (op->ob_next == -1)
		{	if (num_trees) close_bracket();
			open_bracket();
			num_trees++;
		}

		printf("%d,",op->ob_next);
		printf("%d,",op->ob_head);
		printf("%d,",op->ob_tail);

		if (op->ob_type >= G_BOX && op->ob_type <= G_TITLE)
			printf("%s,",types[op->ob_type - G_BOX]);
		else printf("0x%x,",op->ob_type);

		printf("0x%x,",op->ob_flags);
		printf("0x%x,",op->ob_state);

		if(op->ob_type == G_STRING || op->ob_type == G_BUTTON
			|| op->ob_type == G_TITLE)
		{	printf("\"%s\",",&buffer[(long)op->ob_spec]);
		}
		else if (op->ob_type == G_TEXT || op->ob_type == G_BOXTEXT ||
			op->ob_type == G_FTEXT || op->ob_type == G_FBOXTEXT)
		{	ndx = (int)(((long)op->ob_spec - header->rsh_tedinfo)
				/ sizeof(TEDINFO));
			if (ndx >= 0 && ndx < header->rsh_nted)
				printf("&ted%d,",ndx);
			else printf("0x%lxL,",op->ob_spec);
		}
		else printf("0x%lxL,",op->ob_spec);

		printf("%d,",op->ob_x);
		printf("%d,",op->ob_y);
		printf("%d,",op->ob_width);
		printf("%d,\n",op->ob_height);

		op++;
		num_objs++;
	}
	close_bracket();
}

open_bracket()
{
	printf("OBJECT obj%d[] = {\n",num_trees);
}

close_bracket()
{
	printf("};\n\n");
}

Bconws(string)
register char *string;
{
	while (*string) Bconout(2,*string++);
}
