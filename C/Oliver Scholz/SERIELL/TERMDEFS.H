/*
 * TERMDEFS.H
 * Definitionen fÅr TT44TT
 * Copyright (c) 1991 by MAXON Computer
 * Autoren: Oliver Scholz & Uwe Hax
 */

/* Alarmboxen */

#define APP_NOT_STARTED "[3][Applikation konnte nicht|initialisiert werden!][ Ok ]"
#define NO_WINDOW       "[1][Es konnte kein weiteres|Fenster mehr geîffnet werden!][ Ok ]"
#define INF_WRERR       "[1][Kann INF-Datei nicht schreiben][OK]"
#define INF_RDERR       "[1][Kann INF-Datei nicht lesen!][OK]"

/* allgemeine Definitionen */

#define TRUE          1
#define FALSE         0
#define DESKTOP       0
#define EOS           0
#define HORIZONTAL    1
#define VERTICAL      0
#define CURSOR_OFF    0
#define CURSOR_ON     1
#define SCROLL_UP     0
#define SCROLL_DOWN   1

#define CHAR          char
#define _sysbase      0x4F2L

/* Terminal-Definitionen */

#define TERM_WIDTH    80
#define TERM_HEIGHT   25
#define WAITING       0

/* ASCII Codes */

#define BELL          7
#define BACKSPACE     8
#define TAB           9
#define LF            10
#define CR            13
#define ESCAPE        27
#define DELETE        127

/* Handshakearten fÅr rsconf() */

#define P_NONE  0
#define P_XON   1
#define P_RTS   2

/* Default UCR: 8N1 */

#define DEFUCR  0x88

/* verschiedene Makros */

#define show_mouse()  graf_mouse(M_ON,0L)
#define hide_mouse()  graf_mouse(M_OFF,0L)
#define min(a,b)      ((a)<(b) ? (a) : (b))
#define max(a,b)      ((a)>(b) ? (a) : (b))

/* Typdefinitionen */

typedef struct {  /* Einstellung eines Ports */
    int baudrate;
    int flowctrl;
    int ucr;
} CONF_RS;

typedef struct {  /* alte Porteinstellung */
    int iflow;
    int idata;
    int istop;
    int ipar;
} OLDSET;

typedef struct { /* Virtuelles Terminal */
        CHAR screen[TERM_HEIGHT][TERM_WIDTH+1];
        WORD x,y;
        WORD escape; 
        BYTE auxiliary;
        WORD tmp_x,tmp_y;
} TERMINAL;

typedef struct { /* Fensterinformationen */
  WORD handle;
  CHAR title[TERM_WIDTH];
  CHAR info[TERM_WIDTH];
  WORD x,y,w,h;
  WORD fulled;
  WORD x_corner,y_corner;
} WINDOW;
