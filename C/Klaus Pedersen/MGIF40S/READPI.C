/*
 *	read a degas pi1 or pi2 files. decode and stuff into raster array
 *	and color map. both ReadPI1 and ReadPI2 are here...
 */

/* Last changed by Bill 91/6/9 */
static char *sccsid = "@(#) readpi.c 1.1 rosenkra(1.0)  92/11/09 Klockars\0\0";

/* #include <stdio.h>	Included via proto.h */
#include <osbind.h>
/* #include "mgif.h"	Included via proto.h */

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

#define PI1		0		/* type of file (.pi1, etc) */
#define PI2		1		/* also res in file */
#define PI3		2

/* NEW, used to be constants */
extern long MAXRAW, MAXIMG;

/*
 *	globals for GIF decode procedure (only needed in this file,
 *	should actually be static)
 */
LOCAL int	_Palette[16];	/* pi1/pi2 color palette */
LOCAL uchar_t	_Quant[8] = {0,36,72,108,144,180,216,255};
				/* for quantizing 8 levels (3 bits) to 256 */


/*
 *	local functions
 */

/*
LOCAL void	_PI1toIndx ();
LOCAL void	_PI2toIndx ();
*/

/*------------------------------*/
/*	ReadPI1			*/
/*------------------------------*/
GLOBAL int ReadPI1 (fname, raster, colormap, opt)
char	       *fname;		/* file name with .GIF */
uchar_t	       *raster;		/* place to put raster */
uchar_t		colormap[][3];	/* color map */
int		opt;		/* SILENT, INQUIRE, VERBOSE, NORMAL */
{

/*
 *	read a pi1 image from open file infile into raster array.
 *	the array will contain index into color table. caller supplies
 *	all needed space (raster array, color map, etc). colormap
 *	will contain either global or local color map, depending on image.
 *
 *	The following illustrates the general file layout of .PI1 files:
 *
 *		1	word	resolution
 *		16	word	palette
 *		16000	word	screen memory
 */

	static int	firsttime = 1;

	FILE	       *in;
	int		infile;
	reg_t long	ii;
	int		i;
	int		flag;
	int		nread;
	int		res;
	int		line[80];
	int		c;
	int		q;




	/*
	 *   open file...
	 */
	if (opt != SILENT)
	{
		printf ("   \n");
		printf ("\nEnter ReadPI1\n\n");
		printf ("Open file:                           %s\n", fname);
	}	/* NEW, was fopenb */
	if ((in = fopen (fname, "rb")) == (FILE *) 0)
	{
		return (EGIFFILE);
	}

#ifdef __GNUC__
	in->_flag |= _IOBIN;		/* The GNU libraries don't like "rb" */
#endif


	/*
	 *   get ready for next image by clearing variables, tables
	 */
	if (firsttime)
		firsttime = 0;
	else
	{
		/* these take a while to do */
		if (opt != SILENT)
			printf ("\nResetting tables\n");

		for (ii = 0; ii < MAXIMG; ii++)
			raster[ii] = 0;
	}



	/*
	 *   make sure it is a pi1 file
	 */
	if (opt != SILENT)
		printf ("\nRead resolution\n");
	nread = fread (&res, 2, 1, in);
	if (nread != 1)
	{
		fclose (in);
		return (EGIFEOF);
	}
	if (res != PI1)
	{
		fclose (in);
		return (EGIFMAGIC);
	}
	if (opt != SILENT)
		printf ("     res = %d\n", res);



	/*
	 *   read palette...
	 */
	if (opt != SILENT)
		printf ("\nRead palette\n");
	nread = fread (_Palette, 2, 16, in);
	if (nread != 16)
	{
		fclose (in);
		return (EGIFEOF);
	}
	if (opt != SILENT)
	{
		printf ("     %04x %04x %04x %04x %04x %04x %04x %04x\n",
			_Palette[0], _Palette[1], _Palette[2], _Palette[3],
			_Palette[4], _Palette[5], _Palette[6], _Palette[7]);
		printf ("     %04x %04x %04x %04x %04x %04x %04x %04x\n",
			_Palette[8], _Palette[9], _Palette[10], _Palette[11],
			_Palette[12], _Palette[13], _Palette[14], _Palette[15]);
	}



	/*
	 *   set up colormap from palette...
	 */
	for (i = 0; i < 16; i++)
	{
		/*
		 *   the mask for the palette is 0x0777. we quantize based
		 *   on color table with 256 possible values.
		 */
		c              = _Palette[i];
		q              = (int) ((c & 0x0700) >> 8);
		colormap[i][0] = (uchar_t) _Quant[q];
		q              = (int) ((c & 0x0070) >> 4);
		colormap[i][1] = (uchar_t) _Quant[q];
		q              = (int)  (c & 0x0007);
		colormap[i][2] = (uchar_t) _Quant[q];
	}



	/*
	 *   read screen...
	 */
	if (opt != SILENT)
		printf ("\nRead screen\n");
	for (i = 0; i < 200; i++)
	{
		nread = fread (line, 2, 80, in);
		if (nread != 80)
		{
			fclose (in);
			return (EGIFEOF);
		}
		_PI1toIndx (line, raster);

		raster = (uchar_t *) ((long) raster + 320L);
	}
	fclose (in);

	/* at this point, Raster[] contains colormap indices at each pixel
	   and ColMap contains RGB colormap requantized to 256 levels. only
	   the first 16 elements of ColMap are used */

	return (EGIFOK);
}




/*------------------------------*/
/*	_PI1toIndx		*/
/*------------------------------*/
LOCAL void _PI1toIndx (pscrn, pras)
int	       *pscrn;
uchar_t	       *pras;
{

/*
 *	decompose gem bitmap row into colormap index. here we just get
 *	each pixel's color index and stuff it into the raster. the color
 *	map is done elsewhere.
 *
 *	it works like this:
 *
 *			   word, 16 bits
 *			|	.	 |
 *			|	.	 |
 *	plane 0		|0110010110001110|
 *	plane 1		|0100110111110000|
 *	plane 2		|0111110100000001|
 *	plane 3		|0000000110111000|
 *	plane 0		|     ^	.	 |
 *			|     |	.	 |    color index:
 *			      \-------------- 0 1 1 1 = 7
 *							|
 *							v  111111
 *					palette: 0123456789012345
 *							|
 *							v
 *							0 7 3 1
 *							  ^ ^ ^
 *							  | | |
 *						    red---/ | \---blue
 *							    |
 *							  green
 *
 *	the mask for the palette is 0x0777. low rez can use all 16 palette
 *	entries. we only need the color index. the example above shows
 *	further how to decompose that to rgb intensities.
 */

	register int	shift;
	register int	indx;
	register int	colindx;
	register int	ix;

	int		pl_0,		/* 4 planes in low rez... */
			pl_1,
			pl_2,
			pl_3;


	for (ix = 0; ix < 320; ix++)
	{
		/*
		 *   indx is byte, shift gets proper bit. pl_x are
		 *   each of the four planes of a gem image, and are
		 *   interleaved. given the pixel value for each plane,
		 *   the result maps to a color index which in turn
		 *   indexes into the palette for the color. the color
		 *   in the palette gives RGB values for the pixel.
		 */
/*		indx      = (ix / 16) * 4;*/
		indx      = (ix >> 4) << 2;
		shift     = 15 - (ix % 16);

		pl_0      = ((pscrn[indx  ] >> shift) & 1);
		pl_1      = ((pscrn[indx+1] >> shift) & 1);
		pl_2      = ((pscrn[indx+2] >> shift) & 1);
		pl_3      = ((pscrn[indx+3] >> shift) & 1);

		colindx   = (pl_3 << 3) | (pl_2 << 2) | (pl_1 << 1) | (pl_0);

		pras[ix] = (uchar_t) colindx;
	}
}




/*------------------------------*/
/*	ReadPI2			*/
/*------------------------------*/
GLOBAL int ReadPI2 (fname, raster, colormap, opt)
char	       *fname;		/* file name with .GIF */
uchar_t	       *raster;		/* place to put raster */
uchar_t		colormap[][3];	/* color map */
int		opt;		/* SILENT, INQUIRE, VERBOSE, NORMAL */
{

/*
 *	read a pi2 image from open file infile into raster array.
 *	the array will contain index into color table. caller supplies
 *	all needed space (raster array, color map, etc). colormap
 *	will contain either global or local color map, depending on image.
 *
 *	The following illustrates the general file layout of .PI2 files:
 *
 *		1	word	resolution
 *		16	word	palette
 *		16000	word	screen memory
 */

	static int	firsttime = 1;

	FILE	       *in;
	int		infile;
	reg_t long	ii;
	int		i;
	int		flag;
	int		nread;
	int		res;
	int		line[80];
	int		c;
	int		q;




	/*
	 *   open file...
	 */
	if (opt != SILENT)
	{
		printf ("   \n");
		printf ("\nEnter ReadPI2\n\n");
		printf ("Open file:                           %s\n", fname);
	}	/* NEW, was fopenb */
	if ((in = fopen (fname, "rb")) == (FILE *) 0)
	{
		return (EGIFFILE);
	}

#ifdef __GNUC__
	in->_flag |= _IOBIN;		/* The GNU libraries don't like "rb" */
#endif


	/*
	 *   get ready for next image by clearing variables, tables
	 */
	if (firsttime)
		firsttime = 0;
	else
	{
		/* these take a while to do */
		if (opt != SILENT)
			printf ("\nResetting tables\n");

		for (ii = 0; ii < MAXIMG; ii++)
			raster[ii] = 0;
	}



	/*
	 *   make sure it is a pi1 file
	 */
	if (opt != SILENT)
		printf ("\nRead resolution\n");
	nread = fread (&res, 2, 1, in);
	if (nread != 1)
	{
		fclose (in);
		return (EGIFEOF);
	}
	if (res != PI2)
	{
		fclose (in);
		return (EGIFMAGIC);
	}
	if (opt != SILENT)
		printf ("     res = %d\n", res);



	/*
	 *   read palette...
	 */
	if (opt != SILENT)
		printf ("\nRead palette\n");
	nread = fread (_Palette, 2, 16, in);
	if (nread != 16)
	{
		fclose (in);
		return (EGIFEOF);
	}
	if (opt != SILENT)
	{
		printf ("     %04x %04x %04x %04x %04x %04x %04x %04x\n",
			_Palette[0], _Palette[1], _Palette[2], _Palette[3],
			_Palette[4], _Palette[5], _Palette[6], _Palette[7]);
		printf ("     %04x %04x %04x %04x %04x %04x %04x %04x\n",
			_Palette[8], _Palette[9], _Palette[10], _Palette[11],
			_Palette[12], _Palette[13], _Palette[14], _Palette[15]);
	}



	/*
	 *   set up colormap from palette...
	 */
	for (i = 0; i < 4; i++)
	{
		/*
		 *   the mask for the palette is 0x0777. we quantize based
		 *   on color table with 256 possible values.
		 */
		c              = _Palette[i];
		q              = (int) ((c & 0x0700) >> 8);
		colormap[i][0] = (uchar_t) _Quant[q];
		q              = (int) ((c & 0x0070) >> 4);
		colormap[i][1] = (uchar_t) _Quant[q];
		q              = (int)  (c & 0x0007);
		colormap[i][2] = (uchar_t) _Quant[q];
	}



	/*
	 *   read screen...
	 */
	if (opt != SILENT)
		printf ("\nRead screen\n");
	for (i = 0; i < 200; i++)
	{
		nread = fread (line, 2, 80, in);
		if (nread != 80)
		{
			fclose (in);
			return (EGIFEOF);
		}
		_PI2toIndx (line, raster);

		raster = (uchar_t *) ((long) raster + 640L);
	}
	fclose (in);

	/* at this point, Raster[] contains colormap indices at each pixel
	   and ColMap contains RGB colormap requantized to 256 levels. only
	   the first 16 elements of ColMap are used */

	return (EGIFOK);
}




/*------------------------------*/
/*	_PI2toIndx		*/
/*------------------------------*/
LOCAL void _PI2toIndx (pscrn, pras)
int	       *pscrn;
uchar_t	       *pras;
{

/*
 *	decompose gem bitmap row into colormap index. here we just get
 *	each pixel's color index and stuff it into the raster. the color
 *	map is done elsewhere.
 *
 *	it works like this:
 *
 *			   word, 16 bits
 *			|	.	 |
 *			|	.	 |
 *	plane 0		|0110000110001110|
 *	plane 1		|0100110111110000|
 *	plane 0		|     ^	.	 |
 *			|     |	.	 |    color index:
 *			      \-------------- 1 0 = 2
 *						    |
 *						    v       111111
 *					palette:  0123456789012345
 *						    |
 *						    v
 *						    0 7 3 1
 *						      ^ ^ ^
 *						      | | |
 *						red---/ | \---blue
 *						        |
 *
 *	the mask for the palette is 0x0777. med rez can use 4 palette
 *	entries. we only need the color index. the example above shows
 *	further how to decompose that to rgb intensities.
 */

	register int	shift;
	register int	indx;
	register int	colindx;
	register int	ix;

	int		pl_0,		/* 2 planes in med rez... */
			pl_1;


	for (ix = 0; ix < 640; ix++)
	{
		/*
		 *   indx is byte, shift gets proper bit. pl_x are
		 *   each of the four planes of a gem image, and are
		 *   interleaved. given the pixel value for each plane,
		 *   the result maps to a color index which in turn
		 *   indexes into the palette for the color. the color
		 *   in the palette gives RGB values for the pixel.
		 */
/*		indx      = (ix / 16) * 2;*/
		indx      = (ix >> 4) << 1;
		shift     = 15 - (ix % 16);

		pl_0      = ((pscrn[indx  ] >> shift) & 1);
		pl_1      = ((pscrn[indx+1] >> shift) & 1);

		colindx   = (pl_1 << 1) | (pl_0);

		pras[ix] = (uchar_t) colindx;
	}
}





