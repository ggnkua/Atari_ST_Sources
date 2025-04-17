/* Global and static Variables */

#include "../minixfs/hdio.h"

#ifndef EXTERN
#define EXTERN extern
extern char lfname[];
#else
char lfname[]="lost+found";
#endif

/* General linked list structure */
typedef struct linked_list
{
	long member;
	struct linked_list *next;
} llist;

/* Structure for determining inode names */

typedef struct inlist
{
	unsigned inum;		/* Inode number */
	unsigned iparent;	/* Parent directory */
	struct inlist *next;	/* pointer to next entry */
	char name[1];		/* Actually longer than this ... */
} ilist;

EXTERN char *drvnam;

EXTERN char version;		/* Non-zero for V2 */

EXTERN char modified,preen;

EXTERN ilist *inolist;

EXTERN llist *inums;

EXTERN long maxzone,minzone;	/* Max/Min Allowed Zone Numbers */
EXTERN long maxino;		/* Max Inode Number */
EXTERN long ioff;		/* Zone offset to inode block */

EXTERN int incr;		/* Directory increment */

EXTERN long berr;		/* Bitmap errors */

EXTERN char badroot;		/* Bad root inode or forced reallocation */

EXTERN long zonecount;			/* Maximum Zone Count */
EXTERN long indcount;			/* Number of indirection blocks */
EXTERN char dindcount;			/* '1' If double indirection block */

EXTERN char trunc,done_trunc;		/* Flags for truncation of files */

EXTERN char quit_trav;

/* These only appear in 'fsck.c' */
#if defined(V1) || defined(V2)
static d_inode *rip;	
static d_inode zinode;			/* zero inode */
static inode_stat *ist,*inode_status;
#endif

EXTERN long cino;			/* current inode */

EXTERN unsigned *zbitmap,*szbitmap;	/* Zone and shadow zone bitmap */
EXTERN unsigned *ibitmap;		/* Inode Bitmap */

EXTERN int cdirty;	

EXTERN super_block *Super;

EXTERN long ndir,nreg,nfifo,nchr,nblk,nsym,zfree,ifree;

EXTERN char ally,alln,info;

EXTERN unsigned lfinode;

EXTERN struct hdinfo hdinf;
