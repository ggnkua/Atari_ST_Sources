/*
 * prevent.c - Copyright Steve Woodford, August 1993.
 *
 * Send 'prevent/allow' command to SCSI target.
 * (Prevents/Allows media removal. Kinda like a "lock" mechanism. Not
 * all targets will (or are even able to) honour this.)
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Prevent_Allow(u_char id, u_char flg)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Normal(id) );

    sc.sc_command = CMD(id, SZ_CMD_MEDIA_REMOVAL);
    sc.sc_z[0]    = LUN(id, 0);
    sc.sc_z[1]    = 0;
    sc.sc_z[2]    = 0;
    sc.sc_z[3]    = flg & 0x01;
    sc.sc_link    = 0;

    return ( _Scsi_Command( DMA_READ, &sc, 0L, 0 ) );
}
