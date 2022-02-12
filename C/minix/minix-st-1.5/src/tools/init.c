/* This process is the father (mother) of all Minix user processes.  When
 * Minix comes up, this is process number 2, and has a pid of 1.  It
 * executes the /etc/rc shell file, and then reads the /etc/ttys file to
 * determine which terminals need a login process.  The ttys file consists
 * of three-field lines as follows:
 *	abc
 * where
 *	a = 0 (line disabled = no shell), 1 (enabled = shell started)
 *	    2 (enabled through a GETTY)
 *	b = a-r defines UART paramers (baud, bits, parity), 0 for console
 *	c = line number or line name
 *
 * The letters a-r correspond to the 18 entries of the uart table below.
 * For example, 'a' is 110 baud, 8 bits, no parity; 'b' is 300 baud, 8
 * bits, no parity; 'j' is 2400 baud, 7 bits, even parity; etc.  If the
 * third field is a digit, then the terminal device will be /dev/tty{c},
 * otherwise it will be /dev/{c}.  Note that since login cheats in
 * determining the slot number, entries in /etc/ttys must always be in
 * minor device number order - the first line should be for tty0, the
 * second for tty1, and so on.
 *
 * Example /etc/tty file (the text following # should not be in /etc/ttys)
 *	1c0	# /dev/tty0 is enabled as 1200 baud, no parity
 *	2c1	# /dev/tty1 is enabled using /etc/getty for speed detection
 *	0c2	# /dev/tty2 is disabled
 *	
 * If any of the /etc/tty entries start with a 2, the file /etc/getty must
 * be present and executable.
 *
 * If the files /usr/adm/wtmp and /etc/utmp exist and are writable, init
 * (with help from login) will maintain login accounting.  Sending a
 * signal 1 (SIGHUP) to init will cause it to reread /etc/ttys and start
 * up new shell processes if necessary.  It will not, however, kill off
 * login processes for lines that have been turned off; do this manually.
 */
#include <sys/types.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <sgtty.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <utmp.h>

#define CONSNAME	"/dev/tty0"	/* system console device */

#define SHELL1		"/bin/sh"
#define SHELL2		"/usr/bin/sh"
#define LOGIN1		"/bin/login"
#define LOGIN2		"/usr/bin/login"
#define GETTY		"/etc/getty"	/* GETTY for dial IN/OUT */

#define PIDSLOTS	8		/* maximum number of ttys entries */
#define TTYSBUF		(8 * PIDSLOTS)	/* buffer for reading /etc/ttys */
#define STACKSIZE	(192 * sizeof(char *))	/* init's stack */

#define EXIT_TTYFAIL	253		/* child had problems with tty */
#define EXIT_EXECFAIL	254		/* child couldn't exec something */
#define EXIT_OPENFAIL	255		/* child couldn't open something */

struct uart {
  int baud;
  int flags;
} uart[] = {
  B110,   BITS8,		/* 'a':  110 baud, 8 bits, no parity */
  B300,   BITS8,		/* 'b':  300 baud, 8 bits, no parity */
  B1200,  BITS8,		/* 'c': 1200 baud, 8 bits, no parity */
  B2400,  BITS8,		/* 'd': 2400 baud, 8 bits, no parity */
  B4800,  BITS8,		/* 'e': 4800 baud, 8 bits, no parity */
  B9600,  BITS8,		/* 'f': 9600 baud, 8 bits, no parity */

  B110,   BITS7 | EVENP,	/* 'g':  110 baud, 7 bits, even parity */
  B300,   BITS7 | EVENP,	/* 'h':  300 baud, 7 bits, even parity */
  B1200,  BITS7 | EVENP,	/* 'i': 1200 baud, 7 bits, even parity */
  B2400,  BITS7 | EVENP,	/* 'j': 2400 baud, 7 bits, even parity */
  B4800,  BITS7 | EVENP,	/* 'k': 4800 baud, 7 bits, even parity */
  B9600,  BITS7 | EVENP,	/* 'l': 9600 baud, 7 bits, even parity */

  B110,   BITS7 | ODDP,		/* 'm':  110 baud, 7 bits, odd parity */
  B300,   BITS7 | ODDP,		/* 'n':  300 baud, 7 bits, odd parity */
  B1200,  BITS7 | ODDP,		/* 'o': 1200 baud, 7 bits, odd parity */
  B2400,  BITS7 | ODDP,		/* 'p': 2400 baud, 7 bits, odd parity */
  B4800,  BITS7 | ODDP,		/* 'q': 4800 baud, 7 bits, odd parity */
  B9600,  BITS7 | ODDP		/* 'r': 9600 baud, 7 bits, odd parity */
};

#define NPARAMSETS (sizeof uart / sizeof(struct uart))

struct slotent {
  int onflag;			/* should this ttyslot be on? */
  int pid;			/* pid of login process for this tty line */
  int exit;			/* eit status of child */
  char name[8];			/* name of this tty */
  int flags;			/* sg_flags field for this tty */
  int speed;			/* sg_ispeed for this tty */
};

struct slotent slots[PIDSLOTS];	/* init table of ttys and pids */

char stack[STACKSIZE];		/* init's stack */
char *stackpt = &stack[STACKSIZE];
char **environ;			/* declaration required by library routines */
extern int errno;

char *CONSOLE = CONSNAME;	/* name of system console */
struct sgttyb args;		/* buffer for TIOCGETP */
int gothup = 0;			/* flag, showing signal 1 was recieved */
int pidct = 0;			/* count of running children */

char *env[] = { (char *)0 };	/* tiny environment for execle */

main()
{
  int pid;			/* pid of child process */
  int fd;			/* fd of console for error messages */
  int i;			/* loop variable */
  int status;			/* return status from child process */
  struct slotent *slotp;	/* slots[] pointer */
  void onhup();			/* SIGHUP interrupt catch routine */

  sync();			/* force buffers out onto disk */

  /* Execute the /etc/rc file. */
  if(fork()) {
	/* Parent just waits. */
	wait(&status);
  } else {
	/* Child exec's the shell to do the work. */
	if(open("/etc/rc", 0) < 0) exit(EXIT_OPENFAIL);
	dup(open(CONSOLE, 1));	/* std output, error */
	execle(SHELL1, SHELL1, (char *)0, env);
	execle(SHELL2, SHELL2, (char *)0, env);
	exit(EXIT_EXECFAIL);	/* impossible, we hope */
  }

  /* Log system reboot. */
  wtmp("reboot", "~~", "~", 0, BOOT_TIME, -1);

  /* Read the /etc/ttys file. */
  readttys();
  
  /* Main loop. If login processes have already been started up, wait for one
   * to terminate, or for a HUP signal to arrive. Start up new login processes
   * for all ttys which don't have them. Note that wait() also returns when
   * somebody's orphan dies, in which case ignore it.
   * First set up the signals.
   */

  for (i = 1; i <= _NSIG; i++) signal(i, SIG_IGN);
  signal(SIGHUP, onhup);

  while(1) {
	sync();

	if( pidct && (pid = wait(&status)) > 0 ) {
		/* Search to see which line terminated. */
		for(slotp = slots; slotp < &slots[PIDSLOTS]; ++slotp) {
			if(slotp->pid == pid) {
			    pidct--;
			    slotp->pid = 0;	/* now no login process */
			    slotp->exit = status;

			    if(((status >> 8) & 0xFF) == EXIT_TTYFAIL) {
				fd = open(CONSOLE, 1);
				write(fd, "init: tty problems, shutting down ", 39);
				write(fd, slotp->name, sizeof slotp->name);
				write(fd, "\n", 1);

				close(fd);
				slotp->onflag = 0;
			    }
			    break;
			}
	      }
	}

	/* If a signal 1 (SIGHUP) is received, reread /etc/ttys. */
	if(gothup) {
		readttys();
		gothup = 0;
	}

	/* See which lines need a login process started up. */
	for(slotp = slots; slotp < &slots[PIDSLOTS]; ++slotp) {
		if(slotp->onflag && slotp->pid <= 0)
			startup(slotp - slots, DEAD_PROCESS, LOGIN_PROCESS);
	}
  }
}

void onhup()
{
  gothup = 1;
  signal(SIGHUP, onhup);
}

readttys()
{
  /* (Re)read /etc/ttys. */

  char ttys[TTYSBUF];			/* buffer for reading /etc/ttys */
  register char *p;			/* current pos. within ttys */
  char *endp;				/* pointer to end of ttys buffer */
  int fd;				/* file descriptor for /etc/ttys */
  struct slotent *slotp = slots;	/* entry in slots[] */
  char *q;				/* pointer for copying ttyname */

  if((fd = open("/etc/ttys", 0)) < 0) {
	write(open(CONSOLE, 1), "init: can't open /etc/ttys\n", 27);
	while (1) ;		/* just hang -- system cannot be started */
  }

  /* Read /etc/ttys file. */
  endp = (p = ttys) + read(fd, ttys, TTYSBUF);
  *endp = '\n';

  /* The first character of each line on /etc/ttys tells what to do:
   * 	0 = do not enable line
   *	1 = enable line for regular login
   *	2 = use /etc/getty on this line to detect modem speed dynamically
   */
  while(p < endp) {
	switch(*p++) {
		case '0':		/* no getty/login */
			slotp->onflag = 0;
			break;

		case '1':		/* use login on this line */
			slotp->onflag = 1;
			break;

		case '2':		/* use GETTY on this line */
			slotp->onflag = 2;
			break;

		default:
			/* First char of line is rotten.  Skip this entry. */
			while(*p++ != '\n') ;	/* read until '\n' hit */
			continue;	/* go to next entry */
	}
	slotp->exit = 0;
	slotp->flags = CRMOD | XTABS | ECHO;		/* sg_flags setting */

	/* Now examine the second character of an /etc/ttys entry. */
	if('a' <= *p && *p <= 'a' + NPARAMSETS)	{	/* a serial line? */
		slotp->flags |= uart[*p - 'a'].flags;
		slotp->speed = uart[*p - 'a'].baud;
	} else if (*p != '0') {
		while(*p++ != '\n') ;	/* skip the rest of the line */
		continue;
	}
        p++;

	/* Now examine the third character of an /etc/ttys entry. */
	if('0' <= *p && *p <= '9') {			/* ttyname = digit? */
		strncpy(slotp->name, "tty?", sizeof (slotp->name));
		slotp->name[3] = *p;			/* fill in '?' */
	} else {					/* full name - copy */
		for (q = slotp->name; *p != '\n';) *q++ = *p++;
		*q = '\0';
	}

	slotp++;
	while(*p++ != '\n') ;
  }

  close(fd);
}

startup(linenr, mode1, mode2)
int linenr;
int mode1;
int mode2;
{
  /* Fork off a process for the indicated line. */

  register struct slotent *slotp;	/* pointer to ttyslot */
  int pid;				/* new pid */
  char line[30];			/* tty device name */

  slotp = &slots[linenr];

  if( (pid = fork()) != 0 ) {
	/* Parent */
	slotp->pid = pid;
	if( pid > 0 ) ++pidct;
	wtmp("", slotp->name, slotp->name, pid, mode1, linenr);
	if (mode1 != mode2)
		wtmp("", slotp->name, slotp->name, pid, mode2, linenr);
  } else {
	/* Child */
	close(0);				/* just in case */
	strcpy(line, "/dev/");			/* part of device name */
	strncat(line, slotp->name, sizeof (slotp->name)); /* rest of name */

	if( open(line, 2) != 0 ) exit(EXIT_TTYFAIL);	/* standard input */
	if(	   dup(0) != 1 ) exit(EXIT_TTYFAIL);	/* standard output */
	if( 	   dup(1) != 2 ) exit(EXIT_TTYFAIL);	/* standard error */

	/* Set line parameters. */

	if(ioctl(0, TIOCGETP, &args) < 0) exit(EXIT_TTYFAIL);
	args.sg_ispeed = args.sg_ospeed = slotp->speed;
	args.sg_flags = slotp->flags;
	if(ioctl(0, TIOCSETP, &args) < 0) exit(EXIT_TTYFAIL);

	/* Try to exec GETTY first if needed.  Call it with "-k CONSOLE" if
	 * the line is the console.  This causes GETTY to skip the speed 
	 * adaption routines. To get a GETTY process instead of a LOGIN, set 
	 * the first digit in /etc/ttys to '2'.  '1' still means LOGIN.
	 */
	if (slotp->onflag == 2) {
		if (linenr == 0) {
			execle(GETTY, GETTY, line, "-k", "CONSOLE", (char *)0,
			       env);
		 } else {
			execle(GETTY, GETTY, line, (char *)0, env);
		}
	}

	/* Try to exec various logins. */
	execle(LOGIN1, LOGIN1, (char *)0, env);
	execle(LOGIN2, LOGIN2, (char *)0, env);

	/* Emergency! Try to exec various shells. */
	execle(SHELL1, SHELL1, (char *)0, env);
	execle(SHELL2, SHELL2, (char *)0, env);

	write(open(CONSOLE, 1), "init: couldn't exec login\n", 26);
	exit(EXIT_EXECFAIL);
  }
}


wtmp(user, id, line, pid, type, lineno)
char *user;			/* name of user */
char *id;			/* inittab ID */
char *line;			/* TTY name */
int pid;			/* PID of process */
int type;			/* TYPE of entry */
int lineno;			/* slot number in UTMP */
{
/* Log an event into the WTMP and UTMP files. */

  struct utmp utmp;		/* UTMP/WTMP User Accounting */
  char *sp = "               ";	/* blank space */
  register int fd;

  /* Clear the fields. */
  strncpy(utmp.ut_name, sp, sizeof(utmp.ut_name));
  strncpy(utmp.ut_id, sp, sizeof(utmp.ut_id));
  strncpy(utmp.ut_line, sp, sizeof(utmp.ut_line));

  /* Strip the /dev part of the TTY name. */
  sp = strrchr(line, '/');
  if (sp == 0) 
	sp = line;
    else 
	sp++;

  /* Enter new values. */
  strncpy(utmp.ut_name, user, sizeof(utmp.ut_name));
  strncpy(utmp.ut_id, id, sizeof(utmp.ut_id));
  strncpy(utmp.ut_line, sp, sizeof(utmp.ut_line));
  utmp.ut_pid = pid;
  utmp.ut_type = type;
  utmp.ut_time = time((time_t *)0);

  if ((fd = open(WTMP, O_WRONLY)) < 0) return;
  if (lseek(fd, 0L, SEEK_END) >= 0L) 
	write(fd, (char *) &utmp, sizeof(struct utmp));
  close(fd);

  if (lineno >= 0) {		/* remove entry from utmp */
	if ((fd = open(UTMP, O_WRONLY)) < 0) return;
	lineno *= sizeof(struct utmp);
	if (lseek(fd, (long) lineno, SEEK_SET) >= 0L)
		write(fd, (char *) &utmp, sizeof(struct utmp));
	close(fd);
  }
}

char *sbrk(incr)
int incr;
{
/* One-off sbrk to allocate memory for execle.  The stack and heap are not set
 * up right for the library sbrk.
 */

  static void *some_memory[64];	/* (void *) to align it */
  register char *new_brk;
  static char *old_brk = (char *) some_memory;
  register char *result;

  /* Overflow of the next expression will be caught by the next test without
   * an explicit check, because sizeof (some_memory) < INT_MAX.
   */
  new_brk = old_brk + incr;
  if (new_brk > (char *) some_memory + sizeof (some_memory) ||
      new_brk < (char *) some_memory)
	return((char *) -1);
  result = old_brk;
  old_brk = new_brk;
  return(result);
}
