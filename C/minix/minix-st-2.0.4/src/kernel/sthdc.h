/*
 * Atari ST hardware:
 * SH 204 - Hard Disk Drive and Controller
 */

/*
 * Commands, to be written to low 5 bits of DMA->dma_data
 */
#define	HD_TUR	0x00	/* Test Unit Ready */
#define	HD_RST	0x01	/* ReSTore; in fact a ReSeT + head to track 0 */
#define	HD_RQS	0x03	/* ReQuest Sense */
#define	HD_FDR	0x04	/* Format DRive */
#define	HD_RD	0x08	/* ReaD */
#define	HD_WR	0x0a	/* WRite */
#define	HD_SK	0x0b	/* SeeK */
#define	HD_TRAN	0x0f	/* TRANslate */
#define	HD_SET	0x10	/* Set Error Threshold */
#define	HD_RUC	0x10	/* Read/reset Usage Counter */
#define	HD_INQ	0x12	/* INQuire */
#define	HD_WDB	0x13	/* Write Data Buffer */
#define	HD_RDB	0x14	/* Read Data Buffer */
#define	HD_MSL	0x15	/* Mode SeLect */
#define	HD_MSN	0x1a	/* Mode SeNse */
#define	HD_SHP	0x1b	/* seek to SHipping Position (act. start/stop unit) */
#define	HD_RDN	0x1c	/* Receive DiagNostic */
#define	HD_SDN	0x1d	/* Send DiagNostic */

/*
 * bits in completion status byte:
 */
#define	HDC_CC	0x02	/* Check Condition */

/*
 * codes for byte 0 of status block returned by HD_RQS:
 */
#define	NOERROR		0x00
#define	NOINDEX		0x01
#define	NOSEEKCOMPLETE	0x02
#define	WRITEFAULT	0x03
#define	DRIVENOTREADY	0x04
#define	NOTRACKZERO	0x06
#define	IDECC		0x10
#define	BADDATA		0x11
#define	NOIDADDRMARK	0x12
#define	NODATAADDRMARK	0x13
#define	NORECORD	0x14
#define	BADSEEK		0x15
#define	DATANOECC	0x18
#define	DATAECC		0x19
#define	BADBLOCK	0x1a
#define	BADFORMAT	0x1c
#define	BADSELFTEST	0x1d
#define	BADOP		0x20
#define	BADBLOCKADDR	0x21
#define	BADFINALADDR	0x23
#define	BADARG		0x24
#define	BADDEVICE	0x25
#define	BADPARITY	0x26
#define	CARTCHANGED	0x28
#define	ERRORCNTOVFLW	0x2c
#define	SELFTESTFAILED	0x30

/*
 * Partition information (part of sector 0)
 */
struct pi {
  char	pi_flag;		/* active byte */
  char	pi_id[3];		/* partition id (GEM or MIX(?)) */
  long	pi_start;		/* first sector */
  long	pi_size;		/* total number of sectors */
};

/* values of pi_flag: */
#define	PI_INVALID	0x00
#define	PI_VALID	0x01
#define	PI_BOOT		0x81

#define	NPARTS		4		/* normal # partitions */

#ifndef PARTITIONING
#define PARTITIONING ATARI
#endif

/*
 * Hard disk information (sector 0) of any hard disk drive
 */
struct hi {
#if (PARTITIONING == ATARI)
# define	ADDPARTS	0 	/* additional # extended partitions */
  char		hi_gap1[0x1B6];		/* reserved */
#endif /* ATARI */

#if (PARTITIONING == SUPRA)
# define	ADDPARTS	8	/* additional # extended partitions */
  char		hi_gap1[0x156];		/* reserved */
  struct pi	hd_addpi[ADDPARTS];		/* 8 supra partition descriptors */
#endif /* SUPRA */

#if (PARTITIONING == EICKMANN )
# define	ADDPARTS	4	/* additional # extended partitions */
  char		hi_gap1[0x180];		/* reserved			*/
  int		hi_defpart;		/* def. partition (auto-folder)	*/
  struct pi	hd_addpi[ADDPARTS];	/* 4 partition descriptors	*/
  int		hi_reserved;
  int		hi_maxsubdirs;		/* not used by MINIX		*/
#endif /* EICKMANN */

#if (PARTITIONING == CBHD)
# define	ADDPARTS	8 	/* additional # extended partitions */
  char		hi_gap1[0x151];		/* reserved			*/
  char		hi_version;		/* version of rootsector format */
  char		hi_lable[4];		/* == "CBHD"			*/
  struct pi	hd_addpi[ADDPARTS];	/* 8 partition descriptors	*/
#endif /* CBHD */

  short		hi_cc;		/* number of cylinders */
  char		hi_dhc;		/* number of heads */
  char		hi_gap2[1];	/* reserved */
  short		hi_rwcc;	/* reduced write current cyl */
  short		hi_wpc;		/* write-precompensation cyl */
  char		hi_lz;		/* landing zone */
  char		hi_rt;		/* seek rate code */
  char		hi_in;		/* interleave factor */
  char		hi_spt;		/* sectors per track */
  long		hd_size;	/* size of disk in sectors */
  struct pi	hd_pi[NPARTS];	/* 4 partition descriptors */
  long		bsl_start;	/* start of bad sector table */
  long		bsl_count;	/* number of bad sectors */
  short		hi_magic;	/* reserved for checksum */
};
