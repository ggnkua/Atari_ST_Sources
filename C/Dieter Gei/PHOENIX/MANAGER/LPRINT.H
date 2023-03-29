/*****************************************************************************
 *
 * Module : LPRINT.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.11.93
 *
 *
 * Description: This module defines the list printing process.
 *
 * History:
 * 04.11.93: Using fontdesc
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __LPRINT__
#define __LPRINT__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN l_print _((DB *db, WORD table, WORD inx, WORD dir, WORD cols, WORD *columns, WORD *colwidth, WORD device, FONTDESC *fontdesc, RECT *size, BYTE *filename, BOOLEAN minimize));

#endif /* __LPRINT__ */

