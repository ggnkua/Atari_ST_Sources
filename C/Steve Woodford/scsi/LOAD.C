/*
 * load.c - Copyright Steve Woodford, August 1993.
 *
 * Send 'load/unload' command to SCSI target.
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Load_Unload(u_char id, u_char flg)
{
    Scsi_Cmd    sc;
    short       to;

    if ( id & 0xc0 )
        return(-1);

    switch ( flg )
    {
      case 0:   to = T_Unload(id);
                break;
      case 1:   to = T_Load(id);
                break;
      default:  to = T_Retension(id);
                break;
    }

    (void) _Scsi_Timeout( to );

    sc.sc_command = CMD(id, SZ_CMD_LOAD_UNLOAD);
    sc.sc_z[0]    = LUN(id, 0);
    sc.sc_z[1]    = 0;
    sc.sc_z[2]    = 0;
    sc.sc_z[3]    = flg & 0x03;
    sc.sc_link    = 0;

    return ( _Scsi_Command( DMA_READ, &sc, 0L, 0 ) );
}
