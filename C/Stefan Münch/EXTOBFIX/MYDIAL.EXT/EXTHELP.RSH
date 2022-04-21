/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "EXTHELP.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

BYTE *rs_frstr[] =
{ "[0][Exitbutton:|%d = \047%s\047][[Abbruch|%s|[Weiter]",
  "[0][Exitbutton:|%d = \047%s\047][[Abbruch|[Weiter]",
  "Zeichenauswahl",
  "[3D an",
  "[3D aus"
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 HELP_EXTEND ****************************************************/
        -1,        1,       20, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|DRAW3D, (LONG)0x00021100L,
  0x0000, 0x0000, 0x003A, 0x0016,
         2,       -1,       -1, G_IBOX    |0x1100,   /* Object 1  */
  TOUCHEXIT, CROSSED|OUTLINED|DRAW3D, (LONG)0x00FF1101L,
  0x0038, 0x0000, 0x0002, 0x0001,
         3,       -1,       -1, G_BUTTON  |0x1300,   /* Object 2  */
  NONE, DRAW3D, (LONG)"Hilfe \201ber erweiterte MyDial-Objekttypen",
  0x0002, 0x0001, 0x0036, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Mover        : 17, TOUCHEXIT",
  0x0002, 0x0003, 0x001C, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"FlyDial-Ecke : zus\204tzlich IBOX, OUTLINED, CROSSED",
  0x0002, 0x0004, 0x0031, 0x0001,
         6,       -1,       -1, G_STRING  |0x1300,   /* Object 5  */
  NONE, DRAW3D, (LONG)"Tastaturbedienbare Objekte",
  0x0002, 0x0006, 0x001A, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Radiobutton  : 18, BUTTON oder STRING, RBUTTON",
  0x0002, 0x0008, 0x002E, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Checkbox     : 18, BUTTON (!RBUTTON, !EXIT, !SHADOWED)",
  0x0002, 0x0009, 0x0036, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"Popupbutton  : 18, BUTTON, SHADOWED (!RBUTTON, !EXIT)",
  0x0002, 0x000A, 0x0035, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"Exitbutton   : 18, BUTTON oder (BOX)TEXT, (TOUCH)EXIT",
  0x0002, 0x000B, 0x0035, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"String       : 18, STRING (!RBUTTON, !EXIT)",
  0x0002, 0x000C, 0x002B, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"Popuptext    : 24, STRING",
  0x0002, 0x000D, 0x0019, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"Undobutton   : zus\204tzlich noch ob_flags Bit 11 setzen",
  0x0002, 0x000E, 0x0035, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"Unterstrichen: 19, STRING oder BUTTON",
  0x0002, 0x0010, 0x0025, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"Boxtitel     : 20, BUTTON",
  0x0002, 0x0011, 0x0019, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"Helpbutton   : 21",
  0x0002, 0x0012, 0x0011, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"Circlebutton : 22, BOXCHAR",
  0x001C, 0x0012, 0x001A, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"Undobutton   : 31",
  0x0002, 0x0013, 0x0011, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, NORMAL, (LONG)"Sliderobjekt : 25",
  0x001C, 0x0013, 0x0011, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"Popuptext    : 23",
  0x0002, 0x0014, 0x0011, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x1200,   /* Object 20  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, DRAW3D, (LONG)"[OK",
  0x002F, 0x0014, 0x0009, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 HELP_EXTEND */
};
