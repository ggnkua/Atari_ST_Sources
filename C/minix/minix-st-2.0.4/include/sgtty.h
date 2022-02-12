/* The <sgtty.h> header contains data structures for ioctl(). */

#ifndef _SGTTY_H
#define _SGTTY_H

/* Should not be used, nor extended. Termios.h is the replacement for
 * sgtty.h for tty functions, and ioctl replaced code should be moved to
 * sys/ioctl.h and specific header files in the sys, or minix directory.
 */
#include <sys/ioctl.h>		/* Ouch. */

struct sgttyb {
  char sg_ispeed;		/* input speed */
  char sg_ospeed;		/* output speed */
  char sg_erase;		/* erase character */
  char sg_kill;			/* kill character */
  int  sg_flags;		/* mode flags */
};

struct tchars {
  char t_intrc;			/* SIGINT char */
  char t_quitc;			/* SIGQUIT char */
  char t_startc;		/* start output (initially CTRL-Q) */
  char t_stopc;			/* stop output	(initially CTRL-S) */
  char t_eofc;			/* EOF (initially CTRL-D) */
  char t_brkc;			/* input delimiter (like nl) */
};

#if !_SYSTEM			/* the kernel doesn't want to see the rest */

/* Field names */
#define XTABS	     0006000	/* do tab expansion */
#define BITS8        0001400	/* 8 bits/char */
#define BITS7        0001000	/* 7 bits/char */
#define BITS6        0000400	/* 6 bits/char */
#define BITS5        0000000	/* 5 bits/char */
#define EVENP        0000200	/* even parity */
#define ODDP         0000100	/* odd parity */
#define RAW	     0000040	/* enable raw mode */
#define CRMOD	     0000020	/* map lf to cr + lf */
#define ECHO	     0000010	/* echo input */
#define CBREAK	     0000002	/* enable cbreak mode */
#define COOKED       0000000	/* neither CBREAK nor RAW */

#define DCD          0100000	/* Data Carrier Detect */

/* Line speeds */
#define B0		   0	/* code for line-hangup */
#define B110		   1
#define B300		   3
#define B1200		  12
#define B2400		  24
#define B4800		  48
#define B9600 		  96
#define B19200		 192
#define B38400		 195
#define B57600		 194
#define B115200		 193

/* Things Minix supports but not properly */
/* the divide-by-100 encoding ain't too hot */
#define ANYP         0000300
#define B50                0
#define B75                0
#define B134               0
#define B150               0
#define B200               2
#define B600               6
#define B1800             18
#define B3600             36
#define B7200             72
#define EXTA             192
#define EXTB               0

/* Things Minix doesn't support but are fairly harmless if used */
#define NLDELAY      0001400
#define TBDELAY      0006000
#define CRDELAY      0030000
#define VTDELAY      0040000
#define BSDELAY      0100000
#define ALLDELAY     0177400

/* Copied from termios.h: */
struct winsize
{
	unsigned short	ws_row;		/* rows, in characters */
	unsigned short	ws_col;		/* columns, in characters */
	unsigned short	ws_xpixel;	/* horizontal size, pixels */
	unsigned short	ws_ypixel;	/* vertical size, pixels */
};
#endif /* !_SYSTEM */

#if MACHINE == ATARI

/* declaration for font header */
struct fnthdr {
        char width;
	char heigth;
	void *addr;
};

#define VDU_LOADFONT ('F' << 8)

/* ST specific clock stuff */
#define  DCLOCK ('D'<<8)

#define DC_RBMS100      (DCLOCK|1)
#define DC_RBMS200      (DCLOCK|2)
#define DC_RSUPRA       (DCLOCK|3)
#define DC_RICD         (DCLOCK|4)
#define DC_WBMS100      (DCLOCK|8)
#define DC_WBMS200      (DCLOCK|9)

/* acsi/scsi ioctl stuff */
struct scsi_cmd {
	unsigned char *cmd;
	unsigned int  cmd_cnt;
	unsigned char *buf;
	unsigned long size;
};

#define SCSI_READ       (('S'<<8)|'R')
#define SCSI_WRITE      (('S'<<8)|'W')

/* Data structures for floppy disk ioctl */

struct hparam {
	char max_cyl;
	char dense;     /* :6 */
	char size;      /* :2 */
	char sides;     /* :1 */
	char slow;      /* :1 */
};

#define SIDES1  0x00            /* 1 side */
#define SIDES2  0x01            /* 2 sides */
#define FAST    0x00
#define SLOW    0x01
#define I3      0x00
#define I5      0x01

struct fparam {
	int  sector_size;       /* sector size in bytes */
	char sector_0;          /* first sector on a track */
	char nr_sectors;        /* sectors per track */
	char cylinder_0;        /* cylinder offset */
	char nr_cylinders;      /* number of cylinders */
	char nr_sides;          /* :1 single/double sided */
	char density;           /* :3 density code */
	char stepping;          /* :1 double stepping */
	char autocf;            /* :1 autoconfig */
};

#define NSTP    0x00            /* normal stepping */
#define DSTP    0x01            /* double stepping */
#define DD      0x00            /* double density */
#define QD      0x01            /* hyper format */
#define HD      0x02            /* high density */
#define DD5     0x03            /* normal density for 5.25'' */

#define HARD    0x00            /* hard configuration */
#define AUTO    0x01            /* auto configuration */

#define DIOGETP         (('d'<<8)|'G')
#define DIOSETP         (('d'<<8)|'S')
#define DIOGETHP        (('d'<<8)|'g')
#define DIOSETHP        (('d'<<8)|'s')
#define DIOFMTLOCK      (('d'<<8)|'L')
#define DIOFMTFREE      (('d'<<8)|'F')

#endif /* MACHINE == ATARI */

#if MACHINE == SUN_4_60
/* Window size support, not really SparcStation specific */
struct winsize {
  unsigned short ws_row;        /* number of character rows */
  unsigned short ws_col;        /* number of characters per line */
  unsigned short ws_xpixel;     /* horizontal character size in pixels */
  unsigned short ws_ypixel;     /* vertical character size in pixels */
};

#define TIOCSWINSZ (('t'<<8) | 103)     /* set window size */

/* SparcStation specific floppy support: */
struct diskio {
  int  f_cyl;                   /* disk cylinder number */
  unsigned char f_head;         /* disk head (aka 'side' or 'track') number */
  unsigned char f_sec;          /* sector number (not used at the moment */
  unsigned char f_density;      /* bit density (data rate): HIGH_D or LOW_D */
  char *f_buf;                  /* address of data */
  int  f_cnt;                   /* length of buffer in bytes */
};

#define TIOCEJECT (('f'<<8) | 0)        /* Floppy disk eject */
#define TIOCFORMAT (('f'<<8) | 1)       /* Format one track */

#define LOW_D           1       /* Actually: `normal' density MFM (250Kb/s) */
#define HIGH_D          0       /* `high' density MFM (500Kb/s) */
#endif /* MACHINE == SUN_4_60 */

#endif /* _SGTTY_H */
