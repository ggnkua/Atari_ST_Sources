/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/10/19 17:02:35 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	aln.h,v $
* Revision 1.4  90/10/19  17:02:35  apratt
* Added -n flag and noheaderflag variable.
* 
* Revision 1.3  89/03/30  14:09:47  apratt
* Added -h option: sets hflags in prg header (aln.c, writefns.c)
* 
* Revision 1.2  88/08/24  10:36:18  apratt
* Addition of -q and -k options, mainly for OS builds.
* 
* Revision 1.1  88/08/23  14:20:38  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.4 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/aln.h,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * ALN.H: structures & externs for aln.c
 */

/*
 * note nomenclature change: directories became index files, and the suffix
 * became ".ndx," on 10/22/86.
 */

#ifdef VAX
#include <stdio.h>
#endif VAX

#include <ctype.h>
#include "port.h"
#include "slongio.h"

#ifdef DEBUG
#include "debug.h"
#else
#define DEBUG0(s) 0
#define DEBUG1(s,a) 0
#define DEBUG2(s,a,b) 0
#define DEBUG3(s,a,b,c) 0
#endif DEBUG

#ifdef DBMALLOC
#define free myfree
#define malloc mymalloc
#define calloc mycalloc
#define realloc myrealloc
#else
#ifdef ATARIST
#define free lfree
#define malloc lmalloc
#define calloc lcalloc
#define realloc lrealloc
#endif ATARIST
#endif DBMALLOC

#ifndef NULL
#define NULL 0L
#endif NULL

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif TRUE

#ifndef min
#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))
#endif min

/* 
 * most of these structures reflect the actual format of the object in 
 * question, on a 68000: char means one byte, int means two bytes, long
 * means four.  If the host machine doesn't have this same format (like
 * a VAX), you will have to read the file into a buffer and stuff the
 * values into the structure (see slongio.c).
 */

struct OHEADER {
    int magic;			/* 0x601a for .o and .prg, 0x601b for abs */
    long tsize;
    long dsize;
    long bsize;
    long ssize;
    union {
	struct {			/* for .o and .prg */
	    char reserved[10];
	} reloc;
	struct {			/* for .abs */
	    long stksize;		/* unused */
	    long tstart;		/* start of text */
	    int rbflag;			/* -1 if no fixups at all */
	    long dstart;		/* start of data */
	    long bstart;		/* start of bss */
	} abs;
    } absrel;
    char *ostbase;		/* base of output symbol table */
    long fsize;			/* length of fixups */
    char *fixups;		/* start of fixups */
};
#define Newoheader() (struct OHEADER *)malloc((long)sizeof(struct OHEADER))

struct ARHEADER {
	char a_fname[14];
	long a_modti;
	char a_userid;
	char a_gid;
	int a_fimode;
	long a_fsize;
	int reserved;		/* two bytes of zeroes btw header & file */
};
#define Newarheader() (struct ARHEADER *)malloc((long)sizeof(struct ARHEADER))

/*
 * SYMBOL is the external, .o-file format of a symbol.
 */

/*
 * total size of this structure in the ofile is 14 bytes.
 * the numbers 14 and 8 crop up in the source code occasionally, as well as
 * 10 (as in getlong(ptr+10) for the value).
 */

struct SYMBOL {
	char symname[8];
	short symtype;		/* see T_xxx below */
	long symvalue;
};
#define Newsymbol() (struct SYMBOL *)malloc((long)sizeof(struct SYMBOL))

/*
 * Bit definitions for the type field of a symbol.
 *
 * There is a special case for the linker here: the bit T_OST is a flag
 * meaning that the symbol's value field contains an INT (in host-machine
 * format, in the first two bytes of the field) which is the index of the
 * symbol in the output symbol table.
 *
 * If that field is -1, it means you have to look this symbol up in the
 * ost to get its index.  This happens when the symbol was extern to this
 * module and defined by a LATER module.
 *
 * The upshot is that a symbol which isn't in the ost has its type & value
 * fields intact, while a symbol which is in the ost has T_OST set and
 * its index in its value field (or -1 if you have to look it up).
 * When producing the output fixups, you either output a symbol fixup with
 * the new index (for a partial link), or resolve the symbol based on its
 * type & value from the output symbol table.
 */

#define T_DEFINED	0x8000
#define T_EQUATED	0x4000
#define T_GLOBAL	0x2000
#define T_REGISTER	0x1000
#define T_EXTERN	0x0800
#define T_DATA		0x0400	/* data-based relocatable */
#define T_TEXT		0x0200	/* text-based relocatable */
#define T_BSS		0x0100	/* bss-based relocatable  */
#define T_FILE		0x0080	/* file symbol */
#define T_ARCHIVE	0x0040	/* only when FILE set: archive file or no */
#define T_OST		0x0001	/* private: "symbol is in ost": see above */
#define T_COMMON	(T_GLOBAL | T_EXTERN)
#define T_SEG		(T_DATA | T_TEXT | T_BSS) /* segment bits */

/*
 * FIXUP bit definitions
 */

#define F_TYPE 7		/* mask to extract type bits */
#define F_ABS 0			/* absolute (don't fix up) */
#define F_DATA 1		/* data-based relocatable */
#define F_TEXT 2		/* text-based relocatable */
#define F_BSS 3			/* bss-based relocatable */
#define F_SYMBOL 4		/* type >> 3 contains symbol number */
#define F_LONG 5		/* first word of a long fixup */
#define F_PC 6			/* pc-relative relocatable */
#define F_INST 7		/* first word of an instruction */

/*
 * SYMREC: used by builddir for the lists of exports and imports, and
 * by the linker for the output symbol table (that's why there are
 * type and value fields, unused in builddir).
 */

#define SYMLEN 10			  /* symbol name size (incl null) */

struct SYMREC {
	char s_name[SYMLEN];	/* including null terminator */
	int s_type;
	long s_value;
	struct SYMREC *s_next;
};
#define Newsymrec() (struct SYMREC *)malloc((long)sizeof(struct SYMREC))

#define FNLEN 16		/* size of a file name (15 chars + NULL) */
struct FILEREC {
	char f_name[FNLEN];		/* the file name */
	struct FILEREC *f_next;		/* next file in the list */
	long f_offset;			/* offset of this file in archive */
	struct SYMREC *f_imports;	/* list of imported symbols */
	struct SYMREC *f_exports;	/* list of exported symbols */
};
#define Newfilerec() (struct FILEREC *)malloc((long)sizeof (struct FILEREC))

struct OFILE {
    char o_name[FNLEN];			/* fixed-length names */
    char o_arname[FNLEN];		/* name of archive this is from */
    struct OFILE *o_next;		/* next object file */
    long o_tbase, o_dbase, o_bbase;	/* computed bases for this ofile */
    int o_symstart;			/* first sym in image is nth in out */
    int o_flags;			/* flags (see O_*) */
    struct OHEADER o_header;		/* header of this file */
    char *o_image;			/* image of this file */
};
#define Newofile() (struct OFILE *)malloc((long)sizeof(struct OFILE))

/* flags in an Object File's o_flags field */

/* O_USED: means this ofile is used or is on the command line or in a -x */
#define O_USED	0x0001
#define O_ARCHIVE	0x0002	/* means this is a dummy archive entry */

/*
 * HREC: one item in a hash bucket, including a link to the next item
 *
 *	Commons and Globals share a hash table, but their value fields
 *	are interpreted differently.  See hash.c for details.
 */

struct HREC {
    char h_sym[SYMLEN];
    struct HREC *h_next;
    struct OFILE *h_ofile;
    long h_value;
    int h_type;
};

#define Newhrec() (struct HREC *)malloc((long)sizeof(struct HREC))

/*
 * general definitions
 */

#define NBUCKETS 256		/* number of hash buckets */
#define DIRSUFFIX ".ndx"	/* suffix for the directory file */
#define HEADSIZE 6
#define FNSIZE (FNLEN + 4)
#define SYMSIZE (SYMLEN + 2)

/*
 * These macros are for use with dependency vectors.
 */

#define Setbit(ptr,bit) ((ptr)[(bit)>>3] |= (0x80 >> ((bit)&7)))
#define Testbit(ptr,bit) ((ptr)[(bit)>>3] & (0x80 >> ((bit)&7)))

/*
 * These macros are used with the TYPE field of a SYMBOL.
 */

#define iscommon(type) (((type) & T_COMMON) == T_COMMON)
#define isglobal(type) (((type) & T_COMMON) == T_GLOBAL)
#define isextern(type) (((type) & T_COMMON) == T_EXTERN)
#define islocal(type)  (((type) & T_COMMON) == 0)

/*
 * This macro is used to compare two symbols for equality. It depends on
 * symcopy remaining as it is (copies two longs plus a null)
 */

#define symcmp(a,b) ((*(long *)(a) == *(long *)(b)) && \
		     (*(long *)((a) + sizeof(long)) == \
		      *(long *)((b) + sizeof(long))))

/*
 * forward declarations for both aln and builddir
 */

char *malloc(), *calloc(), *realloc();

char *index(), *rindex();
char *build_directory();

#ifndef STANDALONE	/* externals & forwards for aln only */

/* externals, defined by aln.c */

extern int aflag, bflag, dflag, fflag, kflag, lflag, mflag, oflag;
extern int pflag, qflag, rflag, sflag, tflag, uflag, vflag, wflag, xflag;
int noheaderflag;

#ifdef DBMALLOC
extern int twoflag;
extern int fourflag;
#endif DBMALLOC

extern long tval, dval, bval;
extern long hflags;
extern char ofile[];		/* output file name (value of -o arg) */
extern long rvalue, iaddr;

extern struct HREC *htable[];
extern struct HREC *unresolved;

extern struct OFILE *olist, *olast;
extern struct OFILE *plist, *plast;

extern int nsorts;
extern long sorttime;

char *path_tail();		/* get just the filename from a path */
long getticks();
struct HREC *lookup();
char *put_sym();
char *make_string();
struct OHEADER *make_ofile();
char *ost_base();
long ost_size();

#endif
