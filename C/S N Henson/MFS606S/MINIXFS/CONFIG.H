/* User settable parameters */

/*#define MFS_NMOVE_DIR*/	/* no movement of directories (rename OK) */
/*#define LRDEBUG*/		/* debug lrecno */
/*#define BIGDIRTEST*/		/* debug big dir code */
#define SCACHE_SIZE	20	/* # blocks in built in system cache */
#define ICACHE_SIZE	10	/* # blocks in built in inode cache */
#define UCACHE_SIZE	40	/* # blocks in built in user cache */ 

#define PRE_READ	8	/* Max Number of blocks to 'read-ahead' */

#define CACHE_MODE	TURBO	/* Cache mode of operation */
#define TURBO		0	/* Only sync() thru update process */
#define NORMAL 		1	/* sync() on all but writes */
#define ROBUST		2	/* sync() on everything ***slow*** */

#define SYNC_TIME	5	/* sync time is seconds */

#define MAX_RWS		1024	/* Maximum sectors to read/write atomically */

#define MAX_INCREMENT	4	/* Determines max filename length */

/* Default translation modes ... change if desired */
#define TRANS_DEFAULT	(SRCH_TOS | DIR_TOS | DIR_MNT | LWR_TOS | AEXEC_TOS )

/* Set this to be true if 'c' is an illegal character for a filename */

#define BADCHR(c)	(c=='/')

/* Some unixes have something a bit stricter,uncomment out this if required */

/* #define BADCHR(c) ( (c=='/') || (c & 0x80) ) */

/* (or supply your own ) */

#define SYMLINK_NAME_MAX 127	/* Maximum size of symlink name */
#define MINIX_MAX_LINK	127	/* Max links to an inode *MUST* be < 256 */


