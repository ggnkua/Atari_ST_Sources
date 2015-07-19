/* UNARJ.C, UNARJ, R JUNG, 07/07/91
 * Main Extractor routine
 * Copyright (c) 1991 by Robert K Jung.  All rights reserved.
 *
 *   I wish to give credit to Haruhiko Okumura for providing the
 *   basic ideas for ARJ and UNARJ in his program AR.  Please note
 *   that UNARJ is significantly different from AR from an archive
 *   structural point of view.
 *
 * programmers : R. Jung & M. Adler
 *
 */

#ifndef _ARH_DEF_
#define _ARH_DEF_

void decode();

#define UCHAR_MAX (255)
#define CHAR_BIT  (8)

typedef unsigned char  uchar;	/*  8 bits or more */
typedef unsigned int   uint;	/* 16 - 32 bits or more */
typedef unsigned short ushort;	/* 16 bits or more */
typedef unsigned long  ulong;	/* 32 bits or more */

#define MAXSFX	5000L		/* size of self-extracting prefix */

#define FNAME_MAX	    64

/* ********************************************************* */
/*
 * Structure of archive block (low order byte first):
 *
 *  2  header* id (comment and local file) = 0xEA60 or 60000U
 *  2  basic header size (from 'first_hdr_size' thru 'comment' below)
 *	     = first_hdr_size + strlen(filename) + 1 + strlen(comment) + 1
 *	     = 0 if end of archive
 *
 *  1  first_hdr_size (size up to 'extra data')
 *  1  archiver version number
 *  1  minimum archiver version to extract
 *  1  host OS   (0 = MSDOS, 1 = PRIMOS, 2 = UNIX, 3 = AMIGA, 4 = MAC-OS)
 *               (5 = OS/2, 6 = APPLE GS, 7 = ATARI ST, 8 = NEXT)
 *               (9 = VAX VMS)
 *  1  arj flags (0x01 = GARBLED_FLAG, 0x02 = RESERVED)
 *		 (0x04 = VOLUME_FLAG,  0x08 = EXTFILE_FLAG)
 *		 (0x10 = PATHSYM_FLAG)
 *  1  method	 (0 = stored, 1 = compressed most ... 4 compressed fastest)
 *  1  file type (0 = binary, 1 = text, 2 = comment header)
 *		 (3 = directory, 4 = volume label)
 *  1  reserved
 *  4  date time stamp modified
 *  4  compressed size
 *  4  original size
 *  4  original file's CRC
 *  2  entryname position in filename
 *  2  file access mode
 *  2  host data
 *  ?  extra data
 *     4 bytes for extended file position
 *
 *  ?  filename (null-terminated)
 *  ?  comment	(null-terminated)
 *
 *  4  basic header CRC
 *
 *  2  1st extended header size (0 if none)
 *  ?  1st extended header
 *  4  1st extended header's CRC (not present if 0 extended header size)
 *  ...
 *  ?  compressed file
 *
 * ********************************************************* */

#define CODE_BIT	  16

#define NULL_CHAR	'\0'
#define MAXMETHOD	   3

#define ARJ_VERSION	   3
#define ARJ_X_VERSION	   3	/* decoder version */
#define ARJ_X1_VERSION	   1
#define DEFAULT_METHOD	   1
#define DEFAULT_TYPE	   0	/* if type_sw is selected */
#define HEADER_ID     0xEA60
#define HEADER_ID_HI	0xEA
#define HEADER_ID_LO	0x60
#define FIRST_HDR_SIZE	  30
#define FIRST_HDR_SIZE_V  34
#define COMMENT_MAX	2048
#define HEADERSIZE_MAX	 (FIRST_HDR_SIZE + 10 + FNAME_MAX + COMMENT_MAX)
#define BINARY_TYPE	   0	/* This must line up with binary/text strings */
#define TEXT_TYPE	   1
#define COMMENT_TYPE	   2
#define DIR_TYPE	   3
#define LABEL_TYPE	   4

#define GARBLE_FLAG	0x01
#define VOLUME_FLAG	0x04
#define EXTFILE_FLAG	0x08
#define PATHSYM_FLAG	0x10

typedef ulong UCRC;	/* CRC-32 */

#define CRC_MASK	0xFFFFFFFFL

#define FA_RDONLY	0x01		/* Read only attribute */
#define FA_HIDDEN	0x02		/* Hidden file */
#define FA_SYSTEM	0x04		/* System file */
#define FA_LABEL	0x08		/* Volume label */
#define FA_DIREC	0x10		/* Directory */
#define FA_ARCH 	0x20		/* Archive */

#endif

/* end UNARJ.H */

/* Global variables */

UCRC   crc;
ushort bitbuf;
long   compsize;
long   origsize;
uchar  subbitbuf;
uchar  header[HEADERSIZE_MAX];

/*
char   arc_name[]="TEST.ARJ";
char   filename[]="TEST.OUT";
*/

int    bitcount;

/* Messages */

#define ERROR_BADCOMNT	1	/* bad comment */
#define ERROR_BADHEADR	2	/* bad header */
#define ERROR_BADTABLE	3	/* Bad Huffman code */
#define ERROR_CANTREAD	4	/* Can't read file or unexpected end of file */
#define ERROR_CANTWRIT	5	/* Can't write file. Disk full? */
#define ERROR_CRCERROR	6	/* CRC error! */
#define ERROR_ENCRYPT 	7	/* File is password encrypted, */
#define ERROR_HEADRCRC	8	/* Header CRC error! */
#define ERROR_NOTARJ  	9	/* not an ARJ archive */
#define ERROR_UNKNMETH	10	/* Unsupported method */
#define ERROR_UNKNTYPE	11	/* Unsupported file type */
#define ERROR_UNKNVERS	12	/* Unsupported version */

#define get_crc()	get_longword()
#define fget_crc()	fget_longword()

#define setup_get(PTR)	(get_ptr = (PTR))
#define get_byte()	((uchar)(*get_ptr++))

#define BUFFERSIZE	4096
#define CRCPOLY 	0xEDB88320L


/* Local variables */

static uchar  *get_ptr;

static ushort headersize;
static uchar  first_hdr_size;
static uchar  arj_x_nbr;
static uchar  arj_flags;
static short  method;
static short  file_type;
static UCRC   file_crc;
static UCRC   header_crc;

static UCRC   crctable[UCHAR_MAX + 1];

uchar source[10000];
uchar dest[10000];
uchar *ptr_read;
uchar *ptr_write;

/* Functions */
#define fopenin() ptr_read=source
#define fget_byte() (*ptr_read++)
#define fseek(a) ptr_read=source+a

#define fopenout() ptr_write=dest
#define putc(a) *ptr_write++=a

static void
make_crctable()
{
    register uint i, j;
    register UCRC r;

    for (i = 0; i <= UCHAR_MAX; i++)
    {
	r = i;
	for (j = CHAR_BIT; j != 0; j--)
	{
	    if (r & 1)
		r = (r >> 1) ^ CRCPOLY;
	    else
		r >>= 1;
	}
	crctable[i] = r;
    }
}

static void
crc_buf(str, len)
uchar *str;
int  len;
{
    while (len--)
	crc=crctable[(*str++^crc)&0xff]^(crc>>CHAR_BIT);
}

static uint
fget_word()
{
    register uint b0, b1;

    b0 = fget_byte();
    b1 = fget_byte();
    return (b1 << 8) + b0;
}

static ulong
fget_longword()
{
    register ulong b0, b1, b2, b3;

    b0 = fget_byte();
    b1 = fget_byte();
    b2 = fget_byte();
    b3 = fget_byte();
    return (b3 << 24) + (b2 << 16) + (b1 << 8) + b0;
}

static void
fread_crc()
{
    register ushort n;

    for (n=1; n<headersize; n++)
    {
	header[n-1]=fget_byte();
    }
    origsize += headersize;
    crc_buf(header, headersize);
}

void
fwrite_txt_crc(p, n)
uchar *p;
int   n;
{
    int i;
    crc_buf(p, n);

    for (i=1;i<n;i++)
    {
	putc(*p++);
    }
}

static uint
get_word()
{
    register uint b0, b1;

    b0 = get_byte();
    b1 = get_byte();
    return (b1 << 8) + b0;
}

static ulong
get_longword()
{
    register ulong b0, b1, b2, b3;

    b0 = get_byte();
    b1 = get_byte();
    b2 = get_byte();
    b3 = get_byte();
    return (b3 << 24) + (b2 << 16) + (b1 << 8) + b0;
}

static long
find_header()
{
    register long arcpos;
    register int c;

    for (arcpos=0 ; arcpos < MAXSFX; arcpos++)
    {
	fseek(arcpos);
	c = fget_byte();
	while (arcpos < MAXSFX)
	{
	    if (c != HEADER_ID_LO)  /* low order first */
		c = fget_byte();
	    else if ((c = fget_byte()) == HEADER_ID_HI)
		break;
	    arcpos++;
	}
	if (arcpos >= MAXSFX)
	    break;
	if ((headersize = fget_word()) <= HEADERSIZE_MAX)
	{
	    crc = CRC_MASK;
	    fread_crc();
	    if ((crc ^ CRC_MASK) == fget_crc())
	    {
		fseek(arcpos);
		return arcpos;
	    }
	}
    }
    exit(ERROR_NOTARJ);	/* could not find a valid header */
}

static int
read_header(first)
int  first;
{
    register ushort extheadersize, header_id;
    register int n;

    header_id = fget_word();
    if (header_id != HEADER_ID)
    {
	if (first)
	    exit(ERROR_NOTARJ);
	else
	    exit(ERROR_BADHEADR);
    }

    headersize = fget_word();
    if (headersize == 0)
	return 0;		/* end of archive */
    if (headersize > HEADERSIZE_MAX)
	exit(ERROR_BADHEADR);

    crc = CRC_MASK;
    fread_crc();
    header_crc = fget_crc();
    if ((crc ^ CRC_MASK) != header_crc)
	exit(ERROR_HEADRCRC);

    setup_get(header);
    first_hdr_size = get_byte();
    (void)get_byte();		/* arj_nbr */
    arj_x_nbr = get_byte();
    (void)get_byte();		/* host_os */
    arj_flags = get_byte();
    method = get_byte();
    file_type = get_byte();
    (void)get_byte();
    (void)get_longword();	/* time_stamp */
    compsize = get_longword();
    origsize = get_longword();
    file_crc = get_crc();
    (void)get_word();		/* entry_pos */
    (void)get_word();		/* file_mode */
    (void)get_word();		/* host_data */

    /* if extheadersize == 0 then no CRC */
    /* otherwise read extheader data and read 4 bytes for CRC */

    while ((extheadersize = fget_word()) != 0)
    {
	for (n=1;n<extheadersize+4;n++)
	{
	    (void)fget_byte();
	}
    }
    return 1;			/* success */
}

int
main()
{
#asm
	public	.begin
	entry	.begin
.begin
#endasm
    make_crctable();

    first_hdr_size = FIRST_HDR_SIZE;

    fopenin();

    fseek(find_header());
    if (!read_header(1))
	exit(ERROR_BADCOMNT);

    if (read_header(0))
    {
	if (arj_x_nbr > ARJ_X_VERSION)
	{
	    exit(ERROR_UNKNVERS);
	}
	if ((arj_flags & GARBLE_FLAG) != 0)
	{
	    exit(ERROR_ENCRYPT);
	}
	if (method < 1 || method > MAXMETHOD)
	{
	    exit(ERROR_UNKNMETH);
	}
	if (file_type != BINARY_TYPE)
	{
	    exit(ERROR_UNKNTYPE);
	}

	fopenout();
	crc = CRC_MASK;
	decode();

	if ((crc ^ CRC_MASK) != file_crc)
	{
	    exit(ERROR_CRCERROR);
	}

    }

    return 0;
#asm
	public	_exit
_exit:	illegal
#endasm
}

/* end UNARJ.C */

/* DECODE.C, UNARJ, R JUNG, 05/04/91
 * Decode ARJ archive
 * Copyright (c) 1991 by Robert K Jung.  All rights reserved.
 *
 * Modification history:
 * Date      Programmer  Description of modification.
 * 04/05/91  R. Jung	 Rewrote code.
 * 04/23/91  M. Adler	 Portabilized.
 * 04/29/91  R. Jung	 Made GETBIT independent of short size.
 * 05/04/91  R. Jung	 Simplified use of start[len].
 *
 */

#define THRESHOLD    3
#define DDICSIZ      26624
#define MAXDICBIT   16
#define MATCHBIT     8
#define MAXMATCH   256
#define NC	    (UCHAR_MAX + MAXMATCH + 2 - THRESHOLD)
#define NP	    (MAXDICBIT + 1)
#define CBIT	     9
#define NT	    (CODE_BIT + 3)
#define PBIT	     5
#define TBIT	     5

#if NT > NP
#define NPT NT
#else
#define NPT NP
#endif

#define CTABLESIZE  4096

/* Local variables */

static ushort left[2 * NC - 1];
static ushort right[2 * NC - 1];
static uchar  c_len[NC];
static uchar  pt_len[NPT];

static ushort c_table[CTABLESIZE];
static ushort pt_table[256];
static ushort blocksize;

/* Huffman decode routines */

void
fillbuf(n)		  /* Shift bitbuf n bits left, read n bits */
int n;
{
    bitbuf = (bitbuf << n) & 0xFFFF;  /* lose the first n bits */
    while (n > bitcount)
    {
	bitbuf |= subbitbuf << (n -= bitcount);
	if (compsize != 0)
	{
	    compsize--;
	    subbitbuf = (uchar) fget_byte();
	}
	else
	    subbitbuf = 0;
	bitcount = CHAR_BIT;
    }
    bitbuf |= subbitbuf >> (bitcount -= n);
}

ushort
getbits(n)
int n;
{
    register ushort x;

    x = bitbuf >> (2 * CHAR_BIT - n);
    fillbuf(n);
    return x;
}

static void
make_table(nchar, bitlen, tablebits, table)
int    nchar;
uchar  *bitlen;
int    tablebits;
ushort *table;
{
    ushort count[17], weight[17], start[18];
    register ushort *p;
    register uint i, k, len, ch, jutbits, avail, nextcode, mask;

    for (i = 1; i <= 16; i++)
	count[i] = 0;
    for (i = 0; (int)i < nchar; i++)
	count[bitlen[i]]++;

    start[1] = 0;
    for (i = 1; i <= 16; i++)
	start[i + 1] = start[i] + (count[i] << (16 - i));
    if (start[17] != (ushort) (1 << 16))
	exit(ERROR_BADTABLE);

    jutbits = 16 - tablebits;
    for (i = 1; (int)i <= tablebits; i++)
    {
	start[i] >>= jutbits;
	weight[i] = 1 << (tablebits - i);
    }
    while (i <= 16)
    {
	weight[i] = 1 << (16 - i);
	i++;
    }

    i = start[tablebits + 1] >> jutbits;
    if (i != (ushort) (1 << 16))
    {
	k = 1 << tablebits;
	while (i != k)
	    table[i++] = 0;
    }

    avail = nchar;
    mask = 1 << (15 - tablebits);
    for (ch = 0; (int)ch < nchar; ch++)
    {
	if ((len = bitlen[ch]) == 0)
	    continue;
	k = start[len];
	nextcode = k + weight[len];
	if ((int)len <= tablebits)
	{
	    for (i = start[len]; i < nextcode; i++)
		table[i] = ch;
	}
	else
	{
	    p = &table[k >> jutbits];
	    i = len - tablebits;
	    while (i != 0)
	    {
		if (*p == 0)
		{
		    right[avail] = left[avail] = 0;
		    *p = avail++;
		}
		if (k & mask)
		    p = &right[*p];
		else
		    p = &left[*p];
		k <<= 1;
		i--;
	    }
	    *p = ch;
	}
	start[len] = nextcode;
    }
}

static void
read_pt_len(nn, nbit, i_special)
int nn;
int nbit;
int i_special;
{
    register int i, n;
    register short c;
    register ushort mask;

    n = getbits(nbit);
    if (n == 0)
    {
	c = getbits(nbit);
	for (i = 0; i < nn; i++)
	    pt_len[i] = 0;
	for (i = 0; i < 256; i++)
	    pt_table[i] = c;
    }
    else
    {
	i = 0;
	while (i < n)
	{
	    c = bitbuf >> (13);
	    if (c == 7)
	    {
		mask = 1 << (12);
		while (mask & bitbuf)
		{
		    mask >>= 1;
		    c++;
		}
	    }
	    fillbuf((c < 7) ? 3 : (int)(c - 3));
	    pt_len[i++] = (uchar)c;
	    if (i == i_special)
	    {
		c = getbits(2);
		while (--c >= 0)
		    pt_len[i++] = 0;
	    }
	}
	while (i < nn)
	    pt_len[i++] = 0;
	make_table(nn, pt_len, 8, pt_table);
    }
}

static void
read_c_len()
{
    register short i, c, n;
    register ushort mask;

    n = getbits(CBIT);
    if (n == 0)
    {
	c = getbits(CBIT);
	for (i = 0; i < NC; i++)
	    c_len[i] = 0;
	for (i = 0; i < CTABLESIZE; i++)
	    c_table[i] = c;
    }
    else
    {
	i = 0;
	while (i < n)
	{
	    c = pt_table[bitbuf >> (8)];
	    if (c >= NT)
	    {
		mask = 1 << (7);
		do
		{
		    if (bitbuf & mask)
			c = right[c];
		    else
			c = left[c];
		    mask >>= 1;
		} while (c >= NT);
	    }
	    fillbuf((int)(pt_len[c]));
	    if (c <= 2)
	    {
		if (c == 0)
		    c = 1;
		else if (c == 1)
		    c = getbits(4) + 3;
		else
		    c = getbits(CBIT) + 20;
		while (--c >= 0)
		    c_len[i++] = 0;
	    }
	    else
		c_len[i++] = (uchar)(c - 2);
	}
	while (i < NC)
	    c_len[i++] = 0;
	make_table(NC, c_len, 12, c_table);
    }
}

static ushort
decode_c()
{
    register ushort j, mask;

    if (blocksize == 0)
    {
	blocksize = getbits(16);
	read_pt_len(NT, TBIT, 3);
	read_c_len();
	read_pt_len(NP, PBIT, -1);
    }
    blocksize--;
    j = c_table[bitbuf >> 4];
    if (j >= NC)
    {
	mask = 1 << (3);
	do
	{
	    if (bitbuf & mask)
		j = right[j];
	    else
		j = left[j];
	    mask >>= 1;
	} while (j >= NC);
    }
    fillbuf((int)(c_len[j]));
    return j;
}

static ushort
decode_p()
{
    register ushort j, mask;

    j = pt_table[bitbuf >> (8)];
    if (j >= NP)
    {
	mask = 1 << (7);
	do
	{
	    if (bitbuf & mask)
		j = right[j];
	    else
		j = left[j];
	    mask >>= 1;
	} while (j >= NP);
    }
    fillbuf((int)(pt_len[j]));
    if (j != 0)
    {
	j--;
	j = (1 << j) + getbits((int)j);
    }
    return j;
}

void
init_getbits()
{
    bitbuf = 0;
    subbitbuf = 0;
    bitcount = 0;
    fillbuf(2 * CHAR_BIT);
}

static void
decode_start()
{
    blocksize = 0;
    init_getbits();
}

void
decode()
{
    register short i;
    register short j;
    register short c;
    register short r;
    register uchar *text;
    register long count;
    static uchar diction[DDICSIZ];

    text = diction;

    decode_start();
    count = 0;
    r = 0;

    while (count < origsize)
    {
	if ((c = decode_c()) <= UCHAR_MAX)
	{
	    text[r] = (uchar) c;
	    count++;
	    if (++r >= DDICSIZ)
	    {
		r = 0;
		fwrite_txt_crc(text, DDICSIZ);
	    }
	}
	else
	{
	    j = c - (UCHAR_MAX + 1 - THRESHOLD);
	    count += j;
	    i = decode_p();
	    if ((i = r - i - 1) < 0)
		i += DDICSIZ;
	    if (r > i && r < DDICSIZ - MAXMATCH - 1)
	    {
		while (--j >= 0)
		    text[r++] = text[i++];
	    }
	    else
	    {
		while (--j >= 0)
		{
		    text[r] = text[i];
		    if (++r >= DDICSIZ)
		    {
			r = 0;
			fwrite_txt_crc(text, DDICSIZ);
		    }
		    if (++i >= DDICSIZ)
			i = 0;
		}
	    }
	}
    }
    if (r != 0)
	fwrite_txt_crc(text, r);

}

/* end DECODE.C */
