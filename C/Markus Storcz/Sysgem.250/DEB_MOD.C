/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1995, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <stdio.h>
#include        <string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

LOCAL	LONG	modspy_id;

/* ------------------------------------------------------------------- */

LOCAL VOID SpyModule ( INT status, MODULE *mod, INT cmd, INT user, VOID *p, LONG result )

/*
-----------------------------------------------------------------------------
-> -------------------- cmd = 12345 user = 12345 p = 12345678 res = 12345678
*/
{
  BYTE	*x;

  x = "?????";  
  if ( cmd == SGM_IDENTIFY ) x = "IDENT";
  if ( cmd == SGM_INIT     ) x = "INIT ";
  if ( cmd == SGM_START    ) x = "START";
  if ( cmd == SGM_QUIT     ) x = "QUIT ";
  if ( cmd == SGM_USER     ) x = "USER ";

  if ( status == 0 )
    {
      wprintf ( modspy_id, "-> %-10.10s msg = %s user = %5d p = %8lx\n", mod->name, x, user, p );
    }
  else
    {
      wprintf ( modspy_id, "<- %-10.10s msg = %s user = %5d p = %8lx res = %ld\n", mod->name, x, user, p, result );
    }
}

/* ------------------------------------------------------------------- */

VOID DebugTheModule ( INT x, INT y )

{
  modspy_id = 'MSpy';
  sysgem.spy_module = SpyModule;
  OpenLogWindow ( modspy_id, "Module-Debug", "", 68, 25, x, y, (APROC) NULL ); /* [GS] */
}

/* ------------------------------------------------------------------- */
