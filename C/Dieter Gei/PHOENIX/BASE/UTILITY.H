/*****************************************************************************
 *
 * Module : UTILITY.H
 * Author : Dieter Geiﬂ
 *
 * Creation date    : 06.03.89
 * Last modification: 26.05.95
 *
 *
 * Description: This module defines the utility routines.
 *
 * History:
 * 26.05.95: Function mem_realloc added
 * 31.07.93: Functions oem_to_ansi, ansi_to_oem, ansi_upper, and ansi_strcmp added
 * 31.10.92: Far pointer definitions for DLL implementation added
 * 25.10.92: Module header added
 * 06.03.89: Creation of body
 *****************************************************************************/

#ifndef __UTILITY_H
#define __UTILITY_H

#ifdef __cplusplus
extern "C" {
#endif

/****** DEFINES **************************************************************/

#define WILD_CHARS  '*'                 /* any chars */
#define WILD_CHAR   '?'                 /* any char */
#define WILD_DIGIT  '#'                 /* any digit */

/****** TYPES ****************************************************************/

typedef struct
{
  UCHAR  day;
  UCHAR  month;
  USHORT year;
} DATE;

typedef DATE HUGE *HPDATE;

typedef struct
{
  UCHAR hour;
  UCHAR minute;
  UCHAR second;
  UCHAR unused;
  LONG  micro;
} TIME;

typedef TIME HUGE *HPTIME;

typedef struct
{
  DATE date;
  TIME time;
} TIMESTAMP;

typedef TIMESTAMP HUGE *HPTIMESTAMP;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL HPVOID WINAPI mem_alloc   _((LONG mem));
GLOBAL HPVOID WINAPI mem_realloc _((HPVOID memptr, LONG mem));
GLOBAL VOID   WINAPI mem_free    _((HPVOID memptr));
GLOBAL LONG   WINAPI mem_avail   _((VOID));
GLOBAL HPVOID WINAPI mem_set     _((HPVOID dest, INT val, USHORT len));
GLOBAL HPVOID WINAPI mem_move    _((HPVOID dest, CONST HPVOID src, USHORT len));
GLOBAL HPVOID WINAPI mem_lset    _((HPVOID dest, INT val, ULONG len));
GLOBAL HPVOID WINAPI mem_lmove   _((HPVOID dest, CONST HPVOID src, ULONG len));

GLOBAL INT    WINAPI str_match   _((LPSTR s1, LPSTR s2));
GLOBAL LPSTR  WINAPI str_upr     _((LPSTR s));
GLOBAL LPSTR  WINAPI str_lwr     _((LPSTR s));
GLOBAL LPSTR  WINAPI str_upper   _((LPSTR s));
GLOBAL LPSTR  WINAPI str_lower   _((LPSTR s));
GLOBAL LPSTR  WINAPI str_ascii   _((LPSTR s));
GLOBAL LPSTR  WINAPI str_rmchar  _((LPSTR s, INT c));
GLOBAL LPSTR  WINAPI chrcat      _((LPSTR s, CHAR c));
GLOBAL USHORT WINAPI ch_upper    _((USHORT c));
GLOBAL USHORT WINAPI ch_lower    _((USHORT c));
GLOBAL USHORT WINAPI ch_ascii    _((USHORT c));
GLOBAL VOID   WINAPI oem_to_ansi _((HPCHAR oem, HPCHAR ansi));
GLOBAL VOID   WINAPI ansi_to_oem _((HPCHAR ansi, HPCHAR oem));
GLOBAL HPCHAR WINAPI ansi_upper  _((HPCHAR s));
GLOBAL INT    WINAPI ansi_strcmp _((HPCHAR s1, HPCHAR s2));

GLOBAL HPCHAR WINAPI hstrcat     _((HPCHAR s1, HPCHAR s2));
GLOBAL INT    WINAPI hstrcmp     _((HPCHAR s1, HPCHAR s2));
GLOBAL HPCHAR WINAPI hstrcpy     _((HPCHAR s1, HPCHAR s2));
GLOBAL ULONG  WINAPI hstrlen     _((HPCHAR s));
GLOBAL HPCHAR WINAPI hstrncat    _((HPCHAR s1, HPCHAR s2, ULONG count));
GLOBAL HPCHAR WINAPI hstrncpy    _((HPCHAR s1, HPCHAR s2, ULONG count));

GLOBAL VOID   WINAPI get_date    _((HPDATE dateptr));
GLOBAL VOID   WINAPI get_time    _((HPTIME timeptr));
GLOBAL VOID   WINAPI get_tstamp  _((HPTIMESTAMP timestamp));

#ifdef __cplusplus
}
#endif

#endif /* __UTILITY_H */

