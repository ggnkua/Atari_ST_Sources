/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

LOCAL   LONG    result_id;
LOCAL   INT     result_bt;

/* ------------------------------------------------------------------- */

INT sgem_hdl_dialog ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_END : result_id = inf->id;
                    result_bt = button;
                    break;
    }
  return ( SG_CONT );
}

/* ------------------------------------------------------------------- */

BOOL BeginDialog ( LONG win_id, OBJECT *tree, INT edit, BYTE *title )

{
  return ( WindowDialog ( win_id, -1, -1, title, "", FALSE, TRUE, tree, NULL, edit, NULL, sgem_hdl_dialog ));
}

/* ------------------------------------------------------------------- */

INT HandleDialog ( LONG win_id )

{
  if ( find_window ( -1, win_id ) == NULL ) return ( -1 );
  forever
    {
      result_id = 0L;
      result_bt = 0;

      HandleEvents ();

      if ( result_id == win_id )
        {
          return ( result_bt );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID FinishDialog ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      DestroyWindow ( win, TRUE );
    }
}

/* ------------------------------------------------------------------- */

INT DoDialog ( OBJECT *tree, INT edit, BYTE *title )

{
  LONG  win_id = 'xdlg';
  INT   i;

  if ( BeginDialog ( win_id, tree, edit, title ))
    {
      i = HandleDialog ( win_id );
      FinishDialog ( win_id );
      return ( i );
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */
