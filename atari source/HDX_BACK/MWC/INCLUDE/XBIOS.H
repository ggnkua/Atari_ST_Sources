/*
 * xbios.h -- header file for Atari ST xbios functions.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */
/* Bioskeys(): no information required */
/* Cursconf() operation codes: */
#define CC_HIDE	0		/* Hide cursor */
#define CC_SHOW	1		/* Show cursor */
#define CC_BLNK	2		/* Make cursor blink */
#define CC_NBLNK 3		/* Make cursor not blink */
#define CC_SET	4		/* Set cursor blink rate */
#define CC_GET	5		/* Get cursor blink rate */
/* Dosound() operation bytes */
/* Flopfmt(), Floprd(), Flopver(), Flopwr() - no information required */
/* Getrez() resolution codes: */
#define GR_LOW	0		/* Low resolution */
#define GR_MED	1		/* Medium resolution */
#define GR_HIGH	2		/* High resolution */
/* Gettime(), Settime(): see time.h */
/* Giaccess() register names and values */
/* Ikbdws() intelligent keyboard commands: */
#define IK_MOUSEBUT	0x7	/* mouse button pragma, one byte */
				/* 1 - report press; 2 - report release;
				 * 3 - report both; 4 - report as if keys,
				 * left = 0x74, right = 0x75 */
#define IK_MOUSEREL	0x8	/* mouse relative henceforth, three bytes */
#define IK_MOUSEABS	0x9	/* mouse absolute henceforth, two words */
#define IK_MOUSECUR	0xA	/* mouse returns cursor keys */
#define IK_MOUSEHOPREL	0xB	/* mouse relative threshold */
#define IK_MOUSEHOPABS	0xC	/* mouse absolute threshold */
#define IK_CLOCKSET	0x1B	/* Set clock time:
				 * takes yr, mo, da, hr, mi, se in bcd */
#define IK_CLOCKGET	0x1C	/* Get the clock time: Returns 0xFC,
				 * yr, mo, da, hr, mi, se in bcd */
/* Initmouse() opcodes and parameter buffer */
#define IM_OFF	0		/* Disable mouse */
#define IM_REL	1		/* Enable mouse in relative mode */
#define IM_ABS	2		/* Enable mouse in absolute mode */
#define IM_KEY	4		/* Enable mouse in cursor key mode */
struct initmouse {
	char	im_left;	/* Coordinate handedness */
	char	im_bset;	/* Button settings */
	char	im_xwgt;	/* X axis threshold */
	char	im_ywgt;	/* Y axis threshold */
	short	im_xmax;	/* X maximum absolute position */
	short	im_ymax;	/* Y maximum absolute position */
	short	im_xabs;	/* X absolute position */
	short	im_yabs;	/* Y absolute position */
};
/* Iorec() device handles and buffer structure */
#define IO_AUX	0		/* Handle for auxiliary port buffers */
#define IO_KBD	1		/* Handle for keyboard input buffer */
#define IO_MID	2		/* Handle for midi input buffer */
struct iorec {			/* Structure pointed to by Iorec return value */
	char *io_buff;		/* Buffer */
	short io_bufsiz;	/* Buffer size in bytes */
	short io_head;		/* Current write pointer */
	short io_tail;		/* Current read pointer */
	short io_low;		/* Low water mark, unstop line */
	short io_high;		/* High water mark, stop line */
};
/* Jdisint(), Jenabint(), Mfpint() interrupt identifications */
				/* Lowest priority */
#define MFP_BIT0	0	/* I/O port bit 0 */
#define MFP_BIT1	1
#define MFP_BIT2	2
#define MFP_BIT3	3
#define MFP_TIMD	4	/* Timer D, RS232 baud rate generator */
#define MFP_TIMC	5	/* Timer C, system 200hz clock */
#define MFP_BIT4	6	/* I/O port bit 4 */
#define MFP_BIT5	7
#define MFP_TIMB	8	/* Timer B, graphics? */
#define MFP_XERR	9	/* RS232 transmit error */
#define MFP_EMPT	10	/* RS232 transmit buffer empty */
#define MFP_RERR	11	/* RS232 receive error */
#define MFP_FULL	12	/* RS232 receive buffer full */
#define MFP_TIMA	13	/* Timer A, user programmable */
#define MFP_BIT6	14	/* I/O port bit 6 */
#define MFP_BIT7	15	/* I/O port bit 7 */
				/* Highest priority */
/* Keytbl() returned vector */
struct keytbl {
	char *kt_normal;	/* Normal key mapping */
	char *kt_shifted;	/* Shifted key mapping */
	char *kt_capslock;	/* Caps Locked key mapping */
};
/* Kbdvbase() vector table structure */
struct kbdvbase {
	void	(*kb_midivec)();	/* Midi input data vector */
	void	(*kb_vkbderr)();	/* Keyboard error vector */
	void	(*kb_vmiderr)();	/* Midi error vector */
	void	(*kb_statvec)();	/* Keyboard status packet */
	void	(*kb_mousevec)();	/* Keyboard mouse packet */
	void	(*kb_clockvec)();	/* Keyboard clock packet */
	void	(*kb_joyvec)();		/* Keyboard joystick packet */
	void	(*kb_midisys)();	/* System midi vector */
	void	(*kb_kbdsys)();		/* System keyboard vector */
};
/* Kbrate() operation codes */
/* Midiws() - info depends on midi devices */
/* Offgibit(), Ongibit() bit assignments */
/* Protobt() */
/* Prtblk() argument structure */
struct prtblk {
	char *pb_blkptr;		/* Address of bit block
					 * or text string */
	int pb_offset;			/* Bit offset into block */
	int pb_width;			/* Pixel width of block to dump */
					/* or length of text string */
	int pb_height;			/* Pixel height of block to dump
					 * or zero for text print */
	int pb_left;			/* Pixels to left of block */
	int pb_right;			/* Pixels to right of block:
					 * enclosing bitmap is
					 * pb_right+pb_width+pb_left wide */
	int pb_srcres;			/* Source resolution, a la Getrez() */
	int pb_dstres;			/* Output resolution */
	int *pb_colpal;			/* Color palette, ala Setpalette() */
	int pb_type;			/* Printer type */
	int pb_port;			/* Printer port */
	int *pb_masks;			/* Halftone dithers */
};
#define PB_DRAFT	0		/* Low density pb_dstres */
#define PB_FINAL	1		/* High density pb_dstres */
#define PB_MONO160	0		/* Dot matrix 1/160 inch pb_type */
#define PB_COLOR160	1		/* Dot matrix 1/160 inch pb_type */
#define PB_DAISY	2		/* Daisy wheel pb_type (text only) */
#define PB_MONO120	3		/* Dot matrix 1/120 inch pb_type */
#define PB_PRT		0		/* Parallel port pb_port */
#define PB_AUX		1		/* Serial port pb_port */
/* Rsconf() magic numbers */
enum {					/* Line speeds */
	RS_B19600, RS_B9600, RS_B4800, RS_B3600, RS_B2400, RS_B2000,
	RS_B1800, RS_B1200, RS_B600, RS_B300, RS_B200, RS_B150,
	RS_B134, RS_B110, RS_B75, RS_B50
};
enum {					/* Line protocols */
	RS_NONE, RS_XONXOFF, RS_RTSCTS, RS_BOTH
};
/* Setprt() magic numbers */
#define PR_MATRIX	0		/* Dot matrix printer */
#define PR_DAISY	1		/* Daisy wheel printer */
#define PR_POLY		0		/* Polychrome printer */
#define PR_MONO		2		/* Monochrome printer */
#define PR_ATARI	0		/* Atari printer */
#define PR_EPSON	4		/* Epson printer */
#define PR_DRAFT	0		/* Draft quality */
#define PR_FINAL	8		/* Presentation quality */
#define PR_PARALLEL	0		/* Parallel interface */
#define PR_SERIAL	0x10		/* Serial interface */
#define PR_TRACTOR	0		/* Tractor feed */
#define PR_SHEET	0x20		/* Single sheet feed */
/* Xbtimer() magic numbers */

/* End of xbios.h */
