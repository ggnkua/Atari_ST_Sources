/* appl_reg.c - AES 4.0 appl_register() function
 *=======================================================================
 * 920630 kbad
 */
#include "aes4.h"
#include "_aes.h"

/* appl_register(): set application name in the desk menu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns menu item index, or AESERR if no room on the menu.
 * NOTE: like menu_register(), the string passed to this function
 *	must not be a stack-allocated variable, as the AES doesn't copy
 *	the string, it only keeps the pointer.
 */
int
appl_register(const char *name)
{
	if (!isAES4()) return AESERR;

	int_in[0] = GL_APID;
	addr_in[0] = (char *)name;
	return aes(MENU_REGISTER);
}
