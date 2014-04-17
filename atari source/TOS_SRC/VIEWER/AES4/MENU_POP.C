/* menu_pop.c - AES 4.0 menu_popup() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* menu_popup(): handle a popup menu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns AESFAIL (0) if the user didn't click on an
 * enabled item, or 1 if the information in mdata is valid.
 */
int
menu_popup(const MENU *menu, int left_x, int top_y, MENU *mdata)
{
	if (!isAES33()) return AESERR;

	int_in[0] = left_x;
	int_in[1] = top_y;
	addr_in[0] = (void *)menu;
	addr_in[1] = mdata;
	return aes(MENU_POPUP);
}
