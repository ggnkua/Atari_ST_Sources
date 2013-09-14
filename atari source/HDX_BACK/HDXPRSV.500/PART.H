/* part.h */

/*
 *
 * Atari Hard Disk
 * Boot sector and partitioning structures.
 *
 *----
 * 24-Feb-1986 lmd   Structures from documentation.
 * 15-Aug-1988 jye	 Add the dynamic partition structure.
 */


/*
 * Partition entry;
 * There are four of these on the root sector;
 * longs are in 68000 format.
 */
#define	PART struct _part	/* partition */
PART {
    BYTE p_flg;				/* flag byte */
    BYTE p_id[3];			/* three bytes partition ID */
    long p_st;				/* partition starting sector */
    long p_siz;				/* partition size in sectors */
};


#define	SAVEPART struct _savepart	/* partitions the user want to keep after */
									/* the partitioning opration  */
SAVEPART {
    long savest;				/* partition starting sector */
    long savend;				/* partition size in sectors */
    BYTE saveflg;				/* flag byte */
};

#define OLDPART struct _oldpart   	/* reconstruct the kept partition map */
									/* which only include kept parttion   */
OLDPART	{ 							
	long o_st;
	long o_end;
	BYTE o_done;
};

#define NEWPART struct _newpart   	/* reconstruct the kept partition map */
									/* which only include kept parttion   */
NEWPART	{ 							
	long n_st;
	long n_end;
	BYTE n_done;
};

#define PRVHDR struct _prvhdr  		/* the prevous partition header */

PRVHDR {
	UWORD fatsiz;					/* fat size */
	UWORD dirsiz;					/* director size */
};

#define NEWHDR struct _newhdr  		/* the new partition header */

NEWHDR {
	UWORD fatsize;					/* fat size */
	UWORD dirsize;					/* director size */
};


#define	DPART struct _dpart	/* the dynamic partition block*/
DPART {
    BYTE flg;				/* flag byte */
	BYTE kpyes;				/* the flag tells the partition will keep */
	long st;				/* the begining sector of the partition */
    long siz;				/* partition size in sectors */
	DPART *next;			/* the pointer point to next block */
};

/*
 * Bits in p_flg:
 */
#define	P_BOOTBIT	0x80		/* 0x80, boot this partition */
#define	P_EXISTS	0x01		/* 0x01, partition exists */
#define	P_NEXISTS	0x00		/* 0x00, partition does not exists */


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
    UWORD hi_cc;			/* cylinder count MSB / LSB */
    BYTE hi_dhc;			/* number of heads */
    UWORD hi_rwcc;			/* reduced write current cyl */
    UWORD hi_wpc;			/* write precomp cyl */
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
    PART hd_p[4];			/* four partitions */
    long bsl_st;			/* start of bad sector list */
    long bsl_cnt;			/* end of bad sector list */
    UWORD hd_reserved;			/* (reserved word) */
};


/*
 * Boot sector format.
 * This is identical to that on a floppy disk.
 * '*'d entries are valid values in the boot sector.
 *
 */
#define	BOOT struct _boot
BOOT {
    BYTE b_bra[2];		/*    usually BRA.S to code */
    BYTE b_filler[6];		/*    OEM field, "Loader" or "HDLoad" */
    BYTE b_serial[3];		/*    serial number */
    BYTE b_bps[2];		/* *  bytes per sector */
    BYTE b_spc;			/* *  sectors per cluster */
    BYTE b_res[2];		/* *  number of reserved sectors */
    BYTE b_nfats;		/* *  number of FATs */
    BYTE b_ndirs[2];		/* *  number of root directory entries */
    BYTE b_nsects[2];		/* *  number of sectors on media */
    BYTE b_media;		/* *  media descriptor flag */
    BYTE b_spf[2];		/* *  number of sectors/FAT */
    BYTE b_spt[2];		/*    number of sectors/track */
    BYTE b_nsides[2];		/*    number of sides on media */
    BYTE b_nhid[2];		/*    number of hidden sectors */
};



/*
 * `set_mode' parameter format
 * (22 bytes long + 10 wasted bytes)
 *
 */
#define	SETMODE	struct __setmode
SETMODE {
    BYTE smd_xxxx[3];		/* three bytes of zero */
    BYTE smd_8;			/* 0x08 */
    BYTE smd_yyyy[5];		/* five more zero bytes */
    BYTE smd_bs[3];		/* block size MSB, MIDSB, LSB (0x000200) */
    BYTE smd_1;			/* 0x01 */
    BYTE smd_cc[2];		/* cylinder count MSB LSB */
    BYTE smd_dhc;		/* data head count */
    BYTE smd_rwc[2];		/* reduced-write cylinder MSB LSB */
    BYTE smd_wpc[2];		/* write-precomp cylinder MSB LSB */
    BYTE smd_lz;		/* landing zone */
    BYTE smd_rt;		/* stepping pulse rate code */
};


/*
 * Logical to physical device mapping table.
 *
 */
#define LOGMAP struct _logmap
LOGMAP {
    int lm_physdev;		/* physical dev# (or -1) */
    int lm_partno;		/* partition number on dev */
    SECTOR lm_start;		/* physical starting block# of partition */
    SECTOR lm_siz;			/* partition size */
};
