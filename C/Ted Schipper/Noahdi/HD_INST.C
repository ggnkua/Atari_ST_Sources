/*
    File: HD_INST.C       Harddisk Driver Installer. AHDI Compatible.
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

#include "bootsec.h"
#include "hddriver.h"
#include "system.h"
#include <osbind.h>
#include <bios.h>


/***************************************************************************

                            Installer
                           -----------
 HISTORY
---------
 Feb 1989. THS. Started. Tested ppu, pread, getbpb. Made some corrections
                to bootsector structure (allignment). Added a dirty
                vector installer with hd debug messages.
 Mar 1989. THS. Added pool_install.
 Apr 1989. THS. Removed dirty vector installer. Added normal installer,
                exec_res, exec_auto stuff.
 May 1989. THS. Added some extra stuff to pread. Pread now generates an
                error when a non existing drive is selected on a
                existing controller. Can be done better.
 Jun 1989. THS. Runs nice (still from auto folder). Added assembly startup
                code to get it compatible Atari HD boot. Seems to work OK.
                V0.00

***************************************************************************/

/***************************************************************************

                          Global Variables

***************************************************************************/

extern short  puns;
extern struct bpb bpbs[];
extern struct hd_drv pun[];
extern func   o_init;
extern func   o_bpb;
extern func   o_rw;
extern func   o_mediach;
extern short  hd_boot_flg;
extern long   base_pg_addr;

/* Initialize variables to get them into the driver code */

short  clun = 0;                /* current logical unit */
short  cpun = 0;                /* current physical unit */
short  installed = 0;           /* number of installed partitions */
long   cdbit = 0;               /* current drive bit */
struct hd_boot pbuf, lbuf;      /* sector buffers */

char *copy_msg =
"----------------------------\r\n\
 ASCI/SCSI Hard Disk Driver\r\n\
 NOAHDI V0.00 Sept-26-1989\r\n\
 by T.Schipper Installed\r\n\
----------------------------\r\n";

char *env_str = "PATH=\0C:\\\0";  /* enviroment string */
char *nothing = "\0";             /* empry string */
char *auto_path = "C:\\AUTO\\*.PRG"; /* search string for Fsfirst */
char *command = "COMMAND.PRG";    /* prg to execute if comload is true */
long auto_base_pg = 0L;           /* temp storage for basepage addr */

char dta[44] = {0,0};             /* DTA buffer */
char exec_path[32] = {0,0};       /* filename build string */

char   *dvr_nld =
"Hard disk driver not loaded; hit RETURN\r\nkey to continue:\r\n";

char   *dsk_bsd = "*** WARNING ***\r\n\a\
This hard disk driver may not work with\r\n\a\\
a disk-based version of TOS; files on\r\n\a\
your hard disk may be damaged.\r\n\a\r\n\a";

char   *unf_rel = "*** WARNING ***\r\n\a\
You are using an unofficial ROM release\r\n\a\
of the operating system. This driver\r\n\a\
may not work correctly with it. Files\r\n\a\
on your hard disk may be damaged.\r\n\a\r\n\a";

struct rom_rev {
                long rel_date;   /* ROM release date */
                long pool_list;  /* free list addr of release */
               };

struct rom_rev revtable[4] = { 0x11201985L, 0x000056FAL,
                               0x02061986L, 0x000056FAL,
                               0x04241986L, 0x000056FAL,
                               0x00000000L, 0x00000000L
                            };

/***************************************************************************

                               Installer

***************************************************************************/

/***************************************************************************
 *
 * Function name : exec_res. Execute memory resident programs.
 * Parameters    : None
 * Returns       : None
 * Description   : Check physical memory every 512 bytes for a long magic
 *                 number. If magic number found, check if next long points
 *                 to magic number. If pointer to magic number is valid,
 *                 calculate the checksum of the first 256 words. If the
 *                 check is magic too, execute memory resident program at
 *                 the address specified in the 3rd long.
 * Comments      : 
 */

void exec_res()
{
 func res_prg;
 unsigned short checksum;
 short *chksum_ptr, i;
 long  *mem_ptr;

 mem_ptr = (long *)PHYSTOP;         /* get end of memory */
 while ((mem_ptr -= 0x80) > (long *)0x0400L)
 {                                  /* dec 512 bytes, untill 0x600, then */
    if (*mem_ptr == 0x12123456L)    /* magic long word at 512b boundary */
    {
       if (*(mem_ptr + 1) == (long)mem_ptr) /* pointer to magic OK */
       {
          checksum = 0;             /* clear checksum */
          chksum_ptr = (short *)mem_ptr; /* set pointer to first word */
          for (i=0; i<256; i++)     /* calc checksum from 256 words */
             checksum += *chksum_ptr++;
          if (checksum == 0x5678)   /* is the checksum magic */
          {
             res_prg = (func)*(mem_ptr + 2); /* set pointer to entry point */
             (*res_prg)();          /* execute memory resident programm */
          }
       }
    }
 }
}


/***************************************************************************
 *
 * Function name : exec_auto_prg. Start auto-folder execute process.
 * Parameters    : None
 * Returns       : None
 * Description   : Create a basepage for, and start the auto-folder program
 *                 which executes all the programs in the auto folder.
 * Comments      : Since we can't read the micro registers, the basepage
 *                 address is stored in a global variable. This variable
 *                 is used by the auto-folder executer to find its basepage.
 */

void exec_auto_prg()
{
 void auto_prg();
 long *basepage;

 basepage = (long *)Pexec(5,nothing,nothing,nothing); /* create a basepage */
 *(basepage + 2) = (long)auto_prg;            /* set process start address */
 auto_base_pg = (long)basepage;               /* save basepage address */
 Pexec(4,nothing,basepage,nothing);       /* execute auto_prg as a process */
}


/***************************************************************************
 *
 * Function name : auto_prg. Auto folder search and execute program.
 * Parameters    : None
 * Returns       : None
 * Description   : Search the auto folder for programs. Execute each found
 *                 program. Set SYSBASE variable. Check if command load
 *                 flag is set, and execute command.prg if set. Else build
 *                 a basepage and execute the AES.
 * Comments      : 
 */

void auto_prg()
{
 char *ptr_s, *ptr_d, *ptr_m;
 long  *base_page;
 func  reset;

 Dsetdrv(2);                    /* set the default drive to C: */
 Super(auto_base_pg + 0x100L);  /* supervisor mode, stack at end of basepage */
 if (Mshrink(auto_base_pg,0x100L) == 0); /* return unused memory */
 {
     Fsetdta(dta);              /* set disk transfer address */
     if (Fsfirst(auto_path,7) == 0) /* check for auto prg's */
     {
        do
        {
           ptr_s = auto_path;
           ptr_d = exec_path;
           ptr_m = &auto_path[8];
           while (ptr_s != ptr_m)  /* copy C:\AUTO\ to exec filename string */
              *ptr_d++ = *ptr_s++;
           ptr_s = &dta[30];       /* ptr to found program filename */
           while(*ptr_s != 0)      /* copy filename from dta buffer */
              *ptr_d++ = *ptr_s++;
           Pexec(0,exec_path,nothing,nothing); /* load and execute prog */
           Fsetdta(dta);
        } while (Fsnext() == 0);   /* find next auto prg */
     }
 }
 reset = (func) RESET;             /* set pointer to reset routine */
 SYSBASE = 0xFC0000L;              /* set OS entry back to ROM's */
 if (COMLOAD)                      /* command load flag set */
    Pexec(0,command,nothing,nothing); /* load and execute command.prg */
 else                              /* start AES */
 {
    base_page = (long *)Pexec(5,nothing,nothing,env_str);
                                        /* create a basepage */
    *(base_page + 2) = EXEC_OS;         /* set the AES entry point */
    Pexec(4,nothing,base_page,env_str); /* start AES */
 }
 (*reset)();                 /* should never return from AES or COMMAND, */
                             /* but if it may happen, jump to reset vector */
}


/***************************************************************************
 *
 * Function name : pool_install. Extend the OS pool buffer.
 * Parameters    : none.
 * Returns       : short. Number of bytes used to install pool.
 * Description   : Try to extend the OS pool buffer with 128 directory
 *                 control blocks. Check if the right ROM's are used.
 * Comments      : 
 */

short pool_install()
{
 long   *rel;
 long   *pool;
 struct DCB *dcb, *tmp;
 short  *dos_date;
 short  i;
 char   *txt;

 if (SYSBASE >= 0x800000L) /* ROM based OS */
 {
    i = 0;
    rel = (long *)(SYSBASE + 0x18); /* pointer to ROM release date */
    while (revtable[i].rel_date != 0x0L)
    {
          if (*rel == revtable[i].rel_date) /* compare with known releases */
          {
             pool = (long *)(revtable[i].pool_list + 16);
             dcb = (struct DCB *) dvr_nld; /* get addr of end of program */
             for (i=0; i<128; i++)         /* install 128 DCB's into pool */
             {
                dcb->size = 4;          /* DCB size in paragraphs */
                tmp = dcb + 1;          /* pointer to next DCB */
                dcb->next = &tmp->next; /* put it in current DCB */
                dcb = tmp;              /* make next current */
             }
             dcb--;                     /* point to last DCB */
             dcb->next = (struct DCB *) *pool; /* chain in old DCB's */
             return(128 * 66);          /* return bytes used for pool */
          }
          i++;
    }
    txt = unf_rel; /* assume unofficial ROM Release */
 }
 else
    txt = dsk_bsd;           /* assume disk based OS */
 dos_date = (short *)(SYSBASE + 0x1E); /* pointer to ROM dos date */
 if (*dos_date >= 0xCA1)               /* new release ? */
    return(0);               /* assume new release with no folder problems */
 Cconws(txt);                /* print message if not 'new release' */
 Cconws(dvr_nld);            /* print driver not loaded */
 while (Bconin(2) != '\r');  /* wait for a CR */
 return(0);                  /* return with zero bytes pool installed */
}


/***************************************************************************
 *
 * Function name : i_sasi1. Normal entry point.
 * Parameters    : None
 * Returns       : int. 0xE0. Should not return.
 * Description   : Scans all ASCI devices by trying to read there boot
 *                 sectors. When a PUN is found, its partitioned and the
 *                 LUN is installed. If a LUN is found, the driver vectors
 *                 are installed. If the driver was executed from the
 *                 hard disk boot program, memory resident programs are
 *                 executed and the auto folder execute process is started.
 * Comments      : 
 */

 i_sasi1()
{
 short i;
 long  size;
 long savssp;
 void exec_auto_prg();
 extern char _start[];            /* start of driver */

 if (!hd_boot_flg)                /* not called from HD boot */
    savssp = Super(0L);           /* then go into SUPERVISOR mode */

 for (i=0; i < MAX_UNITS; i++)    /* clear all physical units */
    pun[i].dev_addr = -1;

 clun = 2;                        /* set current logical unit number (C) */
 cdbit = 4;                       /* set current drive bit (C) */
 cpun = 0;                        /* set current physical unit number */
 installed = 0;                   /* nothing installed yet */
 puns = 0;                        /* no physical units found yet */

 do
 {
    if (pread(0L,1,&pbuf,cpun) != 0L) /* read boot sector of each physical unit */
       continue;                      /* next physical unit */
/*       break; */                       /* stop scanning if error */
    puns ++;                         /* found a physical unit */
    ppu();                           /* partition it */
/*    cpun ++;*/                         /* next physical unit number */
 } while (++cpun < MAX_UNITS);

 if (puns)                      /* if a drive and partitions where found */
 {
    o_bpb = (func) HDV_BPB;     /* store pointers to old functions */
    o_rw  = (func) HDV_RW;
    o_mediach = (func) HDV_MEDI;
    HDV_BPB = (long) hbpb;      /* store pointer to new functions */
    HDV_RW  = (long) hrw;
    HDV_MEDI = (long) hmediach;
    PUN_PTR  = (long) &puns;

    i = pool_install();         /* install extra folders, get used bytes */

    if (!hd_boot_flg)           /* called from HD boot */
       Super(savssp);           /* no go into USER mode again */

    size = (long)((long)dvr_nld - (long)&_start[0]) + 0x100 + i;
                                /* calc driver size */

    if (!hd_boot_flg)           /* not called from HD boot */
       Ptermres(size,0);        /* terminate and stay resident */

    Cconws(copy_msg);           /* print copy-right message */
    BOOTDEV = 2;                /* set boot device */
    Mshrink(base_pg_addr,size); /* shrink allocated memory to size bytes */
    exec_res();                 /* execute memory resident programs */
    exec_auto_prg();            /* start auto folder executer process */
 /* we should never come back here */
 }
 else
 {
    if (!hd_boot_flg)           /* not called by HD boot */
    {
       Super(savssp);           /* back to user mode */
       Pterm(-1);               /* and quit */
    }
    else                        /* called by HD boot */
    {
       Mfree(base_pg_addr);     /* free allocated memory */
       return(0xE0);            /* return highest ASCI unit number to stop */
                                /* BIOS DMA boot loop */
    }
 }
}


/***************************************************************************
 *
 * Function name : pread. Read physical sectors from harddisk with retries.
 * Parameters    : long  sector number. 21 bits address.
 *                 short sector count.   8 bits count.
 *                 long  buffer addr.   32 bits address.
 *                 short device number.  4 bits: bit 0   = drive # (0 or 1)
 *                                               bit 1-3 = controller # (0-7)
 * Returns       : long OK    = sectors are read.
 *                      ERROR = (-1) timeout, sectors (drive) does not exist.
 *                      >0    = read error on sector.
 * Description   : Try to read a physical sector(s) from harddisk. If a read
 *                 error occurded, try again. Used to test if a drive is
 *                 present on the ASCI bus.
 * Comments      : Assumes processor is in supervisor mode. A workaround
 *                 for the HAC bug has been added to generate an error when
 *                 a sector is read on a non existing drive.
 */

long pread(sect_nr,sect_cnt,buf_addr,dev)

 long  sect_nr;
 short sect_cnt;
 long  buf_addr;
 short dev;

{
 short retrycnt = NRETRIES;
 long  status;
 char  *ptr;
 short cnt;

 ptr = (char *)buf_addr;        /* get pointer to transfer buffer */
 for (cnt=0; cnt < 512; cnt++)  /* zap it */
    *ptr++ = 0;
 do
 {
    status = hread(sect_nr,sect_cnt,buf_addr,dev);  /* read sectors */
 } while ((status > 0L) && ((retrycnt --) > 0)) ;   /* try again if read error */
 if (status < 0L)                                   /* timeout, return */
    return(status);
 ptr = (char *)buf_addr;        /* get pointer to tranfer buffer */
 for (cnt=0; cnt < 512; cnt++)  /* check if still zapped */
 {
    if (*ptr++ != 0)            /* no, return */
       return(status);
 }
 return(ERROR);                 /* still zapped, return timeout error */
} 


/***************************************************************************
 *
 * Function name : ppu. Partition physical unit.
 * Parameters    : None
 * Returns       : None
 * Description   : Check a boot sector for valid partition data. When OK
 *                 build BPB's and record the PUN and start sector of each
 *                 partition. If no partition is found, assume harddisk is
 *                 one big partition.
 * Comments      : 
 */

void ppu()
{
 short i, npart;

 npart = 0;                     /* reset partition count */
 if (pbuf.hi_size)              /* HD size > 0 */
 {
/*    printf("HD size unit %d = %ld\n",cpun,pbuf.hi_size); */
    for (i=0; i < 4; i++)       /* check the 4 partitions */
    {
       if (pbuf.p[i].pi_flag)   /* active partition */
       {
/*          printf("Part %d is active: %d\n",i,pbuf.p[i].pi_flag); */
          npart ++;             /* count number of partitions on drive */
          if (pbuf.p[i].pi_id[0] == 'G') /* check for valid partition name */
          {
/*             printf("found %c\n",pbuf.p[i].pi_id[0]); */
             if (pbuf.p[i].pi_id[1] == 'E')
             {
/*                printf("found %c\n",pbuf.p[i].pi_id[1]); */
                if (pbuf.p[i].pi_id[2] == 'M')
                {
/*                   printf("found %c\n",pbuf.p[i].pi_id[2]); */
                   if (pbuf.p[i].pi_size)  /* partition size OK */
                   {
/*                      printf("Part %d size = %ld\n",i,pbuf.p[i].pi_size); */
                      if (nxtdrv() >= 0)    /* add partition to TOS, check */
                      {
/*                         printf("next Part OK\n"); */
                         if (getbpb(pbuf.p[i].pi_start) == 0L) /* build BPB */
                         {
/*                            printf("Part %d BPB build\n",i); */
                            pun[clun].dev_addr = cpun; /* set dev addr */
                            pun[clun].part_start = pbuf.p[i].pi_start; /* set start sector */
                            clun ++;
                            installed ++; /* actually installed a harddisk */
/*                            printf("partition %d found\n",clun-1);*/
/*                            Cconws("Partition found\r\n");*/
                         }
                      }
                   }
                }
             }
          }
       }
    }
 }

 if (npart)       /* did we find any partitions */
 {
    return;       /* yes, then return */
 }
 else             /* no, so build one BPB */
 {
/*    printf("No Partitions found\n");*/
/*    Cconws("No Partitions found\r\n");*/
    nxtdrv();              /* no valid partitions found, assume the whole */
    pun[clun].dev_addr = cpun;      /* thing is one big GEM disk */
    pun[clun].part_start = 0L;      /* starts at 0 */
    bpbs[clun].bp_recsiz = 512;     /* build BPB for GEM disk */
    bpbs[clun].bp_clsiz = 2;
    bpbs[clun].bp_clsizb = 1024;
    bpbs[clun].bp_rdlen = 16;
    bpbs[clun].bp_fsiz = 41;
    bpbs[clun].bp_fatrec = 42;
    bpbs[clun].bp_datrec = 99;
    bpbs[clun].bp_numcl = 10300;
    bpbs[clun].bp_flags = 1;
    clun ++;
    installed ++;
 }
}


/***************************************************************************
 *
 * Function name : nxtdrv. Set TOS logical drive, check next drive.
 * Parameters    : None
 * Returns       : short >= 0 : Next Current Logical Unit (CLUN).
 *                       ERROR: To many TOS drives installed already.
 * Description   : Check if clun is not overranged. If not, set drivebit
 *                 in TOS variable, make mask for next drivebit and return
 *                 clun.
 * Comments      : 
 */

short nxtdrv()
{
 if (clun >= MAX_UNITS)     /* have we already hit the maximum */
    return(ERROR);          /* yes, so signal error */

 DRVBITS |= cdbit;          /* tell TOS we have the drive */
 cdbit = (cdbit << 1);      /* set next drive bit */
 return(clun);
}


/***************************************************************************
 *
 * Function name : getbpb. Build a BPB block for a partition.
 * Parameters    : long partition sector number.
 * Returns       : long OK : always went OK.
 * Description   : Read the partition root sector. Build from root sector
 *                 data a TOS BPB block.
 * Comments      : 
 */

long getbpb(sectorno)

 long sectorno;

{
 short i,res_cnt,sec_cnt;

 if (pread(sectorno,1,&lbuf,cpun) == OK)  /* read partition boot sector */
 {
    bpbs[clun].bp_recsiz = getlhw(&lbuf,0x0B); /* sector size in H/L */
/*    printf("CLUN %d: recsiz = %d\n",clun,bpbs[clun].bp_recsiz); */
    bpbs[clun].bp_clsiz  = lbuf.bp_spc;        /* sectors per cluster */
/*    printf("CLUN %d: clsiz = %d\n",clun,bpbs[clun].bp_clsiz); */
    bpbs[clun].bp_clsizb = bpbs[clun].bp_recsiz * bpbs[clun].bp_clsiz; /* bytes per cluster */
/*    printf("CLUN %d: clsizb = %d\n",clun,bpbs[clun].bp_clsizb); */
    i = getlhw(&lbuf,0x11) * 32;               /* bytes needed for root dir */
    if (i % bpbs[clun].bp_recsiz)              /* part of sector needed */
       sec_cnt  = i / bpbs[clun].bp_recsiz + 1; /* sectors for dir */
    else
       sec_cnt  = i / bpbs[clun].bp_recsiz;   /* sectors for dir */
    bpbs[clun].bp_rdlen  = sec_cnt;           /* sectors for dir */
/*    printf("CLUN %d: rd_len = %d\n",clun,bpbs[clun].bp_rdlen); */
    i = getlhw(&lbuf,0x16);                   /* get FAT size in sectors */
    bpbs[clun].bp_fsiz = i;                   /* store FAT size in sectors */
/*    printf("CLUN %d: fsiz = %d\n",clun,bpbs[clun].bp_fsiz); */
    res_cnt = i;                              /* count reserved sectors */
    i = getlhw(&lbuf,0x0E);                   /* get reserved sectors */
    bpbs[clun].bp_fatrec = res_cnt + i;       /* start of 2nd FAT */
/*    printf("CLUN %d: fatrec = %d\n",clun,bpbs[clun].bp_fatrec); */
    sec_cnt += (res_cnt * 2 + i);             /* total reserved sectors */
    bpbs[clun].bp_datrec = sec_cnt;           /* set start of data sector */
/*    printf("CLUN %d: datrec = %d\n",clun,bpbs[clun].bp_datrec); */
    i = getlhw(&lbuf,0x13);                   /* get total # sectors */
    i -= sec_cnt;                             /* calc remaining # sectors */
    i /= lbuf.bp_spc;                         /* calc remaining # clusters */
    bpbs[clun].bp_numcl = i;                  /* set # data clusters */
/*    printf("CLUN %d: numcl = %d\n",clun,bpbs[clun].bp_numcl); */
    bpbs[clun].bp_flags = 1;                  /* set 16-bit FAT's */
    return(OK);
 }
}


/***************************************************************************
 *
 * Function name : getlhw. Swop short from INTEL to MOTOROLA format.
 * Parameters    : char  *start. pointer to start boot sector.
 *                 short offset.  offset into boot sector where short is.
 * Returns       : short. Motorola format.
 * Description   : Swop the 2 bytes, beginning at address + offset. return
 *                 the swopped bytes.
 * Comments      : 
 */

short getlhw(addr,offset)

 char  *addr;
 short offset;

{
 char  *ptr;
 short temp;

 ptr = (char *) &temp;                 /* get pointer to temporary short */
 ptr[1] = addr[offset];                /* swop short bytes to MOTOROLA short */
 ptr[0] = addr[offset+1];
 return(temp);                         /* return swopt short */
}

