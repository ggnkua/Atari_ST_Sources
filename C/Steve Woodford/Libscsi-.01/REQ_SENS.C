/*
 * req_sens.c - Copyright Steve Woodford, August 1993.
 *
 * Send 'request sense' command to SCSI target. Returns sense data.
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Request_Sense(u_char id, void *sbuf, u_short len)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Normal(id) );

    sc.sc_command = CMD(id, SZ_CMD_REQUEST_SENSE);
    sc.sc_z[0]    = LUN(id, 0);
    sc.sc_z[1]    = 0;
    sc.sc_z[2]    = 0;
    sc.sc_z[3]    = (u_char) len;
    sc.sc_link    = 0;

    return ( _Scsi_Read_Bytes( &sc, sbuf, (u_char)len ) );
}
