#undef DBL_LOOP			/* def for for(x..., for(y... loops */
#undef INL_SORT			/* def to inline piksrt() in median() */

/*
 *	process.c - all the image processing functions.
 */

/* Last changed by Bill 91/6/9 */
static char *sccsid = "@(#) process.c 1.4 rosenkra(13) 92/11/09 Klockars\0\0";

/* #include <stdio.h>	Included via proto.h */
/* #include "mgif.h"	Included via proto.h */

#ifndef __LATTICE__
#include "proto.h"	/* Lattice C should have this precompiled */
#endif

/* NEW, used to be constants */
extern long MAXRAW, MAXIMG;

/*
 *	local functions
 */

/*
int		larger ();		/* frame processes... *
int		zoom ();
int		smaller ();
int		cut ();
int		rotate ();
int		mirror ();
int		convolve ();		/* area processes... *
int		blur ();
int		median ();
int		piksrt ();
int		logscale ();		/* point processes... *
int		Log2x10 ();
int		contrast ();
int		brighten ();
int		invert ();
int		threshold ();
int		histeq ();
int		redistribute ();
int		copyrast ();		/* others... *
*/

/*
 *	external functions
 */

/*
extern int	do_hist ();
extern int	copyrast ();
*/

/*------------------------------*/
/*	larger			*/
/*------------------------------*/

#define L_BOTH		0
#define L_HOR		1
#define L_VERT		2

int larger (pras, w, h, opt, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		opt;		/* checked by caller! */
uchar_t	       *ptrans;
{

/*
 *	enlarge an image (so far 320x200 -> 640x400). return 1 if
 *	successful, else 0.
 */

	register uchar_t       *pr;
	register uchar_t       *pt;
	register long		x;
	register long		y;
	long			x2;
	long			y2;
	register long		wold;
	long			hold;
	register long		w2;
	long			h2;


	/*
	 *   fail if enlarged image will be too big for buffer
	 */
#if 0
	if ((w > 320) || (h > 200))
		return (0);
#endif
	switch (opt)
	{
	case L_BOTH:
		if (4L * (long) w * (long) h > MAXIMG)
			return (0);
		break;
	case L_HOR:
		if (2L * (long) w * (long) h > MAXIMG)
			return (0);
		break;
	case L_VERT:
		if (2L * (long) w * (long) h > MAXIMG)
			return (0);
		break;
	}



	/*
	 *   here we always do the transform in situ (in ptrans)...
	 */
	if (pras == ptrans)
	{
		/*
		 *   do in place...
		 */
		pr = pras;
		pt = pras;
	}
	else
	{
		/*
		 *   copy to new image
		 */
		pr = pras;
		pt = ptrans;

		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
		pr = ptrans;
	}


	wold = w;
	hold = h;
	switch (opt)
	{
	case L_BOTH:
		/*
		 *   set new sizes
		 */
		w2 = wold*2L;
		h2 = hold*2L;


		/*
		 *   shift existing data:
		 *
		 *	  0123456789
		 *	0|**********|			*=existing pixels
		 *	1|**********|			+=new pixels
		 *	.
		 *	.
		 *	     |
		 *	     v
		 *	            1111111111
		 *	  01234567890123456789
		 *	0|                    |
		 *	1| + + + + + + + + + +|
		 *	2|                    |
		 *	3| + + + + + + + + + +|
		 *	.
		 *	.
		 */
		for (y = hold-1; y >= 0; y--)
		{
			for (x = wold-1; x >= 0; x--)
			{
				x2 = (2*x)+1;
				y2 = (2*y)+1;
				pt[y2*w2 + x2] = pt[y*wold + x];
			}
		}


		/*
		 *   now make intermediate points within row (average):
		 *
		 *	            1111111111
		 *	  01234567890123456789
		 *	0|                    |		*=existing pixels
		 *	1|+*+*+*+*+*+*+*+*+*+*|		+=new pixels
		 *	2|                    |
		 *	3|+*+*+*+*+*+*+*+*+*+*|
		 *	.
		 *	.
		 */
		for (y = 1; y < h2; y += 2)
		{
			/* first point is duplicate of second */
			pt[y*w2 + 0] = pt[y*w2 + 1];

			/* others are average */
			for (x = 2; x < w2; x += 2)
			{
				pt[y*w2 + x] = (uchar_t) (
					 ((uint_t) pt[y*w2 + (x-1)]
					+ (uint_t) pt[y*w2 + (x+1)]) / 2);
			}
		}


		/*
		 *   first row is duplicate of second row:
		 *
		 *	            1111111111
		 *	  01234567890123456789
		 *	0|++++++++++++++++++++|<---
		 *	1|********************|		*=existing pixels
		 *	2|                    |		+=new pixels
		 *	3|********************|
		 *	.
		 *	.
		 */
		for (x = 0; x < w2; x++)
		{
			pt[x] = pt[w2 + x];
		}


		/*
		 *   finally, make new rows (average):
		 *
		 *	            1111111111
		 *	  01234567890123456789
		 *	0|********************|		*=existing pixels
		 *	1|********************|		+=new pixels
		 *	2|++++++++++++++++++++|<---
		 *	3|********************|
		 *	.
		 *	.
		 */
		for (y = 2; y < h2; y += 2)
		{
			for (x = 0; x < w2; x++)
			{
				pt[y*w2 + x] = (uchar_t) (
					 ((uint_t) pt[(y-1)*w2 + x]
					+ (uint_t) pt[(y+1)*w2 + x]) / 2);
			}
		}
		break;


	case L_HOR:
		/*
		 *   set new sizes
		 */
		w2 = wold*2L;
		h2 = hold;


		/*
		 *   shift existing data:
		 *
		 *	  0123456789
		 *	0|**********|			*=existing pixels
		 *	1|**********|			+=new pixels
		 *	     .
		 *	     .
		 *	     |
		 *	     v
		 *	            1111111111
		 *	  01234567890123456789
		 *	0| + + + + + + + + + +|
		 *	1| + + + + + + + + + +|
		 *	.
		 *	.
		 */
		for (y = hold-1; y >= 0; y--)
		{
			for (x = wold-1; x >= 0; x--)
			{
				x2 = (2*x)+1;
				pt[y*w2 + x2] = pt[y*wold + x];
			}
		}


		/*
		 *   now make intermediate points within row (average):
		 *
		 *	            1111111111
		 *	  01234567890123456789
		 *	0|+*+*+*+*+*+*+*+*+*+*|		*=existing pixels
		 *	1|+*+*+*+*+*+*+*+*+*+*|		+=new pixels
		 *	.
		 *	.
		 */
		for (y = 0; y < hold; y++)
		{
			/* first point is duplicate of second */
			pt[y*w2 + 0] = pt[y*w2 + 1];

			/* others are average */
			for (x = 2; x < w2; x += 2)
			{
				pt[y*w2 + x] = (uchar_t) (
					 ((uint_t) pt[y*w2 + (x-1)]
					+ (uint_t) pt[y*w2 + (x+1)]) / 2);
			}
		}
		break;

	case L_VERT:
		/*
		 *   set new sizes
		 */
		w2 = wold;
		h2 = hold*2L;


		/*
		 *   shift existing data:
		 *
		 *	  0123456789
		 *	0|**********|			*=existing pixels
		 *	1|**********|			+=new pixels
		 *	.
		 *	.
		 *	     |
		 *	     v
		 *	  0123456789
		 *	0|          |
		 *	1|++++++++++|
		 *	2|          |
		 *	3|++++++++++|
		 *	.
		 *	.
		 */
		for (y = hold-1; y >= 0; y--)
		{
			for (x = wold-1; x >= 0; x--)
			{
				y2 = (2*y)+1;
				pt[y2*wold + x] = pt[y*wold + x];
			}
		}


		/*
		 *   first row is duplicate of second row:
		 *
		 *	  0123456789
		 *	0|++++++++++|<---
		 *	1|**********|			*=existing pixels
		 *	2|          |			+=new pixels
		 *	3|**********|
		 *	.
		 *	.
		 */
		for (x = 0; x < wold; x++)
		{
			pt[x] = pt[wold + x];
		}


		/*
		 *   finally, make new rows (average):
		 *
		 *	  0123456789
		 *	0|**********|		*=existing pixels
		 *	1|**********|		+=new pixels
		 *	2|++++++++++|<---
		 *	3|**********|
		 *	.
		 *	.
		 */
		for (y = 2; y < h2; y += 2)
		{
			for (x = 0; x < wold; x++)
			{
				pt[y*wold + x] = (uchar_t) (
					 ((uint_t) pt[(y-1)*wold + x]
					+ (uint_t) pt[(y+1)*wold + x]) / 2);
			}
		}
		break;
	}


	return (1);
}




/*------------------------------*/
/*	zoom			*/
/*------------------------------*/
int zoom (pras, w, h, xstart, ystart, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		xstart;
int		ystart;
uchar_t	       *ptrans;
{

/*
 *	zoom in and enlarge an image (so far 2x) starting at xstart,ystart.
 *	return 1 if successful, else 0.
 */

	register uchar_t       *pr;
	register uchar_t       *pt;
	register long		x;
	register long		y;
	long			x2;
	long			y2;
	register long		wold;
	long			hold;
	register long		w2;
	long			h2;



	/*
	 *   enlarged image should ALWAYS fit in buffer!
	 *
	 *   here we always do the transform in situ (in ptrans)...
	 */
	if (pras == ptrans)
	{
		/*
		 *   do in place. pr points to "cut" area, pt to start
		 */
		pr = &pras[xstart + (ystart-1)*w];
		pt = pras;

		/*
		 *   shift smaller image to ul corner of pt
		 */
		if ((xstart != 0) && (ystart != 0))
		{
			for (y = 0L; y < h/2; y++)
			{
				for (x = 0L; x < w/2; x++)
				{
					pt[x + w*(y-1)/2] = pr[x + w*(y-1)];
				}
			}
		}
	}
	else
	{
		/*
		 *   copy to new image
		 */
		pr = &pras[xstart + (ystart-1)*w];
		pt = ptrans;

		/*
		 *   first copy orig image to transform image
		 */
		for (y = 0L; y < h/2; y++)
		{
			for (x = 0L; x < w/2; x++)
			{
				pt[x + w*(y-1)/2] = pr[x + w*(y-1)];
			}
		}
	}



	/*
	 *   set new sizes
	 */
	wold = w/2L;
	hold = h/2L;
	w2   = wold*2L;
	h2   = hold*2L;


	/*
	 *   shift existing data:
	 *
	 *	  0123456789
	 *	0|**********|			*=existing pixels
	 *	1|**********|			+=new pixels
	 *	.
	 *	.
	 *	     |
	 *	     v
	 *	            1111111111
	 *	  01234567890123456789
	 *	0|                    |
	 *	1| + + + + + + + + + +|
	 *	2|                    |
	 *	3| + + + + + + + + + +|
	 *	.
	 *	.
	 */
	for (y = hold-1; y >= 0; y--)
	{
		for (x = wold-1; x >= 0; x--)
		{
			x2 = (2*x)+1;
			y2 = (2*y)+1;
			pt[y2*w2 + x2] = pt[y*wold + x];
		}
	}


	/*
	 *   now make intermediate points within row (average):
	 *
	 *	            1111111111
	 *	  01234567890123456789
	 *	0|                    |		*=existing pixels
	 *	1|+*+*+*+*+*+*+*+*+*+*|		+=new pixels
	 *	2|                    |
	 *	3|+*+*+*+*+*+*+*+*+*+*|
	 *	.
	 *	.
	 */
	for (y = 1; y < h2; y += 2)
	{
		/* first point is duplicate of second */
		pt[y*w2 + 0] = pt[y*w2 + 1];

		/* others are average */
		for (x = 2; x < w2; x += 2)
		{
			pt[y*w2 + x] = (uchar_t) (
				 ((uint_t) pt[y*w2 + (x-1)]
				+ (uint_t) pt[y*w2 + (x+1)]) / 2);
		}
	}


	/*
	 *   first row is duplicate of second row:
	 *
	 *	            1111111111
	 *	  01234567890123456789
	 *	0|++++++++++++++++++++|<---
	 *	1|********************|		*=existing pixels
	 *	2|                    |		+=new pixels
	 *	3|********************|
	 *	.
	 *	.
	 */
	for (x = 0; x < w2; x++)
	{
		pt[x] = pt[w2 + x];
	}


	/*
	 *   finally, make new rows (average):
	 *
	 *	            1111111111
	 *	  01234567890123456789
	 *	0|********************|		*=existing pixels
	 *	1|********************|		+=new pixels
	 *	2|++++++++++++++++++++|<---
	 *	3|********************|
	 *	.
	 *	.
	 */
	for (y = 2; y < h2; y += 2)
	{
		for (x = 0; x < w2; x++)
		{
			pt[y*w2 + x] = (uchar_t) (
				 ((uint_t) pt[(y-1)*w2 + x]
				+ (uint_t) pt[(y+1)*w2 + x]) / 2);
		}
	}

	return (1);
}




/*------------------------------*/
/*	smaller			*/
/*------------------------------*/

#define S_BOTH		0
#define S_HOR		1
#define S_VERT		2

int smaller (pras, w, h, opt, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		opt;		/* checked by caller! */
uchar_t	       *ptrans;
{

/*
 *	reduce an image by half. return 1 if successful, else 0.
 */

	register uchar_t       *pr;
	register uchar_t       *pt;
	register long		x;
	register long		y;
	register long		wold;
	register long		w2;
	long			hold;
	long			h2;


	/*
	 *   there is a limit to what is practical...
	 */
	if ((w < 10) || (h < 10))
		return (0);


	if (pras == ptrans)
	{
		/*
		 *   do in place...
		 */
		pr = pras;
		pt = pras;
	}
	else
	{
		/*
		 *   copy to new image
		 */
		pr = pras;
		pt = ptrans;
	}


	/*
	 *   do it. skip odd lines and pixels
	 */
	wold = w;
	hold = h;
	switch (opt)
	{
	case S_BOTH:
		/*
		 *   set new sizes
		 */
		w2 = wold/2L;
		h2 = hold/2L;

		for (y = 0; y < h2; y++)
		{
			for (x = 0; x < w2; x++)
			{
				pt[y*w2 + x] = pr[2*y*wold + x*2];
			}
		}
		break;

	case S_HOR:
		/*
		 *   set new sizes
		 */
		w2 = wold/2L;
		h2 = hold;

		for (y = 0; y < h2; y++)
		{
			for (x = 0; x < w2; x++)
			{
				pt[y*w2 + x] = pr[y*wold + x*2];
			}
		}
		break;

	case S_VERT:
		/*
		 *   set new sizes
		 */
		w2 = wold;
		h2 = hold/2L;

		for (y = 0; y < h2; y++)
		{
			for (x = 0; x < w2; x++)
			{
				pt[y*w2 + x] = pr[2*y*wold + x];
			}
		}
		break;
	}

	return (1);
}




/*------------------------------*/
/*	cut			*/
/*------------------------------*/
int cut (pras, w, h, x1, y1, x2, y2, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		x1, y1;
int		x2, y2;
uchar_t	       *ptrans;
{

/*
 *	cut out a section of the image from pras to ptrans
 */

	register uchar_t       *pr;
	register uchar_t       *pt;
	register long		x;
	register long		y;
	register long		wold;
	register long		w2;
	register long		h2;


	/*
	 *   check for bad coords...
	 */
	if ((x1 >= x2) || (y1 >= y2))
		return (0);
	if ((x1 < 0) || (x2 < 0) || (y1 < 0) || (y2 < 0))
		return (0);
	if ((x2 >= w) || (y2 >= h))
		return (0);
#if 0
	if ((x2 > 639) || (y2 > 399))
		return (0);
	if ((x2 - x1) > w)		/* don't fail just limit the cut */
		x2 = x1 + w;
	if ((y2 - y1) > h)
		y2 = y1 + h;
#endif


	/*
	 *   set up pointers...
	 */
	if (pras == ptrans)
	{
		/*
		 *   do in place...
		 */
		pr = pras;
		pt = pras;
	}
	else
	{
		/*
		 *   copy to new image
		 */
		pr = pras;
		pt = ptrans;
	}
	

	/*
	 *   do it...
	 */
	wold = w;
	w2   = x2 - x1 + 1;
	h2   = y2 - y1 + 1;
	for (y = 0; y < h2; y++)
	{
		for (x = 0; x < w2; x++)
		{
			pt[y*w2 + x] = pr[(y + y1)*wold + (x + x1)];
		}
	}

	return (1);
}




/*------------------------------*/
/*	rotate			*/
/*------------------------------*/
int rotate (pras, w, h, angle, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		angle;		/* +90, -90, -180 or +180 */
uchar_t	       *ptrans;
{

/*
 *	rotate an image +/-90 or +/-180. does NOT work in place (yet)
 *
 *	based on (rotating about center):
 *
 *		xnew = (x * cos(angle)) + (y * sin(angle))
 *		ynew = (y * cos(angle)) - (x * sin(angle))
 *
 *	note: 45's should be relatively simple:
 *
 *		+45:	xnew = (.707 * x) + (.707 * y)
 *			ynew = (.707 * y) - (.707 * x)
 *
 *		-45:	xnew = (.707 * x) - (.707 * y)
 *			ynew = (.707 * y) + (.707 * x)
 */

	register uchar_t       *pr;
	register uchar_t       *pt;
	register long		xnew;
	register long		ynew;
	register long		wold;
	register long		hold;


	/*
	 *   set up pointers...
	 */
	if (pras == ptrans)
	{
		/*
		 *   can't do in place (yet)...
		 */
		return (0);
	}


	/*
	 *   copy to new image
	 */
	pr = pras;
	pt = ptrans;
	

	/*
	 *   do it...
	 */
	wold = (long) w;
	hold = (long) h;
	switch (angle)
	{
	case 90:
		/*
		 *   counter clockwise:
		 *
		 *	xnew = y		->	y = xnew
		 *	ynew = wold - x - 1		x = wold - ynew - 1
		 *	wnew = hold
		 *	hnew = wold
		 */
		for (ynew = 0L; ynew < wold; ynew++)
		{
			for (xnew = 0L; xnew < hold; xnew++)
			{
			    pt[ynew*hold + xnew] = pr[xnew*wold + (wold-ynew-1)];
			}
		}
		break;

	case -90:
		/*
		 *   clockwise...
		 *
		 *	xnew = hold - y - 1	->	y = hold - xnew - 1
		 *	ynew = x			x = ynew
		 *	wnew = hold
		 *	hnew = wold
		 */
		for (ynew = 0L; ynew < wold; ynew++)
		{
			for (xnew = 0L; xnew < hold; xnew++)
			{
			    pt[ynew*hold + xnew] = pr[(hold-xnew-1)*wold + ynew];
			}
		}
		break;

	case 180:
	case -180:
		/*
		 *   clockwise or counter clockwise...
		 *
		 *	xnew = wold - x - 1	->	x = wold - xnew - 1
		 *	ynew = hold - y - 1		y = hold - ynew - 1
		 *	wnew = wold
		 *	hnew = hold
		 */
		for (ynew = 0L; ynew < hold; ynew++)
		{
			for (xnew = 0L; xnew < wold; xnew++)
			{
			    pt[ynew*wold + xnew] = pr[(hold-ynew-1)*wold + (wold-xnew-1)];
			}
		}
		break;

	default:
		/*
		 *   undefined angle, fail...
		 */
		return (0);
	}

	return (1);
}




/*------------------------------*/
/*	mirror			*/
/*------------------------------*/
int mirror (pras, w, h, opt, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		opt;		/* 0=vert mirror, 1=horiz mirror */
uchar_t	       *ptrans;
{

/*
 *	mirror image.
 *
 *	vert mirror is:
 *
 *		 _______|_______
 *		|	|	|
 *		|	|	|
 *		|	|	|
 *		|_______|_______|
 *			|
 *
 *	horiz mirror is:
 *
 *		 _______________
 *		|		|
 *	      __|_______________|__
 *		|		|
 *		|_______________|
 */

	register uchar_t       *pr;
	register uchar_t       *pt;
	register long		x;
	register long		y;
	register uchar_t	ctemp;


	/*
	 *   set up pointers...
	 */
	if (pras == ptrans)
	{
		/*
		 *   do in place...
		 */
		pr = pras;
		pt = pras;

		if (opt)
		{
			/*
			 *   horizontal mirror
			 */
			for (y = 0L; y < h/2; y++)
			{
				for (x = 0L; x < w; x++)
				{
					ctemp           = pt[y*w + x];
					pt[y*w + x]     = pt[(h-y)*w + x];
					pt[(h-y)*w + x] = ctemp;
				}
			}
		}
		else
		{
			/*
			 *   vertical mirror
			 */
			for (y = 0L; y < h; y++)
			{
				for (x = 0L; x < w/2; x++)
				{
					ctemp           = pt[y*w + x];
					pt[y*w + x]     = pt[y*w + (w-x)];
					pt[y*w + (w-x)] = ctemp;
				}
			}
		}
	}
	else
	{
		/*
		 *   copy to new image
		 */
		pr = pras;
		pt = ptrans;

		if (opt)
		{
			/*
			 *   horizontal mirror
			 */
			for (y = 0L; y < h; y++)
			{
				for (x = 0L; x < w; x++)
				{
					pt[y*w + x] = pr[(h-y-1)*w + x];
				}
			}
		}
		else
		{
			/*
			 *   vertical mirror
			 */
			for (y = 0L; y < h; y++)
			{
				for (x = 0L; x < w; x++)
				{
					pt[y*w + x] = pr[y*w + (w-x-1)];
				}
			}
		}
	}

	return (1);
}




/*------------------------------*/
/*	convolve		*/
/*------------------------------*/

/*
 *	built-in convolution kernels
 *
 *	k[0..8] is kernel (always 3x3)
 *	k[9] is scaling flag: -1=divide, 1=multiply, 0=no scaling
 *	k[10] is scale
 *
 *	example:
 *		for lp1 with flag -1 (divide) and scale 9, use
 *
 *			p = ((p0 * k0) +...+ (p8 * k8)) / 9
 *
 *		for hp2 with flag 0 (no scaling), use
 *
 *			p = (p0 * k0) +...+ (p8 * k8)
 */
int	lp1[11] = { 1, 1, 1,			/* low pass */
		    1, 1, 1,
		    1, 1, 1,	-1, 9};
int	lp2[11] = { 1, 1, 1,
		    1, 2, 1,
		    1, 1, 1,	-1, 10};
int	lp3[11] = { 1, 2, 1,
		    2, 4, 2,
		    1, 2, 1,	-1, 16};

int	hp1[11] = {-1,-1,-1,			/* hi pass */
		   -1, 9,-1,
		   -1,-1,-1,	0, 1};
int	hp2[11] = { 0,-1, 0,
		   -1, 5,-1,
		    0,-1, 0,	0, 1};
int	hp3[11] = { 1,-2, 1,
		   -2, 5,-2,
		    1,-2, 1,	0, 1};

						/* shift edge */
int	se1[11] = { 0, 0, 0,			/* vertical */
		   -1, 1, 0,
		    0, 0, 0,	0, 1};
int	se2[11] = { 0,-1, 0,			/* horizontal */
		    0, 1, 0,
		    0, 0, 0,	0, 1};
int	se3[11] = {-1, 0, 0,			/* hor and vert */
		    0, 1, 0,
		    0, 0, 0,	0, 1};

						/* gradient edge */
int	ge1[11] = { 1, 1, 1,			/* north */
		    1,-2, 1,
		   -1,-1,-1,	0, 1};
int	ge2[11] = { 1, 1, 1,			/* northeast */
		   -1,-2, 1,
		   -1,-1, 1,	0, 1};
int	ge3[11] = {-1, 1, 1,			/* east */
		   -1,-2, 1,
		   -1, 1, 1,	0, 1};
int	ge4[11] = {-1,-1, 1,			/* southeast */
		   -1,-2, 1,
		    1, 1, 1,	0, 1};
int	ge5[11] = {-1,-1,-1,			/* south */
		    1,-2, 1,
		    1, 1, 1,	0, 1};
int	ge6[11] = { 1,-1,-1,			/* southwest */
		    1,-2,-1,
		    1, 1, 1,	0, 1};
int	ge7[11] = { 1, 1,-1,			/* west */
		    1,-2,-1,
		    1, 1,-1,	0, 1};
int	ge8[11] = { 1, 1, 1,			/* northwest */
		    1,-2,-1,
		    1,-1,-1,	0, 1};

int	le1[11] = { 0, 1, 0,			/* laplace edge */
		    1,-4, 1,
		    0, 1, 0,	0, 1};
int	le2[11] = {-1,-1,-1,
		   -1, 8,-1,
		   -1,-1,-1,	0, 1};
int	le3[11] = {-1,-1,-1,
		   -1, 9,-1,
		   -1,-1,-1,	0, 1};
int	le4[11] = { 1,-2, 1,
		   -2, 4,-2,
		    1,-2, 1,	0, 1};

int convolve (pras, w, h, opt, kernel, ptrans)
uchar_t	       *pras;
register int	w;
int		h;
int		opt;		/* 0=user, 1,2,...=built-in */
int	       *kernel;		/* user kernel, if any */
uchar_t	       *ptrans;
{

/*
 *	convolute an image (3x3). return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] = sum (k  * p ) for i pixels in 3x3 neighborhood
 *		               i    i
 */

	uchar_t		       *pr;
	uchar_t		       *pt;
	register int		val;
	register long		x;
	register long		y;
	register uchar_t       *ps;
	register int	       *pk;


	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	/*
	 *   set pointer to user or built-in kernels, depending on opt
	 */
	switch (opt)
	{
	case USER_KERN:		pk = kernel;		break;

	case LP1_KERN:		pk = lp1;		break;
	case LP2_KERN:		pk = lp2;		break;
	case LP3_KERN:		pk = lp3;		break;

	case HP1_KERN:		pk = hp1;		break;
	case HP2_KERN:		pk = hp2;		break;
	case HP3_KERN:		pk = hp3;		break;

	case SE1_KERN:		pk = se1;		break;
	case SE2_KERN:		pk = se2;		break;
	case SE3_KERN:		pk = se3;		break;

	case GE1_KERN:		pk = ge1;		break;
	case GE2_KERN:		pk = ge2;		break;
	case GE3_KERN:		pk = ge3;		break;
	case GE4_KERN:		pk = ge4;		break;
	case GE5_KERN:		pk = ge5;		break;
	case GE6_KERN:		pk = ge6;		break;
	case GE7_KERN:		pk = ge7;		break;
	case GE8_KERN:		pk = ge8;		break;

	case LE1_KERN:		pk = le1;		break;
	case LE2_KERN:		pk = le2;		break;
	case LE3_KERN:		pk = le3;		break;
	case LE4_KERN:		pk = le4;		break;

	default:		return (0);
	}


	/*
	 *   do it...
	 */
	ps = pt;
	for (y = 1; y < h-1; y++)
	{
		for (x = 1; x < w-1; x++)
		{
			val  = ((uint_t) ps[(y-1)*w+(x-1)]) * pk[0];
			val += ((uint_t) ps[(y-1)*w+(x  )]) * pk[1];
			val += ((uint_t) ps[(y-1)*w+(x+1)]) * pk[2];
			val += ((uint_t) ps[(y  )*w+(x-1)]) * pk[3];
			val += ((uint_t) ps[(y  )*w+(x  )]) * pk[4];
			val += ((uint_t) ps[(y  )*w+(x+1)]) * pk[5];
			val += ((uint_t) ps[(y+1)*w+(x-1)]) * pk[6];
			val += ((uint_t) ps[(y+1)*w+(x  )]) * pk[7];
			val += ((uint_t) ps[(y+1)*w+(x+1)]) * pk[8];

			if ((pk[9] < 0) && pk[10])
				val /= pk[10];
			else if (pk[9] > 0)
				val *= pk[10];

			if (val < 0)
				val = 0;
			else if (val > 255)
				val = 255;

			ps[(y*w) + x] = (uchar_t) val;
		}
	}

	return (1);
}




/*------------------------------*/
/*	blur			*/
/*------------------------------*/
int blur (pras, w, h, ptrans)
uchar_t	       *pras;
register int	w;
int		h;
uchar_t	       *ptrans;
{

/*
 *	blur an image. return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] = average of neighboring cells (3x3)
 */

	uchar_t		       *pr;
	uchar_t		       *pt;
	register long		x;
	register long		y;
	register uchar_t       *ps;



	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	/*
	 *   do it...
	 */
	ps = pt;
	for (y = 1; y < h-1; y++)
	{
		for (x = 1; x < w-1; x++)
		{
			ps[(y*w) + x] = (uchar_t) (
					( (uint_t) ps[(y-1)*w + (x-1)]
					+ (uint_t) ps[(y-1)*w + (x  )]
					+ (uint_t) ps[(y-1)*w + (x+1)]
					+ (uint_t) ps[(y  )*w + (x-1)]
					+ (uint_t) ps[(y  )*w + (x  )]
					+ (uint_t) ps[(y  )*w + (x+1)]
					+ (uint_t) ps[(y+1)*w + (x-1)]
					+ (uint_t) ps[(y+1)*w + (x  )]
					+ (uint_t) ps[(y+1)*w + (x+1)]) / 9);
		}
	}

	return (1);
}




/*------------------------------*/
/*	median			*/
/*------------------------------*/
int median (pras, w, h, ptrans)
uchar_t	       *pras;
int		w;
int		h;
uchar_t	       *ptrans;
{

/*
 *	median filter an image. return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] = median of neighboring cells
 */

	uchar_t		       *pr;
	register uchar_t       *pt;
	register long		x;
	register long		y;
#ifdef INL_SORT
	register int		i;
	register uint_t		a;
#endif
	register uint_t	       *pl;
	uint_t			l[9];


	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	/*
	 *   do it...
	 */
	pl = l;
	for (y = 1; y < h-1; y++)
	{
		for (x = 1; x < w-1; x++)
		{
			pl[0] = (uint_t) pt[(y-1)*w + (x-1)];
			pl[1] = (uint_t) pt[(y-1)*w + (x  )];
			pl[2] = (uint_t) pt[(y-1)*w + (x+1)];
			pl[3] = (uint_t) pt[(y  )*w + (x-1)];
			pl[4] = (uint_t) pt[(y  )*w + (x  )];
			pl[5] = (uint_t) pt[(y  )*w + (x+1)];
			pl[6] = (uint_t) pt[(y+1)*w + (x-1)];
			pl[7] = (uint_t) pt[(y+1)*w + (x  )];
			pl[8] = (uint_t) pt[(y+1)*w + (x+1)];
#ifdef INL_SORT
			/* unroll j loop, too... */
			for (a=pl[1], i=0; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
			for (a=pl[2], i=1; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
			for (a=pl[3], i=2; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
			for (a=pl[4], i=3; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
			for (a=pl[5], i=4; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
			for (a=pl[6], i=5; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
			for (a=pl[7], i=6; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
			for (a=pl[8], i=7; i>=0 && pl[i]>a; i--) pl[i+1]=pl[i];
			pl[i+1] = a;
#else
			piksrt (9, l);
#endif
			pt[(y*w) + x] = pl[4];
		}
	}

	return (1);
}




/*------------------------------*/
/*	piksrt			*/
/*------------------------------*/
piksrt (num, arr)
int		num;
uint_t	       *arr;
{

/*
 *	straight insertion sort (num. rec. in C, pp 243). is N^2 sort,
 *	probably ok for N=9. shell sort is 3x faster for N=9.
 */

	register uint_t	       *parr;
	register int		n;
	register int		i;
	register int		j;
	register uint_t		a;

	n    = num;
	parr = arr;
	for (j = 1; j < n; j++)
	{
		for (a=parr[j], i=j-1; i>=0 && parr[i]>a; i--)
			parr[i+1] = parr[i];

		parr[i+1] = a;
	}
}




/*------------------------------*/
/*	findmedian		*/
/*------------------------------*/
uint_t findmedian (num, arr)
int		num;
uint_t	       *arr;
{

/*
 *	find median of an array of numbers. this should be faster than sort.
 *	there are pathalogical cases: if all are the same or all but 1 or 2
 *	are the same...
 */

	register uint_t	       *parr;
	register int		n;
	register int		i;
	register int		j;
	register int		count;
	register uint_t		a;

	parr = arr;
	n    = num;
	for (j = 0; j < n; j++)
	{
		for (a = parr[j], count = 0, i = 0; i < n; i++)
		{
			if (i == j)
				continue;
			if (a > parr[i])
				count++;
		}
		if (count == (n>>1))
			return (a);
	}
		
}




/*------------------------------*/
/*	logscale		*/
/*------------------------------*/
int logscale (pras, w, h, ptrans)
uchar_t	       *pras;
int		w;
int		h;
uchar_t	       *ptrans;
{

/*
 *	apply log scaling to an image. return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] = maxval * log(old[i]) / log(maxval)
 *	or
 *		new[i] = maxval * log2(old[i]) / log2(maxval)
 */

	uchar_t		       *pr;
	uchar_t		       *pt;
	register ulong_t	maxval;
	register ulong_t	l2maxval;
	register ulong_t	l2pr;
	uchar_t			uctmp;
	long			x;
	long			y;
	long			val;
	register long		ii;
	register long		lim;
	register uchar_t       *ps;



	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	/*
	 *   find maxval. here it is max value a pixel can have, 255.
	 */
#if 1
	maxval = 0L;
	for (y = 0; y < h; y++)
	{
		for (x = 0; x < w; x++)
		{
			uctmp = pt[(y*w) + x];
			if (uctmp > maxval)
				maxval = (ulong_t) uctmp;
		}
	}
#endif
/*!!!	maxval = 255L;*/


	/*
	 *   do it...
	 */
#if 1
	l2maxval = (ulong_t) Log2x10 ((uint_t) maxval);
	if (l2maxval == 0)
		return (0);
#endif
/*!!!	l2maxval = 80;*/		/* approx 10 times log2(255) */


#ifdef DBL_LOOP
	for (y = 0; y < h; y++)
	{
		for (x = 0; x < w; x++)
		{
			l2pr          = (ulong_t) Log2x10 ((uint_t) pt[(y*w)+x]);
			pt[(y*w) + x] = (uchar_t) ((maxval * l2pr) / l2maxval);
		}
	}
#else
	lim = (long) w * (long) h;
	for (ps = pt, ii = 0L; ii < lim; ii++)
	{
		l2pr  = (ulong_t) Log2x10 ((uint_t) *ps);
		*ps++ = (uchar_t) ((maxval * l2pr) / l2maxval);
	}
#endif

	return (1);
}





/*------------------------------*/
/*	Log2x10			*/
/*------------------------------*/
int Log2x10(x)
uint_t	x;
{
/*
 *	VERY approximate log base 2 times 10. basically finds MS bit...
 */
	if (x < 256)		goto lobyte;
	if (x & 0x8000)		return (150);
	if (x & 0x4000)		return (140);
	if (x & 0x2000)		return (130);
	if (x & 0x1000)		return (120);
	if (x & 0x0800)		return (110);
	if (x & 0x0400)		return (100);
	if (x & 0x0200)		return (90);
	if (x & 0x0100)		return (80);
lobyte:
	if (x == 0x00ff)
		return (80);
	if (x == 0x0000)
		return (1);
	if (x & 0x0080)
	{
		if (x & 0x0040)
			return (78);
		else if (x & 0x0020)
			return (75);
		else
			return (71);
	}
	if (x & 0x0040)
	{
		if (x & 0x0020)
			return (68);
		else if (x & 0x0010)
			return (65);
		else
			return (61);
	}
	if (x & 0x0020)
	{
		if (x & 0x0010)
			return (58);
		else if (x & 0x0008)
			return (55);
		else
			return (51);
	}
	if (x & 0x0010)
	{
		if (x & 0x0008)
			return (48);
		else if (x & 0x0004)
			return (45);
		else
			return (41);
	}
	if (x & 0x0008)
	{
		if (x & 0x0004)
			return (38);
		else if (x & 0x0002)
			return (35);
		else
			return (31);
	}
	if (x & 0x0004)
	{
		if (x & 0x0002)
			return (28);
		else if (x & 0x0001)
			return (25);
		else
			return (21);
	}
	if (x & 0x0002)
	{
		if (x & 0x0001)
			return (18);
		else
			return (13);
	}
	if (x & 0x0001)		return (10);
	return (0);
}




/*------------------------------*/
/*	contrast		*/
/*------------------------------*/
int contrast (pras, w, h, thresh, hist, ptrans)
uchar_t	       *pras;
int		w;
int		h;
long		thresh;
long	       *hist;
uchar_t	       *ptrans;
{

/*
 *	apply contrast expansion to an image. return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] = maxval * (old[i] - lo) / (hi - lo)
 *
 *		where lo to hi is new contrast range
 */

	uchar_t		       *pr;
	uchar_t		       *pt;
	ulong_t			maxval;
	uchar_t			uctmp;
	long			x;
	long			y;
	long			hi_lo;
	long			newlo;
	long			newhi;
	int			i;
	register long		val;
	register long		rng;
	register long		lim;
	register long		ii;
	register uchar_t       *ps;


	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	/*
	 *   get current histogram...
	 */
	if (do_hist (pt, w, h, hist) == 0)
		return (0);


	/*
	 *    find intensities on either side of hist where pixel count
	 *    exceeds thresh
	 */
	for (i = 0; i < HISTSIZ; i++)
	{
		if (hist[i] > thresh)
			break;
	}
	newlo = i;
	for (i = HISTSIZ-1; i > newlo; i--)
	{
		if (hist[i] > thresh)
			break;
	}
	newhi = i;


	/*
	 *   do it. set pixels below lower threshold 0 and those above to 255.
	 *   contrast expand pixels between...
	 */
#ifdef DBL_LOOP
	rng = newhi - newlo + 1;
	for (y = 0; y < h; y++)
	{
		for (x = 0; x < w; x++)
		{
			val = (ulong_t) pt[(y*w) + x];
			if (val < newlo)
				pt[(y*w) + x] = 0;
			else if (val > newhi)
				pt[(y*w) + x] = 255;
			else
			{
				pt[(y*w) + x] = (uchar_t) ((255L * (val - newlo)) / rng);
			}
		}
	}
#else
	rng = newhi - newlo + 1;
	lim = (long) w * (long) h;
	for (ps = pt, ii = 0L; ii < lim; ii++, ps++)
	{
		val = (ulong_t) *ps;
		if (val < newlo)
			*ps = 0;
		else if (val > newhi)
			*ps = 255;
		else
			*ps = (uchar_t) ((255L * (val - newlo)) / rng);
	}
#endif

	return (1);
}




/*------------------------------*/
/*	brighten		*/
/*------------------------------*/
int brighten (pras, w, h, brite, ptrans)
uchar_t	       *pras;
int		w;
int		h;
register int	brite;
uchar_t	       *ptrans;
{

/*
 *	brighten an image. return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] = old[i] + brite
 */

	uchar_t		       *pr;
	uchar_t		       *pt;
	long			x;
	long			y;
	int			sign;
	register uint_t		val;
	register long		ii;
	register long		lim;
	register uchar_t       *ps;



	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	sign = 0;
	if (brite < 0)
	{
		sign = 1;
		brite = -brite;
	}


	/*
	 *   do it...
	 */
	if (sign)
	{
#ifdef DBL_LOOP
		for (y = 0; y < h; y++)
		{
			for (x = 0; x < w; x++)
			{
				val = (uint_t) pt[y*w + x];
				if (val < brite)
					val  = 0;
				else
					val -= brite;
				pt[(y*w) + x] = (uchar_t) val;
			}
		}
#else
		lim = (long) w * (long) h;
		for (ps = pt, ii = 0L; ii < lim; ii++, ps++)
		{
			if ((uint_t) *ps < brite)
				*ps  = 0;
			else
				*ps -= brite;
		}
#endif
	}
	else
	{
#ifdef DBL_LOOP
		for (y = 0; y < h; y++)
		{
			for (x = 0; x < w; x++)
			{
				val = (uint_t) ((uint_t) pt[y*w + x] + brite);
				if (val > 255)
					val = 255;
				pt[(y*w) + x] = (uchar_t) val;
			}
		}
#else
		lim = (long) w * (long) h;
		for (ps = pt, ii = 0L; ii < lim; ii++, ps++)
		{
			val = (uint_t) ((uint_t) *ps + brite);
			if (val > 255)
				val = 255;
			*ps = (uchar_t) val;
		}
#endif
	}

	return (1);
}




/*------------------------------*/
/*	invert			*/
/*------------------------------*/
int invert (pras, w, h, thresh, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		thresh;
uchar_t	       *ptrans;
{

/*
 *	invert (negate) an image. return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] = 255 - old[i]
 */

	uchar_t		       *pr;
	uchar_t		       *pt;
	long			x;
	long			y;
	int			sign;
	register long		lim;
	register long		ii;
	register int		thr;
	register uchar_t       *ps;


	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	sign = 0;
	if (thresh < 0)
	{
		sign   = 1;
		thresh = -thresh;
	}


	/*
	 *   do it...
	 */
#ifdef DBL_LOOP
	if (thresh == 0)
	{
		for (y = 0; y < h; y++)
		{
			for (x = 0; x < w; x++)
			{
				pt[(y*w) + x] = 255 - pt[(y*w) + x];
			}
		}
	}
	else if (sign)
	{
		/*
		 *   invert only below thresh
		 */
		for (y = 0; y < h; y++)
		{
			for (x = 0; x < w; x++)
			{
				if ((uint_t) pt[(y*w) + x] < thresh)
					pt[(y*w) + x] = 255 - pt[(y*w) + x];
			}
		}
	}
	else
	{
		/*
		 *   invert only above thresh
		 */
		for (y = 0; y < h; y++)
		{
			for (x = 0; x < w; x++)
			{
				if ((uint_t) pt[(y*w) + x] > thresh)
					pt[(y*w) + x] = 255 - pt[(y*w) + x];
			}
		}
	}
#else
	lim = (long) h * (long) w;
	thr = thresh;
	if (thr == 0)
	{
		for (ps = pt, ii = 0L; ii < lim; ii++, ps++)
		{
			*ps = 255 - *ps;
		}
	}
	else if (sign)
	{
		/*
		 *   invert only below thresh
		 */
		for (ps = pt, ii = 0L; ii < lim; ii++, ps++)
		{
			if ((uint_t) *ps < thr)
				*ps = 255 - *ps;
		}
	}
	else
	{
		/*
		 *   invert above below thresh
		 */
		for (ps = pt, ii = 0L; ii < lim; ii++, ps++)
		{
			if ((uint_t) *ps > thr)
				*ps = 255 - *ps;
		}
	}
#endif

	return (1);
}




/*------------------------------*/
/*	threshold		*/
/*------------------------------*/
int threshold (pras, w, h, thresh, ptrans)
uchar_t	       *pras;
int		w;
int		h;
int		thresh;
uchar_t	       *ptrans;
{

/*
 *	threshold an image. return 1 if successful, else 0.
 *
 *	the basic algorithm is:
 *
 *		new[i] =   0 if old[i] <= thresh
 *		new[i] = 255 if old[i] >  thresh
 */

	uchar_t		       *pr;
	uchar_t		       *pt;
	long			x;
	long			y;
	uint_t			val;
	register long		ii;
	register long		lim;
	register uchar_t       *ps;


	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	/*
	 *   do it...
	 */
#ifdef DBL_LOOP
	for (y = 0; y < h; y++)
	{
		for (x = 0; x < w; x++)
		{
			val = (uint_t) pt[(y*w) + x];
			if (val > thresh)
				pt[(y*w) + x] = 255;
			else
				pt[(y*w) + x] = 0;
		}
	}
#else
	lim = (long) h * (long) w;
	for (ps = pt, ii = 0L; ii < lim; ii++, ps++)
	{
		if ((uint_t) *ps > thresh)
			*ps = 255;
		else
			*ps = 0;
	}
#endif

	return (1);
}




/*------------------------------*/
/*	histeq			*/
/*------------------------------*/
int histeq (pras, w, h, hist, ptrans)
uchar_t	       *pras;
int		w;
int		h;
long	       *hist;
uchar_t	       *ptrans;
{

/*
 *	histogram equalization of image. return 1 if successful, else 0.
 */

	long			p_r[HISTSIZ];
	long			s_k[HISTSIZ];
	long			s_kapprx[HISTSIZ];
	uchar_t		       *pr;
	uchar_t		       *pt;
	int			i;
	long			count;



	pr = pras;
	pt = ptrans;

	if (pras != ptrans)
	{
		/*
		 *   first copy orig image to transform image
		 */
		copyrast (pr, w, h, pt);
	}


	/*
	 *   get current histogram...
	 */
	if (do_hist (pt, w, h, hist) == 0)
		return (0);


	/*
	 *   find prob density function (p_r), transformation function (s_k),
	 *   and new distribution. note the 1000 to avoid floats...
	 */
	count = (long) w * (long) h;
	for (i = 0; i < HISTSIZ; i++)
	{
		p_r[i] = (hist[i] * 1000L) / count;
	}
	for (s_k[0] = p_r[0], i = 1; i < HISTSIZ; i++)
	{
		s_k[i] = s_k[i-1] + p_r[i];
	}
	for (i = 0; i < HISTSIZ; i++)
	{
		/* the 500 is for rounding to nearest int... */
		s_kapprx[i] = ((s_k[i] * 255L) + 500L) / 1000L;
	}

#if 0
	printf ("\n    i      hist       p_r       s_k  s_kapprx\n");
	for (count = 0, i = 0; i < HISTSIZ; i++)
	{
		printf ("%5d%10ld%10ld%10ld%10ld\n",
			i,hist[i],p_r[i],s_k[i],s_kapprx[i]);
	}
#endif

	/*
	 *   now redistribute. s_kapprx will contain the new value for
	 *   a given pixel intensity
	 */
	redistribute (pt, w, h, s_kapprx);

	return (1);
}




/*------------------------------*/
/*	redistribute		*/
/*------------------------------*/
int redistribute (pras, w, h, s_kapprx)
uchar_t	       *pras;
int		w;
int		h;
register long  *s_kapprx;
{

/*
 *	redistribute pixels. each pixel set to value given by s_kapprx
 */

	register uchar_t       *pr;
	register long		ii;
	register long		lim;


	lim = (long) w * (long) h;
	for (pr = pras, ii = 0L; ii < lim; ii++, pr++)
	{
		*pr = (uchar_t) s_kapprx[(uint_t) *pr];
	}
}




/*------------------------------*/
/*	copyrast		*/
/*------------------------------*/
int copyrast (ps, w, h, pd)
uchar_t	       *ps;		/* source */
int		w;
int		h;
uchar_t	       *pd;		/* dest */
{

/*
 *	copy an image. return 1 if successful, else 0.
 */

#ifdef DBL_LOOP
	long		x;
	long		y;

	for (y = 0; y < h; y++)
	{
		for (x = 0; x < w; x++)
		{
			pd[(y*w) + x] = ps[(y*w) + x];
		}
	}
#else
	register long	ii;
	register long	lim;

	lim = (long) w * (long) h;
	for (ii = 0L; ii < lim; ii++)
		*pd++ = *ps++;
#endif
	return (1);
}

