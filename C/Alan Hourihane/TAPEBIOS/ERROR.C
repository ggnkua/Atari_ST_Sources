/* Error reporting routines through Request Sense call  */
/* This code is part of the TapeBIOS distribution       */
/* Written by Alan Hourihane 1992                       */

#include <errno.h>
#include "tapebind.h"

int 
Request_Sense()
{
        int status;
        char sense[512];
    
        bzero(sense, 32L);
        status = Trsense(&sense[0], 64L);
        switch ((int)(sense[2]) & 0xFF) {
        
        case -1:                                /* General Error */
                        return(-ERROR);         /* return General Error (-1) */
        case 2:                                 /* Tape drive not ready */
                        return(-EDRVNR);        /* return Drive not ready */
        case 3:                                 /* Medium Error */
                        return(-E_CRC);         /* return CRC error */
        case 4:                                 /* Hardware Error */
                        return(-ERROR);         /* return General Error */
        case 5:                                 /* Illegal Request */
                        return(-EBADRQ);        /* return Bad Request */
        case 6:                                 /* Unit Attention */
                        return(-E_CHNG);        /* return Diskette was changed */
        case 7:                                 /* Data Protect */
                        return(-EROFS);         /* return Diskette write protected */
        case 8:                                 /* Blank Check */
                        return(-E_SEEK);        /* return Seek error, track not found */
        case 9:                                 /* Vendor Unique */
                        return(-ERROR);         /* return General Error */
        case 10:                                /* Copy aborted */
                        return(-ERROR);         /* return General Error */
        case 11:                                /* Aborted Command */
                        return(-ERROR);         /* return General Error */
        case 12:                                /* Equal */
                        return(-ERROR);         /* return General Error */
        case 13:                                /* Volume Overflow */
                        return(-EPAPER);        /* return (No paper) */
        case 14:                                /* Miscompare */
                        return(-ERROR);         /* return General Error */
        case 15:                                /* Reserved (shouldn't happen) */
                        return(-ERROR);         /* return General Error  */
        default:                                /* If not known */
                        return(-ERROR);         /* return General Error */
        }
}
