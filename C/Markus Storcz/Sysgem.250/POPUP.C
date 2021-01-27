/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        "nkcc.h"
#include        <string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;
EXTERN  XEVENT  xevent;

/* ------------------------------------------------------------------- */

EXTERN  BOOL    turn_back;
EXTERN  UINT    make_nkc        ( INT key, INT state );

/* ------------------------------------------------------------------- */

INT PopUp ( OBJECT *tree, INT xpos, INT ypos, INT start, INT first )

{
  XWIN          xwin;
  XTREE         xtree;
  WTREE         *wt;
  USERB         *ub;
  WINDOW        *win;
  INT           i, j;
  INT           x, y;
  INT           ch;
  INT           old;
  INT           obj;
  INT           item;

  x = xpos;
  y = ypos;

  InitXWindow ( &xwin );

  objc_offset ( tree, start, &xwin.work.x, &xwin.work.y );
  xwin.work.w = tree [start].ob_width - 2;
  xwin.work.h = tree [start].ob_height - 2;

  if (( x < 0 ) || ( y < 0 ))
    {
      MouseClicked ( &x, &y );
    }

  xwin.work.x   = ( x < 0 ) ? sysgem.desk.x : x;
  xwin.work.y   = ( y < 0 ) ? sysgem.desk.y : y;

  if ( x != -1 ) x++;
  if ( y != -1 ) y++;

  if ( first > 0 ) y = y - tree [first].ob_y;

  xwin.work.x   = ( x < 0 ) ? sysgem.desk.x : x;
  xwin.work.y   = ( y < 0 ) ? sysgem.desk.y : y;

  xtree.id       = 'xlSt' - 1L;
  xtree.tree     = tree;
  xtree.start    = start;
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

  item = -1;
  
  forever
    {
      if ( ! MouseClicked ( &x, &y )) break;
    }
  
  if ( XWindow ( &xwin ))
    {
      BeginControl ( CTL_MOUSE );
      obj = -1;
      old = xevent.tim_lo;
      xevent.tim_lo = 10;
      forever
        {
          turn_back = 500;
          HandleEvents ();
          if ( turn_back == MU_BUTTON )
            {
              item = obj;
              goto end_loop;
            }
          if ( turn_back == MU_KEYBD )
            {
              ch = alt_shortcut ( make_nkc ( xevent.key, xevent.kstate ));
              if ( ch == 0 ) continue;

              win = find_window ( -1, xtree.id + 1 );
              if ( win == NULL ) continue;

              wt = win->tree;
              while ( wt != NULL )
                {
                  if ( wt->pos != LINK_DIALOG ) goto weiter;
                  ub = wt->dial->user;
                  while ( ub != NULL )
                    {
                      if ( ub->ch == ch )
                        {
                          item = ub->obj;
                          goto end_loop;
                        }
                      ub = ub->next;
                    }
                  weiter:
                  wt = wt->next;
                }
              continue;
            }
          j = objc_find ( tree, start, 8, xevent.x, xevent.y );
          if ( j > 0 )
            {
              if ( j == obj ) continue;
              if ( tree [j].ob_flags & SELECTABLE )
                {
                  if ( obj != -1 )
                    {
                      RedrawObj ( tree, obj, 0, SELECTED, DEL_STATE | UPD_STATE );
                    }
                  RedrawObj ( tree, j, 0, SELECTED, SET_STATE | UPD_STATE );
                  obj = j;
                }
            }
          else
            {
              if ( obj != -1 )
                {
                  RedrawObj ( tree, obj, 0, SELECTED, DEL_STATE | UPD_STATE );
                }
              obj = -1;
            }
        }
      end_loop:
      xevent.tim_lo = old;
      if ( obj != -1 )
        {
          RedrawObj ( tree, obj, 0, SELECTED, DEL_STATE | UPD_STATE );
        }
      turn_back = FALSE;
      while ( MouseClicked ( &i, &i ));
      EndControl ( CTL_MOUSE );
      win = find_window ( -1, xtree.id + 1 );
      if ( win != NULL ) DestroyWindow ( win, TRUE );
    }
  return ( item );
}

/* ------------------------------------------------------------------- */

INT xPopUp ( OBJECT *tree, INT obj, OBJECT *tree2, INT start, INT *first )

{
  INT   x, y;
  BYTE  s2 [200];
/*
  BYTE  s1 [200];
*/

  if ( tree2 == NULL ) return ( -1 );
  if ( *first <= 0 ) *first = start + 1;
  objc_offset ( tree, obj, &x, &y );
  x = PopUp ( tree2, x, y, start, *first );
  if ( x != -1 )
    {
      *first = x;
/*
      GetText ( tree, obj, s1 );
      y = length ( s1 );
*/
      GetText ( tree2, x, s2 );
/*
      sprintf ( s1, "%-*.*s", y, y, s2 );
*/
      xSetText ( tree, obj, s2 );
      RedrawObj ( tree, obj, 0, NONE, UPD_STATE );
    }
  return ( x );
}

/* ------------------------------------------------------------------- */

INT Cycle ( OBJECT *tree, INT obj, OBJECT *pop_tree, INT first, INT last, INT *ret )

{
  BYTE  s [100];

  *ret = *ret + 1;
  if ( *ret > last ) *ret = first;
  GetText ( pop_tree, *ret, s );
  SetText ( tree, obj, s );
  RedrawObj ( tree, obj, 0, NONE, UPD_STATE );
  return ( *ret );
}

/* ------------------------------------------------------------------- */

INT CycleBack ( OBJECT *tree, INT obj, OBJECT *pop_tree, INT first, INT last, INT *ret )

{
  BYTE  s [100];

  *ret = *ret - 1;
  if ( *ret < first ) *ret = last;
  GetText ( pop_tree, *ret, s );
  SetText ( tree, obj, s );
  RedrawObj ( tree, obj, 0, NONE, UPD_STATE );
  return ( *ret );
}

/* ------------------------------------------------------------------- */


