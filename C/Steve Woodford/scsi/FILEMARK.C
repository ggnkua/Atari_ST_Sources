/*
 * filemark.c - Copyright Steve Woodford, August 1993.
 *
 * Send 'write_filemarks' command to SCSI target.
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_File_Marks(u_char id, u_char n)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    (void) _Scsi_Timeout( T_Write(id) );

    sc.sc_command = CMD(id, SZ_CMD_WRITE_FILEMARKS);
    sc.sc_z[0]    = LUN(id, 0);
    sc.sc_z[1]    = 0;
    sc.sc_z[2]    = 0;
    sc.sc_z[3]    = n;  /* 0 -> 255 filemarks */
    sc.sc_link    = 0;

    return ( _Scsi_Command( DMA_READ, &sc, 0L, 0 ) );
}
