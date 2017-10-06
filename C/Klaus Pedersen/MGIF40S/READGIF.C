/*
 *	read a GIF file. decode and stuff into raster array and color maps.
 *
 *	this was adopted from PBMplus.
 */

/* Last changed by Bill 91/6/3 */
static char *sccsid = "@(#) readgif.c 1.2 rosenkra(1.1)  92/11/09 Klockars\0\0";

/* #include <stdio.h>	Included via proto.h */
#include <stdlib.h>
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
#define reg_t		/*register*/


/* NEW, used to be constants */
extern long MAXRAW, MAXIMG;

/*
 *	globals for GIF decode procedure (only needed in this file,
 *	should actually be static)
 */

LOCAL ulong_t	_BitOffset = 0;	/* Bit Offset of next code */
LOCAL int	_XC = 0;	/* Output X and Y coords of current pixel */
LOCAL int	_YC = 0;
LOCAL int	_HEIGHT;	/* image size */
LOCAL int	_WIDTH;
LOCAL int	_Pass = 0;	/* Used by output routine if interlaced pic */
LOCAL int	_OutCount = 0;	/* Decompressor output 'stack count' */
LOCAL int	_Interlace;	/* flag for interlaced image */
LOCAL int	_CodeSize;	/* Code size, read from GIF header */
LOCAL int	_InitCodeSize;	/* Start code size, used during Clear */
LOCAL int	_Code;		/* Value returned by read_code */
LOCAL int	_MaxCode;	/* limit value for current code size */
LOCAL int	_ClearCode;	/* GIF clear code */
LOCAL int	_EOFCode;	/* GIF end-of-information code */
LOCAL int	_CurCode;	/* Decompressor variables */
LOCAL int	_OldCode;
LOCAL int	_InCode;
LOCAL int	_FirstFree;	/* First free code, gen'd per GIF spec */
LOCAL int	_FreeCode;	/* Decompr, next free slot in hash table */
LOCAL int	_FinChar;	/* Decompr variable */
LOCAL int	_BitMask;	/* AND mask for data size */
LOCAL int	_ReadMask;	/* Code AND mask for cur code size */
LOCAL int	_Prefix[HASHSIZ];/* hash table used by the decompr */
LOCAL int	_Suffix[HASHSIZ];
LOCAL int	_OutCode[OUTSIZ];/* output array used by the decompr */
LOCAL int	_BitsPerPixel;	/* image attributes */
LOCAL int	_ColorMapSize;
LOCAL int	_ImageNum = 0;	/* if multi-image file (not used) */
LOCAL int	_Eof = 0;	/* EOF on input flag (_GETC) */
LOCAL long	rcount = 0;
LOCAL long	_YCbyte = 0;
LOCAL long	RasTop;

/*
 *	local functions
 */

/*
LOCAL int	_ReadRaster ();
LOCAL int	_ReadCode ();
LOCAL int	_AddPixel ();
LOCAL void	_InstCMap ();
LOCAL int	_ScanSD ();
LOCAL void	_SkipEB ();
LOCAL int	_ScanID ();
LOCAL void	_ScanCM ();
LOCAL int	_ScanMAGIC ();
LOCAL int	_GetKey ();
LOCAL int	_GETC ();
*/


/*------------------------------*/
/*	ReadGIF			*/
/*------------------------------*/
GLOBAL int ReadGIF (fname, codedgif, raster, scrninf, id, colormap, opt)
char			*fname;		/* file name with .GIF */
uchar_t		*codedgif;	/* place to put raw raster data, coded */
uchar_t		*raster;		/* place to put raster */
screen_t		*scrninf;	/* image info struct */
image_t		*id;			/* image id struct */
uchar_t		colormap[][3];	/* color map */
int			opt;			/* SILENT, INQUIRE, VERBOSE, NORMAL */
{

/*
 *	read a GIF87a image from open file infile into raster array.
 *	the array will contain index into color table. caller supplies
 *	all needed space (raster array, headers, color map, etc). colormap
 *	will contain either global or local color map, depending on image.
 *
 *	The following illustrates the general file layout of .GIF files:
 *
 *	+-----------------------+
 *	| +-------------------+ |
 *	| |   GIF Signature   | |	GIF87a			(required)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| | Screen Descriptor | |	7 bytes, ends with 00	(required)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| | Global Color Map  | |	3*2^bits bytes		(optional but
 *	| +-------------------+ |				 usual)
 *	| +-------------------+ |
 *	| | Extension Block   | |	!			(optional)
 *	| +-------------------+ |
 *	. . .		    . . .
 *	| +-------------------+ |
 *	| |  Image Descriptor | |	,			(required)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| |  Local Color Map  | |				(optional)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| |    Raster Data    | |				(required)
 *	| +-------------------+ |
 *	. . .		    . . .   
 *	|-    GIF Terminator   -|				(required)
 *	+-----------------------+
 */

	static int	firsttime = 1;

	uchar_t		lcm[MAPSIZ][3];
	uchar_t		gcm[MAPSIZ][3];
/*	int		infile; */
	FILE	*infile;
	reg_t long	ii;
	int		flag;



	/*
	 *   open file...
	 */
	if (opt != SILENT)
	{
		printf ("   \n");
		printf ("\nEnter ReadGIF\n\n");
		printf ("Open file:                           %s\n", fname);
	}		/* NEW, was openb */
	if ((infile = fopen (fname, "rb")) == (FILE *)NULL)
	{
		return (EGIFFILE);
	}

#ifdef __GNUC__
	infile->_flag |= _IOBIN;	/* The GNU libraries don't like "rb" */
#endif


	/*
	 *   get ready for next image by clearing variables, tables
	 */
	_BitOffset    = 0;
	_XC           = 0;
	_YC           = 0;
	_YCbyte       = 0;
	_Pass         = 0;
	_OutCount     = 0;
	_CodeSize     = 0;
	_InitCodeSize = 0;
	_Code         = 0;
	_MaxCode      = 0;
	_ClearCode    = 0;
	_EOFCode      = 0;
	_CurCode      = 0;
	_OldCode      = 0;
	_InCode       = 0;
	_FirstFree    = 0;
	_FreeCode     = 0;
	_FinChar      = 0;
	_BitMask      = 0;
	_ReadMask     = 0;
	_Eof          = 0;

	for (ii = 0; ii < HASHSIZ; ii++)
	{
		_Prefix[ii] = 0;
		_Suffix[ii] = 0;
	}

	for (ii = 0; ii < OUTSIZ; ii++)
		_OutCode[ii] = 0;

	if (firsttime)
		firsttime = 0;
	else
	{
		/* these take a while to do */
		if (opt != SILENT)
			printf ("\nResetting tables\n");

		for (ii = 0; ii < MAXRAW; ii++)
			codedgif[ii] = 0;

		for (ii = 0; ii < MAXIMG; ii++)
			raster[ii] = 0;

	}


	/*
	 *   make sure it is a gif file (file header is this...)
	 */
	if (opt != SILENT)
		printf ("\nRead MAGIC\n");
	if (!_ScanMAGIC (infile, "GIF87a", opt))
	{
		fclose (infile);
		return (EGIFMAGIC);
	}



	/*
	 *   read screen descriptor...
	 */
	if (opt != SILENT)
		printf ("\nRead screen descriptor\n");
	if (!_ScanSD (infile, scrninf, opt))
	{
		fclose (infile);
		return (EGIFSDESC);
	}
	if (opt != SILENT)
	{
	  printf ("     Screen width (s_dx)       = %d\n", (int) (scrninf->s_dx));
	  printf ("     Screen height (s_dy)      = %d\n", (int) (scrninf->s_dy));
	  printf ("     Global map? (s_gcm)       = %d\n", (int) (scrninf->s_gcm));
	  printf ("     Color resolution (s_cr)   = %d\n", (int) (scrninf->s_cr));
	  printf ("     Bits/pixel (s_bits)       = %d\n", (int) (scrninf->s_bits));
	  printf ("     Num colors (s_colors)     = %d\n", (int) (scrninf->s_colors));
	  printf ("     Background color (s_bgnd) = %d\n", (int) (scrninf->s_bgnd));
	}



	/*
	 *   read global color map if we have one...
	 */
	if (scrninf->s_gcm)
	{
		if (opt != SILENT)
			printf ("\nRead global color map\n");
		_ScanCM (infile, scrninf->s_colors, (char *) gcm, opt);
	}
	else
	{
		if (opt != SILENT)
			printf ("\nNo global color map\n");
	}


	/*
	 *   read image descriptor
	 */
	_ImageNum++;
	if (opt != SILENT)
		printf ("\nRead image descriptor, image: %d\n", _ImageNum);

	flag = _ScanID (infile, id, opt);

	if (flag == 0)
	{
		return (EGIFEOF);
	}
	if (flag == 1)
		return (EGIFIDBAD);

	if (opt != SILENT)
	{
	  printf ("     Image left (i_x)         = %d\n", (int) (id->i_x));
	  printf ("     Image top (i_y)          = %d\n", (int) (id->i_y));
	  printf ("     Image width (i_dx)       = %d\n", (int) (id->i_dx));
	  printf ("     Image height (i_dy)      = %d\n", (int) (id->i_dy));
	  printf ("     Use local map? (i_gcm)   = %d\n", (int) (id->i_gcm));
	  printf ("     Interlaced? (i_intlace)  = %d\n", (int) (id->i_intlace));
	  printf ("     Bits per pixel (i_bits)  = %d\n", (int) (id->i_bits));
	  printf ("     Number colors (i_colors) = %d\n", (int) (id->i_colors));
	  printf ("     (If no local color map, use screen bits and colors)\n");
	}


	/*
	 *   read local color map, if there
	 */
	if (id->i_gcm)
	{
		if (opt != SILENT)
			printf ("\nRead local color map\n");
		_ScanCM (infile, id->i_colors, (char *) lcm, opt);
		_InstCMap (id->i_colors, (uchar_t *) lcm, colormap, opt);
	}
	else
	{
		if (opt != SILENT)
			printf ("\nUse global color map\n");
		_InstCMap (scrninf->s_colors, (uchar_t *) gcm, colormap, opt);

		/*
		 *   make sure to reset these from global info...
		 */
		id->i_colors = scrninf->s_colors;
		id->i_bits   = scrninf->s_bits;
	}

	_BitsPerPixel = id->i_bits;
	_ColorMapSize = 1 << _BitsPerPixel;
	_BitMask      = _ColorMapSize - 1;
	_WIDTH        = id->i_dx;
	_HEIGHT       = id->i_dy;
	_Interlace    = id->i_intlace;

	if (opt != SILENT)
	{
		printf ("     BitsPerPixel = %d\n", _BitsPerPixel);
		printf ("     ColorMapSize = %d\n", _ColorMapSize);
		printf ("     BitMask      = %04x\n", _BitMask);
		printf ("     WIDTH        = %d\n", _WIDTH);
		printf ("     HEIGHT       = %d\n", _HEIGHT);
		printf ("     Interlace    = %d\n", _Interlace);
	}



	/*
	 *   check size vs internal buffer...
	 */
	if (((long) _WIDTH * (long) _HEIGHT) > MAXIMG)
	{
		return (EGIFBIG);
	}



	/*
	 *   if just an inquiry, quit now...
	 */
	if (opt == INQUIRE)
		return (EGIFOK);



	/*
	 *   read raster data
	 */
	if (_ReadRaster (infile, codedgif, scrninf, raster, opt))
	{
		return (EGIFRAST);
	}

	/* at this point, Raster[] contains colormap indices at each pixel */
	printf("Number of calls to _ReadCode: %ld", rcount);
	return (EGIFOK);
}


/* NEW, this routine reverses the loaded data to simplify ReadCode */

void rasinv(uchar_t *codedgif)
{
	char *ptmp1, *ptmp2, tmp;	

	ptmp1 = codedgif;
	ptmp2 = &codedgif[RasTop];
	while (ptmp1 < ptmp2) {
		tmp = *ptmp1;
		*ptmp1++ = *ptmp2;
		*ptmp2-- = tmp;
	}
}

int rasunpack(uchar_t *codedgif, uchar_t *raster, int opt)
{
	int i;
	int *tmpoutc, tmpoutcnt;
	int tmpcurc, _Code, _FreeCode;
	int *tmpsuf, *tmppre;

/* NEW, quite a few local temporary variables to speed up unpacking */

	tmpoutc = _OutCode;
	tmpoutcnt = 0;
	_FreeCode = _FirstFree;
	tmpsuf = _Suffix;
	tmppre = _Prefix;
	_Code = _ReadCode (codedgif);
	while (_Code != _EOFCode)
	{

		/*
		 *   Clear code sets everything back to its initial value,
		 *   then reads the immediately subsequent code as
		 *   uncompressed data.
		 */
		if (_Code == _ClearCode)
		{
			_CodeSize = _InitCodeSize;
			_MaxCode  = (1 << _CodeSize);
			_ReadMask = _MaxCode - 1;
			_FreeCode = _FirstFree;
			_Code     = _ReadCode (codedgif);
/*			_CurCode  = _Code; */
			tmpcurc   = _Code;
			_OldCode  = _Code;
			_FinChar  = _CurCode & _BitMask;

			_AddPixel ((uchar_t) _FinChar, raster, opt);
		}
		else
		{

			/*
			 *   If not a clear code, then must be data: save
			 *   same as _CurCode and _InCode
			 */
/*			_CurCode = _Code; */
			tmpcurc = _Code;
			_InCode  = _Code;

			/*
			 *   If greater or equal to _FreeCode, not in
			 *   the hash table yet;
			 *   repeat the last character decoded
			 */
/*			if (_CurCode >= _FreeCode) */
			if (tmpcurc >= _FreeCode)
			{
/*				_CurCode              = _OldCode; */
				tmpcurc = _OldCode;
/*				_OutCode[_OutCount++] = _FinChar; */
				*tmpoutc++ = _FinChar;
				tmpoutcnt++;
			}

			/*
			 *   Unless this code is raw data, pursue the chain
			 *   pointed to by _CurCode through the hash table
			 *   to its end; each code in the chain puts its
			 *   associated output code on the output queue.
			 */
/*			while (_CurCode > _BitMask) */
			while (tmpcurc > _BitMask)
			{
/*				if (_OutCount > 1024) */
				if (tmpoutcnt > 1024)
				{
/*					fprintf (stderr, "corrupt GIF file (_OutCount)\n");*/
					return (1);
				}
/*				_OutCode[_OutCount++] = _Suffix[_CurCode]; */
				*tmpoutc++ = tmpsuf[tmpcurc];
				tmpoutcnt++;
/*				_CurCode              = _Prefix[_CurCode]; */
				tmpcurc = tmppre[tmpcurc];
			}

			/*
			 *   The last code in the chain is treated as raw data
			 */
/*			_FinChar              = _CurCode & _BitMask; */
			_FinChar = tmpcurc & _BitMask;
/*			_OutCode[_OutCount++] = _FinChar; */
			*tmpoutc++ = _FinChar;
			tmpoutcnt++;

			/*
			 *   Now we put the data out to the Output routine.
			 *   It's been stacked LIFO, so deal with it that way
			 */
			for (i = tmpoutcnt - 1; i >= 0; i--)
				_AddPixel ((uchar_t) *(--tmpoutc), raster, opt);
			tmpoutcnt = 0;
			tmpoutc = _OutCode;

			/*
			 *   Build the hash table on-the-fly. No table is
			 *   stored in the file.
			 */
/*			_Prefix[_FreeCode] = _OldCode; */
			tmppre[_FreeCode] = _OldCode;
/*			_Suffix[_FreeCode] = _FinChar; */
			tmpsuf[_FreeCode] = _FinChar;
			_OldCode           = _InCode;

			/*
			 *   Point to the next slot in the table.  If we
			 *   exceed the current _MaxCode value, increment
			 *   the code size unless it's already 12.  If it
			 *   is, do nothing: the next code decompressed
			 *   better be CLEAR
			 */
			_FreeCode++;
			if (_FreeCode >= _MaxCode)
			{
				if (_CodeSize < 12)
				{
					_CodeSize++;
					_MaxCode *= 2;
					_ReadMask = (1 << _CodeSize) - 1;
				}
			}
		}
		_Code = _ReadCode (codedgif);
	}
	return(0);
}

/*------------------------------*/
/*	_ReadRaster		*/
/*------------------------------*/
LOCAL int _ReadRaster (infile, codedgif, scrninf, raster, opt)
/* int		infile; */
FILE	*infile;
uchar_t	       *codedgif;
screen_t       *scrninf;
uchar_t	       *raster;
int		opt;
{

/* externals: _CodeSize,_Eof,_ClearCode,_EOFCode,_FreeCode,_FirstFree,
              _InitCodeSize,_MaxCode,_ReadMask,... */

/*
 *	Decode a raster image
 */

	uchar_t		*pcoded,*pncoded;
	uchar_t		*praster;
	uint_t		ch;
	uint_t		ch1;
	int			i;
	size_t			nread;


	/*
	 *   Start reading the raster data. First we get the intial code size
	 *   and compute decompressor constant values, based on this code size.
	 */
	if (opt != SILENT)
		printf ("\nRead raster data\n");

	_CodeSize  = getc (infile);
	if (feof (infile))
	{
/*		fprintf (stderr, "_ReadRaster: unexpected EOF\n");*/
		return (1);
	}
	_ClearCode = (1 << _CodeSize);
	_EOFCode   = _ClearCode + 1;
	_FreeCode  = _FirstFree = _ClearCode + 2;



	/*
	 *   The GIF spec has it that the code size is the code size used to
	 *   compute the above values is the code size given in the file, but
	 *   the code size used in compression/decompression is the code size
	 *   given in the file plus one. (thus the ++).
	 */
	_CodeSize++;
	_InitCodeSize = _CodeSize;
	_MaxCode      = (1 << _CodeSize);
	_ReadMask     = _MaxCode - 1;

	if (opt != SILENT)
	{
		printf ("     CodeSize  = %04x\n", _CodeSize);
		printf ("     ClearCode = %04x\n", _ClearCode);
		printf ("     EOFCode   = %04x\n", _EOFCode);
		printf ("     MaxCode   = %04x\n", _MaxCode);
		printf ("     ReadMask  = %04x\n", _ReadMask);
	}



	/*
	 *   Read the raster data. Here we just transpose it from the GIF array
	 *   to the Raster array, turning it from a series of blocks into one
	 *   long data stream, which makes life much easier for _ReadCode().
	 */
	 
/* NEW, the loading and unblocking is all new */

	nread = fread(codedgif, 1, MAXRAW, infile);	/* Read as much as possible */
	pcoded = pncoded = codedgif;
	for(;;)
	{
		if (!(ch = (uint_t)*pcoded++))
			break;
			
		if (((long) pcoded - (long) codedgif) > MAXRAW-255)
		{
/*			fprintf (stderr, "corrupt GIF file (unblock)\n");*/
			return (1);
		}

		while (ch != 0) {
			*pncoded++ = *pcoded++;
			ch--;
		}

	}


	RasTop = pncoded - codedgif;	/* NEW, was pcoded */

	rasinv(codedgif);		/* NEW */

	if ((RasTop - 2 * (RasTop >> 1)) == 1) { /* RasTop odd */
		_BitOffset = 0;
		RasTop++;
	}
	else {
		_BitOffset = 8;
		RasTop += 2;
	}

	/*
	 *   Decompress the file, continuing until you see the GIF EOF code.
	 *   One obvious enhancement is to add checking for corrupt files here.
	 */
	if (opt != SILENT)
	{
		printf ("\nDecompressing data\n");
		printf ("     Width            = %d\n", (int) scrninf->s_dx);
		printf ("     Height           = %d\n", (int) scrninf->s_dy);
		printf ("     Bits/pixel       = %d\n", (int) scrninf->s_bits);
		printf ("     Number of colors = %d\n", (int) scrninf->s_colors);
	}

	return(rasunpack(codedgif, raster, opt));
}

/*------------------------------*/
/*	_ReadCode		*/
/*------------------------------*/
LOCAL int _ReadCode (uchar_t *codedgif)
{

/* externals: _BitOffset,_CodeSize,_ReadMask */

/*
 * NEW, this routine has been rewritten from scratch to be more efficient
 */

	reg_t ulong_t		rawcode;

	rcount++;		/* This should be removed */

	rawcode = *(long *)(&codedgif[RasTop - 2 * (_BitOffset >> 4) - 4]);
	
	rawcode   >>= _BitOffset % 16;
	_BitOffset += _CodeSize;

	return((int)(rawcode & (ulong_t) _ReadMask));
}



/*------------------------------*/
/*	_AddPixel		*/
/*------------------------------*/
LOCAL int _AddPixel (uchar_t indx, uchar_t *raster, int opt)
/* uchar_t		indx;
uchar_t	       *raster;
int		opt; */		/* NEW, GCC wants the prototype */
{

/* externals: _XC,_YC,_WIDTH,_HEIGHT,_Interlace,_Pass */

	reg_t long	oset;		/* linear ptr into Raster */


	/*
	 *   check for array overflow...
	 */
	oset = _YCbyte + _XC;
/*
	if (opt == VERBOSE && _XC == _WIDTH/2)
		fprintf (stderr, "_AddPixel: _XC,_YC = %d,%d, oset = %ld, indx = %02x\n",
				_XC, _YC, oset, (uint_t) indx);

	if (oset > MAXIMG)
	{
		fprintf (stderr, "_AddPixel: image too large\n");
		exit (1);
	}
*/

	/*
	 *   add to raster array...
	 */
	if (_YC < _HEIGHT)
	{
		raster[oset] = indx;
	}


	/*
	 *   Update the X-coordinate, and if it overflows, update the
	 *   Y-coordinate
	 */
	if (++_XC == _WIDTH)
	{
		_XC = 0;

		/*
		 *   If a non-interlaced picture, just increment _YC to the
		 *   next scan line. If it's interlaced, deal with the
		 *   interlace as described in the GIF spec.  Put the
		 *   decoded scan line out to the screen if we haven't gone
		 *   past the bottom of it
		 */
		if (!_Interlace) {
			_YC++;
			_YCbyte += _WIDTH;
		}
		else
		{
			switch (_Pass)
			{
			case 0:
				_YC += 8;
				_YCbyte += 8 * _WIDTH;
				if (_YC >= _HEIGHT)
				{
					_Pass++;
					_YC = 4;
					_YCbyte = 4 * _WIDTH;
				}
				break;
			case 1:
				_YC += 8;
				_YCbyte += 8 * _WIDTH;
				if (_YC >= _HEIGHT)
				{
					_Pass++;
					_YC = 2;
					_YCbyte = 2 * _WIDTH;
				}
				break;
			case 2:
				_YC += 4;
				_YCbyte += 4 * _WIDTH;
				if (_YC >= _HEIGHT)
				{
					_Pass++;
					_YC = 1;
					_YCbyte = _WIDTH;
				}
				break;
			case 3:
				_YC += 2;
				_YCbyte += 2 * _WIDTH;
				break;
			default:
				fprintf (stderr, "_AddPixel: can't happen\n");
			}
		}
	}
}




/*------------------------------*/
/*	_InstCMap		*/
/*------------------------------*/
LOCAL void _InstCMap (ncolors, cm, map, opt)
int		ncolors;
uchar_t	       *cm;
uchar_t		map[][3];
int		opt;
{

/*
 *	copy cm colormap to map color map for ncolors
 */

	reg_t uchar_t	       *scan;
	reg_t int		i;

	/*
	 *   most all images currently use global map, though this will
	 *   copy whatever cm points to (either local or global) into the
	 *   real map we use...
	 */
	for (scan = cm, i = 0; ncolors > 0; i++, ncolors--)
	{
		map[i][0] = *scan++;
		map[i][1] = *scan++;
		map[i][2] = *scan++;
	}

}




/*------------------------------*/
/*	_ScanSD			*/
/*------------------------------*/
LOCAL int _ScanSD (infile, sd, opt)
/* int		infile; */
FILE	*infile;
screen_t       *sd;
int		opt;
{

/*
 *	read logical screen descriptor (req'd)
 *
 *		bits
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	|		|  1
 *	+-Screen Width -+	Raster width in pixels (LSB first)
 *	|		|  2
 *	+---------------+
 *	|		|  3
 *	+-Screen Height-+	Raster height in pixels (LSB first)
 *	|		|  4
 *	+-+-----+-+-----+	M = 1, Global color map follows Descriptor
 *	|M|  cr |0|pixel|  5	cr+1 = # bits of color resolution
 *	+-+-----+-+-----+	pixel+1 = # bits/pixel in image
 *	|   background  |  6	background=Color index of screen background
 *	+---------------+	     (color is defined from the Global color
 *	|0 0 0 0 0 0 0 0|  7	      map or default map if none specified)
 *	+---------------+
 */


	reg_t uchar_t	data;
	reg_t uint_t	idata;



	idata        = (uint_t) getc (infile);		/* width */
	sd->s_dx     = idata + ((uint_t) getc (infile) << 8);

	idata        = (uint_t) getc (infile);		/* height */
	sd->s_dy     = idata + ((uint_t) getc (infile) << 8);


	idata        = getc (infile);
	if (idata & 8)					/* bit must be 0 */
		return (0);				/* error... */

	sd->s_gcm    = (idata >> 7) & 0x01;		/* global color map?*/
	sd->s_cr     = (idata & 0x70) >> 4;		/* color resolution */
	sd->s_bits   = (idata & 7) + 1;			/* pix size, bits */
	sd->s_colors = 1 << sd->s_bits;			/* num colors */
	sd->s_bgnd   = getc (infile);			/* background color */

	idata        = getc (infile);
	if (idata != 0)					/* sorted map? */
		return (0);

	return (!0);
}




/*------------------------------*/
/*	_SkipEB			*/
/*------------------------------*/
LOCAL void _SkipEB (infile, opt)
/* int	infile; */
FILE	*infile;
int	opt;
{

/*
 *	skips extension block
 *
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	|0 0 1 0 0 0 0 1|  1	   '!' - GIF Extension Block Introducer
 *	+---------------+
 *	| function code |  2	   Extension function code (0 to 255)
 *	+---------------+    ---+
 *	|  byte count	|	|
 *	+---------------+	|
 *	:		:	+-- Repeated as many times as necessary
 *	|func data bytes|	|
 *	:		:	|
 *	+---------------+    ---+
 *	. . .	    . . .
 *	+---------------+
 *	|0 0 0 0 0 0 0 0|	zero byte count (terminates block)
 *	+---------------+
 */

	reg_t uint_t	count;
	char		garbage[256];



	if (opt != SILENT)
		printf ("\nSkip extension block\n");

	getc (infile);			/* get function */

	while (count = (uint_t) getc (infile))	/* get data */
	{
		if (feof (infile))
		{
			fprintf (stderr, "_SkipEB: unexpected EOF\n");
			exit (1);
		}

		fread (garbage, 1, count, infile);

		if (feof (infile))
		{
			fprintf (stderr, "_SkipEB: unexpected EOF\n");
			exit (1);
		}
	}
}




/*------------------------------*/
/*	_ScanID			*/
/*------------------------------*/
LOCAL int _ScanID (infile, id, opt)
/* int		infile; */
FILE	*infile;
image_t        *id;
int		opt;
{

/*
 *	read image descriptor (req'd)
 *
 *	      bits
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	|0 0 1 0 1 1 0 0|  1	',' - Image separator character
 *	+---------------+
 *	|		|  2	Start of image in pixels from the
 *	+-  Image Left -+	left side of the screen (LSB first)
 *	|		|  3
 *	+---------------+
 *	|		|  4
 *	+-  Image Top  -+	Start of image in pixels from the
 *	|		|  5	top of the screen (LSB first)
 *	+---------------+
 *	|		|  6
 *	+- Image Width -+	Width of the image in pixels (LSB first)
 *	|		|  7
 *	+---------------+
 *	|		|  8
 *	+- Image Height-+	Height of the image in pixels (LSB first)
 *	|		|  9
 *	+-+-+-+-+-+-----+	M=0 - Use global color map, ignore 'pixel'
 *	|M|I|0|0|0|pixel| 10	M=1 - Local color map follows, use 'pixel'
 *	+-+-+-+-+-+-----+	I=0 - Image formatted in Sequential order
 *				I=1 - Image formatted in Interlaced order
 *				pixel+1 - # bits per pixel for this image
 */

	reg_t uchar_t	data;


	/*
	 *   skip extension block
	 */
	do
	{
		data = (uchar_t) getc (infile);

		if (feof (infile))
			return (0);
		if (data == ';')
			return (1);
		if (data == 0x21)
			_SkipEB (infile, opt);

	} while (data != 0x2c);				/* ',' is ID start */

	data       = (uchar_t) getc (infile);		/* left coord */
	id->i_x    = data + ((uchar_t) getc (infile) << 8);

	data       = (uchar_t) getc (infile);		/* top coord */
	id->i_y    = data + ((uchar_t) getc (infile) << 8);

	data       = (uchar_t) getc (infile);		/* width */
	id->i_dx   = data + ((uchar_t) getc (infile) << 8);

	data       = (uchar_t) getc (infile);		/* height */
	id->i_dy   = data + ((uchar_t) getc (infile) << 8);

	data         = (uchar_t) getc (infile);		/* flag: */
	id->i_gcm    = (data >> 7) & 0x01;		/* local color map? */
	id->i_intlace= (data >> 6) & 0x01;		/* interlaced? */
	id->i_bits   = (data & 7) + 1;
	id->i_colors = 1 << id->i_bits;

	return (2);
}




/*------------------------------*/
/*	_ScanCM			*/
/*------------------------------*/
LOCAL void _ScanCM (infile, colors, cm, opt)
/* int		infile; */
FILE	*infile;
int		colors;
char	       *cm;
int		opt;		/* SILENT, INQUIRE, VERBOSE */
{

/*
 *	read a color map (optional)
 *
 *	      bits
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	| red intensity |  1	Red value for color index 0
 *	+---------------+
 *	|green intensity|  2	Green value for color index 0
 *	+---------------+
 *	| blue intensity|  3	Blue value for color index 0
 *	+---------------+
 *	| red intensity |  4	Red value for color index 1
 *	+---------------+
 *	|green intensity|  5	Green value for color index 1
 *	+---------------+
 *	| blue intensity|  6	Blue value for color index 1
 *	+---------------+
 *	:		:	(Continues for remaining colors)
 *
 */

	reg_t char	       *scan;
	reg_t int		i;


	if (opt != SILENT)
		fprintf (stderr, "\nRead color map\n");

	for (scan = cm, i = colors; i > 0; i--, scan += 3)
	{
		*scan =     (char) getc (infile);
		*(scan+1) = (char) getc (infile);
		*(scan+2) = (char) getc (infile);

		if (opt == VERBOSE)
		{
			fprintf (stderr, "addr:     %08lx %08lx %08lx\n",
				(long) (scan),
				(long) (scan+1),
				(long) (scan+2));
			fprintf (stderr, "vals:     %02x %02x %02x\n",
				(uint_t) (*scan),
				(uint_t) (*(scan+1)),
				(uint_t) (*(scan+2)));
		}
	}

	if (opt == VERBOSE)
	{
		printf ("\n     Color map for %d colors:\n\n", colors);
		for (scan = cm, i = colors; i > 0; i--, scan += 3)
			printf ("     %02x %02x %02x\n",
				(uint_t) (*scan),
				(uint_t) (*(scan+1)),
				(uint_t) (*(scan+2)));
		printf ("\n");
	}
}



/*------------------------------*/
/*	_ScanMAGIC		*/
/*------------------------------*/
LOCAL int _ScanMAGIC (infile, parse, opt)
/* int	infile; */
FILE	*infile;
char   *parse;
int	opt;
{

/*
 *	read chars from file "infile" and look for string "parse" from
 *	current file position. return 0 if no match at first mismatch.
 */

	reg_t char  *scan;


	for (scan = parse; *scan; scan++)
	{
		if (getc (infile) != (int) *scan)
			return (0);
	}
	return (!0);
}




/*------------------------------*/
/*	_GetKey			*/
/*------------------------------*/
LOCAL int _GetKey ()
{

/*
 *	ckecks for a key and flushes keyboard buffer. same as check_key().
 */

	if (Bconstat (2))			/* if CONSOLE has a char... */
	{
		while (Bconstat (2))		/* read char while there are */
			Bconin (2);		/* chars to read (flush) */
		return (1);			/* yes, there was a key */
	}
	return (0);				/* no key */
}

