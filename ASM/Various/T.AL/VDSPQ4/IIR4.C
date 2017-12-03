/* 
	filter.c

	Deriche filter function 
*/
#include <stdio.h>
#include <portab.h>
#include <tos.h>

#include "vector.h"

/* Deriche filter */
GREY *filter(GREY *sx, GREY *sy)
{
	long size;
	BYTE *x, *y, *d;
	GREY *new= create_grey(sx);

	x= sx->img;
	y= sy->img;
	d= new->img;
	for(size= new->size; size; size--)
		*d++= ((*x++) + (*y++)) >>1;

	return new;
}

/* Deriche gradient */
GREY *gradient(GREY *dx, GREY *dy)
{
	int tmp, pix;
	long size;
	BYTE *x, *y, *d;
	GREY *new= create_grey(dx);

	x= dx->img;
	y= dy->img;
	d= new->img;
	for(size= new->size; size; size--)
	{
		tmp= *x++;
		if(tmp>=0) pix= tmp;
		else      pix= -tmp;

		tmp= *y++;
		if(tmp>=0) pix+= tmp;
		else      pix-= tmp;

		*d++= pix;
	}

	return new;
}

/* Deriche laplacian */
GREY *laplacian(GREY *lx, GREY *ly)
{
	long size;
	BYTE *x, *y, *l;
	GREY *new= create_grey(lx);

	x= lx->img;
	y= ly->img;
	l= new->img;
	for(size= new->size; size; size--)
		*l++= ((*x++) + (*y++)) >>1;

	return new;
}
