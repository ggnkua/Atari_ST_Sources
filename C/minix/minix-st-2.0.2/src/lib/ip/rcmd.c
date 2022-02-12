/*
 * Copyright (c) 1983 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that: (1) source distributions retain this entire copyright
 * notice and comment, and (2) distributions including binaries display
 * the following acknowledgement:  ``This product includes software
 * developed by the University of California, Berkeley and its contributors''
 * in the documentation or other materials provided with the distribution
 * and in all advertising materials mentioning features or use of this
 * software. Neither the name of the University nor the names of its
 * contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)rcmd.c	5.22 (Berkeley) 6/1/90";
#endif /* LIBC_SCCS and not lint */

#if _MINIX
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <net/gen/netdb.h>
#include <net/gen/in.h>
#include <net/gen/tcp.h>
#include <net/gen/tcp_io.h>
#include <net/hton.h>
#include <net/netlib.h>

#define MAXHOSTNAMELEN	256
#define MAXPATHLEN PATH_MAX
#else
#include <stdio.h>
#include <ctype.h>
#include <pwd.h>
#include <sys/param.h>
#include <sys/file.h>
#include <sys/signal.h>
#include <sys/socket.h>
#include <sys/stat.h>

#include <netinet/in.h>

#include <netdb.h>
#include <errno.h>
#endif

#ifdef __STDC__
#define CONST	const
#else
#define CONST
#endif

extern	errno;
#if _MINIX
int _validuser _ARGS(( FILE *hostf, const char *rhost, const char *luser,
					const char *ruser, int baselen ));
static int _checkhost _ARGS(( const char *rhost, const char *lhost, int len ));
#else
char	*index();
#endif

#if _MINIX
int rcmd(ahost, rport, locuser, remuser, cmd, fd2p)
char **ahost;
int rport;
CONST char *locuser, *remuser, *cmd;
int *fd2p;
{
	int fd, fd2, result;
	struct hostent *hp;
	int n;
	static tcpport_t lport;
	nwio_tcpconf_t tcpconf;
	nwio_tcpcl_t tcpconnopt;
	pid_t pid;
	char num[8];
	char c;
	char *tcp_device;

	fd= -1;
	fd2= -1;

	if (lport == 0) {
		pid = getpid();
		lport = 1;
		do {
			lport = (lport << 1) | (pid & 1);

			pid >>= 1;
		} while (lport < TCPPORT_RESERVED/2);
	}

	tcp_device= getenv("TCP_DEVICE");
	if (tcp_device == NULL)
		tcp_device= TCP_DEVICE;
	hp= gethostbyname(*ahost);
	if (!hp)
	{
		fprintf(stderr, "%s: unknown host\n", *ahost);
		return -1;
	}
	*ahost= hp->h_name;
	n = TCPPORT_RESERVED/2;
	do
	{
		if (--lport < TCPPORT_RESERVED/2)
			lport = TCPPORT_RESERVED-1;
		fd= open (tcp_device, O_RDWR);
		if (fd<0)
		{
			fprintf(stderr, "unable to open %s: %s\n",
				tcp_device, strerror(errno));
			goto bad;
		}
		tcpconf.nwtc_flags= NWTC_LP_SET | NWTC_SET_RA | NWTC_SET_RP |
			NWTC_EXCL;
		tcpconf.nwtc_locport= htons(lport);
		tcpconf.nwtc_remport= rport;
		tcpconf.nwtc_remaddr= *(ipaddr_t *)hp->h_addr;

		result= ioctl(fd, NWIOSTCPCONF, &tcpconf);
		if (result<0)
		{
			if (errno == EADDRINUSE)
			{
				close(fd);
				continue;
			}
			fprintf(stderr, "unable to ioctl(NWIOSTCPCONF): %s\n",
				strerror(errno));
			goto bad;
		}
		tcpconf.nwtc_flags= NWTC_SHARED;
		result= ioctl(fd, NWIOSTCPCONF, &tcpconf);
		if (result<0)
		{
			fprintf(stderr, "unable to ioctl(NWIOSTCPCONF): %s\n",
				strerror(errno));
			goto bad;
		}
		tcpconnopt.nwtcl_flags= 0;

		do
		{
			result= ioctl (fd, NWIOTCPCONN, &tcpconnopt);
			if (result<0 && errno == EAGAIN)
			{
				sleep(2);
			}
		} while (result<0 && errno == EAGAIN);
		if (result<0 && errno != EADDRINUSE)
		{
			fprintf(stderr,
				"unable to ioctl(NWIOTCPCONN): %s\n",
				strerror(errno));
			goto bad;
		}
		if (result>=0)
			break;
	} while (--n > 0);
	if (n == 0)
	{
		fprintf(stderr, "can't get port\n");
		return -1;
	}
	if (!fd2p)
	{
		if (write(fd, "", 1) != 1)
		{
			fprintf(stderr, "unable to write: %s", strerror(errno));
			goto bad;
		}
	}
	else
	{
		fd2= open (tcp_device, O_RDWR);
		if (fd2<0)
		{
			fprintf(stderr, "unable to open %s: %s\n",
				tcp_device, strerror(errno));
			goto bad;
		}
		tcpconf.nwtc_flags= NWTC_LP_SET | NWTC_UNSET_RA | 
			NWTC_UNSET_RP | NWTC_SHARED;
		tcpconf.nwtc_locport= htons(lport);

		result= ioctl(fd2, NWIOSTCPCONF, &tcpconf);
		if (result<0)
		{
			fprintf(stderr,
				"unable to ioctl(NWIOSTCPCONF): %s\n",
				strerror(errno));
			goto bad;
		}
		pid= fork();
		if (pid<0)
		{
			fprintf(stderr, "unable to fork: %s\n",
				strerror(errno));
			goto bad;
		}
		if (!pid)
		{
			alarm(0);
			signal(SIGALRM, SIG_DFL);
			alarm(30); /* give up after half a minute */
			tcpconnopt.nwtcl_flags= 0;

			do
			{
				result= ioctl (fd2, NWIOTCPLISTEN,
					&tcpconnopt);
				if (result<0 && errno == EAGAIN)
				{
					sleep(2);
				}
			} while (result<0 && errno == EAGAIN);
			if (result<0 && errno != EADDRINUSE)
			{
				fprintf(stderr,
					"unable to ioctl(NWIOTCPLISTEN): %s\n",
					strerror(errno));
				exit(1);
			}
			if (result>=0)
				exit(0);
			else
				exit(1);
		}
		/*
		 * This sleep is a HACK.  The command that we are starting
		 * will try to connect to the fd2 port.  It seems that for
		 * this to succeed the child process must have already made
		 * the call to ioctl above (the NWIOTCPLISTEN) call.
		 * The sleep gives the child a chance to make the call
		 * before the parent sends the port number to the
		 * command being started.
		 */
		sleep(1);

		sprintf(num, "%d", lport);
		if (write(fd, num, strlen(num)+1) != strlen(num)+1)
		{
			fprintf(stderr, "unable to write: %s\n",
				strerror(errno));
			goto bad;
		}

	}
	write (fd, locuser, strlen(locuser)+1);
	write (fd, remuser, strlen(remuser)+1);
	write (fd, cmd, strlen(cmd)+1);
	if (read(fd, &c, 1) != 1)
	{
		fprintf(stderr, "unable to read: %s\n", strerror(errno) );
		goto bad;
	}
	if (c != 0)
	{
		while (read(fd, &c, 1) == 1)
		{
			write(2, &c, 1);
			if (c == '\n')
				break;
		}
		goto bad;
	}
	if (fd2p)
	{
		*fd2p= fd2;
		result= ioctl(fd2, NWIOGTCPCONF, &tcpconf);
		if (result<0)
		{
			fprintf(stderr, "unable to ioctl(NWIOGTCPCONF): %s\n",
				strerror(errno) );
			goto bad;
		}
		if (ntohs(tcpconf.nwtc_remport) >= TCPPORT_RESERVED)
		{
			fprintf(stderr, "unable to setup 2nd channel\n");
			goto bad;
		}
	}
	return fd;

bad:
	if (fd>=0)
		close(fd);
	if (fd2>=0)
		close(fd2);
	return -1;
}
#else /* _MINIX */
rcmd(ahost, rport, locuser, remuser, cmd, fd2p)
	char **ahost;
	u_short rport;
	char *locuser, *remuser, *cmd;
	int *fd2p;
{
	int s, timo = 1, pid;
	long oldmask;
	struct sockaddr_in sin, sin2, from;
	char c;
	int lport = IPPORT_RESERVED - 1;
	struct hostent *hp;
	fd_set reads;

	pid = getpid();
	hp = gethostbyname(*ahost);
	if (hp == 0) {
		herror(*ahost);
		return (-1);
	}
	*ahost = hp->h_name;
	oldmask = sigblock(sigmask(SIGURG));
	for (;;) {
		s = rresvport(&lport);
		if (s < 0) {
			if (errno == EAGAIN)
				fprintf(stderr, "socket: All ports in use\n");
			else
				perror("rcmd: socket");
			sigsetmask(oldmask);
			return (-1);
		}
		fcntl(s, F_SETOWN, pid);
		sin.sin_family = hp->h_addrtype;
		bcopy(hp->h_addr_list[0], (caddr_t)&sin.sin_addr, hp->h_length);
		sin.sin_port = rport;
		if (connect(s, (caddr_t)&sin, sizeof (sin), 0) >= 0)
			break;
		(void) close(s);
		if (errno == EADDRINUSE) {
			lport--;
			continue;
		}
		if (errno == ECONNREFUSED && timo <= 16) {
			sleep(timo);
			timo *= 2;
			continue;
		}
		if (hp->h_addr_list[1] != NULL) {
			int oerrno = errno;

			fprintf(stderr,
			    "connect to address %s: ", inet_ntoa(sin.sin_addr));
			errno = oerrno;
			perror(0);
			hp->h_addr_list++;
			bcopy(hp->h_addr_list[0], (caddr_t)&sin.sin_addr,
			    hp->h_length);
			fprintf(stderr, "Trying %s...\n",
				inet_ntoa(sin.sin_addr));
			continue;
		}
		perror(hp->h_name);
		sigsetmask(oldmask);
		return (-1);
	}
	lport--;
	if (fd2p == 0) {
		write(s, "", 1);
		lport = 0;
	} else {
		char num[8];
		int s2 = rresvport(&lport), s3;
		int len = sizeof (from);

		if (s2 < 0)
			goto bad;
		listen(s2, 1);
		(void) sprintf(num, "%d", lport);
		if (write(s, num, strlen(num)+1) != strlen(num)+1) {
			perror("write: setting up stderr");
			(void) close(s2);
			goto bad;
		}
		FD_ZERO(&reads);
		FD_SET(s, &reads);
		FD_SET(s2, &reads);
		errno = 0;
		if (select(32, &reads, 0, 0, 0) < 1 ||
		    !FD_ISSET(s2, &reads)) {
			if (errno != 0)
				perror("select: setting up stderr");
			else
			    fprintf(stderr,
				"select: protocol failure in circuit setup.\n");
			(void) close(s2);
			goto bad;
		}
		s3 = accept(s2, &from, &len, 0);
		(void) close(s2);
		if (s3 < 0) {
			perror("accept");
			lport = 0;
			goto bad;
		}
		*fd2p = s3;
		from.sin_port = ntohs((u_short)from.sin_port);
		if (from.sin_family != AF_INET ||
		    from.sin_port >= IPPORT_RESERVED ||
		    from.sin_port < IPPORT_RESERVED / 2) {
			fprintf(stderr,
			    "socket: protocol failure in circuit setup.\n");
			goto bad2;
		}
	}
	(void) write(s, locuser, strlen(locuser)+1);
	(void) write(s, remuser, strlen(remuser)+1);
	(void) write(s, cmd, strlen(cmd)+1);
	if (read(s, &c, 1) != 1) {
		perror(*ahost);
		goto bad2;
	}
	if (c != 0) {
		while (read(s, &c, 1) == 1) {
			(void) write(2, &c, 1);
			if (c == '\n')
				break;
		}
		goto bad2;
	}
	sigsetmask(oldmask);
	return (s);
bad2:
	if (lport)
		(void) close(*fd2p);
bad:
	(void) close(s);
	sigsetmask(oldmask);
	return (-1);
}

rresvport(alport)
	int *alport;
{
	struct sockaddr_in sin;
	int s;

	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = INADDR_ANY;
	s = socket(AF_INET, SOCK_STREAM, 0);
	if (s < 0)
		return (-1);
	for (;;) {
		sin.sin_port = htons((u_short)*alport);
		if (bind(s, (caddr_t)&sin, sizeof (sin)) >= 0)
			return (s);
		if (errno != EADDRINUSE) {
			(void) close(s);
			return (-1);
		}
		(*alport)--;
		if (*alport == IPPORT_RESERVED/2) {
			(void) close(s);
			errno = EAGAIN;		/* close */
			return (-1);
		}
	}
}
#endif /* _MINIX */

int	_check_rhosts_file = 1;

ruserok(rhost, superuser, ruser, luser)
	CONST char *rhost;
	int superuser;
	CONST char *ruser, *luser;
{
	FILE *hostf;
	char fhost[MAXHOSTNAMELEN];
	int first = 1;
	register CONST char *sp;
	register char *p;
	int baselen = -1;

	sp = rhost;
	p = fhost;
	while (*sp) {
		if (*sp == '.') {
			if (baselen == -1)
				baselen = sp - rhost;
			*p++ = *sp++;
		} else {
			*p++ = isupper(*sp) ? tolower(*sp++) : *sp++;
		}
	}
	*p = '\0';
	hostf = superuser ? (FILE *)0 : fopen(_PATH_HEQUIV, "r");
again:
	if (hostf) {
		if (!_validuser(hostf, fhost, luser, ruser, baselen)) {
			(void) fclose(hostf);
			return(0);
		}
		(void) fclose(hostf);
	}
	if (first == 1 && (_check_rhosts_file || superuser)) {
		struct stat sbuf;
		struct passwd *pwd;
		char pbuf[MAXPATHLEN];

		first = 0;
		if ((pwd = getpwnam(luser)) == NULL)
			return(-1);
		(void)strcpy(pbuf, pwd->pw_dir);
		(void)strcat(pbuf, "/.rhosts");
		if ((hostf = fopen(pbuf, "r")) == NULL)
			return(-1);
		/*
		 * if owned by someone other than user or root or if
		 * writeable by anyone but the owner, quit
		 */
		if (fstat(fileno(hostf), &sbuf) ||
		    sbuf.st_uid && sbuf.st_uid != pwd->pw_uid ||
		    sbuf.st_mode&022) {
			fclose(hostf);
			return(-1);
		}
		goto again;
	}
	return (-1);
}

/* don't make static, used by lpd(8) */
int _validuser(hostf, rhost, luser, ruser, baselen)
	FILE *hostf;
	CONST char *rhost, *luser, *ruser;
	int baselen;
{
	char *user;
	char ahost[MAXHOSTNAMELEN];
	register char *p;

	while (fgets(ahost, sizeof (ahost), hostf)) {
		p = ahost;
		while (*p != '\n' && *p != ' ' && *p != '\t' && *p != '\0') {
			*p = isupper(*p) ? tolower(*p) : *p;
			p++;
		}
		if (*p == ' ' || *p == '\t') {
			*p++ = '\0';
			while (*p == ' ' || *p == '\t')
				p++;
			user = p;
			while (*p != '\n' && *p != ' ' && *p != '\t' && *p != '\0')
				p++;
		} else
			user = p;
		*p = '\0';
		if (_checkhost(rhost, ahost, baselen) &&
		    !strcmp(ruser, *user ? user : luser)) {
			return (0);
		}
	}
	return (-1);
}

static int
_checkhost(rhost, lhost, len)
	CONST char *rhost, *lhost;
	int len;
{
	static char ldomain[MAXHOSTNAMELEN + 1];
	static char *domainp = NULL;
	static int nodomain = 0;
	register char *cp;

	if (len == -1)
		return(!strcmp(rhost, lhost));
	if (strncmp(rhost, lhost, len))
		return(0);
	if (!strcmp(rhost, lhost))
		return(1);
	if (*(lhost + len) != '\0')
		return(0);
	if (nodomain)
		return(0);
	if (!domainp) {
		if (gethostname(ldomain, sizeof(ldomain)) == -1) {
			nodomain = 1;
			return(0);
		}
		ldomain[MAXHOSTNAMELEN] = 0;
		if ((domainp = index(ldomain, '.')) == (char *)NULL) {
			nodomain = 1;
			return(0);
		}
		for (cp = ++domainp; *cp; ++cp)
			if (isupper(*cp))
				*cp = tolower(*cp);
	}
	return(!strcmp(domainp, rhost + len +1));
}
