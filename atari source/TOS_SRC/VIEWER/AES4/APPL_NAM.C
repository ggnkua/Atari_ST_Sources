/* appl_nam.c - appl_name() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* appl_name(): set application appl_find() name.
 *-----------------------------------------------------------------------
 * This function works on all AES versions.
 */
void
appl_name(const char *name)
{
	int_in[0] = -1;
	addr_in[0] = (char *)name;
	aes(MENU_REGISTER);
}
