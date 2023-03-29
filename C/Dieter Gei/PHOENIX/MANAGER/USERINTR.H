/*****************************************************************************
 *
 * Module : USERINTR.H
 * Author : Dieter Geiž
 *
 * Creation date    : 03.10.93
 * Last modification: 13.11.93
 *
 *
 * Description: This module defines the user interface dialog box.
 *
 * History:
 * 13.11.93: Parameters in init_userinterface added
 * 03.10.93: Creation of body
 *****************************************************************************/

#ifndef __USERINTR__
#define __USERINTR__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_userinterface   (WORD err_no_open, BYTE **color_strings, BYTE **index_strings, BYTE **check_strings, BYTE **radio_strings, BYTE **arrow_strings);
GLOBAL BOOLEAN term_userinterface   (VOID);

GLOBAL VOID    userinterface_dialog (BYTE *title, BYTE *help_id);

#endif /* __USERINTR__ */

