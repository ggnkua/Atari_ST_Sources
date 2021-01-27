/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include	<string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;
EXTERN  VOID 	log_redraw ( WINDOW_INFO *inf );
EXTERN  VOID 	clear_text ( LOG *log );

/* ------------------------------------------------------------------- */

BOOL xOpenLogWindow ( LONG win_id, BYTE *title, BYTE *info, INT anz_trees, XTREE *trees, INT columns, INT rows, INT x, INT y, VOID *user, APROC action )

{
  WINDOW        *win;
  XWIN          xwin;
  LONG          size;
  FONT          *f;

  InitXWindow ( &xwin );

  xwin.font_id   = sysgem.confont_hid;
  xwin.font_pt   = sysgem.confont_hpt;
  columns        = max ( 5, columns );
  rows           = max ( 3, rows );
  size           = (LONG)( rows * ( columns + 2 ));
  xwin.id        = win_id;
  xwin.flags     = NAME | MOVER | CLOSER | ICONIFIER;		/* [GS] */
  xwin.cfg       = 0;
  xwin.anz_trees = anz_trees;
  xwin.trees     = trees;
  xwin.user      = user;

  if ( VectorFont ( xwin.font_id ))
    {
      f = sysgem.font;
      while ( f != NULL )
        {
          if ( f->vektor == 0 )
            {
              xwin.font_id = f->id;
              break;
            }
          f = f->next;
        }
    }

  SetFont ( xwin.font_id, xwin.font_pt );
  xwin.scr_x    = StringWidth ( "W" );
  xwin.scr_y    = StringHeight ();
  xwin.work.x   = x;
  xwin.work.y   = y;
  xwin.work.w   = StringWidth ( "W" ) * columns;
  xwin.work.h   = StringHeight () * rows;
  xwin.name     = title;
  xwin.info     = info;
  NormalFont ();
  xwin.waction  = action;
  xwin.redraw   = log_redraw;
  xwin.owner    = 'golX';

  if ( info != NULL )
    {
      if ( info [0] != 0 ) xwin.flags |= INFO;
    }
  if ( XWindow ( &xwin ))
    {
      win = find_window ( -1, win_id );
      if ( win != NULL )
        {
          excl ( win->flags, WIN_VISIBLE );
          win->log.txt = (BYTE *) Allocate ( size );
          if ( win->log.txt == NULL )
            {
              DestroyWindow ( win, TRUE );
              return ( FALSE );
            }
          win->user2        = win;
          win->log.x        = 0;
          win->log.y        = 0;
          win->log.col      = columns;
          win->log.row      = rows;
          SetFont ( win->font_id, win->font_pt );
          win->log.w        = StringWidth ( "W" );
          win->log.h        = StringHeight ();
          NormalFont ();
          win->log.pt       = win->log.txt;
          win->log.line_len = columns + 1;
          win->log.cursor   = 0;
          clear_text ( &win->log );

          SendMessage ( SG_START, win, NULL, NULL, 0, 0, 0, 0 );
          incl ( win->flags, WIN_VISIBLE );

          DispatchEvents ();
          DispatchEvents ();
          DispatchEvents ();

          SetXTimer   ( win_id, do_blink, 500, 0, win, NULL );
          return ( TRUE );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */
