/**************************************************************************
 * BRACTION - The default useraction handler for a browser.
 *
 *	Pity I never finished this concept.
 *************************************************************************/

#include <gemfast.h>
#include <osbind.h>

#define BROWSER_INTERNALS
#include "browser.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE	1
  #define FALSE 0
#endif

int __br_action(browser, action, lparm)
	Browser *browser;
	int 	action;
	long	lparm;
{
	switch (action) {
	  case BR_KEYSTROKE:
	  case BR_SEARCHSTR:
	  case BR_PREDELETE:
		break;
	}
	return TRUE;
}

