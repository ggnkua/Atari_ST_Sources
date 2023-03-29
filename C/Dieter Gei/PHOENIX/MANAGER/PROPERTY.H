/*****************************************************************************
 *
 * Module : PROPERTY.H
 * Author : Dieter Geiž
 *
 * Creation date    : 09.10.95
 * Last modification:
 *
 *
 * Description: This module defines the property window.
 *
 * History:
 * 20.01.04: PropertyPos added
 * 12.11.95: PN_SYSMBOL and PN_ELLIPSIS added
 * 08.11.95: PN_READONLY, PN_GETVALS, and PN_RELVALS added
 * 01.11.95: PropertyGetAssocWindow added
 * 22.10.95: PropertyCloseAssocWindow added
 * 19.10.95: PropertySetProps added
 * 09.10.95: Creation of body
 *****************************************************************************/

#ifndef __PROPERTY__
#define __PROPERTY__

/****** DEFINES **************************************************************/

#define CLASS_PROPERTY		27	/* Class Property Window */

#define PN_GETNAME		0	/* property notification: get name of property */
#define PN_GETVALUE		1	/* property notification: get value of property */
#define PN_SETVALUE		2	/* property notification: set value of property */
#define PN_READONLY		3	/* property notification: get readonly flag */
#define PN_GETVALS		4	/* property notification: get all values */
#define PN_RELVALS		5	/* property notification: release all values */
#define PN_SYMBOL			6	/* property notification: draw arrow */
#define PN_ELLIPSIS		7	/* property notification: ellipsis pressed */

#define PROPSYS_NOSYMBOL	0	/* no symbol at all */
#define PROPSYM_ARROW		1	/* arrow symbol */
#define PROPSYS_ELLISPIS	2	/* ellipsis symbol */

/****** TYPES ****************************************************************/

typedef LONG (CALLBACK *PROPFUNC) (INT msg, WINDOWP window, LONG item, CHAR *p);

/****** VARIABLES ************************************************************/

/* [GS] 5.1d; Start */
GLOBAL RECT PropertyPos;								/* Position des Property-Fenster 		 */
/* Ende */

/****** FUNCTIONS ************************************************************/

GLOBAL BOOL    PropertyInit             (VOID);
GLOBAL BOOL    PropertyTerm             (VOID);

GLOBAL WINDOWP PropertyCreate           (OBJECT *obj, OBJECT *menu, WORD icon);

GLOBAL BOOL    PropertyOpen             (WORD icon);
GLOBAL BOOL    PropertyInfo             (WINDOWP window, WORD icon);
GLOBAL BOOL    PropertyHelp             (WINDOWP window, WORD icon);

GLOBAL VOID    PropertySetProps         (WINDOWP window, WINDOWP pSrcWnd, LONG lCount, PROPFUNC propfunc);
GLOBAL VOID    PropertyCloseAssocWindow (WINDOWP window);
GLOBAL WINDOWP PropertyGetAssocWindow   (VOID);

#endif /* __PROPERTY__ */

