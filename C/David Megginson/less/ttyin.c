/*
 * Routines dealing with getting input from the keyboard (i.e. from the user).
 */

#include "less.h"

static int tty;

/*
 * Open keyboard for input.
 * (Just use file descriptor 2.)
 */
	public void
open_getchr()
{
	tty = 2;
}

/*
 * Get a character from the keyboard.
 */
	public int
getchr()
{
	char c;
	int result;

	do
	{
		result = iread(tty, &c, 1);
		if (result == READ_INTR)
			return (READ_INTR);
		if (result < 0)
		{
			/*
			 * Don't call error() here,
			 * because error calls getchr!
			 */
			quit();
		}
	} while (result != 1);
	return (c & 0177);
}
