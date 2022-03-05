/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#ifdef NULL
#undef NULL
#endif
#define NULL	0L

#ifdef dLibs
#define	OPENBR(x)	open(x,0)
#define OPENBW(x)	creat(x,0)
#else
FILE *fopen();
#define OPENBR(x)	openb(x,0)
#define OPENBW(x)	openb(x,1)
#endif

#define MAXFI	60	/* max no. of files */
#define MAXSYM	1000	/* max global syms in final obj */
#define MAXLOC	400	/* max syms in one .o */
#define MAXOBJ	100	/* max objects actually loaded */
#define MAXLIB	200	/* max library objects skipped */

#define NHASH	64	/* power of 2 */
#define HMASK	0x3f	/* bits for NHASH */

#define AMAGIC	0xff65
#define OMAGIC	0x601a

struct hdr {
	int magic;
	long tsize, dsize, bsize;
	long syms;
	long f1,f2;
	int f3;
} h;

struct finfo {
	char *fname;
	int fd;
} files[MAXFI];
int nfiles;

struct oinfo {
	int	fno;
	char aname[14];
	struct hdr oh;
	long tbase, dbase, bbase;
	long im_td, im_rel;
	char *im_sym;
} obj[MAXOBJ];
int nobj;

struct skipstr {
	long offs;
	char aname[14];
	struct hdr oh;
	char *ims;
};
struct skipstr *skip;
int nskip;

struct sym {
	char name[8];
	char flags;
	char mark;
	long value;
};
struct sym *lsym;

struct sinfo {
	int onum;
	struct sym sy;
	struct sinfo *hchain;
} sym[MAXSYM];
int nsym;

struct arch {
	char anm[14];
	long modti;
	long amagic;
	long asize;
	int fill;
};

struct sinfo *hashs[NHASH];

#define LBUFSZ	6000
#define LBUFCNT	(LBUFSZ/2)
short *lbuf;
short *rbuf;

long textsize, datasize, bsssize, comsize;
