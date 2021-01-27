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
EXTERN  RECT    sg_clip_r;
EXTERN	BOOL	not_draw_white;

/* ------------------------------------------------------------------- */

VOID SetNewMax ( WINDOW *win, BOOL x )

{
  REG   WTEXT   *wtxt;
        LONG    l1;
        INT     w;
        INT     h;

  SetFont ( win->font_id, win->font_pt );
  w    = StringWidth ( "W" );
  h    = StringHeight ();
  wtxt = win->first;
  if ( x )
    {
      win->doc_x = 0L;
      while ( wtxt != NULL )
        {
          l1         = (LONG)( simulate_out ( -1, wtxt->text, 0, w, &win->tab [0] ));
          win->doc_x = max ( l1, win->doc_x );
          wtxt       = wtxt->next;
        }
    }
  else
    {
      win->doc_y = (LONG)( h );
      while ( wtxt != NULL )
        {
          l1         = (LONG)( wtxt->height );
          win->doc_y = max ( l1, win->doc_y );
          wtxt       = wtxt->next;
        }
      win->scr_y     = (INT)( win->doc_y );
      if ( win->scr_y <= 0 ) win->scr_y = 1;
      win->doc_y    *= (LONG)( win->lines );
    }
  NormalFont ();
}

/* ------------------------------------------------------------------- */

VOID BeginListUpdate ( LONG win_id )

{
  WINDOW	*win;
  
  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      win->list_upd = TRUE;
    }
}

/* ------------------------------------------------------------------- */

VOID ListUpdate ( WINDOW *win )

{
  RECT  work;

  if ( win->list_upd == FALSE )
    {
      work.x = win->work.x;
      work.y = win->work.y;
      work.w = win->work.w;
      work.h = win->work.h;

      SetNewMax ( win, 1 );
      SetNewMax ( win, 0 );

      CalcSlider ( win, &work );
      if ( win->flags & WIN_DRAWN )
        {
          CheckWindow ( win->id );
          DoRedraw ( win, &work );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID EndListUpdate ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      win->list_upd = FALSE;
      ListUpdate ( win );
    }
}

/* ------------------------------------------------------------------- */

VOID RedrawText ( WINDOW_INFO *inf )

{
  VOID          (*otext)( INT, INT, INT, BYTE * );
  WTEXT         *wtxt;
  WINDOW        *win;
  RECT          r;
  INT           h;
  INT           w, i;
  INT           color;


  win = find_window ( -1, inf->id );
  if ( win == NULL ) return;

  wtxt = find_line ( win, (UINT)( win->pos_y / (LONG)( win->scr_y )));
  if ( wtxt == NULL ) return;

  BeginControl ( CTL_UPDATE | CTL_MHIDE );
  SetFont ( win->font_id, win->font_pt );
  ReplaceMode ();

  r.x = win->work.x;
  r.x = r.x - (INT)( win->pos_x );
  r.y = win->work.y;
  r.w = win->work.w;
  r.h = win->work.h;
  h   = inf->clip.y + inf->clip.h - 1;
  w   = StringWidth ( "W" );
  if ( r.y + r.h - 1 < h ) h = r.y + r.h - 1;

  while ( wtxt != NULL )
    {
      if ( r.y + win->scr_y > inf->clip.y ) break;
      r.y += win->scr_y;
      wtxt = wtxt->next;
    }
  while ( wtxt != NULL )
    {
      color = wtxt->color;
      if ( wtxt->icon != NULL )
        {
          if ( wtxt->flags & 1 )
            {
              incl ( wtxt->icon [wtxt->start].ob_state, SELECTED );
              color = sysgem.selt_color;
              FilledRect ( win->work.x, r.y, win->work.x + win->work.w - 1, r.y + win->scr_y - 1, sysgem.selb_color );
            }
          else
            {
              excl ( wtxt->icon [wtxt->start].ob_state, SELECTED );
            }
          if ( wtxt->only )
            {
              wtxt->icon [wtxt->start].ob_x = r.x;
              i  = win->scr_y;
              i /= 2;
              i -= ( wtxt->icon [wtxt->start].ob_height / 2 );
              i += r.y;
              wtxt->icon [wtxt->start].ob_y = i;
              objc_draw ( wtxt->icon, wtxt->start, 0, sg_clip_r.x, sg_clip_r.y, sg_clip_r.w, sg_clip_r.h );
            }
          else
            {
              wtxt->icon [0].ob_x = 0;
              wtxt->icon [0].ob_y = 0;
              wtxt->icon [wtxt->start].ob_x = r.x;
              wtxt->icon [wtxt->start].ob_y = r.y;
              wtxt->icon [wtxt->start].ob_width = r.w;
              objc_draw ( wtxt->icon, wtxt->start, 8, sg_clip_r.x, sg_clip_r.y, sg_clip_r.w, sg_clip_r.h );
            }
        }
      else
        {
          if ( wtxt->flags & 1 )
            {
              color = sysgem.selt_color;
              FilledRect ( win->work.x, r.y, win->work.x + win->work.w - 1, r.y + win->scr_y - 1, sysgem.selb_color );
            }
          else
            {
            }
        }
      if ( ! not_draw_white ) TransMode ();
      TextEffect ( wtxt->effect );
      if ( win->tab [0].pos == -1 )
        {
          if ( wtxt->len < 127 )
            {
              otext = v_stext;
            }
          else
            {
              otext = v_xtext;
            }
          otext ( color, r.x, CenterY ( r.y, r.y + win->scr_y ) - 1, wtxt->text );
        }
      else
        {
          output_sld ( color, wtxt->text, r.x, CenterY ( r.y, r.y + win->scr_y ) - 1, w, &win->tab [0], v_xtext );
        }
      ReplaceMode ();
      r.y += win->scr_y;
      wtxt = wtxt->next;
      if ( r.y >= h ) break;
    }
  EndControl ( CTL_UPDATE | CTL_MHIDE );
  TextEffect ( 0 );
  NormalFont ();
}

/* ------------------------------------------------------------------- */

BYTE *xLinkList ( LONG win_id, BYTE *text, INT effect, VOID *user )

{
  WINDOW        *win;
  WTEXT         *wtxt;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( NULL );

  if ( win->first != NULL ) return ( NULL );

  SetFont ( win->font_id, win->font_pt );
  win->scr_x    = StringWidth ( "W" );
  win->scr_y    = StringHeight ();
  win->doc_x    = 0L;
  win->doc_y    = 0L;
  win->redraw   = RedrawText;
  NormalFont ();

  wtxt = (WTEXT *) Allocate ( sizeof ( WTEXT ));
  if ( wtxt == NULL ) return ( NULL );

  wtxt->text    = (BYTE *) Allocate ( strlen ( text ) + 1L );
  if ( wtxt->text == NULL )
    {
      Dispose ( wtxt );
      return ( NULL );
    }
  else
    {
      strcpy ( wtxt->text, text );
    }
  wtxt->next    = NULL;
  wtxt->user    = user;
  wtxt->icon    = NULL;
  wtxt->start   = 0;
  wtxt->effect  = effect;
  wtxt->color   = BLACK;
  wtxt->flags   = 0;
  wtxt->len     = length ( text );
  wtxt->pixel   = wtxt->len * win->scr_x;
  wtxt->height  = 0;

  win->lines    = 1;
  win->doc_x    = (LONG)( wtxt->pixel );
  win->doc_y    = (LONG)( win->scr_y  );

  win->first    = wtxt;
  win->last     = wtxt;

  ListUpdate ( win );

  return ( wtxt->text );
}

/* ------------------------------------------------------------------- */

BYTE *xAddToList ( LONG win_id, BYTE *text, INT effect, VOID *user )

{
  WINDOW        *win;
  WTEXT         *wtxt;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( NULL );

  if ( win->first == NULL )
    {
      return ( xLinkList ( win_id, text, effect, user ));
    }

  if ( win->lines >= 65534U ) return ( NULL );

  wtxt = (WTEXT *) Allocate ( sizeof ( WTEXT ));
  if ( wtxt == NULL ) return ( NULL );

  wtxt->text    = (BYTE *) Allocate ( strlen ( text ) + 1L );
  if ( wtxt->text == NULL )
    {
      Dispose ( wtxt );
      return ( NULL );
    }
  else
    {
      strcpy ( wtxt->text, text );
    }
  wtxt->next      = NULL;
  wtxt->user      = user;
  wtxt->icon      = NULL;
  wtxt->start     = 0;
  wtxt->effect    = effect;
  wtxt->color     = BLACK;
  wtxt->flags     = 0;
  wtxt->len       = length ( text );
  wtxt->pixel     = wtxt->len * win->scr_x;
  wtxt->height    = 0;

  win->lines     += 1;
  win->doc_y      = (LONG)( win->scr_y  ) * (LONG)( win->lines );

  win->doc_x      = max (((LONG)( wtxt->pixel )), ( win->doc_x ));

  win->last->next = wtxt;
  win->last       = wtxt;

  ListUpdate ( win );

  return ( wtxt->text );
}

/* ------------------------------------------------------------------- */

BYTE *xInsInList ( LONG win_id, UINT line, BYTE *text, INT effect, VOID *user )

{
  WINDOW        *win;
  WTEXT         *wtxt;
  WTEXT         *wtxt2;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( NULL );

  if ( win->first == NULL )
    {
      return ( xLinkList ( win_id, text, effect , user ));
    }

  if ( win->lines >= 65534U ) return ( NULL );

  if ( line > win->lines )
    {
      return ( xAddToList ( win_id, text, effect, user ));
    }

  wtxt = (WTEXT *) Allocate ( sizeof ( WTEXT ));
  if ( wtxt == NULL ) return ( NULL );

  wtxt->text    = (BYTE *) Allocate ( strlen ( text ) + 1L );
  if ( wtxt->text == NULL )
    {
      Dispose ( wtxt );
      return ( NULL );
    }
  else
    {
      strcpy ( wtxt->text, text );
    }
  wtxt->next      = NULL;
  wtxt->user      = user;
  wtxt->icon      = NULL;
  wtxt->start     = 0;
  wtxt->effect    = effect;
  wtxt->color     = BLACK;
  wtxt->flags     = 0;
  wtxt->len       = length ( text );
  wtxt->pixel     = wtxt->len * win->scr_x;
  wtxt->height    = 0;

  if ( line == 0U )
    {
      wtxt->next  = win->first;
      win->first  = wtxt;
      win->lines += 1;
    }
  else
    {
      wtxt2 = find_line ( win, line - 1 );
      if ( wtxt2 != NULL )
        {
          wtxt->next  = wtxt2->next;
          wtxt2->next = wtxt;
          win->lines += 1;
          win->doc_y  = (LONG)( win->scr_y  ) * (LONG)( win->lines );
          win->doc_x  = max (((LONG)( wtxt->pixel )), ( win->doc_x ));
        }
      else
        {
          Dispose ( wtxt->text );
          Dispose ( wtxt );
          return ( NULL );
        }
    }

  ListUpdate ( win );

  return ( wtxt->text );
}

/* ------------------------------------------------------------------- */

BYTE *xChgInList ( LONG win_id, UINT line, BYTE *text, VOID *user )

{
  WINDOW        *win;
  WTEXT         *wtxt;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( NULL );

  wtxt = find_line ( win, line );
  if ( wtxt == NULL ) return ( NULL );

  if ( text == NULL )
    {
      return ( wtxt->text );
    }

  Dispose ( wtxt->text );

  wtxt->text = (BYTE *) Allocate ( strlen ( text ) + 1L );
  if ( wtxt->text == NULL )
    {
      return ( NULL );
    }
  else
    {
      strcpy ( wtxt->text, text );
    }
  wtxt->user      = user;
  wtxt->len       = length ( text );
  wtxt->pixel     = wtxt->len * win->scr_x;
  wtxt->height    = 0;

  ListUpdate ( win );

  return ( wtxt->text );
}

/* ------------------------------------------------------------------- */

VOID RedrawLine ( LONG win_id, UINT line )

{
  WTEXT         *wtxt;
  WINDOW        *win;
  RECT          r;
  RECT          w;
  INT           h;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return;

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      w.x = win->work.x;
      w.y = win->work.y;
      w.w = win->work.w;
      w.h = win->work.h;

      h   = win->scr_y;

      r.x = w.x;
      r.y = (INT)( win->pos_y / (LONG)( h ));
      r.y = line - r.y;
      if ( r.y < 0 )
        {
          return;
        }
      r.y = r.y * h;
      r.y = r.y + w.y;
      r.w = w.w;
      r.h = h;
      DoRedraw ( win, &r );
    }
}

/* ------------------------------------------------------------------- */

UINT CountLines ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      return ( win->lines );
    }
  return ( 0U );
}

/* ------------------------------------------------------------------- */

INT GetLineHeight ( LONG win_id )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      return ( win->scr_y );
    }
  return ( 0U );
}

/* ------------------------------------------------------------------- */

BOOL SetWindowFont ( LONG win_id, INT font_id, INT font_pt )

{
  WINDOW        *win;
  INT		old_id, old_pt;
  RECT		r;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );
  
  if ( win->icon != 0 ) return ( FALSE );

  old_id = win->font_id;
  old_pt = win->font_pt;
  if ( ! FontExists ( font_id )) return ( FALSE );

  if (( VectorFont ( font_id )) && ( win->log.txt != NULL ))
    {
      font_id = win->font_id;
    }

  SetFont ( font_id, font_pt );
  win->font_id  = font_id;
  win->font_pt  = font_pt;
  win->scr_x    = StringWidth ( "W" );
  win->scr_y    = StringHeight ();
  NormalFont ();

  if (( old_id != win->font_id ) || ( old_pt != win->font_pt ))
    {
      if ( win->log.txt != NULL )
        {
          if ( win->flags & WIN_DRAWN )
            {
              if ( win->flags & WIN_VISIBLE )
                {
                  wind_get ( win->handle, WF_WORKXYWH, &r.x, &r.y, &r.w, &r.h );
                  SetFont ( font_id, font_pt );
                  win->scr_x    = StringWidth ( "W" );
                  win->scr_y    = StringHeight ();
                  win->log.w    = StringWidth ( "W" );
                  win->log.h    = StringHeight ();
                  win->work.w   = StringWidth ( "W" ) * win->log.col;
                  win->work.h   = StringHeight () * win->log.row;
                  r.w           = win->work.w;
                  r.h           = win->work.h;
                  NormalFont ();
                  wind_calc  ( WC_BORDER, win->kind, r.x, r.y, r.w, r.h, &r.x, &r.y, &r.w, &r.h );
                  wind_set   ( win->handle, WF_CURRXYWH, r.x, r.y, r.w, r.h );
                  FixWinTree ( win );
                }
            }
        }
    }

  ListUpdate ( win );

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

BYTE *LinkList ( LONG win_id, BYTE *text )

{
  return ( xLinkList ( win_id, text, 0, NULL ));
}

/* ------------------------------------------------------------------- */

BYTE *AddToList ( LONG win_id, BYTE *text )

{
  return ( xAddToList ( win_id, text, 0, NULL ));
}

/* ------------------------------------------------------------------- */

BYTE *InsInList ( LONG win_id, UINT line, BYTE *text )

{
  return ( xInsInList ( win_id, line, text, 0, NULL ));
}

/* ------------------------------------------------------------------- */

BYTE *ChgInList ( LONG win_id, UINT line, BYTE *text )

{
  return ( xChgInList ( win_id, line, text, NULL ));
}

/* ------------------------------------------------------------------- */

BOOL SetLineIcon ( LONG win_id, UINT line, OBJECT *tree, INT obj )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt == NULL ) return ( FALSE );

  if ( tree == NULL )
    {
      wtxt->icon    = NULL;
      wtxt->start   = 0;
      wtxt->only    = FALSE;
      wtxt->height  = 0;
    }
  else
    {
      wtxt->icon    = tree;
      wtxt->start   = obj;
      wtxt->only    = FALSE;
      wtxt->height  = tree [obj].ob_height;
    }

  ListUpdate ( win );

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

BOOL xSetLineIcon ( LONG win_id, UINT line, OBJECT *tree, INT obj )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt == NULL ) return ( FALSE );

  if ( tree == NULL )
    {
      wtxt->icon    = NULL;
      wtxt->start   = 0;
      wtxt->only    = FALSE;
      wtxt->height  = 0;
    }
  else
    {
      wtxt->icon    = tree;
      wtxt->start   = obj;
      wtxt->only    = TRUE;
      wtxt->height  = tree [obj].ob_height;
    }

  ListUpdate ( win );

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

INT SetLineEffect ( LONG win_id, UINT line, INT effect )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      if ( effect < 0 ) return ( wtxt->effect );
      wtxt->effect = effect;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT SetLineColor ( LONG win_id, UINT line, INT color )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      if ( color < 0 ) return ( wtxt->color );
      wtxt->color = color;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT SetLineFlags ( LONG win_id, UINT line, INT flags )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
/* GS 2.50 Start: */
      if ( flags == -1 ) return ( wtxt->flags );
      if ( flags == -2 )
     		{
      		wtxt->flags ^= 0x0001;
      		return ( 0 );
      	}
/* Ende; alt:
      if ( flags < 0 ) return ( wtxt->flags );
*/
      wtxt->flags = flags;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT SetLineUser ( LONG win_id, UINT line, INT user )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      if ( user < 0 ) return ( wtxt->user_flag );
      wtxt->user_flag = user;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

BOOL SetListUserPtr ( LONG win_id, UINT line, VOID *user )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      wtxt->user = user;
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

INT GetTabPosition ( LONG win_id, INT tab_nr, BOOL pixel )

{
  WINDOW        *win;
  INT		p;

  p   = -1;
  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( -1 );
  
  if ( win->tab [tab_nr].pos != -1 )
    {
      SetFont ( win->font_id, win->font_pt );
      if ( pixel )
        {
          p = win->tab [tab_nr].pos * StringWidth ( "W" );
        }
      else
        {
          p = win->tab [tab_nr].pos;
        }
      NormalFont ();
    }
  return ( p );
}

/* ------------------------------------------------------------------- */

BOOL DelInList ( LONG win_id, UINT line )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( FALSE );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      Dispose ( wtxt->text );
      DeletePtr ( &win->first, wtxt );
      win->lines--;
      wtxt = win->first;
      while ( wtxt != NULL )
        {
          if ( wtxt->next == NULL ) break;
          wtxt = wtxt->next;
        }
      win->last = wtxt;
      ListUpdate ( win );
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL SetListTab ( LONG win_id, INT pos, INT just )

{
  REG   WINDOW  *win;
  REG   INT     i;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      for ( i = 0; i < MAX_TAB; i++ )
        {
          if ( win->tab [i].pos == -1 )
            {
              win->tab [i].pos  = pos;
              win->tab [i].just = just;
              return ( TRUE );
            }
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL UpdListTab ( LONG win_id, INT tab, INT pos, INT just )

{
  REG   WINDOW  *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if ( win->tab [tab].pos != -1 )
        {
          win->tab [tab].pos  = pos;
          win->tab [tab].just = just;
          ListUpdate ( win );
          return ( TRUE );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

