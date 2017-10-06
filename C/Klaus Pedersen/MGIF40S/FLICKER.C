#define SHOW_HIST	/* def to show histo after key */
#undef NO_INVERT	/* def if black is 0xff */
#define FLICKER		/* def to test flicker thing. else just f-s */
#define NEW_RANDOM	/* def to new code to add random noise */
#define SHOW_SCREENS	/* def to display each screen slowly first */
#define AUTO_SHOW	/* def to automatically cycle then proceed */

/*
 *	this is for screen-switching on mono to simulate grayscale. it
 *	uses a combination of floyd-steinberg and simulate "planes" which
 *	get displayed each vblank. the image it works from should be
 *	grayscale, i.e. each pixel is represented by an 8-bit (0 to 255)
 *	intensity. since GIF images come with a color table, it is first
 *	required to map each GIF pixel to the color table which has been
 *	first changed to grayscale, either by averaging the rgb values
 *	or by using the NTSC intensity equation.
 *
 *	note that i think the f-s algorithm employed here sweeps each row
 *	left to right rather than alternating directions. that is why there
 *	is spurious info in areas otherwise supposed to be white.
 *
 *	also, all points where chars are used in a calculation, they MUST
 *	be unsigned.
 *
 *	return ptr to screens.
 */

/* written by Klaus Pedersen (micro@imada.dk) */
/* modified by Bill Rosenkranz (rosenkra@convex.com) */

/* Last changed by Bill 91/6/14 */
static char *sccsid = "@(#) flicker.c 1.3 rosenkra(1.2) 92/11/09 Klockars\0\0";

/* #include <stdio.h>	Included via proto.h */
#include <osbind.h>
#include <stdlib.h>

#ifndef __LATTICE__
#include "proto.h"	/* Lattice C should have this precompiled */
#endif

#ifdef LOCAL
#undef LOCAL
#endif
#ifdef GLOBAL
#undef GLOBAL
#endif

#define LOCAL		/*static*/
#define GLOBAL
#define reg_t		register

#define LEVELS		4
#define NUMERRS		1024
#define SCRNSPACE	48256L


/*
 *	globals.
 *
 *	these are the thresholds for quantizing. 0,85,170,255 seem best
 */
LOCAL int	_Levels[LEVELS] = {  0,  85, 170, 255};

LOCAL int	_Width;			/* image size */
LOCAL int      	_Hight;
LOCAL int     	_Beta;			/* for the Laplace filter */
LOCAL int     	_MaxRandom;		/* for adding random noise */
LOCAL int      *_Err1,			/* the error propagation arrays */
	       *_Err2;
LOCAL int     	_Err1Array[NUMERRS],
	        _Err2Array[NUMERRS];
/* LOCAL int	_ScrnBuf[SCRNSPACE]; */	/* enuf for 3 screens... */
int *_ScrnBuf = (void *)0;
LOCAL int  *_Scrn,
	       *_Scrn1,
	       *_Scrn2,
	       *_Scrn3;
long		_Hist[256];	/* histogram */


/*
 *	local functions
 */

/*
LOCAL void	_Conv2Gray ();
LOCAL void	_SimpConv2Gray ();
LOCAL int	_GenConvPix ();
LOCAL int	_Laplace ();
LOCAL void	_ClearErr ();
LOCAL int	_Rand ();
LOCAL int	_Delay ();
LOCAL int	_DoHist ();
LOCAL int	_GetHist ();
*/


/*------------------------------*/
/*	flicker			*/
/*------------------------------*/
GLOBAL int *flicker (pimg, width, hight, beta, maxrandom, opt)
unsigned char  *pimg;		/* -> raster image of intensities */
int		width;		/* width, pixels */
int		hight;		/* height, pixels */
int		beta;		/* for laplace filter */
int		maxrandom;	/* for random noise */
int		opt;		/* 0=no flicker, 1=flicker */
{

/*
 *	this is the main entry point. complete grayscale raster image
 *	comes from pimg with height and width specified. if beta != 0,
 *	do Laplace filter with that beta. if maxrandom != 0, add some
 *	random noise with that value (see below).
 *
 *	we return ptr to first screen. the other two immediately follow
 *	it.
 */

	register long	ii;

	/*
	 *   set our globals
	 */
	if (!_ScrnBuf) {	/* NEW, dynamic allocation of screen space */
		_ScrnBuf = (int*)malloc(SCRNSPACE * 2);	/* SCRNSPC integers */
		if (!_ScrnBuf)
			exit(-1);
	}
	
	_Hight     = hight;	/* its height... */
	_Width     = width;	/* ...and width */
	_Beta      = beta;	/* Laplace filter coefficient (fixedpoint: */
				/* 1=0.25, 2=0.50, 3=0.75... (Try 4) */
	_MaxRandom = maxrandom;	/* amount of random noise on threshold value */
				/* (0 - 255) for 0% to 100% noise. (Try 10) */

	for (ii = 0L; ii < SCRNSPACE; ii++)	/* clear screens! */
		_ScrnBuf[ii] = 0;

#if 0
	printf ("\n\nwidth,height,beta,maxrandom = %d %d %d %d\n",
		_Width, _Hight, _Beta, _MaxRandom);
	printf ("pimg = %ld\nany key...\n", (long) pimg);
	_Delay (4000);
	if (Bconstat (2))
	{
		while (Bconstat (2))
			Bconin (2);
		exit (1);
	}
#endif

	/*
	 *   do it!
	 */
	if (opt)
		_Conv2Gray (pimg);
	else
		_SimpConv2Gray (pimg);


	/*
	 *   return ptr to screens (_Scrn is already page-aligned)...
	 */
	return ((int *) _Scrn);
}




/*------------------------------*/
/*	_Conv2Gray		*/
/*------------------------------*/
LOCAL void _Conv2Gray (pic)
unsigned char  *pic;
{
	register int	       *ps;
	register int	       *pd;
	register long		ii;
	int			i;
	register int	    	x;
	int        		y;
	int			w;
	int			h;
	register long        	yoffset;
	int		       *TmpErr;
	register int	        q;
	int		        rover1;
	int		        rover2;
	register unsigned int	pix;
	unsigned char	       *p;
	char		       *old1;
	char		       *old2;



#ifdef SHOW_HIST
	/*
	 *   get histogram now. we do not do this in SimpConv...
	 */
	_GetHist (pic, _Width, _Hight, _Hist);
#endif


	/*
	 *   first clear the error arrays
	 */
	_ClearErr ();


	/*
	 *   save old screen info, then set logbase to old physbase and
	 *   physbase to first screen buffer. we *should* never see logbase
	 *   in the displayed image since we never display logbase. make
	 *   sure screen is aligned on 256-byte boundary.
	 */
	old1  = Logbase ();
	old2  = Physbase ();
	_Scrn = (int *) (((long) _ScrnBuf + 256L) & 0xFFFFFF00L);
	for (ii = 0L; ii < 32000L; ii++)
	{
		old1[ii] = 0;
		old2[ii] = 0;
	}
	Setscreen (old2, _Scrn, -1);


	/*
	 *   we set physbase to our buffer already so _Scrn1 points to it.
	 *   set the other screen pointers. _Scrn is a buffer large enuf
	 *   to hold all 3 screens
	 */
	_Scrn1 = Physbase ();
	_Scrn2 = _Scrn1 + 16000L;
	_Scrn3 = _Scrn2 + 16000L;


	/*
	 *   initialize some things. yoffset positions us into each screen
	 *   which are int arrays. each scan line in the screen is thus
	 *   40 words long.
	 */
	yoffset = 0L;
	rover1  = 0;
	rover2  = 0;


	/*
	 *   loop over all rows in image
	 */
	h = (_Hight > 400) ? 400 : _Hight;
	for (y = 1; y < h - 1; y++)
	{
		/*
		 *   set ptr to this pixel row
		 */
		p = pic + ((long) y * (long) _Width);

		/*
		 *   loop over all pixels in the row
		 */
		w = (_Width > 640) ? 640 : _Width;
		for (x = 0; x < w - 1; x++)
		{
			pix = (0x8000 >> (x & 0x000f));

			/*
			 *   get new pixel value, with f-s error. this is
			 *   actually an index into the _Levels array.
			 */
			if (y & 1)
				q = _GenConvPix (p, (int) x, 0);
			else
				q = _GenConvPix (p, (int) x, 1);


			/*
			 *   set screen pixels based on this index
			 */
			if (q == 1)
			{
				switch (rover1)
				{
				case 0: 
					_Scrn1[yoffset + (x >> 4)] |= pix;
					rover1 = 1;
					rover2 = 1;
					break;
				case 1: 
					_Scrn2[yoffset + (x >> 4)] |= pix;
					rover1 = 2;
					rover2 = 2;
					break;
				case 2: 
					_Scrn3[yoffset + (x >> 4)] |= pix;
					rover1 = 0;
					rover2 = 0;
					break;
				}
			}
			else if (q == 2)
			{
				switch (rover2)
				{
				case 0: 
					_Scrn1[yoffset + (x >> 4)] |= pix;
					_Scrn2[yoffset + (x >> 4)] |= pix;
					rover2 = 1;
					rover1 = 2;
					break;
				case 1: 
					_Scrn2[yoffset + (x >> 4)] |= pix;
					_Scrn3[yoffset + (x >> 4)] |= pix;
					rover2 = 2;
					rover1 = 0;
					break;
				case 2: 
					_Scrn1[yoffset + (x >> 4)] |= pix;
					_Scrn3[yoffset + (x >> 4)] |= pix;
					rover2 = 0;
					rover1 = 1;
					break;
				}
			}
			else if (q == 3)
			{
				_Scrn1[yoffset + (x >> 4)] |= pix;
				_Scrn2[yoffset + (x >> 4)] |= pix;
				_Scrn3[yoffset + (x >> 4)] |= pix;
			}
		}


		/*
		 *   get ready for next row by incrementing offset into
		 *   the screens (640 dots = 40 words)
		 */
		yoffset += 40;


		/*
		 *   exchange error arrays
		 */
		TmpErr  = _Err1;
		_Err1   = _Err2;
		_Err2   = TmpErr;


		/*
		 *   check for early withdrawal...
		 */
		if (Bconstat (2))
		{
			while (Bconstat (2))
				Bconin (2);
#if 0
			Setscreen (old1, old2, -1);
			return;
#else
			break;		/* no return, display partial image */
#endif
		}
	}



	/*
	 *   with that all done, now we can display the screens. only
	 *   phys screen is displayed (at next vblank). the Vsync waits
	 *   for the vblank. we display screens 1,2,3. any char stops the
	 *   loop. first just show the screens with delay, then do the loop
	 */
#ifdef SHOW_SCREENS

# ifdef AUTO_SHOW
	/* automatically slow cycle thru screens */
	for (i = 0; i < 2; i++)
	{
		Setscreen (old2, _Scrn1, -1);  Vsync ();  _Delay (200);
		Setscreen (old2, _Scrn2, -1);  Vsync ();  _Delay (200);
		Setscreen (old2, _Scrn3, -1);  Vsync ();  _Delay (200);

		if (Bconstat (2))		goto autodone;
	}
	for (i = 0; i < 3; i++)
	{
		Setscreen (old2, _Scrn1, -1);  Vsync ();  _Delay (100);
		Setscreen (old2, _Scrn2, -1);  Vsync ();  _Delay (100);
		Setscreen (old2, _Scrn3, -1);  Vsync ();  _Delay (100);

		if (Bconstat (2))		goto autodone;
	}
	for (i = 0; i < 4; i++)
	{
		Setscreen (old2, _Scrn1, -1);  Vsync ();  _Delay (50);
		Setscreen (old2, _Scrn2, -1);  Vsync ();  _Delay (50);
		Setscreen (old2, _Scrn3, -1);  Vsync ();  _Delay (50);

		if (Bconstat (2))		goto autodone;
	}
	for (i = 0; i < 6; i++)
	{
		Setscreen (old2, _Scrn1, -1);  Vsync ();  _Delay (20);
		Setscreen (old2, _Scrn2, -1);  Vsync ();  _Delay (20);
		Setscreen (old2, _Scrn3, -1);  Vsync ();  _Delay (20);

		if (Bconstat (2))		goto autodone;
	}

# else /*!AUTO_SHOW*/

	do
	{
		Setscreen (old2, _Scrn1, -1);	Vsync ();	_Delay (200);
		Setscreen (old2, _Scrn2, -1);	Vsync ();	_Delay (200);
		Setscreen (old2, _Scrn3, -1);	Vsync ();	_Delay (200);

	} while (!Bconstat (2));

# endif /*AUTO_SHOW*/

autodone:
	/* clear any key presses */
	while (Bconstat (2))
		Bconin (2);

#endif /*SHOW_SCREENS*/


	/*
	 *   show screens at speed. wait for keypress...
	 */
	do
	{
		Setscreen (old2, _Scrn1, -1);	Vsync ();
		Setscreen (old2, _Scrn2, -1);	Vsync ();
		Setscreen (old2, _Scrn3, -1);	Vsync ();

	} while (!Bconstat (2));




#ifdef SHOW_HIST

	/* clear any key presses */
	while (Bconstat (2))
		Bconin (2);

	/*
	 *   show histogram on screen, too, with image. note that _DoHist
	 *   uses line A to draw to screen (logical, i think) so we set
	 *   screen to make sure the histo gets on the screen.
	 */
	Setscreen (_Scrn1, _Scrn1, -1);	Vsync ();
	_DoHist (_Scrn1, _Hist, 1);
	Setscreen (_Scrn2, _Scrn2, -1);	Vsync ();
	_DoHist (_Scrn2, _Hist, 2);
	Setscreen (_Scrn3, _Scrn3, -1);	Vsync ();
	_DoHist (_Scrn3, _Hist, 3);


	do
	{
		Setscreen (old2, _Scrn1, -1);	Vsync ();
		Setscreen (old2, _Scrn2, -1);	Vsync ();
		Setscreen (old2, _Scrn3, -1);	Vsync ();

	} while (!Bconstat (2));


	/*
	 *   make sure to undo the change!
	 */
	_DoHist (_Scrn1, _Hist, -1);
	_DoHist (_Scrn2, _Hist, -2);
	_DoHist (_Scrn3, _Hist, -3);
#endif



	/*
	 *   before resetting screen and returning, copy a screen to orig
	 *   physbase
	 */
	ps = (int *) _Scrn1;
	pd = (int *) old2;
	for (ii = 0L; ii < 16000L; ii++)
		*pd++ = *ps++;


	/*
	 *   reset screens back to what they were
	 */
	Setscreen (old1, old2, -1);


	/*
	 *   clear any waiting keys...
	 */
	while (Bconstat (2))
		Bconin (2);
}




/*------------------------------*/
/*	_SimpConv2Gray		*/
/*------------------------------*/
LOCAL void _SimpConv2Gray (pic)
unsigned char  *pic;
{

/*
 *	I have also made a version of "Convert2Gray", that don't use
 *	flicker - this allows the pictures to be saved, and used in windows,
 *	and honest - the build-in test-picture looks as good, or even better, 
 *	without the flicker... (this is not true for any *real* pictures 
 *	that I have tested the program with). Here it is :
 */

	long		x,
			y,
			yoffset,
			wordpos;
	int		w,
			h;
	int	       *TmpErr;
	unsigned int	pix;
	unsigned char  *p;



	/*
	 *   first clear the error arrays
	 */
	_ClearErr ();


	/*
	 *   there is only one screen. we use existing physbase
	 */
	_Scrn1 = Physbase ();


	/*
	 *   yoffset positions us into the screen which is an int arrays.
	 *   each scan line in the screen is thus 40 words long.
	 */
	yoffset = 0;
	pix     = 0;


	/*
	 *   loop over all rows in image
	 */
	h = (_Hight > 400) ? 400 : _Hight;
	for (y = 1; y < h - 1; y++)
	{
		/*
		 *   set ptr to this pixel row
		 */
		p       = pic + ((long) y * (long) _Width);
		wordpos = yoffset;


		/*
		 *   loop over all pixels in the row
		 */
		w = (_Width > 640) ? 640 : _Width;
		for (x = 0L; x < w - 1; x++)
		{
			pix <<= 1;
			if (_GenConvPix (p, (int) x, 0))
				pix++;
			if ((x & 0xf) == 0xf)
				_Scrn1[wordpos++] = pix;
		}


		/*
		 *   get ready for next row by incrementing offset into
		 *   the screens (640 dots = 40 words)
		 */
		yoffset += 40;


		/*
		 *   exchange error arrays
		 */
		TmpErr  = _Err1;
		_Err1   = _Err2;
		_Err2   = TmpErr;


		/*
		 *   check for early withdrawal...
		 */
		if (Bconstat (2))
		{
			while (Bconstat (2))
				Bconin (2);
#if 0
			return;
#else
			break;		/* display partial image */
#endif
		}
	}

	/*
	 *   displaying the image consists of waiting for a char since we
	 *   already drew it to the screen. so just return. let caller
	 *   do any waiting...
	 */
#if 0
	while (!Bconstat(2))
		;
	while (Bconstat (2))
		Bconin (2);
#endif
}




/*------------------------------*/
/*	_GenConvPix		*/
/*------------------------------*/
LOCAL int _GenConvPix (pic, x, opt)
unsigned char   *pic;			/* -> image pixel array */
int		x;			/* the current pixel */
int		opt;			/* 0=l to r, 1=r to l */
{

/*
 *	This rutine converts a point in the 'real' image to
 *	a point in the screen image. The procedure uses error-
 *	diffusion to determine the state of the new pixel.
 *	The Error filter is that of Floyd & Steinberg :
 *
 *		/ 1  5  3 \  / 
 *		\ 7  X    / / 16
 *
 *	This rutine uses a table of levels to make the convertion.
 *
 *	It returns the index for the pixel from the quantizing Level
 *	array, i.e. the new pixel intensity is Level[i].
 */

	register int   *p_levels;
	register int	p;
	register int	e;
	register int	i;
	register int	err;
	int		lev;


	p_levels = _Levels;


#ifdef NEW_RANDOM
/*
	The noise is here added to the picture, this means that the noise
	isn't cancled out again, and that is NOT intended, the noise should
	only act as some kind of *catalysator* (verb. is stolen from 
	chemistry - something that start a reaction). The correct way to add
	noise is :
*/

	/*
	 *   first do the weighted average. _Err1 is the current line,
	 *   _Err2 is the previous line.
	 */
	if (x == 0)
	{
# ifdef NO_INVERT
/*!!! next line was actually: */

		p = *pic;

/*!!! but that inverted the image. it was assumed that 0xff was black.
      we insist that black is 0x00 (low intensity) */
# else
		p = 255 - *pic;
# endif
	}
	else if (_Beta)
	{
		p = ((7*_Err1[x - 1]
		      + _Err2[x - 1] + 5*_Err2[x] + 3*_Err2[x + 1]) >> 4)
		      + _Laplace (pic + x);
	}
	else
	{
		p = ((7*_Err1[x - 1]
		      + _Err2[x - 1] + 5*_Err2[x] + 3*_Err2[x + 1]) >> 4)
# ifdef NO_INVERT
		      + *(pic + x);
# else
		      + (255 - *(pic + x));
# endif
	}


	/*
	 *   now calculate the residual errors
	 */
	err = NUMERRS;
	for (i = 0; i < LEVELS; i++)
	{
		if (_MaxRandom)
			e = p + _Rand (_MaxRandom) - p_levels[i];
		else
			e = p - p_levels[i];

		if (e < 0)
			e = -e;
		if (e < err)
		{
			err = e;
			lev = i;
		}
	}
	_Err1[x] = p - p_levels[lev];

#else /*!NEW_RANDOM*/

	if (x == 0)
	{
# ifdef NO_INVERT
		p = *pic;
# else
		p = 255 - *pic;
# endif
	}
	else if (_Beta)
	{
		if (_MaxRandom)
			p = ((7 * _Err1[x - 1] + _Err2[x - 1]
				+ 5 * _Err2[x] + 3 * _Err2[x + 1]) >> 4)
				+ _Laplace (pic + x) + _Rand (_MaxRandom);
		else
			p = ((7 * _Err1[x - 1] + _Err2[x - 1]
				+ 5 * _Err2[x] + 3 * _Err2[x + 1]) >> 4)
				+ _Laplace (pic + x);
	}
	else
	{
		if (_MaxRandom)
		{
			p = ((7 * _Err1[x - 1] + _Err2[x - 1]
				+ 5 * _Err2[x] + 3 * _Err2[x + 1]) >> 4)
# ifdef NO_INVERT
				+ *(pic + x) + _Rand (_MaxRandom);
# else
				+ (255 - *(pic + x)) + _Rand (_MaxRandom);
# endif
		}
		else
		{
			p = ((7 * _Err1[x - 1] + _Err2[x - 1]
				+ 5 * _Err2[x] + 3 * _Err2[x + 1]) >> 4)
# ifdef NO_INVERT
				+ *(pic + x);
# else
				+ (255 - *(pic + x));
# endif
		}
	}
	err = NUMERRS;
	for (i = 0; i < LEVELS; i++)
	{
		e = p - p_levels[i];
		if (e < 0)
			e = -e;
		if (e < err)
		{
			err = e;
			lev = i;
		}
	}
	_Err1[x] = p - p_levels[lev];

#endif /*NEW_RANDOM*/

	return (lev);
}




/*------------------------------*/
/*	_Laplace		*/
/*------------------------------*/
LOCAL int _Laplace (Pic)
unsigned char   *Pic;
{

/*
 *	this is a Laplacian filter, a simple edge detector/enhancer.
 *
 *		   -1
 *		-1  4 -1
 *		   -1
 */

	register unsigned char *pc;
	register int		lp;
	register int		b;
	register int		w;


	pc = Pic;
	b  = _Beta;
	w  = _Width;



	/*
	 *   if _Beta 0, formula reduces to just the pixel
	 */
#ifdef NO_INVERT
	if (b == 0)
		return ((int) *pc);

	lp = (*pc << 2)				/* this pixel */
	   - *(pc - 1) - *(pc + 1)		/* left/right */
	   - *(pc + w) - *(pc - w);		/* top/bottom */
	lp = ((b * lp) >> 2) + *pc;
#else
	if (b == 0)
		return ((int) (255 - *pc));

	lp  = (255 - *pc) << 2;			/* this pixel */
	lp -= (255 - *(pc - 1));		/* left/right */
	lp -= (255 - *(pc + 1));
	lp -= (255 - *(pc + w));		/* top/bottom */
	lp -= (255 - *(pc - w));
	lp  = ((b * lp) >> 2);
	lp += (255 - *pc);			/* self */
#endif

	/*
	 *   check limits and force result to 8 bits
	 */
	if (lp < 0)
		lp = 0;
	if (lp > 255)
		lp = 255;

	return (lp);
}




/*------------------------------*/
/*	_ClearErr		*/
/*------------------------------*/
LOCAL void _ClearErr ()
{
	register int	i;
	register int	w;
	register int   *pe1;
	register int   *pe2;


	_Err1 = _Err1Array;
	_Err2 = _Err2Array;

	pe1   = _Err1Array;
	pe2   = _Err2Array;
	w     = _Width;
	for (i = 0; i < w; i++)
	{
		*pe1++ = 0;
		*pe2++ = 0;
	}
}




/*------------------------------*/
/*	_Rand			*/
/*------------------------------*/
LOCAL int _Rand (mx)
int	mx;
{

/*
 *	returns random number 0 <= x < mx
 */

	static long     Seed = 0;

	if (mx == 0)
		return (0);

/*	Seed = (5 * Seed + 37);*/
	Seed += (Seed << 2) + 37;		/* same thing but faster */
/*	Seed &= 0x00ffffffL;*/			/* should prevent overflow */

	return (((int) Seed) % mx);
}




/*------------------------------*/
/*	_Delay			*/
/*------------------------------*/
LOCAL _Delay (ms)
int	ms;
{
/*
 *	delay with 1 ms granularity on normal ST
 */
	int	i;
	for ( ; ms > 0; ms--)	for (i = 192; i > 0; i--)	;
}




/*------------------------------*/
/*	_GetHist		*/
/*------------------------------*/
_GetHist (pras, w, h, hist)
unsigned char  *pras;
int		w;
int		h;
long	       *hist;
{
	long			x;
	long			y;
	register long		ii;
	register long		lim;
	register unsigned char *ps;
	register long	       *ph;
	register unsigned int	hval;		/* ptr into Hist */


	/*
	 *   clear histo
	 */
	for (ph = hist, ii = 0L; ii < 256; ii++)
		*ph++ = 0L;

	/*
	 *   do it...
	 */
	lim = (long) h * (long) w;
	for (ph = hist, ps = pras, ii = 0L; ii < lim; ii++, ps++)
	{
		hval      = (unsigned int) *ps;
		ph[hval] += 1;
	}

	return (1);
}




/*------------------------------*/
/*	_DoHist			*/
/*------------------------------*/

int	_save1[260*4];		/* NOTE: change dims if hist size changes!!! */
int	_save2[260*4];
int	_save3[260*4];

_DoHist (scrn, hst, opt)
int    *scrn;
long   *hst;
int	opt;
{

/*
 *	draw a histogram, vertical axis, horizontal values.
 */

	register int   *psav;
	register long  *phst;
	register int   *pscrn;
	int		xmn;
	int		ymn;
	int		xmx;
	int		ymx;
	int		vspace;
	int		barsize;
	register long	hmax;
	register int	hstsiz;
	int		bordr;

	register int	i;
	register int	j;
	int		x1,
 			x2,
 			y1,
 			y2;
	long		xsz;


	/*
	 *   set sizes, location
	 */
	hstsiz  = 256;
	vspace  = 1;
	barsize = 1;
	xmn     = 560;
	ymn     = 16;
	xmx     = xmn+64;
	ymx     = ymn+256;
	bordr   = 2;


	/*
	 *   are we drawing histo or restoring the screen?
	 */
	if (opt > 0)
	{
		/*
		 *   drawing. find max value...
		 */
		for (hmax = 0, phst = hst, i = 0; i < hstsiz; i++, phst++)
		{
			if (*phst > hmax)
				hmax = *phst;
		}


		/*
		 *   make space for histogram. save the part of the screen
		 *   we clobber, too.
		 */
		switch (opt)
		{
		case 1:		psav = _save1;		break;
		case 2:		psav = _save2;		break;
		case 3:		psav = _save3;		break;
		}
		pscrn = scrn;
		for (j = ymn; j < ymx; j++)
		{
			for (i = xmn/16; i < xmx/16; i++)
			{
				*psav++             = pscrn[(j-1)*40 + i];
				pscrn[(j-1)*40 + i] = 0;
			}
		}


#if 0
		/*
		 *   draw box around histogram
		 */
		do_line (xmn-bordr, ymn-bordr, xmx+bordr, ymn-bordr);
		do_line (xmn-bordr, ymn-bordr, xmn-bordr, ymx+bordr);
		do_line (xmx+bordr, ymx+bordr, xmx+bordr, ymn-bordr);
		do_line (xmx+bordr, ymx+bordr, xmn-bordr, ymx+bordr);
#endif

		/*
		 *   draw the lines. note that a "baseline" could appear
		 *   because for hst entries of 0, the line is just a dot
		 *   so we do not draw these.
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
	else
	{
		/*
		 *   restore the part of the screen the histo clobbered...
		 */
		switch (opt)
		{
		case -1:	psav = _save1;		break;
		case -2:	psav = _save2;		break;
		case -3:	psav = _save3;		break;
		}
		pscrn = scrn;
		for (j = ymn; j < ymx; j++)
		{
			for (i = xmn/16; i < xmx/16; i++)
			{
				pscrn[(j-1)*40 + i] = *psav++;
			}
		}
	}
}





