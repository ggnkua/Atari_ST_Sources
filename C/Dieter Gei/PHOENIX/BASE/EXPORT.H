/*****************************************************************************
 *
 * Module : EXPORT.H
 * Author : Dieter Geiß
 *
 * Creation date    : 06.03.89
 * Last modification: 04.11.96
 *
 *
 * Description: This module defines the export possibilties for modules.
 *
 * History:
 * 04.11.96: __declspec (dllexport) added for WIN32 DLL's exported WINAPI functions
 * 04.02.94: EXPORT is used instead of LOADDS in DLL's exported WINAPI functions
 * 10.01.93: APIENTRY added
 * 01.11.92: Export capabilities for DLLs added
 * 26.10.92: Module header added
 * 06.03.89: Creation of body
 *****************************************************************************/

#ifndef _EXPORT_H
#define _EXPORT_H

#ifdef GLOBAL
#undef GLOBAL
#endif

#define GLOBAL

#if (_MSC_VER >= 700)
#define EXPORT __export
#define LOADDS __loadds
#else
#define EXPORT _export
#define LOADDS
#endif

#ifdef _WINDOWS
#ifdef WIN32
#ifdef USE_DECLSPEC
#if (_MSC_VER >= 800) || defined(_STDCALL_SUPPORTED)
#ifdef _WINDLL
#define CALLBACK                          __stdcall
#define WINAPI     __declspec (dllexport) __stdcall
#define WINAPIV    __declspec (dllexport) __cdecl
#define APIENTRY   __declspec (dllexport) __stdcall
#define APIPRIVATE                        __stdcall
#else
#define CALLBACK                          __stdcall
#define WINAPI                            __stdcall
#define WINAPIV                           __cdecl
#define APIENTRY                          __stdcall
#define APIPRIVATE                        __stdcall
#endif /* _WINDLL */
#else
#define CALLBACK
#define WINAPI
#define WINAPIV
#define APIENTRY
#define APIPRIVATE
#endif /* USE_DECLSPEC */
#endif /* WIN32 */
#else
#undef CALLBACK
#undef WINAPI
#undef WINAPIV
#undef APIENTRY
#undef APIPRIVATE

#ifdef _WINDLL
#define CALLBACK   LOADDS FAR PASCAL
#define WINAPI     EXPORT FAR PASCAL
#define WINAPIV    EXPORT FAR
#define APIENTRY   EXPORT FAR PASCAL
#define APIPRIVATE LOADDS FAR PASCAL
#else
#define CALLBACK   EXPORT FAR PASCAL
#define WINAPI     EXPORT FAR PASCAL
#define WINAPIV    EXPORT FAR
#define APIENTRY   EXPORT FAR PASCAL
#define APIPRIVATE        FAR PASCAL
#endif /* _WINDLL */
#endif /* WIN32 */
#endif /* _WINDOWS */

#endif /* _EXPORT_H */

