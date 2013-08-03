 /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  *                                                         *
  * "osif.h" Version 1.5 Last delta 13:11:15 3/22/85        *
  *                                                         *
  * RESPONSIBLE ENGINEER:  G. M. Harding                    *
  *                                                         *
  * This file contains the OS-specific definitions for the  *
  * DRI CLEAR/C runtime library. It is intended for inclu-  *
  * sion with those functions dealing directly with the OS  *
  * interface, as well as any function which has hardware-  *
  * dependent code (byte-storage order, for instance).      *
  *                                                         *
  * This version of OSIF.H is a direct descendant of the    *
  * file maintained by the CLEAR group under CP/M. It has   *
  * been placed under the management of SCCS on Pluto. The  *
  * original code is accessible as SID 1.1; the s-file re-  *
  * sides in /vis/harding/sccs/gdos as s.osif.h. See that   *
  * file for revision history prior to 8 March 1985.        *
  *                                                         *
  * Specific command lines for various targets are:         *
  *                                                         *
  *   -Dcpm     CP/M-86 and derivatives (CCP/M)             *
  *   -Dcpmk    CP/M-68K                                    *
  *   -Dpcdos1  PC-DOS v1.0 and up                          *
  *   -Dpcdos2  PC-DOS v2.0 and up                          *
  *   -Dpcdosb  both 1.0 and 2.0 PC-DOS (runtime switch)    *
  *   -DGDOS    GEMDOS                                      *
  *                                                         *
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifdef pcdos1           /* IBM PC DOS v1.0 and higher       */

#define ALCYON  0       /* Alcyon C Compiler                */

#if ALCYON              /* Zap Alcyon's pre-defines         */
#undef CPM
#undef cpm
#undef MC68000
#undef mc68000
#endif

#define CPM     0
#define CPM68K  0
#define CPMPC1  1       /* #if CPM || PCDOS1                */
#define CPMXPC1 1       /* #if CPM || (PCDOS1 && !PCDOS2)   */
#define DRC     1       /* Digital Research C Compiler      */
#define GEMDOS  0
#define I8086   1       /* Intel 8086/8088                  */
#define INT32   0
#define MC68000 0       /* Motorola 68000                   */
#define PC1ONLY 1       /* #if PCDOS1 && !PCDOS2            */
#define PC1OR2  1       /* #if PCDOS1 || PCDOS2             */
#define PC2ONLY 0
#define PCBOTH  0
#define PCDOS1  1       /* #if PCDOS1                       */
#define PCDOS2  0

#endif

#ifdef cpm              /* CP/M version 2.2                 */
#define ALCYON  0       /* Alcyon C Compiler                */

#if ALCYON              /* Zap Alcyon's pre-defines         */
#undef CPM
#undef cpm
#undef MC68000
#undef mc68000
#endif

#define CPM     1
#define CPM68K  0
#define CPMPC1  1       /* #if CPM || PCDOS1                */
#define CPMXPC1 1       /* #if CPM || (PCDOS1 && !PCDOS2)   */
#define DRC     1       /* Digital Research C Compiler      */
#define GEMDOS  0
#define I8086   1       /* Intel 8086/8088                  */
#define INT32   0
#define MC68000 0       /* Motorola 68000                   */
#define PC1ONLY 0
#define PC1OR2  0
#define PC2ONLY 0
#define PCBOTH  0
#define PCDOS1  0       /* IBM PC DOS                       */
#define PCDOS2  0       /* IBM PC DOS 2.0                   */

#endif

#ifdef pcdos2           /* IBM PC DOS 2.0                   */
#define ALCYON  0       /* Alcyon C Compiler                */

#if ALCYON              /* Zap Alcyon's pre-defines         */
#undef CPM
#undef cpm
#undef MC68000
#undef mc68000
#endif

#define CPM     0
#define CPM68K  0
#define CPMPC1  0
#define CPMXPC1 0
#define DRC     1       /* Digital Research C Compiler      */
#define GEMDOS  0
#define I8086   1       /* Intel 8086/8088                  */
#define INT32   0
#define MC68000 0       /* Motorola 68000                   */
#define PC1ONLY 0
#define PC1OR2  1       /* #if PCDOS1 || PCDOS2             */
#define PC2ONLY 1       /* #if PCDOS2 && !PCDOS1            */
#define PCBOTH  0
#define PCDOS1  0
#define PCDOS2  1       /* #if PCDOS2                       */

#endif

#ifdef pcdosb
#define ALCYON  0       /* Alcyon C Compiler                */

#if ALCYON              /* Zap Alcyon's pre-defines         */
#undef CPM
#undef cpm
#undef MC68000
#undef mc68000
#endif

#define CPM     0
#define CPM68K  0
#define CPMPC1  1       /* #if CPM || PCDOS1                */
#define CPMXPC1 0
#define DRC     1       /* Digital Research C Compiler      */
#define GEMDOS  0
#define I8086   1       /* Intel 8086/8088                  */
#define INT32   0
#define MC68000 0       /* Motorola 68000                   */
#define PC1ONLY 0
#define PC1OR2  1       /* #if PCDOS1 || PCDOS2             */
#define PC2ONLY 0
#define PCBOTH  1       /* #if PCDOS1 && PCDOS2             */
#define PCDOS1  1       /* #if PCDOS1                       */
#define PCDOS2  1       /* #if PCDOS2                       */

#endif

#ifdef cpmk
#define ALCYON  1       /* Alcyon C Compiler                */

#if ALCYON              /* Zap Alcyon's pre-defines         */
#undef CPM
#undef cpm
#undef MC68000
#undef mc68000
#endif

#define CPM     1
#define CPM68K  1
#define CPMPC1  1       /* #if CPM || PCDOS1                */
#define CPMXPC1 1
#define DRC     0       /* Digital Research C Compiler      */
#define GEMDOS  0
#define I8086   0       /* Intel 8086/8088                  */
#define INT32   1
#define MC68000 1       /* Motorola 68000                   */
#define PC1ONLY 0
#define PC1OR2  0       /* #if PCDOS1 || PCDOS2             */
#define PC2ONLY 0
#define PCBOTH  0       /* #if PCDOS1 && PCDOS2             */
#define PCDOS1  0       /* #if PCDOS1                       */
#define PCDOS2  0       /* #if PCDOS2                       */

#endif

#ifdef GDOS             /* GEMDOS (PCDOS2, except as noted) */
#define ALCYON  1       /* Using Alcyon compiler            */

#if ALCYON              /* Zap Alcyon's pre-defines         */
#undef CPM
#undef cpm
#undef MC68000
#undef mc68000
#endif

#define CPM     0
#define CPM68K  0
#define CPMPC1  0
#define CPMXPC1 0
#define DRC     0       /* Not using DRC                    */
#define GEMDOS  1       /* Set the GEMDOS flag              */
#define I8086   0       /* Does not use Intel 8086 CPU      */
#define INT32   1       /* Uses 32-bit integers             */
#define MC68000 1       /* Uses Motorola 68000 CPU          */
#define PC1ONLY 0
#define PC1OR2  1
#define PC2ONLY 1
#define PCBOTH  0
#define PCDOS1  0
#define PCDOS2  1

#endif

/*
  +---------------------------------------------
  | The following #define's are not presently in
  | use. Those in the first group are processor-
  | specific, and those in the second group are
  | OS-specific.
  +---------------------------------------------
*/

/* #ifdef UNdefined */

#define VAX     0       /* DEC VAX                          */
#define PDP11   0       /* DEC PDP-11                       */
#define Z8000   0       /* Zilog Z8000                      */

#define CCPM    0       /* Concurrent (multi-tasking)       */
#define CPM3    0       /* CP/M 3.x (Concurrent & Plus)     */
#define CPM4    0       /* CP/M 4.x (Portable Concurrent)   */
#define UNIX    0       /* UNIX                             */
#define VMS     0       /* DEC VAX VMS                      */

/* #endif */

/*
  +---------------------------------------------
  | FCB DEFINITIONS:  The two different types of
  | file control blocks are defined here.
  +---------------------------------------------
*/

#if CPM                 /* CP/M FCB                         */

struct fcbtab
   {
   BYTE drive;          /* Disk drive field [0]             */
   BYTE fname[8];       /* File name [1-8]                  */
   BYTE ftype[3];       /* File type [9-11]                 */
   BYTE extent;         /* Current extent number[12]        */
   BYTE s1,s2;          /* "system reserved" [13-14]        */
   BYTE reccnt;         /* Record counter [15]              */
   BYTE fpasswd[8];     /* Parsefn passwd area[16-23]       */
   BYTE fuser;          /* Parsefn user# area [24]          */
   BYTE resvd[7];       /* More "system reserved"           */
   LONG record;         /* Note -- we overlap [32-36]       */
                        /* current record field to          */
                        /* make this useful.                */
   };

#endif


#if PCDOS1              /* PC-DOS 1 FCB                     */

struct fcbtab
   {
   BYTE drive;          /* Disk drive field [0]             */
   BYTE fname[8];       /* File name [1-8]                  */
   BYTE ftype[3];       /* File type [9-11]                 */
   WORD fcb_curblk;     /* Curr 128 byte blk [12-13]        */
   WORD fcb_lrecsiz;    /* Logical record size[14-15]       */
   LONG fcb_filsiz;     /* Num bytes in file [16-19]        */
   WORD fcb_date;       /* Last updated [20-21]             */
   BYTE fcb_resvd[10];  /* System reserved [22-31]          */
   BYTE fcb_currec;     /* Rel Rec# within curblk[32]       */
   LONG record;         /* Rel Rec# from bgn file           */
                        /* [33-36] depends on lrecsiz       */
   };

#endif


#define SECSIZ 128      /* Size of CP/M sector to obtain    */
                        /* nsecs on err                     */

/*
  +---------------------------------------------
  | CCB DEFINITIONS:  One channel control block
  | is statically allocated for each of the 16
  | possible open files under C. (This includes
  | STDIN, STDOUT, and STDERR.) Permanent data
  | regarding each channel is kept in its CCB.
  +---------------------------------------------
*/

struct ccb
   {
   WORD   flags;           /* Flags byte                    */
   WORD   fd;              /* Channel number being used     */
   LONG   offset;          /* File offset word (bytes)      */

#if CPMPC1

   BYTE   user;            /* User #                        */
   LONG   sector;          /* Sector currently in buffer    */
   LONG   hiwater;         /* High water mark               */
   struct fcbtab fcb;      /* File FCB (may have TTY info)  */
   BYTE   buffer[SECSIZ];  /* Read/write buffer             */

#endif

   };

extern struct ccb _fds[];  /* Declare storage               */

#define FD struct ccb      /* FD Type definition            */
#define NULLFD ((FD *)0)   /* NULLPTR for FD                */

/*
  +---------------------------------------------
  |         FLAGS WORD BIT DEFINITIONS
  +---------------------------------------------
*/

#define OPENED  0x01       /* Channel is OPEN               */
#define ISTTY   0x02       /* Channel open to TTT           */
#define ISLPT   0x04       /* Channel open to LPT           */
#define ISREAD  0x08       /* Channel open readonly         */
#define ISASCII 0x10       /* ASCII file attached           */
#define ATEOF   0x20       /* End of file encountered       */
#define DIRTY   0x40       /* Buffer needs writing          */
#define ISSPTTY 0x80       /* Special tty info              */
#define ISAUX   0x100      /* Auxiliary device              */
#define ISQUE   0x200      /* Queue device                  */
#define ISDEV   0x80       /* IOCTL for pcdos 2.0 dev flag  */

#define READ    0          /* Read mode parameter for open  */
#define WRITE   1          /* Write mode                    */

/*
  +---------------------------------------------
  |              IOCTL DEFINITIONS
  +---------------------------------------------
*/

#if PCDOS2

#define IOGDEV  0       /* get device info                  */
#define IOSDEV  1       /* set device info                  */
#define IORDEV  2       /* read device                      */
#define IOWDEV  3       /* write device                     */
#define IORDRV  4       /* read drive                       */
#define IOWDRV  5       /* write drive                      */
#define IOGIST  6       /* get input status                 */
#define IOGOST  7       /* get output status                */

#endif

/*
  +---------------------------------------------
  |          CCB MANIPULATION MACROS
  +---------------------------------------------
*/

#define _getccb(i) (FD *)(&_fds[i])    /* Get CCB addr      */

/*
  +---------------------------------------------
  |         OSIF FUNCTION DEFINITIONS
  +---------------------------------------------
*/

#if CPM68K
#define __OSIF(fn,arg) __BDOS((fn),(LONG)(arg))
#else
#define __OSIF(fn,arg) __BDOS((fn),(arg))
#endif

#if CPM

#define EXIT            0     /* Exit to BDOS               */
#define CONIN           1     /* Direct echoing con input   */
#define CONOUT          2     /* Direct console output      */
#define LSTOUT          5     /* Direct list device output  */
#define CONIO           6     /* Direct console I/O         */
#define C_WRITESTR      9     /* Console string output      */
#define CONBUF         10     /* Read console buffer        */
#define C_STAT         11     /* Get console status         */
#define S_BDOSVER      12     /* Get System BDOS Ver Num    */
#define OPEN           15     /* OPEN a disk file           */
#define CLOSE          16     /* Close a disk file          */
#define SEARCHF        17     /* Search for first           */
#define SEARCHN        18     /* Search for next            */
#define DELETE         19     /* Delete a disk file         */
#define CREATE         22     /* Create a disk file         */
#define F_RENAME       23     /* Rename a disk file         */
#define SETDMA         26     /* Set DMA address            */
#define USER           32     /* Get/Set user number        */
#define B_READ         33     /* Read Random record         */
#define B_WRITE        34     /* Write Random record        */
#define FILSIZ         35     /* Compute File Size          */
#define F_MULTISEC     44     /* Set Multi-Sector Count     */
#define P_CHAIN        47     /* Program Chain              */
#define SETVEC         61     /* Set exception vector       */
#define N_NETSTAT      68     /* Get Network Status         */
#define F_TRUNC        99     /* Truncate file function     */
#define S_OSVER       163     /* Get OS Version Number      */

#else

#if GEMDOS

#define EXIT            0     /* Exit to OS                 */
#define CONIN           1     /* Read char from STDIN       */
#define CONOUT          2     /* Display char on STDOUT     */
#define AUXIN           3     /* Read char from aux port    */
#define AUXOUT          4     /* Send char to aux port      */
#define LSTOUT          5     /* Send char to list device   */
#define CONIO           6     /* Raw console I/O            */
#define DIRCONIN        7     /* Direct input without echo  */
#define NECONIN         8     /* Direct input without echo  */
#define C_WRITESTR      9     /* Send a string to STDOUT    */
#define CONBUF         10     /* Read console buffer        */
#define C_STAT         11     /* Get console status         */
#define RESDSK         13     /* Reset disk & flush buffers */
#define SETDRV         14     /* Set drive to current drive */
#define CURDSK         25     /* Get current drive ID       */
#define SETTRA         26     /* Set disk transfer address  */
#define G_DATE         42     /* Get system date            */
#define S_DATE         43     /* Set system date            */
#define G_TIME         44     /* Get system time            */
#define S_TIME         45     /* Set system time            */
#define GETDTA         47     /* Get disk transfer address  */
#define GETVER         48     /* Get version number         */
#define KPPROC         49     /* Keep process               */
#define GETDFS         54     /* Get disk free space        */
#define MKDIR          57     /* Make a new subdirectory    */
#define RMDIR          58     /* Remove a subdirectory      */
#define CHDIR          59     /* Change curr. working dir.  */
#define CREATE         60     /* Create file w/attributes   */
#define OPEN           61     /* Open file in given mode    */
#define CLOSE          62     /* Close a file               */
#define B_READ         63     /* Read from an open file     */
#define B_WRITE        64     /* Write to an open file      */
#define DELETE         65     /* Delete a file              */
#define LSEEK          66     /* Position pointer in a file */
#define CHMOD          67     /* Chg attributes of a file   */
#define DUP            69     /* Conv std handle to non-std */
#define FORCE          70     /* Make std point to non-std  */
#define GETDIR         71     /* Get current dir. pathname  */
#define MALLOC         72     /* Memory allocator           */
#define MFREE          73     /* Inverse of MALLOC          */
#define SETBLOCK       74     /* FOR NOW--Block adj routine */
#define EXEC           75     /* Fork, execute program      */
#define EXITWSC        76     /* Exit to OS w/status code   */
#define CHLDRC         77     /* Get return code of a child */
#define SFIRST         78     /* Search for a file          */
#define SNEXT          79     /* Search for next file       */
#define RENAME         86     /* File rename routine        */
#define GSDTOF         87     /* Get/set system date/time   */

#else

#define EXIT            0     /* Exit to BDOS               */
#define CONIN           1     /* direct echoing con input   */
#define CONOUT          2     /* Direct console output      */
#define LSTOUT          5     /* Direct list device output  */
#define CONIO           6     /* Direct console I/O         */
#define C_WRITESTR      9     /* Console string output      */
#define CONBUF         10     /* Read console buffer        */
#define C_STAT         11     /* Get console status         */
#define OPEN           15     /* OPEN a disk file           */
#define CLOSE          16     /* Close a disk file          */
#define SEARCHF        17     /* Search for first           */
#define SEARCHN        18     /* Search for next            */
#define DELETE         19     /* Delete a disk file         */
#define CREATE         22     /* Create a disk file         */
#define F_RENAME       23     /* Rename a disk file         */
#define SETDMA         26     /* Set DMA address            */
#define B_READ         33     /* Read Random record         */
#define B_WRITE        34     /* Write Random record        */
#define FILSIZ         35     /* Compute File Size          */
#define R_READ         39     /* Random blk read            */
#define R_WRITE        40     /* Random blk write           */
#define G_DATE         42     /* Get current date           */
#define G_TIME         44     /* Get current time           */
#define V_DOS          48     /* Find Ver. #                */
#define MKDIR          57     /* Create sub-dir             */
#define RMDIR          58     /* Remove a directory         */
#define CHDIR          59     /* Change directory           */
#define CREATX         60     /* Creat a disk file (EX)     */
#define OPENX          61     /* Open a disk file  (Ex)     */
#define CLOSEX         62     /* Close a disk file (Ex)     */
#define READX          63     /* Read from file/dev (Ex)    */
#define WRITEX         64     /* Write from file/dev        */
#define DELETEX        65     /* Delete a disk file         */
#define LSEEKX         66     /* Move read/write pointer    */
#define IOCTL          68     /* I/O control calls          */
#define DUP            69     /* Duplicate a file des.      */
#define CWD            71     /* current working dir        */
#define SETBLK         74     /* Set Block: free up         */
#define EXECX          75     /* Execl                      */
#define EXITX          76     /* Terminate process          */
#define SRCHFX         78     /* Find first                 */
#define SRCHNX         79     /* Find next                  */
#define RENAMEX        86     /* Rename a file              */

#endif

#endif

/*
  +---------------------------------------------
  |       MISCELLANEOUS CP/M DEFINITIONS
  +---------------------------------------------
*/

#define TERM    "CON:"     /* Console file name             */
#define LIST    "LST:"     /* List device file name         */
#define EOFCHAR 0x1a       /* End of file character: ^Z     */

/*
  +---------------------------------------------
  |           HARDWARE DEPENDENCIES
  +---------------------------------------------
*/

#if MC68000                /* 68K or Z8000                  */
#define HILO 1
#else
#define HILO 0
#endif

#if HILO                   /* Hi/Lo storage (used in 68K)   */

struct long_struct
   {
   BYTE lbhihi;            /* Use this structure to access  */
   BYTE lbhilo;            /* ordered bytes in 32-bit LONG  */
   BYTE lblohi;            /* quantities.                   */
   BYTE lblolo;
   };

struct word_struct
   {
   WORD lwhi;              /* Use this structure to access  */
   WORD lwlo;              /* ordered words in 32-bit LONG  */
   };                      /* quantities.                   */

#else                      /* Lo/Hi storage (used in 8086,  */
                           /* PDP-11, VAX, etc.)            */

struct long_struct
   {
   BYTE lblolo;            /* Use this structure to access  */
   BYTE lblohi;            /* ordered bytes in 32-bit LONG  */
   BYTE lbhilo;            /* quantities.                   */
   BYTE lbhihi;
   };

struct word_struct
   {
   WORD lwlo;              /* Use this structure to access  */
   WORD lwhi;              /* ordered words in 32-bit LONG  */
   };                      /* quantities.                   */

#endif

 /* * * * * * * * * * *  END OF osif.h  * * * * * * * * * * */

