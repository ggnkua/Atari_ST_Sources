/* from Dale Schumacher's dLibs */
/* heavily modified by ers and jrb */
/* and separated from main.c 5/5/92 sb */

#include <stddef.h>
#include <stdlib.h>
#include "lib.h"


/* register a function for execution on termination
 * Ansi requires atleast 32 entries, we make it dynamic and hope
 * it meets the ansi requirement
 */
 
extern ExitFn *_at_exit;
extern int _num_at_exit;
int atexit(ExitFn func)
{
	ExitFn *new_at_exit = _at_exit;
    
	if (_num_at_exit == 0)
		new_at_exit = malloc(sizeof(ExitFn));
	else
		new_at_exit = realloc(new_at_exit, (size_t)((_num_at_exit + 1) * sizeof(ExitFn)));

	if (new_at_exit == NULL)
		/* failure */
		return -1;

	_at_exit = new_at_exit;
	_at_exit[_num_at_exit++] = func;

	/* success */
	return 0;
}
