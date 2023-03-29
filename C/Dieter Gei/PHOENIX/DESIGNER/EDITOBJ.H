/*****************************************************************************
 *
 * Module : EDIT.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 27.04.94
 *
 *
 * Description: This module defines the editor window.
 *
 * History:
 * 27.04.94: ED_GETCLIPBUF, ED_CLEARCLIPBUF deleted
 * 25.04.94: ED_USEPOS added
 * 20.04.94: ED_CANUNDO,...,ED_CANSELALL added
 * 19.04.94: ED_PASTEBUF, ED_GETCLIPBUF, ED_CLEARCLIPBUF added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __EDITOBJ__
#define __EDITOBJ__

/****** DEFINES **************************************************************/

/* EDIT OBJECT messages */

#define ED_INIT              1
#define ED_EXIT              2
#define ED_CLEAR             3
#define ED_DRAW              4
#define ED_SHOWCURSOR        5
#define ED_HIDECURSOR        6
#define ED_KEY               7
#define ED_CLICK             8
#define ED_CUT               9
#define ED_COPY             10
#define ED_PASTE            11
#define ED_PASTEBUF         12
#define ED_SELALL           13
#define ED_SETCURSOR        14
#define ED_UP               15  /* scroll text up */
#define ED_DOWN             16
#define ED_LEFT             17
#define ED_RIGHT            18
#define ED_SELECTED         19  /* text selected? */
#define ED_STRLEN           20  /* string len in characters of specific line */
#define ED_STRWIDTH         21  /* string width in pixels of specific line */
#define ED_CANUNDO          22
#define ED_CANCUT           23
#define ED_CANCOPY          24
#define ED_CANPASTE         25
#define ED_CANCLEAR         26
#define ED_CANSELALL        27

/* EDIT OBJECT flags */

#define ED_MONOSPACED   0x0001  /* monospaced font */
#define ED_AUTOHSCROLL  0x0002
#define ED_AUTOVSCROLL  0x0004
#define ED_WORDBREAK    0x0008
#define ED_ALILEFT      0x0010
#define ED_ALIRIGHT     0x0020
#define ED_LINEONLAST   0x0030  /* line cursor beyond last char */
#define ED_CRACCEPT     0x0080  /* accept CR character */
#define ED_OUTPUT       0x0100  /* output field, not editable */
#define ED_NUMERIC      0x0200  /* only digits and +-., allowed */
#define ED_USEPOS       0x0400  /* use edobj->pos.h for calculating lines in pgup/down */

/* EDIT OBJECT errors & warnings */

#define ED_OK                0
#define ED_WRONGMESSAGE     -1
#define ED_GENERAL          -2
#define ED_BUFFERCHANGED    -3
#define ED_CHARNOTUSED      -4
#define ED_NOMEMORY         -5
#define ED_2MANYLINES       -6
#define ED_SHOWLINES        -7

/****** TYPES ****************************************************************/

typedef struct
{
  WINDOWP window;               /* parent window of edit object */
  RECT    pos;                  /* position & size of edit object relative to window document */
  BYTE    *text;                /* pointer to text buffer */
  LONG    *line_ptr;            /* index to start of each line */
  LONG    bufindex;             /* actual buffer index at cursor position */
  LONG    bufsize;              /* max buffer size */
  LONG    actsize;              /* actual text size */
  RECT    doc;                  /* position and width of sliders/document x = absolut, y = line number */
  WORD    cols;                 /* number of columns */
  WORD    lines;                /* number of lines */
  WORD    max_lines;            /* max number of lines */
  WORD    act_line;             /* actual line number */
  WORD    act_col;              /* actual column */
  BOOLEAN curs_hidden;          /* true, if cursor is hidden */
  LONG    cx;                   /* x cursor position relative to pos in pixel */
  LONG    cy;                   /* y cursor position relative to pos in pixel */
  BOOLEAN selected;             /* text selected? */
  LONG    sel_start;            /* index of start of selected text */
  LONG    sel_end;              /* index of end of selected text */
  WORD    font;                 /* edit font */
  WORD    point;                /* edit point size */
  WORD    color;                /* text color */
  WORD    cell_width;           /* cell width of font */
  WORD    wbox [256];           /* width box of every char for used font */
  WORD    hbox;                 /* height box of a char */
  UWORD   flags;                /* edit object flags */
} EDOBJ;

typedef EDOBJ *EDOBJP;          /* pointer to editobj */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD edit_obj _((EDOBJP edobj, WORD message, WORD wparam, VOID *p));

#endif /* __EDITOBJ__ */

