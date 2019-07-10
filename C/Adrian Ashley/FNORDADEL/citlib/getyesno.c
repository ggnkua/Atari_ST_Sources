/*
 * getyesno.c
 *
 * 90Apr09 A&R	Created by ripping all get[Yes,No] fns from roomb.c
 */

#include "ctdl.h"
#include "citlib.h"
#include "citadel.h"	/* part of citadel, doncha know. */

/*
 * coreGetYesNo() prompts for a yes/no response from (somewhere)
 */
int
coreGetYesNo(char *prompt, int def)
{
    char c;

    do {
	iprintf("%s? (%s/%s): ", prompt,
				  (def=='Y') ? "[Y]" : "Y",
				  (def=='N') ? "[N]" : "N");
	c = toupper(getnoecho());
	if (c == '\n' && def)
	    c = def;
	mprintf("%c\r", (c>=' ') ? c : '?');
    } while (onLine() && c != 'Y' && c != 'N');
    return (c == 'Y');
}

char
getYesNo(char *prompt)
{
    return coreGetYesNo(prompt, 0);
}

char
getYes(char *prompt)
{
    return coreGetYesNo(prompt, 'Y');
}

char
getNo(char *prompt)
{
    return coreGetYesNo(prompt, 'N');
}
