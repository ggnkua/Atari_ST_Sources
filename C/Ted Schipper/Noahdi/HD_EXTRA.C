/*
    File: HD_EXTRA.C     Extra Low Level Harddisk Routines.
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

                        Some EXTRA LOW-LEVEL Stuff
                       ----------------------------
 HISTORY
---------
 Nov 1988. THS. Started. Tested send_cmd routine. Added req_sense.
 Dec 1988. THS. Tested req_sense routine. Not sure it works OK. HAC bug.
 Jan 1989. THS. Added, tested wd_msel and wd_format. Also tested some
                drive errors. Controller always reports no errors.
                V0.00

***************************************************************************/

/***************************************************************************
 *
 * Function name : wd_format. Format hard disk
 * Parameters    : short  device number. 4 bits: bit 0   = drive # ( 0 or 1)
 *                                               bit 1-3 = controller # (0-7)
 *                 short  pattern_flag.  2 bits: bit 1-3 = Data pattern Flag
 *                 short  pattern.       8 bits: bit 0-7 = Data pattern
 *                 short  ileave_high.   8 bits: bit 0-7 = Interleave High
 *                 short  ileave_low.    8 bits: bit 0-7 = Interleave Low
 * Returns       : long. dma completion byte or time-out (-1)
 * Description   : Format a harddisk with given pattern and interleave.
 * Comments      : Assumes processor is in supervisor mode, and drive
 *                 specifications has been set with the wd_msel command.
 */

long wd_format(dev,pattern_flag,pattern,ileave_high,ileave_low)

 short dev;
 short pattern_flag;
 short pattern;
 short ileave_high;
 short ileave_low;

{
 long status;
 short dummy = 0;

 FLOCK = -1;                            /* disable FDC operations */
 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 DMA->DATA = (short)((dev >> 1) << 5) | (HD_FD); /* contrl# + command */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA =  (short)((dev & 1) << 5) | (pattern_flag & 6); /* drv# + pat flag */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA = pattern;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA = ileave_high;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA = ileave_low;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA = dummy;
 DMA->MODE = NO_DMA | HDC | A0;

 while ((MFP->GPIP & IO_DINT) == IO_DINT) ; /* wait (forever) for completion */
 status = (long)(DMA->DATA & 0x00FF);   /* get the status */
 hdone();                               /* restore DMA device to normal */
 return(status);                        /* return completion status */
}


/***************************************************************************
 *
 * Function name : wd_msel. Mode select. Specify drive format parameters.
 * Parameters    : short device number. 4 bits: bit 0   = drive # ( 0 or 1 )
 *                                              bit 1-3 = controller # (0-7)
 *                 short count.         size of parameter block.
 *                 char * parameterblock. pointer to parameter block.
 * Returns       : long. ASCI completion byte or time-out.
 * Description   : Send a mode select command to a controller and drive
 *                 followed by the parameter block which is send under DMA.
 * Comments      : Assumes processor is in supervisor mode, and parameter
 *                 block is not bigger than 1 sector (512 bytes).
 */

long wd_msel(dev,cnt,param)

 short dev;
 short cnt;
 char * param;

{
 long status;
 short dummy = 0;

 FLOCK = -1;                            /* disable FDC operations */
 setdma(param);                         /* setup DMA transfer address */
 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 DMA->DATA = (short)((dev >> 1) << 5) | (HD_MSEL); /* contrl# + command */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA =  (short)((dev & 1) << 5);  /* drv# */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA = dummy;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA = dummy;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->DATA = cnt;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(ERROR);
 }
 DMA->MODE = NO_DMA | SC_REG;           /* clear FIFO and */
 DMA->MODE = DMA_WR | NO_DMA | SC_REG;  /* select sector count register */
 DMA->SECT_CNT = 1;                     /* sector count */
 DMA->MODE = DMA_WR | NO_DMA | HDC | A0; /* select DMA register again */
 DMA->DATA = dummy;                     /* write last byte */
 DMA->MODE = DMA_WR;                    /* start DMA transfer */
 if (fdone() != OK)                     /* wait for DMA completion */
 {
     hdone();                           /* restore DMA device to normal */
     return(ERROR);
 }
 DMA->MODE = DMA_WR | NO_DMA | HDC | A0; /* set DMA register to normal */
 status = (long)(DMA->DATA & 0x00FF);   /* get ASCI completion byte */
 hdone();                               /* restore DMA device to normal */
 return(status);                        /* return ASCI completion byte */
}

 
/***************************************************************************
 *
 * Function name : dosahdxc. Send an ASCI command with timeout.
 * Parameters    : short device number. 4 bits: bit 0   = drive # ( 0 or 1 )
 *                                              bit 1-3 = controller # (0-7)
 *               : short * cdb. Pointer to the Command Descriptor Block.
 * Returns       : long OK    = command block send OK.
 *                      ERROR = timeout.
 * Description   : Send 6 bytes from the Command Descriptor Block to an
 *                 ASCI device.  
 * Comments      : Assumes processor is in supervisor mode. 
 */

long dodahdxc(dev,cdb)

 short dev;
 short cdb[6];

{
 short i;
 long status;

 cdb[0] |= ((dev >> 1) << 5);           /* put controller# in first byte */
 cdb[1] |= ((dev & 1) << 5);            /* put drive# in second byte */
 FLOCK = -1;                            /* disable FDC operations */
 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 for (i=0; i<6; i++)                    /* write 6 bytes to ASCI device */
 {
    DMA->DATA = cdb[i];                 /* next 5 bytes with A1 high */
    DMA->MODE = NO_DMA | HDC | A0; 
    if (i<5)                            /* not the last byte ? */
    {                                   /* use short time-out */
       if (qdone() != OK)               /* wait for ack */
       {
          hdone();                      /* restore DMA device to normal */
          return(ERROR);
       }
    }
    else                                /* last byte, use long time-out */
    {
       if (fdone() != OK)               /* wait for ack */
       {
          hdone();                      /* restore DMA device to normal */
          return(ERROR);
       }
    }
 }
 DMA->MODE = NO_DMA | HDC | A0;         /* get ASCI completion byte */
 status = (long)(DMA->DATA & 0x00FF);
 hdone();                               /* restore DMA device to normal */
 return(status);                        /* return with completion byte */
}


/***************************************************************************
 *
 * Function name : send_cmd. Send an ASCI command with timeout.
 * Parameters    : short * cdb. Pointer to the Command Descriptor Block.
 * Returns       : long OK      = command block send OK.
 *                      ERROR   = timeout.
 * Description   : Send 6 bytes from the Command Descriptor Block to an
 *                 ASCI device.  
 * Comments      : Assumes processor is in supervisor mode. 
 */

long send_cmd(cdb)

 short cdb[6];

{
 short i;
 long status;

 FLOCK = -1;                            /* disable FDC operations */
 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 for (i=0; i<6; i++)                    /* write 6 bytes to ASCI device */
 {
    DMA->DATA = cdb[i];                 /* next 5 bytes with A1 high */
    DMA->MODE = NO_DMA | HDC | A0; 
    if (i<5)                            /* not the last byte ? */
    {                                   /* use short time-out */
       if (qdone() != OK)               /* wait for ack */
       {
          hdone();                      /* restore DMA device to normal */
          return(ERROR);
       }
    }
    else                                /* last byte, use long time-out */
    {
       if (fdone() != OK)               /* wait for ack */
       {
          hdone();                      /* restore DMA device to normal */
          return(ERROR);
       }
    }
 }
 DMA->MODE = NO_DMA | HDC | A0;         /* get ASCI completion byte */
 status = (long)(DMA->DATA & 0x00FF);
 hdone();                               /* restore DMA device to normal */
 return(status);                        /* return with completion byte */
}


/***************************************************************************
 *
 * Function name : req_sense. Request sense. Return Status Error Code 
 * Parameters    : short  device number. 4 bits: bit 0   = drive # ( 0 or 1)
 *                                               bit 1-3 = controller # (0-7)
 * Returns       : long. 1st byte of Error Status Codes
 * Description   : Send a request sense command to a controller and drive,
 *                 then read the ASCI completion byte and the 4 Error Status
 *                 codes.
 * Comments      : Assumes processor is in supervisor mode.
 */

long req_sense(dev)

 short dev;

{
 short status[5], i;
 short dummy = 0;

 for (i=0; i<5; i++)
    status[i] = 0x0080;

 FLOCK = -1;                            /* disable FDC operations */
 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 DMA->DATA = (short)((dev >> 1) << 5) | (HD_RS); /* contrl# + command */
 DMA->MODE = NO_DMA | HDC | A0; 
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(1);
 }
 DMA->DATA = (short)((dev & 1) << 5);   /* drv# */
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                     /* wait for ack */
 {
    hdone();                            /* restore DMA device to normal */
    return(2);
 }
 DMA->DATA = dummy;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                    /* wait for ack */
 {
    hdone();                           /* restore DMA device to normal */
    return(3);
 }
 DMA->DATA = dummy;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                    /* wait for ack */
 {
    hdone();                           /* restore DMA device to normal */
    return(4);
 }
 DMA->DATA = 4;
 DMA->MODE = NO_DMA | HDC | A0;
 if (qdone() != OK)                    /* wait for ack */
 {
    hdone();                           /* restore DMA device to normal */
    return(5);
 }
 DMA->DATA = dummy;
 DMA->MODE = NO_DMA | HDC | A0;
 qdone();                              /* wait 100 msec */
 status[0] = (DMA->DATA & 0x00FF);     /* get completion status byte */
 qdone();                              /* wait 100 msec */
 status[1] = (DMA->DATA & 0x00FF);     /* get the four request sense bytes */
 qdone();                              /* etc. */
 status[2] = (DMA->DATA & 0x00FF);
 qdone();
 status[3] = (DMA->DATA & 0x00FF);
 qdone();
 status[4] = (DMA->DATA & 0x00FF);
/*
 printf("sense : %02x %02x %02x %02x %02x\n",
        status[0],status[1],status[2],status[3],status[4]);
*/
 hdone();                               /* restore DMA device to normal */
 return((long)status[1]);               /* return 1st Status Error Code */
                                        /* that makes sense */
}

