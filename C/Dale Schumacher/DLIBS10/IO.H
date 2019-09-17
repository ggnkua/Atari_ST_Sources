/*
 *	IO.H		Defines for file processing and i/o functions
 */

#define	remove		unlink
#define	fexists(f)	access(f,_ACCe)

/* access() modes */
#define	_ACCe		0x17		/* file/directory exists */
#define	_ACCr		0x07		/* file can be read */
#define	_ACCw		0x06		/* file can be written */
#define	_ACCrw		0x06		/* file can be read and written */

/* creat() modes */
#define	_CRErw		0x00		/* read/write */
#define	_CREro		0x01		/* read only */
#define	_CREh		0x02		/* hidden file */
#define	_CREs		0x04		/* system file */
#define	_CREv		0x08		/* volume label */

/* open() modes */
#define _OPNr		0		/* read mode */
#define _OPNw		1		/* write mode */
#define _OPNrw		2		/* read/write mode */

/* lseek() origins */
#define _LSKbeg		0		/* from beginning of file */
#define _LSKcur		1		/* from current location */
#define _LSKend		2		/* from end of file */

/* cfg_ch() flags */
#define	_CIOb		0x01		/* Use BIOS level i/o calls */
#define	_CIOch		0x02		/* 8-bit codes only (cf:getch) */
#define	_CIOvt		0x04		/* VT-52 escape sequence processing */

/* setvbuf() modes */
#define	_SVBn		0		/* no buffering */
#define	_SVBf		1		/* full buffering */
#define	_SVBl		1		/* line buffering (not available) */


typedef struct {		/* STAT structure (coincidently == DTA) */
	char	S_rsvd[21];		/* reserved field. DON'T TOUCH! */
        char	S_mode;			/* mode flags (creat() compatable) */
        int	S_time;			/* last modification time */
	int	S_date;			/* last modification data */
        long	S_size;			/* size of file in bytes */
        char	S_name[14];		/* file name */
} STAT;


extern	char	*fullpath();
extern	char	*findfile();
extern	char	*pfindfile();
extern	long	fsize();
extern	FILE	*fopen();
extern	FILE	*freopen();
extern	FILE	*fdopen();
extern	long	fseek();
extern	char	*fgets();
extern	char	*gets();
