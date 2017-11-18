/*
    File: HD_LOW.C       Low Level Harddisk Driver. AHDI Compatible.
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

#include "dma.h"
#include "mfp.h"
#include "hddriver.h"
#include "system.h"

/***************************************************************************

                            LOW-LEVEL Driver
                           ------------------
 HISTORY
---------
 Oct 1988. THS. Started. Tested read, write and timeout routines.
                V0.00
 
***************************************************************************/

/***************************************************************************
 *
 * Function name : hwrite. Write to physical sectors on hard disk.
 * Parameters    : long  sector number. 21 bits address.
 *                 short sector count.   8 bits count.
 *                 long  buffer addr    32 bits address.
 *                 short device number.  4 bits: bit 0   = drive # ( 0 or 1)
 *                                               bit 1-3 = controller # (0-7)
 * Returns       : long OK    = write went ok.
 *                      ERROR = timeout.
 * Description   : Write count sectors to ASCI device, starting at given
 *                 sector number, under DMA. Use the data starting at addr.
 * Comments      : Assumes processor is in supervisor mode, and not more
 *                 than 254 sectors written.
 */

long hwrite(sect_nr,sect_cnt,buf_addr,dev)

 long  sect_nr;
 short sect_cnt;
 long  buf_addr;
 short dev;

{
 long  status;
 short dummy = 0;

 FLOCK = -1;                            /* disable FDC operations */
 setdma(buf_addr);                      /* setup DMA transfer address */
 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 DMA->DATA = (short)((dev >> 1) << 5) | (HD_WRITE); /* cntrl + opcode */
 DMA->MODE = NO_DMA | HDC | A0;         /* A1 high again */
 if (setss(dev,sect_nr,sect_cnt) != OK) /* write bytes 1,2,3,4 to contrlr */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->MODE = NO_DMA | SC_REG;           /* clear FIFO = toggle R/W bit */
 DMA->MODE = DMA_WR | NO_DMA | SC_REG;  /* and select sector count reg */
 DMA->SECT_CNT = sect_cnt;              /* write sector cnt to DMA device */
 DMA->MODE = DMA_WR | NO_DMA | HDC | A0;/* select DMA data register again */
 DMA->DATA = dummy;                     /* write control byte ( = 0 ) */
 DMA->MODE = DMA_WR;                    /* start DMA transfer */
 status = endcmd(DMA_WR | NO_DMA | HDC | A0); /* wait for DMA completion */
 hdone();                               /* restore DMA device to normal */
 return(status);
}


/***************************************************************************
 *
 * Function name : hread. Read physical sectors from hard disk.
 * Parameters    : long  sector number. 21 bits address.
 *                 short sector count.   8 bits count.
 *                 long  buffer addr    32 bits address.
 *                 short device number.  4 bits: bit 0   = drive # ( 0 or 1)
 *                                               bit 1-3 = controller # (0-7)
 * Returns       : long OK    = read went ok.
 *                      ERROR = timeout.
 * Description   : Read count sectors from ASCI device, starting at given
 *                 sector number, under DMA. Place the data starting at addr.
 *                 
 * Comments      : Assumes processor is in supervisor mode, and not more
 *                 than 254 sectors are read.
 */

long hread(sect_nr,sect_cnt,buf_addr,dev)

 long  sect_nr;
 short sect_cnt;
 long  buf_addr;
 short dev;

{
 long  status;
 short dummy = 0;

 FLOCK = -1;                            /* disable FDC operations */
 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 DMA->DATA = (short)((dev >> 1) << 5) | (HD_READ);
 setdma(buf_addr);                      /* setup DMA transfer address */
 if (setss(dev,sect_nr,sect_cnt) != OK) /* write bytes 1,2,3,4 to contrlr */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->MODE = DMA_WR | NO_DMA | SC_REG;  /* clear FIFO = toggle R/W bit */
 DMA->MODE = NO_DMA | SC_REG;           /* and select sector count reg */
 DMA->SECT_CNT = sect_cnt;              /* write sector cnt to DMA device */
 DMA->MODE = NO_DMA | HDC | A0;         /* select DMA data register again */
 DMA->DATA = dummy;                     /* write control byte ( = 0 ) */
 DMA->MODE = dummy;                     /* start DMA transfer ( = 0 ) */
 status = endcmd(NO_DMA | HDC | A0);    /* wait for DMA completion */
 hdone();                               /* restore DMA device to normal */
 return(status);
}


/***************************************************************************
 *
 * Function name : endcmd. Wait for end of ASCI command and get status.
 * Parameters    : short Mode word to write DMA mode register.
 * Returns       : long. ASCI completion status or
 *                       ERROR when timeout occured.
 * Description   : Wait for the end of an ASCI command with a long
 *                 timeout. Write mode word to DMA mode register and
 *                 read the DMA data register. Data register should
 *                 contain the completion status byte.
 * Comments      : Assumes processor is in supervisor mode.
 */

long endcmd(mode)

 short mode;

{
 if (fdone() != OK)                   /* wait for operation done ack */
    return(ERRORL);
 DMA->MODE = mode;                    /* write mode word to mode register */
 return((long)(DMA->DATA & 0x00FF));  /* return completion byte */
}


/***************************************************************************
 *
 * Function name : setss. Set ACSI drive, sector number and number of sectors
 * Parameters    : short drive number. Disk drive number to use.
 *                 long  sector number. First sector to be transfered.
 *                 short sector count.  Number of sectors to be transfered.
 * Returns       : long. OK    = SCSI bytes ack OK.
 *                       ERROR = SCSI bytes not ack, timed out. 
 * Description   : Send 4 bytes: drv | MSB sector, MidSB sector, LSB sector,
 *                 sector count to controller. Wait after each byte for 
 *                 ACSI acknowledge.
 * Comments      : Assumes processor is in supervisor mode.
 */

long setss(drv,sect_nr,sect_cnt)

 short drv;
 long  sect_nr;
 short sect_cnt;

{
 DMA->MODE = NO_DMA | HDC | A0;          /* A0 line high again */
 if (qdone() != OK)                      /* wait for ack */
    return(ERROR);

 DMA->DATA = (short)(((drv & 1) << 5) | (((short)(sect_nr >> 16)) & 0x1F));
 DMA->MODE = NO_DMA | HDC | A0;         /* write drv | MSB sector */
 if (qdone() != OK)                     /* wait for ack */
    return(ERROR);

 DMA->DATA = (short)((short)sect_nr >> 8); /* write MidSB sector */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)
    return(ERROR);

 DMA->DATA = (short) sect_nr;           /* write LSB sector */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)
    return(ERROR);

 DMA->DATA = (short) sect_cnt;          /* write sector count */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)
    return(ERROR);

 return(OK);                            /* everything OK, tell the caller */
}


/***************************************************************************
 *
 * Function name : hdone. Restore DMA device to normal.
 * Parameters    : None.
 * Returns       : long. Status of DMA status register.
 * Description   : Restore the DMA mode register for FDC use and clear
 *                 the FDC lock variable. Return (= read) the DMA status
 *                 register.
 * Comments      : Assumes processor is in supervisor mode.
 */

long hdone()
{
 DMA->MODE = NO_DMA;        /* restore DMA mode register */
 FLOCK = 0;                 /* FDC operations may get going again */
 return((long)DMA->STATUS); /* read and return DMA status register */
}


/***************************************************************************
 *
 * Function name : setdma. Setup DMA base (transfer) address.
 * Parameters    : long address. Address to place in base register.
 * Returns       : None. (void)
 * Description   : setup the DMA base HIGH / MID / LOW registers for
 *                 a DMA operation.
 * Comments      : Assumes processor is in supervisor mode.
 */

void setdma(addr)

 long addr;

{
 DMA->ADDR[LOW]  = (char)(addr);
 DMA->ADDR[MID]  = (char)(addr >> 8);
 DMA->ADDR[HIGH] = (char)(addr >> 16);
}


/***************************************************************************
 *
 * Function name : qdone. Wait for command byte handshake.
 * Parameters    : none.
 * Returns       : long. OK    = Handshake received.
 *                       ERROR = Handshake not received, timed out.
 * Description   : Wait for a DMA handshake after a command byte has
 *                 been send. Use a short timeout.
 * Comments      : None.
 */

long qdone()
{
 return(wait_dma_cmpl(STIMEOUT));
}


/***************************************************************************
 *
 * Function name : fdone. Wait for operation done handshake.
 * Parameters    : none.
 * Returns       : long. OK    = Handshake received.
 *                       ERROR = Handshake not received, timed out.
 * Description   : Wait for a DMA handshake after an operation has
 *                 been completed. Use a long timeout.
 * Comments      : None.
 */

long fdone()
{
 return(wait_dma_cmpl(LTIMEOUT));
}


/***************************************************************************
 *
 * Function name : wait_dma_cmpl. Wait for DMA interrupt with timeout.
 * Parameters    : unsigned long timerticks to wait before timeout.
 * Returns       : long. OK    = DMA interrupt occured.
 *                       ERROR = No DMA interrupt occured, timed out.
 * Description   : Wait for a DMA interrupt (IRQ line) to occur within
 *                 timerticks * 5 milliseconds.
 * Comments      : Assumes hz_200 timerfield is being updated and 
 *                 processor is in supervisor mode.
 */

long wait_dma_cmpl(t_ticks)

 unsigned long t_ticks;

{
 unsigned long to_count;

 to_count = t_ticks + HZ_200;   /* calc value timer must get to */

 do
 {
    if ( (MFP->GPIP & IO_DINT) == 0) /* Poll DMA IRQ interrupt */
         return(OK);                 /* got interrupt, then OK */
 }  while (HZ_200 <= to_count);      /* check timer */

 return(ERROR);                      /* no interrupt, and timer expired, */
                                     /* return ERROR status.             */
}

