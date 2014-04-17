/* menu_att.c - AES 4.0 menu_attach() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* menu_attach(): attach, change, remove or inquire a submenu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1 for success, AESFAIL (0) for any error.
 */
int
menu_attach(int set, OBJECT *tree, int item, MENU *mdata)
{
	if (!isAES33()) return AESERR;

	int_in[0] = set;
	int_in[1] = item;
	addr_in[0] = tree;
	addr_in[1] = mdata;
	return aes(MENU_ATTACH);
}

