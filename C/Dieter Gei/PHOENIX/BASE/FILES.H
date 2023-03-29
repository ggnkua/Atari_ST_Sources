/*****************************************************************************
 *
 * Module : FILES.H
 * Author : Dieter Geiﬂ
 *
 * Creation date    : 06.03.89
 * Last modification: 25.05.96
 *
 *
 * Description: This module defines the file management routines.
 *
 * History:
 * 25.05.96: Defines for LFN for GEMDOS added
 * 21.02.93: Defines for multiple declaration of type FILENAME added
 * 14.11.92: Functions reordered
 * 10.11.92: Function file_locked added
 * 03.11.92: Modifications for NT added
 * 02.11.92: MAX_FULLNAME changed to 255
 * 31.10.92: Far pointer definitions for DLL implementation added
 * 25.10.92: Module header added
 * 06.03.89: Creation of body
 *****************************************************************************/

#ifndef _FILES_H
#define _FILES_H

#ifdef __cplusplus
extern "C" {
#endif

#if MSDOS | NT | OS2
#include <fcntl.h>
#endif

#if UNIX
#if XL_C
#include <fcntl.h>
#else
#include <sys/fcntl.h>
#endif
#endif

/****** DEFINES **************************************************************/

#if GEMDOS | MSDOS | NT | OS2 | FLEXOS
#ifndef DRIVESEP
#define DRIVESEP        ':'
#define PATHSEP         '\\'
#define SUFFSEP         '.'
#endif

#if GEMDOS
#ifndef LFN
#define LFN               1
#else
#define LFN               0
#endif
#endif /* GEMDOS */

#ifndef MAX_FILENAME
#if NT | LFN
#define MAX_FILENAME    255
#define MAX_EXT         255
#else
#define MAX_FILENAME     12
#define MAX_EXT           3
#endif
#define MAX_FULLNAME    255
#endif

#define READ_TXT        "r"
#define WRITE_TXT       "w"
#define APPEND_TXT      "a"

#define READ_BIN        "rb"
#define WRITE_BIN       "wb"
#define APPEND_BIN      "ab"

#define RDWR_OLD_TXT    "r+"
#define RDWR_NEW_TXT    "w+"
#define RDWR_APPEND_TXT "a+"

#define RDWR_OLD_BIN    "r+b"
#define RDWR_NEW_BIN    "w+b"
#define RDWR_APPEND_BIN "a+b"
#endif

#if UNIX
#ifndef DRIVESEP
#define DRIVESEP        '@'             /* actually there's no drive */
#define PATHSEP         '/'
#define SUFFSEP         '.'
#endif

#ifndef MAX_FILENAME
#define MAX_FILENAME     14
#define MAX_FULLNAME    255
#define MAX_EXT          14
#endif

#define READ_TXT        "r"
#define WRITE_TXT       "w"
#define APPEND_TXT      "a"

#define READ_BIN        "r"
#define WRITE_BIN       "w"
#define APPEND_BIN      "a"

#define RDWR_OLD_TXT    "r+"
#define RDWR_NEW_TXT    "w+"
#define RDWR_APPEND_TXT "a+"

#define RDWR_OLD_BIN    "r+"
#define RDWR_NEW_BIN    "w+"
#define RDWR_APPEND_BIN "a+"
#endif

#if GEMDOS | NT | MSDOS | OS2 | UNIX
#ifndef _WINDOWS
#define HFILE           INT
#endif
#endif

#if FLEXOS
#define HFILE           LONG
#endif

#define FHANDLE         HFILE		/* obsolete */

#ifndef O_RDONLY
#define O_RDONLY        0x0000
#define O_WRONLY        0x0001
#define O_RDWR          0x0002
#endif

#define O_SHARED        0x8000

#ifndef SEEK_SET
#define SEEK_SET        0
#define SEEK_CUR        1
#define SEEK_END        2
#endif

/****** TYPES ****************************************************************/

#ifndef _FILENAME_DEFINED
typedef CHAR FILENAME [MAX_FILENAME + 1];
typedef CHAR FULLNAME [MAX_FULLNAME + 1];
typedef CHAR EXT [MAX_EXT + 1];
#define _FILENAME_DEFINED
#endif

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL HFILE WINAPI file_create _((LPSTR filename));
GLOBAL HFILE WINAPI file_open   _((LPSTR filename, INT mode));
GLOBAL INT   WINAPI file_close  _((HFILE handle));
GLOBAL LONG  WINAPI file_read   _((HFILE handle, LONG count, HPVOID buf));
GLOBAL LONG  WINAPI file_write  _((HFILE handle, LONG count, HPVOID buf));
GLOBAL LONG  WINAPI file_seek   _((HFILE handle, LONG offset, INT mode));
GLOBAL BOOL  WINAPI file_eof    _((HFILE handle));
GLOBAL BOOL  WINAPI file_lock   _((HFILE handle, LONG offset, LONG count, BOOL wait));
GLOBAL BOOL  WINAPI file_unlock _((HFILE handle, LONG offset, LONG count));
GLOBAL BOOL  WINAPI file_locked _((HFILE handle, LONG offset, LONG count));
GLOBAL BOOL  WINAPI file_remove _((LPCSTR filename));
GLOBAL BOOL  WINAPI file_rename _((LPCSTR oldname, LPCSTR newname));
GLOBAL LONG  WINAPI file_length _((LPCSTR filename));
GLOBAL BOOL  WINAPI file_exist  _((LPCSTR filename));
GLOBAL VOID  WINAPI file_split  _((LPSTR fullname, LPINT drive, LPSTR path, LPSTR filename, LPSTR ext));

GLOBAL INT   WINAPI get_drive   _((VOID));
GLOBAL INT   WINAPI set_drive   _((INT drive));
GLOBAL BOOL  WINAPI get_path    _((LPSTR path));
GLOBAL BOOL  WINAPI get_dpath   _((INT drive, LPSTR path));
GLOBAL BOOL  WINAPI set_path    _((LPCSTR path));

GLOBAL BOOL  WINAPI path_exist  _((LPCSTR path));
GLOBAL BOOL  WINAPI path_create _((LPCSTR path));
GLOBAL BOOL  WINAPI path_remove _((LPCSTR path));

#ifndef _WINDLL
GLOBAL BOOL  WINAPI text_rdln   _((FILE *file, LPSTR s, SIZE_T maxlen));
GLOBAL BOOL  WINAPI text_write  _((FILE *file, LPSTR s));
GLOBAL BOOL  WINAPI text_wrln   _((FILE *file, LPSTR s));
#endif

#ifdef __cplusplus
}
#endif

#endif /* _FILES_H */

