/* get chars from keyboard and put them to rs232 */

#include <sys/types.h>
#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include "const.h"

#define EOT '\004'	/* ^D */
char err_buf[BUFSIZ];
char **envptr;

#ifdef __STDC__
void cleanup(int foo)
#else
int cleanup()
#endif
{
  fprintf(stderr, "writer stopped\n");
  fflush(stderr);

  exit(0);
}

/* passed the escape char, reader pid as args */
main(argc, argv, envp)
int argc;
char **argv;
char **envp;
{
  char ch;
  char esc = *argv[1]; /* no errchk */
  int r_pid = atoi(argv[2]);
  char was_newline = TRUE;

  envptr = envp;
  signal(SIGINT,  SIG_IGN);
  signal(SIGQUIT, SIG_IGN);
  signal(SIGTERM, cleanup);

  setbuf(stderr, err_buf);

  fprintf(stderr, "writer started\n");
  fflush(stderr);

  while (TRUE) {
	read(0, &ch, 1);
	ch &= (char)0177;
	
	if (was_newline) {
		if (ch == esc) {
			read(0, &ch, 1);
			ch &= (char)0177;
			
			switch (ch) {

			case EOT:
			case '.':
				cleanup(1);  /* go home! */

			case '!':
				/* tell read_tty to cool off */
				kill(r_pid, SIGALRM);
				do_shell();
				/* wake him up again */
				kill(r_pid, SIGALRM);
			break;

			default:
				if(ch != esc)
				{
				    fprintf(stderr, "invalid command--use\
 \"~~\" to start a line with \"~\"\n");
				    fflush(stderr);
				}
				
			}
		}
	}			

	if (ch == '\r')
		was_newline = TRUE;
	else
		was_newline = FALSE;

	write(1, &ch, 1);
  }
}
