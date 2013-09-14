/* ________
** getstart header file
** atari corp	(1 March 1988)  asm
**
** see GETSTART(3) manual pages
**
** $Header$
** $Source$
** $Author$
**
** $Revision$
** $Date$
** $State$
** $Locker$
** $Log$
*/



/*
** Getstart information structure.
*/

typedef struct				/* GSINFO getstart information */
	{
	   int gs_count;		/* current cluster link count */
	   int gs_prev;			/* previous cluster number */
	   int gs_head;			/* head cluster number */
	   int gs_dsect;		/* directory logical sector */
	   int gs_doff;			/* directory byte offset */
	   char gs_fpath[256];		/* file path string (packed) */
	} GSINFO;



/*
** Function declarations.
*/

extern GSINFO *getstart ();
extern int *fatck ();



/*
** Getstart errors.
*/

# define	GFAIL	(0L)		/* miscellaneous misdemeanor */
# define	GORPH	(-1L)		/* orphan in FAT allocation chain */
# define	GALLO	(-2L)		/* current cluster not allocated */
# define	GOOFY	(-3L)		/* FAT not validated by fatck */



/*
** Fatck errors.
*/

# define	FFAIL	(0L)		/* miscellaneous misdemeanor */
# define	FFATS	(-1L)		/* FAT read error */
# define	FROOT	(-2L)		/* root directory read error */
# define	FCONF	(-3L)		/* conflicting FAT entry */
# define	FAMBI	(-4L)		/* ambiguous FAT entry reference */



/*
** File system definitions (from fs.h).
*/

typedef struct				/* FCB file control block */
	{
	   char f_name[11];		/* file name with extension */
	   char f_attrib;		/* file attribute */
	   char f_fill[10];		/* reserved */
	   int f_time;			/* file modification time */
	   int f_date;			/* file modification date */
	   int f_clust;			/* file starting cluster number */
	   long f_fileln;		/* file size in bytes */
	} FCB;

# define	FN_FRE	(0x00)		/* file name never used */
# define	FN_DEL	(0xe5)		/* file name deleted */
# define	FN_DIR	(0x2e)		/* directory entry */

# define	FA_SUB	(0x10)		/* subdirectory entry */

typedef struct				/* BPB bios parameter block */
	{
	   int recsiz;			/* record size in bytes */
	   int clsiz;			/* records per cluster */
	   int clsizb;			/* bytes per cluster */
	   int rdlen;			/* root directory length in records */
	   int fsiz;			/* FAT size in records */
	   int fatrec;			/* first FAT record of second FAT */
	   int datrec;			/* first data record */
	   int numcl;			/* available data clusters */
	   int b_flags;			/* flags */
	} BPB;

# define	BF_F16	(0x0001)	/* 16-bit FAT entries, else 12-bit */
