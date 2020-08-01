/*
 * MAC_API.C
 *
 * Set TABs to 4 */

#include <tos.h>
#include "MGMC_API.H"
#include "MAC_API.H"

extern MgMcCookie *gMgMcCookie;		/* declared in DEMOMAIN.C */


/*
 * ExecuteMacFunction
 * ------------------
 *   Executes a routine in Mac mode.
 *   To be called from ATARI mode, either in user or supervisor mode.
 *   Parameters and results can only be passed via global variables.
 *   This function is not reentrant and may not be called from interrupts!
 */

static VoidProcPtr gMacFuncToExec;

static long execMacFuncSub (void)
/* helper function for "ExecuteMacFunction" (see below) */
{
	gMgMcCookie->modeMac ();	/* be careful - you cannot trace into this function with the debugger! */
	gMgMcCookie->callMacContext (gMacFuncToExec);
	gMgMcCookie->modeAtari ();	/* be careful - you cannot trace into this function with the debugger! */
	return 0;	/* dummy */
}

void ExecuteMacFunction (VoidProcPtr theFunction)
{
	gMacFuncToExec = theFunction;
	Supexec (execMacFuncSub);
}


/* EOF */
