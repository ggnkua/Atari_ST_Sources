/*
    File: HDDRIVER.H       Harddisk driver stuff

    Oct 1988. V1.00 T.H. Schipper
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

#define FALSE      0
#define TRUE       1

#define OK         0L           /* OK status */
#define ERROR     -1L           /* ERROR status (timeout) */
#define ERRORL    -2L           /* ERROR status (long timeout) */
#define EWRITF    -10           /* GEMDOS write error code */
#define EREADF    -11           /* GEMDOS read error code */
#define CRITRETRY 0x00010000L   /* RETRY return code */

#define NRETRIES   3            /* number of times to retry -1 */
#define MAX_UNITS  16           /* Max number of drives attached */
#define MAXSECTORS 254          /* Max # sectors for a DMA */
#define MAXRETRIES 1

/* Timing constants */

#define LTIMEOUT   600L         /* long-timeout 3 sec */
#define STIMEOUT    20L         /* short-timeout 100 msec */

/* RWABS flags */

#define RW_FLAG       0x01      /* flag for read/write */
#define MEDIACH_FLAG  0x02      /* flag for read/write with mediachange */
#define RETRY_FLAG    0x04      /* flag for read/write with retries */
#define PHYSOP_FLAG   0x08      /* flag for physical/logical read/write */

/* ASCI Commands */

#define HD_TDR   0x00           /* Test Drive Ready */
#define HD_RS    0x03           /* Request Sense */
#define HD_FD    0x04           /* Format Drive */
#define HD_READ  0x08           /* Read */
#define HD_WRITE 0x0A           /* Write */
#define HD_SEEK  0x0B           /* Seek */
#define HD_MSEL  0x15           /* Mode Select */

typedef long (*func)();         /* pointer to function returning a long */


/* Logical Drive Info */

 struct hd_drv {
            short dev_addr;     /* physical unit ASCI address */
            long  part_start;   /* start sector logical unit */
               } ;


/* Availible functions in the HD_XXXXX.C modules */

/* HD_FRONT.C */

long  hbpb();            /* Return pointer to BPB of device */
long  hrw();             /* Read/write of a device */
long  hmediach();        /* Check if media has changed */
short check_dev();       /* Check if device belongs to this driver */

/* HD_MED.C */

long  sasi_init();       /* Initialize SASI device */
long  sasi_bpb();        /* Return pointer to device BPB */
long  sasi_rw();         /* Read/write harddisk device sectors */
void  smove();           /* Copy sectors arround in memory */
long  do_rw();           /* Read/write no more than 254 sectors */
long  sasi_mediach();    /* Check if harddisk media has changed */

/* HD_LOW.C */

long  hwrite();          /* Write to physical sectors on hard disk */
long  hread();           /* Read physical sectors from hard disk */
long  endcmd();          /* Wait for end of ASCI command and get status */
long  setss();           /* Set ASCI drive, sector # and number of sectors */
long  hdone();           /* Restore DMA device to normal */
void  setdma();          /* Setup DMA base (transfer) address */
long  qdone();           /* Wait for command byte handshake */
long  fdone();           /* Wait for operation done handshake */
long  wait_dma_cmpl();   /* Wait for DMA interrupt with timeout */

/* HD_INST.C */

void  exec_res();        /* Execute memory resident programs */
void  exec_auto_prg();   /* Start auto-folder execute process */
void  auto_prg();        /* Auto-folder search and execute program */
short pool_install();    /* Extend the OS pool buffer */
int   i_sasi1();         /* Normal entry point */
long  pread();           /* Read physical sectors from harddisk with retries */
void  ppu();             /* Partition physical unit */
short nxtdrv();          /* Set TOS logical drive, check next one */
long  getbpb();          /* Build a BPB block for a partition */
short getlhw();          /* Swop short from INTEL to Motorola format */

/* HD_EXTRA.C */

long  wd_format();       /* Format hard disk */
long  wd_msel();         /* Mode select. Specify drive format parameters */
long  dosahxc();         /* Send an ASCI command with timeout */
long  send_cmd();        /* Send an ASCI command with timeout */
long  req_sense();       /* Request sense. Return Status Error Code */

