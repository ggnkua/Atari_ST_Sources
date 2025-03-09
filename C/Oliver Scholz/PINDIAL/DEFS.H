/*
 * DEFS.H
 * verschiedene Definitionen
 * by Oliver Scholz
 * (c) 1991 MAXON Computer
 */
 
#define ABOUT_PRG           "[1][| Pinbare Dialoge | Demonstration | by Oliver Scholz | (c) 1991 MAXON Computer ][ OK ]"
#define APP_NOT_STARTED     "[3][| Applikation konnte nicht initialisiert werden!][ Schade ]"
#define NO_WINDOW           "[3][| Kein Fenster mehr da!][ OK ]"
#define DIAL_ERR            "[2][| Hier kann der Dialog | nicht abgelegt werden! ][ OK ]"

#define DESKTOP   0
#define TRUE      1
#define FALSE     0
#define ELEMENTS  NAME | MOVER | SIZER
 
/* nÅtzliche Macros */

#define SHOW_MOUSE      graf_mouse(M_ON,0L)
#define HIDE_MOUSE      graf_mouse(M_OFF,0L)
#define min(a,b)      ((a)<(b) ? (a) : (b))
#define max(a,b)      ((a)>(b) ? (a) : (b))

/* Schriftarten */

#define PICA    0
#define ELITE   1
#define TIMES   2

/* globaler Status f. Zeichensatz u. Attribute */

typedef struct
{
    WORD font;
    WORD kursiv;
    WORD fett;
    WORD leicht;
    WORD unterstrichen;
} STATUS;

typedef struct /* Fensterinformationen */
{ 
  WORD handle;
  WORD x,y,w,h;
} WINDOW;
