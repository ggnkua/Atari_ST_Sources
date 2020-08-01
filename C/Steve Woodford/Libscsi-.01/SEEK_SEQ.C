/*
 * seek_seq.c - Copyright Steve Woodford, August 1993.
 *
 * Seek on a sequential access device such as a tapedrive. Results are
 * undefined if used for a random access device. NO SANITY CHECKS ARE
 * PERFORMED HERE TO ENSURE THE CORRECT DEVICE TYPE!!!
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_Seek_Seq(u_char id, u_long block)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Seek(id) );

    sc.sc_command = CMD(id, SZ_CMD_SEEK);
    sc.sc_link    = 0;
    sc.sc_z[0]    = LUN(id, 0);
    sc.sc_z[3]    = block & 0xff;
    block       >>= 8;
    sc.sc_z[2]    = block & 0xff;
    block       >>= 8;
    sc.sc_z[1]    = block & 0xff;

    return ( _Scsi_Command( DMA_READ, &sc, 0L, 0 ) );
}
