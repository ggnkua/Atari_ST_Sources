/* part.h */

/*
 *
 * Atari Hard Disk
 * Boot sector and partitioning structures.
 *
 *----
 * 24-Feb-1986 lmd   Structures from documentation.
 *
 */


/*
 * Partition entry for GEMDOS root sector;
 * There are four of these on the root sector;
 * longs are in 68000 format.
 */
#define	GEMPART struct _gempart	/* partition */
GEMPART {
    BYTE p_flg;				/* flag byte */
    BYTE p_id[3];			/* three bytes partition ID */
    long p_st;				/* partition starting sector */
    long p_siz;				/* partition size in sectors */
};

/*
 * Bits in p_flg:
 */
#define	P_BOOTBIT	0x80		/* 0x80, boot this partition */
#define	P_EXISTS	0x01		/* 0x01, partition exists */


/*
 * Partition entry for MSDOS root sector;
 * There are four of these on the root sector;
 * longs are in 8086 format.
 */
#define	MSPART struct _mspart	/* partition */
MSPART {
    BYTE b_ind;				/* boot indicatior */
    BYTE s_head;			/* starting head # */
    BYTE s_sect;			/* starting sector # */
    BYTE s_cyl;				/* starting cylinder # */
    BYTE s_ind;				/* system indicatior */
    BYTE e_head;			/* ending head # */
    BYTE e_sect;			/* ending sector # */
    BYTE e_cyl;				/* ending cylinder # */
    long r_sect;			/* relative starting sector # */
    long n_sect;			/* number of sectors */
};


/*
 * MSDOS Master Boot Record;
 * This lives on physical sector zero
 * of the device, and describes the device.
 *
 * The structure starts at 0x200 - sizeof(MSMBR).
 *
 *
 */
#define	MSMBR struct _msmbr		/* root sector */
MSMBR {
    UWORD chksum;			/* for GEMDOS ONLY */
    MSPART ms_p[4];			/* four partitions */
    UWORD signature;			/* signature */
};


/*
 * Format information is used by the Atari
 * Hard Disk Format Utility to get default
 * parameters for formatting the device.
 *
 * This is an image of part of the "set mode"
 * command.
 *
 */
#define	HINFO struct _hinfo	/* formatting information */
HINFO {
    WORD hi_cc;				/* cylinder count MSB / LSB */
    BYTE hi_dhc;			/* number of heads */
    WORD hi_rwcc;			/* reduced write current cyl */
    WORD hi_wpc;			/* write precomp cyl */
    BYTE hi_lz;				/* landing zone */
    BYTE hi_rt;				/* step rate code */
    BYTE hi_in;				/* interleave factor */
    BYTE hi_spt;			/* sectors-per-track */
};


/*
 * Root sector;
 * This lives on physical sector zero
 * of the device, and describes the device.
 *
 * The structure starts at 0x200 - sizeof(RSECT).
 *
 * longs are in 68000 format.
 *
 */
#define	RSECT struct _rsect	/* root sector */
RSECT {
    HINFO hd_info;			/* formatting information */
    long hd_siz;			/* size of disk, in sectors */
    GEMPART hd_p[4];			/* four partitions */
    long bsl_st;			/* start of bad sector list */
    long bsl_cnt;			/* end of bad sector list */
    WORD hd_reserved;			/* (reserved word) */
};


/*
 * Bios Parameter Block
 */
#define BPB struct _bpb		/* BPB */
BPB {
    int recsiz;			/* record size in bytes */
    int clsiz;			/* records per cluster */
    int clsizb;			/* bytes per cluster */
    int rdlen;			/* root directory length in records */
    int fsiz;			/* FAT size in records */
    int fatrec;			/* first FAT record of second FAT */
    int datrec;			/* first data record */
    int numcl;			/* available data clusters */
    int b_flags;		/* flags */
};

