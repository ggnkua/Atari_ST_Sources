/*
    File: BOOTSEC.H       Atari ST HD Bootsector info.

    Feb 1989. V1.00 T.H. Schipper
*/
/*
Copyright (c) 1988 - 1991 by Ted Schipper.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation.

This software is provided AS IS with no warranties of any kind.  The author
shall have no liability with respect to the infringement of copyrights,
trade secrets or any patents by this file or any part thereof.  In no
event will the author be liable for any lost revenue or profits or
other special, indirect and consequential damages.
*/

/*
 * Partition information
 */

 struct part_info {
        char  pi_flag;          /* partition active/boot flag */
        char  pi_id[3];         /* partition id (GEM) */
        long  pi_start;         /* first (boot) sector of partition */
        long  pi_size;          /* total number of sectors of partition */
                  } ;

/*
 * values of pi_flag
 */

#define PI_INVALID   0x00       /* partition is not valid */
#define PI_ACTIVE    0x01       /* parition is valid. must be non zero */
#define PI_BOOT      0x80       /* partition is bootable */

/*
 * Hard disk boot sector information
 * Note 1: All bp entries in the structure are in INTEL format
 * Note 2: Most entries are char's. Because of memory alignment
 */

struct hd_boot {
        char   hd_bras[2];      /* Branch to boot code */
        char   hd_oem[6];       /* OEM stuff */
        char   hd_serial[3];    /* 24-bit serial number */
        char   bp_bps[2];       /* Sector size in bytes = 512 */
        char   bp_spc;          /* Cluster size in sectors = 2 */
        char   bp_res[2];       /* Reserved sectors */
        char   bp_nfats;        /* Number of FATs = 2 */
        char   bp_ndirs[2];     /* Root directory size in entries */
        char   bp_nsects[2];    /* Total sectors on medium */
        char   bp_media;        /* Medium descriptor */
        char   bp_spf[2];       /* FAT size, in sectors */
        char   bp_spt[2];       /* No. of sectors per track */
        char   bp_nsides[2];    /* No. of sides on medium */
        char   bp_nhid[2];      /* hidden sectors = ignored */
        char   hd_code[408];    /* Boot code (408 bytes) */
        short  hi_cc;           /* Number of cylinders on drive */
        char   hi_dhc;          /* Number of heads on drive */
        char   hi_unsed;
        short  hi_rwcc;         /* Reduced write current cyl of drive */
        short  hi_wpc;          /* Write precomp cyl of drive */
        char   hi_lz;           /* Landing zone of drive */
        char   hi_rt;           /* Seek rate code of drive */
        char   hi_in;           /* Interleave factor of drive */
        char   hi_spt;          /* Sectors per track on drive */
        long   hi_size;         /* Size of drive in sectors */
 struct part_info  p[4];        /* Partition information */
        long   bsl_start;       /* Start sector of bad sector list */
        long   bsl_count;       /* Number of bad sectors in list */
        short  hi_magic;        /* MAGIC checksum */
               } ;

