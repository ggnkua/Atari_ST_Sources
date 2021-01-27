/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <string.h>
#include        <stdlib.h>
#include        <tos.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM          sysgem;
LOCAL   WINDOW_INFO     win_inf;
EXTERN  INT             ed_field;

/* ------------------------------------------------------------------- */

EXTERN  VOID    DelBlub ( VOID );

/* ------------------------------------------------------------------- */

VOID    clear_winfo    ( WINDOW *win, WINDOW_INFO *inf );

/* ------------------------------------------------------------------- */

#ifdef EXTOB
EXTERN  RECT	tdr;
#endif

#define MAXTITEL 15*2+1											/* [GS]	*/

/* ------------------------------------------------------------------- */

LOCAL   BYTE    xwin_text       [200];
LOCAL   RECT    fr;
LOCAL   BYTE    win_name [50];
LOCAL   LONG    win_owner;
LOCAL   WPROC   top_proc;										/* [GS] */
LOCAL		INT			MTitle[MAXTITEL];						/* [GS] */

/* ------------------------------------------------------------------- */

VOID SetTopProc ( WPROC p )

{
  top_proc = p;
}

/* ------------------------------------------------------------------- */

WINDOW *find_window ( INT handle, LONG id )

{
  REG   WINDOW  *win;

  win = sysgem.window;
  if ( id == 0L )
    {
      while ( win != NULL )
        {
          if ( win->handle == handle ) return ( win );
          win = win->next;
        }
    }
  else
    {
      while ( win != NULL )
        {
          if ( win->id == id ) return ( win );
          win = win->next;
        }
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

BYTE *BuildWinName ( BYTE *text )

{
  if ( text == NULL ) text = "???";
  if ( text [0] == '|' )
    {
      if ( length ( text ) == 1 )
        {
          memset ( xwin_text, 0, sizeof ( xwin_text ));
        }
      else
        {
          sprintf ( xwin_text, " %.70s ", &text [1] );
        }
    }
  else
    {
      if ( sysgem.multitasking )
        {
          if ( length ( sysgem.prg_name ) == 0 )
            {
              xwin_text [0] = ' ';
              xwin_text [1] = (BYTE)( sysgem.prg_id >> 24 );
              xwin_text [2] = (BYTE)( sysgem.prg_id >> 16 );
              xwin_text [3] = (BYTE)( sysgem.prg_id >>  8 );
              xwin_text [4] = (BYTE)( sysgem.prg_id >>  0 );
              xwin_text [5] = ':';
              xwin_text [6] = ' ';
              xwin_text [7] = 0;
              append ( text, xwin_text );
              append ( " ",  xwin_text );
            }
          else
            {
              assign ( " ",   xwin_text );
              append ( sysgem.prg_name, xwin_text );
              append ( ": ",  xwin_text );
              append ( text,  xwin_text );
              append ( " ",   xwin_text );
            }
        }
      else
        {
          sprintf ( xwin_text, " %.70s ", text );
        }
    }
  return ( &xwin_text [0] );
}

/* ------------------------------------------------------------------- */

VOID SetWindowName ( INT handle, BYTE *text )

{
  WINDOW        *win;

  win = find_window ( handle, 0L );
  if ( win == NULL ) return;

  if ( text != NULL )																	/* [GS] */
    {																									/* [GS] */
      if ( text [0] == '|' )													/* [GS] */
        {																							/* [GS] */
          strncpy ( win->show, &text [1], 78L );			/* [GS] */
        }																							/* [GS] */
      else																						/* [GS] */
        {																							/* [GS] */
          strncpy ( win->show, text, 78L );						/* [GS] */
        }																							/* [GS] */
    }																									/* [GS] */
  BuildWinName ( text );
  assign ( xwin_text, win->name );
  wind_set ( win->handle, WF_NAME, win->name, 0, 0 );
}

/* ------------------------------------------------------------------- */

VOID SetWindowInfo ( INT handle, BYTE *text )

{
  WINDOW        *win;
  INT           i, j;

  win = find_window ( handle, 0L );
  if ( win != NULL )
    {
      if ( text == NULL ) text = "";
      if ( length ( text ) > 198 ) return;

      if ( win->kind & INFO )
        {
          if ( text [0] == '|' )
            {
              i  = ( win->work.w / sysgem.charw );
              i /= 2;
              j  = length ( text ) - 1;
              i  = i - ( j / 2 );
              memset ( xwin_text, 0, sizeof ( xwin_text ));
              for ( j = 0; j < i; j++ ) xwin_text [j] = ' ';
              append ( &text [1], xwin_text );
            }
          else
            {
              sprintf ( xwin_text, "%.198s", text );
            }
          assign ( xwin_text, win->info );
          wind_set ( win->handle, WF_INFO, win->info, 0, 0 );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID SetWinUser ( LONG win_id, VOID *user )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      win->user = user;
    }
}

/* ------------------------------------------------------------------- */

VOID *GetWinUser ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      return ( win->user );
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

INT CountWindows ( VOID )

{
  REG   WINDOW  *win;
        INT     i;

  win = sysgem.window;
  i   = 0;
  while ( win != NULL )
    {
      win = win->next;
      i++;
    }
  return ( i );
}

/* ------------------------------------------------------------------- */

INT GetTopWindow ( VOID )

{
  INT   i, j;

  wind_get ( 0, WF_TOP, &i, &j, &j, &j );
  return ( i );
}

/* ------------------------------------------------------------------- */

LONG GetTopWindowId ( VOID )

{
  WINDOW        *win;

  win = find_window ( GetTopWindow (), 0L );
  if ( win != NULL )
    {
      return ( win->id );
    }
  return ( 0L );
}

/* ------------------------------------------------------------------- */

WINDOW *topped ( VOID )

{
  REG   INT     handle;

  handle = GetTopWindow ();
  return ( find_window ( handle, 0L ));
}

/* ------------------------------------------------------------------- */

WINDOW *forced ( VOID )

{
  REG   WINDOW  *win;
  REG   WINDOW  *forced;

  forced = NULL;
  win    = sysgem.window;
  while ( win != NULL )
    {
      if ( win->flags & WIN_FORCE ) forced = win;
      win = win->next;
    }
  return ( forced );
}

/* ------------------------------------------------------------------- */

WINDOW *iconified ( VOID )

{
  REG   WINDOW  *win;
  REG   WINDOW  *f;

  f = NULL;
  win = sysgem.window;
  while ( win != NULL )
    {
      if ( win->icon != 0 ) f = win;
      win = win->next;
    }
  return ( f );
}

/* ------------------------------------------------------------------- */

LONG GetWindowId ( INT handle )

{
  REG   WINDOW  *win;

  win = find_window ( handle, 0L );
  if ( win != NULL )
    {
      return ( win->id );
    }
  return ( 0L );
}

/* ------------------------------------------------------------------- */

INT GetHandle ( LONG win_id )

{
  REG   WINDOW  *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      return ( win->handle );
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

VOID MenuLock ( VOID )

{
  REG   OBJECT  *menu;
  REG   INT     i;
  REG   INT     j;														/* [GS]	*/
  REG   INT     wahl;

  if ( sysgem.locked == TRUE ) return;
  menu = sysgem.menu_tree;
  if ( menu == NULL ) return;
  i = 0;
  forever
    {
      if ( menu [i].ob_type == G_TITLE ) break;
      if ( menu [i].ob_flags & LASTOB )  break;
      i++;
    }
  if ( menu [i].ob_flags & LASTOB ) return;
  i++;
	j=0;																						/* [GS] */
  forever
    {
      if ( menu [i].ob_type == G_TITLE )
        {
          excl ( menu [i].ob_state, SELECTED );
          MTitle[j]=i;														/* [GS] */
          MTitle[j+1]=menu [i].ob_state;					/* [GS]	*/
          j +=2;																	/* [GS] */
          incl ( menu [i].ob_state, DISABLED );
        }
      if ( menu [i].ob_flags & LASTOB ) break;
      i++;
    }
  wahl = menu [0].ob_tail;
  wahl = menu [wahl].ob_head;
  menu_ienable ( menu, ( wahl + 1 ), 0 );
  menu_bar ( menu, 1 );
  sysgem.locked = TRUE;
}

/* ------------------------------------------------------------------- */

VOID MenuUnlock ( VOID )

{
  REG   OBJECT  *menu;
  REG   INT     i;
  REG   INT     j;														/* [GS]	*/
  REG   INT     wahl;

  if ( sysgem.locked == FALSE ) return;
  if ( forced () != NULL ) return;
  menu = sysgem.menu_tree;
  if ( menu == NULL ) return;
  i = 0;
	j=0;																						/* [GS] */
  forever
    {
      if ( menu [i].ob_type == G_TITLE )
        {
          if ( menu [i].ob_state & DISABLED )
          	{
          		if(MTitle[j]==i)										/* [GS] */
          			{																	/* [GS]	*/
          				menu [i].ob_state=MTitle[j+1];	/* [GS] */
          				j +=2;													/* [GS]	*/
          			}																	/* [GS] */
          		else																/* [GS] */
          			{
          				excl ( menu [i].ob_state, DISABLED );
          			}
          	}
        }
      if ( menu [i].ob_flags & LASTOB ) break;
      i++;
    }
  wahl = menu [0].ob_tail;
  wahl = menu [wahl].ob_head;
  menu_ienable ( menu, ( wahl + 1 ), 1 );
  menu_bar ( menu, 1 );
  sysgem.locked = FALSE;
}

/* ------------------------------------------------------------------- */

VOID SetWinMinSize ( LONG win_id, INT w, INT h )

{
  REG   WINDOW  *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if ( w != -1 )
        {
          w = ( w <= 0 ) ? 0 : (( w / win->scr_x ) * win->scr_x );
          win->min_w = w;
        }
      if ( h != -1 )
        {
          h = ( h <= 0 ) ? 0 : (( h / win->scr_y ) * win->scr_y );
          win->min_h = h;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID SetWinMaxSize ( LONG win_id, INT w, INT h )

{
  REG   WINDOW  *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if ( w != -1 )
        {
          w = ( w <= 0 ) ? 0 : (( w / win->scr_x ) * win->scr_x );
          win->max_w = w;
        }
      if ( h != -1 )
        {
          h = ( h <= 0 ) ? 0 : (( h / win->scr_y ) * win->scr_y );
          win->max_h = h;
        }
    }
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

VOID DestroyWindow ( WINDOW *win, BOOL close )

{
  WINDOW        *xw;
  BOOL          ok;

  ok = FALSE;
  xw = sysgem.window;
  while ( xw != NULL )
    {
      if ( xw == win )
        {
          ok = TRUE;
          break;
        }
      xw = xw->next;
    }
  if ( ok == FALSE ) return;
  if ( win == NULL ) return;

  hide_cursor ( win->dial );
  ed_field = 0;
  DelXTimer   ( win->id   );
  SendMessage ( SG_QUIT, win, NULL, NULL, 0, 0, 0, 0 );

  while ( win->tree != NULL )
    {
      win->tree->dial->edit   = 0;
      win->tree->dial->edch   = 0;
      win->tree->dial->cursor = FALSE;
      DeletePtr ( &win->tree, win->tree );
    }

  if ( win->log.txt != NULL )
    {
#ifndef EXTOB
      if ( win->log.cursor == 1 ) do_blink ();
#endif
      Dispose ( win->log.txt );
    }

#ifndef EXTOB
  DelCompleteList ( win->id );
#endif

  if ( close )
    {
      BeginControl ( CTL_UPDATE );
      wind_close ( win->handle );
      wind_delete ( win->handle );
      EndControl ( CTL_UPDATE );
    }

#ifdef EXTOB
  if ( win->id == 'xdlg' )
    {
      wind_get ( win->handle, WF_CURRXYWH, &tdr.x, &tdr.y, &tdr.w, &tdr.h );
      tdr.w += 6;
      tdr.h += 6;
    }
#else
  SendToGemini ( AV_WINDCLOSE, win->handle );
#endif

  FreeWindow ( win );
  DeletePtr ( &sysgem.window, win );

  win = find_window ( GetTopWindow (), 0L );
  if ( win != NULL )
    {
      SendMessage ( SG_TOP, win, NULL, NULL, 0, 0, 0, 0 );
    }

#ifndef EXTOB
  MenuUnlock ();
#endif
  if ( sysgem.wait ) HandleEvents ();
}

/* ------------------------------------------------------------------- */

BOOL CloseWindow ( INT handle )

{
  WINDOW        *win;

  win = find_window ( handle, 0L );
  if ( win != NULL )
    {
      if ( SendMessage ( SG_END, win, NULL, NULL, -1, 0, 0, 0 ) == SG_CLOSE )
        {
          DestroyWindow ( win, TRUE );
          return ( TRUE );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL CloseWindowById ( LONG id )

{
  WINDOW        *win;

  win = find_window ( -1, id );
  if ( win != NULL )
    {
      return ( CloseWindow ( win->handle ));
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */
/* Schliež alle Fenster																								 */
/* mode: TRUE = Fenster bekommen nur eine SG_QUIT Message							 */
/*       FALSE = Bekommt erst die Message SG_END											 */
/* Rckgabe: TRUE alle Fenster konnten geschlossen werden, sonst FALSE */
/* [GS]																																 */

BOOL CloseAllWindows ( WORD mode )

{
	if ( mode )
		{
  		while ( sysgem.window != NULL ) DestroyWindow ( sysgem.window, TRUE );
  	}
  else
  	{
	  	while ( sysgem.window != NULL )
	  		{
	  			if ( !CloseWindow ( sysgem.window->handle ) )
	  				return ( FALSE );
	  		}
  	}
	return ( TRUE );
}

/* ------------------------------------------------------------------- */

BOOL TopWindow ( INT handle )

{
  WINDOW        *old;
  WINDOW        *new;

  old = topped ();
  new = find_window ( handle, 0L );
  if ( new == NULL )
    {
      return ( FALSE );
    }
  if ( forced () != NULL )
    {
      new = forced ();
    }
  if ( old == new )
    {
      return ( FALSE );
    }
  if ( old != NULL )
    {
      if ( old->id == 'blub' )
        {
#ifndef EXTOB
          DelBlub ();
#endif
          goto weiter;
        }
      if ( old->log.txt != NULL )
        {
#ifndef EXTOB
          if ( old->log.cursor == 1 ) do_blink ();
#endif
        }
      hide_cursor ( old->dial );
      SendMessage ( SG_UNTOP, old, NULL, NULL, 0, 0, 0, 0 );
    }
  weiter:
  wind_set ( new->handle, WF_TOP, 0, 0, 0, 0 );
  if ( top_proc != NULL )
    {
      top_proc ( new->handle );
    }
  SendMessage ( SG_TOP, new, NULL, NULL, 0, 0, 0, 0 );
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

WTREE *find_wt ( WINDOW *win, LONG id )

{
  WTREE         *wt;

  wt = win->tree;
  while ( wt != NULL )
    {
      if ( wt->id == id ) return ( wt );
      wt = wt->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

WTREE *find_wt_type ( WINDOW *win, INT pos )

{
  WTREE         *wt;

  wt = win->tree;
  while ( wt != NULL )
    {
      if ( wt->pos == pos ) return ( wt );
      wt = wt->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID GetObjWH ( OBJECT *tree, INT obj, INT *w, INT *h )

{
  if ( tree == NULL ) return;

  *w = tree [obj].ob_width;
  *h = tree [obj].ob_height;
}

/* ------------------------------------------------------------------- */

BOOL WindowVisible ( INT handle )

{
  RECT  r;

  wind_get ( handle, WF_WORKXYWH, &r.x, &r.y, &r.w, &r.h );
  if (( r.x >= sysgem.desk.x ) && ( r.y >= sysgem.desk.y ) && ( r.x + r.w < sysgem.desk.x + sysgem.desk.w ) && ( r.y + r.h < sysgem.desk.y + sysgem.desk.h ))
    {
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL RectVisible ( RECT *r )

{
  if (( r->x >= sysgem.desk.x ) && ( r->y >= sysgem.desk.y ) && ( r->x + r->w < sysgem.desk.x + sysgem.desk.w ) && ( r->y + r->h < sysgem.desk.y + sysgem.desk.h ))
    {
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

WINDOW *DialogInWindow ( OBJECT *tree )

{
  WINDOW        *win;
  WTREE         *wt;

  win = sysgem.window;
  while ( win != NULL )
    {
      wt = win->tree;
      while ( wt != NULL )
        {
          if ( wt->dial != NULL )
            {
              if ( wt->dial->tree == tree )
                {
                  return ( win );
                }
            }
          wt = wt->next;
        }
      win = win->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

BOOL CalcSlider ( WINDOW *win, RECT *z )

{
  REG   LONG  c;
  REG   LONG  ax, act, fpos;
        RECT  r;
        INT   i, v;
        BOOL  rwork;

  r.x = z->x;
  r.y = z->y;
  r.w = z->w;
  r.h = z->h;
  rwork = FALSE;
  if ( win->kind & HSLIDE )
    {
      if ((LONG)( r.w ) >= win->doc_x ) win->pos_x = 0L;
      if ( win->pos_x + (LONG)( r.w ) > win->doc_x )
        {
          win->pos_x = win->doc_x - (LONG)( r.w );
          rwork = TRUE;
        }
      if ( win->pos_x < 0L )
        {
          win->pos_x = 0L;
        }

      ax   = win->doc_x;
      act  = (LONG)( r.w );
      fpos = win->pos_x;
      c    = 1000L;
      if ( ax != 0L ) c = ( 1000L * act ) / ax + 1L;
      c = min ( c, 1000L );
      wind_get ( win->handle, WF_HSLSIZE, &i, &v, &v, &v );
      if ( i != (INT)c ) wind_set ( win->handle, WF_HSLSIZE, (INT)c, 0, 0, 0 );
      if (( fpos == 0L ) || ( ax <= act ))
        {
          c = 0L;
        }
      else
        {
          c = ( 1000L * fpos + 1L ) / ( ax - act );
        }
      wind_get ( win->handle, WF_HSLIDE, &i, &v, &v, &v );
      if ( i != (INT)c ) wind_set ( win->handle, WF_HSLIDE, (INT)c, 0, 0, 0 );
    }
  if ( win->kind & VSLIDE )
    {
      if ((LONG)( r.h ) >= win->doc_y ) win->pos_y = 0L;
      if ( win->pos_y + (LONG)( r.h ) > win->doc_y )
        {
          win->pos_y = win->doc_y - (LONG)( r.h );
          rwork = TRUE;
        }
      if ( win->pos_y < 0L )
        {
          win->pos_y = 0L;
        }

      ax   = win->doc_y;
      act  = (LONG)( r.h );
      fpos = win->pos_y;
      c    = 1000L;
      if ( ax != 0L ) c = ( 1000L * act ) / ax + 1L;
      c = min ( c, 1000L );
      c = max ( c, 1L );
      wind_get ( win->handle, WF_VSLSIZE, &i, &v, &v, &v );
      if ( i != (INT)c ) wind_set ( win->handle, WF_VSLSIZE, (INT)c, 0, 0, 0 );
      if (( fpos == 0L ) || ( ax <= act ))
        {
          c = 0L;
        }
      else
        {
          c = ( 1000L * fpos + 1L ) / ( ax - act );
        }
      wind_get ( win->handle, WF_VSLIDE, &i, &v, &v, &v );
      if ( i != (INT)c ) wind_set ( win->handle, WF_VSLIDE, (INT)c, 0, 0, 0 );
    }
  return ( rwork );
}

/* ------------------------------------------------------------------- */

VOID SetTheSlider ( INT handle, INT slid, INT newp )

{
  WINDOW        *win;
  RECT          r;
  LONG          d1, d2, po      = 0L;

  win = find_window ( handle, 0L );
  if ( win != NULL )
    {
      SendMessage ( SG_SLDNEWPOS1, win, NULL, NULL, 0, 0, 0, 0 );
      r.x = win->work.x;
      r.y = win->work.y;
      r.w = win->work.w;
      r.h = win->work.h;
      switch ( slid )
        {
          case HSLIDE : d2 = win->doc_x - (LONG)( r.w );
                        d1 = (LONG)( newp );
                        po = ( d1 * d2 ) / 1000L;
                        po = ( po / (LONG)( win->scr_x )) * (LONG)( win->scr_x );
                        if ( po != win->pos_x )
                          {
                            win->pos_x = po;
                            CalcSlider ( win, &r );
                            DoRedraw ( win, &r );
                          }
                        break;
          case VSLIDE : d2 = win->doc_y - (LONG)( r.h );
                        d1 = (LONG)( newp );
                        po = ( d1 * d2 ) / 1000L;
                        po = ( po / (LONG)( win->scr_y )) * (LONG)( win->scr_y );
                        if ( po != win->pos_y )
                          {
                            win->pos_y = po;
                            CalcSlider ( win, &r );
                            DoRedraw ( win, &r );
                          }
                        break;
        }
      SendMessage ( SG_SLDNEWPOS2, win, NULL, NULL, 0, 0, 0, 0 );
    }
}

/* ------------------------------------------------------------------- */

VOID MoveWinArea ( WINDOW *win, RECT *area, INT scroll, INT w, INT h, BOOL do_white, OPROC callback, VOID *user )

{
  RECT          r;
  RECT          r0;
  RECT          z;
  BOOL          top;

  r0.x  = area->x;
  r0.y  = area->y;
  r0.w  = area->w;
  r0.h  = area->h;

  clear_winfo ( win, &win_inf );
  top = (( topped () == win ) && ( WindowVisible ( win->handle )));
  BeginControl ( CTL_UPDATE | CTL_MHIDE );

  if ( top )
    {
      r.x = r0.x;
      r.y = r0.y;
      r.w = r0.w;
      r.h = r0.h;
      goto move_rectangle;
    }

  wind_get ( win->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h );
  RectIntersect ( &sysgem.desk, &r0 );

  while (( r.w > 0 ) && ( r.h > 0 ))
    {
      RectIntersect ( &r0, &r );
      if (( r.w > 0 ) && ( r.h > 0 ))
        {
          move_rectangle:

          SetClipping ( &r );
          z.x = win_inf.clip.x = r.x;
          z.y = win_inf.clip.y = r.y;
          z.w = win_inf.clip.w = r.w;
          z.h = win_inf.clip.h = r.h;

          switch ( scroll )
            {
              case WA_UPLINE    : r.h -= h;
                                  if ( r.h >= h )
                                    {
                                      move_screen ( &r, r.x, r.y + h );
                                      win_inf.clip.h = h;
                                      SetClipping ( &win_inf.clip );
                                    }
                                  if ( do_white ) FilledRect  ( r.x, r.y, r.x + r.w - 1, r.y + h - 1, win->back );
                                  break;
              case WA_DNLINE    : r.y += h;
                                  r.h -= h;
                                  if ( r.h >= h )
                                    {
                                      move_screen ( &r, r.x, r.y - h );
                                      win_inf.clip.y = r.y + r.h - h;
                                      win_inf.clip.h = h;
                                      SetClipping ( &win_inf.clip );
                                    }
                                  if ( do_white ) FilledRect  ( r.x, r.y + r.h - h, r.x + r.w - 1, r.y + r.h - 1, win->back );
                                  break;
              case WA_LFLINE    : r.w -= w;
                                  if ( r.w >= w )
                                    {
                                      move_screen ( &r, r.x + w, r.y );
                                      win_inf.clip.w = w;
                                      if ( top ) SetClipping ( &win_inf.clip );
                                    }
                                  if ( do_white ) FilledRect  ( r.x, r.y, r.x + w - 1, r.y + r.h - 1, win->back );
                                  break;
              case WA_RTLINE    : r.x += w;
                                  r.w -= w;
                                  if ( r.w >= w )
                                    {
                                      move_screen ( &r, r.x - w, r.y );
                                      win_inf.clip.x = r.x + r.w - w;
                                      win_inf.clip.w = w;
                                      if ( top ) SetClipping ( &win_inf.clip );
                                    }
                                  if ( do_white ) FilledRect  ( r.x + r.w - w - 1, r.y, r.x + r.w - 1, r.y + r.h - 1, win->back );
                                  break;
            }
          if ( ! top )
            {
              if ( do_white )
                {
                  FilledRect ( z.x, z.y, z.x + z.w - 1, z.y + z.h - 1, win->back );
                }
            }
          if ( callback != NULL )
            {
              callback ( win, user );
            }
          else
            {
              if ( win->redraw != NULL )
                {
                  win_inf.denied = (LONG)( &r );
                  win->redraw ( &win_inf );
                }
            }
          if ( top ) goto end_rectangle;
        }
      wind_get ( win->handle, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h );
    }
  end_rectangle:

  SetClipping ( NULL );
  EndControl ( CTL_UPDATE | CTL_MHIDE );
}

/* ------------------------------------------------------------------- */

VOID do_arrow ( INT handle, INT scroll )

{
  WINDOW        *win;
  RECT          r;
  LONG          old;

  win = find_window ( handle, 0L );
  if ( win == NULL ) return;

  r.x = win->work.x;
  r.y = win->work.y;
  r.w = win->work.w;
  r.h = win->work.h;

  if (( r.w <= 0 ) || ( r.h <= 0 )) return;
  if ( sysgem.send_slider )
    {
      SendMessage ( SG_SLDNEWPOS1, win, NULL, NULL, 0, 0, 0, 0 );
    }
  switch ( scroll )
    {
      case WA_UPPAGE : if ( win->pos_y == 0L ) return;
                       win->pos_y -= r.h;
                       win->pos_y = ( win->pos_y < 0L ) ? 0L : win->pos_y;
                       win->pos_y = ( win->pos_y / (LONG)( win->scr_y )) * (LONG)( win->scr_y );
                       DoRedraw ( win, &r );
                       break;
      case WA_DNPAGE : old = win->pos_y;
                       win->pos_y += r.h;
                       if ( win->pos_y + (LONG)( r.h ) > win->doc_y ) win->pos_y = win->doc_y - (LONG)( r.h );
                       win->pos_y = ( win->pos_y < 0L ) ? 0L : win->pos_y;
                       win->pos_y = ( win->pos_y / (LONG)( win->scr_y )) * (LONG)( win->scr_y );
                       if ( old == win->pos_y ) return;
                       DoRedraw ( win, &r );
                       break;
      case WA_LFPAGE : if ( win->pos_x == 0L ) return;
                       win->pos_x -= r.w;
                       win->pos_x = ( win->pos_x < 0L ) ? 0L : win->pos_x;
                       win->pos_x = ( win->pos_x / (LONG)( win->scr_x )) * (LONG)( win->scr_x );
                       DoRedraw ( win, &r );
                       break;
      case WA_RTPAGE : old = win->pos_x;
                       win->pos_x += (LONG)( r.w );
                       if ( win->pos_x + (LONG)( r.w ) > win->doc_x ) win->pos_x = win->doc_x - (LONG)( r.w );
                       if ( win->pos_x < 0L ) win->pos_x = 0L;
                       win->pos_x = ( win->pos_x / (LONG)( win->scr_x )) * (LONG)( win->scr_x );
                       if ( old == win->pos_x ) return;
                       DoRedraw ( win, &r );
                       break;
      case WA_UPLINE : if ( win->pos_y == 0L ) return;
                       win->pos_y -= win->scr_y;
                       win->pos_y = ( win->pos_y < 0L ) ? 0L : win->pos_y;
                       win->pos_y = ( win->pos_y / (LONG)( win->scr_y )) * (LONG)( win->scr_y );
                       MoveWinArea ( win, &win->work, WA_UPLINE, win->scr_x, win->scr_y, TRUE, (OPROC) NULL, NULL );
                       break;
      case WA_DNLINE : old = win->pos_y;
                       win->pos_y += win->scr_y;
                       if ( win->pos_y + (LONG)( r.h ) > win->doc_y ) win->pos_y = win->doc_y - (LONG)( r.h );
                       win->pos_y = ( win->pos_y < 0L ) ? 0L : win->pos_y;
                       win->pos_y = ( win->pos_y / (LONG)( win->scr_y )) * (LONG)( win->scr_y );
                       if ( old == win->pos_y ) return;
                       MoveWinArea ( win, &win->work, WA_DNLINE, win->scr_x, win->scr_y, TRUE, (OPROC) NULL, NULL );
                       break;
      case WA_LFLINE : if ( win->pos_x == 0L ) return;
                       win->pos_x -= win->scr_x;
                       win->pos_x = ( win->pos_x < 0L ) ? 0L : win->pos_x;
                       win->pos_x = ( win->pos_x / (LONG)( win->scr_x )) * (LONG)( win->scr_x );
                       MoveWinArea ( win, &win->work, WA_LFLINE, win->scr_x, win->scr_y, TRUE, (OPROC) NULL, NULL );
                       break;
      case WA_RTLINE : old = win->pos_x;
                       win->pos_x += (LONG)( win->scr_x );
                       if ( win->pos_x + (LONG)( r.w ) > win->doc_x ) win->pos_x = win->doc_x - (LONG)( r.w );
                       if ( win->pos_x < 0L ) win->pos_x = 0L;
                       win->pos_x = ( win->pos_x / (LONG)( win->scr_x )) * (LONG)( win->scr_x );
                       if ( old == win->pos_x ) return;
                       MoveWinArea ( win, &win->work, WA_RTLINE, win->scr_x, win->scr_y, TRUE, (OPROC) NULL, NULL );
                       break;
      case SCROLL_HOME:																														/* [GS] */
      								 if ( win->pos_x == 0L && win->pos_y == 0L ) return;				/* [GS] */
      								 win->pos_x = 0L;																						/* [GS] */
      								 win->pos_y = 0L;																						/* [GS] */
                       DoRedraw ( win, &r );																			/* [GS] */
											 break;																											/* [GS] */
      case SCROLL_SHIFT_HOME:																											/* [GS] */
      								 win->pos_x = 0L;																						/* [GS] */
      								 win->pos_y = win->doc_y - (LONG)( r.h );										/* [GS] */
                       DoRedraw ( win, &r );																			/* [GS] */
											 break;																											/* [GS] */
    }
  CalcSlider ( win, &r );
  if ( sysgem.send_slider )
    {
      SendMessage ( SG_SLDNEWPOS2, win, NULL, NULL, 0, 0, 0, 0 );
    }
}

/* ------------------------------------------------------------------- */

VOID SendSliderPos ( BOOL send )

{
  sysgem.send_slider = send;
}

/* ------------------------------------------------------------------- */

VOID ScrollWindow ( INT handle, INT what )

{
  do_arrow ( handle, what );
}

/* ------------------------------------------------------------------- */

LONG SetWindowParm ( INT handle, INT what, LONG value, BOOL Redraw)	/*[GS]*/

{
  WINDOW        *win;
  LONG          old;
  RECT          r;

  win = find_window ( handle, 0L );
  if ( win == NULL ) return ( -1L );

  r.x = win->work.x;
  r.y = win->work.y;
  r.w = win->work.w;
  r.h = win->work.h;
  switch ( what )
    {
      case SET_X : old = win->pos_x;
                   if ( value == -1L ) return ( win->pos_x );
                   if ( win->pos_x == value ) return ( win->pos_x );
                   win->pos_x = value;
                   if ( win->pos_x + (LONG)( r.w ) > win->doc_x ) win->pos_x = win->doc_x - (LONG)( r.w );
                   if ( win->pos_x < 0L ) win->pos_x = 0L;
                   if ( win->pos_x == old ) return ( old );
                   CalcSlider ( win, &r );
                   if ( Redraw ) DoRedraw ( win, &r );						 /*[GS]*/
                   return ( win->pos_x );
      case SET_Y : old = win->pos_y;
                   if ( value == -1L ) return ( win->pos_y );
                   if ( win->pos_y == value ) return ( win->pos_y );
                   win->pos_y = value;
                   if ((LONG)( r.h ) >= win->doc_y ) win->pos_y = 0L;
                   if ( win->pos_y + (LONG)( r.h ) > win->doc_y ) win->pos_y = win->doc_y - (LONG)( r.h );
                   if ( win->pos_y < 0L ) win->pos_y = 0L;
                   if ( win->pos_y == old ) return ( old );
                   CalcSlider ( win, &r );
                   if ( Redraw ) DoRedraw ( win, &r );						 /*[GS]*/
                   return ( win->pos_y );
      case SET_W : if ( value == -1L ) return ( win->doc_x );
                   value = ( value / (LONG)( win->scr_x )) * (LONG)( win->scr_x );
                   win->doc_x = value;
                   CalcSlider ( win, &r );
                   if ( Redraw ) DoRedraw ( win, &r );						 /*[GS]*/
                   return ( win->doc_x );
      case SET_H : if ( value == -1L ) return ( win->doc_y );
                   value = ( value / (LONG)( win->scr_y )) * (LONG)( win->scr_y );
                   win->doc_y = value;
                   CalcSlider ( win, &r );
                   if ( Redraw ) DoRedraw ( win, &r );						 /*[GS]*/
                   return ( win->doc_y );
      default    : break;
    }
  return ( -1L );
}

/* ------------------------------------------------------------------- */

VOID SetFulledX ( INT x )

{
  fr.x = x;
}

/* ------------------------------------------------------------------- */

VOID SetFulledY ( INT y )

{
  fr.y = y;
}

/* ------------------------------------------------------------------- */

VOID SetFulledW ( INT w )

{
  fr.w = w;
}

/* ------------------------------------------------------------------- */

VOID SetFulledH ( INT h )

{
  fr.h = h;
}

/* ------------------------------------------------------------------- */

VOID MoveWindow ( WINDOW *win, RECT *w, INT msg )

{
  RECT  r;
  RECT  o;
  BOOL  called  = FALSE;

  fr.x = -1;
  fr.y = -1;
  fr.w = -1;
  fr.h = -1;

  r.x  = w->x;
  r.y  = w->y;
  r.w  = w->w;
  r.h  = w->h;

  wind_get ( win->handle, WF_CURRXYWH, &o.x, &o.y, &o.w, &o.h );

  if ( win->icon != 0 )
    {
      called = (*sysgem.icfs_server)( ICFS_SNAP, win->icon_pos, &r.x, &r.y );
      if ( called == -32 ) goto do_set;
      if ( called ==   0 ) goto do_set;
      return;
      do_set:
      wind_set ( win->handle, WF_CURRXYWH, r.x, r.y, r.w, r.h );
      return;
    }

  wind_calc ( WC_WORK, win->kind, r.x, r.y, r.w, r.h, &r.x, &r.y, &r.w, &r.h );

  FixEntry    ( win->tree, LINK_MENU,   &r );
  FixEntry    ( win->tree, LINK_TOP,    &r );
  FixEntry    ( win->tree, LINK_REITER, &r );
  FixEntry    ( win->tree, LINK_BOTTOM, &r );
  FixEntry    ( win->tree, LINK_LEFT,   &r );
  FixEntry    ( win->tree, LINK_RIGHT,  &r );
  FixEntry    ( win->tree, LINK_DIALOG, &r );

  repeat_calc:

  r.x = ( r.x / win->align_x ) * win->align_x;
  r.y = ( r.y / win->align_y ) * win->align_y;
  r.w = ( r.w / win->scr_x   ) * win->scr_x;
  r.h = ( r.h / win->scr_y   ) * win->scr_y;

  if ( win->min_w > 0 ) { if ( r.w < win->min_w ) r.w = win->min_w; }
  if ( win->min_h > 0 ) { if ( r.h < win->min_h ) r.h = win->min_h; }
  if ( win->max_w > 0 ) { if ( r.w > win->max_w ) r.w = win->max_w; }
  if ( win->max_h > 0 ) { if ( r.h > win->max_h ) r.h = win->max_h; }

  if (( called == FALSE ) && ( sysgem.resizing == FALSE ))
    {
      called = TRUE;
      if ( win->dial != NULL )
        {
          SendMessage ( SG_POSX, win, find_wt_type ( win, LINK_DIALOG ), NULL, r.x, 0, 0, 0 );
          SendMessage ( SG_POSY, win, find_wt_type ( win, LINK_DIALOG ), NULL, r.y, 0, 0, 0 );
          msg = SG_POSX;
        }
      else
        {
          if ( SendMessage ( msg, win, NULL, NULL, r.x, r.y, r.w, r.h ) == SG_ABORT )
            {
              FixWinTree ( win );
              return;
            }
        }
      if ( fr.x != -1 ) r.x = fr.x;
      if ( fr.y != -1 ) r.y = fr.y;
      if ( fr.w != -1 ) r.w = fr.w;
      if ( fr.h != -1 ) r.h = fr.h;
      goto repeat_calc;
    }

  WinCalcBorder ( win, &r );

  if (( r.x == o.x ) && ( r.y == o.y ) && ( r.w == o.w ) && ( r.h == o.h )) return;

  wind_set      ( win->handle, WF_CURRXYWH, r.x, r.y, r.w, r.h );
  FixWinTree    ( win );

  CalcSlider ( win, &win->work );
  if (( msg == SG_FULLED ) || ( msg == SG_SIZED ))
    {
      if ( win->flags & WIN_DRAWN )
        {
          SendRedraw ( win->handle, &r );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID ReSizeWindow ( LONG win_id, RECT *size )

{
  WINDOW        *win;

  if (( win = find_window ( -1, win_id )) != NULL )
    {
       MoveWindow ( win, size, SG_SIZED );
       excl ( win->flags, WIN_FULLED );
    }
}

/* ------------------------------------------------------------------- */

VOID CheckWindow ( LONG win_id )

{
  RECT          o;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return;
  if ( win->id == 'blub' ) return;
  wind_get ( win->handle, WF_CURRXYWH, &o.x, &o.y, &o.w, &o.h );
  sysgem.resizing = TRUE;
  ReSizeWindow ( win_id, &o );
  sysgem.resizing = FALSE;
}

/* ------------------------------------------------------------------- */

VOID FullWindow ( WINDOW *win )

{
  if ( win->flags & WIN_FULLED )
    {
      MoveWindow ( win, &win->full, SG_SIZED );
      excl       ( win->flags, WIN_FULLED );
    }
  else
    {
      wind_get ( win->handle, WF_CURRXYWH, &win->full.x, &win->full.y, &win->full.w, &win->full.h );
      MoveWindow  ( win, &sysgem.desk, SG_FULLED );
      SendRedraw  ( win->handle, (RECT *) &sysgem.desk );
      incl        ( win->flags, WIN_FULLED );
    }
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

BOOL UnLinkTree ( LONG win_id, OBJECT *tree )

{
  WINDOW        *win;
  WTREE         *wt;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wt = win->tree;
  while ( wt != NULL )
    {
      if ( wt->dial->tree == tree )
        {
          DeletePtr ( &win->tree, wt );
          FixWinTree ( win );
          return ( TRUE );
        }
      wt = wt->next;
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL ChangeTree ( LONG win_id, LONG sub_id, OBJECT *tree, INT draw_flg )

{
  WINDOW        *win;
  WTREE         *wt;
  DIALOG_SYS    *dial;

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wt = win->tree;
  while ( wt != NULL )
    {
      if ( wt->id == sub_id )
        {
          wt->dial = dial;
          FixWinTree ( win );
          switch ( draw_flg )
            {
              case  0 : break;
              case  1 : RedrawWindow ( win->handle );
                        break;
              default : RedrawObj ( tree, 0, 8, NONE, UPD_STATE );
                        break;
            }
          return ( TRUE );
        }
      wt = wt->next;
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL xLinkTree ( LONG win_id, LONG id, OBJECT *tree, INT start, INT depth, INT pos, INT edit )

{
  WINDOW        *win;
  WTREE         *wt;
  DIALOG_SYS    *dial;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  if ( find_wt ( win, id ) != NULL ) return ( FALSE );

  if ( DialogInWindow ( tree ) != NULL ) return ( FALSE );

  if ( pos == LINK_MENU )
    {
#ifndef EXTOB
      InitWindowMenu ( tree );
#endif
    }

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  wt = (WTREE *) Allocate ( sizeof ( WTREE ));
  if ( wt == NULL ) return ( FALSE );

  wt->id        = id;
  wt->dial      = dial;
  wt->start     = start;
  wt->depth     = depth;
  wt->w         = 0;
  wt->h         = 0;
  wt->pos       = pos;

  clear_edit ( dial, edit );

  GetObjWH ( tree, start, &wt->w, &wt->h );

  InsertPtr ( &win->tree, wt );

  if ( win->flags & WIN_VISIBLE )
    {
      FixWinTree ( win );
    }

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

VOID CalcWinTrees ( LONG win_id )

{
  WINDOW        *win;
  WTREE         *wt;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return;

  wt = win->tree;
  while ( wt != NULL )
    {
      GetObjWH ( wt->dial->tree, wt->start, &wt->w, &wt->h );
      wt = wt->next;
    }
  FixWinTree ( win );
/*
  wind_get ( win->handle, WF_CURRXYWH, &r.x, &r.y, &r.w, &r.h );
  CheckWindow ( win->id );
*/
}

/* ------------------------------------------------------------------- */

BOOL LinkTree ( LONG win_id, OBJECT *tree, LONG id, INT pos )

{
  return ( xLinkTree ( win_id, id, tree, 0, 8, pos, 0 ));
}

/* ------------------------------------------------------------------- */

VOID WinCalcBorder ( WINDOW *win, RECT *w )

{
  WTREE         *wt;

  wt = win->tree;
  while ( wt != NULL )
    {
      switch ( wt->pos )
        {
          case LINK_MENU   :
          case LINK_REITER :
          case LINK_TOP    : w->y = w->y - wt->h - 1;
                             w->h = w->h + wt->h + 1;
                             break;
          case LINK_LEFT   : w->x = w->x - wt->w - 1;
                             w->w = w->w + wt->w + 1;
                             break;
          case LINK_RIGHT  : w->w = w->w + wt->w + 1;
                             break;
          case LINK_BOTTOM : w->h = w->h + wt->h + 1;
                             break;
          case LINK_DIALOG : break;
        }
      wt = wt->next;
    }
  wind_calc ( WC_BORDER, win->kind, w->x, w->y, w->w, w->h, &w->x, &w->y, &w->w, &w->h );
}

/* ------------------------------------------------------------------- */

VOID FixEntry ( WTREE *wt, INT pos, RECT *w )

{
  while ( wt != NULL )
    {
      if ( wt->pos == pos )
        {
          switch ( pos )
            {
              case LINK_MENU   : wt->dial->tree [0].ob_x         = w->x;
                                 wt->dial->tree [0].ob_y         = w->y;
                                 w->y = w->y + wt->h + 1;
                                 w->h = w->h - wt->h - 1;
                                 break;
              case LINK_REITER :
              case LINK_TOP    : wt->dial->tree [wt->start].ob_x = w->x;
                                 wt->dial->tree [wt->start].ob_y = w->y;
                                 wt->dial->tree [wt->start].ob_width = w->w;
                                 w->y = w->y + wt->h + 1;
                                 w->h = w->h - wt->h - 1;
                                 break;
              case LINK_LEFT   : wt->dial->tree [wt->start].ob_x = w->x;
                                 wt->dial->tree [wt->start].ob_y = w->y;
                                 wt->dial->tree [wt->start].ob_height = w->h;
                                 w->x = w->x + wt->w + 1;
                                 w->w = w->w - wt->w - 1;
                                 break;
              case LINK_RIGHT  : wt->dial->tree [wt->start].ob_x = w->x + w->w - wt->w;
                                 wt->dial->tree [wt->start].ob_y = w->y;
                                 wt->dial->tree [wt->start].ob_height = w->h;
                                 w->w = w->w - wt->w - 1;
                                 break;
              case LINK_BOTTOM : wt->dial->tree [wt->start].ob_x = w->x;
                                 wt->dial->tree [wt->start].ob_y = w->y + w->h - wt->h;
                                 wt->dial->tree [wt->start].ob_width = w->w;
                                 w->h = w->h - wt->h - 1;
                                 break;
              case LINK_DIALOG : wt->dial->tree [wt->start].ob_x = w->x;
                                 wt->dial->tree [wt->start].ob_y = w->y;
                                 break;
              default          : break;
            }
        }
      wt = wt->next;
    }
}

/* ------------------------------------------------------------------- */

VOID FixWinTree ( WINDOW *win )

{
  RECT  r;

  wind_get ( win->handle, WF_WORKXYWH, &r.x, &r.y, &r.w, &r.h );

  FixEntry    ( win->tree, LINK_MENU,   &r );
  FixEntry    ( win->tree, LINK_TOP,    &r );
  FixEntry    ( win->tree, LINK_REITER, &r );
  FixEntry    ( win->tree, LINK_BOTTOM, &r );
  FixEntry    ( win->tree, LINK_LEFT,   &r );
  FixEntry    ( win->tree, LINK_RIGHT,  &r );
  FixEntry    ( win->tree, LINK_DIALOG, &r );

  win->work.x = r.x;
  win->work.y = r.y;
  win->work.w = r.w;
  win->work.h = r.h;
}

/* ------------------------------------------------------------------- */

VOID InitXWindow ( XWIN *xwin )

{
  memset ( xwin, 0, sizeof ( XWIN ));

  xwin->id              = 0L;
  xwin->owner           = win_owner;

  xwin->flags           = NAME | MOVER;
  xwin->cfg             = WIN_PAINT;

  xwin->name            = NULL;
  xwin->info            = NULL;

  xwin->user            = NULL;

  xwin->align_x         = 8;
  xwin->align_y         = 1;

  xwin->font_id         = sysgem.act_font_id;
  xwin->font_pt         = sysgem.act_font_pt;

  xwin->scr_x           = StringWidth ( "W" );
  xwin->scr_y           = StringHeight ();

  xwin->min_w           = 0;
  xwin->min_h           = 0;
  xwin->max_w           = 0;
  xwin->max_h           = 0;

  xwin->work.x          = 100;
  xwin->work.y          = 100;
  xwin->work.w          = 100;
  xwin->work.h          = 100;

  xwin->back            = WHITE;

  xwin->doc_w           = 0L;
  xwin->doc_h           = 0L;

  xwin->anz_trees       = 0;
  xwin->trees           = NULL;
  xwin->menu            = NULL;
  xwin->md              = NULL;

  xwin->redraw          = (RPROC) NULL;
  xwin->waction         = (APROC) NULL;
  xwin->daction         = (DPROC) NULL;
}

/* ------------------------------------------------------------------- */

LOCAL VOID say ( WINDOW *win, INT msg )

{
  SendMessage ( msg, win, NULL, NULL, 0, 0, 0, 0 );
  if ( win->dial != NULL )
    {
      if ( msg == SG_INVISIBLE ) hide_cursor ( win->dial );
    }
}

/* ------------------------------------------------------------------- */

VOID FreeWindow ( WINDOW *win )

{
  if ( win->icon_pos < 0 ) return;
  (*sysgem.icfs_server)( ICFS_FREEPOS, win->icon_pos );
  win->icon_pos = -1;
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

LOCAL BOOL make_icon ( WINDOW *win, RECT *v )

{
  RECT  r;
  INT   pos;

  if ( win->icon != 0 ) return ( FALSE );

  if ( length ( sysgem.icn_name ) != 0 )
    {
      assign ( " ", win_name );
      append ( sysgem.icn_name, win_name );
      append ( " ", win_name );
    }
  else
    {
      win_name [0] = ' ';
      win_name [1] = (BYTE)( sysgem.prg_id >> 24 );
      win_name [2] = (BYTE)( sysgem.prg_id >> 16 );
      win_name [3] = (BYTE)( sysgem.prg_id >>  8 );
      win_name [4] = (BYTE)( sysgem.prg_id >>  0 );
      win_name [5] = ' ';
      win_name [6] = 0;
    }

  if ( sysgem.iconify == ICONIFY_AES )
    {
      say ( win, SG_INVISIBLE );
      wind_get    ( win->handle, WF_CURRXYWH, &win->full.x, &win->full.y, &win->full.w, &win->full.h );
      wind_set    ( win->handle, WF_NAME, win_name );
      if (( v->x == -1 ) && ( v->y == -1 ) && ( v->w == -1 ) & ( v->h == -1 ))
        {
          if ( sysgem.mint_version != 0 )
            {
              wind_close ( win->handle );
              wind_set   ( win->handle, WF_ICONIFY, -1, -1, -1, -1 );
              wind_open  ( win->handle, -1, -1, -1, -1 );
            }
          else
            {
              wind_set ( win->handle, WF_ICONIFY, -1, -1, -1, -1 );
            }
        }
      else
        {
          wind_set ( win->handle, WF_ICONIFY, v->x, v->y, v->w, v->h );
        }
      excl ( win->flags, WIN_VISIBLE );
      excl ( win->flags, WIN_DRAWN   );
      win->icon    = ICON_ICON;
      return ( TRUE );
    }
  if ( win->icon_pos >= 0 ) return ( FALSE );

  pos = (*sysgem.icfs_server)( ICFS_GETPOS, &r.x, &r.y, &r.w, &r.h );
  if ( pos < 0 ) return ( FALSE );

  say ( win, SG_INVISIBLE );
  wind_get ( win->handle, WF_CURRXYWH, &win->full.x, &win->full.y, &win->full.w, &win->full.h );

  win->icon_pos = pos;
  wind_close  ( win->handle );
  wind_delete ( win->handle );
  win->handle = wind_create ( NAME | MOVER, sysgem.desk.x, sysgem.desk.y, sysgem.desk.w, sysgem.desk.h );
  wind_set    ( win->handle, WF_NAME, win_name );
  wind_open   ( win->handle, r.x, r.y, r.w, r.h );

  excl ( win->flags, WIN_VISIBLE );
  excl ( win->flags, WIN_DRAWN   );
  win->icon    = ICON_ICON;

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

LOCAL BOOL unmake_icon ( WINDOW *win )

{
  if ( win->icon == 0 ) return ( FALSE );

  if ( sysgem.iconify == ICONIFY_AES )
    {
      wind_set    ( win->handle, WF_UNICONIFY, win->full.x, win->full.y, win->full.w, win->full.h );
      wind_set    ( win->handle, WF_NAME, win->name );
      wind_set    ( win->handle, WF_INFO, win->info );
      FixWinTree  ( win );

      incl ( win->flags, WIN_VISIBLE );
      excl ( win->flags, WIN_DRAWN   );
      win->icon    = 0;
      say ( win, SG_VISIBLE );
      return ( TRUE );
    }

  if ( win->icon_pos < 0 ) return ( FALSE );
  (*sysgem.icfs_server)( ICFS_FREEPOS, win->icon_pos );
  win->icon_pos = -1;

  wind_close  ( win->handle );
  wind_delete ( win->handle );
  win->handle = wind_create ( win->kind, 0, 0, sysgem.xmax, sysgem.ymax );
  wind_set    ( win->handle, WF_NAME, win->name );
  wind_set    ( win->handle, WF_INFO, win->info );
  wind_open   ( win->handle, win->full.x, win->full.y, win->full.w, win->full.h );
  FixWinTree  ( win );
  CalcSlider  ( win, &win->work );

  incl ( win->flags, WIN_VISIBLE );
  excl ( win->flags, WIN_DRAWN   );
  win->icon    = 0;
  say ( win, SG_VISIBLE );

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

LOCAL VOID hide_icon ( WINDOW *win )

{
  if ( win->icon != 0 ) return;

  say ( win, SG_INVISIBLE );

  wind_get ( win->handle, WF_CURRXYWH, &win->full.x, &win->full.y, &win->full.w, &win->full.h );
  wind_set ( win->handle, WF_CURRXYWH, sysgem.xmax + 20, win->full.y, win->full.w, win->full.h );

  excl ( win->flags, WIN_VISIBLE );
  excl ( win->flags, WIN_DRAWN   );
  win->icon    = ICON_HIDE;
}

/* ------------------------------------------------------------------- */

LOCAL VOID unhide_icon ( WINDOW *win )

{
  if ( win->icon == 0 ) return;

  wind_set ( win->handle, WF_CURRXYWH, win->full.x, win->full.y, win->full.w, win->full.h );

  FixWinTree  ( win );

  CalcSlider ( win, &win->work );

  incl ( win->flags, WIN_VISIBLE );
  excl ( win->flags, WIN_DRAWN   );
  win->icon    = 0;

  say ( win, SG_VISIBLE );
}

/* ------------------------------------------------------------------- */

BOOL Iconify ( INT handle, RECT *r )

{
  WINDOW        *win;

  win = sysgem.window;
  while ( win != NULL )
    {
      if ( win->handle == handle )
        {
          if ( win->flags & WIN_VISIBLE )
            {
              return ( make_icon ( win, r ));
            }
        }
      win = win->next;
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL IconifyAllInOne ( INT handle, RECT *r )

{
  WINDOW        *win;

  win = sysgem.window;
  while ( win != NULL )
    {
      if ( win->handle == handle )
        {
          make_icon ( win, r );
          win->icon = ICON_MAIN;
        }
      else
        {
          hide_icon ( win );
        }
      win = win->next;
    }
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

BOOL IconifyAll ( VOID )

{
  WINDOW        *win;

  if ( sysgem.iconify != ICONIFY_ICFS )
    {
      return ( FALSE );
    }
  win = sysgem.window;
  while ( win != NULL )
    {
      make_icon ( win, NULL );
      win = win->next;
    }
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

VOID UnIconify ( INT handle )

{
  WINDOW        *win;

  win = find_window ( handle, 0L );
  if ( win == NULL ) return;

  if ( win->icon == ICON_MAIN )
    {
      unmake_icon ( win );
      win = sysgem.window;
      while ( win != NULL )
        {
          switch ( win->icon )
            {
              case ICON_ICON : unmake_icon ( win );
                               break;
              case ICON_HIDE : unhide_icon ( win );
                               break;
            }
          win = win->next;
        }
      return;
    }
  else
    {
      unmake_icon ( win );
    }
}

/* ------------------------------------------------------------------- */

VOID SetIconifyName ( BYTE *name )

{
  strncpy ( sysgem.icn_name, name, 38L );
}

/* ------------------------------------------------------------------- */

VOID LinkImage ( LONG win_id, BITBLK *image, BYTE *text )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      win->icfs_icon = image;
      strncpy ( win->icfs_name, text, 8L );
      strupr ( win->icfs_name );
    }
}

/* ------------------------------------------------------------------- */

VOID LinkMainImage ( BITBLK *image, BYTE *text )

{
  sysgem.iconified_icon = image;
  strncpy ( sysgem.iconified_name, text, 8L );
  strupr ( sysgem.iconified_name );
}

/* ------------------------------------------------------------------- */

VOID SetIconRedraw ( LONG win_id, IPROC proc )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if ( proc == NULL )
        {
          win->iconredraw = NULL;
        }
      else
        {
          win->iconredraw = proc;
        }
    }
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

VOID GetWindowFont ( LONG win_id, INT *id, INT *pt )

{
  WINDOW        *win;

  if (( win = find_window ( -1, win_id )) != NULL )
    {
      if ( id != NULL ) *id = win->font_id;
      if ( pt != NULL ) *pt = win->font_pt;
    }
}

/* ------------------------------------------------------------------- */

VOID *XWindow ( XWIN *xwin )

{
  WINDOW        *win;
  WINDOW        *old;
  RECT          r, w, ic;
  INT           handle;
  INT           i;
  BOOL          do_icon;
  BYTE          txt [10];
  LONG          own;

  do_icon = FALSE;

  if (( win = find_window ( -1, xwin->id )) != NULL )
    {
      TopWindow ( win->handle );
      return ( NULL );
    }

  win = (WINDOW *) Allocate ( sizeof ( WINDOW ));
  if ( win == NULL ) return ( NULL );

  win->next             = NULL;
  win->id               = xwin->id;
  own                   = xwin->owner;
  win->owner            = win_owner;
  win->handle           = -1;
  win->kind             = xwin->flags;
  win->flags            = xwin->cfg;
  win->user             = xwin->user;
  win->icon_pos         = -1;
  win->icon_icolor      = BLACK;
  win->icon_tcolor      = RED;

  if ( win->flags & WIN_FORCE ) excl ( win->kind, ICONIFIER );	/* [GS] */

  handle = wind_create ( win->kind, 0, 0, sysgem.xmax + 1, sysgem.ymax + 1 );
  if ( handle < 0 )
    {
      if ( xwin->waction != NULL )
        {
          xwin->waction ( SG_NOWIN, NULL );
        }
      Dispose ( win );
      return ( NULL );
    }
  win->handle = handle;
  InsertPtr ( &sysgem.window, win );

  if ( xwin->menu != NULL )
    {
      xLinkTree ( xwin->id, 'menu', xwin->menu, 1, 8, LINK_MENU, 0 );
    }

  for ( i = 0; i < xwin->anz_trees; i++ )
    {
      if ( xLinkTree ( xwin->id, xwin->trees [i].id, xwin->trees [i].tree, xwin->trees [i].start, xwin->trees [i].depth, xwin->trees [i].pos, xwin->trees [i].edit ))
        {
          if ( xwin->md == xwin->trees [i].tree )
            {
              win->dial = find_dialog ( xwin->md );
            }
        }
    }

  for ( i = 0; i < MAX_TAB + 1; i++ )
    {
      win->tab [i].pos  = -1;
      win->tab [i].just = TAB_LEFT;
    }

  win->font_id  = xwin->font_id;
  win->font_pt  = xwin->font_pt;

  win->waction  = xwin->waction;
  win->daction  = xwin->daction;
  win->redraw   = xwin->redraw;

  win->align_x  = ( xwin->align_x <= 0 ) ? 8 : xwin->align_x;
  win->align_y  = ( xwin->align_y <= 0 ) ? 1 : xwin->align_y;

  SetFont ( win->font_id, win->font_pt );
  win->scr_x    = ( xwin->scr_x <= 0 ) ? ( StringWidth ( "W" )) : xwin->scr_x;
  win->scr_y    = ( xwin->scr_y <= 0 ) ? ( StringHeight ())     : xwin->scr_y;
  NormalFont ();

  win->min_w    = ( xwin->min_w <= 0 ) ? 0 : (( xwin->min_w / win->scr_x ) * win->scr_x );
  win->min_h    = ( xwin->min_h <= 0 ) ? 0 : (( xwin->min_h / win->scr_y ) * win->scr_y );
  win->max_w    = ( xwin->max_w <= 0 ) ? 0 : (( xwin->max_w / win->scr_x ) * win->scr_x );
  win->max_h    = ( xwin->max_h <= 0 ) ? 0 : (( xwin->max_h / win->scr_y ) * win->scr_y );

  win->pos_x    = 0L;
  win->pos_y    = 0L;

  win->doc_x    = ( xwin->doc_w <= 0L ) ? 1L : xwin->doc_w;
  win->doc_y    = ( xwin->doc_h <= 0L ) ? 1L : xwin->doc_h;

  win->back     = xwin->back;

  r.x           = xwin->work.x;
  r.y           = xwin->work.y;
  r.w           = xwin->work.w;
  r.h           = xwin->work.h;

  r.x           = ( r.x / win->align_x ) * win->align_x;
  r.y           = ( r.y / win->align_y ) * win->align_y;

/* Workaround wegen Rundungsfehler
  r.w           = ( r.w / win->scr_x   ) * win->scr_x;
  r.h           = ( r.h / win->scr_y   ) * win->scr_y;
*/

  if ( win->min_w > 0 ) { if ( r.w < win->min_w ) r.w = win->min_w; }
  if ( win->min_h > 0 ) { if ( r.h < win->min_h ) r.h = win->min_h; }
  if ( win->max_w > 0 ) { if ( r.w > win->max_w ) r.w = win->max_w; }
  if ( win->max_h > 0 ) { if ( r.h > win->max_h ) r.h = win->max_h; }

  WinCalcBorder ( win, &r );

  if ( r.x + r.w > sysgem.desk.x + sysgem.desk.w ) r.x = sysgem.desk.x + sysgem.desk.w - r.w - 8;
  if ( r.y + r.h > sysgem.desk.y + sysgem.desk.h ) r.y = sysgem.desk.y + sysgem.desk.h - r.h - 8;

  if ( r.y < sysgem.desk.y ) r.y = sysgem.desk.y;
  if ( r.x < sysgem.desk.x ) r.x = sysgem.desk.x - 1;

  w.x           = r.x;
  w.y           = r.y;
  w.w           = r.w;
  w.h           = r.h;

  FixEntry    ( win->tree, LINK_MENU,   &w );
  FixEntry    ( win->tree, LINK_TOP,    &w );
  FixEntry    ( win->tree, LINK_REITER, &w );
  FixEntry    ( win->tree, LINK_BOTTOM, &w );
  FixEntry    ( win->tree, LINK_LEFT,   &w );
  FixEntry    ( win->tree, LINK_RIGHT,  &w );
  FixEntry    ( win->tree, LINK_DIALOG, &w );

  win->work.x = w.x;
  win->work.y = w.y;
  win->work.w = w.w;
  win->work.h = w.h;

  if ( xwin->name != NULL )
    {
      if ( xwin->name [0] == '|' )
        {
          strncpy ( win->show, &xwin->name [1], 78L );
        }
      else
        {
          strncpy ( win->show, xwin->name, 78L );
        }
    }
  SetWindowName ( win->handle, xwin->name );
  SetWindowInfo ( win->handle, xwin->info );

  txt [0] = (BYTE)( win->id >> 24 );
  txt [1] = (BYTE)( win->id >> 16 );
  txt [2] = (BYTE)( win->id >>  8 );
  txt [3] = (BYTE)( win->id >>  0 );
  txt [4] = 0;
#ifndef EXTOB
  LinkImage ( win->id, NULL, txt );
#endif

  if ( SendMessage ( SG_OPENICONIFIED, win, NULL, NULL, 0, 0, 0, 0 ) == SG_ICONIFY )
    {
      excl ( win->flags, WIN_FORCE );
      do_icon = TRUE;
    }

#ifndef EXTOB
  if ( win->flags & WIN_FORCE )
    {
      MenuLock ();
    }
#endif

  old = find_window ( GetTopWindow (), 0L );
  if ( old != NULL )
    {
      SendMessage ( SG_UNTOP, old, NULL, NULL, 0, 0, 0, 0 );
      if ( old->dial != NULL )
        {
          hide_cursor ( old->dial );
        }
    }

  if ( do_icon )
    {
      r.x += sysgem.xmax;
    }

  wind_open ( win->handle, r.x, r.y, r.w, r.h );
  SendMessage ( SG_POSITION, win, find_wt_type ( win, LINK_DIALOG ), NULL, 0, 0, 0, 0 );

  FixWinTree ( win );
#ifndef EXTOB
  CalcSlider ( win, &win->work );
#endif

  if ( own != 'golX' )
    {
      SendMessage ( SG_START, win, find_wt_type ( win, LINK_DIALOG ), NULL, 0, 0, 0, 0 );
    }
  FixWinTree ( win );
#ifndef EXTOB
  CalcSlider ( win, &win->work );
#endif
  incl ( win->flags, WIN_VISIBLE );

  if ( do_icon )
    {
      ic.x = -1;
      ic.y = -1;
      ic.w = -1;
      ic.h = -1;
#ifndef EXTOB
      Iconify ( win->handle, &ic );
#endif
      win->full.x -= sysgem.xmax;
    }

  SendMessage ( SG_TOP, win, NULL, NULL, 0, 0, 0, 0 );
#ifndef EXTOB
  SendToGemini ( AV_WINDOPEN, win->handle );
#endif

  return ( win );
}

/* ------------------------------------------------------------------- */

BOOL WindowDialog ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, BOOL shut, BOOL force, OBJECT *tree, OBJECT *menu, INT edit, VOID *user, DPROC proc )

{
  XWIN          xwin;
  XTREE         xtree;
  DIALOG_SYS    *dial;
  WINDOW        *win;
  INT           x0, y0;

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  if (( win = find_window ( -1, id )) != NULL )
    {
      TopWindow ( win->handle );
      return ( TRUE );
    }

  if ( DialogInWindow ( tree ) != NULL )
    {
      return ( FALSE );
    }

  InitXWindow ( &xwin );

  xtree.id       = id;
  xtree.tree     = tree;
  xtree.start    = 0;
  xtree.depth    = 8;
  xtree.edit     = edit;
  xtree.pos      = LINK_DIALOG;

  xwin.id        = id;
  xwin.user      = user;
  xwin.flags     = MOVER | NAME | CLOSER | ICONIFIER | INFO;   /* [GS] */
  xwin.cfg       = WIN_DIALOG;
  xwin.align_x   = 8;
  xwin.align_y   = 1;
  xwin.scr_x     = 1;
  xwin.scr_y     = 1;
  xwin.name      = name;
  xwin.info      = info;
  xwin.anz_trees = 1;
  xwin.trees     = &xtree;
  xwin.md        = tree;
  xwin.daction   = proc;
  xwin.menu      = menu;

  if ( ! shut ) excl ( xwin.flags, CLOSER );
  if ( force  ) incl ( xwin.cfg,   WIN_FORCE );
  if ( force  ) excl ( xwin.flags, ICONIFIER ); 				/* [GS] */
  if ( info [0] == 0 ) excl ( xwin.flags, INFO );

  form_center ( tree, &xwin.work.x, &xwin.work.y, &xwin.work.w, &xwin.work.h );
  x0 = xwin.work.x;
  y0 = xwin.work.y;
  if ( sysgem.center == FALSE )
    {
      MouseClicked ( &x0, &y0 );
      x0 = x0 - ( xwin.work.w / 2 );
      y0 = y0 - ( xwin.work.h / 2 );
    }

  xwin.work.x   = ( xpos < 0 ) ? x0 : xpos;
  xwin.work.y   = ( ypos < 0 ) ? y0 : ypos;

  if (( win = (WINDOW *) XWindow ( &xwin )) != NULL )
    {
      return ( TRUE );
    }
  else
    {
      if ( proc != NULL )
        {
          proc ( SG_NOWIN, -1, NULL );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

BOOL MultipleDialog ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, OBJECT *top, INT active, OBJECT *tree, OBJECT *menu, INT edit, VOID *user, DPROC proc )

{
  XWIN          xwin;
  XTREE         xtree [2];
  DIALOG_SYS    *dial;
  WINDOW        *win;
  INT           x0, y0;

  if (( win = find_window ( -1, id )) != NULL )
    {
      TopWindow ( win->handle );
      return ( TRUE );
    }

  dial = find_dialog ( top );
  if ( dial == NULL ) return ( FALSE );

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  if ( DialogInWindow ( dial->tree ) != NULL ) return ( FALSE );

  InitXWindow ( &xwin );

  xtree [0].id   = id;
  xtree [0].tree = top;
  xtree [0].start= 0;
  xtree [0].depth= 8;
  xtree [0].edit = 0;
  xtree [0].pos  = LINK_REITER;

  xtree [1].id   = id + 1L;
  xtree [1].tree = tree;
  xtree [1].start= 0;
  xtree [1].depth= 8;
  xtree [1].edit = edit;
  xtree [1].pos  = LINK_DIALOG;

  x0 = 0;
  forever
    {
      excl ( top [x0].ob_state, SELECTED );
      if ( top [x0].ob_flags & LASTOB ) break;
      x0++;
    }

  incl ( top [active].ob_state, SELECTED );

  xwin.id        = id;
  xwin.user      = user;
  xwin.flags     = MOVER | NAME | CLOSER | INFO | SMALLER;
  xwin.cfg       = WIN_DIALOG;
  xwin.align_x   = 8;
  xwin.align_y   = 1;
  xwin.scr_x     = 1;
  xwin.scr_y     = 1;
  xwin.name      = name;
  xwin.info      = info;
  xwin.anz_trees = 2;
  xwin.trees     = &xtree [0];
  xwin.md        = tree;
  xwin.daction   = proc;
  xwin.menu      = menu;									/* [GS] */

  if ( info [0] == 0 ) excl ( xwin.flags, INFO );

  form_center ( tree, &xwin.work.x, &xwin.work.y, &xwin.work.w, &xwin.work.h );
  x0 = xwin.work.x;
  y0 = xwin.work.y;
  if ( sysgem.center == FALSE )
    {
      MouseClicked ( &x0, &y0 );
      x0 = x0 - ( xwin.work.w / 2 );
      y0 = y0 - ( xwin.work.h / 2 );
    }
  xwin.work.x   = ( xpos < 0 ) ? x0 : xpos;
  xwin.work.y   = ( ypos < 0 ) ? y0 : ypos;

  if ( XWindow ( &xwin ))
    {
      win = find_window ( -1, id );
      if ( win != NULL )
        {
          SendMessage ( SG_NEWDIAL, win, NULL, NULL, active, 0, 0, 0 );
          FixWinTree ( win );
          SendMessage ( SG_START, win, NULL, NULL, 0, 0, 0, 0 );
          return ( TRUE );
        }
    }
  else
    {
      if ( proc != NULL )
        {
          proc ( SG_NOWIN, -1, NULL );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL xMultipleDialog ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, OBJECT *top, INT active, OBJECT *tree, INT edit, VOID *user, DPROC proc )

{
  XWIN          xwin;
  XTREE         xtree [2];
  DIALOG_SYS    *dial;
  WINDOW        *win;
  INT           x0, y0;

  if (( win = find_window ( -1, id )) != NULL )
    {
      TopWindow ( win->handle );
      return ( TRUE );
    }

  dial = find_dialog ( top );
  if ( dial == NULL ) return ( FALSE );

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  if ( DialogInWindow ( dial->tree ) != NULL ) return ( FALSE );

  InitXWindow ( &xwin );

  xtree [0].id   = id;
  xtree [0].tree = top;
  xtree [0].start= 0;
  xtree [0].depth= 8;
  xtree [0].edit = 0;
  xtree [0].pos  = LINK_REITER;

  xtree [1].id   = id + 1L;
  xtree [1].tree = tree;
  xtree [1].start= 0;
  xtree [1].depth= 8;
  xtree [1].edit = edit;
  xtree [1].pos  = LINK_DIALOG;

  x0 = 0;
  forever
    {
      excl ( top [x0].ob_state, SELECTED );
      if ( top [x0].ob_flags & LASTOB ) break;
      x0++;
    }

  incl ( top [active].ob_state, SELECTED );

  xwin.id        = id;
  xwin.user      = user;
  xwin.flags     = MOVER | NAME | CLOSER | INFO;
  xwin.cfg       = WIN_DIALOG | WIN_FORCE;
  xwin.align_x   = 8;
  xwin.align_y   = 1;
  xwin.scr_x     = 1;
  xwin.scr_y     = 1;
  xwin.name      = name;
  xwin.info      = info;
  xwin.anz_trees = 2;
  xwin.trees     = &xtree [0];
  xwin.md        = tree;
  xwin.daction   = proc;

  if ( info [0] == 0 ) excl ( xwin.flags, INFO );

  form_center ( tree, &xwin.work.x, &xwin.work.y, &xwin.work.w, &xwin.work.h );
  x0 = xwin.work.x;
  y0 = xwin.work.y;
  if ( sysgem.center == FALSE )
    {
      MouseClicked ( &x0, &y0 );
      x0 = x0 - ( xwin.work.w / 2 );
      y0 = y0 - ( xwin.work.h / 2 );
    }
  xwin.work.x   = ( xpos < 0 ) ? x0 : xpos;
  xwin.work.y   = ( ypos < 0 ) ? y0 : ypos;

  if ( XWindow ( &xwin ))
    {
      win = find_window ( -1, id );
      if ( win != NULL )
        {
          SendMessage ( SG_NEWDIAL, win, NULL, NULL, active, 0, 0, 0 );
          FixWinTree ( win );
          SendMessage ( SG_START, win, NULL, NULL, 0, 0, 0, 0 );
          return ( TRUE );
        }
    }
  else
    {
      if ( proc != NULL )
        {
          proc ( SG_NOWIN, -1, NULL );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */
/* [GS]																																 */

VOID ChangeDialog ( LONG id, INT active )

{
  WINDOW        *win;
  WTREE         *wt;

  if (( win = find_window ( -1, id )) == NULL )
    {
      return ;
    }
  wt = win->tree;
  while ( wt != NULL)
  	{
  		if ( wt->pos == LINK_REITER )
  			{
					KeyFound (win, wt, 0, 0, active, FALSE );
					return;
				}
			wt = wt->next;
		}
}

/* ------------------------------------------------------------------- */

INT OpenWindow ( LONG id, BYTE *name, BYTE *info, INT flags, OBJECT *menu, INT align, BOOL part, INT scr_x, INT scr_y, LONG doc_x, LONG doc_y, INT x, INT y, INT w, INT h, VOID *user, RPROC redraw, APROC action )

{
  WINDOW        *win;
  XWIN          xwin;

  InitXWindow ( &xwin );

  if ( menu != NULL )
    {
      y += menu [1].ob_height;
      y += 1;
      h -= menu [1].ob_height;
      h -= 1;
    }

  xwin.id       = id;
  xwin.name     = name;
  xwin.info     = info;
  xwin.flags    = flags;
  xwin.menu     = menu;
  xwin.align_x  = align;
  xwin.cfg      = ( part ) ? WIN_PAINT : 0;
  xwin.doc_w    = doc_x;
  xwin.doc_h    = doc_y;
  xwin.work.x   = x;
  xwin.work.y   = y;
  xwin.work.w   = w;
  xwin.work.h   = h;
  xwin.user     = user;
  xwin.waction  = action;
  xwin.redraw   = redraw;

  if ( scr_x > 0 ) xwin.scr_x    = scr_x;
  if ( scr_y > 0 ) xwin.scr_y    = scr_y;

  if ( XWindow ( &xwin ))
    {
      win = find_window ( -1, id );
      if ( win != NULL )
        {
          return ( win->handle );
        }
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

INT OpenTextWindow ( LONG id, BYTE *name, BYTE *info, OBJECT *menu, INT x, INT y, INT w, INT h, VOID *user, APROC action )

{
  WINDOW        *win;
  XWIN          xwin;

  InitXWindow ( &xwin );

  xwin.id       = id;
  xwin.name     = name;
  xwin.info     = info;
  xwin.flags    = 0xfef | SMALLER;
  if (( info != NULL ) && ( info [0] != 0 )) xwin.flags |= INFO;
  xwin.menu     = menu;
  xwin.cfg      = WIN_PAINT;
  xwin.doc_w    = 1L;
  xwin.doc_h    = 1L;
  xwin.work.x   = x;
  xwin.work.y   = y;
  xwin.work.w   = w * xwin.scr_x;
  xwin.work.h   = h * xwin.scr_y;
  xwin.user     = user;
  xwin.waction  = action;
  xwin.redraw   = (RPROC) NULL;

  if ( menu != NULL )
    {
      xwin.work.y += menu [1].ob_height;
      xwin.work.y += 1;
      xwin.work.h -= menu [1].ob_height;
      xwin.work.h -= 1;
    }

  if ( XWindow ( &xwin ))
    {
      win = find_window ( -1, id );
      if ( win != NULL ) return ( win->handle );
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

VOID SetOwner ( LONG owner )

{
  win_owner = owner;
}

/* ------------------------------------------------------------------- */

LONG GetOwner ( LONG win_id )

{
  WINDOW        *win;

  if (( win = find_window ( -1, win_id )) != NULL )
    {
      return ( win->owner );
    }
  return ( 0L );
}

/* ------------------------------------------------------------------- */
