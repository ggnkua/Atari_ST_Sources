/*
 * seek_rnd.c - Copyright Steve Woodford, August 1993.
 *
 * Seek on a random access device such as a hard disk. Results are
 * undefined if used for a sequential device. NO SANITY CHECKS ARE
 * PERFORMED HERE TO ENSURE THE CORRECT DEVICE TYPE!!!
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Seek_Rand(u_char id, u_long block)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Seek(id) );

    sc.sc_command = CMD(id, SZ_CMD_SEEK);
    sc.sc_link    = 0;
    sc.sc_z[3]    = 0;
    sc.sc_z[2]    = block & 0xff;
    block       >>= 8;
    sc.sc_z[1]    = block & 0xff;
    block       >>= 8;
    sc.sc_z[0]    = LUN(id, (block & 0x3f));

    return ( _Scsi_Command( DMA_READ, &sc, 0L, 0 ) );
}
