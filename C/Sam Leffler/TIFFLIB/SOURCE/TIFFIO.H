#ifndef __TIFFIO_H__
#define __TIFFIO_H__
/*
 * Copyright (c) 1988, 1990 by Sam Leffler.
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * Tag Image File Format (TIFF)
 *
 * Based on Rev 5.0 from:
 *    Developer's Desk          Window Marketing Group
 *    Aldus Corporation         Microsoft Corporation
 *    411 First Ave. South      16011 NE 36th Way
 *    Suite 200                 Box 97017
 *    Seattle, WA  98104        Redmond, WA  98073-9717
 *    206-622-5500              206-882-8080
 *
 * TIFF I/O Library Definitions.
 */

/****************************************************************************
 * @(#)TIFF/tiffcompat.h 1.09, Copyright (c) Sam Leffler, Dieter Linde, Nov 15 1990
 */
#include <stdio.h>
#include <string.h>
#include <tos.h>

#define	NEXT_SUPPORT
#define	PICIO_SUPPORT
#define	SGI_SUPPORT
#define	THUNDER_SUPPORT

#define L_SET  	SEEK_SET
#define L_INCR  SEEK_CUR
#define L_XTND  SEEK_END

#define bzero(dst, len)        	memset(dst, 0, len)
#define bcopy(src, dst, len)   	memcpy(dst, src, len)
#define bcmp(src, dst, len)     memcmp(dst, src, len)

typedef unsigned char	u_char;
typedef unsigned short 	u_short;
typedef unsigned int 	u_int;
typedef unsigned long 	u_long;

/*
 * Return an open file descriptor or -1.
 */
/*#define TIFFOpenFile(name, mode, prot)	Fopen(name, mode, prot)*/
#define TIFFOpenFile(name, mode, prot)  open(name, mode, prot)

#ifndef L_SET
#define L_SET  	0
#define L_INCR  1
#define L_XTND  2
#endif
/*
#define ReadOK(fd, buf, size)   (Fread(fd, (long)size, (char *)buf) == (long)size)
#define SeekOK(fd, off) 	(Fseek((long)off, fd, L_SET) == (long)off)
#define WriteOK(fd, buf, size)  (Fwrite(fd, (long)size, (char *)buf) == (long)size)
*/
#ifndef ReadOK
#define ReadOK(fd, buf, size)   (read(fd, (char *)buf, (size_t)size) == (size_t)size)
#endif
#ifndef SeekOK
#define SeekOK(fd, off) 	(lseek(fd, (long)off, L_SET) == (long)off)
#endif
#ifndef WriteOK
#define WriteOK(fd, buf, size)  (write(fd, (char *)buf, (size_t)size) == (size_t)size)
#endif

/*
 * dblparam_t is the type that a double precision floating point value will have on the parameter
 * stack (when coerced by the compiler).
 */
#ifdef applec
typedef extended	dblparam_t;
#else
typedef double		dblparam_t;
#endif

/****************************************************************************
 * @(#)TIFF/tiff.h 1.19, Copyright (c) Sam Leffler, Dieter Linde, Oct 8 1990
 */
#define TIFF_VERSION		42
#define TIFF_BIGENDIAN          0x4d4d
#define TIFF_LITTLEENDIAN       0x4949

typedef struct {
        u_short	tiff_magic;     /* magic number (defines byte order) */
        u_short tiff_version;   /* TIFF version number */
        u_long  tiff_diroff;	/* byte offset to first directory */
} TIFFHeader;

/*
 * TIFF Image File Directories are comprised of a table of field descriptors of the form shown
 * below.  The table is sorted in ascending order by tag.  The values associated with each entry
 * are disjoint and may appear anywhere in the file (so long as they are placed on a word boundary).
 *
 * If the value is 4 bytes or less, then it is placed in the offset field to save space.  If the value
 * is less than 4 bytes, it is left-justified in the offset field.
 */
typedef struct {
        u_short	tdir_tag;       /* see below */
        u_short tdir_type;      /* data type; see below */
        u_long  tdir_count;     /* number of items; length in spec */
        u_long  tdir_offset;   	/* byte offset to field data */
} TIFFDirEntry;

typedef enum {
        TIFF_BYTE = 1,          /* 8-bit unsigned integer */
        TIFF_ASCII = 2,         /* 8-bit bytes w/ last byte null */
        TIFF_SHORT = 3,         /* 16-bit unsigned integer */
        TIFF_LONG = 4,          /* 32-bit unsigned integer */
        TIFF_RATIONAL = 5       /* 64-bit fractional (numerator+denominator) */
} TIFFDataType;

/*
 * TIFF Tag Definitions.
 *
 * Those marked with a + are obsoleted by revision 5.0
 */
#define TIFFTAG_SUBFILETYPE             254     /* subfile data descriptor */
#define     FILETYPE_REDUCEDIMAGE       0x1     /* reduced resolution version */
#define     FILETYPE_PAGE               0x2     /* one page of many */
#define     FILETYPE_MASK               0x4     /* transparency mask */
#define TIFFTAG_OSUBFILETYPE            255     /* +kind of data in subfile */
#define     OFILETYPE_IMAGE             1       /* full resolution image data */
#define     OFILETYPE_REDUCEDIMAGE      2       /* reduced size image data */
#define     OFILETYPE_PAGE              3       /* one page of many */
#define TIFFTAG_IMAGEWIDTH              256     /* image width in pixels */
#define TIFFTAG_IMAGELENGTH             257     /* image height in pixels */
#define TIFFTAG_BITSPERSAMPLE           258     /* bits per channel (sample) */
#define TIFFTAG_COMPRESSION             259     /* data compression technique */
#define     COMPRESSION_NONE            1       /* dump mode */
#define     COMPRESSION_CCITTRLE        2       /* CCITT modified Huffman RLE */
#define     COMPRESSION_CCITTFAX3       3       /* CCITT Group 3 fax encoding */
#define     COMPRESSION_CCITTFAX4       4       /* CCITT Group 4 fax encoding */
#define     COMPRESSION_LZW             5       /* Lempel-Ziv & Welch */
#define     COMPRESSION_NEXT            32766U	/* NeXT 2-bit RLE */
#define     COMPRESSION_CCITTRLEW       32771U  /* #1 w/ word alignment */
#define     COMPRESSION_PACKBITS        32773U  /* Macintosh RLE */
#define     COMPRESSION_THUNDERSCAN     32809U  /* ThunderScan RLE */
#define     COMPRESSION_PICIO           32900U  /* old Pixar picio RLE */
#define     COMPRESSION_SGIRLE          32901U  /* Silicon Graphics RLE */
#define TIFFTAG_PHOTOMETRIC             262     /* photometric interpretation */
#define     PHOTOMETRIC_MINISWHITE      0       /* min value is white */
#define     PHOTOMETRIC_MINISBLACK      1       /* min value is black */
#define     PHOTOMETRIC_RGB             2       /* RGB color model */
#define     PHOTOMETRIC_PALETTE         3       /* color map indexed */
#define     PHOTOMETRIC_MASK            4       /* holdout mask */
#define     PHOTOMETRIC_DEPTH           32768U  /* z-depth data */
#define TIFFTAG_THRESHHOLDING           263     /* +thresholding used on data */
#define     THRESHHOLD_BILEVEL          1       /* b&w art scan */
#define     THRESHHOLD_HALFTONE         2       /* or dithered scan */
#define     THRESHHOLD_ERRORDIFFUSE     3       /* usually floyd-steinberg */
#define TIFFTAG_CELLWIDTH               264     /* +dithering matrix width */
#define TIFFTAG_CELLLENGTH              265     /* +dithering matrix height */
#define TIFFTAG_FILLORDER               266     /* +data order within a byte */
#define     FILLORDER_MSB2LSB           1       /* most significant -> least */
#define     FILLORDER_LSB2MSB           2       /* least significant -> most */
#define TIFFTAG_DOCUMENTNAME            269     /* name of doc. image is from */
#define TIFFTAG_IMAGEDESCRIPTION        270     /* info about image */
#define TIFFTAG_MAKE                    271     /* scanner manufacturer name */
#define TIFFTAG_MODEL                   272     /* scanner model name/number */
#define TIFFTAG_STRIPOFFSETS            273     /* offsets to data strips */
#define TIFFTAG_ORIENTATION             274     /* +image orientation */
#define     ORIENTATION_TOPLEFT         1       /* row 0 top, col 0 lhs */
#define     ORIENTATION_TOPRIGHT        2       /* row 0 top, col 0 rhs */
#define     ORIENTATION_BOTRIGHT        3       /* row 0 bottom, col 0 rhs */
#define     ORIENTATION_BOTLEFT         4       /* row 0 bottom, col 0 lhs */
#define     ORIENTATION_LEFTTOP         5       /* row 0 lhs, col 0 top */
#define     ORIENTATION_RIGHTTOP        6       /* row 0 rhs, col 0 top */
#define     ORIENTATION_RIGHTBOT        7       /* row 0 rhs, col 0 bottom */
#define     ORIENTATION_LEFTBOT         8       /* row 0 lhs, col 0 bottom */
#define TIFFTAG_SAMPLESPERPIXEL         277     /* samples per pixel */
#define TIFFTAG_ROWSPERSTRIP            278     /* rows per strip of data */
#define TIFFTAG_STRIPBYTECOUNTS         279     /* bytes counts for strips */
#define TIFFTAG_MINSAMPLEVALUE          280     /* +minimum sample value */
#define TIFFTAG_MAXSAMPLEVALUE          281     /* maximum sample value */
#define TIFFTAG_XRESOLUTION             282     /* pixels/resolution in x */
#define TIFFTAG_YRESOLUTION             283     /* pixels/resolution in y */
#define TIFFTAG_PLANARCONFIG            284     /* storage organization */
#define     PLANARCONFIG_CONTIG         1       /* single image plane */
#define     PLANARCONFIG_SEPARATE       2       /* separate planes of data */
#define TIFFTAG_PAGENAME                285     /* page name image is from */
#define TIFFTAG_XPOSITION               286     /* x page offset of image lhs */
#define TIFFTAG_YPOSITION               287     /* y page offset of image lhs */
#define TIFFTAG_FREEOFFSETS             288     /* +byte offset to free block */
#define TIFFTAG_FREEBYTECOUNTS          289     /* +sizes of free blocks */
#define TIFFTAG_GRAYRESPONSEUNIT        290     /* gray scale curve accuracy */
#define     GRAYRESPONSEUNIT_10S        1       /* tenths of a unit */
#define     GRAYRESPONSEUNIT_100S       2       /* hundredths of a unit */
#define     GRAYRESPONSEUNIT_1000S      3       /* thousandths of a unit */
#define     GRAYRESPONSEUNIT_10000S     4       /* ten-thousandths of a unit */
#define     GRAYRESPONSEUNIT_100000S    5       /* hundred-thousandths */
#define TIFFTAG_GRAYRESPONSECURVE       291     /* gray scale response curve */
#define TIFFTAG_GROUP3OPTIONS           292     /* 32 flag bits */
#define     GROUP3OPT_2DENCODING        0x1     /* 2-dimensional coding */
#define     GROUP3OPT_UNCOMPRESSED      0x2     /* data not compressed */
#define     GROUP3OPT_FILLBITS          0x4     /* fill to byte boundary */
#define TIFFTAG_GROUP4OPTIONS           293     /* 32 flag bits */
#define     GROUP4OPT_UNCOMPRESSED      0x2     /* data not compressed */
#define TIFFTAG_RESOLUTIONUNIT          296     /* units of resolutions */
#define     RESUNIT_NONE                1       /* no meaningful units */
#define     RESUNIT_INCH                2       /* english */
#define     RESUNIT_CENTIMETER          3       /* metric */
#define TIFFTAG_PAGENUMBER              297     /* page numbers of multi-page */
#define TIFFTAG_COLORRESPONSEUNIT       300     /* color scale curve accuracy */
#define     COLORRESPONSEUNIT_10S       1       /* tenths of a unit */
#define     COLORRESPONSEUNIT_100S      2       /* hundredths of a unit */
#define     COLORRESPONSEUNIT_1000S     3       /* thousandths of a unit */
#define     COLORRESPONSEUNIT_10000S    4       /* ten-thousandths of a unit */
#define     COLORRESPONSEUNIT_100000S   5       /* hundred-thousandths */
#define TIFFTAG_COLORRESPONSECURVE      301     /* RGB response curve */
#define TIFFTAG_SOFTWARE                305     /* name & release */
#define TIFFTAG_DATETIME                306     /* creation date and time */
#define TIFFTAG_ARTIST                  315     /* creator of image */
#define TIFFTAG_HOSTCOMPUTER            316     /* machine where created */
#define TIFFTAG_PREDICTOR               317     /* prediction scheme w/ LZW */
#define TIFFTAG_WHITEPOINT              318     /* image white point */
#define TIFFTAG_PRIMARYCHROMATICITIES   319     /* primary chromaticities */
#define TIFFTAG_COLORMAP                320     /* RGB map for pallette image */
#define TIFFTAG_BADFAXLINES             326     /* lines w/ wrong pixel count */
#define TIFFTAG_CLEANFAXDATA            327     /* regenerated line info */
#define      CLEANFAXDATA_CLEAN         0       /* no errors detected */
#define      CLEANFAXDATA_REGENERATED   1       /* receiver regenerated lines */
#define      CLEANFAXDATA_UNCLEAN       2       /* uncorrected errors exist */
#define TIFFTAG_CONSECUTIVEBADFAXLINES  328     /* max consecutive bad lines */
/*** tags 32995-32999 are private tags registered to SGI ***/
#define TIFFTAG_MATTEING                32995U	/* alpha channel is present */

/****************************************************************************
 * @(#)TIFF/tiffio.h 1.29, Copyright (c) Sam Leffler, Dieter Linde, Nov 15 1990
 */

/*
 * Internal format of a TIFF directory entry.
 */
typedef struct {
       	u_short	td_subfiletype;
        u_short td_imagewidth, td_imagelength;
        u_short td_bitspersample;
        u_short td_compression;
        u_short td_photometric;
        u_short td_threshholding;
        u_short td_fillorder;
        u_short td_orientation;
        u_short td_samplesperpixel;
        u_short td_predictor;
        u_long  td_rowsperstrip;
        u_long  td_minsamplevalue, td_maxsamplevalue;	/* maybe float? */
        float   td_xresolution, td_yresolution;
        u_short td_resolutionunit;
        u_short td_planarconfig;
        float   td_xposition, td_yposition;
        u_long  td_group3options;
        u_long  td_group4options;
        u_short td_pagenumber[2];
        u_short td_grayresponseunit;
        u_short td_colorresponseunit;
        u_short td_matteing;
        u_short td_cleanfaxdata;
        u_short td_badfaxrun;
        u_long  td_badfaxlines;
        u_short *td_grayresponsecurve;	/* u_short for now (maybe float?) */
        u_short *td_redresponsecurve;   /* u_short for now (maybe float?) */
        u_short *td_greenresponsecurve; /* u_short for now (maybe float?) */
        u_short *td_blueresponsecurve;  /* u_short for now (maybe float?) */
        u_short *td_redcolormap;
        u_short *td_greencolormap;
        u_short *td_bluecolormap;

#ifdef 	notdef
	/* not yet used/supported */
        float   td_whitepoint[2];
        float   td_primarychromaticities[6];
#endif

        char    *td_documentname;
        char    *td_artist;
        char    *td_datetime;
        char    *td_hostcomputer;
        char    *td_imagedescription;
        char    *td_make;
        char    *td_model;
        char    *td_software;
        char    *td_pagename;
        u_long  td_fieldsset[2];       	/* bit vector of fields that are set */
        u_long  td_stripsperimage;
        u_long  td_nstrips;             /* size of offset & bytecount arrays */
        u_long  *td_stripoffset;
        u_long  *td_stripbytecount;
} TIFFDirectory;

/*
 * Field flags used to indicate fields that have been set in a directory, and to reference fields
 * when manipulating a directory.
 */
/*** multi-entry fields ***/
#define FIELD_IMAGEDIMENSIONS           0
#define FIELD_CELLDIMENSIONS            1               /* XXX */
#define FIELD_RESOLUTION                2
#define FIELD_POSITION                  3
/*** single-entry fields ***/
#define FIELD_SUBFILETYPE               4
#define FIELD_BITSPERSAMPLE             5
#define FIELD_COMPRESSION               6
#define FIELD_PHOTOMETRIC               7
#define FIELD_THRESHHOLDING             8
#define FIELD_FILLORDER                 9               /* XXX */
#define FIELD_DOCUMENTNAME              10
#define FIELD_IMAGEDESCRIPTION          11
#define FIELD_MAKE                      12
#define FIELD_MODEL                     13
#define FIELD_ORIENTATION               14
#define FIELD_SAMPLESPERPIXEL           15
#define FIELD_ROWSPERSTRIP              16
#define FIELD_MINSAMPLEVALUE            17
#define FIELD_MAXSAMPLEVALUE            18
#define FIELD_PLANARCONFIG              19
#define FIELD_PAGENAME                  20
#define FIELD_GRAYRESPONSEUNIT          21
#define FIELD_GRAYRESPONSECURVE         22
#define FIELD_GROUP3OPTIONS             23
#define FIELD_GROUP4OPTIONS             24
#define FIELD_RESOLUTIONUNIT            25
#define FIELD_PAGENUMBER                26
#define FIELD_COLORRESPONSEUNIT         27
#define FIELD_COLORRESPONSECURVE        28
#define FIELD_STRIPBYTECOUNTS           29
#define FIELD_STRIPOFFSETS              31
#define FIELD_COLORMAP                  32
#define FIELD_PREDICTOR                 33
#define FIELD_ARTIST                    34
#define FIELD_DATETIME                  35
#define FIELD_HOSTCOMPUTER              36
#define FIELD_SOFTWARE                  37
#define FIELD_MATTEING                  38
#define FIELD_BADFAXLINES               39
#define FIELD_CLEANFAXDATA              40
#define FIELD_BADFAXRUN                 41
#define FIELD_LAST                      FIELD_BADFAXRUN

#define TIFFFieldSet(tif, field)	((tif)->tif_dir.td_fieldsset[field / 32] & (1UL << (field & 0x1f)))
#define TIFFSetFieldBit(tif, field)	((tif)->tif_dir.td_fieldsset[field / 32] |= (1UL << (field & 0x1f)))

typedef struct tiff_t {
        char    	*tif_name;              				/* name of open file */
        short   	tif_fd;                 				/* open file descriptor */
        short   	tif_mode;               				/* open mode (O_*) */
        char    	tif_fillorder;          				/* natural bit fill order for machine */
        char    	tif_options;            				/* compression-specific options */
        short   	tif_flags;
#define TIFF_DIRTYHEADER        0x1     					/* header must be written on close */
#define TIFF_DIRTYDIRECT        0x2     					/* current directory must be written */
#define TIFF_BUFFERSETUP        0x4     					/* data buffers setup */
#define TIFF_BEENWRITING        0x8     					/* written 1+ scanlines to file */
#define TIFF_SWAB               0x10    					/* byte swap file information */
#define TIFF_NOBITREV           0x20    					/* inhibit bit reversal logic */
        long    	tif_diroff;             				/* file offset of current directory */
        long    	tif_nextdiroff;         				/* file offset of following directory */
        TIFFDirectory 	tif_dir;          					/* internal rep of current directory */
        TIFFHeader 	tif_header;          					/* file's header block */
        int     	tif_typeshift[6];       				/* data type shift counts */
        long    	tif_typemask[6];        				/* data type masks */
        long    	tif_row;                				/* current scanline */
        int     	tif_curstrip;           				/* current strip for read/write */
        long    	tif_curoff;             				/* current offset for read/write */
/*** compression scheme hooks ***/
        int     	(*tif_stripdecode)(struct tiff_t *); 			/* strip decoding routine (pre) */
        int     	(*tif_decoderow)(struct tiff_t *, u_char *, int);	/* scanline decoding routine */
        int     	(*tif_stripencode)(struct tiff_t *);   			/* strip encoding routine (pre) */
        int     	(*tif_encoderow)(struct tiff_t *, u_char *, int);	/* scanline encoding routine */
        int     	(*tif_encodestrip)(struct tiff_t *);			/* strip encoding routine (post) */
        void    	(*tif_close)(struct tiff_t *);				/* cleanup-on-close routine */
        int     	(*tif_seek)(struct tiff_t *, long);			/* position within a strip routine */
        void     	(*tif_cleanup)(struct tiff_t *);			/* routine called to cleanup state */
        u_char    	*tif_data;              				/* compression scheme private data */
/*** input/output buffering ***/
        int     	tif_scanlinesize;       				/* # of bytes in a scanline */
        u_char    	*tif_rawdata;           				/* raw data buffer */
        long    	tif_rawdatasize;        				/* # of bytes in raw data buffer */
        u_char    	*tif_rawcp;             				/* current spot in raw buffer */
        long    	tif_rawcc;              				/* bytes unread from raw buffer */
} TIFF;

/* 
 * Generic option bit names.
 */
#define TIFF_OPT0       0x1
#define TIFF_OPT1       0x2
#define TIFF_OPT2       0x4
#define TIFF_OPT3       0x8
#define TIFF_OPT4       0x10
#define TIFF_OPT5       0x20
#define TIFF_OPT6       0x40
#define TIFF_OPT7       0x80

extern 	u_char	TIFFBitRevTable[256];
extern 	u_char	TIFFNoBitRevTable[256];

/*
 * Prototypes.
 */
/*** tif_error ***/
void 	TIFFError(char *, char *, ...);

/*** tif_warning ***/
void	TIFFWarning(char *, char *, ...);

/*** tif_swab ***/
void	TIFFSwabShort(u_short *);
void	TIFFSwabLong(u_long *);
void	TIFFSwabArrayOfShort(u_short *, int);
void	TIFFSwabArrayOfLong(u_long *, int);
void	TIFFReverseBits(u_char *, long);

/*** tif_compat ***/
long	TIFFGetFileSize(int);

/*** tif_flush ***/
int	TIFFFlush(TIFF *);

/*** tif_open ***/
TIFF 	*TIFFFdOpen(int, char *, char *);
TIFF 	*TIFFOpen(char *, char *);
int	TIFFScanlineSize(TIFF *);

/*** tif_read ***/
long	TIFFReadRawStrip(TIFF *, u_int, void *, u_long);
int	TIFFReadScanline(TIFF *, void *, u_int, u_int);
int	TIFFReadEncodedStrip(TIFF *, u_int, void *, u_int);

/*** tif_write ***/
int	TIFFFlushData1(TIFF *);
int	TIFFFlushData(TIFF *);
int	TIFFWriteScanline(TIFF *, void *, u_int, u_int);
int	TIFFWriteEncodedStrip(TIFF *, u_int, void *, u_int);
int	TIFFWriteRawStrip(TIFF *, u_int, void *, u_int);

/*** tif_close ***/
void	TIFFClose(TIFF *);

/*** tif_print ***/
void	TIFFPrintDirectory(TIFF *, FILE *, int, int, int);

/*** tif_dir ***/
int	TIFFSetField(TIFF *, u_short, ...);
int	TIFFDefaultDirectory(TIFF *);
int	TIFFReadDirectory(TIFF *);
void	TIFFFreeDirectory(TIFF *);
int	TIFFGetField(TIFF *, u_short, ...);
int	TIFFWriteDirectory(TIFF *);
int	TIFFSetDirectory(TIFF *, int);

/*** tif_ccittrle.c ***/
int 	TIFFInitCCITTRLE(TIFF *);
int	TIFFInitCCITTRLEW(TIFF *);

/*** tif_dumpmode ***/
int 	TIFFInitDumpMode(TIFF *);

/*** tif_fax3 ***/
void	TIFFModeCCITTFax3(TIFF *, int);
int	TIFFInitCCITTFax3(TIFF *);

/*** tif_fax4 ***/
int	TIFFInitCCITTFax4(TIFF *);

/*** tif_lzw ***/
int	TIFFInitLZW(TIFF *);

/*** tif_packbits ***/
int	TIFFInitPackBits(TIFF *);

/*** tif_next ***/
#ifdef 	NEXT_SUPPORT
int	TIFFInitNeXT(TIFF *);
#endif	/* NEXT_SUPPORT */

/*** tif_picio ***/
#ifdef 	PICIO_SUPPORT
int	TIFFInitPicio(TIFF *);
#endif	/* PICIO_SUPPORT */

/*** tif_sgi ***/
#ifdef 	SGI_SUPPORT
int 	TIFFInitSGI(TIFF *);
#endif	/* SGI_SUPPORT */

/*** tif_thunder ***/
#ifdef 	THUNDER_SUPPORT
int 	TIFFInitThunderScan(TIFF *);
#endif	/* THUNDER_SUPPORT */

/*** tif_compress ***/
int	TIFFSetCompressionScheme(TIFF *, u_short);

#endif	__TIFFIO_H__
