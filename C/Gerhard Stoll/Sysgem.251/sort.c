/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <stdlib.h>
#include        <string.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM          sysgem;

/* ------------------------------------------------------------------- */

LOCAL   WTEXT           *list;
LOCAL   VPROC           cmp;
LOCAL   XPROC           xcmp;

/* ------------------------------------------------------------------- */

INT cmp_strings_up ( BYTE *str1, BYTE *str2 )

{
  return ( strcmp ( str1, str2 ));
}

/* ------------------------------------------------------------------- */

INT cmp_strings_dn ( BYTE *str1, BYTE *str2 )

{
  INT   c;

  c = strcmp ( str1, str2 );
  if ( c < 0 ) return (  1 );
  if ( c > 0 ) return ( -1 );
  return ( 0 );
}

/* ------------------------------------------------------------------- */

INT do_cmp ( LONG *l1, LONG *l2 )

{
  WTEXT *e1, *e2;

  e1 = (WTEXT *)( *l1 );
  e2 = (WTEXT *)( *l2 );

  return ( cmp ( e1->text, e2->text ));
}

/* ------------------------------------------------------------------- */

VOID do_qsort ( LONG win_id, VPROC compare )

{
  WINDOW        *win;
  WTEXT         *wt;
  LONG          *lst;
  LONG          mem;
  UINT          i;
  UINT          anzahl;

  cmp = cmp_strings_up;
  if ( compare != NULL ) cmp = compare;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return;

  anzahl = CountLines ( win_id );
  if ( anzahl < 2 ) return;

  mem  = (LONG)( anzahl ) * 4L;
  mem += 4L;

  list = (WTEXT *) Allocate ( mem );
  if ( list == NULL ) return;

  lst = (LONG *) list;

  i = 0;
  wt = win->first;
  while ( wt != NULL )
    {
      lst [i] = (LONG)( wt );
      i++;
      wt = wt->next;
    }

  i = 0;
  qsort ( list, (size_t)( anzahl ), 4L, do_cmp );

  win->first = (WTEXT *) lst [0];
  wt = win->first;
  for ( i = 1; i < anzahl; i++ )
    {
      wt->next = (WTEXT *) lst [i];
      wt = wt->next;
    }
  wt->next = NULL;
  win->last = wt;

  Dispose ( list );
  ListUpdate ( win );
}

/* ------------------------------------------------------------------- */

INT xdo_cmp ( LONG *l1, LONG *l2 )

{
  WTEXT *e1, *e2;

  e1 = (WTEXT *)( *l1 );
  e2 = (WTEXT *)( *l2 );

  return ( xcmp ( e1->text, e1->user, e2->text, e2->user ));
}

/* ------------------------------------------------------------------- */

VOID xdo_qsort ( LONG win_id, XPROC compare )

{
  WINDOW        *win;
  WTEXT         *wt;
  LONG          *lst;
  LONG          mem;
  UINT          i;
  UINT          anzahl;

  if ( compare == NULL ) return;
  xcmp = compare;

  win = find_window ( -1, win_id );
  if ( win == NULL ) return;

  anzahl = CountLines ( win_id );
  if ( anzahl < 2 ) return;

  mem  = (LONG)( anzahl ) * 4L;
  mem += 4L;

  list = (WTEXT *) Allocate ( mem );
  if ( list == NULL ) return;

  lst = (LONG *) list;

  i = 0;
  wt = win->first;
  while ( wt != NULL )
    {
      lst [i] = (LONG)( wt );
      i++;
      wt = wt->next;
    }

  i = 0;
  qsort ( list, (size_t)( anzahl ), 4L, xdo_cmp );

  win->first = (WTEXT *) lst [0];
  wt = win->first;
  for ( i = 1; i < anzahl; i++ )
    {
      wt->next = (WTEXT *) lst [i];
      wt = wt->next;
    }
  wt->next = NULL;
  win->last = wt;

  Dispose ( list );
  ListUpdate ( win );
}

/* ------------------------------------------------------------------- */
