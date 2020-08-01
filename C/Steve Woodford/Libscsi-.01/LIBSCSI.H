/*
 * libscsi.h - Copyright Steve Woodford, August 1993.
 *
 * Library header file. Only needed by functions internal to the library.
 */

#define PRIVATE static
#define EXTERN  extern
#define PUBLIC  /* */

#define Bzero       (void)bzero
#define Bcopy       (void)bcopy

/*
 * List all the Scsi Commands we support
 */
#define SZ_CMD_TEST_UNIT_READY  0x00
#define SZ_CMD_REZERO           0x01
#define SZ_CMD_REQUEST_SENSE    0x03
#define SZ_CMD_READ             0x08
#define SZ_CMD_WRITE            0x0a
#define SZ_CMD_SEEK             0x0b
#define SZ_CMD_WRITE_FILEMARKS  0x10
#define SZ_CMD_SPACE            0x11
#define SZ_CMD_INQUIRE          0x12
#define SZ_CMD_MODE_SELECT      0x15        /**********/
#define SZ_CMD_ERASE            0x19
#define SZ_CMD_MODE_SENSE       0x1a
#define SZ_CMD_LOAD_UNLOAD      0x1b
#define SZ_CMD_MEDIA_REMOVAL    0x1e

typedef struct {
    u_char      sc_command;         /* SCSI Command code */
    u_char      sc_z[4];            /* 5 command dependent bytes */
    u_char      sc_link;            /* Final 'link' byte (usually zero) */
} Scsi_Cmd;

#define CMD(id, cmd)    ((cmd) | ((id) << 5))
#define LUN(lu, val)    ((val) | (((lu) & 0x38) << 3))

#define DMA_READ        0           /* ST reads data from SCSI target */
#define DMA_WRITE       1           /* ST writes data to SCSI target */
#ifndef MAX_SCSI_ID
#define MAX_SCSI_ID     7
#define MAX_LUN_ID      7
#endif


/*
 * These macros allow easy access to the 'PER-TARGET' timeout settings.
 * Note that Scsi_Timeouts is declared in libscsi.a and contains
 * default values suitable for a Scsi Hard Disk drive only!
 */
#define T_Normal(target)    (_Scsi_Timeouts[(target) & 0x07].st_normal)
#define T_Rezero(target)    (_Scsi_Timeouts[(target) & 0x07].st_rezero)
#define T_Read(target)      (_Scsi_Timeouts[(target) & 0x07].st_read)
#define T_Write(target)     (_Scsi_Timeouts[(target) & 0x07].st_write)
#define T_Load(target)      (_Scsi_Timeouts[(target) & 0x07].st_load)
#define T_Unload(target)    (_Scsi_Timeouts[(target) & 0x07].st_unload)
#define T_Seek(target)      (_Scsi_Timeouts[(target) & 0x07].st_seek)
#define T_Rewind(target)    (_Scsi_Timeouts[(target) & 0x07].st_rezero)
#define T_Retension(target) (_Scsi_Timeouts[(target) & 0x07].st_retension)
#define T_Space(target)     (_Scsi_Timeouts[(target) & 0x07].st_space)
#define T_Erase(target)     (_Scsi_Timeouts[(target) & 0x07].st_erase)


EXTERN  short       _Scsi_Command(u_short, Scsi_Cmd *, void *, u_char),
                    _Scsi_Read_Bytes(Scsi_Cmd *, void *, u_short),
                    _Scsi_Timeout(short);
EXTERN  u_short     _Scsi_Dma_Len;
EXTERN  Sc_Timeout  _Scsi_Timeouts[MAX_SCSI_ID + 1];
