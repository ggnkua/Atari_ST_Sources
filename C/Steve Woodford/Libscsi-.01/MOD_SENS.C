/*
 * mod_sens.c - Copyright Steve Woodford, August 1993.
 *
 * Send 'mode sense' command to SCSI target. Return sense data.
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Mode_Sense(u_char id, u_char pc, void *mbuf, u_short len)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Normal(id) );

    sc.sc_command = CMD(id, SZ_CMD_MODE_SENSE);
    sc.sc_z[0]    = LUN(id, (pc & 0x3f));
    sc.sc_z[1]    = 0;
    sc.sc_z[2]    = 0;
    sc.sc_z[3]    = (u_char) len;
    sc.sc_link    = 0;

    return ( _Scsi_Read_Bytes( &sc, mbuf, (u_char)len ) );
}
