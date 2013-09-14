/* defs.h */


#define	RESOURCEFILE	"SHOW.RSC"	/* Resource file for main */

#define SCAN_BS     0				/* the flag for sortpart() use */
#define USER_ED     1				/* the flag for sortpart() use */
#define NO_EXT		-1				/* no extended partition */

#define WI_KIND		0		/* window to be opened on screen */

#define	NULL	0L
#define	LONG	long
#define	WORD	int
#define UWORD	unsigned int
#define	BYTE	char

#define	SECTOR	LONG

#define	OFF		0
#define ON		1

#define	NO		0
#define YES		1
#define NOMAX   2

#define	FALSE		0
#define TRUE		1

#define	OK		0
#define	ERROR		(-1)
#define BAILOUT		(-2)

#define ARROW_MOUSE	graf_mouse(ARROW, 0x0L)
#define BEE_MOUSE	graf_mouse(HOURGLASS, 0x0L)

extern long gemdos();
extern char *mymalloc();
