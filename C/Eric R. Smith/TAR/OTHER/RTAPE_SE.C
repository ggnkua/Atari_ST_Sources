/*
 * Copyright (c) 1983 Regents of the University of California.
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

#ifndef lint
char copyright[] =
"@(#) Copyright (c) 1983 Regents of the University of California.\n\
 All rights reserved.\n";
#endif /* not lint */

#ifndef lint
static char sccsid[] = "@(#)rmt.c	5.4 (Berkeley) 6/29/88";
#endif /* not lint */

/* JF added #ifdef about SO_RCVBUF in attempt to make this run on more
   machines.  Maybe it'll work */
/*
 * rmt
 */
#include <stdio.h>
#include <sgtty.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/mtio.h>
#include <errno.h>

int	tape = -1;

char	*record;
int	maxrecsize = -1;
char	*checkbuf();

#define	SSIZE	64
char	device[SSIZE];
char	count[SSIZE], mode[SSIZE], pos[SSIZE], op[SSIZE];

extern	errno;
char	*sys_errlist[];
char	resp[BUFSIZ];

long	lseek();

FILE	*debug;
#define	DEBUG(f)	if (debug) fprintf(debug, f)
#define	DEBUG1(f,a)	if (debug) fprintf(debug, f, a)
#define	DEBUG2(f,a1,a2)	if (debug) fprintf(debug, f, a1, a2)

main(argc, argv)
	int argc;
	char **argv;
{
	int rval;
	char c;
	int n, i, cc;

	argc--, argv++;
	if (argc > 0) {
		debug = fopen(*argv, "w");
		if (debug == 0)
			exit(1);
		(void) setbuf(debug, (char *)0);
	}
top:
	errno = 0;
	rval = 0;
	if (read(0, &c, 1) != 1)
		exit(0);
	switch (c) {

	case 'O':
		if (tape >= 0)
			(void) close(tape);
		getstring(device); getstring(mode);
		DEBUG2("rmtd: O %s %s\n", device, mode);
		tape = open(device, atoi(mode),0666);
		if (tape < 0)
			goto ioerror;
		goto respond;

	case 'C':
		DEBUG("rmtd: C\n");
		getstring(device);		/* discard */
		if (close(tape) < 0)
			goto ioerror;
		tape = -1;
		goto respond;

	case 'L':
		getstring(count); getstring(pos);
		DEBUG2("rmtd: L %s %s\n", count, pos);
		rval = lseek(tape, (long) atoi(count), atoi(pos));
		if (rval < 0)
			goto ioerror;
		goto respond;

	case 'W':
		getstring(count);
		n = atoi(count);
		DEBUG1("rmtd: W %s\n", count);
		record = checkbuf(record, n);
		for (i = 0; i < n; i += cc) {
			cc = read(0, &record[i], n - i);
			if (cc <= 0) {
				DEBUG("rmtd: premature eof\n");
				exit(2);
			}
		}
		rval = write(tape, record, n);
		if (rval < 0)
			goto ioerror;
		goto respond;

	case 'R':
		getstring(count);
		DEBUG1("rmtd: R %s\n", count);
		n = atoi(count);
		record = checkbuf(record, n);
		rval = read(tape, record, n);
		if (rval < 0)
			goto ioerror;
		(void) sprintf(resp, "A%d\n", rval);
		(void) write(1, resp, strlen(resp));
		(void) write(1, record, rval);
		goto top;

	case 'I':
		getstring(op); getstring(count);
		DEBUG2("rmtd: I %s %s\n", op, count);
		{ struct mtop mtop;
		  mtop.mt_op = atoi(op);
		  mtop.mt_count = atoi(count);
		  if (ioctl(tape, MTIOCTOP, (char *)&mtop) < 0)
			goto ioerror;
		  rval = mtop.mt_count;
		}
		goto respond;

	case 'S':		/* status */
		DEBUG("rmtd: S\n");
		{ struct mtget mtget;
		  if (ioctl(tape, MTIOCGET, (char *)&mtget) < 0)
			goto ioerror;
		  rval = sizeof (mtget);
		  (void) sprintf(resp, "A%d\n", rval);
		  (void) write(1, resp, strlen(resp));
		  (void) write(1, (char *)&mtget, sizeof (mtget));
		  goto top;
		}

	default:
		DEBUG1("rmtd: garbage command %c\n", c);
		exit(3);
	}
respond:
	DEBUG1("rmtd: A %d\n", rval);
	(void) sprintf(resp, "A%d\n", rval);
	(void) write(1, resp, strlen(resp));
	goto top;
ioerror:
	error(errno);
	goto top;
}

getstring(bp)
	char *bp;
{
	int i;
	char *cp = bp;

	for (i = 0; i < SSIZE; i++) {
		if (read(0, cp+i, 1) != 1)
			exit(0);
		if (cp[i] == '\n')
			break;
	}
	cp[i] = '\0';
}

char *
checkbuf(record, size)
	char *record;
	int size;
{
	extern char *malloc();

	if (size <= maxrecsize)
		return (record);
	if (record != 0)
		free(record);
	record = malloc(size);
	if (record == 0) {
		DEBUG("rmtd: cannot allocate buffer space\n");
		exit(4);
	}
	maxrecsize = size;
#ifdef SO_RCVBUF
	while (size > 1024 &&
	       setsockopt(0, SOL_SOCKET, SO_RCVBUF, &size, sizeof (size)) < 0)
		size -= 1024;
#else
	size= 1+((size-1)%1024);
#endif
	return (record);
}

error(num)
	int num;
{

	DEBUG2("rmtd: E %d (%s)\n", num, sys_errlist[num]);
	(void) sprintf(resp, "E%d\n%s\n", num, sys_errlist[num]);
	(void) write(1, resp, strlen (resp));
}
