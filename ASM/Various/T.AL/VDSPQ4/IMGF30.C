/*
	imgf30.c
	
	.f30 image file tools
*/

#include <stdio.h>
#include <stdlib.h>
#include <portab.h>
#include <string.h>
#include <tos.h>

#include "vector.h"

/* allocate new f30 image */
IMGF30 *new_f30(void)
{
	IMGF30 *new= malloc(sizeof(IMGF30));
	
	if(!new)
	{
		puts("Not enough memory\n");
		return NULL;
	}
	else
	{
		*new->fname= 0;
		new->mode= 0;
		new->colors= 0;
		new->maxx= new->maxy= 0;
		new->size= 0;
		new->img= NULL;

		return new;
	}
}

/* loads a .f30 image file */
IMGF30 *load_f30(char *fname)
{
	IMGF30 *i;
	FILE *f;
	
	f=fopen(fname,"rb");
	if(f)
	{
		i= new_f30();
		strcpy(i->fname, fname);
		fread( &(i->mode), sizeof(int), 1, f);
		fread( &(i->maxx), sizeof(int), 1, f);
		fread( &(i->maxy), sizeof(int), 1, f);

		printf("reading '%s'\n%dx%d ",i->fname, i->maxx, i->maxy);

		i->colors =1L << (1L << (i->mode & 0x7));
		if( (i->mode & 0x7) != 0x4)
		{
			printf("'%s'\nis a bitmap image.\nNeed a true color image\n", fname);
			return NULL; /* bitmap image */
		}
		printf("true color image.\n");

		i->size= (long) i->maxx*i->maxy;
		i->img= (UWORD *) malloc(i->size * sizeof(UWORD));
		if(!i->img) return NULL;
		
		fread(i->img, sizeof(UWORD), i->size, f);
		fclose(f);

		return i;
	}
	
	printf("can\'t find '%s'\n", fname);
	return NULL;
}

void free_f30(IMGF30 *i)
{
	if(i)
	{
		if(i->img)	
			free(i->img);
		free(i);
	}	
}

