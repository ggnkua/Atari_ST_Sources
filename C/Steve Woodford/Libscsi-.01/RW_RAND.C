/*
 * rw_rand.c - Copyright Steve Woodford, August 1993.
 *
 * Read/Write a random access device such as a hard disk. Results are
 * undefined if used for a sequential device. NO SANITY CHECKS ARE
 * PERFORMED HERE TO ENSURE THE CORRECT DEVICE TYPE!!!
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_RdWr_Rand(Sc_RW rw, u_char id, void *buf,
               u_char dma_blks, u_char dev_blks, u_long start)
{
    Scsi_Cmd    sc;

    if ( id & 0xc0 )
        return(-1);

    if ( rw == SCSI_READ )
    {
        (void) _Scsi_Timeout( T_Read(id) );
        sc.sc_command = CMD(id, SZ_CMD_READ);
    }
    else
    if ( rw == SCSI_WRITE )
    {
        (void) _Scsi_Timeout( T_Write(id) );
        sc.sc_command = CMD(id, SZ_CMD_WRITE);
    }
    else
        return(-1);

    sc.sc_link = 0;                     /* Link is always zero      */
    sc.sc_z[3] = dev_blks;              /* Load Transfer Length     */
    sc.sc_z[2] = start & 0xff;          /* Load Start Block         */
    start    >>= 8;
    sc.sc_z[1] = start & 0xff;
    start    >>= 8;
    sc.sc_z[0] = LUN(id, (start & 0x3f));

    /*
     * Issue the READ/WRITE command...
     */
    return( _Scsi_Command( rw, &sc, buf, dma_blks ) );
}
