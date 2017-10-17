/*
 * One Man Unix system configuration file. MicroBox system
 */

# include	"../include/param.h"
# include       "../include/dev.h"
# include       "../include/memory.h"

/* Eltec Initial memory segment sizes */

extern	struct Minseg mseg0[], mseg1[], mseg2[], mseg3[];
extern	struct Minseg mseg4[], mseg5[], mseg6[];
 
# define	CA	caddr_t		/* C address type */

/*	Inuse - nsegs - address segs - start address - end address */
struct	Majseg dmem_maj[NMSEGS] = {
	1, NMINSEG0, mseg0, (CA)0x000000L, (CA)0x100000L, /* Total space */
	1, NMINSEG1, mseg1, (CA)0x000000L, (CA)0x020000L, /* Kernel space */
	0, NMINSEG2, mseg2, (CA)0x020000L, (CA)0x058000L, /* Process space */
	0, NMINSEG3, mseg3, (CA)0x058000L, (CA)0x058000L, /* Process 2 space */
	0, NMINSEG4, mseg4, (CA)0x058000L, (CA)0x080000L, /* Swap space */
	0, NMINSEG5, mseg5, (CA)0x080000L, (CA)0x080000L, /* Ramdisk space */
	0, NMINSEG6, mseg6, (CA)0x080000L, (CA)0x080000L /* User addon space */
};

int     fdopen(), fdstrat(), fdclose(), fdioctl();
int     rdopen(), rdstrat(), rdclose();
int     hdopen(), hdstrat(), hdclose(), hdioctl();

/* Initial Block Device Switch */
struct dev dbdevsw[NBDEVS] = {
	1, fdopen,   fdclose,  fdstrat,	0,	0, 0,	/* fd (codata) */
	1, rdopen,   rdclose,  rdstrat,	0,	0, 0,	/* Ramdisk */
	1, hdopen,   hdclose,  hdstrat,	0,	0, 0,	/* hd (scsi) */
	0, 0,	  0,	    0,		0,	0, 0	/* User add on */
};

/* Real block device switch */
struct dev bdevsw[NBDEVS];

int o_tty(), c_tty(), i_tty(), r_tty(), w_tty();
int r_null(), w_null();

/* Initial Character Device Switch */
struct dev dcdevsw[NCDEVS] = {
	1, o_tty, c_tty, i_tty,	r_tty,	w_tty, 0,	/* 0 = tty handler */
	1, 0,	0, 0,	r_null,	w_null,	0,		/* 1 = null device */
	1, fdopen, fdclose,fdioctl,0,	0, 0,		/* 2 = the raw fdisk */
	1, hdopen, hdclose,hdioctl,0,	0, 0,		/* 3 = the raw hdisk */
	0, 0,	0,	0,	0,	0, 0,		/* 4 = user add on */
	0, 0,	0,	0,	0,	0, 0,		/* 5 = user add on */
	0, 0,	0,	0,	0,	0, 0,		/* 6 = user add on */
	0, 0,	0,	0,	0,	0, 0		/* 7 = user add on */
};

/* Real character device switch */
struct dev cdevsw[NCDEVS];
