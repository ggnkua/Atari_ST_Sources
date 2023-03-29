/*****************************************************************************
 *
 * Module : SELECT.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 10.09.93
 *
 *
 * Description: This module defines the selection dialog box.
 *
 * History:
 * 10.09.93: New 3d listbox added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __SELECT__
#define __SELECT__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  BYTE   *title;                 /* title of window */
  VOID   *itemlist;              /* list of items */
  SIZE_T itemsize;               /* size of one item */
  WORD   num_items;              /* number of items */
  BYTE   *boxtitle;              /* title of listbox */
  WORD   helpinx;                /* index for helpstring */
  STRING selection;              /* default input and output */
} SEL_SPEC;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_select  _((VOID));
GLOBAL BOOLEAN term_select  _((VOID));

GLOBAL BOOLEAN selection    _((SEL_SPEC *sel_spec));

#endif /* __SELECT__ */

