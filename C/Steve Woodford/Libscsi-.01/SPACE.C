/*
 * space.c - Copyright Steve Woodford, August 1993.
 *
 * Send 'space' command to SCSI target.
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Space(u_char id, u_long where, u_char how)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Space(id) );

    sc.sc_command = CMD(id, SZ_CMD_SPACE);
    sc.sc_link    = 0;
    sc.sc_z[0]    = LUN(id, (how & 0x03));
    sc.sc_z[3]    = where & 0xff;
    where       >>= 8;
    sc.sc_z[2]    = where & 0xff;
    where       >>= 8;
    sc.sc_z[1]    = where & 0xff;

    return ( _Scsi_Command( DMA_READ, &sc, 0L, 0 ) );
}
