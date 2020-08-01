/*
 * scsi_io.c - Copyright Steve Woodford, August 1993
 *
 * Implement a nice clean I/O interface to SCSI devices.
 * This code should be completely independent of the underlying
 * SCSI bus architecture. (Although currently, only support
 * for the ST's ACSI bus is provided in the low level stuff used
 * by the functions here).
 *
 * Although untested, if my theory is good, this should work
 * for CD-ROM devices ;-). Currently, it has been tested on
 * hard disks & an Archive Viper tapedrive.
 */

#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/scsi.h>
#include <sys/scsi_io.h>
#include <memory.h>
#include <strings.h>
#include <cfile.h>
#include "libscsi.h"

/*
 * Ensure version string linked in.
 */
EXTERN  char    Scsi_Lib_Version[];
PRIVATE char   *slv = &(Scsi_Lib_Version[0]);


#define _SCM_READ           0x01    /* Enable READS on device           */
#define _SCM_WRITE          0x02    /* Enable WRITES on device          */
#define _SCM_APPEND         0x04    /* Append (Implies No Rewind Open)  */
#define _SCM_REWIND_CLOSE   0x08    /* Rewind on close                  */

#define NFSLOTS             8

/*
 * Each 'scsi_open()' call results in one of these being allocated...
 */
typedef struct _dd {
    u_char          dd_id;          /* SCSI Id of target                */
    u_char          dd_lun;         /* Lun of target                    */
    u_char          dd_type;        /* Target Type                      */
    u_char          dd_flags;       /* Target flags                     */
    u_char          dd_mode;        /* Open Mode of device              */
    u_char          dd_wfm;         /* Set when filemark to be written  */
    u_char          dd_eof;         /* Set when filemark hit during read*/
    u_char          dd_eot;         /* Set when end of tape reached     */
    u_char          dd_blk_shift;   /* Convert DMA blocks to Device blks*/
    u_char          dd_sense_key;   /* Most recent sense key            */
    u_long          dd_sense_blk;   /* Block # of associated sense key  */
    u_short         dd_blk_size;    /* # of bytes per block             */
    u_long          dd_num_blocks;  /* # of blocks on device            */
    char            dd_vendor[8];   /* Vendor ID                        */
    char            dd_product[16]; /* Product ID                       */
    char            dd_revision[4]; /* Revision level                   */
    long            dd_seek_pos;    /* Current 'seek' position          */
    struct _dd     *dd_prev;        /* Link to previous in device chain */
    struct _dd     *dd_next;        /* Link to next in device chain     */
} Dev_Desc;

PRIVATE Dev_Desc   **sc_open_list    = (Dev_Desc **)0,
                    *Dd_List[]       = {0L,0L,0L,0L,0L,0L,0L,0L};
PRIVATE u_char       is_sequential[] = {0,0,0,0,0,0,0,0},
                     is_write_prot[] = {0,0,0,0,0,0,0,0},
                     is_removable [] = {0,0,0,0,0,0,0,0},
                     num_opens    [] = {0,0,0,0,0,0,0,0};
PRIVATE u_short      free_slots      = 0,
                     nslots          = 0;

PRIVATE u_short      got_cfile = 0;
PRIVATE short        cfiled;
PRIVATE short        get_cfile(void),
                     read_config_file(char *);

PRIVATE int          sc_dev_error(u_char, short, Dev_Desc *);
PRIVATE Dev_Desc    *get_dev_info(u_char);
PRIVATE short        check_numeric(char *);

#define Strncpy      (void)strncpy


/*
 * Initiate a connection to a Scsi device...
 */

PUBLIC  int
scsi_open(u_short id, u_short lun, char *mode)
{
    Dev_Desc    *dd, *sd;
    u_char       md, targ = id | (lun << 3);
    int          fd;

    /*
     * Check range of id and lun. Watch out for magic 'SCSI_TAPE_ID'
     * which implies "system's default Scsi tape drive", normally
     * picked up from the environment, or a SCSI.CNF file.
     */
    if ( ((id > MAX_SCSI_ID) && (id != SCSI_TAPE_ID)) ||
                                            (lun > MAX_LUN_ID) ) {
        errno = ENODEV;
        return(-1);
    }

    /*
     * Quick check on the 'mode' parameter...
     */
    if ( (mode == (char *)0) || (*mode == '\0') ) {
        errno = EINVAL;
        return(-1);
    }

    /*
     * Now decode 'mode' to something a bit more managable internally...
     */
    for (md = 0; *mode; mode++) {
        switch (*mode) {
          case  'r':
          case  'R':    md |= _SCM_READ;            /* Open for reading   */
                        break;
          case  'w':
          case  'W':    md |= _SCM_WRITE;           /* Open for writing   */
                        break;
          case  'a':
          case  'A':    md |= _SCM_APPEND;          /* Open for appending */
                        break;
          case  'c':
          case  'C':    md |= _SCM_REWIND_CLOSE;    /* Rewind on Close    */
                        break;

          default:      errno = EINVAL;
                        return(-1);
        }
    }

    /*
     * Read SCSI config. file
     */
    if ( !got_cfile && (get_cfile() < 0) )
        return(-1);

    /*
     * If caller wants the system's default tapedrive, go find it's ID...
     */
    if ( id == SCSI_TAPE_ID ) {
        char    *tid;
        if ( (tid = getenv("SCSI_TAPE_ID")) == (char *)0 )
            tid = (char *)config_file(CFILE_SEARCH, cfiled, "SCSI_TAPE_ID");

        if ( tid == (char *)0 ) {
            errno = ENODEV;
            return(-1);
        }

        if ( ! check_numeric(tid) ) {
            errno = EGENERIC;
            return(-1);
        }
        id = targ = (u_short)atoi(tid);
    }

    /*
     * Go find out about the device...
     */
    if ( (sd = get_dev_info(targ)) == (Dev_Desc *)0 ) {
        errno = EIO;
        return(-1);
    }

    /*
     * Only one scsi_open() on a sequential device allowed at any time.
     */
    if ( is_sequential[id] && num_opens[id] ) {
        errno = ENMFIL;
        return(-1);
    }

    /*
     * Prevent attempts to Write to Read-only media...
     */
    if ( (md & _SCM_WRITE) && is_write_prot[id] ) {
        errno = EROFS;
        return(-1);
    }

    /*
     * For sequential devices, if caller didn't specify the APPEND
     * flag, rezero the unit. For tapes, this performs a rewind.
     */
    if ( is_sequential[id] && !(md & _SCM_APPEND) ) {
        short   z = Scsi_Rezero(targ);
        if ( z != CBYTE_OK ) {
            errno = EIO;
            (void) sc_dev_error(targ, z, (Dev_Desc *)0);
            return(-1);
        }
    }

    /*
     * Grow the linked list of device descriptor blocks, if required.
     */
    if ( free_slots == 0 ) {
        if ( sc_open_list == (Dev_Desc **)0 ) {
            sc_open_list = (Dev_Desc **)malloc(NFSLOTS * sizeof(Dev_Desc *));
            if ( sc_open_list == (Dev_Desc **)0 )
                return(-1);
            Bzero((char *)sc_open_list, NFSLOTS * sizeof(Dev_Desc *));
        } else {
            char *zz = realloc((char *)sc_open_list,
                            (nslots + NFSLOTS) * sizeof(Dev_Desc *));
            if ( zz == (char *)0 )
                return(-1);
            Bzero(&(zz[nslots * sizeof(Dev_Desc *)]),
                            NFSLOTS * sizeof(Dev_Desc *));
            sc_open_list = (Dev_Desc **)zz;
        }

        nslots     += NFSLOTS;
        free_slots += NFSLOTS;
    }

    /*
     * Find a free slot in the device chain...
     */
    for (fd = 0; (fd < nslots) && (sc_open_list[fd] != (Dev_Desc *)0); fd++)
        ;

    /*
     * This should never actually happen!
     */
    if ( fd == nslots ) {
        errno = EFAULT;
        return(-1);
    }

    /*
     * Allocate space for the device descriptot block (DDB) and then
     * link it into the chain for the required target.
     */
    if ( (dd = (Dev_Desc *)malloc(sizeof(Dev_Desc))) == (Dev_Desc *)0 )
        return(-1);
    else {
        Dev_Desc    **dp = &(Dd_List[id]),
                     *op = (Dev_Desc *)0;

        Bzero((char *)dd, sizeof(Dev_Desc));

        while ( *dp ) {
            op = *dp;
            dp = &(op->dd_next);
        }

        (*dp) = dd;
        dd->dd_prev = op;
        dd->dd_next = (Dev_Desc *)0;
    }

    /*
     * Fix up details in the DDB
     */
    sc_open_list[fd]  = dd;
    free_slots       -= 1;
    num_opens[id]    += 1;

    dd->dd_id         = id;
    dd->dd_lun        = lun;
    dd->dd_mode       = md;
    dd->dd_type       = sd->dd_type;
    dd->dd_flags      = sd->dd_flags;
    dd->dd_blk_shift  = (u_char)(sd->dd_blk_size >> 10);
    dd->dd_num_blocks = sd->dd_num_blocks;
    dd->dd_blk_size   = sd->dd_blk_size;
    Strncpy(dd->dd_vendor, sd->dd_vendor, sizeof(sd->dd_vendor));
    Strncpy(dd->dd_product, sd->dd_product, sizeof(sd->dd_product));
    Strncpy(dd->dd_revision, sd->dd_revision, sizeof(sd->dd_revision));

    return(fd);
}


/*
 * Close device associated to 'fd'.
 */
PUBLIC  int
scsi_close(int fd)
{
    Dev_Desc     dd;
    u_char       targ;

    /*
     * Sanity check
     */
    if ( (fd < 0) || (fd > (nslots - free_slots)) ||
                     (sc_open_list[fd] == (Dev_Desc *)0) ) {
        errno = EBADF;
        return(-1);
    }

    /*
     * Make a local copy of the DDB for the affected device
     */
    Bcopy((char *)(sc_open_list[fd]), (char *)&dd, sizeof(dd));

    /*
     * Unlink from the chain
     */
    if ( dd.dd_prev )
        dd.dd_prev->dd_next = dd.dd_next;
    if ( dd.dd_next )
        dd.dd_next->dd_prev = dd.dd_prev;

    /*
     * Garbage collection...
     */
    (void) free( (char *)(sc_open_list[fd]) );

    sc_open_list[fd]     = (Dev_Desc *)0;
    num_opens[dd.dd_id] -= 1;
    free_slots          += 1;

    targ = dd.dd_id | (dd.dd_lun << 3);

    /*
     * If a filemark needs to be written (for sequential devs.) then
     * go ahead and do it. This could return an error....
     */
    if ( dd.dd_wfm ) {
        short   z = Scsi_File_Marks(targ, 1);
        if ( z != CBYTE_OK ) {
            errno = EIO;
            (void) sc_dev_error(targ, z, (Dev_Desc *)0);
            return(-1);
        }
    }

    /*
     * If device was open such that it should be rewound on close, do it...
     */
    if ( dd.dd_mode & _SCM_REWIND_CLOSE ) {
        if ( is_sequential[dd.dd_id] ) {
            short   z = Scsi_Rezero(targ);
            if ( z != CBYTE_OK ) {
                errno = EIO;
                (void) sc_dev_error(targ, z, (Dev_Desc *)0);
                return(-1);
            }
        }
        /*
         * Assume, (probably incorrectly!) that the caller also wanted
         * the media unloaded...
         */
        if ( is_removable[dd.dd_id] ) {
            short z = Scsi_Load_Unload(targ, 0);
            if ( z != CBYTE_OK ) {
                errno = EIO;
                (void) sc_dev_error(targ, z, (Dev_Desc *)0);
                return(-1);
            }
        }
    }

    return(0);
}


/*
 * The business end. Read 'len' bytes into buffer 'buf' from the
 * device associated with 'fd'.
 * Note that 'len' should be a multiple of the device block size; which
 * for most hard disks is 512 bytes. For tapes, this may vary, and for
 * CD-ROMS, this is probably 2048 bytes. Your best bet is to issue an
 * ioctl(fd, SCIO_GET) to find out the device's block size.
 * Argument 'len' will be rounded DOWN to be a multiple of the device
 * block size.
 * Also note that 'buf' *MUST* be on an even address boundary because
 * that's what the ST's DMA chip expects. I could have provided a work-
 * around, but the performance would have suffered too much. So I'd
 * rather insist that you keep your buffers word alligned.
 */
PUBLIC  long
scsi_read(int fd, void *buf, long len)
{
    Dev_Desc    *dd;
    u_char       id,
                 targ,
                 bshift;
    u_long       bstart;
    long         total = len;

    /*
     * Sanity check...
     */
    if ( (fd < 0) || (fd > (nslots - free_slots)) ||
                     (sc_open_list[fd] == (Dev_Desc *)0) ) {
        errno = EBADF;
        return(-1);
    }

    dd = sc_open_list[fd];

    /*
     * Reject requests to read a device opened Write-only (pretty dum)
     * or if we've already written something to the device (in the case
     * of a sequential device).
     */
    if ( !(dd->dd_mode & _SCM_READ) || dd->dd_wfm ) {
        errno = EBADRQ;
        return(-1);
    }
    id = dd->dd_id;

    /*
     * Reject requests to read a device if we've already read a file-mark.
     * In this case, the caller will either have to close then re-open the
     * device, or issue an ioctl() to reposition the media. (eg. SCIO_FSF)
     */
    if ( is_sequential[id] && (dd->dd_eof || dd->dd_eot) )
        return(0);

    /*
     * Setup some useful stuff...
     */
    targ   = id | (dd->dd_lun << 3);
    bstart = dd->dd_seek_pos;
    bshift = dd->dd_blk_shift;

    /*
     * Round down the supplied length to be a device block size multiple...
     */
    len   &= ~((long)(dd->dd_blk_size) - 1L);

    /*
     * Loop until all blocks have been written...
     */
    while ( len > 0 ) {
        u_char  dma_sects,
                dev_sects;
        short   z;
        long    bytes;

        /*
         * ST's DMA chip always works with 512 byte blocks. So we must
         * compute that number of DMA blocks to transfer this time around...
         * Note that the value '252' stems from wanting 252 * 512 to be
         * a multiple of 2048 bytes, for CD-ROMS etc.
         */
        if ( len > (252L * 512L) )
            dma_sects = 252;
        else
            dma_sects = (u_char)(len >> 9);
        /*
         * From the number of DMA blocks, work out how many physical
         * device blocks this represents. (For devices with 512 byte
         * blocks, 'bshift' is zero. For 2048 byte blocks, 'bshift'
         * is 2, etc.)
         */
        dev_sects = dma_sects >> bshift;

        /*
         * Sequential devices need a slightly different CDB...
         */
        if ( is_sequential[id] )
            z = Scsi_RdWr_Seq(SCSI_READ, targ, buf, dev_sects, dma_sects);
        else {
            u_long  bb;
            z = Scsi_RdWr_Rand(SCSI_READ, targ, buf, dev_sects,
                                                     dma_sects, bstart);
            /*
             * Get actual # of device blocks transferred...
             */
            bb               = (long)_Scsi_Dma_Len >> bshift;
            bstart          += bb;
            dd->dd_seek_pos += bb;
        }

        /*
         * Compute # of bytes transferred. Note: _Scsi_Dma_Len comes
         * from scsismd.s and is the number of DMA blocks _actually_
         * transferred.
         */
        bytes = (long)_Scsi_Dma_Len << 9;
        len  -= bytes;

        /*
         * Check completion code...
         */
        if ( z != CBYTE_OK ) {
            if ( sc_dev_error(targ, z, dd) < 0 ) {
                errno = EIO;
                return(-1);
            }
            break;
        }

        /*
         * Point to next buffer position...
         */
        buf = (void *)(&(((char *)buf)[bytes]));
    }

    /*
     * This is a bit of a bodge to prevent writes to a sequential
     * device following a read. It is probably a bad idea in the case
     * of variable record length tapedrives....
     */
    if ( is_sequential[id] && (dd->dd_mode & _SCM_WRITE) )
        dd->dd_mode &= ~(_SCM_WRITE);

    return(total - len);
}
            

/*
 * Opposite of previous routine. Same comments apply.
 */
PUBLIC  long
scsi_write(int fd, void *buf, long len)
{
    Dev_Desc    *dd;
    u_char       id,
                 targ,
                 bshift;
    u_long       bstart;
    long         total = len;

    if ( (fd < 0) || (fd > (nslots - free_slots)) ||
                     (sc_open_list[fd] == (Dev_Desc *)0) ) {
        errno = EBADF;
        return(-1);
    }

    dd = sc_open_list[fd];
    if ( ! (dd->dd_mode & _SCM_WRITE) ) {
        errno = EBADRQ;
        return(-1);
    }
    id = dd->dd_id;
    if ( is_sequential[id] && (dd->dd_eot || dd->dd_eof) )
        return(0);

    targ   = id | (dd->dd_lun << 3);
    bstart = dd->dd_seek_pos;
    bshift = dd->dd_blk_shift;
    len   &= ~((long)(dd->dd_blk_size) - 1L);

    while ( len > 0 ) {
        u_char  dma_sects,
                dev_sects;
        short   z;
        long    bytes;

        if ( len > (252L * 512L) )
            dma_sects = 252;
        else
            dma_sects = (u_char)(len >> 9);
        dev_sects = dma_sects >> bshift;

        if ( is_sequential[id] )
            z = Scsi_RdWr_Seq(SCSI_WRITE, targ, buf, dev_sects, dma_sects);
        else {
            long    bb;
            z = Scsi_RdWr_Rand(SCSI_WRITE, targ, buf, dev_sects,
                                                      dma_sects, bstart);
            bb               = (long)_Scsi_Dma_Len >> bshift;
            bstart          += bb;
            dd->dd_seek_pos += bb;
        }

        bytes = (long)_Scsi_Dma_Len << 9;
        len  -= bytes;

        if ( z != CBYTE_OK ) {
            if ( sc_dev_error(targ, z, dd) < 0 ) {
                errno = EIO;
                return(-1);
            }
            break;
        }
        buf = (void *)(&(((char *)buf)[bytes]));
    }

    if ( is_sequential[id] )
        dd->dd_wfm = 1;

    return(total - len);
}


/*
 * Seek to specific blocks on device associated with 'fd'.
 * This function has no effect for sequential devices.
 */
PUBLIC  long
scsi_lseek(int fd, long where, u_short how)
{
    Dev_Desc    *dd;

    /*
     * Sanity check...
     */
    if ( (fd < 0) || (fd > (nslots - free_slots)) ||
                     (sc_open_list[fd] == (Dev_Desc *)0) ) {
        errno = EBADF;
        return(-1);
    }

    dd = sc_open_list[fd];

    /*
     * Just return, if the device is sequential...
     */
    if ( is_sequential[dd->dd_id] )
        return(0);

    /*
     * The following code doesn't actually result in the device doing
     * anything. It simply modifies entries in the DDB.
     */
    where >>= 9;
    where >>= dd->dd_blk_shift;

    if ( how == 0 )             /* Seek from current position */
        dd->dd_seek_pos = where;
    else
    if ( how == 1 )
        dd->dd_seek_pos += where;
    else
    if ( how == 2 )
        dd->dd_seek_pos  = ((long)(dd->dd_num_blocks) - 1L) - where;

    where   = dd->dd_seek_pos << dd->dd_blk_shift;
    where <<= 9;

    return(where);
}


/*
 * Yuck. 'ioctl()' in Unix was a nice idea, which got completely overloaded.
 * Well I suppose I'll have to continue the trend since it's now more or
 * less standard...
 */
PUBLIC  int
scsi_ioctl(int fd, u_short op, long arg)
{
    Dev_Desc    *dd;
    u_char       id, targ;
    short        z;
    u_char       dir;

    /*
     * Sanity check...
     */
    if ( (fd < 0) || (fd > (nslots - free_slots)) ||
                     (sc_open_list[fd] == (Dev_Desc *)0) ) {
        errno = EBADF;
        return(-1);
    }
    dd   = sc_open_list[fd];
    id   = dd->dd_id;
    targ = id | (dd->dd_lun << 3);

    /*
     * In this code, when an operation is performed on a sequential device
     * which results in the media being repositioned, we have to check if
     * a file-mark is to be written. This results in a fair bit is repetative
     * crud which I couldn't be bothered to extract into a function...
     */
    switch( op ) {
      case  SCIO_REZERO:
      case  SCIO_OFFLIN:
            /*
             * Check for sequential...
             */
            if ( is_sequential[id] && dd->dd_wfm ) {
                if ( (z = Scsi_File_Marks(targ, 1)) != CBYTE_OK ) {
                    (void) sc_dev_error(targ, z, dd);
                    if ( dd->dd_sense_key != SK_EOT )
                        return(-1);
                }
                dd->dd_wfm = 0;
            }

            /*
             * Do the rezero.
             */
            if ( (z = Scsi_Rezero(targ)) != CBYTE_OK ) {
                (void) sc_dev_error(targ, z, dd);
                return(-1);
            }

            /*
             * Reset our 'known state'.
             */
            dd->dd_eof      = dd->dd_eot = 0;
            dd->dd_seek_pos = 0;

            /*
             * Bit more to do for OFFLINE...
             */
            if ( op == SCIO_OFFLIN ) {
                if ( ! is_removable[id] ) {
                    errno = EIO;
                    dd->dd_sense_key = SK_ILLEGAL_REQUEST;
                    return(-1);
                }
                if ( (z = Scsi_Load_Unload(targ, 0)) != CBYTE_OK ) {
                    errno = EIO;
                    (void) sc_dev_error(targ, z, (Dev_Desc *)0);
                    return(-1);
                }
            }
            break;

      case  SCIO_WEOF:
            /*
             * Only valid for sequential devices, this explicitly
             * writes a file-mark.
             */
            if ( is_sequential[id] ) {
                if ( (z = Scsi_File_Marks(targ, 1)) != CBYTE_OK ) {
                    (void) sc_dev_error(targ, z, dd);
                    if ( dd->dd_sense_key != SK_EOT )
                        return(-1);
                }
                dd->dd_eof = 1;
                dd->dd_wfm = 0;
            }
            break;

      case  SCIO_RETEN:
            /*
             * This is only valid for sequential devices.
             */
            if ( ! is_sequential[id] ) {
                errno = EIO;
                dd->dd_sense_key = SK_ILLEGAL_REQUEST;
                return(-1);
            }
            if ( dd->dd_wfm ) {
                if ( (z = Scsi_File_Marks(targ, 1)) != CBYTE_OK ) {
                    (void) sc_dev_error(targ, z, dd);
                    if ( dd->dd_sense_key != SK_EOT )
                        return(-1);
                }
                dd->dd_wfm = 0;
            }

            /*
             * On my Archive Viper, Retension is accessed via the
             * Load/Unload command. Your mileage may vary...
             */
            if ( (z = Scsi_Load_Unload(targ, 3)) != CBYTE_OK ) {
                (void) sc_dev_error(targ, z, dd);
                return(-1);
            }
            dd->dd_eof = 0;
            break;

      case  SCIO_ERASE:
            if ( ! is_sequential[id] ) {
                errno = EIO;
                dd->dd_sense_key = SK_ILLEGAL_REQUEST;
                return(-1);
            }
            if ( (z = Scsi_Erase(targ)) != CBYTE_OK ) {
                (void) sc_dev_error(targ, z, dd);
                return(-1);
            }
            dd->dd_eof = dd->dd_eot = dd->dd_wfm = 0;
            break;

      case  SCIO_EOD:
            /*
             * Skip to end of recorded data on sequential media.
             * On my Archive Viper, this very quickly finds the end
             * of the last recorded tape file, and leaves the tape
             * so that I can lay down a new file.
             */
            if ( ! is_sequential[id] ) {
                errno = EIO;
                dd->dd_sense_key = SK_ILLEGAL_REQUEST;
                return(-1);
            }
            if ( dd->dd_wfm ) {
                if ( (z = Scsi_File_Marks(targ, 1)) != CBYTE_OK ) {
                    (void) sc_dev_error(targ, z, dd);
                    if ( dd->dd_sense_key != SK_EOT )
                        return(-1);
                }
                dd->dd_wfm = 0;
            }
            if ( (z = Scsi_Space(targ, 0, 3)) != CBYTE_OK ) {
                (void) sc_dev_error(targ, z, dd);
                return(-1);
            }
            dd->dd_eof = dd->dd_eot = 0;
            break;

      /*
       * the following 4 ioctls implement FSF (Forward Skip File),
       * BSF (Backward skip file), FSR (Forward skip record) and
       * BSR (Backward skip record). One argument is expected, which
       * should be the number of filemarks/records to skip.
       */
      case  SCIO_FSF:
      case  SCIO_BSF:   dir = 1;
                        goto skippy;
      case  SCIO_FSR:
      case  SCIO_BSR:   dir = 0;
skippy:   {
            long    where = arg;
            if ( ! is_sequential[id] ) {
                errno = EIO;
                dd->dd_sense_key = SK_ILLEGAL_REQUEST;
                return(-1);
            }
            if ( dd->dd_wfm ) {
                if ( (z = Scsi_File_Marks(targ, 1)) != CBYTE_OK ) {
                    (void) sc_dev_error(targ, z, dd);
                    if ( dd->dd_sense_key != SK_EOT )
                        return(-1);
                }
                dd->dd_wfm = 0;
            }
            if ( (op == SCIO_BSF) || (op == SCIO_BSR) )
                where = -where;
            if ( (z = Scsi_Space(targ, where, dir)) != CBYTE_OK ) {
                (void) sc_dev_error(targ, z, dd);
                return(-1);
            }
            if ( op == SCIO_FSF )
                dd->dd_eof = dd->dd_eot = 0;
            else
            if ( op == SCIO_BSF )
                dd->dd_eof = 1;
            else
                dd->dd_eof = 0;
          }
            break;

      case  SCIO_GET:
            /*
             * This allows programmers to get device specific details
             * into a data structure. The argument is a pointer to a
             * structure of type 'Sc_Desc'.
             */
            {
            Sc_Desc *sc = (Sc_Desc *)arg;

            sc->sc_id        = dd->dd_id;
            sc->sc_lun       = dd->dd_lun;
            sc->sc_type      = dd->dd_type;
            sc->sc_flags     = dd->dd_flags;
            sc->sc_sense_key = dd->dd_sense_key;
            sc->sc_sense_blk = dd->dd_sense_blk;
            sc->sc_blocks    = dd->dd_num_blocks;
            sc->sc_block_sz  = dd->dd_blk_size;
            Strncpy(sc->sc_vendor, dd->dd_vendor, sizeof(sc->sc_vendor));
            Strncpy(sc->sc_product, dd->dd_product, sizeof(sc->sc_product));
            Strncpy(sc->sc_revision, dd->dd_revision, sizeof(sc->sc_revision));
            }
            break;

      default:
            errno = EBADRQ;
            return(-1);
    }

    return(0);
}


/*----------------------------------------------------------------------*/
/* Private 'service' functions....                                      */
/*----------------------------------------------------------------------*/

/*
 * Come here if a SCSI error occurs. This function sorts out what kind
 * of error it is, and writes the result in the DDB.
 */
PRIVATE int
sc_dev_error(u_char targ, short z, Dev_Desc *dd)
{
    Sc_X_Sense   xs;
    Sc_Sense    *ss = (Sc_Sense *)&xs;

    if ( z != CBYTE_OK ) {
        if ( z == CBYTE_TIMEOUT ) {
            if ( dd != (Dev_Desc *)0 ) dd->dd_sense_key = SK_TIMEOUT;
            errno = EIO;
            return(0);
        } else
        if ( z & CBYTE_BUSY ) {
            if ( dd != (Dev_Desc *)0 ) dd->dd_sense_key = SK_BUSY;
            errno = EIO;
            return(0);
        }
    }

    if ( (z = Scsi_Request_Sense(targ, &xs, sizeof(xs))) != CBYTE_OK ) {
        errno = EIO;
        return(-1);
    }

    if ( dd == (Dev_Desc *)0 )
        return(0);

    if ( xs.ss_class == 0x07 ) {
        if ( xs.ss_fm ) {
            dd->dd_sense_key = SK_EOF;
            dd->dd_eof       = 1;
        } else
        if ( xs.ss_eom ) {
            dd->dd_sense_key = SK_EOT;
            dd->dd_eot       = 1;
        } else
            dd->dd_sense_key = xs.ss_sensekey;
        dd->dd_sense_blk = soft_errors(xs);
    } else {
        dd->dd_sense_key = ss->ss_code;
        dd->dd_sense_blk = (u_long)(ss->ss_addr);
    }

    return(0);
}
    

/*
 * This function queries the specified target for information as to
 * what type of device it is, how many blocks it has, how many bytes
 * per block etc.
 */
PRIVATE Dev_Desc *
get_dev_info(u_char targ)
{
    u_char          id = targ & 0x07;
    Sc_Inquire      iq;
    Sc_Mode_Sense   ms;
    short           z;
    PRIVATE         Dev_Desc    dd;

    if ( (z = Scsi_Mode_Sense(targ, 0, &ms, sizeof(ms))) != CBYTE_OK )
        return((Dev_Desc *)0);
    if ( (z = Scsi_Inquire(targ, &iq, sizeof(iq))) != CBYTE_OK )
        return((Dev_Desc *)0);

    is_sequential[id] = (iq.iq_type == DTYPE_SEQUENTIAL);
    is_removable [id] = (iq.iq_remove == 1);
    is_write_prot[id] = (ms.ms_write_prot == 1);

    dd.dd_type   = iq.iq_type;
    dd.dd_flags |= (is_removable [id] ? SCF_IS_REMOVABLE : 0);
    dd.dd_flags |= (is_write_prot[id] ? SCF_IS_WRITABLE  : 0);

    if ( ms.ms_bdesc_len >= sizeof(ms.ms_bd) ) {
        dd.dd_num_blocks = ms.ms_blocks;
        dd.dd_blk_size   = ms.ms_blk_len;
    } else {
        dd.dd_num_blocks = 0;
        dd.dd_blk_size   = 0x200;
    }

    Strncpy(dd.dd_vendor, iq.iq_vendor, sizeof(dd.dd_vendor));
    Strncpy(dd.dd_product, iq.iq_product, sizeof(dd.dd_product));
    Strncpy(dd.dd_revision, iq.iq_revision, sizeof(dd.dd_revision));

    return(&dd);
}



PRIVATE short
check_numeric(char *str)
{
    while (*str) {
        if ( (*str < '0') || (*str++ > '9') )
            return(0);
    }
    return(1);
}


PRIVATE short
get_cfile(void)
{
    char    *s = "scsi.cnf";
    short    z = 0;

    if ( !access(s, 0) )
        z = read_config_file(s);
    else if ( (s = (char *)getenv("SCSI_CONFIG_FILE")) && *s
            && !access(s, 0) )
        z = read_config_file(s);

    return(z);
}


PRIVATE short
read_config_file(char *fn)
{
    char   *s;
    char    str[32];
    short   z;

    cfiled = (short)config_file(CFILE_OPEN, fn);

    if ( cfiled < 0 )
        return(-1);

    for (z = 0; z < (MAX_SCSI_ID + 1); z++) {
        (void)sprintf(str, "SCSI_TIMEOUT_%d", z);
        if ( (s = (char *)config_file(CFILE_SEARCH, cfiled, str)) != 0 ) {
            if ( Scsi_Set_Timeouts(z, s, 0L) != (char *)0 )
                return(-1);
        }
    }
    return(0);
}
