#include <wx_lib.h>
#include <alloc.h>
#include <string.h>

/*
 * This function sets the window's name line to the contents of the string that
 * is passed to it.  The string is copied into an internally allocated buffer,
 * which is free()'d if non-NULL, that way we won't see any horrible memory
 * leakage.
 *
 * Arguments:	The Window structure and a pointer to a NULL-terminated string.
 * Returns:		TRUE if the assignment was successful, FALSE if not.
 */
int		wx_info(ws,sp)
Window	*ws;
char	*sp;
{
	/*
	 * If the buffer's pointer is non-NULL, free that section of memory, so we
	 * can allocate another buffer of the proper size.
	 */
	if (ws->info != NULL) {
		free(ws->info);
	}
	/*
	 * If we're succesful at allocating a new buffer, copy the string into it,
	 * set the Window's name pointer to the string, and return a non-error
	 * condition.
	 */
	if ((ws->info = malloc(strlen(sp) + 1)) != NULL) {
		strcpy(ws->info,sp);
		wind_set(ws->hand,WF_INFO,ws->info);
		return TRUE;
	} else {
		/*
		 * The malloc() failed, and so we need to report the error.
		 */
		return FALSE;
	}
}
