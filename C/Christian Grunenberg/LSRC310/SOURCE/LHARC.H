
#include <limits.h>
#include <ctype.h>

#include <errno.h>
#include <basepage.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <osbind.h>
#include <time.h>
#include <mintbind.h>

#ifdef __SHELL__
#include "..\version.h"
#else
#include "version.h"
#endif

#define GERMAN		0
#define	BETA		0

#ifdef __SHELL__
#define LZHVERSION VERSNO
#else
#define LZHVERSION VERSNO" junior"
#endif

#if GERMAN
#define PERSON	"einem unbekannten Genie"
#else
#define PERSON	"an unknown genius"
#endif

#define close_file(f)	{if (f!=NULL) fclose(f);f=NULL;}

#define FA_SELECTED	2
#define FA_DELETED	4
#define FA_DONE		8
#define FA_EDITED	16
#define FA_COMALLOC	32

#define _PC_CASE		6
#define	_PC_CASESENS	0
#define	_PC_CASECONV	1
#define	_PC_CASEINSENS	2

#define BUFFERSIZ	(24*1024L)
#define	FILEBUFSIZ	16384L

#define MAXBUFFER	(1L<<17)
#define MAXBUFFERL2	(1L<<19)

#define DICBIT		13
#define DICSIZ		(1U<<DICBIT)

#define MATCHBIT	8
#define MAXMATCH	256

#define THRESHOLD	2
#define PERC_FLAG	0x8000U
#define NC			(UCHAR_MAX+MAXMATCH+1-THRESHOLD)
#define CBIT		9
#define CODE_BIT	16

#define NP			(DICBIT+1)
#define NT			(CODE_BIT+3)

#define PBIT		4
#define TBIT		5

#if NT > NP
#define NPT	NT
#else
#define NPT NP
#endif

#define MAX_HASH_VAL	(3*DICSIZ+((DICSIZ>>9)+1)*UCHAR_MAX)

#define MAXPATH		224
#define MAXCOMMENT	1024
#define MAXEXT		1024
#define MAX_PAT 	1024
#define MAX_EXCLD	128
#define MAX_ARC		512

#define N			4096
#define F			18
#define NIL 		N

#define UNKNOWNERR	0
#define INVCMDERR	1
#define MANYPATERR	2
#define NOARCNMERR	3
#define NOFNERR 	4
#define NOARCERR	5
#define RENAMEERR	6
#define MKTMPERR	7
#define DUPFNERR	8
#define TOOMANYERR	9
#define TOOLONGERR	10
#define NOFILEERR	11
#define MKFILEERR	12
#define RDERR		13
#define WTERR		14
#define MEMOVRERR	15
#define INVSWERR	16
#define CTRLBRK 	17
#define NOMATCHERR	18
#define COPYERR 	19
#define NOTLZH		20
#define OVERWT		21
#define MKDIR		22
#define MKDIRERR	23
#define CRCERR		24
#define RDONLY		25

#define EXTEND_GENERIC		0
#define EXTEND_UNIX			'U'
#define EXTEND_ATARI		'a'
#define EXTEND_MSDOS		'M'
#define EXTEND_MACOS		'm'
#define EXTEND_OS9			'9'
#define EXTEND_OS2			'2'
#define EXTEND_OS68K		'K'
#define EXTEND_OS386		'3'
#define EXTEND_HUMAN		'H'
#define EXTEND_CPM			'C'
#define EXTEND_FLEX			'F'
#define EXTEND_RUNSER		'R'
#define EXTEND_TOWNSOS		'T'
#define EXTEND_XOSK			'X'

#define	TEXT		(DICSIZ*2+MAXMATCH)
#define LEVEL		((DICSIZ+UCHAR_MAX+1+8)*sizeof(*level))
#define POSITION	((DICSIZ+UCHAR_MAX+1)*sizeof(*position))
#define PARENT		(DICSIZ*2*sizeof(*parent))
#define PREV		(DICSIZ*2*sizeof(*prev))
#define	NEXT		((MAX_HASH_VAL+1)*sizeof(*next))
#define ENCODE5		(TEXT+LEVEL+POSITION+PARENT+PREV+NEXT+128)

#ifndef SFX
#define LSON		((N+1)*sizeof(*lson))
#define RSON		((N+257)*sizeof(*rson))
#define DAD			((N+1)*sizeof(*dad))
#define ENCODE		(LSON+RSON+DAD+128)
#endif

#define FAULT		0
#define SUCCS		~FAULT

#define COM_ID		"-com-"

#define EXCLUDE		'!'
#define FILE_LIST	'@'
#define TEMPFILE	"LHA)(T)(."

#define MINHDR		20
#define HDRSIZ0		22
#define HDRSIZ1		25
#define HDRSIZ2		24

#define ITIME(t)	itime((ulong *) &t)
#define getch()		gemdos(0x08)

typedef unsigned char	uchar;
typedef unsigned int	uint;
typedef unsigned short	ushort;
typedef unsigned long	ulong;

typedef unsigned long	clock_t;
typedef struct
{
	int dirs,files,items,selected;
	long bytes;
} SELECT;

typedef struct
{
	uchar	*ptr;
	long	cnt;
	uchar	*base;
	long	len;
} OutRec;

extern OutRec outrec;

typedef struct
{
	void	*next;
	_DOSTIME time,Mtime;
	int		cluster;
#ifdef __SHELL__
	uint	crc,index;
	int		sel_files,sel_dirs;
	long	seek_pos,packed,unpacked,sel_size,sel_pack;
	uchar	*name,*comment;
	uchar	method,system,level;
	uchar	view[20],id[3];
#endif
	uchar	fpos,cpos,flag,Case,attr;
	uchar	dir[MAXPATH];
} filebuf;

typedef struct
{
	uchar		HeadSiz,HeadChk,HeadID[5];
	ulong		PacSiz,OrgSiz;
	_DOSTIME	Ftime;
	uchar		Attr,Level;
	uchar		Fname[MAXPATH];
	uchar		crypted;
	_DOSTIME	Mtime;
	uint		crc;
} LzHead;

typedef struct
{
    unsigned hour:5;
    unsigned min:6;
    unsigned sec:5;
    unsigned year:7;
    unsigned mon:4;
    unsigned day:5;
} ftime;

typedef struct xattr {
	ushort	mode;
	long	index;
	ushort	dev;
	ushort	reserved1;
	ushort	nlink;
	ushort	uid;
	ushort	gid;
	long	size;
	long	blksize;
	long	nblocks;
	short	mtime, mdate;
	short	atime, adate;
	short	ctime, cdate;
	short	attr;
	short	reserved2;
	long	reserved3[2];
} XATTR;

#define METHOD_TYPE_STRAGE 5

#ifndef SFX
extern  int *dad;
#endif

extern	int __mint,bad_tab,*rson,*lson,bitcount,blkcnt,RotInd;
extern	int match_position,match_length,matchlen,ship,star;
extern	uint crc,crc_u,subbitbuf,bitbuf;
extern	FILE *file1,*file3;
extern	long textsize,codesize,compsize,blocksize;
extern	uchar flg_n,flg_5,*text,text_buf[],upper[];
extern	short matchpos,*position,*parent,*prev,*next;
extern	ulong origsize;
extern	ushort *sortptr;

extern	uint *level,*childcount;

extern	ushort prnt[],son[],hfreq[];

long	afxonoff(long);
int 	arc_ext(uchar *);
int		Attrib(uchar *);
uchar	*backpath(uchar *);
void	block_crc(long,uchar *);
void	buf_putc(uchar);
int		case_sensitive(uchar *);
int 	chk_wild(uchar *,uchar *,int,int);
clock_t clock(void);
void	code(uchar *,long len);
void	copyfile(FILE *,FILE *,uchar *,long,int,int);
void	copy_to_view(uchar*,long);
void	count_len(int);
int		crc_getc(FILE *);
void	Decode(void);
int		decode5(uint,uchar*);
int		decode_lh5(ulong,ulong);
void	DecodeOld(void);
int		decrypt(long);
void	delete_node(void);
void	DeleteONode(int);
void	dos_2_unixtime(void *);
int		drive(uchar *,uchar **);
void	Encode(void);
void	encode5(void);
void	EncodeOld(void);
void	end_huf(void);
void	error(int,uchar*,int);
void	fillbuf(int);
int 	fread_crc(uchar*,int,FILE*);
ulong	FTimeToULong(_DOSTIME*);
uint	getbits(int);
int 	gethdr(FILE *,LzHead *);
void	get_comment(FILE*);
uchar	*get_ext(void);
uchar	*get_fname(uchar*);
void	get_next_match(void);
void	huf_encode_end(void);
void	huf_encode_start(void);
void	ilong(ulong*);
void	InitTree(void);
void	init_encode5(void);
void	init_lharc(void);
void	itime(ulong*);
void	insert_node(void);
void	InsertONode(int);
void	lha_exit(void);
void	MakeBuffers(void);
void	make_attr(uchar*,int);
int		make_table(int,uchar*,int,ushort*);
int 	make_tree(int,ushort*,uchar*,ushort*);
int		matchpattern(uchar*,uchar*);
void	mkcrc(void);
uchar	mksum(LzHead*,int);
int 	openarc1(long,uchar *);
void	OpenOut(OutRec *,uchar *);
void	output(uint,uint);
void	output5(uint,uint);
int		path_conf(uchar*,int);
void	print(uchar*,int);
void	Print(int);
void	ProcInd(void);
void	proc_ind(void);
void	putbits(int,uint);
uint 	ratio(ulong,ulong);
int		read_attr(uchar *,_DTA *);
int		read_pt_len(int,int,int);
int 	read_c_len(void);
int		search_lzh(FILE*,int);
void	send_block(void);
void	shipout(void);
void	ShipOut(void);
int 	slash(uchar *,int);
uchar	*stpcpy(uchar*,uchar*);
int 	sseek(FILE *,long,long);
uchar 	*sysid(char);
int 	test_afx(uchar*);
void	TruncFile(uchar *);
int		tst_fname(uchar *);
int 	tstID(uchar *);
void	unix2dos(uchar *,int);
void	unix_2_dostime(void *);
int		wildcard(uchar *);
void	yen2slash(uchar *);
