/*
 * tape.c - Copyright Steve Woodford, October 1993
 *
 * Provide interface for backup/restore to SCSI tapedrive.
 * This file is supplied as an example use of the scsi_io interface.
 * It is lifted directly from my backup/restore program which I will
 * tidy up one day to release to the public ;-).
 *
 * This is not standalone, it simply provides entry points used by
 * my backup program. The functions are only of use as examples.
 * I havn't bundled the two last include files 'backup.h' & 'bdev.h'
 * since they are not needed to understand what's going on.
 */

#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/scsi_io.h>
#include "backup.h"
#include "bdev.h"

PRIVATE int      tape_fd;

PRIVATE char    *sense_msgs[] = SENSE_KEY_INFO;


PUBLIC  int
Bdev_Tape_Open(u_short drv, char *id)
{
    u_short  tid  = (*id == '\0') ? SCSI_TAPE_ID : (u_short)atoi(id);
    char    *mode = Backing_Up ? "wa" : "ra";
    Sc_Desc  sc;
    char     tmp[32];
    char     vend[20], prod[20], rev[20];

    if ( (tape_fd = scsi_open(tid, 0, mode)) < 0 ) {
        Log_Error(1, "Can't open Scsi Tape:");
        return(0);
    }

    if ( scsi_ioctl(tape_fd, SCIO_GET, (long)(&sc)) != 0 ) {
        Log_Error(1, "Can't ioctl tapedrive:");
        (void)scsi_close(tape_fd);
        tape_fd = -1;
        return(0);
    }

    if ( sc.sc_lun )
        Sprintf(tmp, "Id:%d, Lun: %d", sc.sc_id, sc.sc_lun);
    else
        Sprintf(tmp, "Id:%d", sc.sc_id);

    Strncpy(vend, sc.sc_vendor, sizeof(sc.sc_vendor));
    vend[sizeof(sc.sc_vendor)]   = '\0';
    Strncpy(prod, sc.sc_product, sizeof(sc.sc_product));
    prod[sizeof(sc.sc_product)]  = '\0';
    Strncpy(rev, sc.sc_revision, sizeof(sc.sc_revision));
    rev [sizeof(sc.sc_revision)] = '\0';

    Log_Message(MSG_INFO,
                "Scsi-Tape (%s): Vendor: %s, Product: %s, Revision: %s\n",
                tmp, vend, prod, rev);

    return(1);
}


PUBLIC  int
Bdev_Tape_Close(void)
{
    (void) scsi_close(tape_fd);

    return(0);
}


PUBLIC  long
Bdev_Tape_Read(char *buf, long bytes)
{
    long    nrd = scsi_read(tape_fd, buf, (u_long)bytes);

    if ( nrd <= 0 ) {
        Sc_Desc sc;
        u_char  key;

        if ( scsi_ioctl(tape_fd, SCIO_GET, (long)(&sc)) != 0 )
            return(-1);

        key = sc.sc_sense_key;

        if ( (key != SK_NO_SENSE) &&  (key != SK_EOF) )
            Log_Message(MSG_ERR, "Error reading tape. Code %d: %s (Errs: %d)",
                                  key, sense_msgs[key], sc.sc_sense_blk);
        return(-1);
    }
    return(nrd);
}


PUBLIC  long
Bdev_Tape_Write(char *buf, long bytes)
{
    long    nwr = scsi_write(tape_fd, buf, (u_long)bytes);

    if ( nwr <= 0 ) {
        Sc_Desc sc;
        u_char  key;

        if ( scsi_ioctl(tape_fd, SCIO_GET, (long)(&sc)) != 0 )
            return(-1);

        key = sc.sc_sense_key;

        if ( (key != SK_NO_SENSE) &&  (key != SK_EOF) )
            Log_Message(MSG_ERR, "Error writing tape. Code %d: %s (Errs: %d)",
                                  key, sense_msgs[key], sc.sc_sense_blk);
        return(-1);
    }
    return(nwr);
}
