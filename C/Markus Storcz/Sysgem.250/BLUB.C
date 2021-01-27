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
EXTERN  XEVENT  xevent;

/* ------------------------------------------------------------------- */

LOCAL   LONG    blub_id;

/* ------------------------------------------------------------------- */

LOCAL   INT     blub_x, blub_y;
LOCAL   INT     blub_count;
LOCAL   LONG    blub_winid;

/* ------------------------------------------------------------------- */

VOID InitBlub ( VOID )

{
  blub_id       = 'sgbl';
  blub_x        = -1;
  blub_y        = -1;
  blub_count    = 0;
  blub_winid    = 0L;
}

/* ------------------------------------------------------------------- */

VOID BeginHelp ( OBJECT *tree, INT obj, BYTE *text )

{
  RECT  r;
  BYTE  *p;
  BYTE  *q;
  BYTE  *t;
  LONG  l;
  INT   z;
  INT   i;


  if ( text == NULL ) return;
  if ( strlen ( text ) == 0L ) return;
  l = strlen ( text ) + 2L;
  p = (BYTE *) Allocate ( l );
  if ( p == NULL ) return;

  if ( tree != NULL )
    {
      CalcArea ( tree, obj, &r );
      r.y = r.y + r.h + 3;
    }
  else
    {
      MouseClicked ( &r.x, &r.y );
      r.x += 8;
      r.y += 4;
    }
  assign ( text, p );
  q = p;
  i = 0;
  z = 0;
  t = p;
  forever
    {
      if ( *q == 0 ) break;
      if ( *q == '|' )
        {
          *q = 0;
          i = max ( i, StringWidth ( t ));
          t = q + 1L;
          z++;
        }
      q++;
    }
  i = max ( i, StringWidth ( t ));
  z++;
  r.h = z * StringHeight ();
  r.w = i + 3;
  if ( OpenWindow ( blub_id, "", "", 0x0000, NULL, 1, TRUE, 1, 1, 1L, 1L, r.x, r.y, r.w, r.h, NULL, (RPROC) NULL, (APROC) NULL ) == -1 )
    {
      Dispose ( p );
      return;
    }

  SetWinBackground ( blub_id, sysgem.help_color );
  BeginListUpdate ( blub_id );
  q = p;
  t = p;
  forever
    {
      if ( *q == 0 )
        {
          AddToList ( blub_id, t );
          q++;
          if ( *q == 0 ) break;
          t = q;
          q--;
        }
      q++;
    }
  EndListUpdate ( blub_id );
  Dispose ( p );
}

/* ------------------------------------------------------------------- */

VOID EndHelp ( VOID )

{
  WINDOW        *win;

  win = find_window ( -1, blub_id );
  if ( win != NULL ) DestroyWindow ( win, TRUE );
  InitBlub ();
}

/* ------------------------------------------------------------------- */

VOID DisableHelp ( VOID )

{
  sysgem.no_blub = TRUE;
}

/* ------------------------------------------------------------------- */

VOID EnableHelp ( VOID )

{
  sysgem.no_blub = FALSE;
}

/* ------------------------------------------------------------------- */

WTREE *find_helpobj ( WINDOW *win, INT x, INT y, INT *obj )

{
  WTREE *wt;
  INT   i;

  wt = win->tree;
  while ( wt != NULL )
    {
      i = objc_find ( wt->dial->tree, wt->start, wt->depth, x, y );
      if ( i > 0 )
        {
          *obj = i;
          return ( wt );
        }
      wt = wt->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID CheckBlub ( VOID )

{
  WINDOW        *win;
  WTREE         *wt;
  INT           x, y;
  INT           h;
  LONG          id;

  if ( sysgem.no_blub ) return;

  x = xevent.x;
  y = xevent.y;

  if (( x == blub_x ) && ( y == blub_y ))
    {
      if ( blub_winid == 0L )
        {
          if ( blub_count >= sysgem.help_count )
            {
              h = wind_find ( x, y );
              if (( h > 0 ) && ( h == GetTopWindow ()))
                {
                  id = GetWindowId ( h );
                  win = find_window ( -1, id );
                  if ( win != NULL )
                    {
                      wt = find_helpobj ( win, x, y, &h );
                      if ( wt != NULL )
                        {
                          SendMessage ( SG_BEGINHELP, win, wt, NULL, h, 0, 0, 0 );
                          if ( find_window ( -1, blub_id ) != NULL )
                            {
                              blub_winid = id;
                            }
                          else
                            {
                              InitBlub ();
                            }
                        }
                    }
                }
            }
          else
            {
              blub_count++;
            }
        }
    }
  else
    {
      if ( blub_winid != 0L )
        {
          DelBlub ();
        }
    }
  blub_x = x;
  blub_y = y;
}

/* ------------------------------------------------------------------- */

VOID DelBlub ( VOID )

{
  WINDOW        *win;

  if ( blub_winid != 0L )
    {
      win = find_window ( -1, blub_winid );
      if ( win != NULL )
        {
          SendMessage ( SG_ENDHELP, win, NULL, NULL, 0, 0, 0, 0 );
        }
    }
  InitBlub ();
}

/* ------------------------------------------------------------------- */

VOID SetHelpTime ( INT count )

{
  sysgem.help_count = count;
}

/* ------------------------------------------------------------------- */

VOID SetHelpColor ( INT color )

{
  sysgem.help_color = color;
}

/* ------------------------------------------------------------------- */
