/****************************************************************/
/*                                                              */
/*   tekkeys.c verarbeitet sondertasten fÅr tektronix 4014      */
/*                                                              */
/****************************************************************/

#include  "ascii.h"
#include  "keytbl.h"
#include  "tek.h"

extern int tek_state;

int  tek_keys(keycode)
register int  keycode;
{
     switch (keycode & 0xff00) {

     case KEY_P:
          return(tek_pfkey(keycode));
          break;
     case KEY_S:
          return(tek_skey(keycode));
          break;
     case KEY_F:
          return(tek_fkey(keycode));
          break;
     case KEY_C:
          return(tek_ckey(keycode));
          break;
     }
     return(-1);
}

static int tek_skey(keycode)
register int keycode;
{
     switch(keycode & 0xff) {

     case K_CLR:
          tek_clear();
          tek_erase();
          if (tek_state & TEK_GIN) {
               gin_off();
          }
          tek_state &= ~(TEK_ESC|TEK_GRAPH|TEK_VECTOR|TEK_POINT|
                         TEK_INCREMENT|TEK_WRITE|TEK_LOY|TEK_BYPASS|
                         TEK_GIN);
          tek_state |= TEK_ALPHA;
          break;
     }
     return(-1);
}

static int tek_ckey(keycode)
register int keycode;
{
     return(-1);
}

static int tek_fkey(keycode)
register int keycode;
{
     return(-1);
}

static int tek_pfkey(keycode)
register int keycode;
{
     switch(keycode & 0xff) {
     case K_P0:
          keycode = '0';
          break;
     case K_P1:
          keycode = '1';
          break;
     case K_P2:
          keycode = '2';
          break;
     case K_P3:
          keycode = '3';
          break;
     case K_P4:
          keycode = '4';
          break;
     case K_P5:
          keycode = '5';
          break;
     case K_P6:
          keycode = '6';
          break;
     case K_P7:
          keycode = '7';
          break;
     case K_P8:
          keycode = '8';
          break;
     case K_P9:
          keycode = '9';
          break;
     case K_PDOT:
          keycode = '.';
          break;
     case K_PENT:
          keycode = CR;
          break;
     case K_PMIN:
          keycode = '-';
          break;
     case K_PADD:
          keycode = '+';
          break;
     case K_PPF1:
          keycode = '(';
          break;
     case K_PPF2:
          keycode = ')';
          break;
     case K_PPF3:
          keycode = '/';
          break;
     case K_PPF4:
          keycode = '*';
          break;
     }
     return (keycode|KEY_N);
}

