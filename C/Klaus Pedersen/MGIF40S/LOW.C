#define V_HIST			/* def for vertical histogram */
#undef DBL_LOOP			/* def for for(x..., for(y... loops */
#undef FULL_SCREEN		/* def to write entire screen, not just wxh */

/*
 *	low.c - low level stuff for mgif.
 */

/* Last changed by Bill 91/6/14 v 1.0 */
static char *sccsid  = "@(#) low.c 1.1 rosenkra(1.0)  92/11/09 Klockars\0\0";

/* #include <stdio.h>	Included via proto.h */
#include <osbind.h>
/* #include "mgif.h"	Included via proto.h */

#ifndef __LATTICE__
#include "proto.h"	/* Lattice C should have this precompiled */
#endif


/*
 *	globals
 */
extern int	Batch;


/*
 *	local functions
 */

/*
int		do_hist ();
int		draw_hist ();
int		drhhist ();
int		drvhist ();
int		grid ();
int		do_line ();		/* atari ST (line A) *
void		xor_line ();
void		xor_dash ();		/* atari ST (line A) *
int		cursor ();		/* atari ST (gemdos, vt52) *
int		clr_cmd ();		/* atari ST (gemdos, vt52) *
int		mv_cursor ();		/* atari ST (vt52) *
int		clr_screen ();		/* atari ST (gemdos, vt52) *
long		do_time ();		/* atari ST (gemdos, sysvar) *
int		check_key ();		/* atari ST (BIOS) *
int		get_key ();
int		get_string ();
long		get_rkey ();
int		get_xypos ();
int		wait_key ();		/* atari ST (BIOS) *
int		wait_ms ();
*/



/*------------------------------*/
/*	do_hist			*/
/*------------------------------*/
do_hist (pras, w, h, hist)
uchar_t	       *pras;
int		w;
int		h;
long	       *hist;
{
	long			x;
	long			y;
	register long		ii;
	register long		lim;
	register uchar_t       *ps;
	register long	       *ph;
	register uint_t		hval;		/* ptr into Hist */


	for (ph = hist, ii = 0L; ii < HISTSIZ; ii++)
		*ph++ = 0L;

#ifdef DBL_LOOP
	for (y = 0; y < h; y++)
	{
		for (x = 0; x < w; x++)
		{
			hval        = (uint_t) (pras[(y*w) + x]);
			hist[hval] += 1;
		}
	}
#else
	lim = (long) h * (long) w;
	for (ph = hist, ps = pras, ii = 0L; ii < lim; ii++, ps++)
	{
		hval      = (uint_t) *ps;
		ph[hval] += 1;
	}
#endif

	return (1);
}




/*------------------------------*/
/*	draw_hist		*/
/*------------------------------*/
int draw_hist (hist)
long   *hist;
{

/*
 *	draw histogram
 */

	long	hmax;
	int	x1,
 		x2,
 		y1,
 		y2;
	long	htot;
	long	ii;


	/*
	 *   find max values in histo for scaling. also total pixels (should
	 *   be w*h)
	 */
	for (htot = 0, hmax = 0, ii = 0; ii < HISTSIZ; ii++)
	{
		htot += hist[ii];

		if (hist[ii] > hmax)
			hmax = hist[ii];
	}


	/*
	 *   overall histogram...
	 */
#ifdef V_HIST
	x1 = 100; 		y1 = 88;
 	x2 = x1 + HISTSIZ; 	y2 = y1 + 208;

	drvhist (hist, HISTSIZ, hmax, x1, y1, x2, y2, 4, 1, 1);
	mv_cursor ( 0, 19); printf ("           00                               FF");
	mv_cursor ( 0,  5); printf ("    %6ld", hmax);
	mv_cursor ( 0, 18); printf ("         0");
#else
	x1 = 100; 	y1 = 50;
 	x2 = x1 + 400; 	y2 = y1 + HISTSIZ;

	drhhist (hist, HISTSIZ, hmax, x1, y1, x2, y2, 4, 1, 1);
	mv_cursor ( 0,  3); printf ("     00");
	mv_cursor ( 0, 19); printf ("     FF");
#endif


	/*
	 *   legends
	 */
	mv_cursor ( 1,  1); printf ("  Histogram for this image:");
	mv_cursor ( 1, 22); printf ("  Total pixels %ld", htot);
}




/*------------------------------*/
/*	drhhist			*/
/*------------------------------*/
int drhhist (hst, hstsiz, hmax, xmn, ymn, xmx, ymx, bordr, vspace, barsize)
long   *hst;
int	hstsiz;
long	hmax;
int	xmn;
int	ymn;
int	xmx;
int	ymx;
int	bordr;
int	vspace;
int	barsize;
{

/*
 *	draw a histogram, vertical axis, horizontal values. UL/LR corners
 *	specified (pixel coord). border outside the corners if bordr >= 0.
 *	vert spacing (in pixels) given by vspace. if hmax is > 0, scale
 *	the length to this value, otherwise automatically scale to fit.
 *
 *	 ____________________________________________
 *	|   /----- start here: (xmn,ymn)	     |<-- border, drawn
 *	|  +XXXXXXXXXXXXXXXXXXXXXXXXX                |    if bordr >= 0
 *	|  XXXXXXXXX                                 |
 *	|  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  |
 *	|  XXXXXXXXXXXXXXXXXXX                       |
 *	.					     .
 *	.					     .
 *	.					     .
 *	|  XXXXXXXXXXXXX                             |
 *	|  XXXXXXXXXXXXXXXXXXXXXXXXX              +  |
 *	|____________________________________________|
 *
 *	width of each bar given by barsize (in pixels). vspace should include
 *	barsize:
 *
 *	XXXXXXXXXXXXXXXXXXXXXX ------------------------------------------
 *	XXXXXXXXXXXXXXXXXXXXXX			barsize(=3)
 *	XXXXXXXXXXXXXXXXXXXXXX ----------------------------    vspace(=4)
 *	
 *	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX---------------------------------
 *	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 *	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 */

	int	i;
	int	j;
	int	x1,
 		x2,
 		y1,
 		y2;
	long	xsz;


	/*
	 *   check data...
	 */
	if (vspace < 1)
		vspace = 1;
	if ((vspace * hstsiz) > (ymx - ymn + 1))
		vspace = (ymx - ymn) / hstsiz;
	if (vspace < 1)
		return;
	if (barsize > vspace)
		barsize = vspace;


	/*
	 *   find max value if necessary...
	 */
	if (hmax < 0)
	{
		hmax = 0;
		for (i = 0; i < hstsiz; i++)
		{
			if (hst[i] > hmax)
				hmax = hst[i];
		}
	}


	/*
	 *   draw box around histogram
	 */
	if (bordr >= 0)
	{
		do_line (xmn-bordr, ymn-bordr, xmx+bordr, ymn-bordr);
		do_line (xmn-bordr, ymn-bordr, xmn-bordr, ymx+bordr);
		do_line (xmx+bordr, ymx+bordr, xmx+bordr, ymn-bordr);
		do_line (xmx+bordr, ymx+bordr, xmn-bordr, ymx+bordr);
	}


	/*
	 *   draw the lines. note that a "baseline" could appear because for
	 *   hst entries of 0, the line is just a dot so we do not draw these.
	 */
	xsz = (long) (xmx - xmn);
	for (i = 0; i < hstsiz; i++)
	{
		x1 = xmn;
		y1 = ymn + (i * vspace);
		x2 = x1 + (int) ((xsz * hst[i]) / hmax);
		y2 = y1;
		if (x2 - x1 > 0)
		{
			for (j = 0; j < barsize; j++, y1++, y2++)
				do_line (x1, y1, x2, y2);
		}
	}
}




/*------------------------------*/
/*	drvhist			*/
/*------------------------------*/
int drvhist (hst, hstsiz, hmax, xmn, ymn, xmx, ymx, bordr, hspace, barsize)
long   *hst;
int	hstsiz;
long	hmax;
int	xmn;
int	ymn;
int	xmx;
int	ymx;
int	bordr;
int	hspace;
int	barsize;
{

/*
 *	draw a histogram, horizontal axis, vertical values. UL/LR corners
 *	specified (pixel coord). border outside the corners if bordr >= 0.
 *	vert spacing (in pixels) given by hspace. if hmax is > 0, scale
 *	the length to this value, otherwise automatically scale to fit.
 *
 *	 _________ . . . _____
 *	|    X    	      |<-- border, drawn
 *	|    X   X	  X   |    if bordr >= 0
 *	|    XX  X	  X   |
 *	|    XX  X	  X   |
 *	|  X XXX X	 XX   |
 *	|  X XXX X	 XXX  |
 *	|  X XXXXX	 XXX  |
 *	|  +XXXXXX	 XXXX |
 *	|  \-- start here:    |
 *	|      (xmn,ymn)      |
 *	|_________ . . . _____|
 *
 *	width of each bar given by barsize (in pixels). hspace should include
 *	barsize:
 *
 *	  /-------- barsize(=3)
 *	  |   /---- hspace(=4)
 *	| | | | |
 *	| | | v |
 *	| | |<->|
 *	| | |   |
 *	| |||  ||
 *	| v||  ||
 *	|<>||  ||
 *	|  ||  ||
 *	XXX |  ||
 *	XXX |  ||
 *	XXX |  |XXX
 *	XXX |  |XXX
 *	XXX XXX XXX
 *	XXX XXX XXX
 *	XXX XXX XXX
 */

	int	i;
	int	j;
	int	x1,
 		x2,
 		y1,
 		y2;
	long	ysz;


	/*
	 *   check data...
	 */
	if (hspace < 1)
		hspace = 1;
	if ((hspace * hstsiz) > (xmx - xmn + 1))
		hspace = (xmx - xmn) / hstsiz;
	if (hspace < 1)
		return;
	if (barsize > hspace)
		barsize = hspace;


	/*
	 *   find max value if necessary...
	 */
	if (hmax < 0)
	{
		hmax = 0;
		for (i = 0; i < hstsiz; i++)
		{
			if (hst[i] > hmax)
				hmax = hst[i];
		}
	}


	/*
	 *   draw box around histogram
	 */
	if (bordr >= 0)
	{
		do_line (xmn-bordr, ymn-bordr, xmx+bordr, ymn-bordr);
		do_line (xmn-bordr, ymn-bordr, xmn-bordr, ymx+bordr);
		do_line (xmx+bordr, ymx+bordr, xmx+bordr, ymn-bordr);
		do_line (xmx+bordr, ymx+bordr, xmn-bordr, ymx+bordr);
	}


	/*
	 *   draw the lines. note that a "baseline" could appear because for
	 *   hst entries of 0, the line is just a dot so we do not draw these.
	 */
	ysz = (long) (ymx - ymn);
	for (i = 0; i < hstsiz; i++)
	{
		y1 = ymx;
		y2 = y1 - (int) ((ysz * hst[i]) / hmax);
		x1 = xmn + (i * hspace);
		x2 = x1;

		if (y1 - y2 > 0)
		{
			for (j = 0; j < barsize; j++, x1++, x2++)
				do_line (x1, y1, x2, y2);
		}
	}
}




/*------------------------------*/
/*	grid			*/
/*------------------------------*/
grid (x, y, w, h, sp)
int	x;
int	y;
int	w;
int	h;
int	sp;
{
	int	i;

	/*
	 *   limit the grid so as not to go off screen! else line A will
	 *   crash...
	 */
	if (x < 0)
		x = 0;
	if (y < 0)
		y = 0;
	if (x+w >= 640)
		w = 640 - x - 1;
	if (y+h >= 400)
		h = 400 - y - 1;


	/*
	 *   verticals
	 */
	for (i = x; i < x+w; i += sp)
		xor_dash (i, y, i, y+h-1);

	/* last (right) one */
	xor_dash (x+w-1, y, x+w-1, y+h-1);


	/*
	 *   horizontals
	 */
	for (i = y; i < y+h; i += sp)
		xor_dash (x, i, x+w-1, i);

	/* last (bottom) one */
	xor_dash (x, y+h-1, x+w-1, y+h-1);
}




/*------------------------------*/
/*	do_line			*/
/*------------------------------*/
do_line (x1, y1, x2, y2)
int	x1, y1, x2, y2;
{

/*
 *	draw a line from (x1,y1) to (x2,y2). uses line A
 */
	/* NEW, differing declarations */
#ifdef __GNUC__
	extern long	linea0 ();
	extern int	linea3 ();
#endif
#ifdef __LATTICE__
	extern long __stdargs linea0 ();
	extern int  __stdargs linea3 ();
#endif
#ifdef __TURBOC__
	extern long cdecl linea0 ();
	extern int  cdecl linea3 ();
#endif

	static long	A_ptr = 0L;


	/*
	 *   line A init first, if needed
	 */
	if (!A_ptr)
		A_ptr = linea0 ();

	linea3 (A_ptr, x1, y1, x2, y2, 0, 0xFFFF, 0);

}




/*------------------------------*/
/*	xor_line		*/
/*------------------------------*/
void xor_line (x1, y1, x2, y2)
int	x1, y1, x2, y2;
{

/*
 *	draw a line from (x1,y1) to (x2,y2), XOR. uses line A
 */
	/* NEW, differing declarations */
#ifdef __GNUC__
	extern long	linea0 ();
	extern int	linea3 ();
#endif
#ifdef __LATTICE__
	extern long __stdargs linea0 ();
	extern int  __stdargs linea3 ();
#endif
#ifdef __TURBOC__
	extern long cdecl linea0 ();
	extern int  cdecl linea3 ();
#endif

	static long	A_ptr = 0L;


	/*
	 *   line A init first, if needed
	 */
	if (!A_ptr)
		A_ptr = linea0 ();

	linea3 (A_ptr, x1, y1, x2, y2, 2, 0xffff, 0);
}




/*------------------------------*/
/*	xor_dash		*/
/*------------------------------*/
void xor_dash (x1, y1, x2, y2)
int	x1, y1, x2, y2;
{

/*
 *	draw a line from (x1,y1) to (x2,y2), XOR. uses line A
 */
	/* NEW, differing declarations */
#ifdef __GNUC__
	extern long	linea0 ();
	extern int	linea3 ();
#endif
#ifdef __LATTICE__
	extern long __stdargs linea0 ();
	extern int  __stdargs linea3 ();
#endif
#ifdef __TURBOC__
	extern long cdecl linea0 ();
	extern int  cdecl linea3 ();
#endif

	static long	A_ptr = 0L;


	/*
	 *   line A init first, if needed
	 */
	if (!A_ptr)
		A_ptr = linea0 ();

	linea3 (A_ptr, x1, y1, x2, y2, 2, 0x3333, 0);
}




/*------------------------------*/
/*	cursor			*/
/*------------------------------*/
cursor (visible)
int	visible;
{

/*
 *	turn cursor on/off
 */

	if (visible)
		Cconws ("\33e");
	else
		Cconws ("\33f");
}




/*------------------------------*/
/*	clr_cmd			*/
/*------------------------------*/
clr_cmd ()
{

/*
 *	clear "command" line
 */

	mv_cursor (0, 24);
	Cconws ("\33K");
}




/*------------------------------*/
/*	mv_cursor		*/
/*------------------------------*/
mv_cursor (col, row)
int	col;
int	row;
{

/*
 *	move cursor to row,col (0,0 is UL corner). for printing
 */

	int	esc = 0x1B;
	int	spc = 0x20;
	char	msg[10];

	msg[0] = esc;
	msg[1] = 'Y';
	msg[2] = row + spc;
	msg[3] = col + spc;
	msg[4] = 0;
	

/*	sprintf (msg, "%cY%c%c\0", (char) esc, (char) (row + spc), (char) (col + spc)); */
	Cconws (msg);
}




/*------------------------------*/
/*	clr_screen		*/
/*------------------------------*/
clr_screen ()
{

/*
 *	clear screen, home cursor
 */

	Cconws ("\33E");
}




/*------------------------------*/
/*	do_time			*/
/*------------------------------*/
long do_time (opt)
int	opt;				/* 0=init,1=start,2=end (ret elapsed)*/
{

/*
 *	timing functions. here we time using 200 Hz system timer
 */

	static ulong_t	start;
	static ulong_t	stop;

	long		savessp;
	ulong_t		elapsed;		/* seconds */


	switch (opt)
	{
	case 0:						/* reset clock */
	case 1:						/* start clock */
		savessp = Super (0L);
		start   = *(long *) (0x4ba);
		Super (savessp);
		break;

	case 2:						/* stop and elapsed */
		savessp = Super (0L);
		stop    = *(long *) (0x4ba);
		Super (savessp);

		if (stop < start)
			elapsed = (long) (stop - start + 0x7FFFFFFFL) / 200L;
		else
			elapsed = (long) (stop - start) / 200L;

		return ((long) elapsed);
	}

	return (0L);

}




/*------------------------------*/
/*	check_key		*/
/*------------------------------*/
int check_key ()
{

/*
 *	ckecks for a key and flushes keyboard buffer.
 */

	if (Bconstat (2))			/* if CONSOLE has a char... */
	{
		while (Bconstat (2))		/* read char while there are */
			Bconin (2);		/* chars to read (flush) */

		return (1);			/* yes, there was a key */
	}

	return (0);				/* no key */
}




/*------------------------------*/
/*	get_key			*/
/*------------------------------*/
int get_key ()
{

/*
 *	gets a key. just the ascii part of Bconin. only low byte is filled.
 */

	long	ret;

	cursor (1);
	while (!Bconstat (2))		/* wait for a key... */
		;
	ret = Bconin (2) & 0x000000ffL;/* get key */
	cursor (0);

	return ((int) ret);
}




/*------------------------------*/
/*	get_string		*/
/*------------------------------*/
get_string (n, buf)
int	n;		/* <= 125 */
char   *buf;
{
	int		i;
	uint_t		num;

	if (n > 125)
		n = 125;
	buf[0] = (char) n;
	cursor (1);
	Cconrs (buf);
	cursor (0);
	num = (uint_t) buf[1];
	for (i = 0; i < num; i++)
		buf[i] = buf[i+2];
	buf[num] = '\0';
}




/*------------------------------*/
/*	get_rkey		*/
/*------------------------------*/
long get_rkey ()
{

/*
 *	gets a key. the full long is returned
 */

	long	ret;

	while (!Bconstat (2))		/* wait for a key... */
		;

	while (Bconstat (2))		/* read char while there are */
		ret =	Bconin (2);		/* chars to read (flush) */
					/* NEW?, the two lines above added? */

	return ((long) ret);
}




/*------------------------------*/
/*	get_xypos		*/
/*------------------------------*/
int get_xypos (opt, type, xorg, yorg, width, height, rwidth, rheight, xstart, ystart, x, y)
int	opt;		/* 0=vert(hor pos), 1=horiz(vert pos), 2=both */
int	type;		/* 0=xhair, 1=box */
int	xorg;		/* UL of limit rect */
int	yorg;
int	width;		/* size of limit rect */
int	height;
int	rwidth;		/* size of rect if type=box */
int	rheight;
int	xstart;		/* start position */
int	ystart;
int    *x;		/* returned coords */
int    *y;
{

/*
 *	draw crosshair or box, let user move with arrow (8 pixel) or
 *	shift-arrows (1 pixel) and return final x,y. return value is as
 *	follows:
 *
 *		if INSERT
 *			ret = 1
 *		else
 *			ret = 0
 *
 *	space to confine cursor/box to is defined by xorg, yorg, width, height.
 *	coord of last point returned in x,y no matter how we exit. crosshair
 *	starts at (xstart,ystart). ClrHome moves to xorg,yorg, shift-ClrHome
 *	moves to (xstart,ystart). box specified with xstart,ystart,rwidth,
 *	rheight.
 */

	register long	lkey;
	register int	drawit;
	register int	xpos;
	register int	ypos;
	int		xrlim, xllim;
	int		yulim, yllim;
	int		i;
	int		done;
	int		ret;
	int		shft;			/* NEW,  shift keys */


	/*
	 *   check for bad input...
	 */
	if (width > 640)
		width = 640;
	if (height > 400)
		height = 400;
	if ((width < 2) || (height < 2))
		return (0);
	if ((xorg < 0) || (xorg >= 640))
		return (0);
	if ((yorg < 0) || (yorg >= 400))
		return (0);
	if (xorg + width - 1 > 640)			/* NEW, changed */
		if ((width = 640 - xorg) < 0)
			return(0);
	if (yorg + height - 1 > 400)			/* NEW, changed */
		if ((height = 400 - yorg) < 0)
			return(0);
	if ((xstart > xorg + width - 1) || (xstart < xorg))
		return (0);
	if ((ystart > yorg + height - 1) || (ystart < yorg))
		return (0);


	/*
	 *   set start positions and limits
	 */
	xpos = xstart;
	ypos = ystart;

	if (type == 0)
	{
		xllim = xorg;
		xrlim = xllim + (width-1);
		yulim = yorg;
		yllim = yorg + (height-1);
	}
	else
	{
		xllim = xorg;
		xrlim = xllim + (rwidth-1);
		yulim = yorg;
		yllim = yorg + (rheight-1);
	}


	/*
	 *   draw initial position crosshair (xor mode)...
	 */
	if (type == 0)
	{
		switch (opt)
		{
		case H_COORD:
			xor_line (xpos,yulim,xpos,yllim);	/* vert */
			break;
		case V_COORD:
			xor_line (xllim,ypos,xrlim,ypos);	/* horiz */
			break;
		case VH_COORD:
			xor_line (xpos,yulim,xpos,yllim);	/* vert */
			xor_line (xllim,ypos,xrlim,ypos);	/* horiz */
			break;
		default:
			return (0);
			break;
		}
	}
	else
	{
		xor_line (xpos,ypos,xpos,ypos+rheight-1);
		xor_line (xpos,ypos,xpos+rwidth-1,ypos);
		xor_line (xpos,ypos+rheight-1,xpos+rwidth-1,ypos+rheight-1);
		xor_line (xpos+rwidth-1,ypos,xpos+rwidth-1,ypos+rheight-1);
	}


	/*
	 *   directions (on cmd line)
	 */
	mv_cursor (0,24);
printf ("ARROWS 8 pix, Shift-ARROWS 1 pix. INSERT detects, any other quit.            ");


	/*
	 *   loop...
	 */
	done = 0;
	ret  = 0;
	while (!done)
	{
		/*
		 *   get raw key, update coord on screen...
		 */
		mv_cursor (70,24); printf ("%3d,%3d", xpos, ypos);
		lkey = get_rkey ();
		shft = Kbshift(-1);	/* NEW, check shift keys */
					/* See also below at key check */
		
#if 0
		mv_cursor (70,23); printf ("%08lx", lkey);
#endif

		/*
		 *   undraw...
		 */
		if (type == 0)
		{
			switch (opt)
			{
			case H_COORD:
				xor_line (xpos,yulim,xpos,yllim);	/* vert */
				break;
			case V_COORD:
				xor_line (xllim,ypos,xrlim,ypos);	/* horiz */
				break;
			case VH_COORD:
				xor_line (xpos,yulim,xpos,yllim);	/* vert */
				xor_line (xllim,ypos,xrlim,ypos);	/* horiz */
				break;
			}
		}
		else
		{
			xor_line (xpos,ypos,xpos,ypos+rheight-1);
			xor_line (xpos,ypos,xpos+rwidth-1,ypos);
			xor_line (xpos,ypos+rheight-1,xpos+rwidth-1,ypos+rheight-1);
			xor_line (xpos+rwidth-1,ypos,xpos+rwidth-1,ypos+rheight-1);
		}


		/*
		 *   what key?
		 */
		if ((lkey == RARROW) && !shft)		/* right arrow */
		{
			/*
			 *   some arrows not used for some opts, so check
			 */
			if (opt != V_COORD)
			{
				/*
				 *   bump it and check if beyond limit
				 */
				xpos += 8;
				if (xpos > xrlim)
				{
					/*
					 *   if so, limit and bell
					 */
					xpos = xrlim;
					Cconws ("\07");
				}
			}
		}
		else if (lkey == RARROW)		/* shift right arrow */
		{
			if (opt != V_COORD)
			{
				xpos += 1;
				if (xpos > xrlim)
				{
					xpos = xrlim;
					Cconws ("\07");
				}
			}
		}
		else if ((lkey == LARROW) && !shft)		/* left arrow */
		{
			if (opt != V_COORD)
			{
				xpos -= 8;
				if (xpos < xllim)
				{
					xpos = xllim;
					Cconws ("\07");
				}
			}
		}
		else if (lkey == LARROW)		/* shift left arrow */
		{
			if (opt != V_COORD)
			{
				xpos -= 1;
				if (xpos < xllim)
				{
					xpos = xllim;
					Cconws ("\07");
				}
			}
		}
		else if ((lkey == UARROW) && !shft)		/* up arrow */
		{
			if (opt != H_COORD)
			{
				ypos -= 8;
				if (ypos < yulim)
				{
					ypos = yulim;
					Cconws ("\07");
				}
			}
		}
		else if (lkey == UARROW)		/* shift up arrow */
		{
			if (opt != H_COORD)
			{
				ypos -= 1;
				if (ypos < yulim)
				{
					ypos = yulim;
					Cconws ("\07");
				}
			}
		}
		else if ((lkey == DARROW) && !shft)		/* down arrow */
		{
			if (opt != H_COORD)
			{
				ypos += 8;
				if (ypos > yllim)
				{
					ypos = yllim;
					Cconws ("\07");
				}
			}
		}
		else if (lkey == DARROW)		/* shift down arrow */
		{
			if (opt != H_COORD)
			{
				ypos += 1;
				if (ypos > yllim)
				{
					ypos = yllim;
					Cconws ("\07");
				}
			}
		}


		else if (lkey == INSERT)
		{
			ret  = 1;
			done = 1;
/*			mv_cursor (70,23); printf ("INSERT  ", lkey);*/
		}
		else if ((lkey == CLRHOME) && !shft)
		{
			/*
			 *   move to org point
			 */
			xpos = xorg + 3;
			ypos = yorg + 3;
/*			mv_cursor (70,23); printf ("CLRHOME ", lkey);*/
		}
		else if (lkey == CLRHOME)		/* shift clrhome */
		{
			/*
			 *   move to start point
			 */
			xpos = xstart;
			ypos = ystart;
/*			mv_cursor (70,23); printf ("S_CLRHOM", lkey);*/
		}
#if 0
		else if (lkey == S_INSERT)
		{
			mv_cursor (70,23); printf ("S_INSERT", lkey);
		}
		else if (lkey == HELP)
		{
			mv_cursor (70,23); printf ("HELP    ", lkey);
		}
		else if (lkey == UNDO)
		{
			mv_cursor (70,23); printf ("UNDO    ", lkey);
		}
#endif


		else
		{
			/*
			 *   any other key causes us to quit...
			 */
			done = 1;
		}





		/*
		 *   check for exit condition...
		 */
		if (done)
			break;


		/*
		 *   draw new postion
		 */
		if (type == 0)
		{
			switch (opt)
			{
			case H_COORD:
				xor_line (xpos,yulim,xpos,yllim);	/* vert */
				break;
			case V_COORD:
				xor_line (xllim,ypos,xrlim,ypos);	/* horiz */
				break;
			case VH_COORD:
				xor_line (xpos,yulim,xpos,yllim);	/* vert */
				xor_line (xllim,ypos,xrlim,ypos);	/* horiz */
				break;
			}
		}
		else
		{
			xor_line (xpos,ypos,xpos,ypos+rheight-1);
			xor_line (xpos,ypos,xpos+rwidth-1,ypos);
			xor_line (xpos,ypos+rheight-1,xpos+rwidth-1,ypos+rheight-1);
			xor_line (xpos+rwidth-1,ypos,xpos+rwidth-1,ypos+rheight-1);
		}
	}



	/*
	 *   set return values
	 */
	*x = xpos;
	*y = ypos;

	return (ret);
}




/*------------------------------*/
/*	wait_key		*/
/*------------------------------*/
wait_key ()
{

/*
 *	waits for a key and flushes keyboard buffer.
 */

	if (Batch)
	{
		wait_ms (1000);
	}
	else
	{
		while (!Bconstat (2))		/* wait for a key... */
			;

		while (Bconstat (2))		/* keep reading while there */
			Bconin (2);		/* are key inputs... */
	}
}




/*------------------------------*/
/*	wait_ms			*/
/*------------------------------*/

#define MSLOOP		192			/* for function */

wait_ms (ms)
int	ms;
{

/*
 *	wait the presribed number of milliseconds. nothing fancy, just
 *	kill time...
 */

	int	i;

	/*
	 *   trivial case (no neg wait)
	 */
	if (ms <= 0)
		return;

	/*
	 *   here we do the loop. inner one is just about 1 ms
	 */
	for ( ; ms > 0; ms--)
		for (i = MSLOOP; i > 0; i--)
			;
	return;
}





