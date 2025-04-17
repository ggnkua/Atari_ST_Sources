/* This file defines the pun_info structure used in several kinds of hard disk
 * driver software. Basically it gives info for the first 16 bios drives.
 * Since it gives physical partition starts it's rather useful. Only snag is
 * the 'first 16 bios drives' bit.
 */

#define		MAXUNITS	16

struct	pun_info {
	unsigned short	puns;			/* Number of HD's */
	unsigned char	pun[MAXUNITS];		/* AND with masks below: */
#define PUN_DEV		0x1f			/* device number of HD */

/* Note: I think this is right. It is a bit mask for the bits of 'pun' which
 * refer to a device. Bits 0-2 are unit number, bit 3=0 for ACSI bus and 1 for
 * TT SCSI bus. Device numbers 0x10, (and possibly 0x11) are for Falcon IDE
 * bus and maybe third party IDE interfaces too. So it looks like bits 0-4 are
 * used for now; so a mask of 0x1f is used. Bit 6 means 'removable'.
 */

#define PUN_UNIT	0x7			/* Unit number */
#define PUN_SCSI	0x8			/* 1=SCSI 0=ACSI */
#define PUN_IDE		0x10			/* Falcon IDE */
#define PUN_REMOVABLE	0x40			/* Removable media */

#define PUN_VALID	0x80			/* zero if valid */

	long		partition_start[MAXUNITS];
	long		cookie;			/* 'AHDI' if following valid */
	long		*cookie_ptr;		/* Points to 'cookie' */
	unsigned short	version_num;		/* AHDI version */
	unsigned short	max_sect_siz;		/* Max logical sec size */
	long		reserved[16];		/* Reserved */
};

#define PUN_PTR (*((struct pun_info **)0x516))
