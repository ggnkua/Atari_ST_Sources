/******    *****   ******
 **   **  **   **  **   **      unRAR utility version 1.00e
 ******   *******  ******       ~~~~~~~~~~~~~~~~~~~~~~~~~~~
 **   **  **   **  **   **         FREE portable version
 **   **  **   **  **   **         ~~~~~~~~~~~~~~~~~~~~~

     Definitions header

   UNCOMMENT ONE OF THE INITIAL LINES TO DEFINE YOUR OS TYPE.
*/

/*#define DOS */         /* PC DOS is used */
/*#define OS2 */         /* if OS/2 is used */
/*#define UNIX*/         /* if Unix branch OS is used */
#define TOS	         /* if Atari¿ TOS is used */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/*
    In following generic OS definitions you can define the optional
    macro SETFILETIME in order to allow UNRAR properly handle the time
    format of your operating media.

    The first argument of SETFILETIME is FILE *DestFile, and the
    second one - pointer to the DOS time structure.

    You can disable SETFILETIME by single ';' after the macro name:

    #define SETFILETIME(FPtr,DosTimePtr)  ;
*/


/* DOS generic definitions */
#ifdef DOS
#include <fcntl.h>
#include <io.h>
#include <dir.h>
#include <alloc.h>

typedef unsigned char   UBYTE;       /*  unsigned 8 bits value type  */
typedef unsigned short  UWORD;       /*  unsigned 16 bits value type */
typedef unsigned long   UDWORD;      /*  unsigned 32 bits value type */
typedef long            SDWORD;      /*  signed 32 bits value type   */
typedef UBYTE huge *    HPBYTE;      /*  pointer type addressing     */
                                     /*  up to 96 kilobytes          */

#define MEMALLOC(Size)                farmalloc(Size)
#define MEMFREE(Ptr)                  farfree(Ptr)
#define MAKEDIR(Name)                 mkdir(Name)
#define SETFILETIME(FPtr,DosTimePtr)  setftime(fileno(FPtr),DosTimePtr)
#define PATHDIV                       '\\'

extern int _fmode=O_BINARY;
#endif


/* OS/2 generic definitions */
#ifdef OS2
#include <fcntl.h>

typedef unsigned char   UBYTE;
typedef unsigned short  UWORD;
typedef unsigned long   UDWORD;
typedef long            SDWORD;
typedef UBYTE *         HPBYTE;

#define MEMALLOC(Size)                malloc(Size)
#define MEMFREE(Ptr)                  free(Ptr)
#define MAKEDIR(Name)                 mkdir(Name)
#define SETFILETIME(FPtr,DosTimePtr)  setftime(fileno(FPtr),DosTimePtr)
#define PATHDIV                       '\\'

extern int _fmode=O_BINARY;
#endif


/* Unix generic definitions */
#ifdef UNIX
#include <unistd.h>

typedef unsigned char   UBYTE;
typedef unsigned short  UWORD;
typedef unsigned long   UDWORD;
typedef long            SDWORD;
typedef UBYTE *         HPBYTE;

#define MEMALLOC(Size)                malloc(Size)
#define MEMFREE(Ptr)                  free(Ptr)
#define MAKEDIR(Name)                 mkdir(Name,0777)
#define SETFILETIME(FPtr,DosTimePtr)  ;
#define PATHDIV                       '/'
#endif

/* TOS generic definitions */
#ifdef TOS
#include <tos.h>		/* For Turbo C/Pure C and Lattice C compilers. */
/*#include <osbind.h>*/	/* For the rest of compilers. */

typedef unsigned char   UBYTE;
typedef unsigned short  UWORD;
typedef unsigned long   UDWORD;
typedef long            SDWORD;
typedef UBYTE *         HPBYTE;

#define MEMALLOC(Size)                malloc(Size)
#define MEMFREE(Ptr)                  free(Ptr)
#define MAKEDIR(Name)                 mkdir(Name)
#define SETFILETIME(FPtr,DosTimePtr)  ;
#define PATHDIV                       '\\'
#endif

#define  UNP_VER       15       /* current version of unpacking method */

/* DOS specific file atributes flags */
#define DOSFA_RDONLY   0x01
#define DOSFA_HIDDEN   0x02
#define DOSFA_SYSTEM   0x04
#define DOSFA_LABEL    0x08
#define DOSFA_DIREC    0x10
#define DOSFA_ARCH     0x20

/* Exit codes */
enum { SUCCESS,WARNING,FATAL_ERROR,CRC_ERROR,LOCK_ERROR,WRITE_ERROR,
       OPEN_ERROR,USER_ERROR,MEMORY_ERROR,USER_BREAK=255 };

/* Status for shutdown */
enum { SD_MEMORY=1,SD_FILES=2 };

/* Status for path comparison */
enum { COMPARE_PATH,NOT_COMPARE_PATH };

/* Archive header flags */
#define  MHD_MULT_VOL       1
#define  MHD_COMMENT        2
#define  MHD_LOCK           4
#define  MHD_SOLID          8

/* File header flags */
#define  LHD_SPLIT_BEFORE   1
#define  LHD_SPLIT_AFTER    2
#define  LHD_PASSWORD       4
#define  LHD_COMMENT        8
#define  SKIP_IF_UNKNOWN    0x4000
#define  LONG_BLOCK         0x8000

/* Archive internal block types */
enum { ALL_HEAD=0,MARK_HEAD=0x72,MAIN_HEAD=0x73,FILE_HEAD=0x74,
       COMM_HEAD=0x75 };

/* HostOS code */
enum { MS_DOS=0 };

/* Error codes */
enum { EEMPTY = -1,EWRITE = 1,EREAD,EOPEN,ECLOSE,ESEEK,EMEMORY,EARCH };

struct dos_ftime {
  unsigned ft_tsec  : 5;
  unsigned ft_min   : 6;
  unsigned ft_hour  : 5;
  unsigned ft_day   : 5;
  unsigned ft_month : 4;
  unsigned ft_year  : 7;
};

/* Headers definitions */

struct MarkHeader
{
  UBYTE Mark[5];
  UWORD HeadSize;
};

struct ArchiveHeader
{
  UWORD  HeadCRC;
  UBYTE  HeadType;
  UWORD  Flags;
  UWORD  HeadSize;
  UBYTE  Reserved[6];
};

struct FileHeader
{
  UWORD  HeadCRC;
  UBYTE  HeadType;
  UWORD  Flags;
  UWORD  HeadSize;
  UDWORD PackSize;
  UDWORD UnpSize;
  UBYTE  HostOS;
  UDWORD FileCRC;
  struct dos_ftime FileTime;
  UBYTE  UnpVer;
  UBYTE  Method;
  UWORD  NameSize;
  UDWORD FileAttr;
};
