/*****************************************************************************
 *
 * Module : MASKDRAW.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 14.12.90
 * Last modification: 11.08.95
 *
 *
 * Description: This module defines the drawing functions for a mask window.
 *
 * History:
 * 11.08.95: IndexFromColor32 made global
 * 17.01.95: Parameter window changed to mask_spec in all interface functions
 * 20.11.94: Function draw_sm added
 * 14.12.90: Creation of body
 *****************************************************************************/

#ifndef __MASKDRAW__
#define __MASKDRAW__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/


GLOBAL VOID  draw_mask        (MASK_SPEC *mask_spec, WORD out_handle);
GLOBAL VOID  draw_sm          (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD sub);
GLOBAL SHORT IndexFromColor32 (LONG lColor);

#endif /* __MASKDRAW__ */

