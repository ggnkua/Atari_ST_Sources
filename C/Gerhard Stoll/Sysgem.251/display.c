/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <string.h>
#include        <tos.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM          sysgem;

/* ------------------------------------------------------------------- */

LONG Display ( BYTE *fname, BYTE *wname, BYTE *winfo, INT len, LONG win_id, INT x, INT y, INT w, INT h, APROC action )

{
  WINDOW *win;
  FILE   *f;
  LONG   hd;
  BYTE   *z;
  BYTE   s   [300];
  UINT   i;
  UINT   v;

  win = find_window ( -1, win_id );
  if ( win != NULL )
    {
      TopWindow ( win->handle );
      return ( 0L );
    }
  len = min ( 298, len );

  hd = Fopen ( fname, FO_READ );
  if ( hd < 0L ) return ( hd );
  Fclose ((INT)( hd ));

  f = fopen ( fname, "r" );
  if ( f == NULL ) return ( 0L );

  i = 0xfef | 0x4000;
  if ( winfo != NULL )
    {
      if ( length ( winfo ) > 0 ) i |= INFO;
    }
  if ( OpenWindow ( win_id, wname, winfo, i, NULL, 8, TRUE, sysgem.charw, sysgem.charh, 1L, 1L, x, y, w, h, NULL, (RPROC) NULL, action ) > 0 )
    {
      BeginListUpdate ( win_id );
      i = 0U;
      forever
        {
          memset ( s, 0, sizeof ( s ));
          if ( feof ( f )) break;
          fgets ( s, len, f );
          if ( feof ( f )) break;
          v = length ( s );
          if ( v > 0 ) s [v-1] = 0;
                  else s [0] = 0;
          z = s;
          while ( *z )
            {
              if ( *z == '\n' ) *z = ' ';
              if ( *z == '\r' ) *z = ' ';
              if ( *z == '\t' ) *z = ' ';
              z++;
            }
          if ( i == 0 ) LinkList  ( win_id, s );
                   else AddToList ( win_id, s );
          i++;
        }
      fclose ( f );
      EndListUpdate ( win_id );
      return ((LONG)( i ));
    }
  fclose ( f );
  return ( -4711L );
}

/* ------------------------------------------------------------------- */
