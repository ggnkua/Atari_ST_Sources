/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

LOCAL	BOOL	wdialok;
LOCAL	DPROC	wdialp;

/* ------------------------------------------------------------------- */

INT wdproc ( INT msg, INT button, DIALOG_INFO *inf )

{
  INT	i;
  
  if ( wdialp != NULL )
    {
      i = wdialp ( msg, button, inf );
      if ( i == SG_CLOSE ) wdialok = TRUE;
      if ( i == SG_TERM  ) wdialok = TRUE;
      return ( i );
    }
  else
    {
      if ( msg == SG_END )
        {
          wdialok = TRUE;
          return ( SG_CLOSE );
        }
    }
  return ( SG_CONT );
}

/* ------------------------------------------------------------------- */

BOOL xWindowDialog ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, BOOL shut, BOOL force, OBJECT *tree, OBJECT *menu, INT edit, VOID *user, DPROC proc )

{
  wdialok = FALSE;
  wdialp  = proc;
  force   = TRUE;
  if ( WindowDialog ( id, xpos, ypos, name, info, shut, force, tree, menu, edit, user, wdproc ))
    {
      forever
        {
          HandleEvents ();
          if ( wdialok ) break;
        }
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */
