/*
**
** Dies sind die globalen Prozeduren des CD-XFS fuer MagiX
** Entwickelt mit PureC und Pasm.
**
** (C) Andreas Kromke 1997
**
**
*/

#include <portab.h>
#include <stddef.h>
#include <tosdefs.h>
#include <tos.h>
#include <magx.h>
#include "mgx_xfs.h"

/* Hier die Assembler-Schnittstelle */

extern MX_XFS cdxfs;
extern MX_DEV cddev;
extern void cdecl kernel__sprintf( char *dst, char *src, LONG *data );
extern void * cdecl kernel_int_malloc( void );
extern void cdecl kernel_int_mfree( void *block );
extern LONG cdecl kernel_diskchange( WORD drv );
extern LONG cdecl kernel_proc_info( WORD code, PD *pd );
extern void cdecl kernel_conv_8_3( char *from, char to[11] );
extern WORD cdecl kernel_match_8_3( char *patt, char *fname );