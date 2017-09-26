/*----------------------------------------------------------------------------------------
  gemdos.h, part of TOS Linker for CodeWarrior

  Gemdos system calls for TOS
  
  21.10.1998 by Manfred Lippert
  based on mgx_dos.h from Andreas Kromke

  last change: 30.11.2000

  Don't edit this file.

  If you have to make any changes on this file, please contact:
  mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __TOS_gemdos_h_
#define __TOS_gemdos_h_

#ifndef __PORTAB__
#include <portab.h>
#endif

#if !TARGET_TOS
  #error Gemdos-Lib used in Non-TOS Project
#endif
#if !MC68K
  #error Gemdos-Lib used in Non-68K Project
#endif

/* GEMDOS- Device- Handles */

#define HDL_CON -1
#define HDL_AUX -2
#define HDL_PRN -3
#define HDL_NUL -4       /* KAOS extension */

/* GEMDOS- Standard- Handles */

#define STDIN  0
#define STDOUT   1
#define STDAUX   2
#define STDPRN   3
#define STDERR   4
#define STDXTRA 5

/* File Attributes */

#define F_RDONLY  0x01
#define F_HIDDEN  0x02
#define F_SYSTEM  0x04
#define F_VOLUME  0x08
#define F_SUBDIR  0x10
#define F_ARCHIVE 0x20

/* BIOS level errors */

#define E_OK    0L  /* OK, no error       */
#define ERROR  -1L  /* basic, fundamental error */
#define EDRVNR   -2L  /* drive not ready      */
#define EUNCMD   -3L  /* unknown command      */
#define E_CRC  -4L  /* CRC error        */
#define EBADRQ   -5L  /* bad request        */
#define E_SEEK   -6L  /* seek error       */
#define EMEDIA   -7L  /* unknown media      */
#define ESECNF   -8L  /* sector not found     */
#define EPAPER   -9L  /* no paper         */
#define EWRITF  -10L  /* write fault        */
#define EREADF  -11L  /* read fault       */
#define EGENRL  -12L  /* general error      */
#define EWRPRO  -13L  /* write protect      */
#define E_CHNG  -14L  /* media change       */
#define EUNDEV  -15L  /* unknown device     */
#define EBADSF  -16L  /* bad sectors on format  */
#define EOTHER  -17L  /* insert other disk    */

/* BDOS level errors */

#define EINVFN  -32L  /* invalid function number       1 */
#define EFILNF  -33L  /* file not found          2 */
#define EPTHNF  -34L  /* path not found          3 */
#define ENHNDL  -35L  /* no handles left           4 */
#define EACCDN  -36L  /* access denied           5 */
#define EIHNDL  -37L  /* invalid handle          6 */
#define ENSMEM  -39L  /* insufficient memory         8 */
#define EIMBA   -40L  /* invalid memory block address    9 */
#define EDRIVE  -46L  /* invalid drive was specified    15 */
#define ENSAME  -48L  /* MV between two different drives  17 */
#define ENMFIL  -49L  /* no more files          18 */

/* our own inventions */

#define ERANGE  -64L  /* range error            33 */
#define EINTRN  -65L  /* internal error         34 */
#define EPLFMT  -66L  /* invalid program load format    35 */
#define EGSBF -67L  /* setblock failure         36 */

/* KAOS extensions */

#define EBREAK  -68L  /* user break (^C)          37 */
#define EXCPT -69L  /* 68000- exception ("bombs")   38 */

/* MiNT extensions */

#define ELOCKED -58L
#define ENSLOCK -59L

/*  MagiC extensions */

#define EPTHOV -70L   /* path overflow        MAG!X */
#define ELOOP  -80L   /* too many symlinks in path  MiNT  */

/* GEMDOS Pexec Modes */

#define EXE_LDEX    0                                       /* TOS */
#define EXE_LD      3                                       /* TOS */
#define EXE_EX      4                                       /* TOS */
#define EXE_BASE    5                                       /* TOS */
#define EXE_EXFR    6                                       /* TOS 1.4  */
#define EXE_XBASE   7                                       /* TOS 3.01 */


/* GEMDOS (MiNT) Fopen modes */

#define   OF_RDONLY       0
#define   OF_WRONLY       1
#define   OF_RDWR         2
#define   OF_APPEND       8
#define   OF_COMPAT       0
#define   OF_DENYRW       0x10
#define   OF_DENYW        0x20
#define   OF_DENYR        0x30
#define   OF_DENYNONE     0x40
#define   OF_CREAT        0x200
#define   OF_TRUNC        0x400
#define   OF_EXCL         0x800

/* GEMDOS Fseek Modes */

#define SEEK_SET    0                                       /* TOS */
#define SEEK_CUR    1                                       /* TOS */
#define SEEK_END    2                                       /* TOS */

/* Psemaphore */

#define PSEM_CRGET       0                                  /* MagiC 3.0 */
#define PSEM_DESTROY     1
#define PSEM_GET         2
#define PSEM_RELEASE     3

/* Dlock modes */

#define DLOCKMODE_LOCK   1
#define DLOCKMODE_UNLOCK 0
#define DLOCKMODE_GETPID 2

/* Dopendir modes */

#define DOPEN_COMPAT     1
#define DOPEN_NORMAL     0

/* Fxattr modes */

#define FXATTR_RESOLVE  0
#define FXATTR_NRESOLVE 1

/* Pdomain modes */

#define PDOM_TOS         0
#define PDOM_MINT        1

/* Modi and Codes for Dpathconf() (-> MiNT) */
 
#define DP_MAXREQ     -1
#define DP_IOPEN      0
#define DP_MAXLINKS   1
#define DP_PATHMAX    2
#define DP_NAMEMAX    3
#define DP_ATOMIC     4
#define DP_TRUNC      5
#define DP_CASE     6
#define DP_MODEATTR   7
#define DP_XATTRFIELDS  8
#define DP_VOLNAMEMAX 9

#define DP_NOTRUNC    0
#define DP_AUTOTRUNC    1
#define DP_DOSTRUNC   2
#define DP_CASE     6
#define DP_CASESENS   0
#define DP_CASECONV   1
#define DP_CASEINSENS 2
#define DP_ATTRBITS   0x000000ffL
#define DP_MODEBITS   0x000fff00L
#define DP_FILETYPS   0xfff00000L
#define DP_FT_DIR     0x00100000L
#define DP_FT_CHR     0x00200000L
#define DP_FT_BLK     0x00400000L
#define DP_FT_REG     0x00800000L
#define DP_FT_LNK     0x01000000L
#define DP_FT_SOCK    0x02000000L
#define DP_FT_FIFO    0x04000000L
#define DP_FT_MEM     0x08000000L
#define DP_XATTRFIELDS  8
#define DP_INDEX      0x0001
#define DP_DEV        0x0002
#define DP_RDEV     0x0004
#define DP_NLINK      0x0008
#define DP_UID        0x0010
#define DP_GID        0x0020
#define DP_BLKSIZE    0x0040
#define DP_SIZE     0x0080
#define DP_NBLOCKS    0x0100
#define DP_ATIME      0x0200
#define DP_CTIME      0x0400
#define DP_MTIME      0x0800

/* additional Dcntl/Fcntl Modes */

#define CDROMEJECT        (('C'<<8)|0x09)
#define CDROMPREVENTREMOVAL (('C'<<8)|0x0e)
#define CDROMALLOWREMOVAL   (('C'<<8)|0x0f)
#define KER_DRVSTAT       0x0104  /* Kernel: Drive-Status (ab 9.9.95) */
#define KER_XFSNAME       0x0105  /* Kernel: XFS-Name (ab 15.6.96) */
#define VFAT_CNFDFLN        0x5600  /* VFAT-XFS: ab 2.1.96 */
#define VFAT_CNFLN        0x5601  /* VFAT-XFS: ab 2.1.96 */

/* D/Fcntl(FUTIME,...) */

struct mutimbuf {
  uint16 actime;      /* access time */
  uint16 acdate;
  uint16 modtime;   /* modify time */
  uint16 moddate;
};

typedef struct {      /* used by Cconrs */
  uint8 maxlen;
  uint8 actuallen;
  char buffer[255];
} LINE;

typedef struct {      /* used by Dfree */
  uint32 b_free;
  uint32 b_total;
  uint32 b_secsiz;
  uint32 b_clsiz;
} DISKINFO;

typedef struct {      /* used by Fsetdta, Fgetdta */
  int8  d_reserved[21];
  uint8 d_attrib;
  uint16  d_time;
  uint16  d_date;
  uint32  d_length;
  char  d_fname[14];
} DTA;

typedef struct baspag {   /* used by Pexec */
  void  *p_lowtpa;
  void  *p_hitpa;
  void  *p_tbase;
  int32 p_tlen;
  void  *p_dbase;
  int32 p_dlen;
  void  *p_bbase;
  int32 p_blen;
  DTA *p_dta;
  struct baspag *p_parent;
  int32 p_resrvd0;
  char  *p_env;
  char  p_stdfh[6];
  char  p_resrvd1;
  char  p_curdrv;
  int32 p_resrvd2[18];
  char  p_cmdlin[128];
} BASPAG;

typedef struct {      /* used by Pexec */
  uint8 length;
  char  command_tail[128];
} COMMAND;

typedef struct {      /* ProgramHeader */
  int16 ph_branch;    /* 0x00: must be 0x601a */
  int32 ph_tlen;      /* 0x02: length of TEXT Segment */
  int32 ph_dlen;      /* 0x06: length of DATA Segment */
  int32 ph_blen;      /* 0x0a: length of BSS Segment */
  int32 ph_slen;      /* 0x0e: length of symbol table */
  int32 ph_res1;      /* 0x12: */
  int32 ph_res2;      /* 0x16: */
  int16 ph_flag;      /* 0x1a: 1: absolut, 0: relocation table */
} PH;

typedef struct {      /* used by Fdatime */
  uint16 time;
  uint16 date;
} DOSTIME;

/* system variable _sysbase (0x4F2L) points to next structure */
typedef struct _syshdr {
  uint16      os_entry; /* $00 BRA to reset handler */
  uint16      os_version; /* $02 TOS version number */
  void        *os_start;  /* $04 -> reset handler */
  struct _syshdr  *os_base; /* $08 -> baseof OS */
  void        *os_membot; /* $0c -> end BIOS/GEMDOS/VDI ram usage */
  void        *os_rsv1; /* $10 << unused,reserved >> */
  int32       *os_magic;  /* $14 -> GEM memoryusage parm. block */
  int32       os_gendat;  /* $18 Date of system build($MMDDYYYY) */
  int16       os_palmode; /* $1c OS configuration bits */
  int16       os_gendatg; /* $1e DOS-format date of systembuild */
/*
    The next three fields are only available in TOS versions 1.2 and
    greater
*/
  void        *_root;   /* $20 -> base of OS pool */
  int32       *kbshift; /* $24 -> keyboard shift state variable */
  BASPAG      **_run;   /* $28 -> GEMDOS PID of current process */
  void        *p_rsv2;    /* $2c << unused, reserved >> */
} SYSHDR;

/* Cookie structure */

typedef struct {
  int32 key;
  int32 value;
} COOKIE;

/* Sconfig(2) -> */

typedef struct {
  char  *in_dos;                 /* Adress of DOS semaphore */
  int16 *dos_time;               /* Adress of DOS time */
  int16 *dos_date;               /* Adress of DOS date */
  int32 res1;
  int32 res2;
  int32 res3;
  void  *act_pd;                 /* running program */
  int32 res4;
  int16 res5;
  void  *res6;
  void  *res7;                   /* internal DOS memory list */
  void  (*resv_intmem)();        /* expand DOS memory */
  int32 (*etv_critic)();         /* etv_critic of Gemdos */
  char* ((*err_to_str)(char e)); /* Code->Text */
  int32 res8;
  int32 res9;
  int32 res10;
} DOSVARS;

/* os_magic -> */

typedef struct {
  int32 magic;                   /* must be $87654321 */
  void  *membot;                 /* end of AES variables */
  void  *aes_start;              /* start adress */
  int32 magic2;                  /* is 'MAGX' */
  int32 date;                    /* creation date ddmmyyyy */
  void  (*chgres)(int16 res, int16 txt);  /* change resolution */
  int32 (**shel_vector)(void);   /* resident desktop */
  char  *aes_bootdrv;            /* from here was booted */
  int16 *vdi_device;             /* by AES used VDI driver */
  void  *reservd1;
  void  *reservd2;
  void  *reservd3;
  int16 version;                 /* e.g. $0201 is V2.1 */
  int16 release;                 /* 0=alpha..3=release */
} AESVARS;

/* Cookie MagX --> */

typedef struct {
  long config_status;
  DOSVARS *dosvars;
  AESVARS *aesvars;
  void *res1;
  void *hddrv_functions;
  int32 status_bits;             /* MagiC 3 ab 24.5.95 */
} MAGX_COOKIE;

/* Bits for <status_bits> in MAGX_COOKIE (read only!) */

#define MGXSTB_TSKMAN_ACTIVE  1    /* MagiC task manager is currently active */

/* attributes for Fcreate/Fsfirst/Fsnext: */

#define FA_READONLY     0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_VOLUME       0x08
#define FA_SUBDIR       0x10
#define FA_ARCHIVE      0x20

/* Fopen modes: */

#define FO_READ         0
#define FO_WRITE        1
#define FO_RW           2

extern BASPAG *_BasPag;
extern long _PgmSize;

typedef struct {
  uint16 mode;
  int32 index;
  uint16 dev;
  uint16 reserved1;
  uint16 nlink;
  uint16 uid;
  uint16 gid;
  int32 size;
  int32 blksize;
  int32 nblocks;
  int16 mtime;
  int16 mdate;
  int16 atime;
  int16 adate;
  int16 ctime;
  int16 cdate;
  int16 attr;
  int16 reserved2;
  int32 reserved3[2];
} XATTR;

/* Sconfig - Functions */

#define SC_GETCONF  0                                      /* KAOS 1.2 */
#define SC_SETCONF  1                                      /* KAOS 1.2 */
#define SC_DOSVARS  2                                      /* KAOS 1.4 */
#define SC_MOWNER   3 /* reserviert */              /* MagiC 3.00 */
#define SC_WBACK    4                         /* MagiC 4.01 */
#define SCWB_GET    0 /* (for WBDAEMON) */            /* MagiC 4.01 */
#define SCWB_SET    1                         /* MagiC 4.01 */
#define SCWB_RESET  2                         /* MagiC 4.01 */
#define SC_INTMAVAIL  5 /* reserviert */              /* MagiC 4.01 */
#define SC_INTGARBC 6 /* reserviert */              /* MagiC 4.01 */

/* Sconfig Bits */

#define SCB_PTHCK   0x001                                   /* KAOS 1.2 */
#define SCB_DSKCH   0x002                                   /* KAOS 1.2 */
#define SCB_BREAK   0x004                                   /* KAOS 1.2 */
#define SCB_NCTLC   0x008                                   /* KAOS 1.2 */
#define SCB_NFAST   0x010                                   /* KAOS 1.2 */
#define SCB_CMPTB   0x020                                   /* KAOS 1.4 */
#define SCB_NSMRT   0x040                                   /* KAOS 1.4 */
#define SCB_NGRSH   0x080                                   /* KAOS 1.4 */
#define SCB_NHALT   0x100                                   /* KAOS 1.4 */
#define SCB_RESVD   0x200                                   /* KAOS 1.4 */
#define SCB_PULLM   0x400                                   /* KAOS 1.4 */
#define SCB_FLPAR   0x800                                   /* MagiC 3.0 */

/* Memory Control Block */

typedef struct {
  int32 mcb_magic;  /* 'ANDR' or 'KROM' (last) */
  int32 mcb_len;    /* netto length */
  int32 mcb_owner;  /* PD* */
  int32 mcb_prev; /* previous block or NULL */
/*  char mcb_data[]; */
} MCB;

/* Fcntl opcodes */

#define   FSTAT          0x4600
#define   FIONREAD       0x4601
#define   FIONWRITE      0x4602
#define   FUTIME         0x4603
#define   FTRUNCATE      0x4604
#define   SHMGETBLK      0x4d00
#define   SHMSETBLK      0x4d01
#define   PBASEADDR      0x5002

/* signal handling */

#define NSIG       31       /* number of signals recognized   */

#define SIGNULL     0       /* not really a signal             */
#define SIGHUP      1       /* hangup signal                   */
#define SIGINT      2       /* sent by ^C                      */
#define SIGQUIT     3       /* quit signal                     */
#define SIGILL      4       /* illegal instruction             */
#define SIGTRAP     5       /* trace trap                      */
#define SIGABRT     6       /* abort signal                    */
#define SIGPRIV     7       /* privilege violation             */
#define SIGFPE      8       /* divide by zero                  */
#define SIGKILL     9       /* cannot be ignored               */
#define SIGBUS     10       /* bus error                       */
#define SIGSEGV    11       /* illegal memory reference        */
#define SIGSYS     12       /* bad argument to a system call   */
#define SIGPIPE    13       /* broken pipe                     */
#define SIGALRM    14       /* alarm clock                     */
#define SIGTERM    15       /* software termination signal     */
#define SIGURG     16       /* urgent condition on I/O channel */
#define SIGSTOP    17       /* stop signal not from terminal   */
#define SIGTSTP    18       /* stop signal from terminal       */
#define SIGCONT    19       /* continue stopped process        */
#define SIGCHLD    20       /* child stopped or exited         */
#define SIGTTIN    21       /* read by background process      */
#define SIGTTOU    22       /* write by background process     */
#define SIGIO      23       /* I/O possible on a descriptor    */
#define SIGXCPU    24       /* CPU time exhausted              */
#define SIGXFSZ    25       /* file size limited exceeded      */
#define SIGVTALRM  26       /* virtual timer alarm             */
#define SIGPROF    27       /* profiling timer expired         */
#define SIGWINCH   28       /* window size changed             */
#define SIGUSR1    29       /* user signal 1                   */
#define SIGUSR2    30       /* user signal 2                   */

#define SIG_DFL    0        /* default signal handler          */
#define SIG_IGN    1        /* ignore the signal               */


/* file types */
#define S_IFMT  0170000     /* mask to select file type */
#define S_IFCHR 0020000     /* BIOS special file */
#define S_IFDIR 0040000     /* directory file */
#define S_IFREG 0100000     /* regular file */
#define S_IFIFO 0120000     /* FIFO */
#define S_IMEM  0140000     /* memory region or process */
#define S_IFLNK 0160000     /* symbolic link */

/* special bits: setuid, setgid, sticky bit */
#define S_ISUID 04000
#define S_ISGID 02000
#define S_ISVTX 01000

/* file access modes for user, group, and other*/
#define S_IRUSR         0400
#define S_IWUSR         0200
#define S_IXUSR         0100
#define S_IRGRP         0040
#define S_IWGRP         0020
#define S_IXGRP         0010
#define S_IROTH         0004
#define S_IWOTH         0002
#define S_IXOTH         0001
#define DEFAULT_DIRMODE (0777)
#define DEFAULT_MODE    (0666)


typedef struct {
  int32 msg1;
  int32 msg2;
  int16 pid;
} MSG;


#define SA_NOCLDSTOP    1

typedef struct {
  void CDECL (*sa_handler)(int32 sig);
  int32 sa_mask;
  int16 sa_flags;
} SIGACTION;


/* Shared Library */

typedef void *SHARED_LIB;
typedef int32 CDECL (*SLB_EXEC)(SHARED_LIB *sl, int32 fn, int16 nargs, ...);


#define Fshrink(a)      Fwrite(a, 0L, (void *) -1L)         /* KAOS 1.2 */
#define Mgrow(a,b)      Mshrink(a,b)                        /* KAOS 1.2 */
#define Mblavail(a)     Mshrink(a,-1L)                      /* KAOS 1.2 */

extern C_CALL int16 CDECL Cauxin(void);
extern C_CALL int16 CDECL Cauxis(void);
extern C_CALL int16 CDECL Cauxos(void);
extern C_CALL void CDECL  Cauxout(int16 c);
extern C_CALL int32 CDECL Cconin(void);
extern C_CALL int16 CDECL Cconis(void);
extern C_CALL int16 CDECL Cconos(void);
extern C_CALL void CDECL  Cconout(int16 c);
extern C_CALL int32 CDECL Cconrs(LINE *buf);
extern C_CALL int16 CDECL Cconws(const char *buf);
extern C_CALL int32 CDECL Cnecin(void);
extern C_CALL int16 CDECL Cprnos(void);
extern C_CALL int16 CDECL Cprnout(int16 c);
extern C_CALL int32 CDECL Crawcin(void);
extern C_CALL int32 CDECL Crawio(int16 w);
extern C_CALL int32 CDECL Dclosedir(int32 handle);
extern C_CALL int32 CDECL Dcntl(int16 cmd, char *name, int32 arg);
extern C_CALL int32 CDECL Dcreate(const char *path);
extern C_CALL int32 CDECL Ddelete(const char *path);
extern C_CALL int16 CDECL Dfree(DISKINFO *buf, int16 driveno);
extern C_CALL int16 CDECL Dgetcwd(char *path, int16 drv, int16 size);
extern C_CALL int16 CDECL Dgetdrv(void);
extern C_CALL int16 CDECL Dgetpath(char *path, int16 driveno);
extern C_CALL int32 CDECL Dlock(int16 mode, int16 drv);
extern C_CALL int32 CDECL Dopendir(char *path, int16 flag);
extern C_CALL int32 CDECL Dpathconf(char *path, int16 mode);
extern C_CALL int32 CDECL Dreaddir(int16 len, int32 handle, char *buf);
extern C_CALL int32 CDECL Dreadlabel(const char *path, char *label, int16 len);
extern C_CALL int32 CDECL Drewinddir(int32 handle);
extern C_CALL int32 CDECL Dsetdrv(int16 drv);
extern C_CALL int16 CDECL Dsetpath(const char *path);
extern C_CALL int32 CDECL Dwritelabel(const char *path, const char *label);
extern C_CALL int32 CDECL Dxreaddir(int16 len, int32 handle, char *buf, XATTR *xattr, int32 *xret);
extern C_CALL int16 CDECL Fattrib(const char *filename, int16 wflag, int16 attrib);
extern C_CALL int32 CDECL Fchmod(char *filename, int16 mode);
extern C_CALL int32 CDECL Fchown(char *filename, int16 uid, int16 gid);
extern C_CALL int16 CDECL Fclose(int16 handle);
extern C_CALL int32 CDECL Fcntl(int16 handle, int32 arg, int16 cmd);
extern C_CALL int32 CDECL Fcreate(const char *filename, int16 attr);
extern C_CALL int16 CDECL Fdatime(DOSTIME *timeptr, int16 handle, int16 wflag);
extern C_CALL int32 CDECL Fdelete(const char *filename);
extern C_CALL int32 CDECL Fdup(int16 handle);
extern C_CALL int16 CDECL Fforce(int16 stch, int16 nonstdh);
extern C_CALL int32 CDECL Fgetchar(int16 handle, int16 mode);
extern C_CALL DTA* CDECL  Fgetdta(void);
extern C_CALL int32 CDECL Finstat(int16 handle);
extern C_CALL int32 CDECL Flink(char *oldname, char *newname);
extern C_CALL int32 CDECL Flock(int16 handle, int16 mode, int32 start, int32 size);
extern C_CALL int32 CDECL Fmidipipe(int16 pid, int16 in, int16 out);
extern C_CALL int32 CDECL Fopen(const char *filename, int16 mode);
extern C_CALL int32 CDECL Foutstat(int16 handle);
extern C_CALL int32 CDECL Fpipe(int16 usrh[2]);
extern C_CALL int32 CDECL Fputchar(int16 handle, int32 c, int16 mode);
extern C_CALL int32 CDECL Fread(int16 handle, int32 count, void *buf);
extern C_CALL int32 CDECL Freadlink(int16 len, char *buf, char *name);
extern C_CALL int16 CDECL Frename(int16 zero, const char *oldname, const char *newname);
extern C_CALL int32 CDECL Fseek(int32 offset, int16 handle, int16 seekmode);
extern C_CALL int32 CDECL Fselect(int16 timeout, int32 *rfds, int32 *wfds, int32 zero);
extern C_CALL void CDECL  Fsetdta(DTA *buf);
extern C_CALL int16 CDECL Fsfirst(const char *filename, int16 attr);
extern C_CALL int16 CDECL Fsnext(void);
extern C_CALL int32 CDECL Fsymlink(char *oldname, char *newname);
extern C_CALL int32 CDECL Fwrite(int16 handle, int32 count, const void *buf);
extern C_CALL int32 CDECL Fxattr(int16 flag, char *filename, XATTR *xattr);
extern C_CALL int32 CDECL Maddalt(void *start, int32 size);
extern C_CALL void* CDECL Malloc(int32 number);
extern C_CALL int16 CDECL Mfree(void *block);
extern C_CALL int32 CDECL Mshrink(int16 zero, void *block, int32 newsiz);
extern C_CALL void* CDECL Mxalloc(int32 number, int16 mode);
extern C_CALL int32 CDECL Pause(void);
extern C_CALL int32 CDECL Pdomain(int16 mode);
extern C_CALL int32 CDECL Pexec(int16 mode, void *ptr1, void *ptr2, void *ptr3);
extern C_CALL int32 CDECL Pfork(void);
extern C_CALL int32 CDECL Pgetauid(void);
extern C_CALL int32 CDECL Pgetegid(void);
extern C_CALL int32 CDECL Pgeteuid(void);
extern C_CALL int32 CDECL Pgetgid(void);
extern C_CALL int32 CDECL Pgetpgrp(void);
extern C_CALL int32 CDECL Pgetpid(void);
extern C_CALL int32 CDECL Pgetppid(void);
extern C_CALL int32 CDECL Pgetuid(void);
extern C_CALL int32 CDECL Pkill(int16 pid, int16 sig);
extern C_CALL int32 CDECL Pmsg(int16 mode, int32 mbox, MSG *msg);
extern C_CALL int32 CDECL Pnice(int16 delta);
extern C_CALL int32 CDECL Prenice(int16 pid, int16 delta);
extern C_CALL int32 CDECL Prusage(int32 *r);
extern C_CALL int32 CDECL Psemaphore(int16 mode, int32 id, int32 timeout);
extern C_CALL int32 CDECL Psetauid(int16 id);
extern C_CALL int32 CDECL Psetgid(int16 id);
extern C_CALL int32 CDECL Psetlimit(int16 lim, int32 value);
extern C_CALL int32 CDECL Psetpgrp(int16 id, int16 newgrp);
extern C_CALL int32 CDECL Psetuid(int16 id);
extern C_CALL int32 CDECL Psigaction(int16 sig, SIGACTION *act, SIGACTION *ocat);
extern C_CALL int32 CDECL Psigblock(int32 mask);
extern C_CALL int32 CDECL Psignal(int16 sig, int32 handler);
extern C_CALL int32 CDECL Psigpause(int32 mask);
extern C_CALL int32 CDECL Psigpending(void);
extern C_CALL int32 CDECL Psigreturn(void);
extern C_CALL int32 CDECL Psigsetmask(int32 mask);
extern C_CALL void CDECL  Pterm(int16 retcode);
extern C_CALL void CDECL  Pterm0(void);
extern C_CALL void CDECL  Ptermres(int32 keepcnt, int16 retcode);
extern C_CALL int32 CDECL Pumask(int16 mode);
extern C_CALL int32 CDECL Pusrval(int32 val);
extern C_CALL int32 CDECL Pvfork(void);
extern C_CALL int32 CDECL Pwait(void);
extern C_CALL int32 CDECL Pwait3(int16 flag, int32 *rusage);
extern C_CALL int32 CDECL Pwaitpid(int16 pid, int16 flag, int32 *rusage);
extern C_CALL int32 CDECL Salert(char *msg);
extern C_CALL int32 CDECL Slbopen(char *name, char *path, int32 min_ver, SHARED_LIB *sl, SLB_EXEC *fn, int32 para);
extern C_CALL int32 CDECL Slbclose(SHARED_LIB *sl);
extern C_CALL int32 CDECL Sconfig(int16 mode, int32 flags);
extern C_CALL int32 CDECL Srealloc(int32 len);
extern C_CALL int32 CDECL Super(void *stack);
extern C_CALL int32 CDECL Ssystem(int16 mode, int32 arg1, int32 arg2);
extern C_CALL int16 CDECL Sversion(void);
extern C_CALL int32 CDECL Syield(void);
extern C_CALL int32 CDECL Sysconf(int16 n);
extern C_CALL int32 CDECL Talarm(int32 time);
extern C_CALL uint16 CDECL  Tgetdate(void);
extern C_CALL uint16 CDECL  Tgettime(void);
extern C_CALL uint16 CDECL  Tsetdate(uint16 date);
extern C_CALL int32 CDECL Tsetitimer(int32 which, int32 interval, int32 value, int32 ointerval, int32 ovalue);
extern C_CALL uint16 CDECL  Tsettime(uint16 time);

#endif
