#include <curses.h>
#include "sokoban.h"

extern short rows, cols, level, moves, pushes, packets, savepack;
extern char map[MAXROW+1][MAXCOL+1];

#if ATARIST
#define input_off()
input_on()	/* Clear the input buffer */
{
	while (Cconis()) Cnecin();
}
#else
#define input_off() raw()
#define input_on() noraw()
#endif

showscreen() {

   short i, j;

   move( 0, 0); clrtobot();
   for( i = 0; i < rows; i++)
      for( j = 0; map[i][j] != '\0'; j++)
         mapchar( map[i][j], i, j);
   move( MAXROW, 0);
   printw( "Level:      Packets:      Saved:      Moves:             Pushes:");
   displevel();
   disppackets();
   dispsave();
   dispmoves();
   disppushes();
   move( MAXROW+2,0);
   refresh();
}

mapchar( c, i, j)
char c;
short i, j;
{
   short offset_row = (MAXROW - rows) / 2;
   short offset_col = MAXCOL - cols;

   move( i + offset_row, 2*j + offset_col);     addch( c);
   move( i + offset_row, 2*j + 1 + offset_col); addch( c);
}

displevel() {
   move( MAXROW, 7); printw( "%3d", level);
}

disppackets() {
   move( MAXROW, 21); printw( "%3d", packets);
}

dispsave() {
   move( MAXROW, 33); printw( "%3d", savepack);
}

dispmoves() {
   move( MAXROW, 45); printw( "%10d", moves);
}

disppushes() {
   move( MAXROW, 65); printw( "%10d", pushes);
}

helpmessage() {
   move( MAXROW+2, 0); printw( "Press ? for help.%c", '\007');
   refresh();
#if ATARIST
	get_char();
#else
   input_off();                              /* no input allowed while sleeping */
   sleep( 2);
   input_on();                            /* end raw mode */
#endif
   move( MAXROW+2, 0); deleteln();
   refresh();
}

showhelp() {

   FILE *helpfile;
   char buf[80];
   short i, ret = 0, endhelp = 0, c;

   if( (helpfile = fopen( HELPFILE, "r")) == NULL)
      ret = E_FOPENHELP;
   else {
      input_off();
      move( 0, 0); clrtobot();
      i = 0;
      while( fgets( buf, 80, helpfile) && (! endhelp)) {
        if( strncmp( buf, "+=", 2) == 0) {             /* page eject */
           move( 23, 0);
           addstr( "(Press space to continue, return to exit help)");
           refresh();
           input_on();
           if( (c = get_char()) == 
#if ATARIST
'\r'
#else
'\n'
#endif
)
              endhelp = 1;
           else {
              i = 0;
              move( 0, 0); clrtobot();
              refresh();
              input_off();
           }
        }
        else if( strncmp( buf, "==", 2) == 0) {        /* end of helpfile */
           move( 23, 0);
           addstr( "(Press any key to continue)");
           refresh();
           input_on();
           get_char();
           endhelp = 1;
        }
        else {
           move( i, 0);
           addstr( buf);
           i++;
        }
      }
   }
   return( ret);
}
