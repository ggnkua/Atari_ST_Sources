/*****************************************************************************
 *
 * Module : RBOBJ.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 14.12.90
 * Last modification: 16.08.95
 *
 *
 * Description: This module defines a radio button object
 *
 * History:
 * 16.08.95: Variable bk_color added in RBOBJ
 * 14.12.90: Creation of body
 *****************************************************************************/

#ifndef __RBOBJ__
#define __RBOBJ__

/****** DEFINES **************************************************************/

/* RADIO BUTTON OBJECT messages */

#define RB_INIT             1
#define RB_EXIT             2
#define RB_CLEAR            3
#define RB_DRAW             4
#define RB_SHOWCURSOR       5
#define RB_HIDECURSOR       6
#define RB_KEY              7
#define RB_CLICK            8

/* RADIO BUTTON OBJECT flags */

#define RB_OUTPUT      0x0001   /* output field, not editable */

/* RADIO BUTTON OBJECT errors & warnings */

#define RB_OK               0
#define RB_WRONGMESSAGE    -1
#define RB_GENERAL         -2
#define RB_BUFFERCHANGED   -3
#define RB_CHARNOTUSED     -4

/****** TYPES ****************************************************************/

typedef struct
{
  WINDOWP window;               /* parent window of radio button object */
  RECT    pos;                  /* position & size of first button */
  WORD    selected;             /* which button is selected */
  WORD    cursor;               /* on which button is the cursor */
  WORD    buttons;              /* number of radio buttons */
  BOOLEAN curs_hidden;          /* true, if cursor is hidden */
  WORD    color;                /* radio button color */
  WORD    bk_color;             /* radio button background color */
  UWORD   flags;                /* radio buuton flags */
} RBOBJ;

typedef RBOBJ *RBOBJP;          /* pointer to checkbox object */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD rb_obj _((RBOBJP rbobj, WORD message, WORD wparam, MKINFO *mk));

#endif /* __RBOBJ__ */

