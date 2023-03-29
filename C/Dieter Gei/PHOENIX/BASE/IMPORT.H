/*****************************************************************************
 *
 * Module : IMPORT.H
 * Author : Dieter Geiß
 *
 * Creation date    : 06.03.89
 * Last modification: 02.11.96
 *
 *
 * Description: This module defines the import possibilties for modules.
 *
 * History:
 * 02.11.96: WINAPIV added
 * 25.04.96: Warning pragmas will be used in DOS version also
 * 13.02.96: Defintion of WS_EX_CLIENTEDGE added
 * 11.02.96: Warning C4310 disabled
 * 07.01.96: FORWARD_WM_HSCROLL/VSCROLL definitions for WIN32 removed
 * 03.01.96: Definitons for COLOR_3DDKSHADOW added
 * 01.01.96: OEMRESOURCE always defined before including windows.h
 * 27.12.95: Include file shellapi.h always included
 * 26.12.95: Warning pragmas moved to beginning of file
 * 09.12.94: More warning pragmas added for include files of MSVC 2.0
 * 17.01.94: _INC_SHELLAPI defined to include HANDLE_WM_DROPFILES in windowsx.h
 * 27.09.93: Problems with labs and fabs (non ANSI) fixed
 * 22.09.93: Definition for HINSTANCE_ERROR removed
 * 27.07.93: VER.H/WINNT.H included for definition of SHORT
 * 22.05.93: Warning C4001 disabled because of App Studio using single line comments
 * 18.05.93: Macro INVALID_ATOM added
 * 31.01.93: Warning C4214 disabled because of DDE.H
 * 11.01.93: APIENTRY added
 * 24.11.92: WIN32 capability added
 * 22.11.92: PC GEM capability removed
 * 26.10.92: CALLBACK added
 * 25.10.92: Module header added
 * 06.03.89: Creation of body
 *****************************************************************************/

#ifndef _IMPORT_H
#define _IMPORT_H

#ifdef WIN32
#ifndef _WINDOWS
#define _WINDOWS
#endif
#endif

#ifdef _MSC_VER
#if (_MSC_VER >= 700)
#pragma warning (disable:4001)			/* nonstandard extension 'single line comment' was used */
#pragma warning (disable:4050)			/* different code attributes */
#pragma warning (disable:4100)			/* unused parameters */
#pragma warning (disable:4115)			/* named type definition in parentheses */
#pragma warning (disable:4131)			/* uses old-style declarator */
#pragma warning (disable:4201)			/* nonstandard extension used : nameless struct/union */
#pragma warning (disable:4209)			/* nonstandard extension used : benign typedef redefinition */
#pragma warning (disable:4214)			/* nonstandard extension used : bit field types other than int */
#pragma warning (disable:4244)			/* conversion from 'int' to 'short', possible loss of data */
#pragma warning (disable:4310)			/* cast truncates constant value */
#pragma warning (disable:4127)			/* conditional expression is constant */
#pragma warning (disable:4514)			/* unreferenced inline function has been removed */
#endif
#endif

#ifdef _WINDOWS
#ifdef NULL
#undef NULL
#endif

#define NOCOMM
#define STRICT
#define OEMRESOURCE

#include <windows.h>

#ifndef _INC_SHELLAPI
#include <shellapi.h>				/* to include HANDLE_WM_DROPFILES in windowsx.h */
#endif

#include <windowsx.h>

#ifdef WIN32
#include <winnt.h>
#else
#include <ver.h>
#endif

#define _(params) params

#ifndef COLOR_3DDKSHADOW			/* new Windows 95 definitions */
#define COLOR_3DDKSHADOW        21
#define COLOR_3DLIGHT           22
#define COLOR_INFOTEXT          23
#define COLOR_INFOBK            24

#define COLOR_DESKTOP           COLOR_BACKGROUND
#define COLOR_3DFACE            COLOR_BTNFACE
#define COLOR_3DSHADOW          COLOR_BTNSHADOW
#define COLOR_3DHIGHLIGHT       COLOR_BTNHIGHLIGHT
#define COLOR_3DHILIGHT         COLOR_BTNHIGHLIGHT
#define COLOR_BTNHILIGHT        COLOR_BTNHIGHLIGHT

#define WS_EX_CLIENTEDGE        0x00000200L
#endif

#ifdef WIN32					/* wrong definitions */
#undef FORWARD_WM_MDISETMENU
#define FORWARD_WM_MDISETMENU(hWnd, fRefresh, hmenuFrame, hmenuWindow, fn)	(HMENU)(UINT)(DWORD)(fn)((hWnd), WM_MDISETMENU, (WPARAM)((fRefresh) ? 0 : (hmenuFrame)), (LPARAM)(hmenuWindow))

#define DlgDirSelect(hDlg, lpString, nIDListBox)	DlgDirSelectEx (hDlg, lpString, sizeof (FULLNAME), nIDListBox)
#define GetTextExtent(hDC, lpString, nCount)		GetTabbedTextExtent (hDC, lpString, nCount, 0, NULL)
#define GetFreeSystemResources(fuSysResource)		100
#define MoveTo(hDC, X, Y)				MoveToEx (hDC, X, Y, NULL)
#define SetBrushOrg(hDC, X, Y)				SetBrushOrgEx (hDC, X, Y, NULL)
#define SetViewportExt(hDC, X, Y)			SetViewportExtEx (hDC, X, Y, NULL)
#define SetViewportOrg(hDC, X, Y)			SetViewportOrgEx (hDC, X, Y, NULL)
#define SetWindowExt(hDC, X, Y)				SetWindowExtEx (hDC, X, Y, NULL)
#define SetWindowOrg(hDC, X, Y)				SetWindowOrgEx (hDC, X, Y, NULL)
#define UnrealizeObject(hgdiobj)

typedef RGBQUAD		*LPRGBQUAD;
#else
#define WINAPIV		FAR
#define APIENTRY	WINAPI
#define APIPRIVATE	WINAPI
#define INVALID_ATOM	((ATOM)0)
#endif
#else
#define CALLBACK
#define WINAPI
#define WINAPIV
#define APIENTRY
#define APIPRIVATE
#endif

#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <portab.h>

#if GEMDOS
#include <aes.h>
#include <vdi.h>
#if TURBO_C
#include <tos.h>
#else
#include <osbind.h>
#endif
#define Mavail() (LONG)Malloc (-1L)
#endif

#if MSDOS
#ifdef _WINDOWS
#if TURBO_C
#undef NULL
#define NULL 0					/* like Microsoft's WINDOWS.H */
#endif
#else
#define _(params) params
#ifdef PASCAL
#undef PASCAL
#define PASCAL
#endif
#endif
#endif

#if FLEXOS
#include <gemdos.h>
#include <dosbind.h>
#endif

#if OS2
#define INCL_DOS
#include <os2.h>
#define Mavail() (64 * 1024L)			/* in OS2 there's no way to decide free memory */
#endif

#if UNIX
#include <sys/types.h>
#define Mavail() (64 * 1024L)			/* in UNIX there's no way to decide free memory */
#endif

#if ANSI
#include <stdlib.h>
#else
#define abs(x)      ((x) < 0 ? -(x) : (x))
#define labs(x)     (LONG)abs (x)
#define fabs(x)     (DOUBLE)abs (x)
#endif

/****** DEFINES **************************************************************/

#ifdef GLOBAL
#undef GLOBAL
#endif

#define GLOBAL EXTERN

#if HIGH_C
#ifdef NULL
#undef NULL
#define NULL 0L
#endif
#endif

#ifndef max
#define max(a,b)    (((a) > (b)) ? (a) : (b))
#define min(a,b)    (((a) < (b)) ? (a) : (b))
#endif

#define odd(i)      ((i) & 1)

/****** TYPES ****************************************************************/

#ifndef _WINDOWS
typedef VOID       FAR *LPVOID;
typedef INT        FAR *LPINT;
typedef LONG       FAR *LPLONG;
typedef CHAR       FAR *LPSTR;
typedef CONST CHAR FAR *LPCSTR;
#endif

typedef CHAR   FAR *LPCHAR;
typedef SHORT  FAR *LPSHORT;
typedef UCHAR  FAR *LPUCHAR;
typedef USHORT FAR *LPUSHORT;
typedef ULONG  FAR *LPULONG;
typedef FLOAT  FAR *LPFLOAT;
typedef DOUBLE FAR *LPDOUBLE;
typedef BOOL   FAR *LPBOOL;

typedef VOID   HUGE *HPVOID;
typedef CHAR   HUGE *HPCHAR;
typedef SHORT  HUGE *HPSHORT;
typedef LONG   HUGE *HPLONG;
typedef UCHAR  HUGE *HPUCHAR;
typedef USHORT HUGE *HPUSHORT;
typedef ULONG  HUGE *HPULONG;
typedef FLOAT  HUGE *HPFLOAT;
typedef DOUBLE HUGE *HPDOUBLE;
typedef BOOL   HUGE *HPBOOL;

/*****************************************************************************/

#endif /* _IMPORT_H */

