/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Beispiele fr Codieralgorithmen				*/
/*							CODING.TTP									*/
/*																		*/
/*		M O D U L E		:	COD_LIB.LIB									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 4.01, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.93 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#ifndef __COD_LIB__
#define __COD_LIB__

#ifdef __TOS__ && __TURBOC__

	/* suppress 'suspicious pointer conversion' */

	#pragma warn -sus

#endif

/*
	Here now some defines to set, depending in your machine this
	programm shall work with.
*/

/*	Processor type */

	/*	for MC680x0, Z8000, IBM 360/370/34xx/30xx/...  processors
		define <BIG_ENDIAN> otherwise do not define <BIG_ENDIAN> */
	
#define	BIG_ENDIAN

	/*	do not define <BID_ENDIAN> for processors like
		I8088, I8086, I80x86, PDP-11, VAX-11 */


/*	define here the file separator */

#define	F_SEP	'\\'

/*	define here the file specification wich will match all files */

#define	F_SPEC	"*.*"


#include <stdio.h>
#include <limits.h>
#include <setjmp.h>

#ifdef __TOS__

	#include <ext.h>
	#include <tos.h>

	#define		mkdir(p)		(Dcreate(p) < 0)
	#define		rmdir(p)		(Ddelete(p))
	#define		getdta()		(Fgetdta())
	#define		setdta(d)		(Fsetdta(d))
	#define		_chmode(p,f,a)	(Fattrib(p,f,a))
	#define		setftime(h,t)	(Fdatime((DOSTIME *)t,h,1))
	#define		getftime(h,t)	(Fdatime((DOSTIME *)t,h,0))

#endif
#ifdef __MSDOS__

	#include <io.h>
	
#endif

#define		Min(a,b)		((a)<=(b) ? (a):(b))
#define		Max(a,b)		((a)>=(b) ? (a):(b))

typedef		unsigned char uchar;
typedef		unsigned int uint;
typedef		unsigned long ulong;

#ifndef BIG_ENDIAN

	void	ConvLong( long *values, int num );
	#define SwapInt(i)	((int)((uint)i >> 8) | (i << 8))
#else
		
	#define	ConvLong(v,n)
	#define	SwapInt(i)		(i)
	
#endif

#ifndef EOS
#define EOS		'\0'
#endif

/*
*	some stuff for check sum
*/

#define INIT_CRC	0			/* CCITT: 0xFFFF */
#define CRCPOLY		0xA001		/* ANSI CRC-16 */
								/* CCITT: 0x8408 */
#define UPDATE_CRC(crc,c) \
				crc = ct[(crc ^ (c)) & 0xFF] ^ (crc >> CHAR_BIT)

typedef unsigned int crc_type;
typedef crc_type crc_table[UCHAR_MAX+1];


#ifndef FA_ATTRIB
#define		FA_ATTRIB		(FA_DIREC|FA_SYSTEM|FA_RDONLY|FA_HIDDEN)
#endif


/*
*	XFILE definitions
*/


#define		MAX_XFILE	8
#define		XFP_BUFFER	8192
#define		NOMES		((void(*)(long))0L)

typedef struct
{
		uchar		bit_buf[XFP_BUFFER];	/* temporary bit buffer */
											/* XGetBits() and XPutBits() */
											/* work with this buffer */
		int			bb_pos;					/* current position in buffer */
		int			bb_max;					/* number of valid characters */
											/* in bit buffer. Only for */
											/* reading */
		int			num_bits;				/* valid bits in <bitmap> */
		ulong		bitmap;					/* bit map */

		FILE		*fp;
		char		fname[128];
		int			mode;					/* file open mode */
		int			p_handle;				/* internal handle of XFILE.C */

		crc_type	crc;					/* check sum. Updated by */
											/* XWrite() and XRead() */ 
		long		limit;					/* optional limit to read/write */
		
		jmp_buf		*jmpbuf;				/* jumps here on I/O error */
		void		(*cntmes)( long cnt );	/* optional message function */
		
		long		cnt;					/* internal byte counter */
}	XFILE;


typedef struct _sd
{
    	int		attrib;				/* file attribute */
    	int		ftime;				/* last file write time */
    	int		fdate;				/* last file write date */
    	long	len;				/* file length */
		char 	src[128];			/* complete file source name */
		char	dest[128];			/* complete file destination path */
}	SD;

typedef struct
{
		int		n_files;			/* number if files in the list */
		int		n_dirs;				/* number of directories in the list */
		long	flen;				/* total length of all files */
		SD		sd[0];				/* start of file list */
}	FLIST;

/*	open modes for XFILE */

#define	XF_READ		1
#define XF_WRITE	2
#define	XF_APPEND	4
#define	XF_TEMP		8
#define XF_CRCSUM	16
		
/*	error types */

#define LIMIT_ERR	4096
#define	EFORMAT		4097
#define ECRCSUM		4098

#ifndef __XFILE

extern	XFILE	*xfp_err;		/* holds the file on wich error occured */

#endif

int		FixPath( char *path );
void	AppendPath( char *path, char *dir, int type );
int		PathExists( const char *path );
int		FileExists( const char *fname );
int		IsFName( char *fname );
int		IsPName( char *pname );
int		TempFileName( char *file, char *new );

FILE	*TempFile( char *path, char *mode );
FLIST	*FileList( const char *src_spec, const char *dest_path, int mode );

crc_type	CRCSum( char *buf, long len, crc_type last );

XFILE	*XOpen( char *fname, int mode, jmp_buf *error, void(*cntmes)(long) );
int		XClose( XFILE *xfp );
size_t	XRead( void *buf, size_t len, XFILE *xfp );
size_t	XWrite( void *buf, size_t len, XFILE *xfp );
crc_type	XStartCRC( XFILE *xfp );
crc_type	XEndCRC( XFILE *xfp );
int		XSeek( XFILE *xfp, long offset, int mode );
uint	XGetBits( int num, XFILE *xfp );
void	XPutBits( int num, uint bits, XFILE *xfp );
void	XBitsFlush( XFILE *xfp );

long	XCopy( XFILE *sxfp, XFILE *dxfp, long len );

#define remove	XRemove
int		XRemove( const char *fname );


/*
*	huffman code definitions
*/


#define MAX_HNUM	2048		/* number of maximal huffman codes */


/* a huffman tree is build up by huffman nodes */

typedef struct
{
		int			son1;		/*	1. son if bit == 1
									2. bit map for codes with less than 17
									   bits else undefined */
		uint		freq;		/*	frequency */
		int			dad;		/*	index to dad (0 for root)
								/*	son0 and son1 hold two different
									values, depending wether it is
									a node or a leaf.
									1.	for nodes (index >= huff_num)
									2.	for leafes (index < huff_num)
								*/
		int			son0;		/*	1. son if bit == 0
									2. number of code bits
									   or 0 if not known */
}	HN;							/* huffman node */


/*	huffman tree info */

typedef struct
{
		int		cnt;			/* number of current huff codes since
									last update */
		int		cupdate;
		int		update;			/* update huff tree after <update> codes */
		int		huf_num;		/* number of values to huffman code */
		int		hn_root;		/* root of huff tree (huf_num * 2 - 1) */
		XFILE	*xfp;			/* xstream for input/output huff codes */
		HN		ht[0];			/* start of huffman tree */
}	HTI;						/* huffman tree info */


/*
*	Huffman coding with maximal MAX_HNUM integer values.
*	The internal generated huffman code of a value can be up to MAX_HNUM - 1
*	bits.
*
*	<xfp>       : XFILE handle for coded file or file to code
*				  (output stream on encoding and input stream on decoding)
*	<huf_num>   : number of huffman codes to support (0...huf_num-1)
*	<update>    : generate new huffman tree on every <update> codes
*				  NOTE: the frequencies of the values will be divided by 2
*				  at this process. To keep real world frequency numbers
*				  for each value do not use a <update> number, wich is
*				  too low.
*	<val>		: value to code (this is also the return of <HuffDecode()>)
*
*	Use <HuffStart()> at the beginning of Encoding AND Decoding
*	If you do want to use static RAM, call <HuffStart()> once and
*	<HuffInit()> for the next times.
*	Use <HuffEnd()> for dynamic allocation, and <HuffExit()> for static RAM
*	at the end of Coding or Decoding.
*
*	<HuffStart()> returns <NULL> if no memory or illegal <huf_num>.
*/

HTI		*HuffStart( XFILE *xfp, int huf_num, int update );
void	HuffInit( HTI *hti, XFILE *xfp, int update );

void	HuffEncode( HTI *hti, uint val );
uint	HuffDecode( HTI *hti );

void	HuffEnd( HTI *hti );
void	HuffExit( HTI *hti );

void	HuffBuildTree( HTI *hti );

/*
*	<HuffBuildTree()> is called by <HuffEn/Decode()> on each <update> codes.
*	<HuffEn/Decode()> also keeps track of the frequencies of all codes.
*	However, you can set your own frequencies:
*	for ( i = 0; i < huf_num; i++ )
*		 hti->hn[i].freq = my_own_freqency(i);
*	and then call <HuffBuildTree()> to generate new huffman codes.
*	Therefore you have to call <HuffStart/Init()> with update == -1.
*
*	All HuffXxx-functions use the XFILE-bit_buffer. To add/read further
*	values to/from the coded stream use <XPutBits()> and <XGetBits()>
*	at any time. This will not collide with the huffman-I/O, as long as
*	the input is synchron with the output.
*	There is only one way to add several bytes between two huffman-codes.
*	This way is not very fast but it works:
*	Before adding several bytes by <XWrite()>, the bit-stream needs to
*	get aligned to the next byte boundary by <XBitsFlush()>.
*	<XBitsFlush()> also uses XWrite/XRead.
*	NOTE: <XBitsFlush()> is a XFILE-function and not a Huffman-function,
*	so it also works with <XGetBits()> and <XPutBits()>.
*
*	NOTE: you can use more then one huffman-code for one X-stream.
*/

/*
*	The following two functions read/write a huffman coded run-length-code
*	as a small example how to use the HuffXxx-functions
*/

int		RLHuffEncode( XFILE *sxfp, XFILE *dxfp, long slen );
int		RLHuffDecode( XFILE *sxfp, XFILE *dxfp, long dlen );

/*
*	A Zero return signals OK.
*	NOTE: the parameter <d/slen> always tells the length of the
*	uncoded file.
*/

/*
*	Huffman coded Lempel Ziv coding
*/

int		LZHEncodeInit( XFILE *sxfp, XFILE *dxfp );
int		LZHDecodeInit( XFILE *sxfp, XFILE *dxfp );
int		LZHExit( void );
int		LZHEncode( long slen );
int		LZHDecode( long dlen );

#endif