/*
 * MAC_API.H
 *
 * Call interface to Mac mode
 */


/*
 * ExecuteMacFunction
 * ------------------
 *   Executes a routine in Mac mode.
 *   To be called from ATARI mode, either in user or supervisor mode.
 *   Parameters and results can only be passed via global variables.
 *   This function is not reentrant and may not be called from interrupts!
 */
void ExecuteMacFunction (VoidProcPtr theFunction);


/* EOF */
