/* cd -- change working directory	Author: Thomas Brupbacher */


/* -------------------------------------------------------------------------
 * lit.: 	POSIX 1003.2/D10 section 4.5
 *
 * Thomas Brupbacher (tobr@mw.lpc.ethz.ch)	Oct 1990
 * -------------------------------------------------------------------------
 *
 * This is a new implementation of cd, written from scratch.
 * cd uses the environment variables HOME and CDPATH to determine where
 * to chdir.
 */

#include <sys/types.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void get_next_prefix, (char *string, char prefix [PATH_MAX ]));

int main(argc, argv)
int argc;
char **argv;
{
  char *string;
  char *prog = *argv;
  char prefix[PATH_MAX];
  int cdflag, cdpath_flag;

  if (argc == 1) {		/* no directory on command line, cd to home
			 * dir						 */
	string = getenv("HOME");
	if (string == NULL) {
		fprintf(stderr, "no home directory, directory not changed\n");
		return(1);
	}
  }
  if (argc > 2)			/* more than one dir on the command line */
	fprintf(stderr, "%s: ignoring arguments\n", prog);

  argv++;
  string = getenv("CDPATH");
  if (string == NULL)/* CDPATH not set, cd relative to .	 */
	cdflag = chdir(*argv);

  else {
	cdpath_flag = 1;
	do {
		get_next_prefix(string, prefix);
		if (prefix[0] != '\0') {
			strcat(prefix, "/");
			strcat(prefix, *argv);
			cdflag = chdir(prefix);
		}
	} while ((cdflag != 0) && (prefix[0] != '\0'));
  }

  if (cdflag != 0) {
	fprintf(stderr, "%s: cannot cd to %s\n", prog, *argv);
	return(1);
  }
  if (cdpath_flag == 1) printf("%s\n", prefix);

  return(0);
}

/* Get_next_prefix() parses the string <string> for the next : or the
 * end of <string> and copies the parsed chars to <prefix>.
 */
void get_next_prefix(string, prefix)
char *string;
char prefix[PATH_MAX];
{
  int index;

  if (*(++string) == ':')	/* CDPATH contains "::" 		 */
	prefix[index++] = ' ';
  while ((*string != ':') && (*string != '\0'))
	prefix[index++] = *(string++);
  prefix[index++] = '\0';
}
