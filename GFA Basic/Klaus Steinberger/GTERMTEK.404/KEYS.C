/****************************************************************/
/*                                                              */
/*   keys.c    umkodierung der tastatur                         */
/*             Manche kontrollkodes sitzen bei atari auf den    */
/*             Tasten, ausserdem sollte man an einem ascii      */
/*             Rechner nicht die alternate taste benoetigen um  */
/*             an '[' zu kommen                                 */
/*                                                              */
/*             warum nicht mit der betreffenden betriebssystem- */
/*             funktion? :                                      */
/*             auf diese weise lassen sich auch gleich die      */
/*             VT100 Keypad-codes abfangen!!                    */
/****************************************************************/

#include  "ascii.h"
#include  "keytbl.h"
#include  "osbind.h"

#define   Kbshift(a)     bios(11,a)     /* getshift in osbind.h falsch ??*/


struct tbl {
     int  normal;
     int  shifted;
     int  control;
     int  caps;
};

static struct tbl key[128] = {
     {0, 0, 0, 0},
     {KEY_N|ESC, KEY_N|ESC, KEY_N|ESC, KEY_N|ESC}, /* KEYCODE 0X01 */
     {KEY_N|'1', KEY_N|'!', 0, KEY_N|'1'},
     {KEY_N|'2', KEY_N|'\042', KEY_N|NUL, KEY_N|'2'},
     {KEY_N|'3', KEY_N|'#', 0, KEY_N|'3'},
     {KEY_N|'4', KEY_N|'$', 0, KEY_N|'4'},
     {KEY_N|'5', KEY_N|'%', 0, KEY_N|'5'},
     {KEY_N|'6', KEY_N|'&', 0, KEY_N|'6'},
     {KEY_N|'7', KEY_N|'/', 0, KEY_N|'7'},
     {KEY_N|'8', KEY_N|'(', 0, KEY_N|'8'},
     {KEY_N|'9', KEY_N|')', 0, KEY_N|'9'},
     {KEY_N|'0', KEY_N|'=', 0, KEY_N|'0'},
     {KEY_N|'~', KEY_N|'?', 0, KEY_N|'~'},
     {KEY_N|047, KEY_N|'`', 0, KEY_N|047},
     {KEY_N|BS, KEY_N|BS, KEY_N|BS, KEY_N|BS},
     {KEY_N|HT, KEY_N|HT, KEY_N|HT, KEY_N|HT},
     {KEY_N|'q', KEY_N|'Q', KEY_N|DC1, KEY_N|'Q'},  /* Keycode 0x10 */
     {KEY_N|'w', KEY_N|'W', KEY_N|ETB, KEY_N|'W'},
     {KEY_N|'e', KEY_N|'E', KEY_N|ENQ, KEY_N|'E'},
     {KEY_N|'r', KEY_N|'R', KEY_N|DC2, KEY_N|'R'},
     {KEY_N|'t', KEY_N|'T', KEY_N|DC4, KEY_N|'T'},
     {KEY_N|'z', KEY_N|'Z', KEY_N|SUB, KEY_N|'Z'},
     {KEY_N|'u', KEY_N|'U', KEY_N|NAK, KEY_N|'U'},
     {KEY_N|'i', KEY_N|'I', KEY_N|HT, KEY_N|'I'},
     {KEY_N|'o', KEY_N|'O', KEY_N|SI, KEY_N|'O'},
     {KEY_N|'p', KEY_N|'P', KEY_N|DLE, KEY_N|'P'},
     {KEY_N|'@', KEY_N|0134, KEY_N|FS,KEY_N|'@'},
     {KEY_N|'+', KEY_N|'*', 0, KEY_N|'+'},
     {KEY_N|CR, KEY_N|CR, KEY_N|CR, KEY_N|CR},
     {0, 0, 0, 0},
     {KEY_N|'a', KEY_N|'A', KEY_N|SOH, KEY_N|'A'},      /* 0x1e */
     {KEY_N|'s', KEY_N|'S', KEY_N|DC3, KEY_N|'S'},
     {KEY_N|'d', KEY_N|'D', KEY_N|EOT, KEY_N|'D'},
     {KEY_N|'f', KEY_N|'F', KEY_N|ACK, KEY_N|'F'},
     {KEY_N|'g', KEY_N|'G', KEY_N|BEL, KEY_N|'G'},
     {KEY_N|'h', KEY_N|'H', KEY_N|BS, KEY_N|'H'},
     {KEY_N|'j', KEY_N|'J', KEY_N|LF, KEY_N|'J'},
     {KEY_N|'k', KEY_N|'K', KEY_N|VT, KEY_N|'K'},
     {KEY_N|'l', KEY_N|'L', KEY_N|FF, KEY_N|'L'},
     {KEY_N|0133, KEY_N|0173, KEY_N|ESC, KEY_N|0133},
     {KEY_N|0135, KEY_N|0175, KEY_N|GS, KEY_N|0135},     /* 0x28 */
     {KEY_N|'#', KEY_N|'^', KEY_N|RS, KEY_N|'#'},
     {0, 0, 0, 0},
     {KEY_N|'~', KEY_N|'|', 0, KEY_N|'~'},              /* 0x2b */
     {KEY_N|'y', KEY_N|'Y', KEY_N|EM, KEY_N|'Y'},
     {KEY_N|'x', KEY_N|'X', KEY_N|CAN, KEY_N|'X'},
     {KEY_N|'c', KEY_N|'C', KEY_N|ETX, KEY_N|'C'},
     {KEY_N|'v', KEY_N|'V', KEY_N|SYN, KEY_N|'V'},
     {KEY_N|'b', KEY_N|'B', KEY_N|STX, KEY_N|'B'},
     {KEY_N|'n', KEY_N|'N', KEY_N|SO, KEY_N|'N'},
     {KEY_N|'m', KEY_N|'M', KEY_N|CR, KEY_N|'M'},
     {KEY_N|',', KEY_N|';', 0, KEY_N|','},
     {KEY_N|'.', KEY_N|':', 0, KEY_N|'.'},
     {KEY_N|'-', KEY_N|'_', KEY_N|US, KEY_N|'-'},       /* keycode 0x35 */
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {KEY_N|' ', KEY_N|' ', KEY_N|' ', KEY_N|' '},
     {0, 0, 0, 0},
     {KEY_F|K_F1, KEY_F|K_SF1, 0, KEY_F|K_F1},            /* keycode 0x3b */
     {KEY_F|K_F2, KEY_F|K_SF2, 0, KEY_F|K_F2},
     {KEY_F|K_F3, KEY_F|K_SF3, 0, KEY_F|K_F3},
     {KEY_F|K_F4, KEY_F|K_SF4, 0, KEY_F|K_F4},
     {KEY_F|K_F5, KEY_F|K_SF5, 0, KEY_F|K_F5},
     {KEY_F|K_F6, KEY_F|K_SF6, 0, KEY_F|K_F6},
     {KEY_F|K_F7, KEY_F|K_SF7, 0, KEY_F|K_F7},
     {KEY_F|K_F8, KEY_F|K_SF8, 0, KEY_F|K_F8},
     {KEY_F|K_F9, KEY_F|K_SF9, 0, KEY_F|K_F9},
     {KEY_F|K_F10, KEY_F|K_SF10, 0, KEY_F|K_F10},          /* keycode 0x44 */
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {KEY_S|K_HOME, KEY_S|K_CLR, 0, KEY_S|K_HOME},
     {KEY_C|K_CUP, KEY_C|K_CUP, KEY_C|K_CUP, KEY_C|K_CUP},
     {0, 0, 0, 0},
     {KEY_P|K_PMIN, KEY_P|K_PMIN, 0, KEY_P|K_PMIN},
     {KEY_C|K_LEFT, KEY_C|K_LEFT, KEY_C|K_LEFT, KEY_C|K_LEFT},
     {0, 0, 0, 0},
     {KEY_C|K_RIGHT, KEY_C|K_RIGHT, KEY_C|K_RIGHT, KEY_C|K_RIGHT},
     {KEY_P|K_PADD, KEY_P|K_PADD, 0, KEY_P|K_PADD},
     {0, 0, 0},
     {KEY_C|K_DOWN, KEY_C|K_DOWN, KEY_C|K_DOWN, KEY_C|K_DOWN},   /* keycode 0x50 */
     {0, 0, 0},
     {KEY_S|K_INSERT, KEY_S|K_INSERT, KEY_S|K_INSERT, KEY_S|K_INSERT},
     {KEY_N|DEL, KEY_N|DEL, KEY_N|DEL, KEY_N|DEL},
     {KEY_F|K_SF1, KEY_F|K_SF1, 0, KEY_F|K_SF1},            /* keycode 0x54 */
     {KEY_F|K_SF2, KEY_F|K_SF2, 0, KEY_F|K_SF2},
     {KEY_F|K_SF3, KEY_F|K_SF3, 0, KEY_F|K_SF3},
     {KEY_F|K_SF4, KEY_F|K_SF4, 0, KEY_F|K_SF4},
     {KEY_F|K_SF5, KEY_F|K_SF5, 0, KEY_F|K_SF5},
     {KEY_F|K_SF6, KEY_F|K_SF6, 0, KEY_F|K_SF6},
     {KEY_F|K_SF7, KEY_F|K_SF7, 0, KEY_F|K_SF7},
     {KEY_F|K_SF8, KEY_F|K_SF8, 0, KEY_F|K_SF8},
     {KEY_F|K_SF9, KEY_F|K_SF9, 0, KEY_F|K_SF9},
     {KEY_F|K_SF10, KEY_F|K_SF10, 0, KEY_F|K_SF10},          /* keycode 0x5d */
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {KEY_N|'<', KEY_N|'>', 0, KEY_N|'<'},
     {KEY_S|K_UNDO, KEY_S|K_UNDO, KEY_S|K_UNDO, KEY_S|K_UNDO},
     {KEY_S|K_HELP, KEY_S|K_HELP, KEY_S|K_HELP, KEY_S|K_HELP},
     {KEY_P|K_PPF1, KEY_P|K_PPF1, KEY_P|K_PPF1, KEY_P|K_PPF1},
     {KEY_P|K_PPF2, KEY_P|K_PPF2, KEY_P|K_PPF2, KEY_P|K_PPF2},
     {KEY_P|K_PPF3, KEY_P|K_PPF3, KEY_P|K_PPF3, KEY_P|K_PPF3},
     {KEY_P|K_PPF4, KEY_P|K_PPF4, KEY_P|K_PPF4, KEY_P|K_PPF4},    
     {KEY_P|K_P7, KEY_P|K_P7, KEY_P|K_P7, KEY_P|K_P7},
     {KEY_P|K_P8, KEY_P|K_P8, KEY_P|K_P8, KEY_P|K_P8},
     {KEY_P|K_P9, KEY_P|K_P9, KEY_P|K_P9, KEY_P|K_P9},
     {KEY_P|K_P4, KEY_P|K_P4, KEY_P|K_P4, KEY_P|K_P4},
     {KEY_P|K_P5, KEY_P|K_P5, KEY_P|K_P5, KEY_P|K_P5},
     {KEY_P|K_P6, KEY_P|K_P6, KEY_P|K_P6, KEY_P|K_P6},
     {KEY_P|K_P1, KEY_P|K_P1, KEY_P|K_P1, KEY_P|K_P1},
     {KEY_P|K_P2, KEY_P|K_P2, KEY_P|K_P2, KEY_P|K_P2},
     {KEY_P|K_P3, KEY_P|K_P3, KEY_P|K_P3, KEY_P|K_P3},
     {KEY_P|K_P0, KEY_P|K_P0, KEY_P|K_P0, KEY_P|K_P0},
     {KEY_P|K_PDOT, KEY_P|K_PDOT, KEY_P|K_PDOT, KEY_P|K_PDOT},
     {KEY_P|K_PENT, KEY_P|K_PENT, KEY_P|K_PENT, KEY_P|K_PENT},  /* keycode 0x72 */
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
     {0, 0, 0, 0},
};

int  keys(keycode, kbstat)
int  keycode,kbstat;

{
     register  int  keyindex;

     keyindex = (keycode & 0xff00) >> 8;
     if (kbstat == 0) {
          if (Kbshift(-1) & 0x10) {
               return(key[keyindex].caps);
          } else {
               return(key[keyindex].normal);
          }
     } else if (kbstat & 0x4) {
          return(key[keyindex].control);
     } else if ((kbstat & 0x1) || (kbstat & 0x2)) {
          return(key[keyindex].shifted);
     }
     return(0);     /* Illegale Shift (alternate) */
}

          
          

