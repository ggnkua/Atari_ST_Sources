/* getty - get tty speed			Author: Fred van Kempen */

/*
 * GETTY  -     Initialize and serve a login-terminal for INIT.
 *		Also, select the correct speed. The STTY() code
 *		was taken from stty(1).c; which was written by
 *		Andrew S. Tanenbaum.
 *		If this program is called as 'uugetty', then it
 *		also performs some tasks that are needed before
 *		UUCP can use the line.
 *
 * Usage:	getty [-c filename] [-h] [-k] [-t] line [speed]
 *
 * Version:	3.4	02/17/90
 *
 * Author:	F. van Kempen, MicroWalt Corporation
 */

#include <sys/types.h>
#include <sgtty.h>
#include <unistd.h>
#include <utmp.h>
#include <ctype.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <pwd.h>

#ifdef NULL	/* ugly, I know... */
#	undef NULL
#endif	/* NULL */
#define NULL 0

#ifdef SIG_IGN	/* even more ugly... */
#	undef SIG_IGN
#	define SIG_IGN 1
#endif	/* SIG_IGN */

#ifndef BITS8	/* new-style UNIX or MINIX */
#	define BITS5 CS5
#	define BITS6 CS6
#	define BITS7 CS7
#	define BITS8 CS8
#endif	/* BITS8 */

#define GDEFS       "/etc/gettydefs"	/* pathname of getty definitions */
#define ISSUE       	"/etc/issue"	/* System-name textfile */
#define LOGIN1       	"/bin/login"
#define LOGIN2       	"/usr/bin/login"
#define COMMENT     		 '#'	/* this char starts a comment-line */
#define SEPA        		 '#'	/* this char separates the fields */
#define EOT         	     '\004'
#define EOF		   (char) 0
#define STARTC	 		021	/* CTRL-Q */
#define STOPC	 		023	/* CTRL-S */
#define QUITC	 		034	/* CTRL-\ */
#define EOFC	 		004	/* CTRL-D */
#define DELC		       0177	/* DEL */
#define ST_IDLE			 44	/* the getty is idle */
#define ST_RUNNING		 55	/* getty is now RUNNING */
#define ST_SUSPEND		 66	/* getty was SUSPENDed for dialout */


typedef struct {
  char *label;			/* label of this entry */
  char *flags1;			/* initial flags */
  char *flags2;			/* final flags */
  char *prompt;			/* login-prompt */
  char *next;			/* next label in chain */
} ENTRY;

#define clr1 tty.sg_flags &= ~(BITS5 | BITS6 | BITS7 | BITS8)
#define clr2 tty.sg_flags &= ~(EVENP | ODDP)


static char *Version = "@(#) GETTY 3.4 (02/17/90)";


char *tty_name;			/* what is our TTY? */
ENTRY gdefs[16];		/* we have space for 16 definitions */
ENTRY *defs;			/* our GETTY definition */
int uugetty = 0;		/* were we called as 'uugetty' ??? */
int nohup = 0;			/* NO hangup on exit/close */
int timeout = 0;		/* use TIMEOUT */
int keyboard = 0;		/* are we using the Console? */
int state = ST_IDLE;		/* the IDLE/SUSPEND/RUNNING state flag */
struct sgttyb tty;		/* the current terminal state */


void do_stty();			/* forward declaration */
  

void sigcatch(sig)
int sig;
{
/* Catch the signals that want to catch. */

  switch(sig) {
	case SIGEMT:	/* SIGEMT means SUSPEND */
		if (state == ST_IDLE) state = ST_SUSPEND;
		break;
	case SIGIOT:	/* SIGIOT means RESTART */
		if (state == ST_SUSPEND) state = ST_RUNNING;
		break;
	case SIGBUS:	/* SIGBUS means IGNORE ALL */
		signal(SIGEMT, SIG_IGN);
		signal(SIGIOT, SIG_IGN);
		state = ST_RUNNING;
		break;
  }
  signal(sig, sigcatch);
}


char agetchar(fd)
int fd;
{
/* Read a character, or EOF if zero chars read. */

  static char buf[1024];
  static char *bufp = buf;
  static int nleft = 0;

  if (nleft == 0) {
	nleft = read(fd, buf, 1024);
	bufp = buf;
  }
  return((--nleft >= 0) ? *bufp++ : EOF);
}


char *readline(fd)
int fd;
{
/* Read one line from the defs-file. */

  char linbuff[512];
  register int c, len;
  register char *bp = linbuff;

  /* Read a line of text. */
  len = 0;
  while (1) {
	c = agetchar(fd);
	if (c == '\n' || c == EOF) break;
	*bp++ = c;
	len++;
  }
  *bp = '\0';

  /* Now allocate a buffer for it. */
  bp = (char *)malloc(len + 1);
  if (bp == (char *) NULL) return((char *) NULL);

  /* Copy this line to its buffer. */
  strcpy(bp, linbuff);

  return((c == EOF) ? (char *) NULL : bp);
}


void decode(text, ep)
char *text;
ENTRY *ep;
{
/* Decode an input line. */

  register char *sp;

  sp = text;
  while (*sp == ' ' || *sp == '\t') sp++;
  ep->label = sp;			/* first, decode LABEL field */
  while (*sp != '\0' && *sp != SEPA) sp++;
  *sp++ = '\0';
  while (*sp == ' ' || *sp == '\t') sp++;
  ep->flags1 = sp;		/* next, INITIAL flags field */
  while (*sp != '\0' && *sp != SEPA) sp++;
  *sp++ = '\0';
  while (*sp == ' ' || *sp == '\t') sp++;
  ep->flags2 = sp;		/* then, FINAL flags field */
  while (*sp != '\0' && *sp != SEPA) sp++;
  *sp++ = '\0';
  while (*sp == ' ' || *sp == '\t') sp++;
  ep->prompt = sp;		/* and the LOGIN_PROMPT field */
  while (*sp != '\0' && *sp != SEPA) sp++;
  *sp++ = '\0';
  while (*sp == ' ' || *sp == '\t') sp++;
  ep->next = sp;		/* finally, decode the NEXT field */
  while (*sp != '\0' && *sp != SEPA) sp++;
  *sp++ = '\0';
}


int readdefs(name, label)
char *name;
char *label;
{
/* Read the defs-file. */

  int defsfd;			/* definition file */
  int defidx;			/* definition index */
  register char *bp;

  if ((defsfd = open(name, O_RDONLY)) < 0) return(defsfd);
  defidx = 0;
  defs = &gdefs[defidx];	/* set DEFAULT definition */
  while (1) {
	bp = readline(defsfd);
	if (bp == (char *) NULL) break;
	switch (*bp) {
	    case '\0':		/* blank line */
		continue;
	    case '#':		/* comment line */
		continue;
	    default:		/* data! */
		decode(bp, &gdefs[defidx]);
		if (label != (char *) NULL) {
			if (!strcmp(gdefs[defidx].label, label))
				defs = &gdefs[defidx];
		}
		defidx++;
	}
  }
  close(defsfd);
  return(0);
}


void select()
{
/* Select next speed from the chain. */

  register int idx;

  idx = 0;
  while (idx < 16) {
	if (!(strcmp(gdefs[idx].label, defs->next))) {
		defs = &gdefs[idx];
		do_stty(defs->flags1);
		return;
	}
	idx++;
  }
}


void showfile(name)
char *name;
{
/* Read a textfile and show it on the desired terminal. */

  register int fd;
  register int len;
  char buff[1024];

  if ((fd = open(name, O_RDONLY)) < 0) return;
  while (1) {
	len = read(fd, buff, 80);
	if (len > 0)
		write(1, buff, len);
	else
		break;
  }
  close(fd);
}


/* Perform some UTMP and WTMP accounting.
 * This information is needed for programs like
 * who(1), last(1) and write(1)...
 */
void wtmp(line)
char *line;			/* tty device name */
{
  struct utmp entry, oldent;
  char *blank = "               ";
  register char *sp;
  int fd, recno;
  extern long time();

  /* Strip off the /dev part of the TTY name. */
  sp = strrchr(line, '/');
  if (sp == NULL) sp = line;
    else sp++;

  /* First, read the current UTMP entry.  We need some of its
   * parameters! (like PID, ID etc...)
   */
  if ((fd = open(UTMP, O_RDONLY)) < 0) return;
  recno = 0;
  while (read(fd, (char *) &oldent, (unsigned) sizeof(struct utmp))
						== sizeof(struct utmp)) {
	if (oldent.ut_pid == getpid()) break;
	recno++;
  }
  close(fd);
  recno *= sizeof(struct utmp);

  /* Clear out the new string fields. */
  strncpy(entry.ut_name, blank, sizeof(entry.ut_name));
  strncpy(entry.ut_id, blank, sizeof(entry.ut_id));
  strncpy(entry.ut_line, blank, sizeof(entry.ut_line));

  /* Enter new string fields. */
  strcpy(entry.ut_name, "");
  strncpy(entry.ut_id, oldent.ut_id, sizeof(entry.ut_id));
  strncpy(entry.ut_line, sp, sizeof(entry.ut_line));

  /* Copy old numeric fields. */
  entry.ut_pid = oldent.ut_pid;

  /* Change new numeric fields. */
  entry.ut_type = LOGIN_PROCESS;/* we are waiting for a LOGIN! */
  time((time_t *) &(entry.ut_time));

  /* Write a WTMP record. */
  if ((fd = open(WTMP, O_WRONLY)) > 0) {
	if (lseek(fd, 0L, SEEK_END) >= 0L) {
		write(fd, (char *) &entry, sizeof(struct utmp));
	}
	close(fd);
  }

  /* Rewrite the UTMP entry. */
  if ((fd = open(UTMP, O_WRONLY)) > 0) {
	if (lseek(fd, (long) recno, SEEK_SET) >= 0L) {
		write(fd, (char *) &entry, sizeof(struct utmp));
	}
	close(fd);
  }
}


/* Read one character from stdin.
 * If it looks bad (highest bit set, or error return)
 * try next speed in the list.
 */
int areadch()
{
  int ch, st;
  char ch1;

  while (1) {
	st = read(0, &ch1, 1);	/* read character from TTY */
	if (st < 0) return(-1);	/* SIGNAL received! */

	ch = ch1 & 0xFF;
	if (keyboard == 1) return(ch);

	if ((ch == 0) || ((ch & 128) == 128)) {
		select();
		ioctl(0, TIOCGETP, &tty);
		tty.sg_flags |= RAW;
		tty.sg_flags &= ~ECHO;
		ioctl(0, TIOCSETP, &tty);
		ioctl(0, TIOCFLUSH, (struct sgttyb *) NULL);
	} else
		return(ch);
  }
}


/* Handle the process of a GETTY.
 */
void do_getty(name)
char *name;
{
  register char *np, *s;
  int ch, bs, can, ucmap, crmap;
  char ch1;

  showfile(ISSUE);		/* what is this all about? */

  ioctl(0, TIOCGETP, &tty);

  tty.sg_flags |= RAW;
  tty.sg_flags &= ~ECHO;
  ioctl(0, TIOCSETP, &tty);

  bs = tty.sg_erase;		/* current ERASE (^H) char */
  can = tty.sg_kill;		/* current CANCEL (^X) char */
  ucmap = 0;			/* lower->upper case mapping yet */
  crmap = 0;			/* no CR to LF mapping yet! */

  /* Display prompt, and try to match the caller's speed. */
  ch = ' ';
  *name = '\0';
  while (ch != EOF) {
	/* Give us a new line */
	write(1, "\r\n", 2);
	write(1, defs->prompt, (unsigned) strlen(defs->prompt));
	ioctl(0, TIOCFLUSH, (struct sgttyb *) NULL);
	np = name;
	while (ch != EOF) {
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
		    case '#':
			bs = ch;/* old-style ERASE */
			ch1 = ch;
			write(1, &ch1, 1);
			if (np > name) np--;
			break;
		    case '\b':	/* new-style ERASE */
			bs = ch;
			if (np > name) {
				np--;
				write(1, "\b \b", 3);
			} else
				write(1, "\007", 1);
			break;
		    case '@':	/* old-style KILL */
			can = ch;
			np = name;
			write(1, "@\r\n", 3);
			break;
		    case 030:	/* new-style KILL */
			can = ch;
			np = name;
			write(1, "^X\r\n", 3);
			break;
		    case '\r':
			crmap = 1;	/* ugly keyboard! */
		    case '\n':
			write(1, "\r\n", 2);	/* should map this */
			*np = '\0';
			ch = EOF;
			break;
		    default:
			ch1 = ch;
			write(1, &ch1, 1);
			*np++ = ch;
		}
	}
	if (*name == '\0') ch = ' ';	/* blank line typed! */
  }

  if (crmap == 1) tty.sg_flags |= CRMOD;	/* map input CR to LF */

  /* Now check if the typed username contains any any lowercase
   * characters. If not, tell kernel to map all lowercase output to
   * uppercase! */
  s = name;
  while (*s != '\0') {
	if (*s >= 'a' || *s <= 'z') ucmap = 1;
	s++;
  }
#ifdef UCMODE
  if (ucmap == 1) tty.sg_flags |= UCMODE;	/* map LOWER to UPPER */
#endif /* UCMODE */

  tty.sg_erase = bs;
  tty.sg_kill = can;
  tty.sg_flags &= ~RAW;
  tty.sg_flags |= ECHO;
  ioctl(0, TIOCSETP, &tty);
}


/* Execute the login(1) command with the current
 * username as its argument. It will reply to the
 * calling user by typing "Password: "...
 */
void do_login(name)
char *name;
{ 
  execl(LOGIN1, LOGIN1, name, (char *) NULL);
  execl(LOGIN2, LOGIN2, name, (char *) NULL);
}


/* Convert speed to code. */
int getspeed(spd)
char *spd;
{
  int code;

  if (!strcmp(spd, "B300"))
	code = B300;
  else if (!strcmp(spd, "B1200"))
	code = B1200;
  else if (!strcmp(spd, "B2400"))
	code = B2400;
  else if (!strcmp(spd, "B4800"))
	code = B4800;
  else if (!strcmp(spd, "B9600"))
	code = B9600;
#ifdef B19200
  else if (!strcmp(spd, "B19200"))
	code = B19200;
#endif
#ifdef B38400
  else if (!strcmp(spd, "B38400"))
	code = B38400;
#endif
#ifdef B115200
  else if (!strcmp(spd, "B115200"))
	code = B115200;
#endif
  else
	code = -1;
  return(code);
}


/* Set the terminal to the specified parameters. */
void do_stty(parms)
char *parms;
{
  char prms[80];		/* temp. copy of parameters */
  struct tchars tch;
  register char *bp, *sp;
  int code;

  /* Get current TTY status and characters. */
  ioctl(0, TIOCGETC, (struct sgttyb *) &tch);
  tty.sg_flags = 0;

  strncpy(prms, parms, 79);
  sp = prms;

  /* Process all options. */
  while (*sp) {
	/* Get an option word. */
	bp = sp;
	while (*sp && *sp != ' ' && *sp != '\t') sp++;
	if (*sp) *sp++ = '\0';
	if (!strcmp(bp, "-TABS"))
		tty.sg_flags &= ~XTABS;
	else if (!strcmp(bp, "-ODD"))
		tty.sg_flags &= ~ODDP;
	else if (!strcmp(bp, "-EVEN"))
		tty.sg_flags &= ~EVENP;
	else if (!strcmp(bp, "-RAW"))
		tty.sg_flags &= ~RAW;
	else if (!strcmp(bp, "-CBREAK"))
		tty.sg_flags &= ~CBREAK;
	else if (!strcmp(bp, "-ECHO"))
		tty.sg_flags &= ~ECHO;
	else if (!strcmp(bp, "-DCD"))
		tty.sg_flags &= ~DCD;
	else if (!strcmp(bp, "-NL"))
		tty.sg_flags |= CRMOD;
	else if (!strcmp(bp, "TABS"))
		tty.sg_flags |= XTABS;
	else if (!strcmp(bp, "NONE")) {
		clr2;
	} else if (!strcmp(bp, "EVEN")) {
		clr2;
		tty.sg_flags |= EVENP;
	} else if (!strcmp(bp, "ODD")) {
		clr2;
		tty.sg_flags |= ODDP;
	} else if (!strcmp(bp, "RAW"))
		tty.sg_flags |= RAW;
	else if (!strcmp(bp, "CBREAK"))
		tty.sg_flags |= CBREAK;
	else if (!strcmp(bp, "ECHO"))
		tty.sg_flags |= ECHO;
	else if (!strcmp(bp, "DCD"))
		tty.sg_flags |= DCD;
	else if (!strcmp(bp, "NL"))
		tty.sg_flags &= ~CRMOD;
	else if (!strcmp(bp, "BITS5")) {
		clr1;
		tty.sg_flags |= BITS5;
	} else if (!strcmp(bp, "BITS6")) {
		clr1;
		tty.sg_flags |= BITS6;
	} else if (!strcmp(bp, "BITS7")) {
		clr1;
		tty.sg_flags |= BITS7;
	} else if (!strcmp(bp, "BITS8")) {
		clr1;
		tty.sg_flags |= BITS8;
	} else {
		code = getspeed(bp);
		if (code >= 0) {
			tty.sg_ispeed = code;
			tty.sg_ospeed = code;
		} else {
			if (!strcmp(bp, "SANE") || !strcmp(bp, "DEFAULT")) {
				tty.sg_flags = (ECHO | CRMOD | XTABS | BITS8);
				tty.sg_ispeed = B1200;
				tty.sg_ospeed = B1200;
				tty.sg_kill = 'X' & 037;
				tty.sg_erase = 'H' & 037;
				tch.t_intrc = DELC;
				tch.t_quitc = QUITC;
				tch.t_startc = STARTC;
				tch.t_stopc = STOPC;
				tch.t_eofc = EOFC;
			}
		}
	}
  }

  /* Set new parameters. */
  ioctl(0, TIOCSETP, &tty);
  ioctl(0, TIOCSETC, (struct sgttyb *) &tch);
}


/* The function carrier() must be called when we are ready
 * to service the terminal.  Basically, it waits for a valid
 * connection by monitoring the DCD line from the modem or
 * terminal, which goes high in such an event.
 *
 * On UNIX systems, it is possible to ask the kernel to
 * wake us up if a change in DCD status occurs.  This
 * program then can go to sleep until that happens.
 * Otherwise, we will have to
 *
 *	a) constantly monitor the DCD line.
 *
 *	b) assume no check is necessary.
 *
 * The first method is somewhat expensive in terms of CPU
 * time, and the latter is somewhat ugly from the user's
 * point of view.  Just pick your choice...
 */
#define CHOICE_B
void do_carrier()
{
#ifdef CHOICE_A
  struct sgttyb tp;
#endif

  if (keyboard == 1) return;

#ifdef CHOICE_A
  state = ST_IDLE;
  while (1) {		/* Check for DCD every second. */
	sleep(1);
	if (state == ST_SUSPEND) {
		while (state != ST_IDLE) {
			pause();
			if (state == ST_RUNNING) state = ST_IDLE;
		}
	}
	if (state == ST_IDLE) {
		ioctl(0, TIOCGETP, &tp);
		if (tp.sg_flags & DCD) return;
	}
  }
#endif /* CHOICE_A */
#ifdef CHOICE_B
   return;		/* Just assume no check is necessary. */
#endif /* CHOICE_B */
}


void usage()
{
  write(2, "Usage: getty [-c filename] [-h] [-k] [-t] line [speed]\n", 55);
}


int main(argc, argv)
int argc;
char *argv[];
{
  char *defsfile = GDEFS;
  char *label = (char *) NULL;
  struct passwd *pw;
  register char *s;
  char uname[30];
  int c;

  /* Ignore all signals. */
  for (c = 1; c <= _NSIG; c++) signal(c, SIG_IGN);

  /* Determine if we were called as 'uugetty'. */
  s = strrchr(argv[0], '/');
  if (s == (char *) NULL) s = argv[0];
    else s++;
  if (*s == 'u') uugetty = 1;


  c = 1;
  tty_name = (char *) NULL;
  while (c < argc) {
	s = argv[c++];
	if (*s == '-') switch (*++s) {
		    case 'c':	/* new GETTYDEFS file */
			defsfile = argv[c++];
			break;
		    case 'h':	/* NO HANGUP ON CLOSE */
			nohup = 1;
			break;
		    case 'k':	/* CONSOLE KEYBOARD */
			keyboard = 1;
			break;
		    case 't':	/* TIMEOUT */
			timeout = 1;
			break;
		    default:
			usage();
			exit(-1);
	} else if (tty_name == (char *) NULL)
		tty_name = argv[c - 1];
	else
		label = argv[c - 1];
  }

  ioctl(0, TIOCGETP, &tty);	/* get line parameters */
  tty.sg_ispeed = B0;
  tty.sg_ospeed = B0;
  if (keyboard == 0) ioctl(0, TIOCSETP, &tty);	/* hangup the line */

  if (tty_name == (char *) NULL)	/* new INIT */
	tty_name = ttyname(0);

  c = readdefs(defsfile, label);/* GETTYDEFS file into core */
  if (c != 0) return(c);

  if (uugetty) {
	pw = getpwnam("uucp");	/* get UUCP user ID and group ID */
        if (pw != (struct passwd *) NULL)
		chown(tty_name, pw->pw_uid, pw->pw_gid);
	  else uugetty = 0;
  }

  if (!uugetty) chown(tty_name, 1, 1);	/* set owner of TTY to BIN.SYS */

  do_stty(defs->flags1);	/* set INITIAL terminal parameters */

  wtmp(tty_name);		/* perform UTMP/WTMP accounting */

  /* Catch some of the available signals. */
  signal(SIGEMT, sigcatch);
  signal(SIGIOT, sigcatch);
  signal(SIGBUS, sigcatch);

  do_carrier();			/* wait for a carrier to come... */

  do_getty(uname);		/* handle getty() */
  uname[29] = '\0';		/* make sure the name fits! */

  do_stty(defs->flags2);	/* set FINAL terminal parameters */

  do_login(uname);		/* and call login(1) if OK */

  return(0);			/* never executed */
}
