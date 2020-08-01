/*
 * <sys/scsi.h> - Steve Woodford, August 1993
 *
 * Declare data structures passed to and from Scsi Targets.
 * Include this if you want to use the low-level device interface.
 * The high level 'scsi_io' interface is preferable, however.
 */

#ifndef __sys_scsi_h
#define __sys_scsi_h

#define MAX_SCSI_ID             7       /* Targets 0 -> 7 allowed */
#define MAX_LUN_ID              7       /* Logical units per target */

/*
 * Completion codes returned from all Scsi driver functions.
 */
#define CBYTE_OK                0x00    /* No errors during command   */
#define CBYTE_CHECK_CONDITION   0x02    /* Target detected error      */
#define CBYTE_BUSY              0x04    /* Target is Busy             */
#define CBYTE_TIMEOUT           (-1)    /* Timeout initiating command */


/*
 * Response to 'Inquire' command
 */
typedef struct {
    u_char      iq_type;            /* Peripheral device type */
#define DTYPE_RANDOM        0x00    /* Random access device */
#define DTYPE_SEQUENTIAL    0x01    /* Sequential access device */
    /*
     * There are more device types, but my SCSI spec. is not
     * up to date enough, plus the fact that I don't own any other
     * type, so I can't test the code!
     */

    unsigned    iq_remove   :1;     /* Set indicates removable media */
    unsigned    iq_qual     :7;     /* Device type qualifier */
    u_char      iq_version;         /* ECMA / ANSI version compliance */
    unsigned    iq_resvd    :4;
    unsigned    iq_rdformat :4;     /* Response data format */
    u_char      iq_length;          /* Additional length */
    u_char      iq_vu[3];           /* Vendor unique padding */
    char        iq_vendor[8];       /* Vendor Name */
    char        iq_product[16];     /* Product Name */
    char        iq_revision[4];     /* Revision level */
} Sc_Inquire;


/*
 * Standard (Non-Extended) Scsi Sense data
 */
typedef struct {
    unsigned      ss_valid  :1;     /* Sense Address valid */
    unsigned      ss_class  :3;     /* Error Class (See Below) */
    unsigned      ss_code   :4;     /* Error Code (See Below) */
    unsigned long ss_addr   :24;    /* Address pertaining to error */
} Sc_Sense;

/*
 * Extended Scsi Sense data
 */
typedef struct {
    unsigned    ss_valid    :1;     /* Data valid */
    unsigned    ss_class    :3;     /* Error Class (See Below) */
    unsigned    ss_code     :4;     /* Error Code (See Below) */
    u_char      ss_segment;         /* Segment number (Copy command only) */
                                    /* Note: Copy cannot be implemented on */
                                    /* the ACSI bus, so this is redundant. */
    unsigned    ss_fm       :1;     /* File mark detected */
    unsigned    ss_eom      :1;     /* End of Media detected */
    unsigned    ss_ili      :1;     /* Incorrect length indicator */
    unsigned                :1;     /* Reserved */
    unsigned    ss_sensekey :4;     /* Sense Key (See below) */
    u_char      ss_info1;           /* 4 information bytes */
    u_char      ss_info2;
    u_char      ss_info3;
    u_char      ss_info4;
    u_char      ss_add_len;         /* Number of additional bytes */
    u_char      ss_info5;           /* Used for search & copy only */
    u_char      ss_info6;
    u_char      ss_info7;
    u_char      ss_info8;
    u_char      ss_sensecode;       /* Additional sense code */
    u_char      ss_info9;           /* Reserved/Error count */
    u_char      ss_additional[3];   /* Pad to 16 bytes */
} Sc_X_Sense;

/* For Archive Viper tape drive, residual transfer length */
#define residue_length(z)   ((long)( ((z).ss_info1 << 24) | \
                                     ((z).ss_info2 << 16) | \
                                     ((z).ss_info3 <<  8) | \
                                      (z).ss_info4))

#define soft_errors(z)      ((short)(((z).ss_sensecode << 8) | \
                                     ((z).ss_info9)))


/*
 * Response to Mode Sense command
 */
typedef struct {
    u_char      ms_length;          /* Additional length (should be 8) */
    u_char      ms_media_type;      /* Media Type */
    unsigned    ms_write_prot :1;   /* Write protected flag */
    unsigned    ms_info       :7;
    u_char      ms_bdesc_len;       /* Block descriptor length (bytes) */
    struct _Sc_Block_Descriptor {
        u_char   ms_density;        /* Density code (See below) */
        unsigned long ms_blocks :24;/* Number of blocks on media */
        u_char   ms_reserved;
        unsigned long ms_blk_len:24;/* Length of a block */
    } ms_bd;
} Sc_Mode_Sense;
/*
 * Easy access for Archive Viper Tapedrive values.
 */
#define ms_density              ms_bd.ms_density
#define ms_blocks               ms_bd.ms_blocks
#define ms_blk_len              ms_bd.ms_blk_len;
#define ms_buffer_mode(z)       (((z).ms_info >> 4) & 0x07)
#define ms_speed(z)             ((z).ms_info & 0x0f)

/*
 * For Archive Viper, the following define the Density codes
 */
#define DENSITY_VIPER_150       0x10    /* 150 Megabyte (18 tracks) */
#define DENSITY_VIPER_120       0x0f    /* 120 Megabyte (15 tracks) */
#define DENSITY_VIPER_60        0x05    /*  60 Megabyte ( 9 tracks) */
#define DENSITY_VIPER_AUTO      0x00    /* Auto Sensing (2150 only) */


/*
 * Enumeration for READ/WRITE for Scsi_RdWr_???() functions.
 * These MUST be used when accessing the functions.
 */
typedef enum {
    SCSI_READ = 0,
    SCSI_WRITE = 1
} Sc_RW;


/*
 * This is the timeout structure type...
 */
typedef struct {
    short   st_normal;      /* Commands that don't imply mechanical movement */
    short   st_rezero;      /* Rezero Target (Or Rewind, for tapes)          */
    short   st_read;        /* Read Data, with implied seek                  */
    short   st_write;       /* Write Data, with implied seek                 */
    short   st_seek;        /* Seek to a particular block                    */
    short   st_load;        /* For Tape Drives, Tape load time               */
    short   st_unload;      /* For Tape Drives, Tape unload time             */
    short   st_retension;   /* Time to retension tape in tape drive          */
    short   st_space;       /* Time to skip a tape file mark                 */
    short   st_erase;       /* Time to erase entire tape                     */
} Sc_Timeout;


#ifndef SK_NO_SENSE
/*
 * Scsi Sense key values (ss_sensekey in above structure)
 */
#define SK_NO_SENSE             0x00
#define SK_RECOVERABLE_ERROR    0x01    /* Recoverable error occurred */
#define SK_NOT_READY            0x02    /* Drive Not Ready error */
#define SK_MEDIA_ERROR          0x03    /* Medium Error */
#define SK_HARDWARE_ERROR       0x04    /* Hardware error */
#define SK_ILLEGAL_REQUEST      0x05    /* Illegal Request error */
#define SK_UNIT_ATTENTION       0x06    /* Unit Attention Error */
#define SK_DATA_PROTECTED       0x07    /* Usually Write Protect error */
#define SK_BLANK_CHECK          0x08    /* Blank check error */
#define SK_VENDOR_UNIQUE        0x09    /* Vendor Unique error */
#define SK_COPY_ABORTED         0x0a    /* Copy aborted error */
#define SK_ABORTED_COMMAND      0x0b    /* Aborted Command error */
#define SK_EQUAL                0x0c    /* Equal error */
#define SK_VOLUME_OVERFLOW      0x0d    /* Volume Overflow error */
#define SK_MISCOMPARE           0x0e    /* Miscompare error */
#define SK_RESERVED             0x0f
/* The following sense keys are generated only by the Scsi_Io drivers */
#define SK_TIMEOUT              0x10    /* Scsi Bus Timeout */
#define SK_EOF                  0x11    /* Filemark */
#define SK_EOT                  0x12    /* End of tape */
#define SK_BOT                  0x13    /* Beginning of tape */
#define SK_MEDIA                0x14    /* Wrong media */
#define SK_BUSY                 0x15    /* Device busy */


/*
 * Additional Sense Codes (ss_sensecode) in above structure.
 * Not every code is possible with every Sense key, and not all
 * targets implement these. To be safe, stick with the normal
 * Sense Keys.
 */
#define SC_NO_ERRR              0x00
#define SC_NO_INDEX             0x01
#define SC_NO_SEEK_COMPLETE     0x02
#define SC_WRITE_FAULT          0x03
#define SC_NOT_READY            0x04
#define SC_DRIVE_NOT_SELECTED   0x05
#define SC_TRACK_ZERO_ERROR     0x06
#define SC_MULTIPLE_DRIVES      0x07
#define SC_COMMS_FAILURE        0x08
#define SC_TRACKING_ERROR       0x09
/**/
#define SC_BAD_CRC              0x10
#define SC_UNRECOVERED_ERROR    0x11
#define SC_ID_ADDR_MARK         0x12
#define SC_DATA_ADDR_MARK       0x13
#define SC_RECORD_NOT_FOUND     0x14
#define SC_SEEK_ERROR           0x15
#define SC_DATA_SYNC_ERROR      0x16
#define SC_RETRY_READ_ERROR     0x17
#define SC_ECC_READ_ERROR       0x18
#define SC_DEFECT_LIST_ERROR    0x19
#define SC_PARAMETER_OVERRUN    0x1a
#define SC_SYNC_TRANSFER_ERROR  0x1b
#define SC_DEFECT_LIST_LOST     0x1c
#define SC_COMPARE_ERROR        0x1d
#define SC_ECC_ID_ERROR         0x1e
/**/
#define SC_INVALID_CMD_CODE     0x20
#define SC_INVALID_BLOCK_ADDR   0x21
#define SC_INVALID_FUNCTION     0x22
#define SC_VOLUME_OVERFLOW      0x23
#define SC_INVALID_CDB          0x24
#define SC_INVALID_LUN          0x25
#define SC_INVALID_PARAM_LIST   0x26
#define SC_WRITE_PROTECTED      0x27
#define SC_MEDIA_CHANGED        0x28
#define SC_DEVICE_RESET         0x29
#define SC_MODE_SELECT_CHANGED  0x2a
/**/
#define SC_INCORRECT_MEDIA      0x30
#define SC_FORMAT_FAILED        0x31
#define SC_DEFECT_LIST_FULL     0x32
/**/
#define SC_RAM_FAILURE          0x40
#define SC_ECC_FAILURE          0x41
#define SC_POWER_ON_FAILURE     0x42
#define SC_MESSAGE_REJECT_FAIL  0x43
#define SC_SCSI_FAILURE         0x44
#define SC_SELECT_TIMEOUT       0x45
#define SC_SOFT_RESET_FAILED    0x46
#define SC_SCSI_PARITY_ERROR    0x47
#define SC_INITIATOR_ERROR      0x48
#define SC_ILLEGAL_MESSAGE      0x49
#define SC_UNABLE_TO_RESELECT   0x4a
#define SC_NO_RECOVERY          0x4b
/**/
#define SC_ILLEGAL_BLOCK_DESC   0x50
#define SC_INVALID_DATA_FIELD   0x51
#define SC_BAD_DEFECT_LST_HDR   0x52
/**/
#define SC_DEVICE_RESET2        0x60
#define SC_MODE_SELECT_CHANGED2 0x61

#define MAX_SC_VALUE            0x7f


/*
 * Text representing the major 'sense key' errors
 */
#define SENSE_KEY_INFO  {                               \
    "No Sense Available",           /* 0x00 */          \
    "Soft Error",                   /* 0x01 */          \
    "Unit Not Ready",               /* 0x02 */          \
    "Media Error",                  /* 0x03 */          \
    "Hardware Error",               /* 0x04 */          \
    "Illegal Request",              /* 0x05 */          \
    "Unit Attention",               /* 0x06 */          \
    "Write Protected",              /* 0x07 */          \
    "Blank Check",                  /* 0x08 */          \
    "Vendor Unique",                /* 0x09 */          \
    "Copy Aborted",                 /* 0x0a */          \
    "Aborted Command",              /* 0x0b */          \
    "Equal Error",                  /* 0x0c */          \
    "Volume Overflow",              /* 0x0d */          \
    "Miscompare Error",             /* 0x0e */          \
    0}                              /* 0x0f */
#endif  /* SK_NO_SENSE */

/*
 * Text representing the additional 'sense code' errors.
 */
#define SENSE_CODE_INFO {                               \
    "No Additional Information",    /* 0x00 */          \
    "No Index/Sector Signal",       /* 0x01 */          \
    "No Seek Complete",             /* 0x02 */          \
    "Write Fault",                  /* 0x03 */          \
    "Drive Not Ready",              /* 0x04 */          \
    "Drive Not Selected",           /* 0x05 */          \
    "Track Zero Not Found",         /* 0x06 */          \
    "Multiple Drives Selected",     /* 0x07 */          \
    "Logical Unit Comms. Failure",  /* 0x08 */          \
    "Tracking Error",               /* 0x09 */          \
    0L, 0L, 0L, 0L, 0L, 0L,         /* 0x0a -> 0x0f */  \
    "ID CRC or ECC Error",          /* 0x10 */          \
    "Unrecoverable Read Error",     /* 0x11 */          \
    "No Address Mark in ID Field",  /* 0x12 */          \
    "No Address Mark in Data Field",/* 0x13 */          \
    "Sector Not Found",             /* 0x14 */          \
    "Seek Error",                   /* 0x15 */          \
    "Data Sync Mark Error",         /* 0x16 */          \
    "Recovered Data Error (Retry)", /* 0x17 */          \
    "Recovered Data Error (ECC)",   /* 0x18 */          \
    "Defect List Error",            /* 0x19 */          \
    "Parameter Overrun",            /* 0x1a */          \
    "Synchronous Transfer Error",   /* 0x1b */          \
    "Primary Defect List Lost",     /* 0x1c */          \
    "Compare Error",                /* 0x1d */          \
    "Recovered ID Error (ECC)",     /* 0x1e */          \
    0L,                             /* 0x1f */          \
    "Invalid Command Code",         /* 0x20 */          \
    "Illegal Block Address",        /* 0x21 */          \
    "Illegal Function for Device",  /* 0x22 */          \
    "Volume Overflow",              /* 0x23 */          \
    "Illegal Field in CDB",         /* 0x24 */          \
    "Invalid Logical Unit Number",  /* 0x25 */          \
    "Invalid Field in Param. List", /* 0x26 */          \
    "Media Write Protected",        /* 0x27 */          \
    "Media Changed",                /* 0x28 */          \
    "Device Reset Occurred",        /* 0x29 */          \
    "Mode Select Params. Changed",  /* 0x2a */          \
    0L, 0L, 0L, 0L, 0L,             /* 0x2b -> 0x2f */  \
    "Incompatible Cartridge",       /* 0x30 */          \
    "Media Format Corrupted",       /* 0x31 */          \
    "Defect List Full",             /* 0x32 */          \
    0L, 0L, 0L, 0L, 0L, 0L,         /* 0x33 -> 0x38 */  \
    0L, 0L, 0L, 0L, 0L, 0L, 0L,     /* 0x39 -> 0x3f */  \
    "RAM Failure",                  /* 0x40 */          \
    "Data Path Diagnostic Failure", /* 0x41 */          \
    "Power On Diagnostic Failure",  /* 0x42 */          \
    "Message Reject Error",         /* 0x43 */          \
    "Internal Controller Error",    /* 0x44 */          \
    "Select/Reselect Failed",       /* 0x45 */          \
    "Unsuccessful Soft Reset",      /* 0x46 */          \
    "Scsi Interface Parity Error",  /* 0x47 */          \
    "Initiator Detected Error",     /* 0x48 */          \
    "Inappropriate/Illegal Message",/* 0x49 */          \
    "Unable to Reselect",           /* 0x4a */          \
    "No Target Recovery from Error",/* 0x4b */          \
    0L, 0L, 0L, 0L,                 /* 0x4c -> 0x4f */  \
    "Illegal Block Descriptor",     /* 0x50 */          \
    "Illegal Use of Some Field (?)",/* 0x51 */          \
    "Defect List Header Unsupp.",   /* 0x52 */          \
    0L, 0L, 0L, 0L, 0L, 0L,         /* 0x53 -> 0x58 */  \
    0L, 0L, 0L, 0L, 0L, 0L, 0L,     /* 0x59 -> 0x5f */  \
    "Device Reset Occurred",        /* 0x60 */          \
    "Mode Select Params. Changed",  /* 0x61 */          \
    0L, 0L, 0L, 0L, 0L, 0L,         /* 0x62 -> 0x67 */  \
    0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, /* 0x68 -> 0x6f */  \
    0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, /* 0x70 -> 0x77 */  \
    0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L} /* 0x78 -> 0x7f */  


/*
 * Forward / prototype declarations for Scsi driver in 'libscsi.a'
 */
extern short Scsi_Test_Unit_Ready(u_char);
extern short Scsi_Rezero(u_char);
#define Scsi_Rewind Scsi_Rezero
extern short Scsi_Request_Sense(u_char, void *, u_short);
extern short Scsi_RdWr_Rand(Sc_RW, u_char, void *, u_char, u_char, u_long);
extern short Scsi_RdWr_Seq(Sc_RW, u_char, void *, u_char, u_char);
extern short Scsi_Seek_Rand(u_char, u_long);
extern short Scsi_Seek_Seq(u_char, u_long);
extern short Scsi_File_Marks(u_char, u_char);
extern short Scsi_Space(u_char, u_long, u_char);
extern short Scsi_Inquire(u_char, void *, u_short);
extern short Scsi_Erase(u_char);
extern short Scsi_Mode_Sense(u_char, u_char, void *, u_short);
extern short Scsi_Load_Unload(u_char, u_char);
extern short Scsi_Prevent_Allow(u_char, u_char);
extern char *Scsi_Set_Timeouts(u_char, char *, Sc_Timeout *);

#endif  /* __sys_scsi_h */
