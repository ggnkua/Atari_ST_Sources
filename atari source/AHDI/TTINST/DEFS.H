/* defs.h */

#define	DVRSOURCE "SHDRIVER.RAW" 	/* hard disk driver */
#define	DVRNAME  ":\\SHDRIVER.SYS" 	/* driver destination on hard disk */
#define	OLDDVR  ":\\SH204DVR.SYS" 	/* old driver */
/*#define	RESOURCEFILE "HINSTALL.RSC"*/	/* resource file for HINSTALL */
#define	RESOURCEFILE "CPYBOOT.RSC"	/* resource file for CPYBOOT */


#define	BUFSIZ	10240L

#define WI_KIND		0		/* window to be opened on screen */

#define MAXPHYSDEVS	8		/* max #devs on DMA bus */
#define	MAXLOGDEVS	14		/* max # logical block devices */
#define	NPARTS		4		/* #partitions in root block */

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

#define	FALSE		0
#define TRUE		1

#define	OK		0
#define	ERROR		(-1)
#define BAILOUT		(-2)

#define	BOOTDEV		0x446	    /* address of boot device */
#define	PUNPTR		0x516	    /* address of pun pointer */

#define	AHDI		0x41484449  /* hex value of 'AHDI' */
