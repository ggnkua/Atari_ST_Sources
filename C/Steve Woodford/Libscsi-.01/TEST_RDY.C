/*
 * test_rdy.c - Copyright Steve Woodford, August 1993.
 *
 * Send 'test unit ready' command to SCSI target.
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Test_Unit_Ready(u_char id)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Normal(id) );

    sc.sc_command = CMD(id, SZ_CMD_TEST_UNIT_READY);
    sc.sc_z[0]    = LUN(id, 0);
    sc.sc_z[1]    = 0;
    sc.sc_z[2]    = 0;
    sc.sc_z[3]    = 0;
    sc.sc_link    = 0;

    return ( _Scsi_Command( DMA_READ, &sc, 0L, 0 ) );
}
