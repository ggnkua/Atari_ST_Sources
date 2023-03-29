/*****************************************************************************
 *
 * Module : CBOBJ.H
 * Author : Jrgen Geiž
 *
 * Creation date    : 14.12.90
 * Last modification: 16.08.95
 *
 *
 * Description: This module defines a checkbox object
 *
 * History:
 * 16.08.95: Variable bk_color added in CBOBJ
 * 14.12.90: Creation of body
 *****************************************************************************/

#ifndef __CBOBJ__
#define __CBOBJ__

/****** DEFINES **************************************************************/

/* CHECKBOX OBJECT messages */

#define CB_INIT             1
#define CB_EXIT             2
#define CB_CLEAR            3
#define CB_DRAW             4
#define CB_SHOWCURSOR       5
#define CB_HIDECURSOR       6
#define CB_KEY              7
#define CB_CLICK            8

/* CHECKBOX OBJECT flags */

#define CB_OUTPUT      0x0001   /* output field, not editable */

/* CHECKBOX OBJECT errors & warnings */

#define CB_OK               0
#define CB_WRONGMESSAGE    -1
#define CB_GENERAL         -2
#define CB_BUFFERCHANGED   -3
#define CB_CHARNOTUSED     -4

/****** TYPES ****************************************************************/

typedef struct
{
  WINDOWP window;               /* parent window of checkbox object */
  RECT    text;                 /* position & size of text */
  RECT    box;                  /* position & size of check box */
  BOOLEAN selected;             /* TRUE => box is selected */
  BOOLEAN curs_hidden;          /* true, if cursor is hidden */
  WORD    color;                /* checkbox color */
  WORD    bk_color;             /* checkbox background color */
  UWORD   flags;                /* checkbox flags */
} CBOBJ;

typedef CBOBJ *CBOBJP;          /* pointer to checkbox object */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD cb_obj _((CBOBJP cbobj, WORD message, WORD wparam, MKINFO *mk));

#endif /* __CBOBJ__ */

