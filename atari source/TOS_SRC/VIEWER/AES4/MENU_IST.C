/* menu_ist.c - AES 4.0 menu_istart() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* menu_istart(): set or inquire the starting menu item of a submenu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns the submenu start item if successful,
 * or AESFAIL (0) on any error.
 */
int
menu_istart(int set, OBJECT *tree, int imenu, int istart)
{
	if (!isAES33()) return AESERR;

	int_in[0] = set;
	int_in[1] = imenu;
	int_in[2] = istart;
	addr_in[0] = tree;
	return aes(MENU_ISTART);
}
