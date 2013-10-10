/*
    File: HD_MED.C       Medium Level Harddisk Driver. AHDI Compatible.
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

#include "bios.h"
#include "hddriver.h"
#include "system.h"

/***************************************************************************

                            MEDIUM-LEVEL Driver
                           ---------------------
 HISTORY
---------
 Feb 1989. THS. Started. Tested read/write routines.
                V0.00

***************************************************************************/

/***************************************************************************

                          Global Variables

***************************************************************************/

/* Initialize variables to get them into the driver code */

struct bpb bpbs[MAX_UNITS] = {0,0};        /* BPB Block for each device */
struct hd_drv pun[MAX_UNITS] = {0,0};      /* PUN table for each device */
  
/***************************************************************************
 *
 * Function name : sasi_init. Initialize SASI device.
 * Parameters    : none.
 * Returns       : long OK    = initialize went OK
 *                      ERROR = initialize error or no drive present
 * Description   : Initialize a ASCI (SCSI) controller.
 * Comments      : Not used. Only needed for controllers who's parameters
 *                 must be set.
 */

long sasi_init()
{
 return(OK);
}


/***************************************************************************
 *
 * Function name : sasi_bpb. Return pointer to device BPB.
 * Parameters    : short device. Logical device number.
 * Returns       : long. Pointer to device BPB.
 * Description   : Return the pointer to requested device's BPB.
 * Comments      : 
 */

long sasi_bpb(dev)

short dev;

{
 return((long) &bpbs[dev]);  /* addr of first struct element */
}


/***************************************************************************
 *
 * Function name : ahdi_rw. Read/write harddisk device sectors
 * Parameters    : short rwflags. Read/write flags:
 *                                bit 0: 0 = read, 1 = write
 *                                bit 1: media change. not used yet.
 *                                bit 2: 0 = with retries, 1 = no retries
 *                                bit 3: 0 = logical, 1 = physical operation
 *                 long  buffer.  Address of buffer.
 *                 short count.   Number of sectors to read/write.
 *                 short recno.   Start sector number.
 *                 short device.  Logical device number.
 * Returns       : long. OK      = read/write wend well
 *                       EREADF  = read error
 *                       EWRITEF = write error
 * Description   : Read/write sectors from/to a harddisk. If more than
 *                 254 sectors are requested, do multiple 254 sector
 *                 tranfers. If buffer is on an odd address, use the BIOS
 *                 2 sector buffer for the transfer.
 * Comments      : 
 */

long sasi_rw(flags,buf,count,recno,dev)

 short flags;
 long  buf;
 short count;
 short recno;
 short dev;

{
 short sec_cnt;
 long  buf_ptr;
 long  status;

 do
 {
    if (count == 0)       /* is there anything to be done */
       return(OK);        /* no, so done with no errors */

    sec_cnt = count;
    buf_ptr = buf;

    if (count > MAXSECTORS) /* more than one DMA full */
       sec_cnt = MAXSECTORS; /* yes, so only do this many this time */

    if (buf & 0x0001)        /* buffer at an odd boundry */
    {
       if (count > 2)        /* more than 2 sectors */
          sec_cnt = 2;       /* set sector to size of BIOS buffer */
       buf_ptr = DSKBUFP;    /* use BIOS buffer for this transfer */

       if (flags & RW_FLAG)  /* is this a write */
          smove(buf_ptr,buf,sec_cnt); /* copy sectors to BIOS buffer */
    }

    if ((status = do_rw(flags,buf_ptr,sec_cnt,recno,dev)) != OK) /* read/write went wrong */
       return(status);                   /* yes, so give up */

    if (buf & 0x0001)        /* buffer at an odd boundry */
    {
       if ((flags & RW_FLAG) == 0) /* and a read */
          smove(buf,buf_ptr,sec_cnt); /* copy sectors to destination */
    }

    buf += (long)((long)sec_cnt * 512L);  /* ajust buffer start */
    recno += sec_cnt;        /* ajust start sector */
    count -= sec_cnt;        /* ajust sectors to be done */
 } while (count > 0);        /* do again if sectors left */
 return(OK);                 /* all done with no errors */
}


/***************************************************************************
 *
 * Function name : smove. Copy sectors arround in memory.
 * Parameters    : char *dest. Pointer to destination address.
 *                 char *src.  Pointer to source address.
 *                 short count. Number of sectors to copy.
 * Returns       : none.
 * Description   : Copy sectors from source to destination. Calculate the
 *                 number of bytes to copy by multiplying by 512.
 * Comments      : 
 */

void smove(dest,src,count)

 char  *dest;
 char  *src;
 short count;

{
  /* calculate bytes to be moved, 1024 tops */

 for (count *= 512; count > 0; count--) /* calc bytes to move, and do it */
     *dest++ = *src++;                  /* copy a byte */
}


/***************************************************************************
 *
 * Function name : do_rw. Read/write no more than 254 sectors.
 * Parameters    : short rwflags. Read/write flags:
 *                                bit 0: 0 = read, 1 = write
 *                                bit 1: media change. not used yet.
 *                                bit 2: 0 = with retries, 1 = no retries
 *                                bit 3: 0 = logical, 1 = physical operation
 *                 long  buffer.  Address of buffer.
 *                 short count.   Number of sectors to read/write.
 *                 short recno.   Start sector number.
 *                 short device.  Logical device number.
 * Returns       : long. OK      = read/write wend well
 *                       EREADF  = read error
 *                       EWRITEF = write error
 * Description   : Reda/write no more than 254 sectors with retries. If
 *                 an error occurs, call the critical error handler.
 * Comments      : 
 */

long do_rw(flags,buf,count,recno,dev)

 short flags;
 long  buf;
 short count;
 short recno;
 short dev;

{
 short retries;
 short pdev;
 long  status;
 long  sec_no;
 long  hz_200_sync;
 func  evt_critic;

 do
 {
    retries = MAXRETRIES;            /* setup retry counter */
    if (flags & RETRY_FLAG)          /* retries disabled ? */
       retries = 0;                  /* yes, retry counter to zero */

    do
    {                                /* first sync with 200 Hz timer. WHY ? */
       hz_200_sync = HZ_200;         /* get 200 Hz ticker value */
       while (hz_200_sync == HZ_200) ; /* wait for 1 tick to elapse */
       hz_200_sync = HZ_200 + 1;     /* ajust variable to ticker + 1. WHY ? */

       if (flags & PHYSOP_FLAG)      /* physical unit operation */
       {
          pdev = dev - 2;   /* ??????? yes, do logical to physical mapping */
          sec_no = (long) recno;
       }
       else                          /* logical operation */
       {
          pdev = pun[dev].dev_addr;  /* get partitions ASCI address */
          sec_no = pun[dev].part_start + (long) recno; /* calc physical sector # */
       }

       if (flags & RW_FLAG)          /* read or write ? */
          status = hwrite(sec_no,count,buf,pdev); /* write, do DMA write */
       else
          status = hread(sec_no,count,buf,pdev);  /* read, do DMA read */

       if (status == OK)      /* errors */
          return(status);     /* no, signal success */

    } while (--retries > 0);  /* drop retry counter and retry */

    status = EREADF;          /* assume READ error */
    if (flags & RW_FLAG)      /* was it a write ? */
       status = EWRITF;       /* yes, set WRITE error */

    if (flags & RETRY_FLAG)   /* retries disabled ? */
       return(status);        /* yes, signal error, no error handler */

    evt_critic = (func) EVT_CRITIC; /* set pointer to error handler */
    status = (*evt_critic)((short)status,pdev);   /* call error handler */
 } while (status == CRITRETRY); /* retry if magic RETRY code */
 return(status);
}


/***************************************************************************
 *
 * Function name : sasi_mediach. Check if harddisk media has changed.
 * Parameters    : short device. Logical device number.
 * Returns       : long. status. Allways 0L.
 * Description   : Check if harddisk media has changed. It never does.
 * Comments      : 
 */

long sasi_mediach(dev)

 short dev;

{
 return(OK);
}

