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
EXTERN  XEVENT  xevent;
EXTERN  BOOL    turn_back;

/* ------------------------------------------------------------------- */

LOCAL   SPROC   for_sliderown   = NULL;

/* ------------------------------------------------------------------- */

VOID do_parse ( BYTE *z, INT *count, INT *len )

{
  INT   i;

  *count = 1;
  *len   = 0;

  i = 0;
  while ( *z )
    {
      if ( *z == '|' )
        {
          *len   = max ( i, *len );
          *count = *count + 1;
          i      = 0;
          z++;
        }
      z++;
      i++;
    }
  *len = max ( i, *len );
}

/* ------------------------------------------------------------------- */

INT Listbox ( BYTE *strings, INT count, INT len, OBJECT *tree, INT box )

{
  XWIN          xwin;
  XTREE         xtree;
  WTREE         *wt;
  WINDOW        *win;
  OBJECT        *list;
  INT           xx, yy;
  INT           b;
  BYTE          *buff, *p, *x;
  INT           i;
  INT           result_bt;

  if ( strings == NULL ) return ( -1 );
  if ( find_window ( -1, 'xlSt' ) != NULL ) return ( -2 );
  list = sysgem.listbox;

  if (( count <= 0 ) && ( len <= 0 ))
    {
      do_parse ( strings, &count, &len );
      i = count;
      if ( i < 8 ) i = 8;
      buff = (BYTE *) Allocate ((LONG)( i ) * (LONG)( len + 1 ));
      if ( buff == NULL ) return ( -1 );
      memset ( buff, 0, (LONG)( i ) * (LONG)( len  + 1 ));
      x = strings;
      i = 0;
      p = buff;
      while ( *x )
        {
          if ( *x == '|' )
            {
              i++;
              x++;
              p = buff + (LONG)((LONG)( i ) * (LONG)( len + 1 ));
            }
          else
            {
              *p++ = *x++;
            }
        }
    }
  else
    {
      i = count;
      if ( i < 8 ) i = 8;
      buff = (BYTE *) Allocate ((LONG)( i ) * (LONG)( len + 5 ));
      if ( buff == NULL ) return ( -1 );
      memset ( buff, 0, (LONG)( i ) * (LONG)( len  + 5 ));
      memcpy ( buff, strings, (LONG)( count ) * (LONG)( len ));
      len--;
    }

  InitXWindow ( &xwin );

  if ( tree != NULL )
    {
      objc_offset ( tree, box, &xx, &yy );

      list [0].ob_x = xx;
      list [0].ob_y = yy + tree [box].ob_height - 2;
      list [1].ob_width = tree [box].ob_width;
    }
  else
    {
      list [1].ob_width = ( len + 1 ) * StringWidth ( "W" );
    }

  if ( ObjTyp ( tree, box ) == OBJ_LISTBOX )
    {
      list [1    ].ob_width = list [1].ob_width - (( 2 * sysgem.charw ) + 4 );
      list [MA_UP].ob_height += 2;
      list [MA_DN].ob_height += 2;
    }

  if ( for_sliderown != NULL )
    {
      xLinkSlider  ( list, MA_UP, MA_DN, MA_SHOW, MA_HIDE, count, MA_BOX, buff, len + 1, 0, for_sliderown );
    }
  else
    {
      LinkSlider   ( list, MA_UP, MA_DN, MA_SHOW, MA_HIDE, count, MA_BOX, buff, len + 1, 0 );
    }
  for_sliderown = NULL;
  SetSliderTab ( list, MA_BOX, 0, TAB_LEFT );
  list [0].ob_width = list [1].ob_width + list [MA_UP].ob_width - 1;

  list [1      ].ob_x  = -1;
  list [1      ].ob_y  = -1;
  list [0      ].ob_width -= 2;
  list [0      ].ob_height -= 2;
  list [MA_UP  ].ob_x -= 1;
  list [MA_UP  ].ob_y -= 1;
  list [MA_DN  ].ob_x -= 1;
  list [MA_DN  ].ob_y -= 1;
  list [MA_HIDE].ob_x -= 1;
  list [MA_HIDE].ob_y -= 1;

  if ( ObjTyp ( tree, box ) == OBJ_LISTBOX )
    {
      list [0      ].ob_width += 2;
      list [MA_UP  ].ob_width += 2;
      list [MA_DN  ].ob_width += 2;
      list [MA_HIDE].ob_width += 2;
      list [MA_SHOW].ob_width += 2;
    }

  form_center ( list, &xwin.work.x, &xwin.work.y, &xwin.work.w, &xwin.work.h );

  if ( tree != NULL )
    {
      xwin.work.x        = xx + 1;
      xwin.work.y        = yy + tree [box].ob_height - 1;
    }
  else
    {
      MouseClicked ( &xwin.work.x, &xwin.work.y );
    }

  result_bt      = -1;

  xtree.id       = 'xllS' - 1L;
  xtree.tree     = list;
  xtree.start    = 0;
  xtree.depth    = 8;
  xtree.edit     = 0;
  xtree.pos      = LINK_DIALOG;

  xwin.id        = xtree.id + 1L;
  xwin.flags     = 0;
  xwin.cfg       = WIN_DIALOG | WIN_FORCE;
  xwin.align_x   = 1;
  xwin.align_y   = 1;
  xwin.scr_x     = 1;
  xwin.scr_y     = 1;
  xwin.anz_trees = 1;
  xwin.trees     = &xtree;

  forever
    {
      if ( ! MouseClicked ( &xx, &yy )) break;
    }
  if ( XWindow ( &xwin ))
    {
      win = find_window ( -1, xtree.id + 1 );
      if ( win == NULL ) return ( -1 );

      wt = win->tree;
      while ( wt != NULL )
        {
          if ( wt->pos == LINK_DIALOG ) break;
          wt = wt->next;
        }
      if ( wt == NULL ) return ( -1 );
      BeginControl ( CTL_UPDATE | CTL_MOUSE );
      forever
        {
          turn_back = 500;
          HandleEvents ();
          if ( turn_back == MU_BUTTON )
            {
              i = objc_find ( sysgem.listbox, 0, 8, xevent.x, xevent.y );
              if ( i > 0 )
                {
                  if ( sysgem.test_slider != NULL )
                    {
                      i = sysgem.test_slider ( win, wt->dial->tree, i, xevent.y, 1, &b );
                      if ( i > 0 )
                        {
                          if ( b > 0 )
                            {
                              result_bt = b - 1;
                              goto end_loop;
                            }
                          if ( b < 0 )
                            {
                              result_bt = -1;
                              goto end_loop;
                            }
                          continue;
                        }
                    }
                  goto end_loop;
                }
              else
                {
                  goto end_loop;
                }
            }
        }
      end_loop:
      turn_back = FALSE;
      while ( MouseClicked ( &i, &i ));
      EndControl ( CTL_UPDATE | CTL_MOUSE );
      if ( result_bt != -1 )
        {
          if ( tree != NULL )
            {
              SetText  ( tree, box, buff + ((LONG)( result_bt ) * (LONG)( len + 1 )));
              RedrawObj ( tree, box, 0, NONE, UPD_STATE );
            }
        }
      DestroyWindow ( win, TRUE );
    }

  UnLinkSlider ( list, MA_BOX );
  Dispose ( buff );

  if ( ObjTyp ( tree, box ) == OBJ_LISTBOX )
    {
      list [0      ].ob_width -= 2;
      list [MA_UP  ].ob_width -= 2;
      list [MA_UP  ].ob_height -= 2;
      list [MA_DN  ].ob_width -= 2;
      list [MA_DN  ].ob_height -= 2;
      list [MA_HIDE].ob_width -= 2;
      list [MA_SHOW].ob_width -= 2;
    }

  list [1      ].ob_x  = 0;
  list [1      ].ob_y  = 0;
  list [0      ].ob_width += 2;
  list [0      ].ob_height += 2;
  list [MA_UP  ].ob_x += 1;
  list [MA_UP  ].ob_y += 1;
  list [MA_DN  ].ob_x += 1;
  list [MA_DN  ].ob_y += 1;
  list [MA_HIDE].ob_x += 1;
  list [MA_HIDE].ob_y += 1;
  return ( result_bt );
}

/* ------------------------------------------------------------------- */

INT xListbox ( BYTE *strings, INT count, INT len, OBJECT *tree, INT box, SPROC redraw )

{
  INT	i;
  
  for_sliderown = redraw;
  i = Listbox ( strings, count, len, tree, box );
  for_sliderown = NULL;
  return ( i );
}

/* ------------------------------------------------------------------- */

