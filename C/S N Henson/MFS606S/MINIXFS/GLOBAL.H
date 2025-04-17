/* Global variables , in order to get these defined properly in 'main.c'
 * and extern everywhere else, the macro EXTERN is used.
 */

#include "hdio.h"

#ifndef EXTERN
#define EXTERN extern
#else
#define INIT
#endif

/* General scratchpad 1K bufr structure */
EXTERN bufr temp;

EXTERN super_info *super_ptr[NUM_DRIVES];   /* Pointer to drive info */

EXTERN char lrecno;		    /* set to '1' if RWABS permits 'lrecno' */
EXTERN char checklrecno;	    /* Set to 1 if lrecno checked for */
EXTERN char lockok;		    /* Set to 1 if locking calls allowed */
EXTERN char no_length;		    /* Length paramater to getname supported */
EXTERN FILEPTR *firstptr;	    /* First FILEPTR in chained list */

/* mini-cache for m_getname */

EXTERN char *lpath;
EXTERN fcookie lroot,ldir;
EXTERN short llength;

/* Hard disk info structure */

EXTERN struct hdinfo disk[NUM_DRIVES];

/* Cache controls system and user */

EXTERN cache_control syscache,icache,usrcache;

/* Kernel info structure */

EXTERN struct kerinfo *kernel;

/* Dummy f_cache structure */
EXTERN f_cache dummy;

/* Cache info */
EXTERN short update_pid;
EXTERN unsigned update_suspend;

/* Binary configurable parameters */

#ifdef INIT
/* Cache sizes */
long ucache_size = UCACHE_SIZE;
long scache_size = SCACHE_SIZE;
long icache_size = ICACHE_SIZE;

/* Translation modes */
long fs_mode[NUM_DRIVES] = {
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,TRANS_DEFAULT,
};


/* Magic number */
long mfs_magic=MFS_MAGIC;

/* Minixfs version */
#include "version.h"
int mfs_maj=MFS_MAJOR;
int mfs_min=MFS_MINOR;
int mfs_plev=MFS_PLEV;

/* Manual partitions */
struct phys_part ppart[NUM_DRIVES] = {
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},
{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1},{ -1,-1,-1,-1}
};

int max_incr=MAX_INCREMENT;

int cache_mode=CACHE_MODE;

int sync_time=SYNC_TIME;

#else 

long ucache_size,scache_size,icache_size;
long mfs_magic;
int mfs_maj,mfs_min,max_incr;
long fs_mode[];
struct phys_part ppart[];
int cache_mode;
int sync_time;

#endif

