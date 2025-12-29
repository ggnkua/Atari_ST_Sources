/*
 * Copyright (c) 1983, 1988 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)syslog.c	5.16 (Berkeley) 6/27/88";
#endif /* LIBC_SCCS and not lint */

/*
 * SYSLOG -- print message on log file
 *
 * This routine looks a lot like printf, except that it
 * outputs to the log file instead of the standard output.
 * Also:
 *	adds a timestamp,
 *	prints the module name in front of the message,
 *	has some other formatting types (or will sometime),
 *	adds a newline on the end of the message.
 *
 * The output of this routine is intended to be read by /etc/syslogd.
 *
 * Author: Eric Allman
 * Modified to use UNIX domain IPC by Ralph Campbell
 * Modified to use fifo's when running under MiNT on the Atari ST/TT/Falcon
 *	by Stephen Usher
 * Modified to be more ANSI-conformant by Thierry Bousch
 */

#include <sys/types.h>
#ifndef atarist
#include <sys/socket.h>
#ifdef SYSLOG_INET
#  include <netinet/in.h>
#else
#  ifdef SYSLOG_UNIXAF
#    include <sys/un.h>
#  else
#    error "Must defined one of SYSLOG_INET or SYSLOG_UNIXAF"
#  endif
#endif
#else
#include <mintbind.h>
#endif

#include <sys/file.h>
#include <sys/signal.h>
#include <syslog.h>
#ifndef atarist
#include <netdb.h>
#endif
#include <strings.h>
#ifdef SYSV
#include <fcntl.h>
#endif

#ifdef __STDC__
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdarg.h>
#include <time.h>
#include <wait.h>
#endif

#ifndef atarist
#define	MAXLINE	1024			/* max message size */
#else
#define	MAXLINE	960			/* max message size */
#endif
#ifndef NULL
#define NULL	0			/* manifest */
#endif

#define IMPORTANT 	LOG_ERR

#ifndef atarist
static char	logname[] = "/dev/log";
#else
static char	logname[] = "/pipe/log";
#endif
static char	ctty[] = "/dev/console";

static int	LogFile = -1;		/* fd for log */
static int	connected;		/* have done connect */
static int	LogStat	= 0;		/* status bits, set by openlog() */
static char	*LogTag = "syslog";	/* string to tag the entry with */
static int	LogMask = 0xff;		/* mask of priorities to be logged */
static int	LogFacility = LOG_USER;	/* default facility code */

#ifdef SYSLOG_INET
static struct sockaddr_in SyslogAddr;	/*  address of loghost */
#else
#  ifdef SYSLOG_UNIXAF
static struct sockaddr_un SyslogAddr;	/* AF_UNIX address of local logger */
#  endif
#endif

extern	int errno, sys_nerr;
extern	char *sys_errlist[];

#ifdef __STDC__
void syslog(int pri, const char *fmt, ...)
#else
syslog(pri, fmt, p0, p1, p2, p3, p4)
	int pri;
	char *fmt;
#endif
{
	char buf[MAXLINE + 1], outline[MAXLINE + 1];
	register char *b, *f, *o;
	register int c;
	long now;
	int pid, olderrno = errno;
#ifdef __STDC__
	va_list argp;
	va_start(argp, fmt);
#endif
	/* see if we should just throw out this message */
	if ((unsigned) LOG_FAC(pri) >= LOG_NFACILITIES ||
	    LOG_MASK(LOG_PRI(pri)) == 0 ||
	    (pri &~ (LOG_PRIMASK|LOG_FACMASK)) != 0)
		return;
	if (LogFile < 0 || !connected)
		openlog(LogTag, LogStat | LOG_NDELAY, 0);

	/* set default facility if none specified */
	if ((pri & LOG_FACMASK) == 0)
		pri |= LogFacility;

	/* build the message */
	o = outline;
	(void)sprintf(o, "<%d>", pri);
	o += strlen(o);
	time(&now);
	(void)sprintf(o, "%.15s ", ctime(&now) + 4);
	o += strlen(o);
	if (LogTag) {
		strcpy(o, LogTag);
		o += strlen(o);
	}
	if (LogStat & LOG_PID) {
		(void)sprintf(o, "[%d]", getpid());
		o += strlen(o);
	}
	if (LogTag) {
		strcpy(o, ": ");
		o += 2;
	}

	b = buf;
	f = fmt;
	while ((c = *f++) != '\0' && c != '\n' && b < &buf[MAXLINE]) {
		if (c != '%') {
			*b++ = c;
			continue;
		}
		if ((c = *f++) != 'm') {
			*b++ = '%';
			*b++ = c;
			continue;
		}
		if ((unsigned)olderrno > sys_nerr)
			(void)sprintf(b, "error %d", olderrno);
		else
			strcpy(b, sys_errlist[olderrno]);
		b += strlen(b);
	}
	*b++ = '\n';
	*b = '\0';
#ifdef __STDC__
	(void)vsprintf(o, buf, argp);
#else
	(void)sprintf(o, buf, p0, p1, p2, p3, p4);
#endif
	c = strlen(outline);
	if (c > MAXLINE)
		c = MAXLINE;

	/* output the message to the local logger */
#ifndef atarist
	if (send(LogFile, outline, c, 0) >= 0)
#else
	/* force a context switch after writing (++tb) */
	if (write(LogFile, outline, c) >= 0 && !Syield())
#endif
		return;
	if (!(LogStat & LOG_CONS))
		return;

	/* output the message to the console */
#ifdef SYSV
	pid = fork();
#else
	pid = vfork();
#endif
	if (pid == -1)
		return;
	if (pid == 0) {
		int fd;

#ifdef SYSV
		signal(SIGALRM, SIG_DFL);
#else
		sigsetmask(sigblock(0L) & ~sigmask(SIGALRM));
#endif
		alarm(5);
		fd = open(ctty, O_WRONLY);
		alarm(0);
		strcat(o, "\r");
		o = index(outline, '>') + 1;
		write(fd, o, c + 1 - (o - outline));
		close(fd);
		_exit(0);
	}
	if (!(LogStat & LOG_NOWAIT))
		while ((c = wait((int *)0)) > 0 && c != pid)
			;
}

/*
 * OPENLOG -- open system log
 */

#ifdef __STDC__
int openlog(const char *ident, int logstat, int logfac)
#else
openlog(ident, logstat, logfac)
	char *ident;
	int logstat, logfac;
#endif
{
#ifdef SYSLOG_INET
	struct servent *sp;
	struct hostent *hp;
#endif

	if (ident != NULL)
		LogTag = ident;
	LogStat = logstat;
	if (logfac != 0 && (logfac &~ LOG_FACMASK) == 0)
		LogFacility = logfac;
#ifdef SYSLOG_INET
	if (LogFile >= 0)
		return(0);
	sp = getservbyname("syslog", "udp");
	hp = gethostbyname(LOG_HOST);
	if (sp != NULL && hp != NULL)
	{
		bzero(&SyslogAddr, sizeof(SyslogAddr));
		SyslogAddr.sin_family = AF_INET;
		bcopy(hp->h_addr, (char *)&SyslogAddr.sin_addr, hp->h_length);
		SyslogAddr.sin_port = sp->s_port;
		if (LogStat & LOG_NDELAY)
			LogFile = socket(AF_INET, SOCK_DGRAM, 0);
	}
	if (LogFile != -1 && !connected &&
	    connect(LogFile, (struct sockaddr *) &SyslogAddr,
		   sizeof(SyslogAddr)) != -1)
	{
		connected = 1;
		return(0);
	}			
	if (LogStat & LOG_NDELAY)
		return(-1);
	else			
		return(0);
#else
#ifdef SYSLOG_UNIXAF
	if (LogFile == -1) {
		SyslogAddr.sun_family = AF_UNIX;
		strncpy(SyslogAddr.sun_path, logname, sizeof SyslogAddr.sun_path);
		if (LogStat & LOG_NDELAY) {
			LogFile = socket(AF_UNIX, SOCK_DGRAM, 0);
			fcntl(LogFile, F_SETFD, 1);
		}
	}
	if (LogFile != -1 && !connected &&
	    connect(LogFile, (struct sockaddr *) &SyslogAddr,
		    sizeof(SyslogAddr.sun_family) +
		    strlen(SyslogAddr.sun_path)) >= 0)
		connected = 1;
#endif
#ifdef atarist
	if (LogFile == -1) {
		LogFile = open(logname, O_RDWR);
	}
	if (LogFile >= 0  && !connected)
	{
		connected = 1;
		return 1;
	} else {
		perror(logname);
		connected = 0;
		return -1;
	}
#endif
#endif
}


/*
 * CLOSELOG -- close the system log
 */

#ifdef __STDC__
void closelog(void)
#else
closelog()
#endif
{
	(void) close(LogFile);
	LogFile = -1;
	connected = 0;
}

/*
 * SETLOGMASK -- set the log mask level
 */
#ifdef __STDC__
int setlogmask(int pmask)
#else
setlogmask(pmask)
	int pmask;
#endif
{
	int omask;

	omask = LogMask;
	if (pmask != 0)
		LogMask = pmask;
	return (omask);
}
