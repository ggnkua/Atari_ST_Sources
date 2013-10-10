/*
    File: HD_FRONT.C      Front End for Harddisk Driver. AHDI Compatible.
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

#include "hddriver.h"

/***************************************************************************

                            Front End
                           -----------
 HISTORY
---------
 Feb 1989. THS. Started. Tested together with installer.
                V0.00

***************************************************************************/


/***************************************************************************

                          Global Variables

***************************************************************************/

extern struct hd_drv pun[];  /* partition info */

/* Initialize variables to get them into the driver code */

func  o_init = 0;            /* ptr to old hd_init function */
func  o_bpb = 0;             /* ptr to old hd_bpb function */
func  o_rw = 0;              /* ptr to old hd_rw function */
func  o_mediach = 0;         /* ptr to old hd_mediach function */
short puns = 0;              /* number of harddisk drives attached */


/***************************************************************************
 *
 * Function name : hbpb. Return pointer to BPB of device.
 * Parameters    : short device. Logical device number.
 * Returns       : long. pointer to logical device BPB
 * Description   : Check if the device belongs to our driver. If true,
 *                 call the sasi_bpb() function. If not our device, pass
 *                 the call to the old function.
 * Comments      : 
 */

long hbpb(dev)

 short dev;

{
 if (check_dev(dev,0) == TRUE)     /* our device */
    return(sasi_bpb(dev));         /* yes, do our function */
 else
    return((*o_bpb)(dev));         /* no, do old function */
}


/***************************************************************************
 *
 * Function name : hrw. Read/write of a device.
 * Parameters    : short rwflags. Read/write flags:
 *                                bit 0: 0 = read, 1 = write
 *                                bit 1: media change. not used yet.
 *                                bit 2: 0 = with retries, 1 = no retries
 *                                bit 3: 0 = logical, 1 = physical operation
 *                 long  buffer.  Address of buffer.
 *                 short count.   Number of sectors to read/write.
 *                 short recno.   Start sector number.
 *                 short device.  Logical device number.
 * Returns       : long. status of operation.
 * Description   : Check if the device belongs to our driver. If true,
 *                 call the sasi_rw() function. If not our device, pass
 *                 the call to the old function.
 * Comments      : 
 */

long hrw(flags,buf,count,recno,dev)

short flags;
long  buf;
short count;
short recno;
short dev;

{
 if (check_dev(dev,flags) == TRUE)               /* our device */
    return(sasi_rw(flags,buf,count,recno,dev));  /* yes, do our function */
 else
    return((*o_rw)(flags,buf,count,recno,dev));  /* no, do old function */
}


/***************************************************************************
 *
 * Function name : hmediach. Check if media has changed.
 * Parameters    : short device. Logical device number.
 * Returns       : long. status, allways 0L if ours.
 * Description   : Check if the device belongs to our driver. If true,
 *                 call the sasi_mediach() function. If not our device, pass
 *                 the call to the old function.
 * Comments      : If device belongs to our driver, no media change (0L) is
 *                 returned. We assume harddisk media does not change.
 */

long hmediach(dev)

short dev;

{
 if (check_dev(dev,0) == TRUE)    /* our device */
    return(sasi_mediach(dev));    /* yes, do our function */
 else
    return((*o_mediach)(dev));    /* no, do old function */
}


/***************************************************************************
 *
 * Function name : check_dev. Check if device belongs to this driver.
 * Parameters    : short device.  Logical device number.
 *                 short rwflags. Read/write flags.
 * Returns       : short. TRUE  = our device.
 *                        FALSE = not our device.
 * Description   : Check if the device belongs to this driver.
 * Comments      : 
 */

short check_dev(dev,flags)

 short dev;
 short flags;

{
 if ((flags & PHYSOP_FLAG))      /* physical operation */
 {
    dev -= 2;                    /* map to physical device */
    if (dev < 0)                 /* not a legal device anymore */
       return(FALSE);            /* not our drive */
    else                         /* still a legal device */
       if (dev >= puns)          /* do we have that many physical drives */
          return(FALSE);         /* no, then not ours */
       else                      /* we have that many drives */
          return(TRUE);          /* tell that it is our drive */
 }
 else                            /* logical operation */
 {
    if (pun[dev].dev_addr >= 0)  /* drive availible, -1 if not */
       return(TRUE);             /* yes, its ours */
    else
       return(FALSE);            /* no, not our drive */
 }
}

