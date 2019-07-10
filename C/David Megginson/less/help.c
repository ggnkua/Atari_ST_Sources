#include  "less.h"

/*
 * Display some help.
 * Just invoke another "less" to display the help file.
 *
 * {{ This makes this function very simple, and makes changing the
 *    help file very easy, but it may present difficulties on
 *    (non-Unix) systems which do not supply the "system()" function. }}
 */

	public void
help()
{
	char cmd[FILENAME+100];

	sprintf(cmd, 
	 "-less -m '-PmHELP -- ?eEND -- Press g to see it again:Press RETURN for more., or q when done ' %s",
	 HELPFILE);
	lsystem(cmd);
	error("End of help");
}
