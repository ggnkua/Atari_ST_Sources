
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
# include "..\version.h"
#else
# include "version.h"
#endif

#include "lhaconst.h"
#include "lhatypes.h"

#ifdef __SHELL__
# define LZHVERSION VERSNO
#else
# define LZHVERSION VERSNO" junior"
#endif

#define close_file(f)	{if (f!=NULL) fclose(f);f=NULL;}

#define ITIME(t)	itime((ulong *) &t)
#define getch()		gemdos(0x08)

extern OutRec outrec;

#ifndef SFX
extern  int *dad;
#endif

extern	int __mint, bad_tab, *rson, *lson, bitcount, blkcnt, RotInd;
extern	int matchlen, ship, star;
extern	uint crc, crc_u, subbitbuf, bitbuf;
extern	FILE *file1, *file3;
extern	long textsize, codesize, compsize, blocksize;
extern	uchar flg_n, flg_5, *text, text_buf[], upper[];
extern	short matchpos, *position, *parent, *prev, *next;
extern	ulong origsize;
extern	ushort *sortptr;

extern	uint *level, *childcount;

extern	ushort prnt[], son[], hfreq[];

extern uchar *backpath(uchar *);
extern void block_crc(long,uchar *);
extern void buf_putc(uchar);
extern void code(uchar *,long len);
extern int crc_getc(FILE *);
extern void Decode(void);
extern int decode5(uint,uchar*);
extern int decode_lh5(ulong,ulong);
extern void DecodeOld(void);
extern void DeleteONode(int);
static void Encode(void);
static void encode5(void);
extern ulong FTimeToULong(_DOSTIME*);
extern uchar *get_fname(uchar*);
extern void ilong(ulong*);
extern void init_encode5(void);
extern void InsertONode(int);
extern void itime(ulong*);
extern void mkcrc(void);
extern uchar mksum(LzHead*,int);
extern void OpenOut(OutRec *,uchar *);
extern void ProcInd(void);
extern void shipout(void);
extern uchar *stpcpy(uchar*,uchar*);
extern int test_afx(uchar*);

long	afxonoff(long);
/*int 	arc_ext(uchar *);*/
/*int		Attrib(uchar *);*/
/*int		case_sensitive(uchar *);*/
/*int 	chk_wild(uchar *,uchar *,int,int);*/
/*clock_t clock(void);*/
/*void	copyfile(FILE *,FILE *,uchar *,long,int,int);*/
void	copy_to_view(uchar*,long);
int		decrypt(long);
void	dos_2_unixtime(void *);
/*int		drive(uchar *,uchar **);*/
void InitTree(void);
void	EncodeOld(void);
void	error(int,uchar*,int);
int 	fread_crc(uchar*,int,FILE*);
/*int 	gethdr(FILE *,LzHead *);*/
void	get_comment(FILE*);
/*uchar	*get_ext(void);*/
/*void lha_exit(void);*/
/*void	MakeBuffers(void);*/
/*void	make_attr(uchar*,int);*/
/*int		matchpattern(uchar*,uchar*);*/
/*int 	openarc1(long,uchar *);*/
/*int		path_conf(uchar*,int);*/
/*void	print(uchar*,int);*/
/*void	Print(int);*/
void	proc_ind(void);
/*uint 	ratio(ulong,ulong);*/
/*int		read_attr(uchar *,_DTA *);*/
int		search_lzh(FILE*,int);
void	ShipOut(void);
/*int 	slash(uchar *,int);*/
/*uchar 	*sysid(char);*/
void	TruncFile(uchar *);
/*int		tst_fname(uchar *);*/
int 	tstID(uchar *);
void	unix2dos(uchar *,int);
void	unix_2_dostime(void *);
/*int		wildcard(uchar *);*/
void	yen2slash(uchar *);
