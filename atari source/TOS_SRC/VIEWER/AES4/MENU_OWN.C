/* menu_own.c - AES 4.0 menu_owner() and menu_bar() functions
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

static WORD showing = 0;

/* menu_bar() is here so that menu_owner() works on AES < 4.0 */
int
menu_bar(OBJECT *m, int show)
{
	showing = int_in[0] = show;
	addr_in[0] = m;
	return aes(MENU_BAR);
}

/* menu_owner(): return the AES id of the current menu owner, or -1 if none.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns GL_APID if your menu is showing, else AESERR (-1).
 * On AES >= 4.0, returns the result of menu_bar(-1,NULL):
 * the apid of the current menu owner, or AESERR (-1).
 */
int
menu_owner(void)
{
	if (isAES4()) return menu_bar(NULL,-1);
	return (showing) ? GL_APID : AESERR;
}
