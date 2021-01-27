/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include				<string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;
EXTERN  VOID    *xusr1;
EXTERN  RECT    sg_clip_r;

/* ------------------------------------------------------------------- */

LOCAL   BYTE            sgl_out         [500];
LOCAL   WINDOW_INFO     linf;

/* ------------------------------------------------------------------- */

VOID clear_text ( LOG *log )

{
  REG   INT     i;
  REG   BYTE    *p;
  REG   INT     size;

  size = log->row * log->line_len;

  p = log->txt;
  for ( i = 0; i <= size; i++ ) *p++ = ' ';

  p = log->txt + (LONG)( log->line_len - 1 );
  for ( i = 0; i < log->row; i++ )
    {
      *p = 0;
      p += (LONG)( log->line_len );
    }
}

/* ------------------------------------------------------------------- */

LOCAL VOID move_up ( LOG *log )

{
  REG   BYTE    *p;
  REG   BYTE    *q;
  REG   INT     i;
  REG   INT     size;

  size = ( log->row - 1 ) * log->line_len;

  p = log->txt;
  q = log->txt + (LONG)( log->line_len );
  for ( i = 0; i <= size; i++ )
    {
      *p++ = *q++;
    }
  p = log->txt + (LONG)(( log->row - 1 ) * log->line_len );
  for ( i = 0; i < log->col; i++ ) *p++ = ' ';
  *p = 0;
}

/* ------------------------------------------------------------------- */

LOCAL VOID move_down ( LOG *log )

{
  REG   BYTE    *p;
  REG   BYTE    *q;
  REG   INT     i;
  REG   INT     size;

  size = ( log->row - 1 ) * log->line_len;
  p    = log->txt;
  q    = log->txt + (LONG)( log->line_len );
  memcpy ( q, p, (LONG)( size ));
  p = log->txt;
  for ( i = 0; i < log->col; i++ ) *p++ = ' ';
  *p = 0;
}

/* ------------------------------------------------------------------- */

LOCAL INT slen ( BYTE *src )

{
  REG   BYTE    *s;
  REG   INT     i;

  i = 0;
  s = src;
  while ( *s )
    {
      i++;
      s++;
    }
  return ( i );
}

/* ------------------------------------------------------------------- */

VOID log_redraw ( WINDOW_INFO *inf )

{
  REG   BYTE    *p;
  REG   INT     i;
  REG   INT     row;
        RECT    *r;
        WINDOW  *win;
        INT     h;
        INT     x;
        INT     y;
        INT     rh;
        LONG    w;

  win = (WINDOW *) inf->user2;
  r   = &inf->clip;

  if ( win->log.cursor == 1 )
    {
      xusr1 = win;
      do_blink ();
      SetClipping ( r );
    }
  BeginControl ( CTL_UPDATE | CTL_MHIDE );

  WhiteArea ( &inf->clip, win->back );
  SetFont   ( win->font_id, win->font_pt );

  p   = win->log.txt;
  x   = win->work.x;
  y   = win->work.y;
  h   = win->log.h;
  rh  = r->y + r->h;
  w   = (LONG)( win->log.line_len );
  row = win->log.row;

  for ( i = 0; i < row; i++ )
    {
      if ( y + h >= r->y )
        {
          v_xtext ( BLACK, x, y, p );
        }
      y += h;
      p += w;
      if ( y > rh ) break;
    }
  NormalFont ();

  EndControl ( CTL_UPDATE | CTL_MHIDE );
}

/* ------------------------------------------------------------------- */

LOCAL VOID do_xredraw_log ( WINDOW *win, VOID *p )

{
  linf.user2    = win;
  linf.clip.x   = sg_clip_r.x;
  linf.clip.y   = sg_clip_r.y;
  linf.clip.w   = sg_clip_r.w;
  linf.clip.h   = sg_clip_r.h;

  if ( p );
  log_redraw ( &linf );
}

/* ------------------------------------------------------------------- */

LOCAL VOID do_log ( WINDOW *win, LOG *log, BOOL win_top )

{
  REG   BYTE    *txt;
  REG   BYTE    *p;
        BYTE    *beg;
        BOOL    nl;
        INT     x, y, w, h;
        INT     cur;
        RECT    r;
        BOOL    open;

  x    = log->x;
  y    = log->y;
  w    = log->col;
  h    = log->row - 1;
  cur  = log->x;
  txt  = log->pt;
  beg  = sgl_out;
  p    = sgl_out;
  open = win->flags & WIN_VISIBLE;

  SetFont ( win->font_id, win->font_pt );
  if ( win->log.cursor == 1 )
    {
      xusr1 = win;
      do_blink ();
    }

  TextEffect ( 0 );
  neu_begin:
  nl  = FALSE;
  switch ( *p )
    {
      case 0    : goto ende;
      case 27   : if ( win->log.no_esc ) goto do_normal;
                  *p = 0;
                  p++;
                  *p = 0;
                  p++;
                  goto ende;
      case '\n' :
      case '\r' : if ( win->log.no_esc ) goto do_normal;
                  nl = TRUE;
                  *p = 0;
                  p++;
                  goto ende;
      default   : do_normal:
                  if ( cur < w )
                    {
                      *txt++ = *p;
                      cur++;
                    }
                  p++;
                  goto neu_begin;
    }
  ende:
  if ( p - beg > 0L )
    {
      if ( win_top )
        {
          if ( open ) v_xtext ( BLACK, ( x * log->w ) + win->work.x, ( y * log->h ) + win->work.y, beg );
        }
      else
        {
          r.x = ( x * log->w ) + win->work.x;
          r.y = ( y * log->h ) + win->work.y;
          r.w = ( cur - x ) * log->w;
          r.h = log->h;
          if ( open )
            {
              MoveWinArea ( win, &r, -1, log->w, log->h, FALSE, do_xredraw_log, win );
            }
        }
      x += slen ( beg );
    }
  if ( nl )
    {
      x = 0;
      cur = 0;
      y++;
      if ( y > h )
        {
          move_up ( &win->log );
          if ( open )
            {
              MoveWinArea ( win, &win->work, WA_DNLINE, log->w, log->h, TRUE, do_xredraw_log, win );
            }
          y = h;
        }
      txt = log->txt + (LONG)( y * log->line_len );
    }
  beg = p;
  if ( *p != 0 ) goto neu_begin;
  log->pt  = txt;
  log->x   = x;
  log->y   = y;
  NormalFont ();
}

/* ------------------------------------------------------------------- */

VOID NoEscSequence ( LONG win_id, BOOL esc )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      win->log.no_esc = esc;
    }
}

/* ------------------------------------------------------------------- */

VOID HideCursor ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if ( win->log.cursor == 1 )
        {
          xusr1 = win;
          do_blink ();
        }
      win->log.cursor = 3;
    }
}

/* ------------------------------------------------------------------- */

EXTERN	ULONG 	get_clock ( VOID );
EXTERN	XTIMER 	*find_xtm ( LONG id );

/* ------------------------------------------------------------------- */

VOID ShowCursor ( LONG win_id )

{
  WINDOW        *win;
  XTIMER	*xtm;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if ( win->log.cursor == 3 )
        {
          win->log.cursor = 0;
          xtm = find_xtm ( win_id );
          if ( xtm )
            {
              xtm->timer = get_clock ();
            }
        }
    }
}

/* ------------------------------------------------------------------- */

VOID wposxy ( LONG win_id, INT x, INT y )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if (( x < win->log.col ) && ( y < win->log.row ))
        {
          if ( win->log.cursor == 1 )
            {
              xusr1 = win;
              do_blink ();
            }
          win->log.pt = win->log.txt + (LONG)(( y * win->log.line_len ) + x );
          win->log.x  = x;
          win->log.y  = y;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID wgetxy ( LONG win_id, INT *x, INT *y )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if ( x != NULL ) *x = win->log.x;
      if ( y != NULL ) *y = win->log.y;
    }
}

/* ------------------------------------------------------------------- */

BYTE wgetchar ( LONG win_id, INT x, INT y, INT *effect )

{
  WINDOW        *win;
  BYTE          *p;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if (( x < win->log.col ) && ( y < win->log.row ))
        {
          p = win->log.txt + (LONG)(( y * win->log.line_len ) + x );

          if ( effect != NULL )
            {
              *effect = 0;
            }

          return ( *p );
        }
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

BYTE *wgetptr ( LONG win_id, INT y )

{
  WINDOW        *win;
  BYTE          *p;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if ( y < win->log.row )
        {
          p = win->log.txt + (LONG)( y * win->log.line_len );
          return ( p );
        }
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID wcls ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if ( win->log.cursor == 1 )
        {
          xusr1 = win;
          do_blink ();
        }
      clear_text ( &win->log );
      win->log.pt = win->log.txt;
      win->log.x  = 0;
      win->log.y  = 0;

      RedrawArea ( win->handle, &win->work );
    }
}

/* ------------------------------------------------------------------- */

VOID wprintf ( LONG win_id, BYTE *format, ... )

{
  va_list       arg;
  WINDOW        *win;

  va_start ( arg, format );
  vsprintf ( sgl_out, format, arg );
  va_end   ( arg );

  win = find_window ( -1, win_id );
  if ( win == NULL ) return;
  if ( win->flags & WIN_VISIBLE )
    {
      ReplaceMode ();
      BeginControl ( CTL_UPDATE | CTL_MHIDE );
      SetClipping ( &win->work );
    }
  if ( win->log.txt != NULL )
    {
      do_log ( win, &win->log, (( topped () == win ) && ( WindowVisible ( win->handle ) != FALSE )));
    }
  if ( win->flags & WIN_VISIBLE )
    {
      SetClipping ( NULL );
      EndControl ( CTL_UPDATE | CTL_MHIDE );
    }
}

/* ------------------------------------------------------------------- */

VOID winsert ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if (( win != NULL ) && ( win->log.txt != NULL ))
    {
      if ( win->log.cursor == 1 )
        {
          xusr1 = win;
          do_blink ();
        }

      if ( win->flags & WIN_VISIBLE )
        {
          ReplaceMode ();
          BeginControl ( CTL_UPDATE | CTL_MHIDE );
          SetClipping ( &win->work );
        }
      move_down ( &win->log );
      win->log.pt = win->log.txt;
      win->log.x  = 0;
      win->log.y  = 0;
      if ( win->flags & WIN_VISIBLE )
        {
          MoveWinArea ( win, &win->work, WA_UPLINE, win->log.w, win->log.h, TRUE, do_xredraw_log, win );
          SetClipping ( NULL );
          EndControl ( CTL_UPDATE | CTL_MHIDE );
        }
    }
}

/* ------------------------------------------------------------------- */

#ifdef PASCAL

/* ------------------------------------------------------------------- */

VOID sgwwrite ( LONG win_id, BYTE *s )

{
  wprintf ( win_id, "%s", s );
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

BOOL OpenLogWindow ( LONG win_id, BYTE *title, BYTE *info, INT columns, INT rows, INT x, INT y, APROC action )

{
  WINDOW        *win;
  XWIN          xwin;
  LONG          size;
  FONT          *f;

  InitXWindow ( &xwin );

  xwin.font_id  = sysgem.confont_hid;
  xwin.font_pt  = sysgem.confont_hpt;
  columns       = max ( 5, columns );
  rows          = max ( 3, rows );
  size          = (LONG)( rows * ( columns + 2 ));
  xwin.id       = win_id;
  xwin.flags    = NAME | MOVER | CLOSER | ICONIFIER;			/* [GS] */
  xwin.cfg      = 0;

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
