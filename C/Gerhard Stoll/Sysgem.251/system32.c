/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        "nkcc.h"
#include        <scan.h>
#include        <ctype.h>
#include        <tos.h>
#include        <string.h>
#include        <stdlib.h>
#include        <stdio.h>

/* -------------------------------------------------------------------
 * Resource
 * ------------------------------------------------------------------- */

#include        "sgem.h"
#include        "sgem.rh"
#include        "sgem.rsh"

#define         rsc_icon        rs_trindex [MAIN_ICON]
#define         rsc_listbox     rs_trindex [MAIN_TREE]
#define         rsc_msg         rs_trindex [MSG]
#define         rsc_cycle       rs_trindex [CYCLE]
#define         rsc_font        rs_trindex [FONTSEL]
#define         rsc_stat        rs_trindex [STATUS]

#define         RSBB0DATA       sg000_ib
#define         RSBB1DATA       sg001_ib
#define         RSBB2DATA       sg002_ib
#define         rs_bitblk       sg010_ib

/* -------------------------------------------------------------------
 * Strukturen
 * ------------------------------------------------------------------- */

typedef struct
  {
    BYTE        text    [20];
    INT         obj;
  } XBUTT;

/* ------------------------------------------------------------------- */

typedef struct
  {
    UINT        ign1    : 3;
    UINT        caps    : 1;
    UINT        alt     : 1;
    UINT        contrl  : 1;
    UINT        lshift  : 1;
    UINT        rshift  : 1;
    UINT        scan    : 8;
    UINT        ign2    : 8;
    UINT        ascii   : 8;
  } TKEY;

/* ------------------------------------------------------------------- */

typedef struct _cov
  {
    struct _cov *next;
  } CONVERT;

/* ------------------------------------------------------------------- */

typedef struct
  {
    INT         version;
    LONG        datum;
  } NVDI;

/* ------------------------------------------------------------------- */

typedef struct
  {
    LONG        dummy1;
    LONG        dummy2;
    INT         version;
  } WINX_COOKIE;

/* -------------------------------------------------------------------
 * Variablen
 * ------------------------------------------------------------------- */

LOCAL BYTE chr_key [] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

/* ------------------------------------------------------------------- */

LOCAL UINT ctl_key [] = { CNTRL_A, CNTRL_B, CNTRL_C, CNTRL_D, CNTRL_E,
                          CNTRL_F, CNTRL_G, CNTRL_H, CNTRL_I, CNTRL_J,
                          CNTRL_K, CNTRL_L, CNTRL_M, CNTRL_N, CNTRL_O,
                          CNTRL_P, CNTRL_Q, CNTRL_R, CNTRL_S, CNTRL_T,
                          CNTRL_U, CNTRL_V, CNTRL_W, CNTRL_X, CNTRL_Y,
                          CNTRL_Z, CNTRL_0, CNTRL_1, CNTRL_2, CNTRL_3,
                          CNTRL_4, CNTRL_5, CNTRL_6, CNTRL_7, CNTRL_8,
                          CNTRL_9, 0 };

/* ------------------------------------------------------------------- */

LOCAL UINT alt_key [] = { ALT_A, ALT_B, ALT_C, ALT_D, ALT_E, ALT_F,
                          ALT_G, ALT_H, ALT_I, ALT_J, ALT_K, ALT_L,
                          ALT_M, ALT_N, ALT_O, ALT_P, ALT_Q, ALT_R,
                          ALT_S, ALT_T, ALT_U, ALT_V, ALT_W, ALT_X,
                          ALT_Y, ALT_Z, ALT_0, ALT_1, ALT_2, ALT_3,
                          ALT_4, ALT_5, ALT_6, ALT_7, ALT_8, ALT_9,
                          0 };

/* ------------------------------------------------------------------- */

LOCAL WORD RSBB0DATA[] =
{ 0x0003, 0xC000, 0x0006, 0x6000,
  0x000D, 0xB000, 0x001B, 0xD800,
  0x0037, 0xEC00, 0x006F, 0xF600,
  0x00DC, 0x3B00, 0x01BC, 0x3D80,
  0x037C, 0x3EC0, 0x06FC, 0x3F60,
  0x0DFC, 0x3FB0, 0x1BFC, 0x3FD8,
  0x37FC, 0x3FEC, 0x6FFC, 0x3FF6,
  0xDFFC, 0x3FFB, 0xBFFC, 0x3FFD,
  0xBFFC, 0x3FFD, 0xDFFC, 0x3FFB,
  0x6FFC, 0x3FF6, 0x37FC, 0x3FEC,
  0x1BFF, 0xFFD8, 0x0DFF, 0xFFB0,
  0x06FC, 0x3F60, 0x037C, 0x3EC0,
  0x01BC, 0x3D80, 0x00DC, 0x3B00,
  0x006F, 0xF600, 0x0037, 0xEC00,
  0x001B, 0xD800, 0x000D, 0xB000,
  0x0006, 0x6000, 0x0003, 0xC000
};

LOCAL WORD RSBB1DATA[] =
{ 0x3FFF, 0xFFFC, 0xC000, 0x0003,
  0x9FFF, 0xFFF9, 0xBFFF, 0xFFFD,
  0xDFF8, 0x3FFB, 0x5FE0, 0x0FFA,
  0x6FC0, 0x07F6, 0x2F83, 0x83F4,
  0x3787, 0xC3EC, 0x1787, 0xC3E8,
  0x1BFF, 0x83D8, 0x0BFF, 0x07D0,
  0x0DFE, 0x0FB0, 0x05FC, 0x1FA0,
  0x06FC, 0x3F60, 0x02FC, 0x3F40,
  0x037C, 0x3EC0, 0x017C, 0x3E80,
  0x01BF, 0xFD80, 0x00BF, 0xFD00,
  0x00DC, 0x3B00, 0x005C, 0x3A00,
  0x006C, 0x3600, 0x002F, 0xF400,
  0x0037, 0xEC00, 0x0017, 0xE800,
  0x001B, 0xD800, 0x000B, 0xD000,
  0x000D, 0xB000, 0x0005, 0xA000,
  0x0006, 0x6000, 0x0003, 0xC000
};

LOCAL WORD RSBB2DATA[] =
{ 0x007F, 0xFE00, 0x00C0, 0x0300,
  0x01BF, 0xFD80, 0x037F, 0xFEC0,
  0x06FF, 0xFF60, 0x0DFF, 0xFFB0,
  0x1BFF, 0xFFD8, 0x37FF, 0xFFEC,
  0x6FFF, 0xFFF6, 0xDFFF, 0xFFFB,
  0xB181, 0x860D, 0xA081, 0x0205,
  0xA4E7, 0x3265, 0xA7E7, 0x3265,
  0xA3E7, 0x3265, 0xB1E7, 0x3205,
  0xB8E7, 0x320D, 0xBCE7, 0x327D,
  0xA4E7, 0x327D, 0xA0E7, 0x027D,
  0xB1E7, 0x867D, 0xBFFF, 0xFFFD,
  0xDFFF, 0xFFFB, 0x6FFF, 0xFFF6,
  0x37FF, 0xFFEC, 0x1BFF, 0xFFD8,
  0x0DFF, 0xFFB0, 0x06FF, 0xFF60,
  0x037F, 0xFEC0, 0x01BF, 0xFD80,
  0x00C0, 0x0300, 0x007F, 0xFE00
};

LOCAL BITBLK rs_bitblk[] =
{ RSBB0DATA,   4,  32,   0,   0, 0x0009,
  RSBB1DATA,   4,  32,   0,   0, 0x0009,
  RSBB2DATA,   4,  32,   0,   0, 0x0009
};

/* ------------------------------------------------------------------- */

LOCAL   INT             m_mouse         = 0;
LOCAL   INT             m_update        = 0;
LOCAL   INT             m_show          = 0;
LOCAL   COOKIE          sgcookie        = { 0L, 0L };
LOCAL   VDIPB           pb;
LOCAL   BYTE            v_output [300];
LOCAL   MFDB            dst             = { NULL,  0,  0, 0, 0, 0, 0, 0, 0 };
LOCAL   INT             high_result;
        RECT            sg_clip_r;
LOCAL   BYTE            clip_buff       [400];
LOCAL   BYTE            edit_buff       [170];
LOCAL   BYTE            buffer          [1024];
LOCAL   DIALOG_SYS      *for_edit       = NULL;
LOCAL   BOOL            sg_redredit     = FALSE;
LOCAL   USERBLK         menu_user;
LOCAL   LONG            xid;
LOCAL   XBUTT           button          [ 6];
LOCAL   OBJECT          alert_tree      [30];
LOCAL   BYTE            alert_text      [16][75];
        VOID            *xusr1;
LOCAL   VOID            *xusr2;
        BOOL            on_screen       = FALSE;
        INT             ed_field        = 0;
        BOOL            sg_sldforone    = FALSE;
        BOOL            not_draw_white  = FALSE;

/* ------------------------------------------------------------------- */

#ifdef PASCAL
LOCAL   BYTE            sccs0 []        = "@(#) SysGem (c) 1995 by Andrea Pietsch / V2.51 / PurePascal ("__DATE__", "__TIME__")";
#else
LOCAL   BYTE            sccs0 []        = "@(#) SysGem (c) 1995 by Andrea Pietsch, Gerhard Stoll / V2.51 / PureC ("__DATE__", "__TIME__")";
#endif
LOCAL   BYTE            sccs1 []        = "SysGem V2.51";
LOCAL		BYTE						sccs2 []				= __DATE__;							/* [GS] 2.51 */

/* ------------------------------------------------------------------- */

EXTERN  VOID Init16System ( VOID );

/* ------------------------------------------------------------------- */

EXTERN  INT             turn_back;

/* ------------------------------------------------------------------- */

GLOBAL  SYSGEM  sysgem;
GLOBAL  XEVENT  xevent;

/* ------------------------------------------------------------------- */

UINT SysGemVersion ( VOID )

{
/* [GS] 2.51, Start: */
  return ( 0x0251 );
/* alt:
  return ( 0x0203 );
*/
}

/* ------------------------------------------------------------------- */

VOID InitSgSystem ( VOID )

{
  m_mouse               = 0;
  m_update              = 0;
  m_show                = 0;
  sgcookie.id           = 0L;
  sgcookie.value        = 0L;
  sg_redredit           = 0;
  on_screen             = FALSE;
  ed_field              = 0;
  sg_sldforone          = 0;
  not_draw_white        = FALSE;
  memset ( v_output,  0, sizeof ( v_output  ));
  memset ( clip_buff, 0, sizeof ( clip_buff ));
  memset ( edit_buff, 0, sizeof ( edit_buff ));
  memset ( buffer,    0, sizeof ( buffer    ));
}

/* -------------------------------------------------------------------
 * Wir buddeln im System...
 * ------------------------------------------------------------------- */

BYTE *SysGemVerStr ( INT i )

{
	if ( i == 1 )
		return ( &sccs2 [0] );

  return ( &sccs1 [0] );
}

/* ------------------------------------------------------------------- */

LOCAL LONG xget_cookie ( VOID )

{
  REG COOKIE    *jar;

  jar = *(COOKIE **) 0x5a0L;
  if ( jar != NULL )
    {
      forever
        {
          if ( jar->id == 0L ) break;
          if ( jar->id == sgcookie.id )
            {
              sgcookie.value = jar->value;
              return ( 1L );
            }
          jar++;
        }
    }
  return ( 0L );
}

/* ------------------------------------------------------------------- */

BOOL GetCookie ( LONG id, VOID *value )

{
  LONG  result;
  LONG  *val;

  val            = (LONG *) value;
  sgcookie.id    = id;
  sgcookie.value = 0L;
  result = Supexec ( xget_cookie );
  if ( val != NULL ) *val = sgcookie.value;
  return ( result == 1L );
}

/* -------------------------------------------------------------------
 * Speicherverwaltung
 * ------------------------------------------------------------------- */

VOID *Allocate ( LONG size )

{
  VOID  *p;

  p = malloc ( size );
  if ( p != NULL )
    {
      memset ( p, 0, size );
      return ( p );
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID Dispose ( VOID *pointer )

{
  if ( pointer == NULL ) return;
  free ( pointer );
}

/* ------------------------------------------------------------------- */

VOID InsertPtr ( VOID *src, VOID *mem )

{
  REG   CONVERT       *s;
  REG   CONVERT       *d;

  d = (CONVERT *) mem;
  s = (CONVERT *)(*(LONG *) src );
  d->next = NULL;
  if ( s == NULL )
    {
      *(LONG *) src = (LONG)( mem );
      return;
    }
  else
    {
      while ( s != NULL )
        {
          if ( s->next == NULL )
            {
              s->next = d;
              return;
            }
          s = s->next;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID DeletePtr ( VOID *src, VOID *mem )

{
  REG   CONVERT       *s;
  REG   CONVERT       *d;

  d = (CONVERT *) mem;
  s = (CONVERT *)(*(LONG *) src );
  if ( s == NULL ) return;
  if ( s == d )
    {
      *(LONG *) src = (LONG)( s->next );
      Dispose ( mem );
      return;
    }
  else
    {
      while ( s != NULL )
        {
          if ( s->next == d )
            {
              s->next = d->next;
              Dispose ( mem );
              return;
            }
          s = s->next;
        }
    }
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

#endif

/* -------------------------------------------------------------------
 * Bildschirm- und Mauskontrolle
 * ------------------------------------------------------------------- */

VOID BeginControl ( INT ctrl )

{
  if ( ctrl & CTL_MOUSE )
    {
      m_mouse++;
      if ( m_mouse == 1 ) wind_update ( BEG_MCTRL );
    }
  if ( ctrl & CTL_UPDATE )
    {
      m_update++;
      if ( m_update == 1 ) wind_update ( BEG_UPDATE );
    }
  if ( ctrl & CTL_MHIDE )
    {
      m_show++;
      if ( m_show == 1 ) graf_mouse ( M_OFF, NULL );
    }
}

/* ------------------------------------------------------------------- */

VOID EndControl ( INT ctrl )

{
  if ( ctrl & CTL_MOUSE )
    {
      m_mouse--;
      if ( m_mouse == 0 ) wind_update ( END_MCTRL );
    }
  if ( ctrl & CTL_UPDATE )
    {
      m_update--;
      if ( m_update == 0 ) wind_update ( END_UPDATE );
    }
  if ( ctrl & CTL_MHIDE )
    {
      m_show--;
      if ( m_show == 0 ) graf_mouse ( M_ON, NULL );
    }
}

/* ------------------------------------------------------------------- */

BOOL MouseClicked ( INT *x, INT *y )

{
  INT   d;

  vq_mouse ( sysgem.vdi_handle, &d, x, y );
  return ( d != 0 );
}

/* ------------------------------------------------------------------- */

VOID RectIntersect ( RECT *r1, RECT *r2 )

{
  REG   INT   x, y, w, h;

  x = max ( r1->x, r2->x );
  y = max ( r1->y, r2->y );
  w = min (( r1->x + r1->w ), ( r2->x + r2->w )) - x;
  h = min (( r1->y + r1->h ), ( r2->y + r2->h )) - y;

  r2->x = x;
  r2->y = y;
  r2->w = w;
  r2->h = h;
}

/* ------------------------------------------------------------------- */

VOID WhiteArea ( RECT *r, INT color )

{
  BeginControl ( CTL_MHIDE );
  FilledRect ( r->x, r->y, r->x + r->w - 1, r->y + r->h - 1, color );
  EndControl ( CTL_MHIDE );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

VOID SetLinkIconColor ( LONG win_id, INT color )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      win->icon_icolor = color;
    }
}

/* ------------------------------------------------------------------- */

VOID SetLinkTextColor ( LONG win_id, INT color )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      win->icon_tcolor = color;
    }
}

/* ------------------------------------------------------------------- */

VOID RedrawIconified ( LONG win_id, RECT *r )

{
  WINDOW        *win;
  INT           *old;
  RECT          work;

  NormalFont ();
  win = find_window ( -1, win_id );
  if ( win == NULL ) return;

  wind_get ( win->handle, WF_WORKXYWH, &work.x, &work.y, &work.w, &work.h );

  old = rsc_icon [IC_IC].ob_spec.bitblk->bi_pdata;
  SetText ( rsc_icon, IC_TX, "" );
  switch ( win->icon )
    {
      case ICON_MAIN : SetText ( rsc_icon, IC_TX, sysgem.iconified_name );
                       SetTextColor ( rsc_icon, IC_TX, win->icon_tcolor );
                       if ( sysgem.iconified_icon != NULL )
                         {
                           rsc_icon [IC_IC].ob_spec.bitblk->bi_pdata = sysgem.iconified_icon->bi_pdata;
                           rsc_icon [IC_IC].ob_spec.bitblk->bi_color = win->icon_icolor;
                         }
                       break;
      case ICON_ICON : SetText ( rsc_icon, IC_TX, win->icfs_name );
                       SetTextColor ( rsc_icon, IC_TX, win->icon_tcolor );
                       if ( win->icfs_icon != NULL )
                         {
                           rsc_icon [IC_IC].ob_spec.bitblk->bi_pdata = win->icfs_icon->bi_pdata;
                           rsc_icon [IC_IC].ob_spec.bitblk->bi_color = win->icon_icolor;
                         }
                       break;
      default        : break;
    }
  rsc_icon [0].ob_x = work.x;
  rsc_icon [0].ob_y = work.y;
  rsc_icon [0].ob_width = work.w;
  rsc_icon [0].ob_height = work.h;
  rsc_icon [1].ob_x = (( work.w - rsc_icon [1].ob_width ) / 2 );
  rsc_icon [1].ob_y = (( work.h - rsc_icon [1].ob_height ) / 2 );
  objc_draw ( rsc_icon, 0, 8, r->x, r->y, r->w, r->h );
  rsc_icon [IC_IC].ob_spec.bitblk->bi_pdata = old;
}

/* ------------------------------------------------------------------- */

VOID do_blink ( VOID )

{
  RECT          d, r;
  WINDOW        *win;

  if ( sysgem.cursor_off ) return;

  win = (WINDOW *) GetXTimerUser1 ();
  if ( win == NULL ) return;

  if (( GetTopWindow () != win->handle ) && ( win->log.cursor == 0 ))
    {
      return;
    }

  if (( win->flags & WIN_VISIBLE ) && ( win->log.cursor < 2 ))
    {
      d.x = ( win->log.x * win->log.w ) + win->work.x;
      d.y = ( win->log.y * win->log.h ) + win->work.y;
      d.w = win->log.w;
      d.h = win->log.h;
      if ( win->log.x >= win->log.col ) d.x -= win->log.w;

      BeginControl ( CTL_UPDATE | CTL_MHIDE );

      RectIntersect ( &sysgem.desk, &d );
      wind_get ( win->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h );
      while (( r.w > 0 ) && ( r.h > 0 ))
        {
          RectIntersect ( &d, &r );
          if (( r.w > 0 ) && ( r.h > 0 ))
            {
              SetClipping ( &r );
              inv_area ( BLACK, r.x, r.y, r.w, r.h );
            }
          wind_get ( win->handle, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h );
        }
      if ( win->log.cursor == 0 ) win->log.cursor = 1;
                             else win->log.cursor = 0;
      SetClipping ( NULL );
      EndControl ( CTL_UPDATE | CTL_MHIDE );
    }
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

VOID DoRedraw ( WINDOW *win, RECT *dirty )

{
  INT     x, y;
  RECT    r;
  RECT    v;
  WTREE   *wt;
#ifndef EXTOB
  SLIDER  *sld;
  XREDRAW *red;
#endif

  hide_cursor  ( win->dial );
  ReplaceMode  ();
  NormalFont   ();
  BeginControl ( CTL_UPDATE );

  wind_get ( win->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h );
  RectIntersect ( &sysgem.desk, dirty );

  while (( r.w > 0 ) && ( r.h > 0 ))
    {
      RectIntersect ( dirty, &r );
      if (( r.w > 0 ) && ( r.h > 0 ))
        {
          SetClipping ( &r );

#ifndef EXTOB
          if ( sg_sldforone ) goto slider_draw;

          if ( win->icon != 0 )
            {
              if ( win->iconredraw == NULL )
                {
                  RedrawIconified ( win->id, &r );
                }
              else
                {
                  win->iconredraw ( win->id, &r );
                }
              goto next_rectangle;
            }
#endif

          wt = win->tree;
          while ( wt != NULL )
            {
              if ( wt->dial != NULL )
                {
                  objc_draw ( wt->dial->tree, wt->start, wt->depth, r.x, r.y, r.w, r.h );
                  BeginControl ( CTL_MHIDE );
                  switch ( wt->pos )
                    {
                      case LINK_MENU   : y = wt->dial->tree [0].ob_y + wt->dial->tree [1].ob_height;
                                         Line ( win->work.x, y, win->work.x + win->work.w - 1, y, BLACK );
                                         break;
                      case LINK_TOP    : y = wt->dial->tree [wt->start].ob_y + wt->dial->tree [wt->start].ob_height;
                                         Line ( win->work.x - 1, y, win->work.x + win->work.w, y, BLACK );
                                         break;
                      case LINK_LEFT   : x = wt->dial->tree [wt->start].ob_x + wt->dial->tree [wt->start].ob_width;
                                         y = wt->dial->tree [wt->start].ob_y + wt->dial->tree [wt->start].ob_height;
                                         Line ( x, wt->dial->tree [wt->start].ob_y, x, y, BLACK );
                                         break;
                      case LINK_RIGHT  : x = wt->dial->tree [wt->start].ob_x - 1;
                                         y = wt->dial->tree [wt->start].ob_y + wt->dial->tree [wt->start].ob_height;
                                         Line ( x, wt->dial->tree [wt->start].ob_y, x, y, BLACK );
                                         break;
                      case LINK_BOTTOM : y = wt->dial->tree [wt->start].ob_y - 1;
                                         Line ( win->work.x - 1, y, win->work.x + win->work.w, y, BLACK );
                                         break;
                      default          : break;
                    }
                  EndControl ( CTL_MHIDE );
                }
              wt = wt->next;
            }

#ifndef EXTOB

          wt = win->tree;
          while ( wt != NULL )
            {
              red = wt->dial->redraw;
              while ( red != NULL )
                {
                  CalcArea ( wt->dial->tree, red->obj, &v );
                  v.x += 1;
                  v.y += 1;
                  v.w -= 2;
                  v.h -= 2;
                  RectIntersect ( &r, &v );
                  if (( v.w > 0 ) && ( v.h > 0 ))
                    {
                      SetClipping  ( &v );
                      BeginControl ( CTL_MHIDE );
                      SendMessage  ( SG_DRAWOWN, win, wt, NULL, red->obj, 0, 0, 0 );
                      EndControl   ( CTL_MHIDE );
                    }
                  red = red->next;
                }
              wt = wt->next;
            }

          slider_draw:

          if ( sysgem.draw_slider != NULL )
            {
              wt = win->tree;
              while ( wt != NULL )
                {
                  sld = wt->dial->slider;
                  while ( sld != NULL )
                    {
                      CalcArea ( sld->tree, sld->box, &v );
                      v.x += 1;
                      v.y += 1;
                      v.w -= 2;
                      v.h -= 2;
                      RectIntersect ( &r, &v );
                      if (( v.w > 0 ) && ( v.h > 0 ))
                        {
                          SetClipping ( &v );
                          sysgem.draw_slider ( sld->tree, sld->box, &v );
                        }
                      sld = sld->next;
                    }
                  wt = wt->next;
                }
            }
#endif
          SetClipping ( &r );

          if ( sg_sldforone ) goto next_rectangle;

          if ( win->flags & WIN_PAINT )
            {
              if ( ! not_draw_white ) WhiteArea ( &win->work, win->back );
            }

          if ( win->redraw != NULL )
            {
              v.x = r.x;
              v.y = r.y;
              v.w = r.w;
              v.h = r.h;
              RectIntersect ( &win->work, &v );
              if (( v.w > 0 ) && ( v.h > 0 ))
                {
                  SetClipping ( &v );
                  SendMessage ( SG_REDRAW, win, NULL, NULL, v.x, v.y, v.w, v.h );
                  SetClipping ( &r );
                }
            }
        }
      next_rectangle:
      wind_get ( win->handle, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h );
    }
  SetClipping ( NULL );
  EndControl ( CTL_UPDATE );

  if (( win->flags & WIN_DRAWN ) == 0 )
    {
      if ( win->dial == NULL )
        {
          if (( win->kind & HSLIDE ) || ( win->kind & VSLIDE ))
            {
#ifndef EXTOB
              CheckWindow ( win->id );
#endif
            }
        }
    }
  incl ( win->flags, WIN_DRAWN );
  not_draw_white = FALSE;
}

/* ------------------------------------------------------------------- */

VOID RedrawObj ( OBJECT *tree, INT obj, INT depth, INT state, INT flag )

{
  WINDOW  *win;
  RECT    r;

  if ( state != 0 )
    {
      if ( flag & FLIP_STATE )
        {
          if ( tree [obj].ob_state & state )
            {
              DelState ( tree, obj, state );
            }
          else
            {
              SetState ( tree, obj, state );
            }
          incl ( flag, UPD_STATE );
        }
      if ( flag & TAKE_STATE )
        {
          if ( tree [obj].ob_state == state ) return;
          tree [obj].ob_state = state;
          incl ( flag, UPD_STATE );
        }
      if ( flag & SET_STATE )
        {
          if ( tree [obj].ob_state & state ) return;
          incl ( tree [obj].ob_state, state );
          incl ( flag, UPD_STATE );
        }
      if ( flag & DEL_STATE )
        {
          if ( ! ( tree [obj].ob_state & state )) return;
          excl ( tree [obj].ob_state, state );
          incl ( flag, UPD_STATE );
        }
    }

  win = DialogInWindow ( tree );
  if ( win == NULL ) return;

  if ( flag & UPD_STATE )
    {
      if (( win->icon == 0 ) && ( win->flags & WIN_DRAWN ))
        {
        }
      else
        {
          return;
        }

      CalcArea ( tree, obj, &r );
      if (( tree [obj].ob_flags & HIDETREE ) || ( tree [obj].ob_state & DISABLED ))
        {
          obj   = 0;
          depth = 8;
        }
      if ( topped () != win )
        {
          DoRedraw ( win, &r );
        }
      else
        {
          if ( flag & USER_STATE )
            {
              DoRedraw ( win, &r );
            }
          else
            {
              NormalFont ();
              hide_cursor   ( win->dial );
              RectIntersect ( &sysgem.desk, &r );
              if (( r.w > 0 ) && ( r.h > 0 ))
                {
                  BeginControl ( CTL_UPDATE );
                  SetClipping( &r );
                  objc_draw  ( tree, obj, depth, r.x, r.y, r.w, r.h );
                  SetClipping ( NULL );
                  EndControl ( CTL_UPDATE );
                }
            }
        }
    }
}

/* ------------------------------------------------------------------- */

VOID DisableObj ( OBJECT *tree, INT obj, BOOL draw )

{
  if ( tree [obj].ob_state & DISABLED ) return;
  incl ( tree [obj].ob_state, DISABLED );
  if ( draw ) RedrawObj ( tree, obj, 0, NONE, UPD_STATE | USER_STATE );
}

/* ------------------------------------------------------------------- */

VOID EnableObj ( OBJECT *tree, INT obj, BOOL draw )

{
  if (( tree [obj].ob_state & DISABLED ) == 0 ) return;
  excl ( tree [obj].ob_state, DISABLED );
  if ( draw ) RedrawObj ( tree, obj, 0, NONE, UPD_STATE | USER_STATE );
}

/* ------------------------------------------------------------------- */

VOID HideObj ( OBJECT *tree, INT obj, BOOL draw )

{
  if ( tree [obj].ob_flags & HIDETREE ) return;
  incl ( tree [obj].ob_flags, HIDETREE );
  if ( draw ) RedrawObj ( tree, obj, 0, NONE, UPD_STATE | USER_STATE );
}

/* ------------------------------------------------------------------- */

VOID ShowObj ( OBJECT *tree, INT obj, BOOL draw )

{
  if (( tree [obj].ob_flags & HIDETREE ) == 0 ) return;
  excl ( tree [obj].ob_flags, HIDETREE );
  if ( draw ) RedrawObj ( tree, obj, 0, NONE, UPD_STATE | USER_STATE );
}

/* ------------------------------------------------------------------- */

VOID RedrawWindow ( INT handle )

{
  WINDOW        *win;
  RECT          r;

	if ( handle!=-1 )																		/* [GS]	*/
		{																									/* [GS]	*/
		  win = find_window ( handle, 0L );
		  if ( win != NULL )
		    {
		      wind_get ( win->handle, WF_WORKXYWH, &r.x, &r.y, &r.w, &r.h );
		      DoRedraw ( win, &r );
		    }
		}																									/* [GS]	*/
	else																								/* [GS]	*/
		{																									/* [GS]	*/
			win = sysgem.window;														/* [GS]	*/
      while ( win != NULL )														/* [GS]	*/
        {																							/* [GS]	*/
          RedrawWindow ( win->handle );								/* [GS]	*/
          win = win->next;														/* [GS]	*/
        }																							/* [GS]	*/
		}
}

/* ------------------------------------------------------------------- */
/* Komplette Funktion [GS]																						 */

VOID RedrawWindowById ( LONG id )

{
  WINDOW        *win;
	
  win = find_window ( -1, id );
  if ( win != NULL )
    {
      RedrawWindow ( win->handle );
    }
}

/* ------------------------------------------------------------------- */

VOID RedrawArea ( INT handle, RECT *r )

{
  WINDOW        *win;

  win = find_window ( handle, 0L );
  if ( win != NULL ) DoRedraw ( win, r );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

BOOL RemoveOwnRedraw ( OBJECT *tree, INT obj )

{
  DIALOG_SYS    *dial;
  XREDRAW       *redraw;

  dial = find_dialog ( tree );
  if ( dial != NULL )
    {
      redraw = dial->redraw;
      while ( redraw != NULL )
        {
          if ( redraw->obj == obj )
            {
              DeletePtr ( &dial->redraw, redraw );
              return ( TRUE );
            }
          redraw = redraw->next;
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL LinkOwnRedraw ( OBJECT *tree, INT obj )

{
  DIALOG_SYS    *dial;
  XREDRAW       *redraw;

  dial = find_dialog ( tree );
  if ( dial != NULL )
    {
      redraw = dial->redraw;
      while ( redraw != NULL )
        {
          if ( redraw->obj == obj ) return ( FALSE );
          redraw = redraw->next;
        }
      redraw = (XREDRAW *) Allocate ( sizeof ( XREDRAW ));
      if ( redraw != NULL )
        {
          redraw->obj   = obj;
          InsertPtr ( &dial->redraw, redraw );
          return ( TRUE );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

VOID SendRedraw ( INT handle, RECT *r )

{
  INT   msg [8];

  msg [0] = WM_REDRAW;
  msg [1] = sysgem.appl_id;
  msg [2] = 0;
  msg [3] = handle;
  msg [4] = r->x;
  msg [5] = r->y;
  msg [6] = r->w;
  msg [7] = r->h;
  appl_write ( sysgem.appl_id, 16, msg );
  evnt_timer ( 5, 0 );
}

/* -------------------------------------------------------------------
 * Alertbox
 * ------------------------------------------------------------------- */

LOCAL VOID SetObj ( INT obj, UINT typ, INT x, INT y, INT w, INT h, UINT f, INT s, VOID *spec )

{
  alert_tree [obj].ob_next              = -1;
  alert_tree [obj].ob_head              = -1;
  alert_tree [obj].ob_tail              = -1;
  alert_tree [obj].ob_type              = typ;
  alert_tree [obj].ob_flags             = f;
  alert_tree [obj].ob_state             = s;
  alert_tree [obj].ob_spec.free_string  = (BYTE *) spec;
  alert_tree [obj].ob_x                 = x;
  alert_tree [obj].ob_y                 = y;
  alert_tree [obj].ob_width             = w;
  alert_tree [obj].ob_height            = h;
  objc_add  ( alert_tree, 0, obj );
}

/* ------------------------------------------------------------------- */

LOCAL VOID PrepareAlert ( VOID )

{
  REG INT i;

  for ( i = 0; i < 30; i++ )
    {
      alert_tree [i].ob_next       = -1;
      alert_tree [i].ob_head       = -1;
      alert_tree [i].ob_tail       = -1;
      alert_tree [i].ob_type       = 0;
      alert_tree [i].ob_flags      = 0;
      alert_tree [i].ob_state      = 0;
      alert_tree [i].ob_spec.index = 0L;
      alert_tree [i].ob_x          = -1;
      alert_tree [i].ob_y          = -1;
      alert_tree [i].ob_width      = -1;
      alert_tree [i].ob_height     = -1;
    }
  alert_tree [0].ob_next       = -1;
  alert_tree [0].ob_head       = -1;
  alert_tree [0].ob_tail       = -1;
  alert_tree [0].ob_type       = G_BOX;
  alert_tree [0].ob_flags      = 0;
  alert_tree [0].ob_state      = OUTLINED;
  alert_tree [0].ob_spec.index = 0x21100L;
  alert_tree [0].ob_x          = 0;
  alert_tree [0].ob_y          = 0;
  alert_tree [0].ob_width      = 0;
  alert_tree [0].ob_height     = 0;
}

/* ------------------------------------------------------------------- */

INT self_alert ( INT def, BYTE *str )

{
  BYTE          *p, *q;
  BYTE          txt [200];

  assign ( str, txt );
  p = strstr ( &txt [4], "][" );
  if ( p )
    {
      p += 2L;
      q = strchr ( p, '[' );
      while ( q )
        {
          memcpy ( q, q + 1L, strlen ( q ));
          q = strchr ( p, '[' );
        }
    }
  return ( form_alert ( def, txt ));
}

/* ------------------------------------------------------------------- */

INT Alert ( INT priority, INT def, BYTE *str )

{
  BITBLK        *iblk;
  DIALOG_SYS    *dial;
  INT           doform;
  INT           i, j, t, bw;
  INT           icon_offs;
  INT           ypos;
  INT           obj;
  INT           state;
  INT           len;
  INT           flags;
  INT           text_w;
  INT           height;
  INT           butt;
  INT           z;
  BYTE          txt [200];

  doform = 0;
  PrepareAlert ();
  memset ( alert_text, 0, sizeof ( alert_text ));
  memset ( &button,    0, sizeof ( button     ));
  if ( length ( str ) == 0L ) return ( -1 );
  len = length ( str );
  if ( str [0] != '[' ) return ( -1 );
  icon_offs = 2 * sysgem.charw;
  ypos = sysgem.charh;
  i = 0;

  if ( str [1] == '2' ) i = 2;
  if ( str [1] == '3' ) i = 3;
  switch ( i )
    {
      case 2  : iblk = &rs_bitblk [1];
                iblk->bi_color = sysgem.icon_frag;
                break;
      case 3  : iblk = &rs_bitblk [2];
                iblk->bi_color = sysgem.icon_stop;
                break;
      default : iblk = &rs_bitblk [0];
                iblk->bi_color = sysgem.icon_ausr;
                break;
    }
  icon_offs = icon_offs + ( iblk->bi_wb * 8 );
  ypos      = ypos + iblk->bi_hl + ( sysgem.charh * 2 );
  SetObj ( 1, G_IMAGE, sysgem.charw, sysgem.charh, ( iblk->bi_wb * 8 ), iblk->bi_hl, 0, 0, iblk );
  obj = 2;
  i = 3;
  j = 0;
  t = -1;
  text_w = 0;
  forever
    {
      j = 0;
      t = t + 1;
      i = i + 1;
      if ( i > len ) return ( -1 );
      flags = G_STRING;
      state = 0;
      while (( str [i] != '|' ) && ( str [i] != ']' ) && ( j < 65 ))
        {
          if ( i > len ) return ( -1 );
          alert_text [t][j] = str [i];
          j++;
          i++;
        }
      SetObj ( obj, flags, icon_offs, (( t + 1 ) * sysgem.charh ), ( j * sysgem.charw ), sysgem.charh, 0, state, alert_text [t] );
      if ( text_w < ( j * sysgem.charw ) + icon_offs )	text_w = ( j * sysgem.charw ) + icon_offs; /* [GS] icon_offs in if-Abfrage dazu addiert*/
      obj++;
      if ( t > 14 ) break;
      if ( str [i] == ']' ) break;
    }
  if ((( t + 1 ) * sysgem.charh ) > icon_offs )
    {
      height = ( t + 3 ) * sysgem.charh;
    }
  else
    {
      height = ypos;
    }
  butt = 0;
  while ( str [i] != '[' )
    {
      if ( i > len ) return ( -1 );
      i++;
    }
  forever
    {
      i++;
      j = 0;
      if ( i > len ) return ( -1 );
      while (( str [i] != '|' ) && ( str [i] != ']' ) && ( j < 19 ))
        {
          if ( i > len ) return ( -1 );
          button [butt].text [j] = str [i];
          i++;
          j++;
        }
      if (( butt + 1 ) == def ) state = ( DEFAULT | SELECTABLE | EXIT );
                           else state = ( SELECTABLE | EXIT );
      button [butt].obj = obj;
      z = sysgem.charh;
      if ( sysgem.bergner ) z += ( sysgem.charh / 2 );
      SetObj ( obj, 0x121A, 0, height, ( sysgem.charw * j ), z, state, 0, button [butt].text );
      if ( butt > 0 )
        {
          if ( alert_tree [obj].ob_width < alert_tree [obj - 1].ob_width )
            {
              alert_tree [obj].ob_width = alert_tree [obj - 1].ob_width;
            }
          else
            {
              if ( alert_tree [obj].ob_width > alert_tree [obj - 1].ob_width )
                   alert_tree [obj - 1].ob_width = alert_tree [obj].ob_width;
            }
        }
      butt++;
      obj++;
      if ( str [i] == ']' ) break;
      if ( butt > 5 ) break;
    }
  alert_tree [obj - 1].ob_flags = ( alert_tree [obj - 1].ob_flags | LASTOB );
  bw = 0;
  for ( i = 0; i < butt; i++ )
    {
      bw = bw + alert_tree [button [i].obj].ob_width;
      if ( i > 0 ) bw = bw + ( sysgem.charw * 2 );
    }
  if ( text_w > bw ) t = text_w + sysgem.charw;
                else t = bw;
  t = t + ( sysgem.charw * 1 );
  t = t + ( sysgem.charw * 2 );
  alert_tree [0].ob_width = t;
  z = sysgem.charh + ( sysgem.charh / 2 );
  if ( sysgem.bergner ) z += ( sysgem.charh / 2 );
  alert_tree [0].ob_height = alert_tree [button [butt - 1].obj].ob_y + z;
  switch ( sysgem.button_just )
    {
      case ButtonLeft   : t = ( sysgem.charw * 2 );
                          break;
      case ButtonCenter : t = ( alert_tree [0].ob_width - bw ) / 2;
                          break;
      default           : t = ( alert_tree [0].ob_width - bw ) - ( 2 * sysgem.charw );
    }
  for ( i = 0; i < butt; i++ )
    {
      alert_tree [button [i].obj].ob_x = t;
      t = t + alert_tree [button [i].obj].ob_width;
      t = t + ( 2 * sysgem.charw );
    }

  if ( priority )
    {
      BeginControl ( CTL_UPDATE | CTL_MOUSE );
    }
  if ( length ( sysgem.win_name ) == 0 )
    {
      assign ( "|Hinweis:", txt );
    }
  else
    {
      assign ( sysgem.win_name, txt );
    }

  if ( NewDialog ( &alert_tree [0] ))
    {
      t = -1;
      if ( BeginDialog ( 'xAlT', &alert_tree [0], 0, txt ))
        {
          t = HandleDialog ( 'xAlT' );
          FinishDialog ( 'xAlT' );
        }
      else
        {
          doform = self_alert ( def, str );
        }
      dial = find_dialog ( &alert_tree [0] );
      if ( dial != NULL )
        {
          while ( dial->user != NULL ) DeletePtr ( &dial->user, dial->user );
          DeletePtr ( &sysgem.dialog, dial );
        }
    }
  else
    {
      doform = self_alert ( def, str );
    }

  if ( priority )
    {
      EndControl ( CTL_UPDATE | CTL_MOUSE );
    }

  if ( doform ) return ( doform );

  if ( t < 0 ) t = -t;
  for ( i = 0; i < butt; i++ )
    {
      if ( button [i].obj == t ) return (( i + 1 ));
    }
  return ( -1 );
}

/* -------------------------------------------------------------------
 * MenÅzeile
 * ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

BOOL outside ( OBJECT *tree, INT box )

{
  INT   x;
  INT   y;
  INT   dx;
  INT   dy;

  x = xevent.x;
  y = xevent.y;

  objc_offset ( tree, box, &dx, &dy );
  if (( x < dx - 1 ) || ( y < dy - 1 ) || ( x > dx + tree [box].ob_width + 1 ) || ( y > dy + tree [box].ob_height + 1 ))
    {
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL inside ( OBJECT *tree, INT box )

{
  return ( ! outside ( tree, box ));
}

/* ------------------------------------------------------------------- */

INT get_obj ( OBJECT *tree, INT *ob, INT box )

{
  INT           x;
  INT           y;
  INT           obj;

  turn_back     = 1;
  x             = xevent.tim_lo;
  y             = xevent.tim_hi;
  xevent.tim_lo = 5;
  xevent.tim_hi = 0;

  HandleEvents ();

  xevent.tim_lo = x;
  xevent.tim_hi = y;

  if ( turn_back == MU_BUTTON )
    {
      turn_back = 0;
      return ( -2 );
    }
  turn_back = 0;

  obj = objc_find ( tree, box, 8, xevent.x, xevent.y );
  obj = ( obj <= 1 ) ? -1 : obj;
  *ob = obj;
  if ( obj != -1 )
    {
      if ( tree [obj].ob_state & DISABLED ) return ( -3 );
    }
  return ( obj );
}

/* ------------------------------------------------------------------- */

INT handle_entry ( OBJECT *tree, INT box )

{
  INT   obj;
  INT   old;
  INT   res;

  old = -1;
  forever
    {
      res = get_obj ( tree, &obj, box );

      if ( res > 0 )
        {
          if ( obj != old )
            {
              if ( old != -1 ) objc_change ( tree, old, 0, 0, 0, sysgem.xmax, sysgem.ymax, ( tree [old].ob_state & ~SELECTED ), 1 );
              objc_change ( tree, obj, 0, 0, 0, sysgem.xmax, sysgem.ymax, ( tree [obj].ob_state | SELECTED ), 1 );
              old = obj;
            }
        }
      if ( outside ( tree, box )) break;
      if ( res == -2 )
        {
          while ( get_obj ( tree, &obj, box ) == -2 );
          if ( old != -1 ) objc_change ( tree, old, 0, 0, 0, sysgem.xmax, sysgem.ymax, ( tree [old].ob_state & ~SELECTED ), 1 );
          return ( old );
        }
      if ( res == -3 )
        {
          if ( old != -1 ) objc_change ( tree, old, 0, 0, 0, sysgem.xmax, sysgem.ymax, ( tree [old].ob_state & ~SELECTED ), 1 );
          old = -1;
        }
    }
  if ( old != -1 ) objc_change ( tree, old, 0, 0, 0, sysgem.xmax, sysgem.ymax, ( tree [old].ob_state & ~SELECTED ), 1 );
  return ( -1 );
}

/* ------------------------------------------------------------------- */

BOOL handle_menu ( WINDOW *win, OBJECT *tree )

{
  INT   obj;
  INT   old;
  INT   box;
  INT   fin;
  AREA  area;
  INT   dx;
  INT   dy;
  RECT  r;

  if ( tree == NULL ) return ( FALSE );
  if ( objc_find ( tree, 1, 8, xevent.x, xevent.y ) <= 1 ) return ( FALSE );
  if ( get_obj ( tree, &obj, 1 ) <= 1 ) return ( FALSE );
  sysgem.cursor_off = TRUE;
  NewArea ( &area );
  BeginControl ( CTL_UPDATE | CTL_MOUSE );
  box =  0;
  dx  =  0;
  dy  =  0;
  old = -1;
  fin = -1;
  forever
    {
      if ( get_obj ( tree, &obj, 1 ) > 0 )
        {
          if (( old != -1 ) && ( box > 0 ))
            {
              if ( inside ( tree, box ))
                {
                  fin = handle_entry ( tree, box );
                  if ( fin != -1 ) goto end_loop;
                }
            }
          if ( obj != old )
            {
              if ( old != -1 )
                {
                  tree [box].ob_x = dx;
                  tree [box].ob_y = dy;
                  RestoreArea ( sysgem.vdi_handle, &area );
                  box = 0;
                  RedrawObj ( tree, old, 0, SELECTED, DEL_STATE | UPD_STATE );
                }
              RedrawObj ( tree, obj, 0, SELECTED, SET_STATE | UPD_STATE );
              old = obj;

              box = tree [0].ob_tail;
              box = tree [box].ob_head;
              for ( fin = 3; fin < obj; fin++ ) box = tree [box].ob_next;
              dx  = tree [box].ob_x;
              dy  = tree [box].ob_y;

              CalcArea ( tree, box, &r );
              if (( r.x + r.w ) >= sysgem.xmax ) r.x = sysgem.xmax - r.w - 3;
              if (( r.y + r.h ) >= sysgem.ymax ) r.y = sysgem.ymax - r.h - 3;
              if (  r.x < sysgem.desk.x ) r.x = sysgem.desk.x;
              if (  r.y < sysgem.desk.y ) r.y = sysgem.desk.y;
              tree [box].ob_x = r.x - tree [0].ob_x;
              tree [box].ob_y = r.y - tree [0].ob_y - tree [1].ob_height - 1;

              CalcArea ( tree, box, &r );
              r.x -= 1;
              r.y -= 1;
              r.w += 2;
              r.h += 2;
              SaveArea ( sysgem.vdi_handle, &area, &r );
              objc_draw ( tree, box, 8, 0, 0, sysgem.xmax, sysgem.xmax );
              fin = -1;
            }
        }
      else
        {
          if ( old != -1 )
            {
              if ( inside ( tree, box ))
                {
                  fin = handle_entry ( tree, box );
                  if ( fin != -1 ) goto end_loop;
                }
            }
        }
      if ( outside ( tree, 1 )) goto end_loop;
    }
  end_loop:

  if ( old != -1 )
    {
      tree [box].ob_x = dx;
      tree [box].ob_y = dy;
      RestoreArea ( sysgem.vdi_handle, &area );
      RedrawObj ( tree, old, 0, SELECTED, DEL_STATE | UPD_STATE );
    }

  turn_back = 0;
  while ( MouseClicked ( &dx, &dy ));
  EndControl ( CTL_UPDATE | CTL_MOUSE );
  FreeArea ( &area );
  sysgem.cursor_off = FALSE;
  if ( fin != -1 )
    {
      SendMessage ( SG_MENU, win, NULL, NULL, fin, 0, 0, 0 );
    }
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

VOID MenuDivider ( BOOL enable )

{
  sysgem.divider = 1;
  if ( enable ) sysgem.divider = 0;
}

/* ------------------------------------------------------------------- */

VOID InitMenuLine ( OBJECT *menu_line )

{
  INT           i;
  DIALOG_SYS    *dial;
  BYTE          text    [200];

  dial = find_dialog ( menu_line );
  if ( dial != NULL ) return;

  dial = (DIALOG_SYS *) Allocate ( sizeof ( DIALOG_SYS ));
  if ( dial == NULL ) return;

  dial->next    = NULL;
  dial->tree    = menu_line;
  dial->user    = NULL;
  dial->edit    = 0;
  dial->edch    = 0;
  dial->cursor  = FALSE;

  InsertPtr ( &sysgem.dialog, dial );

  menu_user.ub_code     = draw_mline;
  menu_user.ub_parm     = 0L;
  i = 0;
  forever
    {
      excl ( menu_line [i].ob_flags, 0x0200 );
      excl ( menu_line [i].ob_flags, 0x0400 );
      if (( menu_line [i].ob_state & DISABLED ) && ( menu_line [i].ob_type != G_USERDEF ))
        {
          if ( menu_line [i].ob_type == G_STRING )
            {
              assign ( menu_line [i].ob_spec.free_string, text );
              if (( text [0] == '-' ) && ( text [1] == '-' ) && ( text [2] == '-' ))
                {
                  if ( sysgem.divider )
                    {
                      menu_line [i].ob_type       = G_USERDEF;
                      menu_line [i].ob_spec.index = (LONG)( &menu_user );
                    }
                }
            }
        }
      if ( menu_line [i].ob_flags & LASTOB ) break;
      i++;
    }
}

/* ------------------------------------------------------------------- */

VOID SetDeskTopMenu ( OBJECT *menu, MPROC proc )

{
  if ( sysgem.menu_tree == NULL )
    {
      if ( menu != NULL )
        {
          InitMenuLine ( menu );
          sysgem.menu_tree = menu;
          sysgem.menu_proc = proc;
          menu_bar ( sysgem.menu_tree, 1 );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID RemDeskTopMenu ( VOID )

{
  if ( sysgem.menu_tree != NULL )
    {
      menu_bar ( sysgem.menu_tree, 0 );
      sysgem.menu_tree = NULL;
      sysgem.menu_proc = (MPROC) NULL;
    }
}

/* ------------------------------------------------------------------- */

VOID InitWindowMenu ( OBJECT *menu_line )

{
  INT           i;
  DIALOG_SYS    *dial;

  dial = find_dialog ( menu_line );
  if ( dial != NULL ) return;

  dial = (DIALOG_SYS *) Allocate ( sizeof ( DIALOG_SYS ));
  if ( dial == NULL ) return;

  dial->next    = NULL;
  dial->tree    = menu_line;
  dial->user    = NULL;
  dial->edit    = 0;
  dial->edch    = 0;
  dial->cursor  = FALSE;

  InsertPtr ( &sysgem.dialog, dial );

  i = 0;
  forever
    {
      excl ( menu_line [i].ob_flags, 0x0200 );
      excl ( menu_line [i].ob_flags, 0x0400 );
      if ( menu_line [i].ob_type != G_USERDEF )
        {
          if ( menu_line [i].ob_type == G_STRING )
            {
              NewUserblock ( dial, menu_line, i, menu_line [i].ob_spec.free_string, OBJ_MENTRY );
            }
          if ( menu_line [i].ob_type == G_TITLE )
            {
              NewUserblock ( dial, menu_line, i, menu_line [i].ob_spec.free_string, OBJ_MTITLE );
            }
          if ( menu_line [i].ob_type == G_BOX )
            {
              NewUserblock ( dial, menu_line, i, NULL, OBJ_MBOX );
            }
        }
      if ( menu_line [i].ob_flags & LASTOB ) break;
      i++;
    }
}

/* ------------------------------------------------------------------- */

#endif

/* -------------------------------------------------------------------
 * Timer
 * ------------------------------------------------------------------- */

LONG get_200hz ( VOID )

{
  return ((*(LONG *) 0x4baL ));
}

/* ------------------------------------------------------------------- */

ULONG get_clock ( VOID )

{
  return ((ULONG) Supexec ( get_200hz ));
}

/* ------------------------------------------------------------------- */

LONG CalcTimer ( INT ms_high, INT ms_low )

{
  LONG  msec;

  msec  = (LONG)( ms_high );
  msec  = (( msec << 16 ) | (LONG)( ms_low ));
  msec /= 5L;
  return ( msec );
}

/* ------------------------------------------------------------------- */

LONG GetXTimerId ( VOID )

{
  return ( xid );
}

/* ------------------------------------------------------------------- */

VOID *GetXTimerUser1 ( VOID )

{
  return ( xusr1 );
}

/* ------------------------------------------------------------------- */

VOID *GetXTimerUser2 ( VOID )

{
  return ( xusr2 );
}

/* ------------------------------------------------------------------- */

VOID SetWindowTimer ( LONG win_id, INT ms_low, INT ms_high )

{
  REG   WINDOW  *win;

  win  = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if (( ms_low <= 0 ) && ( ms_high <= 0 ))
        {
          win->timer_anz = 0L;
          win->timer     = 0L;
        }
      else
        {
          win->timer_anz = CalcTimer ( ms_high, ms_low );
          win->timer     = get_clock ();
          win->timer    += win->timer_anz;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID UseFastTimer ( LONG win_id, BOOL enable )

{
  WINDOW        *win;

  win  = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if ( enable != FALSE )
        {
          incl ( win->flags, WIN_FAST );
        }
      else
        {
          excl ( win->flags, WIN_FAST );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID DelXTimer ( LONG id )

{
  REG   XTIMER  *xtm;

  xtm = sysgem.xtimer;
  while ( xtm != NULL )
    {
      if ( xtm->id == id )
        {
          DeletePtr ( &sysgem.xtimer, xtm );
          return;
        }
      xtm = xtm->next;
    }
}

/* ------------------------------------------------------------------- */

VOID SetXTimer ( LONG id, TPROC proc, INT ms_low, INT ms_high, VOID *user1, VOID *user2 )

{
  REG   XTIMER  *xtm;

  if ( proc == NULL ) return;

  xtm  = sysgem.xtimer;
  while ( xtm != NULL )
    {
      if ( xtm->id == id )
        {
          if (( ms_high <= 0 ) && ( ms_low <= 0 ))
            {
              DelXTimer ( xtm->id );
              return;
            }
          xtm->user1     = user1;
          xtm->user2     = user2;
          xtm->proc      = proc;
          xtm->timer_anz = CalcTimer ( ms_high, ms_low );
          xtm->timer     = get_clock ();
          xtm->timer    += xtm->timer_anz;
          return;
        }
      xtm = xtm->next;
    }
  xtm = (XTIMER *) Allocate ( sizeof ( XTIMER ));
  if ( xtm == NULL ) return;

  xtm->id        = id;
  xtm->user1     = user1;
  xtm->user2     = user2;
  xtm->proc      = proc;
  xtm->timer_anz = CalcTimer ( ms_high, ms_low );
  xtm->timer     = get_clock ();
  xtm->timer    += xtm->timer_anz;

  InsertPtr ( &sysgem.xtimer, xtm );
}

/* ------------------------------------------------------------------- */

XTIMER *find_xtm ( LONG id )

{
  REG   XTIMER        *xtm;

  xtm = sysgem.xtimer;
  while ( xtm != NULL )
    {
      if ( xtm->id == id ) return ( xtm );
      xtm = xtm->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID SetTimer ( INT ms_low, INT ms_high )

{
  if (( ms_low <= 0 ) && ( ms_high <= 0 ))
    {
      sysgem.timer_anz = 0L;
      sysgem.timert    = 0L;
    }
  else
    {
      sysgem.timer_anz = CalcTimer ( ms_high, ms_low );
      sysgem.timert    = get_clock ();
      sysgem.timert   += sysgem.timer_anz;
    }
}

/* ------------------------------------------------------------------- */

VOID SetProcTimer ( TPROC proc )

{
  sysgem.timer_proc = proc;
}

/* ------------------------------------------------------------------- */

VOID HandleTimer ( VOID )

{
  REG   ULONG         tim;
  REG   WINDOW        *win;
  REG   XTIMER        *xtm;
        LONG          id;

  tim = get_clock ();
  xtm = sysgem.xtimer;
  while ( xtm != NULL )
    {
      if ( tim >= xtm->timer )
        {
          id          = xtm->id;
          xid         = xtm->id;
          xusr1       = xtm->user1;
          xusr2       = xtm->user2;
          xtm->proc ();
          xtm         = find_xtm ( id );
          if ( xtm == NULL ) break;
          xtm->timer  = get_clock ();
          xtm->timer += xtm->timer_anz;
        }
      xtm = xtm->next;
    }
  if ( sysgem.timer == FALSE ) return;

  tim = get_clock ();
  win = sysgem.window;
  while ( win != NULL )
    {
      if ( win->timer > 0L )
        {
          if ( tim >= win->timer )
            {
              if ( win->flags & WIN_FAST )
                {
                  SendMessage ( SG_FTIMER, win, NULL, NULL, 0, 0, 0, 0 );
                }
              else
                {
                  SendMessage ( SG_TIMER, win, NULL, NULL, 0, 0, 0, 0 );
                }
              if ( win->timer > 0L )
                {
                  win->timer  = get_clock ();
                  win->timer += win->timer_anz;
                }
            }
        }
      win = win->next;
    }
  if ( sysgem.timert > 0L )
    {
      if ( tim >= sysgem.timert )
        {
          if ( sysgem.timer_proc != NULL )
            {
              sysgem.timer_proc ();
              if ( sysgem.timert > 0L )
                {
                  sysgem.timert  = get_clock ();
                  sysgem.timert += sysgem.timer_anz;
                }
            }
        }
    }
}

/* ------------------------------------------------------------------- */

VOID SetDispatchTime ( INT ms_low, INT ms_high )

{
  xevent.tim_lo = ms_low;
  xevent.tim_hi = ms_high;
}

/* ------------------------------------------------------------------- */

VOID EnableTimer ( VOID )

{
  sysgem.timer = TRUE;
}

/* ------------------------------------------------------------------- */

VOID DisableTimer ( VOID )

{
  sysgem.timer = FALSE;
}

/* -------------------------------------------------------------------
 * Bildschirm-Routinen
 * ------------------------------------------------------------------- */

VOID MoveScreen ( INT handle, RECT *r, INT x, INT y )

{
  MFDB  s;
  MFDB  d;
  INT   pxy [8];

  memset ( &s, 0, sizeof ( s ));
  memset ( &d, 0, sizeof ( d ));

  pxy [0] = r->x;
  pxy [1] = r->y;
  pxy [2] = r->x + r->w;
  pxy [3] = r->y + r->h;
  pxy [4] = x;
  pxy [5] = y;
  pxy [6] = x + r->w;
  pxy [7] = y + r->h;
  BeginControl ( CTL_UPDATE | CTL_MHIDE );
  vro_cpyfm ( handle, 3, pxy, &s, &d );
  EndControl ( CTL_UPDATE | CTL_MHIDE );
}

/* ------------------------------------------------------------------- */

BOOL NewArea ( AREA *p )

{
  p->x          = -1;
  p->y          = -1;
  p->w          = -1;
  p->h          = -1;
  p->init       = FALSE;
  p->size       = 0L;
  p->mf.fd_addr = NULL;
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

VOID FreeArea ( AREA *p )

{
  if ( p != NULL )
    {
      if ( p->mf.fd_addr != NULL ) Dispose ( p->mf.fd_addr );
      NewArea ( p );
    }
}

/* ------------------------------------------------------------------- */

VOID ClearArea ( AREA *p )

{
  if ( p != NULL )
    {
      if ( p->init )
        {
          if ( p->mf.fd_addr != NULL ) Dispose ( p->mf.fd_addr );
          NewArea ( p );
        }
    }
}

/* ------------------------------------------------------------------- */

VOID CopyArea ( INT handle, AREA *p, INT x, INT y )

{
  INT   pxy [8];

  if ( p != NULL )
    {
      if ( p->init == TRUE )
        {
          pxy [0] = 0;
          pxy [1] = 0;
          pxy [2] = p->w - 1;
          pxy [3] = p->h - 1;
          pxy [4] = x;
          pxy [5] = y;
          pxy [6] = x + pxy [2];
          pxy [7] = y + pxy [3];
          BeginControl ( CTL_UPDATE | CTL_MHIDE );
          vro_cpyfm ( handle, S_ONLY, pxy, &p->mf, &dst );
          EndControl ( CTL_UPDATE | CTL_MHIDE );
        }
    }
}

/* ------------------------------------------------------------------- */

BOOL SaveArea ( INT handle, AREA *p, RECT *r )

{
  INT           b, c, d, e;
  INT           pxy [8];

  if ( p != NULL )
    {
      b = r->x;
      c = r->y;
      d = r->w;
      e = r->h;
      if (( p->init ) && (( d > p->w ) || ( e > p->h )))
        {
          if ( p->mf.fd_addr != NULL )
            {
              Dispose ( p->mf.fd_addr );
              p->mf.fd_addr = NULL;
            }
          p->init = FALSE;
        }
      if ( p->init == FALSE )
        {
          p->mf.fd_wdwidth = ( d + 15 ) / 16;
          p->mf.fd_w       = p->mf.fd_wdwidth * 16;
          p->mf.fd_h       = e + 1;
          p->mf.fd_stand   = 0;
          p->mf.fd_nplanes = sysgem.bitplanes;
          p->size          = ((LONG)( p->mf.fd_wdwidth )) * ((LONG)( p->mf.fd_h )) * ((LONG)( sysgem.bitplanes )) * 2L;
          p->mf.fd_addr    = (BYTE *) Allocate ( p->size );
          if ( p->mf.fd_addr == NULL ) return ( FALSE );
          p->init = TRUE;
        }
      p->x = b;
      p->y = c;
      p->w = d;
      p->h = e;
      pxy [0] = p->x;
      pxy [1] = p->y;
      pxy [2] = p->x + p->w - 1;
      pxy [3] = p->y + p->h - 1;
      pxy [4] = 0;
      pxy [5] = 0;
      pxy [6] = p->w - 1;
      pxy [7] = p->h - 1;
      BeginControl ( CTL_UPDATE | CTL_MHIDE );
      vro_cpyfm ( handle, S_ONLY, pxy, &dst, &p->mf );
      EndControl ( CTL_UPDATE | CTL_MHIDE );
    }
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

VOID RestoreArea ( INT handle, AREA *p )

{
  INT   pxy [8];

  if ( p != NULL )
    {
      if ( p->init == TRUE )
        {
          pxy [0] = 0;
          pxy [1] = 0;
          pxy [2] = p->w - 1;
          pxy [3] = p->h - 1;
          pxy [4] = p->x;
          pxy [5] = p->y;
          pxy [6] = p->x + pxy [2];
          pxy [7] = p->y + pxy [3];
          BeginControl ( CTL_UPDATE | CTL_MHIDE );
          vro_cpyfm ( handle, S_ONLY, pxy, &p->mf, &dst );
          EndControl ( CTL_UPDATE | CTL_MHIDE );
        }
    }
}

/* -------------------------------------------------------------------
 * Nachrichtenverwaltung
 * ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

VOID DelCompleteList ( LONG win_id )

{
  REG   WTEXT   *wtxt;
  REG   WTEXT   *wdel;
        WINDOW  *win;
        INT     i;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return;

  wtxt = win->first;
  while ( wtxt != NULL )
    {
      wdel = wtxt;
      wtxt = wtxt->next;
      Dispose ( wdel->text );
      Dispose ( wdel );
    }
  win->first  = NULL;
  win->last   = NULL;
  win->lines  = 0;

  for ( i = 0; i < MAX_TAB + 1; i++ )
    {
      win->tab [i].pos  = -1;
      win->tab [i].just = TAB_LEFT;
    }
}

/* ------------------------------------------------------------------- */

WTEXT *find_line ( WINDOW *win, UINT line )

{
  REG   UINT    i;
  REG   WTEXT   *wtxt;

  i    = 0U;
  wtxt = win->first;
  while ( wtxt != NULL )
    {
      if ( i == line ) return ( wtxt );
      wtxt = wtxt->next;
      i++;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */
/* [GS] komplett neu 																									 */
/* Setzen der ersten Zeile eines Textfensters													 */

VOID SetFirstLine ( LONG win_id, UINT line )

{
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      if ( line < win->lines )
      	{
      			int i;
      		
      			i = win->work.h / win->scr_y;
      			if ( ( win->lines - line ) < i )
      				{
      					line = win->lines - i;
      					if ( line < 1 )
      					line = 1;
      				}
     			win->pos_y = line * win->scr_y;
     	}
    }
}

/* ------------------------------------------------------------------- */
/* [GS] komplett neu 																									 */
/* Ermittelt die Zeile unter einer 											 */

LONG GetLine ( LONG win_id, INT mx, INT my, RECT *pos )

{
  INT  i, w, h;
  LONG line, column;
  WTEXT  *wtxt;
  WINDOW *win;

	line = -1;
  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
		  if (( mx > win->work.x ) && ( mx < ( win->work.x + win->work.w )))
		    {
		      if (( my > win->work.y ) && ( my < ( win->work.y + win->work.h )))
		        {
		          SetFont ( win->font_id, win->font_pt );
		          w = StringWidth ( "W" );
		          h = StringHeight ();
		
		          if ( win->log.txt != NULL )
		            {
		              column = (LONG)(( mx - win->work.x ) / w );
		              line = (LONG)(( my - win->work.y ) / h );
		            }
		          else
		            {
		              column   = -1;
		              line     =  ( win->pos_y / (LONG)( win->scr_y ));
		              line    += (LONG)(( my - win->work.y ) / win->scr_y );
		              wtxt          = find_line ( win, (UINT)( line ));
		              if ( wtxt != NULL )
		                {
		                  i = simulate_out ( mx, wtxt->text, win->work.x - (INT)( win->pos_x ), w, &win->tab [0] );
		                  if ( i >= 0 )
		                    {
		                      i--;
		                      column = i;
		                    }
		                  pos->x = win->work.x;
		                  pos->y = win->work.y + ((( my - win->work.y ) / h ) * h );
		                  pos->w = win->work.w;
		                  pos->h = h;
/*
		                  inf->line_ptr  = wtxt->text;
		                  inf->line_user = wtxt->user;
*/
		                }
		              else
		              	;						/* Keine Zeile gefunden [GS] */
		            }
		          NormalFont ();
		        }
		    }
    }
	return line;
}

/* ------------------------------------------------------------------- */

BYTE *GetLinePtr ( LONG win_id, UINT line )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( NULL );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      return ( wtxt->text );
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID *GetListUserPtr ( LONG win_id, UINT line )

{
  WTEXT         *wtxt;
  WINDOW        *win;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return ( NULL );

  wtxt = find_line ( win, line );
  if ( wtxt != NULL )
    {
      return ( wtxt->user );
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID CalcLinePos ( WINDOW *win, WINDOW_INFO *inf )

{
  WTEXT         *wtxt;
  INT           i, w, h;

  if (( inf->mx > inf->draw_area.x ) && ( inf->mx < ( inf->draw_area.x + inf->draw_area.w )))
    {
      if (( inf->my > inf->draw_area.y ) && ( inf->my < ( inf->draw_area.y + inf->draw_area.h )))
        {
          SetFont ( win->font_id, win->font_pt );
          w = StringWidth ( "W" );
          h = StringHeight ();

          if ( win->log.txt != NULL )
            {
              inf->column = (LONG)(( inf->mx - inf->draw_area.x ) / w );
              inf->line   = (LONG)(( inf->my - inf->draw_area.y ) / h );
            }
          else
            {
              inf->column   = -1;
              inf->line     =  ( inf->pos_y / (LONG)( win->scr_y ));
              inf->line    += (LONG)(( inf->my - inf->draw_area.y ) / win->scr_y );
              wtxt          = find_line ( win, (UINT)( inf->line ));
              if ( wtxt != NULL )
                {
                  i = simulate_out ( inf->mx, wtxt->text, inf->draw_area.x - (INT)( inf->pos_x ), w, &win->tab [0] );
                  if ( i >= 0 )
                    {
                      i--;
                      inf->column = i;
                    }
                  inf->line_ptr  = wtxt->text;
                  inf->line_user = wtxt->user;
                }
              else
              	inf->line = -1;						/* Keine Zeile gefunden [GS] */
            }
          NormalFont ();
        }
    }
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

VOID clear_winfo ( WINDOW *win, WINDOW_INFO *winf )

{
  winf->id                = win->id;
  winf->handle            = win->handle;
  winf->pos_x             = win->pos_x;
  winf->pos_y             = win->pos_y;
  winf->doc_x             = win->doc_x;
  winf->doc_y             = win->doc_y;
  winf->user              = win->user;
  winf->user2             = win->user2;
  winf->key               = -1;
  winf->state             = xevent.kstate;
  winf->mTitle            = -1;
  winf->mItem             = -1;
  winf->mx                = -1;
  winf->my                = -1;
  winf->line              = -1L;
  winf->column            = -1L;
  winf->line_ptr          = NULL;
  winf->line_user         = NULL;
  winf->draw_area.x       = win->work.x;
  winf->draw_area.y       = win->work.y;
  winf->draw_area.w       = win->work.w;
  winf->draw_area.h       = win->work.h;
  winf->work_area.x       = -1;
  winf->work_area.y       = -1;
  winf->work_area.w       = -1;
  winf->work_area.h       = -1;
  winf->clip.x            = sg_clip_r.x;
  winf->clip.y            = sg_clip_r.y;
  winf->clip.w            = sg_clip_r.w;
  winf->clip.h            = sg_clip_r.h;
  winf->tree              = NULL;
  winf->item              = -1;
  winf->obj_id            = 0L;
  winf->dd                = NULL;
  winf->denied            = 0L;
}

/* ------------------------------------------------------------------- */

VOID clear_redraw ( WINDOW *win, WINDOW_INFO *winf )

{
  winf->id                = win->id;
  winf->handle            = win->handle;
  winf->pos_x             = win->pos_x;
  winf->pos_y             = win->pos_y;
  winf->doc_x             = win->doc_x;
  winf->doc_y             = win->doc_y;
  winf->user              = win->user;
  winf->user2             = win->user2;
  winf->draw_area.x       = win->work.x;
  winf->draw_area.y       = win->work.y;
  winf->draw_area.w       = win->work.w;
  winf->draw_area.h       = win->work.h;
  winf->clip.x            = sg_clip_r.x;
  winf->clip.y            = sg_clip_r.y;
  winf->clip.w            = sg_clip_r.w;
  winf->clip.h            = sg_clip_r.h;
  wind_get ( win->handle, WF_WORKXYWH, &winf->work_area.x, &winf->work_area.y, &winf->work_area.w, &winf->work_area.h );
}

/* ------------------------------------------------------------------- */

VOID clear_dinfo ( WINDOW *win, DIALOG_INFO *dinf )

{
  dinf->id         = win->id;
  dinf->user       = win->user;
  dinf->user2      = win->user2;
  dinf->dd         = NULL;
  dinf->denied     = 0L;
  dinf->kstate     = xevent.kstate;
  dinf->box        = 0;
  dinf->tree       = win->dial->tree;
  dinf->edit_field = win->dial->edit;
  dinf->clip.x     = sg_clip_r.x;
  dinf->clip.y     = sg_clip_r.y;
  dinf->clip.w     = sg_clip_r.w;
  dinf->clip.h     = sg_clip_r.h;
}

/* ------------------------------------------------------------------- */

INT GetHighRes ( VOID )

{
  return ( high_result );
}

/* ------------------------------------------------------------------- */

INT SendMessage ( INT msg, WINDOW *win, WTREE *wt, VOID *p0, INT p1, INT p2, INT p3, INT p4 )

{
  INT           res;
  INT           button;
  INT           called;
  LONG          win_id;
  DIALOG_SYS    *dial;
  BOOL          ok;
  WINDOW_INFO   winf;
  DIALOG_INFO   dinf;

  if ( win == NULL ) return ( SG_CONT );

  res           = SG_CONT;
  button        = -1;
  called        = 0;
  high_result   = 0;

  if ( msg == SG_REDRAW )
    {
      if ( win->redraw != NULL )
        {
          clear_winfo  ( win, &winf );
          clear_redraw ( win, &winf );
          winf.clip.x = p1;
          winf.clip.y = p2;
          winf.clip.w = p3;
          winf.clip.h = p4;
          win->redraw  ( &winf );
          return ( SG_CONT );
        }
    }

  if ( win->dial != NULL )
    {
      clear_dinfo ( win, &dinf );
    }
  else
    {
      clear_winfo ( win, &winf );
    }

  if ( win->dial != NULL )
    {																					/* Es ist ein Fensterdialog		*/
      switch ( msg )
        {
          case SG_OPENICONIFIED :
          case SG_TOP           :
          case SG_UNTOP         :
          case SG_VISIBLE       :
          case SG_INVISIBLE     :
          case SG_POSITION      :
          case SG_START         :
          case SG_UNDO          :
          case SG_HELP          :
          case SG_QUIT          :
          case SG_TIMER         :
          case SG_FTIMER        :
          case SG_CLIPBOARD     :
          case SG_LASTEDIT      :
          case SG_EDITABLE      :
          case SG_SLDNEWPOS1    :
          case SG_SLDNEWPOS2    :
          case SG_3DSTATE       : break;
          case SG_BUTTON2       : msg = SG_END2;   goto do_the_button;
          case SG_RBUTTON       : msg = SG_REND;   goto do_the_button;
          case SG_RBUTTON2      : msg = SG_REND2;  goto do_the_button;
          case SG_END           :
          case SG_BUTTON        : msg = SG_END;
                                  do_the_button:
                                  button        = p1;								/* [GS] */
                                  break;														/* [GS] */
          case SG_BEGINHELP     :
          												dinf.tree     = wt->dial->tree;		/* [GS] */
                                  button        = p1;
          case SG_ENDHELP       : break;
          case SG_TOUCH         : dinf.kstate		= p2;								/* [GS] */
          case SG_SELECT        :
          case SG_DESELECT      :
          case SG_RADIO         :
          case SG_NEWDIAL       :
          case SG_POSX          :
          case SG_POSY          :
          case SG_LCIRCLE       :
          case SG_RCIRCLE       : button        = p1;
                                  break;
          case SG_DRAWOWN       : dinf.id       = wt->id;
                                  dinf.tree     = wt->dial->tree;
                                  button        = p1;
                                  CalcArea ( dinf.tree, button, &dinf.clip );
                                  dinf.clip.x  += 1;
                                  dinf.clip.y  += 1;
                                  dinf.clip.w  -= 2;
                                  dinf.clip.h  -= 2;
                                  break;
          case SG_EMPTYSLDLINE  :
          case SG_NEWFONT       :
          case SG_SLIDER        :
          case SG_SLIDER2       :
          case SG_RSLIDER       :
          case SG_RSLIDER2      : button        = p1;
                                  dinf.box      = p2;
                                  break;
          case SG_NEXTSTART     :
          case SG_CHILDEXIT     : dinf.denied   = *(LONG *) p0;
                                  break;
          case SG_EDCHANGED     : button 	= p2;
                                  dinf.edit_field = p1;
                                  break;
          case SG_EDKEY         :
          case SG_KEY           : button        = p1;
                                  dinf.kstate   = p2;
                                  dinf.denied   = (LONG)( p3 );
                                  break;
          case SG_DRAGDROP      : dinf.dd       = &sysgem.drag;
                                  break;
          case SG_MENU          :
          case SG_EDREDRAW      : button        = p1;
                                  break;
					case SG_SILDERMOVE		: button        = p1;								/* [GS] */
																	dinf.box      = p2;
																	break;														/* [GS] */
          default               : break;
        }
    }
  else
    {
      if ( msg != SG_QUIT )
        {
          wind_get ( win->handle, WF_WORKXYWH, &winf.work_area.x, &winf.work_area.y, &winf.work_area.w, &winf.work_area.h );
        }
      switch ( msg )
        {
          case SG_OPENICONIFIED :
          case SG_TOP           :
          case SG_UNTOP         :
          case SG_VISIBLE       :
          case SG_INVISIBLE     :
          case SG_POSITION      :
          case SG_START         :
          case SG_TIMER         :
          case SG_FTIMER        :
          case SG_CLIPBOARD     :
          case SG_3DSTATE       :
          case SG_UNDO          :
          case SG_HELP          :
          case SG_LASTEDIT      :
          case SG_EDITABLE      :
          case SG_QUIT          :
          case SG_SLDNEWPOS1    :
          case SG_SLDNEWPOS2    :
          case SG_END           : break;
#ifndef EXTOB
          case SG_LCLICK1       :
          case SG_LCLICK2       :
          case SG_RCLICK1       :
          case SG_RCLICK2       : winf.mx       = p1;
                                  winf.my       = p2;
                                  winf.state		= p3;	 /* [GS] */
                                  CalcLinePos ( win, &winf );
                                  break;
#endif
          case SG_MOVED         :
          case SG_SIZED         :
          case SG_FULLED        : winf.clip.x   = p1;
                                  winf.clip.y   = p2;
                                  winf.clip.w   = p3;
                                  winf.clip.h   = p4;
                                  break;
          case SG_TOUCH         : winf.state		= p2;								/* [GS] */
          case SG_SELECT        :
          case SG_DESELECT      :
          case SG_RADIO         :
          case SG_NEWDIAL       :
          case SG_BUTTON        :
          case SG_BUTTON2       :
          case SG_RBUTTON       :
          case SG_RBUTTON2      :
          case SG_LCIRCLE       :
          case SG_RCIRCLE       :
          case SG_BEGINHELP     : winf.item     = p1;
                                  winf.obj_id   = wt->id;
                                  winf.tree     = wt->dial->tree;
          case SG_ENDHELP       : break;
          case SG_DRAWOWN       : winf.item     = p1;
                                  winf.obj_id   = wt->id;
                                  winf.tree     = wt->dial->tree;
                                  CalcArea ( winf.tree, winf.item, &winf.clip );
                                  winf.clip.x  += 1;
                                  winf.clip.y  += 1;
                                  winf.clip.w  -= 2;
                                  winf.clip.h  -= 2;
                                  break;
          case SG_EMPTYSLDLINE  :
          case SG_SLIDER        :
          case SG_SLIDER2       :
          case SG_RSLIDER       :
          case SG_RSLIDER2      : winf.item     = p1;
                                  winf.obj_id   = wt->id;
                                  winf.tree     = wt->dial->tree;
                                  winf.denied   = (LONG)( p2 );
                                  break;
          case SG_NEXTSTART     :
          case SG_CHILDEXIT     : winf.denied   = *(LONG *) p0;
                                  break;
          case SG_EDCHANGED     :
          case SG_EDKEY         :
          case SG_KEY           : winf.key      = p1;
                                  winf.state    = p2;
                                  winf.denied   = (LONG)( p3 );
                                  break;
          case SG_DRAGDROP      : winf.dd       = &sysgem.drag;
                                  break;
          case SG_MENU          :
          case SG_EDREDRAW      : winf.mItem    = p1;
                                  break;
          case SG_NEWFONT       : winf.item     = p1;
                                  winf.state    = p2;
                                  break;
          default               : break;
        }
    }

  call_again:

  win_id = win->id;

  if ( win->dial != NULL )
    {
      if ( win->daction != NULL )
        {
          res = win->daction ( msg, button, &dinf );
          if ( msg == SG_HELP )
            {
              DelButton ();
            }
        }
      else
        {
          if ( msg == SG_END ) res = SG_CLOSE;
        }
    }
  else
    {
      if ( win->waction != NULL )
        {
          res = win->waction ( msg, &winf );
          if ( msg == SG_HELP )
            {
              DelButton ();
            }
        }
      else
        {
          if ( msg == SG_END ) res = SG_CLOSE;
        }
    }

  switch ((BYTE)( res ))
    {
      case SG_CLOSE             : if (( win = find_window ( -1, win_id )) != NULL )
                                    {
                                      DestroyWindow ( win, TRUE );
                                      return ( SG_CLOSE );
                                    }
                                  break;
      case SG_REDRAW            : if (( win = find_window ( -1, win_id )) != NULL )
                                    {
                                      RedrawWindow ( win->handle );
                                    }
                                  break;
      case SG_REDRAWALL         : win = sysgem.window;
                                  while ( win != NULL )
                                    {
                                      RedrawWindow ( win->handle );
                                      win = win->next;
                                    }
                                  break;
      case SG_TERM              : TerminateSysGem ();
                                  break;
      case SG_CONT              : break;
      case SG_ABORT             : break;
      case SG_KEYUSED           : break;
      case SG_KEYCONT           : break;
      case SG_CALL              : msg = (INT)( res >> 8 );
                                  goto call_again;
      case SG_PIPE              : if ( win->dial != NULL )
                                    {
                                      win = find_window ( -1, dinf.id );
                                    }
                                  else
                                    {
                                      win = find_window ( -1, winf.id );
                                    }
                                  if ( win == NULL ) return ( SG_CONT );
                                  goto call_again;
      case SG_SELECTED          : break;
      case SG_TAKEKEY           : break;
      case SG_TAKEDIAL          : ok = FALSE;
                                  wt = win->tree;
                                  while ( wt != NULL )
                                    {
                                      if ( wt->pos == LINK_REITER ) ok = TRUE;
                                      if ( wt->pos == LINK_DIALOG )
                                        {
                                          if ( ok )
                                            {
                                              if ( win->dial != NULL )
                                                {
                                                  dial = find_dialog ( dinf.tree );
                                                  if (( dial != NULL ) && ( dial != win->dial ))
                                                    {
                                                      win->dial = dial;
                                                      wt->dial  = dial;
                                                      return ( SG_TAKEDIAL );
                                                    }
                                                }
                                            }
                                          return ( SG_CONT );
                                        }
                                      wt = wt->next;
                                    }
                                  if (( ok != FALSE ) && ( win->dial == NULL )) return ( SG_TAKEDIAL );
                                  return ( SG_CONT );
      case SG_CALLUPD           : break;
      case SG_ICONIFY           : break;
      default                   : called++;
                                  if ( called > 1 )
                                    {
                                      if ( win->dial != NULL )
                                        {
                                          dinf.denied = (LONG)( res );
                                        }
                                      else
                                        {
                                          winf.denied = (LONG)( res );
                                        }
                                      msg = SG_EXCEPTION;
                                      goto call_again;
                                    }
                                  res = SG_CONT;
                                  break;
    }
  high_result = (INT)( res >> 8 );
  res = res << 8;
  res = res >> 8;
  return ( res );
}

/* -------------------------------------------------------------------
 * Resourcen
 * ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

VOID ShowMessage ( BYTE *text )

{
  LONG  msg_id  = 'sgm.';

  if ( find_window ( -1, msg_id ) != NULL )
    {
      SetText      ( rsc_msg, MS_TXT, text );
      RedrawWindow ( GetHandle ( msg_id ));
    }
  else
    {
      SetText ( rsc_msg, MS_TXT, text );
      if ( BeginDialog ( msg_id, rsc_msg, 0, sysgem.win_name ))
        {
          sysgem.msg_shown = TRUE;
          RedrawWindow ( GetHandle ( msg_id ));
        }
    }
}

/* ------------------------------------------------------------------- */

VOID EndMessage ( VOID )

{
  FinishDialog ( 'sgm.' );
  DispatchEvents ();
  DispatchEvents ();
  sysgem.msg_shown = FALSE;
}

/* ------------------------------------------------------------------- */

VOID ShowStatus ( BYTE *text1, BYTE *text2, LONG p, LONG p100, INT esc) 	/* [GS] */

{
  LONG  msg_id  = 'sgs.';

  if ( find_window ( -1, msg_id ) != NULL )
    {
      SetText      ( rsc_stat, ST_TXT1, text1 );
      SetText      ( rsc_stat, ST_TXT2, text2 );

      if ( text1 != NULL ) RedrawObj ( rsc_stat, ST_TXT1, 0, NONE, UPD_STATE );
      if ( text2 != NULL ) RedrawObj ( rsc_stat, ST_TXT2, 0, NONE, UPD_STATE );

      DrawSlider ( rsc_stat, ST_HIDE, p, p100, TRUE );
    }
  else
    {
      SetText    ( rsc_stat, ST_TXT1, " " );
      SetText    ( rsc_stat, ST_TXT2, " " );
      SetText    ( rsc_stat, ST_TXT1, text1 );
      SetText    ( rsc_stat, ST_TXT2, text2 );
      DrawSlider ( rsc_stat, ST_HIDE, p, p100, FALSE );
      if ( esc )																				/* [GS] */
				ShowObj  ( rsc_stat, ST_ESC, FALSE );						/* [GS] */
			else																							/* [GS] */
				HideObj  ( rsc_stat, ST_ESC, FALSE );						/* [GS] */

      if ( BeginDialog ( msg_id, rsc_stat, 0, sysgem.win_name ))
        {
          sysgem.msg_shown = TRUE;
          RedrawWindow ( GetHandle ( msg_id ));
        }
    }
}

/* ------------------------------------------------------------------- */

VOID EndStatus ( VOID )

{
  FinishDialog ( 'sgs.' );
  DispatchEvents ();
  DispatchEvents ();
  sysgem.msg_shown = FALSE;
}

/* ------------------------------------------------------------------- */

INT LoadResource ( BYTE *rsc_name, BOOL long_rsc )

{
  if ( long_rsc );

  if ( rsrc_load ( rsc_name )) return ( TRUE );
  return ( RSC_LOADERR );
}

/* ------------------------------------------------------------------- */

OBJECT *RscAdr ( INT tree_type, INT index )

{
  OBJECT        *p;

  rsrc_gaddr ( tree_type, index, &p );
  return ( p );
}

/* ------------------------------------------------------------------- */

VOID RscFree ( VOID )

{
  rsrc_free ();
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

BOOL InitResource ( OBJECT *rsc_tree, UINT num_obs, UINT num_trees, VOID *rgb_table, BOOL long_rsc )

{
  REG   UINT    num;
  REG   UINT    i;

  if ( rgb_table );
  if ( long_rsc );

  num = num_trees;
  num = num_obs;
  for ( i = 0; i < num; i++ )
    {
      rsrc_obfix ( &rsc_tree [i], 0 );
    }
  return ( TRUE );
}

/* -------------------------------------------------------------------
 * Dialogroutinen
 * ------------------------------------------------------------------- */

DIALOG_SYS *find_dialog ( OBJECT *tree )

{
  DIALOG_SYS      *dial;

  dial = sysgem.dialog;
  while ( dial != NULL )
    {
      if ( dial->tree == tree ) return ( dial );
      dial = dial->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

UBYTE alt_shortcut ( UINT key )

{
  REG   INT   i;

  i = 0;
  forever
    {
      if ( alt_key [i] == 0 ) return ( 0 );
      if ( key == alt_key [i] ) return ( chr_key [i] );
      i++;
    }
}

/* ------------------------------------------------------------------- */

UBYTE ctl_shortcut ( UINT key )

{
  REG   INT   i;

  i = 0;
  forever
    {
      if ( ctl_key [i] == 0 ) return ( 0 );
      if ( key == ctl_key [i] ) return ( chr_key [i] );
      i++;
    }
}

/* ------------------------------------------------------------------- */

VOID SelectMenu ( OBJECT *tree, INT item, BOOL invert )

{
  INT   i;
  INT   j;

  i = tree [0].ob_tail;
  i = tree [i].ob_head;
  j = 3;

  forever
    {
      if (( item >= tree [i].ob_head ) && ( item <= tree [i].ob_tail ))
        {
          if ( tree == sysgem.menu_tree )
            {
              menu_tnormal ( tree, j, (( invert == FALSE ) ? 1 : 0 ));
              return;
            }
          else
            {
              if ( invert )
                {
                  RedrawObj ( tree, j, 0, SELECTED, SET_STATE | UPD_STATE );
                }
              else
                {
                  RedrawObj ( tree, j, 0, SELECTED, DEL_STATE | UPD_STATE );
                }
            }
          return;
        }
      j++;
      if ( tree [i].ob_next < i ) return;
      i = tree [i].ob_next;
    }
}

/* ------------------------------------------------------------------- */

INT IsMenuKey ( OBJECT *tree, INT scan, INT state )

{
  REG   INT     i;
  REG   INT     v;
        INT     t;
        BYTE    alt     = 7;
        BYTE    ctrl    = 94;
        BYTE    s       [100];

  if ( tree == NULL ) return ( -1 );
  if (( state != K_ALT ) && ( state != K_CTRL )) return ( -1 );
  i = 0;
  forever
    {
      GetObjType ( tree, i, &t, NULL );
      if ( t == G_STRING )
        {
          if (( tree [i].ob_state & DISABLED ) == 0 )
            {
              strcpy ( s, GetText ( tree, i, NULL ));
              for ( v = 0; v < (INT)( strlen ( s )); v++ )
                {
                  if (( s [v] == alt ) && ( state == K_ALT ))
                    {
                      if ( alt_shortcut ( scan ) == (UBYTE)( toupper ( s [v + 1] ))) return ( i );
                    }
                  if (( s [v] == ctrl ) && ( state == K_CTRL ))
                    {
                      if ( ctl_shortcut ( scan ) == (UBYTE)( toupper ( s [v + 1] ))) return ( i );
                    }
                }
            }
        }
      if ( tree [i].ob_flags & LASTOB ) break;
      i++;
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

VOID clr_buff ( VOID )

{
  memset ( clip_buff, 0, sizeof ( clip_buff ));
}

/* ------------------------------------------------------------------- */

VOID save_buff ( VOID )

{
  LONG  fh;
  BYTE  tx [4] = { '\r', '\n', 0, 0 };

  if ( length ( clip_buff ) == 0 ) return;
  if ( sysgem.clipboard [0] == 0 ) return;

  fh = Fcreate ( sysgem.clipboard, 0 );
  if ( fh < 0L ) return;
  Fwrite ((INT)( fh ), strlen ( clip_buff ), clip_buff );
  Fwrite ((INT)( fh ), 2L, tx );
  Fclose ((INT)( fh ));
  ClipboardChanged ();
}

/* ------------------------------------------------------------------- */

VOID load_buff ( VOID )

{
  LONG  fh;
  INT   i;

  clr_buff ();

  fh = Fopen ( sysgem.clipboard, FO_READ );
  if ( fh < 0L ) return;
  i = ( Fread ((INT)( fh ), 380L, clip_buff ) > 0L );
  Fclose ((INT)( fh ));

  if ( i )
    {
      for ( i = 0; i < length ( clip_buff ); i++ )
        {
          if (( clip_buff [i] == '\n' ) || ( clip_buff [i] == '\r' ))
            {
              clip_buff [i] = '\0';
            }
        }
    }
}

/* ------------------------------------------------------------------- */

VOID del_buff ( VOID )

{
  clr_buff ();

  if ( sysgem.clipboard [0] == 0 ) return;
  unlink ( sysgem.clipboard );
  ClipboardChanged ();
}

/* ------------------------------------------------------------------- */

VOID buff_copy ( DIALOG_SYS *dial )

{
  clr_buff ();
  GetText ( dial->tree, dial->edit, clip_buff );
  save_buff ();
}

/* ------------------------------------------------------------------- */

VOID buff_insert ( DIALOG_SYS *dial )

{
  load_buff ();
  SetText ( dial->tree, dial->edit, clip_buff );
}

/* ------------------------------------------------------------------- */

VOID Cursor ( VOID )

{
  INT   x, y;
  BYTE  s [200];

  if ( ! sysgem.self_edit ) return;
  if ( sysgem.cursor_off ) return;

  if ( for_edit != NULL )
    {
      objc_offset ( for_edit->tree, for_edit->edit, &x, &y );
      y += 2;
      x += 3;
      GetText ( for_edit->tree, for_edit->edit, s );
      s [for_edit->edch] = 0;
      BeginControl ( CTL_UPDATE );
      inv_area ( BLACK, x + StringWidth ( s ), y, 2, for_edit->tree [for_edit->edit].ob_height - 4 );
      EndControl ( CTL_UPDATE );
      on_screen = ( ! on_screen );
    }
}

/* ------------------------------------------------------------------- */

VOID hide_cursor ( DIALOG_SYS *dial )

{
  if ( dial == NULL ) return;

  if ( dial->edit != 0 )
    {
      if ( dial->cursor )
        {
          if ( ! sysgem.self_edit )
            {
              objc_edit ( dial->tree, dial->edit, 0, &dial->edch, ED_END );
            }
          dial->cursor = FALSE;
          if ( on_screen ) Cursor ();
          for_edit = NULL;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID show_cursor ( DIALOG_SYS *dial )

{
  if ( dial == NULL ) return;

  if ( dial->edit != 0 )
    {
      if ( dial->cursor == FALSE )
        {
          if ( ! sysgem.self_edit )
            {
              objc_edit ( dial->tree, dial->edit, 0, &dial->edch, ED_INIT );
            }
          else
            {
              if ( ed_field != dial->edit )
                {
                  dial->edch = length ( GetText ( dial->tree, dial->edit, NULL ));
                  ed_field   = dial->edit;
                }
            }
          dial->cursor = TRUE;
          for_edit = dial;
          if ( sysgem.self_edit )
            {
              if ( ! on_screen ) Cursor ();
            }
        }
    }
}

/* ------------------------------------------------------------------- */

VOID CalcEdPos ( DIALOG_SYS *dial, INT x )

{
  INT   xx;
  BYTE  *s;
  INT   i;
  BYTE  c;

  objc_offset ( dial->tree, dial->edit, &xx, &i );
  s = GetText ( dial->tree, dial->edit, NULL );
  if ( sysgem.self_edit ) xx += 2;

  x = x - xx;
  if ( x < 0 ) return;
  i = 0;
  forever
    {
      c = s [i];
      if ( c == 0 ) break;
      s [i] = 0;
      if ( x < StringWidth ( s ) + 4 )
        {
          s [i] = c;
          if ( i == dial->edch ) return;
          hide_cursor ( dial );
          s [i] = 0;
          ed_field = 0;
          show_cursor ( dial );
          s [i] = c;
          return;
        }
      s [i] = c;
      i++;
    }
  hide_cursor ( dial );
  ed_field = 0;
  show_cursor ( dial );
}

/* ------------------------------------------------------------------- */

VOID DeleteChar ( BYTE *dst, INT pp, INT pmax, INT *pos )

{
  INT   i;
  BYTE  *p;

  p = edit_buff;
  i = 0;
  forever
    {
      if ( dst [i] == 0 ) break;
      if ( i == pp ) break;
      *p++ = dst [i];
      i++;
    }
  i++;
  forever
    {
      if ( dst [i] == 0 ) break;
      *p++ = dst [i];
      i++;
    }
  *p = 0;

  strncpy ( dst, edit_buff, (LONG)( pmax ));
  if ( pp < *pos )
    {
      *pos -= 1;
    }
}

/* ------------------------------------------------------------------- */

VOID InsertChar ( BYTE *dst, INT ch, INT pmax, INT *pos )

{
  INT   i;
  LONG len;
  BYTE  *p;

  p = dst;
  if ( length ( dst ) >= pmax )
    {
      if (( *pos < pmax )) /* -1 */
        {
          dst [pmax - 1] = 0;
          len = (LONG)( pmax - 1 - *pos );
          memcpy ( &dst [*pos + 1], &dst [*pos], len);
          dst [*pos] = ch;
          *pos = *pos + 1;
          return;
        }
      dst [pmax - 1] = ch;
      return;
    }
  i = 0;
  forever
    {
      if ( i == *pos )
        {
          edit_buff [i] = ch;
        }
      if ( *p == 0 )
        {
          break;
        }
      if ( i < *pos )
        {
          edit_buff [i] = *p++;
        }
      if ( i > *pos )
        {
          edit_buff [i] = *p++;
        }
      i++;
    }
  edit_buff [i + 1] = 0;
  strncpy ( dst, edit_buff, (LONG)( pmax ));
  *pos += 1;
}

/* ------------------------------------------------------------------- */

VOID edit_char ( DIALOG_SYS *dial, INT ch )

{
  INT           x, y, x1, y1;
  USERB         *ub;
  TEDINFO       *ted;
  BYTE          *t;
  COLOR_INF     cinf;
  INT           pmax;
  BOOL          do_white;

  do_white = FALSE;
  if ( dial->edit != 0 )
    {
      if ( dial->cursor )
        {
          if ( sysgem.self_edit )
            {
              if ( on_screen ) Cursor ();
              ub     = (USERB *)( dial->tree [dial->edit].ob_spec.index - 4L );
              ted    = (TEDINFO *) ub->parm;
              t      = ted->te_ptext;
              cinf.p = ted->te_color;
              pmax   = ted->te_txtlen - 1;

              switch ( ch )
                {
                  case BACKSPACE : if ( dial->edch == 0 ) return;
                                   DeleteChar ( t, dial->edch - 1, pmax, &dial->edch );
                                   do_white = TRUE;
                                   break;
                  case DELETE    : if ( dial->edch <= length ( t ))
                                     {
                                       DeleteChar ( t, dial->edch, pmax, &dial->edch );
                                       do_white = TRUE;
                                     }
                                   else
                                     {
                                       return;
                                     }
                                   break;
                  case INSERT		 : Alert ( ALERT_NORM, 1, "[2][ Insert Test.][ [Ja ]" );	/* [GS] */
                  								 break;																									/* [GS] */
/* [GS] 2.51; Start */
				          case CNTRL_CL  : if ( dial->edch == 0 ) return;
				          								 while ( t[dial->edch] != ' ' && dial->edch != 0 )
				          								 	 dial->edch -= 1;
				          								 break;
				          case CNTRL_CR  :
				          								 break;
/* Ende */
                  case CUR_LEFT  : if ( dial->edch == 0 ) return;
                                   dial->edch -= 1;
                                   break;
                  case CUR_RIGHT : if ( dial->edch < length ( t ))
                                     {
                                       dial->edch += 1;
                                     }
                                   else
                                     {
                                       if ( ! on_screen ) Cursor ();
                                       return;
                                     }
                                   break;
/* [GS] 2.51; Start: */
                  case ESC	     : SetText ( dial->tree, dial->edit, "" );
/* Ende; alt:
                  case 0xc01b    : SetText ( dial->tree, dial->edit, "" );
*/
                                   dial->edch = 0;
                                   do_white = TRUE;
                                   break;
                  default        : InsertChar ( t, ch, pmax, &dial->edch );
                                   break;
                }
              BeginControl ( CTL_UPDATE | CTL_MHIDE );
              objc_offset ( dial->tree, dial->edit, &x, &y );
              if ( do_white )
                {
                  x1 = x + dial->tree [dial->edit].ob_width - 1; /* 3 */
                  y1 = y + dial->tree [dial->edit].ob_height - 2;
                  FilledRect ( x + 1 + StringWidth ( t ), y + 1, x1, y1, WHITE );
                }
              y += 2;
              x += 4; /* 3 */
              v_stext ( cinf.b.textcol, x, y, t );
              Cursor ();
              EndControl ( CTL_UPDATE | CTL_MHIDE );
            }
          else
            {
              objc_edit ( dial->tree, dial->edit, nkc_n2gem ( ch ), &dial->edch, ED_CHAR );
            }
        }
    }
}

/* ------------------------------------------------------------------- */

BOOL is_editfield ( OBJECT *tree, INT i )

{
  INT   typ;

  GetObjType ( tree, i, &typ, NULL );
  if (( typ == G_FTEXT ) || ( typ == G_FBOXTEXT ))
    {
      if ((( tree [i].ob_state & DISABLED ) == 0 ) && (( tree [i].ob_flags & HIDETREE ) == 0 ))
        {
          if (( tree [i].ob_flags & EDITABLE ) != 0 ) return ( TRUE );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

VOID ClearEditFields ( OBJECT *tree )

{
  REG   INT     i;

  i = 0;
  forever
    {
      if ( is_editfield ( tree, i ))
        {
          SetText ( tree, i, "" );
        }
      if ( LASTOB & tree [i].ob_flags ) break;
      i++;
    }
}

/* ------------------------------------------------------------------- */

VOID xsetedit ( OBJECT *tree, INT ed )

{
  DIALOG_SYS	*dial;

  dial = find_dialog ( tree );
  if ( dial )
    {
      if ( ed <= 0 )
        {
          hide_cursor ( dial );
          dial->edit   = 0;
          dial->edch   = 0;
          dial->cursor = FALSE;
        }
      else
        {
          dial->edit   = ed;
          dial->edch   = 0;
          dial->cursor = FALSE;
          show_cursor ( dial );
        }
    }
}

/* ------------------------------------------------------------------- */

INT first_edit ( OBJECT *tree )

{
  REG   INT     field;

  field = 0;
  forever
    {
      if ( is_editfield ( tree, field ))
        {
          return ( field );
        }
      if ( tree [field].ob_flags & LASTOB ) break;
      field++;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT last_edit ( OBJECT *tree )

{
  REG   INT     field;

  field = 0;
  forever
    {
      if ( tree [field].ob_flags & LASTOB ) break;
      field++;
    }
  forever
    {
      if ( is_editfield ( tree, field ))
        {
          return ( field );
        }
      if ( field == 0 ) break;
      field--;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT next_edit ( DIALOG_SYS *dial )

{
  REG   OBJECT  *tree;
  REG   INT     field;

  tree  = dial->tree;
  field = dial->edit;
  if ( tree [field].ob_flags & LASTOB )
    {
      return ( first_edit ( tree ));
    }
  field++;
  forever
    {
      if ( is_editfield ( tree, field ))
        {
          return ( field );
        }
      if ( tree [field].ob_flags & LASTOB ) break;
      field++;
    }
  return ( first_edit ( tree ));
}

/* ------------------------------------------------------------------- */

INT prev_edit ( DIALOG_SYS *dial )

{
  REG   OBJECT  *tree;
  REG   INT     field;

  tree  = dial->tree;
  field = dial->edit;
  if ( field <= 1 )
    {
      return ( last_edit ( tree ));
    }
  field--;
  forever
    {
      if ( is_editfield ( tree, field ))
        {
          return ( field );
        }
      if ( field <= 1 ) break;
      field--;
    }
  return ( last_edit ( tree ));
}

/* ------------------------------------------------------------------- */

INT GetEdPos ( OBJECT *tree )

{
  DIALOG_SYS     *dial;

  dial = find_dialog ( tree );
  if ( dial != NULL )
    {
      return ( dial->edch );
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

VOID clear_edit ( DIALOG_SYS *dial, INT edit )

{
  dial->edit    = 0;
  dial->edch    = 0;
  dial->cursor  = FALSE;

  if ( edit == -2 )
    {
      edit = first_edit ( dial->tree );
    }

  if ( is_editfield ( dial->tree, edit ))
    {
      dial->edit   = edit;
    }
}

/* -------------------------------------------------------------------
 * Auswerten der Mausklicks
 * ------------------------------------------------------------------- */

VOID KeyFound ( WINDOW *win, WTREE *wt, INT x, INT y, INT obj, BOOL exit )

{
  OBJECT        *tree;
  USERB         *ub;
  INT           res;
  INT           x0, y0;
  INT           x1, y1;

  if ( wt->pos == LINK_MENU ) return;

  tree = wt->dial->tree;
  if ( tree [obj].ob_state & DISABLED ) return;
  if ( tree [obj].ob_flags & HIDETREE ) return;

  switch ( ObjTyp ( tree, obj ))
    {
      case OBJ_RADIO    : SendMessage ( SG_RADIO, win, wt, NULL, obj, 0, 0, 0 );
                          if (( sysgem.prg_id == 'SINF' ) && ( wt->dial->tree [obj].ob_flags & TOUCHEXIT ))
                            {
                              SendMessage ( SG_BUTTON, win, wt, NULL, obj, 0, 0, 0 );
                            }
                          break;
      case OBJ_SELECT   : if ( tree [obj].ob_state & SELECTED )
                            {
                              SendMessage ( SG_SELECT, win, wt, NULL, obj, 0, 0, 0 );
                            }
                          else
                            {
                              SendMessage ( SG_DESELECT, win, wt, NULL, obj, 0, 0, 0 );
                            }
                          if (( sysgem.prg_id == 'SINF' ) && ( wt->dial->tree [obj].ob_flags & TOUCHEXIT ))
                            {
                              SendMessage ( SG_BUTTON, win, wt, NULL, obj, 0, 0, 0 );
                            }
                          break;
      case OBJ_HELP     : if ( SendMessage ( SG_HELP, win, wt, NULL, obj, 0, 0, 0 ) != SG_SELECTED )
                            {
                              RedrawObj ( tree, obj, 0, SELECTED, DEL_STATE | UPD_STATE | USER_STATE );
                            }
                          break;
      case OBJ_REITER   : if ( wt != NULL )
                            {
                              if ( wt->dial != NULL )
                                {
                                  if ( wt->dial->tree [obj].ob_state & SELECTED ) return;
                                }
                            }
                          hide_cursor ( win->dial );
                          if ( SendMessage ( SG_NEWDIAL, win, wt, NULL, obj, 0, 0, 0 ) == SG_TAKEDIAL )
                            {
                              if ( DialogInWindow ( tree ) == NULL ) return;
                              ub = wt->dial->user;
                              while ( ub != NULL )
                                {
                                  excl ( wt->dial->tree [ub->obj].ob_state, SELECTED );
                                  ub = ub->next;
                                }
                              ub = wt->dial->user;
                              while ( ub != NULL )
                                {
                                  if ( obj == ub->obj )
                                    {
                                      incl ( wt->dial->tree [ub->obj].ob_state, SELECTED );
                                      break;
                                    }
                                  ub = ub->next;
                                }
                              FixWinTree   ( win );
                              RedrawWindow ( win->handle );
                              wt->dial->edit   = 0;
                              wt->dial->edch   = 0;
                              wt->dial->cursor = 0;
                              if ( win->dial == NULL ) return;
                              if ( SendMessage ( SG_EDITABLE, win, NULL, NULL, 0, 0, 0, 0 ) != SG_ABORT )
                                {
                                  res = GetHighRes ();
                                  if (( res == 0 ) || ( res == -2 ))
                                    {
                                      res = first_edit ( win->dial->tree );
                                    }
                                  if ( ! is_editfield ( win->dial->tree, res ))
                                    {
                                      res = 0;
                                    }
                                  win->dial->edit = res;
                                  win->dial->edch = 0;
                                  ed_field        = 0;
                                }
                              return;
                            }
                          break;
      case OBJ_CIRCLE   : objc_offset ( tree, obj, &x0, &y0 );
                          x0 = x0 + tree [obj].ob_width - ( 2 * sysgem.charw ) - 1;
                          x1 = x0 + tree [obj].ob_width;
                          y1 = y0 + tree [obj].ob_height;
                          if (( x > x0 ) && ( x < x1 ) && ( y > y0 ) && ( y < y1 ))
                            {
                              if ( xevent.state == 1 )
                                {
                                  res = SendMessage ( SG_LCIRCLE, win, wt, NULL, obj, 0, 0, 0 );
                                }
                              else
                                {
                                  res = SendMessage ( SG_RCIRCLE, win, wt, NULL, obj, 0, 0, 0 );
                                }
                            }
                          else
                            {
                              res = SendMessage ( SG_BUTTON, win, wt, NULL, obj, 0, 0, 0 );
                            }
                          goto do_deselect;
      default           : if ( exit )									/* Exit-Button ?			*/
                            {
                              res = SendMessage ( SG_BUTTON, win, wt, NULL, obj, 0, 0, 0 );
                            }
                          else
                            {													/* Nein								*/
                              SendMessage ( SG_TOUCH, win, wt, NULL, obj, xevent.kstate, 0, 0 );  /* [GS]*/
                            }
                          do_deselect:
                          if ( ! exit ) return;
                          if ( res != SG_SELECTED )
                            {
                              if (( tree [obj].ob_flags & TOUCHEXIT ) == 0 )
                                {
                                  RedrawObj ( tree, obj, 0, SELECTED, DEL_STATE | UPD_STATE | USER_STATE );
                                }
                            }
                          break;
    }
}

/* ------------------------------------------------------------------- */

BOOL set_edit ( WINDOW *win, INT old, INT new )

{
  if ( win->dial == NULL ) return ( FALSE );
  if ( new == old ) return ( FALSE );
  if ( win->dial->edit == 0 ) return ( FALSE );
  if ( is_editfield ( win->dial->tree, new ))
    {
      hide_cursor ( win->dial );
      if ( SendMessage ( SG_EDCHANGED, win, NULL, NULL, old, new, 0, 0 ) != SG_ABORT )
        {
          win->dial->edit = new;
          win->dial->edch = 0;
          show_cursor ( win->dial );
          return ( TRUE );
        }
      show_cursor ( win->dial );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL SetEditField ( OBJECT *tree, INT field )

{
  WINDOW        *win;
  WTREE         *wt;

  win = DialogInWindow ( tree );
  if ( win != NULL )
    {
      if ( win->dial != NULL )
        {
          wt = win->tree;
          while ( wt != NULL )
            {
              if ( wt->dial == win->dial )
                {
                  if ( field <= 0 )
                    {
                      hide_cursor ( win->dial );
                      win->dial->edit = 0;
                      win->dial->edch = 0;
                      return ( TRUE );
                    }
                  return ( set_edit ( win, win->dial->edit, field ));
                }
              wt = wt->next;
            }
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL ExitButton ( OBJECT *tree, INT obj, INT *ed )

{
  INT   edit;
  INT   i;

  if ( tree [obj].ob_state & DISABLED ) return ( FALSE );
  if ( tree [obj].ob_flags & HIDETREE ) return ( FALSE );
  i = form_button ( tree, obj, 1, &edit );
  if ( i == 0 ) return ( TRUE );
  if ( ed != NULL ) *ed = edit;
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL CheckSliderbox ( WINDOW *win, WTREE *wt, INT obj, INT y, INT clicks, INT state )

{
  INT   i;

  if ( sysgem.test_slider != NULL )
    {
      if (( clicks == 1 ) && ( state == 1 ))
        {
          if ( sysgem.test_slider ( win, wt->dial->tree, obj, y, 1, &i ) == FALSE ) return ( FALSE );
        }
      else
        {
          if ( sysgem.test_slider ( win, wt->dial->tree, obj, y, 2, &i ) == FALSE ) return ( FALSE );
        }
      if ( i < 0 ) /* Leerer Bereich in der Sliderbox */
        {
          i = -( i );
          i--;
          if (( clicks == 1 ) && ( state == 1 ))
            {
              SendMessage ( SG_EMPTYSLDLINE, win, wt, NULL, i, obj, 0, 0 );
            }
          return ( TRUE );
        }
      else
        {
          if ( i == 0 ) /* War Slider-Element */
            {
              return ( TRUE );
            }
          if ( i > 0 ) /* War Eintrag */
            {
              i--;
              if (( clicks == 1 ) && ( state == 1 )) SendMessage ( SG_SLIDER,   win, wt, NULL, i, obj, 0, 0 );
              if (( clicks == 2 ) && ( state == 1 )) SendMessage ( SG_SLIDER2,  win, wt, NULL, i, obj, 0, 0 );
              if (( clicks == 1 ) && ( state == 2 )) SendMessage ( SG_RSLIDER,  win, wt, NULL, i, obj, 0, 0 );
              if (( clicks == 2 ) && ( state == 2 )) SendMessage ( SG_RSLIDER2, win, wt, NULL, i, obj, 0, 0 );
              return ( TRUE );
            }
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

VOID HandleButton ( INT x, INT y, INT clicks, INT state )

{
  WINDOW        *win;
  WTREE         *wt;
  INT           obj;
  INT           edit;

  win = find_window ( wind_find ( x, y ), 0L );
  if ( win == NULL ) return;

#ifndef EXTOB
  DelBlub ();
  if ( win->icon != 0 )
    {
      if ( sysgem.iconify == ICONIFY_ICFS )
        {
          UnIconify ( win->handle );
        }
      return;
    }
#endif

  if ( topped () != win ) return;

  wt = win->tree;
  while ( wt != NULL )
    {
      obj = objc_find ( wt->dial->tree, wt->start, wt->depth, x, y );
      if ( obj != -1 )
        {
          if (( clicks == 1 ) && ( state == 1 ))
            {
              if ( wt->pos == LINK_MENU )
                {
                  hide_cursor ( win->dial );
#ifndef EXTOB
                  handle_menu ( win, wt->dial->tree );
#endif
                  return;
                }
              else
                {
                  if ( CheckSliderbox ( win, wt, obj, y, clicks, state )) return;
                  edit = 0;
                  if ( ExitButton ( wt->dial->tree, obj, &edit ))
                    {
                      KeyFound ( win, wt, x, y, obj, TRUE );
                      return;
                    }
                  else
                    {
                      if ( wt->dial->tree [obj].ob_state & DISABLED ) return;
                      if ( edit != 0 )
                        {
                          if ( win->dial != NULL )
                            {
                              if ( wt->dial->tree == win->dial->tree )
                                {
                                  if ( win->dial->edit == edit )
                                    {
                                      CalcEdPos ( win->dial, x );
                                      return;
                                    }
                                  set_edit ( win, win->dial->edit, edit );
                                }
                            }
                        }
                      else
                        {
                          KeyFound ( win, wt, x, y, obj, FALSE );
                        }
                      return;
                    }
                }
            }
          else
            {
              if ( xevent.state == 2 )
                {
                  if ( ObjTyp ( wt->dial->tree, obj ) == OBJ_CIRCLE )
                    {
                      KeyFound ( win, wt, x, y, obj, FALSE );
                      return;
                    }
                }
              if ( CheckSliderbox ( win, wt, obj, y, clicks, state )) return;
              if (( clicks == 2 ) && ( state == 1 )) SendMessage ( SG_BUTTON2,  win, wt, NULL, obj, 0, 0, 0 );
              if (( clicks == 1 ) && ( state == 2 )) SendMessage ( SG_RBUTTON,  win, wt, NULL, obj, 0, 0, 0 );
              if (( clicks == 2 ) && ( state == 2 )) SendMessage ( SG_RBUTTON2, win, wt, NULL, obj, 0, 0, 0 );
            }
          return;
        }
      wt = wt->next;
    }
  if ( win->dial != NULL ) return;

  if (( clicks == 1 ) && ( state == 1 )) SendMessage ( SG_LCLICK1, win, NULL, NULL, x, y, xevent.kstate, 0 ); /* [GS] */
  if (( clicks == 2 ) && ( state == 1 )) SendMessage ( SG_LCLICK2, win, NULL, NULL, x, y, xevent.kstate, 0 ); /* [GS] */
  if (( clicks == 1 ) && ( state == 2 )) SendMessage ( SG_RCLICK1, win, NULL, NULL, x, y, xevent.kstate, 0 ); /* [GS] */
  if (( clicks == 2 ) && ( state == 2 )) SendMessage ( SG_RCLICK2, win, NULL, NULL, x, y, xevent.kstate, 0 ); /* [GS] */
}

/* ------------------------------------------------------------------- */

UINT make_nkc ( INT key, INT state )

{
  union
    {
      long      l;
      TKEY      t;
    } toskey;

  toskey.t.ign1         = 0;
  toskey.t.caps         = 0;
  toskey.t.alt          = (( state & K_ALT    ) != 0 ) ? 1 : 0;
  toskey.t.contrl       = (( state & K_CTRL   ) != 0 ) ? 1 : 0;
  toskey.t.lshift       = (( state & K_LSHIFT ) != 0 ) ? 1 : 0;
  toskey.t.rshift       = (( state & K_RSHIFT ) != 0 ) ? 1 : 0;
  toskey.t.scan         = (BYTE)( key >> 8 );
  toskey.t.ign2         = 0;
  toskey.t.ascii        = (BYTE)( key );

  return ((UINT) nkc_tconv ( toskey.l ));
}

/* ------------------------------------------------------------------- */

INT get_default ( OBJECT *tree )

{
  REG   INT     i;

  i = 0;
  forever
    {
      if ((( tree [i].ob_state & DISABLED ) == 0 ) && (( tree [i].ob_flags & HIDETREE ) == 0 ))
        {
          if ( tree [i].ob_flags & DEFAULT ) return ( i );
        }
      if ( tree [i].ob_flags & LASTOB  ) break;
      i++;
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

VOID HandleKey ( UINT gem_key, INT kstate )

{
  WINDOW        *win;
  WTREE         *wt;
  DIALOG_SYS    *dial;
  USERB         *ub;
  OBJECT        *tree;
  UINT          key;
  INT           ch;
  INT           old;
  INT           obj;
  INT           d1, d2;

  key = make_nkc ( gem_key, kstate );

  if (( sysgem.menu_tree != NULL ) && ( forced () == NULL ))
    {
      obj = IsMenuKey ( sysgem.menu_tree, key, kstate );
      if ( obj != -1 )
        {
          if ( sysgem.menu_proc != NULL )
            {
              SelectMenu ( sysgem.menu_tree, obj, TRUE );
              if ( sysgem.menu_proc ( NULL, obj ) == SG_TERM ) /* [GS] */
                {
                  TerminateSysGem ();
                }
              SelectMenu ( sysgem.menu_tree, obj, FALSE );
            }
          return;
        }
    }

  win = find_window ( GetTopWindow (), 0L );

  if (( key == HELP ) && ( win == NULL ))
    {
      if ( sysgem.menu_proc != NULL )
        {
          if ( sysgem.menu_proc ( NULL,  -1 ) == SG_TERM ) /* [GS] */
            {
              TerminateSysGem ();
            }
        }
      return;
    }

  if ( win == NULL ) return;

  if ( ! ( win->flags & WIN_VISIBLE )) return;
  if ( win->icon != 0 ) return;

  wt = win->tree;
  while ( wt != NULL )
    {
      if ( wt->pos == LINK_MENU )
        {
          obj = IsMenuKey ( wt->dial->tree, key, kstate );
          if ( obj != -1 )
            {
              tree = wt->dial->tree;
              SelectMenu ( tree, obj, TRUE );
              SendMessage ( SG_MENU, win, NULL, NULL, obj, 0, 0, 0 );
              SelectMenu ( tree, obj, FALSE );
              return;
            }
        }
      wt = wt->next;
    }

  ch = alt_shortcut ( key );
  if ( ch == 0 ) goto no_shortcut;

  wt = win->tree;
  while ( wt != NULL )
    {
      ub = wt->dial->user;
      while ( ub != NULL )
        {
          if ( ub->ch == ch )
            {
              if ( ExitButton ( wt->dial->tree, ub->obj, NULL ))
                {
                  KeyFound ( win, wt, -1, -1, ub->obj, TRUE );
                }
              else
                {
                  KeyFound ( win, wt, -1, -1, ub->obj, FALSE );
                }
              return;
            }
          ub = ub->next;
        }
      wt = wt->next;
    }

  no_shortcut:

  if ( key == UNDO )
    {
      SendMessage ( SG_UNDO, win, NULL, NULL, 0, 0, 0, 0 );
      return;
    }
  if ( key == HELP )
    {
      obj = -1;
      wt  = win->tree;
      while ( wt != NULL )
        {
          ub = wt->dial->user;
          while ( ub != NULL )
            {
              if ( ub->ob_typ == OBJ_HELP )
                {
                  tree = wt->dial->tree;
                  obj  = ub->obj;
                  RedrawObj ( tree, obj, 0, SELECTED, SET_STATE | UPD_STATE | USER_STATE );
                  goto say_ishelp;
                }
              ub = ub->next;
            }
          wt = wt->next;
        }
      say_ishelp:
      if ( SendMessage ( SG_HELP, win, NULL, NULL, 0, 0, 0, 0 ) == SG_KEYCONT )
        {
          if ( obj != -1 )
            {
              RedrawObj ( tree, obj, 0, SELECTED, DEL_STATE | UPD_STATE | USER_STATE );
            }
          if ( sysgem.menu_proc != NULL )
            {
              if ( sysgem.menu_proc ( NULL, -1 ) == SG_TERM ) /* [GS] */
                {
                  TerminateSysGem ();
                }
            }
          return;
        }
      if ( obj != -1 )
        {
          RedrawObj ( tree, obj, 0, SELECTED, DEL_STATE | UPD_STATE | USER_STATE );
        }
      return;
    }

  if ( win->dial != NULL )
    {
      if ( win->dial->edit <= 0 ) goto ohne_editfeld;
      dial = win->dial;
      if ( sysgem.tell )
        {
          if ( SendMessage ( SG_KEY, win, NULL, NULL, key, xevent.kstate, gem_key, 0 ) == SG_KEYUSED )
            {
              return;
            }
        }
      old = dial->edit;
      switch ( key )
        {
          case CNTRL_X   : hide_cursor ( dial );
                           ed_field = 0;
                           buff_copy ( dial );
                           SetText ( dial->tree, dial->edit, "" );
                           RedrawObj ( dial->tree, dial->edit, 0, NONE, UPD_STATE );
                           return;
          case CNTRL_C   : hide_cursor ( dial );
                           ed_field = 0;
                           buff_copy ( dial );
                           return;
          case CNTRL_V   : hide_cursor ( dial );
                           ed_field = 0;
                           buff_insert ( dial );
                           RedrawObj ( dial->tree, dial->edit, 0, NONE, UPD_STATE );
                           return;
          case CNTRL_D   : del_buff ();
                           return;
          case TAB       :
          case CUR_DOWN  : set_edit ( win, old, next_edit ( dial ));
                           break;
          case 0xc20d    : /* left shift return */
          case 0xc10d    : /* right shift return */
          case 0xe20a    : /* left shift enter */
          case 0xe10a    : /* right shift enter */
                           if ( sysgem.sg_return )
                             {
                               goto normal_return;
                             }
                           break;
          case RETURN    :
          case ENTER     : if ( sysgem.sg_return )
                             {
                               if ( dial->edit <= 0 ) goto normal_return;
                               d1 = next_edit ( dial );
                               d2 = first_edit ( dial->tree );
                               if (( d1 == d2 ) && ( dial->edit != d1 ))
                                 {
                                   if ( SendMessage ( SG_LASTEDIT, win, NULL, NULL, 0, 0, 0, 0 ) == SG_CLOSE )
                                     {
                                       return;
                                     }
                                 }
                               set_edit ( win, old, next_edit ( dial ));
                               return;
                             }
                           normal_return:
                           obj = get_default ( dial->tree );
                           if ( obj != -1 )
                             {
                               KeyFound ( win, find_wt_type ( win, LINK_DIALOG ), -1, -1, obj, ExitButton ( win->dial->tree, obj, NULL ));
                               return;
                             }
                           break;
          case LSHFT_TAB :
          case RSHFT_TAB :
          case CUR_UP    : set_edit ( win, old, prev_edit ( dial ));
                           break;
          case HOME      : set_edit ( win, old, first_edit ( dial->tree ));
                           break;
          case RSHFT_HOME:
          case LSHFT_HOME: set_edit ( win, old, last_edit ( dial->tree ));
                           break;
/* [GS] 2.51; Start */
          case CNTRL_CL  :
          case CNTRL_CR  :
/* Ende */
          case CUR_LEFT  :
          case CUR_RIGHT : edit_char ( dial, key );
                           break;
          case LSHFT_CR  :
          case RSHFT_CR  : hide_cursor ( dial );
                           ed_field = 0;
                           show_cursor ( dial );
                           break;
          case LSHFT_CL  :
          case RSHFT_CL  : objc_offset ( dial->tree, dial->edit, &d1, &d2 );
                           CalcEdPos ( dial, d1 + 2 );
                           break;
/* [GS] 2.51; Start */
          case INSERT		 : edit_char ( dial, key );
                           break;
/* Ende */
          default        : obj = SendMessage ( SG_EDKEY, win, NULL, NULL, key, xevent.kstate, gem_key, 0 );
                           if ( obj != SG_ABORT )
                             {
                               if ( obj == SG_TAKEKEY )
                                 {
                                   edit_char ( dial, GetHighRes ());
                                 }
                               else
                                 {
                                   edit_char ( dial, key );
                                 }
                               SendMessage ( SG_EDREDRAW, win, NULL, NULL, dial->edit, 0, 0, 0 );
                               sg_redredit = FALSE;
                             }
                           break;
        }
    }
  else
    {
      ohne_editfeld:
      wt = win->tree;
      while ( wt != NULL )
        {
          if ( wt->pos == LINK_DIALOG ) break;
          wt = wt->next;
        }
      if ( sysgem.tell )
        {
          obj = SendMessage ( SG_KEY, win, wt, NULL, key, xevent.kstate, gem_key, 0 );
          if (( obj == SG_KEYUSED ) || ( obj == SG_CLOSE ))
            {
              return;
            }
        }
      switch ((UINT)( key ))
        {
          case 0xc20d :
          case 0xc10d :
          case 0xe20a :
          case 0xe10a :
          case RETURN :
          case ENTER  : if ( wt == NULL ) goto send_the_key;
                        obj = get_default ( wt->dial->tree );
                        if ( obj != -1 )
                          {
                            KeyFound ( win, wt, -1, -1, obj, ExitButton ( win->dial->tree, obj, NULL ));
                            return;
                          }
          default     : send_the_key:
                        SendMessage ( SG_KEY, win, NULL, NULL, key, xevent.kstate, gem_key, 0 );
                        break;
        }
    }
}

/* ------------------------------------------------------------------- */

BOOL ValidShortcut ( BYTE ch )

{
  REG   BYTE    *p;
  REG   BYTE    c;

  p = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\000";
  c = ch;
  if ( ch >= 97 ) c = ch - 32;
  while ( *p )
    {
      if ( *p++ == c ) return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

VOID MakeShortCut ( USERB *ub )

{
  BYTE          tmp_str [200];
  BYTE          *p;
  BYTE          *q;
  INT           pos;

  if ( ub == NULL ) return;
  p = ub->text;
  if ( p == NULL ) return;

  memset ( tmp_str, 0, sizeof ( tmp_str ));

  ub->ch        = 0;
  ub->pos       = -1;

  if ( strchr ( p, '[' ) == NULL ) return;

  strcpy ( tmp_str, p );
  q   = tmp_str;
  pos = 0;
  while ( *q )
    {
      if ( *q == '[' )
        {
          q++;
          if ( ValidShortcut ( *q ))
            {
              ub->ch  = toupper ( *q );
              ub->pos = pos;
            }
          q--;
        }
      else
        {
          *p++ = *q;
        }
      q++;
      pos++;
    }
  *p = 0;
}

/* ------------------------------------------------------------------- */

USERB *find_user ( OBJECT *tree, INT obj )

{
  DIALOG_SYS    *dial;
  USERB         *ub;

  dial = find_dialog ( tree );
  if ( dial != NULL )
    {
      ub = dial->user;
      while ( ub != NULL )
        {
          if ( ub->obj == obj ) return ( ub );
          ub = ub->next;
        }
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

LONG GetObjType ( OBJECT *tree, INT i, INT *typ, INT *ext )

{
  INT           t;
  INT           e;
  LONG          p;
  USERB         *ub;

	p = 0L;
  if ( tree [i].ob_type == G_USERDEF )
    {
      ub      = find_user ( tree, i );
      if ( ub == NULL )
        {
          if ( typ != NULL ) *typ = -1;
          if ( ext != NULL ) *ext = -1;
          return ( 0L );
        }
      t       = ub->typ;
      e       = ub->ext;
      p       = ub->parm;
    }
  else
    {
      t       = (INT)((BYTE)( tree [i].ob_type ));
      e       = tree [i].ob_type >> 8;
      p       = tree [i].ob_spec.index;
    }
  if ( typ != NULL ) *typ = t;
  if ( ext != NULL ) *ext = e;
  return ( p );
}

/* ------------------------------------------------------------------- */

INT ObjTyp ( OBJECT *tree, INT i )

{
  USERB         *ub;

  if ( tree == NULL ) return ( -1 );
  if ( tree [i].ob_type == G_USERDEF )
    {
      ub = find_user ( tree, i );
      if ( ub != NULL ) return ( ub->ob_typ );
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

VOID SetText ( OBJECT *tree, INT index, BYTE *text )

{
  INT           ext;
  INT           typ;
  TEDINFO       *ted;
  ICONBLK       *icn;
  LONG          q;

  if ( text == NULL ) return;
  if ( tree == NULL ) return;
  if ( index <= 0 )   return;

  q = GetObjType ( tree, index, &typ, NULL );
  if ( q == 0L )
    {
      return;
    }
  switch ( typ )
    {
      case G_TEXT     :
      case G_BOXTEXT  : ted = (TEDINFO *) q;
                        ext = ted->te_txtlen - 1;
                        strncpy ( ted->te_ptext, text, (LONG)( ext ));
                        break;
      case G_FTEXT    :
      case G_FBOXTEXT : ted = (TEDINFO *) q;
                        ext = ted->te_txtlen - 1;
                        strncpy ( ted->te_ptext, text, (LONG)( ext ));
                        break;
      case G_BUTTON   :
      case G_STRING   :
      case G_TITLE    : strcpy ((BYTE *) q, text );
                        break;
      case G_ICON     : icn = (ICONBLK *) q;
                        strcpy ( icn->ib_ptext, text );
                        break;
      default         : ;
    }
}

/* ------------------------------------------------------------------- */

VOID xSetText ( OBJECT *tree, INT index, BYTE *text )

{
  INT           ext;
  INT           typ;
  INT           i;
  TEDINFO       *ted;
  LONG          q;

  if ( text == NULL ) return;
  if ( tree == NULL ) return;
  if ( index <= 0 )   return;

  q = GetObjType ( tree, index, &typ, NULL );
  if ( q == 0L )
    {
      return;
    }
  switch ( typ )
    {
      case G_FTEXT    :
      case G_FBOXTEXT :
      case G_TEXT     :
      case G_BOXTEXT  : ted = (TEDINFO *) q;
                        ext = ted->te_txtlen - 1;
                        switch ( ted->te_just )
                          {
                            case TE_LEFT  : sprintf ( ted->te_ptext, "%-*.*s", ext, ext, text );
                                            break;
                            case TE_RIGHT : sprintf ( ted->te_ptext, "%*.*s", ext, ext, text );
                                            break;
                            case TE_CNTR  : i = length ( text );
                                            i = i / 2;
                                            i = ( ext / 2 ) - i;
                                            if ( i > 0 )
                                              {
                                                sprintf ( ted->te_ptext, "%-*.*s%s%-*.*s", i, i, " ", text, i, i, " " );
                                                return;
                                              }
                            default       : SetText ( tree, index, text );
                                            break;
                          }
                        break;
      default         : SetText ( tree, index, text );
                        break;
    }
}

/* ------------------------------------------------------------------- */
/* Funktion komplett neu [GS] 																				 */

VOID SetBoxChar ( OBJECT *tree, INT index, BYTE c )

{
  INT           typ;
  bfobspec      *obspec;
  LONG          q;

  if ( tree == NULL ) return;
  if ( index <= 0 )   return;

  q = GetObjType ( tree, index, &typ, NULL );
  if ( q == 0L )
    {
      return;
    }

  if ( typ == G_BOXCHAR )
  	{
  		obspec = (bfobspec *) q;
  		obspec->character = c;
  	}

}

/* ------------------------------------------------------------------- */
/* Funktion komplett neu [GS] 																				 */

WORD GetBoxChar ( OBJECT *tree, INT index, BYTE *c )

{
  INT           typ;
  bfobspec      *obspec;
  LONG          q;

  if ( tree == NULL ) return FALSE;
  if ( index <= 0 )   return FALSE;

  q = GetObjType ( tree, index, &typ, NULL );
  if ( q == 0L )
    {
      return FALSE;
    }

  if ( typ == G_BOXCHAR )
  	{
  		obspec = (bfobspec *) q;
  		*c = obspec->character;
  		return TRUE;
  	}

	return FALSE;
}

/* ------------------------------------------------------------------- */
/* Funktion komplett neu [GS] 																				 */

VOID SetInt ( OBJECT *tree, INT index, WORD i )

{
	BYTE	tmp[20];
	
	itoa(i, tmp, 10);
	SetText ( tree, index, tmp );

}

/* ------------------------------------------------------------------- */
/* Funktion komplett neu [GS] 																				 */

WORD GetInt ( OBJECT *tree, INT index)

{
	BYTE	tmp[20];
	
	GetText ( tree, index, tmp );
	return atoi(tmp);

}

/* ------------------------------------------------------------------- */
/* Funktion komplett neu [GS] 																				 */

VOID SetLong ( OBJECT *tree, INT index, LONG i )

{
	BYTE	tmp[33];
	
	ltoa(i, tmp, 10);
	SetText ( tree, index, tmp );
}

/* ------------------------------------------------------------------- */
/* Funktion komplett neu [GS] 																				 */

VOID SetULong ( OBJECT *tree, INT index, ULONG i )

{
	BYTE	tmp[33];
	
	ultoa(i, tmp, 10);
	SetText ( tree, index, tmp );
}

/* ------------------------------------------------------------------- */
/* Funktion komplett neu [GS] 																				 */

LONG GetLong ( OBJECT *tree, INT index)

{
	BYTE	tmp[33];
	
	GetText ( tree, index, tmp );
	return atol(tmp);

}

/* ------------------------------------------------------------------- */

BYTE *GetText ( OBJECT *tree, INT index, BYTE *text )

{
  INT           typ;
  TEDINFO       *ted;
  ICONBLK       *icn;
  BYTE          *p;
  LONG          q;

  q = GetObjType ( tree, index, &typ, NULL );
  if ( q == 0L )
    {
      if ( text != NULL ) *text = 0;
      return ( NULL );
    }
  switch ( typ )
    {
      case G_TEXT     :
      case G_BOXTEXT  :
      case G_FTEXT    :
      case G_FBOXTEXT : ted = (TEDINFO *) q;
                        p = ted->te_ptext;
                        if ( text != NULL ) strcpy ( text, p );
                        break;
      case G_BUTTON   :
      case G_STRING   :
      case G_TITLE    : p = (BYTE *) q;
                        if ( text != NULL ) strcpy ( text, p );
                        break;
      case G_ICON     : icn = (ICONBLK *) q;
                        p = icn->ib_ptext;
                        if ( text != NULL ) strcpy ( text, p );
                        break;
      default         : break;
    }
  if ( text == NULL ) return ( p );
  return ( text );
}

/* ------------------------------------------------------------------- */

VOID ChangeButton ( OBJECT *tree, INT obj, BYTE *text )

{
  USERB         *ub;
  DIALOG_SYS    *dial;

  SetText ( tree, obj, text );
  dial = find_dialog ( tree );
  if ( dial != NULL )
    {
      ub = dial->user;
      while ( ub != NULL )
        {
          if ( ub->obj == obj )
            {
              MakeShortCut ( ub );
              return;
            }
          ub = ub->next;
        }
    }
}

/* ------------------------------------------------------------------- */

USERB *NewUserblock ( DIALOG_SYS *dial, OBJECT *tree, INT obj, BYTE *text, INT typ )

{
  USERB         *ub;
  INT           x, y, w, h;

  if (( tree [obj].ob_type >> 8 ) == 120 ) return ( NULL );

  excl ( tree [obj].ob_flags, 0x0200 );
  excl ( tree [obj].ob_flags, 0x0400 );

  ub = (USERB *) Allocate ( sizeof ( USERB ));
  if ( ub == NULL ) return ( NULL );

  x = 0;
  y = 0;
  w = 0;
  h = 0;

  ub->next          = NULL;
  ub->code          = DrawUserDef;
  ub->ubb           = ub;
  ub->text          = text;
  ub->parm          = tree [obj].ob_spec.index;
  ub->obj           = obj;
  ub->ob_typ        = typ;
  ub->ext           = (INT)((BYTE)( tree [obj].ob_type >> 8 ));
  ub->typ           = (INT)((BYTE)( tree [obj].ob_type >> 0 ));
  ub->ch            = 0;
  ub->pos           = -1;

  InsertPtr ( &dial->user, ub );

  switch ( typ )
    {
      case OBJ_BUTTON  :
      case OBJ_FRAME   :
      case OBJ_TOUCH   :
      case OBJ_HELP    : if ( sysgem.bergner ) goto bergner;
                         x = 1;
                         y = 2 + ( sysgem.charh / 4 );
                         w = 2 + ( sysgem.charw / 4 );
                         h = 2 + ( sysgem.charh / 2 );
                         MakeShortCut ( ub );
                         break;
      case OBJ_REITER  : bergner:
                         x = 1;  y = 2;  w = 2; h = 2;
                         MakeShortCut ( ub );
                         break;
      case OBJ_RADIO   : MakeShortCut ( ub );
                         break;
      case OBJ_SELECT  : MakeShortCut ( ub );
                         break;
      case OBJ_BOX     : x = 0;  y = 0;  w = 2; h = 2;
                         if ( ub->ext == 4 )
                           {
                             w = 0; h = 0;
                           }
                         break;
      case OBJ_CHAR    : x = 0; y = 0; w = 2; h = 2;
                         if ( tree [obj].ob_state & SHADOWED )
                           {
                             w = 4;  h = 4;
                           }
                         break;
      case OBJ_TEXT    : if ( ub->typ == G_BOXTEXT )
                           {
                             if ( tree [obj].ob_state & SHADOWED )
                               {
                                 x = 1;
                                 y = 1;
                                 w = 2;
                                 h = 3;
                               }
                             else
                               {
                                 h = 2;
                               }
                           }
                         MakeShortCut ( ub );
                         break;
      case OBJ_STRING  : MakeShortCut ( ub );
                         break;
      case OBJ_EDIT    : x = 1; y = 2; w = 6; h = 4;
                         break;
      case OBJ_LISTBOX :
      case OBJ_CIRCLE  : x = 1; y = 2; w = ( 3 * sysgem.charw ) + ( sysgem.charw / 2 ); h = 5;
                         MakeShortCut ( ub );
                         break;
    }

  if ( tree [obj].ob_x != 0 )
    {
      tree [obj].ob_x -= x;
    }
  else
    {
      x = 0;
    }
  if ( tree [obj].ob_y != 0 )
    {
      tree [obj].ob_y -= y;
    }
  else
    {
      y = 0;
    }
  tree [obj].ob_width    += w;
  tree [obj].ob_height    += h;
  tree [obj].ob_type  = G_USERDEF;
  tree [obj].ob_spec.index = (LONG)( &ub->code );

  return ( ub );
}

/* ------------------------------------------------------------------- */

BOOL NewDialog ( OBJECT *tree )

{
  DIALOG_SYS    *dial;
  BYTE          *p;
  INT           i;
  INT           flags;

  if ( find_dialog ( tree ))
    {
      return ( FALSE );
    }

  sysgem.new_dial = TRUE;

  dial = (DIALOG_SYS *) Allocate ( sizeof ( DIALOG_SYS ));
  if ( dial == NULL ) return ( FALSE );

  dial->next    = NULL;
  dial->tree    = tree;

  InsertPtr ( &sysgem.dialog, dial );

  form_center ( tree, &i, &i, &i, &i );

  if (( tree [0].ob_type >> 8 ) == 121 )
    {
      tree [0].ob_x = 0;
      tree [0].ob_y = 0;
      return ( TRUE );
    }

  if (( tree [0].ob_type >> 8 ) != 120 )
    {
      tree [0].ob_spec.index = 0L;
      tree [0].ob_state = 0;
      tree [0].ob_flags = 0;
    }

  i = 0;
  forever
    {
      flags = tree [i].ob_flags;
      switch ((BYTE)( tree [i].ob_type ))
        {
          case G_BUTTON     : p = tree [i].ob_spec.free_string;
                              if (( tree [i].ob_type >> 8 ) == 1 )
                                {
                                  excl ( tree [i].ob_state, SELECTED );
                                  NewUserblock ( dial, tree, i, p, OBJ_HELP );
                                  break;
                                }
                              if (( tree [i].ob_type >> 8 ) == 2 )
                                {
                                  excl ( tree [i].ob_state, SELECTED );
                                  NewUserblock ( dial, tree, i, p, OBJ_HELP );
                                  break;
                                }
                              if (( tree [i].ob_type >> 8 ) == 3 )
                                {
                                  excl ( tree [i].ob_flags, EXIT      );
                                  excl ( tree [i].ob_flags, TOUCHEXIT );
                                  excl ( tree [i].ob_flags, DEFAULT   );
                                  NewUserblock ( dial, tree, i, p, OBJ_REITER );
                                  break;
                                }
                              if ( flags & EXIT )
                                {
                                  NewUserblock ( dial, tree, i, p, OBJ_BUTTON );
                                  break;
                                }
                              if ( flags & RBUTTON )
                                {
                                  NewUserblock ( dial, tree, i, p, OBJ_RADIO );
                                  break;
                                }
                              if ( flags & SELECTABLE )
                                {
                                  NewUserblock ( dial, tree, i, p, OBJ_SELECT );
                                  break;
                                }
                              if ( flags & TOUCHEXIT )
                                {
                                  NewUserblock ( dial, tree, i, p, OBJ_TOUCH );
                                  break;
                                }
                              NewUserblock ( dial, tree, i, p, OBJ_FRAME );
                              break;
          case G_BOX        : if (( tree [i].ob_type >> 8 ) == 50 )
                                {
                                  NewUserblock ( dial, tree, i, NULL, OBJ_BALKEN1 );
                                  break;
                                }
                              if (( tree [i].ob_type >> 8 ) == 51 )
                                {
                                  NewUserblock ( dial, tree, i, NULL, OBJ_BALKEN2 );
                                  break;
                                }
                              if (( tree [i].ob_type >> 8 ) == 52 )
                                {
                                  NewUserblock ( dial, tree, i, NULL, OBJ_BALKEN3 );
                                  break;
                                }
                              NewUserblock ( dial, tree, i, NULL, OBJ_BOX );
                              break;
          case G_BOXCHAR    : if (( tree [i].ob_type >> 8 ) != 11 )
                                {
                                  NewUserblock ( dial, tree, i, NULL, OBJ_CHAR );
                                }
                              break;
          case G_TEXT       :
          case G_BOXTEXT    : p = tree [i].ob_spec.tedinfo->te_ptext;
                              switch ( tree [i].ob_type >> 8 )
                                {
                                  case  2 : NewUserblock ( dial, tree, i, p, OBJ_LISTBOX );
                                            break;
                                  case  3 : NewUserblock ( dial, tree, i, p, OBJ_CIRCLE );
                                            break;
                                  default : NewUserblock ( dial, tree, i, p, OBJ_TEXT );
                                            break;
                                }
                              break;
          case G_STRING     : p = tree [i].ob_spec.free_string;
                              NewUserblock ( dial, tree, i, p, OBJ_STRING );
                              break;
          case G_FTEXT      :
          case G_FBOXTEXT   : if ( sysgem.self_edit )
                                {
                                  p = tree [i].ob_spec.tedinfo->te_ptext;
                                  NewUserblock ( dial, tree, i, p, OBJ_EDIT );
                                }
                              break;
          default           : break;
        }

      if ( tree [i].ob_flags & LASTOB ) break;
      i++;
    }
  tree [0].ob_x = 0;
  tree [0].ob_y = 0;
  return ( TRUE );
}

/* -------------------------------------------------------------------
 * Zeichenroutinen
 * ------------------------------------------------------------------- */

VOID CalcArea ( OBJECT *tree, INT obj, RECT *r )

{
/* [GS] 2.51; Start: */
	INT i;
/* Ende */
	
  if ( tree == NULL ) return;

  objc_offset ( tree, obj, &r->x, &r->y );
/* [GS] 2.51; Start: */
	i= ObjTyp ( tree, obj );
  r->w = tree [obj].ob_width;
 	r->h = tree [obj].ob_height;
	if ( i != -1 )
	{
		switch ( i )
			{
				case OBJ_RADIO :
				case OBJ_SELECT: r->w += 24;				break;
			}
	}
/* Ende; alt:
  r->w = tree [obj].ob_width;
 	r->h = tree [obj].ob_height;
*/
}

/* ------------------------------------------------------------------- */

VOID SetClipping ( RECT *r )

{
  INT   pxy [4];

  if ( r == NULL )
    {
      pxy [0] = sysgem.desk.x;
      pxy [1] = sysgem.desk.y;
      pxy [2] = sysgem.desk.x + sysgem.desk.w - 1;
      pxy [3] = sysgem.desk.y + sysgem.desk.h - 1;
      vs_clip ( sysgem.vdi_handle, 0, pxy );
      vs_clip ( sysgem.vdi_user,   0, pxy );
      memcpy  ( &sg_clip_r, &sysgem.desk, sizeof ( RECT ));
      return;
    }

  pxy [0] = r->x;
  pxy [1] = r->y;
  pxy [2] = r->x + r->w - 1;
  pxy [3] = r->y + r->h - 1;
  vs_clip ( sysgem.vdi_handle, 1, pxy );
  vs_clip ( sysgem.vdi_user,   1, pxy );
  memcpy  ( &sg_clip_r, r, sizeof ( RECT ));
}

/* ------------------------------------------------------------------- */

VOID move_screen ( RECT *r, INT x, INT y )

{
  INT   pxy [8];

  pxy [0] = r->x;
  pxy [1] = r->y;
  pxy [2] = r->x + r->w - 1;
  pxy [3] = r->y + r->h - 1;
  pxy [4] = x;
  pxy [5] = y;
  pxy [6] = x + r->w - 1;
  pxy [7] = y + r->h - 1;
  vro_cpyfm ( sysgem.vdi_handle, 3, pxy, &dst, &dst );
}

/* ------------------------------------------------------------------- */

VOID ReplaceMode ( VOID )

{
  vswr_mode ( sysgem.vdi_handle, MD_REPLACE );
}

/* ------------------------------------------------------------------- */

VOID TransMode ( VOID )

{
  vswr_mode ( sysgem.vdi_handle, MD_TRANS );
}

/* ------------------------------------------------------------------- */

VOID TextEffect ( INT eff )

{
  vst_effects ( sysgem.vdi_handle, eff );
}

/* ------------------------------------------------------------------- */

VOID TextColor ( INT color )

{
  vst_color ( sysgem.vdi_handle, color );
}

/* ------------------------------------------------------------------- */

VOID inv_area ( INT color, INT x, INT y, INT w, INT h )

{
  INT   pxy [4];

  pxy [0] = x;
  pxy [1] = y;
  pxy [2] = x + w - 1;
  pxy [3] = y + h - 1;

  BeginControl  ( CTL_MHIDE );
  vsf_style     ( sysgem.vdi_handle, 0 );
  vsf_interior  ( sysgem.vdi_handle, 1 );
  vsf_color     ( sysgem.vdi_handle, color );
  vsf_perimeter ( sysgem.vdi_handle, 0 );
  vswr_mode     ( sysgem.vdi_handle, MD_XOR );
  v_bar         ( sysgem.vdi_handle, pxy );
  vswr_mode     ( sysgem.vdi_handle, MD_REPLACE );
  EndControl    ( CTL_MHIDE );
}

/* ------------------------------------------------------------------- */

VOID CopyToScreen ( BOOL draw_3d, VOID *img_h, VOID *img_l, INT x, INT y )

{
  MFDB  src     = { NULL, 16, 16, 1, 1, 1, 0, 0, 0 };
  INT   pxy [8];
  INT   col [2];

  if ( draw_3d )
    {
      col [0] = BLACK;
      col [1] = sysgem.lwhite;
    }
  else
    {
      col [0] = BLACK;
      col [1] = WHITE;
    }
  pxy [0]  = 0;
  pxy [1]  = 0;
  pxy [2]  = 15;
  pxy [3]  = ( sysgem.ymax <= 200 ) ? 7 : 15;
  pxy [4]  = x;
  pxy [5]  = y;
  pxy [6]  = x + pxy [2];
  pxy [7]  = y + pxy [3];
  src.fd_h = ( sysgem.ymax <= 200 ) ? 8 : 16;
  src.fd_addr = ( sysgem.ymax <= 200 ) ? img_l : img_h;
  vrt_cpyfm ( sysgem.vdi_handle, MD_REPLACE, pxy, &src, &dst, col );
}

/* ------------------------------------------------------------------- */

VOID Line ( INT x0, INT y0, INT x1, INT y1, INT color )

{
  INT     pxy [4];

  pxy [0] = x0;
  pxy [1] = y0;
  pxy [2] = x1;
  pxy [3] = y1;

  vsl_color ( sysgem.vdi_handle, color );
  v_pline   ( sysgem.vdi_handle, 2, pxy );
}

/* ------------------------------------------------------------------- */

VOID xRect ( INT x0, INT y0, INT x1, INT y1, INT color )

{
  INT     pxy [10];

  pxy [0] = x0;
  pxy [1] = y0;
  pxy [2] = x1;
  pxy [3] = y0;
  pxy [4] = x1;
  pxy [5] = y1;
  pxy [6] = x0;
  pxy [7] = y1;
  pxy [8] = x0;
  pxy [9] = y0;

  vsl_color ( sysgem.vdi_handle, color );
  v_pline   ( sysgem.vdi_handle, 5, pxy );
}

/* ------------------------------------------------------------------- */

VOID Frame ( INT x0, INT y0, INT x1, INT y1, INT thick, INT color )

{
  REG   INT     i;

  if ( thick != 0 )
    {
      i = 0;
      forever
        {
          xRect ( x0, y0, x1, y1, color );
          if ( thick < 0 )
            {
              i--;
              if ( i == thick ) return;
              x0--;
              y0--;
              x1++;
              y1++;
            }
          else
            {
              i++;
              if ( i == thick ) return;
              x0++;
              y0++;
              x1--;
              y1--;
            }
        }
    }
}

/* ------------------------------------------------------------------- */

VOID FilledRect ( INT x0, INT y0, INT x1, INT y1, INT color )

{
  INT   pxy [4];

  pxy [0] = x0;
  pxy [1] = y0;
  pxy [2] = x1;
  pxy [3] = y1;

  vsf_interior  ( sysgem.vdi_handle, FIS_SOLID );
  vsf_color     ( sysgem.vdi_handle, color );
  vsf_perimeter ( sysgem.vdi_handle, 0 );
  v_bar         ( sysgem.vdi_handle, pxy );
  vsf_color     ( sysgem.vdi_handle, BLACK );
}

/* ------------------------------------------------------------------- */

VOID DrawPattern ( INT x0, INT y0, INT x1, INT y1, INT pattern, INT interiorcol )

{
  INT     pxy [4];

  switch ( pattern )
    {
      case 0 : vsf_interior ( sysgem.vdi_handle, FIS_HOLLOW );
               break;
      case 7 : vsf_interior ( sysgem.vdi_handle, FIS_SOLID );
               break;
      default: vsf_interior ( sysgem.vdi_handle, FIS_PATTERN );
               vsf_style    ( sysgem.vdi_handle, pattern );
               break;
    }
  pxy [0] = x0;
  pxy [1] = y0;
  pxy [2] = x1;
  pxy [3] = y1;

  vsf_color     ( sysgem.vdi_handle, interiorcol );
  vsf_perimeter ( sysgem.vdi_handle, 0 );
  v_bar         ( sysgem.vdi_handle, pxy );
  vsf_color     ( sysgem.vdi_handle, BLACK );
}

/* ------------------------------------------------------------------- */

VOID PaintPattern ( INT x0, INT y0, INT x1, INT y1, bfobspec *sp )

{
  vsf_color     ( sysgem.vdi_handle, sp->interiorcol );
  vsf_perimeter ( sysgem.vdi_handle, 0 );
  if ( sp->framesize == 0 )
    {
      DrawPattern   ( x0, y0, x1, y1, sp->fillpattern, sp->interiorcol );
      return;
    }
  DrawPattern   ( x0 + 1, y0 + 1, x1 - 1, y1 - 1, sp->fillpattern, sp->interiorcol );
  Frame         ( x0, y0, x1, y1, sp->framesize, sp->framecol );
}

/* -------------------------------------------------------------------
 * Nachgebaute Funktionen
 * ------------------------------------------------------------------- */

VOID VqtReal ( BYTE *text, INT *extent )

{
/*
  INT   len;
  INT   i;
  UINT  *tmp;
*/

  if ( sysgem.nvdi_version < 0x0300 )
    {
      if ( sysgem.act_font_vk )
        {
          vqt_f_extent ( sysgem.vdi_handle, text, extent );
        }
      else
        {
          vqt_extent ( sysgem.vdi_handle, text, extent );
        }
      return;
    }


	vqt_real_extent ( sysgem.vdi_handle, 100, 100, text, extent );

/*--

  _VDIParBlk.ptsin [0] = 100;
  _VDIParBlk.ptsin [1] = 100;

  len = 0;
  tmp = (UINT *) _VDIParBlk.intin;
  while (( *tmp++ = (UBYTE)( *text++ )) != 0 ) len++;

  _VDIParBlk.contrl [0] = 240;
  _VDIParBlk.contrl [1] = 1;
  _VDIParBlk.contrl [3] = len;
  _VDIParBlk.contrl [5] = 4200;						/* vqt_real_extent */
  _VDIParBlk.contrl [6] = sysgem.vdi_handle;

  vdi ( &pb );

  for ( i = 0; i < 8; i++ ) *extent++ = _VDIParBlk.ptsout [i];
---*/
}

/* ------------------------------------------------------------------- */

VOID VqtDevice ( INT dev_no, INT *open, BYTE *name )

{
/*
  INT   i;
  BYTE  *p;
*/

	vqt_devinfo( sysgem.vdi_handle, dev_no, open, name );

/*
  _VDIParBlk.contrl [0] = 248;
  _VDIParBlk.contrl [1] = 0;
  _VDIParBlk.contrl [3] = 1;
  _VDIParBlk.contrl [6] = sysgem.vdi_handle;
  _VDIParBlk.intin  [0] = dev_no;

  _VDIParBlk.ptsout [1] = 0;
  _VDIParBlk.ptsout [2] = 0;
  _VDIParBlk.ptsout [3] = 0;

  vdi ( &pb );

  *open = _VDIParBlk.ptsout [0];
  p     = (BYTE *) &_VDIParBlk.ptsout [1];

  for ( i = 1; i < ( _VDIParBlk.contrl [2] * 2 ); i++ )
    {
      *name++ = *p++;
    }
  *name = 0;
*/
}

/* ------------------------------------------------------------------- */

INT StringWidth ( BYTE *text )

{
  INT   w;
  INT   pxy [10];

  if ( text [0] == 0 ) return ( 0 );

  VqtReal ( text, pxy );
  w = pxy [2] - pxy [0];
  if ( w < 0 ) w = -w;
  return ( w );
}

/* ------------------------------------------------------------------- */

INT StringHeight ( VOID )

{
  INT   h;
  INT   pxy [10];

  VqtReal ( "WjygT!()", pxy );
  h = pxy [3] - pxy [5];
  if ( h < 0 ) h = -h;
  return ( h );
}

/* ------------------------------------------------------------------- */

VOID v_xtext ( INT color, INT x, INT y, BYTE *text )

{
  REG   INT     len;
  REG   INT     minlen;
  REG   BYTE    *p;

  vst_color ( sysgem.vdi_handle, color );
  for ( len = length ( text ), p = text; len > 0; len -= 127, p += 127 )
    {
      minlen = min ( 127, len );
      strncpy ( v_output, p, minlen );
      v_output [minlen] = 0;
      if ( sysgem.act_font_vk )
        {
          v_ftext ( sysgem.vdi_handle, x, y, v_output );
        }
      else
        {
          v_gtext ( sysgem.vdi_handle, x, y, v_output );
        }
      x += StringWidth ( v_output );
    }
  vst_color ( sysgem.vdi_handle, BLACK );
}

/* ------------------------------------------------------------------- */

VOID v_stext ( INT color, INT x, INT y, BYTE *text )

{
  vst_color ( sysgem.vdi_handle, color );
  if ( sysgem.act_font_vk )
    {
      v_ftext ( sysgem.vdi_handle, x, y, text );
    }
  else
    {
      v_gtext ( sysgem.vdi_handle, x, y, text );
    }
  vst_color ( sysgem.vdi_handle, BLACK );
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

VOID output_sld ( INT color, BYTE *q, INT x, INT y, INT w, TABULAR *tab, VOID (*xx_text)( INT, INT, INT, BYTE* ))

{
  REG   BYTE    *p;
  REG   INT     i = 0;
  REG   INT     x0;
        INT     c;

  p = strchr ( q, '\t' );
  if (( p == NULL ) || ( tab [0].pos == -1 ))
    {
      xx_text ( color, x, y, q );
      return;
    }
  strcpy ( buffer, q );
  q  = buffer;
  i  = 0;
  x0 = x;
  while (( p = strtok ( q, "\t" )) != NULL )
    {
      q = NULL;
      x = 0;
      if ( tab [i].pos > 0 )
        {
          switch ( tab [i].just )
            {
              case TAB_RIGHT   : x = StringWidth ( p );
                                 x = 0 - x;
                                 break;
              case TAB_CENTER  : x = StringWidth ( p );
                                 x = 0 - ( x / 2 );
                                 break;
              case TAB_DECIMAL : q = strrchr ( p, '.' );
                                 if ( strrchr ( p, ',' ) > q ) q = strrchr ( p, ',' );
                                 if ( q != NULL )
                                   {
                                     c  = *q;
                                     *q = 0;
                                     x  = StringWidth ( p );
                                     *q = c;
                                     x  = 0 - x;
                                   }
                                 q = NULL;
                                 break;
              default          : break;
            }
          x = x + ( tab [i].pos * w );
        }
      xx_text ( color, x0 + x, y, p );
      i++;
    }
}

/* ------------------------------------------------------------------- */

INT simulate_out ( INT px, BYTE *q, INT x, INT w, TABULAR *tab )

{
  REG   BYTE    *p;
  REG   INT     i = 0;
  REG   INT     x0;
        INT     xx;
        INT     c;
        INT     pxy;
        INT     pos;
        BYTE    ch;

  if ( *q == 255 ) /* eingeb. Icon */
    {
      q += 6L;
    }
  p = strchr ( q, '\t' );
  if (( p == NULL ) || ( tab [0].pos == -1 ))
    {
      if ( px < 0 )
        {
          return ( StringWidth ( q ));
        }
      pxy = 0;
      p   = q;
      while ( *p )
        {
          ch = *p;
          *p = 0;
          if ( px <= x + StringWidth ( q ))
            {
              *p = ch;
              return ( pxy );
            }
          *p = ch;
          p++;
          pxy++;
        }
      return ( -1 );
    }
  strcpy ( buffer, q );
  q   = buffer;
  i   = 0;
  x0  = x;
  xx  = x;
  pxy = 0;
  while (( p = strtok ( q, "\t" )) != NULL )
    {
      pxy++;
      q = NULL;
      x = 0;
      if ( tab [i].pos > 0 )
        {
          switch ( tab [i].just )
            {
              case TAB_RIGHT   : x = StringWidth ( p );
                                 x = 0 - x;
                                 break;
              case TAB_CENTER  : x = StringWidth ( p );
                                 x = 0 - ( x / 2 );
                                 break;
              case TAB_DECIMAL : q = strrchr ( p, '.' );
                                 if ( strrchr ( p, ',' ) > q ) q = strrchr ( p, ',' );
                                 if ( q != NULL )
                                   {
                                     c  = *q;
                                     *q = 0;
                                     x  = StringWidth ( p );
                                     *q = c;
                                     x  = 0 - x;
                                   }
                                 q = NULL;
                                 break;
              default          : break;
            }
          x = x + ( tab [i].pos * w );
        }
      if ( px < 0 ) goto ende;
      pos = 0;
      while ( p [pos] )
        {
          ch = p [pos];
          p [pos] = 0;
          if ( px <= x + x0 + StringWidth ( p ))
            {
              p [pos] = ch;
              if ( pos == 0 ) return ( -1 );
              return ( pxy );
            }
          p [pos] = ch;
          pos++;
          pxy++;
        }
      if ( px <= x + x0 + StringWidth ( p ))
        {
          return ( pxy );
        }
      ende:
      xx = x + x0 + StringWidth ( p );
      i++;
    }
  if ( px < 0 ) return ( xx );
  return ( -1 );
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

INT CenterY ( INT y1, INT y2 )

{
  REG   INT     y;

  y  = y2 - y1;
  y /= 2;
  y += y1;
  y  = y - ( sysgem.act_font_ch / 2 );
  y++;
  return ( y );
}

/* ------------------------------------------------------------------- */

INT CenterX ( INT x1, INT x2, BYTE *text )

{
  REG   INT     x;
  REG   INT     len;

  len = StringWidth ( text );
  x  = x2 - x1;
  x /= 2;
  x += x1;
  x  = x - ( len / 2 );
  x++;
  return ( x );
}

/* ------------------------------------------------------------------- */

VOID SendFontChanged ( INT font_id, INT font_pt )

{
  WINDOW        *win;
  INT           handle;

  if ( FontExists ( font_id ))
    {
      win = sysgem.window;
      while ( win != NULL )
        {
          handle = win->handle;
          SendMessage ( SG_NEWFONT, win, NULL, NULL, font_id, font_pt, 0, 0 );
          RedrawWindow ( handle );
          win = win->next;
        }
    }
}

/* ------------------------------------------------------------------- */

VOID ResetSysFont ( VOID )

{
  sysgem.font_hid = sysgem.sysfont_hid;
  SendFontChanged ( sysgem.font_hid, sysgem.font_hpt );
}

/* ------------------------------------------------------------------- */

VOID SetSysFont ( INT font_id )

{
  if ( FontExists ( font_id ))
    {
      SetFont ( font_id, sysgem.font_hpt );
      sysgem.font_hid = font_id;
      SendFontChanged ( sysgem.font_hid, sysgem.font_hpt );
    }
}

/* ------------------------------------------------------------------- */

FONT *GetFontList ( VOID )

{
  return ( sysgem.font );
}

/* ------------------------------------------------------------------- */

BOOL FontExists ( INT font_id )

{
  REG   FONT    *f;
  REG   INT     id;

  f  = sysgem.font;
  id = font_id;
  while ( f != NULL )
    {
      if ( f->id == id ) return ( TRUE );
      f = f->next;
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BYTE *GetFontName ( INT font_id )

{
  REG   FONT    *f;
  REG   INT     id;

  f  = sysgem.font;
  id = font_id;
  while ( f != NULL )
    {
      if ( f->id == id ) return ( f->name );
      f = f->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

INT GetFontId ( BYTE *font_name )

{
  REG   FONT    *f;

  f = sysgem.font;
  while ( f != NULL )
    {
      if ( strnicmp ( font_name, f->name, strlen ( font_name )) == 0 )
        {
          return ( f->id );
        }
      f = f->next;
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */

INT VectorFont ( INT font_id )

{
  REG   FONT    *f;
  REG   INT     id;

  f  = sysgem.font;
  id = font_id;
  while ( f != NULL )
    {
      if ( f->id == id ) return ( f->vektor );
      f = f->next;
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

VOID SetFont ( INT font_id, INT pt )

{
  INT   d;

  if (( sysgem.act_font_id == font_id ) && ( sysgem.act_font_pt == pt )) return;

  if ( FontExists ( font_id ))
    {
      vst_font      ( sysgem.vdi_handle, font_id );
      if ( sysgem.use_arbpt )
        {
          vst_arbpt ( sysgem.vdi_handle, pt, &d, &d, &sysgem.act_font_cw, &sysgem.act_font_ch );
        }
      else
        {
          vst_point ( sysgem.vdi_handle, pt, &d, &d, &sysgem.act_font_cw, &sysgem.act_font_ch );
        }
      vst_alignment ( sysgem.vdi_handle, 0, 5, &d, &d );

      sysgem.act_font_id = font_id;
      sysgem.act_font_pt = pt;
      sysgem.act_font_vk = VectorFont ( font_id );
    }
}

/* ------------------------------------------------------------------- */

VOID DisableArbpt ( VOID )

{
  sysgem.use_arbpt = FALSE;
}

/* ------------------------------------------------------------------- */

VOID NormalFont ( VOID )

{
  SetFont ( sysgem.font_hid, sysgem.font_hpt );
}

/* ------------------------------------------------------------------- */

VOID SmallFont ( VOID )

{
  SetFont ( sysgem.font_sid, sysgem.font_spt );
}

/* ------------------------------------------------------------------- */

/*----------------

typedef struct
  {
    long        af_magic;
    int         version;
    int         installed;
    int cdecl  (*afnt_getinfo )( int af_gtype, int *af_gout1, int *af_gout2, int *af_gout3, int *af_gout4 );
  } SGAFNT;

/* ------------------------------------------------------------------- */

LOCAL INT appl_getinfo ( INT ap_gtype, INT *ap_gout1, INT *ap_gout2, INT *ap_gout3, INT *ap_gout4 )

{
  SGAFNT        *afnt;
  AESPB aespb = { _GemParBlk.contrl,
                  _GemParBlk.global,
                  _GemParBlk.intin,
                  _GemParBlk.intout,
          (INT *) _GemParBlk.addrin,
          (INT *) _GemParBlk.addrout };

  if (( ap_gtype == 0 ) || ( ap_gtype == 1 ))
    {
      if (( GetCookie ( 'AFnt', &afnt )) && ( afnt->af_magic == 'AFnt' ))
        {
          return ( afnt->afnt_getinfo ( ap_gtype, ap_gout1, ap_gout2, ap_gout3, ap_gout4 ));
        }
    }

  _GemParBlk.intin  [0] = ap_gtype;
  _GemParBlk.contrl [0] = 130;
  _GemParBlk.contrl [1] = 1;
  _GemParBlk.contrl [2] = 5;
  _GemParBlk.contrl [3] = 0;

  _crystal ( &aespb );

  *ap_gout1 = _GemParBlk.intout [1];
  *ap_gout2 = _GemParBlk.intout [2];
  *ap_gout3 = _GemParBlk.intout [3];
  *ap_gout4 = _GemParBlk.intout [4];

  return ( _GemParBlk.intout [0] );

}


/* ------------------------------------------------------------------- */

LOCAL INT objc_sysv ( INT ob_smode, INT ob_swhich, INT ob_sival1, INT ob_sival2, INT *ob_soval1, INT *ob_soval2 )

{
  AESPB _Aespb;

  _GemParBlk.contrl [0] = 48;
  _GemParBlk.contrl [1] = 4;
  _GemParBlk.contrl [2] = 3;
  _GemParBlk.contrl [3] = 0;
  _GemParBlk.contrl [4] = 0;
  _GemParBlk.intin  [0] = ob_smode;
  _GemParBlk.intin  [1] = ob_swhich;
  _GemParBlk.intin  [2] = ob_sival1;
  _GemParBlk.intin  [3] = ob_sival2;

  _Aespb.contrl  = _GemParBlk.contrl;
  _Aespb.global  = _GemParBlk.global;
  _Aespb.intin   = _GemParBlk.intin;
  _Aespb.intout  = _GemParBlk.intout;
  _Aespb.addrin  = NULL;
  _Aespb.addrout = NULL;

  _crystal ( &_Aespb );

  *ob_soval1 = _GemParBlk.intout [1];
  *ob_soval2 = _GemParBlk.intout [2];
  return ( _GemParBlk.intout [0] );
}

-----*/

/* ------------------------------------------------------------------- */

LOCAL VOID VqtName ( INT count )

{
  FONT          *font;
  BYTE          name    [100];

  font = (FONT *) Allocate ( sizeof ( FONT ));
  if ( font == NULL ) return;

  memset ( name, 0, sizeof ( name ));
  font->id     = vqt_name ( sysgem.vdi_handle, count, name );
  font->vektor = (INT)( name [32] );
  strncpy ( font->name, name, 32L );
  InsertPtr ( &sysgem.font, font );
}

/* ------------------------------------------------------------------- */

LOCAL VOID CheckFonts ( VOID )

{
  FONT          *font;
  LONG          small;
  INT           i, d, ddh, ddw, bw, bh;
  INT           attr [12];
  BOOL          has_agi;
  TEDINFO       dum_ted = { " ", "", "", IBM, 0, TE_LEFT, 0, 0, 0, 2, 1 };
  OBJECT        dum_ob  = { 0, -1, -1, G_TEXT, LASTOB, NORMAL, 0L, 0, 0, 0, 0 };

  has_agi = FALSE;
  if (( sysgem.aes_version == 0x0399 ) && ( sysgem.magx_version >= 0x0200 ))
    {
      has_agi = TRUE;
    }
  if ( sysgem.aes_version >= 0x0400 ) has_agi = TRUE;
  if ( appl_find ( "?AGI\0\0\0\0" ) >= 0 ) has_agi = TRUE;

  if ( has_agi )
    {
      if ( appl_getinfo ( 0, &ddh, &ddw, &d, &d ) == 0 ) goto weiter;
      sysgem.font_hpt = ddh;
      sysgem.font_hid = ddw;
      if ( appl_getinfo ( 1, &ddh, &ddw, &d, &d ) == 0 ) goto weiter;
      sysgem.font_spt = ddh;
      sysgem.font_sid = ddw;
    }
  else
    {
      weiter:

      wind_update ( BEG_UPDATE );

      dum_ob.ob_width = sysgem.charw;
      dum_ob.ob_height = sysgem.charh;

      dum_ob.ob_spec.tedinfo = &dum_ted;
      dum_ted.te_font = IBM;
      objc_draw ( &dum_ob, 0, 1, 0, 0, 0, 0 );
      vqt_attributes ( sysgem.vdi_handle, attr );
      sysgem.font_hid = attr [0];

      dum_ted.te_font = SMALL;
      objc_draw ( &dum_ob, 0, 1, 0, 0, 0, 0 );
      vqt_attributes ( sysgem.vdi_handle, attr );
      sysgem.font_sid = attr [0];
      sysgem.font_spt = vst_point ( sysgem.vdi_handle, 1, &d, &d, &d, &d );

      if ( GetCookie ( 'SMAL', &small ))
        {
          if (( d = (int) ( small >> 16 )) != 0 ) sysgem.font_hid = d;
        }
      wind_update ( END_UPDATE );
    }

  i = 1;
  forever
    {
      sysgem.font_hpt = vst_point ( sysgem.vdi_handle, i, &ddw, &ddh, &bw, &bh );
      if (( bw >= sysgem.charw ) && ( bh >= sysgem.charh )) break;
      i++;
    }

  if ( vq_gdos ())
    {
      sysgem.loaded_fonts = vst_load_fonts ( sysgem.vdi_handle, 0 );
      for ( d = 1; d <= sysgem.system_fonts + sysgem.loaded_fonts; d++ )
        {
          VqtName ( d );
        }
    }
  else
    {
      font = (FONT *) Allocate ( sizeof ( FONT ));
      if ( font == NULL ) return;

      assign ( "SysGem-Font Normal", font->name );
      font->id     = sysgem.font_hid;
      font->vektor = FALSE;
      InsertPtr ( &sysgem.font, font );

      font = (FONT *) Allocate ( sizeof ( FONT ));
      if ( font == NULL ) return;

      assign ( "SysGem-Font Small", font->name );
      font->id     = sysgem.font_sid;
      font->vektor = FALSE;
      InsertPtr ( &sysgem.font, font );
    }
}

/* -------------------------------------------------------------------
 * Initialisierung
 * ------------------------------------------------------------------- */

VOID SendChanged ( VOID )

{
  WINDOW        *win;

  win = sysgem.window;
  while ( win != NULL )
    {
      if ( SendMessage ( SG_CLIPBOARD, win, NULL, NULL, 0, 0, 0, 0 ) == SG_ABORT ) return;
      win = win->next;
    }
}

/* ------------------------------------------------------------------- */

VOID SendExit ( INT id, INT res )

{
  WINDOW        *win;
  LONG          l;

  win = sysgem.window;
  l   = *(LONG *) &xevent.msg [3];
  while ( win != NULL )
    {
      if ( SendMessage ( SG_CHILDEXIT, win, NULL, &l, res, id, 0, 0 ) == SG_ABORT ) return;
      win = win->next;
    }
}

/* ------------------------------------------------------------------- */

VOID SendStart ( VOID )

{
  WINDOW        *win;
  INT           msg [8];

  msg [0] = AV_STARTED;															/* [GS] */
  msg [1] = sysgem.appl_id;
  msg [2] = 0;
  msg [3] = xevent.msg [3];
  msg [4] = xevent.msg [4];
  msg [5] = 0;
  msg [6] = 0;
  msg [7] = 0;
  win     = sysgem.window;
  while ( win != NULL )
    {
      if ( SendMessage ( SG_NEXTSTART, win, NULL, &msg [3], 0, 0, 0, 0 ) == SG_ABORT )
        {
          break;
        }
      win = win->next;
    }
  if ( sysgem.gemini != -1 )
    {
      appl_write ( sysgem.gemini, 16, msg );
      evnt_timer  ( 5, 0 );
    }
}

/* ------------------------------------------------------------------- */

VOID SendAVProtokoll ( VOID )

{
  INT   msg [8];

  if ( sysgem.gemini != -1 )
    {
      memset  ( sysgem.global_mem, 0, 1024L );
      strncpy ( sysgem.global_mem, sysgem.prg_name, 8L );

      msg [0] = AV_PROTOKOLL;
      msg [1] = sysgem.appl_id;
      msg [2] = 0;
      msg [3] = 1 | 2 | 4 | 8;
      msg [4] = 0;
      msg [5] = 0;
      msg [6] = (INT)((LONG)( sysgem.global_mem ) >> 16 );
      msg [7] = (INT)((LONG)( sysgem.global_mem ) >>  0 );
      appl_write ( sysgem.gemini, 16, msg );
      evnt_timer  ( 5, 0 );
    }
}

/* ------------------------------------------------------------------- */

VOID SendToGemini ( INT what, INT handle )

{
  INT   msg [8];

  if ( sysgem.gemini != -1 )
    {
      msg [0] = what;
      msg [1] = sysgem.appl_id;
      msg [2] = 0;
      msg [3] = handle;
      msg [4] = 0;
      msg [5] = 0;
      msg [6] = 0;
      msg [7] = 0;
      appl_write ( sysgem.gemini, 16, msg );
      evnt_timer  ( 5, 0 );
    }
}

/* ------------------------------------------------------------------- */

VOID ClipboardChanged ( VOID )

{
  INT   id;
  INT   typ;
  INT   ret;
  INT   ids     [100];
  INT   i;
  INT   msg       [8];
  BYTE  name    [128];

  for ( i = 0; i < 100; i++ ) ids [i] = -1;
  if ( sysgem.aes_version >= 0x0399 )
    {
      ret = 0;
      i   = 0;
      forever
        {
          ret = appl_search ( ret, name, &typ, &id );
          ids [i] = id;
          if ( ret == 0 ) break;
          ret = 1;
          i++;
        }
      msg [0] = SC_CHANGED;
      msg [1] = sysgem.appl_id;
      msg [2] = 0;
      msg [3] = 0x0002;
      msg [4] = '.T';
      msg [5] = 'XT';
      msg [6] = 0;
      msg [7] = 0;
      for ( i = 0; i < 100; i++ )
        {
          if (( ids [i] != -1 ) && ( ids [i] != sysgem.appl_id ))
            {
              appl_write ( ids [i], 16, msg );
              evnt_timer ( 5, 0 );
            }
        }
      assign ( sysgem.clipboard_path, sysgem.global_mem );
      msg [0] = AV_PATH_UPDATE;
      msg [1] = sysgem.appl_id;
      msg [2] = 0;
      msg [3] = (INT)((LONG)( sysgem.global_mem ) >> 16 );
      msg [4] = (INT)((LONG)( sysgem.global_mem ) >>  0 );
      msg [5] = 0;
      msg [6] = 0;
      msg [7] = 0;
      if ( sysgem.gemini != -1 )
        {
          appl_write ( sysgem.gemini, 16, msg );
          evnt_timer ( 5, 0 );
        }
      SendChanged ();
    }
}

/* ------------------------------------------------------------------- */

INT SearchProgram ( BYTE *prg_name )

{
  LONG  len;
  INT   id;
  INT   typ;
  INT   ret;
  BYTE  name    [128];

  if ( sysgem.aes_version >= 0x0399 )
    {
      len = strlen ( prg_name );
      ret = 0;
      forever
        {
          ret = appl_search ( ret, name, &typ, &id );
          if ( strnicmp ( prg_name, name, len ) == 0 ) return ( id );
          if ( ret == 0 ) break;
          ret = 1;
        }
    }
  else
    {
      sprintf ( name, "%-8.8s", prg_name );
      ret = appl_find ( name );
      if ( ret >= 0 ) return ( ret );
    }
  return ( -1 );
}

/* ------------------------------------------------------------------- */
/* [GS] komplett Åberarbeitet																					 */

INT SearchServer ( VOID )

{
	BYTE *server;
	BYTE such[10];
	INT i;
	INT av_server=-1;

	server=getenv("AVSERVER");
	if(server)
	{
		for ( i=0; i<8; i++ )
			such[i] = ' ';
		such[8] = '\0';

		for( i=0; i<8 && server[i]; i++)
		{
			if ( server[i] )
				such[i] = server[i];
		}
		such[8] = '\0';

		av_server = appl_find ( such );
	}

	if(av_server<0) av_server = appl_find ("JINNEE  " );
	if(av_server<0) av_server = appl_find ("GEMINI  " );
	if(av_server<0) av_server = appl_find ("THING   " );
	if(av_server<0) av_server = appl_find ("EASE    " );
	if(av_server<0) av_server = appl_find ("AVSERVER" );
	if(av_server<0) av_server = appl_find ("MAGXDESK" );
	if(av_server<0) av_server = appl_find ("DESKTOP " );		/* Tera Desktop */
	if(av_server<0) av_server=-1;

  return ( av_server );
}

/* ------------------------------------------------------------------- */

VOID DisableGemini ( VOID )

{
  sysgem.gemini = -1;
}

/* ------------------------------------------------------------------- */

VOID MakeStartup ( VOID )

{
  sysgem.gemini = SearchServer ();
  SendAVProtokoll ();
  SendToGemini ( AV_ASKCONFONT, 0 );
}

/* ------------------------------------------------------------------- */

VOID MakeExit ( VOID )

{
  sysgem.gemini = SearchServer ();
  SendToGemini ( AV_EXIT, sysgem.appl_id );
}

/* ------------------------------------------------------------------- */
/* Funktion komplett [GS]																							 */

INT MagiCPCVersion ( VOID )

{
	return GetCookie ( 'MgPC', NULL );
}
/* ------------------------------------------------------------------- */

VOID MagiCVersion ( INT *version, INT *revision )

{
  MAGX_COOKIE   *magx;
  LONG          value;

  *revision = 0;
  *version  = 0;
  magx = GetCookie ( 'MagX', &value ) ? (MAGX_COOKIE *) value : NULL;
  if ( magx != NULL )
    {
      if ( magx->aesvars != NULL )
        {
          if ( magx->aesvars->version >= 0x0200 )
            {
              *revision = magx->aesvars->release;
            }
          *version = magx->aesvars->version;
        }
    }
}

/* ------------------------------------------------------------------- */

INT NVDIVersion ( VOID )

{
  LONG  value;
  NVDI  *nvdi;

  if ( GetCookie ( 'NVDI', &value ))
    {
      nvdi = (NVDI *) value;
      if ( nvdi != NULL )
        {
          return ( nvdi->version );
        }
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT WinxVersion ( VOID )

{
  WINX_COOKIE   *c;
  LONG          v;
  INT           dummy;

  if ( wind_get ( 0, 'WX', &dummy, &dummy, &dummy, &dummy ) == 'WX' )
    {
      if ( GetCookie ( 'WINX', &v ))
        {
          c = (WINX_COOKIE *) v;
          return ( c->version );
        }
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT MiNTVersion ( VOID )

{
  LONG  value;

  if ( GetCookie ( 'MiNT', &value ))
    {
      return ((INT)( value ));
    }
  return ( 0 );
}

/* ------------------------------------------------------------------- */

LOCAL LONG TOSVersion ( VOID )

{
  UINT          os;
  SYSHDR        *sys;


  sys = *((SYSHDR **) 0x04f2L );
  sys = sys->os_base;
  os  = sys->os_version;
 return ((LONG)( os ));
}

/* ------------------------------------------------------------------- */

VOID GetClipboard ( VOID )

{
  BYTE  scrap_name []   = "SCRAP.TXT";
  BYTE  *p;
  INT   i;

  memset ( &sysgem.clipboard, 0, sizeof ( sysgem.clipboard ));
  memset ( &sysgem.clipboard_path, 0, sizeof ( sysgem.clipboard_path ));
  i = scrp_read ( sysgem.clipboard_path );
  if ( i != 0 )
    {
      if ( length ( sysgem.clipboard_path ) > 1 )
        {
          p = strchr ( sysgem.clipboard_path, 0 );
          p--;
          if ( *p != '\\' )
            {
              append ( "\\", sysgem.clipboard_path );
            }
          assign ( sysgem.clipboard_path, sysgem.clipboard );
          append ( scrap_name, sysgem.clipboard );
          return;
        }
    }
}

/* ------------------------------------------------------------------- */

LOCAL VOID cdecl get_signals ( LONG sig )

{
  TerminateSysGem ();
}

/* ------------------------------------------------------------------- */

LOCAL VOID cdecl get_void ( LONG sig )

{
}

/* ------------------------------------------------------------------- */

#define         DEF_WINW    80
#define         DEF_WINH    80

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

VOID InstallIconify ( VOID )

{
  INT   i, d;


  sysgem.iconify = ICONIFY_ICFS;

  d = ( sysgem.aes_version == 0x0399 ) || ( sysgem.aes_version >= 0x0410 );
  if ( ! d )
    {
      return;
    }

  appl_getinfo ( 11, &i, &d, &d, &d );
  if (( i & ( 1 << 7 )) != 0 )
    {
      if (( i & ( 1 << 8 )) != 0 )
        {
          appl_getinfo ( 12, &i, &d, &d, &d );
          if (( i & ( 1 << 7 )) != 0 )
            {
              if (( i & ( 1 << 8 )) != 0 )
                {
                  if (( i & ( 1 << 9 )) != 0 )
                    {
                      sysgem.iconify = ICONIFY_AES;
                    }
                }
            }
        }
    }
}

/* ------------------------------------------------------------------- */

INT CDECL default_server ( INT type, ... )

{
  va_list       pp;
  INT           bitpos, x, *c, ret = -1;
  ULONG         mask               = 1L;
  LOCAL ULONG   pos                = 0L;
  LOCAL RECT    pmax;

  va_start ( pp, type );

  if (( type != ICFS_GETPOS ) && ( type != ICFS_FREEPOS ))
    {
      ret = -32;
      goto icf_ende;
    }

  if ( pos == 0L )
    {
      pmax.x = sysgem.desk.x;
      pmax.y = sysgem.desk.y;
      pmax.w = sysgem.desk.w;
      pmax.h = sysgem.desk.h;
    }
  if ( type == ICFS_GETPOS )
    {
      bitpos = 0;
      x = pmax.x;
      do
        {
          if (( pos & mask ) == 0L )
            {
              pos |= mask;
              ret  = bitpos + 1;
              break;
            }
          bitpos++;
          x += DEF_WINW;
          mask <<= 1;
        }
      while (( bitpos < 32 ) && ( x + DEF_WINW <= pmax.x + pmax.w ));
      if ( ret > 0 )
        {
          c  = va_arg ( pp, int * );
          *c = x;
          c  = va_arg ( pp, int * );
          *c = pmax.y + pmax.h - DEF_WINH - 2;
          c  = va_arg ( pp, int * );
          *c = DEF_WINW - 2;
          c  = va_arg ( pp, int * );
          *c = DEF_WINH - 2;
        }
    }
  if ( type == ICFS_FREEPOS )
    {
      bitpos = va_arg ( pp, int ) - 1;
      if (( bitpos >= 0 ) && ( bitpos <= 31 ))
        {
          if ( bitpos > 0 ) mask <<= bitpos;
          pos &= ~mask;
          ret = 0;
        }
    }
  icf_ende:
  va_end ( pp );
  return ( ret );
}

/* ------------------------------------------------------------------- */

VOID FindICFS ( VOID )

{
  VOID  *p;
  INT   d;

  sysgem.icfs_server  = default_server;
  sysgem.icfs_version = 0;
  if ( GetCookie ( 'ICFS', &p ))
    {
      if ( p != NULL )
        {
          sysgem.icfs_server  = p;
          sysgem.icfs_version = sysgem.icfs_server ( 0, &d, &d );
        }
    }
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

LOCAL VOID GetParameter ( VOID )

{
  sysgem.param.vdi_handle   = sysgem.vdi_user;
  sysgem.param.charw        = sysgem.charw;
  sysgem.param.charh        = sysgem.charh;
  sysgem.param.boxw         = sysgem.boxw;
  sysgem.param.boxh         = sysgem.boxh;
  sysgem.param.acc_entry    = sysgem.acc;
  sysgem.param.appl_id      = sysgem.appl_id;
  sysgem.param.xmax         = sysgem.xmax + 1;
  sysgem.param.ymax         = sysgem.ymax + 1;
  sysgem.param.desktop.x    = sysgem.desk.x;
  sysgem.param.desktop.y    = sysgem.desk.y;
  sysgem.param.desktop.w    = sysgem.desk.w;
  sysgem.param.desktop.h    = sysgem.desk.h;
  sysgem.param.aes_version  = sysgem.aes_version;
  sysgem.param.tos_version  = sysgem.tos_version;
  sysgem.param.bitplanes    = sysgem.bitplanes;
  sysgem.param.multitask    = sysgem.multitasking;
  sysgem.param.max_colors   = sysgem.max_color;
  sysgem.param.act_colors   = sysgem.act_color;
  sysgem.param.color_avail  = sysgem.act_color > 2;
  sysgem.param.magx         = sysgem.magx_version;
  sysgem.param.magx_rel     = sysgem.magx_revision;
  sysgem.param.mint         = sysgem.mint_version;
  sysgem.param.winx         = sysgem.winx_version;
  sysgem.param.search       = sysgem.aes_version >= 0x0399;
  sysgem.param.agi          = AGI_0;
  sysgem.param.AVServer			= sysgem.gemini;
  sysgem.param.icfs         = sysgem.icfs_version;
  sysgem.param.backcol			= sysgem.lwhite;
  sysgem.param.acticol			= sysgem.lblack;
  sysgem.param.syspt				= sysgem.font_hpt;

  if ( sysgem.param.aes_version >= 0x0340 ) sysgem.param.agi = AGI_3;
  if ( sysgem.param.aes_version >= 0x0410 ) sysgem.param.agi = AGI_4;
  if ( sysgem.param.magx        >= 0x0200 ) sysgem.param.agi = AGI_4;
  if ( appl_find ( "?AGI" )     >= 0      ) sysgem.param.agi = AGI_4;
}

/* ------------------------------------------------------------------- */

VOID SetKey ( LONG l1, LONG l2 )

{
  sysgem.key1   = l1;
  sysgem.key2   = l2;
}

/* ------------------------------------------------------------------- */

#ifndef EXTOB

/* ------------------------------------------------------------------- */

LOCAL INT InitAccessory ( VOID )

{
  INT   acc;

  if ( sysgem.app == 0 )
    {
      if ( length ( sysgem.acc_name ) > 0 )
        {
          acc = menu_register ( sysgem.appl_id, sysgem.acc_name );
          if ( acc >= 0 )
            {
              return ( acc );
            }
        }
      forever
        {
          evnt_timer ( 1000, 0 );
        }
    }
  return ( -2 );
}

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */
/* Ermittelt Farben fÅr 3D- Darstellung																 */
/* sysgem.lwhite	: Farbe des 3D Hintergrund													 */
/* sysgem.lblack	: Farbe nicht-selektierter Aktivatoren							 */

VOID GetsyColors ( VOID )

{
  INT   lw, lb, i;

  if ( sysgem.aes_version >= 0x0340 )
    {
      if ( objc_sysvar ( 0, 5, 0, 0, &lw, &i ) != 0 )
        {
          if ( objc_sysvar ( 0, 4, 0, 0, &lb, &i ) != 0 )
            {
              sysgem.lwhite = lw;
              sysgem.lblack = lb;
            }
        }
    }
}

/* ------------------------------------------------------------------- */

#include        "get_mch.c"
#include        "get_cpu.c"

/* ------------------------------------------------------------------- */

INT InitGem ( BYTE *acc_name, LONG prg_id, BYTE *prg_name )

{
	INT		ag1, ag2, ag3, ag4;																/* [GS] */
  INT   work_in   [15];
  INT   work_out  [60];
  INT   i;


  memset ( &sysgem, 0, sizeof ( sysgem ));
  InitSgSystem ();
  Init16System ();
#ifndef EXTOB
	#ifndef RSMOVL
	  InitBlub ();
	#endif
#endif


  strncpy ( sysgem.acc_name, acc_name, 38L );
  strncpy ( sysgem.prg_name, prg_name, 38L );
  strncpy ( sysgem.win_name, "Hinweis", 38L );
  sysgem.prg_id = prg_id;

#ifndef RSMOVL
  if (( sysgem.appl_id = appl_init ()) >= 0 )
    {
      for ( i = 0; i < 15; i++ )
        {
          work_in [i] = 1;
        }
      work_in [10] = 2;
#endif

      sysgem.aes_version    = _GemParBlk.global [ 0];
      sysgem.multitasking   = _GemParBlk.global [ 1] != 1;


#if defined(EXTOB) || defined(RSMOVL)
      sysgem.app            = 1;
      sysgem.acc            = -2;
#else
      sysgem.app            = _app;
      sysgem.acc            = InitAccessory ();
#endif

      wind_get ( 0, WF_WORKXYWH, &sysgem.desk.x, &sysgem.desk.y, &sysgem.desk.w, &sysgem.desk.h );

      sysgem.vdi_user       = graf_handle ( &sysgem.charw, &sysgem.charh, &sysgem.boxw, &sysgem.boxh );
      sysgem.vdi_handle     = sysgem.vdi_user;

      v_opnvwk ( work_in, &sysgem.vdi_handle, work_out );
      if ( sysgem.vdi_handle <= 0 )
        {
#ifndef RSMOVL
          TerminateSysGem ();
#endif
          return ( 0 );
        }

      sysgem.xmax           = work_out [ 0];
      sysgem.ymax           = work_out [ 1];
      sysgem.system_fonts   = work_out [10];
      sysgem.act_color      = work_out [13];
      sysgem.max_color      = work_out [39];

      vq_extnd ( sysgem.vdi_handle, 1, work_out );
      sysgem.bitplanes      = work_out [4];

      v_opnvwk ( work_in, &sysgem.vdi_user, work_out );
      if ( sysgem.vdi_user <= 0 )
        {
#ifndef RSMOVL
          TerminateSysGem ();
#endif
          return ( 0 );
        }

      vswr_mode     ( sysgem.vdi_handle, MD_REPLACE );
      vst_rotation  ( sysgem.vdi_handle, 0 );
      vst_color     ( sysgem.vdi_handle, BLACK );
      vst_effects   ( sysgem.vdi_handle, 0 );
      vst_alignment ( sysgem.vdi_handle, 0, 5, &i, &i );
      vsl_type      ( sysgem.vdi_handle, SOLID );
      vsl_width     ( sysgem.vdi_handle, 1 );
      vsl_color     ( sysgem.vdi_handle, BLACK );
      vsl_ends      ( sysgem.vdi_handle, LE_SQUARED, LE_SQUARED );

#ifndef RSMOVL

      if ( sysgem.app )
        {
          xevent.event      = MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON;
        }
      else
        {
          xevent.event      = MU_MESAG | MU_TIMER;
        }
      xevent.xclicks        = 0x0102;
      xevent.xmask          = 0x0003;
      xevent.xstate         = 0x0000;
      xevent.watch1         = 0;
      xevent.watch1r.x      = 0;
      xevent.watch1r.y      = 0;
      xevent.watch1r.w      = 0;
      xevent.watch1r.h      = 0;
      xevent.watch2         = 0;
      xevent.watch2r.x      = 0;
      xevent.watch2r.y      = 0;
      xevent.watch2r.w      = 0;
      xevent.watch2r.h      = 0;
      xevent.tim_lo         = 100;
      xevent.tim_hi         = 0;
      xevent.mwich          = 0;
      xevent.x              = 0;
      xevent.y              = 0;
      xevent.state          = 0;
      xevent.kstate         = 0;
      xevent.key            = 0;
      xevent.clicks         = 0;

	#ifndef EXTOB
      Psignal ( SIGTERM, get_signals );
      Psignal ( SIGABRT, get_signals );
      Psignal ( SIGQUIT, get_signals );
      Psignal ( SIGUSR1, get_void    );
      Psignal ( SIGUSR2, get_void    );
      Psignal ( SIGPIPE, get_void    );
	#endif
#endif

      pb.contrl             = &_VDIParBlk.contrl [0];
      pb.intin              = &_VDIParBlk.intin  [0];
      pb.ptsin              = &_VDIParBlk.ptsin  [0];
      pb.intout             = &_VDIParBlk.intout [0];
      pb.ptsout             = &_VDIParBlk.ptsout [0];

			sysgem.magicpc_version = MagiCPCVersion ();												/* [GS] */
      MagiCVersion ( &sysgem.magx_version, &sysgem.magx_revision );
      sysgem.nvdi_version = NVDIVersion ();
      sysgem.winx_version = WinxVersion ();
      sysgem.mint_version = MiNTVersion ();
      sysgem.tos_version  = (INT) Supexec ( TOSVersion );

			if( appl_find( "?AGI" ) == 0 )			/* appl_getinfo() vorhanden?     [GS] */
			{																																  /* [GS] */
				if( appl_getinfo(7,&ag1,&ag2,&ag3,&ag4) )	/* Unterfunktion 7  		 [GS] */
				{											 																					/* [GS] */
					if( ( ag1 & 0x17 ) == 0x17 )	  /* WDialog vorhanden? 				 	 [GS]	*/
						sysgem.wdialog=TRUE;																				/* [GS] */
				}												 																				/* [GS] */
			}											 																						/* [GS] */

      sysgem.form         = form_alert;

#ifndef EXTOB
	#ifndef RSMOVL
      GetClipboard ();
      FindICFS ();
      InstallIconify ();
	#endif
#endif

      if (( sysgem.nvdi_version >= 0x0300 ) || ( GetCookie ( '_SPD', NULL ) == TRUE ))
        {
          sysgem.use_arbpt      = TRUE;
        }

      sysgem.center             = TRUE;
      sysgem.like_mac           = TRUE;

      sysgem.shortcut_color     = RED;
      sysgem.frametext_color    = RED;

      sysgem.icon_ausr          = GREEN;
      sysgem.icon_frag          = YELLOW;
      sysgem.icon_stop          = RED;

      sysgem.mono_ausr          = BLACK;
      sysgem.mono_frag          = BLACK;
      sysgem.mono_stop          = BLACK;

      sysgem.selb_color         = BLACK;
      sysgem.selt_color         = WHITE;

      sysgem.lwhite             = LWHITE;
      sysgem.lblack             = LWHITE;

      sysgem.help_count         = 5;
      sysgem.help_color         = WHITE;

      sysgem.check_logfont      = TRUE;
      sysgem.allow_change	= TRUE;

      if ( sysgem.act_color >= 16 )
        {
          sysgem.selb_color     = RED;
          sysgem.selt_color     = BLACK;
          sysgem.help_color     = YELLOW;
        }

      GetsyColors ();


      if ( sysgem.mint_version != 0 )
        {
          sysgem.global_mem = Mxalloc ( 1024L, 0x22 );
          if ( sysgem.global_mem == NULL ) return ( 0 );

          sysgem.gs_info  = Mxalloc ( sizeof ( GS_INFO ), 0x22 );
          if ( sysgem.gs_info  == NULL ) return ( 0 );

          sysgem.gs_buffer  = Mxalloc ( 4096L, 0x22 );
          if ( sysgem.gs_buffer  == NULL ) return ( 0 );
        }
      else
        {
          sysgem.global_mem = Malloc ( 1024L );
          if ( sysgem.global_mem == NULL ) return ( 0 );

          sysgem.gs_info  = Malloc ( sizeof ( GS_INFO ));
          if ( sysgem.gs_info  == NULL ) return ( 0 );

          sysgem.gs_buffer  = Malloc ( 4096L );
          if ( sysgem.gs_buffer  == NULL ) return ( 0 );
        }
      memset ( sysgem.global_mem, 0, 1024L );
      memset ( sysgem.gs_info,    0, sizeof ( GS_INFO ));
      memset ( sysgem.gs_buffer,  0, 4096L );

      sysgem.gs_info->len	= sizeof ( GS_INFO );
      sysgem.gs_info->version   = 0x0100;
      sysgem.gs_info->msgs	= 0x0001;
      sysgem.gs_info->ext	= 0L;

#ifndef RSMOVL
      if ( sysgem.magx_version >= 0x0300 )
        {
          shel_write ( 9, 0, 0, NULL, NULL );
        }
#endif

#ifdef EXTOB
      nkc_init ( 0x00000004UL, 0, NULL );
#else
	#ifndef RSMOVL
      nkc_init ( 0x00000004UL, 0, NULL );
  #endif
#endif

      CheckFonts ();

      if ( FontExists ( sysgem.font_hid ) == FALSE ) sysgem.font_hid = 1;
      if ( FontExists ( sysgem.font_sid ) == FALSE ) sysgem.font_sid = 1;

      sysgem.sysfont_hid = sysgem.font_hid;
      sysgem.sysfont_hpt = sysgem.font_hpt;

      sysgem.confont_hid = sysgem.font_hid;
      sysgem.confont_hpt = sysgem.font_hpt;

#ifndef RSMOVL
/* Remove since Version 2.51 [GS]
      if ( crc_32 ( sccs0, 40L ) != 0xced9392fL ) TerminateSysGem ();
*/
#endif


      SmallFont ();
      NormalFont ();
      SetClipping ( NULL );
      Enable3D ();


#ifdef PASCAL
#include "pas_rsc.h"
#endif

/*
{
  FILE *f;

      f = fopen ( "E:\\PURE_C\\SYS_GEM3\\PAS_RSC.H", "w" );
      for ( i = 0; i < NUM_OBS; i++ )
        {
          fprintf ( f, "rs_object [%2d].ob_x     = %4d;\n", i, rs_object [i].ob_x );
          fprintf ( f, "rs_object [%2d].ob_y     = %4d;\n", i, rs_object [i].ob_y );
          fprintf ( f, "rs_object [%2d].ob_w     = %4d;\n", i, rs_object [i].ob_w );
          fprintf ( f, "rs_object [%2d].ob_h     = %4d;\n", i, rs_object [i].ob_h );
          fprintf ( f, "rs_object [%2d].ob_flags = %4d;\n", i, rs_object [i].ob_flags );
          fprintf ( f, "rs_object [%2d].ob_state = %4d;\n", i, rs_object [i].ob_state );
          fprintf ( f, "rs_object [%2d].ob_type  = %4d;\n", i, rs_object [i].ob_type );
        }
      fclose ( f );
}
*/

#ifndef RSMOVL
      MakeStartup ();
      InitResource ( rs_object, NUM_OBS, NUM_TREE, NULL, FALSE );

      SetXTimer ( 'xcrs', Cursor, 500, 0, NULL, NULL );
	#ifndef EXTOB
      SetXTimer ( 'blux', CheckBlub, 200, 0, NULL, NULL );
	#endif
#endif

#ifndef RSMOVL
      if ( NewDialog ( rsc_icon     ) == FALSE ) return ( 0 );
      if ( NewDialog ( rsc_listbox  ) == FALSE ) return ( 0 );
      if ( NewDialog ( rsc_msg      ) == FALSE ) return ( 0 );
      if ( NewDialog ( rsc_cycle    ) == FALSE ) return ( 0 );
      if ( NewDialog ( rsc_font     ) == FALSE ) return ( 0 );
      if ( NewDialog ( rsc_stat     ) == FALSE ) return ( 0 );

      sysgem.new_dial  = FALSE;

      sysgem.listbox   = rsc_listbox;
      sysgem.cycle_win = rsc_cycle;
      sysgem.fontsel   = rsc_font;

      graf_mouse ( ARROW, NULL );
#endif

      GetParameter ();
      UseRoundButtons ( TRUE );
      SetOwner ( sysgem.prg_id );

      return ( 1 );
#ifndef RSMOVL
    }

  return ( 0 );
#endif
}

/* ------------------------------------------------------------------- */

BOOL DelDialog ( OBJECT *tree )

{
  DIALOG_SYS    *dial;
  USERB         *ub;
  OBJECT        *tr;

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  while ( dial->slider != NULL )
    {
      DeletePtr ( &dial->slider, dial->slider );
    }
  while ( dial->redraw != NULL )
    {
      DeletePtr ( &dial->redraw, dial->redraw );
    }
  ub = dial->user;
  tr = dial->tree;
  while ( ub != NULL )
    {
      tr [ub->obj].ob_spec.index = ub->parm;
      tr [ub->obj].ob_type       = ub->ext;
      tr [ub->obj].ob_type     <<= 8;
      tr [ub->obj].ob_type      |= ub->typ;
      ub = ub->next;
    }
  while ( dial->user != NULL )
    {
      DeletePtr ( &dial->user, dial->user );
    }
  DeletePtr ( &sysgem.dialog, dial );
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

VOID ExitGem ( VOID )

{
#ifndef RSMOVL
  CloseAllWindows ( TRUE );

  if ( sysgem.term_module != NULL )
    {
      while ( sysgem.module != NULL )
        {
          sysgem.term_module ( sysgem.module->name );
        }
    }

  TerminateSysGem ();
  MakeExit ();
#endif

  if ( sysgem.loaded_fonts > 0 )
    {
      vst_unload_fonts ( sysgem.vdi_handle, 0 );
    }

  while ( sysgem.font != NULL )
    {
      DeletePtr ( &sysgem.font, sysgem.font );
    }
  while ( sysgem.xtimer != NULL )
    {
      DeletePtr ( &sysgem.xtimer, sysgem.xtimer );
    }
  while ( sysgem.pini != NULL )
    {
      Dispose ( sysgem.pini->keyword );
      Dispose ( sysgem.pini->value   );
      DeletePtr ( &sysgem.pini, sysgem.pini );
    }
  while ( sysgem.dialog != NULL )
    {
      DelDialog ( sysgem.dialog->tree );
    }

  v_clsvwk ( sysgem.vdi_user   );
  v_clsvwk ( sysgem.vdi_handle );

  Mfree ( sysgem.global_mem );
  Mfree ( sysgem.gs_info    );
  Mfree ( sysgem.gs_buffer  );

#ifndef RSMOVL
  nkc_exit ();
  appl_exit ();
#endif
}

/* ------------------------------------------------------------------- */
