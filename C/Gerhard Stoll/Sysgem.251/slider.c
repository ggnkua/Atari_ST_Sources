/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;
EXTERN  RECT    sg_clip_r;
LOCAL	INT	sc_pos		= 0;
LOCAL	BOOL	all_selected	= FALSE;
EXTERN	BOOL	sg_sldforone;

/* ------------------------------------------------------------------- */

SLIDER *find_slider ( DIALOG_SYS *dial, INT box )

{
  SLIDER        *sld;

  sld = dial->slider;
  while ( sld != NULL )
    {
      if (( sld->tree == dial->tree ) && ( sld->box == box ))
        {
          return ( sld );
        }
      sld = sld->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

SLIDER *xfind_slider ( OBJECT *tree, INT box, RECT *r )

{
  DIALOG_SYS    *dial;
  SLIDER        *sld;
  RECT          v;

  sld = NULL;
  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( NULL );

  sld = find_slider ( dial, box );
  if ( sld == NULL ) return ( NULL );

  if ( r != NULL )
    {
      CalcArea ( tree, box, &v );
      v.x += 1;
      v.y += 1;
      v.w -= 2;
      v.h -= 2;

      r->x = v.x;
      r->y = v.y;
      r->w = v.w;
      r->h = v.h;
    }
  return ( sld );
}

/* ------------------------------------------------------------------- */

VOID CalcSliderPos ( SLIDER *sld, BOOL draw )

{
  RECT  r;
  LONG  h;
  LONG  p;
  LONG  v;
  LONG  m;
  INT   new;
  BOOL  dr;

  dr = FALSE;
  CalcArea ( sld->tree, sld->box, &r );

  /* Gr”že des Sliders berechnen */

  m = (LONG)( sld->max_ver ) * (LONG)( sld->chh );
  if ( m <= (LONG)( r.h ))
    {
      if ( sld->hide > 0 )
        {
          sld->tree [sld->show].ob_y = 0;
          new = sld->tree [sld->hide].ob_height;
        }
    }
  else
    {
      if ( sld->hide > 0 )
        {
          if ( m == 0L ) m = 1L;
          v = (LONG)( r.h ) * 100L / m;
          v = v * (LONG)( sld->tree [sld->hide].ob_height ) / 100L;
          if ( v < (LONG)( sysgem.boxh )) v = (LONG)( sysgem.boxh );
          if ( v > (LONG)( sld->tree [sld->hide].ob_height )) v = (LONG)( sld->tree [sld->hide].ob_height );
          new = (INT)( v );
        }
    }

  if ( new != sld->tree [sld->show].ob_height )
    {
      sld->tree [sld->show].ob_height = new;
      dr = TRUE;
    }

  /* Position berechnen */

  m = (LONG)( sld->max_ver ) * (LONG)( sld->chh );
  m = m - (LONG)( r.h );
  p = (LONG)( sld->tree [sld->hide].ob_height - sld->tree [sld->show].ob_height );
  h = (LONG)( sld->pos ) * (LONG)( sld->chh );

  h = h * p / (( m == 0L ) ? 1L : m );
  new = (INT)( h );
  if ( new + sld->tree [sld->show].ob_height > sld->tree [sld->hide].ob_height )
    {
      new = sld->tree [sld->hide].ob_height - sld->tree [sld->show].ob_height;
    }

  if ( new != sld->tree [sld->show].ob_y )
    {
      sld->tree [sld->show].ob_y = new;
      dr = TRUE;
    }

  if (( draw ) && ( dr ))
    {
      RedrawObj ( sld->tree, sld->hide, 1, NONE, UPD_STATE );
    }

  if ( sld->hor_hide <= 0 ) return;
  dr = FALSE;

  m = (LONG)( sld->max_hor );
  if ( m <= r.w )
    {
      if ( sld->hor_hide > 0 )
        {
          sld->tree [sld->hor_show].ob_x = 0;
          new = sld->tree [sld->hor_hide].ob_width;
        }
    }
  else
    {
      if ( sld->hor_hide > 0 )
        {
          if ( m == 0L ) m = 1L;
          v = (LONG)( r.w ) * 100L / m;
          v = v * (LONG)( sld->tree [sld->hor_hide].ob_width ) / 100L;
          if ( v < (LONG)( sysgem.boxw )) v = (LONG)( sysgem.boxw );
          if ( v > (LONG)( sld->tree [sld->hor_hide].ob_width )) v = (LONG)( sld->tree [sld->hor_hide].ob_width );
          new = (INT)( v );
        }
    }

  if ( new != sld->tree [sld->hor_show].ob_width )
    {
      sld->tree [sld->hor_show].ob_width = new;
      dr = TRUE;
    }

  /* Position berechnen */

  m = (LONG)( sld->max_hor );
  m = m - (LONG)( r.w );
  p = (LONG)( sld->tree [sld->hor_hide].ob_width - sld->tree [sld->hor_show].ob_width );
  h = (LONG)( sld->hpos );

  h = h * p / (( m == 0L ) ? 1L : m );
  new = (INT)( h );
  if ( new + sld->tree [sld->hor_show].ob_width > sld->tree [sld->hor_hide].ob_width )
    {
      new = sld->tree [sld->hor_hide].ob_width - sld->tree [sld->hor_show].ob_width;
    }

  if ( new != sld->tree [sld->hor_show].ob_x )
    {
      sld->tree [sld->hor_show].ob_x = new;
      dr = TRUE;
    }

  if (( draw ) && ( dr ))
    {
      RedrawObj ( sld->tree, sld->hor_hide, 1, NONE, UPD_STATE );
    }
}

/* ------------------------------------------------------------------- */

VOID RedrawTheSlider ( OBJECT *tree, INT box, BOOL draw )

{
  SLIDER        *sld;

  sld = xfind_slider ( tree, box, NULL );
  if ( sld == NULL ) return;

  CalcSliderPos ( sld, draw );
}

/* ------------------------------------------------------------------- */

VOID ReRedrawSliderBox ( WINDOW *win, VOID *s )

{
  RECT          r;
  SLIDER        *sld;

  if ( win );
  sld = (SLIDER *) s;
  r.x = sg_clip_r.x;
  r.y = sg_clip_r.y;
  r.w = sg_clip_r.w;
  r.h = sg_clip_r.h;

  PaintSliderbox ( sld->tree, sld->box, &r );
}

/* ------------------------------------------------------------------- */

VOID DoScrollSlider ( WINDOW *win, SLIDER *sld, INT scr , BOOL message )

{
  RECT  r;
  INT   anz_lines;
  INT   w;
  INT   old;
  BOOL  tab;

  CalcArea ( sld->tree, sld->box, &r );
  r.x += 1;
  r.y += 1;
  r.w -= 2;
  r.h -= 2;
  tab  = sld->tab [0].pos != -1;
  if (( sld->sel != -1 ) && ( sld->paint_entry == NULL )) tab = TRUE;
  anz_lines = r.h / sld->chh;

  switch ( scr )
    {
      case 100       : DoRedraw ( win, &r );
                       break;
      case 101       : MoveWinArea ( win, &r, WA_UPLINE, sld->chw, sc_pos, (( sld->tab [0].pos != -1 ) || ( sld->icons != 0 )), ReRedrawSliderBox, sld );
                       break;
      case 102       : MoveWinArea ( win, &r, WA_DNLINE, sld->chw, sc_pos, (( sld->tab [0].pos != -1 ) || ( sld->icons != 0 )), ReRedrawSliderBox, sld );
                       break;
      case 103       : MoveWinArea ( win, &r, WA_RTLINE, sc_pos, sld->chh, TRUE, ReRedrawSliderBox, sld );
                       break;
      case 104       : MoveWinArea ( win, &r, WA_LFLINE, sc_pos, sld->chh, TRUE, ReRedrawSliderBox, sld );
                       break;
      case WA_UPLINE : if ( sld->pos == 0 ) return;
                       sld->pos--;
                       MoveWinArea ( win, &r, scr, sld->chw, sld->chh, sld->tab [0].pos != -1, ReRedrawSliderBox, sld );
                       break;
      case WA_DNLINE : if (( sld->pos + anz_lines + 1 ) <= sld->max_ver )
                         {
                           sld->pos++;
                           MoveWinArea ( win, &r, scr, sld->chw, sld->chh, sld->tab [0].pos != -1, ReRedrawSliderBox, sld );
                         }
                       else
                         {
                           return;
                         }
                       break;
      case WA_RTLINE : old = sld->hpos;
                       w   = sld->hpos;
                       sld->hpos += sld->chw;
                       if (( sld->hpos + r.w ) > sld->max_hor ) sld->hpos = sld->max_hor - r.w;
                       if ( sld->hpos < 0 ) sld->hpos = 0;
                       if ( w != sld->hpos )
                         {
                           w = sld->hpos - w;
                         }
                       else
                         {
                           w = sld->chw;
                         }
                       if ( old == sld->hpos ) break;
                       MoveWinArea ( win, &r, scr, w, sld->chw, TRUE, ReRedrawSliderBox, sld );
                       break;
      case WA_LFLINE : if ( sld->hpos == 0 ) break;
                       w = sld->hpos;
                       sld->hpos -= sld->chw;
                       if ( sld->hpos < 0 ) sld->hpos = 0;
                       w = w - sld->hpos;
                       MoveWinArea ( win, &r, scr, w, sld->chw, TRUE, ReRedrawSliderBox, sld );
                       break;
      case WA_DNPAGE : old = sld->pos;
                       sld->pos += anz_lines;
                       if (( sld->pos + anz_lines ) > sld->max_ver )
                         {
                           sld->pos = sld->max_ver - anz_lines;
                           if ( sld->pos < 0 ) sld->pos = 0;
                         }
                       if ( old == sld->pos ) return;
                       if ( tab )
                         {
                           DoRedraw ( win, &r );
                         }
                       else
                         {
                           if ( win == topped ())
                             {
                               FastDrawSldBox ( sld->tree, sld->box );
                               break;
                             }
                           RedrawSliderBox ( sld->tree, sld->box );
                         }
                       break;
      case WA_UPPAGE : if ( sld->pos == 0 ) return;
                       sld->pos -= anz_lines;
                       if ( sld->pos < 0 ) sld->pos = 0;
                       if ( tab )
                         {
                           DoRedraw ( win, &r );
                         }
                       else
                         {
                           if ( win == topped ())
                             {
                               FastDrawSldBox ( sld->tree, sld->box );
                               break;
                             }
                           RedrawSliderBox ( sld->tree, sld->box );
                         }
                       break;
      case WA_LFPAGE : if ( sld->hpos == 0 ) return;
                       sld->hpos -= sld->tree [sld->box].ob_width;
                       if ( sld->hpos < 0 ) sld->hpos = 0;
                       sld->hpos = ( sld->hpos / sld->chw ) * sld->chw;
                       if ( tab )
                         {
                           DoRedraw ( win, &r );
                         }
                       else
                         {
                           RedrawSliderBox ( sld->tree, sld->box );
                         }
                       break;
      case WA_RTPAGE : old = sld->hpos;
                       sld->hpos += sld->tree [sld->box].ob_width;
                       if (( sld->hpos + r.w ) > sld->max_hor ) sld->hpos = sld->max_hor - r.w;
                       if ( sld->hpos < 0 ) sld->hpos = 0;
                       if ( old == sld->hpos ) return;
                       if ( tab )
                         {
                           DoRedraw ( win, &r );
                         }
                       else
                         {
                           RedrawSliderBox ( sld->tree, sld->box );
                         }
                       break;
      default        : return;
    }
  CalcSliderPos ( sld, TRUE );
  if ( message )														/* [GS] */
	  SendMessage(SG_SILDERMOVE,win,NULL,NULL,sld->pos,sld->box,0,0);	/* [GS] */
}

/* ------------------------------------------------------------------- */

VOID ScrollSlider ( OBJECT *tree, INT box, INT what )

{
  SLIDER        *slid;
  WINDOW        *win;

  slid = xfind_slider ( tree, box, NULL );
  if ( slid == NULL ) return;

  win = DialogInWindow ( tree );
  if ( win == NULL ) return;

  switch ( what )
    {
      case SCROLL_UP       : DoScrollSlider ( win, slid, WA_UPLINE, FALSE );  break;
      case SCROLL_DOWN     : DoScrollSlider ( win, slid, WA_DNLINE, FALSE );  break;
      case SCROLL_RIGHT    : DoScrollSlider ( win, slid, WA_RTLINE, FALSE );  break;
      case SCROLL_LEFT     : DoScrollSlider ( win, slid, WA_LFLINE, FALSE );  break;
      case SCROLL_PG_UP    : DoScrollSlider ( win, slid, WA_UPPAGE, FALSE );  break;
      case SCROLL_PG_DOWN  : DoScrollSlider ( win, slid, WA_DNPAGE, FALSE );  break;
      case SCROLL_PG_RIGHT : DoScrollSlider ( win, slid, WA_RTPAGE, FALSE );  break;
      case SCROLL_PG_LEFT  : DoScrollSlider ( win, slid, WA_LFPAGE, FALSE );  break;
      default              : return;
    }
}

/* ------------------------------------------------------------------- */

INT GetSliderItems ( OBJECT *tree, INT box )

{
  SLIDER        *slid;

  slid = xfind_slider ( tree, box, NULL );
  if ( slid == NULL ) return ( FALSE );

  return ( slid->max_ver );
}

/* ------------------------------------------------------------------- */

INT CalcLength ( SLIDER *sld )

{
  BYTE	*p;
  INT	l;
  INT	i;
  INT	x;
  
  p = sld->buf;
  l = 0;
  if ( p == NULL ) return ( 0 );
  for ( i = 0; i < sld->max_ver; i++ )
    {
      x = simulate_out ( -1, p, 0, sld->chw, &sld->tab [0] );
      l = max ( l, x );
      p += (LONG)( sld->len );
    }
  return ( l );
}


/* ------------------------------------------------------------------- */

BOOL AddSliderItem ( OBJECT *tree, INT box, INT anz_items )

{
  SLIDER        *slid;
  INT           old;

  slid = xfind_slider ( tree, box, NULL );
  if ( slid == NULL ) return ( FALSE );

  old = slid->max_ver;
  slid->max_ver += anz_items;
  if ( slid->max_ver < 0 ) slid->max_ver = 0;

  if ( slid->max_ver < old )
    {
      slid->pos -= ( old - slid->max_ver );
      if ( slid->pos < 0 ) slid->pos = 0;
    }
  slid->max_hor = CalcLength ( slid );

  CalcSliderPos ( slid, TRUE );
  RedrawSliderBox ( tree, box );

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

INT SetSliderPos ( OBJECT *tree, INT box, INT pos, BOOL draw )

{
  RECT          r;
  SLIDER        *slid;
  INT           old;
  INT           anz_lines;
  INT           v;

  slid = xfind_slider ( tree, box, &r );
  v    = -1;

  if ( slid != NULL )
    {
      anz_lines = r.h / slid->chh;
      old = slid->pos;
      if (( pos < 0 ) || ( pos == slid->pos )) return ( slid->pos );
      v = slid->pos;
      slid->pos = pos;
      if ( slid->pos + anz_lines > slid->max_ver ) slid->pos = slid->max_ver - anz_lines;
      if ( slid->pos < 0 ) slid->pos = 0;
      if ( slid->pos == old ) return ( v );
      CalcSliderPos ( slid, draw );
      if ( draw ) RedrawSliderBox ( tree, box );
    }
  return ( v );
}

/* ------------------------------------------------------------------- */

BOOL SetSliderTab ( OBJECT *tree, INT box, INT pos, INT just )

{
  SLIDER        *slid;
  REG   INT     i;

  slid = xfind_slider ( tree, box, NULL );

  if ( slid != NULL )
    {
      for ( i = 0; i < MAX_TAB; i++ )
        {
          if ( slid->tab [i].pos == -1 )
            {
              slid->tab [i].pos  = pos;
              slid->tab [i].just = just;
              slid->max_hor = CalcLength ( slid );
              CalcSliderPos ( slid, FALSE );
              return ( TRUE );
            }
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL UpdSliderTab ( OBJECT *tree, INT box, INT tab, INT pos, INT just )

{
  SLIDER        *slid;

  slid = xfind_slider ( tree, box, NULL );

  if ( slid != NULL )
    {
      if ( slid->tab [tab].pos != -1 )
        {
          slid->tab [tab].pos  = pos;
          slid->tab [tab].just = just;
          slid->max_hor = CalcLength ( slid );
          CalcSliderPos ( slid, FALSE );
          return ( TRUE );
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

VOID RealCallBack ( WINDOW *win, INT anz_lines, INT pos, BOOL vert, SLIDER *sld )

{
  LONG	p;
  LONG	p1;
  LONG	i;
  INT	old;

  if ( vert )
    {
      old = sld->pos;
      i = (LONG)( sld->tree [sld->hide].ob_height - sld->tree [sld->show].ob_height );
      if ( i == 0L ) i = 1L;
      p  = (LONG)( sld->max_ver - anz_lines );
      p1 = (LONG)( pos );
      p  = p1 * p / i;
      sld->pos = (INT)( p );
      CalcSliderPos ( sld, FALSE );
      if ( sld->pos != old )
        {
          sc_pos = sld->pos - old;
          if ( sc_pos > 0 )
            {
              if ( sc_pos >= anz_lines )
                {
                  all_selected = TRUE;
                  FastDrawSldBox ( sld->tree, sld->box );
                }
              else
                {
                  sc_pos *= sld->chh;
                  DoScrollSlider ( win, sld, 102, FALSE );			/* [GS] */
                }
            }
          else
            {
              sc_pos = -( sc_pos );
              if ( sc_pos >= anz_lines )
                {
                  all_selected = TRUE;
                  FastDrawSldBox ( sld->tree, sld->box );
                }
              else
                {
                  sc_pos *= sld->chh;
                  DoScrollSlider ( win, sld, 101, FALSE );			/* [GS] */
                }
            }
        }
    }
  else
    {
      old = sld->hpos;
      i = (LONG)( sld->tree [sld->hor_hide].ob_width - sld->tree [sld->hor_show].ob_width );
      if ( i == 0L ) i = 1L;
      p  = (LONG)( sld->max_hor - anz_lines );
      p1 = (LONG)( pos );
      p  = p1 * p / i;
      sld->hpos = (INT)( p );
      CalcSliderPos ( sld, FALSE );
      if ( sld->hpos != old )
        {
          sc_pos = sld->hpos - old;
          if ( sc_pos > 0 )
            {
              DoScrollSlider ( win, sld, 103, FALSE );					/* [GS] */
            }
          else
            {
              sc_pos = -( sc_pos );
              DoScrollSlider ( win, sld, 104, FALSE );					/* [GS]	*/
            }
        }
    }
  sc_pos = 0;
  all_selected = FALSE;
}

/* ------------------------------------------------------------------- */

VOID DoRealtimeSlider ( WINDOW *win, SLIDER *sld, OBJECT *dialptr, INT back_index, INT slider_index, INT slider_type, VOID (*call_func)( WINDOW *win, INT anz_lines, INT new_pos, BOOL hor, SLIDER *sld ))

{
  INT         m_x, m_y,
              beg_mx, beg_my,
              dial_x, dial_y,
              abs_x, abs_y,
              max_pos,
              prev_x, prev_y,
              events, _void;
  INT         anz_lines;
  RECT 	      r;

  CalcArea ( sld->tree, sld->box, &r );
  anz_lines = r.h / sld->chh;

  graf_mkstate ( &m_x, &m_y, &_void, &_void );
  beg_mx = m_x;
  beg_my = m_y;

  dial_x = dialptr [slider_index].ob_x;
  dial_y = dialptr [slider_index].ob_y;

  if ( slider_type )
    {
      if ( sld->max_ver <= anz_lines ) return;
      max_pos = dialptr [back_index].ob_height - dialptr [slider_index].ob_height;
    }
  else
    {
      if ( sld->max_hor <= r.w ) return;
      max_pos = dialptr [back_index].ob_width - dialptr [slider_index].ob_width;
    }

  graf_mouse ( FLAT_HAND, 0L );
  BeginControl ( CTL_UPDATE | CTL_MOUSE );

  objc_offset ( dialptr, back_index, &abs_x, &abs_y );

  do
    {
      prev_x = dialptr [slider_index].ob_x;
      prev_y = dialptr [slider_index].ob_y;

      events = evnt_multi ( MU_BUTTON | MU_M1, 1, 
                            1, 0, 1, 
                            m_x, m_y, 1, 
                            1, 0, 0,
                            0, 0, 0, 0L, 0, 0, 
                            &m_x, &m_y, &_void, &_void,
                            &_void, &_void );

      if ( slider_type )
        {
          dialptr [slider_index].ob_y = dial_y + m_y - beg_my;
        }
      else
        {
          dialptr [slider_index].ob_x = dial_x + m_x - beg_mx;
        }

      if ( slider_type )
        {
          dialptr [slider_index].ob_y = ( dialptr [slider_index].ob_y < 0 ) ? 0 : dialptr [slider_index].ob_y;
          dialptr [slider_index].ob_y = ( dialptr [slider_index].ob_y > max_pos ) ? max_pos : dialptr [slider_index].ob_y;
        }
      else
        {
          dialptr [slider_index].ob_x = ( dialptr [slider_index].ob_x < 0 ) ? 0 : dialptr [slider_index].ob_x;
          dialptr [slider_index].ob_x = ( dialptr [slider_index].ob_x > max_pos ) ? max_pos : dialptr [slider_index].ob_x;
        }

      if (( dialptr [slider_index].ob_y != prev_y ) || ( dialptr [slider_index].ob_x != prev_x ))
        {
          if ( slider_type )
            {
              call_func ( win, anz_lines, dialptr [slider_index].ob_y, slider_type, sld );
              if ( dialptr [slider_index].ob_y > prev_y )
                {
                  objc_draw ( dialptr, back_index, 1, abs_x, abs_y + prev_y - 1, dialptr [back_index].ob_width, dialptr [slider_index].ob_y - prev_y );
                }
              else
                {
                  objc_draw ( dialptr, back_index, 1, abs_x, abs_y + dialptr [slider_index].ob_y + dialptr [slider_index].ob_height, dialptr [back_index].ob_width, prev_y - dialptr [slider_index].ob_y + 1 );
                }
            }
          else
            {
              call_func ( win, r.w, dialptr [slider_index].ob_x, slider_type, sld );
              if ( dialptr [slider_index].ob_x > prev_x )
                {
                  objc_draw ( dialptr, back_index, 1, abs_x + prev_x - 1, abs_y, dialptr [slider_index].ob_x - prev_x, dialptr [back_index].ob_height );
                }
              else
                {
                  objc_draw ( dialptr, back_index, 1, abs_x + dialptr [slider_index].ob_x + dialptr [slider_index].ob_width, abs_y, prev_x - dialptr [slider_index].ob_x + 1, dialptr [back_index].ob_height );
                }
            }
          objc_draw ( dialptr, slider_index, 1, abs_x, abs_y + dialptr [slider_index].ob_y - 1, abs_x + dialptr [slider_index].ob_width, abs_y + dialptr [slider_index].ob_y + dialptr [slider_index].ob_height );
        }
    } while ( ! ( events & MU_BUTTON ));
  graf_mouse ( ARROW, 0L );
  EndControl ( CTL_UPDATE | CTL_MOUSE );
  SendMessage(SG_SILDERMOVE,win,NULL,NULL,sld->pos,sld->box,0,0);	/* [GS] */
}

/* --------------------------------------------------------------------------------------------------------*/

BOOL TestSliderbox ( WINDOW *win, OBJECT *tree, INT obj, INT y, INT clicks, INT *ret )

{
  DIALOG_SYS    *dial;
  SLIDER        *sld;
  RECT          r;
  INT           m, x;

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  sld = dial->slider;
  if ( sld == NULL ) return ( FALSE );

  *ret = 0;

  while ( sld != NULL )
    {
      if ( obj == sld->box )
        {
          CalcArea ( tree, obj, &r );
          r.x += 1;
          r.y += 1;
          r.w -= 2;
          r.h -= 2;
          y    = y - r.y;
          y   /= sld->chh;
          y   += 1;
          y   += sld->pos;
          if ( y <= sld->max_ver )
            {
            }
          else
            {
              y = -( y );
            }
          *ret = y;
          DelButton ();
          return ( TRUE );
        }
      if ( obj == sld->up )
        {
          if ( clicks != 1 ) return ( TRUE );
          DoScrollSlider ( win, sld, WA_UPLINE, TRUE );
          return ( TRUE );
        }
      if ( obj == sld->dn )
        {
          if ( clicks != 1 ) return ( TRUE );
          DoScrollSlider ( win, sld, WA_DNLINE, TRUE );
          return ( TRUE );
        }
      if ( obj == sld->left )
        {
          if ( clicks != 1 ) return ( TRUE );
          DoScrollSlider ( win, sld, WA_LFLINE, TRUE );
          return ( TRUE );
        }
      if ( obj == sld->right )
        {
          if ( clicks != 1 ) return ( TRUE );
          DoScrollSlider ( win, sld, WA_RTLINE, TRUE );
          return ( TRUE );
        }
      if ( obj == sld->show )
        {
          if ( clicks != 1 ) return ( TRUE );
          DoRealtimeSlider ( win, sld, sld->tree, sld->hide, sld->show, TRUE, RealCallBack );
          return ( TRUE );
        }
      if ( obj == sld->hor_show )
        {
          if ( clicks != 1 ) return ( TRUE );
          DoRealtimeSlider ( win, sld, sld->tree, sld->hor_hide, sld->hor_show, FALSE, RealCallBack );
          return ( TRUE );
        }
      if ( obj == sld->hide )
        {
          if ( clicks != 1 ) return ( TRUE );
          vq_mouse ( sysgem.vdi_handle, &m, &x, &y );
          objc_offset ( sld->tree, sld->show, &m, &x );
          if ( x > y )
            {
              DoScrollSlider ( win, sld, WA_UPPAGE, TRUE );
            }
          else
            {
              DoScrollSlider ( win, sld, WA_DNPAGE, TRUE );
            }
          return ( TRUE );
        }
      if ( obj == sld->hor_hide )
        {
          if ( clicks != 1 ) return ( TRUE );
          vq_mouse ( sysgem.vdi_handle, &m, &y, &x );
          objc_offset ( sld->tree, sld->hor_show, &x, &m );
          if ( x > y )
            {
              DoScrollSlider ( win, sld, WA_LFPAGE, TRUE );
            }
          else
            {
              DoScrollSlider ( win, sld, WA_RTPAGE, TRUE );
            }
          return ( TRUE );
        }
      sld = sld->next;
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

VOID PaintEntry ( SLD_ENTRY *entry )

{
  BYTE          *p;
  OBJECT        *tree;
  LONG          l;
  INT           y;
  INT           chw;

  p   = entry->text;
  chw = StringWidth ( "W" );

  if ( *p == 255 )
    {
      p += 6L;
    }

  if ( sysgem.act_color >= 16 )
    {
      if ( entry->changed )
        {
          if ( entry->selected )
            {
              FilledRect ( entry->area.x, entry->area.y, entry->area.x + entry->area.w - 1, entry->area.y + entry->area.h - 1, sysgem.selb_color );
            }
          else
            {
              FilledRect ( entry->area.x, entry->area.y, entry->area.x + entry->area.w - 1, entry->area.y + entry->area.h - 1, WHITE );
            }
        }
    }
  else
    {
      if ( entry->changed )
        {
          if ( entry->selected )
            {
              FilledRect ( entry->area.x, entry->area.y, entry->area.x + entry->area.w - 1, entry->area.y + entry->area.h - 1, BLACK );
            }
          else
            {
              FilledRect ( entry->area.x, entry->area.y, entry->area.x + entry->area.w - 1, entry->area.y + entry->area.h - 1, WHITE );
            }
        }
    }

  y = CenterY ( entry->area.y, entry->area.y + entry->area.h - 1 );

  TransMode ();

  entry->area.x -= entry->hpos;

  if ( sysgem.act_color >= 16 )
    {
      if ( entry->selected )
        {
          output_sld ( sysgem.selt_color, p, entry->area.x, y, chw, entry->tab, v_stext );
        }
      else
        {
          ReplaceMode ();
          output_sld ( BLACK, p, entry->area.x, y, chw, entry->tab, v_stext );
        }
    }
  else
    {
      if ( entry->selected )
        {
          output_sld ( WHITE, p, entry->area.x, y, chw, entry->tab, v_stext );
        }
      else
        {
          ReplaceMode ();
          output_sld ( BLACK, p, entry->area.x, y, chw, entry->tab, v_stext );
        }
    }
  ReplaceMode ();

  p = entry->text;
  if ( *p == 255 )
    {
      p++;
      l   = 0L;
      l  |= *p++;
      l <<= 8;
      l  |= *p++;
      l <<= 8;
      l  |= *p++;
      l <<= 8;
      l  |= *p++;

      tree = (OBJECT *) l;
      tree [*p].ob_x = entry->area.x;
      tree [*p].ob_y = entry->area.y;

      if ( entry->selected )
        {
          incl ( tree [*p].ob_state, SELECTED );
        }
      else
        {
          excl ( tree [*p].ob_state, SELECTED );
        }
      objc_draw ( tree, *p, 0, entry->clip.x, entry->clip.y, entry->clip.w, entry->clip.h );
    }
}

/* ------------------------------------------------------------------- */

VOID PaintSliderbox ( OBJECT *tree, INT box, RECT *clip )

{
  SLIDER        *sld;
  RECT          r;
  RECT          v;
  SLD_ENTRY     entry;
  INT           pos;
  INT           y;
  LONG          lp, ll;

  sld = xfind_slider ( tree, box, &r );
  if ( sld == NULL ) return;

  if ( tree [box].ob_flags & HIDETREE ) return;

  y    = clip->y + clip->h;
  pos  = sld->pos;

  BeginControl ( CTL_UPDATE | CTL_MHIDE );
  SetFont ( sld->font_id, sld->font_pt );

  forever
    {
      if ( r.y >= y ) break;
      if ( sld->max_ver == 0 ) break;
      if (( r.y + sld->chh ) < clip->y ) goto next_entry;

      entry.tree     = tree;
      entry.box      = box;
      entry.line     = pos;
      entry.area.x   = r.x;
      entry.area.y   = r.y;
      entry.area.w   = r.w;
      entry.area.h   = sld->chh;
      entry.text     = NULL;
      entry.tab      = &sld->tab [0];
      entry.buffer   = sld->buf;
      entry.len      = sld->len;
      entry.hpos     = sld->hpos;
      entry.selected = FALSE;
      entry.changed  = FALSE;
      entry.drawn    = FALSE;

      v.x = entry.area.x;
      v.y = entry.area.y;
      v.w = entry.area.w;
      v.h = entry.area.h;

      RectIntersect ( clip, &v );

      entry.clip.x = v.x;
      entry.clip.y = v.y;
      entry.clip.w = v.w;
      entry.clip.h = v.h;

      if (( v.w > 0 ) && ( v.h > 0 ))
        {
          if ( sld->buf != NULL )
            {
              lp         = (LONG)( pos );
              ll         = (LONG)( sld->len );
              entry.text = sld->buf + ( lp * ll );
            }
          SetClipping ( &v );
          if ( sld->paint_entry == NULL )
            {
              if ( pos == sld->sel )
                {
                  entry.selected = TRUE;
                  entry.changed  = TRUE;
                }
              if ( pos == sld->desel )
                {
                  entry.changed  = TRUE;
                }
              if ( all_selected ) entry.changed = TRUE;
              if ( sld->buf != NULL )
                {
                  PaintEntry ( &entry );
                }
            }
          else
            {
              sld->paint_entry ( &entry );
              if (( entry.drawn == FALSE ) && ( entry.text != NULL ))
                {
                  if ( all_selected ) entry.changed = TRUE;
                  PaintEntry ( &entry );
                }
            }
        }
      next_entry:

      r.y += sld->chh;
      pos++;
      if ( pos >= sld->max_ver ) break;
    }
  SetClipping ( clip );
  NormalFont ();
  EndControl  ( CTL_UPDATE | CTL_MHIDE );
}

/* ------------------------------------------------------------------- */

VOID RedrawSliderBox ( OBJECT *tree, INT box )

{
  WINDOW        *win;
  SLIDER        *slid;
  RECT          r;

  slid = xfind_slider ( tree, box, &r );
  if ( slid == NULL ) return;

  if ( tree [box].ob_flags & HIDETREE ) return;

  if (( win = DialogInWindow ( tree )) == topped ())
    {
      if (( win->flags & WIN_DRAWN ) == 0 ) return;
      if ( slid->hide     > 0 ) RedrawObj ( slid->tree, slid->hide, 1, NONE, UPD_STATE );
      if ( slid->hor_hide > 0 ) RedrawObj ( slid->tree, slid->hor_hide, 1, NONE, UPD_STATE );
      RedrawObj ( tree, box, 0, NONE, UPD_STATE );
      RectIntersect ( &sysgem.desk, &r );
      PaintSliderbox ( tree, box, &r );
      SetClipping ( NULL );
    }
  else
    {
      DoRedraw ( win, &r );
    }
}

/* ------------------------------------------------------------------- */

VOID FastDrawSldBox ( OBJECT *tree, INT box )

{
  WINDOW        *win;
  SLIDER        *slid;
  RECT          r;

  slid = xfind_slider ( tree, box, &r );
  if ( slid == NULL ) return;

  if ( tree [box].ob_flags & HIDETREE ) return;

  if (( win = DialogInWindow ( tree )) == topped ())
    {
      RectIntersect ( &sysgem.desk, &r );
      PaintSliderbox ( tree, box, &r );
      SetClipping ( NULL );
    }
  else
    {
      DoRedraw ( win, &r );
    }
}

/* ------------------------------------------------------------------- */
/* neue Funktion [GS] 																								 */

INT GetSelectSldItem ( OBJECT *tree, INT box )

{
  SLIDER        *slid;

  slid = xfind_slider ( tree, box, NULL );
  if ( slid == NULL ) return ( -1 );

	return ( slid->sel );
}
	
/* ------------------------------------------------------------------- */

BOOL SelectSldItem ( OBJECT *tree, INT box, INT line, BOOL draw )

{
  SLIDER        *slid;

  slid = xfind_slider ( tree, box, NULL );
  if ( slid == NULL ) return ( FALSE );

  if ( line == slid->sel )
    {
      slid->desel = line;
      slid->sel   = -1;
    }
  else
    {
      if ( line == -1 )
        {
          slid->desel   = slid->sel;
          slid->sel     = -1;
        }
      else
        {
          slid->desel   = slid->sel;
          slid->sel     = line;
        }
    }
  if ( draw )
    {
      sg_sldforone = TRUE;
      FastDrawSldBox ( tree, box );
      sg_sldforone = FALSE;
    }
  slid->desel = -1;
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

BOOL DeSelSldItem ( OBJECT *tree, INT box, BOOL draw )

{
  SLIDER        *slid;

  slid = xfind_slider ( tree, box, NULL );
  if ( slid == NULL ) return ( FALSE );

  if ( slid->sel >= 0 )
    {
      slid->desel = slid->sel;
      slid->sel   = -1;
      if ( draw )
        {
          sg_sldforone = TRUE;
          FastDrawSldBox ( tree, box );
          sg_sldforone = FALSE;
        }
      slid->desel = -1;
      return ( TRUE );
    }
  slid->desel = -1;
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

VOID SetSliderFont ( OBJECT *tree, INT box, INT font_id, INT font_pt, BOOL draw )

{
  SLIDER        *slid;
  OBJECT        *ob;
  BYTE          *p;
  LONG          l;
  INT           i;

  slid = xfind_slider ( tree, box, NULL );
  if ( slid == NULL ) return;

  if ( FontExists ( font_id ))
    {
      slid->font_id = font_id;
      slid->font_pt = ( font_pt > 20 ) ? 20 : font_pt;
      slid->font_pt = ( font_pt < 0 ) ? sysgem.font_hpt : font_pt;
      SetFont ( slid->font_id, slid->font_pt );
      slid->chh       = StringHeight ();
      slid->chw       = StringWidth ( "W" );
      slid->pos       = 0;
      slid->hpos      = 0;
      NormalFont ();

      if ( slid->buf != NULL )
        {
          p = slid->buf;
          for ( i = 0; i < slid->max_ver; i++ )
            {
              if ( *p == 255 )
                {
                  l   = 0L;
                  l  |= p [1];
                  l <<= 8;
                  l  |= p [2];
                  l <<= 8;
                  l  |= p [3];
                  l <<= 8;
                  l  |= p [4];

                  ob = (OBJECT *) l;
                  slid->chh = max (( ob [p [5]].ob_height ), slid->chh );
                }
              p += (LONG)( slid->len );
            }
        }
      slid->max_hor = CalcLength ( slid );
      if ( draw )
        {
          CalcSliderPos   ( slid, TRUE );
          RedrawSliderBox ( tree, box );
        }
      else
        {
          CalcSliderPos ( slid, FALSE );
        }
    }
}

/* ------------------------------------------------------------------- */

BOOL LinkSlider ( OBJECT *tree, INT up, INT dn, INT show, INT hide, INT max, INT box, VOID *buf, INT len, BOOL icons )

{
  DIALOG_SYS    *dial;
  SLIDER        *sld;
  OBJECT        *ob;
  BYTE          *p;
  LONG          l;
  INT           i;

  sc_pos	= 0;
  all_selected	= FALSE;

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );

  if ( find_slider ( dial, box ) != NULL ) return ( FALSE );

  tree [up].ob_x = tree [box].ob_x + tree [box].ob_width - 1;
  tree [up].ob_y = tree [box].ob_y;

  tree [dn].ob_x = tree [box].ob_x + tree [box].ob_width - 1;
  tree [dn].ob_y = tree [box].ob_y + tree [box].ob_height - tree [dn].ob_height;

  if ( hide != -1 )
    {
      tree [hide].ob_x = tree [box].ob_x + tree [box].ob_width - 1;
      tree [hide].ob_y = tree [box].ob_y + tree [ up].ob_height - 1;
      tree [hide].ob_height = tree [box].ob_height - tree [ up].ob_height - tree [dn].ob_height + 2;
    }

  sld = (SLIDER *) Allocate ( sizeof ( SLIDER ));
  if ( sld == NULL ) return ( FALSE );

  sld->font_id   = sysgem.act_font_id;
  sld->font_pt   = sysgem.act_font_pt;
  sld->chw       = StringWidth ( "W" );
  sld->chh       = StringHeight ();

  sld->sel       = -1;
  sld->desel     = -1;

  sld->tree      = tree;
  sld->box       = box;

  sld->up        = up;
  sld->dn        = dn;

  sld->show      = show;
  sld->hide      = hide;

  sld->right     = -1;
  sld->left      = -1;
  sld->hor_show  = -1;
  sld->hor_hide  = -1;
  sld->max_hor   = -1;
  sld->hpos      = 0;

  sld->buf       = buf;
  sld->len       = len;
  sld->pos       = 0;
  sld->max_ver   = max;
  sld->icons     = icons;

  InsertPtr ( &dial->slider, sld );

  sysgem.draw_slider = PaintSliderbox;
  sysgem.test_slider = TestSliderbox;

  for ( i = 0; i < MAX_TAB + 1; i++ )
    {
      sld->tab [i].pos  = -1;
      sld->tab [i].just = TAB_LEFT;
    }

  if (( icons ) && ( buf != NULL ))
    {
      p = buf;
      for ( i = 0; i < sld->max_ver; i++ )
        {
          if ( *p == 255 )
            {
              l   = 0L;
              l  |= p [1];
              l <<= 8;
              l  |= p [2];
              l <<= 8;
              l  |= p [3];
              l <<= 8;
              l  |= p [4];

              ob = (OBJECT *) l;
              sld->chh = max (( ob [p [5]].ob_height ), sld->chh );
            }
          p += (LONG)( sld->len );
        }
    }

  CalcSliderPos ( sld, FALSE );

  return ( TRUE );
}

/* ------------------------------------------------------------------- */

BOOL xLinkSlider ( OBJECT *tree, INT up, INT dn, INT show, INT hide, INT max, INT box, VOID *buf, INT len, BOOL icons, SPROC redraw )

{
  DIALOG_SYS    *dial;
  SLIDER        *sld;

  if ( redraw == NULL ) return ( FALSE );

  if ( LinkSlider ( tree, up, dn, show, hide, max, box, buf, len, icons ))
    {
      dial = find_dialog ( tree );
      if ( dial == NULL ) return ( FALSE );

      sld = find_slider ( dial, box );
      if ( sld == NULL ) return ( FALSE );

      sld->paint_entry = redraw;
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL LinkHorSlider ( OBJECT *tree, INT box, INT left, INT right, INT show, INT hide )

{
  DIALOG_SYS    *dial;
  SLIDER        *slid;

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );
  slid = find_slider ( dial, box );

  tree [left ].ob_x = tree [box].ob_x;
  tree [right].ob_x = tree [box].ob_width + tree [box].ob_x - tree [right].ob_width;

  if ( hide != -1 )
    {
      tree [hide].ob_x = tree [box].ob_x + tree [left].ob_width - 1;
      tree [hide].ob_width = tree [box].ob_width - tree [left].ob_width - tree [right].ob_width + 2;
    }

  tree [left ].ob_y = tree [box].ob_y + tree [box].ob_height - 1;
  tree [right].ob_y = tree [box].ob_y + tree [box].ob_height - 1;
  if ( hide != -1 )
    {
      tree [hide].ob_y = tree [box].ob_y + tree [box].ob_height - 1;
    }

  if ( slid != NULL )
    {
      slid->left     = left;
      slid->right    = right;
      slid->hor_show = show;
      slid->hor_hide = hide;
      slid->max_hor  = CalcLength ( slid );
      slid->hpos     = 0;

      CalcSliderPos ( slid, FALSE );

      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL UnLinkSlider ( OBJECT *tree, INT box )

{
  DIALOG_SYS    *dial;
  SLIDER        *slid;

  dial = find_dialog ( tree );
  if ( dial == NULL ) return ( FALSE );
  slid = find_slider ( dial, box );

  if ( slid != NULL )
    {
      DeletePtr ( &dial->slider, slid );
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

