/*
 * rw_seq.c - Copyright Steve Woodford, August 1993.
 *
 * Read/Write a sequential access device such as a tapedrive. Results are
 * undefined if used for a random access device. NO SANITY CHECKS ARE
 * PERFORMED HERE TO ENSURE THE CORRECT DEVICE TYPE!!!
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"


PUBLIC  short
Scsi_RdWr_Seq(Sc_RW rw, u_char id, void *buf,
                        u_char dma_blks, u_char dev_blks)
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

    sc.sc_z[0] = LUN(id, 1);            /* Validate command         */
    sc.sc_z[1] = 0;                     /* Transfer Length MSB      */
    sc.sc_z[2] = 0;                     /* Transfer Length MID      */
    sc.sc_z[3] = dev_blks;              /* # of device blocks       */
    sc.sc_link = 0;                     /* Link is always zero      */

    /*
     * Issue the READ/WRITE command...
     */
     return( _Scsi_Command( rw, &sc, buf, dma_blks ) );
}
