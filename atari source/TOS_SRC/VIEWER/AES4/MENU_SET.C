/* menu_set.c - AES 4.0 menu_settings() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* menu_settings(): set or inquire submenu delays and scroll height.
 *-----------------------------------------------------------------------
 * If set == 0, returns current values in *values.
 * if set == 1, sets all values in *values which aren't set to -1.
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1.
 */
int
menu_settings(int set, MN_SET *values)
{
	if (!isAES33()) return AESERR;

	int_in[0] = set;
	addr_in[0] = values;
	return aes(MENU_SETTINGS);
}
