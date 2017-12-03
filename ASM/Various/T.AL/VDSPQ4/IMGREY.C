/*
	imgrey.c
	
	grey image tools
*/

#include <stdio.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>

#include "vector.h"

UWORD greytone[256];

/* precalc greytone */
void precalc_grey(void)
{
	int c;
	UWORD *gt= greytone;
	
	for(c= 0; c<64; c++)
		*gt++= (UWORD) ( ((c>>1) <<11) | (c<<5) | (c>>1)); 
	
	for(c= 64; c<256-64; c++)
		*gt++= (UWORD) 0xf800;
	
	for(c= 256-64; c<256; c++)
		*gt++= greytone[256-c];
}

GREY *new_grey(void)
{
	GREY *new= (GREY *) malloc(sizeof(GREY));
	
	if(!new)
		alert("not enough memory\n");
		
	new->maxx= new->maxy= 0;
	new->size= 0;
	new->img= NULL;

	return new;
}

GREY *create_grey(GREY *grey)
{
	GREY *new= (GREY *) malloc(sizeof(GREY));
	if(!new) 
		alert("Not enough memory\n");

	new->maxx= grey->maxx; new->maxy= grey->maxy;
	new->size= (long) new->maxx * new->maxy;
	new->img= (BYTE *) malloc(new->size * sizeof(BYTE));
	if(!new->img)
		alert("Not enough memory\n");
		
	memset(new->img, 0, new->size * sizeof(BYTE));	/* clear image */
	return new;
}

GREY *copy_grey(GREY *grey)
{
	GREY *new= (GREY *) malloc(sizeof(GREY));
	if(!new) 
		alert("Not enough memory\n");

	new->maxx= grey->maxx; new->maxy= grey->maxy;
	new->size= (long) new->maxx * new->maxy;
	new->img= (BYTE *) malloc(new->size * sizeof(BYTE));
	if(!new->img)
		alert("Not enough memory\n");
		
	memcpy(new->img, grey->img, new->size * sizeof(BYTE));
	return new;
}


void free_grey(GREY *g)
{
	if(g)
	{
		if(g->img)	
			free(g->img);
		free(g);
	}
}

GREY *convf30_grey(IMGF30 *i)
{
	int c;
	register long p;
	register UWORD pix;
	register BYTE lum;
	register UWORD *itc;
	register BYTE *ig;
	GREY *g;

	BYTE lumr[64], lumg[64], lumb[64];
	BYTE *lr=lumr, *lg=lumg, *lb=lumb;

	precalc_grey();

	/* L = 0.3*R   + 0.59*G   + 0.11*B 
	   L = lumr(R) + lumg(G)  + lumb(B) */
	for(c= 0; c<64; c++)
	{
		*lr++= (BYTE) ((c*30)/100);
		*lg++= (BYTE) ((c*59)/100);
		*lb++= (BYTE) ((c*11)/100);
	}

	g= (GREY *) malloc(sizeof(GREY));
	if(!g)
		alert("Not enough memory\n");

	g->maxx= i->maxx; g->maxy= i->maxy;
	g->size= (long) i->maxx * i->maxy;
	g->img= (BYTE *) malloc(g->size * sizeof(BYTE));
	if(!g->img)
		alert("Not enough memory\n");

	for(itc= i->img, ig= g->img, p= g->size;
	    p; --p)
	{
		pix=*itc++;
		lum= lumr[ (pix>>11) << 1]
		   + lumg[ (pix>>5) & 0x3f]
		   + lumb[ (pix & 0x1f) << 1];
		*ig++= lum;
	}
	
	return g;
}

void disp_grey(GREY *g)
{
	long size;
	UBYTE *pix= (UBYTE *) g->img;
	UWORD *screen= Physbase();
	
	for(size= g->size; size; size--)
		*screen++= greytone[*pix++];
}

void disp_pol(GREY *g)
{
	long size;
	UBYTE *pix= (UBYTE *) g->img;
	UWORD *screen= Physbase();
	
	for(size= g->size; size; size--, pix++, screen++)
		if(*pix>0 && *pix<128)
			*screen= greytone[0];
		else if(*pix>128)
			*screen= greytone[63];
		else if(*pix==0 || *pix==128)
			*screen= greytone[128];
}

void disp_diff(GREY *g1, GREY *g2)
{
	long size;
	BYTE *pix1= g1->img,
	     *pix2= g2->img;
	UWORD *screen= Physbase();
	
	for(size= g1->size; size; size--)
	{
		if(*pix1++ && *pix2++)
			*screen++= greytone[63];
		else
			*screen++= greytone[128];
	}
}

void disp_mask(GREY *g, GREY *mask)
{
	long size;
	BYTE *pix= g->img,
	     *m= mask->img;
	UWORD *screen= Physbase();
	
	for(size= g->size; size; size--, pix++, m++)
	{
		if(*m)
			*screen++= greytone[*m];
		else
			*screen++= greytone[*pix];
	}
	
}


int save_grey(GREY *g, char *fname)
{
	FILE *f;
	
	f= fopen(fname, "wb");
	if(f == NULL)
	{
		char tmp[256];
		
		sprintf(tmp, "\nerror writing '%s'\n", fname);
		puts(tmp);
		
		return 1;
	}

	printf("\rwriting '%s'\n%dx%d grey image\n", fname, g->maxx, g->maxy);

	fwrite( &(g->maxx), sizeof(uint), 1, f);
	fwrite( &(g->maxy), sizeof(uint), 1, f);
	fwrite( &(g->size), sizeof(ulong), 1, f);
	fwrite( g->img, sizeof(BYTE), g->size, f);
	fclose(f);
		
	return 0;
}

int load_grey(GREY *g, char *fname)
{
	FILE *f;
	
	f= fopen(fname, "rb");
	if(f == NULL) 
	{
		char tmp[256];
		sprintf(tmp, "\ncan't find '%s'\n", fname);
		puts(tmp);
		return 1;
	}

	fread( &(g->maxx), sizeof(uint), 1, f);
	fread( &(g->maxy), sizeof(uint), 1, f);
	fread( &(g->size), sizeof(ulong), 1, f);
	
	printf("\rreading '%s'\n%dx%d grey image\n", fname, g->maxx, g->maxy);

	g->img= (BYTE *) malloc(g->size * sizeof(BYTE));
	if(g->img == NULL) 
	{
		puts("Not enough memory");
		return 1;
	}
	
	fread(g->img, sizeof(BYTE), g->size, f);
	fclose(f);

	return 0;
}
