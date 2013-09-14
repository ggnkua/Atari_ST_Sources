#include	"comp.h"

#define 	LIM		12		/* make sure EVEN !	*/

extern unsigned char	*utinpt;
extern unsigned		disp;
extern char		advld, rldld;
extern struct	slvll	*getslvbuf(), *Bslv;

funct_comm(fct,d,cpl)
unsigned	fct, d;
unsigned char	*cpl;
{
	unsigned char	sc[LIM];
	unsigned	size, i;
	unsigned char	c;

/*	memset(sc,0,LIM);			** clear command buffer */
	sc[0] = fct | 0x80;			/* mark 1st cmd code	*/
	switch (fct) {
	case  9:				/* Vert. Move Forward	*/
		if (setp.omod == 0)		/* 8600 no odd value...	*/
			accval(&advld,&d);
		goto next;
	case 10:				/* Vert. Move Reverse	*/
		if (setp.omod == 0)		/* 8600 no odd value...	*/
			accval(&rldld,&d);
		goto next;
	case 11:				/* Horizontal Position	*/
	case 27: case 28:			/* Hor. Move Right/Left	*/
		size = 3;			/* size is 3 bytes	*/
		start(sc,setp.omod == 2 ?	/* 8200 no odd value...	*/
			d & 0xfffe : d,128);
		break;
	case  0: case  1: case  3:		/* CG original cmmds...	*/
	case  5: case  7: case  8:
	case 15: case 16: case 17:
	case 21:

	case 29: case 30: case 31:		/* GOG own cmmds...	*/
	case 32: case 33: case 44:
	next:					/* size is 3 bytes	*/
		size = 3;
						/* or different size	*/
	case 22:				/* if Typeface cmmd	*/
		start(sc,d,128);		/* set next 2 cmd codes */
		break;
	default:				/* others ? unknown...	*/
		size = 0;
		break;
	}
	if (fct == 11)				/* Horizontal position	*/
		disp = d;
	else
	if (fct == 22) {			/* Typeface command	*/
		size = 9;
		for (i = 3;i != 9;++i) {
			c = (*cpl++ << 4);
			c |= (*cpl++ & 0x0f);
			sc[i] = c;
		}
	}
	else
	if (fct == 27)				/* Horizontal move Right*/
		disp += d;
	else
	if (fct == 28) {			/* Horizontal move Left */
	  if (disp >= d)
		disp -= d;
	}
	if (size) movcmds(sc,size);
} 

long_char_for(c,d)
unsigned char	c;
unsigned	d;
{
	unsigned char	sc[4];
	
	sc[0] = c | 0x80;
/*	sc[1] = sc[2] = 0;	*/
	start(sc,(setp.omod == 2) ? disp & 0xfffe:disp,0);
	disp += d;
	movcmds(sc,3);
}

movcmds(sc,lim)
unsigned char	*sc;
unsigned	lim;
{
	struct	slvll	*nslv;

	if ((utinpt + lim) < (Bslv->bufptr + UTSIZE)) {
doit:		f_move(sc,utinpt,lim);
		utinpt += lim;
	}
	else {
		*utinpt++ = 0x80 | SLVEOB;
		*utinpt   = 0x80;
		if (!(nslv = getslvbuf()))	/* get new list member	*/
			cpabt = 7;
		else {
			Bslv->fptr = nslv;	/* add member to list	*/
			Bslv	= nslv;
			utinpt	= Bslv->bufptr;	/* reset buf pointer	*/
			goto doit;
		}
	}
}

accval(fg,d)
char	 *fg;
unsigned *d;
{
	if (*fg) *d = *d + 1;
	if (*d % 2) {
		*fg = 1;
		*d &= 0xfffe;
	}
	else	*fg = 0;
}
