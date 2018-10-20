/*      TOS.H

        Tos Definition Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __TOS )
#define __TOS

typedef struct          /* used by Cconrs */
{
        unsigned char maxlen;
        unsigned char actuallen;
        char    buffer[255];
} LINE;


typedef struct          /* used by Fsetdta, Fgetdta */
{
    char            d_reserved[21];
    unsigned char   d_attrib;
    unsigned int    d_time;
    unsigned int    d_date;
    unsigned long   d_length;
    char            d_fname[14];
} DTA;


typedef struct          /* used by Dfree */
{
    unsigned long   b_free;
    unsigned long   b_total;
    unsigned long   b_secsiz;
    unsigned long   b_clsiz;
} DISKINFO;


typedef struct baspag   /* used by Pexec */
{
        void    *p_lowtpa;
        void    *p_hitpa;
        void    *p_tbase;
        long    p_tlen;
        void    *p_dbase;
        long    p_dlen;
        void    *p_bbase;
        long    p_blen;
        DTA     *p_dta;
        struct baspag *p_parent;
        long    p_resrvd0;
        char    *p_env;
        char    p_stdfh[6];
        char    p_resrvd1;
        char    p_curdrv;
        long    p_resrvd2[18];
        char    p_cmdlin[128];
} BASPAG;


typedef struct          /* used by Getbpb */
{
        int     recsiz;
        int     clsiz;
        int     clsizb;
        int     rdlen;
        int     fsiz;
        int     fatrec;
        int     datrec;
        int     numcl;
        int     bflags;
} BPB;


typedef struct
{
        unsigned int  time;
        unsigned int  date;
} DOSTIME;


typedef struct          /* used by Iorec */
{
        void    *ibuf;
        int     ibufsiz;
        int     ibufhd;
        int     ibuftl;
        int     ibuflow;
        int     ibufhi;
} IOREC;


typedef struct          /* used by Kbdvbase */
{
        void    (*kb_midivec)();
        void    (*kb_vkbderr)();
        void    (*kb_vmiderr)();
        void    (*kb_statvec)();
        void    (*kb_mousevec)();
        void    (*kb_clockvec)();
        void    (*kb_joyvec)();
        void    (*kb_midisys)();
        void    (*kb_kbdsys)();
} KBDVBASE;


typedef struct          /* used by Pexec */
{
        unsigned char   length;
        char            command_tail[128];
} COMMAND;


typedef struct          /* used by Initmouse */
{
        char    topmode;
        char    buttons;
        char    x_scale;
        char    y_scale;
        int     x_max;
        int     y_max;
        int     x_start;
        int     y_start;
} MOUSE;


typedef struct          /* used by Prtblk */
{
        void    *pb_scrptr;
        int     pb_offset;
        int     pb_width;
        int     pb_height;
        int     pb_left;
        int     pb_right;
        int     pb_screz;
        int     pb_prrez;
        void    *pb_colptr;
        int     pb_prtype;
        int     pb_prport;
        void    *pb_mask;
} PBDEF;


typedef struct          /* used by Keytbl */
{
        char *unshift;
        char *shift;
        char *capslock;
} KEYTAB;


typedef struct __md
{
        struct __md *m_link;
        void        *m_start;
        long        m_length;
        BASPAG      *m_own;
} MD;


typedef struct          /* used by Getmpb */
{
        MD *mp_mfl;
        MD *mp_mal;
        MD *mp_rover;
} MPB;

typedef struct
{
        int   (*Bconstat) ();
        long  (*Bconin) ();
        int   (*Bcostat) ();
        void  (*Bconout) ();
        long  (*Rsconf) ();
        IOREC *iorec;
} MAPTAB;

typedef struct
{
        MAPTAB *maptab;
        int    maptabsize;
} BCONMAP;

/* system variable _sysbase (0x4F2L) points to next structure         */
typedef struct _syshdr
{
    unsigned       os_entry;   /* $00 BRA to reset handler             */
    unsigned       os_version; /* $02 TOS version number               */
    void           *os_start;  /* $04 -> reset handler                 */
    struct _syshdr *os_base;   /* $08 -> baseof OS                     */
    void           *os_membot; /* $0c -> end BIOS/GEMDOS/VDI ram usage */
    void           *os_rsv1;   /* $10 << unused,reserved >>            */
    long           *os_magic;  /* $14 -> GEM memoryusage parm. block   */
    long           os_gendat;  /* $18 Date of system build($MMDDYYYY)  */
    int            os_palmode; /* $1c OS configuration bits            */
    int            os_gendatg; /* $1e DOS-format date of systembuild   */
/*
    The next three fields are only available in TOS versions 1.2 and
    greater
*/
    void           *_root;     /* $20 -> base of OS pool               */
    long           *kbshift;   /* $24 -> keyboard shift state variable */
    BASPAG         **_run;     /* $28 -> GEMDOS PID of current process */
    void           *p_rsv2;    /* $2c << unused, reserved >>           */
} SYSHDR;



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

#ifdef	WIN32

long    gemdos( U32 );
long    bios( U32 );
long    xbios( U32  );

#else

long    gemdos( void, ... );
long    bios( void, ... );
long    xbios( void, ... );

#endif

/****** Tos *************************************************************/

void    Pterm0( void );
long    Cconin( void );
void    Cconout( int c );
int     Cauxin( void );
void    Cauxout( int c );
int     Cprnout( int c );
long    Crawio( int w );
long    Crawcin( void );
long    Cnecin( void );
int     Cconws( const char *buf );
void    Cconrs( LINE *buf );
int     Cconis( void );
long    Dsetdrv( int drv );
int     Cconos( void );
int     Cprnos( void );
int     Cauxis( void );
int     Cauxos( void );
int     Dgetdrv( void );
void    Fsetdta( DTA *buf );
long    Super( void *stack );
unsigned int  Tgetdate( void );
unsigned int Tsetdate( unsigned int date );
unsigned int  Tgettime( void );
unsigned int  Tsettime( unsigned int time );
DTA     *Fgetdta( void );
int     Sversion( void );
void    Ptermres( long keepcnt, int retcode );
int     Dfree( DISKINFO *buf, int driveno );
int     Dcreate( const char *path );
int     Ddelete( const char *path );
int     Dsetpath( const char *path );
long    Fcreate( const char *filename, int attr );
long    Fopen( const char *filename, int mode );
int     Fclose( int handle );
long    Fread( int handle, long count, void *buf );
long    Fwrite( int handle, long count, void *buf );
int     Fdelete( const char *filename );
long    Fseek( long offset, int handle, int seekmode );
int     Fattrib( const char *filename, int wflag, int attrib );
long    Fdup( int handle );
int     Fforce( int stch, int nonstdh );
int     Dgetpath( char *path, int driveno );
void    *Malloc( long number );
int     Mfree( void *block );
int     Mshrink( int zero, void *block, long newsiz );
long    Pexec( int mode, char *ptr1, void *ptr2, void *ptr3 );
void    Pterm( int retcode );
int     Fsfirst( const char *filename, int attr );
int     Fsnext( void );
int     Frename( int zero, const char *oldname, const char *newname );
int     Fdatime( DOSTIME *timeptr, int handle, int wflag );

/****** TOS 030 Gemdos Extension ****************************************/

void    *Mxalloc( long number, int mode );
long    Maddalt( void *start, long size );

/****** Network Gemdos Extension ****************************************/

long    Flock( int handle, int mode, long start, long length );

/****** Bios ************************************************************/

void    Getmpb( MPB *ptr );
int     Bconstat( int dev );
long    Bconin( int dev );
void    Bconout( int dev, int c );
long    Rwabs( int rwflag, void *buf, int cnt, int recnr, int dev );
void    (*Setexc( int number, void (*exchdlr)() )) ();
long    Tickcal( void );
BPB     *Getbpb( int dev );
long    Bcostat( int dev );
long    Mediach( int dev );
long    Drvmap( void );
long    Kbshift( int mode );


/****** XBios ***********************************************************/

void    Initmouse( int type, MOUSE *par, void (*mousevec)() );
void    *Ssbrk( int count );
void    *Physbase( void );
void    *Logbase( void );
int     Getrez( void );
void    Setscreen( void *laddr, void *paddr, int rez );
void    Setpalette( void *pallptr );
int     Setcolor( int colornum, int color );
int     Floprd( void *buf, void *filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopwr( void *buf, void *filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopfmt( void *buf, void *filler, int devno, int spt, int trackno,
                int sideno, int interlv, long magic, int virgin );
void    Midiws( int cnt, void *ptr );
void    Mfpint( int erno, void (*vector)() );
IOREC   *Iorec( int dev );
long    Rsconf( int baud, int ctr, int ucr, int rsr, int tsr, int scr );
KEYTAB  *Keytbl( void *unshift, void *shift, void *capslock );
long    Random( void );
void    Protobt( void *buf, long serialno, int disktype, int execflag );
int     Flopver( void *buf, void *filler, int devno, int sectno,
                int trackno, int sideno, int count );
void    Scrdmp( void );
int     Cursconf( int func, int rate );
void    Settime( unsigned long time );
unsigned long  Gettime( void );
void    Bioskeys( void );
void    Ikbdws( int count, void *ptr );
void    Jdisint( int number );
void    Jenabint( int number );
char    Giaccess( char data, int regno );
void    Offgibit( int bitno );
void    Ongibit( int bitno );
void    Xbtimer( int timer, int control, int data, void (*vector)() );
void    *Dosound( void *buf );
int     Setprt( int config );
KBDVBASE *Kbdvbase( void );
int     Kbrate( int initial, int repeat );
void    Prtblk( PBDEF *par );
void    Vsync( void );
long    Supexec( long (*func)() );
void    Puntaes( void );
int     Floprate( int devno, int newrate );
int     Blitmode( int mode );

/* TOS030 XBios */
int     DMAread( long sector, int count, void *buffer, int devno );
int     DMAwrite( long sector, int count, void *buffer, int devno );
int     NVMaccess( int opcode, int start, int count, void *buffer );
long    Bconmap( int devno );
int     Esetshift( int shftMode );
int     Egetshift( void );
int     EsetBank( int bankNum );
int     EsetColor( int colorNum, int color );
void    EsetPalette( int colorNum, int count, int *palettePtr );
void    EgetPalette( int colorNum, int count, int *palettePtr );
int     EsetGray( int swtch );
int     EsetSmear( int swtch );

/* MinT Gemdos */

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


typedef struct
{
        long     msg1;
        long     msg2;
        int      pid;
} MSG;

typedef struct
{
        unsigned int   mode;
        long           index;
        unsigned int   dev;
        unsigned int   reserved1;
        unsigned int   nlink;
        unsigned int   uid;
        unsigned int   gid;
        long           size;
        long           blksize;
        long           nblocks;
        int            mtime;
        int            mdate;
        int            atime;
        int            adate;
        int            ctime;
        int            cdate;
        int            attr;
        int            reserved2;
        long           reserved3[2];
} XATTR;


#define SA_NOCLDSTOP    1

typedef struct
{
        void    (*sa_handler)( long sig );
        long    sa_mask;
        int     sa_flags;
} SIGACTION;


int     Syield( void );
int     Fpipe( int *usrh );
int     Fcntl( int f, long arg, int cmd );
long    Finstat( int f );
long    Foutstat( int f );
long    Fgetchar( int f, int mode );
long    Fputchar( int f, long c, int mode );
long    Pwait( void );
int     Pnice( int delta );
int     Pgetpid( void );
int     Pgetppid( void );
int     Pgetpgrp( void );
int     Psetpgrp( int pid, int newgrp );
int     Pgetuid( void );
int     Psetuid( int id );
int     Pkill( int pid, int sig );
void    *Psignal( int sig, void *handler );
int     Pvfork( void );
int     Pgetgid( void );
int     Psetgid( int id );
long    Psigblock( long mask );
long    Psigsetmask( long mask );
long    Pusrval( long arg );
int     Pdomain( int newdom );
void    Psigreturn( void );
int     Pfork( void );
long    Pwait3( int flag, long *rusage );
int     Fselect( unsigned int timeout, long *rfds, long *wfds, long *xfds );
void    Prusage( long *r );
long    Psetlimit( int lim, long value );
long    Talarm( long secs );
void    Pause( void );
long    Sysconf( int n );
long    Psigpending( void );
long    Dpathconf( char *name, int n );
long    Pmsg( int mode, long mbox, MSG *msg );
long    Fmidipipe( int pid, int in, int out );
int     Prenice( int pid, int delta );
long    Dopendir( char *name, int flag );
long    Dreaddir( int buflen, long dir, char *buf );
long    Drewinddir( long dir );
long    Dclosedir( long dir );
long    Fxattr( int flag, char *name, XATTR *buf );
long    Flink( char *oldname, char *newname );
long    Fsymlink( char *oldname, char *newname );
long    Freadlink( int size, char *buf, char *name );
long    Dcntl( int cmd, char *name, long arg );
long    Fchown( char *name, int uid, int gid );
long    Fchmod( char *name, int mode );
long    Pumask( unsigned int mode );
long    Psemaphore( int mode, long id, long timeout );
long    Dlock( int mode, int drive );
void    Psigpause( unsigned long mask );
long    Psigaction( int sig, SIGACTION *act, SIGACTION *oact );
int     Pgeteuid( void );
int     Pgetegid( void );
long    Pwaitpid( int pid, int flag, long *rusage );

/* Falcon */

#define VERTFLAG          0x0100
#define STMODES           0x0080
#define OVERSCAN          0x0040
#define PAL               0x0020
#define VGA_FALCON        0x0010
#define TV                0x0000

#define COL80             0x08
#define COL40             0x00

#define BPS16             4
#define BPS8              3
#define BPS4              2
#define BPS2              1
#define BPS1              0

#define NUMCOLS           7


typedef struct
{
    int     blocktype;
    long    blocksize;
    void    *blockaddr;
} DSPBLOCK;


long    locksnd( void );
long    unlocksnd( void );
long    soundcmd( int mode, int data );
long    setbuffer( int reg, void *begaddr, void *endaddr );
long    setmode( int mode );
long    settracks( int playtracks, int rectracks );
long    setmontracks( int montrack );
long    setinterrupt( int src_inter, int cause );
long    buffoper( int mode );
long    dsptristate( int dspxmit, int dsprec );
long    gpio( int mode, int data );
long    devconnect( int src, int dst, int srcclk, int prescale,
                    int protocol );
long    sndstatus( int reset );
long    buffptr( long *ptr );

int     Dsp_LoadProg( char *file, int ability, char *buffer );
long    Dsp_LodToBinary( char *file, char *codeptr );
void    Dsp_DoBlock( char *data_in, long size_in, char *data_out,
                     long size_out );
void    Dsp_BlkHandShake( char *data_in, long size_in, char *data_out,
                          long size_out );
void    Dsp_BlkUnpacked( long *data_in, long size_in, long *data_out,
                         long size_out );
void    Dsp_InStream( char *data_in, long block_size, long num_blocks,
                      long *blocks_done );
void    Dsp_OutStream( char *data_out, long block_size, long num_blocks,
                       long *blocks_done );
void    Dsp_IOStream( char *data_in, char *data_out, long block_insize,
                      long block_outsize, long num_blocks,
                      long *blocks_done );
void    Dsp_RemoveInterrupts( int mask );
int     Dsp_GetWordSize( void );
int     Dsp_Lock( void );
void    Dsp_Unlock( void );
void    Dsp_Available( long *xavailable, long *yavailable );
int     Dsp_Reserve( long xreserve, long yreserve );
void    Dsp_ExecProg( char *codeptr, long codesize, int ability );
void    Dsp_ExecBoot( char *codeptr, long codesize, int ability );
void    Dsp_TriggerHC( int vector );
int     Dsp_RequestUniqueAbility( void );
int     Dsp_GetProgAbility( void );
void    Dsp_FlushSubroutines( void );
int     Dsp_LoadSubroutine( char *codeptr, long codesize, int ability );
int     Dsp_InqSubrAbility( int ability );
int     Dsp_RunSubroutine( int handle );
int     Dsp_Hf0( int flag );
int     Dsp_Hf1( int flag );
int     Dsp_Hf2( void );
int     Dsp_Hf3( void );
void    Dsp_BlkWords( void *data_in, long size_in, void *data_out,
                      long size_out );
void    Dsp_BlkBytes( void *data_in, long size_in, void *data_out,
                      long size_out );
char    Dsp_HStat( void );
void    Dsp_SetVectors( void (*receiver)( ), long (*transmitter)( ));
void    Dsp_MultBlocks( long numsend, long numreceive,
                        DSPBLOCK *sendblocks, DSPBLOCK *receiveblocks );
int     Vsetmode( int modecode );
int     mon_type( void );
long    VgetSize( int mode );
void    VsetSync( int flag );
void    VsetRGB( int index, int count, long *array );
void    VgetRGB( int index, int count, long *array );
void    VsetMask( int ormask, int andmask, int overlay );

#endif

/************************************************************************/
