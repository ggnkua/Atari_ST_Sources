/*
 * bios.h -- header file for Atari ST "bios" functions.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

/*
 * Device handles for Bconin(), Bconout(), Bconstat(), and Bcostat().
 */
#define BC_PRT	0	/* Printer port, output, and input */
#define BC_AUX	1	/* Auxiliary port, output, and input */
#define BC_CON	2	/* Console keyboard/display, output, and input */
#define BC_MID	3	/* Midi port, output, and input */
#define BC_KBD	4	/* Intelligent keyboard port, output only */
#define BC_RAW	5	/* Raw screen, output only */
/*
 * Scan codes for miscellaneous keys.  Some of these may be found in the
 * high word of the long returned by Bconin(BC_CON).
 */
#define KC_RET	0x1C	/* Return key */
#define KC_CTRL	0x1D	/* Control key - never returned by Bconin() */
#define KC_LSH	0x2A	/* Left shift key - never returned by Bconin() */
#define KC_RSH	0x36	/* Right shift key - never returned by Bconin() */
#define KC_ALT	0x38	/* Alt key - never returned by Bconin() */
#define KC_CAPS	0x3A	/* Caps lock key - never returned by Bconin() */
#define KC_F1	0x3B	/* Function key 1 */
#define KC_F2	0x3C
#define KC_F3	0x3D
#define KC_F4	0x3E
#define KC_F5	0x3F
#define KC_F6	0x40
#define KC_F7	0x41
#define KC_F8	0x42
#define KC_F9	0x43
#define KC_F10	0x44
#define KC_CLR	0x47	/* Clr Home key */
#define KC_CUP	0x48	/* Cursor up */
#define KC_CLEFT 0x4B	/* Cursor left */
#define KC_CRIGHT 0x4D	/* Cursor right */
#define KC_CDOWN 0x50	/* Cursor down */
#define KC_INS	0x52	/* Insert key */
#define KC_UNDO	0x61	/* Undo key */
#define KC_HELP	0x62	/* Help key */
#define KC_ENT	0x72	/* Enter key */
/*
 * Shift key bits returned by Getshift():
 */
#define GS_RSH	1	/* Right shift key */
#define GS_LSH	2	/* Left shift key */
#define GS_CTRL	4	/* Control key */
#define GS_ALT	8	/* Alt key */
#define GS_CAPS	16	/* Caps Lock key */
#define GS_RMB	32	/* Right mouse button - Clr Home */
#define GS_LMB	64	/* Left mouse button - Insert */
/*
 * Structures referenced by Getmpb():
 */
struct mdb {			/* Memory descriptor block */
	struct mdb *md_next;	/* Link to next descriptor */
	char *md_base;		/* Base of memory block */
	long md_size;		/* Length of memory block */
	long md_proc;		/* Owner's process identifier */
};
struct mpb {			/* Memory parameter block */
	struct mdb *mp_free;	/* Free descriptor list head */
	struct mdb *mp_used;	/* Allocated descriptor list head */
	long	*mp_rove;	/* Roving pointer of unknown significance */
};
/*
 * Strucures referenced by Getbpb() -- BIOS block device parameter block:
 */
struct bpb {
	short	bp_recsiz;	/* Sector size in bytes = 512 */
	short	bp_clsiz;	/* Cluster size in sectors = 2 */
	short	bp_clsizb;	/* Cluster size in bytes = 1024 */
	short	bp_rdlen;	/* Root directory size in sectors */
	short	bp_fsiz;	/* FAT size in sectors */
	short	bp_fatrec;	/* Sector number of second FAT */
	short	bp_datrec;	/* Sector number of data */
	short	bp_numcl;	/* Number of data clusters */
	short	bp_flags;	/* 1 = 16-bit FAT */
};
/*
 * BIOS parameter block, as found in boot block of device.
 * Note that the byte order is that of the 8086:
 */
struct bbpb {
	char	bp_bras[2];	/* branch to boot code */
	char	bp_oem[6];	/* OEM cruft */
	char	bp_serial[3];	/* 24-bit serial number */
	char	bp_bps[2];	/* Sector size in bytes = 512 */
	char	bp_spc;		/* Cluster size in sectors = 2 */
	char	bp_res[2];	/* Reserved sectors */
	char	bp_nfats;	/* Number of FATs = 2 */
	char	bp_ndirs[2];	/* Root directory size in entries */
	char	bp_nsects[2];	/* Total sectors on medium */
	char	bp_media;	/* Medium descriptor */
	char	bp_spf[2];	/* FAT size, in sectors */
	char	bp_spt[2];	/* No. of sectors per track */
	char	bp_nsides[2];	/* No. of sides on medium */
	char	bp_nhid[2];	/* hidden sectors = ignored */
				/* 482 bytes of boot code */
};

/* End of bios.h */
