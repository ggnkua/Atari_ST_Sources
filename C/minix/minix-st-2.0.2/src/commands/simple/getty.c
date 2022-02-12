/* getty - get tty speed			Author: Fred van Kempen */

/*
 * GETTY  -     Initialize and serve a login-terminal for INIT.
 *		Also, select the correct speed. The STTY() code
 *		was taken from stty(1).c; which was written by
 *		Andrew S. Tanenbaum.
 *
 * Usage:	getty [-c filename] [-h] [-k] [-t] line [speed]
 *
 * Version:	3.4	02/17/90
 *
 * Author:	F. van Kempen, MicroWalt Corporation
 *
 * Modifications:
 *		All the good stuff removed to get a minimal getty, because
 *		many modems don't like all that fancy speed detection stuff.
 *		03/03/91	Kees J. Bot (kjb@cs.vu.nl)
 *
 *		Uname(), termios.  More nonsense removed.  (The result has
 *		only 10% of the original functionality, but a 10x chance of
 *		working.)
 *		12/12/92	Kees J. Bot
 *
 *		Customizable login banner.
 *		11/13/95	Kees J. Bot
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/utsname.h>

char LOGIN[] =		"/usr/bin/login";
char SHELL[] =		"/bin/sh";

#define ST_IDLE			 44	/* the getty is idle */
#define ST_RUNNING		 55	/* getty is now RUNNING */
#define ST_SUSPEND		 66	/* getty was SUSPENDed for dialout */


int state = ST_IDLE;		/* the IDLE/SUSPEND/RUNNING state flag */
char *tty_name;			/* name of the line */


/* Crude indication of a tty being physically secure: */
#define securetty(dev)		((unsigned) ((dev) - 0x0400) < (unsigned) 8)


void sigcatch(int sig)
{
/* Catch the signals that want to catch. */

  switch(sig) {
  case SIGUSR1:	/* SIGUSR1 means SUSPEND */
	if (state == ST_IDLE) state = ST_SUSPEND;
	break;
  case SIGUSR2:	/* SIGUSR2 means RESTART */
	if (state == ST_SUSPEND) state = ST_RUNNING;
	break;
  }
}


void std_out(char *s)
{
  write(1, s, strlen(s));
}


/* Read one character from stdin.
 */
int areadch(void)
{
  int st;
  char ch1;

  /* read character from TTY */
  st = read(0, &ch1, 1);
  if (st == 0) {
	std_out("\n");
	exit(0);
  }
  if (st < 0) {
	if (errno == EINTR) return(-1);		/* SIGNAL received! */
	if (errno != EINTR) {
		std_out("getty: ");
		std_out(tty_name);
		std_out(": read error\n");
		pause();
		exit(1);
	}
  }

  return(ch1 & 0xFF);
}


/* Handle the process of a GETTY.
 */
void do_getty(char *name, size_t len, char **args)
{
  register char *np, *s, *s0;
  int ch;
  struct utsname utsname;
  char **banner;
  static char *def_banner[] = { "%s  Release %r Version %v\n\n%n login: ", 0 };

  /* Default banner? */
  if (args[0] == NULL) args = def_banner;

  /* Display prompt. */
  ch = ' ';
  *name = '\0';
  while (ch != '\n') {
	/* Get data about this machine. */
	uname(&utsname);

	/* Print the banner. */
	for (banner = args; *banner != NULL; banner++) {
		std_out(banner == args ? "\n" : " ");
		s0 = *banner;
		for (s = *banner; *s != 0; s++) {
			if (*s == '\\') {
				write(1, s0, s-s0);
				s0 = s+2;
				switch (*++s) {
				case 'n':  std_out("\n"); break;
				case 's':  std_out(" "); break;
				case 't':  std_out("\t"); break;
				case 0:	   goto leave;
				default:   s0 = s;
				}
			} else
			if (*s == '%') {
				write(1, s0, s-s0);
				s0 = s+2;
				switch (*++s) {
				case 's':  std_out(utsname.sysname); break;
				case 'n':  std_out(utsname.nodename); break;
				case 'r':  std_out(utsname.release); break;
				case 'v':  std_out(utsname.version); break;
				case 'm':  std_out(utsname.machine); break;
				case 'p':  std_out(utsname.arch); break;
#if __minix_vmd
				case 'k':  std_out(utsname.kernel); break;
				case 'h':  std_out(utsname.hostname); break;
				case 'b':  std_out(utsname.bus); break;
#endif
				case 0:	   goto leave;
				default:   s0 = s-1;
				}
			}
		}
	    leave:
		write(1, s0, s-s0);
	}

	np = name;
	while (ch != '\n') {
		ch = areadch();	/* adaptive READ */
		switch (ch) {
		    case -1:	/* signalled! */
			if (state == ST_SUSPEND) {
				while (state != ST_IDLE) {
					pause();
					if (state == ST_RUNNING)
							state = ST_IDLE;
				}
			}
			ch = ' ';
			continue;
		    case '\n':
			*np = '\0';
			break;
		    default:
			if (np < name + len) *np++ = ch;
		}
	}
	if (*name == '\0') ch = ' ';	/* blank line typed! */
  }
}


/* Execute the login(1) command with the current
 * username as its argument. It will reply to the
 * calling user by typing "Password: "...
 */
void do_login(char *name)
{ 
  struct stat st;

  execl(LOGIN, LOGIN, name, (char *) NULL);
  /* Failed to exec login.  Impossible, but true.  Try a shell, but only if
   * the terminal is more or less secure, because it will be a root shell.
   */
  std_out("getty: can't exec ");
  std_out(LOGIN);
  std_out("\n");
  if (fstat(0, &st) == 0 && S_ISCHR(st.st_mode) && securetty(st.st_rdev)) {
	execl(SHELL, SHELL, (char *) NULL);
  }
}


int main(int argc, char **argv)
{
  register char *s;
  char name[30];
  struct sigaction sa;

  /* Don't let QUIT dump core. */
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = 0;
  sa.sa_handler = exit;
  sigaction(SIGQUIT, &sa, NULL);

  tty_name = ttyname(0);
  if (tty_name == NULL) {
	std_out("getty: tty name unknown\n");
	pause();
	return(1);
  }

  chown(tty_name, 0, 0);	/* set owner of TTY to root */
  chmod(tty_name, 0600);	/* mode to max secure */

  /* Catch some of the available signals. */
  sa.sa_handler = sigcatch;
  sigaction(SIGUSR1, &sa, NULL);
  sigaction(SIGUSR2, &sa, NULL);

  do_getty(name, sizeof(name), argv+1);	/* handle getty() */
  name[29] = '\0';		/* make sure the name fits! */

  do_login(name);		/* and call login(1) if OK */

  return(1);			/* never executed */
}
