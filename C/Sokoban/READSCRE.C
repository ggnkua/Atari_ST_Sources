#include <stdio.h>
#include "sokoban.h"

extern short level, packets, savepack, rows, cols;
extern char map[MAXROW+1][MAXCOL+1];
extern POS ppos;

readscreen()
{
   FILE *screen;
   char *fnam;
   short j, c, ret = 0;

   fnam = malloc( strlen( SCREENPATH) + 11);
#if ATARIST
   sprintf( fnam, "%s\\screen.%d", SCREENPATH, level);
#else
   sprintf( fnam, "%s/screen.%d", SCREENPATH, level);
#endif
   if( (screen = fopen( fnam, "r")) == NULL)
      ret = E_FOPENSCREEN;
   else {
      packets = savepack = rows = j = cols  = 0;
      storepos( ppos, -1, -1);
      while( (ret == 0) && ((c = getc( screen)) != EOF)) {
         switch( c) {
           case '\n':     map[rows++][j] = '\0';
                          if( rows > MAXROW)
                             ret = E_TOMUCHROWS;
                          else {
                             if( j > cols) cols = j;
                             j = 0;
                          }
                          break;
           case C_PLAYERSTORE:
           case C_PLAYER: if( ppos.x != -1)
                             ret = E_PLAYPOS1;
                          else {
                             storepos( ppos, rows, j);
                             map[rows][j++] = c;
                             if( j > MAXCOL) ret = E_TOMUCHCOLS;
                          }
                          break;
           case C_SAVE:   savepack++;
           case C_PACKET: packets++;
           case C_WALL:
           case C_STORE:
           case C_GROUND: map[rows][j++] = c;
                          if( j > MAXCOL) ret = E_TOMUCHCOLS;
                          break;
           default:       ret = E_ILLCHAR;
        }
      }
      fclose( screen);
      if( (ret == 0) && (ppos.x == -1)) ret = E_PLAYPOS2;
   }
   return( ret);
}
