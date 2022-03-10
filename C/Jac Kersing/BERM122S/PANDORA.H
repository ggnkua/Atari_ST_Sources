#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#define LINN

#define __PROTO__       1

/* compiler, CHOOSE ONE OF THIS (or all 0 for Windows NT) */
#define TC              0               /* Turbo C 1.5 compiler         */
#define ASTEC           0               /* CPM Astec 1.06D compiler     */
#define AMIGA           0               /* Not yet...                   */
#define MEGAMAX         0               /* Atari MegaMax 1.1 compiler   */
#define MWC             0
#define STTC            0               /* Atari ST, Turbo C 2.0        */
#define UNIX            1				/* Unix ansi compiler			*/

#define DIRSEP		'\\'

#if	UNIX
#include <stdlib.h>
#define MC68000         1               /* Motorola storage not used    */
#define MSDOS           0               /* Flexible file system         */
#define CPM             0               /* Pad files to CP/M records    */
#define BREAD           "r"
#define BWRITE          "w"
#define BRUP            "r+"
#define BWUP            "w+"
#define uclose(f)       { if (f) fclose(f); f = NULL; }
#define useek(f,a,m)    if (f) fseek(f, a, m);
#undef DIRSEP
#define DIRSEP		'/'
/* ... */
#define cdecl
/* BSD alias for ansi libs */
#define memmove		memcpy
#define	strnicmp	strncasecmp
#define stricmp		strcasecmp
#define remove		unlink
#endif

#ifdef WIN32
#include <stdlib.h>
#define BWIN32			1				/* used in utextra.c */
#define MC68000			0
#define MSDOS           0               /* Flexible file system (unused)*/
#define CPM             0               /* Pad files to CP/M records    */
#define BREAD           "rb"
#define BWRITE          "wb"
#define BRUP            "rb+"
#define BWUP            "wb+"
#define uclose(f)       { if (f) fclose(f); f = NULL; }
#define useek(f,a,m)    if (f) fseek(f, a, m);
#endif

#if     TC
#include <stdlib.h>
#include <setjmp.h>

#define MC68000         0               /* Motorola storage not used    */
#define MSDOS           1               /* Flexible file system         */
#define CPM             0               /* Pad files to CP/M records    */
#define BREAD           "rb"
#define BWRITE          "wb"
#define BRUP            "r+b"
#define BWUP            "w+b"

#define uclose(f)       fclose(f)
#define rewind(f)       fseek(f, 0L, 0)
#define useek(f,a,m)    fseek(f,a,m)
#endif

#if MEGAMAX                             /* no filepointer ok check!     */
#define MC68000         1               /* Motorola storage used        */
#define MSDOS           1               /* Flexible file system         */
#define CPM             0               /* Pad files to CP/M records    */
#define BREAD           "br"
#define BWRITE          "bw"
#define BRUP            "br+"
#define BWUP            "bw+"

#define uclose(f)       { if (f) fclose(f); f = NULL; }
#define rewind(f)       if (f) fseek(f, 0L, 0);
#define useek(f,a,m)    if (f) fseek(f, a, m);
#endif

#if MWC                                 /* no filepointer ok check!     */
#include <setjmp.h>
#define MC68000         1               /* Motorola storage used        */
#define MSDOS           1               /* Flexible file system         */
#define CPM             0               /* Pad files to CP/M records    */
#define BREAD           "rb"
#define BWRITE          "wb"
#define BRUP            "r+b"
#define BWUP            "w+b"

#define uclose(f)       { if (f) fclose(f); f = NULL; }
#define rewind(f)       if (f) fseek(f, 0L, 0);
#define useek(f,a,m)    if (f) fseek(f, a, m);
#endif

#if STTC                                /* no filepointer ok check!     */
#include <stdlib.h>
#include <setjmp.h>
#include <ext.h>						/* LINN */
#define MC68000         1               /* Motorola storage used        */
#define MSDOS           1               /* Flexible file system         */
#define CPM             0               /* Pad files to CP/M records    */
#define BREAD           "rb"
#define BWRITE          "wb"
#define BRUP            "r+b"
#define BWUP            "w+b"

#define uclose(f)       { if (f) fclose(f); f = NULL; }

#ifdef LATTICE
#define cdecl __stdargs
#define environ environn /* environ already used */
#endif
#define useek(f,a,m)    if (f) fseek(f, a, m);
#define movmem(s,d,n)	memmove((d),(s),(n))
#endif

#if ASTEC                               /* no filepointer ok check!     */
#include <setjmp.h>

#define MC68000         0               /* Motorola storage not used    */
#define MSDOS           0               /* Flexible file system         */
#define CPM             1               /* Pad files to CP/M records    */
#define BREAD           "r"
#define BWRITE          "w"
#define BRUP            "r+"
#define BWUP            "w+"

#define fopen           uopen           /* path simulation              */
#define uclose(f)       { if (f) fclose(f); f = NULL; }
#define rewind(f)       if (f) fseek(f, 0L, 0);
#define useek(f,a,m)    if (f) fseek(f, a, m);
#endif

#if     MC68000==0
#define inteli(x)       (x)
#define intell(x)       (x)
#endif

#define VERSION         "2.41b"         /* Current Version of Pandora   */
#define ERROR           -1              /* Error value                  */
#define NOFILE          (FILE *)0       /* fopen didn't work            */
#define CPMEOF          0x1A            /* CP/M EOF mark                */
#define SOH             1               /* Start Of Header              */
#define EOT             4               /* End of Transmission          */
#define ACK             6               /* Acknowledge                  */
#define NAK             21              /* Not Acknowledge              */
#define SYN             0x16            /* Telinkblock header           */
#define CAN             0x18            /* Cancel transfer              */
#define CRC             0x43            /* CRC mode requested           */
#define SUB             0x1A            /* End of modem7 filename       */
#define ERRORMAX        10              /* Max error by up/down-load    */
#define RETRYMAX        30              /* Max retry per record         */
#define TIMEOUT         -1              /* Received timed out           */
#define SECSDAY         86400L          /* # seconds/day                */
#define Ctrl_A          0x01            /* Simultanious keyboard ON     */
#define Ctrl_C          0x03            /* ^C value                     */
#define Ctrl_Z          0x1A            /* Simultanious keyboard OFF    */
#define TRUE            1               /* Good, Ok, Success, Hoera!    */
#define FALSE           0               /* all but the above            */
#define FOREVER         for (;;)        /* Loop forever                 */
#define N_AREAS		500		/* Maximum number of areas		*/

#ifndef u_int
#define u_int           unsigned short int /* posix symbol may be defined */
#endif

#define MSGLEN          16384           /* Length of MESSAGE buffer     */

#define TWIT            00
#define GUEST           10
#define NORMAL          20
#define PRIV            30
#define SUPER           40
#define SYSOP           50
#define HIDDEN          60
#define NRPRIV          6

#define PRIVATE         0x0001          /* Flag private bit             */
#define CRASH           0x0002          /* Mail: crash message          */
#define RECEIVED        0x0004          /* Flag received bit            */
#define SENT            0x0008          /* Mail: msg has been sent      */
#define FILEATCH        0x0010          /*       msg has file attached  */
#define MSGFWD          0x0020          /*       msg has been send      */
#define KILLSEND        0x0080          /*       kill/send              */
#define ORPHAN          0x0040          /*       unknown destination    */
#define MSGLOCAL        0x0100          /*       message entered here   */
#define MSGHOLD         0x0200          /*       hold message for pickup*/
#ifdef LINN
#define DIRECT          0x0400          /*       no route but no crash  */
#define NOKILL          0x0800          /*       no kill by crunch      */
#endif
#define DELETED         0x8000          /* Flag deleted bit             */

#define MAIL            1               /* Area is Mail area            */
#define ECHO            2               /* Area is Echo area            */
#define PRIVEON         4               /* private msgs allowed         */
#define TAMON           8               /* ask throw away msg?          */
#define KSON            16              /* ask KILL/SEND?               */
#define CTRLA           32              /* Remove CtrlA lines for SYSOP */
#define SEENBYON        64              /* Remove SEEN-BY's             */

#define SIM_OFF         0               /* Not in simultane mode        */
#define SIM_ON          1               /* Double keyboards at work     */
#define SIM_CHAT        2               /* Sysop chatting with user     */

#define PORTS           7               /* Bitmask for 8 possible ports */
#define WARNING         8               /* 2 minute warning had         */
#define TEST            16              /* Test mode (no remote echo)   */
#define YELL            32              /* Yell disabled                */
#define HAYES           64              /* Hayes modem?                 */
#define AFTER           128             /* Sysop wants time after user  */
#define TB              256             /* Called from TheBox, no init  */
#define EXTRA           512             /* Extra info by Up/Down-load   */
#define LOGALL          1024            /* All user input to LOGfile    */

#define OK              0               /* Normal termination           */
#define FATAL           1               /* Fatal termination            */
#define OUTER           2               /* Proceed with Outer           */
#define MAILEXIT        3               /* Proceed with Mailer          */

#define FULL            0               /* Full treatment               */
#define NEWS            1               /* Welcome only                 */
#define BULL            2               /* Bulletin only                */
#define NONE            3               /* No news, no welcome          */

#define pushBRK         setjmp( Cbuf[ ++Ccount ] )
#define popBRK          Ccount--
#define jmpBRK(val)     longjmp( Cbuf[ Ccount ],val )

struct Reply {
        u_int           msgnr;          /* 1 based                      */
        struct  Reply   *next;          /* to next reply                */
};

struct Parent {
        u_int           msgnr;          /* 1 based                      */
        struct  Parent  *next;          /* to next parent               */
        struct  Reply   *Rchain;        /* to reply numbers             */
};

#ifdef PANDORA
char    invoer[132],                    /* linebuffer for user input    */
        *Ppath,                         /* Pointer to Pandora Path      */
        *input,                         /* next pointer to invoer       */
        *cmdstr,                        /* current pointer to invoer    */
        Xpos,                           /* Screen X position            */
        Ypos,                           /* Screen Y position            */
        echo = TRUE,                    /* Echo "." ?                   */
        special,                        /* special (Log etc.)           */
        simultane,                      /* Simultane keyboard on?       */
        HGUPen,                         /* How to handle userhangup     */
        Cen;                            /* May the user ^C?             */
int     flags,                          /* Various flag bits            */
        tlimit,                         /* users time limit             */
        number,                         /* Global number for getstr     */
        ontime,                         /* users accumlated ontime      */
        maxtime;                        /* max. time for this user      */
u_int   highest,                        /* highest msgs in file         */
        nrmsg,                          /* number of msgs in file       */
        pHDR,                           /* current hdr in memory        */
        *LastRead,                      /* Lastread msgs[C.Areas]       */
        baud,                           /* users baudrate               */
        Ccount;                         /* Ptr for Cbuf 'stack'         */

FILE    *LOG,                           /* Pointer in Logfile           */
        *LBR,                           /* Pointer in Library           */
        *CFG,                           /* Pointer in Config            */
        *PWD,                           /* Pointer in Password          */
        *MSG,                           /* Pointer to MSGs              */
        *HDR,                           /* Pointer to HDRs              */
        *FIL,                           /* Pointer to FILES.x           */
        *fp;                            /* Pointer for temp files       */

struct  Parent  *Parents;

char    MESSAGE[MSGLEN],                /* Storage min. 2048 bytes      */
        prefix[80];                     /* Used in MSGS/FILE as prefix  */

long    Ulast,                          /* Last time user logged in     */
        logintime;                      /* Time the user logged in      */

jmp_buf Cbuf[20],                       /* Space for Setjump's          */
        Hbuf;
#else
#ifndef MAILER
extern  char            invoer[], *Ppath, *input, *cmdstr, Xpos, Ypos,
                        special, echo, simultane, HGUPen, Cen;
extern  int             flags, tlimit, ontime, number, maxtime;
extern  u_int           highest, nrmsg, pHDR, baud, *LastRead, Ccount;
extern  long            Ulast,logintime;
extern  FILE            *LOG, *LBR, *CFG, *PWD, *MSG, *HDR, *FIL, *fp;
extern  struct  Parent  *Parents;
extern  char            MESSAGE[], prefix[];
extern  jmp_buf         Cbuf[], Hbuf;
#endif
#endif

/* Record structure for User, do NOT alter lightly! */

struct User {
 char   name[36],                       /* Name of User                 */
        pass[16],                       /* Password of User             */
        plaats[16];                     /* Home site of User            */
 long   lcall;                          /* Last time User called        */
 u_int  nrcall,                         /* number of calls              */
        Mallow,                         /* Group mask for user area's   */
        Fallow,                         /* Group mask for user area's   */
        credit,                         /* credit of user (cents)       */
        upload,                         /* #K uploaded FROM user        */
        down,                           /* #K downloaded TO user (total)*/
        todown,                         /* downloaded today             */
        tontime;                        /* accumulated inlogtime        */
 char   Access,                         /* Privilage of user            */
        Marea,                          /* Last MSGS area               */
        Farea,                          /* Last FILE area               */
        width,                          /* width of user terminal       */
        length,                         /* length of user terminal      */
        help,                           /* user help level              */
        more,                           /* "More?" on?                  */
        tabs,                           /* Tabs expand on?              */
        nuls,                           /* howmany nuls after LF?       */
        intro,                          /* how to introcuce?            */
        term;                           /* form feed, 0 = nc            */
#if     CPM
 char   _pad[29];                       /* Pad to CP/M record boundery  */
#endif
};

/* record structure for .HDR, do NOT alter lightly! */

struct Hdr {
 char   from[36],                       /* User who created msg         */
        to[36],                         /* User who may read msg        */
        topic[72],                      /* Topic of msg                 */
        time[20];                       /* Date/Time string of message  */
 long   create,                         /* Date when MSGS was received  */
        Mstart;                         /* Start offset of message      */
 u_int  up,                             /* NC                           */
        parent,                         /* Parent # of this msg         */
        flags,                          /* Attribute bits               */
        mailer[8],                      /* needed for the mailer        */
        size,                           /* # bytes in message           */
        reads,                          /* Number of times read         */
        cost,                           /* Cost of message*100          */
        Ozone,
        Onet,                           /* Net on which msg was created */
        Onode,                          /* Node on which msg was created*/
        Opoint,
        Dzone,
        Dnet,                           /* Destination net for msg      */
        Dnode,                          /* Destination node for msg     */
        Dpoint;
#if     CPM
 char   _pad[40];                       /* Pad to CP/M record boundery  */
#endif
};

struct CONFIG {
 u_int  BBSZone,                        /* Pandora zone number          */
        BBSNet,                         /* Pandora node number          */
        BBSNode,                        /* Pandora net number           */
        times,                          /* # Pandora times called       */
        Factor,                         /* Cost factor ( normal 1.00 )  */
        upcount,                        /* Number of files uploaded     */
        Init,                           /* First time login access level*/
        Areas;                          /* Number of areas in SYSTEM.BBS*/
 long   quote;                          /* Offset in quotes file        */
 u_int  Yfrom,                          /* Yell open time               */
        Ytill,                          /* Yell close time              */
        Bfrom,                          /* Pandora open time            */
        Btill,                          /* Pandora close time           */
        Mal,                            /* Initial Msgs area's allowed  */
        Fal,                            /* Initial File area's allowed  */
        ttime[NRPRIV],                  /* Time limits / level / 24hr   */
        tlim[NRPRIV],                   /* Time limits / level / call   */
        dlim[NRPRIV];                   /* Download limit per 24Hrs     */
 char   system,                         /* Kind of Pandora system       */
        Sysop[36],                      /* Name of SYSOP                */
        Main[16],                       /* Min. access level main cmd's */
        Upath[80],                      /* Upload path                  */
        Fpath[80],                      /* Path to FILE area            */
        MdmInit[80],                    /* Modem Init string (send once)*/
        MdmReset[80],                   /* Modem Reset string (send once)*/
        Currency[6];                    /* 0-4 Currency str, 5 bits     */
 int    MdmSpeed;                       /* Modem startup Baudrate       */
#if     CPM
 char   _pad[17];                       /* Pad to CP/M record boundery  */
#endif
};

struct SYSTEM {
 int    Mgroup,                         /* Allowable MSGS groups bits   */
        Fgroup,                         /* Allowable FILE groups bits   */
        Uarea;                          /* Upload area                  */
 char   Mpath[78],                      /* Path to MSGS area            */
        Mname[32],                      /* Name current MSGS area       */
        Fname[32],                      /* Name current FILE area       */
        MSGSacc[16],                    /* Min. access level msgs area  */
        FILEacc[16];                    /* Min. access level file area  */
#if     CPM
/* char _pad[0];                        /+ Pad to CP/M record boundery  */
#endif
};

struct TERMCAP {
        char    Name[16];               /* Terminal Name :              */
        char    Cls[16];                /*              Clear Screen    */
        char    GotoXy[16];             /*              Goto(X,Y)       */
        char    InsLine[16];            /*              Insert line     */
        char    DelLine[16];            /*              Delete Line     */
        char    Invert[16];             /*              Invert video    */
        char    Normal[15];             /*              Normal video    */
        char    Reverse;                /*      Use gotoYX ipv gotoXY   */
};

#define ARCMARK         26              /* compatible with ARC & PXARC  */
#define ARCVER          9               /* max storage version number   */

struct heads {                          /* archive entry header format  */
        char    name[13];               /* file name                    */
        long    size;                   /* size of file, in bytes       */
        u_int   date;                   /* creation date                */
        u_int   time;                   /* creation time                */
        int     crc;                    /* cyclic redundancy check      */
        long    length;                 /* true file length             */
        char    ver;                    /* Coding principle of file     */
};

#ifdef PANDORA
        struct User             U;
        struct Hdr              hdr;
        struct TERMCAP          Term;
        struct CONFIG           C;
        struct SYSTEM           S;
#else
#ifndef MAILER
        extern  struct User     U;
        extern  struct Hdr      hdr;
        extern  struct TERMCAP  Term;
        extern  struct CONFIG   C;
        extern  struct SYSTEM   S;
#endif
#endif

long time();
char *TimeStr(),*DateStr(), *strstr();
FILE *uopen();

