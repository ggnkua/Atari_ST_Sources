/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber			IBM PC Ver 0.1,	Jun. 1989    *
******************************************************************************
* Module to emulate a printf with a possible quite (disable mode.)           *
* A global variable GifQuitePrint controls the printing of this routine      *
******************************************************************************
* History:								     *
* 12 May 91 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#include <stdio.h>

#ifdef USE_VARARGS
#include <varargs.h>
#else
#include <stdarg.h>
#endif /* USE_VARARGS */

#include "gif_lib.h"

#ifdef __MSDOS__
int GifQuitePrint = FALSE;
#else
int GifQuitePrint = TRUE;
#endif /* __MSDOS__ */

/*****************************************************************************
* Same as fprintf to stderr but with optional print.			     *
*****************************************************************************/
#ifdef USE_VARARGS
void GifQprintf(int va_alist)
{
    char *Format, Line[128];
    va_list ArgPtr;

    va_start(ArgPtr);
    Format = va_arg(ArgPtr, char *);
#else
void GifQprintf(char *Format, ...)
{
    char Line[128];
    va_list ArgPtr;

    va_start(ArgPtr, Format);
#endif /* USE_VARARGS */

    if (GifQuitePrint) return;

    vsprintf(Line, Format, ArgPtr);
    va_end(ArgPtr);

    fputs(Line, stderr);
}
