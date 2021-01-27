/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        "sgem.h"
#include        <string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

LOCAL   BYTE    buffer  [40][50];						/* [GS] alt: 50,50	*/
LOCAL   INT     anz             = 0;
LOCAL   INT     line            = 0;

/* ------------------------------------------------------------------- */

LOCAL   LONG    cyc_id          = 'sgcy';

/* ------------------------------------------------------------------- */

#define         rsc_main        sysgem.cycle_win

/* ------------------------------------------------------------------- */

EXTERN	INT SearchServer ( VOID );

/* ------------------------------------------------------------------- */

LOCAL VOID MakeBuffer ( VOID )

{
  WINDOW        *win;
  INT           old;

  memset ( buffer, 0, sizeof ( buffer ));
  old = anz;
  win = sysgem.window;
  anz = 0;
  while ( win != NULL )
    {
      if ( win->id != cyc_id )
        {
          sprintf ( buffer [anz], "%c%c%c%cn %-40.40s ", (BYTE)( win->id >> 24 ), (BYTE)( win->id >> 16 ), (BYTE)( win->id >> 8 ), (BYTE)( win->id ), win->show );
          buffer [anz][4] = 0;
          anz++;
        }
      if ( anz > 39 ) break;						/* [GS] */
      win = win->next;
    }
  if ( GetHandle ( cyc_id ) != -1 )
    {
      AddSliderItem ( rsc_main, CY_BOX, anz - old );
    }
}

/* ------------------------------------------------------------------- */

LOCAL INT HandleCycle ( INT msg, INT button, DIALOG_INFO *inf )

{
  switch ( msg )
    {
      case SG_START     : MakeBuffer ();
                          LinkSlider    ( rsc_main, CY_UP, CY_DN, CY_SHOW, CY_HIDE, anz, CY_BOX, &buffer [0][5], 50, 0 );
                          SelectSldItem ( rsc_main, CY_BOX, 0, FALSE );
                          line = 0;
                          break;
      case SG_SLIDER    : if ( button != line )
                            {
                              SelectSldItem ( rsc_main, CY_BOX, button, TRUE );
                              line = button;
                            }
                          break;
      case SG_SLIDER2   : line = button;
      case SG_END       : UnLinkSlider ( rsc_main, CY_BOX );
                          if ( button == CY_OK )
                            {
                              DestroyWindow ( find_window ( -1, cyc_id ), TRUE );
                              TopWindow     ( GetHandle ( *(LONG *)( &buffer [line][0] )));
                            }
			case SG_UNDO			: return ( SG_CLOSE );						/* [GS] */
      case SG_DRAGDROP  : if ( inf );
                          break;
    }
  return ( SG_CONT );
}

/* ------------------------------------------------------------------- */

VOID CycleWindow ( BOOL show_window )

{
  WINDOW        *win;
  INT   	msg [8];

  anz  = 0;
  line = 0;
  if ( CountWindows () == 0 ) return;
  if ( show_window )
    {
      if ( sysgem.english )
        {
          ChangeButton ( rsc_main, CY_ABORT, "[Abort" );
        }
      else
        {
          ChangeButton ( rsc_main, CY_ABORT, "[Abbruch" );
        }
      WindowDialog ( cyc_id, -1, -1, "Top-Window", "", FALSE, TRUE, rsc_main, NULL, 0, NULL, HandleCycle );
    }
  else
    {
      sysgem.gemini = SearchServer ();
      if ( sysgem.gemini != -1 )
        {
          msg [0] = 0x4710;
          msg [1] = sysgem.appl_id;
          msg [2] = 0;
          msg [3] = K_CTRL;
          msg [4] = 0x1117;
          msg [5] = 0;
          msg [6] = 0;
          msg [7] = 0;
          appl_write ( sysgem.gemini, 16, msg );
          evnt_timer  ( 5, 0 );
          return;
        }
      win = find_window ( GetTopWindow (), 0L );
      if ( win != NULL )
        {
          if ( win->next == NULL )
            {
              win = sysgem.window;
            }
          else
            {
              win = win->next;
            }
          TopWindow ( win->handle );
        }
    }
}

/* ------------------------------------------------------------------- */
