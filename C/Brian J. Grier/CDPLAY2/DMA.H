/***************************************************************************
   Program Name     : n/a
   System Name      : Atari ST and TT
   Program Author   : Copyright (c) 1991 ICD Inc.
                        All rights reserved
                    : Modified for PURE C (Brian J. Grier)
   Language         : Personal Pascal (Pascal Plus)
   Module Name      : DMA.H (converted from DMA.I by B.Grier)
   Purpose          : This is the header file for DMA.O.  It contains
                        routines for direct hard drive access as well
                        as an interface to tables within the ICD hard
                        disk driver (ICDBOOT.PRG).
****************************************************************************/

/*
 *  This revision posted 6-6-1991.  A number of significant changes have
 *  been made.  The FSCSI and SFSCSI commands are gone.  Full scsi commands
 *  are now indicated by a bit in a FLAGS word.  SCSI ID is no longer
 *  embedded in the command frame.  SCSI ID's can now range from 0 to 15.
 *  0 to 7 will reference devices connected to the DMA port on ST and TT.
 *  8 through 15 reference devices connected to the TT internal SCSI bus.
 */


/*
 *      Structures kept within the ICDBOOT hard disk driver
 *      ---------------------------------------------------
 */

/*
        Define needed constants
*/

#define   READ_DIR         0
#define   WRITE_DIR        1
#define   FULLSCSI         2
#define   ONE_SECOND  150000l

typedef struct {
   int   recsiz ;        /* # bytes/sector */
   int   clsiz ;         /* # sectors/cluster */
   int   clsizb ;        /* # bytes/cluster */
   int   rdlen ;         /* # sectors/dir */
   int   fsiz ;          /* # sectors/FAT */
   int   fatrec ;        /* sector # of 2nd FAT */
   int   datrec ;        /* sector # of first data cluster */
   int   numcl ;         /* # data clusters */
   int   bflags ;        /* bits/FAT entry flag: 1=16 bit? */
} bios_block ;


typedef struct {
   int         units ;         /* # SCSI IDs online */
   char        id[16] ;
   char        lun[16] ;
   long        start[16] ;
   bios_block  bpb[16] ;
   char        change[16] ;
   long        sizes[16] ;
} drive_parameters ;

typedef  drive_parameters  * p_drive_parameters ;

/*
 *  typedef  barray * char ;
 *  typedef  bptr   * char ;  { generic byte pointer }
 */

typedef union {
   char     Data[16] ;
   char     buf[1] ;
} Com_Rec ;

typedef union {
   char     bytes[512] ;
   int      words[256] ;
   long     longs[128] ;
   char     buf[512] ;
} Dat_Rec ;



/*
=========================================================================
               Interface to ICDBOOT.PRG
               ------------------------

ICDBOOT: return ptr to drive parameter block

    return:
        NIL     = Driver is not present
        !NIL    = ptr to parameter block

ICDHEAD: return ptr to beginning of ICDBOOT image. This is used by internal
        ICD utilities and the exact structure is undocumented.

    return:
        NIL     = Driver is not present
        !NIL    = ptr to beginning of driver

RELOG:  Rescan all partitions and reset all internal tables

    return:
        TRUE:   = success
        FALSE:  = driver not present or bad version of ICDBOOT

COLDBOOT: reboot system
*/

/*
==========================================================================
               Calls to perform SCSI commands
               ------------------------------

DMA:    Perform SCSI command (no retries, no REQUEST on error).

    in:
      ID        = SCSI ID of device (LUN is embedded in COM_FRAME; see below)
      COM_FRAME = command bytes (packed byte array)
      DATA_FRAME= data buffer (packed byte array)
      FLAGS     = 16 bits as follows:
                     bit[0]=DMA direction.
                     bit[1]=FULL SCSI. 
                     bits[2]-[15] are RESERVED at this time.

                  DMA transfer direction bit:
                     0 = read data from drive,
                     1 = write data to drive.

                  FULL SCSI bit:
                     0 = ACSI format
                            COM_FRAME is always 6 bytes long.
                            COMMAND BYTE is byte[0]
                            LUN is top 3 bits of byte[1]
                     1 = SCSI format
                            COM_FRAME length is variable; length in byte[0]
                            COMMAND BYTE is byte[1]
                            LUN is top 3 bits of byte[2]
      BLOCKS    = number 512 byte blocks to transfer (round up
                    for non-512 byte multiples)
      TIMEOUT   = timeout value used for command completion (not
                    SCSI selection timeout - selection is fixed at
                    100 ms). 150000 is one second and is NOT dependent
                    on cpu or speed

    return:
      0         = success
      2         = indicates an error (do a REQUEST to get actual
                    error sense code)
      -1        = timeout after sending command (drive is not responding)
      -2        = timeout while sending command
      -3        = this ID skipped by ICDBOOT

XDMA:   Performs DMA with retries. No retries are performed if the
        drive timed out. Retries are performed only when DMA returns
        a code 2, in which case XDMA does a REQUEST and tries DMA again.

    in:
            same as DMA

    return:
      0         = success
      -1        = timeout after sending command (drive is not responding)
      -2        = timeout while sending command
      -3        = this ID skipped by ICDBOOT
      127       = REQUEST fails (parity error?)
      1-126     = sense code from drive
      128-252   = more sense codes (not used by most SCSI devices)

SXDMA:  Performs XDMA but is used when a non-multiple of 16 bytes needs
        to be returned from the SCSI device. (For example doing a MODESENSE).
        The ST DMA chip has a bug where the FIFO will not flush its data
        when not full in receive mode. This function compensates for this by
        performing the command 4 times without resetting the DMA chip.
        USE ON READ COMMANDS ONLY.

    in:
            same as DMA

    return:
            same as XDMA

REQUEST: Performs a REQUEST SENSE on the SCSI device.

    in:
      id        = SCSI ID of device
      lun       = LUN of device

    return:
      0         = success
      -1        = timeout after sending command (drive is not responding)
      -2        = timeout while sending command
      -3        = this ID skipped by ICDBOOT
      127       = REQUEST fails (parity error?)
      1-126     = sense code from drive
      128-252   = more sense codes (not used by most SCSI devices)

*/

extern p_drive_parameters ICDBOOT(void) ;

extern char              *ICDHEAD(void) ;

extern void /*boolean*/   RELOG(void) ;      /* rescan all partitions */

extern void               COLDBOOT(void) ;

/*
extern int pascal REQUEST(int id, int lun) ;
*/

extern int _dma(int id, char *com_frame, char *data_frame,
                 int flags, int blocks, long timeout) ;

extern int _xdma(int id, char *com_frame, char *data_frame,
                 int flags, int blocks, long timeout) ;

extern int _sxdma(int id, char *com_frame, char *data_frame,
                 int flags, int blocks, long timeout) ;

extern int       ID,LUN ;             /* global SCSI ID/LUN          */
extern Com_Rec   Command ;            /* global SCSI command buffer  */
extern Dat_Rec   SecBuf ;             /* global sector buffer        */
