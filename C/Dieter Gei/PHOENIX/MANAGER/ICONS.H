/*****************************************************************************
 *
 * Module : ICONS.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.12.93
 * Last modification: 01.12.93
 *
 *
 * Description: This module defines the the initialization for common dialog icons.
 *
 * History:
 * 01.12.93: Creation of body
 *****************************************************************************/

#ifndef __ICONS__
#define __ICONS__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN    InitIcons               (VOID);
GLOBAL BOOLEAN    TermIcons               (VOID);

GLOBAL ICONSUFFIX *IconsGetIconSuffixes   (VOID);
GLOBAL WORD       IconsGetNumIconSuffixes (VOID);

#endif /* __ICONS__ */

